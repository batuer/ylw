title:  面试小结
date: 2018年3月23日09:08:28
categories: Android
tags: 
	 - Android面试

cover_picture: /images/AndroidInterivew.jpg
---



#### 2018-05-07   陕西西建大聚慧

1. int、short、long字节

   | 类型   | 字节    |
   | ------ | ------- |
   | int    | 4个字节 |
   | char   | 2个字节 |
   | byte   | 1个字节 |
   | short  | 2个字节 |
   | long   | 8个字节 |
   | float  | 8个字节 |
   | double | 8个字节 |

2. 树、二叉树

3. Fragment初始化数据

4. service保活

   > http://gusi123.cn/2018/06/26/Android%E8%BF%9B%E7%A8%8B%E3%80%81Service%E4%BF%9D%E6%B4%BB/

5. 锁的使用

6. 线程

7. MVP、MVC优缺点

   - MVC(Mode-View-Controller)：
     - 优点：
       1. 耦合性不高，View层和Model层分离，减少模块之间的影响。
       2. 理解统一，开发维护成本低。
     - 缺点：
       1. View层和Model层相互可知(迪米特法则)。
       2. ​
   - MVP(Model-View-Presenter)：
     - 优点：
       1. 降低耦合度，实现Model和View真正的完全分离，可以修改View而不影响Model。
       2. 职责明显，层次清晰。
       3. 隐藏数据。
       4. Presenter可以复用。
       5. View组件化，提供给上层接口，可以复用View组件。
       6. 代码灵活性。
       7. 利于测试驱动开发。
     - 缺点
       1. Presenter通信协调View、Model，臃肿。
       2. 额外代码。

8. 列表View数据错乱

   > ItemView缓存复用。

9. RecyclerView和ListView缓存
   > http://gusi123.cn/2018/06/27/RecyclerView%E4%B8%8EListView/#ListVIew%E4%B8%8ERecyclerView%E7%BC%93%E5%AD%98%E6%9C%BA%E5%88%B6%E5%AF%B9%E6%AF%94


##### 2018-04-27   山东新北洋信息


1. 自定义View

   > http://gusi123.cn/2018/06/08/Android%E8%87%AA%E5%AE%9A%E4%B9%89View/

2. 事件分发

   > http://gusi123.cn/2018/06/08/Android%E4%BA%8B%E4%BB%B6%E4%BC%A0%E9%80%92/

3. ListView优化

   1. convertView
   2. ViewHolder
   3. 分页加载

4. 列表View数据错乱

5. 多层级控件View

##### 2018-09-19  西安纽扣软件Binder进程通信。

1. Android事件分发。

2. Android View绘制流程。

3. Java封装类
   - 因为泛型类包括预定义的集合，使用的参数都是对象类型，无法直接使用基本类型的数据，所以提供了基本类型的封装类。

4. Android中为什么主线程不会因为Looper.loop()里的死循环阻塞？
   - 主线程因为Looper.loop()死循环，每个消息事件时间限制（ANR）。
   - Android基于事件驱动。

5. [HashMap](https://blog.csdn.net/VampireKalus/article/details/79798372) 

   1. 工作原理
      - HashMap是基于hashing的原理。
      - 使用put(key,value)储存对象Map.Entry到HashMap中。
         1. 先对键调用hashCode()方法，返回的hashCode用于找到bucket位置来储存Map.Entry对象。
         2. HashMap是在bucket中储存键对象和值对象，作为Map.Entry。
      - 使用get(key)从HashMap中获取对象。
         1. 根据key的hashCode获取index。
         2. 遍历链表key.equals()找对应Map.Entry对象。
   2. [JDK1.8源码分析](https://blog.csdn.net/brycegao321/article/details/52527236) 

   ##### 2018-12-24  西安种子科技

   1. Fragment生命周期

      ![](https://upload-images.jianshu.io/upload_images/2088926-c4e0c600af1b92e1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

   2. Fragment懒加载

      - setUserVisibleHint(boolean isVisibleToUser)判断当前Fragment是否可见。