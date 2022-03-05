title: View.requestlayout()
date: 2019年09月22日21:53:27
categories: 未标记
tags: 
     - 未标记
cover_picture: /images/View.requestlayout().jpeg
---
    
```java
/**
* View
*/
public void requestLayout() {
        if (mMeasureCache != null) mMeasureCache.clear();
        // mAttachInfo.mViewRequestingLayout 发起的调用者
        if (mAttachInfo != null && mAttachInfo.mViewRequestingLayout == null) {
            // Only trigger request-during-layout logic if this is the view requesting it,
            // not the views in its parent hierarchy
            ViewRootImpl viewRoot = getViewRootImpl();
            // ViewRootImpl是否正在执行performLayout()
            if (viewRoot != null && viewRoot.isInLayout()) {
                if (!viewRoot.requestLayoutDuringLayout(this)) {
                    return;
                }
            }
            mAttachInfo.mViewRequestingLayout = this;
        }

        mPrivateFlags |= PFLAG_FORCE_LAYOUT;
        mPrivateFlags |= PFLAG_INVALIDATED;
		// 正在requestLayout(),DecorView.parent = ViewRootImpl
        if (mParent != null && !mParent.isLayoutRequested()) {
            mParent.requestLayout();
        }
        if (mAttachInfo != null && mAttachInfo.mViewRequestingLayout == this) {
            mAttachInfo.mViewRequestingLayout = null;
        }
    }
```

```java
/**
* 最终ViewRootImpl
*/
  public void requestLayout() {
      // ViewRootImpl是否正在执行performLayout()
        if (!mHandlingLayoutInLayoutRequest) {
            // MainThread
            checkThread();
            mLayoutRequested = true;
            // 遍历
            scheduleTraversals();
        }
    }
```

```java
/**
* ViewRootImpl遍历绘制
*/   
void scheduleTraversals() {
        if (!mTraversalScheduled) {
            mTraversalScheduled = true;
            // MessageQueue.postSyncBarrier()
            mTraversalBarrier = mHandler.getLooper().getQueue().postSyncBarrier();
            // post.TraversalRunnable
            mChoreographer.postCallback(
                    Choreographer.CALLBACK_TRAVERSAL, mTraversalRunnable, null);
            if (!mUnbufferedInputDispatch) {
                scheduleConsumeBatchedInput();
            }
            notifyRendererOfFramePending();
            pokeDrawLockIfNeeded();
        }
    }
```

```java
/**
* MessageQueue
*/ 
private int postSyncBarrier(long when) {
        // Enqueue a new sync barrier token.
        // We don't need to wake the queue because the purpose of a barrier is to stall it.
        synchronized (this) {
              /** 第一步 */
            final int token = mNextBarrierToken++;
             /** 第二步 */
            final Message msg = Message.obtain();
            msg.markInUse();
            msg.when = when;
            msg.arg1 = token;

              /** 第三步 */
            Message prev = null;
            //把消息队列的第一个元素指向p
            Message p = mMessages;
            if (when != 0) {
             /** 第四步 */
                while (p != null && p.when <= when) {
                    //通过p的时间点和障栅的时间点的比较，如果比障栅的小，就把消息队列中的消息向后移动一位(因为消息队列中所有元素是按照时间排序的)
                    prev = p;
                    p = p.next;
                }
            }
              /** 第五步 */
             //prev != null 代表不是消息队列的头部，则需要考虑前面一个消息和后面的一个消息
            if (prev != null) { // invariant: p == prev.next
                //msg的下一个消息是p 
                msg.next = p;
                 //msg的上一个消息是msg
                prev.next = msg;
            } else {
                //prev == null 代表是消息队列的头部，则只需要负责下一个消息即可
                msg.next = p;
                //设置自己是消息队列的头部
                mMessages = msg;
            }
            /** 第六步 */
            return token;
        }
    }
```

```java
  /**
  * TraversalRunnable
  */
   final class TraversalRunnable implements Runnable {
        @Override
        public void run() {
            // ViewRootImpl.doTraversal()
            doTraversal();
        }
    }

    void doTraversal() {
        if (mTraversalScheduled) {
            mTraversalScheduled = false;
            // remove barrier
            mHandler.getLooper().getQueue().removeSyncBarrier(mTraversalBarrier);

            if (mProfile) {
                Debug.startMethodTracing("ViewAncestor");
            }
		  // 
            performTraversals();

            if (mProfile) {
                Debug.stopMethodTracing();
                mProfile = false;
            }
        }
    }

    private void performTraversals(){
        mIsInTraversal = true;
        // ...
        performMeasure();
        // ...
        performLayout();
        // ...
        performDraw();
        
        mIsInTraversal = false;
    }
```



