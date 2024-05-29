@isTest
private class AuditTrailReportController_Test{

    @testSetup static void setupMethod(){ 
    
        List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment();
        Test.startTest(); 
         List<AcctSeed__Time_Card_Day__c> timeCardDays = TestClassUtil.createTestTimeCardDay(); 
        Test.stopTest();
    }
    
    private static testMethod void myTest1(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='Approved_by__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecs(null, null, '', '','','Time Card Day','',true);
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c]; 
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Hours__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecs(System.Today(), System.Today(), '', '','','Time Card Day','',false);
        Test.stopTest();
    }
    
    private static testMethod void myTest3(){
    
        List<AcctSeed__Time_Card_Line__c> tclLine = [SELECT Id FROM AcctSeed__Time_Card_Line__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Line__History h = new AcctSeed__Time_Card_Line__History(ParentId = tclLine[0].Id, Field='Completed__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecs(null,null, '', '','','Time Card Line','',true);
        Test.stopTest();
    }
        private static testMethod void myTest4(){
    
        List<AcctSeed__Time_Card_Line__c> tclLine = [SELECT Id FROM AcctSeed__Time_Card_Line__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Line__History h = new AcctSeed__Time_Card_Line__History(ParentId = tclLine[0].Id, Field='Completed__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecs(system.today(),null, 'test', 'test','test','Time Card Line','Name',true);
        Test.stopTest();
    }
    
    private static testMethod void myTest5(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Date__c');
            insert h;
            
            AuditTrailReportController.getLookupRecords('test', 'AcctSeed__Time_Card_Day__c', '', '', new List<String>{});
        Test.stopTest();
    }
}