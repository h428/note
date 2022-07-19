
# 5. 动态 SQL

- Mybatis 提供对 SQL 语句动态的组装能力，而且其只有几个基本的元素，十分简洁明了

## 5.1 概述

- 动态 SQL 主要包括这些元素： if, choose when otherwise, trim where set, foreach

## 5.2 if 元素

- if 元素用于判断，相当于 Java 中的 if 语句，常常与 test 属性联合使用
- 主要用于条件化 sql 语句片段，如下述例子：
```xml
<select id="findByUsernameAndGender" parameterType="student" resultType="student">
    select * from student where 1=1
    <if test="name != null and name != ''">
        and name like concat('%', #{name}, '%')
    </if>
    <if test="gender != null">
        and gender = #{gender}
    </if>
</select>
```

## 5.3 choose, when, otherwise 元素

- choose, when, otherwise 元素相当于多重 if else 或 swich case 语句，只会选择其中的一个分支
- 例如下述查找学生样例：
```xml
<select id="findStudents" resultType="Student" parameterType="student">
    select id, name, email from student where 1=1
    <choose>
        <!-- 注意 choose 相当于多重 if else，只会选择一个 when 字句 -->
        <when test="stuNo != null and stuNo !=''">
            and stu_no like concat('%', #{stuNo}, '%')
        </when>
        <when test="name != null and name !=''">
            and name like concat('%', #{name}, '%')
        </when>
        <otherwise>
            and email is not null
        </otherwise>
    </choose>
</select>
```

## 5.4 trim, where, set 元素

**where**

- where 标签用于可用于产生 where 字句，并消除首个 and，这样我们可以不用写上面的 1=1 这一句
- 例如前面的代码，使用 where 元素后可以改成下述样子：
```xml
<select id="findStudents" resultType="Student" parameterType="student">
    select id, name, email from student
    <where>
        <choose>
            <!-- 注意 choose 相当于多重 if else，只会选择一个 when 字句 -->
            <when test="stuNo != null and stuNo !=''">
                and stu_no like concat('%', #{stuNo}, '%')
            </when>
            <when test="name != null and name !=''">
                and name like concat('%', #{name}, '%')
            </when>
            <otherwise>
                and email is not null
            </otherwise>
        </choose>
    </where>
</select>
```
- where 元素会自动删除第一个字句的 and 前缀

**trim**

- trim 元素用于构造字句，并对前后缀进行一定的设置和替换，其拥有 prefix, prefixOverrides, suffix, suffixOverrides 四个属性
- 只有 prefix, suffix 属性时表示添加前缀、后缀
- 只有 prefixOverrides, suffixOverrides 表示删除前缀、后缀
- 如果同时拥有 prefix 和 prefixOverrides 则表示用 prefix 内容覆盖 prefixOverrides 内容（也可以理解为删除后再添加），对于 suffix 和 suffixOverrides 同理
- 注意这里的前缀指的是所有字句的第一个字句，比如所有字句都有 and 前缀只会替换第一个，对于后缀同理，一般前缀是 and 后缀是 ,
- 比如，前面的例子可以使用 trim 元素修改为下述内容：
```xml
<select id="findStudents" resultType="Student" parameterType="student">
    select id, name, email from student
    <trim prefix="where" prefixOverrides="and">
        <choose>
            <!-- 注意 choose 相当于多重 if else，只会选择一个 when 字句 -->
            <when test="stuNo != null and stuNo !=''">
                and stu_no like concat('%', #{stuNo}, '%')
            </when>
            <when test="name != null and name !=''">
                and name like concat('%', #{name}, '%')
            </when>
            <otherwise>
                and email is not null
            </otherwise>
        </choose>
    </trim>
</select>
```
- trim 元素是功能最强的元素，其可以用于替换 where 和 set 元素，但 where 和 set 语义化更明显，在适合场景建议使用 where 和 set

**set**

- 在 Hibernate 中常常需要更新某对象，这会发送 sql 更新对象的所有列，而现实的场景往往只需要更新一个字段，若将所有属性都更新一遍会造成极大地消耗
- 稳定的处理方法是只传递主键和要更新的列，然后更新对应列，但是这种情况下，每个字段的更新都需要编写一条 SQL 语句，十分不方便
- 在 Mybatis 中，配合使用 set 元素和 if 元素可以达到条件更新的目标，传递对象，要更新的列设置值，不更新的列为空，然后使用 if 元素做判断，并生成最终要更新的列，十分灵活
- set 元素主要用于更新更新列，会在前面自动插入 set ，相当于 set 字句 （也可以使用 trim 并使用 set 前缀即可）
- 更新 student 表的样例如下，我们可以传递一个 student 对象然后设置要更新的列，不更新的列置位空即可：
```xml
<update id="update" parameterType="student">
    update student
    <set>
        <if test="stuNo != null and stuNo !=''">
            stu_no = #{stuNo},
        </if>
        <if test="name != null and name !=''">
            name = #{name}
        </if>
        <if test="gender != null">
            gender = #{gender}
        </if>
        <if test="birthday != null and birthday !=''">
            birthday = #{birthday}
        </if>
        <if test="phone != null and phone !=''">
            phone = #{phone}
        </if>
        <if test="email != null and email !=''">
            email = #{email}
        </if>
        <if test="studentClass != null and studentClass.id != null">
            class_id = #{studentClass.id}
        </if>
    </set>
    where id = #{id}
</update>
```

## 5.5 foreach 元素

- foreach 元素用于遍历集合，其支持数组、List、Set
- 该元素含有 6 个常用属性：
    - collection 用于设置遍历的集合，可以使一个数组或 List, Set
    - item 表示当前遍历到的项
    - index 表示当前遍历到的下标
    - open 为添加的前缀
    - close 为添加的后缀
    - separator 为添加的项之间的分隔符
- foreach 常用于 in 字句，in 的内容使用 foreach 元素生成
- 对于大量数据的 in 语句我们要特别注意，其会消耗大量的性能，还有一些数据库的 SQL 对执行的 SQL 长度也有限制，所以使用它时要预估一下 collection 对象的长度

## 5.6 test 属性

- test 属性用于判断，在 Mybatis 中广泛使用，作用相当于判断真假
- 大部分场景都用于判断空和非空，但有时也需要判断字符串、数字和枚举等
- 比如判定字符串相等可以写 `<if test="type = 'Y'">`

## 5.7 bind 元素

- bind 元素是基于 OGNL 定义一个上下文变量，以方便后续的使用
- 比如前面的例子可以改写为如下内容：
```xml
<select id="findStudents" resultType="Student" parameterType="student">
    <bind name="pattern_no" value="'%' + stuNo + '%'" />
    <bind name="pattern_name" value="'%' + name + '%'" />
    select id, name, email from student
    <trim prefix="where" prefixOverrides="and">
        <choose>
            <!-- 注意 choose 相当于多重 if else，只会选择一个 when 字句 -->
            <when test="stuNo != null and stuNo !=''">
                and stu_no like #{pattern_no}
            </when>
            <when test="name != null and name !=''">
                and name like concat('%', #{pattern_name}, '%')
            </when>
            <otherwise>
                and email is not null
            </otherwise>
        </choose>
    </trim>
</select>
```
- 但这将要求 stuNo 和 name 都不为空，否则 bind 中的连接会抛出异常，因此我觉得实用性并不打


