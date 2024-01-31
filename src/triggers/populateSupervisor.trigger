trigger populateSupervisor on Opportunity (before insert, before update) {
    
    Set<String> classificationSet = new Set<String>();
    Set<String> sectionSet = new set<String>();
    List<Opportunity> oppList = new List<Opportunity>();
    Map<String, String> supervisorAssMap = new Map<String, String>();
    
    for (Opportunity opp: Trigger.New) {
        
        if (Trigger.IsInsert || (Trigger.IsUpdate && (Trigger.oldMap.get(opp.Id).Classification__c != opp.Classification__c  
            || Trigger.oldMap.get(opp.Id).Section__c != opp.Section__c))) {
            
            if (opp.Classification__c != NULL) {
                classificationSet.add(opp.Classification__c);
            }
            
            if (opp.Section__c != NULL) {
                sectionSet.add(opp.Section__c);
            }
        
        }
        
       /* if (Trigger.IsUpdate && Trigger.oldMap.get(opp.Id).Classification__c == opp.Classification__c  
            && Trigger.oldMap.get(opp.Id).Section__c == opp.Section__c && opp.Supervisor__c == NULL) {
            opp.Supervisor__c.addError('Please select the Supervisor');
        }
        */
        oppList.add(opp);
        
    }
    
    if (classificationSet.size() > 0 || sectionSet.size() > 0) {
        
      
        for (Supervisor_Assignment_CS__c ass: [ SELECT Id, Classification__c, Section__c, Supervisor__c 
            FROM Supervisor_Assignment_CS__c 
            WHERE (Classification__c IN: classificationSet OR Section__c IN: sectionSet) AND Supervisor__c != NULL]) {
            
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
                    } else {
                        opp.Supervisor__c = NULL;
                    }
                } else {
                        opp.Supervisor__c = NULL;
                }
                
                system.debug('::opp.Supervisor__c::'+opp.Supervisor__c);
                
               /* if (opp.Supervisor__c == NULL) {
                    opp.Supervisor__c.addError('Please select the Supervisor');
                }*/
            }
        } Catch (Exception e) {
            system.debug('::Error::'+e);
        }
    }
    
}