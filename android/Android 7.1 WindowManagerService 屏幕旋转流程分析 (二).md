# Android 7.1 WindowManagerService 屏幕旋转流程分析 (二)

# 一、概述

从上篇【Android 7.1 屏幕旋转流程分析】知道实际的旋转由WindowManagerService来完成，这里接着上面具体详细展开。 调了三个函数完成了三件事，即首先调用updateRotationUncheckedLocked（）更新rotation，然后调用performSurfacePlacement（）做屏幕的绘制，最后调用sendNewConfiguration（）发送Configuration变更事件。
本篇对updateRotationUncheckedLocked（）详细展开，后面的系列会继续详细介绍剩余的部分。

```java
public void updateRotationUnchecked(boolean alwaysSendConfiguration, boolean forceRelayout) {
        if(DEBUG_ORIENTATION) Slog.v(TAG_WM, "updateRotationUnchecked("
                   + "alwaysSendConfiguration=" + alwaysSendConfiguration + ")");
 
        long origId = Binder.clearCallingIdentity();
        boolean changed;
        synchronized(mWindowMap) {
            //（1）更新rotation
            changed = updateRotationUncheckedLocked(false);
            if (!changed || forceRelayout) {
                getDefaultDisplayContentLocked().layoutNeeded = true;
                //（2）做屏幕的绘制
                mWindowPlacerLocked.performSurfacePlacement();
            }
        }
 
        if (changed || alwaysSendConfiguration) {
            //(3)发送Configuration变更事件
            sendNewConfiguration();
        }
 
        Binder.restoreCallingIdentity(origId);
    }
```

