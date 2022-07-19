

# 1. Elasticsearch 介绍和安装

## 1.1 介绍

- Elasticsearch 是一个全文检索技术，例如以前学过的 Solr 是同类框架
- [官网](https://www.elastic.co/cn/)，有一条完整的产品线及解决方案：Elasticsearch、Kibana、Logstash 等，前面说的三个就是大家常说的 ELK 技术栈
- 教程使用版本为 6.3.0


## 1.2 安装

### 1. Linux 下安装 Elasticsearch

- elasticsearch-6.3.0.tar.gz 和 elasticsearch-analysis-ik-6.3.0.zip 两个文件，前者为 elasticsearch，后者为分词器插件
- elasticsearch 默认不允许以 root 账号运行，先 `useradd leyou` 创建用户
- 设置密码 `passwd leyou`
- 切换用户 `su - leyou`
- 将安装包上传到当前用户主目录 /home/leyou
- 解压缩 `tar -zxvf elasticsearch-6.2.4.tar.gz`
- 重命名 `mv elasticsearch-6.3.0/ elasticsearch`
- 进入 elasticsearch/config ，编辑 jvm.options 文件
- 默认配置为 ：
```
-Xms1g
-Xmx1g
```
- 内存可能占用太多，调小一点，修改为
```
-Xms512m
-Xmx512m
```
- 编辑 elasticsearch.yml 文件，修改数据和日志记录
```yml
path.data: /home/leyou/elasticsearch/data # 数据目录位置
path.logs: /home/leyou/elasticsearch/logs # 日志目录位置
```
- 然后在 elasticsearch 下创建上述对应目录
```bash
mkdir data
mkdir logs
```
- 继续在 elasticsearch.yml 修改绑定的 ip，设置为允许任何 ip 访问，默认只允许本机访问
```yml
network.host: 0.0.0.0 # 绑定到0.0.0.0，允许任何ip来访问
```
- 此时启动， elasticsearch 会发现会报错，我们还需要解决下述问题
- 内核过低错误：Elasticsearch 的插件要求至少 Linux 内核为 3.5 以上版本，不过没关系，如果内核版本不足我们禁用这个插件即可，编辑 elasticsearch.yml 文件，在最下面添加下述配置
```yml
bootstrap.system_call_filter: false
```
- 文件权限不足错误：`[1]: max file descriptors [4096] for elasticsearch process likely too low, increase to at least [65536]`
- 先转换到 root 用户，然后修改配置文件 `vim /etc/security/limits.conf`，添加下述内容
```
* soft nofile 65536

* hard nofile 131072

* soft nproc 4096

* hard nproc 4096
```
- 线程数不够错误：`[1]: max number of threads [1024] for user [leyou] is too low, increase to at least [4096]`
- 修改 `vim /etc/security/limits.d/90-nproc.conf`，将 `* soft nproc 1024` 修改为 `* soft nproc 4096`
- 进程虚拟内存错误：`[3]: max virtual memory areas vm.max_map_count [65530] likely too low, increase to at least [262144]`
- 修改 `vim /etc/sysctl.conf`，添加内容 `vm.max_map_count=655360` 然后执行命令 `sysctl -p`
- 修改完毕记得重启 shell 和 elasticsearch
- 启动成功后，可以看到 elasticsearch 占用了两个端口
    - 9300：集群节点间通讯接口
    - 9200：客户端访问接口（我们的访问和请求主要通过该接口）
- 在浏览器访问 http://192.168.25.41:9200 查看请求是否成功获取到相关 json


### 2. 安装 kibana 客户端

- Kibana 是一个基于 Node.js 的 Elasticsearch 索引库数据统计工具，即可视化 Elasticsearch 数据，以及方便开发，我们主要使用其内部的 dev 工具
- Kibana 是基于 Node.js 的项目，虚拟机没有安装 Node.js，因此使用 win 版本
- 解压 zip 包，然后修改 config/kibana.yml 文件，修改 elasticsearch 的服务器地址为我们自己的服务器地址 : `elasticsearch.url: "http://192.168.25.41:9200"`，这样 kibana 客户端就会通过该地址访问到我们的 elasticsearch 索引服务器
- 启动 : 双击 bin/kibana.bat  即可
- Kibana 项目监听的端口是 5601，因此我们访问 http://127.0.0.1:5601 即可，接下来就可以使用 Kibana 中的 DevTools 方便地操作 elasticsearch


### 3. 安装 ik 分词器

- Lucene 的 IK 分词器早在 2012 年已经没有维护了，现在我们要使用的是在其基础上维护升级的版本，并且开发为 ElasticSearch 的集成插件了，与 Elasticsearch 一起维护升级，版本也保持一致，最新版本：6.3.0
- 在 linux 中解压 elasticsearch-analysis-ik-6.3.0.zip 到 elasticsearch 的 plugins 目录中即可，注意插件目录名称直接命名为 ik-analyzer
```bash
unzip elasticsearch-analysis-ik-6.3.0.zip -d ik-analyzer
```
- 重启 elasticsearch 即可
- 测试分词 :
```json
POST _analyze
{
  "analyzer": "ik_max_word",
  "text":     "我是中国人"
}
```

## 1.3 API 语法

- Elasticsearch 提供了多种 API，但最通用的就是基于 http 的 restful 风格的 api，因此我们学习使用这一种
- restful 请求可以利用 postman 这类工具发起，请求体为 application/json 类型，但这样每次学习和测试时比较繁琐，而 kibana 中的 devtools 提供了快速的 restful 访问方式，只需写请求类型、请求地址，之后跟上 json 作为请求体即可，其实本质还是 http 请求，后面操作都写成 kibana 中的格式，只要能自己转化即可
- 例如，前面的 "我是中国人" 的分词测试，本质上是对 `http://192.168.25.41:9200/_analyze` 执行的 post 请求，请求体类型为 application/json，值即为下面的 json，可以自行使用 postman 进行测试


# 2. 常用操作

## 2.1 基本概念

- Elasticsearch 也是基于 Lucene 的全文检索库，本质也是存储数据，很多概念与 MySQL 类似的
- 它们的对应关系如下：
```
索引（indices）--------------------------------Databases 数据库

  类型（type）-----------------------------Table 数据表

     文档（Document）----------------Row 行

	   字段（Field）-------------------Columns 列 
```
- 详细说明：

|概念|说明|
| --- | --- |
| 索引库（indices) | indices是index的复数，代表许多的索引|
| 类型（type）| 类型是模拟mysql中的table概念，一个索引库下可以有不同类型的索引，比如商品索引，订单索引，其数据格式不同。不过这会导致索引库混乱，因此未来版本中会移除这个概念|
| 文档（document）| 存入索引库原始的数据。比如每一条商品信息，就是一个文档|
| 字段（field）| 文档中的属性|
| 映射配置（mappings）| 字段的数据类型、属性、是否索引、是否存储等特性|

