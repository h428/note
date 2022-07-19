
# 1. 安装

- 在 solr 目录提供下述 `docker-compose.yml` 文件 : 
```yml
version: '3.1'
services:
  solr:
    build: ikanalyzer
    restart: always
    container_name: solr
    ports:
      - 8983:8983
    volumes:
      - data:/opt/solrdata
volumes:
  data:
```
- 清除 :
```
docker-compose down
docker volume rm solr_data
```

- ikanalyzer 中文分词器镜像 :
```docker
FROM solr:7.2

MAINTAINER Lusifer <topsale@vip.qq.com>

# 创建 Core
WORKDIR /opt/solr/server/solr
RUN mkdir ik_core
WORKDIR /opt/solr/server/solr/ik_core
RUN echo 'name=ik_core' > core.properties
RUN mkdir data
RUN cp -r ../configsets/sample_techproducts_configs/conf/ .

# 安装中文分词
WORKDIR /opt/solr/server/solr-webapp/webapp/WEB-INF/lib
ADD ik-analyzer-solr5-5.x.jar .
ADD solr-analyzer-ik-5.1.0.jar .
WORKDIR /opt/solr/server/solr-webapp/webapp/WEB-INF
ADD ext.dic .
ADD stopword.dic .
ADD IKAnalyzer.cfg.xml .

# 增加分词配置
COPY managed-schema /opt/solr/server/solr/ik_core/conf

WORKDIR /opt/solr
```

- 从上述 Dockerfile 中可看出，还依赖下述配置文件 : 
    - ext.dic
    - IKAnalyzer.cfg.xml
    - ik-analyzer-solr5-5.x.jar
    - solr-analyzer-ik-5.1.0.jar
    - stopword.dic
    - managed-schema 从 solr 7.2.1 中复制的配置文件，然后修改自定义的配置
- 可以自行网上下载，压缩包的名字应该是 ikanalyzer-solr5.zip
- 复制 managed-schema，并添加下述自定义配置，主要是添加分词器相关配置，在尾部添加下述内容
```xml
    <!-- IK分词 -->
    <fieldType name="text_ik" class="solr.TextField">
        <analyzer type="index">
            <tokenizer class="org.apache.lucene.analysis.ik.IKTokenizerFactory" useSmart="false"/>
        </analyzer>
        <analyzer type="query">
            <tokenizer class="org.apache.lucene.analysis.ik.IKTokenizerFactory" useSmart="false"/>
        </analyzer>
    </fieldType>
    
    <!-- 自定义字段域 -->
    <field name="article_source" type="text_ik" indexed="true" stored="true"/>
    <field name="article_title"  type="text_ik" indexed="true" stored="true"/>
    <field name="article_introduction" type="text_ik" indexed="true" stored="true" />
    <field name="article_url" type="string" indexed="false" stored="true" />
    <field name="article_cover" type="string" indexed="false" stored="true" />

    <!-- 复制域（Solr 的搜索优化功能，将多个字段域复制到一个域里，提高查询效率） -->
    <field name="article_keywords" type="text_ik" indexed="true" stored="false" multiValued="true"/>
    <copyField source="article_source" dest="article_keywords"/>
    <copyField source="article_title" dest="article_keywords"/>
    <copyField source="article_introduction" dest="article_keywords"/>
```

- 执行 `docker-compose up -d` 启动
- 访问 `http://192.168.25.33:8983` 查看 solr 是否搭建成功