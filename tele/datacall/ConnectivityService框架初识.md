# ConnectivityService框架初识

https://blog.csdn.net/sjz4860402/article/details/78532856

Android中提供的数据业务方式有几种：移动数据网络，WIFI，热点，网线等。这些数据业务本身可以独立使用，但是同一时刻，只能使用其中的一种数据业务方式。管理这些数据业务方式的使用由ConnectivityService，NetworkFactory，NetworkAgent，NetworkMonitor等来完成，ConnectivityService处于核心调度位置。

ConnectivityService框架主要有四个方面组成：

一 . 网络有效性检测（NetworkMonitor）
二 . 网络评分机制（NetworkFactory）
三 . 路由配置信息的获取（NetworkAgent）
四 . 网络物理端口的设置（Netd）

![这里写图片描述](https://img-blog.csdn.net/20171114164204441?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc2p6NDg2MDQwMg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)



ConnectivityService的工作总结起来就是：通过wifi，mobile data，Tethering，VPN 等方式来获取路由配置信息。无论通过哪种方式，获取到路由配置信息后，需要交给ConnectivityService来处理，ConnectivityService通过ping网络来检查网络的有效性，进而影响到各个数据业务方式的评分值，ConnectivityService通过这些评分值来决定以哪个数据业务方式连接网络。决定好数据业务方式后，把这些路由配置信息设置到网络物理设备中。这样我们的手机就可以正常上网了。



## 初始化：

ConnectivityService属于系统服务，在SystemServer中被启动。

SystemServer启动的服务：

```java
        NetworkManagementService networkManagement = null;
        NetworkStatsService networkStats = null;
        NetworkPolicyManagerService networkPolicy = null;
        ConnectivityService connectivity = null;
        NetworkScoreService networkScore = null;
        NsdService serviceDiscovery= null;
```

**一 . ConnectivityService初始化**

1.获取其他服务的接口

```java
        mContext = checkNotNull(context, "missing Context");
        mNetd = checkNotNull(netManager, "missing INetworkManagementService");
        mStatsService = checkNotNull(statsService, "missing INetworkStatsService");
        mPolicyManager = checkNotNull(policyManager, "missing INetworkPolicyManager");
        mPolicyManagerInternal = checkNotNull(
                LocalServices.getService(NetworkPolicyManagerInternal.class),
                "missing NetworkPolicyManagerInternal");

        mKeyStore = KeyStore.getInstance();
        mTelephonyManager = (TelephonyManager)                             
        mContext.getSystemService(Context.TELEPHONY_SERVICE);
```

2.注册其他必要的监听和广播，以便接收变化信息和通知变化信息。

```java
        try {
            mNetd.registerObserver(mTethering);
            mNetd.registerObserver(mDataActivityObserver);
        } catch (RemoteException e) {
            loge("Error registering observer :" + e);
        }
```

```java
        //set up the listener for user state for creating user VPNs
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(Intent.ACTION_USER_STARTED);
        intentFilter.addAction(Intent.ACTION_USER_STOPPED);
        intentFilter.addAction(Intent.ACTION_USER_ADDED);
        intentFilter.addAction(Intent.ACTION_USER_REMOVED);
        intentFilter.addAction(Intent.ACTION_USER_UNLOCKED);
        mContext.registerReceiverAsUser(
                mUserIntentReceiver, UserHandle.ALL, intentFilter, null, null);
        mContext.registerReceiverAsUser(mUserPresentReceiver, UserHandle.SYSTEM,
                new IntentFilter(Intent.ACTION_USER_PRESENT), null, null);
```

**二 . NetworkFactory的初始化**

NetworkFactory负责了网络评分机制的功能，为了在手机开机后可以及时依靠网络评分机制来选择网络。ConnectivityService服务起来后，在各个模块的初始化过程中，NetworkFactory必须要启动起来。以下的时序图只画了mobile data和wifi模块的NetworkFactory启动流程：

![img](https://img-blog.csdn.net/20171115103241573?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc2p6NDg2MDQwMg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

NetworkFactory在register()之后通过AsyncChannel与ConnectivityService建立起了连接，这一块的逻辑流程，如果看不太懂，那么需要去看看：[AsyncChannel的工作机制](http://blog.csdn.net/sjz4860402/article/details/78524091)

```java
    public void register() {
        if (DBG) log("Registering NetworkFactory");
        if (mMessenger == null) {
            mMessenger = new Messenger(this);
            ConnectivityManager.from(mContext).registerNetworkFactory(mMessenger, LOG_TAG);
        }
    }
```

```java
    @Override
    public void registerNetworkFactory(Messenger messenger, String name) {
        enforceConnectivityInternalPermission();
        NetworkFactoryInfo nfi = new NetworkFactoryInfo(name, messenger, new AsyncChannel());
        mHandler.sendMessage(mHandler.obtainMessage(EVENT_REGISTER_NETWORK_FACTORY, nfi));
    }
```

```java
    private void handleRegisterNetworkFactory(NetworkFactoryInfo nfi) {
        if (DBG) log("Got NetworkFactory Messenger for " + nfi.name);
        mNetworkFactoryInfos.put(nfi.messenger, nfi);
        nfi.asyncChannel.connect(mContext, mTrackerHandler, nfi.messenger);
    }
```

**三 . NetworkAgent的初始化**

NetworkAgent是一个网络代理，它里面保存了一些路由的配置信息，比如NetworkInfo，LinkProperties，NetworkCapabilities等。NetworkAgent的初始化都是在路由配置信息获取成功之后。比如打开数据开关，打开wifi开关等操作之后。

注：
NetworkInfo 描述一个给定类型的网络接口的状态方面的信息，包括网络连接状态、网络类型、网络可连接性、是否漫游等信息
LinkProperties 描述一个网络连接属性信息（包含网络地址、网关、DNS、HTTP代理等属性信息
NetworkCapabilities 描述一个网络连接能力方面的信息，包括带宽、延迟等

**四 . NetworkMonitor的初始化**

NetworkMonitor主要是**检测网络有效性**的，通过Http封装类去ping一个网站，根据ping网站的结果来影响评分值。因此，它的初始化是在NetworkAgent初始化之后，必须要获取到路由配置信息NetworkAgent后才会去初始化。



## 一 . 网络有效性检测（NetworkMonitor）

NetworkMonitor是一个状态机。负责检测网络有效性，也就是ping网络的过程。ping网络过程中产生的几种状态如下：

DefaultState 默认状态
EvaluatingState 验证状态
ValidatedState 验证通过状态
LingeringState 休闲状态，表示网络的验证位是真实的，并且曾经是满足特定NetworkRequest的最高得分网络，但是此时另一个网络满足了NetworkRequest的更高分数，在断开连接前的一段时间前，该网络被“固定”为休闲状态。
CaptivePortalState 强制门户状态
MaybeNotifyState 可能通知状态，表示用户可能已被通知需要登录。 在退出该状态时，应该小心清除通知。

NetworkMonitor中各个状态之间的关系：

![这里写图片描述](https://img-blog.csdn.net/20171115114721136?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc2p6NDg2MDQwMg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

以正常的ping网站过程为例，DefaultState为默认状态，NetworkMonitor接收到CMD_NETWORK_CONNECTED事件消息后，先由DefaultState状态处理，然后由EvaluatingState处理，最后交给ValidatedState处理。这一块的逻辑流程，如果看不太懂，那么需要去看看StateMachine状态机的使用：StateMachine状态机初识

从NetworkMonitor的初始化，到ping网站的过程，到ping网站的结果影响评分值。这个过程的时序图如下：

![这里写图片描述](https://img-blog.csdn.net/20171115115808027?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc2p6NDg2MDQwMg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

接下来将按照时序图中的三大步骤去结合代码分析。

**1 . NetworkMonitor的初始化（以mobile data为例）**

DataConnection从modem中获取到了代理信息，并把此代理信息保存到了NetworkAgent中：

```java
            mNetworkAgent = new DcNetworkAgent(getHandler().getLooper(), mPhone.getContext(),
                    "DcNetworkAgent", mNetworkInfo, getNetworkCapabilities(), mLinkProperties,
                    50, misc);
```

在NetworkAgent的构造函数中，把它自己注册到了ConnectivityService中，

```java
        ConnectivityManager cm = (ConnectivityManager)mContext.getSystemService(
                Context.CONNECTIVITY_SERVICE);
        netId = cm.registerNetworkAgent(new Messenger(this), new NetworkInfo(ni),
                new LinkProperties(lp), new NetworkCapabilities(nc), score, misc);
```

接下来的流程就如时序图所示了，意味着每产生一个代理信息NetworkAgent的对象，就会有自己相应的NetworkMonitor状态机来处理ping网站的过程。

**2 . ping网站的过程**

NetworkMonitor状态机运行起来后，接收到sendMessage的消息就可以做相应的处理。这里比较重要的就是CMD_NETWORK_LINGER和CMD_NETWORK_CONNECTED消息，分别由ConnectivityService的linger()和unlinger()方法封装发送的操作。

**linger():**

封装了CMD_NETWORK_LINGER消息的发送操作，让NetworkMonitor进入到休闲状态：
CMD_NETWORK_LINGER消息首先进入到DefaultState.processMessage()处理：

CMD_NETWORK_LINGER消息切换到LingeringState处理，enter()做一个CMD_LINGER_EXPIRED消息延迟发送：

LingeringState.processMessage()中对延迟消息CMD_LINGER_EXPIRED做处理：