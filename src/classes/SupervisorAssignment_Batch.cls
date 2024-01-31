global class SupervisorAssignment_Batch implements Database.Batchable<sObject> {
   
    global String Query;   
    global final String q = 'SELECT Id, Section__c, Classification__c FROM Opportunity WHERE Classification__c != NULL';

    global SupervisorAssignment_Batch (){
        Query = q;  
        system.debug('Query:::::::::::'+Query);           
    }

  
    global Database.QueryLocator start(Database.BatchableContext BC){      
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> oppList){    
        
        Map<String, String> supervisorAssMap = new Map<String, String>();
        for (Supervisor_Assignment_CS__c ass: [ SELECT Id, Classification__c, Section__c, Supervisor__c 
            FROM Supervisor_Assignment_CS__c]) {
            
            String clsSection = (ass.Classification__c != NULL) ? ass.Classification__c : '';
            clsSection += (ass.Section__c != NULL) ? ass.Section__c : '';
            supervisorAssMap.put(clsSection, ass.Supervisor__c);
        }
        
        try {
            for (Opportunity opp : oppList){
                if (opp.Classification__c != NULL || opp.Section__c != NULL) {
                    String clsSection = (opp.Classification__c != NULL) ? opp.Classification__c : '';
                    clsSection += (opp.Section__c != NULL) ? opp.Section__c : '';
                    system.debug('::clsSection::::'+clsSection);
                    if (supervisorAssMap.containsKey(clsSection)){
                        opp.Supervisor__c = supervisorAssMap.get(clsSection);
                    } else if (opp.Classification__c != NULL && supervisorAssMap.containsKey(opp.Classification__c)) {
                        opp.Supervisor__c = supervisorAssMap.get(opp.Classification__c);
                    }              
                }
            }
            update oppList;
        } Catch (Exception e) {
            system.debug('::Error::'+e);
        }
    }

    global void finish(Database.BatchableContext BC){

    }
}