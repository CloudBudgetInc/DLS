@isTest
Class Test_Location_Trigger_And_LatLongBatch{
    @testSetup static void setup(){
          List<MTT_Location__c> locList = TestClassUtil.createTestLocations();
     }
    static testMethod void acctTestMethod() {
        
        
        MTT_Location__c loc = new MTT_Location__c();
        loc = [SELECT Id, Name, Zip_Code__c FROM MTT_Location__c LIMIT 1];
        loc.Zip_Code__c = '52345';
        update loc;
        
        Test.startTest();
        
        LocationLatLongBatchClass al = new LocationLatLongBatchClass();
        Database.executeBatch(al);
        Test.stopTest();
    }
}