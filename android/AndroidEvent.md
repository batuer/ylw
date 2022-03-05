title:  Android事件
date: 2018年5月2日00:20:04
categories: Android
tags: 

	 - Android
	 - 事件
cover_picture: /images/Android事件传递.png
---

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