- 此外，类似 SolrCloud，Elasticsearch 也有集群相关的概念
    - 索引集（Indices，index的复数）：逻辑上的完整索引 collection1 
    - 分片（shard）：数据拆分后的各个部分
    - 副本（replica）：每个分片的复制
- 要注意的是：Elasticsearch 本身就是分布式的，因此即便你只有一个节点，Elasticsearch 默认也会对你的数据进行分片和副本操作，当你向集群添加新数据时，数据也会在新加入的节点中进行平衡


## 2.2 索引库 _index 操作（类似 mysql 中的 db）

### 1. 创建/更新索引库

- 创建索引库使用 PUT 请求，请求地址即为索引库的名称，主要参数为 settings
- settings：索引库的设置
    - number_of_shards：分片数量
    - number_of_replicas：副本数量
- 举例：创建名称为 heima 的索引库的请求样例（注意这里是 kibana 中 devtools 的请求格式，其本质还是 restful 格式请求，省略的服务器地址而已）
```json
PUT /heima
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}
```

### 2. 查看索引库

- get 请求 : `GET /索引库名`，例如 `GET /heima`
- 可以使用 * 查询所有索引库 : `GET *`
- 还可以使用 head 请求查看索引库是否存在，例如 `HEAD /heima`，直接根据响应状态码 200, 404 来判定是否存在

### 3. 删除索引库

- delete 请求 : `DELETE /索引库名`，例如 `DELETE /haima`

## 2.3 类型/映射 _type/_mapping 相关操作（类似 mysql 中的表、字段、索引等内容）

- 有了索引库，接下来就需要添加数据了，但在添加数据之前，需要先定义映射（就好像 mysql 中的定义表、列一样）
- 映射 : 映射是定义文档的过程，文档包含哪些字段，这些字段是否保存，是否索引，是否分词等
- 注意，从 ES 6 开始，默认一个 index 库只能有一个 mapping （表）

### 1. 字段属性详解（mysql 中列的类型）

**类型 type**

- 注意这里的 type 是列的数据类型，和前面提到的 _type 不一样，_type 可以理解为 table
- 我们主要介绍几个常用的和关键的数据类型
- String类型，又分两种：
    - text：可分词，不可参与聚合
    - keyword：不可分词，数据会作为完整字段进行匹配，可以参与聚合
- Numerical：数值类型，分两类
    - 基本数据类型：long、interger、short、byte、double、float、half_float
    - 浮点数的高精度类型：scaled_float
    - 需要指定一个精度因子，比如10或100。elasticsearch会把真实值乘以这个因子后存储，取出时再还原
- Date：日期类型，elasticsearch可以对日期格式化为字符串存储，但是建议我们存储为毫秒值，存储为long，节省空间

**索引 index**

- index 设置字段的索引情况
    - true：字段会被索引，则可以用来进行搜索。默认值就是 true
    - false：字段不会被索引，不能用来搜索
- index 的默认值就是 true，也就是说你不进行任何配置，所有字段都会被索引
- 但是有些字段是我们不希望被索引的，比如商品的图片信息，就需要手动设置 index 为 false


**额外存储 store**

- 设置是否将数据额外存储
- 在学习 lucene 和 solr 时，我们知道如果一个字段的 store 设置为 false，那么在文档列表中就不会有这个字段的值，用户的搜索结果中不会显示出来
- 在 Elasticsearch 中，即便 store 设置为 false，也可以搜索到结果
- Elasticsearch 在创建文档索引时，会将文档中的原始数据备份，保存到一个叫做 _source 的属性中，而且我们可以通过过滤 _source 来选择哪些要显示，哪些不显示
- 如果设置 store 为 true，就会在 _source 以外额外存储一份数据，多余，因此一般我们都会将 store 设置为 false，事实上，store 的默认值就是 false

**激励因子 boost**

- 激励因子，这个与 lucene 中一样
- 详情可参考官方文档

### 2. 创建/更新映射（类似 mysql 中的表、字段）

- 创建表时称为 _mapping，而查询数据时，所属的表的 key 则会描述为 _type，注意区别
- PUT 请求，参数格式如下：
```json
PUT /索引库名/_mapping/类型名称(表名)
{
  "properties": {
    "字段名": {
      "type": "类型",
      "index": true，
      "store": true，
      "analyzer": "分词器"
    }
  }
}
```

### 3. 查看映射

- 语法 : `GET /索引库名/_mapping`，例如 `GET /heima/_mapping`，可以得到下述响应
```json
{
  "heima": {
    "mappings": {
      "goods": {
        "properties": {
          "images": {
            "type": "keyword",
            "index": false
          },
          "price": {
            "type": "float"
          },
          "title": {
            "type": "text",
            "analyzer": "ik_max_word"
          }
        }
      }
    }
  }
}
```

## 2.4 数据操作（mysql 中的 crud）

### 1. 新增数据

**随机 id**

