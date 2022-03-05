title:  Java注解
date: 2018年2月17日22:30:51
categories: Java
tags: 

	 - Java基础
	 - Java注解
cover_picture: /images/JavaAnnotaion.jpg
---
### 元数据

> https://gitee.com/pianzhi110/Fragmentation/tree/master/app/src/main/java/com/gusi/fragmentation/annotation

要想理解注解（Annotation）的作用，就要先理解Java中元数据的概念。

##### 1.元数据概念

元数据是关于数据的数据。在编程语言上下文中，元数据是添加到程序元素如方法、字段、类和包上的额外信息。**对数据进行说明描述的数据**。

##### 2.元数据的作用

一般来说，元数据可以用于创建文档（根据程序元素上的注释创建文档），跟踪代码中的依赖性（可声明方法是重载，依赖父类的方法），执行编译时检查（可声明是否编译期检测），代码分析。  
如下：  
1） 编写文档：通过代码里标识的元数据生成文档　　  
2）代码分析：通过代码里标识的元数据对代码进行分析　　  
3）编译检查：通过代码里标识的元数据让编译器能实现基本的编译检查

##### 3.Java平台元数据

注解Annotation就是java平台的元数据，是 J2SE5.0新增加的功能，该机制允许在Java 代码中添加自定义注释，并允许通过反射（reflection），以编程方式访问元数据注释。通过提供为程序元素（类、方法等）附加额外数据的标准方法，元数据功能具有简化和改进许多应用程序开发领域的潜在能力，其中包括配置管理、框架实现和代码生成。

### 注解（Annotation）

##### 1.注解（Annotation）的概念

注解\(Annotation\)在JDK1.5之后增加的一个新特性，注解的引入意义很大，有很多非常有名的框架，比如Hibernate、Spring等框架中都大量使用注解。注解作为程序的元数据嵌入到程序。注解可以被解析工具或编译工具解析。

关于注解（Annotation）的作用，其实就是上述元数据的作用。

**注意：Annotation能被用来为程序元素（类、方法、成员变量等）设置元素据。Annotaion不影响程序代码的执行，无论增加、删除Annotation，代码都始终如一地执行。如果希望让程序中的Annotation起一定的作用，只有通过解析工具或编译工具对Annotation中的信息进行解析和处理。**

##### 2.内建注解

Java提供了多种内建的注解，下面接下几个比较常用的注解：@Override、@Deprecated、@SuppressWarnings以及@FunctionalInterface这4个注解。内建注解主要实现了元数据的第二个作用：**编译检查**。

**@Override**  
用途：用于告知编译器，我们需要覆写超类的当前方法。如果某个方法带有该注解但并没有覆写超类相应的方法，则编译器会生成一条错误信息。如果父类没有这个要覆写的方法，则编译器也会生成一条错误信息。

@Override可适用元素为方法，仅仅保留在java源文件中。

**@Deprecated**  
用途：使用这个注解，用于告知编译器，某一程序元素\(比如方法，成员变量\)不建议使用了（即过时了）。  

**@SuppressWarnings**  
用途：用于告知编译器忽略特定的警告信息，例在泛型中使用原生数据类型，编译器会发出警告，当使用该注解后，则不会发出警告。

注解类型分析： `@SuppressWarnings`可适合用于除注解类型声明和包名之外的所有元素，仅仅保留在java源文件中。

