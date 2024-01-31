@isTest
private class EventListViewController_Test{
 
    @testSetup static void setupMethod(){
        
        List<Events__c> event = TestClassUtil.createTestEvent();
        Test.startTest();
            List<Planned_Days_Off__c> plannedDaysoffList = TestClassUtil.createTestPlannedDaysOff();
        Test.stopTest();
    }
    
    // To cover getEventRecords() method
    private static testMethod void myTest1(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
                
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c LIMIT 1];
        
        List<Events__c> events = [SELECT Id, Schedule__r.Project_Task__r.Project_Task_Type__c, Instructor__c, Status__c, Date__c FROM Events__c WHERE Project__c = :conAssigns[0].Project__c LIMIT 1];
        events[0].Instructor__c = conList[0].Id;        
        update events[0];
        
        System.runAs(user){
            String res = EventListViewController.getEventRecords(new List<String>{events[0].Status__c}, new List<String>{events[0].Schedule__r.Project_Task__r.Project_Task_Type__c}, String.valueOf(events[0].Date__c), String.valueOf(events[0].Date__c), new List<String>{'PlannedDayOff'}, conAssigns[0].Project__c);
            EventListViewController.EventInfo eventView = (EventListViewController.EventInfo) JSON.deserialize(res, EventListViewController.EventInfo.class);
            List<EventDomain.EventCalendarInfo> eventRecords = eventView.eventRecords;
            System.assertEquals(events[0].Id, eventRecords[0].eventId);
        }
        
