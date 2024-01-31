/*******************************************************************************
- class for Zoom meeting creation for Events with room as 'DLS - Online' 
- This will be called from ZoomMeetingCreation_Scheduler
- Created by Dhinesh - W-006013 - Zoom Integration
*******************************************************************************/
public class ZoomMeetingCreationBatch  implements Database.AllowsCallouts, Database.Batchable<sObject>, Database.Stateful{
    public String Query;
    public Id onlineRoomId;
    public List<Events__c> eventsForUpdate;
    public List<ErrorHandler.ErrorLogUtilDomain> errorlogs  = new List<ErrorHandler.ErrorLogUtilDomain>(); //Modified By Dhinesh - 7/7/23 - to fix the callout after DML issue when creating error log if any error occured on callouts
   
    public ZoomMeetingCreationBatch(){
        onlineRoomId = ZoomUtil.getOnlineRoomId();
        eventsForUpdate = new List<Events__c>();
        
        System_Values__c sysVal = System_Values__c.getValues('No. of days to create Zoom meeting');
        Query = 'SELECT Id, Duration__c, Timezone__c, Start_Date_Time__c, Instructor__r.Zoom_Id__c, Project__r.DLS_Ref__c FROM Events__c  WHERE (Room__c = \''+ onlineRoomId +'\' OR Schedule__r.Create_Zoom_Meetings__c = true) AND Status__c = \'Scheduled\' AND  Is_Meeting_Created__c = false AND Start_Time__c != null AND End_Time__c != null';
        Query += ' AND Instructor__r.Zoom_Id__c != null AND Instructor__r.Zoom_User_Status__c = \'Active\' AND Schedule__r.Project_Task__r.Project_Task_Type__c != \'Preparation time\' AND Date__c >= ';
        Query += System.now().formatGMT('yyyy-MM-dd')+' AND Date__c <= '+System.now().addDays(Integer.valueOf(sysVal.Value__c)).formatGMT('yyyy-MM-dd');
        
        if(Test.isRunningTest()){
            Query += ' LIMIT 1';      
        }                      
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
                     
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        
        for(SObject sco : scope){
            try{
                Events__c event = (Events__c)JSON.deserialize(JSON.serialize(sco), Events__c.Class);
                event = ZoomUtil.createMeetingForEvent(event);
                eventsForUpdate.add(event);                
            }catch(Exception exe){
               String result = exe.getMessage();            
               errorlogs.add(new ErrorHandler.ErrorLogUtilDomain('ZoomMeetingCreationBatch','createMeetingForEvent','',result+' at line number '+exe.getLineNumber(),JSON.serialize(sco),'Batch'));
            }        
        }        
    }
    
    public void finish(Database.BatchableContext BC){
        
        
        if(eventsForUpdate.size() > 0){
            try{
                update eventsForUpdate;
                if(errorlogs.size() > 0)//Modified By Dhinesh - 7/7/23 - to fix the callout after DML issue when creating error log if any error occured on callouts
                	ErrorHandler.publishErrorLog(errorlogs);
            }catch(Exception exe){
                String result = exe.getMessage();            
                ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('ZoomMeetingCreationBatch','ZoomMeetingCreationBatch','',result+' at line number '+exe.getLineNumber(),JSON.serialize(eventsForUpdate),'Batch')});
            }   
        }
    }
}