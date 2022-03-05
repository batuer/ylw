title: ActivityLaunch
date: 2019年05月12日08:32:09
categories: 未标记
tags: 
     - 未标记
cover_picture: /images/ActivityLaunch.jpeg
---
    
> https://www.jianshu.com/p/9ecea420eb52

![Activity启动流程](https://upload-images.jianshu.io/upload_images/1869462-882b8e0470adf85a.jpg)

### ActivityThread

![](https://upload-images.jianshu.io/upload_images/2088926-2f7a42daaf8f9b1f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

1. main()：ActivityThread是一个应用的主线程，入口方法是main()。
   1. 应用进程绑定：main()方法通过thread.attach(false)绑定应用进程。
   2. 主线程消息处理。
2. 内部类ApplicationThread： ApplicationThread不是一个Thread而是一个Binder,主要用于应用进程和ActivityManagerService进程间通信的。  
3. 内部类H：继承自Handler的,它是个私有的内部类,其实就是主线程的Handler,通过这个Handler就可以往主线程的消息队列发消息,如:启动Activity、service,接收广播等。 
4. 内部类ActivityClientRecord：一个进程对应一个ActivityThread,成员变量mActivities包含了当前进程的所有的activity。activity封装成ActivityClientRecord。 
5. 总结
   1. ActivityThread#main
   2. ActivityThread#attach
   3. ActivityManagerProxy#attachApplication 
   4. ActivityManagerService#attachApplication 
   5. ActivityManagerService#attachApplicationLocked 
   6. ActivityStack#realStartActivityLocked 
   7. ApplicationThreadProxy#scheduleLaunchActivity 
   8. ApplicationThread#scheduleLaunchActivity 
   9. ActivityThread#queueOrSendMessage 
   10. H#handleMessage 
   11. ActivityThread#handleCreateService 

### 一切从main()开始

Android中，一个应用程序的开始从ActivityThread.java中的main()开始。

1. 配置程序运行环境UserEnvironment,日志等。
2. 准备当前线程的Looper为程序的MainLooper。
3. 初始化ActivityThread实例
4. ActivityThread实例调用attach(false)，创建Application
5. 获取MainThreadHandler。
6. MainLooper开始loop(),接收发送消息。程序开始运行。

### 创建Application的消息

ActivityThread实例调用attach(false)，创建Application

1. 判断是否系统程序，不同的初始化流程(分析非系统)

2. 获得ActivityManager实例——ActivityManagerService，ActivityManagerNative.getDefault()获得代理类**ActivityManagerProxy**，通过ServiceManager获得IBinder实例。获取IBInder目的既是为了通过这个IBinder和ActivityManager进行通讯。

   ```java
   IBinder b = ServiceManager.getService("activity");
   if (false) {
       Log.v("ActivityManager", "default service binder = " + b);
   }
   IActivityManager am = asInterface(b);
   ```

   ```java
   static public IActivityManager asInterface(IBinder obj) {
           if (obj == null) {
               return null;
           }
           IActivityManager in =
               (IActivityManager)obj.queryLocalInterface(descriptor);
           if (in != null) {
               return in;
           }

           return new ActivityManagerProxy(obj);
       }
   ```

3. ActivityManagerProxy.attachApplication(mAppThread)

   ```java
    		Parcel data = Parcel.obtain();
           Parcel reply = Parcel.obtain();
           data.writeInterfaceToken(IActivityManager.descriptor);
           data.writeStrongBinder(app.asBinder());
           mRemote.transact(ATTACH_APPLICATION_TRANSACTION, data,reply,0);
           reply.readException();
           data.recycle();
           reply.recycle();
   ```

   - 调用IBInder实例的tansact()方法，把参数app放到data中，最终传递给ActivityManager。
   - IActvitymanager的实现类ActivityManagerProxy。

4. ApplicationThread  mAppThread ？

   ```java
   private class ApplicationThread extends ApplicationThreadNative {
   }
   ```

   ```java
   public abstract class ApplicationThreadNative extends Binder
           implements IApplicationThread {
           }
   ```

   ```java
   public interface IApplicationThread extends IInterface {
       String descriptor = "android.app.IApplicationThread";
   }
   ```

   ​

   - ActivityThread 中的常量，不希望中途被修改。

   - ApplicationThread是ActivityThread内部类。

   - ApplicationThreadNative继承Binder实现IApplicationThread。

   - ApplicationThread作为IApplicationThread实例承担了最后发送Activity生命周期、及其它一些任务。ApplicationThread传到ActivityManager中为了让系统根据情况控制。

     ​

   ### ActivityManagerService调度发送初始化消息

   ```java
   public abstract class ActivityManagerNative extends Binder implements IActivityManager{
   }
   ```

   ```java
   public final class ActivityManagerService extends ActivityManagerNative
           implements Watchdog.Monitor, BatteryStatsImpl.BatteryCallback {
   }
   ```

   - 获得ActivityManager实例——ActivityManagerService

     ```java
     final IActivityManager mgr = ActivityManagerNative.getDefault();
                 try {
                     mgr.attachApplication(mAppThread);
                 } catch (RemoteException ex) {
                     throw ex.rethrowFromSystemServer();
                 }
     ```

     实现类ActivityManagerService

     ```java
     @Override
      public final void attachApplication(IApplicationThread thread) {
            synchronized (this) {
                 int callingPid = Binder.getCallingPid();
                 final long origId = Binder.clearCallingIdentity();
                 attachApplicationLocked(thread, callingPid);
                 Binder.restoreCallingIdentity(origId);
             }
         }
     ```

     attachApplicationLocked()

     ```java
     private final boolean attachApplicationLocked(IApplicationThread   		thread,int pid) {
         // 以前存在 pid
         // If the app is being launched for restore or full backup, set it up specially
         ...
          //实现类ApplicationThread 执行bindApplication初始化Application
          thread.bindApplication(...);
       	...
           return true;
        }
     ```

     ```java
      public final void bindApplication(...) {
                 if (services != null) {
                     // Setup the service cache in the ServiceManager
                     ServiceManager.initServiceCache(services);
                 }
                 setCoreSettings(coreSettings);
                 AppBindData data = new AppBindData();
                 ...
                 sendMessage(H.BIND_APPLICATION, data);
             }
     ```

     ```java
     case BIND_APPLICATION:
          AppBindData data = (AppBindData)msg.obj;
     	//重要
          handleBindApplication(data);
          Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);
     break;
     ```

     ```java
     private void handleBindApplication(AppBindData data) {
         ...
        //通过反射初始化一个Instrumentation仪表。
         mInstrumentation = (Instrumentation)
             cl.loadClass(data.instrumentationName.getClassName())
             .newInstance();
         ...
         //通过LoadedApp命令创建Application实例
         Application app = data.info.makeApplication(data.restrictedBackupMode, null);
         mInitialApplication = app;
         ...
         mInstrumentation.callApplicationOnCreate(app);
         //让仪器调用Application的onCreate()方法
         ...
     }
     ```


### Instrumentation ?

- Instrumentation会在应用程序的任何代码运行之前被实例化，它能够允许你监视应用程序和系统的所有交互。

- 收集AndroidManifest.xml标签信息

- Apllication的创建，Activity的创建，以及生命周期都会经过这个对象去执行。简单点说，就是把这些操作包装了一层。通过操作Instrumentation进而实现上述的功能。

- ```java
  public void callApplicationOnCreate(Application app) {
          app.onCreate();
      }
  ```

  ### LoadedApk就是data.info

  ```java
  public Application makeApplication(boolean forceDefaultAppClass,
      Instrumentation instrumentation) {
      ...
      String appClass = mApplicationInfo.className;
      //Application的类名。明显是要用反射了。
      ...
      ContextImpl appContext = ContextImpl.createAppContext(mActivityThread
          , this);
      //留意下Context
      app = mActivityThread.mInstrumentation
          .newApplication( cl, appClass, appContext);
      //通过仪表创建Application
      ...
  }
  ```

  - 在取得Application的实际类名之后，最终的创建工作还是交由Instrumentation去完成，就像前面所说的一样。

    #### 回Instrumentation

    ```java
    static public Application newApplication(Class<?> clazz, Context context)
                throws InstantiationException, IllegalAccessException, 
                ClassNotFoundException {
            Application app = (Application)clazz.newInstance();
            app.attach(context);
            return app;
        }
    ```

    ### LaunchActivity

    当Application初始化完成后，系统会根据Manifests中的配置启动Activity发送一个Intent去启动相对应的Activity。

    ```java
     // we use token to identify this activity without having to send the
    // activity itself back to the activity manager. (matters more with ipc)
    @Override
    public final void scheduleLaunchActivity(Intent intent, IBinder token, int ident,
                    ActivityInfo info, Configuration curConfig, Configuration overrideConfig,
                    CompatibilityInfo compatInfo, String referrer, IVoiceInteractor voiceInteractor,
                    int procState, Bundle state, PersistableBundle persistentState,
                    List<ResultInfo> pendingResults, List<ReferrerIntent> pendingNewIntents,
                    boolean notResumed, boolean isForward, ProfilerInfo profilerInfo) {

                updateProcessState(procState, false);

                ActivityClientRecord r = new ActivityClientRecord();

                r.token = token;
                r.ident = ident;
                r.intent = intent;
                r.referrer = referrer;
                r.voiceInteractor = voiceInteractor;
                r.activityInfo = info;
                r.compatInfo = compatInfo;
                r.state = state;
                r.persistentState = persistentState;

                r.pendingResults = pendingResults;
                r.pendingIntents = pendingNewIntents;

                r.startsNotResumed = notResumed;
                r.isForward = isForward;

                r.profilerInfo = profilerInfo;

                r.overrideConfig = overrideConfig;
                updatePendingConfiguration(curConfig);
    			//启动Activity
                sendMessage(H.LAUNCH_ACTIVITY, r);
            }
    ```

    - H 接收到LAUNCH_ACTIVITY的消息，开始初始化Activity，ActivityThread.handleLaunchActivity()

      ```java
      private void handleLaunchActivity(ActivityClientRecord r, Intent customIntent, String reason) {
        // gc、Profiler、Config、WindowManagerGlobal
        //...
        Activity a = performLaunchActivity(r,customIntent);
          if (a != null) {
          //Config...
          //onResume
          handleResumeActivity(r.token, false, r.isForward,
                          !r.activity.mFinished &&       		  !r.startsNotResumed, r.lastProcessedSeq, reason);
          }
      ```

    - performLaunchActivity()

      ```java
      private Activity performLaunchActivity(ActivityClientRecord r, Intent customIntent) {
        //Instrumentation 创建Activity
         Activity activity = null;
         try {
             java.lang.ClassLoader cl = 		r.packageInfo.getClassLoader();
            //反射创建Activity实例
           	activity = mInstrumentation.newActivity(
              cl, component.getClassName(), r.intent);
              } catch (Exception e) {
              }
        		//获取Application，r.packageInfo就是LoadApk
              try {
                  Application app = r.packageInfo.makeApplication(false, mInstrumentation);
         if (activity != null) {
          //...           
         activity.attach( appContext, this,               			getInstrumentation(), r.token,
            	r.ident, app, r.intent, r.activityInfo, title,      	 r.parent,r.embeddedID, 			  			    		r.lastNonConfigurationInstances, config,
              r.referrer, r.voiceInteractor,window);
      		//持久化 Instrumentation执行Activity的onCreate()
             //Mainfiset下Activity标签
             // ersistableMode == persistAcrossReboots
         		if (r.isPersistable()) {                 				  mInstrumentation.callActivityOnCreate(
                  activity,r.state, r.persistentState);
              } else {                 			    		 			mInstrumentation.callActivityOnCreate(
                  activity, r.state);
               }
               //...
              return activity;
          }
      ```


#### Application 创建完成，第一个Activity创建完成。  
