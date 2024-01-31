@isTest
private class GenerateDispositionFormCtrl_Test{

    @testSetup static void setupMethod(){
    
        List<APXTConga4__Conga_Merge_Query__c> cqList = TestClassUtil.createCongaQuery();
        List<AcctSeed__Time_Card_Day__c> days = TestClassUtil.createTestTimeCardDay();
        List<APXTConga4__Conga_Template__c> congaTemplateList = TestClassUtil.createCongaTemplate();
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
            List<Materials_Request__c> matReqs = TestClassUtil.createTestMaterialRequest();
            
        Test.stopTest();
    }
    
    // To cover getFromAndToDate() method
    private static testMethod void myTest1(){
    
        Account a  = new Account(Name = 'DLI-W - LT');
        insert a;
        
        GenerateDispositionFormCtrl.getFromAndToDate(a.Id);
    }
    
    // To cover getFromAndToDate() method
    private static testMethod void myTest1a(){
    
        Account a  = new Account(Name = 'My Test Acc');
        insert a;
        
        GenerateDispositionFormCtrl.getFromAndToDate(a.Id);
    }
    
    // To cover getProjects() method
    private static testMethod void myTest2(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c FROM AcctSeed__Time_Card_Day__c LIMIT 2];
        
        List<AcctSeed__Project__c> proj = [SELECT Id FROM AcctSeed__Project__c WHERE Id = :days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c];
        
        Account a  = new Account(Name = 'DLI-W - LT');
        insert a;
        
        proj[0].AcctSeed__Account__c = a.Id;
        proj[0].Section__c = 'AFP';
        update proj[0];
        
        String datVal = String.valueOf(days[0].AcctSeed__Date__c);
        String dateValFormat = datVal.split('-')[1] +'-'+datVal.split('-')[2]+'-'+datVal.split('-')[0];
        
        List<AcctSeed__Project__c> projRecs = GenerateDispositionFormCtrl.getProjects('Hour', '', dateValFormat, dateValFormat, 'AFP');
        System.assertEquals(proj.size(), projRecs.size());
    }
    
    // To cover getProjects() method
    private static testMethod void myTest3(){
    
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c FROM AcctSeed__Time_Card_Day__c LIMIT 2];
        
        List<AcctSeed__Project__c> proj = [SELECT Id FROM AcctSeed__Project__c WHERE Id = :days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c];
        
        Account a  = new Account(Name = 'DLI-W - LT');
        insert a;
        
        proj[0].AcctSeed__Account__c = a.Id;
        update proj[0];
        
        List<Materials_Request__c> matReqs = [SELECT Id, Project__c, Request_Status__c, Date_Delivered__c FROM Materials_Request__c LIMIT 1];
        matReqs[0].Project__c = proj[0].Id;
        matReqs[0].Request_Status__c = 'Delivered';
        update matReqs[0];
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id FROM Contact_Assignments__c WHERE Project__c = :proj[0].Id AND RecordType.DeveloperName = 'Student'];
        
        String datVal = String.valueOf(matReqs[0].Date_Delivered__c);
        String dateValFormat = datVal.split('-')[1] +'-'+datVal.split('-')[2]+'-'+datVal.split('-')[0];
        
        List<AcctSeed__Project__c> projRecs = GenerateDispositionFormCtrl.getProjects('Material', a.Id, dateValFormat, dateValFormat, 'AFPAK');
        System.assertEquals(proj.size(), projRecs.size());
    }
    
    // To cover getCongaRecordMap() method
    private static testMethod void myTest4(){
    
        List<APXTConga4__Conga_Merge_Query__c> mergeQueries = [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c LIKE '%Disposition%'];
        
        List<APXTConga4__Conga_Template__c> congaTemplates = [SELECT Id,Name,APXTConga4__Name__c,APXTConga4__Template_Group__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Template_Group__c = 'Disposition'];
        GenerateDispositionFormCtrl.getCongaRecordMap();
    }
}