title:  Android进程保活Service常驻
date: 2018年6月26日22:09:09
categories: 进程、Service保活
tags: 

	 - Android
	 - 进程保活
	 - Service保活
cover_picture: /images/ProcessGrade.png
---

> https://mp.weixin.qq.com/s/OXiFQNTyCHpqSP6B9HOiHw
>

### 进程保活

##### 进程保活两个层面：

1. 提高进程优先级，降低被系统杀死概率。
2. 进程被杀死后，进行拉活。

##### 进程的优先级

1. 前台进程：前台进程不多，内存不足时系统才会清理。

   1. 正在可交互的Activity(onResume()和onStart()区别)。

   2. Service绑定到正在可交互的Activity。

   3. 前台Service

      ```java
      public final void startForeground(int id, Notification notification) {}
      
      public ComponentName startForegroundService(Intent service) {}
      ```

   4. 正执行生命周期的Service。

   5. 正执行生命周期的BroadcastReceiver。

2. 可见进程：可见不可交互的进程。

   1. Activity执行onStart()未执行onStop()。
   2. Service绑定到可见的Activity。

3. 服务进程：进程中有Service正在运行。

4. 后台进程：进程最后一个Activity执行onStop()。

5. 空进程：这种进程唯一目的用作缓存，缩短下次启动时间。

   ![](https://upload-images.jianshu.io/upload_images/2088926-53ec9a177a175316.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### 提升进程优先级

###### 利用Activity提升权限

1. 监控解锁屏事件，锁屏时启动1个像素的透明Activity，解锁时销毁。
2. 可以使进程变为**可见进程**。

##### 利用Notification提升权限

1. 普通服务进程升级为前台进程，会在通知栏有通知，用户可感知。
2. 通过实现一个内部 Service，在 LiveService 和其内部 Service 中同时发送具有相同 ID 的 Notification，然后将内部 Service 结束掉。随着内部 Service 的结束，Notification 将会消失，但系统优先级依然保持为2。 

##### 进程杀死后拉活

###### 利用系统广播

1. 注册静态广播监听系统广播事件。
2. 广播管理器会被系统软件或管理软件禁用进而无法接收到广播。
3. 系统广播事件不可控。

##### 利用第三方应用广播

1. 反编译监听第三方应用会发送的广播。
2. 存在第三方广播会升级修改，不能及时通知。

##### 利用系统Service机制拉活

1.  

   ```java
    @Override
           public int onStartCommand(Intent intent, int flags, int startId) {
               return Service.START_STICKY;
           }
   ```

2. Service 第一次被异常杀死后会在5秒内重启，第二次被杀死会在10秒内重启，第三次会在20秒内重启，一旦在短时间内 Service 被杀死达到5次，则系统不再拉起。 

3. 进程被取得 Root 权限的管理工具或系统工具通过 forestop 停止掉，无法重启。 

##### 利用Native进程拉活

1. 利用 Linux 中的 fork 机制创建 Native 进程，在 Native 进程中监控主进程的存活，当主进程挂掉后，在 Native 进程中立即对主进程进行拉活。 
2. ......

##### 利用JobScheduler机制拉活

1. Android5.0 以后系统对 Native 进程等加强了管理，Native 拉活方式失效。系统在 Android5.0 以上版本提供了 JobScheduler 接口，系统会定时调用该进程以使应用进行一些逻辑操作。 

##### 利用账号同步机制

1. Android 系统的账号同步机制会定期同步账号进行，该方案目的在于利用同步机制进行进程的拉活。 
2. 该方案适用于所有的 Android 版本，包括被 forestop 掉的进程也可以进行拉活。
3. 最新 Android 版本（Android N）中系统好像对账户同步这里做了变动，该方法不再有效。

##### 其它方案

1. 利用系统通知管理权限进行拉活 。
2. 利用辅助功能拉活，将应用加入厂商或管理软件白名单。 
3. 根据终端不同，在小米手机（包括 MIUI）接入小米推送、华为手机接入华为推送；其他手机可以考虑接入腾讯信鸽或极光推送与小米推送做 A/B Test。 

### Service常驻

1. JNI：5.0以前，Android系统本身不管理JNI层的，用Linux的Fork机制将App和进程分开。

2. JobService：可以在自动创建进程后台干任何事情，包括拉活activity、service或者执行任何的代码。但JobService并不意味着你不受任何限制，比如受到doze、monitor之类的管理。 

3. 前台服务。

4. Service 的 onstartCommand()。

   