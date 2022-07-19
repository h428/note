
# 数据库

```sql

drop database if exists learn;
create database learn;

alter database learn character set utf8;
alter database learn collate utf8_general_ci;


use learn;

create table student(
    sno varchar(128) primary key,
    sname varchar(128),
    ssex varchar(10),
    sage int,
    sdept varchar(10)
);


create table course(
    cno varchar(128) primary key,
    cname varchar(128),
    cpno varchar(128),
    ccredit smallint
);
-- 如果需要外键
alter table course add constraint fk_course_cpno foreign key (cpno) references course(cno);
-- 删除外键
alter table course drop foreign key fk_course_cpno;

create table sc(
    sno varchar(128),
    cno varchar(128),
    grade smallint,
    primary key(sno, cno)
);

-- 如果需要外键
alter table sc add constraint fk_sc_sno foreign key (sno) references student(sno);
alter table sc add constraint fk_sc_cno foreign key (cno) references course(cno);
-- 删除外键
alter table sc drop foreign key fk_sc_sno;
alter table sc drop foreign key fk_sc_cno;

-- 数据
insert into student values('201215121', '李勇', '男', 20, 'CS');
insert into student values('201215122', '刘晨', '女', 19, 'CS');
insert into student values('201215123', '王敏', '女', 18, 'MA');
insert into student values('201215125', '张力', '男', 19, 'IS');

insert into course values('1', '数据库', '5', 4);
insert into course values('2', '数学', null, 2);
insert into course values('3', '信息系统', 1, 4);
insert into course values('4', '操作系统', 6, 3);
insert into course values('5', '数据结构', 7, 4);
insert into course values('6', '数据处理', null, 2);
insert into course values('7', 'PASCAL 语言', 6, 4);


insert into sc values('201215121', '1', 92);
insert into sc values('201215121', '2', 85);
insert into sc values('201215121', '3', 88);
insert into sc values('201215122', '2', 90);
insert into sc values('201215122', '3', 80);

```

# 查询语句

- 关系代数：在 sql 对应连接相关的关键字 join
- 关系演算：在 sql 中对应 exists 关键字
- 此外，利用子查询相关的关键字，包括 in, any, all 可以方便地进行多表查询

## 2.1 简单查询

**查询选修了数据库和操作系统的学生姓名**

- 关系代数：直接连接后筛选（也可以配合子查询，筛选后连接，但直接连接数据库会进行优化）
```sql
select distinct sname
from student as s inner join sc on s.sno = sc.sno
  inner join course as c on sc.cno = c.cno
where cname = '数据库' or cname = '操作系统';
```
- 关系演算，直接使用 Exists 关键字进行筛选
```sql
select distinct sname
from student
where exists(
    select *
    from sc
    where sc.sno = student.sno and exists(
        select *
        from course
        where course.cno = sc.cno and (course.cname = '操作系统' or course.cname = '数据库')
    )
);
```
- 子查询，使用 in 关键字进行子查询
```sql
select sname
from student s
where s.sno in (
  select sc.sno
  from sc
  where sc.cno in (
    select course.cno
    from course
    where course.cname = '操作系统' or course.cname = '数据库'
  )
);
```

**查询 CS 系必修课 4 学分以上课程挂科的同学和 IS 系有挂科的同学的姓名、年龄**

