trigger GLAccountTrigger on AcctSeed__GL_Account__c (before update) {

    //To update the Bill.com Sync Status - if the GL Account is updated after bill.com sync update need to set status as Pending
    if(Trigger.isBefore && Trigger.isUpdate){
    
        for(AcctSeed__GL_Account__c glAcc : Trigger.new){
        
            if(!BillDotComUtil.updateFromBillDotComSync){
            
                glAcc.Bill_com_Sync_Status__c = 'Pending';
            }    
        }
    }
}