@isTest
private class ClassLeaderAssignmentNotification_Test{

    @testSetup static void setupMethod(){
    
        List<Schedule__c> scheduleRecs = TestClassUtil.createTestSchedule();
        
        Test.startTest();
            List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
    }
    
    private static testMethod void myTest1(){
    
        List<Schedule__c> scheduleRecs = [SELECT Id, Project__c, Start_Date__c
                                                    FROM Schedule__c 
                                                    WHERE Status__c = 'Active' LIMIT 1];
        scheduleRecs[0].Start_Date__c = Date.Today().addDays(-1);
        update scheduleRecs[0];
        
        Account a = new Account(Name = 'Test Account');
        insert a;
        
        Contact con = new Contact();
        con.FirstName = UserInfo.getFirstName();
        con.LastName = UserInfo.getLastName();
        con.Email = UserInfo.getUserEmail();
        con.AccountId = a.Id;
        insert con;
        
        List<AcctSeed__Project__c> proj = [SELECT Id, Project_Manager__c FROM AcctSeed__Project__c WHERE Id = :scheduleRecs[0].Project__c];
        proj[0].Project_Manager__c = UserInfo.getUserId();
        update proj[0];
        
        Test.startTest();
        
            ClassLeaderAssignmentNotification_Sch  sch2 = new ClassLeaderAssignmentNotification_Sch(); 
            String sch = '0 0 14 * * ?'; 
            system.schedule('ClassLeaderAssignmentNotification',sch,sch2);
            
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
        List<Schedule__c> scheduleRecs = [SELECT Id, Project__c, Start_Date__c
                                                    FROM Schedule__c 
                                                    WHERE Status__c = 'Active' LIMIT 1];
        scheduleRecs[0].Start_Date__c = Date.Today().addDays(-1);
        update scheduleRecs[0];
        
        Account a = new Account(Name = 'Test Account');
        insert a;
        
        Contact con = new Contact();
        con.FirstName = UserInfo.getFirstName();
        con.LastName = UserInfo.getLastName();
        con.Email = UserInfo.getUserEmail();
        con.AccountId = a.Id;
        insert con;
        
        List<AcctSeed__Project__c> proj = [SELECT Id, Project_Manager__c FROM AcctSeed__Project__c WHERE Id = :scheduleRecs[0].Project__c];
        proj[0].Project_Manager__c = UserInfo.getUserId();
        update proj[0];
        
        List<Contact_Assignments__c> conAsign = [SELECT Id, Assignment_Position__c FROM Contact_Assignments__c WHERE Project__c = :scheduleRecs[0].Project__c AND RecordType.DeveloperName = 'Student'];
        conAsign[0].Assignment_Position__c = 'Class Leader';
        update conAsign[0];
            
        Test.startTest();
        
            ClassLeaderAssignmentNotification_Sch  sch2 = new ClassLeaderAssignmentNotification_Sch(); 
            String sch = '0 0 14 * * ?'; 
            system.schedule('ClassLeaderAssignmentNotification',sch,sch2);
            
        Test.stopTest();
    }
}