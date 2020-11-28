# sqoop导入hive时，对blob类型的处理

如果直接导入，会出现错误：`ERROR tool.ImportTool: Import failed: java.io.IOException: Hive does not support the SQL type for column name`

## 1、HIVE中blob字段禁用

oraoop-site.xml

```xml
  <property>
    <name>oraoop.import.omit.lobs.and.long</name>
    <value>true</value>
    <description>If true, OraOop will omit BLOB, CLOB, NCLOB and LONG columns during an Import.
    </description>
  </property>
```

```sql
mysql> select * from apps_blob;
+----+--------------+
| id | name         |
+----+--------------+
|  1 | 0x6161096262 |
|  2 | 0x6363096464 |
+----+--------------+

[root@zgg sqoop-1.4.7.bin__hadoop-2.6.0]# sqoop import --connect jdbc:mysql://zgg:3306/users --driver com.mysql.cj.jdbc.Driver --username root --password 1234 --table apps_blob --hive-import --target-dir '/user/hive/warehouse/apps_blob' --hive-drop-import-delims --map-column-hive name=string --fields-terminated-by ',' --lines-terminated-by '\n'  

hive> select * from apps_blob;
OK
1       61 61 09 62 62
2       63 63 09 64 64
```

## 2、当不能禁用时，如果需要其他字段，而不需要blob字段，所以在导入的时候指定`--columns`来过滤。

```sql
mysql> alter table apps_blob add age int(10) not null;  
mysql> select * from apps_blob;
+----+--------------+-----+
| id | name         | age |
+----+--------------+-----+
|  1 | 0x6161096262 |  11 |
|  2 | 0x6363096464 |  22 |
+----+--------------+-----+

mysql> desc apps_blob;
+-------+------+------+-----+---------+-------+
| Field | Type | Null | Key | Default | Extra |
+-------+------+------+-----+---------+-------+
| id    | int  | NO   | PRI | NULL    |       |
| name  | blob | NO   |     | NULL    |       |
| age   | int  | NO   |     | NULL    |       |
+-------+------+------+-----+---------+-------+

[root@zgg sqoop-1.4.7.bin__hadoop-2.6.0]# sqoop import --connect jdbc:mysql://zgg:3306/users --driver com.mysql.cj.jdbc.Driver --username root --password 1234 --table apps_blob --hive-import --target-dir '/user/hive/warehouse/apps_blob' --columns 'id,age' --fields-terminated-by ',' --lines-terminated-by '\n' 

hive> select * from apps_blob;
OK
1       11
2       22
3       33

hive> desc apps_blob;
OK
id                      int                                         
age                     int 
```

## 3、直接入库后使用udf来转换

## 4、从数据库导出时，把BLOB转成STRING保存

