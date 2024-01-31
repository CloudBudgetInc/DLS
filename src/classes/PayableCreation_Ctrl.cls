public class PayableCreation_Ctrl {
    
    @AuraEnabled
    public static BillANDBillPayment getPayableInfo(String startDate,String endDate){
        
        if(Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock8());
        }
        BillDotComUtil.ListResponse res = BillDotComUtil.getList('Bill',startDate+'T00:00:00.000+0000',endDate+'T00:00:00.000+0000');
        
        if(Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock9());
        }
        BillDotComUtil.ListResponse billPaymentRes = BillDotComUtil.getList('SentPay',startDate+'T00:00:00.000+0000',endDate+'T00:00:00.000+0000');
        
        if(Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock12());
        }
        BillDotComUtil.ListResponse vendorCreditRes =  BillDotComUtil.getList('VendorCredit',startDate+'T00:00:00.000+0000',endDate+'T00:00:00.000+0000'); 
        
        System.debug('Bill::'+res);
        System.debug('billPaymentRes::'+billPaymentRes);
        System.debug('vendorCreditRes::'+vendorCreditRes);
        
        BillANDBillPayment billPay = new BillANDBillPayment();
        
        Set<String> vendorIdSet = new Set<String>();
        Set<String> chartOfAccId = new Set<String>();
        Set<String> itemIdSet = new Set<String>();
        Set<String> jobIdSet = new Set<String>();
        Set<String> classIdSet = new Set<String>();
        Set<Date> glPostingDate = new Set<Date>();
        Set<String> accPeriodNameSet = new Set<String>();
        
        Set<String> billComIds = new Set<String>();
        Set<String> billComLineIds = new Set<String>();
        Set<String> billPaymentIds = new Set<String>();
        
        Map<String,Account> vendorIdAccountRec = new Map<String,Account>();
        Map<String,AcctSeed__GL_Account__c> chartOfIdGLAccountRec = new Map<String,AcctSeed__GL_Account__c>();
        Map<String,AcctSeed__Project_Task__c> itemIdProjectTaskRec = new Map<String,AcctSeed__Project_Task__c>();
        Map<String,AcctSeed__Project__c> jobIdProjectRec = new Map<String,AcctSeed__Project__c>();
        Map<String,AcctSeed__Accounting_Variable__c> classIdAcctVariableRec = new Map<String,AcctSeed__Accounting_Variable__c>();
        Map<Date,AcctSeed__Accounting_Period__c> glPostDateAccPeriodRec = new Map<Date,AcctSeed__Accounting_Period__c>();
        Map<String,Id> accPeriodNamwWithIdRec = new Map<String,Id>();

        
        Map<String,String> approvalStatusMap = new Map<String,String>{'0'=>'Unassigned','1'=>'Assigned','4'=>'Approving','3'=>'Approved','5'=>'Denied'};
        Map<String,String> paymentStatusMap = new Map<String,String>{'1'=>'Open','4'=>'Scheduled','0'=>'PaidInFull','2'=>'PartialPayment'};
        Map<String,String> cashDisbursementTypeMap = new Map<String,String>{'0'=>'Check','1'=>'Electronic'};
        Map<String,String> cashDisbursePaymentStatusMap = new Map<String,String>{'0'=>'Approving','1'=>'Scheduled','2'=>'Paid','3'=>'Canceled','4'=>'Void','5'=>'Escheated'};

            
        Map<String,Integer> payRelcashDisburseCountMap = new Map<String,Integer>();
        Map<String,Integer> payRelcashDisburseExistCountMap = new Map<String,Integer>();
        Map<String,AcctSeed__GL_Account__c> cdRelGLAccountMap = new Map<String,AcctSeed__GL_Account__c>();


               
        List<PayableWithLine> payabelList = new List<PayableWithLine>();
        List<CashDisbursement> cashDisburse = new List<CashDisbursement>();
        
        if(vendorCreditRes.responseStatus == true && vendorCreditRes.responseMessage == 'Success'){
            //Vendor Credit & Vendor Credit line
            for(BillDotComUtil.VendorCreditRequest vend : vendorCreditRes.responseVendorCreditList){
                vendorIdSet.add(vend.vendorId);
                
                if(vend.glPostingDate != null){
                    accPeriodNameSet.add(String.valueof(vend.glPostingDate).split('-')[0]+'-'+String.valueof(vend.glPostingDate).split('-')[1]);
                }
                
                if(String.isNotBlank(vend.Id)){
                    billComIds.add(vend.Id); 
                }
                
                if(vend.vendorCreditLineItems.size() > 0){
                    
                    for(BillDotComUtil.VendorCreditLineItemsRequest vendLine : vend.vendorCreditLineItems){
                        itemIdSet.add(vendLine.itemId);
                        jobIdSet.add(vendLine.jobId);
                        classIdSet.add(vendLine.actgClassId);
                        chartOfAccId.add(vendLine.chartOfAccountId);

                        
                        if(String.isNotBlank(vendLine.Id)){
                            billComLineIds.add(vendLine.Id); 
                        }
                    }
                }
                
            }
        }
        
        if(res.responseStatus == true && res.responseMessage == 'Success'){
            
            //Bill & Bill Line
            for(BillDotComUtil.BillRequest bill : res.responseBillList){
                
                vendorIdSet.add(bill.vendorId);
                
                if(bill.glPostingDate != null){
                    accPeriodNameSet.add(String.valueof(bill.glPostingDate).split('-')[0]+'-'+String.valueof(bill.glPostingDate).split('-')[1]);
                }
                
                if(String.isNotBlank(bill.Id)){
                    billComIds.add(bill.Id); 
                }
                
                for(BillDotComUtil.BillLineItemRequest billLine : bill.billLineItems){
                    if(billLine.lineType == '2'){
                        
                        itemIdSet.add(billLine.itemId);
                        jobIdSet.add(billLine.jobId);
                        classIdSet.add(billLine.actgClassId);
                        chartOfAccId.add(billLine.chartOfAccountId);
                        
                        if(String.isNotBlank(billLine.Id)){
                            billComLineIds.add(billLine.Id); 
                        }
                    }
                }
            }
        }
        
        //Bill Payment
        if(billPaymentRes.responseStatus == true && billPaymentRes.responseMessage == 'Success'){
            
            for(BillDotComUtil.SendPayRequest sentPay : billPaymentRes.responseSendPayList){
                
                if(sentPay.status == '1' || sentPay.status == '2' || sentPay.status == '4') {   //Moved this condition from callout to here by NS
                    vendorIdSet.add(sentPay.vendorId);
                    chartOfAccId.add(sentPay.chartOfAccountId);
                   // chartOfAccId.add(sentPay.bankAccountId);
                    
                    if(String.isNotBlank(sentPay.Id)){
                        billPaymentIds.add(sentPay.Id); 
                    }
                    
                    if(sentPay.processDate != null){
                        accPeriodNameSet.add(String.valueof(sentPay.processDate).split('-')[0]+'-'+String.valueof(sentPay.processDate).split('-')[1]);
                    }

                    
                    if(String.isNotBlank(sentPay.description)){
                        if(payRelcashDisburseCountMap.containsKey(sentPay.description)){
                            Integer cashDisburseCount = payRelcashDisburseCountMap.get(sentPay.description) + 1;
                            payRelcashDisburseCountMap.put(sentPay.description,cashDisburseCount);  
                            
                        }else{
                            payRelcashDisburseCountMap.put(sentPay.description,1);  
                        }
                    }
                }
                
            }
        }
        Map<String,AcctSeed__Account_Payable__c> payableWithBillComMap = new Map<String,AcctSeed__Account_Payable__c>();
        Map<String,AcctSeed__Account_Payable_Line__c> payableLineWithBillComMap = new Map<String,AcctSeed__Account_Payable_Line__c>();
        Map<String,AcctSeed__Cash_Disbursement__c> cashDisBurseWithSendPayMap = new Map<String,AcctSeed__Cash_Disbursement__c>();


        for(AcctSeed__Account_Payable__c payable : [SELECT Id,Name,Bill_com_AP_Id__c,Bill_com_Vendor_Credit_Id__c FROM AcctSeed__Account_Payable__c WHERE Bill_com_AP_Id__c IN :billcomIds OR Bill_com_Vendor_Credit_Id__c IN :billcomIds]){
            
            if(payable.Bill_com_AP_Id__c != null){
                
                if(!payableWithBillComMap.containsKey(payable.Bill_com_AP_Id__c)){
                    payableWithBillComMap.put(payable.Bill_com_AP_Id__c,payable);
                }
            }
            
           if(payable.Bill_com_Vendor_Credit_Id__c != null){
                
                if(!payableWithBillComMap.containsKey(payable.Bill_com_Vendor_Credit_Id__c)){
                    payableWithBillComMap.put(payable.Bill_com_Vendor_Credit_Id__c,payable);
                }
            }
        }
        
        for(AcctSeed__Account_Payable_Line__c payLine : [SELECT Id,Name, AcctSeed__Project__c,AcctSeed__Project__r.Name,AcctSeed__Project_Task__c,AcctSeed__Project_Task__r.Name,Bill_com_Vendor_Credit_Line_Id__c,Bill_com_AP_Line_Id__c,Billable__c,AcctSeed__Amount__c,AcctSeed__Quantity__c,Amount_per_Quantity__c FROM AcctSeed__Account_Payable_Line__c WHERE Bill_com_AP_Line_Id__c IN :billComLineIds OR  Bill_com_Vendor_Credit_Line_Id__c IN :billComLineIds]){
          
            if(payLine.Bill_com_AP_Line_Id__c != null){

                if(!payableLineWithBillComMap.containsKey(payLine.Bill_com_AP_Line_Id__c)){
                    payableLineWithBillComMap.put(payLine.Bill_com_AP_Line_Id__c,payLine);
                }
            }
            
            if(payLine.Bill_com_Vendor_Credit_Line_Id__c != null){
                
                if(!payableLineWithBillComMap.containsKey(payLine.Bill_com_Vendor_Credit_Line_Id__c)){
                    payableLineWithBillComMap.put(payLine.Bill_com_Vendor_Credit_Line_Id__c,payLine);
                }
            }
            
        }
        
        for(AcctSeed__Cash_Disbursement__c cashDis : [SELECT Id,Name,Bill_com_BillPayment_Id__c FROM AcctSeed__Cash_Disbursement__c WHERE Bill_com_BillPayment_Id__c IN :billPaymentIds]){
          
            if(cashDis.Bill_com_BillPayment_Id__c != null){
                if(!cashDisBurseWithSendPayMap.containsKey(cashDis.Bill_com_BillPayment_Id__c)){
                    cashDisBurseWithSendPayMap.put(cashDis.Bill_com_BillPayment_Id__c,cashDis);
                }
            } 
        }
        
        //Qry bill.com id related salesforce records for lookup field mapping
        
        for(Account acc : [SELECT Id,Name,Bill_com_Vendor_Id__c,Bill_com_Vendor_2_Id__c FROM Account WHERE (Bill_com_Vendor_Id__c IN :vendorIdSet OR Bill_com_Vendor_2_Id__c IN :vendorIdSet)]){
            
            if(!vendorIdAccountRec.containsKey(acc.Bill_com_Vendor_Id__c)){
                vendorIdAccountRec.put(acc.Bill_com_Vendor_Id__c,acc);
            }
            
            if(!vendorIdAccountRec.containsKey(acc.Bill_com_Vendor_2_Id__c)){
                vendorIdAccountRec.put(acc.Bill_com_Vendor_2_Id__c,acc);
            }
        }
        
        for(AcctSeed__GL_Account__c glAccount : [SELECT Id,Name,Bill_com_Chart_Of_Account_Id__c FROM AcctSeed__GL_Account__c WHERE Bill_com_Chart_Of_Account_Id__c IN :chartOfAccId]){
            
            if(!chartOfIdGLAccountRec.containsKey(glAccount.Bill_com_Chart_Of_Account_Id__c)){
                chartOfIdGLAccountRec.put(glAccount.Bill_com_Chart_Of_Account_Id__c,glAccount);
            }    
        }
       
        for(AcctSeed__Project__c pro : [SELECT Id,Name,Bill_com_Job_Id__c,GL_Variable_2__c,GL_Variable_2__r.Name FROM AcctSeed__Project__c WHERE Bill_com_Job_Id__c IN :jobIdSet]){
            
            if(!jobIdProjectRec.containsKey(pro.Bill_com_Job_Id__c)){
                jobIdProjectRec.put(pro.Bill_com_job_Id__c,pro);
            }
        }
        
        for(AcctSeed__Project_Task__c task : [SELECT Id,Name,AcctSeed__Project__c,Bill_com_Item_Id__c FROM AcctSeed__Project_Task__c WHERE Bill_com_Item_Id__c IN :itemIdSet]){
            
            if(!itemIdProjectTaskRec.containsKey(task.Bill_com_Item_Id__c)){
                itemIdProjectTaskRec.put(task.Bill_com_Item_Id__c,task);
            }
        }
        
        for(AcctSeed__Accounting_Variable__c accVariable : [SELECT Id,Name,Bill_com_Class_Id__c FROM AcctSeed__Accounting_Variable__c WHERE Bill_com_Class_Id__c IN :classIdSet]){
            
            if(!classIdAcctVariableRec.containsKey(accVariable.Bill_com_Class_Id__c)){
                classIdAcctVariableRec.put(accVariable.Bill_com_Class_Id__c,accVariable);
            }
        }
        
        for(AcctSeed__Accounting_Period__c accPeriod : [SELECT Id,Name FROM AcctSeed__Accounting_Period__c WHERE Name IN :accPeriodNameSet]){
            
            if(!accPeriodNamwWithIdRec.containsKey(accPeriod.Name)){
                accPeriodNamwWithIdRec.put(accPeriod.Name,accPeriod.Id);
            }
        }
       
        // this for Cash disbursement Bank  and Debit GL account population
        for(AcctSeed__GL_Account__c gl : [SELECT Id,Name FROM AcctSeed__GL_Account__c WHERE Name IN ('10012 - Bill.com Pay','20001 - Accounts Payable')]){
            if(!cdRelGLAccountMap.containsKey(gl.Name)){
                cdRelGLAccountMap.put(gl.Name,gl);
            }            
        }
               
        //Bill Payment (Cash Disbursement)
        if(billPaymentRes.responseStatus == true && billPaymentRes.responseMessage == 'Success'){
            
            //BillPayment construction
            for(BillDotComUtil.SendPayRequest sentPay : billPaymentRes.responseSendPayList){
                    
                if(sentPay.status == '1' || sentPay.status == '2' || sentPay.status == '4') {   //Moved this condition from callout to here by NS
                
                    AcctSeed__Cash_Disbursement__c cash = new AcctSeed__Cash_Disbursement__c();
                    CashDisbursement cashDisBurs = new CashDisbursement();
                    
                    cash.Bill_com_BillPayment_Id__c = sentPay.id;
                    cash.AcctSeed__Disbursement_Date__c = sentPay.processDate;
                    cash.AcctSeed__Amount__c = sentPay.amount;
                    cash.AcctSeed__Reference__c = sentPay.description;
                    cash.Bill_com_Bill_Payment_Description__c = sentPay.name;
                    
                    if(sentPay.syncReference != null){
                        cash.AcctSeed__Check_Number__c = decimal.valueOf(sentPay.syncReference);
                    }
                    
                    if(cashDisbursePaymentStatusMap.containskey(sentPay.status)){
                        cash.AcctSeed__Payment_Status__c = cashDisbursePaymentStatusMap.get(sentPay.status);
                    }else{
                        cash.AcctSeed__Payment_Status__c = '';
                    }
                    
                    String accPeriod = null;
                    if(cash.AcctSeed__Disbursement_Date__c  != null){
                      accPeriod  = String.valueof(cash.AcctSeed__Disbursement_Date__c ).split('-')[0]+'-'+String.valueof(cash.AcctSeed__Disbursement_Date__c ).split('-')[1];
                    }
                    
                    if(cdRelGLAccountMap.containsKey('20001 - Accounts Payable')){
                        AcctSeed__GL_Account__c debitGL = cdRelGLAccountMap.get('20001 - Accounts Payable');
                        cash.AcctSeed__Debit_GL_Account__c = debitGL.Id;
                        cashDisBurs.debitGlAccName = debitGL.Name;
                    } 
                  
                    
                    if(accPeriodNamwWithIdRec.containsKey(accPeriod)){
                        cash.AcctSeed__Accounting_Period__c = accPeriodNamwWithIdRec.get(accPeriod);
                    }else{
                        cash.AcctSeed__Accounting_Period__c = null;
                    }
                    
                    
                    if(vendorIdAccountRec.containsKey(sentPay.vendorId)){
                        cash.AcctSeed__Vendor__c = vendorIdAccountRec.get(sentPay.vendorId).Id;
                        cashDisBurs.vendorName = vendorIdAccountRec.get(sentPay.vendorId).Name;
                    }
                    
                    cash.AcctSeed__Type__c = cashDisbursementTypeMap.containsKey(sentPay.paymentType) ? cashDisbursementTypeMap.get(sentPay.paymentType) : '';
                   
                    cash.Bill_com_BillPayment_Created_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(sentPay.createdTime));
                    cash.Bill_com_BillPayment_Updated_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(sentPay.updatedTime));
                    
                    /*if(chartOfIdGLAccountRec.containsKey(sentPay.bankAccountId)){
                        cash.AcctSeed__Bank_Account__c = chartOfIdGLAccountRec.get(sentPay.bankAccountId).Id;
                        cashDisBurs.bankGlAccName = chartOfIdGLAccountRec.get(sentPay.bankAccountId).Name;
                    }*/
                    
                    if(cdRelGLAccountMap.containsKey('10012 - Bill.com Pay')){
                        AcctSeed__GL_Account__c bankGL = cdRelGLAccountMap.get('10012 - Bill.com Pay');
                        cash.AcctSeed__Bank_Account__c = bankGL.Id;
                        cashDisBurs.bankGlAccName = bankGL.Name;
                    } 
                    

                    if(cashDisBurseWithSendPayMap.containskey(sentPay.id)){
                        cashDisBurs.isCashDisbursementExist = true;
                        
                        cashDisBurs.cashDisBurseId = cashDisBurseWithSendPayMap.get(sentPay.id).Id;
                        cashDisBurs.cashDisBurseName = cashDisBurseWithSendPayMap.get(sentPay.id).Name;
                        cash.Id =  cashDisBurs.cashDisBurseId;

                        
                        if(payRelcashDisburseExistCountMap.containsKey(sentPay.description)){
                            Integer cashDisburseCount = payRelcashDisburseExistCountMap.get(sentPay.description) + 1;
                            payRelcashDisburseExistCountMap.put(sentPay.description,cashDisburseCount);  
                            
                        }else{
                            payRelcashDisburseExistCountMap.put(sentPay.description,1);  
                        }
                        
                    }else{
                        cashDisBurs.isCashDisbursementExist = false;
                    }
                    
                    cashDisBurs.cash = cash;
                    cashDisburse.add(cashDisBurs);
                }
            }
        }
        
        // (Payable and Payable population from Bill.com and Bill.com Line)
        if(res.responseStatus == true && res.responseMessage == 'Success'){
            
            for(BillDotComUtil.BillRequest bill : res.responseBillList){
                
                PayableWithLine payRec = new PayableWithLine();
                
                AcctSeed__Account_Payable__c pay = new AcctSeed__Account_Payable__c();
                
                pay.Bill_com_AP_Id__c = bill.Id;
                pay.Bill_com_AP_Created_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(bill.createdTime));
                pay.Bill_com_AP_Updated_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(bill.updatedTime));
                
                if(bill.isActive == '1'){
                    pay.Bill_com_AP_Active_Status__c = 'Active';    
                }else {
                    pay.Bill_com_AP_Active_Status__c = 'InActive';
                }
                
                payRec.billApActiveStatus = pay.Bill_com_AP_Active_Status__c;
                pay.AcctSeed__Payee_Reference__c = bill.invoiceNumber;
                payRec.payReference = bill.invoiceNumber;
                
                if(bill.approvalStatus == '0' || bill.approvalStatus == '1'){
                    payRec.billAPApprovalStatus = 'Waiting For Approval'; 
                    pay.Bill_com_AP_Approval_Status__c = 'Waiting For Approval';
                }else{
                    pay.Bill_com_AP_Approval_Status__c = approvalStatusMap.containsKey(bill.approvalStatus) ? approvalStatusMap.get(bill.approvalStatus) : '';
                    payRec.billAPApprovalStatus = pay.Bill_com_AP_Approval_Status__c;  
                }
                
                pay.AcctSeed__Date__c = bill.invoiceDate;
                pay.AcctSeed__Due_Date__c = bill.dueDate;
                pay.Bill_com_AP_GL_Posting_Date__c = bill.glPostingDate;
                
                //pay.AcctSeed__Total__c = bill.amount;
                //pay.AcctSeed__Paid_Amount__c = bill.paidAmount;
                pay.Bill_com_AP_Payment_Scheduled_Status__c = paymentStatusMap.containsKey(bill.paymentStatus) ? paymentStatusMap.get(bill.paymentStatus) : '';
                
                
                if(vendorIdAccountRec.containsKey(bill.vendorId)){
                    pay.AcctSeed__Vendor__c = vendorIdAccountRec.get(bill.vendorId).Id;
                    payRec.vendorName = vendorIdAccountRec.get(bill.vendorId).Name;
                }
                
                if(pay.Bill_com_AP_GL_Posting_Date__c != null){
                    payRec.accountingPeriod = String.valueof(pay.Bill_com_AP_GL_Posting_Date__c).split('-')[0]+'-'+String.valueof(pay.Bill_com_AP_GL_Posting_Date__c).split('-')[1];
                }
                
                if(accPeriodNamwWithIdRec.containsKey(payRec.accountingPeriod)){
                    pay.AcctSeed__Accounting_Period__c = accPeriodNamwWithIdRec.get(payRec.accountingPeriod);
                }else{
                    pay.AcctSeed__Accounting_Period__c = null;
                }
                
                payRec.payable = pay;
                payRec.amount = bill.amount;
                
                if(pay.AcctSeed__Date__c != null){
                    payRec.dateVal = String.valueof(pay.AcctSeed__Date__c).split('-')[1]+'/'+String.valueof(pay.AcctSeed__Date__c).split('-')[2]+'/'+String.valueof(pay.AcctSeed__Date__c).split('-')[0];
                }else{
                    payRec.dateVal = null;  
                }
                
                if(pay.AcctSeed__Due_Date__c != null){
                    payRec.dueDateVal = String.valueof(pay.AcctSeed__Due_Date__c).split('-')[1]+'/'+String.valueof(pay.AcctSeed__Due_Date__c).split('-')[2]+'/'+String.valueof(pay.AcctSeed__Due_Date__c).split('-')[0];
                }else{
                    payRec.dueDateVal = null;
                }
                
                if(pay.Bill_com_AP_GL_Posting_Date__c != null){
                    payRec.glPostingDate = String.valueof(pay.Bill_com_AP_GL_Posting_Date__c).split('-')[1]+'/'+String.valueof(pay.Bill_com_AP_GL_Posting_Date__c).split('-')[2]+'/'+String.valueof(pay.Bill_com_AP_GL_Posting_Date__c).split('-')[0];
                }else{
                    payRec.glPostingDate = null;  
                }
                
                if(payableWithBillComMap.containskey(bill.Id)){
                    payRec.isPayableExist = true;
                    
                    pay.Id = payableWithBillComMap.get(bill.Id).Id;
                    payRec.payableName = payableWithBillComMap.get(bill.Id).Name;

                    if(!payRelcashDisburseCountMap.containsKey(bill.invoiceNumber)){
                        payRec.isPayableExist = true;
                    }else if(payRelcashDisburseCountMap.containsKey(bill.invoiceNumber) && (!payRelcashDisburseExistCountMap.containsKey(bill.invoiceNumber))){
                        payRec.isPayableExist = false;
                    }else if(payRelcashDisburseCountMap.containsKey(bill.invoiceNumber) && (payRelcashDisburseExistCountMap.containsKey(bill.invoiceNumber))){
                        Integer payRelcashDisburseCount = payRelcashDisburseCountMap.get(bill.invoiceNumber);
                        Integer payRelcashDisburseExistCount = payRelcashDisburseExistCountMap.get(bill.invoiceNumber);
                        
                        if(payRelcashDisburseCount == payRelcashDisburseExistCount){
                            payRec.isPayableExist = true;
                            
                        }else{
                            payRec.isPayableExist = false;
                        }
                    }
                    
                }else{
                    payRec.isPayableExist = false;  
                }
                
                if(bill.billLineItems.size() > 0){
                    
                    List<PayableLine> payableLine = new List<PayableLine>();
                    Integer payableExistCount = 0;
                    for(BillDotComUtil.BillLineItemRequest billLine : bill.billLineItems){
                        if(billLine.lineType == '2'){
                             
                            AcctSeed__Account_Payable_Line__c line = new AcctSeed__Account_Payable_Line__c();
                            PayableLine payLine = new PayableLine();
                            
                            line.Bill_com_AP_Line_Id__c = billLine.Id;
                            line.AcctSeed__Internal_Comment__c = billLine.description;
                            line.Bill_com_AP_Line_Created_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(billLine.createdTime));
                            line.Bill_com_AP_Line_Updated_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(billLine.updatedTime));
                            line.AcctSeed__Amount__c = (billLine.amount != null ? billLine.amount : 0.00);
                            line.AcctSeed__Quantity__c = (billLine.quantity  != null ? billLine.quantity : 0.00);
                            line.Amount_per_Quantity__c = (billLine.unitPrice != null ? billLine.unitPrice : 0.00);
                            line.Billable__c = billLine.jobBillable;
                            line.Period_to_Bill__c = pay.AcctSeed__Accounting_Period__c;
                            payLine.payId = billLine.billId;
                            payLine.accountingPeriod = payRec.accountingPeriod;
                            payLine.projectLookup = new List<AcctSeed__Project__c>();
                            payLine.proTaskLookup = new List<AcctSeed__Project_Task__c>();
                            
                            if(pay.Bill_com_AP_GL_Posting_Date__c != null){
                                line.Acctseed__Date__c = pay.Bill_com_AP_GL_Posting_Date__c;
                            }
                            
                            if(chartOfIdGLAccountRec.containsKey(billLine.chartOfAccountId)){
                                line.AcctSeed__Expense_GL_Account__c = chartOfIdGLAccountRec.get(billLine.chartOfAccountId).Id;
                                payLine.expenseGlAccName = chartOfIdGLAccountRec.get(billLine.chartOfAccountId).Name; 
                            }
                            
                            if(pay.Id != null){
                                line.AcctSeed__Account_Payable__c = pay.Id;
                            }

                            if(jobIdProjectRec.containsKey(billLine.jobId)){
                                line.AcctSeed__Project__c = jobIdProjectRec.get(billLine.jobId).Id;
                                payLine.projectName = jobIdProjectRec.get(billLine.jobId).Name;
                            }
                            
                            if(jobIdProjectRec.containsKey(billLine.jobId) && jobIdProjectRec.get(billLine.jobId).GL_Variable_2__c != null){
                                payLine.gl2AccountVarName = jobIdProjectRec.get(billLine.jobId).GL_Variable_2__r.Name;
                            }                                                        
                            
                            payLine.isProTaskRelatedProject = false;
                            if(itemIdProjectTaskRec.containsKey(billLine.itemId)){
                                AcctSeed__Project_Task__c proTask = itemIdProjectTaskRec.get(billLine.itemId);
                                line.AcctSeed__Project_Task__c = proTask.Id;
                                payLine.projectTaskName = proTask.Name;
                                
                                if(line.AcctSeed__Project__c == proTask.AcctSeed__Project__c){
                                    payLine.isProTaskRelatedProject = true; 
                                }
                                
                            }
                            
                            if(classIdAcctVariableRec.containsKey(billLine.actgClassId)){
                                line.AcctSeed__GL_Account_Variable_1__c = classIdAcctVariableRec.get(billLine.actgClassId).Id;
                                payLine.glAccountVarName = classIdAcctVariableRec.get(billLine.actgClassId).Name;
                            }
                            
                            if(payableLineWithBillComMap.containskey(billLine.Id)){
                                AcctSeed__Account_Payable_Line__c payableLne = payableLineWithBillComMap.get(billLine.Id);
                                
                                if(pay.Bill_com_AP_Approval_Status__c != 'Waiting For Approval'){
                                    line.Billable__c = payableLne.Billable__c;
                                    line.AcctSeed__Amount__c = (payableLne.AcctSeed__Amount__c != null ? payableLne.AcctSeed__Amount__c : 0.00);
                                    line.AcctSeed__Quantity__c = (payableLne.AcctSeed__Quantity__c  != null ? payableLne.AcctSeed__Quantity__c : 0.00);
                                    line.Amount_per_Quantity__c = (payableLne.Amount_per_Quantity__c != null ? payableLne.Amount_per_Quantity__c : 0.00);
                                }
                                payLine.payablelineId = payableLne.Id;
                                line.Id = payableLne.Id;
                                
                                if(payableLne.AcctSeed__Project__c != null){
                                    line.AcctSeed__Project__c = payableLne.AcctSeed__Project__c;
                                    payLine.projectName = payableLne.AcctSeed__Project__r.Name;
                                }
                                
                                if(payableLne.AcctSeed__Project_Task__c != null){
                                    line.AcctSeed__Project_Task__c = payableLne.AcctSeed__Project_Task__c;
                                    payLine.projectTaskName = payableLne.AcctSeed__Project_Task__r.Name;
                                    payLine.isProTaskRelatedProject = true; 
                                }
                                
                                payLine.payablelineName = payableLne.Name;
                                payLine.isPayableLineExist = true;
                                payableExistCount += 1;
                            }else{
                                payLine.isPayableLineExist = false;  
                            }
                            
                            payLine.payLine = line;
                            payableLine.add(payLine);
                        }
                    }
                    payRec.payableLine = payableLine;
                     
                    if(payableExistCount == payableLine.size() || payableLine.size() == 0){
                        payRec.isPayableWithPayableLineExist = true;
                    }else{
                        payRec.isPayableWithPayableLineExist = false;
                    }
                    
                    if(payRec.isPayableExist == true && payableExistCount == payableLine.size()){
                        payRec.isPayableExist = true;   
                    }else{
                        payRec.isPayableExist = false;   
                    }
                } 
                
                payabelList.add(payRec);
            }
        }
        
        if(vendorCreditRes.responseStatus == true && vendorCreditRes.responseMessage == 'Success'){
            
            //Vendor Credit & Vendor Credit line
            for(BillDotComUtil.VendorCreditRequest vend : vendorCreditRes.responseVendorCreditList){
                PayableWithLine payRec = new PayableWithLine();
                
                AcctSeed__Account_Payable__c pay = new AcctSeed__Account_Payable__c();
                
                pay.Bill_com_Vendor_Credit_Id__c = vend.Id;
                pay.Bill_com_AP_Created_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(vend.createdTime));
                pay.Bill_com_AP_Updated_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(vend.updatedTime));
                pay.Bill_com_AP_GL_Posting_Date__c = vend.glPostingDate;
                pay.AcctSeed__Payee_Reference__c = vend.description;
                pay.AcctSeed__Due_Date__c = vend.glPostingDate;

                 
                pay.AcctSeed__Date__c = vend.creditDate;
                
                if(pay.AcctSeed__Date__c != null){
                    payRec.dateVal = String.valueof(pay.AcctSeed__Date__c).split('-')[1]+'/'+String.valueof(pay.AcctSeed__Date__c).split('-')[2]+'/'+String.valueof(pay.AcctSeed__Date__c).split('-')[0];
                }else{
                    payRec.dateVal = null;  
                }
                
                if(vend.isActive == '1'){
                    pay.Bill_com_AP_Active_Status__c = 'Active';    
                }else {
                    pay.Bill_com_AP_Active_Status__c = 'InActive';
                } 
                
                if(pay.Bill_com_AP_GL_Posting_Date__c != null){
                    payRec.glPostingDate = String.valueof(pay.Bill_com_AP_GL_Posting_Date__c).split('-')[1]+'/'+String.valueof(pay.Bill_com_AP_GL_Posting_Date__c).split('-')[2]+'/'+String.valueof(pay.Bill_com_AP_GL_Posting_Date__c).split('-')[0];
                }else{
                    payRec.glPostingDate = null;  
                }
                
                
                if(vendorIdAccountRec.containsKey(vend.vendorId)){
                    pay.AcctSeed__Vendor__c = vendorIdAccountRec.get(vend.vendorId).Id;
                    payRec.vendorName = vendorIdAccountRec.get(vend.vendorId).Name;
                }else{
                    payRec.vendorName = null;
                }
                
                if(pay.Bill_com_AP_GL_Posting_Date__c != null){
                    payRec.accountingPeriod = String.valueof(pay.Bill_com_AP_GL_Posting_Date__c).split('-')[0]+'-'+String.valueof(pay.Bill_com_AP_GL_Posting_Date__c).split('-')[1];
                }
                
                if(pay.AcctSeed__Due_Date__c != null){
                    payRec.dueDateVal = String.valueof(pay.AcctSeed__Due_Date__c).split('-')[1]+'/'+String.valueof(pay.AcctSeed__Due_Date__c).split('-')[2]+'/'+String.valueof(pay.AcctSeed__Due_Date__c).split('-')[0];
                }else{
                    payRec.dueDateVal = null;
                }
                
                if(accPeriodNamwWithIdRec.containsKey(payRec.accountingPeriod)){
                    pay.AcctSeed__Accounting_Period__c = accPeriodNamwWithIdRec.get(payRec.accountingPeriod);
                }else{
                    pay.AcctSeed__Accounting_Period__c = null;
                }
                
                if(vend.amount != null){
                    payRec.amount = -(vend.amount);
                }

                  
                if(payableWithBillComMap.containskey(vend.Id)){
                    payRec.isPayableExist = true;
                    
                    pay.Id = payableWithBillComMap.get(vend.Id).Id;
                    payRec.payableName = payableWithBillComMap.get(vend.Id).Name;
                                        
                }else{
                    payRec.isPayableExist = false;  
                }
                
                payRec.payable = pay;
                if(vend.vendorCreditLineItems.size() > 0){
                    List<PayableLine> payableLine = new List<PayableLine>();
                    Integer payableExistCount = 0;
                    
                    for(BillDotComUtil.VendorCreditLineItemsRequest vendLine : vend.vendorCreditLineItems){
                        
                        AcctSeed__Account_Payable_Line__c line = new AcctSeed__Account_Payable_Line__c();
                        PayableLine payLine = new PayableLine();
                            
                            if(pay.Id != null){
                                line.AcctSeed__Account_Payable__c = pay.Id;
                            }
                            
                            if(vend.approvalStatus == '0' || vend.approvalStatus == '1'){
                                payRec.billAPApprovalStatus = 'Waiting For Approval'; 
                                pay.Bill_com_AP_Approval_Status__c = 'Waiting For Approval';
                            }else{
                                pay.Bill_com_AP_Approval_Status__c = approvalStatusMap.containsKey(vend.approvalStatus) ? approvalStatusMap.get(vend.approvalStatus) : '';
                                payRec.billAPApprovalStatus = pay.Bill_com_AP_Approval_Status__c;  
                            }
                        
                            pay.AcctSeed__Payee_Reference__c = vend.refNumber;
                            payRec.payReference = vend.refNumber;
                            
                            if(jobIdProjectRec.containsKey(vendLine.jobId)){
                                line.AcctSeed__Project__c = jobIdProjectRec.get(vendLine.jobId).Id;
                                payLine.projectName = jobIdProjectRec.get(vendLine.jobId).Name;
                            }
                        
                            if(jobIdProjectRec.containsKey(vendLine.jobId) && jobIdProjectRec.get(vendLine.jobId).GL_Variable_2__c != null){
                                payLine.gl2AccountVarName = jobIdProjectRec.get(vendLine.jobId).GL_Variable_2__r.Name;
                            }
                            
                            payLine.isProTaskRelatedProject = false;
                            if(itemIdProjectTaskRec.containsKey(vendLine.itemId)){
                                AcctSeed__Project_Task__c proTask = itemIdProjectTaskRec.get(vendLine.itemId);
                                line.AcctSeed__Project_Task__c = proTask.Id;
                                payLine.projectTaskName = proTask.Name;
                                
                                if(line.AcctSeed__Project__c == proTask.AcctSeed__Project__c){
                                    payLine.isProTaskRelatedProject = true; 
                                }
                                
                            }
                            
                            if(classIdAcctVariableRec.containsKey(vendLine.actgClassId)){
                                line.AcctSeed__GL_Account_Variable_1__c = classIdAcctVariableRec.get(vendLine.actgClassId).Id;
                                payLine.glAccountVarName = classIdAcctVariableRec.get(vendLine.actgClassId).Name;
                            }
                            
                            if(chartOfIdGLAccountRec.containsKey(vendline.chartOfAccountId)){
                                line.AcctSeed__Expense_GL_Account__c = chartOfIdGLAccountRec.get(vendline.chartOfAccountId).Id;
                                payLine.expenseGlAccName = chartOfIdGLAccountRec.get(vendline.chartOfAccountId).Name; 
                            }
                            
                            line.Bill_com_Vendor_Credit_Line_Id__c = vendLine.Id;
                            line.AcctSeed__Internal_Comment__c = vendLine.description;
                            line.Bill_com_AP_Line_Created_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(vendLine.createdTime));
                            line.Bill_com_AP_Line_Updated_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(vendLine.updatedTime));
                            line.AcctSeed__Amount__c = (vendLine.amount != null ? (-vendLine.amount) : 0.00);
                            line.AcctSeed__Quantity__c = (vendLine.quantity  != null ? vendLine.quantity : 0.00);
                        line.Amount_per_Quantity__c = (vendLine.unitPrice != null ? (-vendLine.unitPrice) : 0.00);
                            line.Billable__c = vendLine.jobBillable;
                            line.Period_to_Bill__c = pay.AcctSeed__Accounting_Period__c;
                            payLine.accountingPeriod = payRec.accountingPeriod;
                            payLine.projectLookup = new List<AcctSeed__Project__c>();
                            payLine.proTaskLookup = new List<AcctSeed__Project_Task__c>();

                            
                            if(pay.Bill_com_AP_GL_Posting_Date__c != null){
                                line.Acctseed__Date__c = pay.Bill_com_AP_GL_Posting_Date__c;
                            }
                            
                            if(payableLineWithBillComMap.containskey(vendLine.Id)){
                                AcctSeed__Account_Payable_Line__c payableLne = payableLineWithBillComMap.get(vendLine.Id);
                                
                                if(pay.Bill_com_AP_Approval_Status__c != 'Waiting For Approval'){
                                    line.Billable__c = payableLne.Billable__c;
                                    line.AcctSeed__Amount__c = (payableLne.AcctSeed__Amount__c != null ? payableLne.AcctSeed__Amount__c : 0.00);
                                    line.AcctSeed__Quantity__c = (payableLne.AcctSeed__Quantity__c  != null ? payableLne.AcctSeed__Quantity__c : 0.00);
                                    line.Amount_per_Quantity__c = (payableLne.Amount_per_Quantity__c != null ? payableLne.Amount_per_Quantity__c : 0.00);
                                }
                               
                                if(payableLne.AcctSeed__Project__c != null){
                                    line.AcctSeed__Project__c = payableLne.AcctSeed__Project__c;
                                    payLine.projectName = payableLne.AcctSeed__Project__r.Name;
                                }
                                
                                if(payableLne.AcctSeed__Project_Task__c != null){
                                    line.AcctSeed__Project_Task__c = payableLne.AcctSeed__Project_Task__c;
                                    payLine.projectTaskName = payableLne.AcctSeed__Project_Task__r.Name;
                                    payLine.isProTaskRelatedProject = true; 
                                }
                                
                                payLine.payablelineId = payableLne.Id;
                                line.Id = payableLne.Id;
                                payLine.payablelineName = payableLne.Name;
                                payLine.isPayableLineExist = true;
                                payableExistCount += 1;
                            }else{
                                payLine.isPayableLineExist = false;  
                            }
                            payLine.payLine = line;
                            payableLine.add(payLine); 
                    }
                    payRec.payableLine = payableLine;
                    
                    if(payableExistCount == payableLine.size() || payableLine.size() == 0){
                        payRec.isPayableWithPayableLineExist = true;
                    }else{
                        payRec.isPayableWithPayableLineExist = false;
                    }
                    
                    if(payRec.isPayableExist == true && payableExistCount == payableLine.size()){
                        payRec.isPayableExist = true;   
                    }else{
                        payRec.isPayableExist = false;   
                    } 
                }
                payabelList.add(payRec);
            }
            
        }
        billPay.pay = payabelList;
        billPay.cashDisbursements = cashDisburse;
        
        return billPay;
    }
    @AuraEnabled
    public static String payableCreationRec(String payableJSON,String payableLineJSON,String cashDisbursementJSON){
      try{
            AcctSeed__Account_Payable__c payable = (AcctSeed__Account_Payable__c) JSON.deserialize(payableJSON, AcctSeed__Account_Payable__c.class);
            List<AcctSeed__Account_Payable_Line__c> payableLineList = (List<AcctSeed__Account_Payable_Line__c>) JSON.deserialize(payableLineJSON, List<AcctSeed__Account_Payable_Line__c>.class);
            List<AcctSeed__Cash_Disbursement__c> cashDisbursementList = (List<AcctSeed__Cash_Disbursement__c>) JSON.deserialize(cashDisbursementJSON, List<AcctSeed__Cash_Disbursement__c>.class);
           
           upsert payable /*Bill_com_AP_Id__c*/;
           
           system.debug('payableList'+payableLineList);
           system.debug('payableLineJSON'+payableLineJSON);
           
           if(payable.Id != null){
               
               if(payableLineList.size() > 0){
                   for(AcctSeed__Account_Payable_Line__c payLine : payableLineList){
                       if(payLine.AcctSeed__Account_Payable__c == null){
                           payLine.AcctSeed__Account_Payable__c = payable.Id;
                       }
                   }
                   upsert payableLineList /*Bill_com_AP_Line_Id__c*/;
               }
               
               if(cashDisbursementList.size() > 0){
                   String cashDisBatchName = cashDisbursementList[0].Bill_com_Bill_Payment_Description__c;
                   if(String.isNotBlank(cashDisBatchName)){
                       Boolean isCreateCDBatch = true;
                       List<AcctSeed__Cash_Disbursement_Batch__c> cdBatch = new List<AcctSeed__Cash_Disbursement_Batch__c>();
                       
                       if(String.isNotBlank(cashDisbursementList[0].Id)){
                           cdBatch = [SELECT Id FROM AcctSeed__Cash_Disbursement_Batch__c WHERE name = :cashDisBatchName]; 
                           if(cdBatch.size() > 0){
                               isCreateCDBatch = false;  
                           }
                       }
                       
                       if(isCreateCDBatch == true){
                           AcctSeed__Cash_Disbursement_Batch__c cashDisBatch = new AcctSeed__Cash_Disbursement_Batch__c(Name = cashDisBatchName);
                           insert cashDisBatch;
                           cdBatch.add(cashDisBatch);
                       }
                       
                       if(cdBatch.size() > 0 && cdBatch[0].Id != null){
                           for(AcctSeed__Cash_Disbursement__c cash : cashDisbursementList){
                               cash.AcctSeed__Cash_Disbursement_Batch__c = cdBatch[0].Id;
                               cash.AcctSeed__Status__c = 'In Process';
                           }
                           upsert cashDisbursementList Bill_com_BillPayment_Id__c;  
                           
                           // Call the post service
                           AcctSeed.PostResult[] postResult =  AcctSeed.CashDisbursementPostService.postCashDisbursements(cashDisbursementList);
                           
                           
                           List<AcctSeed__Account_Payable__c> payables = [SELECT Id,Bill_com_AP_Approval_Status__c FROM AcctSeed__Account_Payable__c WHERE Id = :payable.Id AND Bill_com_AP_Approval_Status__c = 'Approved'];
 
                           if(payables.size() > 0){
                               List<AcctSeed__AP_Disbursement__c> existingApDisbursements = [SELECT Id FROM AcctSeed__AP_Disbursement__c WHERE AcctSeed__Cash_Disbursement__c = :cashDisbursementList[0].Id AND AcctSeed__Account_Payable__c = :payable.Id];
                               
                               if(existingApDisbursements.size() == 0){
                                   // Call the post service
                                   AcctSeed.PostResult[] postResults = AcctSeed.AccountPayablePostService.postAccountPayables(payables);
                                   
                                   // AP DisBursement Creation 
                                   AcctSeed__AP_Disbursement__c apDisbursements = new AcctSeed__AP_Disbursement__c();
                                   
                                   if(String.isNotBlank(cashDisbursementList[0].AcctSeed__Accounting_Period__c)){
                                       apDisbursements.AcctSeed__Accounting_Period__c = cashDisbursementList[0].AcctSeed__Accounting_Period__c;
                                   }
                                   apDisbursements.AcctSeed__Cash_Disbursement__c = cashDisbursementList[0].Id;
                                   apDisbursements.AcctSeed__Account_Payable__c = payable.Id;
                                   if(cashDisbursementList[0].AcctSeed__Amount__c != null){
                                       apDisbursements.AcctSeed__Paid_Amount__c = cashDisbursementList[0].AcctSeed__Amount__c;
                                   }
                                   insert apDisbursements; 
                               }
                           }
                       }
                   }
               }
           }
           return payable.Id;
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    } 
    
    public class PayableWithLine {
        @AuraEnabled
        public AcctSeed__Account_Payable__c payable;
        @AuraEnabled
        public Decimal amount;
        @AuraEnabled
        public String dateVal;
        @AuraEnabled
        public String dueDateVal;
        @AuraEnabled
        public String glPostingDate;
        @AuraEnabled
        public String accountingPeriod;
        @AuraEnabled
        public String vendorName;
        @AuraEnabled
        public List<PayableLine> payableLine;
        @AuraEnabled
        public Boolean isPayableExist;
        @AuraEnabled
        public Boolean isPayableWithPayableLineExist;
        @AuraEnabled
        public String payableName;
        @AuraEnabled
        public String payReference;
        @AuraEnabled
        public String billAPApprovalStatus;
        @AuraEnabled
        public String billApActiveStatus;
    }
    
    public class BillANDBillPayment {
        
        @AuraEnabled
        public List<PayableWithLine> pay;
        @AuraEnabled
        public List<CashDisbursement> cashDisbursements;
    }
    
    public class PayableLine {
        
        @AuraEnabled
        public AcctSeed__Account_Payable_Line__c payLine;
        @AuraEnabled
        public String gl2AccountVarName;
        @AuraEnabled
        public String glAccountVarName;
        @AuraEnabled
        public String projectName;
        @AuraEnabled
        public Boolean isProTaskRelatedProject;
        @AuraEnabled
        public String projectTaskName;
        @AuraEnabled
        public String expenseGlAccName;
        @AuraEnabled
        public String payId;
        @AuraEnabled
        public String accountingPeriod;
        @AuraEnabled
        public Boolean isPayableLineExist;
        @AuraEnabled
        public String payableLineId;
        @AuraEnabled
        public String payableLineName;
        @AuraEnabled
        public List<AcctSeed__Project__c> projectLookup;
        @AuraEnabled
        public List<AcctSeed__Project_Task__c> proTaskLookup;
    }
    
    public class  CashDisbursement {
        
        @AuraEnabled
        public AcctSeed__Cash_Disbursement__c cash;
        @AuraEnabled
        public String bankGlAccName;
        @AuraEnabled
        public String vendorName;
        @AuraEnabled
        public String debitGlAccName;
        @AuraEnabled
        public Boolean isCashDisbursementExist;
        @AuraEnabled
        public String cashDisburseId;
        @AuraEnabled
        public String cashDisburseName;
    }
}