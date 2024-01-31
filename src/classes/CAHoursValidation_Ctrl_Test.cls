@isTest
public class CAHoursValidation_Ctrl_Test {
    
    @testsetup static void setup() {
        Test.StartTest();
        List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
        List<AcctSeed__Project_Task__c> proTask = TestClassUtil.createTestProjectTask(); 
        Test.Stoptest();        
    }
    
    private static testMethod void testMethod1() {
        
        List<AcctSeed__Project__c> proLst = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c>  proTask = [SELECT Name,Total_Qty_Planned__c FROM AcctSeed__Project_Task__c LIMIT 1];
        List<Contact_Assignments__c> contactAssignList = [SELECT Id,Project_Task__c,RecordTypeId,Status__c FROM Contact_Assignments__c LIMIT 3];
        String conAssRt = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        String Status;
        
        ApexPages.currentPage().getParameters().put('templateType','Planned');
        contactAssignmentHoursValidation_Ctrl.callApproval(proLst[0].Id,'Job Summary Report - Labor Planned');
        
        if(proTask.size() > 0 && contactAssignList.size() > 0){
            for(Contact_Assignments__c cALst : contactAssignList){
                cALst.Project_Task__c = proTask[0].Id;
                cALst.RecordTypeId = conAssRt;
                cALst.Total_Qty_Planned__c = 20;
            }
            upsert contactAssignList;
            proTask[0].Total_Qty_Planned__c = 50;
            upsert proTask;
            
            ApexPages.currentPage().getParameters().put('projectId',proLst[0].Id);
            contactAssignmentHoursValidation_Ctrl CAHoursValidation = new contactAssignmentHoursValidation_Ctrl();
            CAHoursValidation.hourSave();
           
            /*No Active Contact Assignment*/
            Status = contactAssignmentHoursValidation_Ctrl.callApproval(proLst[0].Id,'Job Summary Report - Labor Planned');
            system.assertEquals('error', Status);
            
            /*The Total Hours of Contact Assignments are equal to Project Task Total Planned Hours! Click Ok to Proceed or cancel to Manage the Hours!*/
            proTask[0].Total_Qty_Planned__c = 60;
            upsert proTask;
            Status = contactAssignmentHoursValidation_Ctrl.callApproval(proLst[0].Id,'Job Summary Report - Labor Planned');
            system.assertEquals('equal', Status);
            
            /*The Total Hours of Contact Assignments are Lesser than the Project Task Total Planned Hours! Click Ok to Proceed or cancel to Manage the Hours!*/
            proTask[0].Total_Qty_Planned__c = 100;
            upsert proTask;
            Status = contactAssignmentHoursValidation_Ctrl.callApproval(proLst[0].Id,'Job Summary Report - Labor Planned');
            system.assertEquals('warning', Status);
        }
    }
}