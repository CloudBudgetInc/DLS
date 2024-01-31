@isTest 
public class ProjectRecord_DeletionClass_Test{
   
    
    @testSetup static void setup(){    
        Test.StartTest();
        List<AcctSeed__Time_Card_Line__c> cardLinelist = TestClassUtil.createTestTimeCardLine();
        Test.StopTest();
    }
    
    public static testmethod void ProjectRecord_DeletionClass_TestMethod(){
        
        List<AcctSeed__Project__c> proList = [
                                                SELECT Id, Name 
                                                FROM AcctSeed__Project__c
                                             ];
        List<Opportunity> oppoList = [SELECT Id, Name FROM Opportunity];
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = [
                                                                SELECT Id, Name 
                                                                FROM AcctSeed__Time_Card_Line__c
                                                                WHERE AcctSeed__Project_Task__r.AcctSeed__Project__c = :proList[0].Id
                                                             ];
        ProjectRecord_DeletionClass.deleteRecords(proList[0].Id);
        
        String str = 'Somthing went wrong';
        ProjectRecord_DeletionClass.sendEmailWhenErrorOccurs(str);
        ProjectRecord_DeletionClass.alertForNotesAttachments(proList[0].Id);
    }
}