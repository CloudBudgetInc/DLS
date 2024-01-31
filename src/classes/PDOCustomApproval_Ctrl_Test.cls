@isTest
public with sharing class PDOCustomApproval_Ctrl_Test {
    @testSetup
    public static void testSetup(){
        TestClassUtil.createTestPlannedDaysOff();
    }
    @isTest
    public static void plannedDaysOff_Approve_Test(){
        List<Planned_Days_Off__c> plannedDaysOffList = [SELECT Id FROM Planned_Days_Off__c LIMIT 1];
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(plannedDaysOffList[0].id);
        
        List<User> loggedInUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        req1.setSubmitterId(loggedInUser[0].Id); 
        req1.setProcessDefinitionNameOrId('Planned_Days_off_Approval_Process');
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        Approval.ProcessResult result = Approval.process(req1);
        
        String returnedString;
        Test.startTest();
        returnedString = PDOCustomApproval_Ctrl.approveOrRejectPDO(plannedDaysOffList[0].Id , 'Approve' , true , '');
        Test.stopTest();
        
        System.assert(returnedString == 'Planned Days Off has been approved.');
    }
    @isTest
    public static void plannedDaysOff_Reject_Test(){
        
        Id requestRecordType = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
        
        List<Planned_Days_Off__c> plannedDaysOffList = [SELECT Id FROM Planned_Days_Off__c LIMIT 1];
		plannedDaysOffList[0].RecordTypeId = requestRecordType;
		update plannedDaysOffList;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(plannedDaysOffList[0].id);
        
        List<User> loggedInUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        req1.setSubmitterId(loggedInUser[0].Id); 
        req1.setProcessDefinitionNameOrId('Planned_Days_off_Approval_Process');
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        Approval.ProcessResult result = Approval.process(req1);
        
            Test.startTest();
        	String returnedString = PDOCustomApproval_Ctrl.approveOrRejectPDO(plannedDaysOffList[0].Id , 'Reject' , false , '');
        	Test.stopTest();
        
        System.assert(returnedString == 'Planned Days Off has been rejected.');
    }
    @isTest
    public static void plannedDaysOff_Exception_Test(){
        
        List<Planned_Days_Off__c> plannedDaysOffList = [SELECT Id FROM Planned_Days_Off__c LIMIT 1];
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(plannedDaysOffList[0].id);
        
        List<User> loggedInUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        req1.setSubmitterId(loggedInUser[0].Id); 
        req1.setProcessDefinitionNameOrId('Planned_Days_off_Approval_Process');
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        Approval.ProcessResult result = Approval.process(req1);
        
        try{
            Test.startTest();
        	PDOCustomApproval_Ctrl.approveOrRejectPDO(plannedDaysOffList[0].Id , 'Reject' , false , '');
        	Test.stopTest();
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
    }
}