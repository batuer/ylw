title:  自定义View
date: 2018年5月3日08:34:08
categories: Activity
tags: 

	 - Android
	 - View基础
	 - View Measure
	 - View Layout
	 - View Draw
cover_picture: /images/common.png
---

[学习链接](https://www.jianshu.com/p/146e5cec4863)

#### View基础

##### View分类

1. View，不包含子View，所有View的最基类。
2. ViewGroup，包含子View，也是View的子类。

##### View构造函数

```java
  //代码new
  public MyView(Context context) {
    super(context);
  }

  /**
   * xml inflate
   *
   * @param attrs 属性集，自定义属性也从这里来
   */
  public MyView(Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
  }

  /**
   * 不会主动调用
   *
   * @param defStyleAttr style属性
   */
  /*
    1.首先获取给定的AttributeSet中的属性值
    2.如果找不到，则去AttributeSet中style（你在写布局文件时定义的style="@style/xxxx"）指定的资源获取
    3.如果找不到，则去defStyleAttr以及defStyleRes中的默认style中获取。
    4.最后去找的是当前theme下的基础值。
   */
  public MyView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
  }

  /**
   * Api >=21
   * @param defStyleRes View有style属性时
   */
  @TargetApi(Build.VERSION_CODES.LOLLIPOP)
  public MyView(Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
    super(context, attrs, defStyleAttr, defStyleRes);
  }
```

##### View位置(坐标)

![](https://upload-images.jianshu.io/upload_images/2088926-35c44aad5ee72007.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### View  Measure

##### 作用

1. 某些情况下，需要多次测量才能确定View自身期望和父容器约束条件的综合值。
2. 测量得到的值并不是View最终的值，在layout()后才能得到最终的值。getMeasureWidth()不一定等于getWidth()的原因。

###### Measure值影响因素

###### ViewGroup.LayoutParams

- 指定View的宽高值。

  ```java
  @ViewDebug.ExportedProperty(category = "layout", mapping = {
              @ViewDebug.IntToString(from = MATCH_PARENT, to = "MATCH_PARENT"),
              @ViewDebug.IntToString(from = WRAP_CONTENT, to = "WRAP_CONTENT")
          })
          public int width;

   @ViewDebug.ExportedProperty(category = "layout", mapping = {
              @ViewDebug.IntToString(from = MATCH_PARENT, to = "MATCH_PARENT"),
              @ViewDebug.IntToString(from = WRAP_CONTENT, to = "WRAP_CONTENT")
          })
          public int height;
  ```

###### MeasureSpec

1. 简介

   - 定义：测量规格类(测量View大小的指导参数)。
   - 作用：指导作用View的大小。

2. 组成

   ```java
   int measureSpec = MeasureSpec.makeMeasureSpec(0, MeasureSpec.EXACTLY);
   ```

   ```java
   //Older apps may need this compatibility hack for measurement.
   //sUseBrokenMakeMeasureSpec = targetSdkVersion <= Build.VERSION_CODES.JELLY_BEAN_MR1;
   public static int makeMeasureSpec(@IntRange(from = 0, to = (1 << MeasureSpec.MODE_SHIFT) - 1) int size,
                                             @MeasureSpecMode int mode) {
               if (sUseBrokenMakeMeasureSpec) {
                   return size + mode;
               } else {
                   return (size & ~MODE_MASK) | (mode & MODE_MASK);
               }
           }
   ```

   ```java
    //UNSPECIFIED 父容器不约束子View，常用于系统内部

      //EXACTLY 父容器指定确切值，子View应该是这个指定值

      //AT_MOST 父容器提供一个最大参考值，子View根据自身测量不可超过参考值

      @IntDef({UNSPECIFIED, EXACTLY, AT_MOST})

         @Retention(RetentionPolicy.SOURCE)
          public @interface MeasureSpecMode {}
   ```

   **结论：子View的大小由父View的MeasureSpec和自身的LayoutParams属性共同决定子View的大小。**

3. Measure过程

   1. View

      1. measure()

         ```java
         //final 不支持子View重写
         public final void measure(int widthMeasureSpec, int heightMeasureSpec) {
               ...
               //测量
         	int cacheIndex = forceLayout ? -1 : mMeasureCache.indexOfKey(key);
         	if (cacheIndex < 0 || sIgnoreMeasureCache) {
         		//onMeasure 计算大小
         		onMeasure(widthMeasureSpec, heightMeasureSpec);
                 ...
         	} else {
         		...
         	}
             ...       
         }
         ```

      2. onMeasure()

         ```java
          protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
                 setMeasuredDimension(getDefaultSize(getSuggestedMinimumWidth(), widthMeasureSpec),
                         getDefaultSize(getSuggestedMinimumHeight(), heightMeasureSpec));
             }
         ```

		 ```java
          public static int getDefaultSize(int size, int measureSpec) {
                 int result = size;
                 int specMode = MeasureSpec.getMode(measureSpec);
                 int specSize = MeasureSpec.getSize(measureSpec);
    
                 switch (specMode) {
                  //多为系统调用，getSuggestSize
                 case MeasureSpec.UNSPECIFIED:
                     result = size;
                     break;
                 case MeasureSpec.AT_MOST:
                 case MeasureSpec.EXACTLY:
                     result = specSize;
                     break;
                 }
                 return result;
             }
    
          //backGround不为null，固有的尺寸
          protected int getSuggestedMinimumWidth() {
                 return (mBackground == null) ? mMinWidth : max(mMinWidth, mBackground.getMinimumWidth());
             }
       ```
   
      3. setMeasuredDimension()
   
         ```JAVA
         //赋值 mMeasuredWidth = measuredWidth; mMeasuredHeight = measuredHeight;
         protected final void setMeasuredDimension(int measuredWidth, int measuredHeight) {
                 ...
             }
         ```
   
      4. 完成测量

   2. ViewGroup

      原理：

      1. 遍历测量所有子View的测量尺寸。
      2. 合并所有子View的尺寸得到ViewGroup的测量尺寸。

      过程：

      1. measure()

         ```java
         //final 不支持子View重写
         public final void measure(int widthMeasureSpec, int heightMeasureSpec) {
               ...
               //测量
         	int cacheIndex = forceLayout ? -1 : mMeasureCache.indexOfKey(key);
         	if (cacheIndex < 0 || sIgnoreMeasureCache) {
         		//onMeasure 计算大小
         		onMeasure(widthMeasureSpec, heightMeasureSpec);
                 ...
         	} else {
         		...
         	}
             ...       
         }
         ```

         ​

      2. onMeasure() (**必须复写,不同ViewGroup有不同的测量布局方式，直接影响ViewGroup的测量尺寸**)

         ```java
          @Override protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
            //1.遍历测量子View的尺寸
               //2.measureChild
                 //3.getChildMeasureSpec
             measureChildren(widthMeasureSpec,heightMeasureSpec);
             //4.合并汇总的到ViewGroup的测量尺寸
             int measuredWidth = 0;
             int measuredHeight = 0;
             //5.赋值 mMeasuredWidth、mMeasuredHeight
             setMeasuredDimension(measuredWidth,measuredHeight);
           }
         ```

         ​

      3. measureChildren()

         ```java
          protected void measureChildren(int widthMeasureSpec, int heightMeasureSpec) {
                 final int size = mChildrenCount;
                 final View[] children = mChildren;
                 for (int i = 0; i < size; ++i) {
                     final View child = children[i];
                     if ((child.mViewFlags & VISIBILITY_MASK) != GONE) {
                         measureChild(child, widthMeasureSpec, heightMeasureSpec);
                     }
                 }
             }
         ```

         ​

      4. measureChild()

         ```java
          protected void measureChild(View child, int parentWidthMeasureSpec,
                     int parentHeightMeasureSpec) {
                 final LayoutParams lp = child.getLayoutParams();

                 final int childWidthMeasureSpec = getChildMeasureSpec(parentWidthMeasureSpec,
                         mPaddingLeft + mPaddingRight, lp.width);
                 final int childHeightMeasureSpec = getChildMeasureSpec(parentHeightMeasureSpec,
                         mPaddingTop + mPaddingBottom, lp.height);

                 child.measure(childWidthMeasureSpec, childHeightMeasureSpec);
             }

         //自身LayoutParams，可以复写为子View添加自定义属性
          @Override protected boolean checkLayoutParams(ViewGroup.LayoutParams p) {
             return p instanceof LayoutParams;
           }

           @Override public LayoutParams generateLayoutParams(AttributeSet attrs) {
             return new LayoutParams(getContext(), attrs);
           }

           @Override protected ViewGroup.LayoutParams generateLayoutParams(ViewGroup.LayoutParams p) {
             return new LayoutParams(p);
           }

         ```

         ​

      5. getChildMeasureSpec()

         ```java
          final int childWidthMeasureSpec = getChildMeasureSpec(parentWidthMeasureSpec,
                         mPaddingLeft + mPaddingRight, lp.width);
                         
          public static int getChildMeasureSpec(int spec, int padding, int childDimension) {
                 int specMode = MeasureSpec.getMode(spec);
                 int specSize = MeasureSpec.getSize(spec);

                 int size = Math.max(0, specSize - padding);

                 int resultSize = 0;
                 int resultMode = 0;
                 
                 ...
                 
                 return MeasureSpec.makeMeasureSpec(resultSize, resultMode);
             }
         ```

         ​

      6. 遍历子View测量并汇总，ViewGroup根据需求自己实现

      7. setMeasuredDimension()
​
#### View Layout

##### 作用

计算确定View的位置，即Left、Top、Right、Bottom的坐标。

##### Layout过程

1. View

   1. layout()

      ```java
      //View本身的位置
      public void layout(int l, int t, int r, int b) {  
          // 当前视图的四个顶点
          int oldL = mLeft;  
          int oldT = mTop;  
          int oldB = mBottom;  
          int oldR = mRight;  
            
          // 1. 确定View的位置：setFrame（） / setOpticalFrame（）
          // 即初始化四个顶点的值、判断当前View大小和位置是否发生了变化 & 返回 
          // ->>分析1、分析2
          boolean changed = isLayoutModeOptical(mParent) ?
                  setOpticalFrame(l, t, r, b) : setFrame(l, t, r, b);

          // 2. 若视图的大小 & 位置发生变化
          // 会重新确定该View所有的子View在父容器的位置：onLayout（）
          if (changed || (mPrivateFlags & PFLAG_LAYOUT_REQUIRED) == PFLAG_LAYOUT_REQUIRED) {  

              onLayout(changed, l, t, r, b);  
              // 对于单一View的laytou过程：由于单一View是没有子View的，故onLayout（）是一个空实现->>分析3
              // 对于ViewGroup的laytou过程：由于确定位置与具体布局有关，所以onLayout（）在ViewGroup为1个抽象方法，需重写实现（后面会详细说）
        ...

      }
      ```
	
2. ViewGroup

   原理：

   1. 计算自身ViewGroup的位置：layout()
   2. 遍历子View并确定子View在ViewGroup的位置(调用子View的layout() )：onLayout() 

   ​


```java
 //与单一View的layout（）源码一致
  public void layout(int l, int t, int r, int b) {  
    int oldL = mLeft;  
    int oldT = mTop;  
    int oldB = mBottom;  
    int oldR = mRight;  
      
    // 1. 确定View的位置：
    boolean changed = isLayoutModeOptical(mParent) ?
            setOpticalFrame(l, t, r, b) : setFrame(l, t, r, b);

    // 2. 若视图的大小 & 位置发生变化
    // 会重新确定该View所有的子View在父容器的位置：onLayout（）
    if (changed || (mPrivateFlags & PFLAG_LAYOUT_REQUIRED) == PFLAG_LAYOUT_REQUIRED) {  

        onLayout(changed, l, t, r, b);  
        
        // 对于单一View的laytou过程：由于单一View是没有子View的，故onLayout（）是一个空实现（上面已分析完毕）
        
        // 对于ViewGroup的laytou过程：由于确定位置与具体布局有关，所以onLayout（）在ViewGroup为1个抽象方法，需重写实现 
  ...

}  


  //确定View本身的位置，即设置View本身的四个顶点位置
  protected boolean setFrame(int left, int top, int right, int bottom) {
        ...
    }

//确定View本身的位置(视觉上的)，即设置View本身的四个顶点位置
  private boolean setOpticalFrame(int left, int top, int right, int bottom) {
      
     ...
         
        // 内部实际上是调用setFrame（）
        return setFrame(
                left   + parentInsets.left - childInsets.left,
                top    + parentInsets.top  - childInsets.top,
                right  + parentInsets.left + childInsets.right,
                bottom + parentInsets.top  + childInsets.bottom);
    }
    // 回到调用原处

/**
  * 分析3：onLayout（）
  * 作用：计算该ViewGroup包含所有的子View在父容器的位置（）
  * 注： 
  *      a. 定义为抽象方法，需重写，因：子View的确定位置与具体布局有关，所以onLayout（）在ViewGroup没有实现
  *      b. 在自定义ViewGroup时必须复写onLayout（）！！！！！
  *      c. 复写原理：遍历子View 、计算当前子View的四个位置值 & 确定自身子View的位置（调用子View layout（））
  */ 
  protected void onLayout(boolean changed, int left, int top, int right, int bottom) {

     // 参数说明
     // changed 当前View的大小和位置改变了 
     // left 左部位置
     // top 顶部位置
     // right 右部位置
     // bottom 底部位置

     // 1. 遍历子View：循环所有子View
          for (int i=0; i<getChildCount(); i++) {
              View child = getChildAt(i);   

              // 2. 计算当前子View的四个位置值
                // 2.1 位置的计算逻辑
                ...// 需自己实现，也是自定义View的关键

                // 2.2 对计算后的位置值进行赋值
                int mLeft  = Left
                int mTop  = Top
                int mRight = Right
                int mBottom = Bottom

              // 3. 根据上述4个位置的计算值，设置子View的4个顶点：调用子view的layout() & 传递计算过的参数
              // 即确定了子View在父容器的位置
              child.layout(mLeft, mTop, mRight, mBottom);
              // 该过程类似于单一View的layout过程中的layout（）和onLayout（），此处不作过多描述
          }
      }
  }
```

#### View Draw

##### 作用

绘制View视图

#####  过程

- 原理

  1. View绘制自身(背景、内容)。
  2. 绘制装饰(滚动条、滚动指示器、前景等)。

- 流程

  1. draw()

     ```java
     /**
       * 源码分析：draw（）
       * 作用：根据给定的 Canvas 自动渲染 View（包括其所有子 View）。
       * 绘制过程：
       *   1. 绘制view背景
       *   2. 绘制view内容
       *   3. 绘制子View
       *   4. 绘制装饰（渐变框，滑动条等等）
       * 注：
       *    a. 在调用该方法之前必须要完成 layout 过程
       *    b. 所有的视图最终都是调用 View 的 draw （）绘制视图（ ViewGroup 没有复写此方法）
       *    c. 在自定义View时，不应该复写该方法，而是复写 onDraw(Canvas) 方法进行绘制
       *    d. 若自定义的视图确实要复写该方法，那么需先调用 super.draw(canvas)完成系统的绘制，然后再进行自定义的绘制
       */ 
       public void draw(Canvas canvas) {

         ...// 仅贴出关键代码
       
         int saveCount;

         // 步骤1： 绘制本身View背景
             if (!dirtyOpaque) {
                 drawBackground(canvas);
             }

         // 若有必要，则保存图层（还有一个复原图层）
         // 优化技巧：当不需绘制 Layer 时，“保存图层“和“复原图层“这两步会跳过
         // 因此在绘制时，节省 layer 可以提高绘制效率
         final int viewFlags = mViewFlags;
         if (!verticalEdges && !horizontalEdges) {

         // 步骤2：绘制本身View内容
             if (!dirtyOpaque) 
                 onDraw(canvas);
             // View 中：默认为空实现，需复写
             // ViewGroup中：需复写

         // 步骤3：绘制子View
         // 由于单一View无子View，故View 中：默认为空实现
         // ViewGroup中：系统已经复写好对其子视图进行绘制我们不需要复写
             dispatchDraw(canvas);
             
         // 步骤4：绘制装饰，如滑动条、前景色等等
             onDrawScrollBars(canvas);

             return;
         }
         ...    
     }
     ```

     ​

  2. drawBackground()

     ```java
     /**
       * 步骤1：drawBackground(canvas)
       * 作用：绘制View本身的背景
       */
       private void drawBackground(Canvas canvas) {
             // 获取背景 drawable
             final Drawable background = mBackground;
             if (background == null) {
                 return;
             }
             // 根据在 layout 过程中获取的 View 的位置参数，来设置背景的边界
             setBackgroundBounds();

             .....

             // 获取 mScrollX 和 mScrollY值 
             final int scrollX = mScrollX;
             final int scrollY = mScrollY;
             if ((scrollX | scrollY) == 0) {
                 background.draw(canvas);
             } else {
                 // 若 mScrollX 和 mScrollY 有值，则对 canvas 的坐标进行偏移
                 canvas.translate(scrollX, scrollY);
     ```


                 // 调用 Drawable 的 draw 方法绘制背景
                 background.draw(canvas);
                 canvas.translate(-scrollX, -scrollY);
             }
        }
     ```
    
     ​

  3. onDraw()

     ```
     /**
       * 作用：绘制View本身的内容
       * 注：
       *   a. 由于 View 的内容各不相同，所以该方法是一个空实现
       *   b. 在自定义绘制过程中，需由子类去实现复写该方法，从而绘制自身的内容
       *   c. 谨记：自定义View中 必须 且 只需复写onDraw（）
       */
       protected void onDraw(Canvas canvas) {
           
             ... // 复写从而实现绘制逻辑

       }

     ```

     ​

  4. dispatchDraw()

     ```java
     //View 没有子View空实现
     //ViewGroup
        protected void dispatchDraw(Canvas canvas) {
             ......

              // 1. 遍历子View
             final int childrenCount = mChildrenCount;
             ......

             for (int i = 0; i < childrenCount; i++) {
                     ......
                     if ((transientChild.mViewFlags & VISIBILITY_MASK) == VISIBLE ||
                             transientChild.getAnimation() != null) {
                       // 2. 绘制子View
                         more |= drawChild(canvas, transientChild, drawingTime);
                     }
                     ....
             }
         }
     //绘制子View
         protected boolean drawChild(Canvas canvas, View child, long drawingTime) {
         
             return child.draw(canvas, this, drawingTime);
         }

     ```

     ​

  5. onDrawForeground()

     ```java
     public void onDrawForeground(Canvas canvas) {
         //滚动条指示器
             onDrawScrollIndicators(canvas);
         //滚动条
             onDrawScrollBars(canvas);
     	//前景
             final Drawable foreground = mForegroundInfo != null ? mForegroundInfo.mDrawable : null;
             if (foreground != null) {
                 if (mForegroundInfo.mBoundsChanged) {
                     mForegroundInfo.mBoundsChanged = false;
                     final Rect selfBounds = mForegroundInfo.mSelfBounds;
                     final Rect overlayBounds = mForegroundInfo.mOverlayBounds;

                     if (mForegroundInfo.mInsidePadding) {
                         selfBounds.set(0, 0, getWidth(), getHeight());
                     } else {
                         selfBounds.set(getPaddingLeft(), getPaddingTop(),
                                 getWidth() - getPaddingRight(), getHeight() - getPaddingBottom());
                     }

                     final int ld = getLayoutDirection();
                     Gravity.apply(mForegroundInfo.mGravity, foreground.getIntrinsicWidth(),
                             foreground.getIntrinsicHeight(), selfBounds, overlayBounds, ld);
                     foreground.setBounds(overlayBounds);
                 }

                 foreground.draw(canvas);
             }
         }
     ```

  6. 加入自己想要绘制的内容。

- View.setWillNotDraw()，标记View是否需要绘制，系统优化ViewGroup默认为true。