- 关系代数
```sql
-- 直接自然连接，实际上数据库会优化
select
  sname,
  sage
from student s
  join sc on s.sno = sc.sno
  join course c on sc.cno = c.cno
where s.sdept = 'CS' and ccredit >= 4 and grade < 60
union
select
  sname,
  sage
from student s
  join sc on s.sno = sc.sno
  join course c on sc.cno = c.cno
where s.sdept = 'IS' and grade < 60;

-- 先做筛选效率更高，但如果先筛选不如直接使用 exist 效率比这个更高，除非你需要多个表组成的列
select
  sname,
  sage
from student s
  join (select *
        from sc
        where grade < 60) sc2 on s.sno = sc2.sno
  join (select *
        from course
        where ccredit >= 4) c2 on sc2.cno = c2.cno
where s.sdept = 'CS'
union
select
  sname,
  sage
from student s
  join (select *
        from sc
        where grade < 60) sc2 on s.sno = sc2.sno
  join course c on sc2.cno = c.cno
where s.sdept = 'IS';
```
- 关系演算
```sql
select
  sname,
  sage
from student s
where sdept = 'CS' and exists(
    select *
    from sc
    where s.sno = sc.sno and sc.grade < 60 and exists(
        select *
        from course c
        where c.cno = sc.cno and c.ccredit >= 4
    )
)
union
select
  sname,
  sage
from student s
where sdept = 'IS' and exists(
    select *
    from sc
    where s.sno = sc.sno and sc.grade < 60
);
```
- 子查询
```sql
select
  sname,
  sage
from student s
where sdept = 'CS' and sno in (
  select sc.sno
  from sc
  where sc.grade < 60 and sc.cno in (
    select course.cno
    from course
    where ccredit >= 4
  )
)
union
select
  sname,
  sage
from student s
where sdept = 'IS' and sno in (
  select sc.sno
  from sc
  where sc.grade < 60
);
```

**选修了先行课为数据库的学生姓名**

- 关系代数/关系演算：使用 exist
```sql
select sname
from student s
where exists(
    select *
    from sc
    where s.sno = sc.sno and exists(
        select *
        from course c
        where c.cno = sc.cno and exists(
            select *
            from course c2
            where c2.cno = c.cpno and c2.cname = '数据库'
        )
    )
);
```
- 使用 in 的子查询
```sql
select sname
from student s
where sno in (
  select sno
  from sc
  where sc.cno in (
    select cno
    from course c
    where c.cpno in (
      select cno
      from course c2
      where c2.cname = '数据库'
    )
  )
);
```

**查询未选数学的同学**

- 关系代数/关系演算：使用 exists 关键字
```sql
select sname
from student s
where not exists(
    select *
    from sc
    where s.sno = sc.sno and exists(
        select *
        from course c
        where sc.cno = c.cno and c.cname = '数学'
    )
);
```
- 使用基于 in 的子查询
```sql
select sname
from student s
where sno not in (
    select sno from sc where sc.sno = s.sno and sc.cno in (
        select cno from course c where c.cname = '数学'
    )
);
```


## 2.2 查找的目标数据是单表的，但检索条件时别的表的且较为复杂

**查询选修了全部课程的学生的姓名和年龄**

- 关系代数、关系演算：not exists 关键字
```sql
select
  sname,
  sage
from student s
where not exists(
    select *
    from course c
    where not exists(
        select *
        from sc
        where sc.sno = s.sno and sc.cno = c.cno
    )
);
```
- 子查询
```sql
select
  sname,
  sage
from student
where sno in (
  select sno
  from sc
  group by sno
  having count(distinct cno) >= (select count(*)
                                 from course)
);
```

**选修了全部课程的女同学**

- not exists，和选修了全部课程的同学一样，只是加了一个女的筛选条件
```sql
select
  sname,
  sage
from student s
where not exists(
    select *
    from course c
    where not exists(
        select *
        from sc
        where sc.cno = c.cno and sc.sno = s.sno
    )
) and s.ssex = '女';
```
- 使用 in 的子查询
```sql
select
  sname,
  sage
from student s
where s.sno in (
  select sno
  from sc
  group by sno
  having count(*) >= (select count(*)
                      from course)
) and ssex = '女';
```


**查询选修了全部必修课的学生的姓名和年龄**

- 关系代数，关系演算：利用 not exists，不存在大于等于 4 学分的课程，该学生没选
```sql
select
  sname,
  sage
from student s
where not exists(
    select *
    from course c
    where c.ccredit >= 4 and not exists(
        select *
        from sc
        where sc.sno = s.sno and c.cno = sc.cno
    )
);
```
- 利用子查询
```sql
select
  sname,
  sage
from student
where sno in (
  select sc.sno
  from sc
  where sc.cno in (
    select cno
    from course
    where ccredit >= 4
  )
  group by sc.sno
  having count(distinct sc.cno) >= (select count(*)
                                    from course
                                    where ccredit >= 4)
);
```

**至少选修了数据库和操作系统的学生姓名和年龄**

