@isTest
public with sharing class CustomActivityTimelineController_Test {
    @TestSetup
    public static void testSetup(){
        TestClassUtil.createTasks();
        TestClassUtil.createEventsAndEmailMessageRecords();
    }
    @isTest
    public static void testAccountActivities(){
        
        List<Account> accountList = [SELECT Id , Name FROM Account WHERE Name='Test Account 1'];
        String serializedWrapperString;
        try{
            Test.startTest();
            serializedWrapperString = CustomActivityTimelineController.getActivities(accountList[0].Id);
            Test.stopTest();
            CustomActivityTimelineController.ActivityTimelineWrapper wrapperInstance = (CustomActivityTimelineController.ActivityTimelineWrapper)JSON.deserialize(serializedWrapperString, CustomActivityTimelineController.ActivityTimelineWrapper.class);
        }
        catch(Exception e){
            System.assert(e.getMessage().containsIgnoreCase('Script-thrown Exception'));
        }
    }
    @isTest
    public static void testOpportunityActivities(){
        
        List<Opportunity> opportunityList = [SELECT Id , Name FROM Opportunity];
        Test.startTest();
        String serializedWrapperString = CustomActivityTimelineController.getActivities(opportunityList[0].Id);
        Test.stopTest();
        CustomActivityTimelineController.ActivityTimelineWrapper wrapperInstance = (CustomActivityTimelineController.ActivityTimelineWrapper)JSON.deserialize(serializedWrapperString, CustomActivityTimelineController.ActivityTimelineWrapper.class);
        List<String> setAsString = new List<String>();
        setAsString.addAll(wrapperInstance.activityWrapperWithStringMap.keySet());
        System.assertEquals(wrapperInstance.activityWrapperWithStringMap.get(setAsString[0])[0].subject , 'Task1 Of Opportunity');
    }
    @isTest
    public static void testNoActivities(){
        Lead leadInstance = new Lead();
        leadInstance.LastName = 'Test Lead';
        leadInstance.Company = 'BMW';
        insert leadInstance;
        
        Test.startTest();
        String returnedString = CustomActivityTimelineController.getActivities(leadInstance.Id);
        Test.stopTest();
        
        CustomActivityTimelineController.ActivityTimelineWrapper wrapperInstance = (CustomActivityTimelineController.ActivityTimelineWrapper)JSON.deserialize(returnedString,CustomActivityTimelineController.ActivityTimelineWrapper.class);
        
        System.assert(wrapperInstance.activityWrapperWithStringMap.get('No Activities').size() == 0);
    }
    @isTest
    public static void testContactMail(){
        
        List<Contact> contactList = [SELECT Id , Name FROM Contact];
        Test.startTest();
        String serializedWrapperString = CustomActivityTimelineController.getActivities(contactList[0].Id);
        Test.stopTest();
        CustomActivityTimelineController.ActivityTimelineWrapper wrapperInstance = (CustomActivityTimelineController.ActivityTimelineWrapper)JSON.deserialize(serializedWrapperString, CustomActivityTimelineController.ActivityTimelineWrapper.class);
        List<String> setAsString = new List<String>();
        setAsString.addAll(wrapperInstance.activityWrapperWithStringMap.keySet());
        System.assertEquals(wrapperInstance.activityWrapperWithStringMap.get(setAsString[1])[0].subject , ' This is the Subject!');
    }
    @isTest
    public static void test_NewTask(){
        
        List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
        Task taskInstance = new Task();
        taskInstance.Subject = 'Test record 1';
        taskInstance.Status = 'In Progress';
        taskInstance.OwnerId = UserInfo.getUserId();
        taskInstance.WhatId = accountList[0].Id;
        
            Test.startTest();
        	CustomActivityTimelineController.insertTask(JSON.serialize(new List<Task>{taskInstance}));
            Test.stopTest();
        	
        	List<Task> taskList = [SELECT Id FROM Task WHERE WhatId = :accountList[0].Id AND Subject = 'Test record 1'];
            System.assert(taskList.size() == 1);
        
    }
    @isTest
    public static void test_NewTask_Exception(){
        Task taskInstance = new Task();
        taskInstance.Subject = 'Test record 1';
        taskInstance.Status = 'In Progress';
        
        try{
            CustomActivityTimelineController.insertTask(JSON.serialize(taskInstance));
        }
        catch(Exception e){
            System.assert(e.getMessage().containsIgnoreCase('Script-thrown Exception'));
        }
        
    }
    @isTest
    public static void test_NewEvent(){
        
        List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
        Event eventInstance = new Event();
        eventInstance.Subject = 'Test record 1';
        eventInstance.OwnerId = UserInfo.getUserId();
        eventInstance.WhatId = accountList[0].Id;
        eventInstance.StartDateTime = System.now();
        eventInstance.EndDateTime = System.now().addDays(2);
        
            Test.startTest();
        	String returnedString = CustomActivityTimelineController.insertEvent(JSON.serialize(new List<Event>{eventInstance}));
            Test.stopTest();
        	
            System.assert(returnedString == 'Success');
        
    }
    @isTest
    public static void test_NewEvent_Exception(){
        Event eventInstance = new Event();
        eventInstance.Subject = 'Test record 1';
        eventInstance.StartDateTime = System.now();
        eventInstance.EndDateTime = System.now().addDays(2);
        
        try{
            CustomActivityTimelineController.insertEvent(JSON.serialize(eventInstance));
        }
        catch(Exception e){
            System.assert(e.getMessage().containsIgnoreCase('Script-thrown Exception'));
        }
        
    }
    @isTest
    public static void getEmailTemplates_Test(){
        
        Test.startTest();
        List<EmailTemplate> emailTemplatesList = CustomActivityTimelineController.getEmailTemplates('Project');
        Test.stopTest();
        System.assert(emailTemplatesList.size() > 0);
    }
    @isTest
    public static void sendMail_Test_Exception(){
        
        String base64data = '770yuvw/';
        Object o = JSON.serialize(base64data);
        Map<String , Object> filesMap = new Map<String , Object>();
        List<Map<String , Object>> filesList = new List<Map<String , Object>>();
        filesMap.put('File1', o);
        filesList.add(filesMap);
        
		Map<String,String> toAddressMap = new Map<String,String>();
		toAddressMap.put('Email' , 'testuser1@testmail.com');

		List<Map<String,String>> ccAddressMap = new List<Map<String,String>>();
		Map<String,String> ccAddress = new Map<String,String>();
		ccAddress.put('Email' , 'testusercc@testmail.com');
		ccAddressMap.add(ccAddress);

		List<Map<String,String>> bccAddressMap = new List<Map<String,String>>();
		Map<String,String> bccAddress = new Map<String,String>();
		bccAddress.put('Email' , 'testuserbcc@testmail.com');
		bccAddressMap.add(bccAddress);
        
        List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
        
        try{
            Test.startTest();
        	CustomActivityTimelineController.sendMail('TestUser <testFromUser@testmail.com>', toAddressMap , ccAddressMap , bccAddressMap , 'Subject' , 'Body' , filesList , accountList[0].Id);
        	Test.stopTest();
        }
        catch(Exception e){
            System.assert(e.getMessage().containsIgnoreCase('Script-thrown Exception'));
        }
    }
    @isTest
    public static void sendMail_Test(){
        
        List<Map<String , Object>> filesList = new List<Map<String , Object>>();
        
		Map<String,String> toAddressMap = new Map<String,String>();
		toAddressMap.put('Email' , 'testuser1@testmail.com');

		List<Map<String,String>> ccAddressMap = new List<Map<String,String>>();
		Map<String,String> ccAddress = new Map<String,String>();
		ccAddress.put('Email' , 'testusercc@testmail.com');
		ccAddressMap.add(ccAddress);

		List<Map<String,String>> bccAddressMap = new List<Map<String,String>>();
		Map<String,String> bccAddress = new Map<String,String>();
		bccAddress.put('Email' , 'testuserbcc@testmail.com');
		bccAddressMap.add(bccAddress);
        
        List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
        
        try{
            Test.startTest();
        	CustomActivityTimelineController.sendMail('TestUser <testFromUser@testmail.com>', toAddressMap , ccAddressMap , bccAddressMap , 'Subject' , 'Body' , filesList ,accountList[0].Id );
        	Test.stopTest();
        }
        catch(Exception e){
            System.assert(e.getMessage().containsIgnoreCase('Script-thrown Exception'));
        }
    }
    @isTest
    public static void mergeFields_Test_Contact(){
        
        List<Contact> contactList = [SELECT Id,Name FROM Contact LIMIT 1];
        String convertedString = '<p>'+contactList[0].Name+'</p>';
        Test.startTest();
        String returnedString = CustomActivityTimelineController.mergeFields('<p>{!Contact.Name}</p>' , contactList[0].Id);
        Test.stopTest();
        System.assert(returnedString == convertedString);
    }
    @isTest
    public static void mergeFields_Test_Project(){
        
        List<Account> accountList = [SELECT Id,Name FROM Account LIMIT 1];
        String convertedString = '<p>'+accountList[0].Name+'</p>';
        Test.startTest();
        String returnedString = CustomActivityTimelineController.mergeFields('<p>{!Account.Name}</p>' , accountList[0].Id);
        Test.stopTest();
        System.assert(returnedString == convertedString);
    }
    @isTest
    public static void getOrgWideEmailAddresses_Test(){
        List<CustomActivityTimelineController.ComboBoxWrapper> wrapperList = new List<CustomActivityTimelineController.ComboBoxWrapper>();
        wrapperList = CustomActivityTimelineController.getOrgWideEmailAddresses();
        System.assert(wrapperList.size() > 0);
    }
    @isTest
    public static void getPendingActivities_Test(){
        List<Account> accountList = [SELECT Id,Name FROM Account LIMIT 1];
        Set<Id> accountIds = new Set<Id>();
        for(Account accountInstance : accountList){
            accountIds.add(accountInstance.Id);
        }
        Map<Id,Integer> pendingActivities = CustomActivityTimelineController.getPendingActivities(accountIds);
        System.debug('pendingActivities: '+pendingActivities);
        System.assert(pendingActivities.values()[0] == 1);
    }
}