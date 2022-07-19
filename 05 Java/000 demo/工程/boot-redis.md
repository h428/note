
# 1. 项目概述

## 1.1 项目介绍

- com.demo.redis:boot-redis 为基于 spring boot 的 redis demo，十分简单
- 其中，项目中的 RedisService 可以作为一个抽取的工具类使用，我们将它放置到 base-component 中

## 1.2 子包介绍

- 项目以 com.demo.redis 为前缀，子包包含 service
- service : 仅包含 RedisService，抽取了 redis 的常用操作，注意由于要放到 base-component 中，redisTemplate 不能强制注入，而是在有 redis 的项目中才注入

# 2. redis 安装

- 基于 docker 安装 redis 参考 docker 相关笔记
- 连接 Redis 服务，`redis-cli -h 127.0.0.1 –p 6379`，默认连接 `127.0.0.1 : 6379`
- 使用 PING 命令测试客户端和服务端连接是否正常，`redis-cli PING` 或进入 redis-cli 后直接 `PING`
- 可以使用客户端连接测试，更加方便

# 3. redis 操作

## 3.1 库操作

- 默认支持 16 个数据库，对外都是以一个从 0 开始的递增数字命名，可以通过参数 database 来修改默认数据库个数
- 选择 1 号数据库 `select 1`
- 清空所有数据库的数据 `FLUSHALL`
- 清空当前数据库的数据 `FLUSHDB`

## 3.2 数据操作

- 设置值 `set test 123`，默认设置 String 类型（Redis 支持字符串、散列、列表、集合、有序集合这几种数据类型，但一般只用字符串，因为 json 可以表示各个类型）
- 取值 `get test`
- 查看所有键 `keys *`，* 匹配所有字符，? 表示单个字符，`[]` 表示所有括号间的任意字符，可使用-表示范围
- 判断是否存在键 `exists test`，返回 0 或 1
- 删除键 `del test`，返回删除的键的个数
- 查看类型 `type test`，可能返回 string, hash, list, set, zset
- 查看帮助 `help 命令`
- Redis 提供了一个递增数字的功能 `INCR 键名称`，例如多次执行 `INCR num`，若删除 num 后重新 incr 又会重新从 1 开始递增
- 可以设置步长 `INCRBY num 2`，num 步长为 2，即在原来基础上 + 2，若是首次则是 0 + 2
- 向尾部追加 `append test aaa`，返回追加后的字符串的总长度
- 查看字符串长度 `strlen test`，若键不存在则返回 0
- 同时设置多个键值 `MSET key value [key value...]`
- 同时获取多个键值 `MGET key [key...]`
- 查看缓存时间 `TTL test`，默认不设置时是 -1，若设置后超时，则会返回 -2（即键不存在的返回 -2）
- 设置生存时间 `expire test 60`，单位是秒，注意重新设置值会清除生存时间，即生存时间变为 -1，除非重新执行 expire 设置生存时间
- 单点登录，用作缓存用户时，一般要设置生存时间，并且往往会在用户访问时重新刷新设置时间（模拟 Session）