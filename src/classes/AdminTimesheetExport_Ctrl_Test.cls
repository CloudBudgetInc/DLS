/*Developed AdminTimesheetExport_Ctrl_Test by Siva Prasanth K.T*/
@isTest
public class AdminTimesheetExport_Ctrl_Test {
    @testsetup static void setup() {
    
        
        List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment();
        
        Test.StartTest();
        List<AcctSeed__Time_Card_Day__c>  tcd = TestClassUtil.createTestTimeCardDay();        
        List<Attendance__c> stuAtn = TestClassUtil.createTestAttendance();
        Test.Stoptest();        
        
    }
    // DLI_W_LT_Projects project related Admin Instructor hours
    private static testMethod void myTest1(){
        
        Date today = system.today();
        Date currst;
        
        //if today = sunday need to load the last week data - because saleforce start of the week is sunday
        if(today.toStartofWeek() == today) {
            currst = today.addDays(-1).toStartofWeek().addDays(1);
        }else {
            currst = today.toStartofWeek().addDays(1);
        } 
        Date currend = currst.addDays(6);
        
        String cAStuRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId(); 
        String cAInsRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        String proRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();  
        String proTaskRT = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
        String instructorId;
        String projectId;
        String insName;
        Decimal insTotalHrs = 0.00;
        
        List<Contact_Assignments__c> caList = [SELECT Id,Name,Status__c,Candidate_Name__c,Candidate_Name__r.Name,Project__c FROM Contact_Assignments__c LIMIT 2];
        List<AcctSeed__Project__c> proList = [SELECT Id,No_Student_Approval__c,Name,RecordTypeId,DLS_Class__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Time_Card_Line__c> tclLst = [SELECT Id, AcctSeed__Time_Card__c, AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Line__c LIMIT 2];
        
        if(proList.size() > 0  && caList.size() > 0) {
            proList[0].RecordTypeId = proRT;
            prolist[0].No_Student_Approval__c = false;
            update proList;
            
            List<AcctSeed__Project_Task__c> proTask = new List<AcctSeed__Project_Task__c>{new AcctSeed__Project_Task__c(RecordTypeId = proTaskRT,Name = 'Language Training Hindi',AcctSeed__Project__c = proList[0].Id,Project_Task_Type__c = 'Language Training'),
                new AcctSeed__Project_Task__c(RecordTypeId = proTaskRT,Name = 'Language Training- Preparation',Project_Task_Type__c = 'Preparation time',AcctSeed__Project__c = proList[0].Id)};
                    insert proTask;
            
            for(Contact_Assignments__c ca : caList){
                ca.Project__c = proList[0].Id;
                ca.Status__c = 'Active';
            }
            caList[0].RecordTypeId = cAStuRT;
            caList[1].RecordTypeId = cAInsRT;
            caList[1].Project_Task__c = proTask[0].Id;
            caList[1].Paper_Timesheet__c = false;
            Test.startTest(); 
            update caList;
            
            instructorId = caList[1].Candidate_Name__c;
            insName = caList[1].Candidate_Name__r.Name;
            projectId = prolist[0].Id;
            
            if(tclLst.size() > 0){
                List<AcctSeed__Time_Card_Day__c> timeCardDay = new List<AcctSeed__Time_Card_Day__c> {
                        new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = tclLst[0].Id,Start_Time1__c = '09:00 AM',End_Time1__c = '10:00 AM',Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = today.addDays(1),Status__c = 'Submitted',Student_Approval_Status__c = 'Submitted'),
                        new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = tclLst[0].Id,Start_Time1__c = '08:00 AM',End_Time1__c = '10:00 AM',Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = today.addDays(2),Status__c = 'Submitted',Student_Approval_Status__c = 'Submitted'),
                        new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = tclLst[0].Id,Start_Time1__c = '08:00 AM',End_Time1__c = '10:00 AM',Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = today.addDays(3),Status__c = 'Submitted',Student_Approval_Status__c = 'Submitted'),
                        new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = tclLst[0].Id,Start_Time1__c = '08:00 AM',End_Time1__c = '10:00 AM',Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = today.addDays(4),Status__c = 'Submitted',Student_Approval_Status__c = 'Submitted'),
                        new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = tclLst[1].Id,Start_Time1__c = '08:00 AM',End_Time1__c = '09:00 AM',Start_Time2__c = '02:00 PM',End_Time2__c = '03:00 PM',Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = today.addDays(4),Status__c = 'Submitted',Student_Approval_Status__c = 'Submitted')
                        };
                        insert timeCardDay;
            }  
            
            List<AcctSeed__Time_Card_Day__c> tcdLst = [SELECT AcctSeed__Time_Card_Line__c,Student_Approval_Status__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Start_Time1__c,End_Time1__c,Total_Hours_Before_Approved__c,AcctSeed__Hours__c,AcctSeed__Date__c,Status__c FROM AcctSeed__Time_Card_Day__c LIMIT 8];        
            
                       
            if(tcdLst.size() > 0){
                for(AcctSeed__Time_Card_Day__c tcd : tcdLst){
                    tcd.Status__c = 'Submitted';
                    tcd.Student_Approval_Status__c = 'Submitted';
                    
                    if(tcd.Total_Hours_Before_Approved__c != null){
                        insTotalHrs = insTotalHrs + tcd.Total_Hours_Before_Approved__c;
                    }
                }
                
                tcdLst[0].Student_Approval_Status__c = 'Approved';
                tcdLst[0].Status__c = 'Approved';
                tcdLst[0].AcctSeed__Date__c = currst;
                tcdLst[1].AcctSeed__Date__c = currst.addDays(1);
                tcdLst[2].AcctSeed__Date__c = currst.addDays(2);
                tcdLst[3].AcctSeed__Date__c = currst.addDays(3);
                tcdLst[4].AcctSeed__Date__c = currst.addDays(4);
                tcdLst[5].AcctSeed__Date__c = currst.addDays(5);
                tcdLst[6].AcctSeed__Date__c = currst.addDays(6);
                tcdLst[7].AcctSeed__Date__c = currst.addDays(4);
                tcdLst[1].Student_Approval_Status__c = 'Rejected';
                tcdLst[1].Student_Notes__c = 'Please reduce your time';
                update tcdLst;   
                
                List<AcctSeed__Time_Card__c> tcLst = [SELECT Id,Intructor__c FROM AcctSeed__Time_Card__c WHERE Id = :tcdLst[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c];
                tcLst[0].Intructor__c =  caList[1].Candidate_Name__c ;
                update tcLst;
                
                List<AcctSeed__Time_Card_Line__c> tclList = [SELECT Id,AcctSeed__Project__c,AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Line__c LIMIT 2];
                tclList[0].AcctSeed__Project_Task__c = proTask[0].Id;
                tclList[0].AcctSeed__Project__c = proList[0].Id;
                tclList[0].AcctSeed__Billable__c = true;
                tclList[1].AcctSeed__Project_Task__c = proTask[1].Id;
                tclList[1].AcctSeed__Project__c = proList[0].Id;
                tclList[1].AcctSeed__Billable__c = true;
                update tclList;
            }
            
            List<Attendance__c> stuAtn = [SELECT Id,Name,Student__c,Instructor__c,Date__c,Duration__c,Student_Approval_Status__c FROM  Attendance__c LIMIT 2];
            if(stuAtn.size() > 0){
                stuAtn[0].Student_Approval_Status__c = 'Approved';
                stuAtn[0].Instructor__c = caList[1].Candidate_Name__c;
                stuAtn[0].Date__c = currst;
                stuAtn[0].Student__c = caList[0].Candidate_Name__c;
                stuAtn[0].Duration__c = 3.00;
                stuAtn[0].Time_Card_Day__c = tcdLst[0].Id;
                update stuAtn;
            }
            
        }
        
        ApexPages.currentPage().getParameters().put('contactId',instructorId);
        ApexPages.currentPage().getParameters().put('projectId', projectId);
        ApexPages.currentPage().getParameters().put('dt1', String.valueOf(currst));
        ApexPages.currentPage().getParameters().put('dt2', String.valueOf(currend));
        
        AdminTimesheetExport_Ctrl adminTime = new AdminTimesheetExport_Ctrl();
        Test.stopTest(); 
        System.assertEquals(adminTime.adminTimeInfo.projectRTName,'DLI_W_LT_Projects');
        System.assertEquals(adminTime.adminTimeInfo.instructorName,insName);
        //System.assertEquals(adminTime.adminTimeInfo.totalHrsDayColEntries.TotaldayHrs,String.valueOf(insTotalHrs));
    }
    // Language_Training_Projects project related Admin Instructor hours
    private static testMethod void myTest2(){
        
        Date today = system.today();
        Date currst;
        
        //if today = sunday need to load the last week data - because saleforce start of the week is sunday
        if(today.toStartofWeek() == today) {
            currst = today.addDays(-1).toStartofWeek().addDays(1);
        }else {
            currst = today.toStartofWeek().addDays(1);
        } 
        Date currend = currst.addDays(6);
        
        String cAStuRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId(); 
        String cAInsRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        String proRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();  
        String proTaskRT = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
        String instructorId;
        String projectId;
        String insName;
        Decimal insTotalHrs = 0.00;
        
        List<Contact_Assignments__c> caList = [SELECT Id,Name,Status__c,Candidate_Name__c,Candidate_Name__r.Name,Project__c FROM Contact_Assignments__c LIMIT 2];
        List<AcctSeed__Project__c> proList = [SELECT Id,No_Student_Approval__c,Name,RecordTypeId,DLS_Class__c FROM AcctSeed__Project__c LIMIT 1];
        
        if(proList.size() > 0  && caList.size() > 0) {
            proList[0].RecordTypeId = proRT;
            prolist[0].No_Student_Approval__c = false;
            update proList;
            
            List<AcctSeed__Project_Task__c> proTask = new List<AcctSeed__Project_Task__c>{new AcctSeed__Project_Task__c(RecordTypeId = proTaskRT,Name = 'Language Training Hindi',AcctSeed__Project__c = proList[0].Id,Project_Task_Type__c = 'Language Training')};
                insert proTask;
            
            for(Contact_Assignments__c ca : caList){
                ca.Project__c = proList[0].Id;
                ca.Status__c = 'Active';
            }
            caList[0].RecordTypeId = cAStuRT;
            caList[1].RecordTypeId = cAInsRT;
            caList[1].Project_Task__c = proTask[0].Id;
            caList[1].Paper_Timesheet__c = false;
            Test.startTest();  
            update caList;
            
            instructorId = caList[1].Candidate_Name__c;
            insName = caList[1].Candidate_Name__r.Name;
            projectId = prolist[0].Id;
            
            List<AcctSeed__Time_Card_Day__c> tcdLst = [SELECT AcctSeed__Time_Card_Line__c,Student_Approval_Status__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Start_Time1__c,End_Time1__c,Total_Hours_Before_Approved__c,AcctSeed__Hours__c,AcctSeed__Date__c,Status__c FROM AcctSeed__Time_Card_Day__c LIMIT 3];        
            
                      
            if(tcdLst.size() > 0){
                for(AcctSeed__Time_Card_Day__c tcd : tcdLst){
                    tcd.Status__c = 'Submitted';
                    tcd.Student_Approval_Status__c = 'Submitted';
                    tcd.Total_Hours_Before_Approved__c = 1.00;
                    
                    if(tcd.Total_Hours_Before_Approved__c != null){
                        insTotalHrs = insTotalHrs + tcd.Total_Hours_Before_Approved__c;
                    }
                }
                tcdLst[0].AcctSeed__Date__c = currst;
                tcdLst[1].AcctSeed__Date__c = currst.addDays(1);
                tcdLst[2].AcctSeed__Date__c = currst.addDays(2);
                update tcdLst;
                
                List<AcctSeed__Time_Card__c> tcLst = [SELECT Id,Intructor__c FROM AcctSeed__Time_Card__c WHERE Id = :tcdLst[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c];
                tcLst[0].Intructor__c = instructorId;
                update tcLst;
                
                List<AcctSeed__Time_Card_Line__c> tclList = [SELECT Id,AcctSeed__Project__c,AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Line__c  WHERE Id = :tcdLst[0].AcctSeed__Time_Card_Line__c];
                tclList[0].AcctSeed__Project_Task__c = proTask[0].Id;
                tclList[0].AcctSeed__Project__c = proList[0].Id;
                tclList[0].AcctSeed__Billable__c = true;
                update tclList;
            }
            
        }
        
        ApexPages.currentPage().getParameters().put('contactId',instructorId);
        ApexPages.currentPage().getParameters().put('projectId', projectId);
        ApexPages.currentPage().getParameters().put('dt1', String.valueOf(currst));
        ApexPages.currentPage().getParameters().put('dt2', String.valueOf(currend));
        
        AdminTimesheetExport_Ctrl adminTime = new AdminTimesheetExport_Ctrl();
        Test.stopTest(); 
        System.assertEquals(adminTime.adminTimeInfo.projectRTName,'Language_Training_Projects');
        System.assertEquals(adminTime.adminTimeInfo.instructorName,insName);
        //System.assertEquals(adminTime.adminTimeInfo.totalHrsDayColEntries.TotaldayHrs,String.valueOf(insTotalHrs));
    }
}