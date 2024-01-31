@istest
private class MaterialsRequestEmailAlert_Test{

    @testSetup static void setupMethod(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='LTS'].Id;
                
        List<User> userRecs = new List<User>{
            
            new User(alias = 'test123', email='test123@noemail.com',
            emailencodingkey='UTF-8', lastname='TestingFst', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p, country='United States',
            timezonesidkey='America/Los_Angeles', username='testerfst@noemail.com', IsActive = TRUE),
                
            new User(alias = 'test345', email='test345@noemail.com',
            emailencodingkey='UTF-8', lastname='TestingScd', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p, country='United States',
            timezonesidkey='America/Los_Angeles', username='testerscd@noemail.com', IsActive = TRUE)
        };
        insert userRecs;
        
        List<User> users  = [SELECT Id, Name FROM User WHERE Id IN : userRecs];
        String usrIds = users[0].Id+','+users[1].Id;
        
        List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Material Request Email Alert User Ids', Value__c = usrIds)};
        insert sysVal;
        
        Test.startTest();
        
            List<Materials_Request__c> matReqs = TestClassUtil.createTestMaterialRequest();
            List<AcctSeed__Project__c> projects  = TestClassUtil.createTestProject();
            
        Test.stopTest();
    }
    
    private static testMethod void myTest1(){
        
        Id matReqRTId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Project_Materials_Request').getRecordTypeId();
    
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        
        List<Materials_Request__c> matReqUp = [SELECT Id, Name, Project__c, Est_Arrival_Date__c FROM Materials_Request__c LIMIT 1];        
        matReqUp[0].Est_Arrival_Date__c = Date.Today().addDays(-1);
        matReqUp[0].Project__c= projects[0].Id;
        matReqUp[0].RecordTypeId = matReqRTId;
        update matReqUp[0];
        
        List<Materials_Request__c> matReqs = [SELECT Id FROM Materials_Request__c WHERE Id =: matReqUp[0].Id];
        
        // Schedule coverage
        String CRON_EXP = '0 0 14 * * ?';
        MaterialsRequestEmailAlert sch = new MaterialsRequestEmailAlert();
        system.schedule('Materials Request Email Alert Schedule', CRON_EXP, sch);
    }
    
    private static testMethod void myTest2(){
        
        Id matReqRTId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Project_Materials_Request').getRecordTypeId();
        
        List<User> users  = [SELECT Id, Name, Email FROM User WHERE Email = 'test345@noemail.com' LIMIT 1];
        String usrIds = users[0].Id;
        
        List<System_Values__c> sysVal = [SELECT Name, Value__c FROM System_Values__c WHERE Name  = 'Material Request Email Alert User Ids'];
        sysVal[0].Value__c = usrIds;
        update sysVal[0];
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        
        List<Materials_Request__c> matReqUp = [SELECT Id, Name, Project__c, Est_Arrival_Date__c FROM Materials_Request__c LIMIT 1];        
        matReqUp[0].Est_Arrival_Date__c = Date.Today().addDays(-1);
        matReqUp[0].Project__c= projects[0].Id;
        matReqUp[0].RecordTypeId = matReqRTId;
        update matReqUp[0];
        
        List<Materials_Request__c> matReqs = [SELECT Id FROM Materials_Request__c WHERE Id =: matReqUp[0].Id];
        // Schedule coverage
        String CRON_EXP = '0 0 14 * * ?';
        MaterialsRequestEmailAlert sch = new MaterialsRequestEmailAlert();
        system.schedule('Materials Request Email Alert Schedule', CRON_EXP, sch);
    }
}