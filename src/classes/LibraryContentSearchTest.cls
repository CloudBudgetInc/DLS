@isTest
private class LibraryContentSearchTest {
    
    @testSetup static void setup(){
        
        Test.StartTest();
        List<Contact_Assignments__c> conassList = TestClassUtil.createTestContactAssignment();  
        List<MTT_Location__c> locations = TestClassUtil.createTestLocations();
        Test.StopTest();  
        List<Events__c> EvventList= TestClassUtil.createTestEvent();
        //List<AcctSeed__Project_Task__c> taskList = TestClassUtil.createTestProjectTask();        
        List<ContentVersion> contentVersion = TestClassUtil.createTestContents(); 
        //List<Materials__c> matList = TestClassUtil.createTestmaterials(); 
        List<Materials_Request__c> materialRequest = TestClassUtil.createTestMaterialRequest();
        //List<Material_Rating__c> materialratingList = TestClassUtil.createTestmaterialsRating();
    }
    
    static testmethod void test1() {
    
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name,AcctSeed__Client_Contact__c,AcctSeed__Project__c,Project_Task_Type__c,AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        Account a = new Account(Name='Test Account Name');
        insert a;
        
        List<RecordType> conrt = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Contact' And DeveloperName = 'DLS_Employee'];
        
        List<Contact> con1 = new List<Contact>{
            new Contact(LastName = 'Testing Contact',RecordTypeId = conrt[0].Id, AccountId = a.Id)
        };
        
        insert con1;
        
        List<Profile> Profile = [SELECT Id FROM Profile WHERE Name = 'DLS Instructor'];
        system.debug(':::Profile'+Profile);
        
        String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
        String en = String.valueOf(System.now().millisecond())+'@dlsTestOrg.com';
        
        User usr = new User(Alias = 'standt', Email='test@gmail.com',EmailEncodingKey='UTF-8',LastName = con1[0].LastName,
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = Profile[0].Id,
        TimeZoneSidKey='America/Los_Angeles', UserName=un,ContactId = con1[0].Id);
        
        insert usr;
        
        List<Materials__c> materialList = [Select Id,Name From Materials__c Limit 2];        
        String materialId = materialList[0].Id;
            
        List<Materials_Request__c> materialReq = new List<Materials_Request__c>{
            new Materials_Request__c(Name = 'Test 1', Materials_Name__c = materialList[0].Id, Project__c = projectTaskList[0].AcctSeed__Project__c,Project_Task__c = projectTaskList[0].Id,Request_Status__c = 'Requested by LTS',Vendor_Name__c = a.Id, Contact__c = con1[0].Id),
            new Materials_Request__c(Name = 'Test 2', Materials_Name__c = materialList[0].Id, Project__c = projectTaskList[0].AcctSeed__Project__c,Project_Task__c = projectTaskList[0].Id,Request_Status__c = 'Requested by LTS',Vendor_Name__c = a.Id, Contact__c = con1[0].Id),
            new Materials_Request__c(Name = 'Test 3', Materials_Name__c = materialList[0].Id, Project__c = projectTaskList[1].AcctSeed__Project__c,Project_Task__c = projectTaskList[1].Id,Request_Status__c = 'Requested by LTS',Vendor_Name__c = a.Id, Contact__c = con1[0].Id)
        };
        String JsonMaterial = JSON.serialize(materialReq);
                
        LibraryContentSearch.CreateMaterialsRequests(JsonMaterial);
        LibraryContentSearch libr = new LibraryContentSearch();
        
        System.runAs(usr){
            LibraryContentSearch.getLookupRecords('Opportunity','','');
        }
    }
     
