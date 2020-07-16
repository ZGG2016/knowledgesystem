# 源码：FileInputFormat类


package org.apache.hadoop.mapreduce.lib.input;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import java.util.concurrent.TimeUnit;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.LocatedFileStatus;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.PathFilter;
import org.apache.hadoop.fs.BlockLocation;
import org.apache.hadoop.fs.RemoteIterator;
import org.apache.hadoop.mapred.LocatedFileStatusFetcher;
import org.apache.hadoop.mapred.SplitLocationInfo;
import org.apache.hadoop.mapreduce.InputFormat;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.JobContext;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.security.TokenCache;
import org.apache.hadoop.util.ReflectionUtils;
import org.apache.hadoop.util.StopWatch;
import org.apache.hadoop.util.StringUtils;

import com.google.common.collect.Lists;

/** 
 * A base class for file-based {@link InputFormat}s.
 *  基于文件的输入描述的基类，继承InputFormat
 * <p><code>FileInputFormat</code> is the base class for all file-based 
 * <code>InputFormat</code>s. This provides a generic implementation of
 * {@link #getSplits(JobContext)}.
 * Subclasses of <code>FileInputFormat</code> can also override the 
 * {@link #isSplitable(JobContext, Path)} method to ensure input-files are
 * not split-up and are processed as a whole by {@link Mapper}s.
 * 其子类可重写isSplitable(JobContext, Path)方法，可以确保不划分输入文件，
 * 将其完整的传给Mapper处理 。
 */
@InterfaceAudience.Public
@InterfaceStability.Stable

// 抽象类
public abstract class FileInputFormat<K, V> extends InputFormat<K, V> {
  public static final String INPUT_DIR =   // 输入目录
    "mapreduce.input.fileinputformat.inputdir";
  public static final String SPLIT_MAXSIZE =    // 分片的最大长度
    "mapreduce.input.fileinputformat.split.maxsize";
  public static final String SPLIT_MINSIZE =   // 分片的最小长度
    "mapreduce.input.fileinputformat.split.minsize";
  public static final String PATHFILTER_CLASS = 
    "mapreduce.input.pathFilter.class";
  public static final String NUM_INPUT_FILES =
    "mapreduce.input.fileinputformat.numinputfiles";
  public static final String INPUT_DIR_RECURSIVE =
    "mapreduce.input.fileinputformat.input.dir.recursive";
  public static final String LIST_STATUS_NUM_THREADS =
      "mapreduce.input.fileinputformat.list-status.num-threads";
  public static final int DEFAULT_LIST_STATUS_NUM_THREADS = 1;

  private static final Log LOG = LogFactory.getLog(FileInputFormat.class);

  private static final double SPLIT_SLOP = 1.1;   // 10% slop
  
  @Deprecated
  public static enum Counter { 
    BYTES_READ
  }

  // 过滤掉以"_"、"."开头的文件
  private static final PathFilter hiddenFileFilter = new PathFilter(){
      public boolean accept(Path p){
        String name = p.getName(); 
        return !name.startsWith("_") && !name.startsWith("."); 
      }
    }; 

  /**
   * Proxy PathFilter that accepts a path only if all filters given in the
   * constructor do. Used by the listPaths() to apply the built-in
   * hiddenFileFilter together with a user provided one (if any).
   */
  private static class MultiPathFilter implements PathFilter {
    private List<PathFilter> filters;  // 新建了一个包含多个过滤条件的列表

    public MultiPathFilter(List<PathFilter> filters) {
      this.filters = filters;
    }

    public boolean accept(Path path) {
      for (PathFilter filter : filters) {
        if (!filter.accept(path)) {  // 只要不满足其中的一个filter，就返回false
          return false;
        }
      }
      return true;  // 都满足，就返回true
    }
  }
  
  /**
   * @param job
   *          the job to modify
   * @param inputDirRecursive  递归的设置输入目录
   */
  public static void setInputDirRecursive(Job job,
      boolean inputDirRecursive) {
    job.getConfiguration().setBoolean(INPUT_DIR_RECURSIVE,
        inputDirRecursive);
  }
 
  /**
   * @param job
   *          the job to look at.   是不是递归的读文件
   * @return should the files to be read recursively?
   */
  public static boolean getInputDirRecursive(JobContext job) {
    return job.getConfiguration().getBoolean(INPUT_DIR_RECURSIVE,
        false);
  }

  /**
   * Get the lower bound on split size imposed by the format.
   * @return the number of bytes of the minimal split for this format
   */
  protected long getFormatMinSplitSize() {
    return 1;  // 在 FileInputFormat 读取文件的格式下，分片的最小长度是1
  }

