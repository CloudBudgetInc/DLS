public class FundingTranslator {


/**********************************************************************
    - Added by Gowtham on Apr 11,2019
    - For Student Community Fund List and Fund Item Record formation
    ***********************************************************************/


    public static List<FundingDomain.FundingInfo> fundingRecordsFormation(List<Transaction__c> fundingList){
        
        List<FundingDomain.FundingInfo> fundingRecordsList= new List<FundingDomain.FundingInfo>();
        
        for(Transaction__c fund: fundingList) {
            
            FundingDomain.FundingInfo fundDetail = new FundingDomain.FundingInfo();
            fundDetail.transactionId = fund.Id;
            fundDetail.transactionName = fund.Name;
            fundDetail.type = fund.Type__c;
            fundDetail.projectId = fund.Project__c;
            fundDetail.modeOfPayment = fund.Method_of_Payment__c;
            fundDetail.totalAmount = fund.Total_Amount__c;
            fundDetail.authorizedDigits = fund.Auth_last_4_digits__c;
            if(fund.Transaction_Date__c != null) {
                List<String> dateString = string.valueOf(fund.Transaction_Date__c).split('-');
                fundDetail.paymentDate = dateString[1]+'/'+dateString[2]+'/'+dateString[0];
            } 
            fundingRecordsList.add(fundDetail); 
        }
     
        return fundingRecordsList;
    
    }
    
    
    public static List<FundingDomain.FundingItemInfo> fundingItemsRecordsFormation(List<Payment_Item__c> fundingitemsList){
        
        List<FundingDomain.FundingItemInfo> fundingItemRecordsList= new List<FundingDomain.FundingItemInfo>();
        
        List<String> taskTypeList = new List<String>{'Language Training','Preparation time','Material budget'};
        Map<String,List<Payment_Item__c>> orderedFundItemMap = new Map<String,List<Payment_Item__c>>();
        for(Payment_Item__c fundItem :fundingitemsList){
            if(fundItem.Project_Task__r.Project_Task_Type__c != null && taskTypeList.contains(fundItem.Project_Task__r.Project_Task_Type__c) ){
                
                if(orderedFundItemMap.containsKey(fundItem.Project_Task__r.Project_Task_Type__c)){
                	List<Payment_Item__c> fundItemlist = orderedFundItemMap.get(fundItem.Project_Task__r.Project_Task_Type__c);
                    fundItemlist.add(fundItem);
                    orderedFundItemMap.put(fundItem.Project_Task__r.Project_Task_Type__c,fundItemlist);
                }else{
                    orderedFundItemMap.put(fundItem.Project_Task__r.Project_Task_Type__c,new List<Payment_Item__c>{fundItem});
                }
            }else{
                 if(orderedFundItemMap.containsKey('others')){
                	List<Payment_Item__c> fundItemlist = orderedFundItemMap.get('others');
                    fundItemlist.add(fundItem);
                    orderedFundItemMap.put('others',fundItemlist);
                }else{
                    orderedFundItemMap.put('others',new List<Payment_Item__c>{fundItem});
                }
            }
        }
        fundingitemsList = new List<Payment_Item__c>();
        if(orderedFundItemMap.containsKey('Language Training')){
         fundingitemsList.addAll(orderedFundItemMap.get('Language Training'));   
        }
         if(orderedFundItemMap.containsKey('Preparation time')){
         fundingitemsList.addAll(orderedFundItemMap.get('Preparation time'));   
        }
        if(orderedFundItemMap.containsKey('Material budget')){
         fundingitemsList.addAll(orderedFundItemMap.get('Material budget'));   
        }
        if(orderedFundItemMap.containsKey('others')){
         fundingitemsList.addAll(orderedFundItemMap.get('others'));  
        }         
        
        for(Payment_Item__c fundingItem: fundingitemsList) {
            
            FundingDomain.FundingItemInfo fundingItemDetail = new FundingDomain.FundingItemInfo();
            fundingItemDetail.projectTaskName = fundingItem.Project_Task__r.name;
            fundingItemDetail.ratePerQty = fundingItem.Rate_per_Quantity__c;
            fundingItemDetail.amount = fundingItem.Amount__c;
            fundingItemDetail.quantity = fundingItem.Quantity__c;
            fundingItemDetail.projectTaskUnit = fundingItem.Project_Task_Unit__c;
           
            fundingItemRecordsList.add(fundingItemDetail ); 
        }
        return fundingItemRecordsList;
    
    }
    
}