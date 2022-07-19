
# 1. 基本用法

- Web 层的单元测试主要基于 MockMvc
- 首先创建两个测试环境配置类，BaseTest 和 BaseWebTest
- BaseTest 提供 Spring 测试环境
```java
/**
 * 基础的测试类，配置测试环境；
 * 所有 Service、Mapper 层的测试类都继承该类而自动具有环境配置
 */
@SpringBootTest(classes = WebApplication.class)
@RunWith(SpringRunner.class)
@Transactional // 为了避免产生脏数据，在单元测试内部设置的事务会自动回滚
public class BaseTest {

}
```
- BaseWebTest 提供 Mock 的测试环境
```java
/**
 * Controller 层的测试类，提供 Mock 测试环境；
 * 所有 Controller 的测试类都继承该类而自动具有环境配置
 */
public class BaseWebTest extends BaseTest {
    @Autowired
    WebApplicationContext wac;

    // 主要通过 mockMvc 完成对 http 请求的测试
    protected MockMvc mockMvc;

    @Before
    public void setUp(){
        mockMvc = MockMvcBuilders.webAppContextSetup(wac).build();
    }
}
```
- 以 ProductController 为例做常见的单元测试，注意继承 BaseWebTest
```java
public class ProductControllerTest extends BaseWebTest{

    @Test
    public void add() throws Exception {

        // 商品，作为请求的 body 部分（即 content）
        Product product = Product.builder()
                .name("阿尔宙斯")
                .cid1(2L)
                .cid2(101L)
                .description("xxxxx")
                .price(439.0f)
                .build();

        // 使用 MockMvcRequestBuilders 构造测试请求
        // 请求的 url、header、body 及类型、请求参数设置等都在此处设置，相当于模拟一个 http 请求，可参考其他测试用例
        MockHttpServletRequestBuilder request = MockMvcRequestBuilders.post("/product")
                .header("Authorization", "token") // 设置 token，此处无用
                .contentType(MediaType.APPLICATION_JSON_UTF8) // 设置 content 类型为 application/json;charset=UTF-8
                .content(JacksonUtil.toJson(product)); // 设置请求体，注意是 json，因此要把 product 转换为 json 然后模拟请求

        // 发送请求，并校验 json 类型的请求结果，对于 json 结果一般使用 jsonPath 校验就够了
        mockMvc.perform(request)
                .andExpect(status().isOk()) // 校验状态码
                .andExpect(jsonPath("$.status").value(200)) // 校验 json 结果
                .andExpect(jsonPath("$.message").exists()) // 校验 json 结果中的 message 存在
                .andDo(MockMvcResultHandlers.print()); // 如果需要打印测试的详细信息，可使用该行查看

        // 保存一个名字冲突的 product，会得到 400 错误（由于在保存时做了校验因此会得到 400）
        product.setName("妙蛙种子");

        request = MockMvcRequestBuilders.post("/product")
                .contentType(MediaType.APPLICATION_JSON_UTF8)
                .content(JacksonUtil.toJson(product));
        mockMvc.perform(request)
                .andExpect(status().isBadRequest()); // 400
    }

    @Test
    public void addForm() throws Exception {
        // 测试表单类型请求，参数通过 param 设置而不是放置到请求体
        MockHttpServletRequestBuilder request = MockMvcRequestBuilders.post("/product/form")
                .param("name", "阿尔宙斯")
                .param("cid1", "1")
                .param("cid2", "101")
                .param("price", "100");

        mockMvc.perform(request)
                .andExpect(status().isOk()); // 插入成功 200
    }

    @Test
    public void delete() throws Exception {
        // 删除存在的记录是 200
        MockHttpServletRequestBuilder request = MockMvcRequestBuilders.delete("/product/1");
        mockMvc.perform(request)
                .andExpect(status().isOk());

        // 删除不存在的记录是 404
        request = MockMvcRequestBuilders.delete("/product/10086");
        mockMvc.perform(request)
                .andExpect(status().isNotFound());
    }

    @Test
    public void update() throws Exception {
        Product product = Product.builder()
                .name("aaaaa")
                .build();

        // 注意这三个请求在同一个事务，因此若先正常更新，则导致名称更新为 aaaaa，则更新不存在的记录时将导致 400
        // 因此要先测试 404

        // 更新不存在的记录，404
        MockHttpServletRequestBuilder request = MockMvcRequestBuilders.put("/product/11111111")
                .contentType(MediaType.APPLICATION_JSON_UTF8)
                .content(JacksonUtil.toJson(product));
        mockMvc.perform(request)
                .andDo(MockMvcResultHandlers.print())
                .andExpect(status().isNotFound());

        // 正常更新 200
        request = MockMvcRequestBuilders.put("/product/1")
                .contentType(MediaType.APPLICATION_JSON_UTF8)
                .content(JacksonUtil.toJson(product));
        mockMvc.perform(request)
                .andExpect(status().isOk());

        // 更新已存在的名字，400
        product.setName("妙蛙花");
        request = MockMvcRequestBuilders.put("/product/1")
                .contentType(MediaType.APPLICATION_JSON_UTF8)
                .content(JacksonUtil.toJson(product));
        mockMvc.perform(request)
                .andExpect(status().isBadRequest());
    }

    @Test
    public void get() throws Exception {
        MockHttpServletRequestBuilder request = MockMvcRequestBuilders.get("/product/1")
                .header("Authorization", "token");// 设置 token，此处无用

        mockMvc.perform(request)
                .andExpect(status().isOk()) // 验证状态码为 200
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.name").value("妙蛙种子"))
                .andExpect(jsonPath("$.price").value(318))
                .andExpect(jsonPath("$.cid1").value(1L))
                .andExpect(jsonPath("$.cid2").value(101L));
    }

    @Test
    @SuppressWarnings("unchecked")
    public void list() throws Exception {

        // 模拟请求
        MockHttpServletRequestBuilder request = MockMvcRequestBuilders.get("/product");

        // 对于大多数情况，都无需取出 json 并反序列话为 object，直接利用 jsonPath 判断 json 即可
        // 但若 json 比较复杂，我们可能想要使用较为复杂的代码甚至是循环校验 json，此时就需要取出 json，
        // 例如此处的 json 是一个 pageBean 对象，里面还包含了 list，我们希望逐一校验

        // json 在响应体中，按照如下顺序取出：MvcResult -> response -> content

        // 拿到 mvcResult，相当于测试的虚拟结果，包含了几乎所有信息
        MvcResult mvcResult = mockMvc.perform(request)
                .andReturn(); // 使用 andReturn 拿到 mvcResult

        // 取出响应体中的 json 并反序列化
        String json = mvcResult.getResponse().getContentAsString();

        // 共 15 条记录， 3 也，每页 5 个
        PageBean<Product> pageBean = JacksonUtil.fromJsonToBean(json, PageBean.class);
        assertEquals(15, pageBean.getTotal());
        assertEquals(3, pageBean.getPages());
        assertEquals(5, pageBean.getList().size());
    }
```
- 自此，完成了 Controller 层基本的单元测试

