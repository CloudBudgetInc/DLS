@isTest
private class LibrarySearchController_Test{ 

    @testSetup static void setupMethod(){
    
        Test.startTest();
            List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
        
            List<Request__c> reqs = TestClassUtil.createTestRequests();
            List<Materials_Request__c> matReqs = TestClassUtil.createTestMaterialRequest();
            //List<Language__c> langs = TestClassUtil.createTestLanguages();
            List<Material_Rating__c> matRatings = TestClassUtil.createTestmaterialsRating();
            List<MTT_Location__c> locations = TestClassUtil.createTestLocations();
    }
    
    // To cover getCurrentUserType() method
    private static testMethod void myTest1(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            system.runAs(user) {
                String res = LibrarySearchController.getCurrentUserType();
                System.assertEquals('Instructor', res);
            }
        Test.stopTest();
    }
    
    // To cover getCurrentUserType() method
    private static testMethod void myTest2(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
            system.runAs(user) {
                String res = LibrarySearchController.getCurrentUserType();
                System.assertEquals('Student', res);
            }
        Test.stopTest();
    }
    
    // To cover getCurrentUserType() method
    private static testMethod void myTest3(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Staff_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
            system.runAs(user) {
                String res = LibrarySearchController.getCurrentUserType();
                System.assertEquals('Staff', res);
            }
        Test.stopTest();
    }
    
