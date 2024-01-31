public class UnlinkZoomUserBatch_Scheduler implements Database.AllowsCallouts, Database.Batchable<SObject>, Schedulable{
    
    public static List<ErrorHandler.ErrorLogUtilDomain> errorLogs = new List<ErrorHandler.ErrorLogUtilDomain>();
    
    public void execute(SchedulableContext sc)
    {
        UnlinkZoomUserBatch_Scheduler b = new UnlinkZoomUserBatch_Scheduler();
        database.executebatch(b,50);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {        
        return Database.getQueryLocator(
            'SELECT Id, Email ' +
            'FROM Contact ' +
            'WHERE Unlink_Zoom_User__c = true AND Email != null'
        );
    }

    public void execute(Database.BatchableContext context, List<Contact> contacts) {
        List<String> emailIds = new List<String>();
               
        for(Contact con: contacts){
            try{
                ZoomUtil.unlinkUser(con.Email);
            }catch(Exception exe){
                
                String result = exe.getMessage();                
                errorLogs.add(new ErrorHandler.ErrorLogUtilDomain('UnlinkZoomUserBatch_Scheduler','unlinkInstructors','',result+' at line number '+exe.getLineNumber(),con.Email,'Trigger'));
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        if(errorLogs.size() > 0)
        	ErrorHandler.publishErrorLog(errorLogs);
    }
}