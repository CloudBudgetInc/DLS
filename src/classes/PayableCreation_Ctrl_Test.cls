@isTest
public class PayableCreation_Ctrl_Test {
    @testSetup static void setupMethod(){
        List<AcctSeed__Accounting_Period__c> accPeriods = TestClassUtil.createTestAccountingPeriod();
        
        Test.startTest();
        List<AcctSeed__Accounting_Settings__c> accSetting = TestClassUtil.createAccountSettings();
        List<AcctSeed__Project_Task__c> proTask = TestClassUtil.createTestProjectTask();
        Test.stopTest();
        
    }
    
    // get Payable ,Payable Line andCashDisbursement Info
    private static testMethod void myTest1(){
        List<AcctSeed__Project_Task__c> protasks = [SELECT Id,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 2];
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id FROM AcctSeed__GL_Account__c WHERE AcctSeed__Bank__c = FAlSE LIMIT 2];
        List<Account> accs = [SELECT Id,Bill_com_Vendor_Id__c,Bill_com_Vendor_2_Id__c FROM Account LIMIT 1];
        
        AcctSeed__Project_Task__c proTask = new AcctSeed__Project_Task__c(Id = protasks[0].Id, Bill_com_Item_Id__c = 'TestProjectTask1');
        update protask;
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Id = protasks[0].AcctSeed__Project__c, Bill_com_Job_Id__c = 'TestProject1');
        update proj;
        
        List<AcctSeed__GL_Account__c> glAcc = new List<AcctSeed__GL_Account__c>{new AcctSeed__GL_Account__c(Id = glAccList[0].Id, Bill_com_Chart_Of_Account_Id__c = 'TestchartOfAccountId', Name = '10012 - Bill.com Pay'),
                                              new AcctSeed__GL_Account__c(Id = glAccList[1].Id, Bill_com_Chart_Of_Account_Id__c = 'TestchartOfAccountId', Name = '20001 - Accounts Payable')};
        update glAcc;
        
        accs[0].Bill_com_Vendor_Id__c = 'testVendor1';
        accs[0].Bill_com_Vendor_2_Id__c = 'testVendor';
        update accs;
            
        Test.startTest();
        
        PayableCreation_Ctrl.BillANDBillPayment bills =  PayableCreation_Ctrl.getPayableInfo(String.valueOf(system.today().addDays(-2)),String.valueOf(system.today().addDays(2)));
        
        System.assertEquals(true, bills.pay.size() > 0);
        System.assertEquals(true, bills.cashDisbursements.size() > 0);
        
        Test.stopTest();
    }
    // Payable,Payable Line and Cash Disbursement Creation
    private static testMethod void myTest2(){
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id FROM AcctSeed__Accounting_Period__c LIMIT 1];
        List<Account> accs = [SELECT Id FROM Account LIMIT 1];
        List<AcctSeed__Ledger__c> ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        List<AcctSeed__GL_Account__c> bankGLAccList = [SELECT Id FROM AcctSeed__GL_Account__c WHERE AcctSeed__Bank__c = TRUE LIMIT 1];
        
        List<AcctSeed__GL_Account__c> glAccList = new List<AcctSeed__GL_Account__c> {
            new AcctSeed__GL_Account__c(Name = 'AccountSettingGLAcc1',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = 'AccountSettingGLAcc2',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false)
        };
        insert glAccList;
            
        AcctSeed__Account_Payable__c pay = new AcctSeed__Account_Payable__c();
        pay.Bill_com_AP_Id__c = 'TestPayable';
        pay.Bill_com_AP_Active_Status__c = 'Active';    
        pay.AcctSeed__Payee_Reference__c = 'testPayable';
        pay.Bill_com_AP_Approval_Status__c = 'Approved';
        pay.AcctSeed__Vendor__c = accs[0].Id;
        pay.AcctSeed__Due_Date__c = System.Today();
        pay.AcctSeed__Accounting_Period__c = acpList[0].Id;
        pay.AcctSeed__Ledger__c = ledger[0].Id;

        List<AcctSeed__Account_Payable_Line__c> lines = new List<AcctSeed__Account_Payable_Line__c>{
            new AcctSeed__Account_Payable_Line__c(Bill_com_AP_Line_Id__c  = 'TestPayableLine1', Period_to_Bill__c = acpList[0].Id, Billable__c = true, AcctSeed__Expense_GL_Account__c = glAccList[0].Id, AcctSeed__Amount__c = 50, Amount_per_Quantity__c = 25, AcctSeed__Quantity__c = 2),
            new AcctSeed__Account_Payable_Line__c(Period_to_Bill__c = acpList[0].Id, Bill_com_AP_Line_Id__c  = 'TestPayableLine2', Billable__c = false, AcctSeed__Expense_GL_Account__c = glAccList[1].Id, AcctSeed__Amount__c = 50, Amount_per_Quantity__c = 25, AcctSeed__Quantity__c = 2)
        }; 
            
        AcctSeed__Cash_Disbursement__c cash = new AcctSeed__Cash_Disbursement__c();
        
        cash.AcctSeed__Type__c = 'Electronic';
        cash.AcctSeed__Vendor__c = accs[0].Id;
        cash.AcctSeed__Accounting_Period__c  = acpList[0].Id;
        cash.Bill_com_BillPayment_Id__c = 'sendpay2Id';
        cash.AcctSeed__Amount__c = 100;
        cash.AcctSeed__Reference__c = 'testPayable';
        cash.Bill_com_Bill_Payment_Description__c = 'Description1';
        cash.AcctSeed__Bank_Account__c = bankGLAccList[0].Id;
        cash.AcctSeed__Ledger__c = ledger[0].Id;
        
        Test.startTest();
        try{
            String payableId = PayableCreation_Ctrl.payableCreationRec(JSON.serialize(pay),JSON.serialize(lines),JSON.serialize(new List<AcctSeed__Cash_Disbursement__c>{cash}));
            List<AcctSeed__Account_Payable__c> payList = [SELECT Id FROM AcctSeed__Account_Payable__c WHERE Id = :payableId];
            System.assertEquals(true,payList.size() > 0);        
        }catch(Exception e){
            System.debug(':::::'+e.getMessage());
        }
        Test.stopTest();
    }
    // get Synced Payable,Payable Line and Cash Disbursement Creation
    private static testMethod void myTest3(){
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id FROM AcctSeed__Accounting_Period__c LIMIT 1];
        List<Account> accs = [SELECT Id FROM Account LIMIT 1];
        List<AcctSeed__Ledger__c> ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        List<AcctSeed__GL_Account__c> bankGLAccList = [SELECT Id FROM AcctSeed__GL_Account__c WHERE AcctSeed__Bank__c = TRUE LIMIT 1];
        
        List<AcctSeed__GL_Account__c> glAccList = new List<AcctSeed__GL_Account__c> {
            new AcctSeed__GL_Account__c(Name = 'AccountSettingGLAcc1',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = 'AccountSettingGLAcc2',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false)
        };
        insert glAccList;
        
        AcctSeed__Account_Payable__c pay = new AcctSeed__Account_Payable__c();
        pay.Bill_com_AP_Id__c = 'TestPayable';
        pay.Bill_com_AP_Active_Status__c = 'Active';    
        pay.AcctSeed__Payee_Reference__c = 'testPayable';
        pay.Bill_com_AP_Approval_Status__c = 'Approved';
        pay.AcctSeed__Vendor__c = accs[0].Id;
        pay.AcctSeed__Due_Date__c = System.Today();
        pay.AcctSeed__Accounting_Period__c = acpList[0].Id;
        pay.AcctSeed__Ledger__c = ledger[0].Id;
        
        insert pay;

        List<AcctSeed__Account_Payable_Line__c> lines = new List<AcctSeed__Account_Payable_Line__c>{
            new AcctSeed__Account_Payable_Line__c(AcctSeed__Account_Payable__c = pay.Id, Bill_com_AP_Line_Id__c  = 'TestPayableLine1', Period_to_Bill__c = acpList[0].Id, Billable__c = true, AcctSeed__Expense_GL_Account__c = glAccList[0].Id, AcctSeed__Amount__c = 50, Amount_per_Quantity__c = 20, AcctSeed__Quantity__c = 2),
            new AcctSeed__Account_Payable_Line__c(AcctSeed__Account_Payable__c = pay.Id, Period_to_Bill__c = acpList[0].Id, Bill_com_AP_Line_Id__c  = 'TestPayableLine2', Billable__c = false, AcctSeed__Expense_GL_Account__c = glAccList[1].Id, AcctSeed__Amount__c = 50, Amount_per_Quantity__c = 20, AcctSeed__Quantity__c = 2)
        }; 
        insert lines;
        
        AcctSeed__Cash_Disbursement_Batch__c cashDisBatch = new AcctSeed__Cash_Disbursement_Batch__c(Name = 'cash1234');
        insert cashDisBatch;
        
        AcctSeed__Cash_Disbursement__c cash = new AcctSeed__Cash_Disbursement__c();
        cash.AcctSeed__Type__c = 'Electronic';
        cash.AcctSeed__Vendor__c = accs[0].Id;
        cash.AcctSeed__Cash_Disbursement_Batch__c = cashDisBatch.Id;
        cash.AcctSeed__Accounting_Period__c  = acpList[0].Id;
        cash.Bill_com_BillPayment_Id__c = 'sendpay2Id';
        cash.AcctSeed__Amount__c = 300;
        cash.AcctSeed__Reference__c = 'testPayable';
        cash.Bill_com_Bill_Payment_Description__c = 'Description1';
        cash.AcctSeed__Bank_Account__c = bankGLAccList[0].Id;
        cash.AcctSeed__Ledger__c = ledger[0].Id; 
        
        insert cash;
        
        Test.startTest();
        
        PayableCreation_Ctrl.BillANDBillPayment bills = PayableCreation_Ctrl.getPayableInfo(String.valueOf(system.today().addDays(-2)),String.valueOf(system.today().addDays(2)));
        
        System.assertEquals(true, bills.pay.size() > 0);
        System.assertEquals(true, bills.cashDisbursements.size() > 0);

        Test.stopTest();
    }
    
     private static testMethod void myTest4A(){
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id FROM AcctSeed__Accounting_Period__c LIMIT 1];
        List<Account> accs = [SELECT Id FROM Account LIMIT 1];
        List<AcctSeed__Ledger__c> ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        List<AcctSeed__GL_Account__c> bankGLAccList = [SELECT Id FROM AcctSeed__GL_Account__c WHERE AcctSeed__Bank__c = TRUE LIMIT 1];
        
        List<AcctSeed__GL_Account__c> glAccList = new List<AcctSeed__GL_Account__c> {
            new AcctSeed__GL_Account__c(Name = 'AccountSettingGLAcc1',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = 'AccountSettingGLAcc2',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false)
        };
        insert glAccList;
            
        AcctSeed__Account_Payable__c pay = new AcctSeed__Account_Payable__c();
        pay.Bill_com_Vendor_Credit_Id__c = 'TestPayable';
        pay.Bill_com_AP_Active_Status__c = 'Active';    
        pay.AcctSeed__Payee_Reference__c = 'testPayable';
        pay.Bill_com_AP_Approval_Status__c = 'Approved';
        pay.AcctSeed__Vendor__c = accs[0].Id;
        pay.AcctSeed__Due_Date__c = System.Today();
        pay.AcctSeed__Accounting_Period__c = acpList[0].Id;
        pay.AcctSeed__Ledger__c = ledger[0].Id;
         
        insert pay;

        List<AcctSeed__Account_Payable_Line__c> lines = new List<AcctSeed__Account_Payable_Line__c>{ 
            new AcctSeed__Account_Payable_Line__c(AcctSeed__Account_Payable__c = pay.Id, Bill_com_Vendor_Credit_Line_Id__c  = 'TestPayableLine1',Period_to_Bill__c = acpList[0].Id, Billable__c = true, AcctSeed__Expense_GL_Account__c = glAccList[0].Id, AcctSeed__Amount__c = 50, Amount_per_Quantity__c = 25, AcctSeed__Quantity__c = 2),
            new AcctSeed__Account_Payable_Line__c(AcctSeed__Account_Payable__c = pay.Id, Period_to_Bill__c = acpList[0].Id, Bill_com_Vendor_Credit_Line_Id__c  = 'TestPayableLine2', Billable__c = false, AcctSeed__Expense_GL_Account__c = glAccList[1].Id, AcctSeed__Amount__c = 50, Amount_per_Quantity__c = 25, AcctSeed__Quantity__c = 2)
        }; 
            
        insert lines;
        Test.startTest();
         
         PayableCreation_Ctrl.BillANDBillPayment bills = PayableCreation_Ctrl.getPayableInfo(String.valueOf(system.today().addDays(-2)),String.valueOf(system.today().addDays(2)));
         
         System.assertEquals(true, bills.pay.size() > 0);        
        
        Test.stopTest();
    }
    
}