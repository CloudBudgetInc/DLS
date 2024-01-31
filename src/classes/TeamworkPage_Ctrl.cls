// For teamowrk task & sub task related records qry & display in home page component table
global class TeamworkPage_Ctrl{
        
    @RemoteAction
    global static List<TaskDomain.TaskInfo> getTaskDetails() {
            
        List<TaskDomain.TaskInfo> taskInfo = TaskTranslator.TaskInfoMethod(TaskandSubTaskService.getTeamworkDetail(),TaskandSubTaskService.getTeamworkSubTaskDetail());
        system.debug('::::TaskList:::'+taskInfo);
        return taskInfo;
    }
    
}