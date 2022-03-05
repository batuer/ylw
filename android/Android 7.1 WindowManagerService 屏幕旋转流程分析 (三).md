# Android 7.1 WindowManagerService 屏幕旋转流程分析 (三)

# 三、屏幕的绘制

performSurfacePlacement（）函数来触发window的绘制，这里最大的循环次数是6，当然一般不会到最大次数就会被Scheduled。

```java
final void performSurfacePlacement() {
        if (mDeferDepth > 0) {
            return;
        }
        int loopCount = 6;
        do {
            mTraversalScheduled = false;
            performSurfacePlacementLoop();
            mService.mH.removeMessages(DO_TRAVERSAL);
            loopCount--;
        } while (mTraversalScheduled && loopCount > 0);
        mWallpaperActionPending = false;
    }
```

等待configuration变更完成的report后才会执行做window layout的更新

```java
private void performSurfacePlacementLoop() {
        if (mInLayout) {
            if (DEBUG) {
                throw new RuntimeException("Recursive call!");
            }
            Slog.w(TAG, "performLayoutAndPlaceSurfacesLocked called while in layout. Callers="
                    + Debug.getCallers(3));
            return;
        }
        //等待configuration变更完成的report
        if (mService.mWaitingForConfig) {
            // Our configuration has changed (most likely rotation), but we
            // don't yet have the complete configuration to report to
            // applications.  Don't do any window layout until we have it.
            return;
        }
 
        if (!mService.mDisplayReady) {
            // Not yet initialized, nothing to do.
            return;
        }
 
        Trace.traceBegin(Trace.TRACE_TAG_WINDOW_MANAGER, "wmLayout");
        mInLayout = true;
 
        boolean recoveringMemory = false;
        if (!mService.mForceRemoves.isEmpty()) {
            recoveringMemory = true;
            // Wait a little bit for things to settle down, and off we go.
            while (!mService.mForceRemoves.isEmpty()) {
                WindowState ws = mService.mForceRemoves.remove(0);
                Slog.i(TAG, "Force removing: " + ws);
                mService.removeWindowInnerLocked(ws);
            }
            Slog.w(TAG, "Due to memory failure, waiting a bit for next layout");
            Object tmp = new Object();
            synchronized (tmp) {
                try {
                    tmp.wait(250);
                } catch (InterruptedException e) {
                }
            }
        }
 
        try {
            performSurfacePlacementInner(recoveringMemory);
 
            mInLayout = false;
 
            if (mService.needsLayout()) {
                if (++mLayoutRepeatCount < 6) {
                    requestTraversal();
                } else {
                    Slog.e(TAG, "Performed 6 layouts in a row. Skipping");
                    mLayoutRepeatCount = 0;
                }
            } else {
                mLayoutRepeatCount = 0;
            }
             // 发REPORT_WINDOWS_CHANGE消息
            if (mService.mWindowsChanged && !mService.mWindowChangeListeners.isEmpty()) {
                mService.mH.removeMessages(REPORT_WINDOWS_CHANGE);
                mService.mH.sendEmptyMessage(REPORT_WINDOWS_CHANGE);
            }
        } catch (RuntimeException e) {
            mInLayout = false;
            Slog.wtf(TAG, "Unhandled exception while laying out windows", e);
        }
 
        Trace.traceEnd(Trace.TRACE_TAG_WINDOW_MANAGER);
    }
```

先来看一个整体流程图，后面详细展开：

