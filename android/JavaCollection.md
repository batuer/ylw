title:  Java集合
date: 2018年2月14日09:13:56
categories: Java
tags: 
	 - Java基础
	 - Java集合
cover_picture: /images/JavaCollection.jpg
---
## 一、Java集合类简介：
Java集合大致可以分为Set、List、Queue和Map四种体系。

其中Set代表无序、不可重复的集合；List代表有序、重复的集合；而Map则代表具有映射关系的集合。Java 5 又增加了Queue体系集合，代表一种队列集合实现。

Java集合就像一种容器，可以把多个对象（实际上是对象的引用，但习惯上都称对象）“丢进”该容器中。从Java 5 增加了泛型以后，Java集合可以记住容器中对象的数据类型，使得编码更加简洁、健壮。
### 1.Java集合和数组的区别：
①.数组长度在初始化时指定，意味着只能保存定长的数据。而集合可以保存数量不确定的数据。同时可以保存具有映射关系的数据（即关联数组，键值对 key-value）。

②.数组元素即可以是基本类型的值，也可以是对象。集合里只能保存对象（实际上只是保存对象的引用变量），基本数据类型的变量要转换成对应的包装类才能放入集合类中。
### 2.Java集合类之间的继承关系:
Java的集合类主要由两个接口派生而出：Collection和Map,Collection和Map是Java集合框架的根接口。