- 关系代数，关系演算（not exists）
```sql
select
  sname,
  sage
from student s
where not exists(
    select *
    from course c
    where (c.cname = '数据库' or c.cname = '操作系统') and not exists(
        select *
        from sc
        where sc.sno = s.sno and sc.cno = c.cno
    )
);
```
- 子查询
```sql
select
  sname,
  sage
from student
where sno in (
  select sno
  from sc
  where cno in (
    select cno
    from course
    where cname = '数据库' or cname = '操作系统'
  )
  group by sc.sno
  having count(sc.cno) = 2
);
```

**选修了全部课程且不挂科的学生姓名和年龄**

- 关系代数、关系演算
```sql
select
  sname,
  sage
from student s
where not exists(
    select *
    from course c
    where not exists(
        select *
        from sc
        where sc.sno = s.sno and sc.cno = c.cno
    ) or exists(
              select *
              from sc
              where sc.sno = s.sno and sc.cno = c.cno and sc.grade < 60
          )
);
```
- 子查询
```sql
select
  sname,
  sage
from student s
where sno in (
  select sno
  from sc
  where grade >= 60
  group by sno
  having count(*) >= (select count(*)
                      from course)
);
```

**查询选修了王敏所选的全部课程，且成绩为优秀的学生姓名、年龄**

- 关系代数、关系演算：
```sql
select
  sname,
  sage
from student s
where not exists(
    select *
    from course c
    where exists(
        select *
        from sc sc1
        where exists(
                  select *
                  from student s1
                  where s1.sno = sc1.sno and c.cno = sc1.cno and s1.sname = '王敏'
              ) and not exists(
            select *
            from sc sc2
            where sc2.sno = s.sno and sc2.cno = c.cno and grade >= 90
        )
    )
);
```
- 子查询
```sql
select
  sname,
  sage
from student s
where sno in (
  select sno
  from sc
  where grade >= 90 and cno in (
    select cno
    from course
    where cno in (
      select cno
      from sc sc2
      where sc2.sno = (
        select sno
        from student s2
        where s2.sname = '王敏'
      )
    )
  )
  group by sno
  having count(*) >= (select count(*)
                      from sc sc3
                      where sc3.sno = (
                        select sno
                        from student s3
                        where s3.sname = '王敏'
                      ))
);
```

**以王敏为模板，查询选修了王敏选修的所有课程，且王敏优秀的他也优秀，王敏挂科的他也挂科**

- not exist：不存在王敏选修的课程，该生没选，且不存在王敏优秀的课程，该生不优秀，且不存在王敏不及格的课程该生不及格
```sql
select
  sname,
  sage
from student s
where not exists(
    select *
    from course c1
    where exists(
        select *
        from sc sc1
        where exists(
                  select *
                  from student s1
                  where s1.sname = '王敏' and sc1.cno = c1.cno and sc1.sno = s1.sno
              ) and not exists(
            select *
            from sc sc2
            where sc2.cno = c1.cno and sc2.sno = s.sno
        )
    )
) and not exists(
    select *
    from course c2
    where exists(
        select *
        from sc sc3
        where sc3.grade >= 90 and exists(
            select *
            from student s2
            where s2.sname = '王敏' and sc3.cno = c2.cno and sc3.sno = s2.sno
        ) and not exists(
            select *
            from sc sc4
            where sc4.cno = c2.cno and sc4.sno = s.sno and sc4.grade >= 90
        )
    )
) and not exists(
    select *
    from course c3
    where exists(
        select *
        from sc sc5
        where sc5.grade < 60 and exists(
            select *
            from student s3
            where s3.sname = '王敏' and sc5.cno = c3.cno and sc5.sno = s3.sno
        ) and not exists(
            select *
            from sc sc6
            where sc6.cno = c3.cno and sc6.sno = s.sno and sc6.grade < 90
        )
    )
);
```
- 子查询
```sql
select
  sname,
  sage
from student
where sno in (
  select sno
  from sc sc1
  where cno in (
    select cno
    from sc sc2
    where sc2.sno in (
      select sno
      from student
      where sname = '王敏'
    )
  )
  group by sc1.sno
  having count(*) >= (select count(*)
                      from sc sc3
                      where sc3.sno in (
                        select sno
                        from student
                        where sname = '王敏'
                      ))
         and sno not in (
    select sno
    from sc sc1
    where sc1.grade < 90 and cno in (
      select cno
      from sc sc2
      where sc2.grade >= 90 and sc2.sno in (
        select sno
        from student
        where sname = '王敏'
      )
    )
    group by sc1.sno
  )
         and sno not in (
    select sno
    from sc sc1
    where sc1.grade >= 60 and cno in (
      select cno
      from sc sc2
      where sc2.grade < 60 and sc2.sno in (
        select sno
        from student
        where sname = '王敏'
      )
    )
    group by sc1.sno
  )
);
```

