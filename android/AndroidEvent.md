title:  Android事件
date: 2018年5月2日00:20:04
categories: Android
tags: 

	 - Android
	 - 事件


- ### 事件从屏幕到达应用

  1. 硬件内核部分

     1. 屏幕触摸或按键出发硬件驱动
     2. 驱动收到事件，将事件包装为Event写入到设备节点/dev/input/event[x]

  2. SystemServer部分

     1. IMS(InputManagerService.java)启动InputReader和InputDispatcher线程。
     2. InputReader从/dev/input/event[x]读取事件，分发给InputDispatcher线程。
     3. WMS(WindowManagerService.java)创建的时候持有IMS，WMS每增加一个窗口，底层消费者InputDispatcher.cpp将窗口列表保存在成员变量mWindowHandles中，焦点窗口保存在成员变量mFocusedWindowHandle中。

  3. 跨进程通信传递给App

     1. InputDispatcher收到事件会通过findTouchedWindowTargetsLocked找到目标窗口，通过Socket通信InputChannel传递给应用。
     2. 在ViewRootImpl.setView()过程中，也会同时注册InputChannel到InputManagerService。
     3. App进程的主线程监听socket客户端，收到事件后回调NativeInputEventReceiver.handleEvent() → InputEventReceiver.dispatchInputEvent()再到ViewRootImpl

     

- ### 事件从应用到达对应页面

  ViewRootImpl → DecorView → Activity → PhoneWindow → DecorView → ViewGroup → View

  ```java
  "main@16282" prio=5 tid=0x2 nid=NA runnable
    java.lang.Thread.State: RUNNABLE
  	  at com.gusi.root.MyView.dispatchTouchEvent(MyView.java:31)
  	  at android.view.ViewGroup.dispatchTransformedTouchEvent(ViewGroup.java:3118)
  	  at android.view.ViewGroup.dispatchTouchEvent(ViewGroup.java:2742)
  	  at android.view.ViewGroup.dispatchTransformedTouchEvent(ViewGroup.java:3118)
  	  at android.view.ViewGroup.dispatchTouchEvent(ViewGroup.java:2742)
  	  at android.view.ViewGroup.dispatchTransformedTouchEvent(ViewGroup.java:3118)
  	  at android.view.ViewGroup.dispatchTouchEvent(ViewGroup.java:2742)
  	  at android.view.ViewGroup.dispatchTransformedTouchEvent(ViewGroup.java:3118)
  	  at android.view.ViewGroup.dispatchTouchEvent(ViewGroup.java:2742)
  	  at android.view.ViewGroup.dispatchTransformedTouchEvent(ViewGroup.java:3118)
  	  at android.view.ViewGroup.dispatchTouchEvent(ViewGroup.java:2742)
  	  at android.view.ViewGroup.dispatchTransformedTouchEvent(ViewGroup.java:3118)
  	  at android.view.ViewGroup.dispatchTouchEvent(ViewGroup.java:2742)
  	  at com.android.internal.policy.DecorView.superDispatchTouchEvent(DecorView.java:488)
  	  at com.android.internal.policy.PhoneWindow.superDispatchTouchEvent(PhoneWindow.java:1871)
  	  at android.app.Activity.dispatchTouchEvent(Activity.java:4125)
  	  at com.gusi.root.TestActivity.dispatchTouchEvent(TestActivity.java:31)
  	  at androidx.appcompat.view.WindowCallbackWrapper.dispatchTouchEvent(WindowCallbackWrapper.java:69)
  	  at com.android.internal.policy.DecorView.dispatchTouchEvent(DecorView.java:446)
  	  at android.view.View.dispatchPointerEvent(View.java:14568)
  	  at android.view.ViewRootImpl$ViewPostImeInputStage.processPointerEvent(ViewRootImpl.java:6016)
  	  at android.view.ViewRootImpl$ViewPostImeInputStage.onProcess(ViewRootImpl.java:5819)
  	  at android.view.ViewRootImpl$InputStage.deliver(ViewRootImpl.java:5310)
  	  at android.view.ViewRootImpl$InputStage.onDeliverToNext(ViewRootImpl.java:5367)
  	  at android.view.ViewRootImpl$InputStage.forward(ViewRootImpl.java:5333)
  	  at android.view.ViewRootImpl$AsyncInputStage.forward(ViewRootImpl.java:5485)
  	  at android.view.ViewRootImpl$InputStage.apply(ViewRootImpl.java:5341)
  	  at android.view.ViewRootImpl$AsyncInputStage.apply(ViewRootImpl.java:5542)
  	  at android.view.ViewRootImpl$InputStage.deliver(ViewRootImpl.java:5314)
  	  at android.view.ViewRootImpl$InputStage.onDeliverToNext(ViewRootImpl.java:5367)
  	  at android.view.ViewRootImpl$InputStage.forward(ViewRootImpl.java:5333)
  	  at android.view.ViewRootImpl$InputStage.apply(ViewRootImpl.java:5341)
  	  at android.view.ViewRootImpl$InputStage.deliver(ViewRootImpl.java:5314)
  	  at android.view.ViewRootImpl.deliverInputEvent(ViewRootImpl.java:8080)
  	  at android.view.ViewRootImpl.doProcessInputEvents(ViewRootImpl.java:8031)
  	  at android.view.ViewRootImpl.enqueueInputEvent(ViewRootImpl.java:7992)
  	  at android.view.ViewRootImpl$WindowInputEventReceiver.onInputEvent(ViewRootImpl.java:8203)
  	  at android.view.InputEventReceiver.dispatchInputEvent(InputEventReceiver.java:220)
  	  at android.os.MessageQueue.nativePollOnce(MessageQueue.java:-1)
  	  at android.os.MessageQueue.next(MessageQueue.java:335)
  	  at android.os.Looper.loop(Looper.java:183)
  	  at android.app.ActivityThread.main(ActivityThread.java:7656)
  	  at java.lang.reflect.Method.invoke(Method.java:-1)
  	  at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:592)
  	  at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:947)
  ```

  ![](C:\Users\batue\Pictures\应用内事件传递.png)

