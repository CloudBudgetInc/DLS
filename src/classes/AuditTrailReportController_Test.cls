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
            
            AuditTrailReportController.getAuditReportRecs(System.Today(), System.Today(), '', '', '');
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Hours__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecs(null, null, '', '', '');
        Test.stopTest();
    }
    
    private static testMethod void myTest3(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Hours__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecs(null, null, 'test', 'test', 'test');
        Test.stopTest();
    }
    
    private static testMethod void myTest4(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Hours__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecs(System.Today(), null, 'test', 'test', 'test');
        Test.stopTest();
    }
    
    private static testMethod void myTest5(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Hours__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecs(null, System.Today(), 'test', 'test', 'test');
        Test.stopTest();
    }
    
    private static testMethod void myTest6(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Hours__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecs(null, System.Today(), 'test', 'test', 'test');
        Test.stopTest();
    }
    
    private static testMethod void myTest7(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Date__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecs(null, System.Today(), 'test', 'test', 'test');
        Test.stopTest();
    }
    
    private static testMethod void myTest8(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='Approved_by__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecsToDownload(System.Today(), System.Today(), '', '', '');
        Test.stopTest();
    }
    
    private static testMethod void myTest9(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Hours__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecsToDownload(null, null, '', '', '');
        Test.stopTest();
    }
    
    private static testMethod void myTest10(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Hours__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecsToDownload(null, null, 'test', 'test', 'test');
        Test.stopTest();
    }
    
    private static testMethod void myTest11(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Hours__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecsToDownload(System.Today(), null, 'test', 'test', 'test');
        Test.stopTest();
    }
    
    private static testMethod void myTest12(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Hours__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecsToDownload(null, System.Today(), 'test', 'test', 'test');
        Test.stopTest();
    }
    
    private static testMethod void myTest13(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Hours__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecsToDownload(null, System.Today(), 'test', 'test', 'test');
        Test.stopTest();
    }
    
    private static testMethod void myTest14(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Date__c');
            insert h;
            
            AuditTrailReportController.getAuditReportRecsToDownload(null, System.Today(), 'test', 'test', 'test');
        Test.stopTest();
    }
    
    private static testMethod void myTest15(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
        
        Test.startTest();
            
            AcctSeed__Time_Card_Day__History h = new AcctSeed__Time_Card_Day__History(ParentId = days[0].Id, Field='AcctSeed__Date__c');
            insert h;
            
            AuditTrailReportController.getLookupRecords('test', 'AcctSeed__Time_Card_Day__c', '', '', new List<String>{});
        Test.stopTest();
    }
}