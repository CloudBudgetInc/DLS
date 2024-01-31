@isTest
private class ScheduleStatusUpdate_Test{

    @testSetup static void setupMethod(){
    
        List<Events__c> events = TestClassUtil.createTestEvent();
    }
    
    private static testMethod void myTest1(){
    
        List<Events__c> eveRec = [SELECT Id, Schedule__c, Status__c FROM Events__c WHERE Schedule__c != NULL];
        System.debug('::eveRec:::'+eveRec);
        
        List<Schedule__c> schRecs = [SELECT Id, Start_Date__c, End_Date__c, Status__c, Schedule_Type__c 
            FROM Schedule__c 
            WHERE Id = :eveRec[0].Schedule__c];
                    
        List<Events__c> eveRecs = [SELECT Id, Schedule__c, Status__c FROM Events__c WHERE Schedule__c =:schRecs[0].Id];
        System.debug('::eveRecs:::'+eveRecs);
        List<Events__c> updateEveRecs = new List<Events__c>();
        
        if(eveRecs != NULL && eveRecs.size() > 0){            
            
            for(Events__c eve : eveRecs){
            
                eve.Status__c = 'Completed';
                updateEveRecs.add(eve);
            }
        }
        System.debug('::updateEveRecs:::'+updateEveRecs);
        
        if(updateEveRecs != NULL && updateEveRecs.size() > 0){
            update updateEveRecs;
        }
        
        schRecs[0].End_Date__c = Date.Today().addDays(-1);
        schRecs[0].Status__c = 'Active';
        schRecs[0].Schedule_Type__c = 'Substitute';
        update schRecs[0];
        
        Test.startTest();
            ScheduleStatusUpdate updateScheduleRec = new ScheduleStatusUpdate();
            updateScheduleRec.execute(null); //system method to schedule apex class        	 
        Test.stopTest();  
        
        List<Schedule__c> updatedSchRecs = [SELECT Id, Status__c FROM Schedule__c WHERE Id = :schRecs[0].Id];
       		System.assertEquals('Completed', updatedSchRecs[0].Status__c);
    }
    
    private static testMethod void myTest2(){
    
        List<Events__c> eveRec = [SELECT Id, Schedule__c, Status__c FROM Events__c WHERE Schedule__c != NULL];
        System.debug('::eveRec:::'+eveRec);
        
        List<Schedule__c> schRecs = [SELECT Id, Start_Date__c, End_Date__c, Status__c, Schedule_Type__c 
            FROM Schedule__c 
            WHERE Id = :eveRec[0].Schedule__c];
                    
        List<Events__c> eveRecs = [SELECT Id, Schedule__c, Status__c FROM Events__c WHERE Schedule__c =:schRecs[0].Id];
        System.debug('::eveRecs:::'+eveRecs);
        List<Events__c> updateEveRecs = new List<Events__c>();
        
        if(eveRecs != NULL && eveRecs.size() > 0){            
            
            for(Events__c eve : eveRecs){
            
                eve.Status__c = 'Scheduled';
                updateEveRecs.add(eve);
            }
        }
        System.debug('::updateEveRecs:::'+updateEveRecs);
        
        if(updateEveRecs != NULL && updateEveRecs.size() > 0){
            update updateEveRecs;
        }
        
        schRecs[0].End_Date__c = Date.Today().addDays(-1);
        schRecs[0].Status__c = 'Active';
        schRecs[0].Schedule_Type__c = 'Substitute';
        update schRecs[0];
        
        Test.startTest();
            ScheduleStatusUpdate updateScheduleRec = new ScheduleStatusUpdate();
            updateScheduleRec.execute(null); //system method to schedule apex class       	
        Test.stopTest();     
        
        List<Schedule__c> updatedSchRecs = [SELECT Id, Status__c FROM Schedule__c WHERE Id = :schRecs[0].Id];
        	System.assertEquals('Active', updatedSchRecs[0].Status__c);
    }
}