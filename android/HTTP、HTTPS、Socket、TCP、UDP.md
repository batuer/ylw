title:  HTTP、HTTPS、SOCKET、TCP、UDP
date: 2018年9月16日00:37:37
categories: 网络
tags: 
	 - Http
	 - Socket
cover_picture: /images/网络传输层.png
---

![](https://upload-images.jianshu.io/upload_images/2088926-9234c2666a6a38af.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### HTTP(Hypertext Transfer  Protocol)

###### 特点

- 基于TCP/IP通信协议传递数据。
- 简单快速：协议简单，短链接发送请求接收数据。
- 灵活：传输任意类型数据对象，由Content-Type标记数据类型。
- 短链接：
  - HTTP1.0：一次TCP链接，处理完本次请求后，自动释放链接。
  - HTTP1.1：一次TCP链接处理多个请求，且多个请求可重叠进行，自动释放链接，减少TCP三次握手开销。
- 无状态协议：对于事物处理没有记忆能力。
- 只能客户端主动请求，服务器不能主动发送。

######组成

- 请求行：用来说明请求类型，要访问的资源以及使用的HTTP版本。
- 请求头：紧接着请求行之后的部分，用来说明服务器要使用的附近信息。
- 空行：请求后面的空行是**必须的**。
- 请求体：请求数据，任意数据，可为空。

###### 状态码

- 1xx（指示消息）：请求已接收，继续处理。
- 2xx（成功）：请求已成功接收。
- 3xx（重定向）：要完成请求必须更进一步的操作。
- 4xx（客户端错误）：请求有语法错误或请求无法实现。
  - 400（Bad Request）：服务器无法理解的请求。
  - 401（Unauthorized）：未经授权。
  - 403（Forbidden）：服务器接收到请求，拒绝提供服务。
  - 404（Not Found）：请求资源不存在，错误的URL。
- 5xx（服务端错误）：服务器未能实现客户端的请求。
  - 500（Internal Server Error）：服务器发生不可知的错误。
  - 503（Server Unavailable）：服务器不能处理请求。

[更多状态码](http://www.runoob.com/http/http-status-codes.html)

###### 工作原理

![Http请求流程](https://upload-images.jianshu.io/upload_images/2088926-4bd1e598b150b219.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

1. 用域名访问服务器，先向DNS服务器请求解析IP地址。
2. 用IP地址和端口和服务器建立TCP连接。
3. 向服务器发送Http请求。
4. 服务器响应请求。
5. 释放TCP连接。
   - 若connection模式为close，则服务器主动关别TCP连接，客户端被动关闭连接，释放TCP连接。
   - 若connection模式为keepalive，则连接会继续保持一段时间，在该时间段内可以继续接收请求。

###### GET和POST区别

- 请求数据
  - GET请求的数据附加在URL之后，有长度限制（限制和浏览器有关）。
  - POST请求的数据在请求体里。
- 提交数据安全性
  - POST在请求体里安全高于GET在URL里。

##### HTTPS（Hypertext Transfer Protocol over Secure Socket Layer）

###### 特点

- 安全版HTTP，即H赛用安全套接字层（SSL/TLS）进行信息交互。

###### 工作原理

![Https使用流程](https://upload-images.jianshu.io/upload_images/2088926-391d8f3c29e19102.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 准备流程，从CA证书机构，获取数字证书

   1. 服务器生成一对公私钥S.pub、S.pri，私钥服务器保留（用于解密和签名），将公钥S.pub，身份信息，传给CA机构。
   2. CA机构也有公私钥C.pub、C.pri，由S.pub、身份信息、CA签名生成数字证书（签名使用C.prt）。
   3. 将数字证书颁发给服务器。
   4. 客户端（如浏览器）会内置一份CA根证书（包含C.pub），用于对数字证书验证。

- 使用流程

   1. 客户端发起请求（TCP三次握手），建立TCP连接。
   2. 客户端将支持的算法列表和产生密钥的随机数发送给服务器。
   3. 服务器返回支持的算法和CA证书。
   4. 验证证书，生成对称密钥。
   5. 通过对称密钥进行HTTP通信。

   ###### 优缺点

   - 优点
     1. 确保数据发送到正确的客户端和服务器。
     2. 防止数据在传输过程中不被窃取、改变，确保数据的完整性。
   - 缺点
     1. 加载时间延长、影响缓存、增加数据开销和功耗。
     2. 无法避免服务器收到攻击。
     3. CA根证书并不安全。
     4. 服务器CA证书需要购买。
     5. 证书绑定固定IP。
     6. 服务器端资源占用较多。

   ##### TCP

   - 面向连接。传输数据建立在可靠的连接上。
   - 传输可靠，保证数据正确性和数据有序性。
   - 速度慢，建立连接需要开销较多（时间、系统资源）。
   - 适用于传输大量数据（流模式）。
   - 建立连接三次握手。
   - 释放连接四次挥手。

   

   ![TCP三次握手](https://upload-images.jianshu.io/upload_images/2088926-01798594d6a21259.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

   ​			

   ![TCP四次挥手](https://upload-images.jianshu.io/upload_images/2088926-12678e1437d7acf2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

   

   

   ##### UDP

   - 面向非连接，传输不需要建立连接。
   - 传输不可靠，不保证传输的完整性和有序性。
   - 传输少量数据（数据包模式）。
   - 速度快。

   ##### SOCKET

   ###### 概念

   - 操作系统对于传输层（TCP/UDP）抽象的接口。
   - 通信的基石，是支持TCP/IP协议网络通信的基本操作单元。
   - 包含通信必须的物种必须信息：
     1. 连接使用的协议。
     2. 本地主机的IP。
     3. 本地进程的协议端口。
     4. 远地主机的IP。
  5. 远地进程的协议端口。
   
###### 建立连接
   
   - 至少需要一对套接字，运行与客户端的ClientSocket和运行与服务端的ServerSocket。
   - 连接步骤
     1. 服务器监听。
     2. 客户端请求。
  3. 连接确认。
   
###### SOCKET、TCP/IP、HTTP
   
   - 建立Socket连接时，可指定使用的传输层协议（TCP或UDP）。
   - TCP/IP是传输层协议，解决数据如何在网络中传输。
- HTTP层是应用层协议，解决如何包装数据。
   
**WebSocket**
   
- 协议层
   - 全双工通信
   - 基于TCP
   - HTTP的url使用"http//"或"https//"开头，Websocket的url使用'ws//'开头。
   - 请求头数据小。
   
   **Socket.io**
   
   - 封装Websocket。
   - 实时、双向、基于事件的通讯机制。
   
   **Netty**
   
   - 并发高
     1. NIO（Nonblocking I/O）![](https://upload-images.jianshu.io/upload_images/1089449-9eebe781fba495fd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/572/format/webp)
     2. BIO（Blocking I/O）![](https://upload-images.jianshu.io/upload_images/1089449-546a563c9822ce16.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/548/format/webp)
   - 传输快，零拷贝，不经Socket缓冲区。
   - 封装好
   
   
   
   