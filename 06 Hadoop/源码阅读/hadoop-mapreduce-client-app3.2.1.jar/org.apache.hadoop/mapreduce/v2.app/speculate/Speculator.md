# Speculator


```java
package org.apache.hadoop.mapreduce.v2.app.speculate;

import org.apache.hadoop.mapreduce.v2.app.job.event.TaskAttemptStatusUpdateEvent.TaskAttemptStatus;
import org.apache.hadoop.yarn.event.EventHandler;

/**
 * Speculator component.
 * Task Attempts 的状态更新被发送到这个组件。
 * 具体的实现类运行推测算法，并发送TaskEventType.T_ADD_ATTEMPT
 *
 * Speculator component. Task Attempts' status updates are sent to this
 * component. Concrete implementation runs the speculative algorithm and
 * sends the TaskEventType.T_ADD_ATTEMPT.
 *
 * 实现类还必须为不时地扫描job，以启动猜测。
 * An implementation also has to arrange for the jobs to be scanned from
 * time to time, to launch the speculations.
 */
public interface Speculator
              extends EventHandler<SpeculatorEvent> {

  enum EventType {
    ATTEMPT_STATUS_UPDATE,
    ATTEMPT_START,
    TASK_CONTAINER_NEED_UPDATE,
    JOB_CREATE
  }

  // This will be implemented if we go to a model where the events are
  //  processed within the TaskAttempts' state transitions' code.
  // 如果我们转到一个模型，这个模型在TaskAttempts的“状态转换”代码中处理事件，这将被实现。
  public void handleAttempt(TaskAttemptStatus status);
}

```