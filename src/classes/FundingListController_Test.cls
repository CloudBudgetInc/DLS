@isTest
private class FundingListController_Test{

    @testSetup static void setupMethod(){
    
        List<Payment_Item__c> paymentItems = TestClassUtil.createTestpaymentItems();
    }
    
    // Cover getFundsListByProject method with projectId != NULL
    private static testMethod void myTest1(){
    
        List<Transaction__c> transactions = [SELECT Id, Project__c FROM Transaction__c WHERE Project__c != NULL LIMIT 1];
        
        String res = FundingListController.getFundsListByProject(transactions[0].Project__c);
        
        List<FundingDomain.FundingInfo> fundingRecordsList = (List<FundingDomain.FundingInfo>) JSON.deserialize(res,List<FundingDomain.FundingInfo>.class);
        
        if(fundingRecordsList.size() > 0){
        
            System.assertEquals(transactions [0].Id,fundingRecordsList[0].transactionId);
        
        }
    }
    
    // Cover getFundsListByProject method with projectId = NULL
    private static testMethod void myTest2(){
    
        List<Transaction__c> transactions = [SELECT Id, Project__c FROM Transaction__c WHERE Project__c = NULL LIMIT 1];
        
        String res = FundingListController.getFundsListByProject(transactions[0].Project__c);
        
        if(transactions .size() > 0 && res == null){
           System.assertEquals(transactions [0].Project__c,res);
        }      
    }
    
    // Cover getFundsItemsByFund method 
    private static testMethod void myTest3(){
    
        List<Payment_Item__c> paymentItems = [SELECT Id, Payment__c FROM Payment_Item__c LIMIT 1];

        String res = FundingListController.getFundsItemsByFund(paymentItems[0].Payment__c);
        
        FundingDomain.FundingWholeinfo fundingInfo  = (FundingDomain.FundingWholeinfo) JSON.deserialize(res,FundingDomain.FundingWholeinfo.Class);
        System.assertEquals(paymentItems[0].Payment__c,fundingInfo.FundingInfo.transactionId);

    }
    // Cover getFundingInfo method 
    private static testMethod void myTest4(){
    
        List<Payment_Item__c> paymentItems = [SELECT Id,Payment__c,Payment__r.Auth_last_4_digits__c,Payment__r.Method_of_Payment__c FROM Payment_Item__c LIMIT 1];
        
        
        if(paymentItems.size() > 0) {
            
            ApexPages.currentPage().getParameters().put('id',paymentItems[0].Payment__c);
            
            FundingListController fundingItemRecs= new FundingListController();
            FundingListController.FundingDetails fundingRec = fundingItemRecs.fundWholeInfo.fundingRecs;

            System.assertEquals(paymentItems[0].Payment__r.Auth_last_4_digits__c,fundingRec.authorizeDigits);
            System.assertEquals(paymentItems[0].Payment__r.Method_of_Payment__c ,fundingRec.methodOfPayment);
         
       }

    }
}