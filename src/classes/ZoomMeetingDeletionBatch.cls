/*******************************************************************************
- class for cancel/delete Zoom meeting when Events with room as 'DLS - Online' was deleted
- This will be called from populateStartAndEndDateTime - Event Trigger
- Created by Dhinesh - W-006013 - Zoom Integration
*******************************************************************************/
public class ZoomMeetingDeletionBatch  implements Database.AllowsCallouts, Database.Batchable<sObject>, Database.Stateful{    
    
    public List<Events__c> eventsToDeleteZoomMeeting;
    public Boolean isUpdate;
    public List<ErrorHandler.ErrorLogUtilDomain> errorlogs = new List<ErrorHandler.ErrorLogUtilDomain>(); //Modified By Dhinesh - 7/7/23 - to fix the callout after DML issue when creating error log if any error occured on callouts
    
    public ZoomMeetingDeletionBatch(String eventRecordsStr, Boolean isFromUpdate){
        eventsToDeleteZoomMeeting = (List<Events__c>)JSON.deserialize(eventRecordsStr, List<Events__c>.Class);
        isUpdate = isFromUpdate;
    }
    
    public List<Events__c> start(Database.BatchableContext BC){
                    
        return eventsToDeleteZoomMeeting;
    }
    
    public void execute(Database.BatchableContext BC, List<Events__c> scope){
        List<Events__c> eventsForUpdate = new List<Events__c>();
        
        for(Events__c sco : scope){
            try{
                String meetingId = sco.Meeting_Id__c;
                String resultStr = ZoomUtil.deleteZoomMeeting(meetingId);                           
            }catch(Exception exe){
                String result = exe.getMessage();            
               errorlogs.add(new ErrorHandler.ErrorLogUtilDomain('ZoomMeetingDeletionBatch','deleteZoomMeeting','',result+' at line number '+exe.getLineNumber(),JSON.serialize(sco),'Batch'));
            }                     
        }        
    }
    
    public void finish(Database.BatchableContext BC){
        /*if(isUpdate){
            List<Events__c> eventsForUpdate = new List<Events__c>();
            for(Events__c eve : eventsToDeleteZoomMeeting){
                eve.Meeting_URL__c = null;
                eve.Meeting_Id__c = null;
                eve.Is_Meeting_Created__c = false;
                eventsForUpdate.add(eve);
            }
            
            update eventsForUpdate;
        }*/
        //Modified By Dhinesh - 7/7/23 - to fix the callout after DML issue when creating error log if any error occured on callouts
        if(errorlogs.size() > 0){
            try{
                ErrorHandler.publishErrorLog(errorlogs);
            }catch(Exception exe){
                String result = exe.getMessage();
                ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('ZoomMeetingDeletionBatch','ZoomMeetingDeletionBatch','',result+' at line number '+exe.getLineNumber(),JSON.serialize(errorlogs),'Batch')});
            } 
        }
    }
}