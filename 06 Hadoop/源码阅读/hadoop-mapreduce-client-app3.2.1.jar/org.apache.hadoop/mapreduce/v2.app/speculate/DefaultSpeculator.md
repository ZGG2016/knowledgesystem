# DefaultSpeculator

```java
package org.apache.hadoop.mapreduce.v2.app.speculate;

....

public class DefaultSpeculator extends AbstractService implements
    Speculator {

  //long MIN_VALUE = 0x8000000000000000L;
  private static final long ON_SCHEDULE = Long.MIN_VALUE;
  private static final long ALREADY_SPECULATING = Long.MIN_VALUE + 1;
  private static final long TOO_NEW = Long.MIN_VALUE + 2;
  private static final long PROGRESS_IS_GOOD = Long.MIN_VALUE + 3;
  private static final long NOT_RUNNING = Long.MIN_VALUE + 4;
  private static final long TOO_LATE_TO_SPECULATE = Long.MIN_VALUE + 5;

  private long soonestRetryAfterNoSpeculate;
  private long soonestRetryAfterSpeculate;
  private double proportionRunningTasksSpeculatable;
  private double proportionTotalTasksSpeculatable;
  private int  minimumAllowedSpeculativeTasks;

  private static final Logger LOG =
      LoggerFactory.getLogger(DefaultSpeculator.class);

   //  任务、是不是正在运行
  private final ConcurrentMap<TaskId, Boolean> runningTasks
      = new ConcurrentHashMap<TaskId, Boolean>();

  // Used to track any TaskAttempts that aren't heart-beating for a while, so
  // that we can aggressively speculate instead of waiting for task-timeout.

  // 用于跟踪任何暂时没有心跳的TaskAttempts，
  // 这样我们就可以积极地推测，而不是等待任务超时
  private final ConcurrentMap<TaskAttemptId, TaskAttemptHistoryStatistics>
      runningTaskAttemptStatistics = new ConcurrentHashMap<TaskAttemptId,
          TaskAttemptHistoryStatistics>();

  // Regular heartbeat from tasks is every 3 secs. So if we don't get a
  // heartbeat in 9 secs (3 heartbeats), we simulate a heartbeat with no change
  // in progress.
  // 任务的正常心跳周期是3秒，如果在9秒内没有收到一个心跳(三个心跳)，
  // 那么我们在没有任何变化的情况下模拟心跳。
  private static final long MAX_WAITTING_TIME_FOR_HEARTBEAT = 9 * 1000;

  // These are the current needs, not the initial needs.  For each job, these
  //  record the number of attempts that exist and that are actively
  //  waiting for a container [as opposed to running or finished]
  // 这些是当前需要，不是初始需要。
  // 对每个job，这些记录了已经存在的以及正在积极等待容器的尝试次数(而不是正在运行或已完成)。
  private final ConcurrentMap<JobId, AtomicInteger> mapContainerNeeds
      = new ConcurrentHashMap<JobId, AtomicInteger>();
  private final ConcurrentMap<JobId, AtomicInteger> reduceContainerNeeds
      = new ConcurrentHashMap<JobId, AtomicInteger>();

  private final Set<TaskId> mayHaveSpeculated = new HashSet<TaskId>();

  private final Configuration conf;

  //在 YARN 应用程序中，用于在组件间共享信息的上下文环境接口
  private AppContext context;
  private Thread speculationBackgroundThread = null;
  private volatile boolean stopped = false;
  private TaskRuntimeEstimator estimator;  

  private BlockingQueue<Object> scanControl = new LinkedBlockingQueue<Object>();

  private final Clock clock;  // A simple clock interface that gives you time.

  private final EventHandler<Event> eventHandler;

  public DefaultSpeculator(Configuration conf, AppContext context) {
    this(conf, context, context.getClock());
  }

  public DefaultSpeculator(Configuration conf, AppContext context, Clock clock) {
    this(conf, context, getEstimator(conf, context), clock);
  }
  
  static private TaskRuntimeEstimator getEstimator
      (Configuration conf, AppContext context) {
    TaskRuntimeEstimator estimator;
    
    try {
      // "yarn.mapreduce.job.task.runtime.estimator.class"
      Class<? extends TaskRuntimeEstimator> estimatorClass
          = conf.getClass(MRJobConfig.MR_AM_TASK_ESTIMATOR,
                          LegacyTaskRuntimeEstimator.class,
                          TaskRuntimeEstimator.class);

      Constructor<? extends TaskRuntimeEstimator> estimatorConstructor
          = estimatorClass.getConstructor();

      // 通过反射创建一个对象
      estimator = estimatorConstructor.newInstance();

      estimator.contextualize(conf, context);
    } catch (InstantiationException ex) {
      LOG.error("Can't make a speculation runtime estimator", ex);
      throw new YarnRuntimeException(ex);
    } catch (IllegalAccessException ex) {
      LOG.error("Can't make a speculation runtime estimator", ex);
      throw new YarnRuntimeException(ex);
    } catch (InvocationTargetException ex) {
      LOG.error("Can't make a speculation runtime estimator", ex);
      throw new YarnRuntimeException(ex);
    } catch (NoSuchMethodException ex) {
      LOG.error("Can't make a speculation runtime estimator", ex);
      throw new YarnRuntimeException(ex);
    }
    
  return estimator;
  }

  // This constructor is designed to be called by other constructors.
  //  However, it's public because we do use it in the test cases.
  // Normally we figure out our own estimator.
  // 这个构造器是要由其他构造器调用
  public DefaultSpeculator
      (Configuration conf, AppContext context,
       TaskRuntimeEstimator estimator, Clock clock) {
    super(DefaultSpeculator.class.getName());

    this.conf = conf;
    this.context = context;
    this.estimator = estimator;
    this.clock = clock;
    this.eventHandler = context.getEventHandler();
    // 如果这轮没有推测任务，进行下一轮推测任务的等待时间(ms)。
    this.soonestRetryAfterNoSpeculate =
        conf.getLong(MRJobConfig.SPECULATIVE_RETRY_AFTER_NO_SPECULATE,
                MRJobConfig.DEFAULT_SPECULATIVE_RETRY_AFTER_NO_SPECULATE);
    // 如果这轮有推测任务，进行下一轮推测任务的等待时间(ms)。
    this.soonestRetryAfterSpeculate =
        conf.getLong(MRJobConfig.SPECULATIVE_RETRY_AFTER_SPECULATE,
                MRJobConfig.DEFAULT_SPECULATIVE_RETRY_AFTER_SPECULATE);
    // 可以在任何时间推测地重新执行的正在运行任务的最大百分比(0-1)。
    this.proportionRunningTasksSpeculatable =
        conf.getDouble(MRJobConfig.SPECULATIVECAP_RUNNING_TASKS,
                MRJobConfig.DEFAULT_SPECULATIVECAP_RUNNING_TASKS);
    // 可以在任何时间推测地重新执行的所有任务的最大百分比(0-1)。
    this.proportionTotalTasksSpeculatable =
        conf.getDouble(MRJobConfig.SPECULATIVECAP_TOTAL_TASKS,
                MRJobConfig.DEFAULT_SPECULATIVECAP_TOTAL_TASKS);
    // 允许在任何时间推测地重新执行的最小任务数。
    this.minimumAllowedSpeculativeTasks =
        conf.getInt(MRJobConfig.SPECULATIVE_MINIMUM_ALLOWED_TASKS,
                MRJobConfig.DEFAULT_SPECULATIVE_MINIMUM_ALLOWED_TASKS);
  }

/*   *************************************************************    */

  // This is the task-mongering that creates the two new threads -- one for
  //  processing events from the event queue and one for periodically
  //  looking for speculation opportunities
  // 两个线程，
  // 一个用于处理来自事件队列的处理事件，一个用来周期地寻找推测机会
  @Override
  protected void serviceStart() throws Exception {
    Runnable speculationBackgroundCore
        = new Runnable() {
            @Override
            public void run() {
              while (!stopped && !Thread.currentThread().isInterrupted()) {
                long backgroundRunStartTime = clock.getTime();
                try {
                  int speculations = computeSpeculations();
                  // 如果推测任务执行成功或失败，下轮执行推测任务的等待时间
                  long mininumRecomp
                      = speculations > 0 ? soonestRetryAfterSpeculate    // 成功
                                         : soonestRetryAfterNoSpeculate; // 失败

                  // 如果当前等待的时间超过了 `理论等待时间`   
                  // 那么从开始到当前的时间就是等待的时间            
                  long wait = Math.max(mininumRecomp,
                        clock.getTime() - backgroundRunStartTime);

                  if (speculations > 0) {
                    LOG.info("We launched " + speculations
                        + " speculations.  Sleeping " + wait + " milliseconds.");
                  }

                  // 等到 wait 时间，检索并移除队列头部元素
                  Object pollResult
                      = scanControl.poll(wait, TimeUnit.MILLISECONDS);
                } catch (InterruptedException e) {
                  if (!stopped) {
                    LOG.error("Background thread returning, interrupted", e);
                  }
                  return;
                }
              }
            }
          };
    speculationBackgroundThread = new Thread
        (speculationBackgroundCore, "DefaultSpeculator background processing");
    speculationBackgroundThread.start();

    super.serviceStart();
  }

  @Override
  protected void serviceStop()throws Exception {
      stopped = true;
    // this could be called before background thread is established
    if (speculationBackgroundThread != null) {
      speculationBackgroundThread.interrupt();
    }
    super.serviceStop();
  }

  @Override
  public void handleAttempt(TaskAttemptStatus status) {
    long timestamp = clock.getTime();
    statusUpdate(status, timestamp);  // 更新状态
  }

  // This section is not part of the Speculator interface; it's used only for
  //  testing
  public boolean eventQueueEmpty() {
    return scanControl.isEmpty();
  }

  // This interface is intended to be used only for test cases.
  public void scanForSpeculations() {
    LOG.info("We got asked to run a debug speculation scan.");
    // debug
    System.out.println("We got asked to run a debug speculation scan.");
    System.out.println("There are " + scanControl.size()
        + " events stacked already.");
    scanControl.add(new Object());
    Thread.yield();
  }


/*   *************************************************************    */

  // This section contains the code that gets run for a SpeculatorEvent
  // 运行一个SpeculatorEvent的代码

 
  private AtomicInteger containerNeed(TaskId taskID) {

    // 返回相关的 JobId
    JobId jobID = taskID.getJobId();

    // 获取任务类型，是map还是reduce
    TaskType taskType = taskID.getTaskType();

// mapContainerNeeds、reduceContainerNeeds
// 对每个job，这些记录了已经存在的以及正在积极等待容器的尝试的次数(而不是正在运行或已完成)。
    
    ConcurrentMap<JobId, AtomicInteger> relevantMap
        = taskType == TaskType.MAP ? mapContainerNeeds : reduceContainerNeeds;

    // 获取这个job的已经存在的以及正在积极等待容器的尝试的次数
    AtomicInteger result = relevantMap.get(jobID);

    if (result == null) {
      relevantMap.putIfAbsent(jobID, new AtomicInteger(0));
      result = relevantMap.get(jobID);
    }

    return result;
  }

  private synchronized void processSpeculatorEvent(SpeculatorEvent event) {
    // 判断事件类型
    switch (event.getType()) {
      case ATTEMPT_STATUS_UPDATE:
        statusUpdate(event.getReportedStatus(), event.getTimestamp());
        break;

      case TASK_CONTAINER_NEED_UPDATE:
      {
        AtomicInteger need = containerNeed(event.getTaskID());
        // addAndGet：将一个值加到当前值，并返回更新后的值
        need.addAndGet(event.containersNeededChange());
        break;
      }

      case ATTEMPT_START:
      {
        LOG.info("ATTEMPT_START " + event.getTaskID());
        estimator.enrollAttempt
            (event.getReportedStatus(), event.getTimestamp());
        break;
      }
      
      case JOB_CREATE:
      {
        LOG.info("JOB_CREATE " + event.getJobID());
        estimator.contextualize(getConfig(), context);
        break;
      }
    }
  }

  /**
   * Absorbs one TaskAttemptStatus 
   *       
   *    我们从一个任务尝试中得到的状态报告，我们想把它调入这个任务的推测数据
   * @param reportedStatus the status report that we got from a task attempt
   *        that we want to fold into the speculation data for this job
   * @param timestamp the time this status corresponds to.  This matters
   *        because statuses contain progress. 这个状态对应的时间
   */
  protected void statusUpdate(TaskAttemptStatus reportedStatus, long timestamp) {

    // 将任务尝试状态转成字符串形式
    String stateString = reportedStatus.taskState.toString();

    
    TaskAttemptId attemptID = reportedStatus.id;
    // 由 任务尝试id 取出 任务id，
    TaskId taskID = attemptID.getTaskId();
    // 再由 任务id 取出其所属的job对象
    Job job = context.getJob(taskID.getJobId());

    if (job == null) {
      return;
    }

    // 由 任务id 获取对应的 task对象
    Task task = job.getTask(taskID);

    if (task == null) {
      return;
    }

    estimator.updateAttempt(reportedStatus, timestamp);

    // 如果任务尝试的状态是运行中，则将这个任务放到runningTasks这个map中
    if (stateString.equals(TaskAttemptState.RUNNING.name())) {
      runningTasks.putIfAbsent(taskID, Boolean.TRUE);
    } else {
      runningTasks.remove(taskID, Boolean.TRUE); // 不在运行中，将其从runningTasks移除
      // 如果也不是在启动状态，就将这个任务尝试id从runningTaskAttemptStatistics中移除
      if (!stateString.equals(TaskAttemptState.STARTING.name())) {
        runningTaskAttemptStatistics.remove(attemptID);
      }
    }
  }

/*   *************************************************************    */

// This is the code section that runs periodically and adds speculations for
//  those jobs that need them.
// 这是定期运行，并为需要它们的作业添加推测的代码部分。


// 这可以为不应该进行推测的任务返回一些神奇的值:
//   如果thresholdRuntime(taskID)表示不应该考虑推测这个任务，则返回ON_SCHEDULE
//   如果为真，则返回ALREADY_SPECULATING。这优先。
//   如果我们的同伴任务没有得到任何信息，返回TOO_NEW
//   如果任务顺利通过，则返回PROGRESS_IS_GOOD
//   如果任务没有运行，则返回NOT_RUNNING

  // This can return a few magic values for tasks that shouldn't speculate:
  //  returns ON_SCHEDULE if thresholdRuntime(taskID) says that we should not
  //     considering speculating this task
  //  returns ALREADY_SPECULATING if that is true.  This has priority.
  //  returns TOO_NEW if our companion task hasn't gotten any information
  //  returns PROGRESS_IS_GOOD if the task is sailing through
  //  returns NOT_RUNNING if the task is not running
  //
  // All of these values are negative.  Any value that should be allowed to
  //  speculate is 0 or positive.
  // 所有这些值都是负的。
  // 允许推测的任何值都是0或正值。
  private long speculationValue(TaskId taskID, long now) {
    Job job = context.getJob(taskID.getJobId());
    Task task = job.getTask(taskID);
    Map<TaskAttemptId, TaskAttempt> attempts = task.getAttempts();
    long acceptableRuntime = Long.MIN_VALUE;
    long result = Long.MIN_VALUE;

    if (!mayHaveSpeculated.contains(taskID)) {
      acceptableRuntime = estimator.thresholdRuntime(taskID);
      if (acceptableRuntime == Long.MAX_VALUE) {
        return ON_SCHEDULE;
      }
    }

    TaskAttemptId runningTaskAttemptID = null;

    int numberRunningAttempts = 0;

    for (TaskAttempt taskAttempt : attempts.values()) {
      if (taskAttempt.getState() == TaskAttemptState.RUNNING
          || taskAttempt.getState() == TaskAttemptState.STARTING) {
        if (++numberRunningAttempts > 1) {
          return ALREADY_SPECULATING;
        }
        runningTaskAttemptID = taskAttempt.getID();

        long estimatedRunTime = estimator.estimatedRuntime(runningTaskAttemptID);

        long taskAttemptStartTime
            = estimator.attemptEnrolledTime(runningTaskAttemptID);
        if (taskAttemptStartTime > now) {
          // This background process ran before we could process the task
          //  attempt status change that chronicles the attempt start
          return TOO_NEW;
        }

        long estimatedEndTime = estimatedRunTime + taskAttemptStartTime;

        long estimatedReplacementEndTime
            = now + estimator.estimatedNewAttemptRuntime(taskID);

        float progress = taskAttempt.getProgress();
        TaskAttemptHistoryStatistics data =
            runningTaskAttemptStatistics.get(runningTaskAttemptID);
        if (data == null) {
          runningTaskAttemptStatistics.put(runningTaskAttemptID,
            new TaskAttemptHistoryStatistics(estimatedRunTime, progress, now));
        } else {
          if (estimatedRunTime == data.getEstimatedRunTime()
              && progress == data.getProgress()) {
            // Previous stats are same as same stats
            if (data.notHeartbeatedInAWhile(now)) {
              // Stats have stagnated for a while, simulate heart-beat.
              TaskAttemptStatus taskAttemptStatus = new TaskAttemptStatus();
              taskAttemptStatus.id = runningTaskAttemptID;
              taskAttemptStatus.progress = progress;
              taskAttemptStatus.taskState = taskAttempt.getState();
              // Now simulate the heart-beat
              handleAttempt(taskAttemptStatus);
            }
          } else {
            // Stats have changed - update our data structure
            data.setEstimatedRunTime(estimatedRunTime);
            data.setProgress(progress);
            data.resetHeartBeatTime(now);
          }
        }

        if (estimatedEndTime < now) {
          return PROGRESS_IS_GOOD;
        }

        if (estimatedReplacementEndTime >= estimatedEndTime) {
          return TOO_LATE_TO_SPECULATE;
        }

        result = estimatedEndTime - estimatedReplacementEndTime;
      }
    }

    // If we are here, there's at most one task attempt.
    if (numberRunningAttempts == 0) {
      return NOT_RUNNING;
    }



    if (acceptableRuntime == Long.MIN_VALUE) {
      acceptableRuntime = estimator.thresholdRuntime(taskID);
      if (acceptableRuntime == Long.MAX_VALUE) {
        return ON_SCHEDULE;
      }
    }

    return result;
  }

  //Add attempt to a given Task.
  protected void addSpeculativeAttempt(TaskId taskID) {
    LOG.info
        ("DefaultSpeculator.addSpeculativeAttempt -- we are speculating " + taskID);
    eventHandler.handle(new TaskEvent(taskID, TaskEventType.T_ADD_SPEC_ATTEMPT));
    mayHaveSpeculated.add(taskID);
  }

  @Override
  public void handle(SpeculatorEvent event) {
    processSpeculatorEvent(event);
  }


// public enum TaskType {
//     MAP, REDUCE
// }

  private int maybeScheduleAMapSpeculation() {
    return maybeScheduleASpeculation(TaskType.MAP);
  }

  private int maybeScheduleAReduceSpeculation() {
    return maybeScheduleASpeculation(TaskType.REDUCE);
  }

  private int maybeScheduleASpeculation(TaskType type) {
    int successes = 0;

    long now = clock.getTime();

    // 判断调度是map任务还是reduce任务
    ConcurrentMap<JobId, AtomicInteger> containerNeeds
        = type == TaskType.MAP ? mapContainerNeeds : reduceContainerNeeds;

    for (ConcurrentMap.Entry<JobId, AtomicInteger> jobEntry : containerNeeds.entrySet()) {
      // This race conditon is okay.  If we skip a speculation attempt we
      //  should have tried because the event that lowers the number of
      //  containers needed to zero hasn't come through, it will next time.
      // Also, if we miss the fact that the number of containers needed was
      //  zero but increased due to a failure it's not too bad to launch one
      //  container prematurely.
      // 这个竞争条件是可以的。
      // 如果我们跳过一个本应该尝试的推测尝试，因为需要的容器数量降低到零的事件还没有通过，那么下次就会通过。
      // 另外，如果我们忽略了这样一个事实，即需要的容器数量为零，但由于故障而增加了，那么过早地启动一个容器也不是太糟糕。
      if (jobEntry.getValue().get() > 0) {
        continue;
      }

      int numberSpeculationsAlready = 0;
      int numberRunningTasks = 0;

      // loop through the tasks of the kind
      Job job = context.getJob(jobEntry.getKey());

      Map<TaskId, Task> tasks = job.getTasks(type);

      int numberAllowedSpeculativeTasks
          = (int) Math.max(minimumAllowedSpeculativeTasks,
              proportionTotalTasksSpeculatable * tasks.size());

      TaskId bestTaskID = null;
      long bestSpeculationValue = -1L;

      // this loop is potentially pricey.
      // TODO track the tasks that are potentially worth looking at
      for (Map.Entry<TaskId, Task> taskEntry : tasks.entrySet()) {
        long mySpeculationValue = speculationValue(taskEntry.getKey(), now);

        if (mySpeculationValue == ALREADY_SPECULATING) {
          ++numberSpeculationsAlready;
        }

        if (mySpeculationValue != NOT_RUNNING) {
          ++numberRunningTasks;
        }

        if (mySpeculationValue > bestSpeculationValue) {
          bestTaskID = taskEntry.getKey();
          bestSpeculationValue = mySpeculationValue;
        }
      }
      numberAllowedSpeculativeTasks
          = (int) Math.max(numberAllowedSpeculativeTasks,
              proportionRunningTasksSpeculatable * numberRunningTasks);

      // If we found a speculation target, fire it off
      if (bestTaskID != null
          && numberAllowedSpeculativeTasks > numberSpeculationsAlready) {
        addSpeculativeAttempt(bestTaskID);
        ++successes;
      }
    }

    return successes;
  }

  private int computeSpeculations() {
    // We'll try to issue one map and one reduce speculation per job per run
    // 一个map、一个reduce
    return maybeScheduleAMapSpeculation() + maybeScheduleAReduceSpeculation();
  }

  static class TaskAttemptHistoryStatistics {

    private long estimatedRunTime;
    private float progress;
    private long lastHeartBeatTime;

    public TaskAttemptHistoryStatistics(long estimatedRunTime, float progress,
        long nonProgressStartTime) {
      this.estimatedRunTime = estimatedRunTime;
      this.progress = progress;
      resetHeartBeatTime(nonProgressStartTime);
    }

    public long getEstimatedRunTime() {
      return this.estimatedRunTime;
    }

    public float getProgress() {
      return this.progress;
    }

    public void setEstimatedRunTime(long estimatedRunTime) {
      this.estimatedRunTime = estimatedRunTime;
    }

    public void setProgress(float progress) {
      this.progress = progress;
    }

    public boolean notHeartbeatedInAWhile(long now) {
      if (now - lastHeartBeatTime <= MAX_WAITTING_TIME_FOR_HEARTBEAT) {
        return false;
      } else {
        resetHeartBeatTime(now);
        return true;
      }
    }

    public void resetHeartBeatTime(long lastHeartBeatTime) {
      this.lastHeartBeatTime = lastHeartBeatTime;
    }
  }

  @VisibleForTesting
  public long getSoonestRetryAfterNoSpeculate() {
    return soonestRetryAfterNoSpeculate;
  }

  @VisibleForTesting
  public long getSoonestRetryAfterSpeculate() {
    return soonestRetryAfterSpeculate;
  }

  @VisibleForTesting
  public double getProportionRunningTasksSpeculatable() {
    return proportionRunningTasksSpeculatable;
  }

  @VisibleForTesting
  public double getProportionTotalTasksSpeculatable() {
    return proportionTotalTasksSpeculatable;
  }

  @VisibleForTesting
  public int getMinimumAllowedSpeculativeTasks() {
    return minimumAllowedSpeculativeTasks;
  }
}

```