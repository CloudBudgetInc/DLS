@isTest
Public Class plannedDaysOff_Trigger_Test{
     
    @testSetup static void setupMethod(){
            
        List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'FALSE')};
        Insert sysVal;    
        List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        Test.startTest();
            List<Events__c> events = TestClassUtil.createTestEvent();
        Test.stopTest();
    }
    
     /* static testMethod void plannedDaysOff_TriggerMethod() {
        String studRT;
        String InstRT;
        String projectRT;
        Account acc = new Account(Name='Test Account 1');
        Insert acc;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=acc.Id,LastName='Test Contact 1'),
            new Contact(AccountId=acc.Id,LastName='Test Contact 2'),
            new Contact(AccountId=acc.Id,LastName='Test Contact 3'),
            new Contact(AccountId=acc.Id,LastName='Test Contact 4')
        };
        Insert contactList;
        
        for(RecordType rt : [select id,Name,DeveloperName from RecordType where SobjectType='Contact_Assignments__c']){
            if(rt.DeveloperName == 'Student') studRT = rt.Id;
            if(rt.DeveloperName == 'Instructor') InstRT = rt.Id;
        }
        
        for(RecordType rt : [select id,Name,DeveloperName from RecordType where SobjectType='AcctSeed__Project__c']){
            if(rt.DeveloperName == 'Language_Training_Projects') projectRT = rt.Id;
        }
        
        Opportunity opp = new Opportunity(AccountId=acc.Id,Name='Test Opp',CloseDate=System.Today(),StageName='Qualification');
        Insert opp;
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = acc.Id,AcctSeed__Opportunity__c=opp.Id,RecordTypeId = projectRT);
        Insert proj;
        
        List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(Status__c = 'Active',Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = opp.Id,RecordTypeId = InstRT,Project__c = proj.Id,Start_Date__c = Date.NewInstance(2014,05,10),End_Date__c = Date.NewInstance(2015,05,10)),
            new Contact_Assignments__c(Status__c = 'Active',Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = opp.Id,RecordTypeId = InstRT,Project__c = proj.Id,Start_Date__c = Date.NewInstance(2014,05,10),End_Date__c = Date.NewInstance(2015,05,10))
        }; 
        Insert contAssignList;
        
        List<Schedule__c> schList = new List<Schedule__c>{
            new Schedule__c(Instructor__c=contactList[0].Id,End_Date__c=System.Today() + 10,Start_Date__c=System.Today(),Start_Time__c='09:00 AM',End_Time__c='10:00 AM',Tuesday__c=True,Monday__c=True,Opportunity__c = opp.Id),
            new Schedule__c(Instructor__c=contactList[1].Id,End_Date__c=System.Today() + 10,Start_Date__c=System.Today(),Start_Time__c='11:00 AM',End_Time__c='12:00 PM',Thursday__c=True,Monday__c=True,Opportunity__c = opp.Id)
        };
        Insert schList;
        
        List<Events__c> eventList = new List<Events__c>{
            new Events__c(Instructor__c = contactList[0].Id,Schedule__c=schList[0].Id,Start_Time__c='09:00 AM',End_Time__c='10:00 AM',Date__c=system.today()+4,Status__c='Scheduled',SequenceNo__c=1235,Project__c = proj.Id),
            new Events__c(Instructor__c = contactList[0].Id,Schedule__c=schList[0].Id,Start_Time__c='09:00 AM',End_Time__c='10:00 AM',Date__c=system.today()+1,Status__c='Scheduled',SequenceNo__c=1234,Project__c = proj.Id),
            new Events__c(Instructor__c = contactList[1].Id,Schedule__c=schList[1].Id,Start_Time__c='09:00 AM',End_Time__c='10:00 AM',Date__c=system.today()+2,Status__c='Scheduled',SequenceNo__c=1233,Project__c = proj.Id),
            new Events__c(Instructor__c = contactList[1].Id,Schedule__c=schList[1].Id,Start_Time__c='09:00 AM',End_Time__c='10:00 AM',Date__c=system.today()+3,Status__c='Scheduled',SequenceNo__c=1232,Project__c = proj.Id)

        };
        Insert eventList;
        
        List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
            new Planned_Days_Off__c(Contact__c = contactList[0].Id,Date__c=System.today(),Description__c='Test',Requested_Reschedule_Date__c=System.today()+15),
            new Planned_Days_Off__c(Contact__c = contactList[0].Id,Date__c=System.today()+10,Description__c='Test',Requested_Reschedule_Date__c=System.today()+20)

        };
        try {        
            Insert plannedDaysOffList;
        } catch(DMLException e) {
            System.assert(e.getMessage().contains('Since the selected "Requested Reschedule Date" already has an Event, Please select some other date.'));    
        }
        Planned_Days_Off__c  pdO = new Planned_Days_Off__c(Id=plannedDaysOffList[0].Id,Requested_Reschedule_Date__c = system.today()+1,Date__c = system.today()+1);
        
        try {        
            Update pdO;
        } catch(DMLException e) {
            System.assert(e.getMessage().contains('Please select some other date'));    
        }
     } 
     */
     // For deleting and creating the planned days off
     private static testMethod void testMethod1() {
         List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c', 'Contact') AND DeveloperName IN ('Request', 'Staff_Planned_Days_Off', 'DLS_Employee')];
         
         String planReqRt, conRt, planStaffRt;
         
         if(rType.size() > 0) {
             
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'Request') planReqRt = rt.Id;
                if(rt.DeveloperName == 'DLS_Employee') conRt = rt.Id;
                if(rt.DeveloperName == 'Staff_Planned_Days_Off') planStaffRt = rt.Id;
            }
            
            List<Account> accList = new List<Account> {
                new Account(Name = 'Test Acccount')
            };
            insert accList;
            
            List<Contact> contactList = new List<Contact>{
                new Contact(AccountId=accList[0].Id,LastName='Test Contact 1', RecordTypeId = conRt),
                new Contact(AccountId=accList[0].Id,LastName='Test Contact 2', RecordTypeId = conRt)
            };
            insert contactList;
            
            List<Profile> profileUser = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
               
            if(profileUser.size() > 0) {
                
                String orgId = UserInfo.getOrganizationId();
                String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
                Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
                String uniqueName = orgId + dateString + randomInt;
                
                List<User> userList = new List<User>{        
                    new User(Alias = uniqueName.substring(18, 23), Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8', LastName='Testing', 
                    LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profileUser[0].Id, contact=contactList[0], 
                    TimeZoneSidKey='America/Los_Angeles', UserName = uniqueName + '@test' + orgId + '.org',Instructor_Access__c = true,  
                    Student_Access__c = true, Partner_Access__c = true, Client_Access__c = true)
                };
                insert userList;
               
                List<User> userList1 = new List<User> {
                    new User(Alias = uniqueName.substring(18, 23), Email = uniqueName + '1@test' + orgId + '.org',EmailEncodingKey='UTF-8', LastName='Testing', ManagerId = userList[0].Id,
                    LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profileUser[0].Id, contact=contactList[0], 
                    TimeZoneSidKey='America/Los_Angeles', UserName= uniqueName + '1@test' + orgId + '.org',Instructor_Access__c = true,  
                    Student_Access__c = true, Partner_Access__c = true, Client_Access__c = true)
                };
                insert userList1;
               
                Test.startTest();
                
                    List<Contract> contractList = new List<Contract> {
                        new Contract(Name = 'Test Contract 1', AccountId = accList[0].Id, Status = 'Completed Draft', StartDate = system.today(), EndDate = system.today().addDays(5), Primary_POC__c = contactList[0].Id),
                        new Contract(Name = 'Test Contract 2', AccountId = accList[0].Id, Status = 'Completed Draft', StartDate = system.today(), EndDate = system.today().addDays(6), Primary_POC__c = contactList[1].Id)
                    };
                    insert contractList;
                
                    System.runAs(userList1[0]) {
                        List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
                            new Planned_Days_Off__c(Contact__c = contactList[0].Id,Date__c=System.today(),Description__c='Test',Requested_Reschedule_Date__c=System.today()+15, RecordTypeId = planReqRt, Status__c = 'Draft', User__c = userList1[0].Id),
                            new Planned_Days_Off__c(Contact__c = contactList[0].Id,Date__c=System.today()+10,Description__c='Test',Requested_Reschedule_Date__c=System.today()+20, RecordTypeId = planStaffRt, Status__c = 'Delete', User__c = userList1[0].Id)
                        };
                        insert plannedDaysOffList;
                        
                        // Record is deleted when the status is updated to 'Approved' from 'Delete'
                        plannedDaysOffList[1].Status__c = 'Approved';
                        
                        // Record is created when the status is updated to 'Approved' when the plandaysoff Recordtype is 'Request'
                        plannedDaysOffList[0].Status__c = 'Approved';
                        update plannedDaysOffList;
                        
                        List<Planned_Days_Off__c> pdoUp = [SELECT Id, Name FROM Planned_Days_Off__c WHERE Id = :plannedDaysOffList[0].Id];
                    }
                Test.stopTest();
            }
         }
     }
     
     private static testMethod void myTest1(){
     
         List<RecordType> rType = [SELECT Id, Name, DeveloperName,SobjectType FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c', 'Contact', 'Contact_Assignments__c') AND DeveloperName IN ('Request', 'Candidate', 'Instructor', 'Student')];
         
         Id reqRTId, candRTId, insRTId, stdRTId;
         
         if(rType.size() > 0) {
             
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'Request') reqRTId = rt.Id;
                if(rt.DeveloperName == 'Candidate') candRTId = rt.Id;
                if(rt.DeveloperName == 'Instructor') insRTId = rt.Id;
                if(rt.SobjectType == 'Contact_Assignments__c' && rt.DeveloperName == 'Student') stdRTId = rt.Id;
            }
        }
         
         List<Account> accList = new List<Account> {
            new Account(Name = 'Test Acccount')
        };
        insert accList;
        
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 1', Email = 'mytestcon1@ss.biz', RecordTypeId = candRTId, Supervisor_Name__c = UserInfo.getUserId()),
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 2', Email = 'mytestcon2@ss.biz', RecordTypeId = candRTId, Supervisor_Name__c = UserInfo.getUserId())
        };
        insert contactList;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+2, Candidate_Name__c = contactList[0].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = insRTId),
                new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+5, Candidate_Name__c = contactList[0].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = stdRTId)
            };
            
            insert conAssigns;
            
            List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
                new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc1',RecordTypeId = reqRTId, Status__c = 'Draft', Type__c='Instructor', All_Projects__c=TRUE),
                new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc2',RecordTypeId = reqRTId, Status__c = 'Draft', Type__c='Instructor', All_Projects__c=TRUE),
                new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc3',RecordTypeId = reqRTId, Status__c = 'Draft', Type__c='Instructor', All_Projects__c=TRUE)
            }; 
        
            insert plannedDaysOffList;
            
            List<Planned_Days_Off__c> pdoRequest = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id IN :plannedDaysOffList];
            System.debug(':::pdoRequest::::'+pdoRequest);
            
            pdoRequest[0].Status__c = 'Approved';
            pdoRequest[1].Status__c = 'Approved';
            pdoRequest[2].Status__c = 'Approved';
            update pdoRequest;
        Test.stopTest();
     }
     
     private static testMethod void myTest2(){
     
         List<RecordType> rType = [SELECT Id, Name, DeveloperName,SobjectType FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c', 'Contact', 'Contact_Assignments__c') AND DeveloperName IN ('Request', 'Candidate', 'Instructor', 'Student')];
         
         Id reqRTId, candRTId, insRTId, stdRTId;
         
         if(rType.size() > 0) {
             
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'Request') reqRTId = rt.Id;
                if(rt.DeveloperName == 'Candidate') candRTId = rt.Id;
                if(rt.DeveloperName == 'Instructor') insRTId = rt.Id;
                if(rt.SobjectType == 'Contact_Assignments__c' && rt.DeveloperName == 'Student') stdRTId = rt.Id;
            }
        }
         
         List<Account> accList = new List<Account> {
            new Account(Name = 'Test Acccount')
        };
        insert accList;
        
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 1', Email = 'mytestcon1@ss.biz', RecordTypeId = candRTId, Supervisor_Name__c = UserInfo.getUserId()),
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 2', Email = 'mytestcon2@ss.biz', RecordTypeId = candRTId, Supervisor_Name__c = UserInfo.getUserId())
        };
        insert contactList;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        Test.startTest();
            List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+2, Candidate_Name__c = contactList[0].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = insRTId),
                new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+5, Candidate_Name__c = contactList[0].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = stdRTId)
            };
            
            insert conAssigns;
            
            List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
                new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = reqRTId , Status__c = 'Draft', Type__c='Instructor', All_Projects__c=TRUE),
                new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc2',RecordTypeId = reqRTId, Status__c = 'Draft', Type__c='Instructor'),
                new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc3',RecordTypeId = reqRTId, Status__c = 'Draft', Type__c='Instructor')
            };
            insert plannedDaysOffList;
            
            List<Planned_Days_Off__c> pdoRequest = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id IN :plannedDaysOffList];
            System.debug(':::pdoRequest::::'+pdoRequest);
            
            pdoRequest[0].Status__c = 'Approved';
            pdoRequest[1].Status__c = 'Approved';
            pdoRequest[2].Status__c = 'Approved';
            update pdoRequest;
        Test.stopTest();
     }
     
     private static testMethod void myTest3(){
     
         List<RecordType> rType = [SELECT Id, Name, DeveloperName,SobjectType FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c', 'Contact', 'Contact_Assignments__c') AND DeveloperName IN ('Request', 'Candidate', 'Instructor', 'Student')];
         
         Id reqRTId, candRTId, insRTId, stdRTId, stdConRTId;
         
         if(rType.size() > 0) {
             
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'Request') reqRTId = rt.Id;
                if(rt.DeveloperName == 'Candidate') candRTId = rt.Id;
                if(rt.DeveloperName == 'Instructor') insRTId = rt.Id;
                if(rt.SobjectType == 'Contact_Assignments__c' && rt.DeveloperName == 'Student') stdRTId = rt.Id;
                if(rt.SobjectType == 'Contact' && rt.DeveloperName == 'Student') stdConRTId = rt.Id;
            }
        }
         
         List<Account> accList = new List<Account> {
            new Account(Name = 'Test Acccount')
        };
        insert accList;
        
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 1', Email = 'mytestcon1@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId()),
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 2', Email = 'mytestcon2@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId())
        };
        insert contactList;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        Test.startTest();
            List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+2, Candidate_Name__c = contactList[0].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = stdRTId),
                new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+5, Candidate_Name__c = contactList[0].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = insRTId)
            };
            
            insert conAssigns;
            
            List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
                new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = reqRTId , Status__c = 'Draft', Type__c='Student', All_Projects__c=TRUE),
                new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc2',RecordTypeId = reqRTId, Status__c = 'Draft', Type__c='Student', All_Projects__c=TRUE),
                new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc3',RecordTypeId = reqRTId, Status__c = 'Draft', Type__c='Student', All_Projects__c=TRUE)
            }; 
            insert plannedDaysOffList;
            
            List<Planned_Days_Off__c> pdoRequest = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id IN :plannedDaysOffList];
            System.debug(':::pdoRequest::::'+pdoRequest);
            
            pdoRequest[0].Status__c = 'Approved';
            pdoRequest[1].Status__c = 'Approved';
            pdoRequest[2].Status__c = 'Approved';
            update pdoRequest;
        Test.stopTest();
     }
     
     private static testMethod void myTest4(){
     
         List<RecordType> rType = [SELECT Id, Name, DeveloperName,SobjectType FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c', 'Contact', 'Contact_Assignments__c') AND DeveloperName IN ('Request', 'Candidate', 'Instructor', 'Student')];
         
         Id reqRTId, candRTId, insRTId, stdRTId, stdConRTId;
         
         if(rType.size() > 0) {
             
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'Request') reqRTId = rt.Id;
                if(rt.DeveloperName == 'Candidate') candRTId = rt.Id;
                if(rt.DeveloperName == 'Instructor') insRTId = rt.Id;
                if(rt.SobjectType == 'Contact_Assignments__c' && rt.DeveloperName == 'Student') stdRTId = rt.Id;
                if(rt.SobjectType == 'Contact' && rt.DeveloperName == 'Student') stdConRTId = rt.Id;
            }
        }
         
         List<Account> accList = new List<Account> {
            new Account(Name = 'Test Acccount')
        };
        insert accList;
        
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 1', Email = 'mytestcon1@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId()),
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 1', Email = 'mytestcon2@ss.biz', RecordTypeId = candRTId, Supervisor_Name__c = UserInfo.getUserId())
        };
        insert contactList;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+2, Candidate_Name__c = contactList[0].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = stdRTId),
                new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+5, Candidate_Name__c = contactList[1].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = insRTId)
            };
            
            insert conAssigns;
            
            List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
                new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc1',RecordTypeId = reqRTId , Status__c = 'Draft', Type__c='Student', Project__c = projects[0].Id),
                new Planned_Days_Off__c(Contact__c=contactList[1].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc2',RecordTypeId = reqRTId, Status__c = 'Draft', Type__c='Instructor', Project__c=projects[0].Id),
                new Planned_Days_Off__c(Contact__c=contactList[1].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc2',RecordTypeId = reqRTId, Status__c = 'Draft', Type__c='Staff', Project__c=projects[0].Id)
            }; 
            insert plannedDaysOffList;
            
            List<Planned_Days_Off__c> pdoRequest = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id IN :plannedDaysOffList];
            System.debug(':::pdoRequest::::'+pdoRequest);
            
            pdoRequest[0].Status__c = 'Approved';
            pdoRequest[1].Status__c = 'Approved';
            update pdoRequest;
            
            List<Task> taskList = [SELECT Id FROM Task WHERE WhoId = :contactList[0].Id];
            //System.assertEquals(1, taskList.size());
        Test.stopTest();
     }
     
     private static testMethod void myTest5(){
     
         Id p = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;
         
         List<User> users = new List<User>{
            new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='mytestcontactusr@noemail.com'
            ),
            new User(alias = 'test345', email='test345@noemail.com',
                emailencodingkey='UTF-8', lastname='userTesting', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='myusrcontacttest@noemail.com'
            ),
            new User(alias = 'test567', email='test567@noemail.com',
                emailencodingkey='UTF-8', lastname='triggerTestUser', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='mytesttriggerusr@noemail.com'
            )
        };
       
        insert users;
        
        List<Contact> conList=new List<Contact> {
            new Contact(FirstName=users[0].FirstName, MiddleName=users[0].MiddleName, LastName=users[0].LastName),
            new Contact(FirstName=users[0].FirstName, MiddleName=users[0].MiddleName, LastName=users[0].LastName),
            new Contact(FirstName=users[0].FirstName, MiddleName=users[0].MiddleName, LastName=users[0].LastName)
        };
        
        Test.startTest();
            insert conList;
            PlannedDaysOffHandler.getContactRelatedUsers(new Set<Id>{conList[0].Id, conList[1].Id, conList[2].Id});
        Test.stopTest();
     }
     
     private static testMethod void myTest6(){
     
         Id p = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;
         
         List<User> users = new List<User>{
            new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='mytestcontactusr@noemail.com'
            ),
            new User(alias = 'test345', email='test345@noemail.com',
                emailencodingkey='UTF-8', lastname='userTesting', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='myusrcontacttest@noemail.com'
            ),
            new User(alias = 'test567', email='test567@noemail.com',
                emailencodingkey='UTF-8', lastname='triggerTestUser', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='mytesttriggerusr@noemail.com'
            )
        };
       
        insert users;
        
        List<Contact> conList=new List<Contact> {
            new Contact(FirstName=users[0].FirstName, MiddleName=users[0].MiddleName, LastName=users[0].LastName),
            new Contact(FirstName=users[0].FirstName, MiddleName=users[0].MiddleName, LastName=users[0].LastName),
            new Contact(FirstName=users[0].FirstName, MiddleName=users[0].MiddleName, LastName=users[0].LastName)
        };
        
        Test.startTest();
            insert conList;
            PlannedDaysOffHandler.getUserRelatedContacts(new Set<Id>{users[0].Id, users[1].Id, users[2].Id});
        Test.stopTest();
     }
     
     private static testMethod void myTest7(){
     
         List<RecordType> rType = [SELECT Id, Name, DeveloperName,SobjectType FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c') AND DeveloperName IN ('DLI_W_LT_Training_Holidays')];
         
         Id dliwltRTId;
         
         if(rType.size() > 0) {
             
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'DLI_W_LT_Training_Holidays') dliwltRTId = rt.Id;
            }
        }
        
        List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
            new Planned_Days_Off__c(From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc1',RecordTypeId = dliwltRTId, Status__c = 'Draft')
        }; 
        
        Test.startTest();
            insert plannedDaysOffList;
           
        Test.stopTest();
     }
     
     private static testMethod void myTest8(){
     
         List<RecordType> rType = [SELECT Id, Name, DeveloperName,SobjectType FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c', 'Contact', 'Contact_Assignments__c') AND DeveloperName IN ('Request', 'Candidate', 'Instructor', 'Student')];
         
         Id reqRTId, candRTId, insRTId, stdRTId, stdConRTId;
         
         if(rType.size() > 0) {
             
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'Request') reqRTId = rt.Id;
                if(rt.DeveloperName == 'Candidate') candRTId = rt.Id;
                if(rt.DeveloperName == 'Instructor') insRTId = rt.Id;
                if(rt.SobjectType == 'Contact_Assignments__c' && rt.DeveloperName == 'Student') stdRTId = rt.Id;
                if(rt.SobjectType == 'Contact' && rt.DeveloperName == 'Student') stdConRTId = rt.Id;
            }
        }
         
        List<Account> accList = new List<Account> {
            new Account(Name = 'Test Acccount')
        };
        insert accList;
        
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 1', Email = 'mytestcon1@ss.biz', RecordTypeId = candRTId, Supervisor_Name__c = UserInfo.getUserId()),
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 2', Email = 'mytestcon2@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId())
        };
        insert contactList;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+2, Candidate_Name__c = contactList[0].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = stdRTId),
                new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+5, Candidate_Name__c = contactList[0].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = insRTId)
            };
            
            insert conAssigns;
            
            List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
                new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = reqRTId , Status__c = 'Submitted for Approval', Type__c='Student', All_Projects__c=TRUE),
                new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc2',RecordTypeId = reqRTId, Status__c = 'Submitted for Approval', Type__c='Student', All_Projects__c=TRUE),
                new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc3',RecordTypeId = reqRTId, Status__c = 'Submitted for Approval', Type__c='Student', All_Projects__c=TRUE)
            }; 
            insert plannedDaysOffList;
            
            List<Planned_Days_Off__c> pdoRequest = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id IN :plannedDaysOffList];
            System.debug(':::pdoRequest::::'+pdoRequest);
            
            pdoRequest[0].Status__c = 'Not Approved';
            pdoRequest[1].Status__c = 'Not Approved';
            pdoRequest[2].Status__c = 'Not Approved';
            update pdoRequest;
            
            List<Task> taskList = [SELECT Id FROM Task WHERE WhoId = :contactList[0].Id];
            System.assertEquals(3, taskList.size());
        Test.stopTest();
     }
     
     // To cover sendEmailToLTSManagerSupr() method
     private static testMethod void myTest9(){
     
         List<RecordType> rType = [SELECT Id, Name, DeveloperName,SobjectType FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c', 'Contact', 'Contact_Assignments__c') AND DeveloperName IN ('Instructor_Planned_Days_Off','Student')];
         
         Id insPDORTId, stdConRTId, stdRTId;
         
         if(rType.size() > 0) {
             
            for(RecordType rt : rType) {
                if(rt.SobjectType == 'Contact' && rt.DeveloperName == 'Student') stdConRTId = rt.Id;
                if(rt.SobjectType == 'Contact_Assignments__c' && rt.DeveloperName == 'Student') stdRTId = rt.Id;
                if(rt.SobjectType == 'Planned_Days_Off__c' && rt.DeveloperName == 'Instructor_Planned_Days_Off') insPDORTId = rt.Id;
            }
        }
        
        List<Account> accList = new List<Account> {
            new Account(Name = 'Test Acccount')
        };
        insert accList;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 1', Email = 'mytestcon1@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId()),
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 2', Email = 'mytestcon2@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId())
        };
        insert contactList;
        
         List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
            new Planned_Days_Off__c(User__c = UserInfo.getUserId(), Contact__c=contactList[0].Id, From_Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = insPDORTId, Status__c = 'Approved', Type__c='Student', All_Projects__c=TRUE),
            new Planned_Days_Off__c(User__c = UserInfo.getUserId(), Contact__c=contactList[0].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc2',RecordTypeId = insPDORTId, Status__c = 'Approved', Type__c='Student', All_Projects__c=TRUE)
        };
        Test.startTest();
        
        insert plannedDaysOffList;
                
        List<Planned_Days_Off__c> pdoList = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id IN : plannedDaysOffList];
        pdoList[0].Status__c = 'Delete';
        update pdoList[0];
        
        Test.stopTest();
     }
     
     // To cover sendEmailToLTSManagerSupr() method
     private static testMethod void myTest9a(){
     
         List<RecordType> rType = [SELECT Id, Name, DeveloperName,SobjectType FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c', 'Contact', 'Contact_Assignments__c') AND DeveloperName IN ('Instructor_Planned_Days_Off','Student')];
         
         Id insPDORTId, stdConRTId, stdRTId;
         
         if(rType.size() > 0) {
             
            for(RecordType rt : rType) {
                if(rt.SobjectType == 'Contact' && rt.DeveloperName == 'Student') stdConRTId = rt.Id;
                if(rt.SobjectType == 'Contact_Assignments__c' && rt.DeveloperName == 'Student') stdRTId = rt.Id;
                if(rt.SobjectType == 'Planned_Days_Off__c' && rt.DeveloperName == 'Instructor_Planned_Days_Off') insPDORTId = rt.Id;
            }
        }
        
        List<Account> accList = new List<Account> {
            new Account(Name = 'Test Acccount')
        };
        insert accList;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 1', Email = 'mytestcon1@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId()),
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 2', Email = 'mytestcon2@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId())
        };
        insert contactList;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
            new Planned_Days_Off__c(User__c = UserInfo.getUserId(), Contact__c=contactList[0].Id, From_Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = insPDORTId, Status__c = 'Approved', Type__c='Student', Project__c = projects[0].Id),
            new Planned_Days_Off__c(User__c = UserInfo.getUserId(), Contact__c=contactList[0].Id, From_Date__c=System.today(),To_Date__c=System.today(), Description__c='Test Desc2',RecordTypeId = insPDORTId, Status__c = 'Approved', Type__c='Student', Project__c=projects[0].Id)
        };
        Test.startTest();
        
        insert plannedDaysOffList;
                
        List<Planned_Days_Off__c> pdoList = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id IN : plannedDaysOffList];
        pdoList[0].Status__c = 'Delete';
        update pdoList[0];
        
        Test.stopTest();
     }
     
     // To cover updateEventRecsToCancelled() method
     private static testMethod void myTest10(){
     
         List<RecordType> rType = [SELECT Id, Name, DeveloperName,SobjectType FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c', 'Contact', 'Contact_Assignments__c') AND DeveloperName IN ('Student_Planned_Days_Off','Student', 'Request')];
         
         Id stdPDORTId, stdConRTId, stdRTId, reqPDORTId;
         
         if(rType.size() > 0) {
             
            for(RecordType rt : rType) {
                if(rt.SobjectType == 'Contact' && rt.DeveloperName == 'Student') stdConRTId = rt.Id;
                if(rt.SobjectType == 'Contact_Assignments__c' && rt.DeveloperName == 'Student') stdRTId = rt.Id;
                if(rt.SobjectType == 'Planned_Days_Off__c' && rt.DeveloperName == 'Student_Planned_Days_Off') stdPDORTId = rt.Id;
                if(rt.SobjectType == 'Planned_Days_Off__c' && rt.DeveloperName == 'Request') reqPDORTId = rt.Id;
            }
        }
        
        List<Account> accList = new List<Account> {
            new Account(Name = 'Test Acccount')
        };
        insert accList;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 1', Email = 'mytestcon1@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId()),
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 2', Email = 'mytestcon2@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId())
        };
        insert contactList;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        Test.startTest();
        
        List<Events__c> events = [SELECT Id, Project__c, Date__c, Status__c FROM Events__c LIMIT 1];
        events[0].Project__c = projects[0].Id;
        events[0].Date__c = System.today();
        events[0].Status__c = 'Scheduled';
        update events[0];
                
        Planned_Days_Off__c pdo = new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Approved', Type__c='Student', Project__c = projects[0].Id);
        insert pdo;
        
        List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+2, Candidate_Name__c = contactList[0].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = stdRTId)
        };
        insert conAssigns;
        
        List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>();
        
        for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Project__c = :projects[0].Id AND RecordType.DeveloperName = 'Student']){
            Planned_Days_Off__c stdPDO = new Planned_Days_Off__c(Parent_Planned_Day_Off__c=pdo.Id, Contact__c=ca.Candidate_Name__c, Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = stdPDORTId, Status__c = 'Approved', Type__c='Student', Project__c = ca.Project__c);
            plannedDaysOffList.add(stdPDO);
        }
        
        if(plannedDaysOffList.size() > 0)
        insert plannedDaysOffList;
                
        List<Events__c> eve = [SELECT Id, Status__c FROM Events__c WHERE Id = :events[0].Id];
        //System.assertEquals('Canceled',eve[0].Status__c);
        
        Test.stopTest();
     }
     
     // To cover updateEventRecsToCancelled() method
     private static testMethod void myTest10a(){
     
         List<RecordType> rType = [SELECT Id, Name, DeveloperName,SobjectType FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c', 'Contact', 'Contact_Assignments__c') AND DeveloperName IN ('Student_Planned_Days_Off','Student', 'Request')];
         
         Id stdPDORTId, stdConRTId, stdRTId, reqPDORTId;
         
         if(rType.size() > 0) {
             
            for(RecordType rt : rType) {
                if(rt.SobjectType == 'Contact' && rt.DeveloperName == 'Student') stdConRTId = rt.Id;
                if(rt.SobjectType == 'Contact_Assignments__c' && rt.DeveloperName == 'Student') stdRTId = rt.Id;
                if(rt.SobjectType == 'Planned_Days_Off__c' && rt.DeveloperName == 'Student_Planned_Days_Off') stdPDORTId = rt.Id;
                if(rt.SobjectType == 'Planned_Days_Off__c' && rt.DeveloperName == 'Request') reqPDORTId = rt.Id;
            }
        }
        
        List<Account> accList = new List<Account> {
            new Account(Name = 'Test Acccount')
        };
        insert accList;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 1', Email = 'mytestcon1@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId()),
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 2', Email = 'mytestcon2@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId())
        };
        insert contactList;
        
        Test.startTest();
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        List<Events__c> events = [SELECT Id, Project__c, Date__c, Status__c FROM Events__c LIMIT 1];
        events[0].Project__c = projects[0].Id;
        events[0].Date__c = System.today();
        events[0].Status__c = 'Scheduled';
        update events[0];
        
        List<Planned_Days_Off__c> createPDOs = new List<Planned_Days_Off__c>();
        
        Planned_Days_Off__c pdo = new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Approved', Type__c='Student', Project__c = projects[0].Id);
        Planned_Days_Off__c oldPDO = new Planned_Days_Off__c(Contact__c=contactList[1].Id, Date__c=System.today().addDays(2),Description__c='Test Desc1',RecordTypeId = stdPDORTId, Status__c = 'Approved', Type__c='Student', Project__c = projects[0].Id);
        createPDOs.add(pdo);
        createPDOs.add(oldPDO);
        
        insert createPDOs;
        
        List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+2, Candidate_Name__c = contactList[0].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = stdRTId),
            new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+2, Candidate_Name__c = contactList[1].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = stdRTId)
        };
        insert conAssigns;
        
        List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
            new Planned_Days_Off__c(Parent_Planned_Day_Off__c=pdo.Id, Contact__c=contactList[0].Id, Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = stdPDORTId, Status__c = 'Approved', Type__c='Student', Project__c = projects[0].Id),
            new Planned_Days_Off__c(Parent_Planned_Day_Off__c=pdo.Id, Contact__c=contactList[0].Id, Date__c=System.today().addDays(2),Description__c='Test Desc2',RecordTypeId = stdPDORTId, Status__c = 'Approved', Type__c='Student', Project__c=projects[0].Id)
        };
        
        insert plannedDaysOffList;
                
        List<Events__c> eve = [SELECT Id, Status__c FROM Events__c WHERE Id = :events[0].Id];
        System.assertEquals('Scheduled',eve[0].Status__c);
        
        Test.stopTest();
     }
     
     // To cover updateEventRecsToScheduled() method
     private static testMethod void myTest11(){
     
         List<RecordType> rType = [SELECT Id, Name, DeveloperName,SobjectType FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c', 'Contact', 'Contact_Assignments__c') AND DeveloperName IN ('Student_Planned_Days_Off','Student', 'Request')];
         
         Id stdPDORTId, stdConRTId, stdRTId, reqPDORTId;
         
         if(rType.size() > 0) {
             
            for(RecordType rt : rType) {
                if(rt.SobjectType == 'Contact' && rt.DeveloperName == 'Student') stdConRTId = rt.Id;
                if(rt.SobjectType == 'Contact_Assignments__c' && rt.DeveloperName == 'Student') stdRTId = rt.Id;
                if(rt.SobjectType == 'Planned_Days_Off__c' && rt.DeveloperName == 'Student_Planned_Days_Off') stdPDORTId = rt.Id;
                if(rt.SobjectType == 'Planned_Days_Off__c' && rt.DeveloperName == 'Request') reqPDORTId = rt.Id;
            }
        }
        
        List<Account> accList = new List<Account> {
            new Account(Name = 'Test Acccount')
        };
        insert accList;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 1', Email = 'mytestcon1@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId()),
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 2', Email = 'mytestcon2@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId())
        };
        insert contactList;
        
        Test.startTest();
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        List<Events__c> events = [SELECT Id, Project__c, Date__c, Status__c FROM Events__c LIMIT 1];
        events[0].Project__c = projects[0].Id;
        events[0].Date__c = System.today();
        events[0].Status__c = 'Scheduled';
        update events[0];
        
        Planned_Days_Off__c pdo = new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Approved', Type__c='Student', Project__c = projects[0].Id);
        insert pdo;
        
        List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+2, Candidate_Name__c = contactList[0].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = stdRTId)
        };
        insert conAssigns;
        
        List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
            new Planned_Days_Off__c(Parent_Planned_Day_Off__c=pdo.Id, Contact__c=contactList[0].Id, Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = stdPDORTId, Status__c = 'Approved', Type__c='Student', Project__c = projects[0].Id),
            new Planned_Days_Off__c(Parent_Planned_Day_Off__c=pdo.Id, Contact__c=contactList[0].Id, Date__c=System.today(),Description__c='Test Desc2',RecordTypeId = stdPDORTId, Status__c = 'Approved', Type__c='Student', Project__c=projects[0].Id)
        };
        
        insert plannedDaysOffList;
        
        List<Planned_Days_Off__c> pdoList = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE RecordTypeId =: stdPDORTId];
        pdoList[0].Status__c = 'Delete';
        update pdoList[0];
        
        List<Events__c> eve = [SELECT Id, Status__c FROM Events__c WHERE Id = :events[0].Id];
        System.assertEquals('Scheduled',eve[0].Status__c);
        
        Test.stopTest();
     }
     
     // To cover updateEventRecsToScheduled() method
     private static testMethod void myTest11a(){
     
         List<RecordType> rType = [SELECT Id, Name, DeveloperName,SobjectType FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c', 'Contact', 'Contact_Assignments__c') AND DeveloperName IN ('Student_Planned_Days_Off','Student', 'Request')];
         
         Id stdPDORTId, stdConRTId, stdRTId, reqPDORTId;
         
         if(rType.size() > 0) {
             
            for(RecordType rt : rType) {
                if(rt.SobjectType == 'Contact' && rt.DeveloperName == 'Student') stdConRTId = rt.Id;
                if(rt.SobjectType == 'Contact_Assignments__c' && rt.DeveloperName == 'Student') stdRTId = rt.Id;
                if(rt.SobjectType == 'Planned_Days_Off__c' && rt.DeveloperName == 'Student_Planned_Days_Off') stdPDORTId = rt.Id;
                if(rt.SobjectType == 'Planned_Days_Off__c' && rt.DeveloperName == 'Request') reqPDORTId = rt.Id;
            }
        }
        
        List<Account> accList = new List<Account> {
            new Account(Name = 'Test Acccount')
        };
        insert accList;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 1', Email = 'mytestcon1@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId()),
            new Contact(AccountId=accList[0].Id,LastName='Test Contact 2', Email = 'mytestcon2@ss.biz', RecordTypeId = stdConRTId, Supervisor_Name__c = UserInfo.getUserId())
        };
        insert contactList;
        
        Test.startTest();
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        List<Events__c> events = [SELECT Id, Project__c, Date__c, Status__c FROM Events__c LIMIT 1];
        events[0].Project__c = projects[0].Id;
        events[0].Date__c = System.today();
        events[0].Status__c = 'Scheduled';
        update events[0];
        
        List<Planned_Days_Off__c> createPDOs = new List<Planned_Days_Off__c>();
        
        Planned_Days_Off__c pdo = new Planned_Days_Off__c(Contact__c=contactList[0].Id, From_Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Approved', Type__c='Student', Project__c = projects[0].Id);
        Planned_Days_Off__c oldPDO = new Planned_Days_Off__c(Contact__c=contactList[1].Id, Date__c=System.today().addDays(2),Description__c='Test Desc1',RecordTypeId = stdPDORTId, Status__c = 'Approved', Type__c='Student', Project__c = projects[0].Id);
        createPDOs.add(pdo);
        createPDOs.add(oldPDO);
        
        insert createPDOs;
        
        List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+2, Candidate_Name__c = contactList[0].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = stdRTId),
            new Contact_Assignments__c(Start_Date__c = Date.Today(), End_Date__c = Date.Today()+2, Candidate_Name__c = contactList[1].Id, Status__c = 'Active', Project__c = projects[0].Id, RecordTypeId = stdRTId)
        };
        insert conAssigns;
        
        List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
            new Planned_Days_Off__c(Parent_Planned_Day_Off__c=pdo.Id, Contact__c=contactList[0].Id, Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = stdPDORTId, Status__c = 'Approved', Type__c='Student', Project__c = projects[0].Id),
            new Planned_Days_Off__c(Parent_Planned_Day_Off__c=pdo.Id, Contact__c=contactList[0].Id, Date__c=System.today().addDays(2),Description__c='Test Desc2',RecordTypeId = stdPDORTId, Status__c = 'Approved', Type__c='Student', Project__c=projects[0].Id)
        };
        
        insert plannedDaysOffList;
                
        List<Events__c> eve = [SELECT Id, Status__c FROM Events__c WHERE Id = :events[0].Id];
        System.assertEquals('Scheduled',eve[0].Status__c);
        
        List<Planned_Days_Off__c> pdoList = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id =: pdo.Id];
        pdoList[0].Status__c = 'Delete';
        update pdoList[0];
               
        List<Events__c> eve1 = [SELECT Id, Status__c FROM Events__c WHERE Id = :events[0].Id];
        System.assertEquals('Scheduled',eve1[0].Status__c);
        
        Test.stopTest();
     }
    
     private static testMethod void myTest12(){
     
         Id stdRtId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Student_Planned_Days_Off').getRecordTypeId();
         
         List<Account> accList = new List<Account> {
            new Account(Name = 'Test Acccount')
        };
        insert accList;
        
        Contact c = new Contact(AccountId=accList[0].Id,LastName='mypdotest', Email = 'mytestcon1@ss.biz');
        insert c;
            
        Test.startTest();
        
            Id pId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
            
            User u = new User(
                ProfileId = pId,
                LastName = 'mypdotest',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            ); 
            insert u;
            
            Planned_Days_Off__c pdo = new Planned_Days_Off__c(Contact__c=c.Id, Date__c=System.today(),Description__c='Test Desc1',RecordTypeId = stdRtId, Status__c = 'Approved', All_Projects__c = TRUE);
            insert pdo;
        
        Test.stopTest();
     }
     
     // To cover updateEventRecsForProjectPDO() method
     private static testMethod void myTest13(){
     
        Id projPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Project_Planned_Days_Off').getRecordTypeId();
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        List<Events__c> events = [SELECT Id, Project__c, Date__c, Status__c FROM Events__c LIMIT 1];
        events[0].Project__c = projects[0].Id;
        events[0].Date__c = System.today().addDays(5);
        events[0].Status__c = 'Scheduled';
        update events[0];
        
        Test.startTest();
        
        Planned_Days_Off__c pdo = new Planned_Days_Off__c(Date__c = System.today().addDays(5),Description__c = 'Test Desc1',RecordTypeId = projPDORTId, Status__c = 'Approved', Project__c = projects[0].Id);
        insert pdo;
                        
        List<Events__c> eve = [SELECT Id, Status__c FROM Events__c WHERE Id = :events[0].Id];
        System.assertEquals('Canceled',eve[0].Status__c);
        
        Test.stopTest();
     }
     
     // To cover updateEventRecsForProjectPDO() method
     private static testMethod void myTest14(){
     
        Id projPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Project_Planned_Days_Off').getRecordTypeId();
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        
        List<Events__c> events = [SELECT Id, Project__c, Date__c, Status__c FROM Events__c LIMIT 1];
        events[0].Project__c = projects[0].Id;
        events[0].Date__c = System.today().addDays(5);
        events[0].Status__c = 'Scheduled';
        update events[0];
        
        Test.startTest();
        
        Planned_Days_Off__c pdo = new Planned_Days_Off__c(Date__c = System.today().addDays(5),Description__c = 'Test Desc1',RecordTypeId = projPDORTId,Status__c = 'Approved',Project__c = projects[0].Id);
        insert pdo;
        
        List<Planned_Days_Off__c> pdoList = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id = :pdo.Id];
        pdoList[0].Status__c = 'Delete';
        update pdoList[0];
        
        List<Events__c> eve = [SELECT Id, Status__c FROM Events__c WHERE Id = :events[0].Id];
        System.assertEquals('Scheduled',eve[0].Status__c);
        
        Test.stopTest();
     }
     /*
     // To cover updateChildPDOAndEventRecs() method
     private static testMethod void updateChildPDOAndEventRecs_1(){
         
        Test.startTest();
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60));
        insert proj;
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
                   
        
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60), Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
            insert conAssignRecs;
        
            List<Events__c> events = [SELECT Id, Project__c, Date__c, Status__c FROM Events__c LIMIT 2];
            
            events[0].Project__c = proj.Id;
            events[0].Date__c = System.today().addDays(6);
            events[0].Status__c = 'Scheduled';
            events[1].Project__c = proj.Id;
            events[1].Date__c = System.today().addDays(7);
            events[1].Status__c = 'Scheduled';
            update events;
            
            Id reqPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
            
            Planned_Days_Off__c pdo = new Planned_Days_Off__c(Contact__c=stdCon[0].Id, From_Date__c=System.today().addDays(5),To_Date__c=System.today().addDays(6), Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Submitted for Approval', Type__c='Student', Project__c = proj.Id);
            insert pdo;
            
            //List<Planned_Days_Off__c> updateParentPDO_Status = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id = :pdo.Id];
            pdo.Status__c = 'Approved';
            update pdo;
            
            //List<Planned_Days_Off__c> updateParentPDO_Date = [SELECT Id, From_Date__c, To_Date__c FROM Planned_Days_Off__c WHERE Id = :pdo.Id];
            pdo.From_Date__c = System.today().addDays(6);
            pdo.To_Date__c = System.today().addDays(7);
            update pdo;
            
        Test.stopTest();
     }
     */
     // To cover updateChildPDOAndEventRecs() method
     private static testMethod void updateChildPDOAndEventRecs_2(){
         
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                  
        Test.startTest();
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'UpdateChildPDO Test Project 2',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60));
        insert proj;
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
          
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60), Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
        insert conAssignRecs;
        
        List<Events__c> updateEvents = new List<Events__c>();
        Date dateVal = System.today().addDays(5);
        for(Events__c eve : [SELECT Id, Project__c, Date__c, Status__c FROM Events__c]){
            eve.Project__c = proj.Id;
            eve.Date__c = dateVal;
            eve.Status__c = 'Scheduled';
            dateVal =  dateVal+1;
            updateEvents.add(eve);
        }
        update updateEvents;
        
        Id reqPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
        
        Planned_Days_Off__c pdo = new Planned_Days_Off__c(Contact__c=stdCon[0].Id, From_Date__c=System.today().addDays(5),To_Date__c=System.today().addDays(8), Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Submitted for Approval', Type__c='Student', Project__c = proj.Id);
        insert pdo;
            
        Test.stopTest(); 
                    
        /*List<Planned_Days_Off__c> updateParentPDO_Status = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id = :pdo.Id];
        updateParentPDO_Status[0].Status__c = 'Approved';
        update updateParentPDO_Status[0];
        
        List<Planned_Days_Off__c> updateParentPDO_Date = [SELECT Id, From_Date__c, To_Date__c, All_Projects__c FROM Planned_Days_Off__c WHERE Id = :pdo.Id];
        updateParentPDO_Date[0].From_Date__c = System.today().addDays(6);
        updateParentPDO_Date[0].To_Date__c = System.today().addDays(7);
        updateParentPDO_Date[0].All_Projects__c = True;
        update updateParentPDO_Date[0]; */    
          
     }
     
     // To cover updateChildPDOAndEventRecs() method
     private static testMethod void updateChildPDOAndEventRecs_3(){
         
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Test.startTest();
         
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'UpdateChildPDO Test Project 3',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60));
        insert proj;
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60), Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
        insert conAssignRecs;
        
        List<Events__c> updateEvents = new List<Events__c>();
        Date dateVal = System.today().addDays(6);
        for(Events__c eve : [SELECT Id, Project__c, Date__c, Status__c FROM Events__c]){
            eve.Project__c = proj.Id;
            eve.Date__c = dateVal;
            eve.Status__c = 'Scheduled';
            dateVal =  dateVal+1;
            updateEvents.add(eve);
        }
        update updateEvents;
        
        Id reqPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
        
        Planned_Days_Off__c pdo = new Planned_Days_Off__c(Contact__c=stdCon[0].Id, From_Date__c=System.today().addDays(5),To_Date__c=System.today().addDays(8), Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Submitted for Approval', Type__c='Student', All_Projects__c = True);
        insert pdo;
            
        Test.stopTest(); 
                    
        /*List<Planned_Days_Off__c> updateParentPDO_Status = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id = :pdo.Id];
        updateParentPDO_Status[0].Status__c = 'Approved';
        update updateParentPDO_Status[0];
        
        List<Planned_Days_Off__c> updateParentPDO_Date = [SELECT Id, From_Date__c, To_Date__c, All_Projects__c FROM Planned_Days_Off__c WHERE Id = :pdo.Id];
        updateParentPDO_Date[0].From_Date__c = System.today().addDays(6);
        updateParentPDO_Date[0].To_Date__c = System.today().addDays(7);
        updateParentPDO_Date[0].Project__c = proj.Id;
        update updateParentPDO_Date[0]; */    
          
     }
     
     // To cover updateChildPDOAndEventRecs() method
     private static testMethod void updateChildPDOAndEventRecs_3a(){
         
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
            
        Test.startTest(); 
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
                
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'UpdateChildPDO Test Project 3a',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60));
        insert proj;
        
        Id reqPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
             
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60), Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60), Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
        };
        
        insert conAssignRecs;
        
        List<Events__c> updateEvents = new List<Events__c>();
        Date dateVal = System.today().addDays(6);
        for(Events__c eve : [SELECT Id, Project__c, Date__c, Status__c FROM Events__c]){
            eve.Project__c = proj.Id;
            eve.Date__c = dateVal;
            eve.Status__c = 'Scheduled';
            dateVal =  dateVal+1;
            updateEvents.add(eve);
        }
        update updateEvents;
                    
        Planned_Days_Off__c pdo = new Planned_Days_Off__c(User__c = UserInfo.getUserId(), Contact__c=stdCon[0].Id, From_Date__c=System.today().addDays(5),To_Date__c=System.today().addDays(8), Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Approved', Type__c='Student', All_Projects__c = True);
        insert pdo;
         
        //List<Planned_Days_Off__c> updateParentPDO_Date = [SELECT Id, From_Date__c, To_Date__c, All_Projects__c FROM Planned_Days_Off__c WHERE Id = :pdo.Id];
        pdo.From_Date__c = System.today().addDays(6);
        pdo.To_Date__c = System.today().addDays(7);
        update pdo;     
            
        Test.stopTest();   
     }
     /*
     // To cover updateChildPDOAndEventRecs() method
     private static testMethod void updateChildPDOAndEventRecs_4(){
         
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Test.startTest();
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60));
        insert proj;
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
                    
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60), Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
        insert conAssignRecs;
    
        List<Events__c> events = [SELECT Id, Project__c, Date__c, Status__c FROM Events__c LIMIT 2];
        events[0].Project__c = proj.Id;
        events[0].Date__c = System.today().addDays(10);
        events[0].Status__c = 'Scheduled';
        events[1].Project__c = proj.Id;
        events[1].Date__c = System.today().addDays(11);
        events[1].Status__c = 'Scheduled';
        update events;
        
        Id reqPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
        Test.stopTest();
        Planned_Days_Off__c pdo = new Planned_Days_Off__c(Contact__c=stdCon[0].Id, From_Date__c=System.today().addDays(5),To_Date__c=System.today().addDays(6), Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Submitted for Approval', Type__c='Student', Project__c = proj.Id);
        insert pdo;
        
        //List<Planned_Days_Off__c> updateParentPDO_Status = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id = :pdo.Id];
        pdo.Status__c = 'Approved';
        update pdo;
        
        //List<Planned_Days_Off__c> updateParentPDO_Date = [SELECT Id, From_Date__c, To_Date__c FROM Planned_Days_Off__c WHERE Id = :pdo.Id];
        pdo.From_Date__c = System.today().addDays(10);
        pdo.To_Date__c = System.today().addDays(11);
        update pdo;        
     }
     */
     // To cover updateChildPDOAndEventRecs() method
     private static testMethod void updateChildPDOAndEventRecs_5(){
         
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'UpdateChildPDO Test Project 5',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60));
        insert proj;
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
                    
        Test.startTest();
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60), Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
        insert conAssignRecs;
    
        List<Events__c> events = [SELECT Id, Project__c, Date__c, Status__c FROM Events__c LIMIT 2];
        events[0].Project__c = proj.Id;
        events[0].Date__c = System.today().addDays(10);
        events[0].Status__c = 'Scheduled';
        events[1].Project__c = proj.Id;
        events[1].Date__c = System.today().addDays(11);
        events[1].Status__c = 'Scheduled';
        update events;
        
        Id reqPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
        
        Planned_Days_Off__c pdo = new Planned_Days_Off__c(Contact__c=stdCon[0].Id, From_Date__c=System.today().addDays(5),Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Submitted for Approval', Type__c='Student', Project__c = proj.Id);
        insert pdo;
        
        List<Planned_Days_Off__c> updateParentPDO_Status = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id = :pdo.Id];
        updateParentPDO_Status[0].Status__c = 'Approved';
        update updateParentPDO_Status[0];
        
        List<Planned_Days_Off__c> updateParentPDO_Date = [SELECT Id, From_Date__c, To_Date__c FROM Planned_Days_Off__c WHERE Id = :pdo.Id];
        updateParentPDO_Date[0].From_Date__c = System.today().addDays(10);
        update updateParentPDO_Date[0];
            
        Test.stopTest();
     }
     
     // To cover updateChildPDOAndEventRecs() method
     private static testMethod void updateChildPDOAndEventRecs_6(){
         
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Test.startTest();
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'UpdateChildPDO Test Project 6',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60));
        insert proj;
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
                    
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60), Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60), Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
        insert conAssignRecs;
    
        List<Events__c> events = [SELECT Id, Project__c, Date__c, Status__c FROM Events__c LIMIT 2];
        events[0].Project__c = proj.Id;
        events[0].Date__c = System.today().addDays(10);
        events[0].Status__c = 'Scheduled';
        events[1].Project__c = proj.Id;
        events[1].Date__c = System.today().addDays(11);
        events[1].Status__c = 'Scheduled';
        update events;
        
        Id reqPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
        List<Planned_Days_Off__c> parentPDOs = new List<Planned_Days_Off__c>();
        
        Planned_Days_Off__c pdo1 = new Planned_Days_Off__c(Contact__c=stdCon[0].Id, From_Date__c=System.today().addDays(5),Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Submitted for Approval', Type__c='Student', Project__c = proj.Id);
        Planned_Days_Off__c pdo2 = new Planned_Days_Off__c(Contact__c=stdCon[1].Id, From_Date__c=System.today().addDays(10),Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Submitted for Approval', Type__c='Student', Project__c = proj.Id);
        parentPDOs.add(pdo1);
        parentPDOs.add(pdo2);
        insert parentPDOs;
        
        List<Planned_Days_Off__c> updateParentPDO_Status = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id IN :parentPDOs];
        updateParentPDO_Status[0].Status__c = 'Approved';
        updateParentPDO_Status[1].Status__c = 'Approved';
        update updateParentPDO_Status;
        
        List<Planned_Days_Off__c> updateParentPDO_Date = [SELECT Id, From_Date__c, To_Date__c FROM Planned_Days_Off__c WHERE Id IN :updateParentPDO_Status];
        updateParentPDO_Date[0].From_Date__c = System.today().addDays(10);
        update updateParentPDO_Date[0];
            
        Test.stopTest();
     }
     
     // To cover updateChildPDOAndEventRecs() method
     private static testMethod void updateChildPDOAndEventRecs_7(){
         
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Test.startTest();
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'UpdateChildPDO Test Project 7',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60));
        insert proj;
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60), Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = Date.Today().addDays(5), End_Date__c = Date.Today().addDays(60), Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
        insert conAssignRecs;
    
        List<Events__c> events = [SELECT Id, Project__c, Date__c, Status__c FROM Events__c LIMIT 2];
        events[0].Project__c = proj.Id;
        events[0].Date__c = System.today().addDays(5);
        events[0].Status__c = 'Canceled';
        events[1].Project__c = proj.Id;
        events[1].Date__c = System.today().addDays(6);
        events[1].Status__c = 'Canceled';
        update events;
        
        Id reqPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
        List<Planned_Days_Off__c> parentPDOs = new List<Planned_Days_Off__c>();
        
        Planned_Days_Off__c pdo1 = new Planned_Days_Off__c(Contact__c=stdCon[0].Id, From_Date__c=System.today().addDays(5),Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Submitted for Approval', Type__c='Student', Project__c = proj.Id);
        Planned_Days_Off__c pdo2 = new Planned_Days_Off__c(Contact__c=stdCon[1].Id, From_Date__c=System.today().addDays(5),Description__c='Test Desc2',RecordTypeId = reqPDORTId, Status__c = 'Submitted for Approval', Type__c='Student', Project__c = proj.Id);
        parentPDOs.add(pdo1);
        parentPDOs.add(pdo2);
        insert parentPDOs;
        
        Test.stopTest();
        
        /*List<Planned_Days_Off__c> updateParentPDO_Status = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id IN :parentPDOs];
        updateParentPDO_Status[0].Status__c = 'Approved';
        updateParentPDO_Status[1].Status__c = 'Approved';
        update updateParentPDO_Status;
        
        List<Planned_Days_Off__c> updateParentPDO_Date = [SELECT Id, From_Date__c, To_Date__c FROM Planned_Days_Off__c WHERE Id IN :updateParentPDO_Status];
        updateParentPDO_Date[0].From_Date__c = System.today().addDays(10);
        update updateParentPDO_Date[0];*/
        
     }
     
     private static testMethod void create_Update_DeleteTaskRelatedToProject_Test1(){
       
       List<Contact> cons = [SELECT Id, Name FROM Contact LIMIT 2];
       
       List<AcctSeed__Project__c> proj = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
       
       Id reqPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
       
       Planned_Days_Off__c parentPDO = new Planned_Days_Off__c(Contact__c=cons[0].Id, From_Date__c=System.today().addDays(10),Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Submitted for Approval', Type__c='Instructor', Project__c = proj[0].Id);
       insert parentPDO;
       
       parentPDO.Status__c = 'Approved';
       update parentPDO;
       
       Test.startTest();
       
           List<Planned_Days_Off__c> reqPDO = [SELECT Id, From_Date__c FROM Planned_Days_Off__c WHERE Id = :parentPDO.Id];
           reqPDO[0].From_Date__c = System.today().addDays(8);
           update reqPDO[0];
           
       Test.stopTest();
     }
     
     private static testMethod void create_Update_DeleteTaskRelatedToProject_Test2(){
       
       List<Contact> cons = [SELECT Id, Name FROM Contact LIMIT 2];
       
       List<AcctSeed__Project__c> proj = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
       
       Id reqPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
       
       Planned_Days_Off__c parentPDO = new Planned_Days_Off__c(Contact__c=cons[0].Id, From_Date__c=System.today().addDays(10),Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Submitted for Approval', Type__c='Instructor', Project__c = proj[0].Id);
       insert parentPDO;
       
       parentPDO.Status__c = 'Approved';
       update parentPDO;
       
       Test.startTest();
       
           List<Planned_Days_Off__c> reqPDO = [SELECT Id, Status__c FROM Planned_Days_Off__c WHERE Id = :parentPDO.Id];
           reqPDO[0].Status__c = 'Delete';
           update reqPDO[0];
           
       Test.stopTest();
     }
}