@isTest
public class JournalEntryLineTrigger_Test{
    @testsetup static void setup() {
       
        List<Materials_Request__c> materialReqList = TestClassUtil.createTestMaterialRequest();
        List<AcctSeed__Accounting_Variable__c> accVar = TestClassUtil.createAccountingVariable();
        TestClassUtil.createTestProjectTaskGLVariableMapping();
        List<AcctSeed__Project_Task__c> ptList = TestClassUtil.createTestProjectTask();
        Test.StartTest();
        List<AcctSeed__Time_Card_Day__c> tcdList = TestClassUtil.createTestTimeCardDay();
        List<Contact_Assignments__c> conAssignList = TestClassUtil.createTestContactAssignment();        
        Test.Stoptest();  
    }
    private static testMethod void testMethod7a(){
        
        List<Account> accList = [SELECT Id,Account_Code__c FROM Account LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c,GL_Variable_2__c FROM AcctSeed__Project__c LIMIT 2];
        List<AcctSeed__Accounting_Variable__c> av = [SELECT Id FROM AcctSeed__Accounting_Variable__c WHERE  AcctSeed__Type__c = 'GL Account Variable 2'];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,Name FROM AcctSeed__Accounting_Period__c LIMIT 1];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 2];
        Map<String,AcctSeed__Journal_Entry__c> journalMap = new Map<String,AcctSeed__Journal_Entry__c>();
        Map<String,List<AcctSeed__Journal_Entry_Line__c>> journalMapLineMap = new Map<String,List<AcctSeed__Journal_Entry_Line__c>>();
        List<AcctSeed__GL_Account__c> glAcclist = [SELECT Name FROM AcctSeed__GL_Account__c LIMIT 1];
        
        Id proId1 = null;
        Id proPT1 = null;
        Id accPId = null;
        Id accId = null;
        Id glAcc = null;
        String accCode = null;
        String accpdName = null;
        
        AcctSeed__Journal_Entry__c je = new AcctSeed__Journal_Entry__c();
        
        if(proList.size() > 0){
            proId1 = proList[0].Id; 
            if(accList.size() > 0){
                proList[0].AcctSeed__Account__c =  accList[0].Id;
                proList[0].GL_Variable_2__c = av[0].Id;
                update proList;
            }
        }
        if(proPTList.size() > 0){
            proPT1 = proPTList[0].Id;
        }
        if(acpList.size() > 0){
            accPId = acpList[0].Id;
            accpdName = acpList[0].Name;
            je.AcctSeed__Accounting_Period__c  = acpList[0].Id;
        }
        if(accList.size() > 0){
            accId = accList[0].Id;
            accCode = accList[0].Account_Code__c;
        }
        if(glAcclist.size() > 0){
            glAcclist[0].Name = 'Actual';
            update glAcclist;
            glAcc = glAcclist[0].Id;
        }
        
        if(proId1 != null){
            journalMap.put(proId1,je);

            List<AcctSeed__Journal_Entry_Line__c> jel = new List<AcctSeed__Journal_Entry_Line__c>();
            AcctSeed__Journal_Entry_Line__c jelCredit = new AcctSeed__Journal_Entry_Line__c();
            jelCredit.AcctSeed__Project__c = proId1;
            jelCredit.AcctSeed__Project_Task__c = proPT1;
            jelCredit.AcctSeed__Credit__c = 100;
            jelCredit.AcctSeed__GL_Account__c = glAcc;
            
            AcctSeed__Journal_Entry_Line__c jelDebit = new AcctSeed__Journal_Entry_Line__c();
            jelDebit.AcctSeed__Debit__c = 100;
            jelDebit.AcctSeed__GL_Account__c = glAcc;
            
            jel.add(jelCredit);
            jel.add(jelDebit);
            journalMapLineMap.put(proId1,jel);
        }
      
        String journalJSON = JSON.serialize(journalMap);
        String journaLineJSON = JSON.serialize(journalMapLineMap);
        Test.startTest();
        BillingCreation_Ctrl.journalEntryCreation(journalJSON,journaLineJSON,accId,accPId);
        
        List<AcctSeed__Journal_Entry__c> journal = [SELECT Id,Name FROM AcctSeed__Journal_Entry__c]; 
        if(journal.size() > 0){
            system.assertEquals(1,journal.size());
        }
        Test.stoptest();
    }
}