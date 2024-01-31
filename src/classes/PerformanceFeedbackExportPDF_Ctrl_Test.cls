/*
Created By Dhinesh 29/11/2021
Test Class Cover 
        - PerformanceFeedbackExportPDF_Ctrl - Apex Class
*/
@isTest
public class PerformanceFeedbackExportPDF_Ctrl_Test{
    @TestSetup
    static void setupMethod(){
         TestClassUtil.createTestUsers();
         TestClassUtil.createPerformanceCycleAndQuestionSet();        
    }    
    
    private static testMethod void testPerformanceFeedbackExportPDF(){        
        
        Test.startTest();
            //To Get the Active DLS Employees Contacts to create Form Response
            Map<String, List<Contact>> employeeMap = PerformanceCycleCmp_Ctrl.getEmployees();
            System.assertEquals(true, employeeMap.get('active').size() > 0);
                        
            //To Create the Self and Manager Summary - Form Responses
            Map<Id, Contact> activeEmployee = new Map<Id, Contact>(employeeMap.get('active'));
            User usr = [SELECT Id, FirstName, LastName, Email, MiddleName FROM User LIMIT 1];
            List<Contact> contactsToUpdate = new List<Contact>();
        	Id empRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        	contactsToUpdate.add(
                new Contact(FirstName=usr.FirstName, LastName=usr.LastName, MiddleName=usr.MiddleName, 
                            Email=usr.Email, recordTypeId=empRecTypeId
                           )
            );
            for(Contact con: activeEmployee.values()){
                con.Supervisor_Name__c = usr.Id;
                contactsToUpdate.add(con);
            }
            upsert contactsToUpdate;
            List<Id> conIds = new List<Id>();
            conIds.addAll(activeEmployee.keySet());
            
            Performance_Cycle__c performanceCycle = [SELECT Id, Status__c FROM Performance_Cycle__c LIMIT 1];
            
            Map<String, String> resultWrap = PerformanceCycleCmp_Ctrl.createEmpFormResponse(conIds, performanceCycle.Id);
            System.assertEquals('success', resultWrap.get('result'));
        
            //To Create the Peer Summary - Form Responses
            Form_Response__c formRes = [SELECT Id, Performance_Cycle__c, Feedback_About__c, Feedback_From__c FROM Form_Response__c WHERE Form_Feedback_Type__c='Self Summary' LIMIT 1];
            resultWrap = PerformanceCycleCmp_Ctrl.createPeerFormResponse(conIds, JSON.serialize(formRes));   
            System.assertEquals('success', resultWrap.get('result'));
        
            //To get the Form Responses to submit
            PerformanceCycleDomain.formResAndPeers wrap = PerformanceCycleCmp_Ctrl.getFormResponseRecord(formRes.Id);
            
            //To get the Form Responses and related Form Template to submit
            PerformanceCycleCmp_Ctrl.getAllFormResElementsAndFormTempElements(formRes.Id);
            List<Form_Response_Element__c> formResEle = [SELECT Id FROM Form_Response_Element__c WHERE Form_Response__c = :formRes.Id];
            PerformanceCycleCmp_Ctrl.saveFormResAndFormResElements(JSON.serialize(formResEle), JSON.serialize(formRes));
            
            //To Trigger the Mail notification             
            performanceCycle.status__c = 'Deployed';
            update performanceCycle;
             
        	ApexPages.currentPage().getParameters().put('feedbackId', String.valueOf(formRes.Id));
        	PerformanceFeedbackExportPDF_Ctrl tsExport = new PerformanceFeedbackExportPDF_Ctrl();
        
        	formRes = [SELECT Id, Performance_Cycle__c, Feedback_About__c, Feedback_From__c FROM Form_Response__c WHERE Form_Feedback_Type__c='Manager Summary' LIMIT 1];
			ApexPages.currentPage().getParameters().put('feedbackId', String.valueOf(formRes.Id));
        	PerformanceFeedbackExportPDF_Ctrl tsExport2 = new PerformanceFeedbackExportPDF_Ctrl();
        Test.stopTest();
    }        
}