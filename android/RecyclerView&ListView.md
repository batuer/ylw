title:  RecyclerView与ListView
date: 2018年6月27日14:37:04
categories: RecyclerView、ListView
tags: 

	 - RecyclerView
	 - ListView
cover_picture: /images/common.png
---

### 区别

##### 布局效果对比

1. ListView布局单一，纵向。
2. RecyclerView的布局由LayoutManager决定（可纵向、横向、瀑布流或自定义）。

##### 常用功能与API对比

1. HeaderView和Foot而View：ListView支持添加HeaderView和FooterView，RecyclerView没有。

2. EmptyView：ListView默认有setEmptyView()，RecyclerView没有。

3. 局部刷新：RecyclerView支持局部刷新，ListView需自己实现。

   ```java
    /**
            * @param data
            * @param pos  数据pos
            */
           private void updateItemView(String data, int pos) {
               int firstVisiblePosition = mLv.getFirstVisiblePosition();
               int index = pos - firstVisiblePosition;
               if (index >= 0 && index < mLv.getChildCount()) {
                   View child = mLv.getChildAt(index);
                   //更新
               }
           }
   ```

4. 监听条目点击：ListView支持条目点击事件，RecyclerView需要自己实现，（[RecyclerView无法添加onItemClickListener最佳的高效解决方案](https://blog.csdn.net/liaoinstan/article/details/51200600)）。

5. 动画效果：RecyclerView由默认实现效果可扩展性强。

##### Android L引入嵌套滚动机制（NestedScrolling）

1. 在事件分发机制中，Touch事件在进行分发的时候，由父View向子View传递，一旦子View消费这个事件的话，那么接下来的事件分发的时候，父View将不接受，由子View进行处理；但是与Android的**事件分发机制**不同，**嵌套滚动机制**（Nested Scrolling）可以弥补这个不足，能让子View与父View同时处理这个Touch事件，主要实现在于**NestedScrollingChild**与**NestedScrollingParent**这两个接口；而在RecyclerView中，实现的是NestedScrollingChild，所以能实现嵌套滚动机制；
2. ListView就没有实现嵌套滚动机制；

##### RecyclerView优缺点

###### 优点

- RecyclerView本身它是不关心视图相关的问题的 ，由LayoutManager管理。
- 只负责回收和重用的工作 。
- 可扩展性强。

###### 缺点

- 条目监听。
- HeaderView和FooterView。
- EmptyView。

##### RecyclerView

- Adapter：包装数据集合并为每个条目创建视图。
- ViewHolder：保存用于显示每个数据条目的 子View。
- LayoutManager：决定每个ItemView的位置。
- ItemDecoration：条目间隔绘制。
- ItemAnimatior：条目添加、移除、重排序动画。

### ListVIew与RecyclerView缓存机制对比

> https://segmentfault.com/a/1190000007331249

#### 缓存原理相似

1. 回收离屏的ItemView至缓存。
2. 入屏的ItemView优先从缓存中获取。
3. 两者实现细节有差异。

#### 缓存层级不同

##### RecyclerView

1. mAttachedScrap
   - 快速重用屏幕上可见的列表项ItemView，不需要createView()和bindView()。
2. mCacheViews（优势）
   - 缓存离开屏幕的 ItemView，复用。
   - 默认上限2，即缓存屏幕外2个ItemView。
   - ItemView被复用时，无需bindView快速复用。
   - Adapter被更换时被清空，生命周期关联于Adapter。
3. mViewCacheExtension
   - 默认不实现，扩展。
4. mRecyclerPool
   - 缓存离开屏幕的 ItemView，复用。
   - 默认上限5。

##### ListView

1. mActiveViews
   - 快速重用屏幕上可见的列表项ItemView，不需要createView()和bindView()。
2. mScrapViews
   - 缓存离开屏幕的ItemView，复用。
   - Adapter被更换时，被清空，生命周期关联于Adapter。

#### 缓存不同

1. RecyclerView缓存RecyclerView.ViewHolder，ItemView + ViewHolder。

2. ListView获取缓存

   ![](https://upload-images.jianshu.io/upload_images/2088926-a16a93ebbeed4bee.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3. RecyclerView获取缓存

   ![](https://upload-images.jianshu.io/upload_images/2088926-9137cae6bbb5658f.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

4. 局部刷新

   1. RecyclerView 提供局部刷新，ListVIew没有。
   2. RecyclerView局部刷新时，会预先通过对pso和flag的预处理，尽可能的减少bindVIew()。

### 结论

- 性能上，RecyclerView并没有显著的提升。

- 有频繁更新、ItemView动画、局部刷新这些需求时，RecyclerView优势大于ListView。
- RecyclerView扩展性强（LayoutManager：ItemView布局，ViewCacheExtension：ItemView缓存复用 ）。