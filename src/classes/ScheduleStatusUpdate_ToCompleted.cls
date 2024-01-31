// This Batch to update the schedule status to completed when all the related events are not equal to scheudled
// Also email is send to Chris and April after updating schedule status as completed
// Developed by E. Keerthika on 7th, September 2018

global class ScheduleStatusUpdate_ToCompleted implements Database.Batchable<sobject>, Database.Stateful{
    
    global Map<String, Map<Id, String>> referenceFieldMap = new Map<String, Map<Id, String>>();
    global List<Schedule__c> scheduleList = new List<Schedule__c>();
    global Map<String, String> headerMap = new Map<String, String> {
                                               'Name' => 'Schedule Name',
                                               'Project__c' => 'Project',
                                               'Instructor__c' => 'Instrutor',
                                               'Start_Date__c' => 'Start Date',
                                               'Room__c' => 'Room'
                                           };
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date today = System.today();
        return Database.getQueryLocator('SELECT Id, Name, Status__c, Start_Date__c, Instructor__c, Instructor__r.Name, Project__c, Project__r.Name, Room__c, Room__r.Name FROM Schedule__c WHERE End_Date__c < :today AND Status__c = \'Active\'');
    }
     
    global void execute(Database.BatchableContext BC, List<Schedule__c> schList){
        
        if(schList != null && schList.size() > 0) {
            
            referenceFieldMap.put('Project__c', new Map<Id, String>());
            referenceFieldMap.put('Instructor__c', new Map<Id, String>());
            referenceFieldMap.put('Room__c', new Map<Id, String>());
            
            Set<Id> schIds = new Set<Id>();
            Map<Id, Integer> schIdEventCountMap = new Map<Id,  Integer>();
            List<Schedule__c> schUpdateList = new List<Schedule__c>();
            
            for(Schedule__c sch : schList) {
                schIds.add(sch.Id);
            }
            
            for(Events__c eve : [SELECT Id, Name, Status__c, Schedule__c FROM Events__c WHERE Schedule__c IN :schIds AND Status__c = 'Scheduled']) {
                if(!schIdEventCountMap.containsKey(eve.Schedule__c)) {
                    schIdEventCountMap.put(eve.Schedule__c, 0);
                }
                schIdEventCountMap.put(eve.Schedule__c, schIdEventCountMap.get(eve.Schedule__c)+1);
            }
            
            for(Schedule__c sch : schList) {
                
                if((schIdEventCountMap.containsKey(sch.Id) && schIdEventCountMap.get(sch.Id) == 0) || !schIdEventCountMap.containsKey(sch.Id)) {
                   
                    sch.Status__c = 'Completed';
                    
                    if(referenceFieldMap.containsKey('Project__c') && !referenceFieldMap.get('Project__c').containsKey(sch.Project__c)) {
                        referenceFieldMap.get('Project__c').put(sch.Project__c, sch.Project__r.Name);
                    }
                    
                    if(referenceFieldMap.containsKey('Instructor__c') && !referenceFieldMap.get('Instructor__c').containsKey(sch.Instructor__c)) {
                        referenceFieldMap.get('Instructor__c').put(sch.Instructor__c, sch.Instructor__r.Name);
                    }
                     
                    if(referenceFieldMap.containsKey('Room__c') && !referenceFieldMap.get('Room__c').containsKey(sch.Room__c)) {
                        referenceFieldMap.get('Room__c').put(sch.Room__c, sch.Room__r.Name);
                    }
                    schUpdateList.add(sch);
                }
            }
            
            try {
                if(schUpdateList != null && schUpdateList.size() > 0) {
                    update schUpdateList;
                    scheduleList = schUpdateList;
                }
                
            } catch(exception ex) {
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(ex.getMessage(),system.Label.TimeCardDayEmail,'Error on Updating Schedule Status as Completed');  
            }
        }
    }
     
    global void finish(Database.BatchableContext BC){
        
        Date dt = System.today().addDays(-1);
        String endDate = String.valueOf(dt.Month()) + '/' + String.valueOf(dt.Day()) + '/' + String.valueOf(dt.Year());
        
        String content = '<html>Hello Chris and April, <br/><br/>The following Schedule for which the end date is '+endDate+' is updated with the Status as Completed.<br/><br/>';
        
        if(scheduleList != null && scheduleList.size() > 0) {
            SendEmailsForUpdatedFields_Handler sendEmail = new SendEmailsForUpdatedFields_Handler();
            sendEmail.sendMailForComSchedule(headerMap, scheduleList, content, referenceFieldMap, 'Schedule status has been updated to Completed', 'cbellas@dlsdc.com, abellas@dlsdc.com');
        }
    }    
}