- 使用 POST 请求，可以向一个已存在的索引库中添加数据，语法如下：
```json
POST /索引库名/类型名
{
    "key":"value"
}
```
- 例如下述请求会在 heima 索引库的 goods 表中插入一条数据，id 为随机值
```json
POST /heima/goods/
{
    "title":"小米手机",
    "images":"http://image.leyou.com/12479122.jpg",
    "price":2699.00
}
```
- 上述请求得到如下响应，可以看出 id 是随机值（删除时要用到）
```json
{
  "_index": "heima",
  "_type": "goods",
  "_id": "r9c1KGMBIhaxtY5rlRKv",
  "_version": 1,
  "result": "created",
  "_shards": {
    "total": 3,
    "successful": 1,
    "failed": 0
  },
  "_seq_no": 0,
  "_primary_term": 2
}
```
- 使用 get 查看数据，详情查看**查看数据**部分笔记，这也是数据操作的最难掌握的内容
- 暂时可以使用下述请求查询所有索引库下的所有数据，其他查询方式后续再学习
```json
get _search
{
    "query":{
        "match_all":{}
    }
}
```

**自定义 id（常用）**

- 插入数据时，也可以指定 id，语法如下：
```json
POST /索引库名/表名(_type)/id值
{
    ...
}
```
- 例如下面的例子，在 heima 索引库的 goods 表（也叫 type）中插入一条数据，id 为 2（删除时要用到 id）
```json
POST /heima/goods/2
{
    "title":"大米手机",
    "images":"http://image.leyou.com/12479122.jpg",
    "price":2899.00
}
```

**智能判断**

- 学习 Solr 时我们发现，我们在新增数据时，只能使用提前配置好映射属性的字段，否则就会报错，但在 Elasticsearch 中并没有这样的规定
- elasticsearch 非常智能，你不需要给索引库设置任何 mapping 映射（即不定义表、字段），它也可以根据你输入的数据来判断类型，动态添加或修改数据映射（但要注意 mapping 和现有 mapping 名称不能冲突，因为默认一个 index 只能有一个 mapping）
- 甚至可以连 index 都不创建，直接插入数据，elasticsearch 会直接创建 index 和 mapping，此时对于 index 相关属性会采取默认值
- 假设不存在名为 heima99 的 index 以及其下的名为 haha 的 mapping，则下述请求会创建一个名为 heima99 的 index，以及在内部创建一个 haha 的 mapping，其中 heima99 的参数采用默认值，而 haha 映射的列即为插入数据的列 aaa, bbb, ccc, ddd, eee，
```json
POST /heima99/goods/3
{
    "aaa":"超米手机",
    "bbb":"http://image.leyou.com/12479122.jpg",
    "ccc":2899.00,
    "ddd": 200,
    "eee":true
}
```

### 2. 修改数据

- 将前面的 POST 请求改为 PUT 请求，就是修改了，修改时必须指定 id，需要注意：
    - id 对应文档（行、记录）存在，则修改
    - id 对应文档（行、记录）不存在，则新增
- 例如，下述请求对 id 为 3 的数据进行修改
```json
PUT /heima/goods/3
{
    "title":"超大米手机",
    "images":"http://image.leyou.com/12479122.jpg",
    "price":3899.00,
    "stock": 100,
    "saleable":true
}
```

### 3. 删除数据

- 删除数据使用 DELETE 请求，删除时需要提供 id，语法如下：
```
DELETE /索引库名/类型名/id值
```
- 例如，删除 _index:heima 下的 _type:goods 中的 id 为 3 的数据
```
DELETE /heima/goods/3
```

## 2.5 数据查询（见 3）


# 3. 数据操作之查询数据

- 查询相关内容主要包括：基本查询、_source 过滤、结果过滤、高级查询、排序

## 3.1 基本查询

- 查询的基本语法如下：
```json
GET /索引库名/_search
{
    "query":{
        "查询类型":{
            "查询条件":"查询条件值"
        }
    }
}
```
- 其中，查询类型支持 match_all, match, term, rang 等类型
- 而查询条件和查询条件值根据查询类型的不同，会有不同的写法

**查询所有 (match all)**

- query 表示查询对象，match_all 表示查询所有
- 例如，查询所有 _index 下的所有数据：
```json
GET _search
{
    "query":{
        "match_all":{}
    }
}
```
- 查询 _index:heima 下的所有数据：
```json
GET /heima/_search
{
    "query":{
        "match_all":{}
    }
}
```
- 查询结果相关参数分析：
- took : 查询花费的时间，单位是毫秒
- time_out : 是否超时
- _shards : 分片信息
- hists : 搜索结果总对象，其内部包含了搜索结果的所有信息
    - total : 搜索到的总条数
    - max_source : 所有结果中文档（即一条记录）得分的最高分
    - hists : 搜索结存的文档对象数组，每个元素是一条搜索到的文档信息（一条记录）
        - _index : 该记录所在索引库
        - _type : 该记录所在的表
        - _id : 该记录的文档 id
        - _score : 该记录的文档得分
        - _source : 该记录的真正数据部分

**匹配查询 match**

- 对于 match 类型查询，会先对查询条件进行分词，然后把分词后的词语作为条件进行查询，词语间的关系默认是 or，即下面的查询会查到所有和 小米、电视相关的内容
```json
GET /heima/_search
{
    "query":{
        "match":{
            "title":"小米电视"
        }
    }
}
```
- 某些情况，我们可能需要精确查找，希望变成 and 关系，则可以这样：
```json
GET /heima/_search
{
    "query":{
        "match": {
          "title": {
            "query": "小米电视",
            "operator": "and"
          }
        }
    }
}
```
- 在 or 与 and 间二选一有点过于非黑即白，如果用户给定的条件分词后有 5 个查询词项，想查找只包含其中 4 个词的文档，该如何处理？将 operator 操作符参数设置成 and 只会将此文档排除
- 有时候这正是我们期望的，但在全文搜索的大多数应用场景下，我们既想包含那些可能相关的文档，同时又排除那些不太相关的。换句话说，我们想要处于中间某种结果
- match 查询支持 minimum_should_match 最小匹配参数， 这让我们可以指定必须匹配的词项数用来表示一个文档是否相关。我们可以将其设置为某个具体数字，更常用的做法是将其设置为一个百分数，因为我们无法控制用户搜索时输入的单词数量，例如下述查询
```json
GET /heima/_search
{
    "query":{
        "match":{
            "title":{
            	"query":"小米曲面电视",
            	"minimum_should_match": "75%"
            }
        }
    }
}
```
- 本例中，搜索语句可以分为 3 个词，如果使用 and 关系，需要同时满足 3 个词才会被搜索到。这里我们采用最小品牌数：75%，那么也就是说只要匹配到总词条数量的 75% 即可，这里 3*75%=2.25 截尾后为 2，所以只要包含 2 个词条就算满足条件了

