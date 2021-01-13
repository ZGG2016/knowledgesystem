# TaskRuntimeEstimator

```java
package org.apache.hadoop.mapreduce.v2.app.speculate;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.mapreduce.v2.api.records.TaskAttemptId;
import org.apache.hadoop.mapreduce.v2.api.records.TaskId;
import org.apache.hadoop.mapreduce.v2.app.AppContext;
import org.apache.hadoop.mapreduce.v2.app.job.event.TaskAttemptStatusUpdateEvent.TaskAttemptStatus;



public interface TaskRuntimeEstimator {
  public void enrollAttempt(TaskAttemptStatus reportedStatus, long timestamp);

  public long attemptEnrolledTime(TaskAttemptId attemptID);

  public void updateAttempt(TaskAttemptStatus reportedStatus, long timestamp);

  public void contextualize(Configuration conf, AppContext context);

  /**
   *
   * Find a maximum reasonable execution wallclock time.  Includes the time
   * already elapsed.
   *
   * 找到一个最大的合理执行时间，包括已经过去的时间。
   * 如果这个任务的预计总执行时间超过了它的合理执行时间，我们可以推测它。
   *
   * Find a maximum reasonable execution time.  Includes the time
   * already elapsed.  If the projected total execution time for this task
   * ever exceeds its reasonable execution time, we may speculate it.
   *
   * @param id the {@link TaskId} of the task we are asking about 请求的任务id
   * @return the task's maximum reasonable runtime, or MAX_VALUE if
   *         we don't have enough information to rule out any runtime,
   *         however long.
   *  返回任务的最大的合理运行时间，
   *  如果没有足够的信息排除任何运行时间(无论多长)，则为MAX_VALUE。
   *
   */
  public long thresholdRuntime(TaskId id);

  /**
   * 估计一个任务尝试的总运行时间，包括已经过去的时间。
   * Estimate a task attempt's total runtime.  Includes the time already
   * elapsed.
   *
   * @param id the {@link TaskAttemptId} of the attempt we are asking about
   * @return our best estimate of the attempt's runtime, or {@code -1} if
   *         we don't have enough information yet to produce an estimate.
   *  返回对尝试运行时间的最佳估计，如果我们没有足够的信息来产生一个估计，则返回-1。
   */
  public long estimatedRuntime(TaskAttemptId id);

  /**
   * 如果我们现在开始一个任务，估计对这个任务的新尝试将花费多长时间
   * Estimates how long a new attempt on this task will take if we start
   *  one now
   *
   * @param id the {@link TaskId} of the task we are asking about
   * @return our best estimate of a new attempt's runtime, or {@code -1} if
   *         we don't have enough information yet to produce an estimate.
   *  返回对一个新的尝试的运行时间的最佳估计，如果我们没有足够的信息来产生一个估计，则返回-1。
   */
  public long estimatedNewAttemptRuntime(TaskId id);

  /**
   * 计算由estimatedRuntime(TaskAttemptId)返回的任务运行时间的估计的错误频带宽度
   * Computes the width of the error band of our estimate of the task
   *  runtime as returned by {@link #estimatedRuntime(TaskAttemptId)}
   *
   * @param id the {@link TaskAttemptId} of the attempt we are asking about
   * @return our best estimate of the attempt's runtime, or {@code -1} if
   *         we don't have enough information yet to produce an estimate.
   *
   */
  public long runtimeEstimateVariance(TaskAttemptId id);
}

```