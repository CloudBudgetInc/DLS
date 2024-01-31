trigger RHX_Contact_Assignments on Contact_Assignments__c
    (after delete, after insert, after undelete, after update, before delete) {
     Type rollClass = System.Type.forName('rh2', 'ParentUtil');
     if(rollClass != null) {
        Map<Id,Contact_Assignments__c> oldMap = new Map<Id,Contact_Assignments__c>();
        Map<Id,Contact_Assignments__c> newMap = new Map<Id,Contact_Assignments__c>();
        rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
        // Added to avoid recursive error while sending getFeedBack Form
        //if (trigger.isAfter && !trigger.isdelete) {
        if (trigger.isAfter) {
            //Set<Id> contactIdSet = sendFeedbackFormHelper.contactIdSet;
            //System.debug('contactIdSet::::'+contactIdSet);
            //for (Contact_Assignments__c ca : trigger.new) {
            //    if(!contactIdSet.Contains(ca.Id) ) {
            //        if(trigger.oldMap != null && trigger.oldMap.containskey(ca.Id)) { 
            //            oldMap.put(ca.Id,trigger.oldMap.get(ca.Id)); 
            //        }
            //        newMap.put(ca.Id,ca);
            //    }
            //}
            //System.debug('oldMap::::'+oldMap);
            //System.debug('newMap::::'+newMap);
            pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'Contact_Assignments__c'}, null);
            //if( oldMap.size() > 0 && newMap.size() > 0 ) {
            //    pu.performTriggerRollups(oldMap, newMap, new String[]{'Contact_Assignments__c'}, null);
            //}
        }
    }
}