**多字段查询 (multi_match)**

- multi_match 与 match 类似，不同的是它可以在多个字段中查询，例如下述例子，会将 title 和 subTitle 中包含小米的记录都查出来
```json
GET /heima/_search
{
    "query":{
        "multi_match": {
            "query":    "小米",
            "fields":   [ "title", "subTitle" ]
        }
	}
}
```

**词条匹配 (term)**

- term 类型的查询被用于 精确值 匹配，这些精确值可能是数字、时间、布尔或者那些**未分词**的字符串
- 注意，对于字符串类型，term 不对查询条件做分词，而是直接拿查询条件和 index 中记录分词后的结果进行比对，特别要注意的一点是 index 中的记录是会分词的，例如 index 库中的记录的标题为 "小米手机和电视"，其分词后分别为 "小米、手机、和、电视"，并不包括 "小米手机" 这个分词，此时，以 "小米手机" 为查询条件进行 term 类型的查询，并不会查询出该条记录，尽管该记录包含了 "小米手机" 这四个字
- term 查询的语法如下：
```json
GET /heima/_search
{
    "query":{
        "term":{
            "price":2699.00
        }
    }
}
```

**多词条精确匹配 (terms)**

- terms 查询和 term 查询一样，但其允许你指定多值进行匹配，只要包含了指定值中的任何一个即为满足查询条件，如下述例子
```json
GET /heima/_search
{
    "query":{
        "terms":{
            "price":[2699.00,2899.00,3899.00]
        }
    }
}
```

## 3.2 结果过滤（过滤列）

- 默认情况下，elasticsearch 在搜索的结果中，会把文档保存在 _source 的所有字段都返回
- 如果我们只想获取其中的部分列，可以添加对 _source 的过滤

**直接指定想要的字段：数组或 includes**

- 使用数组进行指定想要的字段，例如下述请求
```json
GET /heima/_search
{
  "_source": ["title","price"],
  "query": {
    "term": {
      "price": 2699
    }
  }
}
```
- 使用 includes 指定想要的字段，例如下述请求
```json
GET /heima/_search
{
  "_source": {
    "includes":["title","price"]
  },
  "query": {
    "term": {
      "price": 2699
    }
  }
}
```

**指定要排除的字段：excludes**

- 也可以使用 excludes 指定要排除的字段，例如下述查询
```json
GET /heima/_search
{
  "_source": {
     "excludes": ["images"]
  },
  "query": {
    "term": {
      "price": 2699
    }
  }
}
```

## 3.3 高级查询

**布尔组合 bool**

- bool 把各种查询通过 must, must_not, should 的方式进行组合，按顺序分别表示 与、非、或，请求样例如下
```json
GET /heima/_search
{
    "query":{
        "bool":{
        	"must":     { "match": { "title": "大米" }},
        	"must_not": { "match": { "title":  "电视" }},
        	"should":   { "match": { "title": "手机" }}
        }
    }
}
```
- 而且 bool 可以嵌套查询，因此可以使用布尔代数完成复杂的查询

**范围查询 range**

- range 查询找出那些落在指定区间内的数字或者时间，例如下述查询
```json
GET /heima/_search
{
    "query":{
        "range": {
            "price": {
                "gte":  1000.0,
                "lt":   2800.00
            }
    	}
    }
}
```
- range 查询支持下述字符 : gt, gte, lt, lte (greater/less than (equal))

**模糊查询 fuzzy**

- fuzzy 查询是 term 查询的模糊等价，它允许用户搜索词条与实际词条的拼写出现偏差，但是偏差的编辑距离不得超过 2，例如 apple 时，输入 appla 也能查找出来
- 可以通过 fuzziness 来指定允许的编辑距离，但不能超过 2（最多错两个字母）
```json
GET /heima/_search
{
  "query": {
    "fuzzy": {
        "title": {
            "value":"appla",
            "fuzziness":1
        }
    }
  }
}
```

## 3.4 行过滤 filter

**条件查询后进行过滤**

- 所有的查询都会影响到文档的评分及排名，如果我们需要在查询结果中进行过滤，并且不希望过滤条件影响评分，那么就不要把过滤条件作为查询条件来用。而是使用 filter 方式
```json
GET /heima/_search
{
    "query":{
        "bool":{
        	"must":{ "match": { "title": "小米手机" }},
        	"filter":{
                "range":{"price":{"gt":2000.00,"lt":3800.00}}
        	}
        }
    }
}
```
- 注意：filter 内部还可以使用 bool 组合来进行条件过滤

**无条件查询直接过滤**

- 如果一次查询只有过滤，没有查询条件，不希望进行评分，我们可以使用 constant_score 取代只有 filter 语句的 bool 查询。在性能上是完全相同的，但对于提高查询简洁性和清晰度有很大帮助
```json
GET /heima/_search
{
    "query":{
        "constant_score":   {
            "filter": {
            	 "range":{"price":{"gt":2000.00,"lt":3000.00}}
            }
        }
}
```

## 3.5 排序