  /**
   * Is the given filename splitable? Usually, true, but if the file is
   * stream compressed, it will not be.
   * 文件是否可划分。通常是true。如果文件是压缩流，那么就是false
   * <code>FileInputFormat</code> implementations can override this and return
   * <code>false</code> to ensure that individual input files are never split-up
   * so that {@link Mapper}s process entire files.
   *  其实现类可重写这个方法。让文件不划分。
   * @param context the job context
   * @param filename the file name to check
   * @return is this file splitable?
   */
  protected boolean isSplitable(JobContext context, Path filename) {
    return true;
  }

  /**
   * Set a PathFilter to be applied to the input paths for the map-reduce job.
   * @param job the job to modify  设置一个文件过滤器，过滤输入文件
   * @param filter the PathFilter class use for filtering the input paths.
   */
  public static void setInputPathFilter(Job job,
                                        Class<? extends PathFilter> filter) {
    job.getConfiguration().setClass(PATHFILTER_CLASS, filter, 
                                    PathFilter.class);
  }

  /**
   * Set the minimum input split size  设置最小的输入分片长度
   * @param job the job to modify
   * @param size the minimum size
   */
  public static void setMinInputSplitSize(Job job,
                                          long size) {
    job.getConfiguration().setLong(SPLIT_MINSIZE, size);
  } // 将SPLIT_MINSIZE 设置为 size

  /**
   * Get the minimum split size 获取最小的分片长度
   * @param job the job
   * @return the minimum number of bytes that can be in a split 最小的字节数量
   */
  public static long getMinSplitSize(JobContext job) {
    return job.getConfiguration().getLong(SPLIT_MINSIZE, 1L);
  }

  /*
   * getLong：如果SPLIT_MINSIZE是null，就返回默认的1L。
   * （getHexDigits）
   * 否则就返回SPLIT_MINSIZE
   */
//        public long getLong(String name, long defaultValue) {
//            String valueString = getTrimmed(name);
//            if (valueString == null)
//                return defaultValue;
//            String hexString = getHexDigits(valueString);
//            if (hexString != null) {
//                return Long.parseLong(hexString, 16);
//            }
//            return Long.parseLong(valueString);
//        }

  /**
   * Set the maximum split size 设置最大的输入分片长度
   * @param job the job to modify
   * @param size the maximum split size
   */
  public static void setMaxInputSplitSize(Job job,
                                          long size) {
    job.getConfiguration().setLong(SPLIT_MAXSIZE, size);
  }

  /**
   * Get the maximum split size.
   * @param context the job to look at.
   * @return the maximum number of bytes a split can include
   */
  public static long getMaxSplitSize(JobContext context) {
    return context.getConfiguration().getLong(SPLIT_MAXSIZE, 
                                              Long.MAX_VALUE);
  }

  /**
   * Get a PathFilter instance of the filter set for the input paths.
   * 返回PathFilter实例
   * @return the PathFilter instance set for the job, NULL if none has been set.
   */
  public static PathFilter getInputPathFilter(JobContext context) {
    Configuration conf = context.getConfiguration();
    Class<?> filterClass = conf.getClass(PATHFILTER_CLASS, null,
        PathFilter.class);
    return (filterClass != null) ?
        (PathFilter) ReflectionUtils.newInstance(filterClass, conf) : null;
  }

