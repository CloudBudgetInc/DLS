@isTest
public class CustomButtonServiceTest { 

    @testSetup static void setup(){    
     
        List<AcctSeed__Time_Card_Day__c> cardlist = TestClassUtil.createTestTimeCardDay();
        Test.StartTest();
            List<Events__c> eventList = TestClassUtil.createTestEvent();
            List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        Test.StopTest();
    }
    
    public static testMethod void myTest1() {
        
        String oppRT;
        Account acc = new Account(Name='New Test Account 1', Email__c = 'myacc1@gmail.com');
        Insert acc;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=acc.Id,FirstName='Test',MiddleName='Contact',LastName='rec 1'),
            new Contact(AccountId=acc.Id,FirstName='Test',MiddleName='Contact',LastName='rec 2')
        };
        Insert contactList;
        
        for(RecordType rt : [select id,Name,DeveloperName from RecordType where SobjectType='Opportunity']){
            if(rt.DeveloperName == 'New_Classes_Opportunities') oppRT = rt.Id;
        }
        
        Test.startTest();
        
            Opportunity opp = new Opportunity(AccountId=acc.Id,Name='Test Opp',CloseDate=System.Today(),StageName='Active',Start_Date__c = Date.NewInstance(2014,05,10),End_Date__c = Date.NewInstance(2015,05,10),RecordTypeId = oppRT);
            Insert opp;
        
            List<RecordType> recRTList = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'AcctSeed__Project__c' AND DeveloperName = 'Admin_Projects'];
            
            List<AcctSeed__Project__c> projList = new List<AcctSeed__Project__c> {
                new AcctSeed__Project__c(Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = recRTList[0].Id,  AcctSeed__Opportunity__c = opp.Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10)),
                new AcctSeed__Project__c(Name = 'Test Project 2',AcctSeed__Status__c = 'Inquiry',RecordTypeId = recRTList[0].Id, AcctSeed__Opportunity__c = opp.Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10))
            };
            insert projList;
            
            List<Time_Log__c> timelogList = new List<Time_Log__c>{
               new Time_Log__c(Opportunity__c = opp.Id,Date__c = System.Today(),Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'Interpretation (per hr)'),
               new Time_Log__c( Opportunity__c = opp.Id,Date__c = System.Today()+100,Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'SVC:Language Training:Afrikaans',Unposted__c = False,Payroll_Item__c = 'ADM')
            };
            Insert timelogList;
            System.debug(':::::Tl::::'+timelogList);
            
            CustomButtonService.TimelogToTCDConversion(opp.Id,projList[0].Id);
            //CustomButtonService.EventUpdation(opp.Id,projList[0].Id);
            
            timelogList[1].Service_Item__c = 'SVC:RT';
            update timelogList;
            CustomButtonService.TimelogToTCDConversion(opp.Id,projList[0].Id);
    
            timelogList[1].Service_Item__c = 'SVC:';
            timelogList[1].Payroll_Item__c = 'ADM';
            update timelogList;
            CustomButtonService.TimelogToTCDConversion(opp.Id,projList[0].Id);
            
            timelogList[0].Service_Item__c = 'Fringe';
            timelogList[0].Payroll_Item__c = 'Holiday';
            update timelogList;
            CustomButtonService.TimelogToTCDConversion(opp.Id,projList[0].Id);
            
            timelogList[1].Service_Item__c = 'Fringe';
            timelogList[1].Payroll_Item__c = 'Vacation';
            update timelogList;
            CustomButtonService.TimelogToTCDConversion(opp.Id,projList[0].Id);
        Test.StopTest();

    }

    public static testMethod void myTest1a() {
        
        String oppRT;
        Account acc = new Account(Name='New Test Account 2', Email__c = 'myacc2@gmail.com');
        Insert acc;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=acc.Id,FirstName='Test',MiddleName='Contact',LastName='rec 1'),
            new Contact(AccountId=acc.Id,FirstName='Test',MiddleName='Contact',LastName='rec 2')
        };
        Insert contactList;
        
        for(RecordType rt : [select id,Name,DeveloperName from RecordType where SobjectType='Opportunity']){
            if(rt.DeveloperName == 'New_Classes_Opportunities') oppRT = rt.Id;
        }
        
        Test.StartTest();
        
            Opportunity opp = new Opportunity(AccountId=acc.Id,Name='Test Opp',CloseDate=System.Today(),StageName='Active',Start_Date__c = Date.NewInstance(2014,05,10),End_Date__c = Date.NewInstance(2015,05,10),RecordTypeId = oppRT);
            Insert opp;
            
            List<RecordType> recRTList = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'AcctSeed__Project__c' AND DeveloperName = 'Admin_Projects'];
            
            List<AcctSeed__Project__c> projList = new List<AcctSeed__Project__c> {
                new AcctSeed__Project__c(Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = recRTList[0].Id,  AcctSeed__Opportunity__c = opp.Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10)),
                new AcctSeed__Project__c(Name = 'Test Project 2',AcctSeed__Status__c = 'Inquiry',RecordTypeId = recRTList[0].Id, AcctSeed__Opportunity__c = opp.Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10))
            };
            insert projList;
            
            List<Time_Log__c> timelogList = new List<Time_Log__c>{
               new Time_Log__c(Opportunity__c = opp.Id,Date__c = System.Today(),Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'Fringe', Payroll_Item__c = 'S')
            };
            Insert timelogList;
            System.debug(':::::Tl::::'+timelogList);
            
            CustomButtonService.TimelogToTCDConversion(opp.Id,projList[0].Id);
            //CustomButtonService.EventUpdation(opp.Id,projList[0].Id);
            
        Test.StopTest();

    }
    
    public static testMethod void myTest2() {
        
        Account acc = new Account(Name='New Test Account 3', Email__c = 'myacc3@gmail.com');
        Insert acc;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=acc.Id,FirstName='Test',MiddleName='Contact',LastName='rec 1'),
            new Contact(AccountId=acc.Id,FirstName='Test',MiddleName='Contact',LastName='rec 2')
        };
        Insert contactList;
        
        List<AcctSeed__Time_Card_Day__c> timecardlist = [SELECT Id,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Day__c Limit 1];
        ID projtaskId = timecardlist[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
        
        Test.StartTest();
        
            List<AcctSeed__Project_Task__c> projecttaskList = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Client_Contact__c FROM AcctSeed__Project_Task__c WHERE Id = :projtaskId];
            Id oppId = projecttaskList[0].AcctSeed__Project__r.AcctSeed__Opportunity__c;
            Id projId = projecttaskList[0].AcctSeed__Project__c;
            system.debug('::::oppId'+oppId);
            
            List<Schedule__c> schList = [SELECT Id,Name,Instructor__c,Opportunity__c,Project__c FROM Schedule__c];
            schList[0].Opportunity__c = oppId;
            update schList;
            
            List<Events__c> eveList = [SELECT Id,Name,Date__c,Instructor__c,Project__c,Schedule__c,Status__c FROM Events__c];        
            eveList[0].Schedule__c = schList[0].Id;
            eveList[0].Status__c = 'Scheduled';
            eveList[0].Project__c = null;
            update eveList;   
                 
            CustomButtonService.TimelogToTCDConversion(oppId,projId);
            CustomButtonService.EventUpdation(oppId,projId);
        CustomButtonService.updateProStatusToOnHold(projId,JSON.serialize(new List<Contact_Assignments__c>()),String.valueOf(system.today()),'','On Hold', true);
            
            CustomButtonService.updateProStatusToOnHold(projId,JSON.serialize(new List<Contact_Assignments__c>()),String.valueOf(system.today()),'Testing','Canceled', false);
        Test.StopTest();
        
    }
    
    public static testMethod void myTest2a() {
        
        Account acc = new Account(Name='New Test Account 4', Email__c = 'myacc4@gmail.com');
        Insert acc;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=acc.Id,FirstName='Test',MiddleName='Contact',LastName='rec 1'),
            new Contact(AccountId=acc.Id,FirstName='Test',MiddleName='Contact',LastName='rec 2')
        };
        Insert contactList;
        
        List<AcctSeed__Time_Card_Day__c> timecardlist = [SELECT Id,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Day__c Limit 1];
        ID projtaskId = timecardlist[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
        
        Test.StartTest();
            List<AcctSeed__Project_Task__c> projecttaskList = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Client_Contact__c FROM AcctSeed__Project_Task__c WHERE Id = :projtaskId];
            Id oppId = projecttaskList[0].AcctSeed__Project__r.AcctSeed__Opportunity__c;
            Id projId = projecttaskList[0].AcctSeed__Project__c;
            system.debug('::::oppId'+oppId);
            
            List<Schedule__c> schList = [SELECT Id,Name,Instructor__c,Opportunity__c,Project__c FROM Schedule__c];
            schList[0].Opportunity__c = oppId;
            update schList;
            
            List<Events__c> eveList = [SELECT Id,Name,Date__c,Instructor__c,Project__c,Schedule__c,Status__c FROM Events__c];        
            eveList[0].Schedule__c = schList[0].Id;
            eveList[0].Status__c = 'Scheduled';
            eveList[0].Project__c = null;
            update eveList;   
                 
            CustomButtonService.TimelogToTCDConversion(oppId,projId);
            CustomButtonService.EventUpdation(oppId,projId);
            CustomButtonService.updateProStatusToOnHold(projId,JSON.serialize(new List<Contact_Assignments__c>()),String.valueOf(system.today()),'test reason','Canceled', false);
        Test.StopTest();
        
    }
    
    public static testMethod void myTest2b() {
        
        Account acc = new Account(Name='New Test Account 5', Email__c = 'myacc5@gmail.com');
        Insert acc;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=acc.Id,FirstName='Test',MiddleName='Contact',LastName='rec 1'),
            new Contact(AccountId=acc.Id,FirstName='Test',MiddleName='Contact',LastName='rec 2')
        };
        Insert contactList;
        
        List<AcctSeed__Time_Card_Day__c> timecardlist = [SELECT Id,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Day__c Limit 1];
        ID projtaskId = timecardlist[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
        
        Test.StartTest();
            List<AcctSeed__Project_Task__c> projecttaskList = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Client_Contact__c FROM AcctSeed__Project_Task__c WHERE Id = :projtaskId];
            Id oppId = projecttaskList[0].AcctSeed__Project__r.AcctSeed__Opportunity__c;
            Id projId = projecttaskList[0].AcctSeed__Project__c;
            system.debug('::::oppId'+oppId);
            
            List<Schedule__c> schList = [SELECT Id,Name,Instructor__c,Opportunity__c,Project__c FROM Schedule__c];
            schList[0].Opportunity__c = oppId;
            update schList;
            
            List<Events__c> eveList = [SELECT Id,Name,Date__c,Instructor__c,Project__c,Schedule__c,Status__c FROM Events__c];        
            eveList[0].Schedule__c = schList[0].Id;
            eveList[0].Status__c = 'Scheduled';
            eveList[0].Project__c = null;
            update eveList;   
                 
            CustomButtonService.TimelogToTCDConversion(oppId,projId);
            CustomButtonService.EventUpdation(oppId,projId);
            try{
                CustomButtonService.updateProStatusToOnHold(projId,JSON.serialize(new List<Contact_Assignments__c>()),String.valueOf(system.today()),'','Canceled', false);
            }catch(Exception e){
            
                System.debug('e===='+e.getMessage());
                Boolean expectedExceptionThrown =  e.getMessage().contains('Script-thrown exception') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.StopTest();
        
    }
    
    // To cover convertToFixedAsset method
    public static testMethod void myTest3(){
    
        Id equipRTId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Computer').getRecordTypeId();
                
        Account acc = new Account(Name='New Test Account 6', Email__c = 'myacc6@gmail.com');
        Insert acc;
        
        Test.startTest();
        
            Purchase_Order__c order = new Purchase_Order__c(Name = 'Test Order', Vendor__c = acc.Id);
            insert order;
            
            Sobject_Master_Field_Mapping__c master = new Sobject_Master_Field_Mapping__c();
            master.Name = 'Computer Equipment';
            master.Default_Field_Value__c = 'Computer_Equipment';
            master.Field_Name__c = 'RecordTypeId';
            master.Object_Name__c = 'AcctSeed__Fixed_Asset__c';
            master.RecordType_Name__c = 'Computer';
            master.Description__c = 'Record type mapping for Equipment to fixed asset conversion - RT - Equipment RT, Default Value - Fixed Asset RT';
            insert master;
            
            Equipment__c equip = new Equipment__c(Name = 'MyTest', RecordTypeId  = equipRTId, Acquisition_Cost__c = 100, Purchase_Order_No__c = order.Id);
            insert equip;
            
            System.debug('equip======================'+equip);
            
            CustomButtonService.convertToFixedAsset(equip.Id);
        Test.stopTest();
    }
    
    public static testMethod void myTest4(){
    
        Id equipRTId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Fixtures').getRecordTypeId();
                
        Account acc = new Account(Name='New Test Account 7', Email__c = 'myacc7@gmail.com');
        Insert acc;
        
        Test.startTest();
        
            Purchase_Order__c order = new Purchase_Order__c(Name = 'Test Order', Vendor__c = acc.Id);
            insert order;
                            
            Equipment__c equip = new Equipment__c(Name = 'MyTest', RecordTypeId  = equipRTId, Acquisition_Cost__c = 100, Purchase_Order_No__c = order.Id);
            insert equip;
            
            System.debug('equip======================'+equip);
            
            CustomButtonService.convertToFixedAsset(equip.Id);
        Test.stopTest();
    }
    
    public static testMethod void myTest5(){
    
        String oppRT;
        Account acc = new Account(Name='New Test Account 8', Email__c = 'myacc8@gmail.com');
        Insert acc;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=acc.Id,FirstName='Test',MiddleName='Contact',LastName='rec 1'),
            new Contact(AccountId=acc.Id,FirstName='Test',MiddleName='Contact',LastName='rec 2')
        };
        Insert contactList;
        
        for(RecordType rt : [select id,Name,DeveloperName from RecordType where SobjectType='Opportunity']){
            if(rt.DeveloperName == 'New_Classes_Opportunities') oppRT = rt.Id;
        }
        
        Test.StartTest();
        
            Opportunity opp = new Opportunity(AccountId=acc.Id,Name='Test Opp',CloseDate=System.Today(),StageName='Active',Start_Date__c = Date.NewInstance(2014,05,10),End_Date__c = Date.NewInstance(2015,05,10),RecordTypeId = oppRT);
            Insert opp;
            
            List<RecordType> recRTList = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'AcctSeed__Project__c' AND DeveloperName = 'Admin_Projects'];
            
            List<AcctSeed__Project__c> projList = new List<AcctSeed__Project__c> {
                new AcctSeed__Project__c(Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = recRTList[0].Id,  AcctSeed__Opportunity__c = opp.Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10)),
                new AcctSeed__Project__c(Name = 'Test Project 2',AcctSeed__Status__c = 'Inquiry',RecordTypeId = recRTList[0].Id, AcctSeed__Opportunity__c = opp.Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10))
            };
            //insert projList;
            
            List<Time_Log__c> timelogList = new List<Time_Log__c>{
               new Time_Log__c(Opportunity__c = opp.Id,Date__c = System.Today(),Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'Interpretation (per hr)'),
               new Time_Log__c( Opportunity__c = opp.Id,Date__c = System.Today()+100,Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'SVC:Language Training:Afrikaans',Unposted__c = False,Payroll_Item__c = 'ADM')
            };
            insert timelogList;
                        
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' AND LastName='StaffContact' LIMIT 1];
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            update conAss[0]; 
                        
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c LIMIT 1];
            System.debug('projects========'+projects);
            
            List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+projTask);
            
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
            
            List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
                new AcctSeed__Time_Card_Day__c(Time_Log_Id__c = timelogList[0].Id, AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(2),Status__c= 'Draft'),
                new AcctSeed__Time_Card_Day__c(Time_Log_Id__c = timelogList[0].Id, AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(3),Status__c= 'Draft')
            
            };
            insert days;
            
            CustomButtonService.TimelogToTCDConversion(opp.Id,projTask[0].AcctSeed__Project__c);
        Test.stopTest();
    }
    
    public static testMethod void myTest6(){
    
        Test.startTest();
        
        try{
        
            CustomButtonService.initiateUserCreation();
            
        }Catch(Exception e){
            system.debug('Exception:'+e+e.getLineNumber());
        }
            
        Test.stopTest();
    }
    
    // Cover EventsCreationFromProject() method
    public static testMethod void myTest7(){
    
        List<AcctSeed__Project__c> proj = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        CustomButtonService.EventsCreationFromProject(proj[0].Id);
    }
    
    // Cover dlsInstructorAccountCreation() method in AccountUtil
    private static testMethod void myTest8(){
    
        Account parentAcc = new Account();
        parentAcc.Name = 'DLS - Candidate';
        insert parentAcc;
        
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Name, Email, Phone, AccountId, OwnerId FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        contacts[0].Email = 'mydlstest@gmail.com';
        update contacts[0];
        
        AccountUtil.dlsInstructorAccountCreation(contacts[0].Id);
        
        List<Account> acc = [SELECT Id FROM Account WHERE ParentId != NULL AND Parent.Name = 'DLS - Candidate' AND RecordType.DeveloperName = 'DLS'];
        System.assertEquals(1, acc.size());
        
        
        Test.startTest();
            AccountUtil.dlsInstructorAccountCreation(contacts[0].Id);
            AccountUtil.dlsInstructorAccountCreation(contacts[0].Id);
        Test.stopTest();
    }
    
    // Cover dlsInstructorAccountCreation() method in AccountUtil
    private static testMethod void myTest8a(){
    
        Account parentAcc = new Account();
        parentAcc.Name = 'DLS - Candidate';
        insert parentAcc;
        
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Name, Email, Phone, AccountId, OwnerId FROM Contact WHERE RecordType.DeveloperName = 'Student'];
        contacts[0].Email = 'mydlstest@gmail.com';
        update contacts[0];
        
        String s = AccountUtil.dlsInstructorAccountCreation(contacts[0].Id);
        //System.assertEquals('Invalid RecordType', s);
    }
    
    // Cover dlsInstructorAccountCreation() method in AccountUtil
    private static testMethod void myTest8b(){
    
        Account parentAcc = new Account();
        parentAcc.Name = 'DLS';
        insert parentAcc;
        
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Name, Email, Phone, AccountId, OwnerId FROM Contact WHERE RecordType.DeveloperName = 'DLS_Employee'];
        contacts[0].Email = 'mydlstest@gmail.com';
        update contacts[0];
        
        AccountUtil.dlsInstructorAccountCreation(contacts[0].Id);
        
        List<Account> acc = [SELECT Id FROM Account WHERE ParentId != NULL AND Parent.Name = 'DLS' AND RecordType.DeveloperName = 'DLS'];
        System.assertEquals(1, acc.size());
    }
    
    // Cover createPVTAccRecs() method in AccountUtil
    private static testMethod void myTest8c(){
            
        Account parentAcc = new Account();
        parentAcc.Name = 'PVT';
        insert parentAcc;
        
        Id commRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial_Clients').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c, Candidate_Name__c FROM Contact_Assignments__c WHERE Status__c IN ('Planned','Active') AND RecordType.DeveloperName = 'Student'];
        System.debug(':::conAssigns:::'+conAssigns);
        
        List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
        for(Contact_Assignments__c ca : [SELECT Id, End_Date__c FROM Contact_Assignments__c WHERE Project__c = : conAssigns[0].Project__c]){
            ca.End_Date__c = Date.Today();
            updateCAs.add(ca);    
        }
        update updateCAs;
        
        List<Contact> contact = [SELECT Id, Email, Name FROM Contact WHERE Id = :conAssigns[0].Candidate_Name__c];
        contact[0].Email = 'testcon@softsquare.biz';
        update contact[0];
        
        Account childAcc = new Account();
        childAcc.Name = contact[0].Name;
        childAcc.Email__c = 'testcon@softsquare.biz';
        childAcc.RecordTypeId = commRTId;
        childAcc.ParentId = parentAcc.Id;
        insert childAcc;
        
        Id testRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
    
        Test.startTest();
            
            Date stMonth = Date.Today().toStartOfMonth().addDays(-15);
            Date edMonth = stMonth.addDays(7);
            
            List<AcctSeed__Project__c> proj = [SELECT Id, RecordTypeId, AcctSeed__Account__c, AcctSeed__Opportunity__c, Start_Date__c, End_Date__c, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE Id = :conAssigns[0].Project__c];
            System.debug(':::proj:::'+proj);
            proj[0].AcctSeed__Account__c = parentAcc.Id;
            proj[0].Start_Date__c = stMonth;
            proj[0].End_Date__c = edMonth;
            proj[0].AcctSeed__Status__c = 'Ended';
            proj[0].RecordTypeId = testRTId;
            update proj[0];
            
            List<Opportunity> opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :proj[0].AcctSeed__Opportunity__c];
            System.debug(':::proj:::'+proj);
            opp[0].AccountId = parentAcc.Id;
            update opp[0];       
            
            AccountUtil.createPVTAccRecs(proj[0].Id);
        Test.stopTest();
    }
    
    // Cover createPVTAccRecs() method in AccountUtil
    private static testMethod void myTest8d(){
    
        Account parentAcc = new Account();
        parentAcc.Name = 'PVT';
        insert parentAcc;
        
        Date stMonth = Date.Today().toStartOfMonth().addDays(-30);
        Date edMonth = stMonth.addDays(7);
        
        Id testRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> proj = [SELECT Id, RecordTypeId, AcctSeed__Account__c, AcctSeed__Opportunity__c, Start_Date__c, End_Date__c, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active'];
        System.debug(':::proj:::'+proj);
        
        List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
        for(Contact_Assignments__c ca : [SELECT Id, End_Date__c FROM Contact_Assignments__c WHERE Project__c = : proj[0].Id]){
            ca.End_Date__c = Date.Today();
            updateCAs.add(ca);    
        }
        update updateCAs;
        
        proj[0].AcctSeed__Account__c = parentAcc.Id;
        proj[0].Start_Date__c = stMonth;
        proj[0].End_Date__c = edMonth;
        proj[0].AcctSeed__Status__c = 'Ended';
        proj[0].RecordTypeId = testRTId;
        update proj[0];
        
        List<Opportunity> opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :proj[0].AcctSeed__Opportunity__c];
        System.debug(':::proj:::'+proj);
        opp[0].AccountId = parentAcc.Id;
        update opp[0];
        
        Test.startTest();
            
            Contact c = new Contact();
            c.lastName = 'newTestCon';
            insert c;
            
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
            System.debug(':::conAssigns:::SIZE'+conAssigns.size());
            conAssigns[0].Assignment_Position__c = 'Class Leader';
            conAssigns[0].Candidate_Name__c = c.Id;
            conAssigns[0].Project__c = proj[0].Id;
            update conAssigns[0];
            
            List<Contact> contact = [SELECT Id, Email FROM Contact WHERE Id = :conAssigns[0].Candidate_Name__c];
            contact[0].Email = 'testcon@softsquare.biz';
            update contact[0];
            
            AccountUtil.createPVTAccRecs(proj[0].Id);
            
        Test.stopTest();
    }
    
    // Cover createChildPVT() method in AccountUtil
    private static testMethod void myTest8e(){
    
        Id commRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial_Clients').getRecordTypeId();
        
        Account parentAcc = new Account();
        parentAcc.Name = 'PVT';
        insert parentAcc;
              
        List<Contact> contact = [SELECT Id, Email, AccountId FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Student' LIMIT 1];
        contact[0].AccountId = parentAcc.Id;
        update contact[0];
                            
        Test.startTest();
            
            AccountUtil.dlsInstructorAccountCreation(contact[0].Id); // It calls createChildPVT() method
        Test.stopTest();
    }
    
    // Cover createChildPVT() method in AccountUtil
    private static testMethod void myTest8f(){
    
        Id commRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial_Clients').getRecordTypeId();
        
        Account parentAcc = new Account();
        parentAcc.Name = 'PVT';
        insert parentAcc;
                      
        List<Contact> contact = [SELECT Id, Email, AccountId, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Student' LIMIT 1];
        contact[0].AccountId = parentAcc.Id;
        update contact[0];
               
        Account childAcc = new Account();
        childAcc.Name = 'PVT - ' + contact[0].Name;
        childAcc.Email__c = contact[0].Email;
        childAcc.RecordTypeId = commRTId;
        childAcc.ParentId = parentAcc.Id;
        insert childAcc;
             
        Test.startTest();
            
            AccountUtil.dlsInstructorAccountCreation(contact[0].Id); // It calls createChildPVT() method
        Test.stopTest();
    }
    
    // Cover dlsInstructorAccountCreation() method in AccountUtil
    private static testMethod void myTest8g(){
        
        List<Contact> contact = [SELECT Id, Email, AccountId FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Contact' LIMIT 1];
        
        Test.startTest();
        
        AccountUtil.dlsInstructorAccountCreation(contact[0].Id); 
        Test.stopTest();
    }
    
    // Cover createChildPVT() method in AccountUtil
    private static testMethod void myTest8h(){
        
        Id commRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial_Clients').getRecordTypeId();
        
        Account parentAcc = new Account();
        parentAcc.Name = 'PVT';
        insert parentAcc;
        
        List<Contact> contact = [SELECT Id, Email, AccountId, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Student' LIMIT 1];
        contact[0].AccountId = parentAcc.Id;
        update contact[0];
        
        Account childAcc = new Account();
        childAcc.Name = contact[0].Name;
        childAcc.Email__c = contact[0].Email;
        childAcc.RecordTypeId = commRTId;
        childAcc.ParentId = parentAcc.Id;
        insert childAcc;
        
        Test.startTest();
        
        AccountUtil.dlsInstructorAccountCreation(contact[0].Id); // It calls createChildPVT() method
        AccountUtil.dlsInstructorAccountCreation(contact[0].Id); // It calls createChildPVT() method
        Test.stopTest();
    }
    public static testMethod void myTest5A() {
        
        List<AcctSeed__Project__c> pro = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 2];
        
        List<RecordType> rtype = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Contact_Assignments__c','AcctSeed__Project__c') AND DeveloperName IN ('Instructor','DLI_W_LT_Projects')];
        Id caRtId, proRtId;
        
        if(rtype.size() > 0) {
            for(RecordType rt : rtype) {
                if(rt.DeveloperName == 'Instructor') 
                    caRtId = rt.Id;
                else 
                    proRtId = rt.Id;
            }
        }
        
        List<Contact> con = new List<Contact> {
            new Contact(LastName = 'Test Cont1', Email = 'test1@gmail.com'),
            new Contact(LastName = 'Test Cont2', Email = 'test2@gmail.com')
           };
           insert con;
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = con[0].Id, Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA MTT',AcctSeed__Hourly_Cost__c = 43 , Status__c = 'Approved',Payroll_Item__c='R'),
            new AcctSeed__Cost_Rates__c(Contact__c = con[0].Id,Pay_Type__c = 'Salary', Rate_Type__c = 'Non-SCA Testing',AcctSeed__Hourly_Cost__c = 22, Per_Test_Cost__c = 1, Status__c = 'Approved',Payroll_Item__c='P')
           };
           insert costrateList;
        
        if(pro.size() > 0) {
            Test.startTest();
            
            pro[0].RecordTypeId = proRtId;
            pro[1].RecordTypeId = proRtId;
            update pro;
            
            List<Contact_Assignments__c> conAss = new List<contact_Assignments__c> {
                new Contact_Assignments__c(Project__c = pro[0].Id, RecordTypeId = caRtId, Candidate_Name__c = con[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active',Rate_Card_Rate__c = costrateList[0].Id),
                 new Contact_Assignments__c(Project__c = pro[0].Id, RecordTypeId = caRtId, Candidate_Name__c = con[1].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active')
            };
            insert conAss;
            
            if(costrateList.size() > 0){
                costrateList[1].Prior_Version__c = costrateList[0].Id;
                costrateList[0].Status__c = 'Inactive';
                
                update costrateList;
            }
            Test.stopTest();
            
            String conAssignJSON = CustomButtonService.getInactiveLCRRelatedConAssigns(pro[0].Id);
           ManageProjectDatescontroller.CARecords conAssign = (ManageProjectDatescontroller.CARecords) JSON.deserialize(conAssignJSON , ManageProjectDatescontroller.CARecords.class);
            if(conAssign.conAssign.size() > 0){
                System.assertEquals('Planned', conAssign.conAssign[0].Status__c);
            }
            
        }
    }  
    public static testmethod void test6(){
        List<System_Values__c> sysVal = new List<System_Values__c>{
            new System_Values__c(Name ='Bill.com Vendor Last Sync Date Time', Value__c = '2020-04-24 08:30:45'), 
            new System_Values__c(Name ='Bill.com Job Last Sync Date Time', Value__c = '2020-04-24 08:30:45'),
            new System_Values__c(Name ='Bill.com Item Last Sync Date Time', Value__c = '2020-04-24 08:30:45'),
            new System_Values__c(Name ='Bill.com Class Last Sync Date Time', Value__c = '2020-04-24 08:30:45')
        };
        
        insert sysVal;
        Account acc = new Account(Name='New Test Account 1', Email__c = 'myacc1@gmail.com',Status_Bill_com__c = 'Active', AcctSeed__Accounting_Type__c = 'Vendor');
        Insert acc; 
        Account acc1 = CustomButtonService.getAccountForVendorCreation(acc.Id);       
        String result = CustomButtonService.executeVendorCreationBatch(acc.Id);        
        System.assertEquals(result, 'success');
    }
}