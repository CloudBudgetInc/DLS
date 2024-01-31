@isTest
private class DLIAttendanceEmailReminder_Test{

    @testSetup static void setupMethod(){
    
        List<Events__c> events = TestClassUtil.createTestEvent();
        
        Test.startTest();
            List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment(); 
        Test.stopTest();
    }
    
    private static testMethod void myTest1(){
    
        List<Events__c> events = [SELECT Project__c 
                                    FROM Events__c 
                                    WHERE Date__c = TODAY AND 
                                        Status__c = 'Scheduled' AND
                                        Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time' LIMIT 1];
        
        Id dliRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
              
        List<AcctSeed__Project__c> proj = [SELECT Id, RecordTypeId FROM AcctSeed__Project__c WHERE Id = :events[0].Project__c];
        proj[0].RecordTypeId = dliRTId;
        update proj[0];
        
        Test.startTest();
        
            List<Contact_Assignments__c> stdConAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Assignment_Position__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            stdConAss[0].Project__c = proj[0].Id;
            stdConAss[0].Assignment_Position__c = 'Class Leader';
            update stdConAss[0];
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            DLIAttendanceEmailReminder sch = new DLIAttendanceEmailReminder();
            system.schedule('DLI Attendance Email Reminder', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    private static testMethod void myTest1a(){
    
        List<Events__c> events = [SELECT Project__c 
                                    FROM Events__c 
                                    WHERE Date__c = TODAY AND 
                                        Status__c = 'Scheduled' AND
                                        Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time' LIMIT 1];
        
        Id dliRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
              
        List<AcctSeed__Project__c> proj = [SELECT Id, RecordTypeId FROM AcctSeed__Project__c WHERE Id = :events[0].Project__c];
        proj[0].RecordTypeId = dliRTId;
        update proj[0];
        
        Id stdConRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Test.startTest();
        
            List<Contact_Assignments__c> stdConAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Assignment_Position__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            stdConAss[0].Project__c = proj[0].Id;
            update stdConAss[0];
            
            List<Contact> stdCon = [SELECT Id, RecordTypeId FROM Contact WHERE Id = :stdConAss[0].Candidate_Name__c];
            stdCon[0].RecordTypeId = stdConRTId;
            update stdCon[0];
            
            Id stdPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Student_Planned_Days_Off').getRecordTypeId();
    
            List<Planned_Days_Off__c> pdos = new List<Planned_Days_Off__c>{
            
                new Planned_Days_Off__c(RecordTypeId = stdPDORTId, Project__c = proj[0].Id, Type__c = 'Student', Contact__c = stdConAss[0].Candidate_Name__c, Date__c=System.today(), Description__c='Test', Status__c = 'Approved'),
                new Planned_Days_Off__c(RecordTypeId = stdPDORTId, Project__c = NULL, All_Projects__c = TRUE, Contact__c = stdConAss[0].Candidate_Name__c, Date__c=System.today(), Description__c='Test', Status__c = 'Approved')
            };
            insert pdos;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            DLIAttendanceEmailReminder sch = new DLIAttendanceEmailReminder();
            system.schedule('DLI Attendance Email Reminder', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
        List<Events__c> events = [SELECT Project__c 
                                    FROM Events__c 
                                    WHERE Date__c = TODAY AND 
                                        Status__c = 'Scheduled' AND
                                        Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time' LIMIT 1];
        
        Id dliRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
              
        List<AcctSeed__Project__c> proj = [SELECT Id, RecordTypeId FROM AcctSeed__Project__c WHERE Id = :events[0].Project__c];
        proj[0].RecordTypeId = dliRTId;
        update proj[0];
        
        Test.startTest();
        
            List<Contact_Assignments__c> stdConAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Assignment_Position__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            stdConAss[0].Project__c = proj[0].Id;
            stdConAss[0].Assignment_Position__c = 'Class Leader';
            update stdConAss[0];
            
            List<AcctSeed__Project__c> project = [SELECT Id FROM AcctSeed__Project__c WHERE Id != :proj[0].Id];
            
            DLI_Attendance__c dliAtt = new DLI_Attendance__c(Project__c = project[0].Id, Class_Leader__c = stdConAss[0].Candidate_Name__c, Date__c = System.Today());
            insert dliAtt;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            DLIAttendanceEmailReminder sch = new DLIAttendanceEmailReminder();
            system.schedule('DLI Attendance Email Reminder', CRON_EXP, sch);
            
        Test.stopTest();
    }
}