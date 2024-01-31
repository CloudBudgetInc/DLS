public without sharing class FundingListController {

    //Added bt Siva prasanth on 2/25/2020
    //W-002989 - PVT Student Payment Receipts
    public FundingListController(){
        
        system.debug('::::::::url::;'+ApexPages.currentPage().getParameters());
    
        String fundingId  = ApexPages.currentPage().getParameters().get('id');
        //For Funding Download Receipt quick action - W-007854
        if(fundingId == null){
            fundingId = ApexPages.currentPage().getParameters().get('recordId');
        }
        
        if(fundingId != null){
            fundWholeInfo = getFundingInfo(fundingId);
            Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=Funding Receipt PDF.pdf'); 
        }
    }

    @AuraEnabled
    public static String getFundsListByProject(String projectId){
        system.debug('');
        if(projectId != Null){
            List<Transaction__c> fundsList = [SELECT Id,Project__c,Name,Auth_last_4_digits__c,Transaction_Date__c,Type__c,Method_of_Payment__c,Total_Amount__c FROM Transaction__c WHERE Project__c = :projectId ORDER BY Transaction_Date__c DESC];
            system.debug('sd'+FundingTranslator.fundingRecordsFormation(fundsList));
            return JSON.serialize(FundingTranslator.fundingRecordsFormation(fundsList));
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static String getFundsItemsByFund(String fundingId){
        
        List<Payment_Item__c> fundingitemsList = [SELECT Id ,Project_Task__r.Project_Task_Type__c,Amount__c,Project_Task__r.name ,Project_Task_Unit__c,Quantity__c,Rate_per_Quantity__c from Payment_Item__c  where Payment__c = :fundingId];
        FundingDomain.FundingWholeinfo fundingFullInfo = new  FundingDomain.FundingWholeinfo();
        List<Transaction__c> fundingList = [SELECT Id,Project__c,Name,Auth_last_4_digits__c,Transaction_Date__c,Type__c,Method_of_Payment__c,Total_Amount__c FROM Transaction__c WHERE id = :fundingId];
        List<FundingDomain.FundingInfo> fundingInfoList = FundingTranslator.fundingRecordsFormation(fundingList);
        fundingFullInfo.FundingInfo = fundingInfoList[0];
        
        fundingFullInfo.FundingItemInfo = FundingTranslator.fundingItemsRecordsFormation(fundingitemsList);
        return JSON.serialize(fundingFullInfo);
    }
    
    public static FundingWholeInfo getFundingInfo(Id fundingId){
    
        List<Payment_Item__c> fundingItemsList = FundingItemService.getPaymentItemsByPaymentIds(' WHERE Payment__c',new Set<Id>{fundingId});
        
        Set<Id> fundIDs = new Set<Id>();
        FundingWholeInfo fundInfo = new FundingWholeInfo();
        List<FundingLineItems> fundDetalList = new List<FundingLineItems>();
        
        if(fundingitemsList.size() > 0){
            Decimal fundTotAmtPaid = 0.00;
            for(Payment_Item__c fundLT: fundingitemsList){
                FundingLineItems fundLTInfo = new  FundingLineItems();
                
                if(fundLT.Payment__c != null && (!fundIDs.contains(fundLT.Payment__c))){
                    FundingDetails fund = new FundingDetails();
                    String transDt = null;
                    
                    if(fundLT.Payment__r.Transaction_Date__c != null){
                        String dt = String.valueOf(fundLT.Payment__r.Transaction_Date__c).split(' ')[0];
                        transDt = dt.split('-')[1]+'/'+dt.split('-')[2]+'/'+dt.split('-')[0];
                    }
                    
                    if(fundLT.Payment__r.Customer_Name__c != null){
                       fund.custName = fundLT.Payment__r.Customer_Name__r.Name; 
                    }
                    
                    fundTotAmtPaid = (fundLT.Payment__r.Total_Amount__c != null ? fundLT.Payment__r.Total_Amount__c  : 0.00);

                    if(fundLT.Payment__r.Project__c != null && fundLT.Payment__r.Project__r.DLS_Ref__c != null){
                       fund.classNumber = fundLT.Payment__r.Project__r.DLS_Ref__c;
                    }
                    fund.transactionDt = transDt;
                    fund.authorizeDigits = fundLT.Payment__r.Auth_last_4_digits__c;
                    fund.methodOfPayment = fundLT.Payment__r.Method_of_Payment__c;
                    fund.transactionNotes = fundLT.Payment__r.Transaction_Notes__c;
                    fundInfo.fundingRecs = fund;
                    fundIDs.add(fundLT.Payment__c);
                }   
                
                if(fundLT.Project_Task__c != null){                   
                    fundLTInfo.proTaskName = fundLT.project_Task__r.Name;
                }
                
                fundLTInfo.totalAmtPaid = fundLT.Amount__c  != null ? String.valueOf(fundLT.Amount__c.setScale(2)) : '0.00';
                fundLTInfo.qtyPaid = fundLT.Quantity__c != null ? String.valueOf(fundLT.Quantity__c.setScale(2)) : '0.00';
                fundLTInfo.ratePerQuantity = fundLT.Rate_per_Quantity__c != null ? String.valueOf(fundLT.Rate_per_Quantity__c) : '0.00';              
                fundDetalList.add(fundLTInfo);
            }
            fundInfo.fundTotalAmtPaid = String.valueOf(fundTotAmtPaid.setScale(2));
            if(fundDetalList.size() > 0){
                fundInfo.fundingLTRecs = fundDetalList;
            }
            
        }
        return  fundInfo;
    }
    
    public FundingWholeInfo fundWholeInfo{get; set;}
    
    public class FundingWholeInfo {
        public FundingDetails fundingRecs {get; set;}
        public List<FundingLineItems> fundingLTRecs {get; set;}
        public String fundTotalAmtPaid {get; set;}
    }
    
    public class FundingDetails{
        public String custName {get; set;}
        public String transactionDt {get; set;}
        public String authorizeDigits  {get; set;}
        public String methodOfPayment {get; set;}
        public String transactionNotes {get; set;}
        public String classNumber {get; set;}
    } 
    
    public class FundingLineItems{
        public String proTaskName {get; set;}
        public String qtyPaid {get; set;}       
        public String ratePerQuantity {get; set;}       
        public String totalAmtPaid {get; set;}
    }
    
}