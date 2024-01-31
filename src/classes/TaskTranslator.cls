public class TaskTranslator {

    public static List<TaskDomain.TaskInfo> TaskInfoMethod(List<TeamforcePro__Tasks__c> teamworkList,List<TeamforcePro__Teamwork_Sub_Task__c> teamsubTaskList) {
             
        List<TaskDomain.TaskInfo> taskInfo = new List<TaskDomain.TaskInfo>();
        for(TeamforcePro__Tasks__c tc : teamworkList) {
            
            TaskDomain.TaskInfo task = new TaskDomain.TaskInfo();
            
            task.Task_Name = tc.Name;
            task.ParentTask = '';
            if(tc.TeamforcePro__Task_List__r.Name != null){
                task.TaskList = tc.TeamforcePro__Task_List__r.Name;
            } else {
                task.TaskList = '';
            }
            if(tc.TeamforcePro__Due_Date__c != null) {
                task.DueDate =tc.TeamforcePro__Due_Date__c;
            } 
            task.Priority = tc.Priority_Formula__c;
            task.TeamworkLink = tc.TeamforcePro__Teamwork_TSK_URL__c;
            task.SalesforceLink = tc.Id;
            taskInfo.add(task);
        }
        
        for(TeamforcePro__Teamwork_Sub_Task__c tc : teamsubTaskList) {
            
            TaskDomain.TaskInfo task = new TaskDomain.TaskInfo();
            
            task.Task_Name = tc.Name;
            if(tc.TeamforcePro__Teamwork_Task__r.Name != null) {
                task.ParentTask = tc.TeamforcePro__Teamwork_Task__r.Name;
            } else {
                task.ParentTask = '';
            }
            
            if(tc.TeamforcePro__Task_List__r.Name != null){
                task.TaskList = tc.TeamforcePro__Task_List__r.Name;
            } else {
                task.TaskList = '';
            }
            if(tc.TeamforcePro__Due_Date__c != null) {
                task.DueDate = tc.TeamforcePro__Due_Date__c;
            } 
            task.Priority = tc.Priority_Formula__c;
            task.TeamworkLink = tc.TeamforcePro__Teamwork_SUBTSK_URL__c;
            task.SalesforceLink = tc.Id;
            taskInfo.add(task);
        }
        return taskInfo;
    }
}