    // To cover getCurrentUserType() method
    private static testMethod void myTest4(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='testertest1@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            system.runAs(user) {
                String res = LibrarySearchController.getCurrentUserType();
                System.assertEquals('Internal', res);
            }
        Test.stopTest();
    }
    
    // To cover getFilterValues() method
    private static testMethod void myTest5(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            List<Language__c> languages = [SELECT Id FROM Language__c];
            system.runAs(user) {
                String res = LibrarySearchController.getFilterValues();
            }
        Test.stopTest();
    }
    
    // To cover getMRFilterDetails() method
    private static testMethod void myTest6(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            List<MTT_Location__c> locations = [SELECT Id, Name FROM MTT_Location__c];
            locations[0].Name = 'DLS - Arlington';
            update locations[0];
            
            System.runAs(user) {
                LibrarySearchController.getMRFilterDetails();
            }
        Test.stopTest();
    }
    
    // To cover getRecordTypeBased_PicklistValues() method
    private static testMethod void myTest7(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            List<Materials_Request__c> matReqs = [SELECT Id, RecordTypeId FROM Materials_Request__c LIMIT 1];
            
            System.runAs(user) {
                try{
                    LibrarySearchController.getRecordTypeBased_PicklistValues('Materials_Request__c', 'Request_Status__c', matReqs[0].RecordTypeId);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover getLookupRecords() method
    private static testMethod void myTest8(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            System.runAs(user) {
                try{
                    LibrarySearchController.getLookupRecords('', 'Materials_Request__c', '', '', new List<String>{});
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover materialRequestBasedonFilter() method
    private static testMethod void myTest9(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            System.runAs(user) {
                try{
                    LibrarySearchController.materialRequestBasedonFilter('', '', '', '','');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover materialRequestBasedonFilter() method
    private static testMethod void myTest10(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<Contact> supr = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' AND LastName='StaffContact' LIMIT 1];
        System.debug('conList==='+conList);
        
        Test.startTest();
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = supr[0].Id;
        conAss[0].Assignment_Position__c = 'Project Manager';
        update conAss[0]; 
        
        
            Id projMatRqId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Project_Materials_Request').getRecordTypeId();
            List<MTT_Location__c> locations = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
            
            List<Materials_Request__c> matReqs = [SELECT Id, RecordTypeId, Contact__c, Location__c FROM Materials_Request__c LIMIT 1];
            matReqs[0].RecordTypeId = projMatRqId;
            matReqs[0].Contact__c = conList[0].Id;
            matReqs[0].Location__c = locations[0].Id;
            update matReqs[0];
            
            System.runAs(user) {
                try{
                    LibrarySearchController.materialRequestBasedonFilter('Project_Materials_Request', 'Ordered', supr[0].Id, conList[0].Id, locations[0].Id);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover materialRequestBasedonFilter() method
    private static testMethod void myTest11(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<Contact> supr = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' AND LastName='StaffContact' LIMIT 1];
        System.debug('conList==='+conList);
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = supr[0].Id;
            conAss[0].Assignment_Position__c = 'Project Manager';
            update conAss[0]; 
                
            Id projMatRqId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Project_Materials_Request').getRecordTypeId();
            List<MTT_Location__c> locations = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
            
            List<Materials_Request__c> matReqs = [SELECT Id, RecordTypeId, Contact__c, Location__c FROM Materials_Request__c LIMIT 1];
            matReqs[0].RecordTypeId = projMatRqId;
            matReqs[0].Contact__c = conList[0].Id;
            matReqs[0].Location__c = locations[0].Id;
            update matReqs[0];
            
            System.runAs(user) {
                try{
                    LibrarySearchController.materialRequestBasedonFilter('Material_Loan_Request', 'Ordered', supr[0].Id, conList[0].Id, locations[0].Id);
                    LibrarySearchController.materialRequestBasedonFilter('All', 'Ordered', supr[0].Id, conList[0].Id, locations[0].Id);
                    LibrarySearchController.materialRequestBasedonFilter('Project_Materials_Request', 'Ordered', '', conList[0].Id, locations[0].Id);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover materialRequestBasedonFilter() method
    private static testMethod void myTest12(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<Contact> supr = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' AND LastName='StaffContact' LIMIT 1];
        System.debug('conList==='+conList);
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = supr[0].Id;
            conAss[0].Assignment_Position__c = 'Project Manager';
            update conAss[0]; 
                
            Id projMatRqId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Project_Materials_Request').getRecordTypeId();
            List<MTT_Location__c> locations = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
            
            List<Materials_Request__c> matReqs = [SELECT Id, RecordTypeId, Contact__c, Location__c FROM Materials_Request__c LIMIT 1];
            matReqs[0].RecordTypeId = projMatRqId;
            matReqs[0].Contact__c = conList[0].Id;
            matReqs[0].Location__c = locations[0].Id;
            update matReqs[0];
            
            System.runAs(user) {
                try{
                    LibrarySearchController.materialRequestBasedonFilter('Material_Loan_Request', 'Ordered', 'test', conList[0].Id, locations[0].Id);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover updateLoanMRRecords() method
    private static testMethod void myTest13(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            Id loanRqId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Material_Loan_Request').getRecordTypeId();
            List<MTT_Location__c> locations = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
            
            List<Materials_Request__c> matReqs = [SELECT Id, RecordTypeId, Contact__c, Location__c FROM Materials_Request__c LIMIT 1];
            matReqs[0].RecordTypeId = loanRqId;
            matReqs[0].Contact__c = conList[0].Id;
            matReqs[0].Location__c = locations[0].Id;
            update matReqs[0];
            
            List<Materials_Request__c> loanList = new List<Materials_Request__c>();
            loanList.add(matReqs[0]);
            
            System.runAs(user) {
                try{
                    LibrarySearchController.updateLoanMRRecords(JSON.serialize(loanList));
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover updateForallObjects() method
    private static testMethod void myTest14(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
            List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
            
            List<Favourite_Material__c> favMaterials = new List<Favourite_Material__c>{
            
                new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[0].Id, ContentVersion_Id__c = contentVersions[0].Id),
                new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[1].Id, ContentVersion_Id__c = contentVersions[0].Id)
            };
            insert favMaterials;
             
            System.runAs(user) {
                try{
                    LibrarySearchController.updateForallObjects(JSON.serialize(favMaterials), 'Favourite_Material__c');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover updateForallObjects() method
    private static testMethod void myTest15(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Material_Rating__c> matRatings = [SELECT Id FROM Material_Rating__c];
             
            System.runAs(user) {
                try{
                    LibrarySearchController.updateForallObjects(JSON.serialize(matRatings), 'Material_Rating__c');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover updateForallObjects() method
    private static testMethod void myTest16(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Request__c> reqs = [SELECT Id FROM Request__c];
             
            System.runAs(user) {
                try{
                    LibrarySearchController.updateForallObjects(JSON.serialize(reqs), 'Request__c');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover updateForallObjects() method
    private static testMethod void myTest17(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
             
            System.runAs(user) {
                try{
                    LibrarySearchController.updateForallObjects(JSON.serialize(contentVersions), 'ContentVersion');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover updateForallObjects() method
    private static testMethod void myTest18(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
            
            System.runAs(user) {
                try{
                    LibrarySearchController.updateForallObjects(JSON.serialize(materials), 'Materials__c');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover updateForallObjects() method
    private static testMethod void myTest19(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
            List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
            
            List<Favourite_Material__c> favMaterials = new List<Favourite_Material__c>{
            
                new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[0].Id, ContentVersion_Id__c = contentVersions[0].Id),
                new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[1].Id, ContentVersion_Id__c = contentVersions[0].Id)
            };
            insert favMaterials;
            
            List<Favourite_Material__c> favMaterials1 = [SELECT Id FROM Favourite_Material__c WHERE Id IN :favMaterials];
            favMaterials1[0].Id = null;
            favMaterials1[1].Id = null;
            
            System.runAs(user) {
                try{
                    LibrarySearchController.updateForallObjects(JSON.serialize(favMaterials1), 'Favourite_Material__c');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover deleteForallObjects() method
    private static testMethod void myTest20(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
            List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
            
            List<Favourite_Material__c> favMaterials = new List<Favourite_Material__c>{
            
                new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[0].Id, ContentVersion_Id__c = contentVersions[0].Id),
                new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[1].Id, ContentVersion_Id__c = contentVersions[0].Id)
            };
            insert favMaterials;
             
            System.runAs(user) {
                try{
                    LibrarySearchController.deleteForallObjects(JSON.serialize(favMaterials), 'Favourite_Material__c');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover deleteForallObjects() method
    private static testMethod void myTest21(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Material_Rating__c> matRatings = [SELECT Id FROM Material_Rating__c];
             
            System.runAs(user) {
                try{
                    LibrarySearchController.deleteForallObjects(JSON.serialize(matRatings), 'Material_Rating__c');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover deleteForallObjects() method
    private static testMethod void myTest22(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            Id loanRqId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Material_Loan_Request').getRecordTypeId();
            List<MTT_Location__c> locations = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
            
            List<Materials_Request__c> matReqs = [SELECT Id, RecordTypeId, Contact__c, Location__c FROM Materials_Request__c LIMIT 1];
            matReqs[0].RecordTypeId = loanRqId;
            matReqs[0].Contact__c = conList[0].Id;
            matReqs[0].Location__c = locations[0].Id;
            update matReqs[0];
            
            List<Materials_Request__c> loanList = new List<Materials_Request__c>();
            loanList.add(matReqs[0]);
            
            System.runAs(user) {
                try{
                    LibrarySearchController.deleteForallObjects(JSON.serialize(loanList), 'Materials_Request__c');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover deleteForallObjects() method
    private static testMethod void myTest23(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
            List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
            
            List<Favourite_Material__c> favMaterials = new List<Favourite_Material__c>{
            
                new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[0].Id, ContentVersion_Id__c = contentVersions[0].Id),
                new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[1].Id, ContentVersion_Id__c = contentVersions[0].Id)
            };
            insert favMaterials;
            
            List<Favourite_Material__c> favMaterials1 = [SELECT Id FROM Favourite_Material__c WHERE Id IN :favMaterials];
            favMaterials1[0].Id = null;
            favMaterials1[1].Id = null;
            
            System.runAs(user) {
                try{
                    LibrarySearchController.deleteForallObjects(JSON.serialize(favMaterials1), 'Favourite_Material__c');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover getCommunityHomePageDetails() method
    private static testMethod void myTest24(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
                   
            System.runAs(user) {
                try{
                    LibrarySearchController.getCommunityHomePageDetails();
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover getCommunityHomePageDetails() method
    private static testMethod void myTest25(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
        
        List<Favourite_Material__c> favMaterials = new List<Favourite_Material__c>{
            
            new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[0].Id, ContentVersion_Id__c = contentVersions[0].Id),
            new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[1].Id, ContentVersion_Id__c = contentVersions[0].Id)
        };
        insert favMaterials;
        
        Test.startTest();
        
            List<Material_Rating__c> matRatings = [SELECT Id, Ratings__c FROM Material_Rating__c];
            matRatings[0].Contact__c = conList[0].Id;
            matRatings[0].Rating__c = '5';
            update matRatings[0];
            
            Id loanRqId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Material_Loan_Request').getRecordTypeId();
            List<MTT_Location__c> locations = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
            
            List<Materials_Request__c> matReqs = [SELECT Id, RecordTypeId, Contact__c, Location__c FROM Materials_Request__c LIMIT 1];
            matReqs[0].RecordTypeId = loanRqId;
            matReqs[0].Contact__c = conList[0].Id;
            matReqs[0].Location__c = locations[0].Id;
            update matReqs[0];
                       
            System.runAs(user) {
                try{
                    LibrarySearchController.getCommunityHomePageDetails();
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getDigitalContentsByText() method
    private static testMethod void myTest26(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
                
        Test.startTest();
            
            System.runAs(user) {
                try{
                    LibrarySearchController.getDigitalContentsByText('test', 'Other', 'Other', 'Other', 'Other', 'Most Requested',null,null);
                    LibrarySearchController.getDigitalContentsByText('test string', '', '', '', '', 'Newest',null,null);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getDigitalContentsByText() method
    private static testMethod void myTest26a(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
                
        Test.startTest();
            
            System.runAs(user) {
                try{
                    LibrarySearchController.getDigitalContentsByText('test', 'Other', 'Other', 'Other', 'Other', 'Top Rated',null,null);
                    LibrarySearchController.getDigitalContentsByText('test', 'Other', 'Other', 'Other', 'Other', 'Most Favorited',1,15);
                    LibrarySearchController.getDigitalContentsByText('test string', '', '', '', '', 'Alphabetical',null,null);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getDigitalContentsByText() method
    private static testMethod void myTest27(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
                
        Test.startTest();
            
            System.runAs(user) {
                try{
                    LibrarySearchController.getDigitalContentsByText('test +{', 'Other', 'Other', 'Other', 'Other', 'Top Rated',null,null);
                    LibrarySearchController.getDigitalContentsByText('test', 'Other', 'Other', 'Other', 'Other', 'Top Rated',null,null);
                    LibrarySearchController.getDigitalContentsByText('test', '', '', '', '', 'Alphabetical',null,null);
                    LibrarySearchController.getDigitalContentsByText('test', '', '', '', '', 'Most Favorited',null,null);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover parseCSVString() method
    private static testMethod void myTest28(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
                
        Test.startTest();
            
            System.runAs(user) {
                try{
                    LibrarySearchController.parseCSVString('"test, test, test"');
                    LibrarySearchController.parseCSVString('"test, test, test');
                    LibrarySearchController.parseCSVString('test, test, test"');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover parseCSVString() method
    private static testMethod void myTest29(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
                
        Test.startTest();
            
            System.runAs(user) {
                try{
                    LibrarySearchController.parseCSVString('"test, test, test"');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getMaterialsByText() method
    private static testMethod void myTest30(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
        
        Test.startTest();
            
            System.runAs(user) {
                try{
                    LibrarySearchController.getMaterialsByText('test', 'Other', 'Other', 'Other', 'Other', 'Top Rated', 'Other', 'Other',1,15);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getMaterialsByText() method
    private static testMethod void myTest31(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
        
        Test.startTest();
            
            System.runAs(user) {
                try{
                    LibrarySearchController.getMaterialsByText('test+ test', 'Other', 'Other', 'Other', 'Other', 'Top Rated', 'Other', 'Other',null,null);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getMaterialsByText() method
    private static testMethod void myTest32(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
        
        Test.startTest();
            
            System.runAs(user) {
                try{
                    LibrarySearchController.getMaterialsByText('test', 'Other', 'Other', 'Other', 'Other', 'Most Favorited', 'Other', 'Other',null,null);
                    LibrarySearchController.getMaterialsByText('test', '', '', '', '', 'Most Requested', '', '',null,null);
                    LibrarySearchController.getMaterialsByText('test', '', '', '', '', 'Newest', '', '',null,null);
                    LibrarySearchController.getMaterialsByText('test', '', '', '', '', 'Alphabetical', '', '',null,null);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getDigitalContentsWithoutText() method
    private static testMethod void myTest33(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
        
        Test.startTest();
            
            System.runAs(user) {
                try{
                    LibrarySearchController.getDigitalContentsWithoutText('', '', '', '','Top Rated',null,null);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getDigitalContentsWithoutText() method
    private static testMethod void myTest34(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
        
        Test.startTest();
            
            System.runAs(user) {
                try{
                    LibrarySearchController.getDigitalContentsWithoutText('Other', 'Other', 'Other', 'Other','Most Requested',null,null);
                    LibrarySearchController.getDigitalContentsWithoutText('Other', 'Other', 'Other', 'Other','Newest',null,null);
                    LibrarySearchController.getDigitalContentsWithoutText('Other', 'Other', 'Other', 'Other','Alphabetical',null,null);
                    LibrarySearchController.getDigitalContentsWithoutText('Other', 'Other', 'Other', 'Other','Most Favorited',null,null);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getMaterialsWithoutText() method
    private static testMethod void myTest35(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
        
        Test.startTest();
            
            System.runAs(user) {
                try{
                    LibrarySearchController.getMaterialsWithoutText('', '', '', '','Top Rated', '', '',null,null);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getMaterialsWithoutText() method
    private static testMethod void myTest36(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
        
        Test.startTest();
            
            System.runAs(user) {
                try{
                    LibrarySearchController.getMaterialsWithoutText('Other', 'Other', 'Other', 'Other','Most Requested', 'Other', 'Other',null,null);
                    LibrarySearchController.getMaterialsWithoutText('Other', 'Other', 'Other', 'Other','Newest', 'Other', 'Other',null,null);
                    LibrarySearchController.getMaterialsWithoutText('Other', 'Other', 'Other', 'Other','Alphabetical', 'Other', 'Other',null,null);
                    LibrarySearchController.getMaterialsWithoutText('Other', 'Other', 'Other', 'Other','Most Favorited', 'Other', 'Other',null,null);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getContentVersionAllDetails() method
    private static testMethod void myTest37(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;
        System.debug('p=========='+p);
                
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                //ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='testertest3@noemail.com');
       
        insert user;        
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
        
        Test.startTest();
            
            System.runAs(user) {
                conList[0].DLS_User__c = UserInfo.getUserId();
                update conList[0];
                
                try{
                    LibrarySearchController.getContentVersionAllDetails('Internal', contentVersions[0].Id);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getContentVersionAllDetails() method
    private static testMethod void myTest38(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        
        
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
        
        Test.startTest();
            
            System.runAs(user) {
                
                try{
                    LibrarySearchController.getContentVersionAllDetails('Student', contentVersions[0].Id);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover createForallObjects() method
    private static testMethod void myTest39(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
            List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
            
            List<Favourite_Material__c> favMaterials = new List<Favourite_Material__c>{
            
                new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[0].Id, ContentVersion_Id__c = contentVersions[0].Id),
                new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[1].Id, ContentVersion_Id__c = contentVersions[0].Id)
            };
             
            System.runAs(user) {
                try{
                    LibrarySearchController.createForallObjects(JSON.serialize(favMaterials), 'Favourite_Material__c');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover createForallObjects() method
    private static testMethod void myTest40(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Materials__c> MaterialsList = [SELECT Id FROM Materials__c LIMIT 2];
            List<ContentVersion> contentList = [SELECT Id FROM ContentVersion LIMIT 2];
            
            List<Material_Rating__c> rateList = new List<Material_Rating__c>{
                new Material_Rating__c(ContentVersionId__c=contentList[0].Id, Rating__c = '4', Material_Name__c = MaterialsList[0].Id),
                new Material_Rating__c(ContentVersionId__c=contentList[1].Id, Rating__c = '4', Material_Name__c = MaterialsList[0].Id)
            };
             
            System.runAs(user) {
                try{
                    LibrarySearchController.createForallObjects(JSON.serialize(rateList), 'Material_Rating__c');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover createForallObjects() method
    private static testMethod void myTest41(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Materials__c> MaterialsList = [SELECT Id FROM Materials__c LIMIT 2];
            List<ContentVersion> contentList = [SELECT Id FROM ContentVersion LIMIT 2];
            
            List<Request__c> reqList = new List<Request__c>{
                new Request__c(ContentVersionId__c=contentList[0].Id),
                new Request__c(ContentVersionId__c=contentList[1].Id)
            };
             
            System.runAs(user) {
                try{
                    LibrarySearchController.createForallObjects(JSON.serialize(reqList), 'Request__c');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover createForallObjects() method
    private static testMethod void myTest42(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Materials__c> MaterialsList = [SELECT Id FROM Materials__c LIMIT 2];
            List<ContentVersion> contentList = [SELECT Id FROM ContentVersion LIMIT 2];
            
            List<Request__c> reqList = new List<Request__c>{
                new Request__c(ContentVersionId__c=contentList[0].Id),
                new Request__c(ContentVersionId__c=contentList[1].Id)
            };
            insert reqList;
            
            System.runAs(user) {
                try{
                    LibrarySearchController.createForallObjects(JSON.serialize(reqList), 'Request__c');
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover getMeterialRelatedAllInfo() method
    private static testMethod void myTest43(){

        Id p = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;
        System.debug('p=========='+p);
                
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                //ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='testertest2@noemail.com');
       
        insert user;        
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        List<Materials__c> materialsList = [SELECT Id FROM Materials__c LIMIT 2];
        
        Test.startTest();
            
            System.runAs(user) {
                conList[0].DLS_User__c = UserInfo.getUserId();
                update conList[0];
                
                try{
                    LibrarySearchController.getMeterialRelatedAllInfo('Internal', materialsList[0].Id);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getMeterialRelatedAllInfo() method
    private static testMethod void myTest44(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        
        
        List<Materials__c> materialsList = [SELECT Id FROM Materials__c LIMIT 2];
        
        Test.startTest();
            
            System.runAs(user) {
                
                try{
                    LibrarySearchController.getMeterialRelatedAllInfo('Student', materialsList[0].Id);
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getMeterialRelatedAllInfo() method
    private static testMethod void myTest45(){
    
        
        List<Materials__c> materialsList = [SELECT Id FROM Materials__c LIMIT 2];
        try{
            LibrarySearchController.getMeterialRelatedAllInfo('Internal', materialsList[0].Id);
        }catch(Exception e){
            System.debug('====='+e.getMessage());
        }
    }
    
    // To cover getFavoriteMaterialsInfo() method
    private static testMethod void myTest46(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
            List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
            
            List<Favourite_Material__c> favMaterials = new List<Favourite_Material__c>{
            
                new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[0].Id, ContentVersion_Id__c = contentVersions[0].Id),
                new Favourite_Material__c(Contact__c = conList[0].Id, Material_Name__c = materials[1].Id, ContentVersion_Id__c = contentVersions[0].Id)
            };
            insert favMaterials;
            
            System.runAs(user) {
                try{
                    List<Materials__c> mat = LibrarySearchController.getFavoriteMaterialsInfo();
                    System.assertEquals(materials.size(), mat.size());
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover getTopRatedMaterialsInfo() method
    private static testMethod void myTest47(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;        
        
        Test.startTest();
        
            List<Materials__c> MaterialsList = [SELECT Id FROM Materials__c LIMIT 2];
            List<ContentVersion> contentList = [SELECT Id FROM ContentVersion LIMIT 2];
            
            List<Material_Rating__c> rateList = new List<Material_Rating__c>{
                new Material_Rating__c(ContentVersionId__c=contentList[0].Id, Rating__c = '5', Material_Name__c = MaterialsList[0].Id),
                new Material_Rating__c(ContentVersionId__c=contentList[1].Id, Rating__c = '7', Material_Name__c = MaterialsList[0].Id)
            };
            insert rateList;
            
            System.runAs(user) {
                try{
                    List<Materials__c> mat = LibrarySearchController.getTopRatedMaterialsInfo();
                }catch(Exception e){
                    System.debug('====='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // To cover upsertLoanMRRecords() method
    private static testMethod void myTest48(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;     
        
        Test.startTest();
        
            Id matTransRqId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Material_Transfer').getRecordTypeId();
        
            List<Account> acc = [SELECT Id FROM Account LIMIT 1];
            
            List<AcctSeed__Project__c> projs = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
            
            List<Materials_Request__c> matReqs = [SELECT Id, Project__c, RecordtypeId, Vendor_Name__c FROM Materials_Request__c LIMIT 1];
            matReqs[0].Vendor_Name__c =acc[0].Id;
            matReqs[0].Project__c = projs[0].Id;
            matReqs[0].RecordtypeId = matTransRqId;
            update matReqs[0];
            
            System.runAs(user) {
            
                String s = LibrarySearchController.upsertLoanMRRecords(matReqs[0].Id, projs[1].Id);
                System.assertEquals(s, 'SUCCESS');
            }
            
        Test.stopTest();
    }
    
    // To cover upsertLoanMRRecords() method
    private static testMethod void myTest48a(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;     
        
        Test.startTest();
        
            Id matTransRqId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Material_Transfer').getRecordTypeId();
        
            List<Account> acc = [SELECT Id FROM Account LIMIT 1];
            
            List<AcctSeed__Project__c> projs = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
            
            List<Materials_Request__c> matReqs = [SELECT Id, Project__c, RecordtypeId, Vendor_Name__c FROM Materials_Request__c LIMIT 1];
            matReqs[0].Vendor_Name__c =acc[0].Id;
            matReqs[0].Project__c = projs[0].Id;
            matReqs[0].RecordtypeId = matTransRqId;
            update matReqs[0];
            
            System.runAs(user) {
            
                try{
                    LibrarySearchController.upsertLoanMRRecords(matReqs[0].Id, 'test');
                }catch(Exception e){
                    Boolean isError = e.getMessage().contains('Script-thrown exception') ? true : false;
                    System.AssertEquals(isError, true);
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getInstructorProjects() method
    private static testMethod void myTest49(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Instructor_Access__c  = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;     
        
        Test.startTest();
                
                List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c IN ('Planned','Active') AND Project__r.AcctSeed__Status__c IN ('Order','Active')];
                conAss[0].Candidate_Name__c = conList[0].Id;
                update conAss[0]; 
                
                List<AcctSeed__Project__c> projs = [SELECT Id, Name, DLS_Class__c FROM AcctSeed__Project__c WHERE Id =:conAss[0].Project__c];
                
            System.runAs(user) {
            
                String s = LibrarySearchController.getInstructorProjects(conList[0].Id);
                System.AssertEquals(s, JSON.serialize(projs));
            }
            
        Test.stopTest();
    }
}