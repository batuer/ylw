title: JavaInnerClass
date: 2019年05月12日08:33:37
categories: 未标记
tags: 
     - 未标记
cover_picture: /images/JavaInnerClass.jpeg
---
    
#### 内部类

- 类的内部定义一个类。

- 内部类在编译完成后也会产生.class文件，但文件名称是：外部类名称$内部类名称.class。 

- 优点：

  - 实现多重继承。

    ```java
    class Mather {
      public void mather() {
        System.out.println("mather");
      }
    }
    
    class Father {
      public void father() {
        System.out.println("father");
      }
    }
    
    public class Son {
    
      class MatherSon extends Mather {
      }
    
      class FatherSon extends Father {
      }
    
      public void son() {
        new MatherSon().mather();
        new FatherSon().father();
      }
    }
    ```

  - 内部类可以很好的实现隐藏：一般非内部类，是不允许有private和protected权限的，但内部类可以。

  - 减少类文件编译后产生的字节码文件的大小。

- 缺点：

  - 程序结构不清楚。

#### 静态内部类

- 内部类使用static声明。
- 通过**外部类.内部类**访问。
- **内部类不需要外部类的实例**（区别成员内部类），静态内部类存在仅仅为外部类提供服务或逻辑上属于外部类，逻辑上可以单独存在。

###### 特征

- 静态内部类不会持有外部类的引用。
- 静态内部类可以访问外部类的静态属性、方法。

```java
public class Outer {
  public static int a = 0;
  private int b = 0;

  public void outer() {
  }

  private static void privateDoSth() {
  }

  static class Inner {
    public void inner() {
      privateDoSth();
      a = 2;
      // b = 3; error
    }
  }
}

  public static void main(String[] args) {
     Outer outer = new Outer();
    //Outer.Inner inner = outer.new Inner(); error
     Outer.Inner.inner();
  }
```

#### 成员内部类

- 也叫实例内部类。
- **内部类离不开外部类的存在**。

###### 特征

- 外部类的一个成员存在，与外部类的属性、方法并列。
- 成员内部类持有外部类的引用。
- 成员内部类中不能定义static变量和方法。

```java
public class Outer {
  public void outer() {
  }

  private void privateDoSth() {
  }

  class Inner {
    public void inner() {
      privateDoSth();
    }
  }
}

public static void main(String[] args) {
    Outer outer = new Outer();
    Outer.Inner inner = outer.new Inner();
    // inner.outer(); error
    inner.inner();
}
```

##### 匿名内部类

- 没有名字的内部类，仅使用一次的内部类。
- 简化内部类的使用。

###### 特征

- 使用new创建，没有具体位置。
- 创建的匿名内部类，默认继承或实现new后面的类型。
- 根据情况决定持有外部类对象引用。
- 内嵌匿名类编译后产生.class文件的命名方式是“外部类名称$编号.class "

```java
public class Client {
  public void main(String[] args) {
    Person person = new Person() {
      public void person() {
        System.out.println("person 匿名内部类");
      }
    };
  }
}
```
##### 局部内部类

- 也叫局域内嵌类。
- 与成员内部类类似，局域内部类定义在方法之中。
- 内部类对象仅仅为外部类的某个方法使用，使用局部内部类。

###### 特征

- 用在方法内部，作用范围仅限于该方法中。
- 不能使用private、protected、public修饰符。
- 不能包含静态成员。
- 根据情况决定持有外部类对象引用。

```java
public class Client {
  public void main(String[] args) {
    methodInner();
  }

  public void methodInner() {
    class MethodInner {
      public void methodInner() {
      }
    }

    MethodInner methodInner = new MethodInner();
    methodInner.methodInner();
  }
}public class Client {
  public void main(String[] args) {
    methodInner();
  }

  public void methodInner() {

    class MethodInner {
      //private static int a = 0; error
      public void methodInner() {
      }
    }

    MethodInner methodInner = new MethodInner();
    methodInner.methodInner();
  }
}
```