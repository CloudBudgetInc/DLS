trigger AccountingVariableTrigger on AcctSeed__Accounting_Variable__c (before update) {

    //To update the Bill.com Sync Status - if the Accounting Variable is updated after bill.com sync update need to set status as Pending
    if(Trigger.isBefore && Trigger.isUpdate){
    
        for(AcctSeed__Accounting_Variable__c accVar : Trigger.new){
        
            if(!BillDotComUtil.updateFromBillDotComSync){
            
                accVar.Bill_com_Sync_Status__c = 'Pending';
            }    
        }
    }
}