**查询选修课所有成绩为优秀的女同学（必须有选修的课程）**

- 关系代数/关系演算：exists
```sql
select
  sname,
  sage
from student s
where not exists(
    select *
    from sc
    where sc.sno = s.sno and sc.grade < 90
) and exists(
          select *
          from sc
          where sc.sno = s.sno
      );
```
- 基于 in 的子查询
```sql
select
  sname,
  sage
from student s
where sno not in (
  select sno
  from sc
  where grade < 90
) and sno in (
  select sno
  from sc
  group by sno
  having count(*) > 0
);
```

**查询CS系学霸（选修了计算机系同学选修的所有课程且都为优秀）**

- 关系代数/关系演算：not exists
```sql
select sname, ssex from student s
where not exists(
  select * from course c where not exists(
    select * from sc where sc.cno = c.cno and sc.sno = s.sno and sc.grade >= 90
  )
);
```
- 基于 in 的子查询
```sql
select sname, sage from student s
where sno in (
  select sno from sc sc1 where sc1.grade >= 90 and cno in (
    select cno from sc sc2 where sc2.sno in (
      select sno from student s1 where s1.sdept = 'CS'
    )
  )
  group by sno
  having count(*) >= (select count(distinct cno) from sc sc3 where sno in (
    select sno from student s2 where s2.sdept = 'CS'
  ))
);
```


**查询CS的女汉子学霸（以优秀成绩选修了所有计算机系男同学选修的全部课程且全为优秀）**

- 关系代数/关系演算：not exists
```sql
select
  sname,
  sage
from student s
where s.ssex = '女' and s.sdept = 'CS' and not exists(
    select *
    from course c
    where exists(
              select *
              from sc sc1
              where sc1.cno = c.cno and exists(
                  select *
                  from student s1
                  where s1.sno = sc1.sno and s1.ssex = '男' and s1.sdept = 'CS'
              )
          ) and not exists(
        select *
        from sc sc2
        where sc2.cno = c.cno and sc2.sno = s.sno and sc2.grade >= 90
    )
);
```
- 基于 in 的子查询
```sql
select
  sname,
  sage
from student s
where s.ssex = '女' and sno in (
  select sno
  from sc sc1
  where grade >= 90 and cno in (
    select cno
    from sc sc2
    where sc2.sno in (
      select sno
      from student s1
      where s1.sdept = 'CS' and s1.ssex = '男'
    )
  )
  group by sc1.sno
  having count(*) >= (select count(distinct cno)
                      from sc sc3
                      where sc3.sno in (
                        select sno
                        from student s2
                        where s2.sdept = 'CS' and s2.ssex = '男'
                      ))
);
```

**查询姓林的女神（选了所有4学分以上的课程且都为优秀）**

- 关系代数/关系演算：
```sql
select
  sname,
  sage
from student s
where ssex = '女' and sname like '林%' and not exists(
    select *
    from sc
    where sc.sno = s.sno and sc.grade < 90
);
```
- 基于 in 的子查询
```sql
select sname, sage from student s
where s.sname like '林%' and s.ssex = '女' and sno not in (
  select sno from sc where sc.grade < 90 and sc.cno in (
    select cno from course c where c.ccredit >= 4
  )
) and sno in (
  select sno from sc sc2
  where cno in (
    select cno from course where ccredit >= 4
  )
  group by sno
  having count(*) >= (select count(*) from course where ccredit >= 4)
);
```
- 更简单一点的（利用 min 函数）
```sql
select sname, sage from student s
where s.sname like '林%' and s.ssex = '女' and sno in (
  select sno from sc where cno in (
    select cno from course where ccredit >= 4
  )
  group by sno
  having min(grade) >= 90 and count(*) >= (select count(*) from course where ccredit >= 4)
);
```