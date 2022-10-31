
# 1 入门案例 HookDemo

- [参考地址](https://www.jianshu.com/p/fdece2fbff1c)

## 1.1 创建安卓工程

- 首先创建一个安卓工程，一般来说，对于 Xposed 模块只需要拦截别人，不需要主界面，因此通常 Xposed 模块是一个 No Activiry 类型的项目
- 但在本例中，为了方便测试，我们的案例是进行 Hook 自己，因此我们需要一个 Activity，故我们创建 Empty Activity 类型的项目
- 项目名称为：`HookDemo`，项目包名为：`com.example.hook`，API 级别为 21，即安卓 5.0 +

## 1.2 配置 gradle 代理以及引入 xposed 依赖

- xposed 的依赖包托管在 jcenter 中，而国内访问国外仓库速度很慢，因此我们需要配置代理，将 gradle 下载 lib 的源设置为阿里的源
- 为了方便，统一设置常用源的代理，包括 google, maven 等，配置内容大致如下
```js
repositories {
    maven { url 'https://maven.aliyun.com/repository/central' }
    maven { url 'https://maven.aliyun.com/repository/google' }
    maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
    maven { url 'https://maven.aliyun.com/repository/jcenter' }
    maven { url 'https://maven.aliyun.com/repository/public' }
    mavenLocal()

    google()
    mavenCentral()
}
```
- 对于 gradle，好像需要同时在两个地方配置源，一个是 buildscript 内部，一个是 all_projects 内部，但对于我的 7.0.2 版本的 gradle 没有找到 all_projects 块，通过搜索好像是配置移到了 setting.gradle 内部，由于个人对 gradle 和安卓都不是很熟悉，因此不知道本质上是谁发生的变动，反正最终的结果是：分别在 项目根目录下的 build.gradle 和 settings.gradle 两个文件的 repositories 块内配置上述内容
- 项目根目录下的 build.gradle 的配置看起来如下：
```js
buildscript {
    repositories {

        maven { url 'https://maven.aliyun.com/repository/central' }
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
        maven { url 'https://maven.aliyun.com/repository/jcenter' }
        maven { url 'https://maven.aliyun.com/repository/public' }
        mavenLocal()

        google()
        mavenCentral()
    }
    dependencies {
        classpath "com.android.tools.build:gradle:7.0.0"

        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
```
- 项目根目录下的 settings.gradle 的配置看起来如下：
```js
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {

        maven { url 'https://maven.aliyun.com/repository/central' }
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
        maven { url 'https://maven.aliyun.com/repository/jcenter' }
        maven { url 'https://maven.aliyun.com/repository/public' }
        mavenLocal()

        google()
        jcenter() // Warning: this repository is going to shut down soon
    }
}
rootProject.name = "HookDemo"
include ':app'
```
- 配置好源后，我们引入 xposed 依赖，引入依赖的配置在 app 模块的 build.gradle 文件中，在 dependencies 中引入 xposed 的依赖
```js
dependencies {
    compileOnly 'de.robv.android.xposed:api:82'
    compileOnly 'de.robv.android.xposed:api:82:sources'
}
```
- 特别注意，引入依赖的配置要写在 app 模块的 build.gradle 中而不能写在顶层 build.gradle 文件中，最开始由于对 gradle 不熟悉，又没仔细看官方文档，加上网上一些文章老配置方式的误导，我直接把 dependencies 配置在顶层 build 文件中，结果导致 hello world 随便引个 junit 都跑不起来 helloworld
- 此外，如果对安卓不熟悉，对于 app 模块默认的依赖则尽量不要去动，app 模块的 build.gradle 的 dependencies 块的配置如下：
```js
dependencies {
    implementation 'androidx.appcompat:appcompat:1.4.1'
    implementation 'com.google.android.material:material:1.5.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.3'
    testImplementation 'junit:junit:4.+'
    androidTestImplementation 'androidx.test.ext:junit:1.1.3'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.4.0'
    // 引入 xposed 相关 lib
    compileOnly 'de.robv.android.xposed:api:82'
    compileOnly 'de.robv.android.xposed:api:82:sources'
}
```
- 上面的后两行配置即为引入 xposed 相关的依赖，注意引入方式为 compileOnly，如果是旧版的 gradle 配置可能为 provided，但 provided 已经过时，用 compileOnly 引入（类似 maven 中的 provided scope）
- 自此，相关源和依赖都配置成功


## 1.3 准备被 Hook 的程序：编写 MainActivity

- 通常来说，对于一个简单不需要界面的模块来说，不需要这一步，但在这个例子中，我们要做的是自己 Hook 自己，因此需要编写一个界面
- 举例来说，假如我们需要编写一个模块来 Hook QQ 中的某个类，实际上我们只需要编写后面的模块类即可，而此处的 MainActivity 就对应着 QQ 中的那个类
- 由于我们选择的是 EmptyActivity，编译器自动创建并注册该 Activity，我们只需对该界面添加一个按钮，并单击按钮弹出一个提示，为了方便讲解 Hook，我们可以让该提示信息由一个函数返回，代码如下：
```java
public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // 获取按钮
        Button button = findViewById(R.id.button);

        // 设置按钮单击事件的回调
        button.setOnClickListener(view -> {
            // 单击时使用 Toast 弹出提示，提示内容由 toastMessage() 函数决定
            Toast.makeText(MainActivity.this, toastMessage(), Toast.LENGTH_SHORT).show();
        });
    }

    // 返回一个单击按钮后用于展示的提示信息
    private String toastMessage() {
        return "单击按钮成功";
    }

}
```
- activity_main.xml 文件内添加一个按钮：
```xml
<Button
    android:id="@+id/button"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="Button"
    app:layout_constraintEnd_toEndOf="parent"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toTopOf="parent" />
```
- 编写完毕，先运行一下该应用，确保应用正常，文本展示从 1 开始，每次单击增加一次


## 1.4 编写模块配置以及 Hook 代码

- 被 Hook 的 Activity 准备完毕后，我们即可开始编写 Hook 代码了
- 首先，我们需要告诉 Xposed 该项目不仅仅是一个普通的 apk，而同样是一个 xposed 模块，故我们需要在文件清单 AndroidManifest.xml 中添加和 xposed 相关的元数据配置，文件清单的完整配置内容如下，其中重点关注和 xposed 相关的三个 meta-data 元素的配置：
```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.hook">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.HookDemo">

        <!--xposedmodule 配置用于告诉 Xposed 这是一个 Xposed 模块-->
        <meta-data
            android:name="xposedmodule"
            android:value="true" />

        <!--xposeddescription 用于配置模块的简短描述，会在 Xposed 模块列表中展示-->
        <meta-data
            android:name="xposeddescription"
            android:value="这是一个 Xposed 模块示例，它会自己拦截自己的 toastMessage 方法并返回固定的内容" />

        <!--xposedminversion 用于运行该模块所需的最低 Xposed 版本-->
        <!--按我的理解这个版本应该和依赖的版本一致才对，不知道为什么不设置成一致的，理解不够，可能是尽量向前兼容但不保证百分比兼容吧-->
        <meta-data
            android:name="xposedminversion"
            android:value="53" />


        <!--这是 IDE 自动生成的 Activity 的配置-->
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />

                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
```
- 之后，我们编写一个 HookEntry 类作为模块的入口点，该类需要实现 IXposedHookLoadPackage 接口，Xposed 通过该接口调用进入对模块的调用，在该模块中，我们要做的就是拦截 MainActivity 的 toastMessage() 方法，并直接设置返回值为我们想展示的值，详细的代码如下：
```java
public class HookEntry implements IXposedHookLoadPackage {

    private static final String LOG_TAG = "hook";

    @Override
    public void handleLoadPackage(XC_LoadPackage.LoadPackageParam lpparam) throws Throwable {

        // 我们要拦截的就是 com.example.hook.MainActivity
        if (!lpparam.packageName.equals("com.example.hook")) {
            return;
        }

        Log.d(LOG_TAG, "拦截到包 com.example.hook");

        // 使用 XposedHelpers 提供的 findAndHookMethod(完整类名, 类加载器, 方法名, 方法参数列表, XC_MethodHook 拦截接口) 方法找到 toastMessage 方法并添加拦截逻辑
        XposedHelpers.findAndHookMethod("com.example.hook.MainActivity", lpparam.classLoader, "toastMessage", new XC_MethodHook() {

            // 该拦截接口类似 aop 编程拦截逻辑，
            // 采用该接口后，方法的执行顺序为：beforeHookedMethod --> 目标方法 --> afterHookedMethod

            // beforeHookedMethod 在目标方法执行之前执行，一般用于对入参的修改，添加前置逻辑等
            // 若是在 beforeHookedMethod 内直接设置返回值将导致后续方法不往后执行，直接返回对应值
            @Override
            protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
                Log.d(LOG_TAG, "拦截到方法 toastMessage, 即将继续往后执行");
            }

            // beforeHookedMethod 在目标方法执行之后执行，一般用于对返回值的修改或添加后置逻辑等
            @Override
            protected void afterHookedMethod(MethodHookParam param) throws Throwable {
                // 我们直接添加后置逻辑，拿到原方法的返回值并打印日志
                Log.d(LOG_TAG, String.format("toastMessage 原方法返回值为 %s", param.getResult()));
                // 修改返回值，使其永远返回固定字符串，从而导致单击按钮后永远展示该字符串
                param.setResult("单击按钮 10086 次");
            }
        });
    }
}
```
- 现在我们已经编写完毕这个模块的入口类，但是 Xposed 框架并不知道如何找到这个入口，因此我们需要告诉 Xposed 入口在哪，我们在 src/main 下创建 assets 目录，在 assets 目录下创建 xposed_init 文件，并将入口类 HookEntry 的完整路径写到该文件中，在该示例中，xposed_init 的内容如下：
```java
com.example.hook.HookEntry
```
- 自此，我们模块编写完毕，编译并安装到安卓机器上，勾选模块，重启系统，打开 HookDemo 应用，单击按钮，查看弹出的提示信息是否已经被 Hook，同时每单击按钮一次，在 logcat 查看打印的日志，确定原有的结果仍然逐次递增


## 1.5 Demo 总结

- 首先，我们创建了一个工程，配置 gradle 镜像源为阿里源，并引入开发 xposed 模块所需的依赖
- 之后，我们编写一个 MainActivity 用于指代被 Hook 的软件
- 拥有了用于被 Hook 的软件后，我们继续编写 Hook 逻辑，拦截软件中目标类的目标方法，以达到我们想达到的目的
- 在上述步骤中，第三步的如何找到目标方法并修改相关逻辑以达到我们想达到的目的往往是十分困难的，因为我们往往没法拿到 apk 的源码，从一般的商业 apk 逆向出来的代码往往也是被混淆过的，需要大量的时间阅读以理解它们的逻辑；在本例中我们如此简单是因为我们 MainActivity 的源码就是我们自己编写的，我们自己完全清楚逻辑，根本不需要逆向这一步骤

## 1.6 Xposed 运行逻辑

- 通过前面的学习，我们知道 Xposed 的运行逻辑大致如下：
- XposedFramework（即 Xposed 框架）加载 app 的 AndroidManifest.xml，检查 xposed 相关的三个 meta-data，若是 XposedModule（Xposed 模块）则继续往下执行
- XposedFramework 找到 assets/xposed_init 文件中的类，该类必须实现 XposedFramework 提供的开放接口中的一个，并基于接口调用目标类的方法，最常用的就是 IXposedHookLoadPackage 接口的 `handleLoadPackage(XC_LoadPackage.LoadPackageParam loadPackageParam)` 方法
- 进入拦截方法后，利用 Xposed 提供的 Api（XC_LoadPackage.LoadPackageParam、XposedHelpers、XposedBridge 等）, 同时结合 Java 反射技术，以获取到目标类、方法、域等，并利用 Xposed Api 添加相应逻辑，以达到不更改原有代码的情况下影响原有功能
- 从上文描述可以看出，Xposed Api 就是很明显的 aop 编程方式，我们可以使用 aop 的方式进行描述：
    - 每个进程都拥有自己的虚拟机，在每次启动 app 时都会加载 app 所在的包，从而触发 handleLoadPackage 的调用：故以前面的例子为例，HookDemo 每次启动，都会加载对应的 com.example.hook 包，我们每次启动应用，都会加载 handleLoadPackage 方法，从而每次 app 都会对 handleLoadPackage 内的所有切面执行一遍；当然其他所有 app 的启动也会触发 handleLoadPackage 的调用，但由于我们在内部只处理 com.example.hook 包，对其他包虽然进入了
    - 我们可以在内部编写多个切面（即 hook 多个方法，或者 hook 一个方法多次等）
    - 在该函数内部我们可以使用 Xposed Api 获取切点切面，并定义自己的逻辑将其织入切面，以完成对程序逻辑的影响


# 2 Xposed Api

- 为了方便测试 Xposed Api，我们专门编写一个 AppDemo 用于测试，源码见附录
- 之后我们再创建一个工程 HookDemo 用于执行本章的测试
- 为了查看 Field 对象的 json，引入了 fastjson android 版，在 app 模块的 build.gradle 添加依赖
```js
dependencies {
    // fastjson
    implementation 'com.alibaba:fastjson:1.1.72.android'
}
```

## 2.1 查找类字节码

- 使用 `XposedHelpers.findClass(String className, ClassLoader classLoader)` 查找字节码
- 通过跟踪源码发现，XposedHelpers.findClass 调用的是 commons-lang 的 ClassUtils，而其本质即为 Class.forName
- 示例代码如下：
```java
/**
 * 测试使用 XposedHelpers.findClass 加载类字节码；
 * 其调用 apache 的 ClassUtils 实现，而 ClassUtils 本质上任然是 Class.forName()
 * @param loadPackageParam loadPackageParam
 * @throws Throwable 运行异常
 */
private Class<?> testLoadClass(XC_LoadPackage.LoadPackageParam loadPackageParam) throws Throwable {
    Log.d(TAG, "测试加载类开始...");
    // 使用 XposedHelpers.findClass 加载类字节码
    Class<?> clazz = XposedHelpers.findClass("com.hao.app.Test", loadPackageParam.classLoader);
    // 使用 Class.forName 加载类字节码
    Class<?> clazz2 = Class.forName("com.hao.app.Test", false, loadPackageParam.classLoader);

    // 测试二者为同一个 Class
    Log.d(TAG, String.format("clazz = %s, clazz2 = %s", clazz.getName(), clazz2.getName()));
    Log.d(TAG, String.format("二者是否相同：%b", clazz == clazz2));
    Log.d(TAG, "测试加载类结束...");

    return clazz;
}
```

## 2.2 设置和读取静态变量


```java
/**
 * 测试使用 XposedHelpers.getStaticIntField 读取静态域
 * 测试使用 XposedHelpers.setStaticIntField 设置静态域；
 * @param clazz 目标类
 * @throws Throwable 异常
 */
private void testGetAndSetStaticField(Class<?> clazz) throws Throwable {
    Log.d(TAG, "测试读取和设置静态域开始...");
    final String fieldName = "privateStaticInt";

    // 使用 XposedHelpers.getStaticIntField 读取域
    // 通过跟踪源码其原理为：先使用 XposedHelpers.findField(Class<?> clazz, String fieldName) 查找到域，然后调用 Field 的 filed.setXxx(null) 方法设置静态值
    int privateStaticInt = XposedHelpers.getStaticIntField(clazz, fieldName);
    Log.d(TAG, String.format("读取到的 privateStaticInt 的值为 %d", privateStaticInt));

    // 使用 XposedHelpers.setStaticIntField 设置静态域
    // 通过跟踪源码其原理为：先使用 XposedHelpers.findField(Class<?> clazz, String fieldName) 查找到域，然后调用 Field 的方法 filed.setXxx(null) 设置静态值
    final int val = RANDOM.nextInt(1000);
    Log.d(TAG, "准备将 privateStaticInt 设置为 " + val);
    XposedHelpers.setStaticIntField(clazz, fieldName, val);

    // 设置值后重新读取 privateStaticInt 检验
    int newPrivateStaticInt = XposedHelpers.getStaticIntField(clazz, fieldName);
    Log.d(TAG, String.format("设置新值后， privateStaticInt 的值为 %d", newPrivateStaticInt));


    // 对于 XposedHelpers.findField(Class<?> clazz, String fieldName)，其对 filed 做了缓存，
    // 若缓存未命中，则调用方法 XposedHelpers.findFieldRecursiveImpl(Class<?> clazz, String fieldName) 逐级递归往上查找声明域，
    // findFieldRecursiveImpl 内部包含一个 while 循环，其使用 Java 反射技术，基于单根继承结构，会逐级往上查找声明域
    // 也就是说子类找不到域，会继续去父类里面找，直到找到对应的域（getDeclaredField 找到的域不一定是静态的，若找到非静态的域在读取/设置值时由于传入 null 会导致空指针）
    Field field = XposedHelpers.findField(clazz, fieldName);
    Field fieldReflect = clazz.getDeclaredField(fieldName); // 由于该域就在传进来的这个类，无需往上递归，直接使用 getDeclaredField 就能查出 staticInt 域

    // 验证二者为同一个 Field
    Log.d(TAG, String.format("field = %s, fieldReflect = %s", field.getName(), fieldReflect.getName()));
    Log.d(TAG, String.format("field hashCode = %d, fieldReflect hashCode = %d", field.hashCode(), fieldReflect.hashCode()));
    // 判断两个 Field == 结果恒为 false，这是 Java 反射天然导致的 false，害我 debug 了好久！！！
    // 经测试，对任意的 Class，clazz.getDeclaredField("staticInt") == clazz.getDeclaredField("staticInt") 结果为 false
    // jdk 内部 filed 的获取全部采用了 copyField 的方式，因此 == 必然为 false
    Log.d(TAG, String.format("二个域是否 == ：%b", field == fieldReflect));  // 结果为 false
    Log.d(TAG, "二个域是否 equals ：" + field.equals(fieldReflect));
    Log.d(TAG, "~~~~~~~~~~~~~~field description json start~~~~~~~~~~~");
    Log.d(TAG, JSON.toJSONString(field));
    Log.d(TAG, "~~~~~~~~~~~~~~field description json end~~~~~~~~~~~");
    Log.d(TAG, System.lineSeparator());
    Log.d(TAG, "~~~~~~~~~~~~~~fieldReflect description json start~~~~~~~~~~~");
    Log.d(TAG, JSON.toJSONString(fieldReflect));
    Log.d(TAG, "~~~~~~~~~~~~~~fieldReflect description json end~~~~~~~~~~~");
    Log.d(TAG, "测试读取和设置静态域结束...");

}
```

## 2.3 拦截构造器和方法




### 2.3.1 简单参数列表

- 可以使用 XposedHelpers.findAndHookConstructor 来 hook 构造器，使用 XposedHelpers.findAndHookMethod 来 hook 普通方法
- 他们的原理是一致的：先使用反射技术找到构造器 Constructor 或者普通方法 Method，然后调用 XposedBridge.hookMethod(Member hookMethod, XC_MethodHook callback) 添加逻辑，测试代码如下：
```java
/**
 * 使用 XposedHelpers.findAndHookConstructor 来 hook 构造器；
 * 使用 XposedHelpers.findAndHookMethod 来 hook 普通方法
 * @param clazz
 */
private void testHookConstructorAndMethod(Class<?> clazz) throws Throwable {

    final String className =  clazz.getName();

    // 使用 XposedHelpers.findAndHookConstructor 来 hook 构造器
    XposedHelpers.findAndHookConstructor(clazz, new XC_MethodHook() {

        @RequiresApi(api = Build.VERSION_CODES.O)
        @Override
        protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
            printMethodInfo(param);
            // 默认构造函数无入参，不修改
        }

        @Override
        protected void afterHookedMethod(MethodHookParam param) throws Throwable {
            super.afterHookedMethod(param);
        }
    });


    // 使用 XposedHelpers.findAndHookMethod 来 hook 普通方法
    XposedHelpers.findAndHookMethod(clazz, "privateFunc", String.class, new XC_MethodHook() {
        @RequiresApi(api = Build.VERSION_CODES.O)
        @Override
        protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
            printMethodInfo(param);
            // 打印信息后，修改第一个入参
            param.args[0] = "hao1";
        }

        @Override
        protected void afterHookedMethod(MethodHookParam param) throws Throwable {
            super.afterHookedMethod(param);
        }
    });



    // 它们的原理都是：先使用反射技术找到构造器 Constructor 或者普通方法 Method
    // 然后调用 XposedBridge.hookMethod(Member hookMethod, XC_MethodHook callback) 添加逻辑
    // 其中 XC_MethodHook 接口提供了 beforeHookedMethod, afterHookedMethod 两个方法分别用于在方法调用前后做额外的操作
    // 因此，我们也可以手动获取 Constructor/Method，然后用 XposedBridge.hookMethod 添加 hook 逻辑
    // 同时，我们可以直接 hook 静态方法
    Method publicFunc = clazz.getDeclaredMethod("staticPrivateFunc", String.class);
    XposedBridge.hookMethod(publicFunc, new XC_MethodHook() {
        @RequiresApi(api = Build.VERSION_CODES.O)
        @Override
        protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
            printMethodInfo(param);
            // 打印信息后，修改第一个入参
            param.args[0] = "hao2";
        }

        @Override
        protected void afterHookedMethod(MethodHookParam param) throws Throwable {
            super.afterHookedMethod(param);
        }
    });
}
```
- 在上述测试 hook 的过程中，为了方便查看被 hook 方法的信息，统一封装了 printMethodInfo 方法用于打印方法信息，代码如下：
```java
@RequiresApi(api = Build.VERSION_CODES.O)
private void printMethodInfo(XC_MethodHook.MethodHookParam param) throws Throwable {
    Executable executable = (Executable) param.method;
    String methodName = executable.getName();
    Log.d(TAG, String.format("hook 到 %s 方法，参数列表为：", methodName));

    IntStream.range(0, param.args.length)
            .mapToObj(i -> "---- " + executable.getParameters()[i].getType().getName() + " = " + param.args[i])
            .forEach(s -> Log.d(TAG, s));

    Log.d(TAG, String.format("是否静态方法：%b", Modifier.isStatic(executable.getModifiers())));
    Log.d(TAG, String.format("this == null : %b", param.thisObject == null));
}
```

### 2.3.2 多次 hook 同一方法时的优先级

- 我们在前一个例子中，hook 了 printStr 两次，并为第二次 hook 设置了 priority 为 10，接下来我们进一步分析和测试 hook 同一方法多次时的优先级
- Hook 方法的方式还是如前面所说的有两种方式，一种是直接使用  XposedHelpers.findAndHookMethod 查找方法并直接 hook，另一种是使用反射技术/XposedHelpers 先找到目标方法，然后使用 XposedBridge.hookMethod 添加 hook 逻辑，而且这两种方式，本质上都是一样的：都是先找到 Method 对象，然后使用 XposedBridge.hookMethod 添加 hook 逻辑
- 通过分析可得：hook 同一个函数多次，并都修改了值，会导致优先级高的覆盖优先级低的；查看 XposedBridge.hookMethod 源码，其内部对每个方法都定义了一个 SortedSet 用于缓存该方法的所有 callback，故我们从 XC_MethodHook 的继承树往上查找，发现 XCallback 实现了 Comparable 接口，我们查看其 compareTo 源码，发现其首先按照 priority 降序排序，若 priority 相同则按照 hashCode 值升序排序，排到 set 最后的元素优先级最高，因为最后的回调最后才执行，其逻辑会覆盖前面的，因此 priority 最小的值优先级最高，在 set 中排在最后，同时查看 XCallback 的 priority 的注释 "higher number means earlier execution"，也符合我们的分析
- 在我们下面的例子中，由于没有手动设置 priority，其为默认值 XCallback.PRIORITY_DEFAULT = 50，因此，会根据两个 XC_MethodHook 的 hashCode 判定优先级，hashCode 值大的优先级高，最后调用，其设置的值会覆盖另一个
- 测试代码如下：
```java
/**
 * 测试 hook 同一个方法 printStr(String.class) 多次时，各个 hook 逻辑执行的优先级
 *
 * @param clazz 目标类
 * @throws Throwable 异常
 */
private void testPriority(Class<?> clazz) throws Throwable {

    // 要 hook 的方法名
    final String methodName = "printStr";

    // 方式一：使用 XposedHelpers.findAndHookMethod 直接 hook 并拦截目标方法
    XposedHelpers.findAndHookMethod(clazz, methodName, String.class, new XC_MethodHook() {

        {
            Log.d(TAG, "第一个 MethodHook 的 priority：" + priority);
            Log.d(TAG, "第一个 MethodHook 的 hashCode：" + this.hashCode());
            Log.d(TAG, "第一个 MethodHook 的 System.identityHashCode：" + System.identityHashCode(this));
        }

        @Override
        protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
            printMethodInfo(param);
            // 修改第二个参数 value，但该赋值会被后面的覆盖
            param.args[0] = "hookedValue1";
        }

        // 不需要 after 可以直接省略
    });

    // 方式二：使用反射找到 Method，并直接使用 XposedBridge.hookMethod 添加 hook 逻辑
    Method method = clazz.getDeclaredMethod(methodName, String.class);
    XposedBridge.hookMethod(method, new XC_MethodHook() {

        {
            Log.d(TAG, "第二个 MethodHook 的 priority：" + priority);
            Log.d(TAG, "第二个 MethodHook 的 hashCode：" + this.hashCode());
            Log.d(TAG, "第二个 MethodHook 的 System.identityHashCode：" + System.identityHashCode(this));
        }

        @Override
        protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
            printMethodInfo(param);
            // hook 同一个函数多次，并都修改了值，会导致优先级高的覆盖优先级低的
            // 查看 XposedBridge.hookMethod 源码，其内部对每个方法都定义了一个 SortedSet 用于缓存该方法的所有 callback
            // 故我们从 XC_MethodHook 的继承树往上查找，发现 XCallback 实现了 Comparable 接口，我们查看其 compareTo 源码
            // 发现其首先按照 priority 降序排序，若 priority 相同则按照 hashCode 值升序排序，
            // 排到 set 最后的元素优先级最高，因为最后的回调最后才执行，其逻辑会覆盖前面的，因此 priority 最小的值优先级最高，在 set 中排在最后，
            // 同时查看 XCallback 的 priority 的注释 "higher number means earlier execution"，也符合我们的分析
            // 在我们的例子中，由于没有手动设置 priority，其为默认值 XCallback.PRIORITY_DEFAULT = 50
            // 因此，会根据两个 XC_MethodHook 的 hashCode 判定优先级，hashCode 值大的优先级高，最后调用，其设置的值会覆盖另一个
            param.args[0] = "hookedValue2";
        }

        // 不需要 after 可以直接省略
    });

}
```


### 2.3.3 复杂参数列表

- 前面提供的例子，参数类型较为简单，其参数为 jdk 的内置类，我们可以直接使用 .class 方便地获取参数列表的 Class 对象
- 当方法的参数为 app 内自定义的类类型时，我们无法使用 .class 语法或者 Class 对象，但我们仍然可以使用 Class.forName 或者 XposedHelpers.findClass 获取对应的 Class 对象
- 当参数为自定义类的数组类型时，则必须使用字符串描述符，或者提前找到对应 Class 对象，其 Class 对象的字符串格式为 `[Lcom.hao.app.Person;`
- 综合来说，对参数列表的描述本质就是所有参数的 Class 对象，因此不管什么参数列表，只要通过 .class 语法、Class.forName 函数或 XposedHelpers.findClass 获取到参数的 Class 对象并找到对应的方法即可
- 测试代码如下
```java
/**
 * 测试 hook 复杂方法，我们以各个重载的 print 方法作为测试
 *
 * @param clazz 目标类
 * @throws Throwable 异常
 */
private void testHookComplexMethod(Class<?> clazz) throws Throwable {

    ClassLoader classLoader = clazz.getClassLoader();

    // 提前找到 Person.class 对象
    Class<?> personClass = XposedHelpers.findClass("com.hao.app.Person", classLoader);

    // 要 hook 的方法名
    final String methodName = "print";

    // 拦截 print(int i, int j) 方法
    XposedHelpers.findAndHookMethod(clazz, methodName, int.class, double.class, new XC_MethodHook() {
        @Override
        protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
            printMethodInfo(param);
        }
    });

    // 拦截 print(float[] arr, int idx) 方法
    XposedHelpers.findAndHookMethod(clazz, methodName, float[].class, int.class, new XC_MethodHook() {
        @Override
        protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
            printMethodInfo(param);
        }
    });

    // 拦截 print(Person[] persons) 方法
    Class<?> perssonArrayClass = XposedHelpers.findClass("[Lcom.hao.app.Person;", classLoader);
    XposedHelpers.findAndHookMethod(clazz, methodName, perssonArrayClass, new XC_MethodHook() {
        @Override
        protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
            printMethodInfo(param);
        }
    });

    // 拦截 print(List<Person> persons) 方法
    // 注意由于泛型擦除，不同的泛型类型是无法重载的，
    // 例如该函数和 print(List<Integer> list) 是一样的签名 List.class，会报错
    XposedHelpers.findAndHookMethod(clazz, methodName, List.class, new XC_MethodHook() {
        @Override
        protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
            printMethodInfo(param);
        }
    });

}
```

### 2.3.4 覆盖函数

- 我们前面都是使用抽象类 XC_MethodHook 添加 hook 逻辑，其提供 beforeHookedMethod 和 afterHookedMethod 两个方法供子类实现，分别在方法调用之前和之后调用自定义的 hook 逻辑
- 除了 XC_MethodHook，还有另一个常用的抽象类 XC_MethodReplacement，其提供了 replaceHookedMethod 用于替换目标方法
- 我们跟踪其源码可以发现其是 XC_MethodHook 的子类，其实现了 beforeHookedMethod 方法，在该方法内部，其先去调用 replaceHookedMethod 拿到结果，之后调用 MethodHookParam 对象的 setResult 方法，而我们知道，在 beforeHookedMethod 内部调用 setResult 将导致直接返回结果，不会继续调用目标方法，通过“在 beforeHookedMethod 调用 setResult”这种方式，我们实现了方法替换
- 同时，为了弹出提示，我们额外实现了 init 方法用于初始化 Context context 变量，其指向 MainActiviry 实例，在执行 testReplaceMethod 之前需要先初始化：
```java
private Context context;

/**
 * 初始化方法，拦截 MainActivity.onCreate 函数，拿到并保存 this 对象，以用于调用
 * @param loadPackageParam loadPackageParam
 */
private void init(XC_LoadPackage.LoadPackageParam loadPackageParam) {
    XposedHelpers.findAndHookMethod("com.hao.app.MainActivity", loadPackageParam.classLoader, "onCreate", Bundle.class, new XC_MethodHook() {
        @Override
        protected void afterHookedMethod(MethodHookParam param) throws Throwable {
            Activity app = (Activity) param.thisObject;
            context = app.getApplicationContext();
        }
    });
}

private void showText(String text) throws Throwable {
    Toast.makeText(context, text, Toast.LENGTH_SHORT).show();
}
```
- 测试代码如下，第一个测试我们 hook 目标类的 printPrivateInt 方法，并使用 XC_MethodReplacement 替换对应方法；第二个测试我们使用 XC_MethodHook 实现方法替换，并做一个复杂的替换，详细内容见代码
```java
/**
 * 测试替换方法，分别测试直接使用 XC_MethodReplacement 替换；
 * 以及使用 XC_MethodHook 模拟 XC_MethodReplacement 的实现原理进行替换
 * @param clazz 目标类
 * @throws Throwable 异常
 */
private void testReplaceMethod(Class<?> clazz) throws Throwable {

    // 方式一：使用 XC_MethodReplacement 替换目标方法 printPrivateInt，
    XposedHelpers.findAndHookMethod(clazz, "printPrivateInt", int.class, new XC_MethodReplacement() {

        @Override
        protected Object replaceHookedMethod(MethodHookParam param) throws Throwable {
            // 原方法内部会在其 tag 下打印日志：privateInt = 3
            // 替换后将不再打印，同时我们自己打印一条日志
            Log.d(TAG, "正在替换方法：" + param.method.getName());
            // 同时我们在 AppDemo 的 TAG 下打印一条日志，且打印值为原来两倍
            String APP_TAG = (String) XposedHelpers.getStaticObjectField(clazz, "TAG");
            Log.d(APP_TAG, "被替换的方法: privateInt = " + (int)param.args[0] * 2);
            // 原方法没有返回值，直接返回 null
            return null;
        }
    });

    // 方式二：自己使用 XC_MethodHook 实现替换逻辑
    // 同时玩点花的：我们使用一个 boolean 变量控制是否替换，一次替换一次不替换，以方便在控制台看出区别
    // 测试的目标方法是 test，拦截后单击按钮将不会调用一系列方法，从而 test 内部的一系列方法也不会被调用
    // 这样，我们会达到：点击两次按钮，才调用一次目标方法的效果，另一次被替换为弹出“请检查网络连接”的提示
    XposedHelpers.findAndHookMethod(clazz, "test", new XC_MethodHook() {

        // 控制本次是否替换的变量，默认为 false 表示第一次不替换
        private boolean replace = false;

        @Override
        protected void beforeHookedMethod(MethodHookParam param) throws Throwable {

            String methodName = param.method.getName();
            Log.d(TAG, "拦截到方法：" + methodName);

            // 若 replace 为 true，表示本次要替换
            if (replace) {
                Log.d(TAG, "正在替换方法：" + methodName);
                // 弹出一个提示
                showText("请检查网络连接");
                param.setResult(null);
            }

            // 变换状态
            replace = !replace;
        }
    });
}
```

### 2.3.5 拦截内部类的方法

- 拦截内部类的方法和拦截普通方法本质上还是一样的，本质上是还是先找到内部类的 Class 对象，然后根据使用 XposedHelpers.findAndHookMethod 传入 Class 对象、方法名和参数列表即可进行拦截
- 其中，对于非静态内部类，其类名组成为 `包名.外部类名$内部类名` 组成，我们找到内部类的 Class 对象即可
- 对于匿名内部类（包括 lambda 表达式），其在运行时才基于动态代理生成具体的实现类，故我们无法确定其具体类名，但我们可以通过 hook 接受匿名内部类作为参数的方法，拿到匿名内部类的实例，再调用实例的 getClass() 方法拿到 Class 对象；唯一的难点是，像这种接受匿名内部类作为参数的方法往往是系统级的接受监听器的方法，其往往会在整个 app 中接收大量不同的内部类，我们很难确定到我们真正想确定的那个内部类（但一般可以通过我们想 hook 的目标内部类的特征出发找到对应的内部类）
- 此外，对于匿名内部类，也可以使用 Android Killer 反编译 apk，通过查看 smali 文件名拿到类名
- 测试代码如下：
```java
/**
 * 测试 hook 内部类的方法以及获取内部类对象的 field 值
 *
 * @param loadPackageParam loadPackageParam
 */
private void testHookInnerClassMethod(XC_LoadPackage.LoadPackageParam loadPackageParam) {

    ClassLoader classLoader = loadPackageParam.classLoader;

    final String innerClassName = "com.hao.app.Test$Teacher";

    // 测试拦截静态内部类：先找到内部类，然后 hook 内部类的方法
    Class<?> innerClass = XposedHelpers.findClass(innerClassName, classLoader);
    XposedHelpers.findAndHookMethod(innerClass, "type", new XC_MethodHook() {
        @Override
        protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
            printMethodInfo(param);

            // 由于在该方法内部，我们可以拿到 this 对象，从而可以进一步获取获内部类的变量值
            Integer age = (Integer) XposedHelpers.getObjectField(param.thisObject, "age");
            Log.d(TAG, "teacher's age = " + age);

        }
    });

    // 通过 Android Killer 直接获取匿名内部类类名
    Class<?> clazz = XposedHelpers.findClass("com.hao.app.Test$1", classLoader);
    // 直接 hook 匿名内部类的 toString 方法
    XposedHelpers.findAndHookMethod(clazz, "type", new XC_MethodHook() {
        @Override
        protected void afterHookedMethod(MethodHookParam param) throws Throwable {
            // 获取结果
            Log.d(TAG, "匿名内部类的 type 方法结果：" + param.getResult());
        }
    });

    // 测试拦截匿名内部类：通过方法参数拦截
    // 我们在 AppDemo 内部特地提供了个 printAnonymousInnerClass(Person person) 方法用于该测试
    XposedHelpers.findAndHookMethod("com.hao.app.Test", classLoader, "printAnonymousInnerClass", "com.hao.app.Person", new XC_MethodHook() {
        @Override
        protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
            printMethodInfo(param);
            // 拿到参数类型
            Class<?> clazz2 = param.args[0].getClass();
            Log.d(TAG, "两种方式获取到的匿名内部类是否相等：" + (clazz == clazz2));
            Method type = clazz2.getMethod("type");
            Log.d(TAG, "调用 type 方法结果：" + type.invoke(param.args[0]));
        }
    });
}
```

## 2.4 主动调用方法

- 可以使用 XposedHelpers.callStaticMethod 主动调用静态方法，使用 XposedHelpers.callMethod 主动调用非静态方法 getPrivateInt
- xposed 有提供对构造器的 hook，但没有提供专门的调用构造器的方法，但我们仍然可以通过 java 反射找到构造器并进行调用
- 测试代码如下：
```java
/**
 * 测试使用 XposedHelpers.callStaticMethod 主动调用静态方法；
 * 测试使用 XposedHelpers.callMethod 主动调用非静态方法
 * @param loadPackageParam loadPackageParam
 * @throws Throwable 异常
 */
public void testInvokeMethod(XC_LoadPackage.LoadPackageParam loadPackageParam) throws Throwable {

    ClassLoader classLoader = loadPackageParam.classLoader;

    // 先获取 Test 类
    Class<?> clazz = XposedHelpers.findClass("com.hao.app.Test", classLoader);

    // 使用 XposedHelpers.callStaticMethod 主动调用静态方法 getPrivateStaticInt
    int privateStaticInt = (int) XposedHelpers.callStaticMethod(clazz, "getPrivateStaticInt");
    Log.d(TAG, "privateStaticInt = " + privateStaticInt);

    // 使用 XposedHelpers.callMethod 主动调用非静态方法 getPrivateInt
    int privateInt = (int) XposedHelpers.callMethod(clazz.newInstance(), "getPrivateInt");
    Log.d(TAG, "privateInt = " + privateInt);

    // xposed 有提供对构造器的 hook，但没有提供专门的调用构造器的方法
    // 但我们仍然可以通过 java 反射找到构造器并进行调用
    Class<?> studentClass = XposedHelpers.findClass("com.hao.app.Student", classLoader);
    Constructor<?> constructor = studentClass.getConstructor(String.class, Integer.class, String.class);

    // 调用构造器：即创建一个对象
    Object jane = constructor.newInstance("jane", 22, "MIT");
    Log.d(TAG, jane.toString());

}
```


## 2.5 获取所有类

- 如何获取所有类的 Class 对象呢，我们知道，在 java 中，不管是 .class 语法还是 Class.forName，其最后都是调用 ClassLoader 对象的 loadClass 加载并返回 Class 对象，
- 由于所有的 Class 对象都是由 ClassLoader 加载并返回的，故我们可以通过 hook 类加载器的 loadClass 的方法，获取其返回值，来拿到所有的 Class 对象
- 此外，利用 ClassLoader 的双亲委派特性，我们可以通过不同的 ClassLoader 最 Class 集合做过滤
- 测试代码如下：
```java
/**
 * 测试 hook ClassLoader.loadClass(String) 方法
 * @param loadPackageParam
 */
private void testHookLoadClass(XC_LoadPackage.LoadPackageParam loadPackageParam) {

    XposedHelpers.findAndHookMethod(ClassLoader.class, "loadClass", String.class, new XC_MethodHook() {
        @Override
        protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
            Log.d(TAG, "begin to load : " + param.args[0]);
        }

        @Override
        protected void afterHookedMethod(MethodHookParam param) throws Throwable {

            Object className = param.args[0];

            Log.d(TAG, String.format("load %s returned", className));

            Class<?> clazz = (Class<?>) param.getResult();

            if (clazz == null) {
                Log.d(TAG, String.format("load %s get null", className));
                return;
            }

            Log.d(TAG, String.format("load %s success", className));
        }
    });

}
```


## 

## 2.6 测试入口代码

```java
@Override
public void handleLoadPackage(XC_LoadPackage.LoadPackageParam loadPackageParam) throws Throwable {

    if (!loadPackageParam.packageName.equals("com.muyang.xposeddemo")) {
        return;
    }

    Class<?> clazz = testLoadClass(loadPackageParam);
    testGetAndSetStaticField(clazz);

}
```


## 补充说明

- 对于父类的方法，若被子类覆盖，则只 hook 父类是无效的




# 3 附录

## 3.1 AppDemo 源码

```

```

## 3.2 模拟器安装 xposed

- [参考地址](https://www.i4k.xyz/article/weixin_44183483/118931351)
- 根据模拟器的安卓版本确定 api 版本，其中 5.1 为 22，7.1 为 25
- 访问 [https://dl-xda.xposed.info/framework/](https://dl-xda.xposed.info/framework/)，下载对应版本的 xposed 包，注意手机一般为 arm64，而模拟器是电脑，一般为 x86
- 将加载的文件解压，并将 system 拷贝到 xposed 文件夹中
- 下载 [scrapy.txt](https://forum.xda-developers.com/attachment.php?attachmentid=4489568&d=1525092710) 文件并改名为 scrapy.sh，并拷贝到 xposed 文件夹中
- 执行下述 adb 命令以将 xposed 刷入系统
```bash
adb remount
adb push xposed /system
adb shell
su
cd /system/xposed
mount -o remount -w /system
sh script.sh
```