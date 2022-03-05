title:  Java反射
date: 2018年2月17日22:30:51
categories: Java
tags: 
	 - Java基础
	 - Java反射
cover_picture: /images/JavaReflect.jpg
---
### 一、概述

**Java反射机制定义**

Java反射机制是在**运行**状态中，对于任意一个类，都能够知道这个类中的所有属性和方法；对于任意一个对象，都能够调用它的任意一个方法和属性；这种动态获取的信息以及动态调用对象的方法的功能称为java语言的反射机制。  
**Java 反射机制的功能**

1.在运行时判断任意一个对象所属的类。

2.在运行时构造任意一个类的对象。

3.在运行时判断任意一个类所具有的成员变量和方法。

4.在运行时调用任意一个对象的方法。

5.生成**动态代理**。

**Java 反射机制的应用场景**

1.逆向代码 ，例如反编译

2.与注解相结合的框架 例如Retrofit

3.单纯的反射机制应用框架 例如EventBus

4.动态生成类框架 例如Gson

### 二、代理模式

**定义：**给某个对象提供一个代理对象，并由代理对象控制对于原对象的访问，即客户不直接操控原对象，而是通过代理对象间接地操控原对象。

##### 1、代理模式的参与者

代理模式的角色分四种：  


![](http://upload-images.jianshu.io/upload_images/3985563-f4d339a69a8b9e92.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

  



**主题接口：**Subject 是委托对象和代理对象都共同实现的接口，即代理类的所实现的行为接口。Request\(\) 是委托对象和代理对象共同拥有的方法。  
**目标对象：**ReaSubject 是原对象，也就是被代理的对象。  
**代理对象：**Proxy 是代理对象，用来封装真是主题类的代理类。  
**客户端 ：**使用代理类和主题接口完成一些工作。

##### 2、代理模式的分类

代理的实现分为：

**静态代理：**代理类是在**<u>编译时</u>**就实现好的。也就是说 Java 编译完成后代理类是一个实际的 class 文件。  
**动态代理：**代理类是在**<u>运行时</u>**生成的。也就是说 Java 编译完之后并没有实际的 class 文件，而是在运行时动态生成的类字节码，并加载到JVM中。

##### 3、代理模式的实现思路

1.代理对象和目标对象均实现同一个行为接口。

2.代理类和目标类分别具体实现接口逻辑。

3.在代理类的构造函数中实例化一个目标对象。

4.在代理类中调用目标对象的行为接口。

5.客户端想要调用目标对象的行为接口，只能通过代理类来操作。

##### 4、静态代理模式的简单实现

```java
public class ProxyDemo {
    public static void main(String args[]) {
      ShopCart subject = new ShopCart();
      ShopProxy p = new ShopProxy(subject);
      p.shop();
    }
  }

  interface Shop {
    void shop();
  }

  class ShopCart implements Shop {

    @Override public void shop() {
      Log.w("Fire", "ShopCart:25: Shop");
    }
  }

  class ShopProxy implements Shop {
    private ShopCart mShopCart;

    public ShopProxy(ShopCart shopCart) {
      mShopCart = shopCart;
    }

    @Override public void shop() {
      Log.w("Fire", "ShopProxy:38:登录验证");
      mShopCart.shop();
      Log.w("Fire", "ShopProxy:40:日志记录");
    }
  }
```

目标对象\(RealSubject \)以及代理对象（Proxy）都实现了主题接口（Subject）。在代理对象（Proxy）中，通过构造函数传入目标对象\(RealSubject \)，然后重写主题接口（Subject）的request\(\)方法，在该方法中调用目标对象\(RealSubject \)的request\(\)方法，并可以添加一些额外的处理工作在目标对象\(RealSubject \)的request\(\)方法的前后。

**代理模式的好处：**

假如有这样的需求，要在某些模块方法调用前后加上一些统一的前后处理操作，比如在添加购物车、修改订单等操作前后统一加上登陆验证与日志记录处理，该怎样实现？首先想到最简单的就是直接修改源码，在对应模块的对应方法前后添加操作。如果模块很多，你会发现，修改源码不仅非常麻烦、难以维护，而且会使代码显得十分臃肿。

这时候就轮到代理模式上场了，它可以在被调用方法前后加上自己的操作，而不需要更改被调用类的源码，大大地降低了模块之间的耦合性，体现了极大的优势。

### 三、Java反射机制与动态代理

##### 1、动态代理介绍

动态代理是指在**运行时动态**生成代理类。即，代理类的字节码将在运行时生成并载入当前代理的 ClassLoader。与静态处理类相比，动态类有诸多好处。

①不需要为\(RealSubject \)写一个形式上完全一样的封装类，假如主题接口（Subject）中的方法很多，为每一个接口写一个代理方法也很麻烦。如果接口有变动，则目标对象和代理类都要修改，不利于系统维护；

②使用一些动态代理的生成方法甚至可以在运行时制定代理类的执行逻辑，从而大大提升系统的灵活性。

##### 2、动态代理涉及的主要类

**java.lang.reflect.Proxy:**这是生成代理类的主类，通过 Proxy 类生成的代理类都继承了 Proxy 类。  
Proxy提供了用户创建动态代理类和代理对象的静态方法，它是所有动态代理类的父类。

**java.lang.reflect.InvocationHandler:**这里称他为"调用处理器"，它是一个接口。当调用动态代理类中的方法时，将会直接转接到执行自定义的InvocationHandler中的invoke\(\)方法。即我们动态生成的代理类需要完成的具体内容需要自己定义一个类，而这个类必须实现 InvocationHandler 接口，通过重写invoke\(\)方法来执行具体内容。

Proxy提供了如下两个方法来创建动态代理类和动态代理实例。

> static Class&lt;?&gt; getProxyClass\(ClassLoader loader, Class&lt;?&gt;... interfaces\) 返回代理类的java.lang.Class对象。第一个参数是类加载器对象（即哪个类加载器来加载这个代理类到 JVM 的方法区），第二个参数是接口（表明你这个代理类需要实现哪些接口），第三个参数是调用处理器类实例（指定代理类中具体要干什么），该代理类将实现interfaces所指定的所有接口，执行代理对象的每个方法时都会被替换执行InvocationHandler对象的invoke方法。
>
> static Object newProxyInstance\(ClassLoader loader, Class&lt;?&gt;\[\] interfaces, InvocationHandler h\) 返回代理类实例。参数与上述方法一致。

对应上述两种方法创建动态代理对象的方式：

```java
        //创建一个InvocationHandler对象
        InvocationHandler handler = new MyInvocationHandler(.args..);
        //使用Proxy生成一个动态代理类
        Class proxyClass = 		Proxy.getProxyClass(RealSubject.class.getClassLoader(),RealSubject.class.getInterfaces());
        //获取proxyClass类中一个带InvocationHandler参数的构造器
        Constructor constructor = proxyClass.getConstructor(InvocationHandler.class);
        //调用constructor的newInstance方法来创建动态实例
        RealSubject real = (RealSubject)constructor.newInstance(handler);
```

```java
        //创建一个InvocationHandler对象
    InvocationHandler handler = new MyInvocationHandler();
    //使用Proxy直接生成一个动态代理对象
    RealSubject real =
        (RealSubject) java.lang.reflect.Proxy.newProxyInstance(RealSubject.class.getClassLoader(),
            RealSubject.class.getInterfaces(), handler);
```

**newProxyInstance这个方法实际上做了两件事：第一，创建了一个新的类【代理类】，这个类实现了Class\[\] interfaces中的所有接口，并通过你指定的ClassLoader将生成的类的字节码加载到JVM中，创建Class对象；第二，以你传入的InvocationHandler作为参数创建一个代理类的实例并返回。**

Proxy 类还有一些静态方法，比如：

`InvocationHandler getInvocationHandler(Object proxy):`获得代理对象对应的调用处理器对象。

`Class getProxyClass(ClassLoader loader, Class[] interfaces):`根据类加载器和实现的接口获得代理类。

InvocationHandler 接口中有方法：

`invoke(Object proxy, Method method, Object[] args)`  
这个函数是在代理对象调用任何一个方法时都会调用的，方法不同会导致第二个参数method不同，第一个参数是代理对象（表示哪个代理对象调用了method方法），第二个参数是 Method 对象（表示哪个方法被调用了），第三个参数是指定调用方法的参数。

##### 3、动态代理模式的简单实现

```java

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

/**
 * Created by Administrator on 2018/2/17.
 */

public class DynamicProxyDemo {
  public static void main(String[] args) {
    //1.创建目标对象
    RealSubject realSubject = new RealSubject();
    //2.创建调用处理器对象
    ProxyHandler handler = new ProxyHandler(realSubject);
    //3.动态生成代理对象
    Subject proxySubject = (Subject) Proxy.newProxyInstance(RealSubject.class.getClassLoader(),
        RealSubject.class.getInterfaces(), handler);
    //4.通过代理对象调用方法
    proxySubject.request();
  }
}

/**
 * 主题接口
 */
interface Subject {
  void request();
}

/**
 * 目标对象类
 */
class RealSubject implements Subject {
  public void request() {
    System.out.println("====RealSubject Request====");
  }
}

/**
 * 代理类的调用处理器
 */
class ProxyHandler implements InvocationHandler {
  private Subject subject;

  public ProxyHandler(Subject subject) {
    this.subject = subject;
  }

  @Override public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
    //定义预处理的工作，当然你也可以根据 method 的不同进行不同的预处理工作
    System.out.println("====before====");
    //调用RealSubject中的方法
    Object result = method.invoke(subject, args);
    System.out.println("====after====");
    return result;
  }
}
```

可以看到，我们通过newProxyInstance就产生了一个Subject 的实例，即代理类的实例，然后就可以通过Subject .request\(\)，就会调用InvocationHandler中的invoke\(\)方法，传入方法Method对象，以及调用方法的参数，通过Method.invoke调用RealSubject中的方法的request\(\)方法。同时可以在InvocationHandler中的invoke\(\)方法加入其他执行逻辑。

### 四、泛型和Class类

从JDK 1.5 后，Java中引入泛型机制，Class类也增加了泛型功能，从而允许使用泛型来限制Class类，例如：String.class的类型实际上是Class&lt;String&gt;。如果Class对应的类暂时未知，则使用Class&lt;?&gt;\(?是通配符\)。通过反射中使用泛型，可以避免使用反射生成的对象需要强制类型转换。

泛型的好处众多，最主要的一点就是避免类型转换，防止出现ClassCastException，即类型转换异常。

### 五、使用反射来获取泛型信息

通过指定类对应的 Class 对象，可以获得该类里包含的所有 Field，不管该 Field 是使用 private 修饰，还是使用 public 修饰。获得了 Field 对象后，就可以很容易地获得该 Field 的数据类型，即使用如下代码即可获得指定 Field 的类型。

```java
// 获取 Field 对象 f 的类型
Class<?> a = f.getType();
```

但这种方式只对普通类型的 Field 有效。如果该 Field 的类型是有泛型限制的类型，如 Map&lt;String, Integer&gt; 类型，则不能准确地得到该 Field 的泛型参数。

为了获得指定 Field 的泛型类型，应先使用如下方法来获取指定 Field 的类型。

```java
// 获得 Field 实例的泛型类型
Type type = f.getGenericType();
```

然后将 Type 对象强制类型转换为 ParameterizedType 对象，ParameterizedType 代表被参数化的类型，也就是增加了泛型限制的类型。ParameterizedType 类提供了如下两个方法。

**getRawType\(\)：**返回没有泛型信息的原始类型。

**getActualTypeArguments\(\)：**返回泛型参数的类型。

下面是一个获取泛型类型的完整程序。

```java
public class GenericTest
{
    private Map<String , Integer> score;
    public static void main(String[] args)
        throws Exception
    {
        Class<GenericTest> clazz = GenericTest.class;
        Field f = clazz.getDeclaredField("score");
        // 直接使用getType()取出Field类型只对普通类型的Field有效
        Class<?> a = f.getType();
        // 下面将看到仅输出java.util.Map
        System.out.println("score的类型是:" + a);
        // 获得Field实例f的泛型类型
        Type gType = f.getGenericType();
        // 如果gType类型是ParameterizedType对象
        if(gType instanceof ParameterizedType)
        {
            // 强制类型转换
            ParameterizedType pType = (ParameterizedType)gType;
            // 获取原始类型
            Type rType = pType.getRawType();
            System.out.println("原始类型是：" + rType);
            // 取得泛型类型的泛型参数
            Type[] tArgs = pType.getActualTypeArguments();
            System.out.println("泛型类型是:");
            for (int i = 0; i < tArgs.length; i++) 
            {
                System.out.println("第" + i + "个泛型类型是：" + tArgs[i]);
            }
        }
        else
        {
            System.out.println("获取泛型类型出错！");
        }
    }
}
```

输出结果：

> score 的类型是: interface java.util.Map  
> 原始类型是: interface java.util.Map  
> 泛型类型是:  
> 第 0 个泛型类型是: class java.lang.String  
> 第 1 个泛型类型是：class java.lang.Integer

从上面的运行结果可以看出，直接使用 Field 的 getType\(\) 方法只能获取普通类型的 Field 的数据类型：对于增加了泛型参数的类型的 Field，应该使用 getGenericType\(\) 方法来取得其类型。

Type 也是 java.lang.reflect 包下的一个接口，该接口代表所有类型的公共高级接口，Class 是 Type 接口的实现类。Type 包括原始类型、参数化类型、数组类型、类型变量和基本类型等。