![img](https://upload-images.jianshu.io/upload_images/2088926-139e6996b357ba18.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 1）windowManagerService:removeWindowInnerLocked()

**遍历整个win树将其下所有的Child Windows都remove：**
（1）首先通过moveInputMethodWindowsIfNeededLocked() 优先处理IME输入的window
（2）windowManagerService:scheduleRemoveStartingWindowLocked()调度Remove Window操作
（3）InputMonitor:updateInputWindowsLw() 将window更新到InputManagerService的dispatcher中，以便接受Input事件

```java
void removeWindowInnerLocked(WindowState win) {
        if (win.mRemoved) {
            // Nothing to do.
            if (DEBUG_ADD_REMOVE) Slog.v(TAG_WM,
                    "removeWindowInnerLocked: " + win + " Already removed...");
            return;
        }
 
        for (int i = win.mChildWindows.size() - 1; i >= 0; i--) {
            WindowState cwin = win.mChildWindows.get(i);
            Slog.w(TAG_WM, "Force-removing child win " + cwin + " from container " + win);
            //嵌套调用 remove 所有的Child Windows
            removeWindowInnerLocked(cwin);
        }
 
        win.mRemoved = true;
 
        if (mInputMethodTarget == win) {
            moveInputMethodWindowsIfNeededLocked(false);
        }
 
        if (false) {
            RuntimeException e = new RuntimeException("here");
            e.fillInStackTrace();
            Slog.w(TAG_WM, "Removing window " + win, e);
        }
 
        final int type = win.mAttrs.type;
        if (excludeWindowTypeFromTapOutTask(type)) {
            final DisplayContent displaycontent = win.getDisplayContent();
            displaycontent.mTapExcludedWindows.remove(win);
        }
        mPolicy.removeWindowLw(win);
        win.removeLocked();
 
        if (DEBUG_ADD_REMOVE) Slog.v(TAG_WM, "removeWindowInnerLocked: " + win);
        mWindowMap.remove(win.mClient.asBinder());
        if (win.mAppOp != AppOpsManager.OP_NONE) {
            mAppOps.finishOp(win.mAppOp, win.getOwningUid(), win.getOwningPackage());
        }
 
        mPendingRemove.remove(win);
        mResizingWindows.remove(win);
        mWindowsChanged = true;
        if (DEBUG_WINDOW_MOVEMENT) Slog.v(TAG_WM, "Final remove of window: " + win);
 
        if (mInputMethodWindow == win) {
            mInputMethodWindow = null;
        } else if (win.mAttrs.type == TYPE_INPUT_METHOD_DIALOG) {
            mInputMethodDialogs.remove(win);
        }
 
        final WindowToken token = win.mToken;
        final AppWindowToken atoken = win.mAppToken;
        if (DEBUG_ADD_REMOVE) Slog.v(TAG_WM, "Removing " + win + " from " + token);
        token.windows.remove(win);
        if (atoken != null) {
            atoken.allAppWindows.remove(win);
        }
        if (localLOGV) Slog.v(
                TAG_WM, "**** Removing window " + win + ": count="
                + token.windows.size());
        if (token.windows.size() == 0) {
            if (!token.explicit) {
                mTokenMap.remove(token.token);
            } else if (atoken != null) {
                atoken.firstWindowDrawn = false;
                atoken.clearAllDrawn();
            }
        }
 
        if (atoken != null) {
            if (atoken.startingWindow == win) {
                if (DEBUG_STARTING_WINDOW) Slog.v(TAG_WM, "Notify removed startingWindow " + win);
                scheduleRemoveStartingWindowLocked(atoken);
            } else
            if (atoken.allAppWindows.size() == 0 && atoken.startingData != null) {
                // If this is the last window and we had requested a starting
                // transition window, well there is no point now.
                if (DEBUG_STARTING_WINDOW) Slog.v(TAG_WM, "Nulling last startingWindow");
                atoken.startingData = null;
            } else if (atoken.allAppWindows.size() == 1 && atoken.startingView != null) {
                // If this is the last window except for a starting transition
                // window, we need to get rid of the starting transition.
                scheduleRemoveStartingWindowLocked(atoken);
            }
        }
 
        if (type == TYPE_WALLPAPER) {
            mWallpaperControllerLocked.clearLastWallpaperTimeoutTime();
            getDefaultDisplayContentLocked().pendingLayoutChanges |=
                    WindowManagerPolicy.FINISH_LAYOUT_REDO_WALLPAPER;
        } else if ((win.mAttrs.flags&FLAG_SHOW_WALLPAPER) != 0) {
            getDefaultDisplayContentLocked().pendingLayoutChanges |=
                    WindowManagerPolicy.FINISH_LAYOUT_REDO_WALLPAPER;
        }
 
        final WindowList windows = win.getWindowList();
        if (windows != null) {
            windows.remove(win);
            if (!mWindowPlacerLocked.isInLayout()) {
                mLayersController.assignLayersLocked(windows);
                win.setDisplayLayoutNeeded();
                mWindowPlacerLocked.performSurfacePlacement();
                if (win.mAppToken != null) {
                    win.mAppToken.updateReportedVisibilityLocked();
                }
            }
        }
 
        mInputMonitor.updateInputWindowsLw(true /*force*/);
    }
```

**A:moveInputMethodWindowsIfNeededLocked()**

首先遍历找到有IME输入的window，如果需要分配Layer则调用LayersController.assignLayersLocked（）如果出现了旋转后出现正在输入的位置不正常，应该知道从哪里入手了吧 ^_^

```java
boolean moveInputMethodWindowsIfNeededLocked(boolean needAssignLayers) {
        final WindowState imWin = mInputMethodWindow;
        final int DN = mInputMethodDialogs.size();
        if (imWin == null && DN == 0) {
            return false;
        }
 
        // TODO(multidisplay): IMEs are only supported on the default display.
        WindowList windows = getDefaultWindowListLocked();
 
        int imPos = findDesiredInputMethodWindowIndexLocked(true);
        if (imPos >= 0) {
            // In this case, the input method windows are to be placed
            // immediately above the window they are targeting.
 
            // First check to see if the input method windows are already
            // located here, and contiguous.
            final int N = windows.size();
            WindowState firstImWin = imPos < N
                    ? windows.get(imPos) : null;
 
            // Figure out the actual input method window that should be
            // at the bottom of their stack.
            WindowState baseImWin = imWin != null
                    ? imWin : mInputMethodDialogs.get(0);
            if (baseImWin.mChildWindows.size() > 0) {
                WindowState cw = baseImWin.mChildWindows.get(0);
                if (cw.mSubLayer < 0) baseImWin = cw;
            }
 
            if (firstImWin == baseImWin) {
                // The windows haven't moved...  but are they still contiguous?
                // First find the top IM window.
                int pos = imPos+1;
                while (pos < N) {
                    if (!(windows.get(pos)).mIsImWindow) {
                        break;
                    }
                    pos++;
                }
                pos++;
                // Now there should be no more input method windows above.
                while (pos < N) {
                    if ((windows.get(pos)).mIsImWindow) {
                        break;
                    }
                    pos++;
                }
                if (pos >= N) {
                    // Z order is good.
                    // The IM target window may be changed, so update the mTargetAppToken.
                    if (imWin != null) {
                        imWin.mTargetAppToken = mInputMethodTarget.mAppToken;
                    }
                    return false;
                }
            }
 
            if (imWin != null) {
                if (DEBUG_INPUT_METHOD) {
                    Slog.v(TAG_WM, "Moving IM from " + imPos);
                    logWindowList(windows, "  ");
                }
                imPos = tmpRemoveWindowLocked(imPos, imWin);
                if (DEBUG_INPUT_METHOD) {
                    Slog.v(TAG_WM, "List after removing with new pos " + imPos + ":");
                    logWindowList(windows, "  ");
                }
                imWin.mTargetAppToken = mInputMethodTarget.mAppToken;
                reAddWindowLocked(imPos, imWin);
                if (DEBUG_INPUT_METHOD) {
                    Slog.v(TAG_WM, "List after moving IM to " + imPos + ":");
                    logWindowList(windows, "  ");
                }
                if (DN > 0) moveInputMethodDialogsLocked(imPos+1);
            } else {
                moveInputMethodDialogsLocked(imPos);
            }
 
        } else {
            // In this case, the input method windows go in a fixed layer,
            // because they aren't currently associated with a focus window.
 
            if (imWin != null) {
                if (DEBUG_INPUT_METHOD) Slog.v(TAG_WM, "Moving IM from " + imPos);
                tmpRemoveWindowLocked(0, imWin);
                imWin.mTargetAppToken = null;
                reAddWindowToListInOrderLocked(imWin);
                if (DEBUG_INPUT_METHOD) {
                    Slog.v(TAG_WM, "List with no IM target:");
                    logWindowList(windows, "  ");
                }
                if (DN > 0) moveInputMethodDialogsLocked(-1);
            } else {
                moveInputMethodDialogsLocked(-1);
            }
 
        }
 
        if (needAssignLayers) {
            mLayersController.assignLayersLocked(windows);
        }
 
        return true;
    }
```

**B: scheduleRemoveStartingWindowLocked()**
   通过发送REMOVE_STARTING消息来调度Remove Window操作。

```java
void scheduleRemoveStartingWindowLocked(AppWindowToken wtoken) {
        if (wtoken == null) {
            return;
        }
        if (mH.hasMessages(H.REMOVE_STARTING, wtoken)) {
            // Already scheduled.
            return;
        }
 
        if (wtoken.startingWindow == null) {
            if (wtoken.startingData != null) {
                // Starting window has not been added yet, but it is scheduled to be added.
                // Go ahead and cancel the request.
                if (DEBUG_STARTING_WINDOW) Slog.v(TAG_WM,
                        "Clearing startingData for token=" + wtoken);
                wtoken.startingData = null;
            }
            return;
        }
 
        if (DEBUG_STARTING_WINDOW) Slog.v(TAG_WM, Debug.getCallers(1) +
                ": Schedule remove starting " + wtoken + (wtoken != null ?
                " startingWindow=" + wtoken.startingWindow : ""));
        Message m = mH.obtainMessage(H.REMOVE_STARTING, wtoken);
        mH.sendMessage(m);
    }
```

**C:InputMonitor.updateInputWindowsLw()**

将已经缓存（ cached）window 更新到 InputManagerService的dispatcher中，以便接受Input 事件。

```java
public void updateInputWindowsLw(boolean force) {
        if (!force && !mUpdateInputWindowsNeeded) {
            return;
        }
        mUpdateInputWindowsNeeded = false;
 
        if (false) Slog.d(TAG_WM, ">>>>>> ENTERED updateInputWindowsLw");
 
        // Populate the input window list with information about all of the windows that
        // could potentially receive input.
        // As an optimization, we could try to prune the list of windows but this turns
        // out to be difficult because only the native code knows for sure which window
        // currently has touch focus.
        boolean disableWallpaperTouchEvents = false;
 
        // If there's a drag in flight, provide a pseudowindow to catch drag input
        final boolean inDrag = (mService.mDragState != null);
        if (inDrag) {
            if (DEBUG_DRAG) {
                Log.d(TAG_WM, "Inserting drag window");
            }
            final InputWindowHandle dragWindowHandle = mService.mDragState.mDragWindowHandle;
            if (dragWindowHandle != null) {
                addInputWindowHandleLw(dragWindowHandle);
            } else {
                Slog.w(TAG_WM, "Drag is in progress but there is no "
                        + "drag window handle.");
            }
        }
 
        final boolean inPositioning = (mService.mTaskPositioner != null);
        if (inPositioning) {
            if (DEBUG_TASK_POSITIONING) {
                Log.d(TAG_WM, "Inserting window handle for repositioning");
            }
            final InputWindowHandle dragWindowHandle = mService.mTaskPositioner.mDragWindowHandle;
            if (dragWindowHandle != null) {
                addInputWindowHandleLw(dragWindowHandle);
            } else {
                Slog.e(TAG_WM,
                        "Repositioning is in progress but there is no drag window handle.");
            }
        }
 
        boolean addInputConsumerHandle = mService.mInputConsumer != null;
 
        boolean addWallpaperInputConsumerHandle = mService.mWallpaperInputConsumer != null;
 
        // Add all windows on the default display.
        final int numDisplays = mService.mDisplayContents.size();
        final WallpaperController wallpaperController = mService.mWallpaperControllerLocked;
        for (int displayNdx = 0; displayNdx < numDisplays; ++displayNdx) {
            final DisplayContent displayContent = mService.mDisplayContents.valueAt(displayNdx);
            final WindowList windows = displayContent.getWindowList();
            for (int winNdx = windows.size() - 1; winNdx >= 0; --winNdx) {
                final WindowState child = windows.get(winNdx);
                final InputChannel inputChannel = child.mInputChannel;
                final InputWindowHandle inputWindowHandle = child.mInputWindowHandle;
                if (inputChannel == null || inputWindowHandle == null || child.mRemoved
                        || child.isAdjustedForMinimizedDock()) {
                    // Skip this window because it cannot possibly receive input.
                    continue;
                }
                if (addInputConsumerHandle
                        && inputWindowHandle.layer <= mService.mInputConsumer.mWindowHandle.layer) {
                    addInputWindowHandleLw(mService.mInputConsumer.mWindowHandle);
                    addInputConsumerHandle = false;
                }
 
                if (addWallpaperInputConsumerHandle) {
                    if (child.mAttrs.type == WindowManager.LayoutParams.TYPE_WALLPAPER) {
                        // Add the wallpaper input consumer above the first wallpaper window.
                        addInputWindowHandleLw(mService.mWallpaperInputConsumer.mWindowHandle);
                        addWallpaperInputConsumerHandle = false;
                    }
                }
 
                final int flags = child.mAttrs.flags;
                final int privateFlags = child.mAttrs.privateFlags;
                final int type = child.mAttrs.type;
 
                final boolean hasFocus = (child == mInputFocus);
                final boolean isVisible = child.isVisibleLw();
                if ((privateFlags
                        & WindowManager.LayoutParams.PRIVATE_FLAG_DISABLE_WALLPAPER_TOUCH_EVENTS)
                            != 0) {
                    disableWallpaperTouchEvents = true;
                }
                final boolean hasWallpaper = wallpaperController.isWallpaperTarget(child)
                        && (privateFlags & WindowManager.LayoutParams.PRIVATE_FLAG_KEYGUARD) == 0
                        && !disableWallpaperTouchEvents;
                final boolean onDefaultDisplay = (child.getDisplayId() == Display.DEFAULT_DISPLAY);
 
                // If there's a drag in progress and 'child' is a potential drop target,
                // make sure it's been told about the drag
                if (inDrag && isVisible && onDefaultDisplay) {
                    mService.mDragState.sendDragStartedIfNeededLw(child);
                }
 
                addInputWindowHandleLw(
                        inputWindowHandle, child, flags, type, isVisible, hasFocus, hasWallpaper);
            }
        }
 
        if (addWallpaperInputConsumerHandle) {
            // No wallpaper found, add the wallpaper input consumer at the end.
            addInputWindowHandleLw(mService.mWallpaperInputConsumer.mWindowHandle);
        }
 
        // Send windows to native code.
        mService.mInputManager.setInputWindows(mInputWindowHandles);
 
        // Clear the list in preparation for the next round.
        clearInputWindowHandlesLw();
 
        if (false) Slog.d(TAG_WM, "<<<<<<< EXITED updateInputWindowsLw");
    }
```

## 2）performSurfacePlacementInner（）

这个函数很长，主要是对一些状态的更新和设置，每段注释比较清晰，不在赘述。

```java
performSurfacePlacementInner（）
    {
        if (DEBUG_WINDOW_TRACE) Slog.v(TAG, "performSurfacePlacementInner: entry. Called by "
                + Debug.getCallers(3));
 
        int i;
        boolean updateInputWindowsNeeded = false;
 
        if (mService.mFocusMayChange) {
            mService.mFocusMayChange = false;
            updateInputWindowsNeeded = mService.updateFocusedWindowLocked(
                    UPDATE_FOCUS_WILL_PLACE_SURFACES, false /*updateInputWindows*/);
        }
 
        // Initialize state of exiting tokens.
        final int numDisplays = mService.mDisplayContents.size();
        for (int displayNdx = 0; displayNdx < numDisplays; ++displayNdx) {
            final DisplayContent displayContent = mService.mDisplayContents.valueAt(displayNdx);
            for (i=displayContent.mExitingTokens.size()-1; i>=0; i--) {
                displayContent.mExitingTokens.get(i).hasVisible = false;
            }
        }
 
        for (int stackNdx = mService.mStackIdToStack.size() - 1; stackNdx >= 0; --stackNdx) {
            // Initialize state of exiting applications.
            final AppTokenList exitingAppTokens =
                    mService.mStackIdToStack.valueAt(stackNdx).mExitingAppTokens;
            for (int tokenNdx = exitingAppTokens.size() - 1; tokenNdx >= 0; --tokenNdx) {
                exitingAppTokens.get(tokenNdx).hasVisible = false;
            }
        }
 
        mHoldScreen = null;
        mHoldScreenWindow = null;
        mObsuringWindow = null;
        mScreenBrightness = -1;
        mButtonBrightness = -1;
        mUserActivityTimeout = -1;
        mObscureApplicationContentOnSecondaryDisplays = false;
        mSustainedPerformanceModeCurrent = false;
        mService.mTransactionSequence++;
 
        final DisplayContent defaultDisplay = mService.getDefaultDisplayContentLocked();
        final DisplayInfo defaultInfo = defaultDisplay.getDisplayInfo();
        final int defaultDw = defaultInfo.logicalWidth;
        final int defaultDh = defaultInfo.logicalHeight;
 
        if (SHOW_LIGHT_TRANSACTIONS) Slog.i(TAG,
                ">>> OPEN TRANSACTION performLayoutAndPlaceSurfaces");
        SurfaceControl.openTransaction();
        try {
            applySurfaceChangesTransaction(recoveringMemory, numDisplays, defaultDw, defaultDh);
        } catch (RuntimeException e) {
            Slog.wtf(TAG, "Unhandled exception in Window Manager", e);
        } finally {
            SurfaceControl.closeTransaction();
            if (SHOW_LIGHT_TRANSACTIONS) Slog.i(TAG,
                    "<<< CLOSE TRANSACTION performLayoutAndPlaceSurfaces");
        }
 
        final WindowList defaultWindows = defaultDisplay.getWindowList();
 
        // If we are ready to perform an app transition, check through
        // all of the app tokens to be shown and see if they are ready
        // to go.
        if (mService.mAppTransition.isReady()) {
            defaultDisplay.pendingLayoutChanges |= handleAppTransitionReadyLocked(defaultWindows);
            if (DEBUG_LAYOUT_REPEATS)
                debugLayoutRepeats("after handleAppTransitionReadyLocked",
                        defaultDisplay.pendingLayoutChanges);
        }
 
        if (!mService.mAnimator.mAppWindowAnimating && mService.mAppTransition.isRunning()) {
            // We have finished the animation of an app transition.  To do
            // this, we have delayed a lot of operations like showing and
            // hiding apps, moving apps in Z-order, etc.  The app token list
            // reflects the correct Z-order, but the window list may now
            // be out of sync with it.  So here we will just rebuild the
            // entire app window list.  Fun!
            defaultDisplay.pendingLayoutChanges |=
                    mService.handleAnimatingStoppedAndTransitionLocked();
            if (DEBUG_LAYOUT_REPEATS)
                debugLayoutRepeats("after handleAnimStopAndXitionLock",
                        defaultDisplay.pendingLayoutChanges);
        }
 
        if (mWallpaperForceHidingChanged && defaultDisplay.pendingLayoutChanges == 0
                && !mService.mAppTransition.isReady()) {
            // At this point, there was a window with a wallpaper that
            // was force hiding other windows behind it, but now it
            // is going away.  This may be simple -- just animate
            // away the wallpaper and its window -- or it may be
            // hard -- the wallpaper now needs to be shown behind
            // something that was hidden.
            defaultDisplay.pendingLayoutChanges |= FINISH_LAYOUT_REDO_LAYOUT;
            if (DEBUG_LAYOUT_REPEATS)
                debugLayoutRepeats("after animateAwayWallpaperLocked",
                        defaultDisplay.pendingLayoutChanges);
        }
        mWallpaperForceHidingChanged = false;
 
        if (mWallpaperMayChange) {
            if (DEBUG_WALLPAPER_LIGHT)
                Slog.v(TAG, "Wallpaper may change!  Adjusting");
            defaultDisplay.pendingLayoutChanges |= FINISH_LAYOUT_REDO_WALLPAPER;
            if (DEBUG_LAYOUT_REPEATS) debugLayoutRepeats("WallpaperMayChange",
                    defaultDisplay.pendingLayoutChanges);
        }
 
        if (mService.mFocusMayChange) {
            mService.mFocusMayChange = false;
            if (mService.updateFocusedWindowLocked(UPDATE_FOCUS_PLACING_SURFACES,
                    false /*updateInputWindows*/)) {
                updateInputWindowsNeeded = true;
                defaultDisplay.pendingLayoutChanges |= FINISH_LAYOUT_REDO_ANIM;
            }
        }
 
        if (mService.needsLayout()) {
            defaultDisplay.pendingLayoutChanges |= FINISH_LAYOUT_REDO_LAYOUT;
            if (DEBUG_LAYOUT_REPEATS) debugLayoutRepeats("mLayoutNeeded",
                    defaultDisplay.pendingLayoutChanges);
        }
 
        for (i = mService.mResizingWindows.size() - 1; i >= 0; i--) {
            WindowState win = mService.mResizingWindows.get(i);
            if (win.mAppFreezing) {
                // Don't remove this window until rotation has completed.
                continue;
            }
            // Discard the saved surface if window size is changed, it can't be reused.
            if (win.mAppToken != null) {
                win.mAppToken.destroySavedSurfaces();
            }
            win.reportResized();
            mService.mResizingWindows.remove(i);
        }
 
        if (DEBUG_ORIENTATION && mService.mDisplayFrozen) Slog.v(TAG,
                "With display frozen, orientationChangeComplete=" + mOrientationChangeComplete);
        if (mOrientationChangeComplete) {
            if (mService.mWindowsFreezingScreen != WINDOWS_FREEZING_SCREENS_NONE) {
                mService.mWindowsFreezingScreen = WINDOWS_FREEZING_SCREENS_NONE;
                mService.mLastFinishedFreezeSource = mLastWindowFreezeSource;
                mService.mH.removeMessages(WINDOW_FREEZE_TIMEOUT);
            }
            mService.stopFreezingDisplayLocked();
        }
 
        // Destroy the surface of any windows that are no longer visible.
        boolean wallpaperDestroyed = false;
        i = mService.mDestroySurface.size();
        if (i > 0) {
            do {
                i--;
                WindowState win = mService.mDestroySurface.get(i);
                win.mDestroying = false;
                if (mService.mInputMethodWindow == win) {
                    mService.mInputMethodWindow = null;
                }
                if (mWallpaperControllerLocked.isWallpaperTarget(win)) {
                    wallpaperDestroyed = true;
                }
                win.destroyOrSaveSurface();
            } while (i > 0);
            mService.mDestroySurface.clear();
        }
 
        // Time to remove any exiting tokens?
        for (int displayNdx = 0; displayNdx < numDisplays; ++displayNdx) {
            final DisplayContent displayContent = mService.mDisplayContents.valueAt(displayNdx);
            ArrayList<WindowToken> exitingTokens = displayContent.mExitingTokens;
            for (i = exitingTokens.size() - 1; i >= 0; i--) {
                WindowToken token = exitingTokens.get(i);
                if (!token.hasVisible) {
                    exitingTokens.remove(i);
                    if (token.windowType == TYPE_WALLPAPER) {
                        mWallpaperControllerLocked.removeWallpaperToken(token);
                    }
                }
            }
        }
 
        // Time to remove any exiting applications?
        for (int stackNdx = mService.mStackIdToStack.size() - 1; stackNdx >= 0; --stackNdx) {
            // Initialize state of exiting applications.
            final AppTokenList exitingAppTokens =
                    mService.mStackIdToStack.valueAt(stackNdx).mExitingAppTokens;
            for (i = exitingAppTokens.size() - 1; i >= 0; i--) {
                AppWindowToken token = exitingAppTokens.get(i);
                if (!token.hasVisible && !mService.mClosingApps.contains(token) &&
                        (!token.mIsExiting || token.allAppWindows.isEmpty())) {
                    // Make sure there is no animation running on this token,
                    // so any windows associated with it will be removed as
                    // soon as their animations are complete
                    token.mAppAnimator.clearAnimation();
                    token.mAppAnimator.animating = false;
                    if (DEBUG_ADD_REMOVE || DEBUG_TOKEN_MOVEMENT) Slog.v(TAG,
                            "performLayout: App token exiting now removed" + token);
                    token.removeAppFromTaskLocked();
                }
            }
        }
 
        if (wallpaperDestroyed) {
            defaultDisplay.pendingLayoutChanges |= FINISH_LAYOUT_REDO_WALLPAPER;
            defaultDisplay.layoutNeeded = true;
        }
 
        for (int displayNdx = 0; displayNdx < numDisplays; ++displayNdx) {
            final DisplayContent displayContent = mService.mDisplayContents.valueAt(displayNdx);
            if (displayContent.pendingLayoutChanges != 0) {
                displayContent.layoutNeeded = true;
            }
        }
 
        // Finally update all input windows now that the window changes have stabilized.
        mService.mInputMonitor.updateInputWindowsLw(true /*force*/);
 
        mService.setHoldScreenLocked(mHoldScreen);
        if (!mService.mDisplayFrozen) {
            if (mScreenBrightness < 0 || mScreenBrightness > 1.0f) {
                mService.mPowerManagerInternal.setScreenBrightnessOverrideFromWindowManager(-1);
            } else {
                mService.mPowerManagerInternal.setScreenBrightnessOverrideFromWindowManager(
                        toBrightnessOverride(mScreenBrightness));
            }
            if (mButtonBrightness < 0
                    || mButtonBrightness > 1.0f) {
                mService.mPowerManagerInternal.setButtonBrightnessOverrideFromWindowManager(-1);
            } else {
                mService.mPowerManagerInternal.setButtonBrightnessOverrideFromWindowManager(
                        toBrightnessOverride(mButtonBrightness));
            }
            mService.mPowerManagerInternal.setUserActivityTimeoutOverrideFromWindowManager(
                    mUserActivityTimeout);
        }
 
        if (mSustainedPerformanceModeCurrent != mSustainedPerformanceModeEnabled) {
            mSustainedPerformanceModeEnabled = mSustainedPerformanceModeCurrent;
            mService.mPowerManagerInternal.powerHint(
                    mService.mPowerManagerInternal.POWER_HINT_SUSTAINED_PERFORMANCE_MODE,
                    (mSustainedPerformanceModeEnabled ? 1 : 0));
        }
 
        if (mService.mTurnOnScreen) {
            if (mService.mAllowTheaterModeWakeFromLayout
                    || Settings.Global.getInt(mService.mContext.getContentResolver(),
                        Settings.Global.THEATER_MODE_ON, 0) == 0) {
                if (DEBUG_VISIBILITY || DEBUG_POWER) {
                    Slog.v(TAG, "Turning screen on after layout!");
                }
                mService.mPowerManager.wakeUp(SystemClock.uptimeMillis(),
                        "android.server.wm:TURN_ON");
            }
            mService.mTurnOnScreen = false;
        }
 
        if (mUpdateRotation) {
            if (DEBUG_ORIENTATION) Slog.d(TAG, "Performing post-rotate rotation");
            if (mService.updateRotationUncheckedLocked(false)) {
                mService.mH.sendEmptyMessage(SEND_NEW_CONFIGURATION);
            } else {
                mUpdateRotation = false;
            }
        }
 
        if (mService.mWaitingForDrawnCallback != null ||
                (mOrientationChangeComplete && !defaultDisplay.layoutNeeded &&
                        !mUpdateRotation)) {
            mService.checkDrawnWindowsLocked();
        }
 
        final int N = mService.mPendingRemove.size();
        if (N > 0) {
            if (mService.mPendingRemoveTmp.length < N) {
                mService.mPendingRemoveTmp = new WindowState[N+10];
            }
            mService.mPendingRemove.toArray(mService.mPendingRemoveTmp);
            mService.mPendingRemove.clear();
            DisplayContentList displayList = new DisplayContentList();
            for (i = 0; i < N; i++) {
                WindowState w = mService.mPendingRemoveTmp[i];
                mService.removeWindowInnerLocked(w);
                final DisplayContent displayContent = w.getDisplayContent();
                if (displayContent != null && !displayList.contains(displayContent)) {
                    displayList.add(displayContent);
                }
            }
 
            for (DisplayContent displayContent : displayList) {
                mService.mLayersController.assignLayersLocked(displayContent.getWindowList());
                displayContent.layoutNeeded = true;
            }
        }
 
        // Remove all deferred displays stacks, tasks, and activities.
        for (int displayNdx = mService.mDisplayContents.size() - 1; displayNdx >= 0; --displayNdx) {
            mService.mDisplayContents.valueAt(displayNdx).checkForDeferredActions();
        }
 
        if (updateInputWindowsNeeded) {
            mService.mInputMonitor.updateInputWindowsLw(false /*force*/);
        }
        mService.setFocusTaskRegionLocked();
 
        // Check to see if we are now in a state where the screen should
        // be enabled, because the window obscured flags have changed.
        mService.enableScreenIfNeededLocked();
 
        mService.scheduleAnimationLocked();
        mService.mWindowPlacerLocked.destroyPendingSurfaces();
 
        if (DEBUG_WINDOW_TRACE) Slog.e(TAG,
                "performSurfacePlacementInner exit: animating=" + mService.mAnimator.isAnimating());
    }
```

## 3）requestTraversal（）

```java
void requestTraversal() {
        if (!mTraversalScheduled) {
            mTraversalScheduled = true;
            mService.mH.sendEmptyMessage(DO_TRAVERSAL);
        }
    }
```

