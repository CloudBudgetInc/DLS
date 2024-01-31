trigger timeSnapshot_Edit_Delete_Prevent_Trigger on Accounting_Seed_Time_Snapshot__c (before insert,before update,before delete) {
    
    if(Trigger.isBefore) {
        if(Trigger.isUpdate) {
            for(Accounting_Seed_Time_Snapshot__c timeSnap : trigger.new) {
                timeSnap.addError('You can\'t update Time Snapshot Record');
            }
        }
        
        if(Trigger.isDelete) {
           for(Accounting_Seed_Time_Snapshot__c timeSnap : trigger.Old) {
                //timeSnap.addError('You can\'t delete Time Snapshot Record');
            } 
        }    
    }
}