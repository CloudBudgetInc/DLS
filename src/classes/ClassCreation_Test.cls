@isTest
public class ClassCreation_Test {

    @testSetup static void setupMethod(){
    
        List<System_Values__c> sysVal = TestClassUtil.createBillDotComSystemValues();
                         
        List<AcctSeed__Accounting_Variable__c> accVar = TestClassUtil.createAccountingVariable();
        accVar[0].AcctSeed__Active__c = true;
        update accVar;
    }
    
    private static testMethod void myTest(){             
                
       Test.startTest();            
            Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock7());
            Map<String,String> cookieAndSessionIdMap_Item;
            ClassCreation classCreat = new ClassCreation(cookieAndSessionIdMap_Item);
            Database.ExecuteBatch(classCreat);
        Test.stopTest();
        
    }
}