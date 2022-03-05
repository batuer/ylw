title:  Android面试
date: 2018年3月23日09:08:28
categories: Android
tags: 
	 - Android面试
cover_picture: /images/AndroidInterivew.jpg
---

## 一、Java

####  Java基础

1. 对封装、抽象、继承、多态的理解

   > - 封装：面向对象重要原则，把过程和数据包围起来，数据的访问通过自定义接口，隐藏内部实现细节。增加安全性。
   > - 抽象：同一事物共有属性和方法的集合，多态的基础。
   > - 继承：代码复用的重要手段。单继承特点，只有一个父类，继承父类非私有属性和方法。根据自身需求扩展。
   > - 多态：同一种行为具有不同的表现形态或形式的能力。程序中定义的引用变量在编译时期不能确定具体类型，在运行中才能知道具体类型。

2. 泛型的作用及使用场景

   > 作用：编译阶段完成类型转换，避免运行时期转换异常。类型安全。
   >
   > 场景：
   >
   > - 泛型类和接口
   > - 泛型方法
   > - 泛型构造器
   > - 类型通配符，上限和下限通配符。

3. 枚举的特点及使用场景

   > 特点：
   >
   > - 枚举的直接父类是java.lang.Enum，但是不能显示的继承Enum。
   > - 枚举就相当于一个类，可以定义构造方法、成员变量、普通方法和抽象方法。
   > - 每个实例分别用于一个全局常量表示，枚举类型的对象是固定的，实例个数有限，不能使用new关键字。 
   > - 枚举实例后有花括号时，该实例是枚举的**匿名内部类对象**。
   >
   > 场景：
   >
   > - 普通常量。
   > - 枚举中添加变量、构造函数，灵活获取指定值。
   > - 添加自己特定的方法，实现自己的需求。根据code获取相应的对应值。（常见于原因Code获取具体原因描述）

4. 线程sleep和wait的区别

   > - sleep（）属于Thread，wait（）属于Object.。
   > - sleep（）仅仅是睡眠，不涉及到锁的释放问题，让出CPU，睡眠时间结束自动竞争CPU执行。 wait（）绑定了某个对象的锁，等待该对象的notify（），notifyAll（）来唤醒自己，等待的时间是未知的，甚至出现死锁。
   > - 无论怎用sleep都会释放cpu，但是在线程池中会占用位置。（CPU和线程区别）。

5. JAVA反射机制

   Java反射机制是在**运行**状态中，对于任意一个类，都能够知道这个类中的所有属性和方法；对于任意一个对象，都能够调用它的任意一个方法和属性；这种**动态获取的信息以及动态调用对象的方法**的功能称为java语言的反射机制。

   > - 在运行时判断任意一个对象所属的类。
   > - 在运行时构造任意一个类的对象。
   > - 在运行时判断任意一个类所具有的成员变量和方法。
   > - 在运行时调用任意一个对象的方法。
   > - 生成**动态代理**。

6. weak/soft/strong引用的区别

   > - JAVA虚拟机通过**可达性**（Reachability)来判断对象是否存活，基本思想：以"GC Roots"的对象作为起始点向下搜索，搜索形成的路径称为引用链，当一个对象到GC Roots没有任何引用链相连（即不可达的），则该对象被判定为可以被回收的对象，反之不能被回收。
   > - Strong：普通的java引用，我们通常new的对象就是： `StringBuffer buffer = new StringBuffer();` 如果一个对象通过一串强引用链可达，那么它就不会被垃圾回收。
   > - Soft：当内存不足的时候才回收它。
   > - Weak：一旦gc发现对象是weakReference可达，就会把它放到ReferenceQueue中，下次gc时回收它。
   > - Phantom：和soft，weak Reference区别较大，它的get()方法总是返回null。

7. Object的hashCode()与equals()的区别和作用
   > - equals() 的作用是 用来判断两个对象是否相等。
   > - hashCode() 的作用是获取哈希码，也称为散列码；它实际上是返回一个int整数。这个哈希码的作用是确定该对象在哈希表中的**索引位置**。
   > - hashCode是为了提高在散列结构存储中查找的效率，在线性表中没有作用。