- ### 事件应用内部分发

##### cover_picture: /images/Android事件传递.png

![](https://upload-images.jianshu.io/upload_images/2088926-ac2596ed73815e52.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 事件一般有

  - MotionEvent.ACTION_DOWN
  - MotionEvent.ACTION_UP
  - MotionEvent.ACTION_MOVE
  - MotionEvent.ACTION_CANCEL(触摸移出第一消费事件View外)

- 事件顺序Activity → ViewGroup → ... →View

- 相应决定事件分发、拦截、消费的具体 

  - Activity

    - dispatchTouchEvent

      ```java
      public boolean dispatchTouchEvent(MotionEvent ev) {
          if (ev.getAction() == MotionEvent.ACTION_DOWN) {
              //空方法，实现屏保功能，当此activity在栈顶时，触屏点击按home，back，menu键等都会触发此方法
              onUserInteraction();
          }
          //重要！！！ 找到PhoneWindow及DecoreView，往下传递事件
          if (getWindow().superDispatchTouchEvent(ev)) {
              return true;
          }
          return onTouchEvent(ev);
      }
      ```

    - onTouchEvent(消费事件，true消费)

  - ViewGroup

    - dispatchTouchEvent
    - onInterceptTouchEvent
    - onTouchEvent

  - View

    - dispatchTouchEvent
    - onTouchEvent

  ##### super很重要决定事件的下一步走向，不执行super时谨慎使用(如Activity的super.dispatchTouchEvent(ev))。


interceptKeyBeforeQueueing:4872, PhoneWindowManager (com.android.server.policy)
interceptKeyBeforeQueueing:3573, HwPhoneWindowManager (com.android.server.policy)
interceptKeyBeforeQueueing:189, InputManagerCallback (com.android.server.wm)
interceptKeyBeforeQueueing:3199, InputManagerService (com.android.server.input)
injectInputEvent:-1, NativeInputManagerService$NativeImpl (com.android.server.input)
injectInputEventInternal:1295, InputManagerService (com.android.server.input)
injectInputEventToTarget:1254, InputManagerService (com.android.server.input)
onTransact:790, IInputManager$Stub (android.hardware.input)
execTransactInternal:1371, Binder (android.os)
execTransact:1310, Binder (android.os)


interceptKeyBeforeDispatching:3725, PhoneWindowManager (com.android.server.policy)
interceptKeyBeforeDispatching:4518, HwPhoneWindowManager (com.android.server.policy)
interceptKeyBeforeDispatching:207, InputManagerCallback (com.android.server.wm)
interceptKeyBeforeDispatching:3234, InputManagerService (com.android.server.input)