- sort 可以让我们按照不同的字段进行排序，并且通过 order 指定排序的方式，例如下述例子
```json
GET /heima/_search
{
  "query": {
    "match": {
      "title": "小米手机"
    }
  },
  "sort": [
    {
      "price": {
        "order": "desc"
      }
    }
  ]
}
```
- 支持多字段排序，假定我们想要结合使用 price和 _score（得分） 进行查询，并且匹配的结果首先按照价格排序，然后按照相关性得分排序：
```json
GET /goods/_search
{
    "query":{
        "bool":{
        	"must":{ "match": { "title": "小米手机" }},
        	"filter":{
                "range":{"price":{"gt":200000,"lt":300000}}
        	}
        }
    },
    "sort": [
      { "price": { "order": "desc" }},
      { "_score": { "order": "desc" }}
    ]
}
```

# 4. 聚合 aggregations

- 聚合可以让我们极其方便的实现对数据的统计、分析。例如：
  - 什么品牌的手机最受欢迎？
  - 这些手机的平均价格、最高价格、最低价格？
  - 这些手机每月的销售情况如何？
- 实现这些统计功能的比数据库的 sql 要方便的多，而且查询速度非常快，可以实现实时搜索效果

## 4.1 基本概念

- Elasticsearch 中和聚合相关的内容，主要包括桶和度量

**桶（bucket）**

- 桶(bucket) : 按照某种方式对数据进行分组，每一组数据称作一个桶，例如根据国籍对人划分，可得到中国桶、英国桶、日本桶等
- Elasticsearch 提供的划分桶的方式有很多，下面是比较常见的：
  - Date Histogram Aggregation：根据日期阶梯分组，例如给定阶梯为周，会自动每周分为一组
  - Histogram Aggregation：根据数值阶梯分组，与日期类似
  - Terms Aggregation：根据词条内容分组，词条内容完全匹配的为一组
  - Range Aggregation：数值和日期的范围分组，指定开始和结束，然后按段分组
- bucket aggregations 只负责对数据进行分组，并不进行计算，因此往往 bucket 中往往会嵌套另一种聚合：metrics aggregations 即度量

**度量（metrics）**

- 分组完成以后，我们一般会对组中的数据进行聚合运算，例如求平均值、最大、最小、求和等，这些在 ES 中称为度量
- 比较常用的一些度量聚合方式：
  - Avg Aggregation：求平均值
  - Max Aggregation：求最大值
  - Min Aggregation：求最小值
  - Percentiles Aggregation：求百分比
  - Stats Aggregation：同时返回avg、max、min、sum、count等
  - Sum Aggregation：求和
  - Top hits Aggregation：求前几
  - Value Count Aggregation：求总数
- 为了方便测试，我们导入一些数据，我们先创建索引
```json
PUT /cars
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  },
  "mappings": {
    "transactions": {
      "properties": {
        "color": {
          "type": "keyword"
        },
        "make": {
          "type": "keyword"
        }
      }
    }
  }
}
```
- 注意，在 ES 中，需要进行聚合、排序、过滤的字段其处理方式比较特殊，因此不能被分词。这里我们将 color 和 make 这两个文字类型的字段设置为 keyword 类型，这个类型不会被分词，将来就可以参与聚合
- 导入数据：
```json
POST /cars/transactions/_bulk
{ "index": {}}
{ "price" : 10000, "color" : "red", "make" : "honda", "sold" : "2014-10-28" }
{ "index": {}}
{ "price" : 20000, "color" : "red", "make" : "honda", "sold" : "2014-11-05" }
{ "index": {}}
{ "price" : 30000, "color" : "green", "make" : "ford", "sold" : "2014-05-18" }
{ "index": {}}
{ "price" : 15000, "color" : "blue", "make" : "toyota", "sold" : "2014-07-02" }
{ "index": {}}
{ "price" : 12000, "color" : "green", "make" : "toyota", "sold" : "2014-08-19" }
{ "index": {}}
{ "price" : 20000, "color" : "red", "make" : "honda", "sold" : "2014-11-05" }
{ "index": {}}
{ "price" : 80000, "color" : "red", "make" : "bmw", "sold" : "2014-01-01" }
{ "index": {}}
{ "price" : 25000, "color" : "blue", "make" : "ford", "sold" : "2014-02-12" }
```

## 4.2 聚合为桶

- 按照骑车的颜色 color 来划分桶：
```json
GET /cars/_search
{
    "size" : 0,
    "aggs" : { 
        "popular_colors" : { 
            "terms" : { 
              "field" : "color"
            }
        }
    }
}
```
- size： 查询条数，这里设置为0，因为我们不关心搜索到的数据，只关心聚合结果，提高效率
- aggs：声明这是一个聚合查询，是aggregations的缩写
  - popular_colors：给这次聚合起一个名字，任意。
    - terms：划分桶的方式，这里是根据词条划分
      - field：划分桶的字段
- 上述查询得到如下结果：
```json
{
  "took": 1,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 8,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "popular_colors": {
      "doc_count_error_upper_bound": 0,
      "sum_other_doc_count": 0,
      "buckets": [
        {
          "key": "red",
          "doc_count": 4
        },
        {
          "key": "blue",
          "doc_count": 2
        },
        {
          "key": "green",
          "doc_count": 2
        }
      ]
    }
  }
}
```
- hits：查询结果为空，因为我们设置了size为0
- aggregations：聚合的结果
- popular_colors：我们定义的聚合名称
- buckets：查找到的桶，每个不同的 color 字段值都会形成一个桶
  - key：这个桶对应的color字段的值
  - doc_count：这个桶中的文档数量

## 4.3 桶内度量

