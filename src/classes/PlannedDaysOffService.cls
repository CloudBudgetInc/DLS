/**********************************************************************
    Created by Sukanya on Jan 5 2017: Service class used for Planned_Days_Off__c object      
***********************************************************************/
public without sharing class PlannedDaysOffService {
     
      /**********************************************************************
        Created by Sukanya on Jan 5 2017: This method return list of PlannedDaysOff
        @filterQry - Pass where conditions
        @contactIdSet - set of Contact records Ids
        @dateSet - Set of Contact dates
        return - list of PlannedDaysOff records
    ***********************************************************************/
     public static list<Planned_Days_Off__c> getPlanneddaysBycontact(String filterQry,Set<Id> contactIdSet,Set<Date> dateSet,String ordercondition,Boolean applyfiltercond,String parentField) {
         
        system.debug('::filterQry:'+filterQry);
        system.debug('::contactIdSet:::'+contactIdSet);
        system.debug('::dateSet::'+dateSet);
        system.debug(':::::::ordercondition'+ordercondition);
     
        list<Planned_Days_Off__c> plannedDays = new list<Planned_Days_Off__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Planned_Days_Off__c');
        String defaultQry = 'SELECT '+fieldName;
         if(parentField != null){
             defaultQry = defaultQry+parentField;
         }
               defaultQry = defaultQry+' FROM'
                                +' Planned_Days_Off__c';
        if(filterQry != null && filterQry != '' && applyfiltercond == true){
            defaultQry +=  filterQry;   
        }                        
        
        if(contactIdSet != null && contactIdSet.size() > 0 && ordercondition != null && ordercondition != '' && !applyfiltercond){
            defaultQry=  defaultQry +' WHERE Contact__c IN :contactIdSet'+ ordercondition;   
        }else if(contactIdSet != null && contactIdSet.size() > 0 && !applyfiltercond){            
            defaultQry=  defaultQry +' WHERE Contact__c IN :contactIdSet';
        }else if (dateSet != null && dateSet.size() > 0 && !applyfiltercond){
            defaultQry= defaultQry +' WHERE Date__c IN :dateSet';
        }       
        system.debug('::defaultQry:'+defaultQry);
        plannedDays = Database.query(defaultQry);
        return plannedDays;
     }
     
     /**********************************************************************
        Created by Sukanya on Jan 5 2017: This method return list of PlannedDaysOff
        @contactIdSet - set of Contact records Ids
        @dateSet - Set of Contact dates
        return - list of PlannedDaysOff records
    ***********************************************************************/
     
     public static list<Planned_Days_Off__c> getPlanneddaysByconDates(Set<Id> contactIdSet,Set<Date> dateSet) {
         
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Planned_Days_Off__c');
         
        list<Planned_Days_Off__c> plannedDays = Database.query('SELECT '+fieldName
                                                +' FROM'
                                                +' Planned_Days_Off__c'
                                                +' WHERE'
                                                +' Contact__c IN : contactIdSet'
                                                +' AND '
                                                +' Date__c IN :dateSet');                          
        return plannedDays;
     }
     
     /**********************************************************************
        Created by Sukanya on Jan 5 2017: This method return list of PlannedDaysOff
        @studentContactidSet - set of Student Contact records Ids
        @instructorConactidSet - Set of Instructor Contact records Ids
        @dateSet - Set of Contact dates
        return - list of PlannedDaysOff records
    ***********************************************************************/
     
     public static list<Planned_Days_Off__c> getPlanneddaysByconDates(Set<Id> studentContactidSet,Set<Id> instructorConactidSet,Set<Date> dateSet) {
         
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Planned_Days_Off__c');
         
        list<Planned_Days_Off__c> plannedDays = Database.query('SELECT '+fieldName
                                                +' FROM'
                                                +' Planned_Days_Off__c'
                                                +' WHERE'
                                                +' (Contact__c IN :studentContactidSet'
                                                +' OR '
                                                +' Contact__c IN :instructorConactidSet)'
                                                +' AND'
                                                +' Date__c IN : dateSet'
                                                +' ORDER BY'
                                                +' Date__c ASC');  
        return plannedDays;
     }    
        
     /**********************************************************************
        Created by Arun on Jan 18, 2017: To Delete the given List  
        @plannedDaysList - List of Planned Days.
        Returns - List of Updated Planned Days.   
    ***********************************************************************/
     
     public static List<Planned_Days_Off__c> deletePlanneddaysOff(List<Planned_Days_Off__c> plannedDaysList) {
         
         if(plannedDaysList.size() > 0)
             delete plannedDaysList;
         
         return plannedDaysList;
     }
     
     /**********************************************************************
        Created by Arun on Jan 18, 2017: To insert the given List  
        @plannedDaysList - List of Planned Days.
        Returns - List of inserted Planned Days.   
    ***********************************************************************/

    public Static List<Planned_Days_Off__c> insertPlanneddaysOff(List<Planned_Days_Off__c> plannedDaysList) {
        
        if(plannedDaysList != null && plannedDaysList.size() > 0) {            
            Insert plannedDaysList;            
        }
        
        return plannedDaysList;
    }
    
    /**********************************************************************
        Created by Arun on Jan 18, 2017: To Update the given List  
        @plannedDaysList - List of Planned Days.
        Returns - List of Updated Planned Days.   
    ***********************************************************************/

    public Static List<Planned_Days_Off__c> updatePlanneddaysOff(List<Planned_Days_Off__c> plannedDaysList) {
        
        if(plannedDaysList != null && plannedDaysList.size() > 0) {
            
            Update plannedDaysList;
        }
        
        return plannedDaysList;
    }
}