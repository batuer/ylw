title:  Dart
date: 2018年4月7日16:41:17
categories: Dart
tags: 

	 - Dart
cover_picture: /images/dart.png
---

### Dart基础学习。

List

- 固定长度的列表，一旦定义无法改变。

  ```dart
  void _fixedList() {
      List<int> list = new List(3);
      list[0] = 0;
      list[1] = 1;
      for (var value in list) {
        print('Fire:' + value.toString());
      }
      //错误:Unsupported operation: Cannot add to a fixed-length list
      //list.add(4);
    }
  ```

- 可变长度，动态加减。

  ```dart
   void _growableList() {
      List<int> list = [0, 1];
      print('Fire:' + list[1].toString());
      list[1] = 11;
      print('Fire:' + list[1].toString());
      //add
      list.add(3);
      for (var value in list) {
        print('Fire:DartTest:29:' + value.toString());
      }
    }
  ```

- 几种构造。

  ```dart
  // 创建固定长度的列表
  	List fixedLengthList = new List(3);
  // 创建可改变长度的列表
  	List growableListA = new List();
  // 创建包含所有元素的固定长度列表
  	List fixedLengthListB = new List.unmodifiable([1, 2, 3]);
  // 创建包含所有元素的可改变长度列表
  	List growableListC = new List.from([1, 2, 3]);
  // 用生成器给所有元素赋初始值
      List fixedLengthList = new List<int>.generate(4, (int index) {
        return index * index;
      });

  ```

- 排序。

  ```dart
  void _listSort() {
      List<int> list = [1, 3, 2, 5, 6, 7, 4];
      list.sort((a, b) {
        return a.compareTo(b);
      });
      print('Fire:DartTest:47:' + list.join(","));
      list.sort((a, b) {
        return a - b;
      });
      print('Fire:DartTest:51:' + list.join(","));
      list.sort((a, b) {
        return b - a;
      });
      print('Fire:DartTest:55:' + list.join(","));
    }
  ```

#### Map

- 键值对，每个键对应一个值。

- 几种构造。

  ```dart
  void _map() {
      //
      Map<String, int> map = {"a": 1, "b": 2};
      print('DartTest:62:' + map.keys.join(",") + ":" + map.values.join(","));
      map.addAll({"c": 3});
      print('DartTest:65:' + map.keys.join(",") + ":" + map.values.join(","));
      map.addAll({"a": 11});
      print('DartTest:67:' + map.keys.join(",") + ":" + map.values.join(","));
      //
      Map<String, int> map1 = Map.castFrom(map);
      print('DartTest:70:' + map1.keys.join(",") + ":" + map1.values.join(","));
      //
      List<MapEntry<String, int>> list = [
        new MapEntry("a", 1),
        new MapEntry("b", 2)
      ];
      Map<String, int> mapFromEntries = new Map.fromEntries(list);
      //
      List<String> list1 = ["4", "5"];
      List<int> list2 = [1, 2];
      var map2 = new Map.fromIterables(list1, list2);
      print('DartTest:82:' + map2.keys.join(",") + map2.values.join(","));

      Map<String, String> map3 =
          new Map.fromIterable(list1, key: (item) => item, value: (item) => item);
      Map<String, String> map4 = new Map.fromIterable(list2, key: (item) {
        item.toString();
      }, value: (item) {
        item.toString();
      });
    }
  ```

#### Set

- 每个对象只能出现一次，不能重复。

#### 命名参数

- 用 { } 把参数包装起来，就能标识命名参数。
- 用 : 指定默认值。

```dart
void test() {
    _parameter(name: "xiaoming", age: 11);
    _parameter(name: "xiaoming", age: 11, sex: "woman");
    _parameter1("小明", 22, "man");
  }

  //用 { } 把参数包装起来，就能标识命名参数。
  //用 : 指定默认值
  void _parameter({String name, int age, String sex: 'man'}) {}

  void _parameter1(String name, int age, String sex) {}
```

#### 位置参数

- 用[ ] 把参数包括起来，标示参数位置
- 用=指定默认值