- 前面的例子告诉我们每个桶里面的文档数量，这很有用；但通常，我们的应用需要提供更复杂的文档度量，例如最大值、最小值、平均值等
- 要达到次目的，我们需要告诉 Elasticsearch 度量哪个字段，使用何种度量方式进行运算，这些信息要嵌套在桶内，度量的运算会基于桶内的文档进行
- 例如，我们在前面聚合的基础上添加一个求价格的平均值
```json
GET /cars/_search
{
    "size" : 0,
    "aggs" : { 
        "popular_colors" : { 
            "terms" : { 
              "field" : "color"
            },
            "aggs":{
                "avg_price": { 
                   "avg": {
                      "field": "price" 
                   }
                }
            }
        }
    }
}
```
- aggs：我们在上一个 aggs(popular_colors) 中添加新的 aggs，可见度量也是一个聚合
- avg_price：聚合的名称
- avg：度量的类型，这里是求平均值
- field：度量运算的字段

## 4.4 桶内嵌套桶

- 刚刚的案例中，我们在桶内嵌套度量运算。事实上桶不仅可以嵌套运算， 还可以再嵌套其它桶。也就是说在每个分组中，再分更多组
- 比如：我们想统计每种颜色的汽车中，分别属于哪个制造商，按照 make 字段再进行分桶
```json
GET /cars/_search
{
    "size" : 0,
    "aggs" : { 
        "popular_colors" : { 
            "terms" : { 
              "field" : "color"
            },
            "aggs":{
                "avg_price": { 
                   "avg": {
                      "field": "price" 
                   }
                },
                "maker":{
                    "terms":{
                        "field":"make"
                    }
                }
            }
        }
    }
}
```

- 原来的 color 桶和 avg 计算我们不变
- maker：在嵌套的 aggs 下新添一个桶，叫做 maker
- terms：桶的划分类型依然是词条
- filed：这里根据 make 字段进行划分
- 执行上述请求后分析结果，我们可以看到，新的聚合 maker 被嵌套在原来每一个 color 的桶中。
- 每个颜色下面都根据 make 字段进行了分组
- 我们能读取到的信息：
  - 红色车共有4辆
  - 红色车的平均售价是 $32，500 美元。
  - 其中3辆是 Honda 本田制造，1辆是 BMW 宝马制造。

## 4.5 划分桶的其它方式

### 1. 阶梯分桶 Histogram

- histogram 是把数值类型的字段，按照一定的阶梯大小进行分组。你需要指定一个阶梯值（interval）来划分阶梯大小，比如你有价格字段，如果你设定 interval 的值为 200，那么阶梯就会是这样的 0，200，400，600 ...（列出的值是区间的起点），并把这些起点值作为 key
- 除了间隔 interval，还有一个初始偏移 offset，默认为 0，则 value 落入区间的计算公式为：
```js
bucket_key = Math.floor((value - offset) / interval) * interval + offset
```
- 例如 `key = Math.floor((450 - 0) / 200) * 200 + 0 = 400`
- 我们对汽车的价格进行分组，指定间隔 interval 为5000：
```json
GET /cars/_search
{
  "size":0,
  "aggs":{
    "price":{
      "histogram": {
        "field": "price",
        "interval": 5000
      }
    }
  }
}
```
- 默认情况下，中间有大量的文档数量为 0 的桶，看起来很丑，我们可以增加一个参数 min_doc_count 为 1，来约束最少文档数量为 1，这样文档数量为 0 的桶会被过滤：
```json
GET /cars/_search
{
  "size":0,
  "aggs":{
    "price":{
      "histogram": {
        "field": "price",
        "interval": 5000,
        "min_doc_count": 1
      }
    }
  }
}
```
- 可以利用 kibana 将结果变为柱形图，在 visualize 中查看

### 2. 范围分桶 range

- 范围分桶与阶梯分桶类似，也是把数字按照阶段进行分组，只不过 range 方式需要你自己指定每一组的起始和结束大小

# 5. Spring Data Elasticsearch

- Elasticsearch 提供的 Java 客户端有一些不太方便的地方：
    - 很多地方需要拼接 Json 字符串，在java中拼接字符串有多恐怖你应该懂的
    - 需要自己把对象序列化为 json 存储
    - 查询到结果也需要自己反序列化为对象
- 因此，我们这里就不讲解原生的 Elasticsearch 客户端 API 了，而是学习 Spring 提供的套件：Spring Data Elasticsearch

## 5.1 简介

- Spring Data Elasticsearch 是 Spring Data 项目下的一个子模块
- Spring Data 的使命是为数据访问提供熟悉且一致的基于 Spring 的编程模型，同时仍保留底层数据存储的特殊特性
- 它使得使用数据访问技术，关系数据库和非关系数据库，map-reduce 框架和基于云的数据服务变得容易
- 这是一个总括项目，其中包含许多特定于给定数据库的子项目，这些令人兴奋的技术项目背后，是由许多公司和开发人员合作开发的
- Spring Data 的使命是给各种数据访问提供统一的编程接口，不管是关系型数据库（如 MySQL ），还是非关系数据库（如 Redis ），或者类似 Elasticsearch 这样的索引数据库，从而简化开发人员的代码，提高开发效率，其包含很多不同数据操作的模块
- 特征：
    - 支持 Spring 的基于 @Configuration 的 java 配置方式，或者 XML 配置方式
    - 提供了用于操作 ES 的便捷工具类 ElasticsearchTemplate，包括实现文档到 POJO 之间的自动智能映射
    - 利用 Spring 的数据转换服务实现的功能丰富的对象映射
    - 基于注解的元数据映射方式，而且可扩展以支持更多不同的数据格式
    - 根据持久层接口自动生成对应实现方法，无需人工编写基本操作代码（类似 mybatis，根据接口自动得到实现）。当然，也支持人工定制查询

## 5.2 Demo 以及 index 操作

