@isTest
private class CAStatusUpdate_Schedule_Test {

    @testsetup static void setup(){
    
        Test.startTest();
            List<AcctSeed__Project__c> projects = TestClassUtil.createTestProject();
        Test.stopTest();
    }
    
    private static testmethod void myTest(){
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
    
        List<AcctSeed__Project__c> projList = [SELECT Id, Name, Start_Date__c, AcctSeed__Status__c, RecordTypeId, QB_Classification__c FROM AcctSeed__Project__c LIMIT 1];
        projList[0].RecordTypeId = dodaRTId;
        projList[0].Start_Date__c = Date.Today().addDays(1);
        projList[0].AcctSeed__Status__c  = 'Order';
        projList[0].QB_Classification__c = 'OF0MTT0PS';
        update projList[0];
        
        Database.executeBatch(new CAStatusUpdation_FromProject_Batch());
        
        Test.startTest();
        
            String CRON_EXP = '0 0 10 * * ?';
            CAStatusUpdate_Schedule sch = new CAStatusUpdate_Schedule();
            System.schedule('Project Status Updation', CRON_EXP, sch);
        Test.stopTest();
    }    
}