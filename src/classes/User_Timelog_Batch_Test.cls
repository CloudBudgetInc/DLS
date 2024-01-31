// Developed by Shalini on Oct 11 2017 for code coverage of "UserCreation_FrmContact, TimeCard_Creation_FromCTP, EventUpdation_FromCTP" batches 

@isTest
public class User_Timelog_Batch_Test {
    
    @testSetup static void setup() {
       // List<Opportunity> oppList = TestClassUtil.createTestOpportunities(); 
        List<Events__c> eveList = TestClassUtil.createTestEvent();
        Test.startTest();
            List<AcctSeed__Time_Card_Day__c> days =  TestClassUtil.createTestTimeCardDay();
        Test.stopTest();
    }
    
    public static testmethod void test1() {
        String studRT;
        String InstRT;
      
        date myDate = System.Today().addDays(150);
        date weekStart = myDate.toStartofWeek()+1;
        date weekEnd = myDate.toStartofWeek()+7;
        String month;
         if(weekStart.month() < 10){
            month = '0'+weekStart.month();
        }else {
            month = String.valueOf(weekStart.month());
        }
        
        Test.startTest();
        
        Account acc = new Account(Name='Test Account Jerry');
        Insert acc;
        
        Id recId = [select id,Name,DeveloperName from RecordType where SobjectType='Contact' AND DeveloperName = 'DLS_Employee'].Id;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId = acc.Id,FirstName = 'Test',MiddleName = 'Contact',LastName = 'rec1',Email = 'harry_potterTest@gmail.com')
        };
        Insert contactList;
        
        List<User> userList = new List<User>();
        String en = String.valueOf(System.now().millisecond())+'@dlsTestOrg.com';
        
        List<Profile> DLSProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User Clone'];
        
        userList.add(new User(Alias = 'harry', Email = 'harry_potterTest@gmail.com',EmailEncodingKey = 'UTF-8',FirstName = 'Test',MiddleName = 'Contact',LastName = 'rec3',
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = DLSProfile[0].Id, 
            contactId = contactList[0].Id,TimeZoneSidKey = 'America/Los_Angeles', UserName = 'john@acme.com',
            Instructor_Access__c = true, Student_Access__c = true));
       
        insert userList;
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
                
        AcctSeed__Project__c pro = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        
        List<AcctSeed__Accounting_Period__c> accPeriod = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c];
        List<AcctSeed__Time_Card_Period__c> timePeriod = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Time_Card_Period__c];
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card__c];
        
        timeCard[0].Intructor__c = contactList[0].Id;
        update timeCard;
        
        List<AcctSeed__Project_Task__c> ptList = [SELECT Id,Name FROM AcctSeed__Project_Task__c LIMIT 2];
        ptList[0].Name = 'Language Training- Russian';
        update ptList;
        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id,AcctSeed__Billable__c,Payroll_Item__c,AcctSeed__Time_Card__c,AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Line__c LIMIT 2];
        timeCardLine[0].Payroll_Item__c = 'HOL';
        timeCardLine[0].AcctSeed__Billable__c = true;
        timeCardLine[0].AcctSeed__Project_Task__c = ptList[0].Id; 
        update timeCardLine;
        
        Test.stopTest();
        
        List<Events__c> eve =[SELECT ID,Date__c FROM Events__c WHERE Date__c = :system.today() LIMIT 1];
        eve[0].Date__c = myDate.toStartofWeek()+4;
        update eve;
        List<Time_Log__c> timelogList = new List<Time_Log__c>{
            new Time_Log__c(Opportunity__c = opp.Id,Date__c=myDate.toStartofWeek()+4,Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'SVC:Language Training:Russian',Payroll_Item__c='HOL',Billable_Work__c=true)
        };
        Insert timelogList;
        
        Set<Date> startdtSet = new Set<Date>{weekStart,system.today(),system.today()+3,timePeriod[0].AcctSeed__Start_Date__c};  // For Time Card Period Query Week Start Date Set
        Set<Date> enddtSet = new Set<Date>{weekEnd,system.today()+1,system.today()+2,timePeriod[0].AcctSeed__End_Date__c};    // For Time Card Period Query Week End Date Set
        
        Map<Date,Date> stdateandEnddtMap = new Map<Date,Date>();
        stdateandEnddtMap.put(weekStart, weekEnd);
        stdateandEnddtMap.put(system.today(), system.today()+1);
        stdateandEnddtMap.put(system.today()+3, system.today()+2);

        List<Date> tlDateSet = new List<Date>{system.today()};
        tlDateSet.add(myDate.toStartofWeek()+4);     // Time Log Dates     
        Set<Date> monthStartdtSet = new Set<Date>{weekStart.toStartofMonth(),system.today().addMonths(1).toStartofMonth(),accPeriod[0].AcctSeed__Start_Date__c}; // For Accounting Period 
        Set<Date> monthEnddtSet = new Set<Date>{weekStart.addMonths(1).toStartofMonth().addDays(-1),system.today().addMonths(2).toStartofMonth().addDays(-1),accPeriod[0].AcctSeed__End_Date__c};   // For Accounting Period
        
        Map<Id,Map<Date,Date>> contIdWithStAndEndDateMap = new Map<Id,Map<Date,Date>>();
        contIdWithStAndEndDateMap.put(contactList[0].Id, new Map<Date,Date>());
        contIdWithStAndEndDateMap.get(contactList[0].Id).put(weekStart, weekEnd);
        contIdWithStAndEndDateMap.put(contactList[0].Id, new Map<Date,Date>());
        contIdWithStAndEndDateMap.get(contactList[0].Id).put(weekStart, weekEnd);
        
        Set<Id> ContIds = new Set<Id>{contactList[0].Id,timeCard[0].Intructor__c};
       
        Id oppId = opp.Id;
        
        Map<String,String> contServItemPtName = new Map<String,String>();
        Map<String,Id> projectTaskNameWithProjectTaskId = new Map<String,Id>();
        
        Map<String,String> PayRollValuesMap = new Map<String,String>{'S' => 'Sick', 'V' => 'Vacation', 'HOL' => 'Holiday', 'OTH' => 'Other Pay', 'BLE' => 'Bonus Leave Earned', 'BLT' => 'Bonus Leave Taken'};
        Id newProjectId;
        
        List<AcctSeed__Project_Task__c> proTaskList = [SELECT Id,Name, AcctSeed__Project__c, AcctSeed__Project__r.AcctSeed__Opportunity__c FROM AcctSeed__Project_Task__c];
        system.debug('::*proTaskList*::'+proTaskList+'::*proTaskList.size()*::'+proTaskList.size());
        
        for(AcctSeed__Project_Task__c proTaskMap : proTaskList) {
            system.debug('::*proTaskMap.Name*::'+proTaskMap.Name+'::*proTaskMap.Id*::'+proTaskMap.Id);
            if(proTaskMap.Name != Null && proTaskMap.Id != Null) {
                projectTaskNameWithProjectTaskId.put(proTaskMap.Name,proTaskMap.Id); 
            }       
        } 
        List<AcctSeed__Project__c> prolist = [SELECT Id,Name,AcctSeed__Opportunity__c FROM AcctSeed__Project__c];
        prolist[0].AcctSeed__Opportunity__c = opp.Id;
        update prolist;

        
        UtilDomain.batchParameters batchParam = new UtilDomain.batchParameters();
        batchParam.oppId = oppId;
        batchParam.contServItemPtName = contServItemPtName;
        batchParam.projectTaskNameWithProjectTaskId = projectTaskNameWithProjectTaskId;
        batchParam.startdtSet = startdtSet;
        batchParam.enddtSet = enddtSet;
        batchParam.stdateandEnddtMap = stdateandEnddtMap;
        batchParam.tlDateSet = tlDateSet;
        batchParam.monthStartdtSet = monthStartdtSet;
        batchParam.monthEnddtSet = monthEnddtSet;
        batchParam.contIdWithStAndEndDateMap = contIdWithStAndEndDateMap;
        batchParam.ContIds = ContIds;
        batchParam.PayRollValuesMap = PayRollValuesMap;
        batchParam.newProjectId = pro.Id;
        batchParam.existingTLIds = new Set<Id>();
        
        UserCreation_FrmContact usrContactBatch = new UserCreation_FrmContact(batchParam);
        usrContactBatch.sendEmailWhenErrorOccurs('Test');
        database.executeBatch(usrContactBatch);  
        TimeCard_Creation_FromCTP ti = new TimeCard_Creation_FromCTP(batchParam); 
        ti.sendEmailWhenErrorOccurs('Good');
        
    }
    
    public static testMethod void Test2() {
       
        List<Contact> contactList = [SELECT Id FROM Contact];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Schedule__c> schList = [SELECT Id FROM Schedule__c];
        List<Events__c> eventList = [SELECT Id FROM Events__c LIMIT 2];
        eventList.add(new Events__c(Instructor__c = contactList[0].Id,Schedule__c=schList[0].Id,Start_Time__c='09:00 AM',End_Time__c='10:00 AM',Date__c=system.today()+1,Status__c='Scheduled',SequenceNo__c=1234));
        
        Id newProjectId;
        Set<Id> scheduleIdSet = new Set<Id>{schList[0].Id};
        Set<Id> eventIdSet = new Set<Id>();
        Map<Id,Id> schIdWithInstructorIdMap = new Map<Id,Id>();
        Date temp;
        List<UtilDomain.EventInnerClass> eveList = new List<UtilDomain.EventInnerClass>();
        eveList.add(new UtilDomain.EventInnerClass(eventList[2],'',temp));
        
        EventUpdation_FromCTP eventBatch = new EventUpdation_FromCTP(scheduleIdSet,eventIdSet,eveList,schIdWithInstructorIdMap,newProjectId);
        eventBatch.sendEmailWhenErrorOccurs('');
        database.executeBatch(eventBatch);
        
        QualificationUtil incc = new QualificationUtil();
        incc.increaseCodeCoverge();
       
    }
    public static testmethod void test3() {
        String studRT;
        String InstRT;
      
        date myDate = System.Today();
        date weekStart = myDate.toStartofWeek()+1;
        date weekEnd = myDate.toStartofWeek()+7;
        String month;
         if(weekStart.month() < 10){
            month = '0'+weekStart.month();
        }else {
            month = String.valueOf(weekStart.month());
        }
        
        Test.startTest();
        
        Account acc = new Account(Name='Test Account Tom');
        Insert acc;
        
        Id recId = [select id,Name,DeveloperName from RecordType where SobjectType='Contact' AND DeveloperName = 'DLS_Employee'].Id;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId = acc.Id,FirstName = 'Test',MiddleName = 'Contact',LastName = 'rec3',Email = 'harry_potterTest@gmail.com',RecordTypeId = recId)
        };
        Insert contactList;
        List<User> userList = new List<User>();
        String en = String.valueOf(System.now().millisecond())+'@dlsTestOrg.com';
        
        List<Profile> DLSProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User Clone'];
        
        userList.add(new User(Alias = 'harry', Email = 'harry_potterTest@gmail.com',EmailEncodingKey = 'UTF-8',FirstName = 'Test',MiddleName = 'Contact',LastName = 'rec3',
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = DLSProfile[0].Id, 
            contactId = contactList[0].Id,TimeZoneSidKey = 'America/Los_Angeles', UserName = 'john@acme.com',
            Instructor_Access__c = true, Student_Access__c = true));
       
        insert userList;
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        AcctSeed__Project__c pro = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        
        List<AcctSeed__Accounting_Period__c> accPeriod = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c];
        List<AcctSeed__Time_Card_Period__c> timePeriod = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Time_Card_Period__c];
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card__c];
        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id,AcctSeed__Billable__c,Payroll_Item__c,AcctSeed__Time_Card__c,AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Line__c LIMIT 2];
        timeCardLine[0].Payroll_Item__c = 'HOL';
        timeCardLine[0].AcctSeed__Billable__c = true;
        update timeCardLine;
        
        timeCard[0].Intructor__c = contactList[0].Id;
        update timeCard;
        
        List<AcctSeed__Project_Task__c> ptList = [SELECT Id,Name FROM AcctSeed__Project_Task__c LIMIT 2];
        ptList[0].Name = 'Language Training- Russian';
        update ptList;
        system.debug('::timeCardLine::'+timeCardLine);
        system.debug('::timeCard::'+timeCard);
        system.debug('::ptList::'+ptList);
        system.debug('::timePeriod::'+timePeriod);

        List<AcctSeed__Time_Card_Day__c> timeCardDay = [SELECT Id,Status__c FROM AcctSeed__Time_Card_Day__c];
        timeCardDay[0].Status__c = 'Approved';
        update timeCardDay;
        
        List<Time_Log__c> timelogList = new List<Time_Log__c>{
            new Time_Log__c(Opportunity__c = opp.Id,Date__c=system.today().toStartofWeek()+4,Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'SVC:',Payroll_Item__c='HOL',Billable_Work__c=true,Notes__c='Preparation')
        };
        Insert timelogList;
        
        
        Set<Date> startdtSet = new Set<Date>{weekStart,system.today(),system.today()+3,timePeriod[0].AcctSeed__Start_Date__c};  // For Time Card Period Query Week Start Date Set
        Set<Date> enddtSet = new Set<Date>{weekEnd,system.today()+1,system.today()+2,timePeriod[0].AcctSeed__End_Date__c};    // For Time Card Period Query Week End Date Set
        
        Map<Date,Date> stdateandEnddtMap = new Map<Date,Date>();
        stdateandEnddtMap.put(weekStart, weekEnd);
        stdateandEnddtMap.put(system.today(), system.today()+1);
        stdateandEnddtMap.put(system.today()+3, system.today()+2);

        List<Date> tlDateSet = new List<Date>{system.today()};     // Time Log Dates     
        Set<Date> monthStartdtSet = new Set<Date>{weekStart.toStartofMonth(),system.today().addMonths(1).toStartofMonth(),accPeriod[0].AcctSeed__Start_Date__c}; // For Accounting Period 
        Set<Date> monthEnddtSet = new Set<Date>{weekStart.addMonths(1).toStartofMonth().addDays(-1),system.today().addMonths(2).toStartofMonth().addDays(-1),accPeriod[0].AcctSeed__End_Date__c};   // For Accounting Period
        
        Map<Id,Map<Date,Date>> contIdWithStAndEndDateMap = new Map<Id,Map<Date,Date>>();
        contIdWithStAndEndDateMap.put(contactList[0].Id, new Map<Date,Date>());
        contIdWithStAndEndDateMap.get(contactList[0].Id).put(weekStart, weekEnd);
        contIdWithStAndEndDateMap.put(contactList[0].Id, new Map<Date,Date>());
        contIdWithStAndEndDateMap.get(contactList[0].Id).put(weekStart, weekEnd);
        
        Set<Id> ContIds = new Set<Id>{contactList[0].Id,timeCard[0].Intructor__c};
       
        Id oppId = opp.Id;
        
        Map<String,String> contServItemPtName = new Map<String,String>();
        Map<String,Id> projectTaskNameWithProjectTaskId = new Map<String,Id>();
        
        Map<String,String> PayRollValuesMap = new Map<String,String>{'S' => 'Sick', 'V' => 'Vacation', 'HOL' => 'Holiday', 'OTH' => 'Other Pay', 'BLE' => 'Bonus Leave Earned', 'BLT' => 'Bonus Leave Taken'};
        Id newProjectId;
        
        List<AcctSeed__Project_Task__c> proTaskList = [SELECT Id,Name FROM AcctSeed__Project_Task__c];
        system.debug('::*proTaskList*::'+proTaskList+'::*proTaskList.size()*::'+proTaskList.size());
        
        for(AcctSeed__Project_Task__c proTaskMap : proTaskList) {
            system.debug('::*proTaskMap.Name*::'+proTaskMap.Name+'::*proTaskMap.Id*::'+proTaskMap.Id);
            if(proTaskMap.Name != Null && proTaskMap.Id != Null) {
                projectTaskNameWithProjectTaskId.put(proTaskMap.Name,proTaskMap.Id); 
            }       
        }      
        
        Test.stopTest();  
        
        UtilDomain.batchParameters batchParam = new UtilDomain.batchParameters();
        batchParam.contServItemPtName = contServItemPtName;
        batchParam.projectTaskNameWithProjectTaskId = projectTaskNameWithProjectTaskId;
        batchParam.startdtSet = startdtSet;
        batchParam.enddtSet = enddtSet;
        batchParam.stdateandEnddtMap = stdateandEnddtMap;
        batchParam.tlDateSet = tlDateSet;
        batchParam.monthStartdtSet = monthStartdtSet;
        batchParam.monthEnddtSet = monthEnddtSet;
        batchParam.contIdWithStAndEndDateMap = contIdWithStAndEndDateMap;
        batchParam.ContIds = ContIds;
        batchParam.PayRollValuesMap = PayRollValuesMap;
        batchParam.existingTLIds = new Set<Id>();
        batchParam.oppIds = new Set<Id>{oppId};
        batchParam.projectIds = new Set<Id>{pro.Id};
        batchParam.oppIdProjectIdMap = new Map<Id,Id>{oppId=>pro.Id}; 
        
        UserCreation_FrmContact usrContactBatch = new UserCreation_FrmContact(batchParam);
        usrContactBatch.sendEmailWhenErrorOccurs('Test');
        database.executeBatch(usrContactBatch);  
    }
    
    public static testmethod void test4() {
        String studRT;
        String InstRT;
      
        date myDate = System.Today().addDays(150);
        date weekStart = myDate.toStartofWeek()+1;
        date weekEnd = myDate.toStartofWeek()+7;
        String month;
         if(weekStart.month() < 10){
            month = '0'+weekStart.month();
        }else {
            month = String.valueOf(weekStart.month());
        }
        
        Account acc = new Account(Name='Test Account Harry');
        Insert acc;
        
        Id recId = [select id,Name,DeveloperName from RecordType where SobjectType='Contact' AND DeveloperName = 'DLS_Employee'].Id;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId = acc.Id,FirstName = 'Test',MiddleName = 'Contact',LastName = 'rec1',Email = 'harry_potterTest@gmail.com')
        };
        Insert contactList;
        
        List<User> userList = new List<User>();
        String en = String.valueOf(System.now().millisecond())+'@dlsTestOrg.com';
        
        List<Profile> DLSProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User Clone'];
        
        userList.add(new User(Alias = 'harry', Email = 'harry_potterTest@gmail.com',EmailEncodingKey = 'UTF-8',FirstName = 'Test',MiddleName = 'Contact',LastName = 'rec3',
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = DLSProfile[0].Id, 
            contactId = contactList[0].Id,TimeZoneSidKey = 'America/Los_Angeles', UserName = 'john@acme.com',
            Instructor_Access__c = true, Student_Access__c = true));
       
        insert userList;
        
        Test.startTest();
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
                
        AcctSeed__Project__c pro = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        
        List<AcctSeed__Accounting_Period__c> accPeriod = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c];
        List<AcctSeed__Time_Card_Period__c> timePeriod = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Time_Card_Period__c];
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card__c];
        
        timeCard[0].Intructor__c = contactList[0].Id;
        update timeCard;
        
        
        
        List<AcctSeed__Project_Task__c> ptList = [SELECT Id,Name FROM AcctSeed__Project_Task__c LIMIT 2];
        ptList[0].Name = 'Language Training- Russian';
        update ptList;
        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id,Name,AcctSeed__Billable__c,Payroll_Item__c,AcctSeed__Time_Card__c,AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Line__c LIMIT 2];
        timeCardLine[0].Payroll_Item__c = 'HOL';
        timeCardLine[0].AcctSeed__Billable__c = true;
        timeCardLine[0].AcctSeed__Project_Task__c = ptList[0].Id; 
        update timeCardLine;
        List<Events__c> eve =[SELECT ID,Date__c FROM Events__c WHERE Date__c = :system.today() LIMIT 1];
        eve[0].Date__c = myDate.toStartofWeek()+4;
        update eve;
        List<Time_Log__c> timelogList = new List<Time_Log__c>{
            new Time_Log__c(Opportunity__c = opp.Id,Date__c=myDate.toStartofWeek()+4,Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'SVC:Language Training:Russian',Payroll_Item__c='HOL',Billable_Work__c=true),
            new Time_Log__c(Opportunity__c = opp.Id,Date__c=myDate.toStartofWeek()+4,Hours__c=8,Contact__c = contactList[0].Id,Service_Item__c = 'SVC:Language Training:Russian',Payroll_Item__c='HOL',Billable_Work__c=true)
        };
        Insert timelogList;
        
        
        
        List<AcctSeed__Time_Card_Day__c> timeCardDay = [SELECT Id,Name,Status__c,AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c];
        timeCardDay[0].Status__c = 'Approved';
        //timeCardDay[0].AcctSeed__Time_Card_Line__c = timeCardLine[0].Id;
        
        update timeCardDay;
        
        Set<Date> startdtSet = new Set<Date>{weekStart,system.today(),system.today()+3,timePeriod[0].AcctSeed__Start_Date__c};  // For Time Card Period Query Week Start Date Set
        Set<Date> enddtSet = new Set<Date>{weekEnd,system.today()+1,system.today()+2,timePeriod[0].AcctSeed__End_Date__c};    // For Time Card Period Query Week End Date Set
        
        Map<Date,Date> stdateandEnddtMap = new Map<Date,Date>();
        stdateandEnddtMap.put(weekStart, weekEnd);
        stdateandEnddtMap.put(system.today(), system.today()+1);
        stdateandEnddtMap.put(system.today()+3, system.today()+2);

        List<Date> tlDateSet = new List<Date>{system.today()};
        tlDateSet.add(myDate.toStartofWeek()+4);     // Time Log Dates     
        Set<Date> monthStartdtSet = new Set<Date>{weekStart.toStartofMonth(),system.today().addMonths(1).toStartofMonth(),accPeriod[0].AcctSeed__Start_Date__c}; // For Accounting Period 
        Set<Date> monthEnddtSet = new Set<Date>{weekStart.addMonths(1).toStartofMonth().addDays(-1),system.today().addMonths(2).toStartofMonth().addDays(-1),accPeriod[0].AcctSeed__End_Date__c};   // For Accounting Period
        
        Map<Id,Map<Date,Date>> contIdWithStAndEndDateMap = new Map<Id,Map<Date,Date>>();
        contIdWithStAndEndDateMap.put(contactList[0].Id, new Map<Date,Date>());
        contIdWithStAndEndDateMap.get(contactList[0].Id).put(weekStart, weekEnd);
        contIdWithStAndEndDateMap.put(contactList[0].Id, new Map<Date,Date>());
        contIdWithStAndEndDateMap.get(contactList[0].Id).put(weekStart, weekEnd);
        
        Set<Id> ContIds = new Set<Id>{contactList[0].Id,timeCard[0].Intructor__c};
       
        Id oppId = opp.Id;
        
        Map<String,String> contServItemPtName = new Map<String,String>();
        Map<String,Id> projectTaskNameWithProjectTaskId = new Map<String,Id>();
        
        Map<String,String> PayRollValuesMap = new Map<String,String>{'S' => 'Sick', 'V' => 'Vacation', 'HOL' => 'Holiday', 'OTH' => 'Other Pay', 'BLE' => 'Bonus Leave Earned', 'BLT' => 'Bonus Leave Taken'};
        Id newProjectId;
        
        List<AcctSeed__Project_Task__c> proTaskList = [SELECT Id,Name, AcctSeed__Project__c, AcctSeed__Project__r.AcctSeed__Opportunity__c FROM AcctSeed__Project_Task__c];
        system.debug('::*proTaskList*::'+proTaskList+'::*proTaskList.size()*::'+proTaskList.size());
        
        for(AcctSeed__Project_Task__c proTaskMap : proTaskList) {
            system.debug('::*proTaskMap.Name*::'+proTaskMap.Name+'::*proTaskMap.Id*::'+proTaskMap.Id);
            if(proTaskMap.Name != Null && proTaskMap.Id != Null) {
                projectTaskNameWithProjectTaskId.put(proTaskMap.Name,proTaskMap.Id); 
            }       
        } 
        List<AcctSeed__Project__c> prolist = [SELECT Id,Name,AcctSeed__Opportunity__c FROM AcctSeed__Project__c];
        prolist[0].AcctSeed__Opportunity__c = opp.Id;
        update prolist;
        
        Test.stopTest();
        
        UtilDomain.batchParameters batchParam = new UtilDomain.batchParameters();
        batchParam.oppId = oppId;
        batchParam.contServItemPtName = contServItemPtName;
        batchParam.projectTaskNameWithProjectTaskId = projectTaskNameWithProjectTaskId;
        batchParam.startdtSet = startdtSet;
        batchParam.enddtSet = enddtSet;
        batchParam.stdateandEnddtMap = stdateandEnddtMap;
        batchParam.tlDateSet = tlDateSet;
        batchParam.monthStartdtSet = monthStartdtSet;
        batchParam.monthEnddtSet = monthEnddtSet;
        batchParam.contIdWithStAndEndDateMap = contIdWithStAndEndDateMap;
        batchParam.ContIds = ContIds;
        batchParam.PayRollValuesMap = PayRollValuesMap;
        batchParam.newProjectId = pro.Id;
        batchParam.existingTLIds = new Set<Id>(); 
        
        TimeCard_Creation_FromCTP ti = new TimeCard_Creation_FromCTP(batchParam); 
        database.executeBatch(ti,2);  
    }
    
}