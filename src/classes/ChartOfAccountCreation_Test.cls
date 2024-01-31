@isTest
private class ChartOfAccountCreation_Test{

    @testSetup static void setupMethod(){
    
        List<System_Values__c> sysVal = TestClassUtil.createBillDotComSystemValues();
        
        List<AcctSeed__GL_Account__c> glAcc = TestClassUtil.createTestGLAccount();
                 
    }
    
    private static testMethod void myTest1(){
    
                
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock1());
        Test.startTest();
            Map<String,String> cookieAndSessionIdMap_Class;
            ChartOfAccountCreation venCreat = new ChartOfAccountCreation(cookieAndSessionIdMap_Class);
            Database.ExecuteBatch(venCreat);
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
                
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock5());
        Test.startTest();
            Map<String,String> cookieAndSessionIdMap_Class;
            ChartOfAccountCreation venCreat = new ChartOfAccountCreation(cookieAndSessionIdMap_Class);
            Database.ExecuteBatch(venCreat);
        Test.stopTest();
    }
}