- 基于 spring boot，主要引入 spring-boot-starter-data-elasticsearch ，则已经启用了 elasticsearch
- 创建 pojo，配置对应的 index 和 mapping :
```java
@Document(indexName = "item",type = "docs", shards = 1, replicas = 0)
public class Item {
    @Id
    Long id;
    @Field(type = FieldType.Text, analyzer = "ik_max_word")
    String title; //标题
    @Field(type = FieldType.Keyword)
    String category;// 分类
    @Field(type = FieldType.Keyword)
    String brand; // 品牌
    @Field(type = FieldType.Double)
    Double price; // 价格
    @Field(index = false, type = FieldType.Keyword)
    String images; // 图片地址
}
```
- 配置 elasticsearch 服务器地址：
```yml
spring:
  data:
    elasticsearch:
      cluster-name: elasticsearch
      cluster-nodes: 192.168.56.101:9300
```
- 配置 spring boot 配置类，无需额外配置
```java
@SpringBootApplication
public class ElasticsearchApplication {
    public static void main(String[] args) {
        SpringApplication.run(ElasticsearchApplication.class);
    }
}
```
- 执行单元测试测试索引库相关操作即可，主要是增删
```java
@SpringBootTest(classes = ElasticsearchApplication.class)
@RunWith(SpringRunner.class)
public class ElasticsearchTest {
    @Autowired
    private ElasticsearchTemplate template;

    @Test
    public void testIndex() {
        // 创建 index（索引库）
        this.template.createIndex(Item.class);
        // 创建 mapping（相当于数据表映射，一般一个库只能有一个映射）
        this.template.putMapping(Item.class);
    }

    @Test
    public void testDeleteIndex() {
//        this.template.deleteIndex(Item.class);
        this.template.deleteIndex("item");
    }
}
```

## 5.3 文档操作（CRUD）

- 最基本的文档操作主要利用 ElasticsearchRepository 接口，其定义了基本的查询方法，我们只需定义自己的接口，并继承该接口即可，然后在需要的地方注入自定义接口即可
- 需要注意，我们只需定义接口而不需提供实现，Spring 已经为我们写好了实现，我们只需注入使用即可
- 下面是我们自定义的接口，其继承了 ElasticsearchRepository 接口（接口内可以自定义方法并按规定定制方法名，Spring 会自动实现，后面再讲）
```java
public interface ItemRepository extends ElasticsearchRepository<Item,Long> {
}
```
- 然后在单元测试中测试 CRUD 即可：
```java
@SpringBootTest(classes = ElasticsearchApplication.class)
@RunWith(SpringRunner.class)
public class ElasticsearchTest {
    @Autowired
    private ItemRepository itemRepository;

    // 新增或修改文档，id 作为标识符
    @Test
    public void testAddRow() {
        Item item = new Item(1L, "小米手机7", " 手机",
                "小米", 3499.00, "http://image.leyou.com/13123.jpg");
        this.itemRepository.save(item);
    }

    // 批量新增或修改，id 作为标识符
    @Test
    public void testAddList() {
        List<Item> list = new ArrayList<>();
        list.add(new Item(2L, "坚果手机R1", " 手机", "锤子", 3699.00, "http://image.leyou.com/123.jpg"));
        list.add(new Item(3L, "华为META10", " 手机", "华为", 4499.00, "http://image.leyou.com/3.jpg"));
        // 接收对象集合，实现批量新增
        this.itemRepository.saveAll(list);
    }

    // 基本查询
    @Test
    public void testFind() {
        // 根据 id 查询
        Optional<Item> optional = this.itemRepository.findById(1L);
        System.out.println(optional.get());
        // 查询全部并按照价格降序排序
        Iterable<Item> itemIterable = this.itemRepository.findAll(Sort.by(Sort.Direction.DESC, "price"));
        itemIterable.forEach(item -> System.out.println(item));
    }
}
```

## 5.4 自定义方法

- Spring Data 的另一个强大功能，是根据方法名称自动实现功能
- 比如：你的方法名叫做：findByTitle，那么它就知道你是根据 title 查询，然后自动帮你完成，无需写实现类，当然，方法名称要符合一定的约定
- 例如 : findByNameAndPrice, findByNameOrPrice, findByName, findByNameNot, findByPriceBetween, findByPriceLessThan, findByPriceGreaterThan, findByPriceBefore, findByPriceAfter, findByNameLike, findByNameStartingWith, findByNameEndingWith, findByNameContaining, findByNameIn(Collection<String>names), findByNameNotIn(Collection<String>names), findByStoreNear, findByAvailableTrue, findByAvailableFalse, findByAvailableTrueOrderByNameDesc
- 例如我们按约定添加如下方法：
```java
public interface ItemRepository extends ElasticsearchRepository<Item,Long> {
    /**
     * 根据价格区间查询
     * @param price1
     * @param price2
     * @return
     */
    List<Item> findByPriceBetween(double price1, double price2);
}
```
- 不必编写实现类，直接运行接口
```java
@Test
public void queryByPriceBetween(){
    List<Item> list = this.itemRepository.findByPriceBetween(2000.00, 3500.00);
    for (Item item : list) {
        System.out.println("item = " + item);
    }
}
```


## 5.5 高级查询

### 1. 基本查询（利用 QueryBuilders）

- 虽然基本查询和自定义方法已经很强大了，但是如果是复杂查询（模糊、通配符、词条查询等）就显得力不从心了。此时，我们只能使用原生查询
- Repository 的 search 方法，其需要 QueryBuilder 参数，其指代查询的自定义条件
- ElasticSearch 为我们提供了一个对象 QueryBuilders，提供了大量的静态方法，用于生成各种不同类型的 QueryBuilder 对象，例如：词条、模糊、通配符等
- elasticsearch 提供很多可用的查询方式，但是不够灵活。如果想玩过滤或者聚合查询等就很难了
```java
@Test
public void testQuery(){
    // 词条查询
    MatchQueryBuilder queryBuilder = QueryBuilders.matchQuery("title", "小米");
    // 执行查询
    Iterable<Item> items = this.itemRepository.search(queryBuilder);
    items.forEach(System.out::println);
}
```


### 2. 自定义查询