  /** List input directories.  列出输入目录
   * Subclasses may override to, e.g., select only files matching a regular
   * expression.  子类可重写此方法，例如，只选择符合匹配规则的文件
   * 
   * FileStatus：描述了客户端侧的文件信息
   * @param job the job to list input paths for
   * @return array of FileStatus objects
   * @throws IOException if zero items.
   */
  protected List<FileStatus> listStatus(JobContext job
                                        ) throws IOException {
    Path[] dirs = getInputPaths(job);
    if (dirs.length == 0) {
      throw new IOException("No input paths specified in job");
    }
    
    // get tokens for all the required FileSystems..
    TokenCache.obtainTokensForNamenodes(job.getCredentials(), dirs, 
                                        job.getConfiguration());

    // Whether we need to recursive look into the directory structure
	// 递归查看目录
    boolean recursive = getInputDirRecursive(job);

    // creates a MultiPathFilter with the hiddenFileFilter and the
    // user provided one (if any).
	// 创建 MultiPathFilter，包含 hiddenFileFilter 和用户自定义的Filter
    List<PathFilter> filters = new ArrayList<PathFilter>();
    filters.add(hiddenFileFilter);
    PathFilter jobFilter = getInputPathFilter(job);
    if (jobFilter != null) {
      filters.add(jobFilter);
    }
    PathFilter inputFilter = new MultiPathFilter(filters);
    
    List<FileStatus> result = null;
	
	// 单线程和多线程分开处理
    int numThreads = job.getConfiguration().getInt(LIST_STATUS_NUM_THREADS,
        DEFAULT_LIST_STATUS_NUM_THREADS);
    StopWatch sw = new StopWatch().start();
    if (numThreads == 1) {  // 单线程
      result = singleThreadedListStatus(job, dirs, inputFilter, recursive);
    } else {  // 多线程
      Iterable<FileStatus> locatedFiles = null;
      try {
        LocatedFileStatusFetcher locatedFileStatusFetcher = new LocatedFileStatusFetcher(
            job.getConfiguration(), dirs, recursive, inputFilter, true);
        locatedFiles = locatedFileStatusFetcher.getFileStatuses();
      } catch (InterruptedException e) {
        throw new IOException("Interrupted while getting file statuses");
      }
      result = Lists.newArrayList(locatedFiles);
    }
    
    sw.stop();
    if (LOG.isDebugEnabled()) {
      LOG.debug("Time taken to get FileStatuses: "
          + sw.now(TimeUnit.MILLISECONDS));
    }
    LOG.info("Total input paths to process : " + result.size()); 
    return result;
  }

  // 单线程处理
  private List<FileStatus> singleThreadedListStatus(JobContext job, Path[] dirs,
      PathFilter inputFilter, boolean recursive) throws IOException {
    List<FileStatus> result = new ArrayList<FileStatus>();
    List<IOException> errors = new ArrayList<IOException>();
    for (int i=0; i < dirs.length; ++i) {
      Path p = dirs[i];
      FileSystem fs = p.getFileSystem(job.getConfiguration()); 
      FileStatus[] matches = fs.globStatus(p, inputFilter); //根据inputFilter过滤
      if (matches == null) {
        errors.add(new IOException("Input path does not exist: " + p));
      } else if (matches.length == 0) {
        errors.add(new IOException("Input Pattern " + p + " matches 0 files"));
      } else {
        for (FileStatus globStat: matches) {
          if (globStat.isDirectory()) {  // 是目录，迭代遍历
            RemoteIterator<LocatedFileStatus> iter =
                fs.listLocatedStatus(globStat.getPath());
            while (iter.hasNext()) {
              LocatedFileStatus stat = iter.next();  // 遍历取到值
              if (inputFilter.accept(stat.getPath())) {  // 过滤
                if (recursive && stat.isDirectory()) {  // 还是目录递归处理
                  addInputPathRecursively(result, fs, stat.getPath(),
                      inputFilter);
                } else {
                  result.add(stat); // 文件的话添加
                }
              }
            }
          } else {
            result.add(globStat); // 文件的话添加
          } 
        }
      }
    }

    if (!errors.isEmpty()) {
      throw new InvalidInputException(errors);
    }
    return result;
  }
  
  /**
   * 递归的将输入路径的文件添加到结果列表
   * Add files in the input path recursively into the results.
   * @param result
   *          The List to store all files.
   * @param fs
   *          The FileSystem.
   * @param path
   *          The input path.
   * @param inputFilter
   *          The input filter that can be used to filter files/dirs. 
   * @throws IOException
   */
  protected void addInputPathRecursively(List<FileStatus> result,
      FileSystem fs, Path path, PathFilter inputFilter) 
      throws IOException {
    RemoteIterator<LocatedFileStatus> iter = fs.listLocatedStatus(path);
    while (iter.hasNext()) {
      LocatedFileStatus stat = iter.next();
      if (inputFilter.accept(stat.getPath())) {
        if (stat.isDirectory()) {
          addInputPathRecursively(result, fs, stat.getPath(), inputFilter);
        } else {
          result.add(stat);
        }
      }
    }
  }
  
  
  /**
   * A factory that makes the split for this class. It can be overridden
   * by sub-classes to make sub-types
   *
   * 进行分片，传入了文件、起始位置、偏移量和主机列表，
   * 实际返回了 FileSplit 对象  （FileSplit第一个构造方法）
   */
  protected FileSplit makeSplit(Path file, long start, long length, 
                                String[] hosts) {
    return new FileSplit(file, start, length, hosts);
  }
  
