# 在Windows上使用IDEA本地调试Hadoop程序

(1)下载 hadoop-2.7.7.tar.gz

(2)解压，放在 `D:\software\hadoop-2.7.7`

(3)配置环境变量：

    HADOOP_HOME=D:\software\hadoop-2.7.7

在 Path 环境变量后追加 `;%HADOOP_HOME%\bin`

(4)下载`winutils.exe`和`hadoop.dll`文件，放在`D:\software\hadoop-2.7.7\bin`目录下

(5)IDEA 下新建 MAVEN 工程

![1](https://s1.ax1x.com/2020/05/31/t3lVtU.png)

(6)编写 pom.xml 文件

（如果写完 pom.xml，依赖没有添加成功，点击如下图标）

![2](https://s1.ax1x.com/2020/05/31/t3lZhF.png)

(7)写个 wordcount 测试

```java
    import java.io.FileWriter;
    import java.io.IOException;
    import java.net.URI;

    import org.apache.hadoop.conf.Configuration;
    import org.apache.hadoop.fs.FileSystem;
    import org.apache.hadoop.fs.Path;
    import org.apache.hadoop.io.IntWritable;
    import org.apache.hadoop.io.Text;
    import org.apache.hadoop.mapreduce.Job;
    import org.apache.hadoop.mapreduce.Mapper;
    import org.apache.hadoop.mapreduce.Reducer;
    import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
    import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
    import org.apache.log4j.BasicConfigurator;

    public class WordCount {

       private static final String input_path = "hdfs://zgg:9000/input/123.txt";
       private static final String output_path = "hdfs://zgg:9000/output";
       public static void main(String[] args) throws Exception {

          BasicConfigurator.configure();

          Configuration conf = new Configuration();

          FileSystem fileSystem = FileSystem.get(new URI(input_path), conf);
          Path outPath = new Path(output_path);
          if(fileSystem.exists(outPath)){
             fileSystem.delete(outPath, true);
          }

          Job job = Job.getInstance(conf);

          job.setJarByClass(WordCount.class);

          job.setMapperClass(SplitedMapper.class);  //把map任务传给job
          job.setMapOutputKeyClass(Text.class);
          job.setMapOutputValueClass(IntWritable.class);

          job.setReducerClass(CountReducer.class);
          job.setOutputKeyClass(Text.class);
          job.setOutputValueClass(IntWritable.class);

          FileInputFormat.setInputPaths(job,new Path(input_path));  //注意导包
          FileOutputFormat.setOutputPath(job, outPath);

          System.exit(job.waitForCompletion(true)? 0: 1);

       }

       public static class SplitedMapper extends Mapper<Object, Text, Text, IntWritable>{
          private final static IntWritable one = new IntWritable(1);  //value
          private Text word = new Text();   //key

          @Override
          protected void map(Object key, Text value, Context context)
                throws IOException, InterruptedException {

             String[] token = value.toString().split(" ");

             for(String str : token) {
                word.set(str);
                context.write(word, one);
             }        
          }
       }

       public static class CountReducer extends Reducer<Text, IntWritable, Text,IntWritable>{

          private IntWritable result = new IntWritable();  //value      

          @Override
          protected void reduce(Text key, Iterable<IntWritable> values,
                Context context) throws IOException, InterruptedException {
             int sum =0 ;
             for(IntWritable val : values) {
                sum += val.get();
             }

             result.set(sum);
             context.write(key, result);
          }
       }

    }
```