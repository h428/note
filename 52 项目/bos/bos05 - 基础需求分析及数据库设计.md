[toc]

# 基础需求分析

> 整个BOS项目分为基础设置、去拍、中转、路由、报表、财务等部分

> 需求所明书2.6

## 一、数据字典

一个系统或功能中的基础选择的数据，用于帮助其他模块功能的完成，为了可维护，故构建成数据字典
如学历类型，线路类型，保险类型

## 二、收派标准

定义快件如何收费

## 三、班车设置

将设置的线路和车辆设置好对应关系

## 四、取派设置


## 五、区域设置

设置国家行政区域

## 六、管理分区

区域是由国家划分的，区域往往很大，不便于进行人员分配
因此要对于区域进行细分，就是分区
该模块用于对分区进行维护

## 七、管理定区

定区是物流分配的基本单位，可以将客户信息，取派员信息，分区信息进行关联
可能包含多个小的物理位置较近的分区

## 八、时间管理

上班时间管理

# 数据库设计

> sql代码

```
/*==============================================================*/
/* DBMS name: MySQL 5.0 */
/* Created on: 2017/8/15 16:19:44 */
/*==============================================================*/


drop table if exists bc_decidedzone;

drop table if exists bc_region;

drop table if exists bc_staff;

drop table if exists bc_subarea;

/*==============================================================*/
/* Table: bc_decidedzone */
/*==============================================================*/
create table bc_decidedzone
(
id varchar(32) not null,
name varchar(30),
staff_id varchar(32),
primary key (id)
);

/*==============================================================*/
/* Table: bc_region */
/*==============================================================*/
create table bc_region
(
id varchar(32) not null,
province varchar(50),
city varchar(50),
district varchar(50),
postcode varchar(50),
shortcode varchar(30),
citycode varchar(30),
primary key (id)
);

/*==============================================================*/
/* Table: bc_staff */
/*==============================================================*/
create table bc_staff
(
id varchar(32) not null,
name varchar(20),
telephone varchar(20),
haspda char(1),
deltag char(1),
station varchar(40),
standard varchar(100),
primary key (id)
);

/*==============================================================*/
/* Table: bc_subarea */
/*==============================================================*/
create table bc_subarea
(
id varchar(32) not null,
decidedzone_id varchar(32),
region_id varchar(32),
addresskey varchar(100),
startnum varchar(30),
endnum varchar(30),
single char(1),
position varchar(255),
primary key (id)
);

alter table bc_decidedzone add constraint FK_decidedzone_staff foreign key (staff_id)
references bc_staff (id) on delete restrict on update restrict;

alter table bc_subarea add constraint FK_area_decidedzone foreign key (decidedzone_id)
references bc_decidedzone (id) on delete restrict on update restrict;

alter table bc_subarea add constraint FK_area_region foreign key (region_id)
references bc_region (id) on delete restrict on update restrict;
```