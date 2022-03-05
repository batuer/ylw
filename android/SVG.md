title: SVG
date: 2019年04月18日22:24:11
categories: 未标记
tags: 
     - 未标记
cover_picture: /images/SVG.jpeg
---
    
#### SVG

##### 简介

- svg**耗资源**：文件存储绘制图片的相关信息，在使用的时候再绘制，所以会消耗更多的时间和资源。
- svg**体积小**：文件体积远小于位图文件。
- svg**不失真**：矢量图，不存在失真问题，理论支持任何级别缩放。
- svg不支持硬件加速。

##### 文件

```xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
        android:width="8dp"
        android:height="8dp"
        android:viewportHeight="24.0"
        android:viewportWidth="24.0">
    <path
        android:fillType="evenOdd"
        android:fillAlpha="0.5"
        android:fillColor="#ffffff"
        android:pathData="M12,4l-1.41,1.41L16.17,11H4v2h12.17l-5.58,5.59L12,20l8,-8z"/>
</vector>
```

- `width`, `height`：图片的宽高。
- viewportHeight，viewportWidth：将height和width等分的分数（8dp的宽度分24份，8dp的高度份24份）。
- fillColor：填充颜色。
- fillAlpha：不透明度。
- fillType：填充原则。
- pathData：具体path描述。

##### Vector语法

###### Path支持的指令

- M = moveto(M X,Y) ：将画笔移动到指定的坐标位置
- L = lineto(L X,Y) ：画直线到指定的坐标位置
- H = horizontal lineto(H X)：画水平线到指定的X坐标位置
- V = vertical lineto(V Y)：画垂直线到指定的Y坐标位置
- C = curveto(C X1,Y1,X2,Y2,ENDX,ENDY)：三次贝赛曲线
- S = smooth curveto(S X2,Y2,ENDX,ENDY)
- Q = quadratic Belzier curve(Q X,Y,ENDX,ENDY)：二次贝赛曲线
- T = smooth quadratic Belzier curveto(T ENDX,ENDY)：映射
- A = elliptical Arc(A RX,RY,XROTATION,FLAG1,FLAG2,X,Y)：弧线
- Z = closepath()：关闭路径

###### 使用原则

- 坐标轴为以(0,0)为中心，X轴水平向右，Y轴水平向下
- 所有指令大小写均可。大写绝对定位，参照全局坐标系；小写相对定位，参照父容器坐标系
- 指令和数据间的空格可以省略
- 同一指令出现多次可以只用一个

**注意，'M'处理时，只是移动了画笔， 没有画任何东西。 它也可以在后面给出上同时绘制不连续线。**

#### 使用

##### 获取svg文件

[Iconfont](https://www.iconfont.cn/plus/home/index)

##### svg2Android

[Android SVG to VectorDrawable](http://inloop.github.io/svg2android/)

[svgtoandroid插件](https://github.com/misakuo/svgtoandroid)

##### png转svg

1. 获取png图片

2. vmde将图片转成svg格式

   [vmde](https://pan.baidu.com/s/1jFJQIa3jU3mRS_p_RWA4ZQ?jqmz)

3. svg2Android

4. xml中使用

##### 开源库

[PathAnimView](https://github.com/mcxtzhang/PathAnimView)

##### 兼容性

- Android5.0引入，支持api21及以上。

- 通过support-library支持到api16及以上

  ```groovy
  defaultConfig { 
        vectorDrawables.generatedDensities = ['hdpi','xxhdpi']
  }
  //缺点打包了位图资源apk包变大，生成不同分辨率的位图资源可通过gradle配置。
  ```

  

- 兼容性Support Library 23.2+不会自动生成位图，build.gradle配置

   

  ```groovy
  defaultConfig { 
             vectorDrawables.useSupportLibrary = true  
   }
  ```

- vector兼容使用

  ```xml
    <ImageView
              android:layout_width="wrap_content"
              android:layout_height="wrap_content"
              android:layout_marginTop="10dp"
              android:background="#66000000"
              app:srcCompat="@drawable/vector" />
  ```

- animated-vector兼容使用代码适配。

- api16以下或用图片代替。