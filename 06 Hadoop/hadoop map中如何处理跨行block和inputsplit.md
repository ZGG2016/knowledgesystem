# Hadoop Map中如何处理跨行Block和InputSplit

么对于一个记录行形式的文本大于128M时，HDFS将会分成多块存储（block）
，同时分片并非到每行行尾。这样就会产生两个问题：

	A：Hadoop的一个Block默认是128M，那么对于一个记录行形式的文本，
	   会不会造成一行记录被分到两个Block当中？
	   
	B：在把文件从Block中读取出来进行切分时，会不会造成一行记录被分成两个
	   InputSplit，如果被分成两个InputSplit，这样一个InputSplit里面就有一
	   行不完整的数据，那么处理这个InputSplit的Mapper会不会得
	   出不正确的结果？
	   
对于上面的两个问题，首先再次明确两个概念：Block和InputSplit：

	A：Block是HDFS存储文件的单位（默认是128M）；

	B：InputSplit是MapReduce对文件进行处理和运算的输入单位，
		只是一个逻辑概念，每个InputSplit并没有对文件实际的切割，
		只是记录了要处理的数据的位置（包括文件的path和hosts）和
		长度（由start和length决定）。

因此以行记录形式的文本，可能存在一行记录被划分到不同的Block，
甚至不同的DataNode上去。

通过分析FileInputFormat里面的getSplits方法，
可以得出，某一行记录同样也可能被划分到不同的InputSplit。

从org.apache.hadoop.mapreduce.lib.input.FileInputFormat源码分析

```java
/**  
 * Generate the list of files and make them into FileSplits. 
 * @param job the job context 
 * @throws IOException 
 */  
public List<InputSplit> getSplits(JobContext job) throws IOException {  
  long minSize = Math.max(getFormatMinSplitSize(), getMinSplitSize(job));  
  long maxSize = getMaxSplitSize(job);  

  // generate splits  
  List<InputSplit> splits = new ArrayList<InputSplit>();  
  List<FileStatus> files = listStatus(job);  
  for (FileStatus file: files) {  
    Path path = file.getPath();  
    long length = file.getLen();  
    if (length != 0) {  
      BlockLocation[] blkLocations;  
      if (file instanceof LocatedFileStatus) {  
        blkLocations = ((LocatedFileStatus) file).getBlockLocations();  
      } else {  
        FileSystem fs = path.getFileSystem(job.getConfiguration());  
        blkLocations = fs.getFileBlockLocations(file, 0, length);  
      }  
      if (isSplitable(job, path)) {  
        long blockSize = file.getBlockSize();  
        long splitSize = computeSplitSize(blockSize, minSize, maxSize);  

        long bytesRemaining = length;  
        while (((double) bytesRemaining)/splitSize > SPLIT_SLOP) {  
          int blkIndex = getBlockIndex(blkLocations, length-bytesRemaining);  
          splits.add(makeSplit(path, length-bytesRemaining, splitSize,  
                                   blkLocations[blkIndex].getHosts()));  
          bytesRemaining -= splitSize;  
        }  

        if (bytesRemaining != 0) {  
          int blkIndex = getBlockIndex(blkLocations, length-bytesRemaining);  
          splits.add(makeSplit(path, length-bytesRemaining, bytesRemaining,  
                     blkLocations[blkIndex].getHosts()));  
        }  
      } else { // not splitable  
        splits.add(makeSplit(path, 0, length, blkLocations[0].getHosts()));  
      }  
    } else {   
      //Create empty hosts array for zero length files  
      splits.add(makeSplit(path, 0, length, new String[0]));  
    }  
  }  
  // Save the number of input files for metrics/loadgen  
  job.getConfiguration().setLong(NUM_INPUT_FILES, files.size());  
  LOG.debug("Total # of splits: " + splits.size());  
  return splits;  
}  

```

从上面的代码可以看出，对文件进行切分其实很简单：获取文件在HDFS上的路径
和Block信息，然后根据splitSize对文件进行切分，
`splitSize = computeSplitSize(blockSize, minSize, maxSize);`
maxSize，minSize，blockSize都可以配置，**默认splitSize 就等于blockSize的默认值（128m）**

