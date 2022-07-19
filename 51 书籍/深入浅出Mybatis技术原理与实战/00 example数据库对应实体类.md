
- 实体类满足 JavaBean 的规范，该有默认构造函数和 get/set 方法，但在此处省略，只显示他们的 private 属性
- 并且，为了简便起见，省略了 package 和 import 的内容，自己可以根据自己的喜好定义合适的包名，如com.xxx.entity等

# Admin类

```java
public class Admin {
    private Integer id;
    private String username;
    private String password;

    /**
     * 为了方便测试，定义该函数
     * 调用该函数将随机生成一个 Admin，其 id 为 null
     * @return 返回随机生成的 admin
     */
    public static Admin generate() {
        int num = (int) (Math.random() * 1000);
        Admin admin = new Admin();
        admin.setUsername("admin"+num);
        admin.setPassword("pass"+num);
        return admin;
    }
}
```

# Student类
```java
public class Student {
    private Integer id;
    private String stuNo;
    private String name;
    private Gender gender;
    private Date birthday;
    private String phone;
    private String email;

    /**
     * 随机生成 Student 实例
     * @return 生成的实例
     */
    public static Student generate() {
        int num = (int) (Math.random() * 10000);
        Student student = new Student();
        student.setStuNo(String.valueOf(num));
        student.setName("student" + num);
        student.setGender(num % 2 == 0 ? Gender.MALE : Gender.FEMALE);
        student.setBirthday(new Date());
        student.setPhone("189-5920-" + num);
        student.setEmail("hao" + num + "@xmu.edu.cn");
        return student;
    }
}
```

# Gender类
```java
public enum Gender {
	MALE(1, "男"), FEMALE(10, "女");
	
	private int id;
	private String name;
	
	private Gender(int id, String name){
		this.id = id;
		this.name = name;
	}

	public static Gender getGender(int id){
		if(id == 1){
			return MALE;
		}else if(id == 10){
			return FEMALE;
		}
		return null;
	}
}
```

# StudentCard 类

```java
public class StudentCard {
    private Integer id;
    private Integer stuId;
    private String nativePlace;
    private Date makeDate;
    private Date endDate;
    private String notes;
    private Student student;
}
```

# StudentClass 类

```java
public class StudentClass {
    private Integer id;
    private String name;
    private String notes;
    private List<Student> students;
}
```


# 健康信息相关类

```java
public class MaleStudent extends Student {
    private List<MaleStudentHealth> maleStudentHealthList;
}

public class FemaleStudent extends Student {
    private List<FemaleStudentHealth> femaleStudentHealthList;
}

// 下面两个类其实可以进一步抽象，但书上没提故不抽象
public class MaleStudentHealth {
    private Integer id;
    private Date checkDate;
    private String heart;
    private String liver;
    private String spleen;
    private String lung;
    private String kidney;
    private String prostate;
    private String notes;
}

public class FemaleStudentHealth {
    private Integer id;
    private Date checkDate;
    private String heart;
    private String liver;
    private String spleen;
    private String lung;
    private String kidney;
    private String uterus;
    private String notes;
}

```
