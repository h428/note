

# 1. 使用 explain 查询 sql


- 使用到的数据库参见尾部，s, c, sc 三张表（根据数据库系统概论中的表做的简单修改）
- 语法 : `explain sql`，例如 `explain select * from admin`
- explain 默认显示 9 列信息，包括 id, select_type, table, type, possible_keys, key, key_len, ref, rows, extra，此外还可以额外扩展显示 partitions 和 filtered 
- id : select 语句的标识符，每个 select 都会被分配到一个唯一 id
- select_type : 该 select 查询的类型
    - SIMPLE, 表示此查询不包含 UNION 查询或子查询
    - PRIMARY, 表示此查询是最外层的查询
    - UNION, 表示此查询是 UNION 的第二或随后的查询
    - DEPENDENT UNION, UNION 中的第二个或后面的查询语句, 取决于外面的查询
    - UNION RESULT, UNION 的结果
    - SUBQUERY, 子查询中的第一个 SELECT
    - DEPENDENT SUBQUERY: 子查询中的第一个 SELECT, 取决于外面的查询. 即子查询依赖于外层查询的结果.
- table : 该 select 查询的是哪个表，可能是联合表
- **type** : 连接类型，重要评估指标，显示该查询是否高效
    - 通过 type 字段, 我们判断此次查询是**全表扫描**还是**索引扫描**等
    - system : const 的特殊情况，一般出现在连接查询中，表示目标表中只有一条数据，例如 `explain select * from (select * from s where s.id = 1) s2;` 的第一个 select 的 type 就是 system
    - const : 针对主键或唯一索引的等值查询扫描, 最多只返回一行数据, const 查询速度非常快, 因为它仅仅读取一次即可，例如 `explain select * from s where s.id = 1;`
    - eq_ref : 通常出现在多表连接查询，表示对于前一个表的每一个结果，都只能匹配到后一张表的一行结果，查询比较操作符通常是 =，效率极高，例如 `explain select * from sc join s on sc.sid = s.id;` 中的 s，对于每个 sc 记录，s 都只能匹配到一条
    - > 需要注意的是，`explain select * from s join sc on sc.sid = s.id;`，数据量很少式， mysql 将对 s 进行全表扫描，而数据量足够多时或者一定时间后，mysql 会进行索引优化，达到和前面的语句相同的结果
    - ref : 通常出现在多表连接查询（连接字段带索引）和以索引字段为查询条件的单表查询，对于非唯一、非主键的索引，或者查询时触发最左前缀规则索引的查询，就是该种类型，例如 `explain select * from s where sname = 'a';` 和 `explain select * from sc where sid = 1;`
    - range : 以索引列为条件做范围查询，该类型通常出现在索引列的 `=, <>, >, >=, <, <=, IS NULL, <=>, BETWEEN, IN()` 操作中，非索引列则会导致全表扫描，例如 `explain select * from s where id > 2;` 就是 range 类型，再比如 `explain select * from s where id between 2 and 8;` 的结果也是 range 类型
    - > 一个好的 SQL 应该至少达到 range 级别，否则将导致全表扫描
    - index : 全索引扫描，和 ALL 类似，只不错该种情况查询的索引，不需要扫表，只需要扫索引，例如 `explain select id, sname from s;` 查询所有的 id, sname，但由于 sname 存在索引，因此不用扫描全表而是扫描索引即可，若加上非索引列将导致全表扫描
    - all : 全表扫描，在数据量大的情况下将是一个灾难，全表扫描时，possible_keys 和 key 字段都是 NULL, 表示没有使用到索引, 并且 rows 十分巨大, 因此整个查询效率是十分低下的，例如 `explain select id, sname, sage from s;` 将导致全表扫描
- possible_keys : mysql 在查询时能够使用到的索引（但注意不是真正的用到）
- key : 查询时真正使用到的索引，如果没有使用索引则为 NULL
- key_len : 优化器使用了索引的字节数. 这个字段可以评估组合索引是否完全被使用, 或只有最左部分字段被使用到
- ref : 哪个字段或常数与 key 一起被使用
- rows : 查询优化器根据统计信息, 估算 SQL 要查找到结果集需要扫描读取的数据行数，这个值非常直观显示 SQL 的效率好坏, 原则上 rows 越少越好
- extra : 通常显示一些额外的影响效率的东西，例如 Using filesort 时, 表示 MySQL 需额外的排序操作, 不能通过索引顺序达到排序效果，有 Using filesort 时, 都建议优化去掉, 因为这样的查询 CPU 资源消耗大；Using temporary 也是不好的值，
- 比较重要的几个字段，可用于分析 sql 效率：type, key, key_len, rows, extra
    - type : 一个好的 sql 要




