title: Android.mk
date: 2019年03月17日23:32:43
categories: 未标记
tags: 
     - 未标记
cover_picture: /images/Android.mk.jpeg
---
    
##### Android.mk简介

- 允许将Source打包成一个"modules"
- 编译生成so库名
- 引用的头文件目录
- 需要编译的.c/.cpp文件.a静态库文件

##### 语法

```makefile
LOCAL_PATH := $(call my-dir)  
include $(CLEAR_VARS)  
................  
LOCAL_xxx       := xxx  
LOCAL_MODULE    := hello-jni  
LOCAL_SRC_FILES := hello-jni.c 
LOCAL_MODULE_PATH :=$(TARGET_ROOT_OUT) #指定最后生成的模块的目标地址
LOCAL_xxx       := xxx  
................  
include $(BUILD_SHARED_LIBRARY)
```

- LOCAL_PATH：必须定义为开始，开发中查找源文件，宏**my-dir**由Build System提供，返回包含Android.mk的目录路径。
- CLEAR_VARS：变量由Build System提供。并指向一个指定的GNU Makefile
- ，由它负责清理很多LOCAL_xxx（LOCAL_MODULE、LOCAL_SRC_FILES。。。），但不清理LOCAL_PATH。这个清理动作是必须的。
- LOCAL_MODULE：必须定义，定义Modules名。表示Android.mk中的每一个模块。名字必须唯一且不包含空格。Build System会自动添加适当的前缀和后缀。
- LOCAL_MODULE_FILENAME：允许用户重新定义最终生成的目标文件名。
- LOCAL_CPP_EXTENSION：指定c++扩展名
- LOCAL_MODULE_PATH：指定最后生成的模块的目标地址。（默认是TARGE_OUT）
  - TARGET_ROOT_OUT:根文件系统，路径为out/target/product/generic/root
  - TARGET_OUT:system文件系统，路径为out/target/product/generic/system
  - TARGET_OUT_DATA:data文件系统，路径为out/target/product/generic/data
- LOCAL_SRC_FILES：必须包含将要打包模块的c/c++源码。不必列出头文件，Build System会自动帮我们找出依赖文件。缺省的c++的源码扩展名为.cpp，也可以修改。通过LOCAL_CPP_EXXTENSION
- include $(BUILD_SHARED_LIBRARY)：BUILD_SHARED_LIBRARY是Build System提供的一个变量，指向GNU Makefile Script。负责收集自从上次调用include (CLEAR_VARS)后的所有LOCAL_xxx信息。并决定编译成什么。
  - BUILD_STATIC_LIBRARY    ：编译为静态库。 
  - BUILD_SHARED_LIBRARY ：编译为动态库 
  - BUILD_EXECUTABLE           ：编译为Native C可执行程序  
  - BUILD_PREBUILT                 ：该模块已经预先编译 

##### NDK Build System变量

###### 保留的变量名

- 以LOCAL_、PRIVATE_、NDK_、APP_开头的名字
- 小写字幕的名字，如：my-dir
- 建议想要定义自己在Android.mk中使用的变量名，建议添加MY_前缀。

###### NDK提供的变量

- CLEAR_VARS：编译脚本
- BUILD_SHARED_LIBRARY：编译脚本（动态库）
- BUILD_STATIC_LIBRARY：编译脚本（静态库）
- BUILD_EXECUTABLE ：编译脚本（Native程序）
- PREBUILT_SHARED_LIBRARY：指定预先编译好的动态库
- PREBUILT_STATIC_LIBRARY：指定预先编译好的静态库
- TARGET_ARCH：目标CPU架构名，与CPU架构版本无关
- TARGET_PLATFORM：目标平台的名字，对应Android版本号
- TARGET_ARCH_ABI：cpu/api的类型，取值包括：
  - 32位：armeabi、armeabi-v7a、x86、mips
  - 64位：arm64-v8a、x86_64、mips64

###### NDK提供的功能宏

