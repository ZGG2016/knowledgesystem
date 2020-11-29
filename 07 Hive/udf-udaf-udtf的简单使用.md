# udf-udaf-udtf的简单使用

[TOC]

## 1、UDF

1、建一个新类，继承GenericUDF，重写initialize、evaluate和getDisplayString方法。

```java
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

2、将代码打成 jar 包，并将这个 jar 包添加到 Hive classpath。

```sh
hive> add jar /root/jar/udfgetlength.jar;
Added [/root/jar/udfgetlength.jar] to class path
Added resources: [/root/jar/udfgetlength.jar]
```

3、注册自定义函数，并使用

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