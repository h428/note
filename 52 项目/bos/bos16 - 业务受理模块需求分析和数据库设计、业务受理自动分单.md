[TOC]

# 业务受理模块需求分析和数据库设计

## 一、业务受理模块需求分析

整个BOS项目分为基础设置、取派、中转、路由、报表等几大部分。
受理环节，是物流公司业务的开始，作为服务前端，客户通过电话、网络等多种方式进行委托，业务受理员通过与客户交流，获取客户的服务需求和具体委托信息，将服务指令输入我司服务系统。

客户通过打电话方式进行物流委托，物流公司的客服人员需要将委托信息录入到BOS系统中，这个录入的信息称为业务通知单。
当客服人员将业务通知单信息录入到系统后，系统会根据客户的住址自动匹配到一个取派员，并为这个取派员产生一个任务，这个任务就称为工单。
取派员收到取货任务后，会到客户住址取货，取派员会让客户填写纸质的单子（寄件人信息、收件人信息等），取派员将货物取回物流公司网点后，需要将纸质单子上的信息录入到BOS系统中，录入的信息称为工作单。


## 二、业务受理模块数据库设计

```
/*==============================================================*/
/* DBMS name: MySQL 5.0 */
/* Created on: 2017/8/19 13:27:42 */
/*==============================================================*/


drop table if exists qp_noticebill;

drop table if exists qp_workbill;

drop table if exists qp_workordermanage;

/*==============================================================*/
/* Table: qp_noticebill */
/*==============================================================*/
create table qp_noticebill
(
id varchar(32) not null,
staff_id varchar(32),
customer_id varchar(32),
customer_name varchar(20),
delegater varchar(20),
telephone varchar(20),
pickaddress varchar(200),
arrivecity varchar(20),
product varchar(20),
pickdate date,
num int,
weight double,
volume varchar(20),
remark varchar(255),
ordertype varchar(20),
user_id varchar(32),
primary key (id)
);

/*==============================================================*/
/* Table: qp_workbill */
/*==============================================================*/
create table qp_workbill
(
id varchar(32) not null,
noticebill_id varchar(32),
type varchar(20),
pickstate varchar(20),
buildtime timestamp,
attachbilltimes int,
remark varchar(255),
staff_id varchar(32),
primary key (id)
);

/*==============================================================*/
/* Table: qp_workordermanage */
/*==============================================================*/
create table qp_workordermanage
(
id varchar(32) not null,
arrivecity varchar(20),
product varchar(20),
num int,
weight double,
floadreqr varchar(255),
prodtimelimit varchar(40),
prodtype varchar(40),
sendername varchar(20),
senderphone varchar(20),
senderaddr varchar(200),
receivername varchar(20),
receiverphone varchar(20),
receiveraddr varchar(200),
feeitemnum int,
actlweit double,
vol varchar(20),
managerCheck varchar(1),
updatetime date,
primary key (id)
);

alter table qp_noticebill add constraint FK_Reference_2 foreign key (user_id)
references t_user(id) on delete restrict on update restrict;

alter table qp_noticebill add constraint FK_Reference_3 foreign key (staff_id)
references bc_staff(id) on delete restrict on update restrict;

alter table qp_workbill add constraint FK_Reference_4 foreign key (staff_id)
references bc_staff(id) on delete restrict on update restrict;

alter table qp_workbill add constraint FK_workbill_noticebill_fk foreign key (noticebill_id)
references qp_noticebill (id) on delete restrict on update restrict;
```

三、执行Hibernate反向工程构建实体


# 业务受理自动分单

## 一、在CRM中扩展方法：根据手机号查询客户信息以及根据客户的取件地址查询定区ID

1. 实现代码如下

