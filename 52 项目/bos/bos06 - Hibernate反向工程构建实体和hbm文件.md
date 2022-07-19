
> 反向工程生成的java类以及hbm文件内容

# 实体类

## 定区

```
package com.hao.bos.entity;
// Generated 2017-8-15 16:30:28 by Hibernate Tools 4.0.0

import java.util.HashSet;
import java.util.Set;

/**
* 定区
*/
public class Decidedzone implements java.io.Serializable {

private static final long serialVersionUID = 1L;

private String id;
private Staff staff;
private String name;
private Set<Subarea> subareas = new HashSet<Subarea>(0);

public Decidedzone() {
}

public Decidedzone(String id) {
this.id = id;
}

public Decidedzone(String id, Staff staff, String name,
Set<Subarea> subareas) {
this.id = id;
this.staff = staff;
this.name = name;
this.subareas = subareas;
}

public String getId() {
return this.id;
}

public void setId(String id) {
this.id = id;
}

public Staff getStaff() {
return this.staff;
}

public void setStaff(Staff staff) {
this.staff = staff;
}

public String getName() {
return this.name;
}

public void setName(String name) {
this.name = name;
}

public Set<Subarea> getSubareas() {
return this.subareas;
}

public void setSubareas(Set<Subarea> subareas) {
this.subareas = subareas;
}

}
```
## 区域

```
package com.hao.bos.entity;

import java.util.HashSet;
import java.util.Set;

/**
* 区域
*/
public class Region implements java.io.Serializable {

private static final long serialVersionUID = 1L;

private String id;
private String province;
private String city;
private String district;
private String postcode;
private String shortcode;
private String citycode;
private Set<Subarea> subareas = new HashSet<Subarea>(0);

public Region() {
}

public Region(String id) {
this.id = id;
}

public Region(String id, String province, String city, String district,
String postcode, String shortcode, String citycode,
Set<Subarea> subareas) {
this.id = id;
this.province = province;
this.city = city;
this.district = district;
this.postcode = postcode;
this.shortcode = shortcode;
this.citycode = citycode;
this.subareas = subareas;
}

public String getId() {
return this.id;
}

public void setId(String id) {
this.id = id;
}

public String getProvince() {
return this.province;
}

public void setProvince(String province) {
this.province = province;
}

public String getCity() {
return this.city;
}

public void setCity(String city) {
this.city = city;
}

public String getDistrict() {
return this.district;
}

public void setDistrict(String district) {
this.district = district;
}

public String getPostcode() {
return this.postcode;
}

public void setPostcode(String postcode) {
this.postcode = postcode;
}

public String getShortcode() {
return this.shortcode;
}

public void setShortcode(String shortcode) {
this.shortcode = shortcode;
}

public String getCitycode() {
return this.citycode;
}

public void setCitycode(String citycode) {
this.citycode = citycode;
}

public Set<Subarea> getSubareas() {
return this.subareas;
}

public void setSubareas(Set<Subarea> subareas) {
this.subareas = subareas;
}

}
```

## 取派员

```
package com.hao.bos.entity;

import java.util.HashSet;
import java.util.Set;

/**
* 取派员
*/
public class Staff implements java.io.Serializable {

private static final long serialVersionUID = 1L;

private String id;
private String name;
private String telephone;
private Character haspda;
private Character deltag;
private String station;
private String standard;
private Set<Decidedzone> decidedzones = new HashSet<Decidedzone>(0);

public Staff() {
}

public Staff(String id) {
this.id = id;
}

public Staff(String id, String name, String telephone, Character haspda,
Character deltag, String station, String standard,
Set<Decidedzone> decidedzones) {
this.id = id;
this.name = name;
this.telephone = telephone;
this.haspda = haspda;
this.deltag = deltag;
this.station = station;
this.standard = standard;
this.decidedzones = decidedzones;
}

public String getId() {
return this.id;
}

public void setId(String id) {
this.id = id;
}

public String getName() {
return this.name;
}

public void setName(String name) {
this.name = name;
}

public String getTelephone() {
return this.telephone;
}

public void setTelephone(String telephone) {
this.telephone = telephone;
}

public Character getHaspda() {
return this.haspda;
}

public void setHaspda(Character haspda) {
this.haspda = haspda;
}

public Character getDeltag() {
return this.deltag;
}

public void setDeltag(Character deltag) {
this.deltag = deltag;
}

public String getStation() {
return this.station;
}

public void setStation(String station) {
this.station = station;
}

public String getStandard() {
return this.standard;
}

public void setStandard(String standard) {
this.standard = standard;
}

public Set<Decidedzone> getDecidedzones() {
return this.decidedzones;
}

public void setDecidedzones(Set<Decidedzone> decidedzones) {
this.decidedzones = decidedzones;
}

}

```

## 分区

```
package com.hao.bos.entity;

/**
* 分区
*/
public class Subarea implements java.io.Serializable {

private static final long serialVersionUID = 1L;

private String id;
private Decidedzone decidedzone; //定区
private Region region; //区域
private String addresskey;
private String startnum;
private String endnum;
private Character single;
private String position;

public Subarea() {
}

public Subarea(String id) {
this.id = id;
}

public Subarea(String id, Decidedzone decidedzone, Region region,
String addresskey, String startnum, String endnum,
Character single, String position) {
this.id = id;
this.decidedzone = decidedzone;
this.region = region;
this.addresskey = addresskey;
this.startnum = startnum;
this.endnum = endnum;
this.single = single;
this.position = position;
}

public String getId() {
return this.id;
}

public void setId(String id) {
this.id = id;
}

public Decidedzone getDecidedzone() {
return this.decidedzone;
}

public void setDecidedzone(Decidedzone decidedzone) {
this.decidedzone = decidedzone;
}

public Region getRegion() {
return this.region;
}

public void setRegion(Region region) {
this.region = region;
}

public String getAddresskey() {
return this.addresskey;
}

public void setAddresskey(String addresskey) {
this.addresskey = addresskey;
}

public String getStartnum() {
return this.startnum;
}

public void setStartnum(String startnum) {
this.startnum = startnum;
}

public String getEndnum() {
return this.endnum;
}

public void setEndnum(String endnum) {
this.endnum = endnum;
}

public Character getSingle() {
return this.single;
}

public void setSingle(Character single) {
this.single = single;
}

public String getPosition() {
return this.position;
}

public void setPosition(String position) {
this.position = position;
}

}
```

