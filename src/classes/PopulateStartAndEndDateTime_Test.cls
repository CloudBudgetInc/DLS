@isTest
private class PopulateStartAndEndDateTime_Test {

    @testSetup static void setup() {
    
        List<Events__c> eveList = TestClassUtil.createTestEvent();
        
        Test.startTest();
            List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
    }
    
    private static testMethod void testMethod1() {
        List<Events__c> eveList = [SELECT Id, Name, Status__c FROM Events__c WHERE Status__c != 'Scheduled'];
       
        if(eveList.size() > 0) {
            
            eveList[0].Timezone__c = 'America/New_York';
            eveList[0].Date__c = System.today();
            eveList[1].Date__c = System.today();
            eveList[0].Status__c = 'Scheduled';
            update eveList;
            
            eveList[0].Status__c = 'Canceled';
            update eveList;
            
            delete eveList;
        }
    }
        
    private static testMethod void testMethod2() {
    
        List<Events__c> eveList = [SELECT Id, Name, Start_Time__c, Project__c FROM Events__c WHERE Status__c = 'Scheduled'];
        
        Id testRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
        Id insCARTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<AcctSeed__Project__c> proj = [SELECT Id, RecordTypeId, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE Id = :eveList[0].Project__c];
        proj[0].RecordTypeId = testRTId;
        update proj[0];
        
        List<Opportunity> opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id =:proj[0].AcctSeed__Opportunity__c];
        opp[0].RecordTypeId = testOppRTId;
        update opp[0];
        
        List<Contact_Assignments__c> ca = [SELECT Id, Candidate_Name__c, Project__c, RecordTypeId
            FROM Contact_Assignments__c 
            WHERE Status__c IN ('Active', 'Planned') LIMIT 1];
        ca[0].Project__c = proj[0].Id;
        ca[0].RecordTypeId = insCARTId;
        update ca[0];
        
        Test.startTest();
            
            EventTabController.isUpdateTestingProjectDates = True;
            
            eveList[0].Start_Time__c = '10:00 AM';
            eveList[0].Date__c = System.Today().addDays(2);
            eveList[0].Instructor__c = ca[0].Candidate_Name__c;
            update eveList[0];
            
            String startTime =  '10:00';
            DateTime oralExamDateTime = DateTime.newInstance(System.Today().addDays(2), Time.newInstance(Integer.valueOf(startTime.split(':')[0]), Integer.valueOf(startTime.split(':')[1]), 0, 0));
                
            List<AcctSeed__Project__c> pro = [SELECT Id, Oral_Exam_Date_Time__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            //System.assertEquals(oralExamDateTime, pro[0].Oral_Exam_Date_Time__c);
            
        Test.stopTest();
    }
    
