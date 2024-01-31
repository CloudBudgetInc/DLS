@isTest
public class Qualification_Trigger_Test {

    @testSetup static void setUp(){
    
        List<Qualification__c> qualificationList = TestClassUtil.createTestQualification();
    } 
    
    public static testMethod void testMethod1() {
               
           Qualification__c qualificationRec = new Qualification__c();
           qualificationRec.Name = 'test qualification';
           qualificationRec.Condition__c = 'GREATER THAN';
           qualificationRec.Type__c = 'Experience';
           qualificationRec.Value__c = '25';
           
           List<Qualification__c> qualificationList1 = new List<Qualification__c>();
           qualificationList1.add(qualificationRec);
           
           List<Qualification__c> qualificationList2 = [SELECT Id, Name, Type__c, Condition__c, Value__c FROM Qualification__c LIMIT 1];
           
           qualificationList2[0].Value__c = '13';
           qualificationList2[0].Type__c = 'English Language Proficiency';
           
           Update qualificationList2;
    }
}