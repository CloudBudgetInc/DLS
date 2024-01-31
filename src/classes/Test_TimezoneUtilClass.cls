@isTest
Class Test_TimezoneUtilClass{
    
    static testMethod void timeZoneTestMethod() {
        
        List<RecordType> rTList = [SELECT Id,Name,DeveloperName From RecordType WHERE DeveloperName = 'DLS' AND SObjectType = 'Account'];
        Account acc;
        if( rTList != null && rTList.size() > 0 ) {
        
            acc = new Account(name='Test Acct 1',Type = 'Other',RecordTypeId=rTList[0].Id,BillingStreet = '24 Jackson Road');
            Insert acc;
        }
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator.LatLongCalloutMock());
        TimezoneUtilClass tu = new TimezoneUtilClass();
        tu.getDateTimeInGMT('America/New_York',System.today(),'12:00 AM',true); 
        tu.updateLatLong('test','','','','',acc.Id,'Account','Location_GeoCode__latitude__s','Location_GeoCode__longitude__s','Geo_Code_Status__c');  
        test.StopTest();
    }
}