![](http://upload-images.jianshu.io/upload_images/3985563-e7febf364d8d8235.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

图中，ArrayList,HashSet,LinkedList,TreeSet是我们经常会有用到的已实现的集合类。

Map实现类用于保存具有映射关系的数据。Map保存的每项数据都是key-value对，也就是由key和value两个值组成。Map里的key是不可重复的，key用户标识集合里的每项数据。

![](http://upload-images.jianshu.io/upload_images/3985563-06052107849a7603.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

图中，HashMap，TreeMap是我们经常会用到的集合类。
## 二、Collection接口：
### 1.简介
Collection接口是Set,Queue,List的父接口。Collection接口中定义了多种方法可供其子类进行实现，以实现数据操作。由于方法比较多，就偷个懒，直接把JDK文档上的内容搬过来。
#### 1.1.接口中定义的方法
![](http://upload-images.jianshu.io/upload_images/3985563-414332ffe4733274.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

可以看出Collection用法有：添加元素，删除元素，返回Collection集合的个数以及清空集合等。
其中重点介绍iterator()方法，该方法的返回值是Iterator<E>。
#### 1.2.使用Iterator遍历集合元素
Iterator接口经常被称作迭代器，它是Collection接口的父接口。但Iterator主要用于遍历集合中的元素。
Iterator接口中主要定义了2个方法：

![](http://upload-images.jianshu.io/upload_images/3985563-63737a2d81713a47.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

下面程序简单示范了通过Iterator对象逐个获取元素的逻辑。
```java
public class IteratorExample {
	public static void main(String[] args){
		//创建集合，添加元素  
		Collection<Day> days = new ArrayList<Day>();
		for(int i =0;i<10;i++){
			Day day = new Day(i,i*60,i*3600);
			days.add(day);
		}
		//获取days集合的迭代器
		Iterator<Day> iterator = days.iterator();
		while(iterator.hasNext()){//判断是否有下一个元素
			Day next = iterator.next();//取出该元素
			//逐个遍历，取得元素后进行后续操作
			.....
		}
	}

}
```
**注意：** 当使用Iterator对集合元素进行迭代时，把集合元素的值传给了迭代变量（就如同参数传递是值传递，基本数据类型传递的是值，引用类型传递的仅仅是对象的**引用变量**。
下面的程序演示了这一点：
```java
public class IteratorExample {
  public static void main(String[] args) {
            List<MyObject> list = new ArrayList<>();
            for (int i = 0; i < 10; i++) {
                list.add(new MyObject(i));
            }

            System.out.println(list.toString());

            Iterator<MyObject> iterator = list.iterator();//集合元素的值传给了迭代变量，仅仅传递了对象引用。保存的仅仅是指向对象内存空间的地址
            while (iterator.hasNext()) {
                MyObject next = iterator.next();
                next.num = 99;
            }

            System.out.println(list.toString());
    }
    static class MyObject {
        int num;

        MyObject(int num) {
            this.num = num;
        }

        @Override
        public String toString() {
            return String.valueOf(num);
        }
    }
}
```
输出结果如下：
>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
>
>[99, 99, 99, 99, 99, 99, 99, 99, 99, 99]

下面具体介绍Collection接口的三个子接口Set，List，Queue。
### 2.Set集合
#### 简介

Set集合与Collection集合基本相同，没有提供任何额外的方法。实际上Set就是Collection，只是行为略有不同（Set不允许包含重复元素）。

Set集合不允许包含相同的元素，如果试图把两个相同的元素加入同一个Set集合中，则添加操作失败，add()方法返回false，且新元素不会被加入。
### 3.List集合
#### 3.1.简介
List集合代表一个元素有序、可重复的集合，集合中每个元素都有其对应的顺序索引。List集合允许使用重复元素，可以通过索引来访问指定位置的集合元素 。List集合默认按元素的添加顺序设置元素的索引，例如第一个添加的元素索引为0，第二个添加的元素索引为1......

List作为Collection接口的子接口，可以使用Collection接口里的全部方法。而且由于List是有序集合，因此List集合里增加了一些根据索引来操作集合元素的方法。

#### 3.2.接口中定义的方法
> **void add(int index, Object element):** 在列表的指定位置插入指定元素（可选操作）。
>
> **boolean addAll(int index, Collection<? extends E> c) :** 将集合c 中的所有元素都插入到列表中的指定位置index处。
>
> **Object get(index):** 返回列表中指定位置的元素。
>
> **int indexOf(Object o):** 返回此列表中第一次出现的指定元素的索引；如果此列表不包含该元素，则返回 -1。
>
> **int lastIndexOf(Object o):** 返回此列表中最后出现的指定元素的索引；如果列表不包含此元素，则返回 -1。
>
> **Object remove(int index):** 移除列表中指定位置的元素。
>
> **Object set(int index, Object element):** 用指定元素替换列表中指定位置的元素。
>
> **List subList(int fromIndex, int toIndex):** 返回列表中指定的 fromIndex（包括 ）和 toIndex（不包括）之间的所有集合元素组成的子集。
>
> **Object[] toArray():** 返回按适当顺序包含列表中的所有元素的数组（从第一个元素到最后一个元素）。

除此之外，Java 8还为List接口添加了如下两个默认方法。
> **void replaceAll(UnaryOperator operator):** 根据operator指定的计算规则重新设置List集合的所有元素。
>
> **void sort(Comparator c):** 根据Comparator参数对List集合的元素排序。

### 4.Queue集合
#### 4.1.简介
Queue用户模拟队列这种数据结构，队列通常是指“先进先出”(FIFO，first-in-first-out)的容器。队列的头部是在队列中存放时间最长的元素，队列的尾部是保存在队列中存放时间最短的元素。新元素插入（offer）到队列的尾部，访问元素（poll）操作会返回队列头部的元素。通常，队列不允许随机访问队列中的元素。
#### 4.2.接口中定义的方法

![](http://upload-images.jianshu.io/upload_images/3985563-0505554930ca982e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
## 三、Map集合
### 1.简介
Map用户保存具有映射关系的数据，因此Map集合里保存着两组数，一组值用户保存Map里的key,另一组值用户保存Map里的value，key和value都可以是任何引用类型的数据。Map的key不允许重复，即同一个Map对象的任何两个key通过equals方法比较总是返回false。

如下图所描述，key和value之间存在单向一对一关系，即通过指定的key,总能找到唯一的、确定的value。从Map中取出数据时，只要给出指定的key，就可以取出对应的value。

![](http://upload-images.jianshu.io/upload_images/3985563-51f6c5278df941fe.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 2.Map集合与Set集合、List集合的关系
**①.与Set集合的关系**

如果 把Map里的所有key放在一起看，它们就组成了一个Set集合（所有的key没有顺序，key与key之间不能重复），实际上Map确实包含了一个keySet()方法，用户返回Map里所有key组成的Set集合。

**②.与List集合的关系**

如果把Map里的所有value放在一起来看，它们又非常类似于一个List：元素与元素之间可以重复，每个元素可以根据索引来查找，只是Map中索引不再使用整数值，而是以另外一个对象作为索引。
### 3.接口中定义的方法
![](http://upload-images.jianshu.io/upload_images/3985563-d2494516e1d68a6d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

Map中还包括一个内部类Entry，该类封装了一个key-value对。Entry包含如下三个方法：

![](http://upload-images.jianshu.io/upload_images/3985563-ecedd1880af9d40a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

Map集合最典型的用法就是成对地添加、删除key-value对，然后就是判断该Map中是否包含指定key，是否包含指定value，也可以通过Map提供的keySet()方法获取所有key组成的集合，然后使用foreach循环来遍历Map的所有key，根据key即可遍历所有的value。下面程序代码示范Map的一些基本功能：

```java
public class MapTest {
	public static void main(String[] args){
		Day day1 = new Day(1, 2, 3);
		Day day2 = new Day(2, 3, 4);
		Map<String,Day> map = new HashMap<String,Day>();
		//成对放入key-value对
		map.put("第一个", day1);
		map.put("第二个", day2);
		//判断是否包含指定的key
		System.out.println(map.containsKey("第一个"));
		//判断是否包含指定的value
		System.out.println(map.containsValue(day1));
		//循环遍历
		//1.获得Map中所有key组成的set集合
		Set<String> keySet = map.keySet();
		//2.使用foreach进行遍历
		for (String key : keySet) {
			//根据key获得指定的value
			System.out.println(map.get(key));
		}
		//根据key来移除key-value对
		map.remove("第一个");
		System.out.println(map);
	}

}
```
输出结果：
>true
>
>true
>
>Day [hour=2, minute=3, second=4]
>
>Day [hour=1, minute=2, second=3]
>
>{第二个=Day [hour=2, minute=3, second=4]}

四、e.g.

```
 数组:
 	优点：使用方便 ，查询效率 比链表高，内存为一连续的区域 
 	缺点：大小固定，不适合动态存储，不方便动态添加
 链表：
 	 优点：可动态添加删除   大小可变 
 	 缺点：只能通过顺次指针访问，查询效率低 	 
```

1. #### ArrayList:

   > 以数组实现。节约空间，但数组有容量限制。超出限制时会增加50%容量，用System.arraycopy\(\)复制到新的数组，因此最好能给出数组大小的预估值。默认第一次插入元素时创建大小为10的数组。
   >
   > 按数组下标访问元素—get\(i\)/set\(i,e\) 的性能很高，这是数组的基本优势。
   >
   > 直接在数组末尾加入元素—add\(e\)的性能也高，但如果按下标插入、删除元素—add\(i,e\), remove\(i\), remove\(e\)，则要用System.arraycopy\(\)来移动部分受影响的元素，性能就变差了，这是基本劣势。

   - ArrayList是一个相对来说比较简单的数据结构，最重要的一点就是它的**自动扩容**，可以认为就是我们常说的“动态数组”。

2. #### LinkedList:

   > 以双向链表实现。链表无容量限制，但双向链表本身使用了更多空间，也需要额外的链表指针操作。
   >
   > 按下标访问元素—get\(i\)/set\(i,e\) 要悲剧的遍历链表将指针移动到位\(如果i&gt;数组大小的一半，会从末尾移起\)。
   >
   > 插入、删除元素时修改前后节点的指针即可，但还是要遍历部分链表的指针才能移动到下标所指的位置，只有在链表两头的操作—add\(\)，addFirst\(\)，removeLast\(\)或用iterator\(\)上的remove\(\)能省掉指针的移动。

   - LinkedList是一个简单的数据结构，与ArrayList不同的是，他是基于链表实现的。
   - set和get函数都调用了`node`函数，该函数会以O\(n/2\)的性能去获取一个节点。
   - 判断index是在前半区间还是后半区间，如果在前半区间就从head搜索，而在后半区间就从tail搜索。而不是一直从头到尾的搜索。如此设计，将节点访问的复杂度由O\(n\)变为O\(n/2\)。

3. #### HashMap:

   **1. 什么时候会使用HashMap？他有什么特点？**  
   是基于Map接口的实现，存储键值对时，它可以接收null的键值，是非同步的，不保证**有序**\(比如插入的顺序\)、也不保证序不随时间变。HashMap存储着**Entry\(hash, key, value, next\)对象**。

   **2. 你知道HashMap的工作原理吗？**  
   通过hash的方法，通过put和get存储和获取对象。存储对象时，我们将K/V传给put方法时，它调用hashCode计算hash从而得到bucket位置，进一步存储，HashMap会根据当前bucket的占用情况自动调整容量\(超过`Load Facotr`则resize为原来的2倍\)。获取对象时，我们将K传给get，它调用hashCode计算hash从而得到bucket位置，并进一步调用equals\(\)方法确定键值对。如果发生碰撞的时候，Hashmap通过链表将产生碰撞冲突的元素组织起来，在Java 8中，如果一个bucket中碰撞冲突的元素超过某个限制\(默认是8\)，则使用红黑树来替换链表，从而提高速度。

   **3. 你知道get和put的原理吗？equals\(\)和hashCode\(\)的都有什么作用？**  
   通过对key的hashCode\(\)进行hashing，并计算下标\( `(n-1) & hash`\)，从而获得buckets的位置。如果产生碰撞，则利用key.equals\(\)方法去链表或树中去查找对应的节点。

   **4. 你知道hash的实现吗？为什么要这样实现？**  
   在Java 1.8的实现中，是通过hashCode\(\)的高16位异或低16位实现的：`(h = k.hashCode()) ^ (h >>> 16)`，主要是从速度、功效、质量来考虑的，这么做可以在bucket的n比较小的时候，也能保证考虑到高低bit都参与到hash的计算中，同时不会有太大的开销。

   **5. 如果HashMap的大小超过了负载因子\(`load factor`\)定义的容量，怎么办？**  
   如果超过了负载因子\(默认**0.75**\)，则会重新resize一个原来长度两倍的HashMap，并且重新调用hash方法。

4. #### TreeMap:

   - HashMap不保证数据有序，LinkedHashMap保证数据可以保持**插入顺序**，而如果我们希望Map可以**保持key的大小顺序**的时候，我们就需要利用TreeMap了。

5. #### LinkedHashMap:

   - LinkedHashMap是Hash表和链表的实现，并且依靠着双向链表保证了**迭代顺序**是**插入的顺序**。
   - **保证双向链表中的节点次序或者双向链表容量所**
   - 总之，LinkedHashMap不愧是HashMap的儿子，和老子太像了，当然，青出于蓝而胜于蓝，LinkedHashMap的其他的操作也基本上都是为了维护好那个具有访问顺序的双向链表。

6. #### ArrayMap:

   - ArrayMap的存储中没有Entry这个东西，他是由两个数组来维护的，mHashes数组中保存的是每一项的HashCode值，mArray中就是键值对，每两个元素代表一个键值对，前面保存key，后面的保存value。

   > HashMap内部有一个HashMapEntry[]对象，每一个键值对都存储在这个对象里，当使用put方法添加键值对时，就会new一个HashMapEntry对象，而ArrayMap的存储中没有Entry这个东西，他是由两个数组来维护的，mHashes数组中保存的是每一项的HashCode值，mArray中就是键值对，每两个元素代表一个键值对，前面保存key，后面的保存value。

   > ArrayMap 和 HashMap区别：
   >
   > 1. 存储方式不同：
   >    - HashMap内部有一个HashMapEntry[]对象，每一个键值对都存储在这个对象里，当使用put方法添加键值对时，就会new一个HashMapEntry对象。
   >    - ArrayMap的存储中没有Entry这个东西，他是由两个数组来维护的
   >      mHashes数组中保存的是每一项的HashCode值，
   >      mArray中就是键值对，每两个元素代表一个键值对，前面保存key，后面的保存value。
   > 2. 添加数据时扩容时的处理不一样：
   >    - HashMap使用New的方式申请空间，并返回一个新的对象，开销会比较大。
   >    - ArrayMap用的是System.arrayCopy数据，所以效率相对要高。
   > 3. ArrayMap提供了数组收缩的功能，只要判断过判断容量尺寸，例如clear，put，remove等方法，只要通过判断size大小触发到freeArrays或者allocArrays方法，会重新收缩数组，释放空间。
   > 4. ArrayMap相比传统的HashMap速度要慢，因为查找方法是二分法，并且当你删除或者添加数据时，会对空间重新调整，在使用大量数据时，效率低于50%。可以说ArrayMap是牺牲了**时间换区空间**。但在写手机app时，适时的使用ArrayMap，会给内存使用带来可观的提升。ArrayMap内部还是按照**正序排列**的，这时因为ArrayMap在检索数据的时候使用的是二分查找，所以每次插入新数据的时候ArrayMap都需要重新排序，逆序是最差情况；