```dart
 void test() {
    _parameterPos("小明", "11");
    _parameterPos("小明", "11", "sex", 11);
  }

  // 用 [ ] 把参数包装起来，就能标识位置参数
  // 用 = 指定默认值
  void _parameterPos(String name, String age, [String sex, int height]) {
    StringBuffer sb = new StringBuffer();
    sb.write("name_");
    if (name != null) {
      sb.write(name);
    }
    sb.write("  age_");
    if (age != null) {
      sb.write(age);
    }
    sb.write("  sex_");
    if (sex != null) {
      sb.write(sex);
    }
    sb.write("  height_");
    if (height != null) {
      sb.write(height);
    }
    print('Fire:DartTest:27:' + sb.toString());
  }
```

#### 高阶函数

- 将一个函数当作参数传递。

  ```dart
   void test() {
      List<String> list = ["a", "b"];
      list.forEach((item) {
        _printElement(item);
      });
      list.forEach(_printElement);
    }

    //将一个函数当作参数传递
    void _printElement(Object obj) {
      print('Fire:DartTest:11:' + obj.toString());
    }
  ```

- 将一个函数分配给变量。

  ```dart
  void test() {
      //将一个函数分配给一个变量
      var loudify = (msg) => "将一个函数分配给一个变量:${msg.toUpperCase()}";
      print('Fire:DartTest:14:' + loudify('hello'));
    }
  ```



#### 闭包函数

- dart的闭包就是函数对象，其实跟JavaScript的闭包函数差不多，理论请参考JavaScript的闭包函数。

  ```dart
  void test() {
        var makeAddBy2 = makeAddBy(num: 2);
        var makeAddBy3 = makeAddBy(num: 3);
        print('Fire:DartTest:9:' + makeAddBy3(5).toString());
        print('Fire:DartTest:8:' + makeAddBy2(3).toString());
    }
    Function makeAddBy({int num}) {
      return (int i) => i + num;
    }
  ```

#### 泛型

- dart中所有基本类型数组和列表都是泛型，这样可以提高代码的可读性。
- 减少代码。
- 提前检查。

#### 异常

- dart会抛出并捕获异常，如果没有捕获异常，就会中断运行或结束程序。
- 与Java不同的是dart的所有异常都是**未经检查**的。
- dart提供了Exception、Error类型，以及更多的子类型，也可以自定义异常。

```dart
void _exception() {
//    //
//    if (true) {
//      throw new Exception("异常");
//    }
//    //自定异常
//    if (true) {
//      throw "自定义异常";
//    }
    //捕获并处理
    try {
      if (true) {
        throw new Exception("异常");
      }
    } on Exception {
      print('Fire:DartTest:24:' + '捕获异常');
    }
    //
    try {
      if (true) {
        throw new Exception("异常");
      }
    } on Exception catch (e) {
      print('Fire:DartTest:24:' + '捕获异常:' + e.toString());
    } finally {}
  }
```

#### 实例变量

- 声明实例变量，未初始化为null。

#### 构造函数

- 默认无参构造。

- 命名构造。

  ```dart
   DartTest.fromJson(String json) {}
  ```
  
- 子类构造函数调用父类的默认构造函数，如果父类没有默认构造函数，必须手动调用父类的构造函数。

- 重定向构造。

  ```dart
  DartTest({int a}) {}

    DartTest.fromJson(int b) : this(a: b);
  ```

- 常量构造。声明const 构造，**并且**确保实例变量是final的。

  ```dart
  //常量构造
    const DartTest();

    static final DartTest dartTest = new DartTest();
  ```


#### 抽象类

- 使用abstract修饰符定义的抽象类不能被实例化。
- 用于定义接口。
- 有抽象方法的一定是抽象类，反之则不然。

#### 隐式接口

- 每个类都有一个隐式定义的接口，包含所有非私有方法和变量。
- implements 实现一个或多个接口。

```dart
class Person {
  final _name;
  int height;
  int _width;
  Person(this._name);

  String greet(who) => "Hello, $who. I am $_name.";
  void _test(){}
}

class PersonIml implements Person {
  @override
//  String greet(who) => "-------";
  String greet(who) {
    return "-----";
  }

  @override
  int height;
}
```

