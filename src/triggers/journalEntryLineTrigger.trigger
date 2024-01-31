trigger journalEntryLineTrigger on AcctSeed__Journal_Entry_Line__c (before insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        journalEntryLineTriggerHandler.populateGLAV2Field(Trigger.new);
    }
}