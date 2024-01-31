@isTest
private class WeeklyStudentHoursApprovalRequest_Test{

    @testSetup static void setupMethod(){
    
        List<Contact_Assignments__c> contactAssigns = TestClassUtil.createTestContactAssignment();
        
        Test.startTest();
            List<Events__c> events = TestClassUtil.createTestEvent();
            List<AcctSeed__Time_Card_Day__c> days = TestClassUtil.createTestTimeCardDay();
        Test.stopTest();
    }
    
    private static testMethod void myTest1(){
    
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student'];
                                                
        List<Contact_Assignments__c> conAssign = [SELECT Id, Candidate_Name__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Assignment_Position__c = 'Student' LIMIT 1];
        conAssign[0].Time_Approval_Preference__c = 'Weekly';
        update conAssign[0];
        
        Test.startTest();
            
            Date currentWeekStart = System.today().toStartofWeek().addDays(1);
            Date currentWeekEnd = currentWeekStart.addDays(6);
         
            List<AcctSeed__Time_Card_Day__c> days  = [SELECT Id, AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c WHERE AcctSeed__Date__c >= :currentWeekStart AND  AcctSeed__Date__c <= :currentWeekEnd];
            
            events[0].No_Student_Approval__c = FALSE;
            events[0].Time_Card_Day__c = days[0].Id;
            events[0].Date__c = days[0].AcctSeed__Date__c;
            update events;
        
            List<Attendance__c> attendanceList = new List<Attendance__c>{
            
                new Attendance__c(Event__c = events[0].Id, Student__c = conAssign[0].Candidate_Name__c, Date__c = days[0].AcctSeed__Date__c, Time_Card_Day__c = days[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c)
            };
            insert attendanceList;
            
        Test.stopTest();
        
            String CRON_EXP = '0 0 5 * * ?';
            WeeklyStudentHoursApprovalRequest sch = new WeeklyStudentHoursApprovalRequest();
            system.schedule('Weekly Student Hours Approval Request', CRON_EXP, sch);
    } 
    
    private static testMethod void myTest2(){
    
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student'];
                                                
        List<Contact_Assignments__c> conAssign = [SELECT Id, Candidate_Name__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Assignment_Position__c = 'Student' LIMIT 1];
        conAssign[0].Time_Approval_Preference__c = 'Weekly';
        update conAssign[0];
        
        Test.startTest();
            
            Date currentWeekStart = System.today().toStartofWeek().addDays(1);
            Date currentWeekEnd = currentWeekStart.addDays(6);
         
            List<AcctSeed__Time_Card_Day__c> days  = [SELECT Id, AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c WHERE AcctSeed__Date__c >= :currentWeekStart AND  AcctSeed__Date__c <= :currentWeekEnd];
            
            events[0].No_Student_Approval__c = FALSE;
            events[0].Time_Card_Day__c = days[0].Id;
            events[0].Date__c = days[0].AcctSeed__Date__c;
            update events;
        
            List<Attendance__c> attendanceList = new List<Attendance__c>{
            
                new Attendance__c(Event__c = events[0].Id, Student__c = conAssign[0].Candidate_Name__c, Date__c = days[0].AcctSeed__Date__c, Time_Card_Day__c = days[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c)
            };
            insert attendanceList;
            
        Test.stopTest();
        
        Database.ExecuteBatch(new WeeklyStudentHoursApprovalRequest_Batch());
    }  
}