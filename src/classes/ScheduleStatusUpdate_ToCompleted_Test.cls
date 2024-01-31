@isTest
private class ScheduleStatusUpdate_ToCompleted_Test {
    
    @testSetup static void setup() {
        List<Events__c> eveList = TestClassUtil.createTestEvent();
    }
    
    // For sending the mail to Chris and April when the schedule is completed
    private static testMethod void testMethod1() {
        
        List<Events__c> eveList = [SELECT Id, Name, Schedule__c FROM Events__c WHERE Schedule__c != null AND Status__c = 'Scheduled'];
        Set<Id> schIds = new Set<Id>();
        
        if(eveList.size() > 0) {
            
            for(Events__c eve : eveList) {
                schIds.add(eve.Schedule__c);
            }
            eveList[0].Status__c = 'Substituted';
            update eveList;
            
            List<Schedule__c> schList = [SELECT Id, Name, Status__c, End_Date__c FROM Schedule__c WHERE Id IN :schIds LIMIT 2];
            
            if(schList.size() > 0) {
                for(Schedule__c sch : schList) {
                    sch.Status__c = 'Active';
                    sch.End_Date__c = System.today().addDays(-1);
                }
                update schList;
                
                Database.BatchableContext BC;   
    
                ScheduleStatusUpdate_ToCompleted schComBatch = new ScheduleStatusUpdate_ToCompleted();
                schComBatch.start(BC);
                schComBatch.execute(BC, schList); 
                schComBatch.finish(BC);
            }
        }
    }
}