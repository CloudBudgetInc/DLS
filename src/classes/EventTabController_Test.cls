@isTest
private class EventTabController_Test {
    
    @testSetup static void Setup() {
        
        List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
         
        Test.startTest();
            List<Events__c> eveList = TestClassUtil.createTestEvent();
            List<Room__c> roomList = TestClassUtil.createTestRoom();
        Test.stopTest();
    }
    
    // For getting the event records based on the project, start date and end date
    private static testMethod void testMethod1() {
       
        List<Events__c> eveList = [SELECT Id, Name, Project__c FROM Events__c LIMIT 3];
        List<String> proIds = new List<String>();
        
        if(eveList.size() > 0) {
            for(Events__c eve : eveList) {
                if(eve.Project__c != null )
                    proIds.add(eve.Project__c);
            }
        }
        
        EventTabController.eventDatePickListValWrapper eventWrapper = new EventTabController.eventDatePickListValWrapper();
        //eventWrapper = EventTabController.getEventRecordsInitial(proIds);
        /*if(eventWrapper != null) {
            System.assertEquals(eventWrapper.startDate, System.today().toStartOfWeek().addDays(-7));
        }*/
    }
    
    // For getting the value for instructor and room lookup fields based on the search string
    private static testMethod void testMethod2() {
        
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c WHERE Name LIKE '%Room%'];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 1];
        
        if(roomList.size() > 0 && conList.size() > 0) {
            
            EventTabController.getContactRecords(conList[0].Id);
            EventTabController.getRoomRecords(roomList[0].Id);
            
            EventTabController.getLookupRecords('test', 'Contact', 'Candidate_Name__r.Name', '', new List<String>());
            List<Sobject> objRet = EventTabController.getLookupRecords('Room', 'Room__c', 'Name', '', new List<String>());
            
            if(objRet.size() > 0) {
                System.assertEquals(objRet.size(), roomList.size());
            }
        }
    }
    
    // For Saving the event records
    private static testMethod void testMethod3() {
        
        List<Events__c> eveList = [SELECT Id, Name FROM Events__c LIMIT 3];    
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c LIMIT 1];
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 1];
         
        if(eveList.size() > 0 && roomList.size() > 0 && conList.size() > 0) {
            eveList[0].Status__c = 'Rescheduled';
            eveList[0].Date__c = System.today().addDays(-6);
            eveList[0].Room__c = roomList[0].Id;
            eveList[0].Instructor__c = conList[0].Id;
            eveList[0].Start_Time__c = '07:45 AM';
            eveList[0].End_Time__c = '10:15 AM';
            List<Events__c> eveListRet = EventTabController.saveEventRecords(JSON.serialize(eveList), JSON.serialize(eveList[0]));
            
            if(eveListRet.size() > 0) {
                System.assertEquals(eveListRet[0].Start_Time__c, '07:45 AM');
            }
        }
    }
    
    private static testMethod void testMethod4() {
        
        List<AcctSeed__Project__c> projects = [SELECT Id, Oral_Exam_Date_Time__c FROM AcctSeed__Project__c];
        projects[0].Oral_Exam_Date_Time__c = System.today();
        update projects[0];
        
        List<Contact_Assignments__c> ca = [SELECT Id, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Project__c != :projects[0].Id AND RecordType.DeveloperName = 'Instructor'];
        Contact_Assignments__c caNew = new Contact_Assignments__c();
        
        Test.startTest();
        EventTabController.eventDatePickListValWrapper wrap = EventTabController.getEventRecordsInitial(new List<String>{projects[0].Id}, 'Scheduled');
        System.assertEquals(true, wrap.eveList.size() > 0);
        EventTabController.getGenericLookupRecords('Test','Contact','Name','', new list<String>());
        Boolean isCAAvailable = false;
        if(ca.size() > 0){
            isCAAvailable = EventTabController.checkContactAssignmentExist(ca[0].Candidate_Name__c, projects[0].Id);
            System.debug('isCAAvailable::>'+isCAAvailable);
            caNew = ca[0];            
            caNew.Project__c = projects[0].Id;
            caNew.Id = null;            
        }
        Events__c eve = wrap.eveList[0];
        eve.Id = null;
        eve.Project__c = projects[0].Id;
        
        String result = EventTabController.createEventsForTestingProject(JSON.serialize(new List<Events__c>{eve}), JSON.serialize(caNew),isCAAvailable, false);
        Test.stopTest();
    }
    
     private static testMethod void testMethod5() {
        
        List<Opportunity> opp = [SELECT Id, Oral_Exam__c FROM Opportunity];
        opp[0].Oral_Exam__c = System.today();
        update opp[0];
        
        List<Contact_Assignments__c> ca = [SELECT Id, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Opportunity_Name__c != :opp[0].Id AND RecordType.DeveloperName = 'Instructor'];
        Contact_Assignments__c caNew = new Contact_Assignments__c();
        Boolean isCAAvailable = false;
        
        Test.startTest();
        EventTabController.eventDatePickListValWrapper wrap = EventTabController.getEventRecordsInitial(new List<String>{opp[0].Id}, 'Scheduled');
        System.assertEquals(true, wrap.eveList.size() > 0);
        
        Events__c eve = wrap.eveList[0];
        eve.Id = null;
        eve.Opportunity__c = opp[0].Id;
        
        String result = EventTabController.createEventsForTestingProject(JSON.serialize(new List<Events__c>{eve}), JSON.serialize(caNew),isCAAvailable, true);
        Test.stopTest();
    }
    
    private static testMethod void testMethod6() {
        
        List<AcctSeed__Project__c> pro = [SELECT Id,End_Date__c,DLS_Class__c FROM AcctSeed__Project__c LIMIT 1];
                
        List<Contact> contactRec = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName = 'Candidate' LIMIT 1];                
        
        Test.startTest();
        EventTabController.eventDatePickListValWrapper wrap = EventTabController.getEventRecordsInitial(new List<String>{pro[0].Id}, 'Scheduled');
        System.assertEquals(true, wrap.eveList.size() > 0);
        
        Events__c eve = wrap.eveList[0];
        eve.Id = null;
        eve.Project__c =  pro[0].Id;
        
        Contact_Assignments__c caNew = new Contact_Assignments__c();
        caNew.Candidate_Name__c = contactRec[0].Id;
        caNew.Project__c = pro[0].Id;
        caNew.Start_Date__c = Date.Today();
        caNew.End_Date__c = Date.Today().addDays(50);
        
        String result = EventTabController.createEventsForTestingProject(JSON.serialize(new List<Events__c>{eve}), JSON.serialize(caNew),True, true);
        Test.stopTest();
    }
    
    private static testMethod void testMethod7() {
        
        AcctSeed__Project__c pro = [SELECT Id,End_Date__c,DLS_Class__c FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> contactRec = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName = 'Candidate' LIMIT 1];        
        
        Test.startTest();
            EventTabController.checkContactAssignmentExist(contactRec[0].Id, pro.Id);
        Test.stopTest();
    }
    
    private static testMethod void testMethod8() {
        
        Acctseed__Project_Task__c projTask = [SELECT Id, Name FROM Acctseed__Project_Task__c LIMIT 1];
        
        Test.startTest();
            EventTabController.getProjTaskRecords(projTask.Id);
        Test.stopTest();
    }
}