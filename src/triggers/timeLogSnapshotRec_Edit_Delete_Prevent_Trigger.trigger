trigger timeLogSnapshotRec_Edit_Delete_Prevent_Trigger on Time_Log_Snapshot__c (before update,before delete) {
    
    if(Trigger.isUpdate || Trigger.isDelete) {
        if(Trigger.isUpdate) {
            for(Time_Log_Snapshot__c logComt : trigger.new) {
                logComt.addError('You can\'t update Time Log Snapshot Record');
            }
        }
        
        if(Trigger.isDelete) {
           for(Time_Log_Snapshot__c logComt : trigger.Old) {
                logComt.addError('You can\'t delete Time Log Snapshot Record');
            } 
        }    
    }
}