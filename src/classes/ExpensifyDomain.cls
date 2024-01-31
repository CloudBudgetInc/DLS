public class ExpensifyDomain {    
    public class payableLineWrap{
        public String invoiceComment;
        public String postdate;
        public Decimal Total;
        public String Expense_GL_Account;
        public String GL_Account_Variable_1;
        public String referenceNo;
        public String Internal_Comment;
        public String transactionId;
        public List<AcctSeed__Project__c> projectLookup;
        public List<AcctSeed__Project_Task__c> proTaskLookup;
    }
    public class payableWrap{
        
        public List<AcctSeed__Accounting_Period__c> accountingPeriod;
        public List<Account> vendor;
        public String dateVal;        
        public String dueDate;
        public Decimal totalAmount;
        public String payeeReference;
        public String Id;
    }
    
    public class CreditCardWrap{
        
        public String cardID;        
        public String cardName;
        public String cardNumber;
        public String email;
        public String bank;
    }
}