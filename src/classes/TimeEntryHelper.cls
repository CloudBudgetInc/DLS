public class TimeEntryHelper {
    public static Map<Id, Set<Date>> getApprovedPDOsByProjectIds( Map<Id, Set<Id>> conIdsWithProjectIds, Set<Date> dateSet, Set<Id> projectIds){
        Map<Id,Set<Date>> pdosByProjectId = new Map<Id,Set<Date>>();
        Set<Id> contactIds = conIdsWithProjectIds.keySet();
        
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Planned_Days_Off__c');
         Date dat = System.today().addDays(-30);
       for(Planned_Days_Off__c pdo : Database.query('SELECT '+fieldName
                                                +' FROM Planned_Days_Off__c'
                                                +' WHERE Contact__c IN :contactIds'
                                                +' AND Date__c <= TODAY AND Date__c >= :dat'
                                                +' AND Status__c = \'Approved\''
                                                +' AND (All_Projects__c = true OR Project__c IN :projectIds)'
                                                +' ORDER BY Date__c ASC')){
            
            Set<Id> projIds = new Set<Id>();
                                                    
            if(pdo.All_Projects__c){
                projIds.addAll(conIdsWithProjectIds.get(pdo.Contact__c));                      
            }else{
                projIds.add(pdo.Project__c);
            }
                                                    
            for(Id projId : projIds){                                        
                if(!pdosByProjectId.containsKey(projId))                                        
                    pdosByProjectId.put(projId, new Set<Date>());
                pdosByProjectId.get(projId).add(pdo.Date__c);
            }
        }                        
        
        return pdosByProjectId;
    }
}