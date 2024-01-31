@isTest
private class SendMonthlyLibraryLoanStatement_Test{

    @testSetup static void setupMethod(){
    
        List<Materials_Request__c> matReqs = TestClassUtil.createTestMaterialRequest();    
        List<AcctSeed__Project__c> projects =TestClassUtil.createTestProject();
    }
    
    private static testMethod void myTest1(){
    
        Id matRTId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Material_Loan_Request').getRecordTypeId();
        
        List<AcctSeed__Project__c> proj = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        List<Materials_Request__c> matReqs = [SELECT Id, Date_Loaned_Out__c, Contact__c, RecordTypeId FROM Materials_Request__c lIMIT 2];
        matReqs[0].Date_Loaned_Out__c = System.Today().addDays(-2);
        matReqs[0].RecordTypeId = matRTId;
        matReqs[0].Request_Status__c = 'Loaned Out';
        matReqs[0].Project__c = proj[0].Id;
        update matReqs[0];
                       
        System.debug(':::matReqs:::::'+matReqs);
        
        String CRON_EXP = '0 0 14 * * ?';
        SendMonthlyLibraryLoanStatement sch = new SendMonthlyLibraryLoanStatement();
        system.schedule('Monthly Outstanding Library Loan Notification', CRON_EXP, sch);
    }
    
    private static testMethod void myTest2(){
    
        Id matRTId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Material_Loan_Request').getRecordTypeId();
        
        List<AcctSeed__Project__c> proj = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        MTT_Location__c loc = new MTT_Location__c(Name='DLS - Herndon');
        insert loc;
        
        List<Materials_Request__c> matReqs = [SELECT Id, Date_Loaned_Out__c, Contact__c, RecordTypeId FROM Materials_Request__c lIMIT 2];
        matReqs[0].Date_Loaned_Out__c = System.Today().addDays(-2);
        matReqs[0].RecordTypeId = matRTId;
        matReqs[0].Request_Status__c = 'Loaned Out';
        matReqs[0].Project__c = proj[0].Id;
        matReqs[0].Location__c = loc.Id;
        update matReqs[0];
                       
        System.debug(':::matReqs:::::'+matReqs);
        
        String CRON_EXP = '0 0 14 * * ?';
        SendMonthlyLibraryLoanStatement sch = new SendMonthlyLibraryLoanStatement();
        system.schedule('Monthly Outstanding Library Loan Notification', CRON_EXP, sch);
    }
    
    private static testMethod void myTest3(){
    
        Id matRTId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Material_Loan_Request').getRecordTypeId();
        
        List<AcctSeed__Project__c> proj = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        MTT_Location__c loc = new MTT_Location__c(Name='DLS - Elkridge');
        insert loc;
        
        List<Materials_Request__c> matReqs = [SELECT Id, Date_Loaned_Out__c, Contact__c, RecordTypeId FROM Materials_Request__c lIMIT 2];
        matReqs[0].Date_Loaned_Out__c = System.Today().addDays(-2);
        matReqs[0].RecordTypeId = matRTId;
        matReqs[0].Request_Status__c = 'Loaned Out';
        matReqs[0].Project__c = proj[0].Id;
        matReqs[0].Location__c = loc.Id;
        update matReqs[0];
                       
        System.debug(':::matReqs:::::'+matReqs);
        
        String CRON_EXP = '0 0 14 * * ?';
        SendMonthlyLibraryLoanStatement sch = new SendMonthlyLibraryLoanStatement();
        system.schedule('Monthly Outstanding Library Loan Notification', CRON_EXP, sch);
    }
}