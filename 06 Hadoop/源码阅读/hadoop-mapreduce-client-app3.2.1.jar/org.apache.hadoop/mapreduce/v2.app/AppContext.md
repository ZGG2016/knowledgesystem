# AppContext

```java
package org.apache.hadoop.mapreduce.v2.app;

import java.util.Map;
import java.util.Set;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.mapreduce.v2.api.records.JobId;
import org.apache.hadoop.mapreduce.v2.app.job.Job;
import org.apache.hadoop.yarn.api.records.ApplicationAttemptId;
import org.apache.hadoop.yarn.api.records.ApplicationId;
import org.apache.hadoop.yarn.event.Event;
import org.apache.hadoop.yarn.event.EventHandler;
import org.apache.hadoop.yarn.security.client.ClientToAMTokenSecretManager;
import org.apache.hadoop.yarn.util.Clock;


/**
 * 在 YARN 应用程序中，用于在组件间共享信息的上下文环境接口
 *
 * Context interface for sharing information across components in YARN App.
 */
@InterfaceAudience.Private
public interface AppContext {

  ApplicationId getApplicationID();

  ApplicationAttemptId getApplicationAttemptId();

  String getApplicationName();

  long getStartTime();

  CharSequence getUser();

  Job getJob(JobId jobID);

  Map<JobId, Job> getAllJobs();

  EventHandler<Event> getEventHandler();

  Clock getClock();
  
  ClusterInfo getClusterInfo();
  
  Set<String> getBlacklistedNodes();
  
  ClientToAMTokenSecretManager getClientToAMTokenSecretManager();

  boolean isLastAMRetry();

  boolean hasSuccessfullyUnregistered();

  String getNMHostname();

  TaskAttemptFinishingMonitor getTaskAttemptFinishingMonitor();

  String getHistoryUrl();

  void setHistoryUrl(String historyUrl);
}

```