@isTest
Class Test_Account_Trigger_And_LatLongBatch{
    @testSetup static void setup(){
          List<Account> AccList = TestClassUtil.createTestAccounts();
     }
    static testMethod void acctTestMethod() {
        
        List<Account> acctList = new List<Account>{
            new Account(Name='Test Account 1'+Datetime.now(),Follow_Up__c = date.today(),Type = 'Other',BillingStreet = '24 Jackson Road', Entity_Type__c = 'C Corporation'),
            new Account(Name='Test Account 2'+Datetime.now(),Follow_Up__c = date.today()+3,Type = 'Other',BillingStreet = '25 Jackson Road', Entity_Type__c = 'Partnership'),
            new Account(Name='Test Account 3'+Datetime.now(),Follow_Up__c = date.today()+6,Type = 'Other',BillingStreet = '26 Jackson Road', Entity_Type__c = 'Investor')
        };
        insert acctList;
        
        List<Account> accList = [SELECT Id, AcctSeed__X1099_Vendor__c FROM Account WHERE Entity_Type__c != null];
        system.assertEquals(false, accList[0].AcctSeed__X1099_Vendor__c);
        system.assertEquals(true, accList[1].AcctSeed__X1099_Vendor__c);
        system.assertEquals(true, accList[2].AcctSeed__X1099_Vendor__c);
        
        acctList[0].Entity_Type__c = 'Partnership';
        acctList[1].Entity_Type__c = 'C Corporation';
        acctList[2].BillingStreet = '30 Jackson Road';
        update acctList;
        
        List<Account> accList1 = [SELECT Id, Geo_Code_Status__c, AcctSeed__X1099_Vendor__c FROM Account WHERE Entity_Type__c != null];
        system.assertEquals(true, accList1[0].AcctSeed__X1099_Vendor__c);
        system.assertEquals(false, accList1[1].AcctSeed__X1099_Vendor__c);
        system.assertEquals('Not Processed', accList1[2].Geo_Code_Status__c);       
    }
    
    static testMethod void testAccountLatLongBatchClass() {
        Test.startTest();
        AccountLatLongBatchClass al = new AccountLatLongBatchClass();
        Database.executeBatch(al);
        Test.stopTest();
    }
}