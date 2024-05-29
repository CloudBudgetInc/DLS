@isTest
private class ExistingRecords_UpdationBatch_Test{
    
    @testSetup static void setupMethod(){
        
        //Insert Paper Timesheet custom setting
        List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'True')};
        Insert sysVal;
        
        List<AcctSeed__Project_Task__c> projtasks = TestClassUtil.createTestProjectTask();
    } 
    
    // Exp updation with End Date = null
    private static testMethod void myTest1(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),01);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Create Exp Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', Total_Qty_Planned__c = 100);
        insert projTask;
        
        List<Schedule__c> schList = new List<Schedule__c> {
            new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = cons[0].Id)
            
        };
        insert schList;
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id, Candidate_Name__c = cons[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
        };
            
        insert conAssignRecs;
        
        // CA insertion created Experience record
        List<Experience__c> expRecs = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, expRecs.size() > 0);
        expRecs[0].End_Date__c = projED;
        update expRecs[0];
                        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> updatedExp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(null, updatedExp[0].End_Date__c);
    }
    
    // Exp Creation for non testing project with Instructor Position (Ended Map)
    private static testMethod void myTest2(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                
        List<AcctSeed__Project__c> projRec = [SELECT Id FROM AcctSeed__Project__c WHERE RecordTypeId = :lTProjRTId LIMIT 1];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[0].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-30), End_Date__c = Date.Today().addDays(-1), Opportunity_Name__c = opp[0].Id,Status__c = 'Ended', Assignment_Position__c = 'Instructor')
        };
            
        insert conAssignRecs;
        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
    
    // Exp Creation for testing project with Instructor Position (Ended Map - CA.End_Date__c not null)
    private static testMethod void myTest3(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id testProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                
        List<AcctSeed__Project__c> projRec = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        projRec[0].RecordTypeId = testProjRTId;
        update projRec[0];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[0].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-30), End_Date__c = Date.Today().addDays(-1), Opportunity_Name__c = opp[0].Id,Status__c = 'Ended', Assignment_Position__c = 'Instructor')
        };
            
        insert conAssignRecs;
        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
    
    // Exp Creation for testing project with Instructor Position (Ended Map - CA.Oral_Exam_Date_Time__c not null)
    private static testMethod void myTest4(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id testProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        List<AcctSeed__Project__c> projRec = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        projRec[0].RecordTypeId = testProjRTId;
        update projRec[0];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[0].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-30), End_Date__c = Date.Today().addDays(-30), Oral_Exam_Date_Time__c = Date.Today().addDays(-30), Opportunity_Name__c = opp[0].Id,Status__c = 'Ended', Assignment_Position__c = 'Instructor')
        };
            
        insert conAssignRecs;
        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
    
    // Exp Creation for testing project with Instructor Position (Ended Map - CA.End_Date__c not null)
    private static testMethod void myTest5(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id testProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        AcctSeed__Project__c projRec = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Create Exp Test Project 5',AcctSeed__Status__c = 'Active',RecordTypeId = testProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Oral_Exam_Date_Time__c = Date.Today().addDays(-30));
        insert projRec;
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec.Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-30), End_Date__c = Date.Today().addDays(-30), Opportunity_Name__c = opp[0].Id,Status__c = 'Ended', Assignment_Position__c = 'Instructor')
        };
        insert conAssignRecs;
        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
    
    // Exp Creation for non testing project with Tester Position (Ended Map)
    private static testMethod void myTest6(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                
        List<AcctSeed__Project__c> projRec = [SELECT Id FROM AcctSeed__Project__c WHERE RecordTypeId = :lTProjRTId LIMIT 1];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[0].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-30), End_Date__c = Date.Today().addDays(-1), Opportunity_Name__c = opp[0].Id,Status__c = 'Ended', Assignment_Position__c = 'Tester')
        };
            
        insert conAssignRecs;
        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
    
    // Exp Creation for non testing project with Instructor Position (Ended and On Hold Map)
    private static testMethod void myTest7(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                
        List<AcctSeed__Project__c> projRec = [SELECT Id FROM AcctSeed__Project__c WHERE RecordTypeId = :lTProjRTId LIMIT 2];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[0].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-30), End_Date__c = Date.Today().addDays(-1), Opportunity_Name__c = opp[0].Id,Status__c = 'Ended', Assignment_Position__c = 'Instructor'),
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[1].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-30), End_Date__c = Date.Today().addDays(-2), Opportunity_Name__c = opp[0].Id,Status__c = 'On Hold', Assignment_Position__c = 'Instructor')
        };
            
        insert conAssignRecs;
        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
    
    // Exp Creation for testing project with Tester Position (Ended and On Hold Map - CA.Oral_Exam_Date_Time__c not null)
    private static testMethod void myTest8(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id testingProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                
        List<AcctSeed__Project__c> updateProjs = new List<AcctSeed__Project__c>();
        
        List<AcctSeed__Project__c> projRec = [SELECT Id FROM AcctSeed__Project__c  LIMIT 2];
        for(AcctSeed__Project__c p : projRec){
            p.RecordTypeId = testingProjRTId;
            updateProjs.add(p);
        }
        update updateProjs;
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[0].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-1), End_Date__c = Date.Today().addDays(-1), Oral_Exam_Date_Time__c = Date.Today().addDays(-1), Opportunity_Name__c = opp[0].Id,Status__c = 'Ended', Assignment_Position__c = 'Tester'),
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[1].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-2), End_Date__c = Date.Today().addDays(-2), Oral_Exam_Date_Time__c = Date.Today().addDays(-2), Opportunity_Name__c = opp[0].Id,Status__c = 'On Hold', Assignment_Position__c = 'Tester')
        };
        insert conAssignRecs;
        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
    
    // Exp Creation for testing project with Tester Position (Ended and On Hold Map - Project__r.Oral_Exam_Date_Time__c not null)
    private static testMethod void myTest9(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id testProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                                
        List<AcctSeed__Project__c> insertProjs = new List<AcctSeed__Project__c>{
            new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Create Exp Test Project 9',AcctSeed__Status__c = 'Active',RecordTypeId = testProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Oral_Exam_Date_Time__c = Date.Today().addDays(-2)),
            new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Create Exp Test Project 9a',AcctSeed__Status__c = 'Active',RecordTypeId = testProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Oral_Exam_Date_Time__c = Date.Today().addDays(-3))
        };
        insert insertProjs;
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = insertProjs[0].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-2), End_Date__c = Date.Today().addDays(-2), Opportunity_Name__c = opp[0].Id,Status__c = 'Ended', Assignment_Position__c = 'Tester'),
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = insertProjs[1].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-3), End_Date__c = Date.Today().addDays(-3), Opportunity_Name__c = opp[0].Id,Status__c = 'On Hold', Assignment_Position__c = 'Tester')
        };
        insert conAssignRecs;
        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
    
    // Exp Creation for testing project with Tester Position (Ended and On Hold Map - End_Date__c not null)
    private static testMethod void myTest10(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id testProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                                
        List<AcctSeed__Project__c> insertProjs = new List<AcctSeed__Project__c>{
            new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Create Exp Test Project 10',AcctSeed__Status__c = 'Active',RecordTypeId = testProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id),
            new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Create Exp Test Project 10a',AcctSeed__Status__c = 'Active',RecordTypeId = testProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id)
        };
        insert insertProjs;
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = insertProjs[0].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-2), End_Date__c = Date.Today().addDays(-2), Opportunity_Name__c = opp[0].Id,Status__c = 'Ended', Assignment_Position__c = 'Tester'),
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = insertProjs[1].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-3), End_Date__c = Date.Today().addDays(-3), Opportunity_Name__c = opp[0].Id,Status__c = 'On Hold', Assignment_Position__c = 'Tester')
        };
        insert conAssignRecs;
        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
    
    // Exp Creation for non testing project with Instructor Position (On Hold Map)
    private static testMethod void myTest11(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                
        List<AcctSeed__Project__c> projRec = [SELECT Id FROM AcctSeed__Project__c WHERE RecordTypeId = :lTProjRTId LIMIT 1];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[0].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-30), End_Date__c = Date.Today().addDays(-1), Opportunity_Name__c = opp[0].Id,Status__c = 'On Hold', Assignment_Position__c = 'Instructor')
        };
            
        insert conAssignRecs;
        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
    
    // Exp Updation for non testing project with Instructor Position (Ended Map)
    private static testMethod void myTest12(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                
        List<AcctSeed__Project__c> projRec = [SELECT Id FROM AcctSeed__Project__c WHERE RecordTypeId = :lTProjRTId LIMIT 1];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[0].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-30), End_Date__c = Date.Today().addDays(-1), Opportunity_Name__c = opp[0].Id,Status__c = 'Ended', Assignment_Position__c = 'Instructor')
        };
            
        insert conAssignRecs;
        
        Id profWorkExpRTId = Schema.SObjectType.Experience__c.getRecordTypeInfosByDeveloperName().get('Professional_Work_Experience').getRecordTypeId();
        Experience__c expRec = new Experience__c(Contact__c = cons[0].Id, Name_of_Company__c = 'DLS', RecordTypeId = profWorkExpRTId, 
            Start_Date__c = Date.Today().addDays(-30) , Services__c = 'Language Training', Role_Title__c = 'Language Instructor');
        insert expRec;

        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
    
    // Exp updation for non testing project with Instructor Position (Ended and On Hold Map)
    private static testMethod void myTest13(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                
        List<AcctSeed__Project__c> projRec = [SELECT Id FROM AcctSeed__Project__c WHERE RecordTypeId = :lTProjRTId LIMIT 2];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[0].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-30), End_Date__c = Date.Today().addDays(-1), Opportunity_Name__c = opp[0].Id,Status__c = 'Ended', Assignment_Position__c = 'Instructor'),
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[1].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-30), End_Date__c = Date.Today().addDays(-2), Opportunity_Name__c = opp[0].Id,Status__c = 'On Hold', Assignment_Position__c = 'Instructor')
        };
            
        insert conAssignRecs;
        
        Id profWorkExpRTId = Schema.SObjectType.Experience__c.getRecordTypeInfosByDeveloperName().get('Professional_Work_Experience').getRecordTypeId();
        Experience__c expRec = new Experience__c(Contact__c = cons[0].Id, Name_of_Company__c = 'DLS', RecordTypeId = profWorkExpRTId, 
            Start_Date__c = Date.Today().addDays(-30) , Services__c = 'Language Training', Role_Title__c = 'Language Instructor');
        insert expRec;
        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
    
     // Exp updation for non testing project with Instructor Position (On Hold Map)
    private static testMethod void myTest14(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                
        List<AcctSeed__Project__c> projRec = [SELECT Id FROM AcctSeed__Project__c WHERE RecordTypeId = :lTProjRTId LIMIT 1];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[0].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-30), End_Date__c = Date.Today().addDays(-1), Opportunity_Name__c = opp[0].Id,Status__c = 'On Hold', Assignment_Position__c = 'Instructor')
        };
            
        insert conAssignRecs;
        
        Id profWorkExpRTId = Schema.SObjectType.Experience__c.getRecordTypeInfosByDeveloperName().get('Professional_Work_Experience').getRecordTypeId();
        Experience__c expRec = new Experience__c(Contact__c = cons[0].Id, Name_of_Company__c = 'DLS', RecordTypeId = profWorkExpRTId, 
            Start_Date__c = Date.Today().addDays(-30) , Services__c = 'Language Training', Role_Title__c = 'Language Instructor');
        insert expRec;
        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
    
    // Exp Creation for non testing project with Translator Position (Ended Map)
    private static testMethod void myTest15(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id candRTId = Schema.SObjectType.Contact .getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> cons = new List<Contact>{
            new Contact (RecordTypeId = candRTId, LastName = 'Exp Con 1', Email = 'expcontact1@gmail.com', AccountId = a.Id)
        };
        insert cons;
        
        Id translationProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Translation_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                
        List<AcctSeed__Project__c> projRec = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        projRec[0].RecordTypeId = translationProjRTId;
        update projRec[0];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projRec[0].Id, Candidate_Name__c = cons[0].Id, Start_Date__c = Date.Today().addDays(-30), End_Date__c = Date.Today().addDays(-1), Opportunity_Name__c = opp[0].Id,Status__c = 'Ended', Assignment_Position__c = 'Translator')
        };
            
        insert conAssignRecs;
        
        Test.startTest();     
            Database.executeBatch(new ExistingRecords_UpdationBatch());
        Test.stopTest();
        
        List<Experience__c> exp = [SELECT Id, End_Date__c FROM Experience__c WHERE Contact__c = :cons[0].Id];
        System.assertEquals(True, exp.size() > 0);
    }
}