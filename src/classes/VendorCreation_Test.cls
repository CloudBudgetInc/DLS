@isTest
private class VendorCreation_Test{

    @testSetup static void setupMethod(){
    
        List<Contact> contacts = TestClassUtil.createTestContacts();
                 
        List<System_Values__c> sysVal = TestClassUtil.createBillDotComSystemValues();
    }
    
    private static testMethod void myTest1(){
    
        Id comVenRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial_Vendor').getRecordTypeId();
    
        List<Account> account = [SELECT Id, RecordTypeId, AcctSeed__Accounting_Type__c, AcctSeed__Accounting_Active__c FROM Account LIMIT 1]; 
        
        List<Contact> con = [SELECT Id FROM Contact LIMIT 1];
        
        account[0].RecordTypeId = comVenRTId;
        account[0].AcctSeed__Accounting_Type__c = 'Vendor';
        account[0].AcctSeed__Accounting_Active__c = TRUE;
        account[0].Account_Code__c = 'My test code';
        account[0].Account_Full_Name__c = 'My test full Name';
        account[0].Bill_com_Name_On_Check__c = 'My test check name';
        account[0].AccountNumber = 'My test Number 123';
        account[0].Tax_ID__c = 'My test tax Id';
        account[0].AcctSeed__X1099_Vendor__c = TRUE;
        account[0].BillingStreet = 'My test tax Id';
        account[0].BillingCity = 'My test tax Id';
        account[0].BillingState = 'My test tax Id';
        account[0].BillingCountry = 'My test tax Id';
        account[0].BillingPostalCode = 'My test tax Id';
        account[0].Email__c = 'mytestemail@gmail.com';
        account[0].Fax = '7867465736';
        account[0].Phone = '7836456577';
        account[0].Account_Description__c = 'My test description';
        account[0].Bill_com_Payment_Email__c = 'mytestpayment@gmail.com';
        account[0].Bill_com_Payment_Phone__c = '7836354657';
        account[0].Bill_com_PayBy_Method__c = 'check';
        account[0].Bill_com_Account_Type__c = 'Business';
        account[0].AcctSeed__Billing_Contact__c = con[0].Id;
        account[0].Status_Bill_com__c = 'Active';
        update account[0];
                
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock1());
        
        Test.startTest();
        
            VendorCreation venCreat = new VendorCreation(account[0].Id);
            Database.ExecuteBatch(venCreat, 1);
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
        Id comVenRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial_Vendor').getRecordTypeId();
    
        List<Account> account = [SELECT Id, RecordTypeId, AcctSeed__Accounting_Type__c, AcctSeed__Accounting_Active__c FROM Account LIMIT 1]; 
        
        List<Contact> con = [SELECT Id FROM Contact LIMIT 1];
        
        account[0].RecordTypeId = comVenRTId;
        account[0].AcctSeed__Accounting_Type__c = 'Vendor';
        account[0].AcctSeed__Accounting_Active__c = FALSE;
        account[0].Account_Code__c = 'My test code';
        account[0].Account_Full_Name__c = 'My test full Name';
        account[0].Bill_com_Name_On_Check__c = 'My test check name';
        account[0].AccountNumber = 'My test Number 123';
        account[0].Tax_ID__c = 'My test tax Id';
        account[0].AcctSeed__X1099_Vendor__c = TRUE;
        account[0].BillingStreet = 'My test tax Id';
        account[0].BillingCity = 'My test tax Id';
        account[0].BillingState = 'My test tax Id';
        account[0].BillingCountry = 'My test tax Id';
        account[0].BillingPostalCode = 'My test tax Id';
        account[0].Email__c = 'mytestemail@gmail.com';
        account[0].Fax = '7867465736';
        account[0].Phone = '7836456577';
        account[0].Account_Description__c = 'My test description';
        account[0].Bill_com_Payment_Email__c = 'mytestpayment@gmail.com';
        account[0].Bill_com_Payment_Phone__c = '7836354657';
        account[0].Bill_com_Account_Type__c = 'Business';
        account[0].AcctSeed__Billing_Contact__c = con[0].Id;
        account[0].Status_Bill_com__c = 'Active';
        update account[0];
                
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock2());
        
        Test.startTest();
        
            VendorCreation venCreat = new VendorCreation(account[0].Id);
            Database.ExecuteBatch(venCreat, 1);
        Test.stopTest();
    }
    
    private static testMethod void myTest3(){
    
        Id comVenRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial_Vendor').getRecordTypeId();
    
        List<Account> account = [SELECT Id, RecordTypeId, AcctSeed__Accounting_Type__c, AcctSeed__Accounting_Active__c FROM Account LIMIT 1]; 
        
        List<Contact> con = [SELECT Id FROM Contact LIMIT 1];
        
        account[0].RecordTypeId = comVenRTId;
        account[0].AcctSeed__Accounting_Type__c = 'Vendor';
        account[0].AcctSeed__Accounting_Active__c = TRUE;
        account[0].Account_Code__c = 'My test code';
        account[0].Account_Full_Name__c = 'My test full Name';
        account[0].Bill_com_Name_On_Check__c = 'My test check name';
        account[0].AccountNumber = 'My test Number 123';
        account[0].Tax_ID__c = 'My test tax Id';
        account[0].AcctSeed__X1099_Vendor__c = TRUE;
        account[0].BillingStreet = 'My test tax Id';
        account[0].BillingCity = 'My test tax Id';
        account[0].BillingState = 'My test tax Id';
        account[0].BillingCountry = 'My test tax Id';
        account[0].BillingPostalCode = 'My test tax Id';
        account[0].Email__c = 'mytestemail@gmail.com';
        account[0].Fax = '7867465736';
        account[0].Phone = '7836456577';
        account[0].Account_Description__c = 'My test description';
        account[0].Bill_com_Payment_Email__c = 'mytestpayment@gmail.com';
        account[0].Bill_com_Payment_Phone__c = '7836354657';
        account[0].Bill_com_PayBy_Method__c = 'check';
        account[0].Bill_com_Account_Type__c = 'Business';
        account[0].AcctSeed__Billing_Contact__c = con[0].Id;
        account[0].Bill_com_Vendor_Id__c = 'My test Id';
        account[0].Status_Bill_com__c = 'Active';
        update account[0];
                
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock3());
        
        Test.startTest();
        
            VendorCreation venCreat = new VendorCreation(account[0].Id);
            Database.ExecuteBatch(venCreat, 1);
        Test.stopTest();
    }
}