# hbm文件

## 定区

```
<?xml version="1.0"?>
<!DOCTYPE hibernate-mapping PUBLIC "-//Hibernate/Hibernate Mapping DTD 3.0//EN"
"http://www.hibernate.org/dtd/hibernate-mapping-3.0.dtd">
<!-- Generated 2017-8-15 16:30:28 by Hibernate Tools 4.0.0 -->
<hibernate-mapping>
<class name="com.hao.bos.entity.Decidedzone" table="bc_decidedzone">
<id name="id" type="string">
<column name="id" length="32" />
<generator class="assigned" />
</id>
<many-to-one name="staff" class="Staff" fetch="select">
<column name="staff_id" length="32" />
</many-to-one>
<property name="name" type="string">
<column name="name" length="30" />
</property>
<set name="subareas" table="bc_subarea" inverse="true" lazy="true" fetch="select">
<key>
<column name="decidedzone_id" length="32" />
</key>
<one-to-many class="Subarea" />
</set>
</class>
</hibernate-mapping>
```
 
## 区域

```
<?xml version="1.0"?>
<!DOCTYPE hibernate-mapping PUBLIC "-//Hibernate/Hibernate Mapping DTD 3.0//EN"
"http://www.hibernate.org/dtd/hibernate-mapping-3.0.dtd">
<!-- Generated 2017-8-15 16:30:28 by Hibernate Tools 4.0.0 -->
<hibernate-mapping>
<class name="com.hao.bos.entity.Region" table="bc_region" >
<id name="id" type="string">
<column name="id" length="32" />
<generator class="assigned" />
</id>
<property name="province" type="string">
<column name="province" length="50" />
</property>
<property name="city" type="string">
<column name="city" length="50" />
</property>
<property name="district" type="string">
<column name="district" length="50" />
</property>
<property name="postcode" type="string">
<column name="postcode" length="50" />
</property>
<property name="shortcode" type="string">
<column name="shortcode" length="30" />
</property>
<property name="citycode" type="string">
<column name="citycode" length="30" />
</property>
<set name="subareas" table="bc_subarea" inverse="true" lazy="true" fetch="select">
<key>
<column name="region_id" length="32" />
</key>
<one-to-many class="Subarea" />
</set>
</class>
</hibernate-mapping>
```
## 员工

```
<?xml version="1.0"?>
<!DOCTYPE hibernate-mapping PUBLIC "-//Hibernate/Hibernate Mapping DTD 3.0//EN"
"http://www.hibernate.org/dtd/hibernate-mapping-3.0.dtd">
<!-- Generated 2017-8-15 16:30:28 by Hibernate Tools 4.0.0 -->
<hibernate-mapping>
<class name="com.hao.bos.entity.Staff" table="bc_staff" >
<id name="id" type="string">
<column name="id" length="32" />
<generator class="assigned" />
</id>
<property name="name" type="string">
<column name="name" length="20" />
</property>
<property name="telephone" type="string">
<column name="telephone" length="20" />
</property>
<property name="haspda" type="java.lang.Character">
<column name="haspda" length="1" />
</property>
<property name="deltag" type="java.lang.Character">
<column name="deltag" length="1" />
</property>
<property name="station" type="string">
<column name="station" length="40" />
</property>
<property name="standard" type="string">
<column name="standard" length="100" />
</property>
<set name="decidedzones" table="bc_decidedzone" inverse="true" lazy="true" fetch="select">
<key>
<column name="staff_id" length="32" />
</key>
<one-to-many class="Decidedzone" />
</set>
</class>
</hibernate-mapping>
```
 
## 分区

```
<?xml version="1.0"?>
<!DOCTYPE hibernate-mapping PUBLIC "-//Hibernate/Hibernate Mapping DTD 3.0//EN"
"http://www.hibernate.org/dtd/hibernate-mapping-3.0.dtd">
<!-- Generated 2017-8-15 16:30:28 by Hibernate Tools 4.0.0 -->
<hibernate-mapping>
<class name="com.hao.bos.entity.Subarea" table="bc_subarea">
<id name="id" type="string">
<column name="id" length="32" />
<generator class="assigned" />
</id>
<many-to-one name="decidedzone" class="Decidedzone" fetch="select">
<column name="decidedzone_id" length="32" />
</many-to-one>
<many-to-one name="region" class="Region" fetch="select">
<column name="region_id" length="32" />
</many-to-one>
<property name="addresskey" type="string">
<column name="addresskey" length="100" />
</property>
<property name="startnum" type="string">
<column name="startnum" length="30" />
</property>
<property name="endnum" type="string">
<column name="endnum" length="30" />
</property>
<property name="single" type="java.lang.Character">
<column name="single" length="1" />
</property>
<property name="position" type="string">
<column name="position" />
</property>
</class>
</hibernate-mapping>
```