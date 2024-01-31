@isTest
public class ManagePlannedHours_Controller_Test {
    
    @testsetup static void setup() {
        Test.StartTest();
        List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
        List<AcctSeed__Project_Task__c> proTask = TestClassUtil.createTestProjectTask(); 
        Test.Stoptest();        
    }
    
    private static testMethod void testMethod1() {
        List<AcctSeed__Project__c> proLst = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c>  proTask = [SELECT Name,Total_Qty_Planned__c,Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Material budget' LIMIT 2];
        List<Contact_Assignments__c> contactAssignList = [SELECT Id,Total_Qty_Planned__c,Project_Task__c,RecordTypeId,Status__c FROM Contact_Assignments__c LIMIT 3];
        String conAssRt = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        String proTaskRT = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
        String Status;
        String proInfo;
        
        if(proLst.size() > 0 && contactAssignList.size() > 0 && proTask.size() > 0){
            AcctSeed__Project_Task__c ProTsk = new AcctSeed__Project_Task__c(RecordTypeId = proTaskRT,Total_Qty_Planned__c = 90,Id = proTask[0].Id,Name = 'Language Training Hindi',AcctSeed__Project__c = proLst[0].Id,Project_Task_Type__c = 'Language Training');
            update proTsk;
            AcctSeed__Project_Task__c prepProTask = new AcctSeed__Project_Task__c(RecordTypeId = proTaskRT ,Total_Qty_Planned__c = 15,Id = proTask[1].Id,Name = 'Preparation Time',Parent_Project_Task__c = proTsk.Id,AcctSeed__Project__c = proLst[0].Id,Project_Task_Type__c = 'Preparation time');
            update  prepProTask;          
            proInfo = 'templateType=Planned&web=true&projectId='+proLst[0].Id; 
           
            for(Contact_Assignments__c ca : contactAssignList){
                ca.RecordTypeId = conAssRt;
                ca.Status__c = 'Active';
                ca.Total_Qty_Planned__c = 20;
                ca.Project_Task__c = ProTsk.Id;
            }
            update contactAssignList;
            ManagePlannedHours_Controller.getInitialProjectTaskRelatedCA(proInfo); 
            proInfo = 'templateType=Actual&web=true&projectId='+proLst[0].Id;
            ManagePlannedHours_Controller.getInitialProjectTaskRelatedCA(proInfo);
            
            for(Contact_Assignments__c cA : contactAssignList){               
                cA.Total_Qty_Planned__c = 30;
                 cA.Total_Prep_Qty_Planned__c = 5;
            }
            ManagePlannedHours_Controller.saveContactAssignment(contactAssignList);   
        }
    }
    private static testMethod void testMethod2() {
        List<AcctSeed__Project__c> proList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c>  proTask = [SELECT Name,Total_Qty_Planned__c,Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Material budget' LIMIT 2];
        
        if(proList.size() > 0  && proTask.size() > 0){
            AcctSeed__Project_Task__c ProTsk = new AcctSeed__Project_Task__c(Id = proTask[0].Id,Name = 'Language Training Hindi',AcctSeed__Project__c = proList[0].Id,Project_Task_Type__c = 'Language Training');
            update proTsk;
            AcctSeed__Project_Task__c prepProTask = new AcctSeed__Project_Task__c(Id = proTask[1].Id,Name = 'Preparation Time',Parent_Project_Task__c = proTask[0].Id,AcctSeed__Project__c = proList[0].Id,Project_Task_Type__c = 'Preparation time');
            update  prepProTask;               
            
            List<APXTConga4__Conga_Merge_Query__c > congaQuery = new List<APXTConga4__Conga_Merge_Query__c> {
                new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Project Query for Job Summary Report'),
                    new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'ContactAssign Query for Job Summary Report')
                    };
                        insert congaQuery;
            String congaInfo = ManagePlannedHours_Controller.getCongaUrl('Project Query for Job Summary Report,ContactAssign Query for Job Summary Report','Job Summary Report - Labor Actual',proList[0].Id); 
            
            CongaButtonsController.congaWrapper wrap = new CongaButtonsController.congaWrapper();
            wrap = (CongaButtonsController.congaWrapper)JSON.deserialize(congaInfo,  CongaButtonsController.congaWrapper.class);
            
            if(wrap!= null){
                List<APXTConga4__Conga_Template__c> congaTemp = [Select Id,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c  WHERE APXTConga4__Name__c = 'Job Summary Report - Labor Actual'];
                if(congaTemp.size() > 0){
                    System.assertEquals(congaTemp[0].Id, wrap.congaWrap.tempNameIdMap.get('Job Summary Report - Labor Actual')); 
                } 
            }
        }
    }
}