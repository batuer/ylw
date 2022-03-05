title:  RxJava2操作符
date: 2018年2月13日13:55:44
categories: RxJava2
tags: 
	 - RxJava2
cover_picture: /images/RxJava.jpeg
---
### 创建
#### 基本创建
1. create() : 完整创建1个被观察者对象（Observable）
#### 快速创建 & 发送事件 
1. just() : 
  * 快速创建1个被观察者对象（Observable）
  * 发送事件的特点：直接发送 传入的事件
  * 最多只能创建10个
2. fromArray（）:
  * 快速创建1个被观察者对象（Observable）
  * 发送事件的特点：直接发送 传入的数组数据
  * 10个以上事件
3. fromIterable（）:
  * 快速创建一个被观察者对象(Observable)
  * 发送事件的特点，直接发送传入的集合数据
  * 发送10个以上事件
#### 延迟创建
1. defer():
  * 直到有观察者（Observer ）订阅时，才动态创建被观察者对象（Observable） & 发送事件
2. timer():
  * 快速创建1个被观察者对象（Observable）
  * 发送事件的特点：延迟指定时间后，发送1个数值0（Long类型）
  * 本质:延迟执行onNext(0)
3. interval():
  * 快速创建1个被观察者对象(Observable)
  * 发送事件的特点:延迟初始化时间开始执行定时间隔发送事件
  * 从0开始，递增1执行
4. intervalRange():
  * 快速创建1个被观察者对象(Observable)
  * 发送事件的特点:类似于interval(),区别在于事件 起始值和数量有限制.
5. range() /rangeLong() :
  * 快速创建1个被观察者对象(Observable)
  * 发送事件的特点: 连续发送事件，参数分别为起始值和事件数量.
### 变换
#### 变换操作符
1. map():
  * 改变发射源的数据类型
2. flatMap():
  * 将被观察者发送的事件序列进行 拆分 & 单独转换，再合并成一个新的事件序列，最后再进行发送(<font color = ff0000 size = 4>无序</font> )
  * 直接改变发射源
3. contactMap() :
  * 类似于flatMap()
  * 与FlatMap（）的 区别在于：拆分 & 重新合并生成的事件序列 的顺序 = 被观察者旧序列生产的顺序(<font color = ff0000 size = 4>有序</font>)
4. switchMap() :
  * switchMap的作用在flatMap的基础上，对输出结果若同时发生，只会保证最新结果而放弃旧数据。
5. buffer() :
  * 定期从 被观察者（Observable）需要发送的事件中 获取一定数量的事件 & 放到缓存区中，最终发送
### 组合/合并
#### 组合多个被观察者
1. concat（） / concatArray（）:
  * 组合多个被观察者一起发送数据，合并后 按发送顺序<font color = ff0000 size = 4>串行执行</font>
  * 二者区别：组合被观察者的数量，即concat（）组合被观察者数量≤4个，而concatArray（）则可＞4个
2. merge（） / mergeArray（）:
  * 组合多个被观察者一起发送数据，合并后 按时间线<font color = ff0000 size = 4>并行执行</font>
  * 二者区别：组合被观察者的数量，即merge（）组合被观察者数量≤4个，而mergeArray（）则可＞4个
  * 区别上述concat（）操作符：同样是组合多个被观察者一起发送数据，但concat（）操作符合并后是按发送顺序**串行**执行
3. concatDelayError（） / mergeDelayError（）:
  * 使用contact或merge时，前面的某一事件发生error时终止其他观察者发送事件
  * 用DelayError()推迟error事件至其它观察者发送完事件.
#### 合并多个事件
1. zip() 
  * 合并 多个被观察者（Observable）发送的事件，生成一个新的事件序列（即组合过后的事件序列），并最终发送
  * 事件组合方式 = 严格按照原先事件序列 进行对位合并
  * 被合并的事件都会执行完毕，最终合并的事件已最少的为基准。
