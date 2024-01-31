@isTest
private class ProjectSummaryController_Test{

    @testSetup static void setupMethod(){
    
        Test.startTest();
            List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
        Test.stopTest();
        List<MTT_Location__c> location = TestClassUtil.createTestLocations();
    }
    
    // To cover getProjectList() method
    private static testMethod void myTest1(){
        
        List<Contact> conList = [SELECT Id, AccountId FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Id = :conList[0].AccountId];
        System.debug('accounts =='+accounts+'accounts  SIZE=='+accounts.size());
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, RecordTypeId FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        String caRTId = conAss[0].RecordTypeId;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c, AcctSeed__Status__c, RecordTypeId,RecordType.Name FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        proj[0].AcctSeed__Account__c = accounts[0].Id;
        update proj[0];
        
        ProjectSummaryController.ProjectSummaryInputDetails  pSInputs = new ProjectSummaryController.ProjectSummaryInputDetails();
 
        pSInputs.accountId = (new List<Account>{accounts[0]});
        pSInputs.cARTId = conAss[0].RecordTypeId;
        pSInputs.projectStatus = new List<String>{proj[0].AcctSeed__Status__c};
        pSInputs.projectRTNames = (new List<String>{proj[0].RecordType.Name});
        pSInputs.cAPosition = 'Class Leader';
        pSInputs.cAStatus = new List<String>{'Active'};
        pSInputs.locationId = loc.Id;
        pSInputs.contactId = conList[0].Id;
        pSInputs.sortingFieldName = 'AcctSeed__Status__c';
        pSInputs.sortingOrder = 'ASC';
        
        Test.startTest();
            ProjectSummaryController.projectSummaryFullInfo projectInfo = ProjectSummaryController.getProjectList(json.serialize(pSInputs));
            List<ProjectSummaryController.projectSummaryInfo> projSumList = projectInfo.projectSummaryList;
            System.assertEquals(accounts[0].Id, projSumList[0].accountId);
            System.assertEquals(0, projectInfo.hoursWeek );
            System.assertEquals(1, projectInfo.noOfProjects);
        Test.stopTest();
    }
    
    // To cover getProjectList() method
    private static testMethod void myTest2(){
        
        List<Contact> conList = [SELECT Id, AccountId FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Id = :conList[0].AccountId];
        System.debug('accounts =='+accounts+'accounts  SIZE=='+accounts.size());
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, RecordTypeId FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        String caRTId = conAss[0].RecordTypeId;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c, AcctSeed__Status__c, RecordTypeId,RecordType.Name FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        proj[0].AcctSeed__Account__c = accounts[0].Id;
        update proj[0];
        
        ProjectSummaryController.ProjectSummaryInputDetails  pSInputs = new ProjectSummaryController.ProjectSummaryInputDetails();
        pSInputs.accountId = (new List<Account>{accounts[0]});
        pSInputs.cARTId = conAss[0].RecordTypeId;
        pSInputs.projectStatus = (new List<String>{proj[0].AcctSeed__Status__c});
        pSInputs.projectRTNames =  (new List<String>{proj[0].RecordType.Name});
        pSInputs.cAPosition = 'Class Leader';
        pSInputs.cAStatus = (new List<String>{'Active'});
        pSInputs.locationId = loc.Id;
        pSInputs.contactId = conList[0].Id;
        pSInputs.sortingFieldName = 'Name';
        pSInputs.sortingOrder = 'ASC';
        
        Test.startTest();
        ProjectSummaryController.getProjectList(JSON.serialize(pSInputs));
        
        pSInputs.locationId = null;
        ProjectSummaryController.getProjectList(JSON.serialize(pSInputs));
        
        pSInputs.contactId = null;
        ProjectSummaryController.getProjectList(JSON.serialize(pSInputs));
        
        Test.stopTest();
    }
    
