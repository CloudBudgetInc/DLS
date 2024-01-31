@isTest
private class DailyTimeEntryEmailToUAEInstructor_Test{

    @testSetup static void setupMethod(){
    
        List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        List<System_Values__c> sysVa = TestClassUtil.createSystemValues();
        
        Test.startTest();
            List<AcctSeed__Time_Card_Day__c> days = TestClassUtil.createTestTimeCardDay();
        Test.stopTest();
    }
    
    private static testMethod void sendEmailToUAEIns1(){
        
        Id canRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Contact con = new Contact(LastName = 'My test con', Active_DLS_Online_User__c = TRUE, RecordTypeId = canRTId, Email = 'mytestcon@gmail.com');
        insert con;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Id = :con.Id];
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            update conAss[0]; 
                
            Id eflRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            proj[0].RecordTypeId = eflRTId;
            update proj[0];
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            DailyTimeEntryEmailToUAEInstructor sch = new DailyTimeEntryEmailToUAEInstructor();
            system.schedule('Daily Time Entry Email To UAE Instructor', CRON_EXP, sch);
        Test.stopTest();    
    }
    
    private static testMethod void sendEmailToUAEIns2(){
    
        Id canRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Contact con = new Contact(LastName = 'My test con', Active_DLS_Online_User__c = TRUE, RecordTypeId = canRTId, Email = 'mytestcon@gmail.com');
        insert con;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Id = :con.Id];
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            update conAss[0]; 
                
            Id eflRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            proj[0].RecordTypeId = eflRTId;
            update proj[0];
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :proj[0].Id LIMIT 1];
            
            List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
            update timeCard;
        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = proj[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
        
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            DailyTimeEntryEmailToUAEInstructor sch = new DailyTimeEntryEmailToUAEInstructor();
            system.schedule('Daily Time Entry Email To UAE Instructor', CRON_EXP, sch);
        Test.stopTest();    
    }
}