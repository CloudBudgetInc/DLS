@isTest
private class supervisorTimeApproval_Ctrl_Test {

    @testSetup static void setup(){ 
    
        List<AcctSeed__Cost_Rates__c> costRate = TestClassUtil.createTestCostRates();
        List<Planned_Days_Off__c> pdos = TestClassUtil.createTestPlannedDaysOff();
        Test.StartTest();
            List<AcctSeed__Time_Card_Day__c> timecardlist = TestClassUtil.createTestTimeCardDay();
            List<MTT_Location__c> locations = TestClassUtil.createTestLocations();
            List<Events__c> createTestEvent = TestClassUtil.createTestEvent();
        Test.StopTest();        
    }
    
    // For Querying time card day details
    private static testMethod void testMethod1() {
        
        Test.StartTest();
        List<AcctSeed__Time_Card_Day__c> tcdList = [SELECT Id, Name, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c LIMIT 2];
        List<User> usrList = [SELECT Id, Name FROM User LIMIT 2];
        if(tcdList.size() > 0) {
            
            Set<Id> tclId = new set<Id>();
            
            tclId.add(tcdList[0].AcctSeed__Time_Card_Line__c);
            tclId.add(tcdList[1].AcctSeed__Time_Card_Line__c);
            
            List<AcctSeed__Time_Card_Line__c> tclList = [SELECT Id, Name, AcctSeed__Time_Card__c FROM AcctSeed__Time_Card_Line__c WHERE Id IN :tclId];
           
            if(tclList.size() > 0) {
                
                List<AcctSeed__Time_Card__c> tcList = [SELECT Id, Name, Intructor__c FROM AcctSeed__Time_Card__c WHERE Id = :tclList[0].AcctSeed__Time_Card__c];
                
                if(tcList.size() > 0) {
                    
                    List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :tcList[0].Intructor__c];
                    List<RecordType> conRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'DLS_Employee' AND SobjectType = 'Contact'];
                    
                    if(conList.size() > 0 && conRt.size() > 0) {
                    
                        conList[0].Supervisor_Name__c = usrList[0].Id;
                        conList[0].RecordTypeId = conRt[0].Id;
                        update conList;
    
                        tcdList[0].Status__c = 'Submitted';
                        tcdList[1].Status__c = 'Submitted';
                        update tcdList;
                        
                        supervisorTimeApproval_Ctrl.getTimeCardDayDetails(usrList[0].Id);
                        
                        conList[0].Supervisor_Name__c = UserInfo.getUserId();
                        update conList;
                        Date dt = system.today();
                        tcdList[0].AcctSeed__Date__c = dt.toStartofWeek().addDays(1);
                        //update tcdList;
                        
                        TimeCardDayDomain.WrapperClass ret = supervisorTimeApproval_Ctrl.getTimeCardDayDetails('--None--');
                        String retval = string.valueOf(ret);
                        if(retVal != null && retVal != '') 
                            System.assert(retVal.contains(UserInfo.getTimeZone().getID()));
                    }
                }
            }
        }
        Test.StopTest();
    } 
    
    // For QueryingInstructor time entry records for approval process
    private static testMethod void testMethod2() {
        
        Test.StartTest();
        //List<User> usrList = [SELECT Id, Name, FirstName, LastName FROM User LIMIT 2];
        List<User> usrList = insUserRecords('Insert','two');
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Project__c != null AND Status__c = 'Active' LIMIT 2];
        List<AcctSeed__Time_Card_Day__c> tcdList = [SELECT Id, Name, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c LIMIT 2];
        List<AcctSeed__Project_Task__c> proTaskList = [SELECT Id, Name, AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 2];
        
        if(usrList.size() > 0 && conAssList.size() > 0 && tcdList.size() > 0 && proTaskList.size() > 0) {
  
            Set<Id> tclId = new set<Id>();
           
            tclId.add(tcdList[0].AcctSeed__Time_Card_Line__c);
            tclId.add(tcdList[1].AcctSeed__Time_Card_Line__c);
            
            List<AcctSeed__Time_Card_Line__c> tclList = [SELECT Id, Name, AcctSeed__Time_Card__c FROM AcctSeed__Time_Card_Line__c WHERE Id IN :tclId];
           
            if(tclList.size() > 0) {
                
                tclList[0].AcctSeed__Project_Task__c = proTaskList[0].Id;
                update tclList;
             
                List<AcctSeed__Time_Card__c> tcList = [SELECT Id, Name, Intructor__c FROM AcctSeed__Time_Card__c WHERE Id = :tclList[0].AcctSeed__Time_Card__c];
                
                if(tcList.size() > 0) {
                    
                    List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :tcList[0].Intructor__c];
                    List<RecordType> conRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Candidate' AND SobjectType = 'Contact'];
                    
                    if(conList.size() > 0 && conRt.size() > 0) {
                        
                        conAssList[0].Project__c = proTaskList[0].AcctSeed__Project__c;
                        conAssList[1].Project__c = proTaskList[1].AcctSeed__Project__c;
                        conAssList[0].Candidate_Name__c = conList[0].Id;
                        conAssList[1].Candidate_Name__c = conList[0].Id;
                        update conAssList;
                        
                        tcdList[0].Status__c = 'Submitted';
                        tcdList[1].Status__c = 'Submitted';
                        update tcdList;
                        
                        conList[0].LastName = usrList[0].LastName;
                        conList[0].FirstName = usrList[0].FirstName;
                        conList[0].RecordTypeId = conRt[0].Id;
                        update conList;
                        
                        supervisorTimeApproval_Ctrl.getInstructor_WholeWeekValues(usrList[0].Id);
                        
                        conList[0].Supervisor_Name__c = UserInfo.getUserId();
                        update conList;
                        Date dt = system.today();
                        tcdList[0].AcctSeed__Date__c = dt.toStartofWeek().addDays(4);
                        //update tcdList;
                        
                        conList[0].LastName = UserInfo.getLastName();
                        update conList;
                        
                        TimeCardDayDomain.WrapperClass ret = supervisorTimeApproval_Ctrl.getInstructor_WholeWeekValues('--None--');
                        String retval = string.valueOf(ret);
                        if(retVal != null && retVal != '') 
                            System.assert(retVal.contains(UserInfo.getTimeZone().getID()));
                    }
                }                
            }
        }
        Test.StopTest();
    } 
    
    // For Summary information Qry for Last week & This Week filter conditions
    private static testMethod void testMethod3() {
        
        Test.StartTest();
        //List<User> usrList = [SELECT Id, Name, FirstName, LastName FROM User LIMIT 2];
        List<User> usrList = insUserRecords('Insert', 'three');
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Project__c != null AND Status__c = 'Active' LIMIT 2];
        List<AcctSeed__Time_Card_Day__c> tcdList = [SELECT Id, Name, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c LIMIT 2];
        Date stDate = System.today(), endDate = System.today().addDays(30);
       
        if(usrList.size() > 0 && conAssList.size() > 0 && tcdList.size() > 0) {    
            
            tcdList[0].AcctSeed__Date__c = System.today();
            update tcdList;
            
            Set<Id> tclId = new set<Id>();
           
            tclId.add(tcdList[0].AcctSeed__Time_Card_Line__c);
            tclId.add(tcdList[1].AcctSeed__Time_Card_Line__c);
            
            List<AcctSeed__Time_Card_Line__c> tclList = [SELECT Id, Name, AcctSeed__Time_Card__c FROM AcctSeed__Time_Card_Line__c WHERE Id IN :tclId];
           
            if(tclList.size() > 0) {
               
                List<AcctSeed__Time_Card__c> tcList = [SELECT Id, Name, Intructor__c FROM AcctSeed__Time_Card__c WHERE Id = :tclList[0].AcctSeed__Time_Card__c];
                
                if(tcList.size() > 0) {
                    
                    List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :tcList[0].Intructor__c];
                    List<RecordType> conRt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName IN ('DLS_Employee', 'Candidate') AND SobjectType = 'Contact'];
                    
                    if(conList.size() > 0 && conRt.size() > 0) {
                        
                        Id dlsId, candiId;
                        
                        for(RecordType rt : conRt) {
                            if(rt.DeveloperName == 'DLS_Employee')
                                dlsId = rt.Id;
                            if(rt.DeveloperName == 'Candidate')
                                candiId = rt.Id;
                                
                        }
                        
                        conList[0].Supervisor_Name__c = usrList[0].Id;
                        conList[0].RecordTypeId = dlsId;
                        update conList;
                        
                        conAssList[0].Candidate_Name__c = conList[0].Id;
                        conAssList[1].Candidate_Name__c = conList[0].Id;
                        update conAssList;
                        
                        tcdList[0].Status__c = 'Submitted';
                        tcdList[1].Status__c = 'Submitted';
                        update tcdList;
                        
                        conList[0].LastName = usrList[0].LastName;
                        conList[0].FirstName = usrList[0].FirstName;
                        update conList;
                        
                        supervisorTimeApproval_Ctrl.getSummaryInfoForWeekRange(String.valueOf(stDate), String.valueOf(endDate), 'Internal',usrList[0].Id);
                        
                        conList[0].Supervisor_Name__c = UserInfo.getUserId();
                        update conList;
                        
                        conList[0].LastName = UserInfo.getLastName();
                        conList[0].RecordTypeId = candiId;
                        update conList;
                        
                        TimeCardDayDomain.WrapperClass ret = supervisorTimeApproval_Ctrl.getSummaryInfoForWeekRange(String.valueOf(stDate), String.valueOf(endDate), 'Instructor','--None--');
                        String retval = string.valueOf(ret);
                        if(retVal != null && retVal != '') 
                            System.assert(retVal.contains(UserInfo.getTimeZone().getID()));
                    }
                }        
            }
        }
        Test.StopTest();
    } 
    
     // For Specific date range semi monthly view data formation
    private static testMethod void testMethod4() {
        
        Test.StartTest();
        Date stDate = System.today(), endDate = System.today().addDays(30);
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Project__c != null AND Status__c = 'Active' LIMIT 2];
        List<AcctSeed__Time_Card_Day__c> tcdList = [SELECT Id, Name, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c LIMIT 2];
        
        if(conAssList.size() > 0 && tcdList.size() > 0) {
            
            Set<Id> tclId = new set<Id>();
            
            tclId.add(tcdList[0].AcctSeed__Time_Card_Line__c);
            tclId.add(tcdList[1].AcctSeed__Time_Card_Line__c);
            
            List<AcctSeed__Time_Card_Line__c> tclList = [SELECT Id, Name, AcctSeed__Time_Card__c FROM AcctSeed__Time_Card_Line__c WHERE Id IN :tclId];
           
            if(tclList.size() > 0) {
               
                List<AcctSeed__Time_Card__c> tcList = [SELECT Id, Name, Intructor__c FROM AcctSeed__Time_Card__c WHERE Id = :tclList[0].AcctSeed__Time_Card__c];
                
                if(tcList.size() > 0) {
                    
                    List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :tcList[0].Intructor__c];
                    List<RecordType> conRt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Candidate' AND SobjectType = 'Contact'];
                    
                    if(conList.size() > 0 && conRt.size() > 0) {
                        
                        conAssList[0].Candidate_Name__c = conList[0].Id;
                        conAssList[1].Candidate_Name__c = conList[0].Id;
                        update conAssList;
                        
                        tcdList[0].Status__c = 'Submitted';
                        tcdList[1].Status__c = 'Submitted';
                        update tcdList;
                                                
                        conList[0].LastName = UserInfo.getLastName();
                        conList[0].RecordTypeId = conRt[0].Id;
                        update conList;
                                                
                        supervisorTimeApproval_Ctrl.getSemiMonthly_TimeRecords(String.valueOf(stDate), String.valueOf(endDate), 'Internal');
                        
                        stDate = system.today().toStartofWeek().addDays(1);
                        
                        insUserRecords('Update', 'four');
                        conList[0].FirstName = UserInfo.getFirstName();
                        update conList;
                        
                        TimeCardDayDomain.Approval_SemiMonthlyWrapper ret = supervisorTimeApproval_Ctrl.getSemiMonthly_TimeRecords(String.valueOf(stDate), String.valueOf(endDate), 'Instructor');
                        String retVal = string.valueOf(ret);
                        if(retVal != null && retVal != '') 
                            System.assert(retVal.contains('dateSummaryDetailMap'));
                    }
                }
            }
        }
        Test.StopTest();
    } 
    
    // To cover contact_Date_SummarydataFormation() method in TimeCardDayTranslator
    private static testMethod void testMethod4a() {
        
        List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Name FROM AcctSeed__Cost_Rates__c WHERE AcctSeed__Hourly_Cost__c != null LIMIT 1];
        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id,Payroll_Item__c,Labor_Cost_Rate__c FROM AcctSeed__Time_Card_Line__c];
        timeCardLine[0].Labor_Cost_Rate__c = costRates[0].Id;
        update timeCardLine[0];
        
        List<AcctSeed__Time_Card_Day__c> timeCardDay = new List<AcctSeed__Time_Card_Day__c> {
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = system.today().addDays(1),Status__c = 'Draft'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = system.today().addDays(2),Status__c = 'Draft'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(3),Status__c = 'Draft'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(4),Status__c = 'Draft'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[1].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(4),Status__c = 'Draft')
        };
        List<Date> daysList = new List<Date>();
        TimeCardDayTranslator.contact_Date_SummarydataFormation(timeCardDay, daysList);
    } 
    
    // To cover summaryDetailsFormation() method in TimeCardDayTranslator
    private static testMethod void testMethod4b() {
        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id,Payroll_Item__c FROM AcctSeed__Time_Card_Line__c];
        
        List<AcctSeed__Time_Card_Day__c> timeCardDay = new List<AcctSeed__Time_Card_Day__c> {
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = system.today().addDays(1),Status__c = 'Draft'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = system.today().addDays(2),Status__c = 'Draft'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(3),Status__c = 'Draft'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(4),Status__c = 'Draft'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[1].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(4),Status__c = 'Draft')
        };
        List<Date> daysList = new List<Date>();
        TimeCardDayTranslator.summaryDetailsFormation(timeCardDay, daysList);
    } 
    
    // For Inserting / Updating the User Record based on the Parameter
    private static List<User> insUserRecords(String dmlOperation, String tempStr) {
        
        List<User> userList = new List<User>();

        if(dmlOperation == 'Insert') {
            List<RecordType> conRt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'DLS_Employee'];
        
            if(conRt.size() > 0) {
                
                List<Contact> con = new List<Contact> { 
                    new Contact(LastName = 'TestCont1'+tempStr,Email = tempStr+'test1@test.com', RecordTypeId = conRt[0].Id),
                    new Contact(LastName = 'TestCont2'+tempStr,Email = tempStr+'test2@testcon.com', RecordTypeId = conRt[0].Id)
                };
                insert con;
                
                List<Profile> profileUser = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
                String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc'+tempStr;
                
                if(profileUser.size() > 0) {
                    userList = new List<User>{        
                        new User(Alias = 'standt', Email = 'demotest@gmail.com',EmailEncodingKey = 'UTF-8', LastName = 'demoCon', FirstName = 'demoTest',
                        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profileUser[0].Id, DelegatedApproverId = UserInfo.getUserId(),
                        TimeZoneSidKey = 'America/Los_Angeles', UserName = un)
                    };
                    insert userList;
                }
            }  
        } else {
            userList = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
            
            if(userList.size() > 0) {
                userList[0].FirstName = 'Company';
                update userList;
            }
        }        
        return userList;
    }
    
    // For updating time card day records
    private static testMethod void testMethod5() {
        
        Test.StartTest();
        List<AcctSeed__Time_Card_Day__c> tcdList = [SELECT Id, Name FROM AcctSeed__Time_Card_Day__c LIMIT 2];
        
        if(tcdList.size() > 0) {
            
            tcdList[0].Status__c = 'Submitted';
            tcdList[1].Status__c = 'Draft';
                        
            supervisorTimeApproval_Ctrl.updateTimecardDayrecords(JSON.serialize(tcdList), 'ApproveAll', 'ApproveAll');
            supervisorTimeApproval_Ctrl.updateTimecardDayrecords(JSON.serialize(tcdList), 'RejectAll', 'RejectAll');
            supervisorTimeApproval_Ctrl.updateTimecardDayrecords(JSON.serialize(tcdList), 'Partial', 'Partial');
            
            List<AcctSeed__Time_Card_Day__c> tcdListUp = [SELECT Id, Name, Status__c FROM AcctSeed__Time_Card_Day__c WHERE Id = :tcdList[1].Id];
            if(tcdListUp.size() > 0)
                System.assertEquals('Draft', tcdListUp[0].Status__c);
        }
        Test.StopTest();
    } 
    
    // For getting the logged in user (Gelegated approver) related user records
    private static testMethod void testMethod6() {
        
        Test.StartTest();
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        List<RecordType> pdoRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Staff_Planned_Days_Off' AND SobjectType = 'Planned_Days_Off__c'];
        List<User> usrList = insUserRecords('Insert', 'one');
        if(conList.size() > 0 && pdoRt.size() > 0 && usrList.size() > 0) {
            
            conList[0].DLS_User__c = usrList[0].Id;
            conList[0].DLS_User__c = usrList[0].Id;
            update conList;
            
            List<Planned_Days_Off__c> pdoList = new List<Planned_Days_Off__c> {
                new Planned_Days_Off__c(Contact__c = conList[0].Id, Date__c = System.today(), Description__c = 'Test', Requested_Reschedule_Date__c = System.today().addDays(-1), RecordTypeId = pdoRt[0].Id),
                new Planned_Days_Off__c(Contact__c = conList[1].Id, Date__c = System.today(), Description__c = 'Test', Requested_Reschedule_Date__c = System.today().addDays(-1), RecordTypeId = pdoRt[0].Id)
            };
            insert pdoList;
            
            List<User> retval = supervisorTimeApproval_Ctrl.getDelegatedApproverRelatedUsrs();
            System.assertEquals(usrList[0].Id, retval[0].Id);
        }
        Test.StopTest();
    }
        
    // Added by HL
    // To call approve_RejectAll_EmailMethod method in timeCardRelated_Email_Controller (ApproveAll)
    public static testMethod void myTestMethod1(){
                    
        Test.startTest();    
        List<Contact> conList1 = [SELECT Id, Active_DLS_Employee__c  FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee'];
        conList1[0].Active_DLS_Employee__c = TRUE;
        update conList1[0];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList1[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
                
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList1[0].Id;
        update timeCard;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        Set<Id> dayId = new Set<Id>();
        dayId.add(day.Id);
        
        try{
            timeCardRelated_Email_Controller.approve_RejectAll_EmailMethod(dayId, 'ApproveAll');
        }catch(Exception e){
        
            System.debug('============'+e.getLineNUmber());
        }
        
        Test.stopTest();
    }
    
    // To call approve_RejectAll_EmailMethod method in timeCardRelated_Email_Controller (RejectAll)
    public static testMethod void myTestMethod2(){
                       
        Test.startTest();
         
        List<Contact> conList = [SELECT Id, Active_DLS_Employee__c  FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee'];
        conList[0].Active_DLS_Employee__c = TRUE;
        update conList[0];        
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
                        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                  
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        Set<Id> dayId = new Set<Id>();
        dayId.add(day.Id);
        try{
            timeCardRelated_Email_Controller.approve_RejectAll_EmailMethod(dayId, 'RejectAll');
        }catch(Exception e){
        
            System.debug('============'+e.getLineNUmber());
        }
        Test.stopTest();
    }
    
    // To call partial_approve_Reject_EmailMethod method in timeCardRelated_Email_Controller
    public static testMethod void myTestMethod3(){
                    
        Test.startTest();
            
        List<Contact> conList = [SELECT Id, Active_DLS_Employee__c  FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee'];
        conList[0].Active_DLS_Employee__c = TRUE;
        update conList[0];
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
                        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                  
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        Set<Id> dayId = new Set<Id>();
        dayId.add(day.Id);
        try{
            timeCardRelated_Email_Controller.partial_approve_Reject_EmailMethod(dayId);
        }catch(Exception e){
        
            System.debug('============'+e.getLineNUmber());
        }
        Test.stopTest();
    }
    
    // To cover contact_Date_SummarydataFormation() method in TimeCardDayTranslator
    private static testMethod void testMethod7() {
        
        List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Name FROM AcctSeed__Cost_Rates__c WHERE AcctSeed__Hourly_Cost__c != null LIMIT 1];
        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id,Payroll_Item__c,Labor_Cost_Rate__c FROM AcctSeed__Time_Card_Line__c];
        timeCardLine[0].Labor_Cost_Rate__c = costRates[0].Id;
        update timeCardLine[0];
        
        Test.startTest();
                    
            List<AcctSeed__Time_Card_Day__c> timeCardDay = new List<AcctSeed__Time_Card_Day__c> {
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = system.today().addDays(1),Status__c = 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = system.today().addDays(2),Status__c = 'Submitted'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(3),Status__c = 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(4),Status__c = 'Submitted'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[1].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(4),Status__c = 'Draft')
            };
            List<Date> daysList = new List<Date>();
            
            List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, Name, AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__c, AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Day__c WHERE Id IN : timeCardDay];
            TimeCardDayTranslator.contact_Date_SummarydataFormation(days, daysList);
            
        Test.stopTest();
    } 
    
    // To cover daily_SummaryDetailsFormation() method in TimeCardDayTranslator
    private static testMethod void testMethod8() {
    
        Test.startTest();
        
        List<AcctSeed__Project__c> proj = [SELECT Id FROM AcctSeed__Project__c WHERE RecordType.DeveloperName = 'Admin_Projects' LIMIT 1];
        
        List<Contact> conList = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        conList[0].Home_Department_Project__c = proj[0].Id;
        update conList[0];
                
        List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Name FROM AcctSeed__Cost_Rates__c WHERE AcctSeed__Hourly_Cost__c != null LIMIT 1];
                        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id,Payroll_Item__c,Labor_Cost_Rate__c, Sequence_Number__c FROM AcctSeed__Time_Card_Line__c];
        timeCardLine[0].Labor_Cost_Rate__c = costRates[0].Id;
        update timeCardLine[0];
                
        List<AcctSeed__Time_Card_Line__c> lines1 = [SELECT Id, Display_in_Future_Weeks__c FROM AcctSeed__Time_Card_Line__c WHERE Id != :timeCardLine[0].Id];
        lines1[0].Display_in_Future_Weeks__c = TRUE;
        update lines1[0];
                                
            List<AcctSeed__Time_Card_Day__c> timeCardDay = new List<AcctSeed__Time_Card_Day__c> {
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = system.today().addDays(1),Status__c = 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = system.today().addDays(2),Status__c = 'Submitted'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(3),Status__c = 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(4),Status__c = 'Submitted')
            };
            List<Date> daysList = new List<Date>();
            try{
                TimeCardDayTranslator.daily_SummaryDetailsFormation(timeCardLine, System.Today(), System.Today().addDays(3), conList, lines1, proj, new List<AcctSeed__Project_Task__c>(), new List<Contact_Assignments__c>() , new List<Project_Task_Master__c>(), new Set<Date>());
            }catch(Exception e){
                System.debug('::::'+e.getMessage());
            }
        Test.stopTest();
    }
    
    // To cover instructorDayRowFormation() method in TimeCardDayTranslator
    private static testMethod void testMethod9() {
        
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 1];
        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id,AcctSeed__Project__c, AcctSeed__Project_Task__c, Payroll_Item__c, AcctSeed__Billable__c, Location__c FROM AcctSeed__Time_Card_Line__c];
        
        Test.startTest();
        
        List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Name FROM AcctSeed__Cost_Rates__c WHERE AcctSeed__Hourly_Cost__c != null LIMIT 1];
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, AcctSeed__Project__c, AcctSeed__Project__r.DLS_Class__c, Project_Task_Type__c, AcctSeed__Project__r.Training_Location__c, AcctSeed__Project__r.Training_Location__r.Name, Billable__c, RecordType.DeveloperName, Payroll_Item__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' LIMIT 1];
                
            List<AcctSeed__Time_Card_Day__c> timeCardDay = new List<AcctSeed__Time_Card_Day__c> {
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = system.today().addDays(1),Status__c = 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = system.today().addDays(2),Status__c = 'Submitted'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(3),Status__c = 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(4),Status__c = 'Submitted'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[1].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(4),Status__c = 'Draft')
            };
            List<Date> daysList = new List<Date>();
            TimeCardDayTranslator.instructorDayRowFormation(System.Today(), System.Today().addDays(3), conList[0].Name, timeCardLine, task, new List<Contact_Assignments__c>() , new Map<Id,Integer>(), new Map<Id,String>(),new List<Contact_Assignments__History>(),costRates);
            
        Test.stopTest();
    } 
    
    private static testMethod void myTestMethod10(){
    
        List<Planned_Days_Off__c> pdo = [SELECT Id, Name, Contact__c, Contact__r.Name, Date__c, Description__c FROM Planned_Days_Off__c LIMIT 3];
        TimeCardDayTranslator.instructorTimeEntryRowWrapperFormation(System.Today(),System.Today().addDays(5), pdo[0].Contact__r.Name, pdo[0].Contact__c, new List<AcctSeed__Time_Card_Line__c>(),new List<Accounting_Seed_Time_Snapshot__c>(),new List<AcctSeed__Project_Task__c>(),new List<Contact_Assignments__c>(), new Map<Id,Integer>(),new Map<Id,String>(),new List<Contact_Assignments__History>(),new List<AcctSeed__Cost_Rates__c>(),new List<Contact_Assignments__c>(),new Map<Id,List<Attendance__c>>(),pdo,new Set<Date>());
    }
    
    // Method to cover timeCardDayFormation() in TimeCardDayTranslator
    public static testMethod void myTestMethod11() {
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                                 
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
                
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        schList[0].Instructor__c = conList[0].Id;
        schList[0].Start_Time__c = '03:00 PM';
        schList[0].End_Time__c = '05:00 PM';
        update schList;
        
        List<Events__c> eve = [SELECT Id FROM Events__c LIMIT 1];
        eve[0].Schedule__c = schList[0].Id;
        eve[0].SequenceNo__c = 1;
        eve[0].Instructor__c = conList[0].Id;
        eve[0].Date__c = weekStart1;
        eve[0].Project__c = task[0].AcctSeed__Project__c;
        eve[0].Status__c = 'Scheduled';
        update eve[0];
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(6)};
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
        
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Unposted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Unposted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(2), Status__c = 'Unposted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(3), Status__c = 'Unposted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(4), Status__c = 'Unposted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(5), Status__c = 'Unposted'), 
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(6), Status__c = 'Unposted')
        };
        insert days;
        
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, 
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, 
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, Status__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE Id = :timeCardLine.Id];
                
        System.runAs(user){
            TimeCardDayTranslator.timeCardDayFormation(lines, dateList, conList[0].Id);
        }
        
        Test.stopTest();
    }
}