![img](https://upload-images.jianshu.io/upload_images/2088926-26c0a9ff6e59c496.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 二、更新rotation

**updateRotationUncheckedLocked（）主要完成如下几件事：**

**A : 首先判断有下列情形的则返回false放弃更新rotation**

（1）有延迟的Rotation尚未完成，即DeferredRotationPauseCount > 0

（2）上次旋转还没有完成旋转动画还在运行中，即screenRotationAnimation.isAnimating() == true

（3）旋转动画已完成但display还未unfrozen（display 还在Frozen状态）及 mDisplayFrozen == true

（4）display 不可用

**B:获取设备方向**

（PhoneWindowManager的rotationForOrientationLw（）根据根据传感器数据计算转换为设备方向）和是否需要平滑（Seamlessly）旋转（PhoneWindowManager的shouldRotateSeamlessly（）函数）如果Seamlessly则不能有旋转动画。

**C:根据新的显示方向（Orientation）来更新DisplayInfo**

**D通过SurfaceControl.openTransaction()设置Surface参数**

```java
public boolean updateRotationUncheckedLocked(boolean inTransaction) {
        if (mDeferredRotationPauseCount > 0) {
            // Rotation updates have been paused temporarily.  Defer the update until
            // updates have been resumed.
            if (DEBUG_ORIENTATION) Slog.v(TAG_WM, "Deferring rotation, rotation is paused.");
            return false;
        }
        //如果上次的旋转动画还在运行中（即上次还未旋转完成则无需旋转，返回false）
        ScreenRotationAnimation screenRotationAnimation =
                mAnimator.getScreenRotationAnimationLocked(Display.DEFAULT_DISPLAY);
        if (screenRotationAnimation != null && screenRotationAnimation.isAnimating()) {
            // Rotation updates cannot be performed while the previous rotation change
            // animation is still in progress.  Skip this update.  We will try updating
            // again after the animation is finished and the display is unfrozen.
            if (DEBUG_ORIENTATION) Slog.v(TAG_WM, "Deferring rotation, animation in progress.");
            return false;
        }
        //display 尚未unfrozen
        if (mDisplayFrozen) {
            // Even if the screen rotation animation has finished (e.g. isAnimating
            // returns false), there is still some time where we haven't yet unfrozen
            // the display. We also need to abort rotation here.
            if (DEBUG_ORIENTATION) Slog.v(TAG_WM, "Deferring rotation, still finishing previous rotation");
            return false;
        }
 
        if (!mDisplayEnabled) {
            // No point choosing a rotation if the display is not enabled.
            if (DEBUG_ORIENTATION) Slog.v(TAG_WM, "Deferring rotation, display is not enabled.");
            return false;
        }
 
        final DisplayContent displayContent = getDefaultDisplayContentLocked();
        final WindowList windows = displayContent.getWindowList();
 
        final int oldRotation = mRotation;
        //获取设备方向（根据传感器数据计算转换为设备方向）
        int rotation = mPolicy.rotationForOrientationLw(mLastOrientation, mRotation);
        //获取rotateSeamlessly
        boolean rotateSeamlessly = mPolicy.shouldRotateSeamlessly(oldRotation, rotation);
        // 处理判断是否可以Seamlessly
        if (rotateSeamlessly) {
            for (int i = windows.size() - 1; i >= 0; i--) {
                WindowState w = windows.get(i);
                if (w.mSeamlesslyRotated) {
                    return false;
                }
 
                if (w.isChildWindow() & w.isVisibleNow() &&
                        !w.mWinAnimator.mSurfaceController.getTransformToDisplayInverse()) {
                    rotateSeamlessly = false;
                }
            }
        }
 
        boolean altOrientation = !mPolicy.rotationHasCompatibleMetricsLw(
                mLastOrientation, rotation);
 
        if (DEBUG_ORIENTATION) {
            Slog.v(TAG_WM, "Selected orientation "
                    + mLastOrientation + ", got rotation " + rotation
                    + " which has " + (altOrientation ? "incompatible" : "compatible")
                    + " metrics");
        }
 
        if (mRotation == rotation && mAltOrientation == altOrientation) {
            // No change.
             return false;
        }
 
        if (DEBUG_ORIENTATION) {
            Slog.v(TAG_WM,
                "Rotation changed to " + rotation + (altOrientation ? " (alt)" : "")
                + " from " + mRotation + (mAltOrientation ? " (alt)" : "")
                + ", lastOrientation=" + mLastOrientation);
        }
 
        mRotation = rotation;
        mAltOrientation = altOrientation;
        mPolicy.setRotationLw(mRotation);
 
        mWindowsFreezingScreen = WINDOWS_FREEZING_SCREENS_ACTIVE;
        //发送WINDOW_FREEZE_TIMEOUT消息
        mH.removeMessages(H.WINDOW_FREEZE_TIMEOUT);
        mH.sendEmptyMessageDelayed(H.WINDOW_FREEZE_TIMEOUT, WINDOW_FREEZE_TIMEOUT_DURATION);
        mWaitingForConfig = true;
        displayContent.layoutNeeded = true;
        final int[] anim = new int[2];
        if (displayContent.isDimming()) {
            anim[0] = anim[1] = 0;
        } else {
            mPolicy.selectRotationAnimationLw(anim);
        }
        // 如果是Seamlessly则无旋转动画，因Seamlessly目前不支持旋转动画
        if (!rotateSeamlessly) {
            startFreezingDisplayLocked(inTransaction, anim[0], anim[1]);
            // startFreezingDisplayLocked can reset the ScreenRotationAnimation.
            screenRotationAnimation =
                mAnimator.getScreenRotationAnimationLocked(Display.DEFAULT_DISPLAY);
        } else {
            // The screen rotation animation uses a screenshot to freeze the screen
            // while windows resize underneath.
            // When we are rotating seamlessly, we allow the elements to transition
            // to their rotated state independently and without a freeze required.
            screenRotationAnimation = null;
 
            // We have to reset this in case a window was removed before it
            // finished seamless rotation.
            mSeamlessRotationCount = 0;
        }
 
        // We need to update our screen size information to match the new rotation. If the rotation
        // has actually changed then this method will return true and, according to the comment at
        // the top of the method, the caller is obligated to call computeNewConfigurationLocked().
        // By updating the Display info here it will be available to
        // computeScreenConfigurationLocked later.
        //根据rotation 去更新DisplayInfo
        updateDisplayAndOrientationLocked(mCurConfiguration.uiMode);
 
        final DisplayInfo displayInfo = displayContent.getDisplayInfo();
        if (!inTransaction) {
            if (SHOW_TRANSACTIONS) {
                Slog.i(TAG_WM, ">>> OPEN TRANSACTION setRotationUnchecked");
            }
            // 设置surface参数
            SurfaceControl.openTransaction();
        }
        try {
            // NOTE: We disable the rotation in the emulator because
            //       it doesn't support hardware OpenGL emulation yet.
            if (CUSTOM_SCREEN_ROTATION && screenRotationAnimation != null
                    && screenRotationAnimation.hasScreenshot()) {
                if (screenRotationAnimation.setRotationInTransaction(
                        rotation, mFxSession,
                        MAX_ANIMATION_DURATION, getTransitionAnimationScaleLocked(),
                        displayInfo.logicalWidth, displayInfo.logicalHeight)) {
                    scheduleAnimationLocked();
                }
            }
 
            if (rotateSeamlessly) {
                for (int i = windows.size() - 1; i >= 0; i--) {
                    WindowState w = windows.get(i);
                    w.mWinAnimator.seamlesslyRotateWindow(oldRotation, mRotation);
                }
            }
 
            mDisplayManagerInternal.performTraversalInTransactionFromWindowManager();
        } finally {
            if (!inTransaction) {
                SurfaceControl.closeTransaction();
                if (SHOW_LIGHT_TRANSACTIONS) {
                    Slog.i(TAG_WM, "<<< CLOSE TRANSACTION setRotationUnchecked");
                }
            }
        }
 
        for (int i = windows.size() - 1; i >= 0; i--) {
            WindowState w = windows.get(i);
            // Discard surface after orientation change, these can't be reused.
            if (w.mAppToken != null) {
                w.mAppToken.destroySavedSurfaces();
            }
            if (w.mHasSurface && !rotateSeamlessly) {
                if (DEBUG_ORIENTATION) Slog.v(TAG_WM, "Set mOrientationChanging of " + w);
                w.mOrientationChanging = true;
                mWindowPlacerLocked.mOrientationChangeComplete = false;
                w.mLastFreezeDuration = 0;
            }
        }
        if (rotateSeamlessly) {
            mH.removeMessages(H.SEAMLESS_ROTATION_TIMEOUT);
            mH.sendEmptyMessageDelayed(H.SEAMLESS_ROTATION_TIMEOUT, SEAMLESS_ROTATION_TIMEOUT_DURATION);
        }
 
        for (int i=mRotationWatchers.size()-1; i>=0; i--) {
            try {
                mRotationWatchers.get(i).watcher.onRotationChanged(rotation);
            } catch (RemoteException e) {
            }
        }
 
        // TODO (multidisplay): Magnification is supported only for the default display.
        // Announce rotation only if we will not animate as we already have the
        // windows in final state. Otherwise, we make this call at the rotation end.
        if (screenRotationAnimation == null && mAccessibilityController != null
                && displayContent.getDisplayId() == Display.DEFAULT_DISPLAY) {
            mAccessibilityController.onRotationChangedLocked(getDefaultDisplayContentLocked(),rotation);
        }
 
        return true;
    }
```

![img](https://upload-images.jianshu.io/upload_images/2088926-366a40f8c5856fa0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 1）通过PhoneWindowManager获取orientation 和rotateSeamlessly

**A:PhoneWindowManager的rotationForOrientationLw（）**

PhoneWindowManager的rotationForOrientationLw（）根据传感器数据和各种场景和设置来更新preferredRotation 和orientation（注释比较详细，不赘述）

```java
public int rotationForOrientationLw(int orientation, int lastRotation) {
 
        if (mForceDefaultOrientation) {
            return Surface.ROTATION_0;
        }
 
        synchronized (mLock) {
            int sensorRotation = mOrientationListener.getProposedRotation(); // may be -1
            if (sensorRotation < 0) {
                sensorRotation = lastRotation;
            }
 
            final int preferredRotation;
            //根据各种场景和设置来更新preferredRotation 和orientation
            if (mLidState == LID_OPEN && mLidOpenRotation >= 0) {
                // Ignore sensor when lid switch is open and rotation is forced.
                preferredRotation = mLidOpenRotation;
            } else if (mDockMode == Intent.EXTRA_DOCK_STATE_CAR
                    && (mCarDockEnablesAccelerometer || mCarDockRotation >= 0)) {
                // Ignore sensor when in car dock unless explicitly enabled.
                // This case can override the behavior of NOSENSOR, and can also
                // enable 180 degree rotation while docked.
                preferredRotation = mCarDockEnablesAccelerometer
                        ? sensorRotation : mCarDockRotation;
            } else if ((mDockMode == Intent.EXTRA_DOCK_STATE_DESK
                    || mDockMode == Intent.EXTRA_DOCK_STATE_LE_DESK
                    || mDockMode == Intent.EXTRA_DOCK_STATE_HE_DESK)
                    && (mDeskDockEnablesAccelerometer || mDeskDockRotation >= 0)) {
                // Ignore sensor when in desk dock unless explicitly enabled.
                // This case can override the behavior of NOSENSOR, and can also
                // enable 180 degree rotation while docked.
                preferredRotation = mDeskDockEnablesAccelerometer
                        ? sensorRotation : mDeskDockRotation;
            } else if (mHdmiPlugged && mDemoHdmiRotationLock) {
                // Ignore sensor when plugged into HDMI when demo HDMI rotation lock enabled.
                // Note that the dock orientation overrides the HDMI orientation.
                preferredRotation = mDemoHdmiRotation;
            } else if (mHdmiPlugged && mDockMode == Intent.EXTRA_DOCK_STATE_UNDOCKED
                    && mUndockedHdmiRotation >= 0) {
                // Ignore sensor when plugged into HDMI and an undocked orientation has
                // been specified in the configuration (only for legacy devices without
                // full multi-display support).
                // Note that the dock orientation overrides the HDMI orientation.
                preferredRotation = mUndockedHdmiRotation;
            } else if (mDemoRotationLock) {
                // Ignore sensor when demo rotation lock is enabled.
                // Note that the dock orientation and HDMI rotation lock override this.
                preferredRotation = mDemoRotation;
            } else if (orientation == ActivityInfo.SCREEN_ORIENTATION_LOCKED) {
                // Application just wants to remain locked in the last rotation.
                preferredRotation = lastRotation;
            } else if (!mSupportAutoRotation) {
                // If we don't support auto-rotation then bail out here and ignore
                // the sensor and any rotation lock settings.
                preferredRotation = -1;
            } else if ((mUserRotationMode == WindowManagerPolicy.USER_ROTATION_FREE
                            && (orientation == ActivityInfo.SCREEN_ORIENTATION_USER
                                    || orientation == ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
                                    || orientation == ActivityInfo.SCREEN_ORIENTATION_USER_LANDSCAPE
                                    || orientation == ActivityInfo.SCREEN_ORIENTATION_USER_PORTRAIT
                                    || orientation == ActivityInfo.SCREEN_ORIENTATION_FULL_USER))
                    || orientation == ActivityInfo.SCREEN_ORIENTATION_SENSOR
                    || orientation == ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR
                    || orientation == ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
                    || orientation == ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT) {
                // Otherwise, use sensor only if requested by the application or enabled
                // by default for USER or UNSPECIFIED modes.  Does not apply to NOSENSOR.
                if (mAllowAllRotations < 0) {
                    // Can't read this during init() because the context doesn't
                    // have display metrics at that time so we cannot determine
                    // tablet vs. phone then.
                    mAllowAllRotations = mContext.getResources().getBoolean(
                            com.android.internal.R.bool.config_allowAllRotations) ? 1 : 0;
                }
                if (sensorRotation != Surface.ROTATION_180
                        || mAllowAllRotations == 1
                        || orientation == ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR
                        || orientation == ActivityInfo.SCREEN_ORIENTATION_FULL_USER) {
                    preferredRotation = sensorRotation;
                } else {
                    preferredRotation = lastRotation;
                }
            } else if (mUserRotationMode == WindowManagerPolicy.USER_ROTATION_LOCKED
                    && orientation != ActivityInfo.SCREEN_ORIENTATION_NOSENSOR) {
                // Apply rotation lock.  Does not apply to NOSENSOR.
                // The idea is that the user rotation expresses a weak preference for the direction
                // of gravity and as NOSENSOR is never affected by gravity, then neither should
                // NOSENSOR be affected by rotation lock (although it will be affected by docks).
                preferredRotation = mUserRotation;
            } else {
                // No overriding preference.
                // We will do exactly what the application asked us to do.
                preferredRotation = -1;
            }
 
            switch (orientation) {
                case ActivityInfo.SCREEN_ORIENTATION_PORTRAIT:
                    // Return portrait unless overridden.
                    if (isAnyPortrait(preferredRotation)) {
                        return preferredRotation;
                    }
                    return mPortraitRotation;
 
                case ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE:
                    // Return landscape unless overridden.
                    if (isLandscapeOrSeascape(preferredRotation)) {
                        return preferredRotation;
                    }
                    return mLandscapeRotation;
 
                case ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT:
                    // Return reverse portrait unless overridden.
                    if (isAnyPortrait(preferredRotation)) {
                        return preferredRotation;
                    }
                    return mUpsideDownRotation;
 
                case ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE:
                    // Return seascape unless overridden.
                    if (isLandscapeOrSeascape(preferredRotation)) {
                        return preferredRotation;
                    }
                    return mSeascapeRotation;
 
                case ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE:
                case ActivityInfo.SCREEN_ORIENTATION_USER_LANDSCAPE:
                    // Return either landscape rotation.
                    if (isLandscapeOrSeascape(preferredRotation)) {
                        return preferredRotation;
                    }
                    if (isLandscapeOrSeascape(lastRotation)) {
                        return lastRotation;
                    }
                    return mLandscapeRotation;
 
                case ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT:
                case ActivityInfo.SCREEN_ORIENTATION_USER_PORTRAIT:
                    // Return either portrait rotation.
                    if (isAnyPortrait(preferredRotation)) {
                        return preferredRotation;
                    }
                    if (isAnyPortrait(lastRotation)) {
                        return lastRotation;
                    }
                    return mPortraitRotation;
 
                default:
                    // For USER, UNSPECIFIED, NOSENSOR, SENSOR and FULL_SENSOR,
                    // just return the preferred orientation we already calculated.
                    if (preferredRotation >= 0) {
                        return preferredRotation;
                    }
                    return Surface.ROTATION_0;
            }
        }
    }
```

**B: shouldRotateSeamlessly（）**
判断是否需要平滑（Seamlessly）旋转，目前仅 top window且为fullscreen 状态时才会返回true，其他均为false，因为Seamlessly要求冻结Surface的各种状态并且影响旋转动画效果，所以此状态时不支持旋转动画。所以这种状态支持的场景也仅限于此。了解一下即可。

```java
public boolean shouldRotateSeamlessly(int oldRotation, int newRotation) {
 
        if (oldRotation == mUpsideDownRotation || newRotation == mUpsideDownRotation) {
            return false;
        }
        int delta = newRotation - oldRotation;
        if (delta < 0) delta += 4;
        if (delta == Surface.ROTATION_180) {
            return false;
        }
 
        final WindowState w = mTopFullscreenOpaqueWindowState;
        if (w != mFocusedWindow) {
            return false;
        }
        if (w != null && !w.isAnimatingLw() &&
                ((w.getAttrs().rotationAnimation == ROTATION_ANIMATION_JUMPCUT) ||
                        (w.getAttrs().rotationAnimation == ROTATION_ANIMATION_SEAMLESS))) {
            return true;
        }
        return false;
    }
```

## 2）更新显示信息（DisplayInfo）

根据新的显示方向（Orientation）来更新DisplayInfo，然后通过setDisplayInfoOverrideFromWindowManager（）来更新显示设备最后计算frame Rect 给应用来做缩放用。

```java
DisplayInfo updateDisplayAndOrientationLocked(int uiMode) {
        // TODO(multidisplay): For now, apply Configuration to main screen only.
        final DisplayContent displayContent = getDefaultDisplayContentLocked();
 
        // Use the effective "visual" dimensions based on current rotation
        final boolean rotated = (mRotation == Surface.ROTATION_90
                || mRotation == Surface.ROTATION_270);
        final int realdw = rotated ?
                displayContent.mBaseDisplayHeight : displayContent.mBaseDisplayWidth;
        final int realdh = rotated ?
                displayContent.mBaseDisplayWidth : displayContent.mBaseDisplayHeight;
        int dw = realdw;
        int dh = realdh;
 
        if (mAltOrientation) {
            if (realdw > realdh) {
                // Turn landscape into portrait.
                int maxw = (int)(realdh/1.3f);
                if (maxw < realdw) {
                    dw = maxw;
                }
            } else {
                // Turn portrait into landscape.
                int maxh = (int)(realdw/1.3f);
                if (maxh < realdh) {
                    dh = maxh;
                }
            }
        }
 
        // Update application display metrics.
        final int appWidth = mPolicy.getNonDecorDisplayWidth(dw, dh, mRotation, uiMode);
        final int appHeight = mPolicy.getNonDecorDisplayHeight(dw, dh, mRotation, uiMode);
        final DisplayInfo displayInfo = displayContent.getDisplayInfo();
        displayInfo.rotation = mRotation;
        displayInfo.logicalWidth = dw;
        displayInfo.logicalHeight = dh;
        displayInfo.logicalDensityDpi = displayContent.mBaseDisplayDensity;
        displayInfo.appWidth = appWidth;
        displayInfo.appHeight = appHeight;
        displayInfo.getLogicalMetrics(mRealDisplayMetrics,
                CompatibilityInfo.DEFAULT_COMPATIBILITY_INFO, null);
        displayInfo.getAppMetrics(mDisplayMetrics);
        if (displayContent.mDisplayScalingDisabled) {
            displayInfo.flags |= Display.FLAG_SCALING_DISABLED;
        } else {
            displayInfo.flags &= ~Display.FLAG_SCALING_DISABLED;
        }
 
        mDisplayManagerInternal.setDisplayInfoOverrideFromWindowManager(
                displayContent.getDisplayId(), displayInfo);
 
        displayContent.mBaseDisplayRect.set(0, 0, dw, dh);
        if (false) {
            Slog.i(TAG_WM, "Set app display size: " + appWidth + " x " + appHeight);
        }
 
        mCompatibleScreenScale = CompatibilityInfo.computeCompatibleScaling(mDisplayMetrics,
                mCompatDisplayMetrics);
        return displayInfo;
    }
```

**A: DisplayManagerService.setDisplayInfoOverrideFromWindowManager()**
window manager 通过此函数来更新逻辑显示设备（logical display）的大小变化和一些特性的变更。
首先通过sendDisplayEventLocked（）会发送一个MSG_DELIVER_DISPLAY_EVENT消息然后通过，然后调用scheduleTraversalLocked（）发送MSG_REQUEST_TRAVERSAL消息请求surface 和display处理变更请求。

```java
public void setDisplayInfoOverrideFromWindowManager(int displayId, DisplayInfo info) {
        setDisplayInfoOverrideFromWindowManagerInternal(displayId, info);
    }
 
    private void setDisplayInfoOverrideFromWindowManagerInternal(int displayId, DisplayInfo info) {
        synchronized (mSyncRoot) {
            LogicalDisplay display = mLogicalDisplays.get(displayId);
            if (display != null) {
                if (display.setDisplayInfoOverrideFromWindowManagerLocked(info)) {
                    //发送MSG_DELIVER_DISPLAY_EVENT消息
                    sendDisplayEventLocked(displayId, DisplayManagerGlobal.EVENT_DISPLAY_CHANGED);
                    //发送MSG_REQUEST_TRAVERSAL消息
                    scheduleTraversalLocked(false);
                }
            }
        }
    }
 
    private void sendDisplayEventLocked(int displayId, int event) {
        Message msg = mHandler.obtainMessage(MSG_DELIVER_DISPLAY_EVENT, displayId, event);
        mHandler.sendMessage(msg);
    }
```

发送MSG_REQUEST_TRAVERSAL消息请求，稍后由surface 和display处理变更请求。这样处理是为了异步执行。

```java
private void scheduleTraversalLocked(boolean inTraversal) {
        if (!mPendingTraversal && mWindowManagerInternal != null) {
            mPendingTraversal = true;
            if (!inTraversal) {
                mHandler.sendEmptyMessage(MSG_REQUEST_TRAVERSAL);
            }
        }
    }
```

**B: computeCompatibleScaling() 计算frame Rect来供应用做缩放**

```java
public static float computeCompatibleScaling(DisplayMetrics dm, DisplayMetrics outDm) {
        final int width = dm.noncompatWidthPixels;
        final int height = dm.noncompatHeightPixels;
        int shortSize, longSize;
        if (width < height) {
            shortSize = width;
            longSize = height;
        } else {
            shortSize = height;
            longSize = width;
        }
        int newShortSize = (int)(DEFAULT_NORMAL_SHORT_DIMENSION * dm.density + 0.5f);
        float aspect = ((float)longSize) / shortSize;
        if (aspect > MAXIMUM_ASPECT_RATIO) {
            aspect = MAXIMUM_ASPECT_RATIO;
        }
        int newLongSize = (int)(newShortSize * aspect + 0.5f);
        int newWidth, newHeight;
        if (width < height) {
            newWidth = newShortSize;
            newHeight = newLongSize;
        } else {
            newWidth = newLongSize;
            newHeight = newShortSize;
        }
 
        float sw = width/(float)newWidth;
        float sh = height/(float)newHeight;
        float scale = sw < sh ? sw : sh;
        if (scale < 1) {
            scale = 1;
        }
 
        if (outDm != null) {
            outDm.widthPixels = newWidth;
            outDm.heightPixels = newHeight;
        }
 
        return scale;
    }
```

![img](https://upload-images.jianshu.io/upload_images/2088926-f1e810da4628011b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 3）DisplayManagerService的performTraversalInTransactionFromWindowManager（）

```java
public void performTraversalInTransactionFromWindowManager() {
performTraversalInTransactionFromWindowManagerInternal();
}
```

```java
private void performTraversalInTransactionFromWindowManagerInternal() {
        synchronized (mSyncRoot) {
            if (!mPendingTraversal) {
                return;
            }
            mPendingTraversal = false;
 
            performTraversalInTransactionLocked();
        }
 
        // List is self-synchronized copy-on-write.
        for (DisplayTransactionListener listener : mDisplayTransactionListeners) {
            listener.onDisplayTransaction();
        }
    }
```

```java
private void performTraversalInTransactionLocked() {
        // Clear all viewports before configuring displays so that we can keep
        // track of which ones we have configured.
        clearViewportsLocked();
 
        // Configure each display device.
        final int count = mDisplayDevices.size();
        for (int i = 0; i < count; i++) {
            DisplayDevice device = mDisplayDevices.get(i);
            configureDisplayInTransactionLocked(device);
            device.performTraversalInTransactionLocked();
        }
 
        // Tell the input system about these new viewports.
        if (mInputManagerInternal != null) {
            mHandler.sendEmptyMessage(MSG_UPDATE_VIEWPORT);
        }
    }
```

```java
private void configureDisplayInTransactionLocked(DisplayDevice device) {
        final DisplayDeviceInfo info = device.getDisplayDeviceInfoLocked();
        final boolean ownContent = (info.flags & DisplayDeviceInfo.FLAG_OWN_CONTENT_ONLY) != 0;
 
        // Find the logical display that the display device is showing.
        // Certain displays only ever show their own content.
        LogicalDisplay display = findLogicalDisplayForDeviceLocked(device);
        if (!ownContent) {
            if (display != null && !display.hasContentLocked()) {
                // If the display does not have any content of its own, then
                // automatically mirror the default logical display contents.
                display = null;
            }
            if (display == null) {
                display = mLogicalDisplays.get(Display.DEFAULT_DISPLAY);
            }
        }
 
        // Apply the logical display configuration to the display device.
        if (display == null) {
            // TODO: no logical display for the device, blank it
            Slog.w(TAG, "Missing logical display to use for physical display device: "
                    + device.getDisplayDeviceInfoLocked());
            return;
        }
        display.configureDisplayInTransactionLocked(device, info.state == Display.STATE_OFF);
 
        // Update the viewports if needed.
        if (!mDefaultViewport.valid
                && (info.flags & DisplayDeviceInfo.FLAG_DEFAULT_DISPLAY) != 0) {
            setViewportLocked(mDefaultViewport, display, device);
        }
        if (!mExternalTouchViewport.valid
                && info.touch == DisplayDeviceInfo.TOUCH_EXTERNAL) {
            setViewportLocked(mExternalTouchViewport, display, device);
        }
    }
```

![img](https://upload-images.jianshu.io/upload_images/2088926-2104b87e039787ad.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 4）总结

![img](https://upload-images.jianshu.io/upload_images/2088926-ad02429dc1477a38.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)