- 以常见的 match 查询为例，我们构造查询对象
```java
@Test
public void testNativeQuery(){
    // 构建查询条件
    NativeSearchQueryBuilder queryBuilder = new NativeSearchQueryBuilder();
    // 添加基本的分词查询
    queryBuilder.withQuery(QueryBuilders.matchQuery("title", "小米"));
    // 执行搜索，获取结果
    Page<Item> items = this.itemRepository.search(queryBuilder.build());
    // 打印总条数
    System.out.println(items.getTotalElements());
    // 打印总页数
    System.out.println(items.getTotalPages());
    items.forEach(System.out::println);
}
```
- `NativeSearchQueryBuilder`：Spring提供的一个查询条件构建器，帮助构建json格式的请求体
- `Page<item>`：默认是分页查询，因此返回的是一个分页的结果对象，包含属性：
    - totalElements：总条数
    - totalPages：总页数
    - Iterator：迭代器，本身实现了 Iterator 接口，因此可直接迭代得到当前页的数据
    - 其它属性：

### 3. 分页查询

- 利用 NativeSearchQueryBuilder 可以方便的实现分页：
```java
@Test
public void testNativeQuery(){
    // 构建查询条件
    NativeSearchQueryBuilder queryBuilder = new NativeSearchQueryBuilder();
    // 添加基本的分词查询
    queryBuilder.withQuery(QueryBuilders.termQuery("category", "手机"));

    // 初始化分页参数
    int page = 0;
    int size = 3;
    // 设置分页参数
    queryBuilder.withPageable(PageRequest.of(page, size));

    // 执行搜索，获取结果
    Page<Item> items = this.itemRepository.search(queryBuilder.build());
    // 打印总条数
    System.out.println(items.getTotalElements());
    // 打印总页数
    System.out.println(items.getTotalPages());
    // 每页大小
    System.out.println(items.getSize());
    // 当前页
    System.out.println(items.getNumber());
    items.forEach(System.out::println);
}
```
- 可以发现，Elasticsearch 中的分页是从第 0 页开始

### 4. 排序

- 排序也通用通过 NativeSearchQueryBuilder 完成：
```java
@Test
public void testSort(){
    // 构建查询条件
    NativeSearchQueryBuilder queryBuilder = new NativeSearchQueryBuilder();
    // 添加基本的分词查询
    queryBuilder.withQuery(QueryBuilders.termQuery("category", "手机"));

    // 排序
    queryBuilder.withSort(SortBuilders.fieldSort("price").order(SortOrder.DESC));

    // 执行搜索，获取结果
    Page<Item> items = this.itemRepository.search(queryBuilder.build());
    // 打印总条数
    System.out.println(items.getTotalElements());
    items.forEach(System.out::println);
}
```

## 5.6 聚合

### 1. 聚合为桶

- 桶就是分组，比如这里我们按照品牌 brand 进行分组：
```java
@Test
public void testAgg(){
    NativeSearchQueryBuilder queryBuilder = new NativeSearchQueryBuilder();
    // 不查询任何结果
    queryBuilder.withSourceFilter(new FetchSourceFilter(new String[]{""}, null));
    // 1、添加一个新的聚合，聚合类型为terms，聚合名称为brands，聚合字段为brand
    queryBuilder.addAggregation(
        AggregationBuilders.terms("brands").field("brand"));
    // 2、查询,需要把结果强转为AggregatedPage类型
    AggregatedPage<Item> aggPage = (AggregatedPage<Item>) this.itemRepository.search(queryBuilder.build());
    // 3、解析
    // 3.1、从结果中取出名为brands的那个聚合，
    // 因为是利用String类型字段来进行的term聚合，所以结果要强转为StringTerm类型
    StringTerms agg = (StringTerms) aggPage.getAggregation("brands");
    // 3.2、获取桶
    List<StringTerms.Bucket> buckets = agg.getBuckets();
    // 3.3、遍历
    for (StringTerms.Bucket bucket : buckets) {
        // 3.4、获取桶中的key，即品牌名称
        System.out.println(bucket.getKeyAsString());
        // 3.5、获取桶中的文档数量
        System.out.println(bucket.getDocCount());
    }

}
```
- 关键API：
    - AggregationBuilders：聚合的构建工厂类。所有聚合都由这个类来构建，看看他的静态方法
    - AggregatedPage：聚合查询的结果类。它是 `Page<T>` 的子接口，AggregatedPage 在 Page 功能的基础上，拓展了与聚合相关的功能，它其实就是对聚合结果的一种封装，大家可以对照聚合结果的 JSON 结构来看

### 2. 嵌套聚合，求平均值

```java
@Test
public void testSubAgg(){
    NativeSearchQueryBuilder queryBuilder = new NativeSearchQueryBuilder();
    // 不查询任何结果
    queryBuilder.withSourceFilter(new FetchSourceFilter(new String[]{""}, null));
    // 1、添加一个新的聚合，聚合类型为terms，聚合名称为brands，聚合字段为brand
    queryBuilder.addAggregation(
        AggregationBuilders.terms("brands").field("brand")
        .subAggregation(AggregationBuilders.avg("priceAvg").field("price")) // 在品牌聚合桶内进行嵌套聚合，求平均值
    );
    // 2、查询,需要把结果强转为AggregatedPage类型
    AggregatedPage<Item> aggPage = (AggregatedPage<Item>) this.itemRepository.search(queryBuilder.build());
    // 3、解析
    // 3.1、从结果中取出名为brands的那个聚合，
    // 因为是利用String类型字段来进行的term聚合，所以结果要强转为StringTerm类型
    StringTerms agg = (StringTerms) aggPage.getAggregation("brands");
    // 3.2、获取桶
    List<StringTerms.Bucket> buckets = agg.getBuckets();
    // 3.3、遍历
    for (StringTerms.Bucket bucket : buckets) {
        // 3.4、获取桶中的key，即品牌名称  3.5、获取桶中的文档数量
        System.out.println(bucket.getKeyAsString() + "，共" + bucket.getDocCount() + "台");

        // 3.6.获取子聚合结果：
        InternalAvg avg = (InternalAvg) bucket.getAggregations().asMap().get("priceAvg");
        System.out.println("平均售价：" + avg.getValue());
    }

}
```

