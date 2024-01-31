/*** Qualification_TriggerHandler Created on 7th FEB 2017 By Mohan Raj S ***/

/****   This Qualification_TriggerHandler is to be changed the Name field in the "Qualification__c" Custom Object *****/
/****   in their another fields of Condition__c, Value__c, Type__c in the following format: Name = Type__c + Condition__c + Value__c   *****/

public class Qualification_TriggerHandler {

    public static void insertTrigger (List<Qualification__c> qualificationNewList) {
    
        System.debug('<<<<<<<<<<<Insert Method is started>>>>>>>>>>');
        
        for (Qualification__c qualificationRecord : qualificationNewList) {
        
            qualificationRecord.Name = qualificationRecord.Type__c +' '+ qualificationRecord.Condition__c +' '+qualificationRecord.Value__c;
            system.debug('qualificationRecord value is>>>>>>>>'+qualificationRecord);
        }
    }
    
    public static void updateTrigger (List<Qualification__c> qualificationNewList, Map<Id, Qualification__c> qualificationOldMap) {
        System.debug('<<<<<<<<<<<<<<<<<<<Update Method is started>>>>>>>>>>>>>>>>>>>>>>>>');
                
        for (Qualification__c qualificationRecord : qualificationNewList) {
        
            Qualification__c oldQualificationRecord = qualificationOldMap.get(qualificationRecord.Id);
            
            if (oldQualificationRecord.Id == qualificationRecord.Id && 
                    ( (oldQualificationRecord.Condition__c != qualificationRecord.Condition__c) || (oldQualificationRecord.Type__c != qualificationRecord.Type__c) || (oldQualificationRecord.Value__c != qualificationRecord.Value__c) )) {
                    
                    qualificationRecord.Name = qualificationRecord.Type__c +' '+ qualificationRecord.Condition__c +' '+ qualificationRecord.Value__c;
            }        
        }
    }
}