        Test.stopTest();
    }
    
    // To cover getEventRecords() method
    private static testMethod void myTest2(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'instructor' LIMIT 1];
                
        List<Events__c> events = [SELECT Id, Schedule__r.Project_Task__r.Project_Task_Type__c, Instructor__c, Status__c, Date__c FROM Events__c WHERE Project__c = :conAssigns[0].Project__c LIMIT 1];
        events[0].Instructor__c = conList[0].Id;        
        update events[0];
        
        System.runAs(user){
            String res = EventListViewController.getEventRecords(new List<String>{events[0].Status__c}, new List<String>{events[0].Schedule__r.Project_Task__r.Project_Task_Type__c}, '', '', new List<String>{'PlannedDayOff'}, 'All');
            EventListViewController.EventInfo eventView = (EventListViewController.EventInfo) JSON.deserialize(res, EventListViewController.EventInfo.class);
            Date tempDate = Date.today();
            //Date startDate = (tempDate.toStartOfWeek()).addDays(1);
            System.assertEquals(tempDate, eventView.stDate );
        }
        
        Test.stopTest();
    }
    
    // To cover getEventRecords() method
    private static testMethod void myTest3(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
       Test.startTest();
       
            insert user;
        
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'instructor' LIMIT 1];
            conAssigns[0].Candidate_Name__c = conList[0].Id;
                
            update conAssigns[0];
            
            List<Events__c> events = [SELECT Id, Schedule__r.Project_Task__r.Project_Task_Type__c, Instructor__c, Status__c, Date__c FROM Events__c WHERE Project__c = :conAssigns[0].Project__c LIMIT 1];
            events[0].Instructor__c = conList[0].Id;
            update events[0];
                    
            System.runAs(user){
                EventListViewController.getEventRecords(new List<String>{events[0].Status__c}, new List<String>{events[0].Schedule__r.Project_Task__r.Project_Task_Type__c}, null, String.valueOf(events[0].Date__c), new List<String>{'PlannedDayOff'}, 'All');
                EventListViewController.getEventRecords(new List<String>{events[0].Status__c}, new List<String>{events[0].Schedule__r.Project_Task__r.Project_Task_Type__c}, String.valueOf(events[0].Date__c), null, new List<String>{'Holiday'}, 'All');
            }
            
        Test.stopTest();
    }
    
    // To cover getCommunityName() method
    private static testMethod void myTest4(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
                
        Test.startTest();
        
            insert user;
            
            System.runAs(user){
                EventListViewController.getCommunityName();
            }
        Test.stopTest();
    }
    
    // To cover getPlannedRecords() method
    private static testMethod void myTest5(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
           Test.startTest();
           
            insert user;
               
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' LIMIT 1];
            conAssigns[0].Candidate_Name__c = conList[0].Id;
            update conAssigns[0];
            
            Id reqRTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
    
            List<Planned_Days_Off__c> pdo = [SELECT Id, Contact__c, Name, Project__c, Status__c, RecordTypeId FROM Planned_Days_Off__c LIMIT 1];
            System.debug('pdo =='+pdo );
            pdo[0].Contact__c = conList[0].Id;
            pdo[0].Project__c = conAssigns[0].Project__c;
            pdo[0].Date__c = System.Today();
            pdo[0].RecordTypeId = reqRTId;
            pdo[0].Status__c = 'Approved';
            update pdo[0];
            
            List<Planned_Days_Off__c> plannedDays = [SELECT Id, Contact__c, Project__c,RecordType.DeveloperName, Status__c FROM Planned_Days_Off__c WHERE Id = :pdo[0].Id];
            System.debug('plannedDays=='+plannedDays[0].RecordType.DeveloperName+'==='+plannedDays[0].Status__c );
            
            System.runAs(user){
                String res = EventListViewController.getPlannedRecords(String.valueOf(System.Today()), String.valueOf(System.Today()), conAssigns[0].Project__c, 'Approved', TRUE);
                EventListViewController.LeaveInfo plannedOff = (EventListViewController.LeaveInfo) JSON.deserialize(res, EventListViewController.LeaveInfo.class);
                List<EventListViewController.plannedLeaveInfo> leaveInfoList = plannedOff.leaveInfoList;
              
                if(leaveInfoList.size() > 0){
                    System.assertEquals(pdo[0].Name, leaveInfoList[0].name);
                }
            }
            
        Test.stopTest();
    }
    
    // To cover getPlannedRecords() method
    private static testMethod void myTest6(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
       Test.startTest();
       
            insert user;
                
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' LIMIT 1];
            conAssigns[0].Candidate_Name__c = conList[0].Id;
            update conAssigns[0];
            
            List<Planned_Days_Off__c> pdo = [SELECT Id, Contact__c, Name, Project__c FROM Planned_Days_Off__c LIMIT 1];
            System.debug('pdo =='+pdo );
            pdo[0].Contact__c = conList[0].Id;
            pdo[0].Project__c = conAssigns[0].Project__c;
        
            update pdo[0];
            
            List<Planned_Days_Off__c> plannedDays = [SELECT Id, Contact__c, Project__c,RecordType.DeveloperName, Status__c FROM Planned_Days_Off__c WHERE Id = :pdo[0].Id];
            System.debug('plannedDays=='+plannedDays[0].RecordType.DeveloperName+'==='+plannedDays[0].Status__c );
            
            
            System.runAs(user){
                EventListViewController.getPlannedRecords(String.valueOf(System.Today()), null, 'All', plannedDays[0].Status__c, true);
                EventListViewController.getPlannedRecords(null, String.valueOf(System.Today()), conAssigns[0].Project__c, plannedDays[0].Status__c, false);
            }
            
        Test.stopTest();
    }
    
    // To cover getPlannedRecords() method
    private static testMethod void myTest7(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
       Test.startTest();
       
            insert user;
                   
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' LIMIT 1];
            conAssigns[0].Candidate_Name__c = conList[0].Id;
            update conAssigns[0];
            
            List<Planned_Days_Off__c> pdo = [SELECT Id, Contact__c, Name, Project__c, Status__c FROM Planned_Days_Off__c LIMIT 1];
            System.debug('pdo =='+pdo );
            pdo[0].Contact__c = conList[0].Id;
            pdo[0].Project__c = conAssigns[0].Project__c;
            pdo[0].Date__c = null;
            pdo[0].From_Date__c = System.Today();
            pdo[0].To_Date__c = System.Today();
            update pdo[0];
            
            List<Planned_Days_Off__c> plannedDays = [SELECT Id, Contact__c, Project__c,RecordType.DeveloperName, Status__c FROM Planned_Days_Off__c WHERE Id = :pdo[0].Id];
            System.debug('plannedDays=='+plannedDays[0].RecordType.DeveloperName+'==='+plannedDays[0].Status__c );
            
            System.runAs(user){
                EventListViewController.getPlannedRecords(null, null, conAssigns[0].Project__c,pdo[0].Status__c, false);
            }
            
        Test.stopTest();
    }
    
    // To cover getPlannedRecords() method
    private static testMethod void myTest7a(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
       Test.startTest();
       
            insert user;
                   
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' LIMIT 1];
            conAssigns[0].Candidate_Name__c = conList[0].Id;
            update conAssigns[0];
            
            List<Planned_Days_Off__c> pdo = [SELECT Id, Contact__c, Name, Project__c, Status__c FROM Planned_Days_Off__c LIMIT 1];
            System.debug('pdo =='+pdo );
            pdo[0].Contact__c = conList[0].Id;
            pdo[0].Project__c = conAssigns[0].Project__c;
            pdo[0].From_Date__c = System.Today();
            pdo[0].Status__c = 'Approved';
            update pdo[0];
            
            //Planned_Days_Off__c childPDO = new Planned_Days_Off__c(Contact__c = conList[0].Id,Date__c=System.today().addDays(-1),Description__c='Test',Requested_Reschedule_Date__c=System.today().addDays(-1),RecordTypeId=instructorTypeId);
            
            List<Planned_Days_Off__c> plannedDays = [SELECT Id, Contact__c, Project__c,RecordType.DeveloperName, Status__c FROM Planned_Days_Off__c WHERE Id = :pdo[0].Id];
            System.debug('plannedDays=='+plannedDays[0].RecordType.DeveloperName+'==='+plannedDays[0].Status__c );
            
            System.runAs(user){
                EventListViewController.getPlannedRecords(String.valueOf(System.Today()), String.valueOf(System.Today()), conAssigns[0].Project__c,plannedDays[0].Status__c, TRUE);
            }
            
        Test.stopTest();
    }
    
    // To cover createNewPlannedOffRecords() method
    private static testMethod void myTest8(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
           Test.startTest();
           
            insert user;
                    
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' LIMIT 1];
            conAssigns[0].Candidate_Name__c = conList[0].Id;
            update conAssigns[0];
            
            List<Planned_Days_Off__c> requestList = new List<Planned_Days_Off__c>();
            List<Planned_Days_Off__c> pdo = [SELECT Id, Contact__c, Name, Project__c FROM Planned_Days_Off__c LIMIT 1];
        
            Planned_Days_Off__c pdOff = new Planned_Days_Off__c();
            pdOff.Contact__c = conList[0].Id;
            pdOff.Project__c = conAssigns[0].Project__c;
            pdOff.Date__c = System.Today();
            requestList.add(pdOff);
            
            System.runAs(user){
                String res = EventListViewController.createNewPlannedOffRecords(JSON.serialize(requestList), 'Deleted', TRUE, pdo[0].Id);
                System.assertEquals('SUCCESS', res);
            }
            
        Test.stopTest();
    }
    
    // To cover createNewPlannedOffRecords() method
    private static testMethod void myTest9(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
       Test.startTest();
       
            insert user;
                
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' LIMIT 1];
            conAssigns[0].Candidate_Name__c = conList[0].Id;
            update conAssigns[0];
            
            List<Planned_Days_Off__c> requestList = new List<Planned_Days_Off__c>();
            List<Planned_Days_Off__c> pdo = [SELECT Id, Contact__c, Name, Project__c FROM Planned_Days_Off__c LIMIT 1];
        
            Planned_Days_Off__c pdOff = new Planned_Days_Off__c();
            pdOff.Id = pdo[0].Id;
            pdOff.Contact__c = conList[0].Id;
            pdOff.Project__c = conAssigns[0].Project__c;
            pdOff.Date__c = System.Today();
            requestList.add(pdOff);
            
            try{
                System.runAs(user){
                    String res = EventListViewController.createNewPlannedOffRecords(JSON.serialize(requestList), 'Deleted', TRUE, pdo[0].Id);
                }
            }catch(Exception e){
                System.debug('======'+e.getMessage());  
                Boolean expectedExceptionThrown =  e.getMessage().contains('Script-thrown exception') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);  
            }
            
        Test.stopTest();
    }
    
    // To cover getCommunityNameWithEventsInfo() method and login as Instructor
    private static testMethod void myTest10(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
       Test.startTest();
       
        insert user;
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' LIMIT 1];
        conAssigns[0].Candidate_Name__c = conList[0].Id;
        update conAssigns[0];
        
        System.runAs(user){
            String res = EventListViewController.getCommunityNameWithEventsInfo('instructor',String.valueOf(system.today()));
        }
            
        Test.stopTest();
    }
     // To cover getCommunityNameWithEventsInfo() method and login as Student
    private static testMethod void myTest10a(){ 
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
       Test.startTest();
       
        insert user;
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        conAssigns[0].Candidate_Name__c = conList[0].Id;
        update conAssigns[0];
        
        System.runAs(user){
            String res = EventListViewController.getCommunityNameWithEventsInfo('student',String.valueOf(system.today()));
        }
            
        Test.stopTest();
    }
    // To cover updatePDOStatusAsDelete() method and login as Instructor
    private static testMethod void myTest11(){
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        String pdoRT = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Instructor_Planned_Days_Off').getRecordTypeId();

        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conList[0].Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        Test.startTest();
        
        insert user;
        
        System.runAs(user){
            
            List<Planned_Days_Off__c> requestList = new List<Planned_Days_Off__c>();
            Planned_Days_Off__c pdOff = new Planned_Days_Off__c();
            pdOff.Contact__c = conList[0].Id;
            pdOff.Date__c = System.Today();
            pdOff.RecordTypeId = pdoRT;
            requestList.add(pdOff);
                        
            insert requestList;
            
            if(requestList.size() > 0 && requestList[0].Id != null){
                requestList[0].Status__c = 'Delete';
                EventListViewController.updatePDOStatusAsDelete(JSON.serialize(requestList));
            }
            
            Test.stopTest();
        }
    }
    
    // To cover updatePDOStatusAsDelete() method and login as Instructor
    private static testMethod void myTest11a(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        String pdoRT = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Instructor_Planned_Days_Off').getRecordTypeId();
    
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conList[0].Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        Test.startTest();
        
        insert user;
        
        System.runAs(user){
            
            List<Planned_Days_Off__c> requestList = new List<Planned_Days_Off__c>();
            Planned_Days_Off__c pdOff = new Planned_Days_Off__c();
            pdOff.Contact__c = conList[0].Id;
            pdOff.Date__c = System.Today();
            pdOff.RecordTypeId = pdoRT;
            requestList.add(pdOff);
                                    
            try{
            
                EventListViewController.updatePDOStatusAsDelete(JSON.serialize(requestList));
            }catch(Exception e){
            
                Boolean expectedExceptionThrown =  e.getMessage().contains('Script-thrown exception') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            Test.stopTest();
        }
    }

    //To cover getHolidayBydate() method in HolidayService
    private static testMethod void myTest12(){
    
        Holiday h = new Holiday(Name='My Test holiday1',activitydate = System.Today().addDays(-1));
        insert h;
        
        Test.startTest();
        
        HolidayService.getHolidayBydate(new Set<Date>{System.Today().addDays(-1)});
        
        Test.stopTest();
    }
    
    //To cover getHolidays() method in HolidayService
    private static testMethod void myTest13(){
    
        List<Holiday> holidays = [SELECT Id, activitydate FROM Holiday];
        
        Test.startTest();
        
            HolidayService.getHolidays();
        Test.stopTest();
    }
    
    //To cover getHolidaysWithRecurrence() method in HolidayService
    private static testMethod void myTest14(){
    
        Holiday h = new Holiday(Name='My Test holiday1',activitydate = System.Today().addDays(-1));
        insert h;
        
        Test.startTest();
            
            HolidayService.getHolidaysWithRecurrence(System.Today().addDays(-1), System.Today());
        Test.stopTest();
    }
    
    //To cover getHolidaysWithRecurrence() method in HolidayService
    private static testMethod void myTest15(){
    
        List<Holiday> holiday = [SELECT Id, ActivityDate, RecurrenceType, IsRecurrence, RecurrenceEndDateOnly 
            FROM Holiday
            WHERE RecurrenceType ='RecursYearly' AND IsRecurrence = TRUE AND RecurrenceEndDateOnly = NULL];
        
        Test.startTest();
        
            HolidayService.getHolidaysWithRecurrence(holiday[0].ActivityDate, holiday[0].ActivityDate);
        Test.stopTest();
    }
    
    //To cover getHolidaysWithRecurrence() method in HolidayService
    private static testMethod void myTest16(){
    
        List<Holiday> holiday = [SELECT Id, ActivityDate, RecurrenceType, IsRecurrence, RecurrenceEndDateOnly 
            FROM Holiday
            WHERE RecurrenceType ='RecursYearly' AND IsRecurrence = TRUE AND RecurrenceEndDateOnly = NULL];
        
        Date newHolDate = Date.newInstance(holiday[0].ActivityDate.year(),holiday[0].ActivityDate.month(),holiday[0].ActivityDate.day());
        
        Test.startTest();
        
            HolidayService.getHolidaysWithRecurrence(holiday[0].ActivityDate.addDays(-400), newHolDate);
        Test.stopTest();
    }
    
    //To cover getHolidaysWithRecurrence() method in HolidayService
    private static testMethod void myTest17(){
    
        List<Holiday> holiday = [SELECT Id, ActivityDate, RecurrenceType, IsRecurrence, RecurrenceEndDateOnly 
            FROM Holiday
            WHERE RecurrenceType = 'RecursYearlyNth' AND IsRecurrence = TRUE AND RecurrenceEndDateOnly = NULL
                AND RecurrenceInstance = 'Last'];
        
        Date newHolDate = Date.newInstance(holiday[0].ActivityDate.year(),holiday[0].ActivityDate.month(),holiday[0].ActivityDate.day());
        
        Test.startTest();
        
            HolidayService.getHolidaysWithRecurrence(holiday[0].ActivityDate.addDays(-400), newHolDate);
        Test.stopTest();
    }
    
    //To cover getHolidaysWithRecurrence() method in HolidayService
    private static testMethod void myTest18(){
    
        List<Holiday> holiday = [SELECT Id, ActivityDate, RecurrenceType, IsRecurrence, RecurrenceEndDateOnly 
            FROM Holiday
            WHERE RecurrenceType = 'RecursYearlyNth' AND IsRecurrence = TRUE AND RecurrenceEndDateOnly = NULL
                AND RecurrenceInstance = 'Last'];
        
        Date newHolDate = Date.newInstance(holiday[0].ActivityDate.year(),holiday[0].ActivityDate.month(),holiday[0].ActivityDate.day());
        
        Test.startTest();
        
            HolidayService.getHolidaysWithRecurrence(newHolDate, holiday[0].ActivityDate.addDays(400));
        Test.stopTest();
    }
    
    //To cover getHolidayRecordsWithRecurrence() method in HolidayService
    private static testMethod void myTest19(){
    
        Holiday h = new Holiday(Name='My Test holiday1',activitydate = System.Today().addDays(-1));
        insert h;
        
        Test.startTest();
        
            HolidayService.getHolidayRecordsWithRecurrence(System.Today().addDays(-1), System.Today());
        Test.stopTest();
    }
    
    //To cover getHolidayRecordsWithRecurrence() method in HolidayService
    private static testMethod void myTest20(){
    
        List<Holiday> holiday = [SELECT Id, ActivityDate, RecurrenceType, IsRecurrence, RecurrenceEndDateOnly 
            FROM Holiday
            WHERE RecurrenceType ='RecursYearly' AND IsRecurrence = TRUE AND RecurrenceEndDateOnly = NULL];
        
        Test.startTest();
        
            HolidayService.getHolidayRecordsWithRecurrence(holiday[0].ActivityDate, holiday[0].ActivityDate);
        Test.stopTest();
    }
    
    //To cover getHolidayRecordsWithRecurrence() method in HolidayService
    private static testMethod void myTest21(){
    
        List<Holiday> holiday = [SELECT Id, ActivityDate, RecurrenceType, IsRecurrence, RecurrenceEndDateOnly 
            FROM Holiday
            WHERE RecurrenceType ='RecursYearly' AND IsRecurrence = TRUE AND RecurrenceEndDateOnly = NULL];
        
        Date newHolDate = Date.newInstance(holiday[0].ActivityDate.year(),holiday[0].ActivityDate.month(),holiday[0].ActivityDate.day());
        
        Test.startTest();
        
            HolidayService.getHolidayRecordsWithRecurrence(holiday[0].ActivityDate.addDays(-400), newHolDate);
        Test.stopTest();
    }
    
    //To cover getHolidayRecordsWithRecurrence() method in HolidayService
    private static testMethod void myTest22(){
    
        List<Holiday> holiday = [SELECT Id, ActivityDate, RecurrenceType, IsRecurrence, RecurrenceEndDateOnly 
            FROM Holiday
            WHERE RecurrenceType = 'RecursYearlyNth' AND IsRecurrence = TRUE AND RecurrenceEndDateOnly = NULL
                AND RecurrenceInstance = 'Last'];
        
        Date newHolDate = Date.newInstance(holiday[0].ActivityDate.year(),holiday[0].ActivityDate.month(),holiday[0].ActivityDate.day());
        
        Test.startTest();
        
            HolidayService.getHolidayRecordsWithRecurrence(holiday[0].ActivityDate.addDays(-400), newHolDate);
        Test.stopTest();
    }
    
    //To cover getHolidayRecordsWithRecurrence() method in HolidayService
    private static testMethod void myTest23(){
    
        List<Holiday> holiday = [SELECT Id, ActivityDate, RecurrenceType, IsRecurrence, RecurrenceEndDateOnly 
            FROM Holiday
            WHERE RecurrenceType = 'RecursYearlyNth' AND IsRecurrence = TRUE AND RecurrenceEndDateOnly = NULL
                AND RecurrenceInstance = 'Last'];
        
        Date newHolDate = Date.newInstance(holiday[0].ActivityDate.year(),holiday[0].ActivityDate.month(),holiday[0].ActivityDate.day());
        
        Test.startTest();
        
            HolidayService.getHolidayRecordsWithRecurrence(newHolDate, holiday[0].ActivityDate.addDays(400));
        Test.stopTest();
    }
    
    //To cover getPDODaysDifference() method in EventListViewController
    private static testMethod void myTest24(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
    
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conList[0].Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        Test.startTest();
        
            insert user;
                        
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active'  LIMIT 1];
            conAssigns[0].Candidate_Name__c = conList[0].Id;
            update conAssigns[0];
            
            List<Events__c> events = [SELECT Id, Schedule__r.Project_Task__r.Project_Task_Type__c, Instructor__c, Status__c, Date__c FROM Events__c WHERE  Status__c = 'Scheduled' LIMIT 1];
            events[0].Date__c = System.Today().addDays(2);
            events[0].Project__c = conAssigns[0].Project__c;
            update events[0];
                
            System.runAs(user){
                
                EventListViewController.getPDODaysDifference(System.Today().addDays(2));
            }
            
        Test.StopTest();
    }
    
    //To cover getEventsForApproval() method in EventListViewController
    private static testMethod void myTest25(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
    
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conList[0].Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
         System.runAs(user){
             EventListViewController.getEventsForApproval();
        }
    }
    
    //To cover getDetailsForRequestEvent() method in EventListViewController
    private static testMethod void myTest26(){
     
        EventListViewController.getDetailsForRequestEvent();
    }
    
    //To cover timeEventGroupedDetails() method in EventTranslator
    private static testMethod void myTest27(){
    
        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        List<AcctSeed__Project__c> projRecs = [SELECT Id, Name, AcctSeed__Account__c, Start_Date__c, End_Date__c, RecordType.DeveloperName, Recordtype.Name,
            AcctSeed__Status__c, DLS_Class__c, Service_Item__c, QB_Classification__c, Scheduled_Hours_Week__c, 
            (SELECT Id, Project_Task__c, Paper_Timesheet__c, Candidate_Name__c, Candidate_Name__r.name FROM Contact_Assignments__r) FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
        Map<String,Integer> pendingDayCount = new Map<String,Integer>();
        pendingDayCount.put(conAss[0].Candidate_Name__c+'-'+projRecs[0].Id, 1);
        
        Map<String,Integer> pendingEventCount = new Map<String,Integer>();
        pendingEventCount.put(conAss[0].Candidate_Name__c+'-'+projRecs[0].Id, 1);
        
        Map<String,Decimal> proIdTCDHrs = new Map<String,Decimal>();
        proIdTCDHrs.put(conAss[0].Candidate_Name__c+'-'+projRecs[0].Id, 1);
        
        Map<String,Decimal> projectIdTCDApprovedHrs = new Map<String,Decimal>();
        projectIdTCDApprovedHrs.put(conAss[0].Candidate_Name__c+'-'+projRecs[0].Id, 1);
        
        Map<Id,Boolean> projectIdEventExist = new Map<Id,Boolean>();
        projectIdEventExist.put(projRecs[0].Id, True);
        
        Map<Id,Decimal> projIdEventsHrs = new Map<Id,Decimal>();
        projIdEventsHrs.put(projRecs[0].Id, 5);
        
        Map<Id,String> proIdTimesheetStatus = new Map<Id,String>();
        
        Map<Id, Map<Id, Schedule__c>> projectIdWithInstructorAndScheduleMap = new Map<Id, Map<Id, Schedule__c>>();
        
        Map<String,Integer> proIdStuApprovedDayCount = new Map<String,Integer>();
        
        Test.startTest();
        
            EventTranslator.timeEventGroupedDetails(pendingDayCount, pendingEventCount, projRecs, projRecs[0].Start_Date__c, projRecs[0].End_Date__c, proIdTCDHrs, contacts, projectIdTCDApprovedHrs, 'All', projectIdEventExist, projIdEventsHrs, proIdTimesheetStatus, projectIdWithInstructorAndScheduleMap, proIdStuApprovedDayCount);
            EventTranslator.timeEventGroupedDetails(pendingDayCount, pendingEventCount, projRecs, projRecs[0].Start_Date__c, projRecs[0].End_Date__c, proIdTCDHrs, contacts, projectIdTCDApprovedHrs, 'No Time Entries', projectIdEventExist, projIdEventsHrs, proIdTimesheetStatus, projectIdWithInstructorAndScheduleMap, proIdStuApprovedDayCount);
            EventTranslator.timeEventGroupedDetails(pendingDayCount, pendingEventCount, projRecs, projRecs[0].Start_Date__c, projRecs[0].End_Date__c, proIdTCDHrs, contacts, projectIdTCDApprovedHrs, 'Pending Approval - Student Approved', projectIdEventExist, projIdEventsHrs, proIdTimesheetStatus, projectIdWithInstructorAndScheduleMap, proIdStuApprovedDayCount);
        
        Test.stopTest();
    }
}