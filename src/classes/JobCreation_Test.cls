@isTest
private class JobCreation_Test{
    
    @testSetup static void setupMethod(){
        
        List<AcctSeed__Project__c> projects = TestClassUtil.createTestProject();
        
        List<System_Values__c> sysVal = TestClassUtil.createBillDotComSystemValues();
    }
    
    private static testMethod void myTest1(){
    
        List<AcctSeed__Project__c> projects = [SELECT Id, Name, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName NOT IN ('Cost_Only','Partner_School_LT_Projects','Admin_Projects','Facilities_Project') LIMIT 1];
        projects[0].AcctSeed__Status__c = 'Active';
        update projects[0];
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock4());
        
        Test.startTest();
        
            JobCreation jobCreat = new JobCreation();
            Database.ExecuteBatch(jobCreat, 1);
        Test.stopTest();
        
    }
    
    private static testMethod void myTest2(){
    
        List<AcctSeed__Project__c> projects = [SELECT Id, Name, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName NOT IN ('Cost_Only','Partner_School_LT_Projects','Admin_Projects','Facilities_Project') LIMIT 1];
        projects[0].AcctSeed__Status__c = 'Active';
        update projects[0];
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock4());
                
        Test.startTest();
                        
            JobCreation jobCreat = new JobCreation();
            Database.ExecuteBatch(jobCreat, 1);
        Test.stopTest();
        
    }
    private static testMethod void myTest3(){
    
        List<AcctSeed__Project__c> projects = [SELECT Id, Name, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName NOT IN ('Cost_Only','Partner_School_LT_Projects','Admin_Projects','Facilities_Project') LIMIT 1];
        projects[0].AcctSeed__Status__c = 'Active';
        projects[0].Bill_com_Job_Id__c = 'Test123';
        update projects[0];
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock11());
                
        Test.startTest();
                        
            JobCreation jobCreat = new JobCreation();
            Database.ExecuteBatch(jobCreat, 1);
        Test.stopTest();
        
    }
}