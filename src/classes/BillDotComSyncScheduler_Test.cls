@isTest
private class BillDotComSyncScheduler_Test{

    @testSetup static void setupMethod(){
    
        List<AcctSeed__Project__c> projects = TestClassUtil.createTestProject();
        
        List<System_Values__c> sysVal = new List<System_Values__c>{
            new System_Values__c(Name ='Bill.com Vendor Last Sync Date Time', Value__c = '2020-04-24 08:30:45'), 
            new System_Values__c(Name ='Bill.com Job Last Sync Date Time', Value__c = '2020-04-24 08:30:45'),
            new System_Values__c(Name ='Bill.com Item Last Sync Date Time', Value__c = '2020-04-24 08:30:45'),
            new System_Values__c(Name ='Bill.com Class Last Sync Date Time', Value__c = '2020-04-24 08:30:45')
        };
        insert sysVal;
    }
    
    private static testMethod void myTest1(){
    
        List<AcctSeed__Project__c> projects = [SELECT Id, Name, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName NOT IN ('Cost_Only','Partner_School_LT_Projects','Admin_Projects','Facilities_Project') LIMIT 1];
        projects[0].AcctSeed__Status__c = 'Active';
        update projects[0];
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock4());
                        
        // Schedule coverage
        String CRON_EXP = '0 0 * * * ?';
        BillDotComSyncScheduler sch = new BillDotComSyncScheduler();
        system.schedule('BillDotCom Sync Scheduler', CRON_EXP, sch);    
        
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
        
        // Schedule coverage
        String CRON_EXP = '0 0 * * * ?';
        BillDotComSyncScheduler sch = new BillDotComSyncScheduler();
        system.schedule('BillDotCom Sync Scheduler', CRON_EXP, sch); 
        
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
        
        // Schedule coverage
        String CRON_EXP = '0 0 * * * ?';
        BillDotComSyncScheduler sch = new BillDotComSyncScheduler();
        system.schedule('BillDotCom Sync Scheduler', CRON_EXP, sch); 
        
        Test.startTest();
                        
            JobCreation jobCreat = new JobCreation();
            Database.ExecuteBatch(jobCreat, 1);
        Test.stopTest();
    }
}