trigger ContactAffiliationTrigger on Contact_Affiliation__c (after insert, after update, after delete) {

    if(Trigger.isAfter){
    
        if(Trigger.isInsert){
            
            List<Contact_Affiliation__c> updateConAffRecs = new List<Contact_Affiliation__c>();
            Set<String> newConIdAccId = new Set<String>();
            Set<String> oldConIdAccId = new Set<String>();
            
            Set<Id> accIds = new Set<Id>();
            Set<Id> conIds = new Set<Id>();
            Set<Id> contAffIds = new Set<Id>();
            Set<String> conIdAccId = new Set<String>();
            
            for(Contact_Affiliation__c ca : trigger.new){
            
                if(ca.Account__c != NULL && ca.Contact__c != NULL){
                
                    String s = ca.Contact__c+''+ca.Account__c;
                    
                    newConIdAccId.add(s);
                    accIds.add(ca.Account__c);
                    conIds.add(ca.Contact__c);
                    contAffIds.add(ca.Id);
                }
            }
            System.debug('::::newConIdAccId::'+newConIdAccId);
            System.debug('::::accIds::'+accIds);
            System.debug('::::conIds::'+conIds);
            System.debug('::::contAffIds::'+contAffIds);
            
            for(Contact_Affiliation__c c : [SELECT Id, Account__c, Contact__c
                FROM Contact_Affiliation__c 
                WHERE Id NOT IN : contAffIds AND Account__c IN : accIds AND Contact__c IN : conIds]){
            
                if(c.Account__c != NULL && c.Contact__c != NULL){
                
                    String s = c.Contact__c+''+c.Account__c;
                    
                    oldConIdAccId.add(s);
                } 
            }
            System.debug('::::oldConIdAccId::'+oldConIdAccId);
            
            for(Contact_Affiliation__c ca : trigger.new){
            
                if(ca.Account__c != NULL && ca.Contact__c != NULL){
                
                    String s = ca.Contact__c+''+ca.Account__c;
                    Contact_Affiliation__c conAff = new Contact_Affiliation__c();
                    conAff.Id = ca.Id;
                    
                    if(oldConIdAccId.contains(s)){
                        
                        conAff.Unique_Contact_Affiliation__c = 0;
                    }
                    if(!oldConIdAccId.contains(s) && newConIdAccId.contains(s)){
                        
                        if(!conIdAccId.contains(s)){
                            conAff.Unique_Contact_Affiliation__c = 1;
                            conIdAccId.add(s);
                        }else{
                            conAff.Unique_Contact_Affiliation__c = 0;
                        }
                    }
                    updateConAffRecs.add(conAff);
                }
            }
            System.debug('::::updateConAffRecs::'+updateConAffRecs);
            
            if(updateConAffRecs.size() > 0){
            
                update updateConAffRecs;
            }
        }
        
        if(Trigger.isDelete){
        
            Set<Id> accIds = new Set<Id>();
            Set<Id> conIds = new Set<Id>();
            Set<Id> contAffIds = new Set<Id>();
            Set<String> delRecConIdAccId = new Set<String>();
            Set<String> existingConIdAccId = new Set<String>();
            List<Contact_Affiliation__c> updateConAff = new List<Contact_Affiliation__c>();
            
            for(Contact_Affiliation__c ca : Trigger.old){
            
                if(ca.Account__c != NULL && ca.Contact__c != NULL && ca.Unique_Contact_Affiliation__c != NULL && 
                    ca.Unique_Contact_Affiliation__c == 1){
                
                    String s = ca.Contact__c+''+ca.Account__c;
                    delRecConIdAccId.add(s);
                    accIds.add(ca.Account__c);
                    conIds.add(ca.Contact__c);
                    contAffIds.add(ca.Id);
                }
            }
            System.debug('::::contAffIds::'+contAffIds);
            
            for(Contact_Affiliation__c c : [SELECT Id, Account__c, Contact__c
                FROM Contact_Affiliation__c 
                WHERE Id NOT IN : contAffIds AND Account__c IN : accIds AND Contact__c IN : conIds
                    ORDER BY CreatedDate ASC]){
            
                if(c.Account__c != NULL && c.Contact__c != NULL){
                
                    String s = c.Contact__c+''+c.Account__c;
                    
                    if(delRecConIdAccId.contains(s) && !existingConIdAccId.contains(s)){
                        existingConIdAccId.add(s);
                        c.Unique_Contact_Affiliation__c = 1;
                        updateConAff.add(c);
                    }
                } 
            }
            System.debug('::::updateConAff::'+updateConAff);
            
            if(updateConAff.size() > 0){
            
                update updateConAff;
            }
        }
        
        if(Trigger.isUpdate){
        
            Set<Id> accIds = new Set<Id>();
            Set<Id> newConIds = new Set<Id>();
            Set<Id> oldConIds = new Set<Id>();
            
            Set<Id> conAffIds = new Set<Id>();
            Set<String> newConIdAccId = new Set<String>();
            Set<String> conIdAccId = new Set<String>();
            
            Map<String, Contact_Affiliation__c> conAccIdAndOldConAffRec = new Map<String, Contact_Affiliation__c>();
            Set<String> oldRecConIdAccId = new Set<String>();
            List<Contact_Affiliation__c> allConAffRecs = new List<Contact_Affiliation__c>();
            List<Contact_Affiliation__c> updateConAffRecs = new List<Contact_Affiliation__c>();
            
            for(Contact_Affiliation__c ca : Trigger.new){
            
                Contact_Affiliation__c oldCA = Trigger.oldMap.get(ca.Id);
                
                if(ca.Account__c != NULL && ca.Contact__c != NULL && ca.Contact__c != oldCA.Contact__c &&
                    oldCA.Contact__c != NULL && oldCA.Account__c != NULL){
                
                    String newConIdAccIdStr = ca.Contact__c+''+ca.Account__c;
                    String oldConIdAccIdStr = oldCA.Contact__c+''+oldCA.Account__c;
                    
                    accIds.add(ca.Account__c);
                    newConIds.add(ca.Contact__c);
                    if(oldCA.Unique_Contact_Affiliation__c == 1){
                        oldConIds.add(oldCA.Contact__c);
                    }
                    conAffIds.add(ca.Id);
                    newConIdAccId.add(newConIdAccIdStr);
                    allConAffRecs.add(ca);
                }
            }
            
            System.debug(':::newConIds::'+newConIds);
            System.debug(':::oldConIds::'+oldConIds);
            System.debug(':::accIds::'+accIds);
            System.debug(':::newConIdAccId::'+newConIdAccId);
            System.debug(':::allConAffRecs::'+allConAffRecs);
            
            for(Contact_Affiliation__c c : [SELECT Id, Account__c, Contact__c
                FROM Contact_Affiliation__c 
                WHERE Id NOT IN : conAffIds AND Account__c IN : accIds AND (Contact__c IN : newConIds OR Contact__c IN : oldConIds)
                    ORDER BY CreatedDate ASC]){
            
                if(c.Account__c != NULL && c.Contact__c != NULL){
                
                    String s = c.Contact__c+''+c.Account__c;
                    
                    if(!oldRecConIdAccId.contains(s)){
                    
                        oldRecConIdAccId.add(s);
                        conAccIdAndOldConAffRec.put(s, c);
                    }
                } 
            }
            System.debug(':::conAccIdAndOldConAffRec:::'+conAccIdAndOldConAffRec);
            
            for(Contact_Affiliation__c ca : allConAffRecs){
            
                Contact_Affiliation__c oldCA = Trigger.oldMap.get(ca.Id);
                                
                String newConIdAccIdStr = ca.Contact__c+''+ca.Account__c;
                String oldConIdAccIdStr = oldCA.Contact__c+''+oldCA.Account__c;
                
                Contact_Affiliation__c updateCA = new Contact_Affiliation__c();
                updateCA.Id = ca.Id;
                
                if(oldRecConIdAccId.contains(newConIdAccIdStr)){
                
                    updateCA.Unique_Contact_Affiliation__c = 0;
                }
                if(oldRecConIdAccId.contains(oldConIdAccIdStr)){
                
                    if(oldCA.Unique_Contact_Affiliation__c == 0){
                        // Nothing need to be update
                    }
                    if(oldCA.Unique_Contact_Affiliation__c == 1){
                        
                        if(conAccIdAndOldConAffRec.containsKey(oldConIdAccIdStr)){
                        
                            Contact_Affiliation__c updateoldCA = new Contact_Affiliation__c();
                            updateoldCA.Id = conAccIdAndOldConAffRec.get(oldConIdAccIdStr).Id;
                            updateoldCA.Unique_Contact_Affiliation__c = 1;
                            updateConAffRecs.add(updateoldCA);
                        }
                    }
                }
                    
                if(!oldRecConIdAccId.contains(newConIdAccIdStr) && newConIdAccId.contains(newConIdAccIdStr)){
                
                    if(!conIdAccId.contains(newConIdAccIdStr)){
                    
                        updateCA.Unique_Contact_Affiliation__c = 1;
                        conIdAccId.add(newConIdAccIdStr);
                    }else{
                        updateCA.Unique_Contact_Affiliation__c = 0;
                    }
                }
                
                if(!oldRecConIdAccId.contains(oldConIdAccIdStr)){
                    // Nothing need to be update
                }
                updateConAffRecs.add(updateCA);
            }
            System.debug(':::updateConAffRecs:::'+updateConAffRecs);
            
            if(updateConAffRecs.size() > 0){
            
                update updateConAffRecs;
            }
        }
    }
}