    static testmethod void test2() {
        
        List<RecordType> conrt = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Contact' And DeveloperName = 'Candidate'];
        
        List<Profile> Profile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User Clone'];
        
        String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
        String en = String.valueOf(System.now().millisecond())+'@dlsTestOrg.com';
        
        Account a = new Account(Name='Test Account Name');
        insert a;
        
        List<Contact> con1 = new List<Contact>{
            new Contact(LastName = 'Testing Contact',RecordTypeId = conrt[0].Id, AccountId = a.Id),
            new Contact(LastName = 'Testing Contact 1',RecordTypeId = conrt[0].Id, AccountId = a.Id)
        };
        
        insert con1;
        
        User usr = new User(Alias = 'standt', Email='test@gmail.com',EmailEncodingKey='UTF-8',LastName = con1[0].LastName,
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = Profile[0].Id,Staff_Access__c = true,Current_Previlege__c = 'Staff',
        TimeZoneSidKey='America/Los_Angeles', UserName=un,ContactId = con1[0].Id);
        
        insert usr;
        
         system.runAs(usr){            
            LibraryContentSearch.getLookupRecords('Contact','test','AccountId != null');
            LibraryContentSearch.getLookupRecords('Opportunity','test','Id != NULL');
            LibraryContentSearch.getLookupRecords('AcctSeed__Project__c','test','Id != NULL');
            LibraryContentSearch.getLookupRecords('Opportunity','','Id != NULL');
            LibraryContentSearch.getLookupRecords('AcctSeed__Project__c','','Id != NULL');
            LibraryContentSearch.getLookupRecords('Contact','','AccountId != null');
            LibraryContentSearch.getLookupRecords('Contact','','');
        }
        
        List<MTT_Location__c> locList = new List<MTT_Location__c>();
        locList.add(new MTT_Location__c(Name='DLS - Rosslyn',State__c = 'VA'));
        locList.add(new MTT_Location__c(Name='DLS - Elkridge',State__c = 'MD'));
        insert locList;
        
        List<Contact_Assignments__c> conassignList = [SELECT Id,Project__c,Opportunity_Name__c,RecordType.DeveloperName,Candidate_Name__c FROM Contact_Assignments__c WHERE (Project__c != null OR Opportunity_Name__c != null) AND RecordType.DeveloperName = 'Staff' ];
        system.debug('::123:conassignList'+conassignList);
        conassignList[0].Candidate_Name__c = con1[0].Id;
        update conassignList;
        
        List<Materials__c> materialList = [Select Id,Name From Materials__c Limit 2];        
        String materialId = materialList[0].Id;
        
        List<ContentVersion> contentDetails = [SELECT Id,Title,Number_of_Downloads__c,ContentDocument.ParentId FROM ContentVersion LIMIT 2];
        
        ContentVersionService.getContentVersionbyIds(new Set<Id>{contentDetails[0].Id,contentDetails[1].Id},new Set<Id>{});
        ContentVersionService.getContentVersionbyIds(new Set<Id>{},new Set<Id>{contentDetails[0].ContentDocument.ParentId,contentDetails[1].ContentDocument.ParentId});
        ContentVersionService.getContentVersionbyIds(new Set<Id>{contentDetails[0].Id,contentDetails[1].Id},'Average_Rating__c',2);
        
        //To inrease code coverage for "RequestService"
        RequestService.getAggregatelist(new Set<Id>{contentDetails[0].Id});
        
    }
    
    static testmethod void test3() {
        List<ContentVersion> contentDetails = [SELECT Id,Title,Number_of_Downloads__c,ContentDocument.ParentId FROM ContentVersion LIMIT 2];
        
        List<ContentDocument> contentDocument = [SELECT Id,Title,ParentId FROM ContentDocument LIMIT 2];
                
        List<Contact_Assignments__c> conassignList = [SELECT Id,Project__c,Opportunity_Name__c,RecordType.DeveloperName,Candidate_Name__c FROM Contact_Assignments__c WHERE (Project__c != null OR Opportunity_Name__c != null) AND RecordType.DeveloperName = 'Staff' ];
        
        List<Contact> conList = [SELECT Id,Name FROM Contact LIMIT 2];
        
        LibraryContentSearch.projectTasksBasedOnProject(conassignList[0].Project__c);
        LibraryContentSearch.projectsBasedonContact(conList[0].Id);
        
    } 

}