    private static testMethod void testMethod3() {
    
        List<Events__c> eveList = [SELECT Id, Name, Start_Time__c, Project__c FROM Events__c WHERE Status__c = 'Scheduled'];
        
        Id testRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
        Id insCARTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<AcctSeed__Project__c> proj = [SELECT Id, RecordTypeId, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE Id = :eveList[0].Project__c];
        proj[0].RecordTypeId = testRTId;
        update proj[0];
        
        List<Opportunity> opp = [SELECT Id, RecordTypeId, Oral_Exam__c FROM Opportunity WHERE Id =:proj[0].AcctSeed__Opportunity__c];
        opp[0].RecordTypeId = testOppRTId;
        //opp[0].Oral_Exam__c = System.Today().addDays(4);
        update opp[0];
        
        List<Contact_Assignments__c> ca = [SELECT Id, Candidate_Name__c, Project__c, RecordTypeId
            FROM Contact_Assignments__c 
            WHERE Status__c IN ('Active', 'Planned') LIMIT 1];
        ca[0].Project__c = proj[0].Id;
        ca[0].RecordTypeId = insCARTId;
        update ca[0];
        
        Test.startTest();
            
            EventTabController.isUpdateTestingProjectDates = True;
            
            Events__c eve = new Events__c();
            eve.Start_Time__c = '10:00 AM';
            eve.Date__c = System.Today().addDays(2);
            eve.Project__c = proj[0].Id;
            eve.Status__c = 'Scheduled';
            eve.Instructor__c = ca[0].Candidate_Name__c;
            eve.SequenceNo__c = 8;
            insert eve;
            
            String startTime =  '10:00';
            DateTime oralExamDateTime = DateTime.newInstance(System.Today().addDays(2), Time.newInstance(Integer.valueOf(startTime.split(':')[0]), Integer.valueOf(startTime.split(':')[1]), 0, 0));
                
            List<AcctSeed__Project__c> pro = [SELECT Id, Oral_Exam_Date_Time__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            //System.assertEquals(oralExamDateTime, pro[0].Oral_Exam_Date_Time__c);
            
        Test.stopTest();
    }
    
    private static testMethod void testMethod4() {
    
        List<Events__c> eveList = [SELECT Id, Name, Start_Time__c, Project__c FROM Events__c WHERE Status__c = 'Scheduled'];
        
        Id testRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
        Id insCARTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Opportunity> opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        
        Opportunity myOpp = new Opportunity(Name = 'My Test Opp',StageName = 'Active',Start_Date__c = System.Today()+10,End_Date__c = System.Today()+40,CloseDate = System.Today()+45,AccountId = opp[0].AccountId,RecordTypeId = testOppRTId,Oral_Exam__c = System.Today()+20);
        insert myOpp;
        
        List<AcctSeed__Project__c> proj = [SELECT Id, RecordTypeId, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE Id = :eveList[0].Project__c];
        proj[0].RecordTypeId = testRTId;
        proj[0].AcctSeed__Opportunity__c = myOpp.Id;
        update proj[0];
            
        Test.startTest();
            
            List<Contact_Assignments__c> ca = [SELECT Id, Candidate_Name__c, Project__c, RecordTypeId
                FROM Contact_Assignments__c 
                WHERE Status__c IN ('Active', 'Planned') LIMIT 1];
            ca[0].Project__c = proj[0].Id;
            ca[0].RecordTypeId = insCARTId;
            update ca[0];
                    
            EventTabController.isUpdateTestingProjectDates = True;
            
            Events__c eve = new Events__c();
            eve.Start_Time__c = '10:00 AM';
            eve.Date__c = System.Today().addDays(2);
            eve.Project__c = proj[0].Id;
            eve.Status__c = 'Scheduled';
            eve.Instructor__c = ca[0].Candidate_Name__c;
            eve.SequenceNo__c = 8;
            insert eve;
            
            String startTime =  '10:00';
            DateTime oralExamDateTime = DateTime.newInstance(System.Today().addDays(2), Time.newInstance(Integer.valueOf(startTime.split(':')[0]), Integer.valueOf(startTime.split(':')[1]), 0, 0));
                
            List<AcctSeed__Project__c> pro = [SELECT Id, Oral_Exam_Date_Time__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            //System.assertEquals(oralExamDateTime, pro[0].Oral_Exam_Date_Time__c);
            
        Test.stopTest();
    }
    
    private static testMethod void testMethod5() {
    
        List<Events__c> eveList = [SELECT Id, Name, Start_Time__c, Project__c FROM Events__c WHERE Status__c = 'Scheduled'];
        
        Id testRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
        Id insCARTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Opportunity> opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        
        Opportunity myOpp = new Opportunity(Name = 'My Test Opp',StageName = 'Active',Start_Date__c = System.Today()+10,End_Date__c = System.Today()+40,CloseDate = System.Today()+45,AccountId = opp[0].AccountId,RecordTypeId = testOppRTId,Oral_Exam__c = System.Today()+20);
        insert myOpp;
        
        List<AcctSeed__Project__c> proj = [SELECT Id, RecordTypeId, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE Id = :eveList[0].Project__c];
        proj[0].RecordTypeId = testRTId;
        proj[0].AcctSeed__Opportunity__c = myOpp.Id;
        update proj[0];
            
        Test.startTest();
            
            List<Contact_Assignments__c> ca = [SELECT Id, Candidate_Name__c, Project__c, RecordTypeId
                FROM Contact_Assignments__c 
                WHERE Status__c IN ('Active', 'Planned') LIMIT 1];
            ca[0].Project__c = proj[0].Id;
            ca[0].RecordTypeId = insCARTId;
            update ca[0];
            
            EventTabController.isUpdateTestingProjectDates = True;
            
            Events__c eve = new Events__c();
            eve.Start_Time__c = '10:00 AM';
            eve.Date__c = System.Today().addDays(2);
            eve.Project__c = proj[0].Id;
            eve.Status__c = 'Scheduled';
            eve.Instructor__c = ca[0].Candidate_Name__c;
            eve.SequenceNo__c = 8;
            insert eve;
            
            List<Events__c> eveRecs = [SELECT Id, Start_Time__c FROM Events__c WHERE Id =:eve.Id];
            eveRecs[0].Start_Time__c = '11:00 AM';
            update eveRecs[0];
            
            String startTime =  '11:00';
            DateTime oralExamDateTime = DateTime.newInstance(System.Today().addDays(2), Time.newInstance(Integer.valueOf(startTime.split(':')[0]), Integer.valueOf(startTime.split(':')[1]), 0, 0));
                
            List<AcctSeed__Project__c> pro = [SELECT Id, Oral_Exam_Date_Time__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
            //System.assertEquals(oralExamDateTime, pro[0].Oral_Exam_Date_Time__c);
            
        Test.stopTest();
    }
}