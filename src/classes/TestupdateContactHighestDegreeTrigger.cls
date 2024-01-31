@isTest 
private class TestupdateContactHighestDegreeTrigger{
    
    @testSetup static void setup(){
    
          List<Experience__c> experienceList = TestClassUtil.createTestExperience();
          
     }
     
     static testMethod void insertExperience() {
         
         List<Experience__c> experience = new List<Experience__c>();
         Experience__c experience1 = new Experience__c();
         experience = [SELECT Id, RecordTypeId, Start_Date__c, End_Date__c, Contact__c, Degree_Level__c, Name_of_Company__c FROM Experience__c LIMIT 5];
         
         System.debug('******'+experience);
         if(experience != Null && experience.size() > 0) {
             
             experience1.RecordTypeId = experience[1].RecordTypeId;
             experience1.Start_Date__c= experience[1].Start_Date__c;
             experience1.End_Date__c= experience[1].End_Date__c;
             experience1.Contact__c= experience[1].Contact__c;
             experience1.Id= experience[1].Id;
             experience1.Degree_Level__c = 'Ph.D';             
             
             Update experience1;
         }
     }
}