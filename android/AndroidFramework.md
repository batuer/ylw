title:  Android层次
date: 2018年8月8日22:33:33
categories: Android
tags: 

	 - Android
cover_picture: /images/common.png
---

### Linux内核层

- Android系统是基于Linux2.6内核的，这一层为Android设备的各种硬件提供了底层的驱动，如显示驱动、音频驱动、照相机驱动、蓝牙驱动、Wi-Fi驱动、电源管理、Binder驱动等。 

### 系统库层

包含Android Libraries 和Android Runtime

#### Android Libraries

c/c++库为Android系统提供了主要的特性支持。如Sqlite库提供了数据库的支持，OpenGl|ES库提供 了3D绘图的支持，WebKit提供了浏览器内核的支持。 

#### Android Runtime

包括Core和Android虚拟机。Core提供Java语言编程的功能，允许开发者使用java语言编写Android应用。另外Android运行时库还包含了Dalvik虚拟机，它使得每一个Android应用都能运行在独立的进程当中，并且拥有一个自己的Dalvik虚拟机实例。 Android4.4以前Android虚拟机Dalvik，4.4后提供ART虚拟机。

### 框架层

编写Google核心应用时所应用的API框架层，开发人员也可以使用开发自己的程序。简化结构设计，但必须总受框架的开发原则。

- ContentProviders：程序之间可以共享数据。
- Resource Manager：提供费代码资源的访问，包括字符串、图形、布局文件等。
- Notification Manager：状态栏中自定义通知消息。
- Activity Manager：管理应用程序的生命周期管理，提供导航退回功能。
- Window Manager：管理所有的窗口程序。
- Package Manager：Android内的程序管理器。
- 在Android SDK中内置一些对象，重要的有Activity、Intent、Service、ContentProviders。

### 应用层

系统应用和第三方应用。用Java、Kotlin或其它语言编写的运行在虚拟机上的程序。eg：Google原生的短信、浏览器或自己开发的程序。