@isTest
private class ItemCreation_Test{

    @testSetup static void setupMethod(){
    
        List<System_Values__c> sysVal = TestClassUtil.createBillDotComSystemValues();
        
        List<AcctSeed__Project_Task__c> projTasks = TestClassUtil.createTestProjectTask();
        /*List<AcctSeed__Accounting_Variable__c> accVar = TestClassUtil.createAccountingVariable();
        accVar[0].AcctSeed__Active__c = true;
        update accVar;*/
    }
    
    private static testMethod void myTest(){
    
        Set<String> taskTypeValues = new Set<String>{'Language Training','Language Testing','Linguist Support Services','Material Budget','Preparation Time','Translation (per hr)','Translation (per word)','Translation (per FFP)','Interpretation (per hrs)','Accommodations','Admin Fee','Air Fare','Change Fee','Curriculum Development','ELC Langauge Training','Gas'};
        
        List<RecordType> recordType = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'AcctSeed__Project_Task__c' AND Name = 'Language Training'];
        
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id,Name,RecordType.DeveloperName,RecordType.Name,Rate__c,Bill_com_Item_Id__c,AcctSeed__Status__c,Description__c 
                                                        FROM AcctSeed__Project_Task__c
                                                        WHERE Project_Task_Type__c IN :taskTypeValues];
        
        projTask[0].AcctSeed__Status__c = 'Active';
        projTask[0].Bill_com_Item_Id__c = 'Test123';
        projTask[0].RecordTypeId = recordType[0].Id;
        update projTask[0]; 
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock6());
        
        Test.startTest();
            Map<String,String> cookieAndSessionIdMap_Job;
            ItemCreation itemCreat = new ItemCreation(cookieAndSessionIdMap_Job);
            Database.ExecuteBatch(itemCreat);
        Test.stopTest();
        
    }
    private static testMethod void myTest2(){
    
        Set<String> taskTypeValues = new Set<String>{'Language Training','Language Testing','Linguist Support Services','Material Budget','Preparation Time','Translation (per hr)','Translation (per word)','Translation (per FFP)','Interpretation (per hrs)','Accommodations','Admin Fee','Air Fare','Change Fee','Curriculum Development','ELC Langauge Training','Gas'};
        
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id,Name,RecordType.DeveloperName,RecordType.Name,Rate__c,Bill_com_Item_Id__c,AcctSeed__Status__c,Description__c 
                                                        FROM AcctSeed__Project_Task__c
                                                        WHERE Project_Task_Type__c IN :taskTypeValues];
        
        projTask[0].AcctSeed__Status__c = 'Active';
        update projTask[0];  
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock10());
        
        Test.startTest();
            Map<String,String> cookieAndSessionIdMap_Job;
            ItemCreation itemCreat = new ItemCreation(cookieAndSessionIdMap_Job);
            Database.ExecuteBatch(itemCreat);
        Test.stopTest();
        
    }
    private static testMethod void myTest3(){
    
        Set<String> taskTypeValues = new Set<String>{'Language Training','Language Testing','Linguist Support Services','Material Budget','Preparation Time','Translation (per hr)','Translation (per word)','Translation (per FFP)','Interpretation (per hrs)','Accommodations','Admin Fee','Air Fare','Change Fee','Curriculum Development','ELC Langauge Training','Gas'};
        
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id,Name,RecordType.DeveloperName,RecordType.Name,Rate__c,Bill_com_Item_Id__c,AcctSeed__Status__c,Description__c 
                                                        FROM AcctSeed__Project_Task__c
                                                        WHERE Project_Task_Type__c IN :taskTypeValues];
        
        projTask[0].AcctSeed__Status__c = 'Active';
        update projTask[0];  
                
        Test.startTest();
            Map<String,String> cookieAndSessionIdMap_Job;
            ItemCreation itemCreat = new ItemCreation(cookieAndSessionIdMap_Job);
            Database.ExecuteBatch(itemCreat);
        Test.stopTest();
        
    }
}