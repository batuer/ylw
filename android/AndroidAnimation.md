title:  Android动画
date: 2018年8月19日23:34:46
categories: Android
tags: 

	 - Android
	 - 动画
cover_picture: /images/common.png
---

### View Animation

- 视图动画也叫Tween(补间)动画，简单的变换(大小、位置、旋转、透明度)。

- 可通过XML或代码定义。

- AnimationSet 动画容器管理类。

- 视图动画执行之后欧并未改变View的**真实布局属性值**，改变的是View的绘制效果。

- 仅支持View，支持种类少。

  > ```java
  > View view1 = findViewById(R.id.view1);
  > int type1 = Animation.RELATIVE_TO_SELF;
  > TranslateAnimation animation1 = new TranslateAnimation(type1, 0, type1, 2f, type1, 0, type1, 0);
  > animation1.setInterpolator(new BounceInterpolator());
  > animation1.setRepeatCount(-1);
  > animation1.setRepeatMode(Animation.REVERSE);
  > animation1.setDuration(2000);
  > view1.startAnimation(animation1);
  > ```

### Property Animation(3.0+)

- 修改控件属性值实现的动画。
- 对象的任意属性添加动画。
- 动态修改属性值。

##### ViewPropertyAnimator

属性动画扩展。

> ```java
> View view4 = findViewById(R.id.view4);
> view4.animate()
>         .translationX(200)
>         .setInterpolator(new BounceInterpolator())
>         .setDuration(2000)
>         .start();
> ```

##### ObjectAnimatior

- TypeEvaluator

  > ```java
  > //view 属性position
  > ObjectAnimator animator = ObjectAnimator.ofObject(view, "position",
  >         new PointFEvaluator(), new PointF(0, 0), new PointF(1, 1));
  > animator.setInterpolator(new LinearInterpolator());
  > animator.setDuration(1000);
  > ```

- PropertyValuesHolder同一个动画中改变多个属性。

  > ```java
  > PropertyValuesHolder holder1 = PropertyValuesHolder.ofFloat("scaleX", 0, 1);
  > PropertyValuesHolder holder2 = PropertyValuesHolder.ofFloat("scaleY", 0, 1);
  > PropertyValuesHolder holder3 = PropertyValuesHolder.ofFloat("alpha", 0, 1);
  > ObjectAnimator.ofPropertyValuesHolder(view, holder1, holder2, holder3).start();
  > ```

- 简单属性动画

  > ```Java
  > View view3 = findViewById(R.id.view3);
  > ValueAnimator animator = ObjectAnimator.ofFloat(view3, "translationX", 0, 200);
  > animator.setInterpolator(new BounceInterpolator());
  > animator.setRepeatCount(-1);
  > animator.setRepeatMode(ValueAnimator.REVERSE);
  > animator.setDuration(2000);
  > animator.start();
  > ```

- 动画集执行顺序

  > ```java
  > ObjectAnimator a1 = ObjectAnimator.ofFloat(view, "alpha", 1.0f, 0f);  
  > ObjectAnimator a2 = ObjectAnimator.ofFloat(view, "translationY", 0f, viewWidth);  
  > ......
  > AnimatorSet animSet = new AnimatorSet();  
  > animSet.setDuration(5000);  
  > animSet.setInterpolator(new LinearInterpolator());   
  > //animSet.playTogether(a1, a2, ...); //两个动画同时执行  
  > animSet.play(a1).after(a2); //先后执行
  > ......//其他组合方式
  > animSet.start();  
  > ```

- Keyframe

  > ```java
  > Keyframe keyframe1 = Keyframe.ofFloat(0, 0); // 开始：progress 为 0
  > Keyframe keyframe2 = Keyframe.ofFloat(0.5f, 100); // 进行到一半是，progres 为 100
  > Keyframe keyframe3 = Keyframe.ofFloat(1, 80); // 结束时倒回到 80
  > PropertyValuesHolder holder = PropertyValuesHolder.ofKeyframe("progress", keyframe1, keyframe2, keyframe3);
  > 
  > ObjectAnimator animator = ObjectAnimator.ofPropertyValuesHolder(view, holder);
  > animator.setDuration(2000);
  > animator.setInterpolator(new FastOutSlowInInterpolator());
  > animator.start();
  > ```

###### 使用方式

1. 如果是自定义控件，需要添加setter / getter方法。
2. 用ObjectAnimator.ofXXX()创建ObjectAnimator对象。
3. 用start()开始执行动画。

### Drawable Animaton

- 其实就是Frame动画，幻灯片效果。

  > ```Xml
  > <!-- 注意：rocket.xml文件位于res/drawable/目录下 -->
  > <?xml version="1.0" encoding="utf-8"?>
  > <animation-list xmlns:android="http://schemas.android.com/apk/res/android"
  >     android:oneshot=["true" | "false"] >
  >     <item
  >         android:drawable="@[package:]drawable/drawable_resource_name"
  >         android:duration="integer" />
  > </animation-list>
  > ```