title:  Binder进程通信
date: 2018年4月12日10:17:30
categories: Android
tags: 

	 - Android
	 - Binder
cover_picture: /images/common.png
---

[学习链接](https://www.jianshu.com/p/4ee3fd07da14 )

#### Binder

- 从机制、模型的角度
  - 定义：Binder是Android中IPC[^1]的一种方式。
  - 作用：Android中跨进程通信。
- 模型的结构、组成
  - 定义：Binder是一种虚拟的物理设备驱动（Binder驱动)。
  - 作用：连接Service进程，Client进程和ServiceManager进程。
- Android代码的实现
  - 定义：Binder是一个类，实现IBinder接口。
  - 作用：Binder机制模型，代码的形式具体实现在Android中。


#### 进程空间

##### 划分

- 一个进程空间划分成用户空间与内核空间，进程内用户与内核隔离。
- 区别
  - 进程间，用户空间数据**不可共享。**
  - 进程间，内核空间数据**可共享。**
- **所有进程共用一个内核空间。**

##### 进程隔离

Linux机制，为了保证安全性与独立性，一个进程不能直接访问另一个进程。

##### IPC

进程间数据交互、通信。

#### Binder跨进程通信机制、模型

##### 模型原理

Binder跨进程通信机制基于Client -Server 模式