FileInputFormat对文件的切分是严格按照偏移量来的，因此 **一行记录比较长的话，可能被切分到不同的InputSplit**。 
但这并不会对Map造成影响，尽管一行记录可能被拆分到不同的InputSplit，
但是与FileInputFormat关联的RecordReader被设计的足够健壮，当一行记录
跨InputSplit时，其能够到读取不同的InputSplit，直到把这一行记录读取完成。
我们拿最常见的TextInputFormat源码分析如何处理跨行InputSplit的，
TextInputFormat关联的是LineRecordReader，下面我们先看
LineRecordReader的nextKeyValue方法里读取文件的代码：

```java
public boolean nextKeyValue() throws IOException {  
  if (key == null) {  
    key = new LongWritable();  
  }  
  key.set(pos);  
  if (value == null) {  
    value = new Text();  
  }  
  int newSize = 0;  
  // We always read one extra line, which lies outside the upper  
  // split limit i.e. (end - 1)  
  while (getFilePosition() <= end) {  
    newSize = in.readLine(value, maxLineLength,  
        Math.max(maxBytesToConsume(pos), maxLineLength));  
    pos += newSize;  
    if (newSize < maxLineLength) {  
      break;  
    }  

    // line too long. try again  
    LOG.info("Skipped line of size " + newSize + " at pos " +   
             (pos - newSize));  
  }  
  if (newSize == 0) {  
    key = null;  
    value = null;  
    return false;  
  } else {  
    return true;  
  }  
}  

```

1、其读取文件是通过LineReader（in就是一个LineReader实例）的readLine方法完成的。

关键的逻辑就在这个readLine方法里，这个方法主要的逻辑归纳起来是3点:

- 总是从buffer里读取数据，如果buffer里的数据读完了，先加载下一批数据到buffer

- 在buffer中查找”行尾”，将开始位置至行尾处的数据拷贝给str(也就是最后的Value)。如果为遇到”行尾”，继续加载新的数据到buffer进行查找

- 关键点在于:给到buffer的数据是直接从文件中读取的，完全不会考虑是否超过了
split的界限，而是一直读取到当前行结束为止。

```java
/** 
 * Read a line terminated by one of CR, LF, or CRLF. 
 */  
private int readDefaultLine(Text str, int maxLineLength, int maxBytesToConsume)  
throws IOException {  
  /* We're reading data from in, but the head of the stream may be 
   * already buffered in buffer, so we have several cases: 
   * 1. No newline characters are in the buffer, so we need to copy 
   *    everything and read another buffer from the stream. 
   * 2. An unambiguously terminated line is in buffer, so we just 
   *    copy to str. 
   * 3. Ambiguously terminated line is in buffer, i.e. buffer ends 
   *    in CR.  In this case we copy everything up to CR to str, but 
   *    we also need to see what follows CR: if it's LF, then we 
   *    need consume LF as well, so next call to readLine will read 
   *    from after that. 
   * We use a flag prevCharCR to signal if previous character was CR 
   * and, if it happens to be at the end of the buffer, delay 
   * consuming it until we have a chance to look at the char that 
   * follows. 
   */  
  str.clear();  
  int txtLength = 0; //tracks str.getLength(), as an optimization  
  int newlineLength = 0; //length of terminating newline  
  boolean prevCharCR = false; //true of prev char was CR  
  long bytesConsumed = 0;  
  do {  
    int startPosn = bufferPosn; //starting from where we left off the last time  
    //如果buffer中的数据读完了，先加载一批数据到buffer里   
    if (bufferPosn >= bufferLength) {  
      startPosn = bufferPosn = 0;  
      if (prevCharCR) {  
        ++bytesConsumed; //account for CR from previous read  
      }  
      bufferLength = in.read(buffer);  
      if (bufferLength <= 0) {  
        break; // EOF  
      }  
    }  
    //注意：由于不同操作系统对“行结束符“的定义不同：    
    //UNIX: '\n'  (LF)    
    //Mac:  '\r'  (CR)    
    //Windows: '\r\n'  (CR)(LF)    
    //为了准确判断一行的结尾，程序的判定逻辑是：    
    //1.如果当前符号是LF，可以确定一定是到了行尾，但是需要参考一下前一个    
    //字符，因为如果前一个字符是CR，那就是windows文件，“行结束符的长度”    
    //(即变量：newlineLength)应该是2，否则就是UNIX文件，“行结束符的长度”为1。    
    //2.如果当前符号不是LF，看一下前一个符号是不是CR，如果是也可以确定一定上个字符就是行尾了，这是一个mac文件。    
    //3.如果当前符号是CR的话，还需要根据下一个字符是不是LF判断“行结束符的长度”，所以只是标记一下prevCharCR=true，供读取下个字符时参考  
    for (; bufferPosn < bufferLength; ++bufferPosn) { //search for newline  
      if (buffer[bufferPosn] == LF) {//存在'\n'换行字符     
        newlineLength = (prevCharCR) ? 2 : 1;  
        ++bufferPosn; // at next invocation proceed from following byte  
        break;  
      }  
      if (prevCharCR) { //CR + notLF, we are at notLF  
        newlineLength = 1;  
        break;  
      }  
      prevCharCR = (buffer[bufferPosn] == CR);//存在'\r'回车字符  
    }  
    int readLength = bufferPosn - startPosn;  
    if (prevCharCR && newlineLength == 0) {  
      --readLength; //CR at the end of the buffer  
    }  
    bytesConsumed += readLength;  
    int appendLength = readLength - newlineLength;  
    if (appendLength > maxLineLength - txtLength) {  
      appendLength = maxLineLength - txtLength;  
    }  
    if (appendLength > 0) {  
      str.append(buffer, startPosn, appendLength);  
      txtLength += appendLength;  
    }  
 //newlineLength == 0 就意味着始终没有读到行尾，程序会继续通过文件输入流继续从文件里读取数据。  
 //这里有一个非常重要的地方：in的实例创建自构造函数：org.apache.hadoop.mapreduce.LineRecordReader.lib.input.LineRecordReader.initialize(InputSplit, TaskAttemptContext)    
    //方法内:FSDataInputStream fileIn = fs.open(split.getPath()); 我们以看到:    
    //对于LineRecordReader：当它对取“一行”时，一定是读取到完整的行，不会受filesplit的任何影响，因为它读取是filesplit所在的文件，而不是限定在filesplit的界限范围内。    
    //所以不会出现“断行”的问题！   
  } while (newlineLength == 0 && bytesConsumed < maxBytesToConsume);  

  if (bytesConsumed > (long)Integer.MAX_VALUE) {  
    throw new IOException("Too many bytes before newline: " + bytesConsumed);  
  }  
  return (int)bytesConsumed;  
}  
```

