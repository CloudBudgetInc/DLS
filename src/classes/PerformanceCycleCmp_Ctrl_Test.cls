/*
Created By Dhinesh 04/10/2021
Test Class Cover 
        - PerformanceCycleCmp_Ctrl, FormResponseTriggerHandler, FeedbackRemainderMail_Scheduler, PerformanceFeedbackExportPDF_Ctrl - Apex Class
        - performanceCycleTrigger - Apex Trigger

*/
@isTest
public class PerformanceCycleCmp_Ctrl_Test{
    @TestSetup
    static void setupMethod(){
         //TestClassUtil.createTestContacts();
         TestClassUtil.createTestUsers();
         TestClassUtil.createPerformanceCycleAndQuestionSet();        
    }
    
    private static testMethod void testgetLookupRecords(){    
        
        Test.startTest();        
            PerformanceCycleCmp_Ctrl.getLookupRecords('test','Contact','Name','RecordType.DeveloperName = \'Candidate\'',new List<String>());
        Test.stopTest();
    }
    
    private static testMethod void testgetFormResponseRecord(){        
        
        Test.startTest();
            //To Get the Active DLS Employees Contacts to create Form Response
           PerformanceCycleDomain.dlsEmpAndConFilter employeeMap = PerformanceCycleCmp_Ctrl.getEmployees(null);
            System.assertEquals(true, employeeMap.dlsEmp.get('active').size() > 0);
                        
            //To Create the Self and Manager Summary - Form Responses
            Map<Id, Contact> activeEmployee = new Map<Id, Contact>(employeeMap.dlsEmp.get('active'));
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
            
            employeeMap = PerformanceCycleCmp_Ctrl.getEmployees(performanceCycle.Id);
            System.assertEquals(true, employeeMap.dlsEmp.get('active').size() > 0);
        
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
                        
            //To send the reminder mail for feedback submit
            FeedbackRemainderMail_Scheduler s = new FeedbackRemainderMail_Scheduler();
            s.execute(null) ;
            
            resultWrap = PerformanceCycleCmp_Ctrl.createPeerFormResponse(conIds, JSON.serialize(formRes));   
            System.assertEquals('success', resultWrap.get('result'));
            
            Form_Response__c peerformRes = [SELECT Id, Performance_Cycle__c, Feedback_About__c, Feedback_From__c FROM Form_Response__c WHERE Form_Feedback_Type__c='Peer Summary' LIMIT 1];
            peerformRes.Is_Share_with_Employee__c = true;
            update peerformRes;        
        Test.stopTest();
    }        
}