    // To cover getProjectList() method
    private static testMethod void myTest3(){
        
        List<Contact> conList = [SELECT Id, AccountId FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Id = :conList[0].AccountId];
        System.debug('accounts =='+accounts+'accounts  SIZE=='+accounts.size());
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, RecordTypeId FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        String caRTId = conAss[0].RecordTypeId;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        proj[0].AcctSeed__Account__c = accounts[0].Id;
        update proj[0];
        
        ProjectSummaryController.ProjectSummaryInputDetails  pSInputs = new ProjectSummaryController.ProjectSummaryInputDetails();
        pSInputs.accountId = (new List<Account>());
        pSInputs.cARTId = null;
        pSInputs.projectStatus = new List<String>{proj[0].AcctSeed__Status__c};
        pSInputs.projectRTNames =  (new List<String>{});
        pSInputs.cAPosition = 'Class Leader';
        pSInputs.cAStatus = new List<String>{'Active'};
        pSInputs.locationId = null;
        pSInputs.contactId = null;
        pSInputs.sortingFieldName = 'Name';
        pSInputs.sortingOrder = 'ASC';
        
        Test.startTest();
        ProjectSummaryController.getProjectList(json.serialize(pSInputs));
        
        pSInputs.cAPosition = null;
        ProjectSummaryController.getProjectList(json.serialize(pSInputs));
        
        pSInputs.projectStatus = new List<String>();
        ProjectSummaryController.getProjectList(json.serialize(pSInputs));
        
        Test.stopTest();
    }
    
    // To cover getProjectList() method
    private static testMethod void myTest4(){
        
        List<Contact> conList = [SELECT Id, AccountId FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Id = :conList[0].AccountId];
        System.debug('accounts =='+accounts+'accounts  SIZE=='+accounts.size());
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, RecordTypeId FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        String caRTId = conAss[0].RecordTypeId;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c, AcctSeed__Status__c, RecordTypeId,RecordType.Name FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        proj[0].AcctSeed__Account__c = accounts[0].Id;
        proj[0].Hours_Week__c = 8;
        update proj[0];
                
        ProjectSummaryController.ProjectSummaryInputDetails  pSInputs = new ProjectSummaryController.ProjectSummaryInputDetails();
        pSInputs.accountId = (new List<Account>{accounts[0]});
        pSInputs.cARTId = conAss[0].RecordTypeId;
        pSInputs.projectStatus = (new List<String>{proj[0].AcctSeed__Status__c});
        pSInputs.projectRTNames = (new List<String>{proj[0].RecordType.Name});
        pSInputs.cAPosition = 'Class Leader';
        pSInputs.cAStatus = (new List<String>{'Active'});
        pSInputs.locationId = loc.Id;
        pSInputs.contactId = conList[0].Id;
        pSInputs.sortingFieldName = 'Name';
        pSInputs.sortingOrder = 'ASC';
        
        Test.startTest();
        ProjectSummaryController.projectSummaryFullInfo projectInfo = ProjectSummaryController.getProjectList(json.serialize(pSInputs));
        System.assertEquals(8, projectInfo.hoursWeek );
        Test.stopTest();
    }
    
    // To cover SaveSearches() method
    private static testMethod void myTest5(){
    
        List<Saved_Search__c> saveList = new List<Saved_Search__c>{
            new Saved_Search__c(Name = 'SS1', Filter_Value__c = '{"Contact Assignment Record Type":"All","Contact Assignment Position":"All","Contact Assignment Status":["Active"]}')
        };
        ProjectSummaryController.SaveSearches(JSON.serialize(saveList));
    }
    
