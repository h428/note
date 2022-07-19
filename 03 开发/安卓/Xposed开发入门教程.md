
# 构建简单的App

- 该app用于给Xposed 模块hook
- 布局文件提供一个Button和一个TextView
- 代码MainActivity为Button添加监听器，单击按钮时改变TextView的内容
```
public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Button btn = (Button)findViewById(R.id.btn);
        final TextView textView = (TextView)findViewById(R.id.text_view);

        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                textView.setText("按钮改变的内容");
            }
        });

    }
}

```

# 构建Xposed模块，hook上述简单App

- 利用Xposed模块更改App内容，其核心思想类似于AOP编程思想
- 利用Xposed提供的工具类和方法，快速定位到指定的apk，并指定需要拦截的类和方法，在该方法执行之前和执行之后分别做一些修改内容，以达到修改程序的目的
- 编程涉及的相关类、接口、方法：
    - IXposedHookLoadPackage：实现该接口，表示这是一个Xposed模块
    - XposedHelpers.findAndHookMethod：核心方法，用于找到指定类和方法，并定义回调
    - XposedBridge：帮助类，可以用于日志记录，打开Xposed程序-日志，可以观察到日志内容


```
public class Main implements IXposedHookLoadPackage {

    // 日志记录前缀。用于快速辨认自己的日志
    public static final String prefix = "=============== :  ";

    @Override
    public void handleLoadPackage(XC_LoadPackage.LoadPackageParam loadPackageParam) throws Throwable {

        // 记录日志
        XposedBridge.log(prefix + "handleLoadPackage开始执行");

        // 判断需要hook的apk对应的包名
        if (loadPackageParam.packageName.equals("com.hao.test")){
            // 记录日志
            XposedBridge.log(prefix + "开始hook：Test程序");
//

            /**
             * 利用XposedHelpers.findAndHookMethod方法进行拦截：拦截setText方法
             * 第一个参数为要拦截的类，第二个参数为要拦截的方法
             * 第三个参数为Object..类型，可包含多个参数，其中，前t-1个表示setText的参数类型，
             * 最后一个为拦截到对应方法后的回调操作，通常实现XC_MethodHook接口
             * 如该示例：被拦截的setText有一个参数，参数类型为CharSequence.class，
             * 最后一个即为回调函数，我们在里面编写我们想要的处理
             */
            XposedHelpers.findAndHookMethod(TextView.class, "setText", CharSequence.class, new XC_MethodHook() {
                /**
                 * onCreate之前回调，可以修改
                 * @param param onCreate方法的信息，可以修改
                 * @throws Throwable
                 */
                @Override
                protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
                    // 记录日志
                    XposedBridge.log(prefix + "处理setText方法之前");
                    // 更改setText方法的参数
                    param.args[0] = "我是被Xposed修改的内容";
                }

                @Override
                protected void afterHookedMethod(MethodHookParam param) throws Throwable {
                    XposedBridge.log(prefix + "处理setText的方法后");
                }
            });

        }

    }
}
```

- 之后，在`AndroidManifest.xml`文件的application元素内部配置如下信息，告诉xposed这是一个xposed模块
```
<!-- 是否是xposed模块，xposed根据这个来判断是否是模块 -->
<meta-data
    android:name="xposedmodule"
    android:value="true" />

<!-- 模块描述，显示在xposed模块列表那里第二行 -->
<meta-data
    android:name="xposeddescription"
    android:value="测试Xposed模块" />

<!-- 最低xposed版本号(lib文件名可知) -->
<meta-data
    android:name="xposedminversion"
    android:value="30" />
```
- 最后，在`assets`目录下新建``，告诉



# 相关网址