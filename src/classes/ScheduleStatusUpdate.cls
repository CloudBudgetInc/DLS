/********************
    - Created By HL on May 22 2020
    - Work Item : W-005441 - Schedule not Completing when Events are Completed
    - To update Schedule record status as Completed if all the related Event records status are completed
    - This scheduler runs daily basis
    **************/
    
global class ScheduleStatusUpdate implements Schedulable, Database.Batchable<Schedule__c> {

    global void execute(SchedulableContext SC) {
        Database.executebatch(new ScheduleStatusUpdate());
    }
    
     public Iterable<Schedule__c> start(Database.Batchablecontext BC){
         return [SELECT Id, (SELECT Id, Status__c FROM Events__r WHERE Status__c = 'Scheduled') FROM Schedule__c
                                WHERE End_Date__c < TODAY AND Status__c = 'Active'];
     }
    
     public void execute(Database.BatchableContext BC, List<Schedule__c> schedules){  
        //List<Schedule__c> schedules = (List<Schedule__c>)JSON.deserialize((JSON.serialize(scope)), List<Schedule__c>.class);
        Set<Id> scheduleIds = new Set<Id>();
        //Modified By Dhinesh - 8/3/2023 - Fix the System.QueryException: Aggregate query has too many rows for direct assignment, use FOR loop issue
        for(Schedule__c s : schedules){
            System.debug('schedule events::>'+s.Events__r);
            if(s.Events__r != NULL && s.Events__r.size() < 1){            
                scheduleIds.add(s.id);
            }  
        }
        System.debug('::::scheduleIds::::::'+scheduleIds);
        System.debug('::::scheduleIds::::::'+scheduleIds.size());
            
        if(scheduleIds.size() > 0){
            
            List<Schedule__c> updateScheduleRecs = new List<Schedule__c>();
            //Modified By Dhinesh - 8/3/2023 - optimize
            for(Id schId : scheduleIds){
                              
                updateScheduleRecs.add(new Schedule__c(Id=schId, Status__c = 'Completed'));
            }
            System.debug('::::updateScheduleRecs::::::'+updateScheduleRecs);
            
            if(updateScheduleRecs.size() > 0){
            
                update updateScheduleRecs;
            }
        }
    }       

    public void finish(Database.BatchableContext info){
        
    }
}