- my-dir：最近一次include的Makefile的路径，通常返回Android.mk所在的路径 
- all-subdir-makefiles：返回一个列表，包含 “my-dir” 中所有子目录中的Android.mk 
- this-makefile：当前Makefile的路径
- parent-makefile：返回include tree中父Makefile路径，也就是include当前Makefile的Makefile路径 
- import-module：允许寻找并import其它Modules到本Android.mk中来。 它会从**NDK_MODULE_PATH**寻找指定的模块名 

##### 示例

```makefile
#编译静态库    
LOCAL_PATH := $(call my-dir)    
include $(CLEAR_VARS)    
LOCAL_MODULE = libhellos    
LOCAL_CFLAGS = $(L_CFLAGS)    
LOCAL_SRC_FILES = hellos.c    
LOCAL_C_INCLUDES = $(INCLUDES)    
LOCAL_SHARED_LIBRARIES := libcutils    
LOCAL_COPY_HEADERS_TO := libhellos    
LOCAL_COPY_HEADERS := hellos.h    
include $(BUILD_STATIC_LIBRARY)    
    
#编译动态库    
LOCAL_PATH := $(call my-dir)    
include $(CLEAR_VARS)    
LOCAL_MODULE = libhellod    
LOCAL_CFLAGS = $(L_CFLAGS)    
LOCAL_SRC_FILES = hellod.c    
LOCAL_C_INCLUDES = $(INCLUDES)    
LOCAL_SHARED_LIBRARIES := libcutils    
LOCAL_COPY_HEADERS_TO := libhellod    
LOCAL_COPY_HEADERS := hellod.h    
include $(BUILD_SHARED_LIBRARY)    
    
#使用静态库    
LOCAL_PATH := $(call my-dir)    
include $(CLEAR_VARS)    
LOCAL_MODULE := hellos    
LOCAL_STATIC_LIBRARIES := libhellos    
LOCAL_SHARED_LIBRARIES :=    
LOCAL_LDLIBS += -ldl    
LOCAL_CFLAGS := $(L_CFLAGS)    
LOCAL_SRC_FILES := mains.c    
LOCAL_C_INCLUDES := $(INCLUDES)    
include $(BUILD_EXECUTABLE)    
    
#使用动态库    
LOCAL_PATH := $(call my-dir)    
include $(CLEAR_VARS)    
LOCAL_MODULE := hellod    
LOCAL_MODULE_TAGS := debug    
LOCAL_SHARED_LIBRARIES := libc libcutils libhellod    
LOCAL_LDLIBS += -ldl    
LOCAL_CFLAGS := $(L_CFLAGS)    
LOCAL_SRC_FILES := maind.c    
LOCAL_C_INCLUDES := $(INCLUDES)    
include $(BUILD_EXECUTABLE)    
  
  
#拷贝文件到指定目录  
LOCAL_PATH := $(call my-dir)  
include $(CLEAR_VARS)  
LOCAL_MODULE := bt_vendor.conf  
LOCAL_MODULE_CLASS := ETC  
LOCAL_MODULE_PATH := $(TARGET_OUT)/etc/bluetooth  
LOCAL_MODULE_TAGS := eng  
LOCAL_SRC_FILES := $(LOCAL_MODULE)  
include $(BUILD_PREBUILT)  
  
  
#拷贝动态库到指定目录  
LOCAL_PATH := $(call my-dir)  
include $(CLEAR_VARS)  
#the data or lib you want to copy  
LOCAL_MODULE := libxxx.so  
LOCAL_MODULE_CLASS := SHARED_LIBRARIES  
LOCAL_MODULE_PATH := $(ANDROID_OUT_SHARED_LIBRARIES)  
LOCAL_SRC_FILES := lib/$(LOCAL_MODULE )  
OVERRIDE_BUILD_MODULE_PATH := $(TARGET_OUT_INTERMEDIATE_LIBRARIES)  
include $(BUILD_PREBUILT)  
```