该注解有方法value\(）,可支持多个字符串参数，用户指定忽略哪种警告。

![](http://upload-images.jianshu.io/upload_images/3985563-24e39cdaf0d62c75.png?imageMogr2/auto-orient/strip|imageView2/2/w/1240)

#### 3.元Annotation

JDK除了在java.lang提供了上述内建注解外，还在java.lang。annotation包下提供了**6**个Meta Annotation\(元Annotataion\)，其中有5个元Annotation都用于修饰其他的Annotation定义。其中@Repeatable专门用户定义Java 8 新增的可重复注解。

我们先介绍其中4个常用的修饰其他Annotation的元Annotation。在此之前，我们先了解如何自定义Annotation。

**当一个接口直接继承java.lang.annotation.Annotation接口时，仍是接口，而并非注解。要想自定义注解类型，只能通过@interface关键字的方式，其实通过该方式会隐含地继承.Annotation接口。**

**@Documented**

`@Documented`用户指定被该元Annotation修饰的Annotation类将会被javadoc工具提取成文档，如果定义Annotation类时使用了`@Documented`修饰，则所有使用该Annotation修饰的程序元素的API文档中将会包含该Annotation说明。

**@Inherited(世袭)**

默认情况下,我们自定义的注解用在父类上不会被子类所继承.如果想让子类也继承父类的注解,即注解在子类也生效,需要在自定义注解时设置@Inherited.一般情况下该注解用的比较少.

**@Retention**

`@Retention`：表示该注解类型的注解保留的时长。当注解类型声明中没有`@Retention`元注解，则默认保留策略为RetentionPolicy.CLASS。关于保留策略\(RetentionPolicy\)是枚举类型，共定义3种保留策略，如下表：  
![](http://upload-images.jianshu.io/upload_images/3985563-828fe68fcdf834b4.png?imageMogr2/auto-orient/strip|imageView2/2/w/1240)

**@Target**

`@Target`：表示该注解类型的所适用的程序元素类型。当注解类型声明中没有`@Target`元注解，则默认为可适用所有的程序元素。如果存在指定的`@Target`元注解，则编译器强制实施相应的使用限制。关于程序元素\(ElementType\)是枚举类型，共定义8种程序元素，如下表：  
![](http://upload-images.jianshu.io/upload_images/3985563-7b457df2143fa5dd.png?imageMogr2/auto-orient/strip|imageView2/2/w/1240)

### 自定义注解（Annotation）

创建自定义注解，与创建接口有几分相似，但注解需要以@开头。

> - 其定义是以无形参的方法形式来声明的。
> - 此处只能使用public或者默认的default两个权限修饰符。
> - 配置参数的类型只能使用基本类型(byte,boolean,char,short,int,long,float,double)和String,Enum,Class,annotation。
> - 配置参数一旦设置,其参数值必须有确定的值,要不在使用注解的时候指定,要不在定义注解的时候使用default为其设置默认值,对于非基本类型的参数值来说,其不能为null。

**当然注解中也可以不存在成员变量，在使用解析注解进行操作时，仅以是否包含该注解来进行操作。当注解中有成员变量时，若没有默认值，需要在使用注解时，指定成员变量的值。**

### 注解解析

接下来，通过反射技术来解析自定义注解。关于反射类位于包java.lang.reflect，其中有一个接口AnnotatedElement，该接口主要有如下几个实现类：Class，Constructor，Field，Method，Package。除此之外，该接口定义了注释相关的几个核心方法，如下：  
![](http://upload-images.jianshu.io/upload_images/3985563-4077bbaef5b27a4b.png?imageMogr2/auto-orient/strip|imageView2/2/w/1240)  
因此，当获取了某个类的Class对象，然后获取其Field,Method等对象，通过上述4个方法提取其中的注解，然后获得注解的详细信息。

### 注解的应用

#### 运行时注解

Java反射获取变量或调用方法。

> ```java
>  //view控件
>   public static void initViews(Object object, View sourceView) {
>     //获取该类声明的成员变量
>     Field[] fields = object.getClass().getDeclaredFields();
>     for (Field field : fields) {
>       //获取该成员变量上使用的ViewInject注解
>       ViewInject viewInject = field.getAnnotation(ViewInject.class);
>       if (viewInject != null) {
>         int viewId = viewInject.id();//获取id参数值
>         boolean clickable = viewInject.clickable();//获取clickable参数值
>         if (viewId != -1) {
>           try {
>             field.setAccessible(true);
>             //赋值
>             field.set(object, sourceView.findViewById(viewId));
>             if (clickable == true) {
>               //click
>               sourceView.findViewById(viewId).setOnClickListener((View.OnClickListener) (object));
>             }
>           } catch (Exception e) {
>           }
>         }
>       }
>     }
>   }
> ```
>
> ```java
> //布局资源
> public static void initLayout(Activity activity) {
>   Class<? extends Activity> activityClass = activity.getClass();
>   ContentView contentView = activityClass.getAnnotation(ContentView.class);
>   if (contentView != null) {
>     int layoutId = contentView.value();
>     try {
>       //反射执行setContentView（）方法
>       Method method = activityClass.getMethod("setContentView", int.class);
>       method.invoke(activity, layoutId);
>     } catch (Exception e) {
>       e.printStackTrace();
>     }
>   }
> }
> ```

#### 编译时期注解(APT)

- Annotation Processing Tool 是一种处理在注视的工具，对源代码文件编译时期找出其中的Annotation，进行额外的处理（编译时期生成文件）。

- 组成要素

  1. 注解处理器(AbstractProcess)

     > ```java
     > public class BindViewProcessor extends AbstractProcessor {}
     > ```

  2. 代码处理(JavaPoet)

     > ```java
     > /**
     >  * scan
     >  * process annotation
     >  * mk file
     >  *
     >  * @param set
     >  * @param roundEnvironment
     >  * @return
     >  */
     > @Override
     > public boolean process(Set<? extends TypeElement> set, RoundEnvironment roundEnvironment) {
     >     mMessager.printMessage(Diagnostic.Kind.NOTE, "processing..");
     >     mProxyMap.clear();
     >     //get all BindView annotation
     >     Set<? extends Element> viewElements = roundEnvironment.getElementsAnnotatedWith(BindView.class);
     >     for (Element element : viewElements) {
     >         VariableElement variableElement = (VariableElement) element;
     >         TypeElement classElement = (TypeElement) variableElement.getEnclosingElement();
     >         String fullClassName = classElement.getQualifiedName().toString();
     >         ClassCreatorProxy proxy = mProxyMap.get(fullClassName);
     >         if (proxy == null) {
     >             proxy = new ClassCreatorProxy(mElementUtils, classElement);
     >             mProxyMap.put(fullClassName, proxy);
     >         }
     >         BindView bindAnnotation = variableElement.getAnnotation(BindView.class);
     >         int id = bindAnnotation.value();
     >         proxy.putElement(id, variableElement);
     >     }
     >     
     >     //通过遍历mProxyMap，创建java文件
     >     //通过StringBuilder生成
     >     /*for (String key : mProxyMap.keySet()) {
     >         ClassCreatorProxy proxyInfo = mProxyMap.get(key);
     >         try {
     >             JavaFileObject jfo = processingEnv.getFiler().createSourceFile(proxyInfo.getProxyClassFullName(), proxyInfo.getTypeElement());
     >             Writer writer = jfo.openWriter();
     >             writer.write(proxyInfo.generateJavaCode());
     >             writer.flush();
     >             writer.close();
     >             mMessager.printMessage(Diagnostic.Kind.NOTE, " --> create " + proxyInfo.getProxyClassFullName() + "success");
     >         } catch (IOException e) {
     >             mMessager.printMessage(Diagnostic.Kind.NOTE, " --> create " + proxyInfo.getProxyClassFullName() + "error");
     >         }
     >     }*/
     >     //通过javapoet生成
     >     for (String key : mProxyMap.keySet()) {
     >         ClassCreatorProxy proxyInfo = mProxyMap.get(key);
     >         JavaFile javaFile = JavaFile.builder(proxyInfo.getPackageName(), proxyInfo.generateJavaCode2()).build();
     >         try {
     >             //生成文件
     >             javaFile.writeTo(processingEnv.getFiler());
     >         } catch (IOException e) {
     >             e.printStackTrace();
     >         }
     >     }
     >     mMessager.printMessage(Diagnostic.Kind.NOTE, "process finish ...");
     >     return false;
     > }
     > ```

  3. 处理器注册(AutoService + apt)

     > ```java
     > //自动生成
     > implementation 'com.google.auto.service:auto-service:1.0-rc2'
     > 
     > @AutoService(Processor.class)
     > public class BindViewProcessor extends AbstractProcessor {}
     > 
     > ```

- 流程

  - 自定义注解(apt-annotation)

  - 自定义注解处理器(apt-processor)

  - 处理器里面完成处理，生成文件(apt-library)

  - 反射调用

    > ```java
    > public static void bind(Activity activity) {
    >     Class clazz = activity.getClass();
    >     try {
    >         Class bindViewClass = Class.forName(clazz.getName() + "_ViewBinding");
    >         Method method = bindViewClass.getMethod("bind", activity.getClass());
    >         method.invoke(bindViewClass.newInstance(), activity);
    >     } catch (Exception e) {
    >     }
    > }
    > ```

    

