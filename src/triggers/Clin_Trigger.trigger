/*
* Developed by Vinitha on May 15, 2017
* Send Email Alert When the CLIN record is edited.
*/
trigger Clin_Trigger on CLIN__c (after update,before insert, before update) {
    
    if(trigger.isBefore) {
        if(trigger.isUpdate){
            CLINTrigger_Handler.validateChildClinsName(trigger.new, Trigger.oldMap);
        }
        if(trigger.isInsert){
            CLINTrigger_Handler.updateCLIN_Name(Trigger.new);
            CLINTrigger_Handler.validateChildClinsName(trigger.new, NULL);
        }
    }
    if(trigger.isAfter && trigger.isUpdate) {
        SendEmailsForUpdatedFields_Handler se = new SendEmailsForUpdatedFields_Handler();
        try {
            se.sendEmail('CLIN__c',trigger.new,trigger.oldMap,'Contract Modified Notify Users');
        } catch(Exception e) {
            system.debug('::err::');
        }
        CLINTrigger_Handler.updateChildClins(Trigger.new, Trigger.oldMap); // Added by Shalini to update Child Contract CLINs with Parent Contract CLIN for Delivery Order Contract
    } 
}