public class FundingDomain {

/**********************************************************************
    - Added by Gowtham on Apr 11,2019
    - For Student Community Fund List view based in Fund detail page changes
    ***********************************************************************/
    public class FundingInfo{
    
        public Id transactionId;
        public String transactionName;
        public String paymentDate;
        public String type;
        public String modeOfPayment;
        public Decimal totalAmount;
        public String authorizedDigits;
        public String projectId;
        
    }
    
    public class FundingItemInfo{
    public string projectTaskName;
    public decimal quantity;
    public decimal ratePerQty;
    public string projectTaskUnit;
    public decimal amount;
    }
    public class FundingWholeinfo{
    
        public list<FundingItemInfo> FundingItemInfo;
        public FundingInfo FundingInfo;
    
    }
}