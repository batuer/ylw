title:  Android广播
date: 2018年9月11日00:17:16
categories: Android
tags: 

	 - Android
	 - Broadcast
cover_picture: /images/common.png
---

##### 概述

- 四大组件之一。
- 基于消息的发布/订阅模式（高内聚低耦合）。
- 订阅者在AMS中注册感兴趣的广播。
- 发布者发送广播到AMS中查找注册者。
- 异步处理。

##### 注册过程

- 分为动态注册和静态注册（常驻型）。
- ContextImpl通过Binder机制向AMS完成广播注册。
- 注册过程的核心就是将广播接收者和IntentFilter保存在AMS中。

##### 发送过程

- 发送者调用sendBroadcast()发送广播，通过Binder机制向AMS发送广播，在AMS中查找注册关系表里查找感兴趣的接收者。
- 发送过程是异步的。

##### 使用场景

- 同一App内部不同组件之间的消息通信（多线程）。
- 同一App内部不同组件之间的消息通信（单进程）。
- 同一App内不同进程间的组件消息通信（多进程）。
- 不同App之间组件消息通信。
- Android系统在特定情况下与App间的消息通信（系统广播）。
- 广播接收器回调在UI线程，不执行耗时操作。

##### 注册方式

1. 动态注册
   - Context调用registerReceiver()注册，退出时及时反注册。
2. 静态注册
   - android:exported ：BroadcastReceiver能否接收其他App的发出的广播，这个属性默认值是由receiver中有无intent-filter决定的，如果有intent-filter，默认值为true，否则为false。（同样的，activity/service中的此属性默认值一样遵循此规则）同时，需要注意的是，这个值的设定**是以application或者application user id为界**的，而非进程为界（一个应用中可能含有多个进程）。
   - android:name ：BroadcastReceiver类名 。
   - android:permission ：具有相应权限的广播发送方发送的广播才能被此BroadcastReceiver所接收。
   - android:process ：broadcastReceiver运行所处的进程。默认为app的进程。可以指定独立的进程（Android四大基本组件都可以通过此属性指定自己的独立进程）。

##### 广播类型

###### Normal Broadcast

- 开发者自己定义的Intent。
- 无序。
- 权限对应。

###### System Broadcast

- 系统发送的广播（开机启动、网络状态、蓝牙等等）。

###### Ordered Broadcast

- 针对接收者的顺序。
- 动态广播优于静态广播。
- 优先接收者可对广播拦截或修改。

###### Sticky Broadcast

- API 21以后不再推荐使用。
- @Deprecated。
- Sticky Order Broadcast 也同样@Deprecated。

###### Local Broadcast

- App应用内广播（Application或Application User id为界）。
- 不接收其它应用相同IntentFilter的广播。
- 不让其它应用接收相同IntentFilter的广播。

##### 安全方案

- android:exported为false时，不接收其它应用的广播干扰。
- android:permission：发送和接收都添加权限验证。
- 发送广播时指定接收者的包名。
- 应用内广播（LocalBroadcastManager）。
  - 安全性高、更高效。
  - LocalBroadcastManager发送的应用内广播，只能是LocalBroadcastManager动态注册的广播才能接收到。

##### 广播接收器回调onReceiver(context,intent)中context的具体类型

- 对于静态注册的ContextReceiver，回调onReceive(context, intent)中的context具体指的是ReceiverRestrictedContext。
- 对于全局广播的动态注册的ContextReceiver，回调onReceive(context, intent)中的context具体指的是Activity Context。
- 对于通过LocalBroadcastManager动态注册的ContextReceiver，回调onReceive(context, intent)中的context具体指的是Application Context。

##### 不同API版本的广播机制重要变迁

- API level 21开始粘滞广播和有序粘滞广播过期，以后不再建议使用。
- 静态注册的广播接收器即使app已经退出，只要有相应的广播发出，依然可以接收到，但此种描述自Android 3.1开始有可能不再成立。
  - Android 3.1开始系统在Intent与广播相关的flag增加了参数，分别是FLAG_INCLUDE_STOPPED_PACKAGES（即包所在的进程已经退出）和FLAG_EXCLUDE_STOPPED_PACKAGES（不包含已经停止的包）。
  - Android3.1开始，系统本身则增加了对所有app当前是否处于运行状态的跟踪。在发送广播时，不管是什么广播类型，系统默认直接增加了值为FLAG_EXCLUDE_STOPPED_PACKAGES的flag，导致即使是静态注册的广播接收器，对于其所在进程已经退出的app，同样无法接收到广播。由此，对于系统广播，由于是系统内部直接发出，无法更改此intent flag值，因此，3.1开始对于静态注册的接收系统广播的BroadcastReceiver，如果App进程已经退出，将不能接收到广播。
  - 对于自定义的广播可重写flag值，发送广播。