![](https://upload-images.jianshu.io/upload_images/2088926-d7e9a9466dec9452.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



##### 模型组成角色

- Client进程（Android客户端）：使用服务的进程。
- Server进程（服务器端）：提供服务的进程。
- ServiceManager进程（类似于路由器）：管理Service注册与查询（将字符形式的Binder名字转化成Client中对该Binder的引用）。
- Binder驱动（持有每个Server进程在内和空间的Binder实体，并提供Client进程Binder实体的引用）：
  - 虚拟设备驱动，是连接Servier、Client和ServiceManager的桥梁。
  - **传递服务进程消息。**
  - **传递进程间需要传递的数据：通过内存映射。**
  - 线程控制：采用Binder线程池，并有Binder驱动自身进行管理。

##### 原理步骤

- 注册服务：ServiceManager拥有Server进程的信息。
  1. Server进程向Binder驱动发起服务注册请求。
  2. Binder驱动将注册请求转发给ServiceManager。
  3. ServiceManager添加该Server进程。
- 获取服务：（Client进程与Server进程已建立连接）
  1. Client向Binder驱动传递要获取服务的名称，获取请求服务。
  2. Binder驱动将请求转发给ServiceManager进程。
  3. ServiceManager通过名称查找需要的Server信息。
  4. 通过Binder驱动将上述服务信息返回给Client进程。
- 使用服务
  1. Binder驱动为跨进程通信做准备——实现内存映射。
     1. Binder驱动创建一块接收缓存区。
     2. 根据ServiceManager进程里的Server信息找到对应的Server进程，实现<u>内核缓存区和Server进程用户空间地址同时映射到**同一个接收缓存区**中</u>。
  2. Client进程将参数数据发送到Server进程。
     1. Client进程通过系统调用copy_from_user()发送数据到内核空间中的缓存区（当前线程被挂起）。
     2. 由于内核缓存与接收进程的用户空间地址存在映射关系（同时映射Binder创建的接收缓存区中）相当于也发送到了Server进程的用户空间地址，即Binder驱动实现了跨进程通信。
     3. Binder驱动通知Server进程执行解包。
  3. Server进程将参数数据发送到Serve进程。
     1. 收到BInder驱动通知后，Server进程从线程池中取出线程，进行数据解包与调用目标方法。
     2. 将最终执行结果写入到自己的共享内存中。
  4. Server进程将目标方法的结果返回给Client进程。
     1. 将最宠执行结果写入映射的用户空间的内存区域中。
     2. 由于内核缓存区与接收进程的用户空间地址存在映射关系(同时映射Binder创建的接收缓存区中)，相当于也发送到了内核缓存区中。
     3. Binder通知Client进程获得返回结果(此时Client进程之前被挂起的线程被重新唤醒)。
     4. Client进程通过系统调用copy_to_user()从内核缓存区接收Server 进程返回的结果。
- 优点：
  - 传输效率高，每次单项通信数据拷贝次数一次，用户空间与内核空间可直接通过共享对象直交互。
  - 为接收进程分配了不确定大小的接收缓存区。


![Binder模型原理说明图](https://upload-images.jianshu.io/upload_images/2088926-86a9acfe520ed71f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### 额外说明

1. Client、Server、ServiceManager进程之间的交互都必须通过Binder驱动，并非直接交互。
   1. Client、Server、ServiceManager进程数据进程空间的用户空间，不可直接交互。
   2. Binder驱动属于进程空间的内核空间。
2. Binder驱动与ServiceManager属于Android基础架构( 系统已经实现)，而Client进程和Server进程应用层，需开发者自己实现。
3. Binder请求的线程管理
   - Server进程可能会创建多个线程来处理Binder请求。
   - Binder模型线程管理采用Binder驱动的线程池，并由Binder驱动自身管理，非Server进程管理。
   - 一个进程Binder线程数默认为16。

#### Binder机制在Android具体实现原理

- Binder机制在Android中实现主要靠Binder类，其实现了IBinder接口。

##### 注册服务

- Server进程通过Binder驱动像ServiceManager进程注册服务。
- Server进程创建一个Binder对象。
  1. Binder实体是Server进程在Binder驱动中的存在形式。
  2. Binder实体保存Server和ServiceManager的信息(保存在内核空间中)。
  3. Binder驱动通过内核空间的Binder实体找到用户空间的Server对象。
- 注册服务后，Binder驱动持有Server进程创建的BInder实体。


##### 获取服务

- Client进程使用某个service前，须通过Binder驱动向ServiceManager进程获取相应的Service信息。

![](https://upload-images.jianshu.io/upload_images/2088926-62925df9974d278b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### 使用服务

Client 进程获取到的Service信息(Binder代理对象)，通过Binder驱动建立与该Server所在Server进程通信的链路，并开始使用服务。

![](https://upload-images.jianshu.io/upload_images/2088926-017b7a26b17765c8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/2088926-416ecacccf3623b1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 优点

Linux上的其他进程通信方式(管道、消息队列、共享内存、信号量、Socker)，Binder机制的优点：

- 高效
  - Binder机制拷贝只需一次，而管道、消息队列、Socket都需两次。
  - 通过驱动在内核空间拷贝数据，不需要额外的同步处理。
- 安全性高
  - Binder机制为每个进程分配了UUID/PID来作为鉴别身份的表示。
  - 在Binder通信时会根据UUID/PID进行有效性检测。
  - 传统的进程通信方式对于通信双方的身份没有做出严格的验证。
- 使用简单
  - 采用Client/Server架构
  - 实现面向对象的调用方式(即在使用BInder时，就和调用一个本地对象实例一样)

[^1]: 通过文件共享、Socket、Messenger（AIDL一种）、ContentProvider、AIDL。



##### Review

###### 一次拷贝

1. Client先从自己的进程空间把通信的数据拷贝到内核空间
2. Server和内核共享数据，所以不需要重新拷贝数据，直接通过内存地址的偏移量直接获取到数据地址。
- Server和内核空间之所以能够共享一块空间数据主要是通过binder_mmap来是实现的。
- 是在内核的虚拟地址空间申请一块喝用户虚拟内存相同大小的内存，然后再申请一个page大小的内存，将它映射到内核虚拟地址空间和用户虚拟内存空间，从而实现了用户空间缓冲和内核空间缓冲同步的功能。

###### 每个进程最多存在多少个Binder线程，这些线程都被占满后会导致什么问题？

​	Binder线程池中的线程数量是在Binder驱动初始化时被定义的，进程池中的线程个数上线为15个，加上主Binder线程，一共最大能存在16个binder线程。

​	当Binder线程都在执行工作时，也就是当出现线程饥饿的时候，从别的进程调用的binder请求如果是同步的话，会在TODO队列中阻塞等待，直到线程池中有空闲的binder线程来处理请求。

###### 使用Binder传输数据的最大限制是多少，被占满后会导致什么问题？

​	在调用mmap时会指定Binder内存缓冲区的大小为1016K，当服务端的内存缓冲区被Binder进程占用满后，Binder驱动不会再处理binder调用并在c++层跑出DeadObjectException到客户端。

同步空间是1016K，异步空间只有一半508K。

###### Binder驱动什么时候释放缓冲区的内存

​	在binder call完成之后，调用Parce.recycle完成释放内存的。

- (128*1024)：对Service Manager的限制。

- ((1*1024*1024) - (4096 *2))：对普通Android services的限制。

- 4M：kernel可以接受的最大空间。

- 所以，实际应用可以申请的最大Binder Buffer是4M。但考虑实际传输的需要和节省内存，Android中申请的是(1M - 8K)。这个值是可以增加的，只要不大于4M就可以。

  > Modify the binder to request 1M - 2 pages instead of 1M. The backing store in the kernel requires a guard page, so 1M allocations fragment memory very badly. Subtracting a couple of pages so that they fit in a power of two allows the kernel to make more efficient use of its virtual address space.

  这段解释还没有充分理解，其大致的意思是：kernel的“backing store”需要一个保护页，这使得1M用来分配碎片内存时变得很差，所以这里减去两页来提高效率，因为减去一页就变成了奇数。至于保护页如何影响内存分配，需要后续分析内存管理时再进一步研究。

  ###### 同步和异步

  Binder通信可以分为同步传输和异步传输，在设置传输空间大小时，将异步传输空间设置为同步传输的一半。
  proc->free_async_space = proc->buffer_size / 2;
  Binder通过红黑树进行buffer管理，将分配使用的buffer放入 allocated_buffers，将回收的buffer放入free_buffers。无论同步还是异步，这里的操作都是相同的。

  而free_async_space只是用来统计异步传输时已经分配了多少空间。初始化时将其设置为全部buffer空间的一半，更多的是想对异步传输做一个限制，不希望异步传输消耗掉所有的buffer。相比较而言，同步传输可能会承载更重要的数据，应该尽量保证同步传输有可用buffer。并且异步传输是不需要等待返回的，连续的异步传输很可能将buffer耗光。