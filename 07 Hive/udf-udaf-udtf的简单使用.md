# udf-udaf-udtf的简单使用

[TOC]

## 1、UDF

(1)建一个新类，继承GenericUDF，实现initialize、evaluate和getDisplayString方法。

```java
package hive.udf;

import org.apache.hadoop.hive.ql.exec.Description;
import org.apache.hadoop.hive.ql.exec.UDFArgumentException;
import org.apache.hadoop.hive.ql.exec.UDFArgumentLengthException;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.udf.generic.GenericUDF;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorFactory;
import org.apache.hadoop.hive.serde2.objectinspector.primitive.StringObjectInspector;

@Description(name="GetLength",
        value="_FUNC_(str) - Returns the length of this string.",
        extended = "Example:\n"
                + " > SELECT _FUNC_('abc') FROM src; \n")
public class GetLengthG extends GenericUDF {

    StringObjectInspector ss;

    @Override
    public ObjectInspector initialize(ObjectInspector[] arguments) throws UDFArgumentException {
        if(arguments.length>1){
            throw new UDFArgumentLengthException("GetLength Only take one argument:ss");
        }

        ss = (StringObjectInspector) arguments[0];

        return ss;

    }

    @Override
    public Object evaluate(DeferredObject[] arguments) throws HiveException {
        String s = ss.getPrimitiveJavaObject(arguments[0].get());

        return s.length();
    }

    @Override
    public String getDisplayString(String[] children) {
        return "GetLength";
    }
}

```   

-----------------------------------------

```java
// UDF类被弃用了
package hive.udf;

import org.apache.hadoop.hive.ql.exec.Description;
import org.apache.hadoop.hive.ql.exec.UDF;

@Description(name="GetLength",
        value="_FUNC_(str) - Returns the length of this string.",
        extended = "Example:\n"
                + " > SELECT _FUNC_('abc') FROM src; \n")

public class GetLength extends UDF {
    public int evaluate(String s) {
        return s.length();
    }
}

```

------------------------------------------ 

(2)将代码打成 jar 包，并将这个 jar 包添加到 Hive classpath。

```sh
hive> add jar /root/jar/udfgetlength.jar;
Added [/root/jar/udfgetlength.jar] to class path
Added resources: [/root/jar/udfgetlength.jar]
```

(3)注册自定义函数，并使用

```sh
# function是新建的函数名，as后的字符串是主类路径
hive> create temporary function GetLength as 'hive.udf.GetLength';
OK
Time taken: 0.051 seconds
hive> describe function GetLength;
OK
GetLength(str) - Returns the length of this string.
Time taken: 0.028 seconds, Fetched: 1 row(s)
hive> select GetLength("abc");
OK
3
Time taken: 0.415 seconds, Fetched: 1 row(s)
```

(4)在hive的命令行窗口删除函数

    Drop [temporary] function [if exists] [dbname.]function_name;

```sh
hive> Drop temporary function GetLength;
OK
Time taken: 0.018 seconds
```

## 2、UDTF

(1)建一个新类，继承GenericUDTF，实现initialize、process和close方法。

```java
package hive.udtf;

import org.apache.hadoop.hive.ql.exec.Description;
import org.apache.hadoop.hive.ql.exec.UDFArgumentException;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.udf.generic.GenericUDTF;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorFactory;
import org.apache.hadoop.hive.serde2.objectinspector.StructObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorFactory;

import java.util.ArrayList;
import java.util.List;

@Description(name="GetName",
        value="_FUNC_(str) - Returns the name this string contains.",
        extended = "Example:\n"
                + " > SELECT _FUNC_('mike:jackson') FROM src; \n")
public class GetName extends GenericUDTF {

    @Override
    public StructObjectInspector initialize(StructObjectInspector argOIs) throws UDFArgumentException {

        List<String> fieldNames = new ArrayList<String>();
        List<ObjectInspector> fieldOIs = new ArrayList<ObjectInspector>();

        fieldNames.add("first_name");
        fieldOIs.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);

        fieldNames.add("last_name");
        fieldOIs.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);

        return ObjectInspectorFactory.getStandardStructObjectInspector(fieldNames, fieldOIs);
    }

    @Override
    public void process(Object[] args) throws HiveException {
        String name = args[0].toString();
        forward(name.split(":"));
    }

    @Override
    public void close() throws HiveException {

    }
}

```
(2)打jar包、注册、使用

```sh
hive> add jar /root/jar/getname.jar;
Added [/root/jar/getname.jar] to class path
Added resources: [/root/jar/getname.jar]

hive> create temporary function GetName as 'hive.udtf.GetName';
OK
Time taken: 0.027 seconds

hive> select GetName("mike:jackson");
OK
mike    jackson
Time taken: 4.113 seconds, Fetched: 1 row(s)
```