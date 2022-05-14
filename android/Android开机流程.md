## Android开机流程

#### 启动电源及系统启动

设备上电，引导芯片代码从ROM开始执行，加载BootLoader到RAM执行

#### BootLoader

拉起系统OS运行

#### Kernel

内核启动，设置缓存、被保护存储器、加载驱动、计划列表。内核完成系统设置，在系统文件中找init.rc文件，启动init进程。

#### init

初始化和启动init.rc属性服务，并且启动Zygote和ServiceManager进程

#### Zygote

创建虚拟机并注册JNI方法，创建服务端Socket（用于AMS创建进程fork），启动SystemServer进程。

#### SystemServer

启动Binder线程池和SystemServiceManager，并且启动AMS、PMS、WMS等系统服务。

#### Launcher

桌面应用显示，启动完成。

![Android启动流程](https://upload-images.jianshu.io/upload_images/2088926-26aaa0be71533a5c.png)

![Android启动流程](https://upload-images.jianshu.io/upload_images/2088926-3d981b715f121499.png)