8. interface和abstract class区别

   > - Java抽象类定义的两种机制，这两张机制赋予了Java强大的面向对象能力。两者有很大相似性，也可以相互替换，但两者之间也有很大区别。
   > - 抽象类：在代码中使用abstract修饰的class即为抽象类，**类对象的抽象集合。**具体的使用中主要用来进行类型隐藏，我们可以构造出一组固定的行为，这组行为却能够有任意个可能的具体实现，这个抽象描述就是**抽象类**，这一组任意个可能的具体实现则表现为泽类。这样模块可以操作一个抽象提，由于模块依赖于一个固定的抽象提，一次它可以使不允许修改的，但是允许扩展，这就是面向对象设计的一个核心原则OCP，抽象是关键所在。
   > - 接口：比abstract class更加抽象，是一种特殊的abstract class。用Interface关键字修饰，**类方法的抽象集合。**为了把程序模块进行固话契约，降低耦合。

   ![Markdown](https://upload-images.jianshu.io/upload_images/2088926-38d48cab30b2d2fe.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


#### 集合类

1. JAVA常用集合类功能、区别和性能

   - Java的集合类主要由两个接口派生而出：Collection和Map,Collection和Map是Java集合框架的根接口。

     ![](http://upload-images.jianshu.io/upload_images/3985563-e7febf364d8d8235.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

     ​

     图中，ArrayList,HashSet,LinkedList,TreeSet是我们经常会有用到的已实现的集合类。

     1. Collection: 最基本的集合类型，实现**Iterable**接口。
        1. List: **有序，可重复**。
           1. LinkedList: 双向链表实现，可被用作堆栈、队列、双向队列，set和get函数以O(n/2)的性能获取一个节点。
           2. ArrayList: 数组实现，自动扩容。
           3. Vector: 数组实现，自动扩容，同步存取。
           4. Stack: 继承Vector,实现后进先出堆栈，提供5个额外方法使得Vector当堆栈使用。
        2. Set: **不可重复**。
           1. HashSet: 代用对象hashCode，计算存放位置,通过hashCode 和equals判断重复。(HashMap的Key的判断,无序)
           2. TreeSet: 排序。(TreeMap存取)

   - Map实现类用于保存具有映射关系的数据。Map保存的每项数据都是key-value对，也就是由key和value两个值组成。Map里的key是不可重复的，key用户标识集合里的每项数据。

     ![](http://upload-images.jianshu.io/upload_images/3985563-06052107849a7603.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

     图中，HashMap和TreeMap经常用到。

     1. Map: Key和Value 的映射，不包含相同的Key。
        1. HashTable: 同步，存取非空对象。(Entrty对象)
        2. HashMap: 不同步，允许空对象，不保证有序，存储Entrty。
        3. Treemap: 类似HashMap，实现排序。
        4. LinkedHashMap: Hash表和链表的实现，类似HashMap，保证双向链表节点的顺序。
        5. WeakHashMap: key弱应用。
        6. ArrayMap: 没用Entrty，由两数组维护。速度慢于HashMap，有排序，二分法查找，数组收缩功能，时间换空间。

2. 并发相关的集合类 

   1. Vector
      - Synchronize实现
      - 数组保证顺序
      - 自动扩容，System.arraycopy()效率低
      - 适合一次赋值多次读取，数据量小的多线程环境
   2. Stack
      - Vector子类,扩展5个关于栈的操作方法
      - 栈先进后出
   3. HashTable
      - Synchronize实现
      - Entrty对象
   4. Concurrent包提供的线程安全集合
      1. ConcurrentHashMap
         - 不允许空键值对
         - 使用ReentranLock保证线程安全
      2. ConcurrentLinkedDeque
         - 双端队列
         - Linked大小不受限
      3. ConcurrentLinkedQueue
      4. ConcurrentSkipListMap
      5. ConcurrentSkipSet
         - 基于ConcurrentSkipListMap实现
      6. CopyOnWriteArrayList
         - 写入时赋值数组
         - ReentrantLock实现线程安全
         - 保证数据多线程最终一致性
         - Copy两份数组，内存浪费。

3. 部分常用集合类的内部实现方式

#### 多线程相关

1. Thread、Runnable、Callable、Futrue类关系与区别

   - Thread
     - 实现Runnable接口
     - 提供线程等待、睡眠、礼让等操作


   - Runnable
     - 接口
     - 无返回值
   - Callable
     - 接口
     - 有返回值he
   - Future
     - 对Runnable和Callable任务的执行结果进行取消、查询是否完成、获取结构。设置结果等操作
   - FutureTask
     - Runnable和Future结合

2. JDK中默认提供了哪些线程池，有何区别

    > https://batuer.github.io/2018/03/15/Executor/

3. 线程同步有几种方式，分别阐述在项目中的用法

   1. **临界区** 
      - 通过对多线程串行化来访问公共资源或一段代码，速度快，是个控制数据访问。任何时刻只允许一个线程对共享资源访问。多线程访问时，刚起其它等待线程，一直等到临界区的线程离开。
      - Step
         1. 定义临界区对象Lock
         2. 访问共享资源之前，获得临街对象Lock.lock()
         3. 访问资源后，放弃临界对象Lock.unlock()
   2. **互斥量** (互斥锁)
      - 采用互斥对象机制，只有拥有互斥对象的线程才有访问公共资源的权限，互斥对象只有一个。
   3. **信号量** 
      - 允许多线程访问公共资源，但是限制同一时刻访问该资源的最大线程数
   4. **事件**
      - 通过通知方式保持线程同步，并可实现优先级操作。
   5. 具体实现
      1. 同步方法：synchronized修饰方法。
      2. 同步代码块：synchronized修饰语句块
         - 同步是一种高开销操作，减少同步内容。没有必要同步整个方法时，同步关键语句块。
      3. 特殊域变量(volatile)实现线程同步（可见性）
         1. volatile关键字为域变量的访问提供了一种免锁机制
         2. 使用volatile修饰域相当于告诉[虚拟机](http://www.2cto.com/os/xuniji/)该域可能会被其他线程更新
         3. 因此每次使用该域就要重新计算，而不是使用寄存器中的值
         4. volatile不会提供任何原子操作，它也不能用来修饰final类型的变量 
      4. 使用重入锁
         1. 在JavaSE5.0中新增了一个java.util.concurrent包来支持同步
         2. ReentrantLock类是可重入、互斥、实现了Lock接口的锁
         3. 它与使用synchronized方法和快具有相同的基本行为和语义，并且扩展了其能力
         4. 注：**关于Lock对象和synchronized关键字的选择**
            - 最好两个都不用，使用一种java.util.concurrent包提供的机制，能够帮助用户处理所有与锁相关的代码
            - 如果synchronized关键字能满足用户的需求，就用synchronized，因为它能简化代码 
            - 如果需要更高级的功能，就用ReentrantLock类，此时要注意及时释放锁，否则会出现死锁，通常在finally代码释放锁 
      5. 使用局部变量实现线程同步 
         - 如果使用ThreadLocal管理变量，则每一个使用该变量的线程都获得该变量的副本
         - 副本之间相互独立，这样每一个线程都可以随意修改自己的变量副本，而不会对其他线程产生影响
      6. Volatile与Synchronized
         - 对于volatile修饰的变量，当一条线程修改了这个变量的值，新值对于其他线程来说是可以立即得知的，volatile变量对所有线程是立即可见的，对volatile变量的所有写操作都能立刻反应到其他线程之中。
         - VM规范规定了任何一个线程修改了volatile变量的值都需要立即将新值更新到主内存中, 任何线程任何时候使用到volatile变量时都需要重新获取主内存的变量值
      7. 两者区别
         1. volatile本质是在告诉jvm当前变量在寄存器（工作内存）中的值是不确定的，需要从主存中读取；synchronized则是锁定当前变量，只有当前线程可以访问该变量，其他线程被阻塞住。
         2. volatile仅能使用在变量级别；synchronized则可以使用在变量、方法、和类级别的
         3. volatile仅能实现变量的修改可见性，不能保证原子性；而synchronized则可以保证变量的修改可见性和原子性
         4. volatile不会造成线程的阻塞；synchronized可能会造成线程的阻塞。
         5. volatile标记的变量不会被编译器优化（禁止指令重排序优化，即执行顺序与程序顺序一致）；synchronized标记的变量可以被编译器优化

4. 在理解默认线程池的前提下，自己实现线程池

#### 字符

1. String的不可变性
   - 不可变对象：基础类型对象之不能改变，引用类型对象的引用不能改变。
   - 节省内存空间
   - 多线程同步
   - hashcode唯一，效率高
2. StringBuilder和StringBuffer的区别
   - StringBuilder线程不安全
   - StringBuffer线程安全
3. 字符集的理解：Unicode、UTF-8、GB2312等 
4. 正则表达式相关问题

#### 注解    http://gusi123.cn/2018/02/24/JavaAnnotaion/

1. 注解的使用 
   - 编写文档
   - 代码分析
   - 编译检查
2. 注解的级别及意义
   -   ​
3. 如何自定义注解
   - 反射技术解析自定义注解


## 二、Android技术

#### Android基础

1. 四大组件的意义及使用，生命周期回调及意义

2. AsyncTask、Handler的使用

   > https://batuer.github.io/2018/03/23/AsyncTask/ 

3. Android系统层次框架结构

   > [https://batuer.github.io/2018/03/21/AnrdroidFrameWork/](http://gusi123.cn/batuer.github.io/2018/03/21/AnrdroidFrameWork/)

4. AsyncTask的实现方式

   > https://batuer.github.io/2018/03/23/AsyncTask/ 

   - 封装ThreadPoolExecutor和Handler执行线程任务并且完成结果回调。

5. AsyncTask使用的时候应该注意什么

   > https://batuer.github.io/2018/03/23/AsyncTask/ 

   - 版本不同任务执行方式不同，3.0以上默认串行。
   - 容易造成内存泄漏。
   - 只能执行一次任务。

6. Android常见的存储方式

   1. 内存
   2. 外部SD卡
   3. SharedPreferences
   4. Sqlite

7. Looper、Handler和MessageQueue的关系  

   - Handler封装消息的发送、接收，内部和Looper关联。
   - Looper循环从MessageQueue取出消息交给Handler处理。
   - MessageQueue消息队列，供Looper取。

8. Activity的启动流程（考察对Framwork的熟悉程度）

   > http://gusi123.cn/2018/03/27/Activity启动流程/

9. 多进程开发的注意事项(Application类区分进程，进程间内存不可见、进程间通讯方式)

   > http://gusi123.cn/2018/03/26/MultiProcess/

#### Resource相关

1. .9图片的意义

2. style和theme的作用及用法

3. dpi、sp、px的区别以及转换关系

   - px是像素，屏幕上实际的像素点单位。
   - dip/dp设备独立像素，布局常使用，与屏幕有关，在不同**像素密度**的设备上会自动适配。
   - sp放大像素，处理字体大小。
   - dpi 像素密度，每平方英寸中的像素数。
   - px和dp转换：px=1dp * 像素密度(dpi) / 160 =dp * density

4. raw和assets文件夹的作用，二者有何区别

   - 两者目录下的文件在打包后会原封不动的保存在apk包中,不会被编译成二进制。
   - res/raw中的文件会被映射到R.java文件中,访问的时候直接使用资源ID即R.id.filename; 而assets文件夹下的文件不会被映射到R.java中,访问的时候需要AssetManager类。
   - res/raw不可以有目录结构,而assets则可以有目录结构,也就是assets目录下可以再建立文件夹。
   - 读取res/raw下的文件资源,通过以下方式获取输入流来进行写操作InputStreamis=getResources().openRawResource(R.id.filename); 
     //通过 资源 id 直接打开 raw 下的 流文件
   - 读取assets下的文件资源,通过以下方式获取输入流来进行写操作，InputStream is = getAssets().open("filename"); 

5. Android系统如何在多个资源文件夹下查找匹配最合适的资源

   > https://www.jianshu.com/p/fd07300b031a

   ![Android资源匹配顺序](https://upload-images.jianshu.io/upload_images/2088926-c222faae63ebcb0c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

   对于资源文件夹的命名必须按照上表中的顺序依次配置，切不可倒置。

#### 虚拟机

1. Java内存模型
2. Android虚拟机的特点
3. Dalvik和Art的区别
4. 熟悉垃圾回收的实现机制，辣椒虚拟机的GC类型

#### View相关

1. 常用组件的使用：ListView、RecyclerView及Adapter的使用
2. View之间的继承关系
3. invalidate和postInvalidate的区别
4. 自定义View
5. onMeasure、onLayout、onDraw的作用
6. Paint、Matrix、Shader等回执相关类的方法作用
7. 事件分发机制

#### 动画

1. Android有哪些动画实现方式
2. Interpolator类的意义和常用的Interpolator
3. ViewAnimation与属性动画有什么区别
4. 如何自定义ViewAnimation
5. 属性动画的实现原理

#### 图片处理

1. 一般项目中如何加载大图
2. 图片压缩方式
3. 如何不压缩图片加载高清图
4. 图片加载过程中，一般会使用缓存，这个缓存的主要作用是什么
5. 图片加载框架对比