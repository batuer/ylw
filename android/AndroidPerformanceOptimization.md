title:  Android性能优化
date: 2018年4月23日08:09:57
categories: Android
tags: 

	 - Android
	 - 性能优化
cover_picture: /images/OptimizingPerformance.jpg
---

### 性能优化

- 流畅(卡顿优化)
- 内存优化
- 耗电优化
- 安装包大小优化

#### 卡顿优化

![](https://upload-images.jianshu.io/upload_images/2088926-be2fac616c7b93b6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 原因
  - 绘制任务太重，绘制一帧内容耗时太长。
  - 主线程太忙，根据系统传递过来的 VSYNC 信号来时还没准备好数据导致丢帧。
- 优化
  - 界面绘制卡顿
    - 布局优化：布局嵌套过深、使用合适布局。列表控件缓存复用、include、merge、ViewStub、移除Activity默认背景。
  - 数据处理阻塞UI线程。
    - 获取数去耗时，占用UI线程。
    - 处理数据占用CPU高，UI线程拿不到时间片。
  - 内存占用过大
    - 具体见内存优化。
  - 启动优化
    - 绘制优化。
    - 启动加载逻辑优化。
    - 可延迟初始化项，延迟初始化。
  - 动画优化
    - 可以使用硬件加速，提高流畅度。
- 工具
  - System Trace（收集和检测时间信息，CPU的消耗）

  - Hierarchy Viewer（布局层级、绘制）

  - TraceView（定位代码的执行时间）

  - AndroidStudio3.0 自带的 [Profiler](https://developer.android.google.cn/studio/releases/index.html#3-0-0)
  
#### 内存优化

内存优化主要就是消除应用中的内存泄漏、避免内存抖动。

Android应用的沙箱机制，每个应用所分配的大小是有限度的，内存太低会被系统清除，即会出现闪退现象。搞懂Android内存管理机制，如何分配和回收的。

Android应用都是在Android虚拟机上运行，应用后才能徐的内存分配与垃圾回收都是由虚拟机完成的，因此不需要在代码中分配和释放内存。

- Android内存分配回收机制

  - Anroid基于进程中运行的组件及其状态规定了默认的五个回收优先级：Empty process(空进程) >  Background process(后台进程) > Service process(服务进程) > Visible process(可见进程) > Foreground process(前台进程)。
  - Android中由ActivityManagerService 集中管理所有进程的内存资源分配。
  - Android Dalvik Heap与原生Java一样，将堆的内存空间分为三个区域，Young Generation，Old Generation， Permanent Generation。最近分配的对象会存放在Young Generation区域，当这个对象在这个区域停留的时间达到一定程度，它会被移动到Old Generation，最后累积一定时间再移动到Permanent Generation区域。系统会根据内存中不同的内存数据类型分别执行不同的gc操作。GC发生的时候，所有的线程都是会被暂停的。执行GC所占用的时间和它发生在哪一个Generation也有关系，Young Generation中的每次GC操作时间是最短的，Old Generation其次，Permanent Generation最长。

- 内存常见问题及解决

  - 内存泄漏

    - **单例**（主要原因还是因为一般情况下单例都是全局的，有时候会引用一些实际生命周期比较短的变量，导致其无法释放）
    - **静态变量**（同样也是因为生命周期比较长）
    - **Handler内存泄露**[
    - **匿名内部类**（匿名内部类会引用外部类，导致无法释放，比如各种回调）
    - **资源使用完未关闭**（BraodcastReceiver，ContentObserver，File，Cursor，Stream，Bitmap）
    - 内存泄漏检测LeakCanary，监控每个Activity，在activity ondestory后，在后台线程检测引用，然后过一段时间进行gc，gc后如果引用还在，那么dump出内存堆栈，并解析进行可视化显示。
    - 资源性对象未关闭。比如Cursor、File文件等，往往都用了一些缓冲，在不使用时，应该及时关闭它们。
    - 注册对象未注销。比如事件注册后未注销，会导致观察者列表中维持着对象的引用。
    - WebView。WebView 存在着内存泄漏的问题，在应用中只要使用一次 WebView，内存就不会被释放掉。

  - 图片分辨率相关

    - 很多情况下图片所占的内存在整个App内存占用中会占大部分。适配不同屏幕的图片资源。
    - 优先考虑率使用webp格式图片代替传统格式图片。

  - 图片压缩

    - BitmapFactory 在解码图片时，可以带一个Options参数，适当配置该参数。

  - 缓存池大小

    - 图片加载组件都不仅仅是使用软引用或者弱引用了，实际上类似Glide 默认使用的事LruCache，因为软引用 弱引用都比较难以控制，使用LruCache可以实现比较精细的控制，而默认缓存池设置太大了会导致浪费内存，设置小了又会导致图片经常被回收，所以需要根据每个App的情况，以及设备的分辨率，内存计算出一个比较合理的初始值，可以参考Glide的做法。

  - 内存抖动

    - 内存抖动引起OOM。大量小的对象频繁创建，导致内存碎片，从而当需要分配内存时，虽然总体上还是有剩余内存可分配，而由于这些内存不连续，导致无法分配，系统直接就返回OOM了。

  - 常用数据结构优化

    - ArrayMap及SparseArray是android的系统API，是专门为移动设备而定制的。用于在一定情况下取代HashMap而达到节省内存的目的,具体性能见[HashMap，ArrayMap，SparseArray源码分析及性能对比](http://www.jianshu.com/p/7b9a1b386265 )，对于key为int的HashMap尽量使用SparceArray替代，大概可以省30%的内存，而对于其他类型，ArrayMap对内存的节省实际并不明显，10%左右，但是数据量在1000以上时，查找速度可能会变慢。

  - 枚举

    - Android平台上枚举是比较争议的，在较早的Android版本，使用枚举会导致包过大，在个例子里面，使用枚举甚至比直接使用int包的size大了10多倍 ，使用枚举需要谨慎，因为枚举变量可能比直接用int多使用2倍的内存。

  - 尽量使用系统资源。

  - 减少view的层级。

  - 数据相关

    - 使用protobuf。

  - dex优化，代码优化，谨慎使用外部库。

  - 常用工具

    - Memory Analyzer(MAT)工具。[MAT使用教程]([http://blog.csdn.net/itomge/article/details/48719527]())，[MAT - Memory Analyzer Tool 使用进阶]([http://www.lightskystreet.com/2015/09/01/mat_usage/]())。

    - 内存泄漏检测 [Leakcanary](https://github.com/square/leakcanary)。

    - AndroidStudio3.0 自带的 [Profiler](https://developer.android.google.cn/studio/releases/index.html#3-0-0)。

    - Android Lint 工具。
  
#### 耗电优化

Android5.0 以前，在应用中测试电量消耗比较麻烦，也不准确，5.0 之后专门引入了一个获取设备上电量消耗信息的 API:Battery Historian。Battery Historian 是一款由 Google 提供的 Android 系统电量分析工具，和Systrace 一样，是一款图形化数据分析工具，直观地展示出手机的电量消耗过程，通过输入电量分析文件，显示消耗情况，最后提供一些可供参考电量优化的方法。

常用方案：

- 计算优化，避开浮点运算等。
- 避免 WaleLock 使用不当。
- 使用 Job Scheduler。

#### 安装包大小优化

应用安装包大小对应用使用没有影响，但应用的安装包越大，用户下载的门槛越高，特别是在移动网络情况下，用户在下载应用时，对安装包大小的要求更高，因此，减小安装包大小可以让更多用户愿意下载和体验产品。常用方案：

- 代码混淆。使用proGuard 代码混淆器工具，它包括压缩、优化、混淆等功能。
- 资源优化。比如使用 Android Lint 删除冗余资源，资源文件最少化等。
- 图片优化。比如利用 AAPT 工具对 PNG 格式的图片做压缩处理，降低图片色彩位数等。
- 避免重复功能的库，使用 WebP图片格式等。
- 插件化。比如功能模块放在服务器上，按需下载，可以减少安装包大小。



