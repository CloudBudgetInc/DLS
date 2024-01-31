@isTest
Class Test_Hotel_Trigger_And_LatLongBatch{
    @testSetup static void setup(){
          List<Hotel__c> HotelList = TestClassUtil.createTestHotels();
          system.debug('HotelList:::'+HotelList);
          
     }
    static testMethod void hotelTestMethod() {
        
        /*List<RecordType> rTList = [SELECT Id,Name,DeveloperName From RecordType WHERE DeveloperName = 'Corporate' AND SObjectType = 'MTT_Location__c'];
        
        MTT_Location__c loc;
        Hotel__c hotel;
        
        if( rTList != null && rTList.size() > 0 ) {
        
            loc = new MTT_Location__c(name='Test Location',RecordTypeId=rTList[0].Id);
            Insert loc;
        }
        
        
        hotel = new Hotel__c(name='Test Hotel 1',MTT_Location__c = loc.Id,Address__c = '4601 US Highway 17, Richmond Hill, GA 31324');
        Insert hotel;*/
        Hotel__c hotel = new Hotel__c();
        hotel = [SELECT Id, Name, Address__c FROM Hotel__c LIMIT 1];
        
        hotel.Address__c = '4601 US Highway 17, Richmond Hill';
        
        update hotel;
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator.LatLongCalloutMock());
        HotelLatLongBatchClass al = new HotelLatLongBatchClass();
        Database.executeBatch(al);
        Test.stopTest();
    }
}