    // To cover SaveSearches() method
    private static testMethod void myTest6(){
    
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<Saved_Search__c> saveList = new List<Saved_Search__c>();
        try{
            ProjectSummaryController.SaveSearches(JSON.serialize(saveList));
        }catch(Exception e){
            System.debug('======'+e.getMessage());  
            Boolean expectedExceptionThrown =  e.getMessage().contains('Script-thrown exception') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);  
        }
    }
    
    // To cover deleteFilter() method
    private static testMethod void myTest7(){
    
        List<Saved_Search__c> saveList = new List<Saved_Search__c>{
            new Saved_Search__c(Name = 'SS1', Filter_Value__c = '{"Contact Assignment Record Type":"All","Contact Assignment Position":"All","Contact Assignment Status":["Active"]}')
        };
        insert saveList;
        
        ProjectSummaryController.deleteFilter(saveList[0].Id);
    }    
    
    // To cover updateContact() method
    private static testMethod void myTest8(){
    
        User logUser = [SELECT Id, FirstName, Middlename, Lastname FROM User WHERE Id = :UserInfo.getUserId()]; 
        
        List<Contact> conList = [SELECT Id, FirstName, Middlename, Lastname FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        conList[0].FirstName = logUser.FirstName;
        conList[0].Middlename = logUser.Middlename;
        conList[0].Lastname = logUser.Lastname;
        update conList[0];
        
        Test.startTest();
            
            List<Saved_Search__c> saveList = new List<Saved_Search__c>{
                new Saved_Search__c(Name = 'SS1', Filter_Value__c = '{"Contact Assignment Record Type":"All","Contact Assignment Position":"All","Contact Assignment Status":["Active"]}')
            };
            insert saveList;
            
            ProjectSummaryController.updateContact(saveList[0].Id, 'Update');
            ProjectSummaryController.updateContact(saveList[0].Id, 'insert');
            
        Test.stopTest();
    }
    
    // To cover updateContact() method
    private static testMethod void myTest9(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
            
            List<Saved_Search__c> saveList = new List<Saved_Search__c>{
                new Saved_Search__c(Name = 'SS1', Filter_Value__c = '{"Contact Assignment Record Type":"All","Contact Assignment Position":"All","Contact Assignment Status":["Active"]}')
            };
            insert saveList;
            
            System.runAs(user){
                try{
                    ProjectSummaryController.updateContact(saveList[0].Id, 'Update');
                }catch(Exception e){
                    System.debug('======'+e.getMessage()); 
                }
            }
        Test.stopTest();
    }
    
    // To cover updateContact() method
    private static testMethod void myTest10(){
    
        User logUser = [SELECT Id, FirstName, Middlename, Lastname FROM User WHERE Id = :UserInfo.getUserId()]; 
        
        List<Contact> conList = [SELECT Id, FirstName, Middlename, Lastname FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        conList[0].FirstName = logUser.FirstName;
        conList[0].Middlename = logUser.Middlename;
        conList[0].Lastname = logUser.Lastname;
        update conList[0];
       
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, RecordTypeId FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<Saved_Search__c> saveList = new List<Saved_Search__c>{
            new Saved_Search__c(Name = 'SS1', Filter_Value__c = '{"Contact Assignment Record Type":"All","Contact Assignment Position":"All","Contact Assignment Status":["Active"]}')
        };
        insert saveList;
            
        Test.startTest();
            
            try{
                ProjectSummaryController.getFilters();
            }catch(Exception e){
                System.debug('======'+e.getMessage());     
            }
        Test.stopTest();
    }
    
    // To cover updateProjectStatus() method
    private static testMethod void myTest11(){
    
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c, AcctSeed__Status__c FROM AcctSeed__Project__c LIMIT 1];
        
        try{
            ProjectSummaryController.updateProjectStatus(proj[0].Id, String.valueOf(system.today()),'Testing','On Hold');
        }catch(Exception e){
            
        }
    }
    
    // To cover updateProjectStatus() method
    private static testMethod void myTest12(){
    
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c, AcctSeed__Status__c FROM AcctSeed__Project__c LIMIT 1];
        
        try{
            ProjectSummaryController.updateProjectStatus(proj[0].Id, String.valueOf(system.today().addDays(-4)),'','Canceled');
        }catch(Exception e){
            System.debug('======'+e.getMessage());     
        }
    }
    
    // To cover getLookupRecords() method
    private static testMethod void myTest13(){
    
        List<Contact> conList = [SELECT Id, FirstName, Middlename, Lastname FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, RecordTypeId FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        try{
            ProjectSummaryController.getLookupRecords('', 'Contact_Assignments__c', '', '', new List<String>{});
        }catch(Exception e){
            System.debug('======'+e.getMessage());     
        }
    }
    
    // To cover getRecordTypeBased_PicklistValues() method
    private static testMethod void myTest14(){
    
        List<Contact> conList = [SELECT Id, FirstName, Middlename, Lastname FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, RecordTypeId FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        try{
            ProjectSummaryController.getRecordTypeBased_PicklistValues('Contact_Assignments__c', '', conAss[0].RecordTypeId);
        }catch(Exception e){
            System.debug('======'+e.getMessage());     
        }
    }
    
    // To cover getRecordTypeBased_PicklistValues() method
    private static testMethod void myTest15(){
    
        List<Contact> conList = [SELECT Id, FirstName, Middlename, Lastname FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, RecordTypeId FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        try{
            ProjectSummaryController.getRecordTypeBased_PicklistValues('Contact_Assignments__c', '', 'All');
        }catch(Exception e){
            System.debug('======'+e.getMessage());     
        }
    }
    
    // To cover downloadCsvFile() method
    private static testMethod void myTest16(){
    
        List<Contact> conList = [SELECT Id, FirstName, Middlename, Lastname FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, RecordTypeId FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
        try{
            ProjectSummaryController.downloadCsvFile(new List<String>{conAss[0].Project__c}, 'Student');
        }catch(Exception e){
            System.debug('======'+e.getMessage());     
        }
    }
}