

- sql

```sql
drop database if exists library;
create database library character set utf8 collate utf8_general_ci;
use library;

-- 管理员类型，相当于权限表
create table admin_type (
  id varchar(25) primary key comment 'id',
  name varchar(255) not null comment '管理员类型名称',
  sys_set bit not null default 0 comment '能否系统设置',
  reader_set bit not null default 0 comment '能否读者设置',
  book_set bit not null default 0 comment '能否图书设置',
  borrow_set bit not null default 0 comment '能否借阅设置',
  sys_query bit not null default 1 comment '能否查询系统',
  delete_time bigint  comment '删除时间，null 表示未删除'
);
insert into admin_type values ('1', 'super admin', 1, 1, 1, 1, 1, null);
insert into admin_type values ('2', 'standard admin', 0, 1, 1, 1, 1, null);
insert into admin_type values ('3', 'base admin', 0, 0, 0, 0, 1, null);

-- 管理员表
create table admin (
  id varchar(25) primary key comment 'id',
  username varchar(255) not null comment '登录用户名',
  password varchar(255) comment '登录密码',
  name varchar(255) comment '管理员姓名',
  delete_time bigint comment '删除时间，null 表示未删除',
  admin_type varchar(25) comment '外键，管理员类型',
  foreign key (admin_type) references admin_type(id)
);
insert into admin values ('1', 'tom', 'tom', 'admin tom', null, '1');
insert into admin values ('2', 'jack', 'jack', 'admin jack', null , '1');
insert into admin values ('3', 'cat', 'cat', 'admin cat', null , '2');
insert into admin values ('4', 'dog', 'dog', 'admin dog', null , '3');

-- 读者类型
create table reader_type (
  id varchar(25) primary key comment 'id',
  name varchar(255) not null comment '类型名称',
  allow_borrow_days int comment '借阅天数',
  allow_borrow_nums int comment '借阅数量',
  renew_days int comment '续借天数',
  delay_punish double comment '逾期价格',
  delete_time bigint comment '删除时间，null 表示未删除'
);
insert into reader_type values ('1', '学生', 30, 10, 15, 0.1, null);
insert into reader_type values ('2', '教师', 40, 20, 15, 0.15, null);
insert into reader_type values ('3', '会员', 50, 30, 15, 0.2, null);

-- 读者（借书证）
create table reader (
  id varchar(25) primary key comment 'id',
  paper_no varchar(255) comment '借阅证编号，如果用于学校可以直接用学号',
  barcode varchar(1023) comment '借阅证条形码',
  name varchar(255) not null comment '读者姓名',
  sex bit comment '性别',
  birthday date comment '出生日期',
  telephone varchar(255) comment '联系电话',
  email varchar(255) comment '电子邮件',
  profession varchar(255) comment '读者职业',
  mark varchar(255) comment '借阅者评价',
  create_date date comment '制证日期',
  delete_time bigint comment '删除时间，null 表示未删除',
  reader_type varchar(25) comment '外键，读者类型',
  op_admin varchar(25) comment '外键，操作管理员',
  foreign key (reader_type) references reader_type(id),
  foreign key (op_admin) references admin(id)
);

insert into reader values ('1', '001', 'barcode001', '令狐冲', 0, 19960212, 18099990000, 'lhc@xmu.edu.cn', '程序员', '100, 无不良记录', 20181001, null, '1', '1');
insert into reader values ('2', '002', 'barcode002', '郭靖', 0, 19960212, 18099990000, 'lhc@xmu.edu.cn', '律师', '100, 无不良记录', 20181001, null, '1', '1');
insert into reader values ('3', '003', 'barcode003', '黄蓉', 0, 19960212, 18099990000, 'lhc@xmu.edu.cn', '医生', '100, 无不良记录', 20181001, null, '1', '1');
insert into reader values ('4', '004', 'barcode004', '岳不群', 0, 19960212, 18099990000, 'lhc@xmu.edu.cn', '记者', '100, 无不良记录', 20181001, null, '2', '1');
insert into reader values ('5', '005', 'barcode005', '张无忌', 0, 19960212, 18099990000, 'lhc@xmu.edu.cn', '检察官', '100, 无不良记录', 20181001, null, '3', '1');

-- 出版社
create table publisher (
  id varchar(25) primary key comment 'id',
  name varchar(255) not null comment '出版社名称',
  sub_isbn varchar(255) comment '出版社的子ISBN',
  delete_time bigint comment '删除时间，null 表示未删除'
);


insert into publisher values ('1', '机械工业出版社', '111', null);
insert into publisher values ('2', '清华大学出版社', '302', null);
insert into publisher values ('3', '高等教育出版社', '0402', null);

-- 图书类型
create table book_type (
  id varchar(25) primary key comment 'id',
  name varchar(255) not null comment '类型名称',
  delete_time bigint comment '删除时间，null 表示未删除',
  parent_type varchar(25) comment '外键，当前类型的父类型，指向本表',
  foreign key (parent_type) references book_type(id)
);
insert into book_type values ('1', '基础学科', null, null );
insert into book_type values ('2', '应用学科', null, null );
insert into book_type values ('3', '新兴学科', null, null );
insert into book_type values ('4', '其他学科', null, null );
insert into book_type values ('5', '物理', null, '1');
insert into book_type values ('6', '生物', null, '1');
insert into book_type values ('7', '化学', null, '1');
insert into book_type values ('8', '计算机科学', null, '2');
insert into book_type values ('9', '经济学', null, '2');
insert into book_type values ('10', '医学', null, '2');
insert into book_type values ('11', '数学', null, '1');


-- 图书表
create table book (
  id varchar(25) primary key comment 'id',
  name varchar(255) not null comment '书名',
  author varchar(255) comment '作者',
  translator varchar(255) comment '译者',
  isbn varchar(255) comment '书的 ISBN',
  price double comment '价格',
  page_nums int comment '页码数',
  barcode varchar(255) comment '条形码',
  delete_time bigint comment '删除时间，null 表示未删除',
  book_type varchar(25) comment '外键，书籍类型，',
  publisher varchar(25) comment '外键，出版社',
  first_buy_admin varchar(25) comment '外键，首次选购人',
  foreign key (book_type) references book_type(id),
  foreign key (publisher) references publisher(id),
  foreign key (first_buy_admin) references admin(id)
);

insert into book values ('1',
  '算法导论（原书第3版）',  -- 书名
  'Thomas H.Cormen / Charles E.Leiserson / Ronald L.Rivest / Clifford Stein', -- 作者
  '殷建平 / 徐云 / 王刚 / 刘晓光 / 苏明 / 邹恒明 / 王宏志 ',  -- 译者
  '9787111503934', -- ISBN
  128.00, 780, -- 价格、页码
  'barcode 算法导论', null, -- 条形码、删除时间
  '8', '1', '1'); -- 外键：书籍类型、出版社、首次选购人

insert into book values ('2',
  'Java编程思想 （第4版）',  -- 书名
  '[美] Bruce Eckel', -- 作者
  '陈昊鹏 ', -- 译者
  '9787111213826',  -- ISBN
  108.00, 880, -- 价格、页码
  'barcode Java编程思想', null, -- 条形码、删除时间
  '8', '1', '1'); -- 外键：书籍类型、出版社、首次选购人

insert into book values ('3',
  '数据挖掘 : 概念与技术（原书第3版）',  -- 书名
  '[美] Jiawei Han / [加]Micheline Kamber / [加] Jian Pei ', -- 作者
  '范明 / 孟小峰', -- 译者
  '9787111391401',  -- ISBN
  79.00, 468, -- 价格、页码
  'barcode 数据挖掘', null, -- 条形码、删除时间
  '8', '1', '1'); -- 外键：书籍类型、出版社、首次选购人

insert into book values ('4',
  'Effective java 中文版（第2版）',  -- 书名
  '[美] Joshua Bloch ', -- 作者
  '俞黎敏', -- 译者
  '9787111255833',  -- ISBN
  52.00, 287, -- 价格、页码
  'barcode Effective java', null, -- 条形码、删除时间
  '8', '1', '1'); -- 外键：书籍类型、出版社、首次选购人
insert into book values ('5',
  '深入理解计算机系统（原书第2版）',  -- 书名
  '（美）Randal E.Bryant / David O''Hallaron ', -- 作者
  '龚奕利 / 雷迎春  ', -- 译者
  '9787111321330',  -- ISBN
  99.00, 702, -- 价格、页码、存量
  'barcode 深入理解计算机系统', null, -- 条形码、删除时间
  '8', '1', '1'); -- 外键：书籍类型、出版社、首次选购人

-- 清华大学出版社
insert into book values ('6',
  '大话数据结构',  -- 书名
  '程杰 ', -- 作者
  null , -- 译者
  '9787302255659',  -- ISBN
  59.00, 440, -- 价格、页码
  'barcode 大话数据结构', null, -- 条形码、删除时间
  '8', '2', '1'); -- 外键：书籍类型、出版社、首次选购人
insert into book values ('7',
  '数据结构（C语言版）',  -- 书名
  '严蔚敏 / 吴伟民 ', -- 作者
  null , -- 译者
  '9787302023685',  -- ISBN
  29.00, 335, -- 价格、页码
  'barcode 数据结构（C语言版）', null, -- 条形码、删除时间
  '8', '2', '1'); -- 外键：书籍类型、出版社、首次选购人
insert into book values ('8',
  'C程序设计(第四版)',  -- 书名
  '谭浩强 ', -- 作者
  null , -- 译者
  '9787302224464',  -- ISBN
  33.00, 390, -- 价格、页码
  'barcode C程序设计(第四版)', null, -- 条形码、删除时间
  '8', '2', '1'); -- 外键：书籍类型、出版社、首次选购人

-- 高等教育出版社
insert into book values ('9',
  '高等数学（第六版）（上册）',  -- 书名
  '同济大学数学系', -- 作者
  null , -- 译者
  '9787040205497',  -- ISBN
  27.60, 413, -- 价格、页码
  'barcode 高等数学（第六版）（上册）', null, -- 条形码、删除时间
  '11', '3', '1'); -- 外键：书籍类型、出版社、首次选购人
insert into book values ('10',
  '高等数学（第六版）（下册）',  -- 书名
  '同济大学数学系 ', -- 作者
  null , -- 译者
  '9787040212778',  -- ISBN
  23.60, 351, -- 价格、页码
  'barcode ', null, -- 条形码、删除时间
  '11', '3', '1'); -- 外键：书籍类型、出版社、首次选购人
insert into book values ('11',
  '离散数学',  -- 书名
  '屈婉玲 / 耿素云 / 张立昂 ', -- 作者
  null , -- 译者
  '9787040231250',  -- ISBN
  35.00, 380, -- 价格、页码
  'barcode 离散数学', null, -- 条形码、删除时间
  '11', '3', '1'); -- 外键：书籍类型、出版社、首次选购人
insert into book values ('12',
  '工程数学.线性代数',  -- 书名
  '同济大学数学系', -- 作者
  null , -- 译者
  '9787040212181',  -- ISBN
  12.10, 164, -- 价格、页码
  'barcode 工程数学.线性代数', null, -- 条形码、删除时间
  '11', '3', '1'); -- 外键：书籍类型、出版社、首次选购人
insert into book values ('13',
  '概率论与数理统计',  -- 书名
  '盛骤 / 谢式千 / 潘承毅  ', -- 作者
  null , -- 译者
  '9787040238969',  -- ISBN
  34.70, 414, -- 价格、页码
  'barcode 概率论与数理统计', null, -- 条形码、删除时间
  '11', '3', '1'); -- 外键：书籍类型、出版社、首次选购人

-- 图书馆及分馆
create table library (
  id varchar(25) primary key comment 'id',
  name varchar(255) not null comment '图书馆名称',
  curator varchar(255) comment '馆长',
  telephone varchar(255) comment '联系电话',
  address varchar(255) comment '详细地址',
  email varchar(255) comment '电子邮箱',
  url varchar(255) comment '网址',
  create_date date comment '建馆日期',
  introduce varchar(255) comment '图书馆、分馆介绍',
  delete_time bigint comment '删除时间，null 表示未删除'
);

insert into library values ('1', '思明校图书馆', '思明馆馆长', '18959200001', '厦门大学思明校区', 'smlib@xmu.edu.cn', 'www.lib.xmu.edu.cn', 19870101,
                            '思明校区图书馆是服务与业务中心馆，位于校本部大南校门旁，馆舍落成于1987年，2001年、2008年进行改扩建，面积2万6千平方米。', null);
insert into library values ('2', '德旺图书馆', '德旺图书馆馆长', '18959200002', '厦门大学翔安校区', 'xalib@xmu.edu.cn', 'www.lib.xmu.edu.cn', 20070101,
                            '厦门大学德旺图书馆坐落于翔安校区主楼群三号楼，正对主校门，居全校区之中央位置，外观宏伟壮丽气势磅礴，充分融合了中西方建筑文化的精华，既体现了嘉庚建筑风格的气质与内涵，又与思明校区图书馆和漳州校区图书馆遥相呼应，共同构成厦门大学图书馆的完整体系。', null);


-- 书架，也可以是仓库
create table book_case (
  id varchar(25) primary key comment 'id',
  name varchar(255) not null comment '书架名称，最好也通过名称在一定的程度上体现类型，然后让书本根据类型能一定的程度进行存放',
  delete_time bigint comment '删除时间，null 表示未删除',
  branch varchar(25) comment '外键，书架所在分馆',
  foreign key (branch) references library (id)
);

insert into book_case values ('1', 'A-01', null, '1');
insert into book_case values ('2', 'A-02', null, '1');
insert into book_case values ('3', 'B-01', null, '1');
insert into book_case values ('4', 'B-02', null, '1');

-- 一本书
create table book_one (
  id varchar(25) primary key comment 'id',
  buy_date date comment '购买日期',
  allow_borrow bit comment '是否可借，null 表示该种书不可借，0 表示该本已借出而不可借，为 1 才可借',
  delete_time bigint comment '删除时间，null 表示未删除',
  which_book varchar(25) comment '外键，所属图书',
  which_book_case varchar(25) comment '外键，存放的书架或仓库位置',
  foreign key (which_book) references book(id),
  foreign key (which_book_case) references book_case(id)
);

-- 算法导论 3 本
insert into book_one values ('1', 20180101, 1, null, '1', '1');
insert into book_one values ('2', 20180101, 1, null, '1', '1');
insert into book_one values ('3', 20180101, 1, null, '1', '1');
-- Java 编程思想 3 本
insert into book_one values ('4', 20180101, 1, null, '2', '2');
insert into book_one values ('5', 20180101, 1, null, '2', '2');
insert into book_one values ('6', 20180101, 1, null, '2', '2');
-- 数据挖掘 1 本
insert into book_one values ('7', 20180101, 1, null, '3', '2');
-- Effective java 中文版（第2版） 1
insert into book_one values ('8', 20180101, 1, null, '4', '2');
-- 深入理解计算机系统 2 本
insert into book_one values ('9', 20180101, 1, null, '5', '1');
insert into book_one values ('10', 20180101, 1, null, '5', '1');

-- 大华数据结构 2 本
insert into book_one values ('11', 20180101, 1, null, '6', '1');
insert into book_one values ('12', 20180101, 1, null, '6', '1');
-- 数据结构严蔚敏 2 本
insert into book_one values ('13', 20180101, 1, null, '7', '1');
insert into book_one values ('14', 20180101, 1, null, '7', '1');
-- C 程序设计 3 本
insert into book_one values ('15', 20180101, 1, null, '8', '2');
insert into book_one values ('16', 20180101, 1, null, '8', '2');
insert into book_one values ('17', 20180101, 1, null, '8', '2');
-- 高数上 3 本
insert into book_one values ('18', 20180101, 1, null, '9', '3');
insert into book_one values ('19', 20180101, 1, null, '9', '3');
insert into book_one values ('20', 20180101, 1, null, '9', '3');
-- 高数下 3 本
insert into book_one values ('21', 20180101, 1, null, '10', '3');
insert into book_one values ('22', 20180101, 1, null, '10', '3');
insert into book_one values ('23', 20180101, 1, null, '10', '3');
-- 离散数学 2 本
insert into book_one values ('24', 20180101, 1, null, '11', '4');
insert into book_one values ('25', 20180101, 1, null, '11', '4');
-- 线性代数 2 本
insert into book_one values ('26', 20180101, 1, null, '12', '4');
insert into book_one values ('27', 20180101, 1, null, '12', '4');

-- 概率论 3 本
insert into book_one values ('28', 20180101, 1, null, '13', '3');
insert into book_one values ('29', 20180101, 1, null, '13', '3');
insert into book_one values ('30', 20180101, 1, null, '13', '3');

-- 归还表
create table giveback (
  id varchar(25) primary key comment 'id',
  back_time datetime comment '归还时间',
  delay_days int comment '逾期天数',
  total_delay_punishment double comment '计算总罚款价格',
  delete_time bigint comment '删除时间，null 表示未删除'
);

-- 借阅表
create table borrow (
  id varchar(25) primary key comment 'id',
  borrow_time datetime comment '借阅时间',
  need_back_time datetime comment '应还时间',
  renew bit default 0 comment '是否续借过',
  op_admin_list varchar(255) comment '操作管理员记录序列 id-op, id-op, id-op...',
  delete_time bigint comment '删除时间，null 表示未删除',
  reader varchar(25) comment '外键，借阅人',
  borrow_book varchar(25) comment '外键，借阅的书',
  giveback varchar(25) comment '外键，是否归还，null表示未归还',
  foreign key (reader) references reader(id),
  foreign key (borrow_book) references book_one(id),
  foreign key (giveback) references giveback(id)
);

```