/*
* This trigger creates OpportunityContactRoles for every Student Assignment's "Student Name"
* with role as "Student", if and only if already an OCR doesn't exist 
* with this opportunity id and student name combination.
*/

trigger createOppContRolesForStudents on Student_Assignment__c (after insert, after update) {


    Set<Id> oppIdSet = new Set<Id>();
    
    for (Student_Assignment__c sa : trigger.new) {
    
        if (sa.Class_Name__c != null && sa.Student_Name__c != null && (Trigger.isInsert || Trigger.oldMap.get(sa.Id).Student_Name__c != sa.Student_Name__c) ) {
            
            oppIdSet.add(sa.Class_Name__c);
        }
    
    } // end for trigger.new
    
    System.debug('oppIdSet : ' + oppIdSet);
    
    if (oppIdSet != null && oppIdSet.size() > 0) {
    
        createContactRoles_Util.createContactRoles(oppIdSet, false);    
    }
}