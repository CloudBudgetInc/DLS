@isTest
public class PartnerSchoolTimeSheetUploadCtrl_Test {

    @testSetup 
    public static void setupMethod() {
        
        Test.startTest();
            List<MTT_Location__c> locationsList = TestClassUtil.createTestLocations();          
            List<AcctSeed__Ledger__c> ledgerList = TestClassUtil.createTestLedger(); 
            List<Events__c> eventsList = TestClassUtil.createTestEvent();
            for(Events__c event : eventsList){
                event.Date__c = System.today();
                event.Start_Time__c = '10:00 AM';
                event.End_Time__c = '12:00 PM';
            }
            update eventsList;
            List<AcctSeed__Cost_Rates__c> costRatesList = TestClassUtil.createTestCostRates();
        Test.stopTest();
        
        List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id , RecordTypeId , Project_Task_Type__c , Payroll_Item__c FROM AcctSeed__Project_Task__c];
        List<RecordType> recordTypeList = [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType WHERE DeveloperName = 'Cost'];
        projectTaskList[0].RecordTypeId = recordTypeList[0].Id;
        projectTaskList[0].Project_Task_Type__c = 'Fringe';
        projectTaskList[0].Payroll_Item__c = 'ADM';
        update projectTaskList[0];
        contactAssignList[0].Project_Task__c = projectTaskList[0].Id;
        update contactAssignList[0];
    }
    @isTest
    public static void getInstructorIdsByProjectId_Test(){
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        String jsonString = PartnerSchoolTimeSheetUploadCtrl.getInstructorIdsByProjectId(projList[0].Id);
        
        Set<String> instructorIds = (Set<String>) JSON.deserialize(jsonString,Set<String>.class);
        System.assertEquals(instructorIds.size(),2);
    }
    @isTest
    public static void saveTimeEntries_Test(){
        
        List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
        List<MTT_Location__c> locationList = [SELECT Id FROM MTT_Location__c LIMIT 1];
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Cost_Rates__c> costRatesList = [SELECT Id,Account__c,Contact__c,Status__c FROM AcctSeed__Cost_Rates__c];
        costRatesList[0].Account__c = accountList[0].Id;
        costRatesList[0].Status__c = 'Approved';
        update costRatesList[0];
        List<Contact_Assignments__c> caList = [SELECT Id,Name,Account__c,Candidate_Name__c,Project_Task__c,Rate_Card_Rate__c,Status__c FROM Contact_Assignments__c WHERE Candidate_Name__c != null];
        caList[0].Project_Task__c = null;
        caList[0].Rate_Card_Rate__c = costRatesList[0].Id;
        caList[0].Account__c = accountList[0].Id;
        update caList[0];
        
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Project_Task_Type__c,Billable__c,Parent_Project_Task__c,Payroll_Item__c,RecordTypeId,RecordType.DeveloperName FROM AcctSeed__Project_Task__c LIMIT 2];
        projectTaskList[0].Parent_Project_Task__c = projectTaskList[1].Id;
        projectTaskList[0].Billable__c = false;
        update projectTaskList[0];

        Date startOfWeek = System.today().toStartOfWeek().addDays(1);
        Date endOfWeek = System.today().toStartOfWeek().addDays(7);
        String dateRange = String.valueOf(startOfWeek) + '~' + String.valueOf(endOfWeek);

        Map<String, List<TimeCardDayCommunityDomain.DayEntries>> weekRangeStrWithDayMap = new Map<String, List<TimeCardDayCommunityDomain.DayEntries>>();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntriesList = new List<TimeCardDayCommunityDomain.DayEntries>();
        TimeCardDayCommunityDomain.DayEntries dayEntry1 = new TimeCardDayCommunityDomain.DayEntries();
        dayEntry1.taskId = projectTaskList[0].Id;
        dayEntry1.status = 'Admin Approved';
        dayEntry1.locationId = locationList[0].Id;
        dayEntry1.comments = '';
        dayEntry1.dayHours = '2';
        dayEntry1.dateVal = System.today();
        dayEntry1.isBillable = projectTaskList[0].Billable__c;
        dayEntry1.payrollItem = 'ADM';
        TimeCardDayCommunityDomain.DayEntries dayEntry2 = new TimeCardDayCommunityDomain.DayEntries();
        dayEntry2.taskId = projectTaskList[0].Id;
        dayEntry2.status = 'Admin Approved';
        dayEntry2.locationId = locationList[0].Id;
        dayEntry2.comments = '';
        dayEntry2.dayHours ='2';
        dayEntry2.dateVal = System.today().addDays(1);
        dayEntry2.isBillable = projectTaskList[0].Billable__c;
        dayEntry2.payrollItem = 'ADM';
        
        dayEntriesList.add(dayEntry1);
        dayEntriesList.add(dayEntry2);

        weekRangeStrWithDayMap.put(dateRange,dayEntriesList);
        
        Test.startTest();
            PartnerSchoolTimeSheetUploadCtrl.saveTimeEntries(projList[0].Id , caList[0].Candidate_Name__c , JSON.serialize(projectTaskList[0]) ,JSON.serialize(weekRangeStrWithDayMap) , false);
            String message2 = PartnerSchoolTimeSheetUploadCtrl.saveTimeEntries(projList[0].Id , caList[0].Candidate_Name__c , JSON.serialize(projectTaskList[0]) ,JSON.serialize(weekRangeStrWithDayMap) , false);
        Test.stopTest();
        
        System.assert(message2 == 'success'); 
        message2 = PartnerSchoolTimeSheetUploadCtrl.saveTimeEntries(projList[0].Id , caList[0].Candidate_Name__c , JSON.serialize(projectTaskList[0]) ,JSON.serialize(weekRangeStrWithDayMap) , true);
        
        System.assert(message2.contains('Time is already available for the following dates')); 
    }
    @isTest
    public static void saveTimeEntries_Test_BillableTrue(){
        
        List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
        List<MTT_Location__c> locationList = [SELECT Id FROM MTT_Location__c LIMIT 1];
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Cost_Rates__c> costRatesList = [SELECT Id,Account__c,Contact__c,Status__c FROM AcctSeed__Cost_Rates__c];
        costRatesList[0].Account__c = accountList[0].Id;
        costRatesList[0].Status__c = 'Approved';
        update costRatesList[0];
        List<Contact_Assignments__c> caList = [SELECT Id,Name,Account__c,Candidate_Name__c,Project_Task__c,Rate_Card_Rate__c,Status__c FROM Contact_Assignments__c WHERE Candidate_Name__c != null];
        caList[0].Project_Task__c = null;
        caList[0].Rate_Card_Rate__c = costRatesList[0].Id;
        caList[0].Account__c = accountList[0].Id;
        update caList[0];
        
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Project_Task_Type__c,Billable__c,Parent_Project_Task__c,Payroll_Item__c,RecordTypeId,RecordType.DeveloperName FROM AcctSeed__Project_Task__c LIMIT 2];
        projectTaskList[0].Parent_Project_Task__c = projectTaskList[1].Id;
        projectTaskList[0].Billable__c = true;
        update projectTaskList[0];

        Date startOfWeek = System.today().toStartOfWeek().addDays(1);
        Date endOfWeek = System.today().toStartOfWeek().addDays(7);
        String dateRange = String.valueOf(startOfWeek) + '~' + String.valueOf(endOfWeek);

        Map<String, List<TimeCardDayCommunityDomain.DayEntries>> weekRangeStrWithDayMap = new Map<String, List<TimeCardDayCommunityDomain.DayEntries>>();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntriesList = new List<TimeCardDayCommunityDomain.DayEntries>();
        TimeCardDayCommunityDomain.DayEntries dayEntry1 = new TimeCardDayCommunityDomain.DayEntries();
        dayEntry1.taskId = projectTaskList[0].Id;
        dayEntry1.status = 'Admin Approved';
        dayEntry1.locationId = locationList[0].Id;
        dayEntry1.comments = '';
        dayEntry1.dayHours = '2';
        dayEntry1.dateVal = System.today();
        dayEntry1.isBillable = projectTaskList[0].Billable__c;
        dayEntry1.payrollItem = 'ADM';
        TimeCardDayCommunityDomain.DayEntries dayEntry2 = new TimeCardDayCommunityDomain.DayEntries();
        dayEntry2.taskId = projectTaskList[0].Id;
        dayEntry2.status = 'Admin Approved';
        dayEntry2.locationId = locationList[0].Id;
        dayEntry2.comments = '';
        dayEntry2.dayHours ='2';
        dayEntry2.dateVal = System.today().addDays(1);
        dayEntry2.isBillable = projectTaskList[0].Billable__c;
        dayEntry2.payrollItem = 'ADM';
        
        dayEntriesList.add(dayEntry1);
        dayEntriesList.add(dayEntry2);

        weekRangeStrWithDayMap.put(dateRange,dayEntriesList);
        
        Test.startTest();
            PartnerSchoolTimeSheetUploadCtrl.saveTimeEntries(projList[0].Id , caList[0].Candidate_Name__c , JSON.serialize(projectTaskList[0]) ,JSON.serialize(weekRangeStrWithDayMap) , false);
            String message2 = PartnerSchoolTimeSheetUploadCtrl.saveTimeEntries(projList[0].Id , caList[0].Candidate_Name__c , JSON.serialize(projectTaskList[0]) ,JSON.serialize(weekRangeStrWithDayMap) , false);
        Test.stopTest();
        
        System.assert(message2 == 'success'); 
        message2 = PartnerSchoolTimeSheetUploadCtrl.saveTimeEntries(projList[0].Id , caList[0].Candidate_Name__c , JSON.serialize(projectTaskList[0]) ,JSON.serialize(weekRangeStrWithDayMap) , true);
        
        System.assert(message2.contains('Time is already available for the following dates')); 
    }
    
    @isTest
    public static void lookup_fetchLookupData_test1(){
        String fields = 'Id , Name';
        String filter = 'Name Like \'Test%\'';
        List<SObject> lookupRecords = Lookup.fetchLookupData('Test' , 'Name' , fields , 'Contact' , filter, new List<String>());
        System.assert(lookupRecords.size() > 0);
    }
    
    @isTest
    public static void lookup_fetchLookupData_test2(){
        String filter = 'Name Like \'Test%\'';
        List<SObject> lookupRecords = Lookup.fetchLookupData('' , 'Name' , '' , 'Contact' , filter, new List<String>());
        System.assert(lookupRecords.size() > 0);
    }
    
    @isTest
    public static void lookup_fetchDefaultRecord_test1(){
        List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
        SObject lookupRecord = Lookup.fetchDefaultRecord(contactList[0].Id , 'Contact');
        System.assert(lookupRecord.Id == contactList[0].Id);
    }
    
    @isTest
    public static void lookup_fetchDefaultRecord_test2(){
        SObject lookupRecord = Lookup.fetchDefaultRecord('DummyString' , 'Contact');
        System.assert(lookupRecord == null);
    }
}