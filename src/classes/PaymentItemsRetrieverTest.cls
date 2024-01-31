@isTest
public Class PaymentItemsRetrieverTest{
    @testsetup static void setup() {
        List<Payment_Item__c> transL = TestClassUtil.createTestpaymentItems();
        //List<PricebookEntry> prodL = TestClassUtil.createTestPriceBook();      
    }
    static testmethod void payTest() {
        
        List<Payment_Item__c> trans = new List<Payment_Item__c>();
        List<Product2> prds = [SELECT Id,Name FROM Product2 LIMIT 5]; 
        integer i = 0;
        for(Payment_Item__c pi : [Select Id,Name,Payment__c,Product__c FROM Payment_Item__c LIMIT 5]) {
            if(i == 0 ) {
                pi.Product__c = prds[0].Id;
                trans.add(pi);
            }
            i++;
        }       
        PaymentItemsRetriever pr = new PaymentItemsRetriever();
        pr.setPayId(trans[0].Payment__c);
         
        update trans;
        
        
        pr.getPayId();
        system.debug('prds :::'+prds);  
        
        if( trans != null && trans.size() > 0 ) {
            pr.PayId = trans[0].Payment__c;
            pr.retrieveData();  
        }        
    }
}