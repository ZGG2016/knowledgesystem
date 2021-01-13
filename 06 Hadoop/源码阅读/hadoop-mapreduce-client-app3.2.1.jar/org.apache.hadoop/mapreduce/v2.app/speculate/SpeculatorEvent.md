# SpeculatorEvent

```java
package org.apache.hadoop.mapreduce.v2.app.speculate;

import org.apache.hadoop.mapreduce.v2.app.job.event.TaskAttemptStatusUpdateEvent.TaskAttemptStatus;
import org.apache.hadoop.yarn.event.AbstractEvent;
import org.apache.hadoop.mapreduce.v2.api.records.JobId;
import org.apache.hadoop.mapreduce.v2.api.records.TaskAttemptId;
import org.apache.hadoop.mapreduce.v2.api.records.TaskId;

public class SpeculatorEvent extends AbstractEvent<Speculator.EventType> {

  // valid for ATTEMPT_STATUS_UPDATE
  private TaskAttemptStatus reportedStatus;

  // valid for TASK_CONTAINER_NEED_UPDATE
  private TaskId taskID;
  private int containersNeededChange;
  
  // valid for CREATE_JOB
  private JobId jobID;

  public SpeculatorEvent(JobId jobID, long timestamp) {
    super(Speculator.EventType.JOB_CREATE, timestamp);
    this.jobID = jobID;
  }

  public SpeculatorEvent(TaskAttemptStatus reportedStatus, long timestamp) {
    super(Speculator.EventType.ATTEMPT_STATUS_UPDATE, timestamp);
    this.reportedStatus = reportedStatus;
  }

  public SpeculatorEvent(TaskAttemptId attemptID, boolean flag, long timestamp) {
    super(Speculator.EventType.ATTEMPT_START, timestamp);
    this.reportedStatus = new TaskAttemptStatus();
    this.reportedStatus.id = attemptID;
    this.taskID = attemptID.getTaskId();
  }

  /*
   * This c'tor creates a TASK_CONTAINER_NEED_UPDATE event .
   * We send a +1 event when a task enters a state where it wants a container,
   *  and a -1 event when it either gets one or withdraws the request.
   * The per job sum of all these events is the number of containers requested
   *  but not granted.  The intent is that we only do speculations when the
   *  speculation wouldn't compete for containers with tasks which need
   *  to be run.
   */
  // 这个 c'tor 创建了一个 TASK_CONTAINER_NEED_UPDATE 事件。
  // 当任务进入它需要容器的状态时，我们发送a+1事件，
  // 当它获得一个容器或撤回请求时发送a-1事件。
  // 所有这些事件的每个作业总和是请求但未授予的容器数量。
  // 这样做的目的是，我们只在推测不会与需要运行的任务竞争容器时才进行。
  public SpeculatorEvent(TaskId taskID, int containersNeededChange) {
    super(Speculator.EventType.TASK_CONTAINER_NEED_UPDATE);
    this.taskID = taskID;
    this.containersNeededChange = containersNeededChange;
  }

  public TaskAttemptStatus getReportedStatus() {
    return reportedStatus;
  }

  public int containersNeededChange() {
    return containersNeededChange;
  }

  public TaskId getTaskID() {
    return taskID;
  }
  
  public JobId getJobID() {
    return jobID;
  }
}
```