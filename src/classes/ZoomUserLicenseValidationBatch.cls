/*******************************************************************************
- class for Upgrade and Downgrade the Lisence based on Project no. of active students for Events with room as 'DLS - Online' with Is Moved Online Via Community field as true
- This will be called from ZoomUserLicenseValidation_Scheduler
- Created by Dhinesh - W-006013 - Zoom Integration
*******************************************************************************/
public class ZoomUserLicenseValidationBatch implements Database.Batchable<sObject>, Database.Stateful{
    public String Query;
    public Id onlineRoomId;
    public Set<Id> instructorsNeedProLicense;
    public Set<Id> instructorsNeedBasicLicense;
    
    public ZoomUserLicenseValidationBatch(){
        onlineRoomId = ZoomUtil.getOnlineRoomId();
        /*Commented By Dhinesh - 12/7/2022 - W-007513 - Zoom License Agreement changes
        Query = 'SELECT Id, Instructor__c, Instructor__r.Virtual_Conference_License__c, Instructor__r.Zoom_Id__c FROM Events__c  WHERE Room__c = \''+ onlineRoomId +'\' AND Status__c = \'Scheduled\' AND Is_Moved_Online_via_Community__c = true';
        Query += ' AND Instructor__r.Zoom_Id__c != null AND Instructor__r.Zoom_User_Status__c = \'Active\' AND Date__c = ';
        Query += String.valueOf(System.now().addDays(-1).date()).split(' ')[0];   */
        Query = 'SELECT Id FROM Contact WHERE RecordType.DeveloperName = \'Candidate\' AND Zoom_Id__c != null AND Zoom_User_Status__c = \'Active\'';
        instructorsNeedProLicense = new Set<Id>();
        instructorsNeedBasicLicense = new Set<Id>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
                     
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> contacts){
        Set<Id> instructorIds = (new Map<Id, Contact>(contacts)).keySet();
        
        /*Commented By Dhinesh - 12/7/2022 - W-007513 - Zoom License Agreement changes
        for(Events__c eve : events){
            instructorsNeedBasicLicense.add(eve.Instructor__c);
            instructorIds.add(eve.Instructor__c);
        }*/
        
        instructorsNeedBasicLicense.addAll(instructorIds);
        
        for(AggregateResult ar : [SELECT count(Id) onlineEventsCount, Instructor__c 
                                                  FROM Events__c WHERE (Room__c = :onlineRoomId OR Schedule__r.Create_Zoom_Meetings__c = true) AND Status__c = 'Scheduled' 
                                                  AND (Project_Task__r.Project_Task_Type__c != 'Preparation time' OR Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time') 
                                                  AND Instructor__c IN :instructorIds AND (Actual_Start_Date__c = TODAY OR Actual_End_Date__c = TODAY) GROUP BY Instructor__c]){  //Modified By Dhinesh - 7/7/23 - W-007828 - Changed Date__c = :System.today() and consider Start Date Time = Today
                                                  
            if( (Decimal) ar.get('onlineEventsCount') > 0){
                instructorsNeedBasicLicense.remove((Id) ar.get('Instructor__c'));
                instructorsNeedProLicense.add((Id) ar.get('Instructor__c'));    
            }                        
        }
        
        //Modified By Dhinesh - 15/7/2022 - W-007513 - Zoom License Agreement changes
        for(Schedule__c sch : [SELECT Id, Instructor__c, Project__r.Number_of_Students_Active__c FROM Schedule__c
                               WHERE Instructor__c IN :instructorIds AND (Room__c = :onlineRoomId OR Create_Zoom_Meetings__c = true) AND Status__c = 'Active' 
                               AND Project_Task__r.Project_Task_Type__c != 'Preparation time' AND Varied_Day__c = true AND Start_Date__c <= TODAY AND End_Date__c >= TODAY]){
            
          instructorsNeedBasicLicense.remove(sch.Instructor__c);
          instructorsNeedProLicense.add(sch.Instructor__c);                     
        }   
                
        //Modified By Dhinesh - 06/02/2022 - W-007708 - Enable Zoom License Update Process for Examiner Instructors in Testing Projects
        Map<Id, Set<Id>> projectIdWithContactIds = new Map<Id, Set<Id>>();
        for(Contact_Assignments__c conAssignment : [SELECT Id, Candidate_Name__c, Project__c FROM Contact_Assignments__c 
                                                                                      WHERE Candidate_Name__c IN :instructorIds AND Assignment_Position__c = 'Examiner' AND
                                                                                      Status__c = 'Active' AND Project__c != null AND
                                                                                      Project__r.RecordType.DeveloperName = 'Testing_Projects'                                                                                  
                                                                                     ]){
            if(!projectIdWithContactIds.containsKey(conAssignment.Project__c)){
                     projectIdWithContactIds.put(conAssignment.Project__c, new Set<Id>());                                                                        
            }                                                                            
            projectIdWithContactIds.get(conAssignment.Project__c).add(conAssignment.Candidate_Name__c);    
        } 
        
        if(projectIdWithContactIds.size() > 0){
            for(AggregateResult ar : [SELECT count(Id) eventsCount, Project__c 
                                                     FROM Events__c WHERE Status__c = 'Scheduled' 
                                                     AND (Project_Task__r.Project_Task_Type__c != 'Preparation time' OR Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time') 
                                                     AND Project__c IN :projectIdWithContactIds.keySet() AND  (Actual_Start_Date__c = TODAY OR Actual_End_Date__c = TODAY)  GROUP BY Project__c]){  //Modified By Dhinesh - 7/7/23 - W-007828 - Changed Date__c = :System.today() and consider Start Date Time = Today
                if( (Decimal) ar.get('eventsCount') > 0 && projectIdWithContactIds.get((Id) ar.get('Project__c')) != null ){
                    instructorsNeedBasicLicense.removeAll(projectIdWithContactIds.get((Id) ar.get('Project__c')));
                    instructorsNeedProLicense.addAll(projectIdWithContactIds.get((Id) ar.get('Project__c')));    
                }   
            }
        }
       
    }
    
    public void finish(Database.BatchableContext BC){
        //To downgrade the licenses for the Zoom User
        System_Values__c sysVal = System_Values__c.getValues('Zoom User License Update Batch size');
        ZoomUserLicenseUpdationBatch bat = new ZoomUserLicenseUpdationBatch(new List<Id>(instructorsNeedProLicense), new List<Id>(instructorsNeedBasicLicense), false);
        database.executeBatch(bat, Integer.valueOf(sysVal.Value__c));
    }
}