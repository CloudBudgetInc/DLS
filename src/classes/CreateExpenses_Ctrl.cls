public class CreateExpenses_Ctrl {
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    }
    
    @AuraEnabled
    public static String exportReport(String startDate, String endDate){
        return ExpensifyUtil.createReport(startDate, endDate);
    }
    
    @AuraEnabled
    public static String getPayableLineByTransactionId(List<String> expensifyTransactionIds){
        Set<String> availableTransIds = new Set<String>();
        for(AcctSeed__Account_Payable_Line__c payLine : [SELECT Id, Expensify_Transaction_Id__c FROM AcctSeed__Account_Payable_Line__c WHERE Expensify_Transaction_Id__c IN :expensifyTransactionIds]){
            availableTransIds.add(payLine.Expensify_Transaction_Id__c);
        }
        return JSON.serialize(availableTransIds);
    }
    
    @AuraEnabled
    public static String getExpensifyCreditCard(){
        Map<String, String> creditNameIdAndEmailStrWithVendorNameMap = new Map<String, String>();
        for(Expensify_Credit_Card__c expensifyCreditCard : [SELECT Id, Card_ID__c, Card_Name__c, Card_Number__c, Contact__c, Email__c, Vendor__c, Vendor__r.Name FROM Expensify_Credit_Card__c]){
            creditNameIdAndEmailStrWithVendorNameMap.put(expensifyCreditCard.Card_ID__c+'~'+expensifyCreditCard.Email__c, expensifyCreditCard.Vendor__r.Name);
        }   
        return JSON.serialize(creditNameIdAndEmailStrWithVendorNameMap);
    }
    
    @AuraEnabled
    public static String createPayableAndPayableLines(String payableRec, String payableLineRec){
        
        Map<String, String> result = new Map<String, String>{'result'=> 'success'};
        try{
            ExpensifyDomain.payableWrap payableWrapObj = (ExpensifyDomain.payableWrap) JSON.deserialize(payableRec, ExpensifyDomain.payableWrap.class);
            List<ExpensifyDomain.payableLineWrap> payableLineWrapObj = (List<ExpensifyDomain.payableLineWrap>) JSON.deserialize(payableLineRec, List<ExpensifyDomain.payableLineWrap>.class);
            
            Map<String, Id> accountVariableNameWithId = new Map<String, Id>();
            Map<String, Id> glAccountNameWithId = new Map<String, Id>();
            
            for(ExpensifyDomain.payableLineWrap payableLineObj : payableLineWrapObj){
                glAccountNamewithId.put(payableLineObj.Expense_GL_Account, null);
                accountVariableNameWithId.put(payableLineObj.GL_Account_Variable_1, null);
            }
            
            for(AcctSeed__GL_Account__c glAcc : [SELECT Id, Name FROM AcctSeed__GL_Account__c WHERE Name IN :glAccountNamewithId.keySet()]){
                glAccountNamewithId.put(glAcc.Name, glAcc.Id);
            }
            
            for(AcctSeed__Accounting_Variable__c accVar : [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c WHERE Name IN :accountVariableNameWithId.keySet()]){
                accountVariableNameWithId.put(accVar.Name, accVar.Id);
            }
            
            AcctSeed__Account_Payable__c payable;
            
            if(payableWrapObj.Id == null){
                payable = new AcctSeed__Account_Payable__c(
                    AcctSeed__Accounting_Period__c = payableWrapObj.accountingPeriod.size() > 0 ? payableWrapObj.accountingPeriod[0].Id : null,
                    AcctSeed__Vendor__c = payableWrapObj.vendor.size() > 0 ? payableWrapObj.vendor[0].Id : null,
                    AcctSeed__Date__c = Date.valueOf(payableWrapObj.dateVal),
                    AcctSeed__Due_Date__c = Date.valueOf(payableWrapObj.dueDate),
                    AcctSeed__Payee_Reference__c = payableWrapObj.payeeReference,
                    AcctSeed__Status__c = 'In Process'
                );
                
                insert payable;
            }else{
                payable = new AcctSeed__Account_Payable__c(Id = payableWrapObj.Id);
            }
            
            List<AcctSeed__Account_Payable_Line__c> payableLines = new List<AcctSeed__Account_Payable_Line__c>();
            for(ExpensifyDomain.payableLineWrap payableLineObj : payableLineWrapObj){
                payableLines.add(new AcctSeed__Account_Payable_Line__c(
                    AcctSeed__Account_Payable__c = payable.Id,
                    AcctSeed__Invoice_Comment__c = payableLineObj.invoiceComment,
                    AcctSeed__Date__c = Date.valueOf(payableLineObj.postdate),
                    AcctSeed__Amount__c = payableLineObj.Total,
                    AcctSeed__Expense_GL_Account__c = glAccountNamewithId.get(payableLineObj.Expense_GL_Account),
                    AcctSeed__GL_Account_Variable_1__c = accountVariableNameWithId.get(payableLineObj.GL_Account_Variable_1),
                    Reference_Number__c = payableLineObj.referenceNo,
                    AcctSeed__Internal_Comment__c = payableLineObj.Internal_Comment,
                    Expensify_Transaction_Id__c = payableLineObj.transactionId,
                    AcctSeed__Project__c = payableLineObj.projectLookup != null && payableLineObj.projectLookup.size() > 0 ? payableLineObj.projectLookup[0].Id : null,
                    AcctSeed__Project_Task__c = payableLineObj.proTaskLookup != null && payableLineObj.proTaskLookup.size() > 0 ? payableLineObj.proTaskLookup[0].Id : null,
                    Amount_per_Quantity__c =  payableLineObj.Total,
                    AcctSeed__Quantity__c = 1 //Added by Dhinesh - 17/11/2023 - W-007928
                ));         
            }
            insert payableLines;
            
            result.put('payableId', payable.Id);        
        }catch(Exception exe){
            
            result.put('result', exe.getMessage());
        }
        
        return JSON.serialize(result);
    }
    
}