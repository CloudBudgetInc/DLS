@isTest
private class AttendanceTrigger_Test{

    @testSetup static void setupMethod(){
    
        List<Contact_Assignments__c> contactAssigns = TestClassUtil.createTestContactAssignment();
        
        Test.startTest();
            List<Events__c> events = TestClassUtil.createTestEvent();
            List<AcctSeed__Time_Card_Day__c> days = TestClassUtil.createTestTimeCardDay();
            List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'FALSE')};
            insert sysVal;
        Test.stopTest();
    }
    
    private static testMethod void myTest1(){
    
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student'];
        contacts[0].Time_Approval_Preference__c = 'Daily';
        update contacts[0];
        
        System.debug('contacts::::'+contacts[0].Id);
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c];
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        System.debug('projs ======'+projs);
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projs[0].Id,Candidate_Name__c = contacts[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Student'),
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projs[0].Id,Candidate_Name__c = contacts[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
        
        Test.startTest();
        
            insert conAssignRecs;  
            
            List<Contact_Assignments__c> conAssign = [SELECT Id, Candidate_Name__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE Id IN :conAssignRecs];
            System.debug('Candidate_Name__c::::'+conAssign[0].Candidate_Name__c);
            System.debug('Time_Approval_Preference__c::::'+conAssign[0].Time_Approval_Preference__c);
            
            events[0].No_Student_Approval__c = FALSE;
            events[0].Time_Card_Day__c = days[0].Id;
            events[1].No_Student_Approval__c = FALSE;
            events[1].Time_Card_Day__c = days[1].Id;
            update events;
                
            List<Attendance__c> attendanceList = new List<Attendance__c>{
            
                new Attendance__c(Event__c = events[0].Id, Student__c = contacts[0].Id, Date__c = days[0].AcctSeed__Date__c, Time_Card_Day__c = days[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c),
                new Attendance__c(Event__c = events[1].Id, Student__c = contacts[0].Id, Date__c = days[1].AcctSeed__Date__c, Time_Card_Day__c = days[1].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c)
            };
            insert attendanceList;
            
        Test.stopTest();
    }  
    
    private static testMethod void myTest1a(){
    
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student'];
        contacts[0].Time_Approval_Preference__c = 'Daily';
        update contacts[0];
        
        System.debug('contacts::::'+contacts[0].Id);
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c];
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        System.debug('projs ======'+projs);
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projs[0].Id,Candidate_Name__c = contacts[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Student'),
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projs[0].Id,Candidate_Name__c = contacts[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
        
        Test.startTest();
        
            insert conAssignRecs;  
            
            List<Contact_Assignments__c> conAssign = [SELECT Id, Candidate_Name__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE Id IN :conAssignRecs];
            System.debug('Candidate_Name__c::::'+conAssign[0].Candidate_Name__c);
            System.debug('Time_Approval_Preference__c::::'+conAssign[0].Time_Approval_Preference__c);
            
            Id pdoRTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Training_Holidays').getRecordTypeId();
    
            Planned_Days_Off__c pdo = new Planned_Days_Off__c(Description__c='Test Desc1',RecordTypeId = pdoRTId, Type__c='DLI-W LT', Date__c = days[0].AcctSeed__Date__c);
            insert pdo;
            
            events[0].No_Student_Approval__c = FALSE;
            events[0].Time_Card_Day__c = days[0].Id;
            events[1].No_Student_Approval__c = FALSE;
            events[1].Time_Card_Day__c = days[1].Id;
            update events;
            
            List<Attendance__c> attendanceList = new List<Attendance__c>{
            
                new Attendance__c(Event__c = events[0].Id, Student__c = contacts[0].Id, Date__c = days[0].AcctSeed__Date__c, Time_Card_Day__c = days[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c),
                new Attendance__c(Event__c = events[1].Id, Student__c = contacts[0].Id, Date__c = days[1].AcctSeed__Date__c, Time_Card_Day__c = days[1].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c)
            };
            insert attendanceList;
            
        Test.stopTest();
    } 
        
    private static testMethod void myTest2(){
    
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student'];
        contacts[0].Time_Approval_Preference__c = 'Daily';
        update contacts[0];
        
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c];
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        System.debug('projs ======'+projs);
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projs[0].Id,Candidate_Name__c = contacts[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Student'),
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projs[0].Id,Candidate_Name__c = contacts[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
        Test.StartTest();
            insert conAssignRecs; 
            
            events[0].No_Student_Approval__c = FALSE;
            events[0].Time_Card_Day__c = days[0].Id;
            events[1].No_Student_Approval__c = FALSE;
            events[1].Time_Card_Day__c = days[1].Id;
            update events;
            
            List<Attendance__c> attendanceList = new List<Attendance__c>{
            
                new Attendance__c(Event__c = events[0].Id, Student__c = contacts[0].Id, Date__c = days[0].AcctSeed__Date__c, Time_Card_Day__c = days[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c),
                new Attendance__c(Event__c = events[1].Id, Student__c = contacts[0].Id, Date__c = days[1].AcctSeed__Date__c, Time_Card_Day__c = days[1].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c)
            };
            
            insert attendanceList;
            
            List<Attendance__c> attendances = [SELECT Id, Student_Approval_Status__c, Duration__c FROM Attendance__c WHERE Id IN :attendanceList];
            attendances[0].Duration__c = 3;
            attendances[1].Student_Approval_Status__c = 'Rejected';
            update attendances;
            
            List<Attendance__c> attendances1 = [SELECT Id, Student_Approval_Status__c, Duration__c FROM Attendance__c WHERE Id IN :attendances AND Student_Approval_Status__c = 'Rejected'];
            attendances1[0].Student_Approval_Status__c = 'Submitted';
            update attendances1[0];
            
        Test.StopTest();
    }   
    
    private static testMethod void myTest3(){
    
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        
        Id stdId = NULL;
        Id insId = NULL;
        Id empId = NULL;
        
        for(Contact c  : [SELECT Id, RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName IN ('Student', 'Candidate', 'DLS_Employee')]){
            if(c.RecordType.DeveloperName == 'Candidate'){
                insId = c.Id;
            }
            if(c.RecordType.DeveloperName == 'Student'){
                stdId = c.Id;
            }
            if(c.RecordType.DeveloperName == 'DLS_Employee'){
                empId = c.Id;
            }
        }
        System.debug('insId:::'+insId);
        System.debug('stdId:::'+stdId);
        
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c];
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        System.debug('projs ======'+projs);
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projs[0].Id,Candidate_Name__c = insId,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Instructor'),
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projs[0].Id,Candidate_Name__c = empId,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Instructor')
        };
        Test.StartTest();
            insert conAssignRecs; 
            
            events[0].No_Student_Approval__c = FALSE;
            events[0].Time_Card_Day__c = days[0].Id;
            events[1].No_Student_Approval__c = FALSE;
            events[1].Time_Card_Day__c = days[1].Id;
            update events;
            
            List<Attendance__c> attendanceList = new List<Attendance__c>{
            
                new Attendance__c(Event__c = events[0].Id, Student__c = stdId, Date__c = days[0].AcctSeed__Date__c, Time_Card_Day__c = days[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = insId),
                new Attendance__c(Event__c = events[1].Id, Student__c = stdId, Date__c = days[1].AcctSeed__Date__c, Time_Card_Day__c = days[1].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = empId)
            };
            
            insert attendanceList;
                
            List<Attendance__c> attendances = [SELECT Id, Student_Approval_Status__c, Duration__c FROM Attendance__c WHERE Id IN :attendanceList];
            attendances[0].Student_Approval_Status__c = 'Rejected';
            attendances[1].Student_Approval_Status__c = 'Rejected';
            update attendances;
            
            List<Attendance__c> attendances1 = [SELECT Id, Student_Approval_Status__c, Duration__c FROM Attendance__c WHERE Id IN :attendances AND Student_Approval_Status__c = 'Rejected'];
            attendances1[0].Student_Approval_Status__c = 'Submitted';
            update attendances1[0];
            
        Test.StopTest();
    }
}