2. combineLatest（）
  * 当两个Observables中的任何一个发送了数据后，将先发送了数据的Observables 的最新（最后）一个数据 与 另外一个Observable发送的每个数据结合，最终基于该函数的结果发送数据
  * 与Zip（）的区别：Zip（）= 按个数合并，即1对1合并；CombineLatest（） = 按时间合并，即在同一个时间点上合并
3. combineLatestDelayError()
  * 类似于contactDelayError()
4. reduce() 
  * 把被观察者需要发送的事件聚合成1个事件 & 发送
  * 聚合的逻辑根据需求撰写，但本质都是前2个数据聚合，然后与后1个数据继续进行聚合，依次类推
5. collect()
  * 将被观察者Observable发送的数据事件收集到一个数据结构里
#### 发送事件前追加发送事件
1. startWitch()/startWithArray()
  * 在一个被观察者发送事件前，追加发送一些数据 / 一个新的被观察者
#### 统计发送事件的数量
1. count()
  * 统计被观察者发送的事件数量
### 应用场景 & 对应操作符详解
#### 连接被观察者 & 观察者
1. subscribe（）
  * 订阅，即连接观察者 & 被观察者
#### 线程调度
#### 延迟操作
1. delay（）
  * 使得被观察者延迟一段时间再发送事件
#### 在事件的生命周期中操作
1. do()
  * 在某个事件的生命周期中调用
  * doOnEach 当Observable每发送1次数据事件就会调用1次.包含onNext、onError、onComplete
  * doOnNext 执行Next事件前调用 
  * doAfterNext 执行Next事件后调用
  * doOnComplete Observable正常发送事件完毕后调用
  * doOnError Observable发送错误事件时调用
  * doOnSubscribe 观察者订阅时调用
  * doAfterTerminate  Observable发送事件完毕后调用，无论正常发送完毕 / 异常终止
  * doFinally 最后执行
#### 错误处理
1. onErrorReturn（）
  * 遇到错误时，发送1个特殊事件 & 正常终止
2. onErrorResumeNext（）
  * 遇到错误时，发送1个新的Observable
  * onErrorResumeNext（）拦截的错误 = Throwable；若需拦截Exception请用onExceptionResumeNext（）
  * 若onErrorResumeNext（）拦截的错误 = Exception，则会将错误传递给观察者的onError方法
3. onExceptionResumeNext（）
  * 遇到错误时，发送1个新的Observable
  * onExceptionResumeNext（）拦截的错误 = Exception；若需拦截Throwable请用onErrorResumeNext（）
  * 若onExceptionResumeNext（）拦截的错误 = Throwable，则会将错误传递给观察者的onError方法
4. retry()
  * 重试，即当出现错误时，让被观察者（Observable）重新发射数据
  * 接收到 onError（）时，重新订阅 & 发送事件
  * Throwable 和 Exception都可拦截
5. retryUntil（）
  * 出现错误后，判断是否需要重新发送数据
  * 若需要重新发送 & 持续遇到错误，则持续重试
  * 作用类似于retry（Predicate predicate）
  * 返回true则不重新发送数据事件
6. retryWhen（）
  * 遇到错误时，将发生的错误传递给一个新的被观察者（Observable），并决定是否需要重新订阅原始被观察者（Observable）& 发送事件
  * 若返回的Observable发送的事件 = Next事件，则原始的Observable重新发送事件（若持续遇到错误，则持续重试）
  * 返回的Observable发送的事件 = Error事件，则原始的Observable不重新发送事件,该异常错误信息可在观察者中的onError（）中获得
#### 重复发送
1. repeat()
  * 无条件地、重复发送 被观察者事件
2. repeatWhen（）
  * 有条件地、重复发送 被观察者事件
  * 若新被观察者（Observable）返回1个Complete（） /  Error（）事件，则不重新订阅 & 发送原来的 Observable
  * 若新被观察者（Observable）返回其余事件，则重新订阅 & 发送原来的 Observable