- user_info, order_info

```sql
drop table if exists user_info;
CREATE TABLE `user_info` (
  `id`   BIGINT(20)  NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL DEFAULT '',
  `age`  INT(11)              DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `name_index` (`name`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

INSERT INTO user_info (name, age) VALUES ('xys', 20);
INSERT INTO user_info (name, age) VALUES ('a', 21);
INSERT INTO user_info (name, age) VALUES ('b', 23);
INSERT INTO user_info (name, age) VALUES ('c', 50);
INSERT INTO user_info (name, age) VALUES ('d', 15);
INSERT INTO user_info (name, age) VALUES ('e', 20);
INSERT INTO user_info (name, age) VALUES ('f', 21);
INSERT INTO user_info (name, age) VALUES ('g', 23);
INSERT INTO user_info (name, age) VALUES ('h', 50);
INSERT INTO user_info (name, age) VALUES ('i', 15);

drop table if exists order_info;
CREATE TABLE `order_info` (
  `id`           BIGINT(20)  NOT NULL AUTO_INCREMENT,
  `user_id`      BIGINT(20)           DEFAULT NULL,
  `product_name` VARCHAR(50) NOT NULL DEFAULT '',
  `productor`    VARCHAR(30)          DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_product_detail_index` (`user_id`, `product_name`, `productor`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

INSERT INTO order_info (user_id, product_name, productor) VALUES (1, 'p1', 'WHH');
INSERT INTO order_info (user_id, product_name, productor) VALUES (1, 'p2', 'WL');
INSERT INTO order_info (user_id, product_name, productor) VALUES (1, 'p1', 'DX');
INSERT INTO order_info (user_id, product_name, productor) VALUES (2, 'p1', 'WHH');
INSERT INTO order_info (user_id, product_name, productor) VALUES (2, 'p5', 'WL');
INSERT INTO order_info (user_id, product_name, productor) VALUES (3, 'p3', 'MA');
INSERT INTO order_info (user_id, product_name, productor) VALUES (4, 'p1', 'WHH');
INSERT INTO order_info (user_id, product_name, productor) VALUES (6, 'p1', 'WHH');
INSERT INTO order_info (user_id, product_name, productor) VALUES (9, 'p8', 'TE');
```

- s, c, sc
```sql
drop table if exists s;
create table s (
    id int auto_increment,
    sname varchar(30),
    sage int,
    primary key (id),
    key sname_index (sname)
);

insert into s values(1, 'hao1', 21);
insert into s values(2, 'hao2', 22);
insert into s values(3, 'hao3', 23);
insert into s values(4, 'hao4', 24);
insert into s values(5, 'hao5', 24);
insert into s values(6, 'hao6', 24);
insert into s values(7, 'hao7', 24);
insert into s values(8, 'hao8', 24);
insert into s values(9, 'hao9', 24);
insert into s values(10, 'hao10', 24);


drop table if exists c;
create table c (
    id int primary key,
    cname varchar(30),
    ccredit int,
    key cname_index (cname)
);

insert into c values(1, 'c', 4);
insert into c values(2, 'java', 4);
insert into c values(3, 'os', 4);
insert into c values(4, 'py', 4);
insert into c values(5, 'c#', 4);
insert into c values(6, 'c++', 4);
insert into c values(7, 'html', 4);
insert into c values(8, 'css', 4);
insert into c values(9, 'js', 4);
insert into c values(10, 'jquery', 4);


drop table if exists sc;
create table sc (
    id int auto_increment,
    sid int,
    cid int,
    score int,
    primary key(id),
    key sid_cid_score_index (sid, cid, score)
);

insert into sc values(1, 1, 1, 81);
insert into sc values(2, 1, 2, 82);
insert into sc values(3, 1, 3, 92);
insert into sc values(4, 2, 2, 93);
insert into sc values(5, 2, 3, 93);
insert into sc values(6, 2, 4, 94);
insert into sc values(7, 3, 3, 94);
insert into sc values(8, 4, 4, 94);
insert into sc values(9, 6, 6, 94);
insert into sc values(10, 9, 9, 94);
```

```sql
explain select * from s, sc where s.id = sc.sid;
explain select * from sc, s where s.id = sc.sid;

explain select * from s join sc on s.id = sc.sid;
explain select * from sc join s on s.id = sc.sid;
```