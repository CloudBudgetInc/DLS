@isTest 
private class TestupdateContentVersionRatingTrigger{
    @testSetup static void setup(){
          List<Material_Rating__c> rateList = TestClassUtil.createTestmaterialsRating();
     }
    static testMethod void Testmethod1() {
       
        Material_Rating__c materialRating2 = new Material_Rating__c ();
        materialRating2 = [SELECT Id,Rating__c FROM Material_Rating__c LIMIT 1];
        
        materialRating2.Rating__c = '2';
        update materialRating2;
        
        materialRating2.Rating__c = '3';
        update materialRating2;
        
        materialRating2.Rating__c = null;
        update materialRating2;
        
        materialRating2.Rating__c = '2';
        update materialRating2;         
    }
}