2、按照readLine的上述行为，**在遇到跨split的行时，会将下一个split开始行数据读取出来构成一行完整的数据**，那么下一个split怎么判定开头的一行有没有被上一个split的LineRecordReader读取过从而避免漏读或重复读取开头一行呢?这方面LineRecordReader使用了一个简单而巧妙的方法:

既然无法断定每一个split开始的一行是独立的一行还是被切断的一行的一部分，
**那就跳过每个split的开始一行(当然要除第一个split之外)，从第二行开始读取,然后在到达split的结尾端时总是再多读一行**，
这样数据既能接续起来又避开了断行带来的麻。

以下是相关的源码:

```java
// If this is not the first split, we always throw away first record
// because we always (except the last split) read one extra line in
// next() method.
// 若不是第一个split，总会扔掉第一条记录。因为我们总会
// 使用next()方法读取额外的一行（除了最后一个split）
if (start != 0) {
	start += in.readLine(new Text(), 0, maxBytesToConsume(start));
}
this.pos = start;
```

3、相应地,在LineRecordReader判断是否还有下一行的方法:
org.apache.hadoop.mapreduce.lib.input.LineRecordReader.nextKeyValue()中，
while使用的判定条件保证了InputSplit读取跨界的问题:
当前位置小于或等于split的结尾位置，也就说:
**当前已处于split的结尾位置上时,while依然会执行一次，**
这一次读到显然已经是下一个split的开始行了。

```java
public boolean nextKeyValue() throws IOException {  
   if (key == null) {  
     key = new LongWritable();  
   }  
   key.set(pos);  
   if (value == null) {  
     value = new Text();  
   }  
   int newSize = 0;  
   // We always read one extra line, which lies outside the upper  
   // split limit i.e. (end - 1)  
   while (getFilePosition() <= end) {//保证InputSplit读取边界的问题  
     newSize = in.readLine(value, maxLineLength,  
         Math.max(maxBytesToConsume(pos), maxLineLength));  
     pos += newSize;  
     if (newSize < maxLineLength) {  
       break;  
     }  

     // line too long. try again  
     LOG.info("Skipped line of size " + newSize + " at pos " +   
              (pos - newSize));  
   }  
   if (newSize == 0) {  
     key = null;  
     value = null;  
     return false;  
   } else {  
     return true;  
   }  
 }  
```

原文链接：[Hadoop Map中如何处理跨行Block和InputSplit](https://blog.csdn.net/chengyuqiang/article/details/79156495)















