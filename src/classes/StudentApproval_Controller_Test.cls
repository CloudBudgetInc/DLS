@isTest
public class StudentApproval_Controller_Test {

    @testsetup static void setup() {
        
        List<AcctSeed__Time_Card_Day__c>  tcd = TestClassUtil.createTestTimeCardDay();
        Test.StartTest();
            List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment();
            List<Attendance__c> stuAtn = TestClassUtil.createTestAttendance();
        Test.Stoptest();        
        
    }
    // Method to getting intial WeekDetails and Project filter details
    private static testMethod void testMethod1() {
        List<Contact> stuConList = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Student Community'];
        
        if(profileLst.size() > 0 && stuConList.size() > 0){
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey ='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileLst[0].Id, country ='United States',IsActive = true,
                                 ContactId = stuConList[0].Id,
                                 timezonesidkey = 'America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            system.runas(user){
                String intialfilterVal = StudentApproval_Controller.getInitialFilterValues();
                TimeCardDayCommunityDomain.InitialFilterValues intialVal = (TimeCardDayCommunityDomain.InitialFilterValues) JSON.deserialize(intialfilterVal,TimeCardDayCommunityDomain.InitialFilterValues.Class);
                System.assertEquals(intialVal.contactId,stuConList[0].Id);
                
            }
        }
    }
    private static testMethod void testMethod2(){
        List<Contact> stuConList = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Student Community'];
        
        if(profileLst.size() > 0 && stuConList.size() > 0){
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey ='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileLst[0].Id, country ='United States',IsActive = true,
                                 ContactId = stuConList[0].Id,
                                 timezonesidkey = 'America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            List<Contact_Assignments__c> caInsList = new List<Contact_Assignments__c>();
            List<Contact_Assignments__c> caStuList = new List<Contact_Assignments__c>();
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Status__c,Candidate_Name__c,Candidate_Name__r.LastName,Candidate_Name__r.Name,Candidate_Name__r.FirstName,Project__c,RecordType.DeveloperName,Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN('Student','Instructor')]){
                if(ca.RecordType.DeveloperName == 'Student'){
                    caStuList.add(ca);
                }else if(ca.RecordType.DeveloperName == 'Instructor'){
                    caInsList.add(ca);
                }
            }
            if(caInsList.size() > 0 && caStuList.size() > 0){
                List<AcctSeed__Project__c> proList = [SELECT Id,No_Student_Approval__c,Name,RecordTypeId,DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :caInsList[0].Project__c LIMIT 1];
                List<AcctSeed__Project_Task__c>  proTask = [SELECT Name,Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :caInsList[0].Project__c LIMIT 1];
                
                if(proList.size() > 0 && proTask.size() > 0){
                    
                    caInsList[0].Paper_Timesheet__c = false;
                    update caInsList;
                    
                    Test.startTest();
                    Date today = system.today();
                    Date currst;
                    
                    //if today = sunday need to load the last week data - because saleforce start of the week is sunday
                    if(today.toStartofWeek() == today) {
                        currst = today.addDays(-1).toStartofWeek().addDays(1);
                    }else {
                        currst = today.toStartofWeek().addDays(1);
                    } 
                    Date currend = currst.addDays(6);
                    
                    List<AcctSeed__Time_Card_Day__c> tcdLst = [SELECT AcctSeed__Time_Card_Line__c,Student_Approval_Status__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Start_Time1__c,End_Time1__c,Total_Hours_Before_Approved__c,AcctSeed__Hours__c,AcctSeed__Date__c,Status__c FROM AcctSeed__Time_Card_Day__c LIMIT 3];        
                    
                    if(tcdLst.size() > 0){
                        for(AcctSeed__Time_Card_Day__c tcd : tcdLst){
                            tcd.Student_Approval_Status__c = 'Submitted';
                        }
                        update tcdLst;
                        
                        system.runas(user){
                            String getproFilter = StudentApproval_Controller.getProjectFilterValues(string.valueOf(currst),string.valueOf(currend),stuConList[0].Id);
                            TimeCardDayCommunityDomain.ProjectFilterInfo proInfo  = (TimeCardDayCommunityDomain.ProjectFilterInfo)JSON.deserialize(getproFilter, TimeCardDayCommunityDomain.ProjectFilterInfo.class);
                            Map<String,String> instructorRelProMap = proInfo.instructorRelatedProjects;
                            if(instructorRelProMap != null && instructorRelProMap.size() > 0) {
                                System.assertEquals(instructorRelProMap.get(proList[0].Id+'-'+caInsList[0].Candidate_Name__c),proList[0].DLS_Class__c+' / '+caInsList[0].Candidate_Name__r.Name);
                            }
                        }
                        Test.stopTest();
                    }
                }
            }
        }
    }// get Project filter
    private static testMethod void testMethod2A(){
        List<Contact> stuConList = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Student Community'];
        String studentNames;
        
        
        if(profileLst.size() > 0 && stuConList.size() > 0){
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey ='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileLst[0].Id, country ='United States',IsActive = true,
                                 ContactId = stuConList[0].Id,
                                 timezonesidkey = 'America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            List<Contact_Assignments__c> caInsList = new List<Contact_Assignments__c>();
            List<Contact_Assignments__c> caStuList = new List<Contact_Assignments__c>();
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Status__c,Candidate_Name__c,Candidate_Name__r.LastName,Candidate_Name__r.Name,Candidate_Name__r.FirstName,Project__c,RecordType.DeveloperName,Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN ('Student','Instructor')]){
                if(ca.RecordType.DeveloperName == 'Student'){
                    caStuList.add(ca);
                }else if(ca.RecordType.DeveloperName == 'Instructor'){
                    caInsList.add(ca);
                }
            }
            if(caInsList.size() > 0 && caStuList.size() > 0){
                List<AcctSeed__Project__c> proList = [SELECT Id,No_Student_Approval__c,Name,RecordTypeId,DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :caInsList[0].Project__c LIMIT 1];
                List<AcctSeed__Project_Task__c>  proTask = [SELECT Name,Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :caInsList[0].Project__c LIMIT 1];
                if(proList.size() > 0 && proTask.size() > 0){
                    studentNames =  prolist[0].DLS_Class__c+'/';
                    
                    for(Contact_Assignments__c ca : caStuList){
                        studentNames = studentNames + ca.Candidate_Name__r.FirstName+'.'+ca.Candidate_Name__r.LastName.subString(0,1)+'; ';
                    }
                    
                    caInsList[0].Paper_Timesheet__c = false;
                    update caInsList;
                    
                    Test.startTest();
                    Date today = system.today();
                    Date currst;
                    
                    //if today = sunday need to load the last week data - because saleforce start of the week is sunday
                    if(today.toStartofWeek() == today) {
                        currst = today.addDays(-1).toStartofWeek().addDays(1);
                    }else {
                        currst = today.toStartofWeek().addDays(1);
                    } 
                    Date currend = currst.addDays(6);
                    
                    List<AcctSeed__Time_Card_Day__c> tcdLst = [SELECT AcctSeed__Time_Card_Line__c,Student_Approval_Status__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Start_Time1__c,End_Time1__c,Total_Hours_Before_Approved__c,AcctSeed__Hours__c,AcctSeed__Date__c,Status__c FROM AcctSeed__Time_Card_Day__c LIMIT 3];        
                    
                    if(tcdLst.size() > 0){
                        for(AcctSeed__Time_Card_Day__c tcd : tcdLst){
                            tcd.Student_Approval_Status__c = 'Submitted';
                        }
                        update tcdLst;
                        
                        system.runas(user){
                            String rowDetails = StudentApproval_Controller.getTimeCardDayDetails(proList[0].Id,currst,currend,caInsList[0].Candidate_Name__c,studentNames);
                            TimeCardDayCommunityDomain.InstructorRowDetails insRowDetails = (TimeCardDayCommunityDomain.InstructorRowDetails) JSON.deserialize(rowDetails, TimeCardDayCommunityDomain.InstructorRowDetails.Class);
                            system.assertEquals(insRowDetails.projectName,'Language_Training_Projects');
                        }
                        Test.stopTest();
                    }
                }
            }
        }
    }
    // Method to getting TimeCardDay Records
    private static testMethod void testMethod3(){
        
        String studentNames;
        String proDlsNo; 
        List<Contact> stuConList = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Student Community'];
        List<AcctSeed__Time_Card_Line__c> tcllList = [SELECT Id, AcctSeed__Time_Card__c, AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Line__c LIMIT 2];
        
        
        if(profileLst.size() > 0 && stuConList.size() > 0){
            User user = new User(alias = 'test123', email = 'test123@noemail.com',
                                 emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                                 localesidkey = 'en_US', profileid = profileLst[0].Id, country = 'United States',IsActive = true,
                                 ContactId = stuConList[0].Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            
            List<Contact_Assignments__c> caInsList = new List<Contact_Assignments__c>();
            List<Contact_Assignments__c> caStuList = new List<Contact_Assignments__c>();
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Status__c,Candidate_Name__c,Candidate_Name__r.LastName,Candidate_Name__r.Name,Candidate_Name__r.FirstName,Project__c,RecordType.DeveloperName,Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN('Student','Instructor')]){
                if(ca.RecordType.DeveloperName == 'Student'){
                    caInsList.add(ca);
                }else if(ca.RecordType.DeveloperName == 'Instructor'){
                    caInsList.add(ca);
                }
            }
            if(caStuList.size() > 0 && caInsList.size() > 0){
                List<AcctSeed__Project__c> proList = [SELECT Id,No_Student_Approval__c,Name,RecordTypeId,DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :caInsList[0].Project__c LIMIT 1];
                List<AcctSeed__Project_Task__c>  proTask = [SELECT Name,Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :caInsList[0].Project__c LIMIT 1];
                caInsList[0].Paper_Timesheet__c = false;
                update caInsList;
                
                if(proList.size() > 0 && proTask.size() > 0){
                    studentNames =  prolist[0].DLS_Class__c+'/';
                    
                    for(Contact_Assignments__c ca : caStuList){
                        studentNames = studentNames + ca.Candidate_Name__r.FirstName+'.'+ca.Candidate_Name__r.LastName.subString(0,1)+'; ';
                    }
                    Date today = system.today();
                    Date currst;
                    
                    //if today = sunday need to load the last week data - because saleforce start of the week is sunday
                    if(today.toStartofWeek() == today) {
                        currst = today.addDays(-1).toStartofWeek().addDays(1);
                    }else {
                        currst = today.toStartofWeek().addDays(1);
                    } 
                    Date currend = currst.addDays(6);
                    
                    if(tcllList.size() > 0){
                        List<AcctSeed__Time_Card_Day__c> timeCardDay = new List<AcctSeed__Time_Card_Day__c> {
                            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = tcllList[0].Id,Start_Time1__c = '09:00 AM',End_Time1__c = '10:00 AM',Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = today.addDays(1),Status__c = 'Pending Approval',Student_Approval_Status__c = 'Submitted'),
                                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = tcllList[0].Id,Start_Time1__c = '08:00 AM',End_Time1__c = '10:00 AM',Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = today.addDays(2),Status__c = 'Pending Approval',Student_Approval_Status__c = 'Submitted'),
                                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = tcllList[0].Id,Start_Time1__c = '08:00 AM',End_Time1__c = '10:00 AM',Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = today.addDays(3),Status__c = 'Pending Approval',Student_Approval_Status__c = 'Submitted'),
                                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = tcllList[0].Id,Start_Time1__c = '08:00 AM',End_Time1__c = '10:00 AM',Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = today.addDays(4),Status__c = 'Pending Approval',Student_Approval_Status__c = 'Submitted')
                                };
                                    insert timeCardDay;
                    }  
                    
                    List<AcctSeed__Time_Card_Day__c> tcdLst = [SELECT AcctSeed__Time_Card_Line__c,Student_Notes__c,Student_Approval_Status__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Start_Time1__c,End_Time1__c,Total_Hours_Before_Approved__c,AcctSeed__Hours__c,AcctSeed__Date__c,Status__c FROM AcctSeed__Time_Card_Day__c LIMIT 7];        
                    
                    if(tcdLst.size() > 0){
                        String instructor = tcdLst[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c;
                        Decimal totalHrs = 0.00;
                        
                        tcdLst[0].Student_Approval_Status__c = 'Approved';
                        tcdLst[0].AcctSeed__Date__c = currst;
                        tcdLst[1].AcctSeed__Date__c = currst.addDays(1);
                        tcdLst[2].AcctSeed__Date__c = currst.addDays(2);
                        tcdLst[3].AcctSeed__Date__c = currst.addDays(3);
                        tcdLst[4].AcctSeed__Date__c = currst.addDays(4);
                        tcdLst[5].AcctSeed__Date__c = currst.addDays(5);
                        tcdLst[6].AcctSeed__Date__c = currst.addDays(6);
                        tcdLst[1].Student_Approval_Status__c = 'Rejected';
                        tcdLst[1].Student_Notes__c = 'Please reduce your time';
                        update tcdLst;   
                        
                        system.runas(user){
                            StudentApproval_Controller.getTimeCardDayDetails(proList[0].Id,currst,currend,caInsList[0].Candidate_Name__c,studentNames);
                        }
                    }
                }
                
            }
        }
    }
    
    // Method to save TimeCardDay and StudentAttendance Records
    private static testMethod void testMethod5(){
        
        List<Contact> con = [SELECT Id FROM Contact LIMIT 1];
        List<Attendance__c> stuAtn = [SELECT Id,Name,Student__c,Instructor__c,Date__c,Duration__c,Student_Approval_Status__c FROM  Attendance__c LIMIT 2];
        stuAtn[0].Student_Approval_Status__c = 'Approved';
        
        List<AcctSeed__Time_Card_Day__c> tcdLst = [SELECT Student_Approver__c,AcctSeed__Time_Card_Line__c,Student_Notes__c,Student_Approval_Status__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Start_Time1__c,End_Time1__c,Total_Hours_Before_Approved__c,AcctSeed__Hours__c,AcctSeed__Date__c,Status__c FROM AcctSeed__Time_Card_Day__c LIMIT 2];        
        tcdLst[0].Student_Approval_Status__c = 'Approved';
        tcdLst[0].Student_Approver__c = con[0].Id;
        tcdLst[1].Student_Approval_Status__c = 'Rejected';
        tcdLst[1].Student_Notes__c = 'Please reduce your time';
        tcdLst[1].Student_Approver__c = con[0].Id; 
        
        StudentApproval_Controller.updateDayAndAttendanceEntryRecord(JSON.serialize(tcdLst),'DODA_Projects',JSON.serialize(stuAtn));
        stuAtn[0].Student_Approval_Status__c = 'Rejected';
        stuAtn[0].Rejection_Reason__c = 'Please Reduce your Time';
        StudentApproval_Controller.updateDayAndAttendanceEntryRecord(JSON.serialize(tcdLst),'DODA_Projects',JSON.serialize(stuAtn));
        
        List<AcctSeed__Time_Card_Day__c> tcdList = [SELECT Id,Student_Notes__c,Student_Approval_Status__c FROM AcctSeed__Time_Card_Day__c WHERE Id =:  tcdLst[0].Id];        
        System.assertEquals('Approved', tcdList[0].Student_Approval_Status__c);
        
    }
    // Method to Schedule Records
    private static testMethod void testMethod6(){
        List<Schedule__c> schList = [SELECT Id,Status__c,Project__c FROM Schedule__c LIMIT 1];
        if(schList.size() > 0){
            String schJSON =  StudentApproval_Controller.getProjectRelatedSchedules(schList[0].Project__c,String.valueOf(System.today()),String.valueOf(System.today().addDays(10)));
            List<Schedule__c> scheduleRecords = (List<Schedule__c>) JSON.deserialize(schJSON,List<Schedule__c>.Class);
            System.assertEquals(schList[0].Project__c,scheduleRecords[0].Project__c);
        }
    }
    // Method to getting Student Attendance Records
    private static testMethod void testMethod7(){
        List<Contact> stuConList = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        List<Contact> con = [SELECT Id,LastName FROM Contact LIMIT 2];
        List<Events__c> eventList = [SELECT Id FROM Events__c LIMIT 2];
        List<Attendance__c> stuAtn = new List<Attendance__c>();
        
        String studentNames;
        String proDlsNo; 
        
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Student Community'];
        if(profileLst.size() > 0 && con.size() > 0){
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileLst[0].Id, country='United States',IsActive =true,
                                 ContactId = stuConList[0].Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            
            List<Contact_Assignments__c> caInsList = new List<Contact_Assignments__c>();
            List<Contact_Assignments__c> caStuList = new List<Contact_Assignments__c>();
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Status__c,Candidate_Name__c,Candidate_Name__r.LastName,Candidate_Name__r.Name,Candidate_Name__r.FirstName,Project__c,RecordType.DeveloperName,Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN('Student','Instructor')]){
                if(ca.RecordType.DeveloperName == 'Student'){
                    caStuList.add(ca);
                }else if(ca.RecordType.DeveloperName == 'Instructor'){
                    caInsList.add(ca);
                }
            }
            if(caStuList.size() > 0 && caInsList.size() > 0){
                List<AcctSeed__Project__c> proList = [SELECT Id,No_Student_Approval__c,Name,RecordTypeId,DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :caInsList[0].Project__c LIMIT 1];
                List<AcctSeed__Project_Task__c>  proTask = [SELECT Name,Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :caInsList[0].Project__c LIMIT 1];
                
                caInsList[0].Paper_Timesheet__c = false;
                update caInsList;
                
                if(proList.size() > 0 && proTask.size() > 0){
                    List<Attendance__c> attendList = new List<Attendance__c> {
                        new Attendance__c(Event__c = eventList[1].Id)
                            };
                            insert attendList;
                    stuAtn = [SELECT Id,Name,Event__c,Date__c,Student__c,Instructor__r.Name FROM  Attendance__c LIMIT 2];
                    studentNames =  prolist[0].DLS_Class__c+'/';
                    
                    for(Contact_Assignments__c ca : caStuList){
                        studentNames = studentNames + ca.Candidate_Name__r.FirstName+'.'+ca.Candidate_Name__r.LastName.subString(0,1)+'; ';
                    }
                    caStuList[0].Assignment_Position__c = 'Class Leader';
                    update caStuList;
                    
                    Date today = system.today();
                    Date currst;
                    Date st;
                    
                    //if today = sunday need to load the last week data - because saleforce start of the week is sunday
                    if(today.toStartofWeek() == today) {
                        st = today.addDays(-1).toStartofWeek().addDays(-6);
                        currst = today.addDays(-1).toStartofWeek().addDays(1);
                    }else {
                        st = today.toStartofWeek().addDays(-6);
                        currst = today.addDays(-1).toStartofWeek().addDays(1);
                    } 
                    Date ed = st.addDays(6);
                    Date currend = currst.addDays(6);
                    
                    List<AcctSeed__Time_Card_Day__c> tcdLst = [SELECT AcctSeed__Time_Card_Line__c,Student_Notes__c,Student_Approval_Status__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Start_Time1__c,End_Time1__c,Total_Hours_Before_Approved__c,AcctSeed__Hours__c,AcctSeed__Date__c,Status__c FROM AcctSeed__Time_Card_Day__c LIMIT 3];        
                    
                    if(tcdLst.size() > 0){
                        
                        String instructor = tcdLst[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c;
                        Decimal totalHrs = 0.00;
                        Test.startTest();
                        
                        tcdLst[0].Student_Approval_Status__c = 'Approved';
                        tcdLst[1].Student_Approval_Status__c = 'Approved';
                        update tcdLst;
                        
                        if(proList.size() > 0 && stuAtn.size() > 0){
                            List<Events__c> evt = [SELECT Id,Name,Project__c FROM  Events__c WHERE Id =: stuAtn[0].Event__c]; 
                            evt[0].Project__c = proList[0].Id;
                            update evt;
                            
                            stuAtn[0].Instructor__c = con[0].Id;
                            stuAtn[0].Date__c = st;
                            stuAtn[0].Student__c = con[1].Id;
                            stuAtn[0].Duration__c = 3.00;
                            stuAtn[0].Time_Card_Day__c = tcdLst[0].Id;
                            stuAtn[0].Student_Approval_Status__c = 'Approved';
                            
                            stuAtn[1].Instructor__c = con[0].Id;
                            stuAtn[1].Date__c = st.addDays(1);
                            stuAtn[1].Student__c = con[1].Id;
                            stuAtn[1].Duration__c = 3.00;
                            stuAtn[1].Time_Card_Day__c = tcdLst[1].Id;
                            stuAtn[1].Student_Approval_Status__c = 'Approved';
                            update stuAtn;
                        }
                        
                        system.runas(user){
                            
                            Decimal stuTotalHrs = 0.00;
                            String stuJSON = StudentApproval_Controller.studentTimeEntriesRowFormation('DLI_W_LT_Projects',proList[0].Id,st,ed,con[0].Id);
                            List<TimeCardDayCommunityDomain.StudentTimeDetail> stuTimeEntries = (List<TimeCardDayCommunityDomain.StudentTimeDetail>) JSON.deserialize(stuJSON,List<TimeCardDayCommunityDomain.StudentTimeDetail>.class);
                            system.assertEquals(stuTimeEntries.size() , stuAtn.size());
                        }
                        Test.stopTest();
                    }
                }                
            }
        }
    }
    
    // Method to getting Student Attendance Records
    private static testMethod void testMethod8(){
        
        List<Contact> stuConList = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        List<Contact> con = [SELECT Id,LastName FROM Contact LIMIT 2];
        List<Events__c> eventList = [SELECT Id FROM Events__c LIMIT 2];
        List<Attendance__c> stuAtn = new List<Attendance__c>();
        
        String studentNames;
        String proDlsNo; 
        
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Student Community'];
        if(profileLst.size() > 0 && con.size() > 0){
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileLst[0].Id, country='United States',IsActive =true,
                                 ContactId = stuConList[0].Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            
            List<Contact_Assignments__c> caInsList = new List<Contact_Assignments__c>();
            List<Contact_Assignments__c> caStuList = new List<Contact_Assignments__c>();
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Status__c,Candidate_Name__c,Candidate_Name__r.LastName,Candidate_Name__r.Name,Candidate_Name__r.FirstName,Project__c,RecordType.DeveloperName,Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN('Student','Instructor')]){
                if(ca.RecordType.DeveloperName == 'Student'){
                    caStuList.add(ca);
                }else if(ca.RecordType.DeveloperName == 'Instructor'){
                    caInsList.add(ca);
                }
            }
            if(caStuList.size() > 0 && caInsList.size() > 0){
                List<AcctSeed__Project__c> proList = [SELECT Id,No_Student_Approval__c,Name,RecordTypeId,DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :caInsList[0].Project__c LIMIT 1];
                List<AcctSeed__Project_Task__c>  proTask = [SELECT Name,Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :caInsList[0].Project__c LIMIT 1];
                
                caInsList[0].Paper_Timesheet__c = false;
                update caInsList;
                
                if(proList.size() > 0 && proTask.size() > 0){
                    List<Attendance__c> attendList = new List<Attendance__c> {
                        new Attendance__c(Event__c = eventList[1].Id)
                            };
                           insert attendList;
                    stuAtn = [SELECT Id,Name,Event__c,Date__c,Student__c,Instructor__r.Name FROM  Attendance__c LIMIT 2];
                    studentNames =  prolist[0].DLS_Class__c+'/';
                    
                    for(Contact_Assignments__c ca : caStuList){
                        studentNames = studentNames + ca.Candidate_Name__r.FirstName+'.'+ca.Candidate_Name__r.LastName.subString(0,1)+'; ';
                    }
                    caStuList[0].Assignment_Position__c = 'Class Leader';
                    update caStuList;
                    
                    Date today = system.today();
                    Date currst;
                    Date st;
                    
                    //if today = sunday need to load the last week data - because saleforce start of the week is sunday
                    if(today.toStartofWeek() == today) {
                        st = today.addDays(-1).toStartofWeek().addDays(-6);
                        currst = today.addDays(-1).toStartofWeek().addDays(1);
                    }else {
                        st = today.toStartofWeek().addDays(-6);
                        currst = today.addDays(-1).toStartofWeek().addDays(1);
                    } 
                    Date ed = st.addDays(6);
                    Date currend = currst.addDays(6);
                    
                    List<AcctSeed__Time_Card_Day__c> tcdLst = [SELECT AcctSeed__Time_Card_Line__c,Student_Notes__c,Student_Approval_Status__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Start_Time1__c,End_Time1__c,Total_Hours_Before_Approved__c,AcctSeed__Hours__c,AcctSeed__Date__c,Status__c FROM AcctSeed__Time_Card_Day__c LIMIT 3];        
                    
                    if(tcdLst.size() > 0){
                        String instructor = tcdLst[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c;
                        Decimal totalHrs = 0.00;
                        
                        Test.startTest();
                        
                        tcdLst[0].Student_Approval_Status__c = 'Approved';
                        tcdLst[1].Student_Approval_Status__c = 'Approved';
                        update tcdLst;                
                        
                        if(proList.size() > 0 && stuAtn.size() > 0){
                            List<Events__c> evt = [SELECT Id,Name,Project__c FROM  Events__c WHERE Id =: stuAtn[0].Event__c]; 
                            evt[0].Project__c = proList[0].Id;
                            update evt;
                            
                            stuAtn[0].Instructor__c = con[0].Id;
                            stuAtn[0].Date__c = currst;
                            stuAtn[0].Student__c = con[1].Id;
                            stuAtn[0].Duration__c = 3.00;
                            stuAtn[0].Time_Card_Day__c = tcdLst[0].Id;
                            stuAtn[0].Student_Approval_Status__c = 'Rejected';
                            
                            update stuAtn;
                        }
                        Test.stopTest();
                        system.runas(user){
                            Decimal stuTotalHrs = 0.00;
                            String stuJSON = StudentApproval_Controller.studentTimeEntriesRowFormation('DLI_W_LT_Projects',proList[0].Id,currst,currend,con[0].Id);
                            List<TimeCardDayCommunityDomain.StudentTimeDetail> stuTimeEntries = (List<TimeCardDayCommunityDomain.StudentTimeDetail>) JSON.deserialize(stuJSON,List<TimeCardDayCommunityDomain.StudentTimeDetail>.class);
                            system.assertEquals(stuTimeEntries.size() , stuAtn.size());
                        }
                    }
                }                
            }
        }
    }        
}