@isTest
public class timeCardDayTrigger_Test {
    
    @testSetup static void setup(){    
        List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        Test.startTest();
            List<AcctSeed__Time_Card_Day__c> timeCardDayList = TestClassUtil.createTestTimeCardDay();
             List<Events__c> events = TestClassUtil.createTestEvent();
        Test.stopTest();
        List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
    }
    
    static testmethod void test1() {
        Test.StartTest();
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = [Select Id,Name, Status__c From AcctSeed__Time_Card_Day__c];
        system.debug(':::timeCardDayList:::'+timeCardDayList); 
        
        // Declare value for static value in class
        DLS_Staff_Time_Entry_Ctrl.isGroupAction = false;
        
        //timeCardDayList[0].Late_Cancellation__c = 'Late';
        timeCardDayList[0].Status__c = 'Approved';
        update timeCardDayList;
        system.debug(':::timeCardDayList:::'+timeCardDayList[0]);
        
        //timeCardDayList[1].Late_Cancellation__c = 'Early';
        timeCardDayList[1].Status__c = 'Rejected';
        update timeCardDayList[1];
        system.debug(':::timeCardDayList:::'+timeCardDayList[1]);
        Test.StopTest(); 
    }
    
    public static testMethod void testMethod1() {
         
        List<Contact> conList = [SELECT Id,Name FROM Contact LIMIT 2];
        
        Test.StartTest();
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Hours__c,Status__c,AcctSeed__Time_Card_Line__c,
                                                                 Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c
                                                         FROM AcctSeed__Time_Card_Day__c 
                                                         LIMIT 3];
        
        System_Values__c sysVal = new System_Values__c();
        sysVal.Name = 'TimeLog_Locking_Date';
        sysVal.Value__c = String.valueOf(system.today().addDays(-30));
        
        insert sysVal;
        
        List<Profile> Profile = [SELECT Id FROM Profile WHERE Name = 'Timekeeping'];
        
        String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
        String en = String.valueOf(System.now().millisecond())+'@dlsTestOrg.com';
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User usr = new User(Alias = 'standt', Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8', LastName='Testing', 
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = Profile[0].Id, contact=conList[0], 
            TimeZoneSidKey='America/Los_Angeles', UserName = uniqueName + '@test' + orgId + '.org');
            
        insert usr;
        
        // Declare value for static value in class
        DLS_Staff_Time_Entry_Ctrl.isGroupAction = false;
        
         try {
             System.runAs(usr) {
                timeCardDayList[0].Total_Hours_Before_Approved__c = 3;
                update timeCardDayList[0];
            } 
            delete timeCardDayList[0];
            
        }catch(Exception e) {
            system.debug(':::::::::erro::::::'+e.getMessage());
            Boolean expectedExceptionThrown;
            
            if(e.getMessage().contains('You cannot delete Time Card Day record')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('You cannot edit Time Card Day record after Time Card Day locking period')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('Insufficient Privilege')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('Please update Time Card Day comments')) {
                expectedExceptionThrown = true;
            }
            
            
            //System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.StopTest();

     }
    public static testMethod void testMethod2() {
        List<Contact> conList = [SELECT Id,Name FROM Contact LIMIT 2];
        
        Id instructorTypeId;
        
        Test.StartTest();
        for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact']){
            if(rt.DeveloperName == 'DLS_Employee'){
                instructorTypeId = rt.Id;
            }
        }
        conList[0].RecordTypeId = instructorTypeId;
        update conList;
        
        
        
