

# 工作流概述

## 概念

工作流（Workflow），就是通过计算机对业务流程自动化执行管理。它主要解决的是“使在多个参与者之间按照某种预定义的规则自动进行传递文档、信息或任务的过程，从而实现某个预期的业务目标，或者促使此目标的实现”。

## 工作流系统

一个软件系统中具有工作流的功能，我们把它称为工作流系统，一个系统中工作流的功能是什么？就是对系统的业务流程进行自动化管理，所以工作流是建立在业务流程的基础上，所以一个软件的系统核心根本上还是系统的业务流程，工作流只是协助进行业务流程管理。即使没有工作流业务系统也可以开发运行，只不过有了工作流可以更好的管理业务流程，提高系统的可扩展性。

## 适用行业

消费品行业，制造业，电信服务业，银证险等金融服务业，物流服务业，物业服务业，物业管理，大中型进出口贸易公司，政府事业机构，研究院所及教育服务业等，特别是大的跨国企业和集团公司。

## 具体应用

- 关键业务流程：订单、报价处理、合同审核、客户电话处理、供应链管理等
- 行政管理类:出差申请、加班申请、请假申请、用车申请、各种办公用品申请、购买申请、日报周报等凡是原来手工流转处理的行政表单。
- 人事管理类：员工培训安排、绩效考评、职位变动处理、员工档案信息管理等。
- 财务相关类：付款请求、应收款处理、日常报销处理、出差报销、预算和计划申请等。
- 客户服务类：客户信息管理、客户投诉、请求处理、售后服务管理等。
- 特殊服务类：ISO 系列对应流程、质量管理对应流程、产品数据信息管理、贸易公司报关处理、物流公司货物跟踪处理等各种通过表单逐步手工流转完成的任务均可应用工作流软件自动规范地实施。

## 实现方式

在没有专门的工作流引擎之前，我们之前为了实现流程控制，通常的做法就是采用状态字段的值来跟踪流程的变化情况。这样不用角色的用户，通过状态字段的取值来决定记录是否显示。

针对有权限可以查看的记录，当前用户根据自己的角色来决定审批是否合格的操作。如果合格将状态字段设置一个值，来代表合格；当然如果不合格也需要设置一个值来代表不合格的情况。

这是一种最为原始的方式。通过状态字段虽然做到了流程控制，但是当我们的流程发生变更的时候，这种方式所编写的代码也要进行调整。

那么有没有专业的方式来实现工作流的管理呢？并且可以做到业务流程变化之后，我们的程序可以不用改变，如果可以实现这样的效果，那么我们的业务系统的适应能力就得到了极大提升。


# Activiti7 概述

## 介绍

Alfresco 软件在 2010 年 5 月 17 日宣布 Activiti 业务流程管理（BPM）开源项目的正式启动，其首席架构师由业务流程管理 BPM 的专家 Tom Baeyens担任，Tom Baeyens 就是原来  jbpm 的架构师，而 jbpm 是一个非常有名的工作流引擎，当然 activiti 也是一个工作流引擎。

Activiti 是一个工作流引擎， activiti 可以将业务系统中复杂的业务流程抽取出来，使用专门的建模语言 BPMN2.0 进行定义，业务流程按照预先定义的流程进行执行，实现了系统的流程由 activiti 进行管理，减少业务系统由于流程变更进行系统升级改造的工作量，从而提高系统的健壮性，同时也减少了系统开发维护成本。

官方网站：<https://www.activiti.org/>


### BPM 介绍


## 使用步骤

## 部署 activiti

- 下载 jar 或者使用 maven 引入，业务系统访问 activiti 的接口，就可以方便操作流程相关数据

## 流程定义

- 使用 activiti 流程剑魔工具定义业务流程（.bpmn 文件），.bpmn 文件就是业务流程定义文件，通过 xml 定义业务流程

## 流程定义部署

activiti 部署流程定义文件（.bpmn 文件），activiti 会把流程定义存储在数据库中，在执行过程中可以查询定义的内容


## 启动一个流程实例

- 流程实例也叫 ProcessInstance
- 启动一个流程实例表示开始依次业务流程的运行
- 在员工请假流程定义部署完成以后，如果张三要请假就可以