  /**
   * A factory that makes the split for this class. It can be overridden
   * by sub-classes to make sub-types（FileSplit第二个构造方法）
   */
  protected FileSplit makeSplit(Path file, long start, long length, 
                                String[] hosts, String[] inMemoryHosts) {
    return new FileSplit(file, start, length, hosts, inMemoryHosts);
  }

  /** 
   * Generate the list of files and make them into FileSplits.
   * @param job the job context
   * @throws IOException
   */
  public List<InputSplit> getSplits(JobContext job) throws IOException {
  
    // StopWatch：一个简化的秒表实现，可以测量时间在纳秒。
    StopWatch sw = new StopWatch().start();
	
	// 1
	// job.getConfiguration().getLong(SPLIT_MINSIZE, 1L);
    long minSize = Math.max(getFormatMinSplitSize(), getMinSplitSize(job));
    
	// context.getConfiguration().getLong(SPLIT_MAXSIZE,Long.MAX_VALUE);
	long maxSize = getMaxSplitSize(job);

    // generate splits
	// 分片的列表
    List<InputSplit> splits = new ArrayList<InputSplit>();
	
	// FileStatus：描述了客户端侧的文件信息
	// 文件信息的列表
    List<FileStatus> files = listStatus(job);
	
    for (FileStatus file: files) {
      Path path = file.getPath(); // 文件路径
      long length = file.getLen(); // 文件大小
      if (length != 0) {
	  
	  // BlockLocation ：表示块在网络中位置信息
        BlockLocation[] blkLocations;
        if (file instanceof LocatedFileStatus) {
          blkLocations = ((LocatedFileStatus) file).getBlockLocations();
        } else {
          FileSystem fs = path.getFileSystem(job.getConfiguration());
          blkLocations = fs.getFileBlockLocations(file, 0, length);
        }
        if (isSplitable(job, path)) {
		
		  // 取块大小
          long blockSize = file.getBlockSize();
		  
		  // 取分片大小
          long splitSize = computeSplitSize(blockSize, minSize, maxSize);

          long bytesRemaining = length;
		  
		  // 文件大小 除以 分片大小  > 1.1 ，切片
          while (((double) bytesRemaining)/splitSize > SPLIT_SLOP) {
		    // 取块索引
            int blkIndex = getBlockIndex(blkLocations, length-bytesRemaining);
            
			// 添加一个分片
			// makeSplit：实际 new FileSplit
			splits.add(makeSplit(path, length-bytesRemaining, splitSize,
                        blkLocations[blkIndex].getHosts(),
                        blkLocations[blkIndex].getCachedHosts()));
            bytesRemaining -= splitSize; // 去掉已经划分过的位置
          }

		  // 还没到文件的末尾
          if (bytesRemaining != 0) {
		  
		    // 取块索引
            int blkIndex = getBlockIndex(blkLocations, length-bytesRemaining);
            // 直接添加
			splits.add(makeSplit(path, length-bytesRemaining, bytesRemaining,
                       blkLocations[blkIndex].getHosts(),
                       blkLocations[blkIndex].getCachedHosts()));
          }
        } else { // 若不可切分，整个文件作为一个分片
          splits.add(makeSplit(path, 0, length, blkLocations[0].getHosts(),
                      blkLocations[0].getCachedHosts()));
        }
      } else { 
	    // 文件长度是0，就创建一个空的分片
        //Create empty hosts array for zero length files
        splits.add(makeSplit(path, 0, length, new String[0]));
      }
    }
    // Save the number of input files for metrics/loadgen
	// 在配置中记录分片的数量
    job.getConfiguration().setLong(NUM_INPUT_FILES, files.size());
    sw.stop();
    if (LOG.isDebugEnabled()) {
      LOG.debug("Total # of splits generated by getSplits: " + splits.size()
          + ", TimeTaken: " + sw.now(TimeUnit.MILLISECONDS));
    }
    return splits;
  }

	// 取分片大小
  protected long computeSplitSize(long blockSize, long minSize,
                                  long maxSize) {
	// 先取 块大小 和 分片的最大大小  中的最小值，再和 分片的最小大小 比较取最大值							  
    return Math.max(minSize, Math.min(maxSize, blockSize));
  }

  protected int getBlockIndex(BlockLocation[] blkLocations, 
                              long offset) {
    for (int i = 0 ; i < blkLocations.length; i++) {
      // is the offset inside this block?
      if ((blkLocations[i].getOffset() <= offset) &&
          (offset < blkLocations[i].getOffset() + blkLocations[i].getLength())){
        return i;
      }
    }
    BlockLocation last = blkLocations[blkLocations.length -1];
    long fileLength = last.getOffset() + last.getLength() -1;
    throw new IllegalArgumentException("Offset " + offset + 
                                       " is outside of file (0.." +
                                       fileLength + ")");
  }

