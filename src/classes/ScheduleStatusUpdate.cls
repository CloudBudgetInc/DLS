/********************
    - Created By HL on May 22 2020
    - Work Item : W-005441 - Schedule not Completing when Events are Completed
    - To update Schedule record status as Completed if all the related Event records status are completed
    - This scheduler runs daily basis
    **************/
    
global class ScheduleStatusUpdate implements Schedulable, Database.Batchable<Schedule__c>{

    global void execute(SchedulableContext SC){
        Database.executebatch(new ScheduleStatusUpdate());
    }
    
    global Iterable<Schedule__c> start(Database.Batchablecontext BC){
        return [SELECT Id, Project__c, Instructor__c, End_Date__c, (SELECT Id, Status__c FROM Events__r WHERE Status__c = 'Scheduled') FROM Schedule__c WHERE End_Date__c < TODAY AND Status__c = 'Active' AND Id = 'a5WRT0000002xwr2AA'];
    }
     
    global void execute(Database.BatchableContext BC, List<Schedule__c> schedules){
                
        Set<Id> scheduleIds = new Set<Id>();
        Set<Id> projIds = new Set<Id>();
        Set<Id> insIds = new Set<Id>();
        Map<String, Date> projIdInsIdAndSchEndDate = new Map<String, Date>();
        
        //Modified By Dhinesh - 8/3/2023 - Fix the System.QueryException: Aggregate query has too many rows for direct assignment, use FOR loop issue
        for(Schedule__c s : schedules){
            
            if(s.Events__r != NULL && s.Events__r.size() < 1){   
                     
                scheduleIds.add(s.Id);
                projIds.add(s.Project__c); 
                insIds.add(s.Instructor__c); 
                String projIdInsId = s.Project__c+'-'+s.Instructor__c;
                if(!projIdInsIdAndSchEndDate.containsKey(projIdInsId)){
                    projIdInsIdAndSchEndDate.put(projIdInsId, s.End_Date__c);
                }
            } 
        }
        
        if(scheduleIds.size() > 0){
            
            List<Schedule__c> updateScheduleRecs = new List<Schedule__c>();
            Map<String, Set<Id>> projIdInsIdAndScheIds = new Map<String, Set<Id>>();
            List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
            
            //Modified By Dhinesh - 8/3/2023 - optimize
            for(Id schId : scheduleIds){
                updateScheduleRecs.add(new Schedule__c(Id=schId, Status__c = 'Completed'));
            }
            
            for(Schedule__c s : [SELECT Id, Project__c, Instructor__c FROM Schedule__c WHERE Id NOT IN : scheduleIds AND Project__c IN : projIds AND Instructor__c IN : insIds AND Status__c NOT IN ('Canceled', 'Completed') AND End_Date__c >= TODAY AND Project_Task__r.Project_Task_Type__c != 'Preparation time']){
                
                String projIdInsId = s.Project__c+'-'+s.Instructor__c;
                if(!projIdInsIdAndScheIds.containsKey(projIdInsId)){
                    projIdInsIdAndScheIds.put(projIdInsId, new Set<Id>());
                }
                projIdInsIdAndScheIds.get(projIdInsId).add(s.Id);
            }
            
            // W-008035 : Request to Automatically Update Instructor CA from Active to Ended when End Date has Passed
            // When the end date of a schedule has passed and there are no other active or draft schedules assigned to its instructor, then the status of the contact assignment should be automatically updated to "Ended."
            for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Project__c, End_Date__c FROM Contact_Assignments__c WHERE Project__c IN : projIds AND Candidate_Name__c IN : insIds AND Status__c NOT IN ('Canceled', 'Ended') AND RecordType.DeveloperName = 'Instructor']){
                
                String projIdInsId = ca.Project__c+'-'+ca.Candidate_Name__c;
                if(!projIdInsIdAndScheIds.containsKey(projIdInsId)){
                    
                    ca.Status__c = 'Ended';    
                    ca.End_Date__c = projIdInsIdAndSchEndDate.containsKey(projIdInsId) ? projIdInsIdAndSchEndDate.get(projIdInsId) : ca.End_Date__c;
                    updateCAs.add(ca);
                }
            }
                        
            if(updateScheduleRecs.size() > 0){
                update updateScheduleRecs;
            }
            
            if(updateCAs.size() > 0){
                update updateCAs;
            }
        }
    }
    
    global void finish(Database.BatchableContext info){
        
    }
}