        List<AcctSeed__Project_Task__c> projTask1 = [SELECT Id,AcctSeed__Labor_GL_Account__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 1];
        
        
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Hours__c,Status__c,AcctSeed__Time_Card_Line__c,
                                                                 Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c
                                                         FROM AcctSeed__Time_Card_Day__c 
                                                         LIMIT 3];
        //List<AcctSeed__Project__c> projt = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 1];
        
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c> {
            new AcctSeed__Project_Task__c(Name = 'Bonus Leave Earned',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = projTask1[0].AcctSeed__Project__c,Project_Task_Type__c = 'Language Training',Rate__c = 41,AcctSeed__Labor_GL_Account__c = projTask1[0].AcctSeed__Labor_GL_Account__c)
        };
        
        insert projTask;
          
          
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id,AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Line__c WHERE Id = :timeCardDayList[0].AcctSeed__Time_Card_Line__c];
        timeCardLine[0].AcctSeed__Project_Task__c = projTask[0].Id;
        update timeCardLine;
        
        Test.StopTest();
           
    }
    
    // Time Card Day updated with Approved status for Bonus Leave Earned PT
    public static testMethod void myTestMethod1(){
                        
            List<Contact> conList1 = [SELECT Id, Active_DLS_Employee__c  FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' AND LastName='StaffContact' LIMIT 1];
            conList1[0].Active_DLS_Employee__c = TRUE;
            update conList1[0];
            System.debug('conList1==='+conList1);
            
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' AND Id =:conList1[0].Id];
            
            Test.startTest();
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            System.debug('projects========'+projects);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
            
            List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c> {
                new AcctSeed__Project_Task__c(Name = 'Bonus Leave Earned',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = task[0].AcctSeed__Project__c,Project_Task_Type__c = 'Language Training',Rate__c = 41,AcctSeed__Labor_GL_Account__c = task[0].AcctSeed__Labor_GL_Account__c)
            };
            
            insert projTask;
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
                      
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = projTask[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
            insert day;
            
            try{
                List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, Status__c FROM AcctSeed__Time_Card_Day__c WHERE Id  =:day.Id];
                days[0].Status__c = 'Approved';
                update days[0];
            }catch(Exception e){
            
                 system.debug('Exception:'+e+e.getLineNumber());
            }
            Test.stopTest();
    }
    
    // Time Card Day updated with Rejected status for Bonus Leave Earned PT
    public static testMethod void myTestMethod2(){
                        
            List<Contact> conList1 = [SELECT Id, Active_DLS_Employee__c  FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' AND LastName='StaffContact' LIMIT 1];
            conList1[0].Active_DLS_Employee__c = TRUE;
            update conList1[0];
            System.debug('conList1==='+conList1);
            
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' AND Id =:conList1[0].Id];
            
            Test.startTest();
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            System.debug('projects========'+projects);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
            
            List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c> {
                new AcctSeed__Project_Task__c(Name = 'Bonus Leave Earned',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = task[0].AcctSeed__Project__c,Project_Task_Type__c = 'Language Training',Rate__c = 41,AcctSeed__Labor_GL_Account__c = task[0].AcctSeed__Labor_GL_Account__c)
            };
            
            insert projTask;
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
                      
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = projTask[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
            insert day;
            
            try{
                List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, Status__c FROM AcctSeed__Time_Card_Day__c WHERE Id  =:day.Id];
                days[0].Status__c = 'Rejected';
                update days[0];
            }catch(Exception e){
            
                 system.debug('Exception:'+e+e.getLineNumber());
            }
            Test.stopTest();
    }
    
    // Added by HL
    public static testMethod void sendEmailTestMethod1(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        Date PrevDate;
        
         if(todayVal.format('EEEE') == 'Monday')
            PrevDate = system.today().addDays(-3);
        else
            PrevDate = system.today().addDays(-1);
            
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
            System.debug('conList==='+conList);
                        
            Test.startTest();
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Time_Approval_Preference__c = 'Daily';
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            System.debug('projects========'+projects);
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
          
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = PrevDate,Student_Approval_Status__c = 'Submitted');
            insert day;
            
            Test.stopTest();
    }
    
    // CA with Planned_Days_Off__c Record
    public static testMethod void sendEmailTestMethod2(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        Date PrevDate;
        
         if(todayVal.format('EEEE') == 'Monday')
            PrevDate = system.today().addDays(-3);
        else
            PrevDate = system.today().addDays(-1);
            
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
            System.debug('conList==='+conList);
            
            Id insRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
            Contact c = new Contact(LastName  = 'My TestContact', Email = 'test@gmail.com', RecordTypeId = insRT );
            insert c;
            
            Test.startTest();
            
                Planned_Days_Off__c pdo = new Planned_Days_Off__c(Contact__c = conList[0].Id,Date__c=System.today(),Description__c='Test',Requested_Reschedule_Date__c=System.today()+15, Status__c = 'Approved');
                insert pdo;
                        
                List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 2];
                conAss[0].Candidate_Name__c = conList[0].Id;
                conAss[0].Assignment_Position__c = 'Class Leader';
                conAss[1].Candidate_Name__c = c.Id;
                conAss[1].Assignment_Position__c = 'Class Leader';
                conAss[0].Time_Approval_Preference__c = 'Daily';
                //conAss[1].Time_Approval_Preference__c = 'Daily';
                update conAss; 
                System.debug('conAss======='+conAss);
                
                List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
                System.debug('projects========'+projects);
            
                List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
                timeCard[0].Intructor__c = conList[0].Id;
                update timeCard;
                System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
                
                List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
                System.debug('task ====='+task);
              
                AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
                timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
                timeCardLine.AcctSeed__Project__c = projects[0].Id;
                timeCardLine.AcctSeed__Billable__c = TRUE;
                timeCardLine.Payroll_Item__c = 'ADM';
                timeCardLine.Contact_Assignment__c = conAss[0].Id;
                timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
                insert timeCardLine;
                
                AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = PrevDate,Student_Approval_Status__c = 'Submitted');
                insert day;
            
            Test.stopTest();
    }
    
    public static testMethod void sendEmailTestMethod3(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        Date PrevDate;
        
         if(todayVal.format('EEEE') == 'Monday')
            PrevDate = system.today().addDays(-3);
        else
            PrevDate = system.today().addDays(-1);
            
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
            System.debug('conList==='+conList);
                        
            Test.startTest();
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Time_Approval_Preference__c = 'Daily';
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            System.debug('projects========'+projects);
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
          
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = PrevDate,Student_Approval_Status__c = 'Submitted');
            insert day;
            
            List<Schedule__c> schedule = [SELECT Id FROM Schedule__c WHERE Project_Task__c = :task[0].Id];
            
            List<Events__c> eve = [SELECT Id, No_Student_Approval__c FROM Events__c WHERE Schedule__c = :schedule[0].Id];
            eve[0].No_Student_Approval__c = FALSE;
            eve[0].Time_Card_Day__c = day.Id;
            update eve[0];
                
            try{
            
                List<AcctSeed__Time_Card_Day__c > day1 = [SELECT Id, Status__c, AcctSeed__Hours__c  FROM AcctSeed__Time_Card_Day__c WHERE Id = :day.Id];
                day1[0].Student_Approval_Status__c = 'Rejected';
                update day1;
                
                List<AcctSeed__Time_Card_Day__c > dayRec = [SELECT Id, Status__c, AcctSeed__Hours__c  FROM AcctSeed__Time_Card_Day__c WHERE Id = :day1[0].Id];
                dayRec[0].Student_Approval_Status__c = 'Submitted';
                dayRec[0].AcctSeed__Hours__c = 4;
                update dayRec;
                
            }catch(Exception e){
                System.debug('============='+e.getMessage());
            }
            
            Test.stopTest();
    }
    
    // Added by HL
    public static testMethod void populateTimeAndDurationforEve1(){
    
        Test.startTest();
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
            System.debug('conList==='+conList);
                    
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
            
            List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c>();
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training' LIMIT 1];
            System.debug('task ====='+task);
            
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
            schList[0].Status__c = 'Active';
            update schList;
            System.debug('schList===='+schList);
            
            timeCardLine = new List<AcctSeed__Time_Card_Line__c> {
                new AcctSeed__Time_Card_Line__c(AcctSeed__Time_Card__c = timeCard[0].Id,AcctSeed__Project_Task__c = task[0].Id, AcctSeed__Project__c = task[0].AcctSeed__Project__c)    
            };
            insert timeCardLine;
            System.debug('timeCardLine====='+timeCardLine[0].AcctSeed__Project__r.RecordType.DeveloperName);
        
            Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine[0].AcctSeed__Project__c,Status__c = 'Scheduled');
            insert event;
            System.debug('event ========='+event );
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Student_Approval_Status__c = 'Submitted');
            insert day;
            System.debug('day========='+day);
        Test.stopTest();
    }
    
     public static testMethod void populateTimeAndDurationforEve2(){
    
        Test.startTest();
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
            System.debug('conList==='+conList);
                    
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
            
            List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c>();
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training' LIMIT 1];
            task[0].Project_Task_Type__c = 'Preparation time';
            update task;
            System.debug('task ====='+task);
            
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
            schList[0].Status__c = 'Active';
            update schList;
            System.debug('schList===='+schList);
            
            timeCardLine = new List<AcctSeed__Time_Card_Line__c> {
                new AcctSeed__Time_Card_Line__c(AcctSeed__Time_Card__c = timeCard[0].Id,AcctSeed__Project_Task__c = task[0].Id, AcctSeed__Project__c = task[0].AcctSeed__Project__c)    
            };
            insert timeCardLine;
            System.debug('timeCardLine====='+timeCardLine[0].AcctSeed__Project__r.RecordType.DeveloperName);
            
            
            List<Events__c> events = new List<Events__c>{
                new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine[0].AcctSeed__Project__c,Status__c = 'Scheduled', Start_Time__c = '06:00 AM', End_Time__c = '06:45 PM'),
                new Events__c(Name = '15-00687-SH1-EV2',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine[0].AcctSeed__Project__c,Status__c = 'Scheduled', Start_Time__c = '09:00 PM', End_Time__c = '09:45 PM')
            };
            insert events;
            System.debug('events==========='+events);
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Student_Approval_Status__c = 'Submitted', Start_Time1__c = '06:00 AM', Start_Time2__c = '09:00 PM', End_Time1__c = '06:45 AM', End_Time2__c = '09:30 PM');
            insert day;
            System.debug('day========='+day);
        Test.stopTest();
    }
    
    public static testMethod void populateTimeAndDurationforEve3(){
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c>();
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training' LIMIT 1];
        System.debug('task ====='+task);
        
        Test.startTest();
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
            schList[0].Status__c = 'Active';
            update schList;
            System.debug('schList===='+schList);
            
            timeCardLine = new List<AcctSeed__Time_Card_Line__c> {
                new AcctSeed__Time_Card_Line__c(AcctSeed__Time_Card__c = timeCard[0].Id,AcctSeed__Project_Task__c = task[0].Id, AcctSeed__Project__c = task[0].AcctSeed__Project__c)    
            };
            insert timeCardLine;
            System.debug('timeCardLine====='+timeCardLine[0].AcctSeed__Project__r.RecordType.DeveloperName);
        
            Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine[0].AcctSeed__Project__c,Status__c = 'Scheduled');
            insert event;
            System.debug('event ========='+event );
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Status__c= 'Draft');
            insert day;
            System.debug('day========='+day);
            
            //List<Events__c> events = [SELECT ID, Status__c FROM Events__c WHERE Id = :event.Id];            
            System.debug('========EVENTS====='+[SELECT Id, Time_Card_Day__c, Status__c FROM Events__c]);
            
            List<AcctSeed__Time_Card_Day__c > dayRec = [SELECT Id, Status__c FROM AcctSeed__Time_Card_Day__c WHERE Id = :day.Id];
            dayRec[0].Status__c = 'Unposted';
            update dayRec;
            
        Test.stopTest();
    }
    
    public static testMethod void stdRejectionNotifyTestMthd1(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
                    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                    
        Test.startTest();
            List<Contact_Assignments__c> caUpdate = new List<Contact_Assignments__c>();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            List<Contact_Assignments__c> conAss1 = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Time_Approval_Preference__c = 'Daily';
            conAss1[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Paper_Timesheet__c = FALSE;
            conAss1[0].Paper_Timesheet__c = FALSE;
            caUpdate.add(conAss[0]);
            caUpdate.add(conAss1[0]);
            update caUpdate; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            System.debug('projects========'+projects);
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
          
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
            schList[0].Status__c = 'Active';
            update schList;
            System.debug('schList===='+schList);
        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Student_Approval_Status__c = 'Submitted');
            insert day;
            
            Events__c event = new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = day.Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
            insert event;
            
            try{
            
                List<AcctSeed__Time_Card_Day__c > day1 = [SELECT Id, Status__c, AcctSeed__Hours__c  FROM AcctSeed__Time_Card_Day__c WHERE Id = :day.Id];
                day1[0].Student_Approval_Status__c = 'Rejected';
                update day1;
                                
            }catch(Exception e){
                System.debug('============='+e.getMessage());
            }
        Test.stopTest();
    }
    
    public static testMethod void lateCancellationMail(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                        
            Test.startTest();
            
                List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
                conAss[0].Candidate_Name__c = conList[0].Id;
                conAss[0].Assignment_Position__c = 'Class Leader';
                conAss[0].Time_Approval_Preference__c = 'Daily';
                update conAss[0]; 
                System.debug('conAss========##'+conAss.size());
                
                List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
                System.debug('projects========'+projects);
            
                List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
                timeCard[0].Intructor__c = conList[0].Id;
                update timeCard;
                System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
                
                List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
                System.debug('task ====='+task);
              
                AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
                timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
                timeCardLine.AcctSeed__Project__c = projects[0].Id;
                timeCardLine.AcctSeed__Billable__c = TRUE;
                timeCardLine.Payroll_Item__c = 'ADM';
                timeCardLine.Contact_Assignment__c = conAss[0].Id;
                timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
                insert timeCardLine;
                
                AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Student_Approval_Status__c = 'Submitted', Late_Cancellation__c = TRUE, Cancellation_Reason__c = 'Test Cancellation Reason');
                insert day;
                
            Test.stopTest();
    }
    
    // To cover unpostedTCDRelatedAttendance() method in TimeCardDayTrigger_Handler
    private static testMethod void updateAttendanceRecs(){
    
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        
        Id stdId = NULL;
        Id insId = NULL;        
        for(Contact c  : [SELECT Id, RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName IN ('Student', 'Candidate', 'DLS_Employee')]){
            if(c.RecordType.DeveloperName == 'Candidate'){
                insId = c.Id;
            }
            if(c.RecordType.DeveloperName == 'Student'){
                stdId = c.Id;
            }
        }
        System.debug('insId:::'+insId);
        System.debug('stdId:::'+stdId);
        
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, Status__c FROM AcctSeed__Time_Card_Day__c];
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        System.debug('projs ======'+projs);
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projs[0].Id,Candidate_Name__c = insId,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Instructor')
        };
        Test.StartTest();
            insert conAssignRecs; 
            
            List<Attendance__c> attendanceList = new List<Attendance__c>{
            
                new Attendance__c(Event__c = events[0].Id, Student__c = stdId, Date__c = days[0].AcctSeed__Date__c, Time_Card_Day__c = days[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = insId),
                new Attendance__c(Event__c = events[1].Id, Student__c = stdId, Date__c = days[1].AcctSeed__Date__c, Time_Card_Day__c = days[1].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = insId)
            };
            
            insert attendanceList;
            
            days[0].Status__c = 'Unposted';
            update days[0];
            
            List<Attendance__c> attenRec = [SELECT Id, Student_Approval_Status__c FROM Attendance__c WHERE Id IN : attendanceList AND Time_Card_Day__c = :days[0].Id];
            System.assertEquals('Unposted', attenRec[0].Student_Approval_Status__c);
            
        Test.StopTest();
    }
    
    // To cover weeklyApprovedNotificationToInstructor() method in timeCardRelated_Email_Controller
    public static testMethod void wklyAppNotifyTest(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                        
        Test.startTest();
            EventReconciliationController.isGroupAction = TRUE;
            EventReconciliationController.groupActionType = 'Approved';
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Paper_Timesheet__c = FALSE;
            update conAss[0]; 
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
                        
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, Total_Hours_Used_For_Language_Training__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
              
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Status__c = 'Submitted');
            insert day;
            
            day.Status__c = 'Approved';
            update day;
                        
        Test.stopTest();
    }
    
    public static testMethod void newTestMethod1(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                        
        Test.startTest();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Paper_Timesheet__c = FALSE;
            update conAss[0]; 
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
                        
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, Total_Hours_Used_For_Language_Training__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
              
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Status__c = 'Draft');
            insert day;
            
            day.Status__c = 'Submitted';
            update day;
                        
        Test.stopTest();
    }
    
    public static testMethod void newTestMethod2(){
    
        InstructorTimeEntry_Controller.pageType = 'Instructor Time Entry';
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                        
        Test.startTest();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Paper_Timesheet__c = FALSE;
            update conAss[0]; 
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
                        
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, Total_Hours_Used_For_Language_Training__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
              
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Status__c = 'Draft');
            insert day;
            
            day.Status__c = 'Submitted';
            update day;
                        
        Test.stopTest();
    }
    
    public static testMethod void newTestMethod3(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                        
        Test.startTest();
            
            conList[0].Supervisor_Name__c = UserInfo.getUserId();
            update conList[0];
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
                        
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
                        
            List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, Project_Task_Type__c, Payroll_Item__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            task[0].Project_Task_Type__c = 'Fringe';
            task[0].Name = 'Test - Bonus Leave Earned';
            update task[0];
            
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Status__c = 'Submitted');
            insert day;
                                    
        Test.stopTest();
    }
    
    public static testMethod void newTestMethod4(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                        
        Test.startTest();
            
            conList[0].Supervisor_Name__c = UserInfo.getUserId();
            update conList[0];
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
                        
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
                        
            List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, Project_Task_Type__c, Payroll_Item__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            task[0].Project_Task_Type__c = 'Fringe';
            task[0].Name = 'Test - Bonus Leave Earned';
            update task[0];
            
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            Id pDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Student_Planned_Days_Off').getRecordTypeId();
            
            Planned_Days_Off__c parentPDO = new Planned_Days_Off__c(Contact__c = conAss[0].Candidate_Name__c, Date__c = System.today().addDays(-2),Description__c = 'Test Desc1',RecordTypeId = pDORTId, Status__c = 'Approved', Type__c='Student', Project__c = projects[0].Id);
            insert parentPDO;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.today().addDays(-2),Status__c = 'Submitted');
            insert day;
                                    
        Test.stopTest();
    }
    
    public static testMethod void newTestMethod5(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                        
        Test.startTest();
            
            conList[0].Supervisor_Name__c = UserInfo.getUserId();
            update conList[0];
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
                        
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
                        
            List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, Project_Task_Type__c, Payroll_Item__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            task[0].Project_Task_Type__c = 'Fringe';
            task[0].Name = 'Test - Bonus Leave Earned';
            update task[0];
            
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            Id pDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Student_Planned_Days_Off').getRecordTypeId();
            
            Planned_Days_Off__c parentPDO = new Planned_Days_Off__c(Contact__c = conAss[0].Candidate_Name__c, Date__c = System.today().addDays(-2),Description__c = 'Test Desc1',RecordTypeId = pDORTId, Status__c = 'Approved', Type__c='Student', All_Projects__c = True);
            insert parentPDO;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.today().addDays(-2),Status__c = 'Submitted');
            insert day;
                                    
        Test.stopTest();
    }
    
    // To cover findDuration in TimeCardDayTrigger_Handler
    private static testMethod void newTestMethod6(){
        
        TimeCardDayTrigger_Handler.findDuration(120, 360);
    }
    
    // To cover notesFormationBasedonTCD method in TimeCardDayTrigger_Handler
    private static testMethod void newTestMethod7(){
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
                    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
                    
        Test.startTest();
            List<Contact_Assignments__c> caUpdate = new List<Contact_Assignments__c>();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            List<Contact_Assignments__c> conAss1 = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Time_Approval_Preference__c = 'Daily';
            conAss1[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Paper_Timesheet__c = FALSE;
            conAss1[0].Paper_Timesheet__c = FALSE;
            caUpdate.add(conAss[0]);
            caUpdate.add(conAss1[0]);
            update caUpdate; 
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
          
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
            schList[0].Status__c = 'Active';
            update schList;
        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Student_Approval_Status__c = 'Submitted');
            insert day;
            
            Events__c event = new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = day.Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
            insert event;
            
            Map<Id,String> tcdIdNoteType = new Map<Id,String>();
            tcdIdNoteType.put(day.Id, 'Student Rejection');
            InstructorTimeEntry_Controller.tcdIdNoteType = tcdIdNoteType;
            
            List<AcctSeed__Time_Card_Day__c > day1 = [SELECT Id, Status__c, AcctSeed__Hours__c  FROM AcctSeed__Time_Card_Day__c WHERE Id = :day.Id];
            day1[0].Student_Approval_Status__c = 'Rejected';
            update day1;
        Test.stopTest();
    }
    
    // To cover notesFormationBasedonTCD method in TimeCardDayTrigger_Handler
    private static testMethod void newTestMethod8(){
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
                    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
                    
        Test.startTest();
            List<Contact_Assignments__c> caUpdate = new List<Contact_Assignments__c>();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            List<Contact_Assignments__c> conAss1 = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Time_Approval_Preference__c = 'Daily';
            conAss1[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Paper_Timesheet__c = FALSE;
            conAss1[0].Paper_Timesheet__c = FALSE;
            caUpdate.add(conAss[0]);
            caUpdate.add(conAss1[0]);
            update caUpdate; 
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
          
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
            schList[0].Status__c = 'Active';
            update schList;
        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Student_Approval_Status__c = 'Submitted');
            insert day;
            
            Events__c event = new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = day.Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
            insert event;
            
            Map<Id,String> tcdIdNoteType = new Map<Id,String>();
            tcdIdNoteType.put(day.Id, 'Daily Recall');
            InstructorTimeEntry_Controller.tcdIdNoteType = tcdIdNoteType;
            
            List<AcctSeed__Time_Card_Day__c > day1 = [SELECT Id, Status__c, AcctSeed__Hours__c  FROM AcctSeed__Time_Card_Day__c WHERE Id = :day.Id];
            day1[0].Student_Approval_Status__c = 'Recalled';
            update day1;
        Test.stopTest();
    }
    
    // To cover notesFormationBasedonTCD method in TimeCardDayTrigger_Handler
    private static testMethod void newTestMethod9(){
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
                    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
                    
        Test.startTest();
            List<Contact_Assignments__c> caUpdate = new List<Contact_Assignments__c>();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            List<Contact_Assignments__c> conAss1 = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Time_Approval_Preference__c = 'Daily';
            conAss1[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Paper_Timesheet__c = FALSE;
            conAss1[0].Paper_Timesheet__c = FALSE;
            caUpdate.add(conAss[0]);
            caUpdate.add(conAss1[0]);
            update caUpdate; 
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
          
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
            schList[0].Status__c = 'Active';
            update schList;
        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Student_Approval_Status__c = 'Submitted');
            insert day;
            
            Events__c event = new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = day.Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
            insert event;
            
            Map<Id,String> tcdIdNoteType = new Map<Id,String>();
            tcdIdNoteType.put(day.Id, 'Weekly Approval');
            InstructorTimeEntry_Controller.tcdIdNoteType = tcdIdNoteType;
            
            List<AcctSeed__Time_Card_Day__c > day1 = [SELECT Id, Status__c, AcctSeed__Hours__c  FROM AcctSeed__Time_Card_Day__c WHERE Id = :day.Id];
            day1[0].Student_Approval_Status__c = 'Approved';
            update day1;
        Test.stopTest();
    }
    
    // To cover notesFormationBasedonTCD method in TimeCardDayTrigger_Handler
    private static testMethod void newTestMethod10(){
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
                    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
                    
        Test.startTest();
            List<Contact_Assignments__c> caUpdate = new List<Contact_Assignments__c>();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            List<Contact_Assignments__c> conAss1 = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Time_Approval_Preference__c = 'Daily';
            conAss1[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Paper_Timesheet__c = FALSE;
            conAss1[0].Paper_Timesheet__c = FALSE;
            caUpdate.add(conAss[0]);
            caUpdate.add(conAss1[0]);
            update caUpdate; 
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
          
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
            schList[0].Status__c = 'Active';
            update schList;
        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Student_Approval_Status__c = 'Submitted');
            insert day;
            
            Events__c event = new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = day.Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
            insert event;
            
            Map<Id,String> tcdIdNoteType = new Map<Id,String>();
            tcdIdNoteType.put(day.Id, 'Weekly Reject');
            InstructorTimeEntry_Controller.tcdIdNoteType = tcdIdNoteType;
            
            List<AcctSeed__Time_Card_Day__c > day1 = [SELECT Id, Status__c, AcctSeed__Hours__c  FROM AcctSeed__Time_Card_Day__c WHERE Id = :day.Id];
            day1[0].Student_Approval_Status__c = 'Rejected';
            update day1;
        Test.stopTest();
    }
    
    // To cover notesFormationBasedonTCD method in TimeCardDayTrigger_Handler
    private static testMethod void newTestMetho11(){
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
                    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
                    
        Test.startTest();
            List<Contact_Assignments__c> caUpdate = new List<Contact_Assignments__c>();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            List<Contact_Assignments__c> conAss1 = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Time_Approval_Preference__c = 'Daily';
            conAss1[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Paper_Timesheet__c = FALSE;
            conAss1[0].Paper_Timesheet__c = FALSE;
            caUpdate.add(conAss[0]);
            caUpdate.add(conAss1[0]);
            update caUpdate; 
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
          
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
            schList[0].Status__c = 'Active';
            update schList;
        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Student_Approval_Status__c = 'Submitted');
            insert day;
            
            Events__c event = new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = day.Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
            insert event;
            
            Map<Id,String> tcdIdNoteType = new Map<Id,String>();
            tcdIdNoteType.put(day.Id, 'Weekly Revert');
            InstructorTimeEntry_Controller.tcdIdNoteType = tcdIdNoteType;
            
            List<AcctSeed__Time_Card_Day__c > day1 = [SELECT Id, Status__c, AcctSeed__Hours__c  FROM AcctSeed__Time_Card_Day__c WHERE Id = :day.Id];
            day1[0].Status__c = 'Reverted';
            update day1;
        Test.stopTest();
    }
    
    // To cover notesFormationBasedonTCD method in TimeCardDayTrigger_Handler
    private static testMethod void newTestMethod12(){
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
                    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
                    
        Test.startTest();
            List<Contact_Assignments__c> caUpdate = new List<Contact_Assignments__c>();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            List<Contact_Assignments__c> conAss1 = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Time_Approval_Preference__c = 'Daily';
            conAss1[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Paper_Timesheet__c = FALSE;
            conAss1[0].Paper_Timesheet__c = FALSE;
            caUpdate.add(conAss[0]);
            caUpdate.add(conAss1[0]);
            update caUpdate; 
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
          
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
            schList[0].Status__c = 'Active';
            update schList;
        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            InstructorTimeEntry_Controller.pageType = 'Instructor Time Entry';
                        
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Student_Approval_Status__c = 'Submitted', Late_Cancellation__c = True, Cancellation_Reason__c = 'Test Cancellation reason');
            insert day;
            
        Test.stopTest();
    }
}