```java
/*
* Choreographer
* 控制输入、动画。绘制的时机。
* 1.接收垂直同步的时间脉冲。2.安排在下一帧中要做的工作。
*/
public final class Choreographer {
    ...
     // 下一帧执行TraversalRunnable
     private void postCallbackDelayedInternal(int callbackType,
            Object action, Object token, long delayMillis) {
        if (DEBUG_FRAMES) {
            Log.d(TAG, "PostCallback: type=" + callbackType
                    + ", action=" + action + ", token=" + token
                    + ", delayMillis=" + delayMillis);
        }

        synchronized (mLock) {
            final long now = SystemClock.uptimeMillis();
            final long dueTime = now + delayMillis;
            mCallbackQueues[callbackType].addCallbackLocked(dueTime, action, token);

            if (dueTime <= now) {
                scheduleFrameLocked(now);
            } else {
                Message msg = mHandler.obtainMessage(MSG_DO_SCHEDULE_CALLBACK, action);
                msg.arg1 = callbackType;
                msg.setAsynchronous(true);
                mHandler.sendMessageAtTime(msg, dueTime);
            }
        }
    }
    // 
    private void scheduleFrameLocked(long now) {
        if (!mFrameScheduled) {
            mFrameScheduled = true;
            if (USE_VSYNC) {
                if (DEBUG_FRAMES) {
                    Log.d(TAG, "Scheduling next frame on vsync.");
                }

                // If running on the Looper thread, then schedule the vsync immediately,
                // otherwise post a message to schedule the vsync from the UI thread
                // as soon as possible.
                if (isRunningOnLooperThreadLocked()) {
                    // FrameDisplayEventReceiver注册了个Vsync的通知
                    scheduleVsyncLocked();
                } else {
                    Message msg = mHandler.obtainMessage(MSG_DO_SCHEDULE_VSYNC);
                    msg.setAsynchronous(true);
                    mHandler.sendMessageAtFrontOfQueue(msg);
                }
            } else {
                final long nextFrameTime = Math.max(
                        mLastFrameTimeNanos / TimeUtils.NANOS_PER_MS + sFrameDelay, now);
                if (DEBUG_FRAMES) {
                    Log.d(TAG, "Scheduling next frame in " + (nextFrameTime - now) + " ms.");
                }
                Message msg = mHandler.obtainMessage(MSG_DO_FRAME);
                msg.setAsynchronous(true);
                mHandler.sendMessageAtTime(msg, nextFrameTime);
            }
        }
    }
    //
     void doFrame(long frameTimeNanos, int frame) {
        .......
        try {
            Trace.traceBegin(Trace.TRACE_TAG_VIEW, "Choreographer#doFrame");
            AnimationUtils.lockAnimationClock(frameTimeNanos / TimeUtils.NANOS_PER_MS);

            mFrameInfo.markInputHandlingStart();
            doCallbacks(Choreographer.CALLBACK_INPUT, frameTimeNanos);

            mFrameInfo.markAnimationsStart();
            doCallbacks(Choreographer.CALLBACK_ANIMATION, frameTimeNanos);

            mFrameInfo.markPerformTraversalsStart();
            doCallbacks(Choreographer.CALLBACK_TRAVERSAL, frameTimeNanos);

            doCallbacks(Choreographer.CALLBACK_COMMIT, frameTimeNanos);
        } finally {
            AnimationUtils.unlockAnimationClock();
            Trace.traceEnd(Trace.TRACE_TAG_VIEW);
        }

        ....
    }
}
```

```java
/*
* FrameDisplayEventReceiver
*/
 private final class FrameDisplayEventReceiver extends DisplayEventReceiver{
      @Override
        public void onVsync(long timestampNanos, int builtInDisplayId, int frame) {
   		   ...
            Message msg = Message.obtain(mHandler, this);
            msg.setAsynchronous(true);
            mHandler.sendMessageAtTime(msg, timestampNanos / TimeUtils.NANOS_PER_MS);
        }

        @Override
        public void run() {
            mHavePendingVsync = false;
            // Choreographer.doFrame
            doFrame(mTimestampNanos, mFrame);
        }
     
 }
```

> 我们调用View的requestLayout或者invalidate时，最终都会触发ViewRootImp执行scheduleTraversals()方法。这个方法中ViewRootImp会通过Choreographer来注册个接收Vsync的监听，当接收到系统体层发送来的Vsync后我们就执行doTraversal()来重新绘制界面。**通过上面的分析我们调用invalidate等刷新操作时，系统并不会立即刷新界面，而是等到Vsync消息后才会刷新页面**