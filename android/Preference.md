title: Preference
date: 2019年07月03日23:37:57
categories: 未标记
tags: 
     - 未标记
cover_picture: /images/Preference.jpeg
---
    
##### 简介

- 常用于Settings模块。
- 默认数据保存在SharePreference中。

##### 使用

- 创建xml。
- PreferenceScreen容器，可包含多个Preference控件。

###### xml定义preference

1. xml文件保存res/xml中
2. 继承PreferenceActivity在oncreate方法中直接调用addPreferencesFromResource()
3. 点击事件setOnPreferenceClickListener。
4. 内容变化事件setOnPreferenceChangeListener。

###### Fragment定义preference

1. 自定义fragment
2. Activiyt中调用Fragment，填充布局