  /**
   * Sets the given comma separated paths as the list of inputs 
   * for the map-reduce job.
   *  设置多个输入路径，逗号分隔 
   * @param job the job
   * @param commaSeparatedPaths Comma separated paths to be set as 
   *        the list of inputs for the map-reduce job. 字符串
   */
  public static void setInputPaths(Job job, 
                                   String commaSeparatedPaths
                                   ) throws IOException {
    setInputPaths(job, StringUtils.stringToPath(
                        getPathStrings(commaSeparatedPaths)));
  }

  /**
   * Add the given comma separated paths to the list of inputs for
   *  the map-reduce job.
   * 添加
   * @param job The job to modify
   * @param commaSeparatedPaths Comma separated paths to be added to
   *        the list of inputs for the map-reduce job.
   */
  public static void addInputPaths(Job job, 
                                   String commaSeparatedPaths
                                   ) throws IOException {
    for (String str : getPathStrings(commaSeparatedPaths)) {
      addInputPath(job, new Path(str));
    }
  }

  /**
   * Set the array of {@link Path}s as the list of inputs
   * for the map-reduce job.
   * 
   * @param job The job to modify 
   * @param inputPaths the {@link Path}s of the input directories/files 
   *  是Path类型
   * for the map-reduce job.
   */ 
  public static void setInputPaths(Job job, 
                                   Path... inputPaths) throws IOException {
    Configuration conf = job.getConfiguration();
	// makeQualified：相当于格式检查，确保指向了系统的某个文件
    Path path = inputPaths[0].getFileSystem(conf).makeQualified(inputPaths[0]);
    
	// escapeString：使用默认转义字符转义字符串中的逗号
	StringBuffer str = new StringBuffer(StringUtils.escapeString(path.toString()));
    for(int i = 1; i < inputPaths.length;i++) {
      str.append(StringUtils.COMMA_STR);
      path = inputPaths[i].getFileSystem(conf).makeQualified(inputPaths[i]);
      str.append(StringUtils.escapeString(path.toString()));
    }
    conf.set(INPUT_DIR, str.toString());
  }

  /**
   * Add a {@link Path} to the list of inputs for the map-reduce job.
   * 
   * @param job The {@link Job} to modify
   * @param path {@link Path} to be added to the list of inputs for 
   *            the map-reduce job.
   */
  public static void addInputPath(Job job, 
                                  Path path) throws IOException {
    Configuration conf = job.getConfiguration();
    path = path.getFileSystem(conf).makeQualified(path);
    String dirStr = StringUtils.escapeString(path.toString());
    String dirs = conf.get(INPUT_DIR);
    conf.set(INPUT_DIR, dirs == null ? dirStr : dirs + "," + dirStr);
  }
  
  // This method escapes commas in the glob pattern of the given paths.
  private static String[] getPathStrings(String commaSeparatedPaths) {
    int length = commaSeparatedPaths.length();
    int curlyOpen = 0;
    int pathStart = 0;
    boolean globPattern = false;
    List<String> pathStrings = new ArrayList<String>();
    
    for (int i=0; i<length; i++) {
      char ch = commaSeparatedPaths.charAt(i);
      switch(ch) {
        case '{' : {
          curlyOpen++;
          if (!globPattern) {
            globPattern = true;
          }
          break;
        }
        case '}' : {
          curlyOpen--;
          if (curlyOpen == 0 && globPattern) {
            globPattern = false;
          }
          break;
        }
        case ',' : {
          if (!globPattern) {
            pathStrings.add(commaSeparatedPaths.substring(pathStart, i));
            pathStart = i + 1 ;
          }
          break;
        }
        default:
          continue; // nothing special to do for this character
      }
    }
    pathStrings.add(commaSeparatedPaths.substring(pathStart, length));
    
    return pathStrings.toArray(new String[0]);
  }
  
  /**
   * Get the list of input {@link Path}s for the map-reduce job.
   * 
   * @param context The job
   * @return the list of input {@link Path}s for the map-reduce job.
   */
  public static Path[] getInputPaths(JobContext context) {
    String dirs = context.getConfiguration().get(INPUT_DIR, "");
    String [] list = StringUtils.split(dirs);
    Path[] result = new Path[list.length];
    for (int i = 0; i < list.length; i++) {
      result[i] = new Path(StringUtils.unEscapeString(list[i]));
    }
    return result;
  }

}
