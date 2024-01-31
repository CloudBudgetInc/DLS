/*******************************************************************************
- class for schedule Zoom User Creation for the newly created DLS Online Instructor
- Created by Dhinesh - 20-10-2021
- Scheduled on every hour
*******************************************************************************/
public class ZoomUserCreation_Scheduler implements Schedulable, Database.AllowsCallouts, Database.Batchable<ZoomDomain.zoomUserCreationWrap> {
  
    public void execute(SchedulableContext SC) {
        Database.executebatch(new ZoomUserCreation_Scheduler(), 1);
    }
   
    public Iterable<ZoomDomain.zoomUserCreationWrap> start(Database.Batchablecontext BC){
        List<ZoomDomain.zoomUserCreationWrap> zoomUserCreationWrapList = new List<ZoomDomain.zoomUserCreationWrap>();
        try{
            Set<Id> instructorsNeedsZoomUser = new Set<Id>();
            Id onlineRoomId = ZoomUtil.getOnlineRoomId();
            Map<Id, ZoomDomain.zoomUser> instructorIdWithZoomUserMap = new Map<Id, ZoomDomain.zoomUser>();
            
            for(Schedule__c sch : [SELECT Id, Instructor__c, Instructor__r.FirstName, Instructor__r.LastName, Instructor__r.Email, 
                                          Project__r.Number_of_Students_Active__c, (SELECT Id FROM Events__r WHERE Date__c = :System.Today()) 
                                   FROM Schedule__c
                                   WHERE (Room__c = :onlineRoomId OR Create_Zoom_Meetings__c = true) AND Status__c = 'Active' 
                                   AND Project_Task__r.Project_Task_Type__c != 'Preparation time' 
                                   AND Instructor__r.Active_DLS_Online_User__c = true 
                                   AND Instructor__r.Zoom_ID__c = null]){
                               
                instructorsNeedsZoomUser.add(sch.Instructor__c);
                instructorIdWithZoomUserMap.put(sch.Instructor__c, new ZoomDomain.zoomUser(sch.Instructor__r.FirstName, sch.Instructor__r.LastName, sch.Instructor__r.Email, (sch.Events__r.size() > 0) ? '2' : '1'));                       
            }
            
            if(instructorsNeedsZoomUser.size() > 0){
                for(Id instructorId : instructorsNeedsZoomUser){
                    ZoomDomain.zoomUser zoomUser = instructorIdWithZoomUserMap.get(instructorId);
                    
                    ZoomDomain.zoomUserCreationWrap zoomUserCreationWrap = new ZoomDomain.zoomUserCreationWrap();                    
                    zoomUserCreationWrap.instructorMailId = zoomUser.email;
                    zoomUserCreationWrap.instructorId = instructorId;
                    zoomUserCreationWrap.zoomUser = zoomUser;
                    zoomUserCreationWrapList.add(zoomUserCreationWrap);
                }
            }                
        }catch(Exception exe){
            String result = exe.getMessage();            
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('ZoomUserCreation_Scheduler','ZoomUserCreation_Scheduler','',result+' at line number '+exe.getLineNumber(),'','Scheduler')});
        }
        
        return zoomUserCreationWrapList;    
    }

    public void execute(Database.BatchableContext BC, List<ZoomDomain.zoomUserCreationWrap> zoomUserCreationWrapList){  
        
        for(ZoomDomain.zoomUserCreationWrap zoomUserCreationWrap : zoomUserCreationWrapList){
            
            ZoomUtil.getUserDetailsAndUpdateDetails(zoomUserCreationWrap.instructorMailId, JSON.serialize(zoomUserCreationWrap.zoomUser), zoomUserCreationWrap.instructorId, true, true);
        }
    }

    public void finish(Database.BatchableContext info){
        
    }

}