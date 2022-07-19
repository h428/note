
# 数据表描述

- 这是一个用于自己 demo 的数据库，根据书上的例子自己改造的，是一个简单的学生课程管理系统
- 管理员表单独独立出来
- 主要和业务逻辑相关的表有：学生、学生证、班级、教师、课程、选课、健康信息(拆分出男生、女生两个表)
- 上述表格基本涉及了常见数据库之间的关系，可以很方便的学习映射

# 建库建表语句


```sql
-- 建库
create database example default character set utf8 collate utf8_general_ci;

use example;

-- 管理员
create table admin(
	id int primary key auto_increment,
	username varchar(30) not null unique,
	password varchar(30) not null
);
insert into admin(id, username, password) values(1, 'admin', 'admin');
insert into admin(id, username, password) values(2, 'cat', 'cat');


-- 班级
create table student_class(
	id int primary key auto_increment,
	name varchar(30) not null,
	notes varchar(1024)
);
insert into student_class(id, name, notes) values(1, '射雕英雄传', '射雕班级');
insert into student_class(id, name, notes) values(2, '倚天屠龙记', '倚天班级');
insert into student_class(id, name, notes) values(3, '笑傲江湖', '笑傲江湖');

-- 学生
create table student(
	id int auto_increment,
	stu_no varchar(12) not null,
	name varchar(30) not null,
	gender bit,
	birthday date,
	phone varchar(30),
	email varchar(30),
	class_id int,
	primary key(id),
	foreign key (class_id) references student_class(id)
);
insert into student(id, stu_no, name, gender, birthday, phone, email, class_id) values(1, '001', '郭靖', 0, 19900512, '156-0001-0000', 'guojing@sj.com', 1);
insert into student(id, stu_no, name, gender, birthday, phone, email, class_id) values(2, '002', '黄蓉', 1, 19900714, '156-0002-0000', 'huangrong@sj.com', 1);
insert into student(id, stu_no, name, gender, birthday, phone, email, class_id) values(3, '003', '杨康', 0, 19900312, '156-0001-9527', 'yangkang@sd.com', 1);
insert into student(id, stu_no, name, gender, birthday, phone, email, class_id) values(4, '004', '张无忌', 0, 19940612, '156-0006-1234', 'zwj@yt.com', 2);
insert into student(id, stu_no, name, gender, birthday, phone, email, class_id) values(5, '005', '周芷若', 1, 19950819, '156-0006-2324', 'zzr@yt.com', 2);
insert into student(id, stu_no, name, gender, birthday, phone, email, class_id) values(6, '006', '令狐冲', 0, 19960212, '156-5978-0000', 'lhc@xajh.com', 2);

-- 学生证
create table student_card(
	id int primary key auto_increment,
	stu_id int not null,
	native_place varchar(30),
	make_date date,
	end_date date,
	notes varchar(1024),
	foreign key(stu_id) references student(id),
	unique(stu_id)
);
insert into student_card(id, stu_id, native_place, make_date, end_date, notes) values(1, 1, '四川', 19970113, 20010113, '郭靖的学生证');
insert into student_card(id, stu_id, native_place, make_date, end_date, notes) values(2, 2, '桃花岛', 19970213, 20010213, '黄蓉的学生证');
insert into student_card(id, stu_id, native_place, make_date, end_date, notes) values(3, 3, '金国', 19970314, 20050314, '杨康的学生证');
insert into student_card(id, stu_id, native_place, make_date, end_date, notes) values(4, 4, '湖北武当山', 19970526, 20000526, '张无忌的学生证');


-- 教师
create table teacher(
	id int primary key auto_increment,
	teacher_no varchar(30) not null,
	name varchar(30) not null,
	gender bit,
	birthday date,
	seniority int
);
insert into teacher(id, teacher_no, name, gender, birthday, seniority) values(1,'001', '洪七公', 0, 17900221, 0);
insert into teacher(id, teacher_no, name, gender, birthday, seniority) values(2, '002', '丘处机', 1, 17920615, 1);
insert into teacher(id, teacher_no, name, gender, birthday, seniority) values(3, '003', '张三丰', 0, 17800111, 0);
insert into teacher(id, teacher_no, name, gender, birthday, seniority) values(4, '003', '岳不群', 0, 17800111, 2);
insert into teacher(id, teacher_no, name, gender, birthday, seniority) values(5, '003', '任我行', 0, 17800111, 1);
insert into teacher(id, teacher_no, name, gender, birthday, seniority) values(6, '003', '灭绝师太', 0, 17800111, 2);


-- 课程
create table course(
	id int primary key auto_increment,
	name varchar(30) not null,
	note varchar(100),
	course_teacher int,
	foreign key(course_teacher) references teacher(id)
);
insert into course(id, name, note, course_teacher) values(1, '降龙十八掌', '丐帮绝学', 1);
insert into course(id, name, note, course_teacher) values(2, '打狗棒法', '丐帮绝学', 1);
insert into course(id, name, note, course_teacher) values(3, '全真心法', '全真入门心法', 2);
insert into course(id, name, note, course_teacher) values(4, '太极拳', '武当绝学', 3);
insert into course(id, name, note, course_teacher) values(5, '太极剑法', '武当绝学', 3);
insert into course(id, name, note, course_teacher) values(6, '华山剑法', '华山入门剑法', 4);
insert into course(id, name, note, course_teacher) values(7, '紫霞神功', '华山高级心法', 4);
insert into course(id, name, note, course_teacher) values(8, '吸星大法', '日月神教神功', 5);
insert into course(id, name, note, course_teacher) values(9, '峨嵋剑法', '峨眉派入门心法', 6);

-- 选课

create table student_take_course(
	id int primary key auto_increment,
	stu_id int not null,
	course_id int not null,
	grade float,
	foreign key(stu_id) references student(id),
	foreign key(course_id) references course(id),
	unique(stu_id, course_id)
);
insert into student_take_course(id, stu_id, course_id, grade) values(1, 1, 1, 90);
insert into student_take_course(id, stu_id, course_id, grade) values(2, 2, 1, 80);
insert into student_take_course(id, stu_id, course_id, grade) values(3, 1, 3, 85.5);
insert into student_take_course(id, stu_id, course_id, grade) values(4, 3, 3, 83.5);
insert into student_take_course(id, stu_id, course_id, grade) values(5, 4, 4, 87);
insert into student_take_course(id, stu_id, course_id, grade) values(6, 4, 5, 85);
insert into student_take_course(id, stu_id, course_id, grade) values(7, 5, 9, 80);
insert into student_take_course(id, stu_id, course_id, grade) values(8, 6, 6, 85);
insert into student_take_course(id, stu_id, course_id, grade) values(9, 6, 7, 80);
insert into student_take_course(id, stu_id, course_id, grade) values(10, 6, 8, 88);

-- 男生健康信息
create table male_student_health(
	id int primary key auto_increment,
	stu_id int not null,
	check_date date,
	heart varchar(60),
	liver varchar(60),
	spleen varchar(60),
	lung varchar(60),
	kidney varchar(60),
	prostate varchar(60), -- 前列腺
	notes varchar(1024),
	foreign key(stu_id) references student(id)
);
insert into male_student_health(id, stu_id, check_date, heart, liver, prostate, notes) values(1, 1, 19970101, '健康', '健康', '健康', '郭靖');
insert into male_student_health(id, stu_id, check_date, heart, liver, prostate, notes) values(2, 3, 19970101, '健康', '健康', '健康', '杨康');
insert into male_student_health(id, stu_id, check_date, heart, liver, prostate, notes) values(3, 4, 19970101, '健康', '健康', '健康', '张无忌');
insert into male_student_health(id, stu_id, check_date, heart, liver, prostate, notes) values(4, 6, 19970101, '健康', '健康', '健康', '令狐冲');
insert into male_student_health(id, stu_id, check_date, heart, liver, prostate, notes) values(5, 1, 19980101, '健康', '异常', '健康', '郭靖');
insert into male_student_health(id, stu_id, check_date, heart, liver, prostate, notes) values(6, 1, 19990101, '健康', '健康', '健康', '郭靖');


-- 女生健康信息
create table female_student_health(
	id int primary key auto_increment,
	stu_id int not null,
	check_date date,
	heart varchar(60),
	liver varchar(60),
	spleen varchar(60),
	lung varchar(60),
	kidney varchar(60),
	uterus varchar(60), -- 子宫
	notes varchar(1024),
	foreign key(stu_id) references student(id)
);
insert into female_student_health(id, stu_id, check_date, heart, liver, uterus, notes) values(1, 2, 19970101, '健康', '健康', '健康', '黄蓉');
insert into female_student_health(id, stu_id, check_date, heart, liver, uterus, notes) values(2, 5, 19970101, '健康', '健康', '健康', '周芷若');

```





















