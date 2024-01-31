/***************************************************
    Developed by GRK on 17 Aug, 2018
******************************************************/
Public with sharing Class AmortizationEntryDomain {
    Public Class AELocationWrapperClass{
        public String Location;
        public List<AEWrapperClass> aeList;
        public Integer count;
        public Decimal amountSum;
        public String currentMonth;
        public String locationFARTGroupBy;
        
        public AELocationWrapperClass() {
            Location = '';
            aeList = new List<AEWrapperClass>();
            count = 0;
            amountSum = 0.00;
            currentMonth ='';
            locationFARTGroupBy = '';
        }
    }
    
    Public Class AEWrapperClass {
        public Id fAId;
        public String fAName;
        public Decimal amount;
        public Id gLVar1Id;
        public String gLVar1Name;
        public Id periodId;
        public String periodName;
        public Id creditGLAccId;
        public String creditGLAccName;
        public Id debitGLAcctId;
        public String debitGLAcctName;
        public String locationName;
        public Id equipId;
        public String equipName;
        public String fixedAssetRT;
        public String assetId;
        public String serviceTag;
    }
}