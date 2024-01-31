@isTest
private class ListViewControllerTest{

    @testSetup static void setupMethod(){
    
        List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
        Test.startTest();
            List<Schedule__c> schedules = TestClassUtil.createTestScheduleWithOpportunity();
        Test.stopTest();
    }
    
    //Cover getProjectList method with communityName = 'Instructor'
    private static testMethod void testMethod1(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
                
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            System.debug('projects========'+projects);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
                                 
            system.runAs(user) {
            
                try{
                    String res = ListViewController.getProjectList();                                
                }catch(Exception e){
                
                    System.debug('EXception===='+e.getMessage());
                }
            }
        Test.stopTest();
    }

    //Cover getScheduleList method 
    private static testMethod void testMethod2(){
    
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
      
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            System.debug('projects========'+projects);
                
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
                      
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
            schList[0].Status__c = 'Active';
            schList[0].Project__c = task[0].AcctSeed__Project__c;
            schList[0].Project_Task__c = task[0].Id;
            schList[0].Start_Date__c = weekStart1;
            schList[0].End_Date__c = WeekEnd1;
            update schList;
            System.debug('schList===='+schList);
                       
            system.runAs(user) {
            
                try{
                    String res = ListViewController.getScheduleList(new List<String>{}, new List<String>{});                
                }catch(Exception e){
                
                    System.debug('EXception===='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    //Cover getSchedule method 
    private static testMethod void testMethod3(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            System.debug('projects========'+projects);
                
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
                      
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
            schList[0].Status__c = 'Active';
            schList[0].Project__c = task[0].AcctSeed__Project__c;
            schList[0].Project_Task__c = task[0].Id;
            schList[0].Start_Time__c = '06:15 AM';
            schList[0].End_Time__c = '06:45 AM';
            update schList;
            System.debug('schList===='+schList);
                       
            system.runAs(user) {
            
                try{
                    String res = ListViewController.getSchedule(task[0].AcctSeed__Project__c, 'Active');                
                }catch(Exception e){
                
                    System.debug('EXception===='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    //Cover getProjectRecord method 
    private static testMethod void testMethod4(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
                
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            System.debug('projects========'+projects);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
                              
            system.runAs(user) {
            
                try{
                    String res = ListViewController.getProjectRecord(task[0].AcctSeed__Project__c);                
                    
                }catch(Exception e){
                
                    System.debug('EXception===='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    //Cover getProjectRecord method 
    private static testMethod void testMethod4a(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
      
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
                
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            System.debug('projects========'+projects);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
                              
            system.runAs(user) {
            
                try{
                    String res = ListViewController.getProjectRecord('Test');                
                }catch(Exception e){
                
                    System.debug('EXception===='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    //Cover getSchduleRecord method 
    private static testMethod void testMethod5(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
                
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            System.debug('projects========'+projects);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
                      
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
            schList[0].Status__c = 'Active';
            schList[0].Project__c = task[0].AcctSeed__Project__c;
            schList[0].Project_Task__c = task[0].Id;
            schList[0].Start_Time__c = '06:15 AM';
            schList[0].End_Time__c = '06:45 AM';
            update schList;
            System.debug('schList===='+schList);
                    
            system.runAs(user) {
            
                try{
                    String res = ListViewController.getSchduleRecord(schList[0].Id);                
                }catch(Exception e){
                
                    System.debug('EXception===='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    //Cover getSchduleRecord method 
    private static testMethod void testMethod5a(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
      
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            update conAss[0]; 
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            System.debug('projects========'+projects);
            
            system.runAs(user) {
            
                try{
                    String res = ListViewController.getSchduleRecord('test');                
                }catch(Exception e){
                
                    System.debug('EXception===='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    //Cover getScheduleByFilter method 
    private static testMethod void testMethod6(){
    
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
                
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            System.debug('projects========'+projects);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
                      
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
            schList[0].Status__c = 'Active';
            schList[0].Project__c = task[0].AcctSeed__Project__c;
            schList[0].Project_Task__c = task[0].Id;
            schList[0].Start_Date__c = weekStart1;
            schList[0].End_Date__c = WeekEnd1;
            update schList;
            System.debug('schList===='+schList);
                       
            system.runAs(user) {
            
                try{
                    String res = ListViewController.getScheduleByFilter(task[0].AcctSeed__Project__c, new List<String>{schList[0].Status__c}, new List<String>{task[0].Project_Task_Type__c});                
                }catch(Exception e){
                
                    System.debug('EXception===='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    //Cover getScheduleByFilter method 
    private static testMethod void testMethod6a(){
    
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
      
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
                
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            System.debug('projects========'+projects);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
                      
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
            schList[0].Status__c = 'Active';
            schList[0].Project__c = task[0].AcctSeed__Project__c;
            schList[0].Project_Task__c = task[0].Id;
            schList[0].Start_Date__c = weekStart1;
            schList[0].End_Date__c = WeekEnd1;
            update schList;
            System.debug('schList===='+schList);
                       
            system.runAs(user) {
            
                try{
                    String res = ListViewController.getScheduleByFilter('All', new List<String>{schList[0].Status__c}, new List<String>{});                
                }catch(Exception e){
                
                    System.debug('EXception===='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    //Cover getCommunityName method 
    private static testMethod void testMethod7(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            try{
            
                ListViewController.getCommunityName();                
                
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        Test.stopTest();
    }
    
    private static testMethod void testMethodForGetPolicyDetails(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
      
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Policies_and_Procedure_Box_Share_URL__c = 'box.com/testshareablelink';
            update conAss[0]; 
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            System.debug('projects========'+projects);
            
            system.runAs(user) {
            
                try{
                    List<Contact_Assignments__c> con = ListViewController.getPolicyAndCertificateDetails(proj[0].Id);                
                }catch(Exception e){
                
                    System.debug('EXception===='+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    //Cover payloadConstructionMethod method 
    private static testMethod void testMethod9(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            update conAss[0]; 
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            
            system.runAs(user) {
            
                try{
                    string endUrl = ListViewController.payloadConstructionMethod(proj[0].DLS_Class__c,proj[0].Id);                
                }catch(Exception e){
                
                    System.debug('EXception===='+e.getMessage());
                }
            }
            
        Test.stopTest();
    }
    
    private static testMethod void scheduleRecordsFormation_Test(){
        
        List<Schedule__c> schRec = [SELECt Id, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 1];
        schRec[0].Start_Time__c = '09:00 AM';
        schRec[0].End_Time__c = '10:00 AM';
        update schRec[0];
        
        List<Schedule__c> schList = [SELECT Id, Name, Days__c, DLS_Ref__c, Start_Date__c, End_Date__c, 
            Timezone__c, Start_Time__c, End_Time__c, Status__c, Project_Task__r.Name, Project_Task__r.Project_Task_Type__c, 
            Instructor__r.Name, Room__r.Name, Hours_Planned__c, Total_Hours__c, Project_Task__r.Unit__c, Total_Hours_per_Session__c  
        FROM Schedule__c 
        WHERE Id = :schRec[0].Id LIMIT 1];
        
        
        ScheduleTranslator.scheduleRecordsFormation(schList);
    }
    private static testMethod void getLanguageTestingRecords_Test(){
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c LIMIT 1];
        if(proj.size() > 0){
            ListViewController.getLanguageTestingRecords(proj[0].Id);
        }
    }
}