```java
package com.ganymede.test;
 
/**
 * 十六进制的转换操作
 * @author Ganymede
 *
 */
public class Hex {
 
	/**
	 * 用于建立十六进制字符的输出的小写字符数组
	 */
	private static final char[] DIGITS_LOWER = { '0', '1', '2', '3', '4', '5',
			'6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
 
	/**
	 * 用于建立十六进制字符的输出的大写字符数组
	 */
	private static final char[] DIGITS_UPPER = { '0', '1', '2', '3', '4', '5',
			'6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
 
	/**
	 * 将字节数组转换为十六进制字符数组
	 * 
	 * @param data
	 *            byte[]
	 * @return 十六进制char[]
	 */
	public static char[] encodeHex(byte[] data) {
		return encodeHex(data, true);
	}
 
	/**
	 * 将字节数组转换为十六进制字符数组
	 * 
	 * @param data
	 *            byte[]
	 * @param toLowerCase
	 *            <code>true</code> 传换成小写格式 ， <code>false</code> 传换成大写格式
	 * @return 十六进制char[]
	 */
	public static char[] encodeHex(byte[] data, boolean toLowerCase) {
		return encodeHex(data, toLowerCase ? DIGITS_LOWER : DIGITS_UPPER);
	}
 
	/**
	 * 将字节数组转换为十六进制字符数组
	 * 
	 * @param data
	 *            byte[]
	 * @param toDigits
	 *            用于控制输出的char[]
	 * @return 十六进制char[]
	 */
	protected static char[] encodeHex(byte[] data, char[] toDigits) {
		int l = data.length;
		char[] out = new char[l << 1];
		// two characters form the hex value.
		for (int i = 0, j = 0; i < l; i++) {
			out[j++] = toDigits[(0xF0 & data[i]) >>> 4];
			out[j++] = toDigits[0x0F & data[i]];
		}
		return out;
	}
 
	/**
	 * 将字节数组转换为十六进制字符串
	 * 
	 * @param data
	 *            byte[]
	 * @return 十六进制String
	 */
	public static String encodeHexStr(byte[] data) {
		return encodeHexStr(data, true);
	}
 
	/**
	 * 将字节数组转换为十六进制字符串
	 * 
	 * @param data
	 *            byte[]
	 * @param toLowerCase
	 *            <code>true</code> 传换成小写格式 ， <code>false</code> 传换成大写格式
	 * @return 十六进制String
	 */
	public static String encodeHexStr(byte[] data, boolean toLowerCase) {
		return encodeHexStr(data, toLowerCase ? DIGITS_LOWER : DIGITS_UPPER);
	}
 
	/**
	 * 将字节数组转换为十六进制字符串
	 * 
	 * @param data
	 *            byte[]
	 * @param toDigits
	 *            用于控制输出的char[]
	 * @return 十六进制String
	 */
	protected static String encodeHexStr(byte[] data, char[] toDigits) {
		return new String(encodeHex(data, toDigits));
	}
 
	/**
	 * 将十六进制字符数组转换为字节数组
	 * 
	 * @param data
	 *            十六进制char[]
	 * @return byte[]
	 * @throws RuntimeException
	 *             如果源十六进制字符数组是一个奇怪的长度，将抛出运行时异常
	 */
	public static byte[] decodeHex(char[] data) {
 
		int len = data.length;
 
		if ((len & 0x01) != 0) {
			throw new RuntimeException("Odd number of characters.");
		}
 
		byte[] out = new byte[len >> 1];
 
		// two characters form the hex value.
		for (int i = 0, j = 0; j < len; i++) {
			int f = toDigit(data[j], j) << 4;
			j++;
			f = f | toDigit(data[j], j);
			j++;
			out[i] = (byte) (f & 0xFF);
		}
 
		return out;
	}
 
	/**
	 * 将十六进制字符转换成一个整数
	 * 
	 * @param ch
	 *            十六进制char
	 * @param index
	 *            十六进制字符在字符数组中的位置
	 * @return 一个整数
	 * @throws RuntimeException
	 *             当ch不是一个合法的十六进制字符时，抛出运行时异常
	 */
	protected static int toDigit(char ch, int index) {
		int digit = Character.digit(ch, 16);
		if (digit == -1) {
			throw new RuntimeException("Illegal hexadecimal character " + ch
					+ " at index " + index);
		}
		return digit;
	}
 
	public static void main(String[] args) {
		String srcStr = "待转换字符串";
		String encodeStr = encodeHexStr(srcStr.getBytes());
		String decodeStr = new String(decodeHex(encodeStr.toCharArray()));
		System.out.println("转换前：" + srcStr);
		System.out.println("转换后：" + encodeStr);
		System.out.println("还原后：" + decodeStr);
		
		
		System.out.println("---------------------------------------");
		decodeStr = new String(decodeHex("3435363738390d0a626c6f62".toCharArray()));
		System.out.println("还原后：" + decodeStr);
	}
 
}
```



参考：[https://blog.csdn.net/kwu_ganymede/article/details/49096695?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-3.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-3.control](https://blog.csdn.net/kwu_ganymede/article/details/49096695?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-3.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-3.control)