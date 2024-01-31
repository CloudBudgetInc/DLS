trigger Qualification_Trigger on Qualification__c (before insert, before update) {
    
    if (Trigger.IsInsert && Trigger.IsBefore) {
        
        Qualification_TriggerHandler.insertTrigger(Trigger.New);
    }
    if (Trigger.IsUpdate && Trigger.IsBefore) {
    
        Qualification_TriggerHandler.updateTrigger(Trigger.New, Trigger.OldMap);
    }  
}