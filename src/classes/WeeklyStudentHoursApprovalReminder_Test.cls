@isTest
private class WeeklyStudentHoursApprovalReminder_Test{

    @testSetup static void setupMethod(){
    
        List<Contact_Assignments__c> contactAssigns = TestClassUtil.createTestContactAssignment();
        
        Test.startTest();
            List<Events__c> events = TestClassUtil.createTestEvent();
            List<AcctSeed__Time_Card_Day__c> days = TestClassUtil.createTestTimeCardDay();
        Test.stopTest();
    }
    
    private static testMethod void myTest1(){
    
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        //List<Contact> contacts = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student'];
        
        List<AcctSeed__Time_Card_Line__c> tcl = [SELECT Id, AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Line__c LIMIT 1];
                                        
        List<Contact_Assignments__c> conAssign = [SELECT Id, Candidate_Name__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Assignment_Position__c = 'Student' LIMIT 1];
        conAssign[0].Time_Approval_Preference__c = 'Weekly';
        update conAssign[0];
        
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = : conAssign[0].Candidate_Name__c];
        
        Test.startTest();
            
            Date currentWeekStart = System.today().toStartofWeek().addDays(1);
            
            Date previouswkStart = currentWeekStart.addDays(-7);
            Date previouswkEnd = previouswkStart.addDays(6);
                                    
            List<AcctSeed__Time_Card_Day__c> dayRecs = new List<AcctSeed__Time_Card_Day__c>{
                new AcctSeed__Time_Card_Day__c (AcctSeed__Time_Card_Line__c = tcl[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = previouswkStart,Status__c = 'Draft', Student_Approval_Status__c = 'Submitted'),
                new AcctSeed__Time_Card_Day__c (AcctSeed__Time_Card_Line__c = tcl[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = previouswkStart.addDays(2),Status__c = 'Draft', Student_Approval_Status__c = 'Submitted')
            };
            insert dayRecs;
            
            events[0].No_Student_Approval__c = FALSE;
            events[0].Time_Card_Day__c = dayRecs[0].Id;
            events[0].Date__c = previouswkStart;
            events[1].No_Student_Approval__c = FALSE;
            events[1].Time_Card_Day__c = dayRecs[1].Id;
            events[1].Date__c = previouswkEnd;
            update events;
        
            List<Attendance__c> attendanceList = new List<Attendance__c>{
            
                new Attendance__c(Event__c = events[0].Id, Student__c = conAssign[0].Candidate_Name__c, Date__c = previouswkStart, Time_Card_Day__c = dayRecs[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = tcl[0].AcctSeed__Time_Card__r.Intructor__c),
                new Attendance__c(Event__c = events[1].Id, Student__c = conAssign[0].Candidate_Name__c, Date__c = previouswkEnd, Time_Card_Day__c = dayRecs[1].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = tcl[0].AcctSeed__Time_Card__r.Intructor__c)
            };
            insert attendanceList;
            
        Test.stopTest();
            
            String CRON_EXP = '0 0 8 * * ?';
            WeeklyStudentHoursApprovalReminder sch = new WeeklyStudentHoursApprovalReminder();
            system.schedule('Weekly Student Hours Approval Reminder', CRON_EXP, sch);            
    }  
    
    private static testMethod void myTest2(){
    
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        //List<Contact> contacts = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student'];
        
        List<AcctSeed__Time_Card_Line__c> tcl = [SELECT Id, AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Line__c LIMIT 1];
                                        
        List<Contact_Assignments__c> conAssign = [SELECT Id, Candidate_Name__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Assignment_Position__c = 'Student' LIMIT 1];
        conAssign[0].Time_Approval_Preference__c = 'Weekly';
        update conAssign[0];
        
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = : conAssign[0].Candidate_Name__c];
        
        Test.startTest();
            
            Date currentWeekStart = System.today().toStartofWeek().addDays(1);
            
            Date previouswkStart = currentWeekStart.addDays(-7);
            Date previouswkEnd = previouswkStart.addDays(6);
                                    
            List<AcctSeed__Time_Card_Day__c> dayRecs = new List<AcctSeed__Time_Card_Day__c>{
                new AcctSeed__Time_Card_Day__c (AcctSeed__Time_Card_Line__c = tcl[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = previouswkStart,Status__c = 'Draft', Student_Approval_Status__c = 'Submitted'),
                new AcctSeed__Time_Card_Day__c (AcctSeed__Time_Card_Line__c = tcl[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = previouswkStart.addDays(2),Status__c = 'Draft', Student_Approval_Status__c = 'Submitted')
            };
            insert dayRecs;
            
            events[0].No_Student_Approval__c = FALSE;
            events[0].Time_Card_Day__c = dayRecs[0].Id;
            events[0].Date__c = previouswkStart;
            events[1].No_Student_Approval__c = FALSE;
            events[1].Time_Card_Day__c = dayRecs[1].Id;
            events[1].Date__c = previouswkEnd;
            update events;
        
            List<Attendance__c> attendanceList = new List<Attendance__c>{
            
                new Attendance__c(Event__c = events[0].Id, Student__c = conAssign[0].Candidate_Name__c, Date__c = previouswkStart, Time_Card_Day__c = dayRecs[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = tcl[0].AcctSeed__Time_Card__r.Intructor__c),
                new Attendance__c(Event__c = events[1].Id, Student__c = conAssign[0].Candidate_Name__c, Date__c = previouswkEnd, Time_Card_Day__c = dayRecs[1].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = tcl[0].AcctSeed__Time_Card__r.Intructor__c)
            };
            insert attendanceList;
            
        Test.stopTest();
            
            Database.ExecuteBatch(new WeeklyStudentHoursApprovalReminder_Batch());
    }  
}