# 2. 封装 MockMvc

- 观察上面的代码我们发现，单元测试中包含大量重复的的请求封装以及校验响应的代码
- 实际上我们可以将重复代码抽取出来形成较为通用的请求模拟和响应校验方法，以便能快速模拟请求以及测试响应结果
- 我们在 MockMvc 的基础上封装常用代码，并在 BaseWebTest 中提供，这样所有继承该类的测试类都能便捷的测试
- 主要封装了 Request 和 Response，分别表示本次测试的请求与相应，它们各自提供链式的构造或测试方法
- 封装了便捷方法的 BaseWebTest 代码如下：
```java
/**
 * Controller 层的测试类，提供 Mock 测试环境，所有 Controller 的测试类都继承该类而自动具有环境配置
 *
 * 为了方便测试，在 MockMvc 封装请求，以便快速测试
 *
 * @author hao
 */
public class BaseWebTest extends BaseTest {

    public static final String BASE_USER_HEADER = "X-BASE-USER-ID";
    public static final String LYH = "1";
    public static final String ZLM = "2";
    public static final String ERROR_USER = "1111111112";

    @Autowired
    WebApplicationContext wac;

    // 主要通过 mockMvc 完成对 http 请求的测试
    protected MockMvc mockMvc;

    @Before
    public void setUp() {
        mockMvc = MockMvcBuilders.webAppContextSetup(wac).build();
    }

    /**
     * 构造 get 请求，注意执行 execute 获得封装的 Response
     *
     * @param url 请求地址
     * @param vars 路径参数
     * @return 封装的 Request
     */
    protected Request get(String url, Object... vars) {
        return new Request(HttpMethod.GET, url, vars);
    }

    /**
     * 构造 post 请求，注意执行 execute 获得封装的 Response
     *
     * @param url 请求地址
     * @param vars 路径参数
     * @return 封装的 Request
     */
    protected Request post(String url, Object... vars) {
        return new Request(HttpMethod.POST, url, vars);
    }

    /**
     * 构造 put 请求，注意执行 execute 获得封装的 Response
     *
     * @param url 请求地址
     * @param vars 路径参数
     * @return 封装的 Request
     */
    protected Request put(String url, Object... vars) {
        return new Request(HttpMethod.PUT, url, vars);
    }

    /**
     * 构造 delete 请求，注意执行 execute 获得封装的 Response
     *
     * @param url 请求地址
     * @param vars 路径参数
     * @return 封装的 Request
     */
    protected Request delete(String url, Object... vars) {
        return new Request(HttpMethod.DELETE, url, vars);
    }

    public class Request {

        private MockHttpServletRequestBuilder requestBuilder;

        /**
         * 根据请求类型和请求地址构造请求
         *
         * @param method 请求类型
         * @param url 请求地址
         * @param vars 路径参数
         */
        public Request(HttpMethod method, String url, Object... vars) {
            requestBuilder = MockMvcRequestBuilders.request(method, url, vars);
        }

        /**
         * 设置请求头
         *
         * @param headerName 请求头名称
         * @param headerValue 请求头值
         * @return 返回 Request 以链式调用
         */
        public Request header(String headerName, String headerValue) {
            // 设置请求头
            requestBuilder.header(headerName, headerValue);
            return this;
        }

        /**
         * 设置请求头 Authorization
         *
         * @param token token 值
         * @return 返回 Request 以链式调用
         */
        public Request token(String token) {
            // 设置请求头
            requestBuilder.header(HttpHeader.AUTHORIZATION, token);
            return this;
        }

        /**
         * 设置请求体
         *
         * @param body 请求体
         * @return 返回 Request 以链式调用
         */
        public Request body(Object body) {
            // 请求体转化为 json
            String json = JacksonUtil.toJson(body);

            // 请求体不为空则本次请求添加请求体，类型为 application/json;charset=UTF-8
            if (json != null) {
                requestBuilder.contentType(MediaType.APPLICATION_JSON_UTF8)
                        .content(json);
            }
            return this;
        }

        /**
         * 设置请求的查询参数
         *
         * @param paramName 参数名
         * @param paramValue 参数值
         * @return 返回 Request 以链式调用
         */
        public Request param(String paramName, String paramValue) {
            requestBuilder.param(paramName, paramValue);
            return this;
        }

        /**
         * 执行请求，拿到本次请求的响应
         *
         * @return 返回本次请求的响应 Response，其支持链式调用以链式判定
         */
        public Response execute() {
            try {
                return new Response(mockMvc.perform(requestBuilder));
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
    }

    /**
     * 对 ResultActions 的封装，方便自己操作和测试以及链式校验
     */
    public class Response {

        private ResultActions resultActions;

        // 必须提供 ResultActions 实例，该类在其基础上封装，用于快速测试
        public Response(ResultActions resultActions) {
            this.resultActions = resultActions;
        }

        /**
         * 校验响应状态码
         *
         * @param status 响应状态码
         * @return 返回 Result 以便能够链式校验
         */
        public Response status(int status) {
            try {
                resultActions.andExpect(MockMvcResultMatchers.status().is(status));
                return this;
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }

        /**
         * 校验响应体中 json 的对应属性存在
         *
         * @param propertyName 属性名称
         * @return 返回 Result 以便能够链式校验
         */
        public Response propertyExist(String propertyName) {
            try {
                resultActions.andExpect(jsonPath("$." + propertyName).exists());
                return this;
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }

        /**
         * 校验响应体中 json 的对应属性值
         *
         * @param propertyName 属性名
         * @param expectedValue 属性值
         * @return 返回 Result 以便能够链式校验
         */
        public Response property(String propertyName, Object expectedValue) {
            try {
                resultActions.andExpect(jsonPath("$." + propertyName).value(expectedValue));
                return this;
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }

        /**
         * 答应该响应
         *
         * @return 返回 Result 以便能够链式校验
         */
        public Response print() {
            try {
                resultActions.andDo(MockMvcResultHandlers.print());
                return this;
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }

        /**
         * 泛型方法，取出响应体 json 并反序列化为对应类型
         *
         * @param clazz 目标类别
         * @param <T> 泛型 T 即结果类型
         * @return 返回反序列化的结果
         */
        public <T> T getBean(Class<T> clazz) {
            try {
                String json = resultActions.andReturn().getResponse().getContentAsString();
                return JacksonUtil.fromJsonToBean(json, clazz);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }

        /**
         * 泛型方法，取出响应体 json 并反序列化为列表类型
         *
         * @param clazz 目标类别
         * @param <T> 泛型 T 元类型，一般是实体
         * @return 返回反序列化的列表
         */
        public <T> List<T> getList(Class<T> clazz) {
            try {
                String json = resultActions.andReturn().getResponse().getContentAsString();
                return JacksonUtil.fromJsonToList(json, clazz);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }

        /**
         * 泛型方法，取出响应体 json 并反序列化为集合类型
         *
         * @param clazz 目标类别
         * @param <T> 泛型 T 元类型，一般是实体
         * @return 返回反序列化的列表
         */
        public <T> Set<T> getSet(Class<T> clazz) {
            try {
                String json = resultActions.andReturn().getResponse().getContentAsString();
                return JacksonUtil.fromJsonToSet(json, clazz);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }

        /**
         * 泛型方法，取出响应体 json 并反序列化为集合类型
         *
         * @param keyClass 键的类型
         * @param valueClass 值的类型
         * @param <K> 键泛型
         * @param <V> 值泛型
         * @return 返回 map
         */
        public <K, V> Map<K, V> getMap(Class<K> keyClass, Class<V> valueClass) {
            try {
                String json = resultActions.andReturn().getResponse().getContentAsString();
                return JacksonUtil.fromJsonToMap(json, keyClass, valueClass);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
    }
}
```
- 基于修改后的 BaseWebTest，我们修改对应的 ProductControllerTest
```java
public class ProductControllerTest extends BaseWebTest {

    @Test
    public void add() {

        // 商品，作为请求的 body 部分（即 content）
        Product product = Product.builder()
                .name("阿尔宙斯")
                .cid1(2L)
                .cid2(101L)
                .description("xxxxx")
                .price(439.0f)
                .build();

        // 正常保存
        post("/product").body(product).header("Authorization", "token") // 构造请求
                .execute() // 执行请求，得到 Response
                .checkStatus(HttpStatus.HTTP_OK)
                .existProperty("status")
                .existProperty("message")
                .print();

        // 保存一个名字冲突的 product，会得到 400 错误（由于在保存时做了校验因此会得到 400）
        product.setName("妙蛙种子");
        post("/product").body(product).header("Authorization", "token") // 构造请求
                .execute()
                .checkStatus(HttpStatus.HTTP_BAD_REQUEST)
                .existProperty("status")
                .existProperty("message")
                .print();
    }

    @Test
    public void addForm() {
        // 测试表单类型请求，参数通过 param 设置而不是放置到请求体
        post("/product/form").param("name", "阿尔宙斯")
                .param("cid1", "1")
                .param("cid2", "101")
                .param("price", "100")
                .execute() // 执行请求
                .checkStatus(HttpStatus.HTTP_OK)
                .existProperty("status")
                .existProperty("message")
                .print();
    }

    @Test
    public void delete() {
        // 删除存在的记录是 200
        delete("/product/1").execute()
                .checkStatus(HttpStatus.HTTP_OK)
                .existProperty("status")
                .existProperty("message");

        // 删除不存在的记录是 404
        delete("/product/10086").execute()
                .checkStatus(HttpStatus.HTTP_NOT_FOUND)
                .existProperty("status")
                .existProperty("message");
    }

    @Test
    public void update() {
        Product product = Product.builder()
                .name("aaa")
                .build();

        // 注意这三个请求在同一个事务，因此若先正常更新，则导致名称更新为 aaa，则更新不存在的记录时将导致 400
        // 因此要先测试 404

        // 更新不存在的记录，404
        put("/product/11111111").body(product).execute()
                .checkStatus(HttpStatus.HTTP_NOT_FOUND)
                .existProperty("status")
                .existProperty("message");

        // 正常更新 200
        put("/product/1").body(product).execute()
                .checkStatus(HttpStatus.HTTP_OK)
                .existProperty("status")
                .existProperty("message");

        // 更新已存在的名字，400
        product.setName("妙蛙花");
        put("/product/1").body(product).execute()
                .checkStatus(HttpStatus.HTTP_BAD_REQUEST)
                .existProperty("status")
                .existProperty("message");
    }

    @Test
    public void get() {
        // 取出不存在的记录
        get("/product/111111").execute()
                .checkStatus(HttpStatus.HTTP_NOT_FOUND)
                .existProperty("status")
                .existProperty("message");


        // 正常取出
        get("/product/1").header("Authorization", "token").execute()
                .checkStatus(HttpStatus.HTTP_OK)
                .checkPropertyValue("id", 1)
                .checkPropertyValue("name", "妙蛙种子")
                .checkPropertyValue("price", 318)
                .checkPropertyValue("cid1", 1L)
                .checkPropertyValue("cid2", 101L);
    }

    @Test
    public void list() {
        // 模拟请求
        MockHttpServletRequestBuilder request = MockMvcRequestBuilders.get("/product");

        PageBean pageBean = get("/product").param("pageSize", "6").execute()
                .getBody(PageBean.class);

        // 共 15 条，每页 6 条，共 3 页
        assertEquals(15, pageBean.getTotal());
        assertEquals(3, pageBean.getPages());
        assertEquals(6, pageBean.getList().size());
    }
}
```
- 可以看到，通过使用封装后的 Request 和 Response，测试代码不再含有大量的冗余代码，可以很方便地构造请求、测试响应