```
@Override
public Customer findCustomerByTelephone(String telephone) {
String sql = "select * from t_customer where telephone = ?";
List<Customer> customerList = jdbcTemplate.query(sql, new CustomerRowMapper(), telephone);
if(customerList != null && customerList.size() > 0){
return customerList.get(0);
}
return null;
}

@Override
public String findDecidedzoneIdByAddress(String address) {
String sql = "select decidedzone_id from t_customer where telephone = ?";
String decidedzoneId = jdbcTemplate.queryForObject(sql, String.class, address);
return decidedzoneId;
}
```

2. 重新生成客户端调用类

```
wsimport -s . -p com.hao.crm.service http://localhost:8080/CRM/service/customer?wsdl
```

## 二、页面完善

1. 为手机号输入框绑定失焦事件

```
$(function(){
//页面加载完成后为手机输入框绑定失焦事件
$("input[name=telephone]").blur(function(){
var telephone = this.value;
//发送ajax请求，在Action中调用crm服务获取客户信息，用于页面回显
$.ajax({
"url":"noticebillAction_findCustomerByTelephone.action",
"data":{"telephone":telephone},
"success":function(resp, textStatus, xmlHttp){
if(resp != null){
//查询到了客户信息，可以进行页面回显
var customerId = resp.id;
var customerName = resp.name;
var address = resp.address;
$("input[name=customerId]").val(customerId);
$("input[name=customerName]").val(customerName);
$("input[name=delegater]").val(customerName);
$("input[name=pickaddress]").val(address);
}else{
//没有查询到客户信息，清空已经回显的数据
$("input[name=customerId]").val("");
$("input[name=customerName]").val("");
$("input[name=delegater]").val("");
$("input[name=pickaddress]").val("");
}
},
"error":function(xmlHttp, testStatus, exception){
alert(textStatus);
}
});
});
});
```

2. 创建NoticebillAction，注入crm代理对象，提供方法根据手机号查询客户

```
/**
* 调用crm根据电话查询客户信息
* @return
*/
public String findCustomerByTelephone(){
Customer customer = customerService.findCustomerByTelephone(model.getTelephone());
object2JsonAndWriteToResponse(customer);
return NONE;
}
```

## 三、服务端实现业务单受理以及自动分单功能

1. NoticebillAction.add实现

```
/**
* 添加新的业务通知单，并尝试自动分单
*/
public String add(){
noticebillService.save(model);
return LIST;
}
```

2. NoticebillService.save实现

```
/**
* 保存业务通知单并尝试自动分单
*/
@Override
public void save(Noticebill model) {
User user = BOSUtils.getLoginUser();
model.setUser(user);//设置当前登录的用户
noticebillDao.save(model);

//获取客户的取件地址
String pickaddress = model.getPickaddress();
//远程调用crm服务，根据取件地址查询定区ID
String decidedzoneId = customerService.findDecidedzoneIdByAddress(pickaddress);
if(decidedzoneId != null){
//匹配到了定区ID，可以进行自动分单
Decidedzone decidedzone = decidedzoneDao.findById(decidedzoneId);
Staff staff = decidedzone.getStaff();
model.setStaff(staff);// 业务通知关联取派员对象
//设置分单类型为自动分单
model.setOrdertype(Noticebill.ORDERTYPE_AUTO);
//为取派员产生一个工单
Workbill workbill = new Workbill();
workbill.setAttachbilltimes(0);
workbill.setBuildtime(new Timestamp(System.currentTimeMillis())); //创建时间，当前提供时间
workbill.setNoticebill(model); //工单关联业务通知单
workbill.setPickstate(Workbill.PICKSTATE_NO); //设置取件状态为未取件
workbill.setRemark(model.getRemark()); //备注信息
workbill.setStaff(staff);//工单关联取派员
workbill.setType(Workbill.TYPE_NEW); //新单

//保存工单
workbillDao.save(workbill);

//保存后调用短信平台发送短信

}else{
//没有查询到定区ID，不能进行自动分单
model.setOrdertype(Noticebill.ORDERTYPE_MAN);
}
}
```

