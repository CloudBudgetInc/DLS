/* 
Developed by Shalini on July 31 2017 
to update Child Contract CLINs with Parent Contract CLIN for Delivery Order Contract 
*/
     
public class CLINTrigger_Handler {
    
    public static void updateChildClins(List<CLIN__c> clinsList, Map<Id,CLIN__c> oldCLINIdMap){
        
        Map<String,CLIN__c> nameParentClinIdMap = new Map<String,CLIN__c>();
        Set<Id> parentClinIdSet = new Set<Id>();
        Set<String> clinNameSet = new Set<String>();
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> updatedCLINIdSet = new Set<Id>();
        
        // Sets formation with oldMap values of newly updated CLINs to query Child Contract CLINs
        for(CLIN__c c : clinsList){
            if(c.CLIN_Name__c != oldCLINIdMap.get(c.Id).CLIN_Name__c || c.CLIN_Type__c != oldCLINIdMap.get(c.Id).CLIN_Type__c || c.CLIN_Unit__c != oldCLINIdMap.get(c.Id).CLIN_Unit__c || c.Parent_CLIN__c != oldCLINIdMap.get(c.Id).Parent_CLIN__c){
                nameParentClinIdMap.put(oldCLINIdMap.get(c.Id).Name+';'+oldCLINIdMap.get(c.Id).Parent_CLIN__c,c);
                updatedCLINIdSet.add(c.Id); 
                parentClinIdSet.add(oldCLINIdMap.get(c.Id).Parent_CLIN__c);
                clinNameSet.add(oldCLINIdMap.get(c.Id).Name);
                if(oldCLINIdMap.get(c.Id).Contract__c != null){
                    contractIdSet.add(oldCLINIdMap.get(c.Id).Contract__c);
                }
            }   
        }
        
        List<CLIN__c> CLINList = new List<CLIN__c>();   
        
        // Updation of Child Contract CLIN records with Parent Contract CLIN
        for(CLIN__c c : [SELECT Id, Name, CLIN_Name__c, CLIN_Type__c, CLIN_Unit__c,Contract__c,Contract__r.APXT_Redlining__Contract_Family_Parent__c, CLIN_Unit_Price__c, Parent_CLIN__c, Parent_CLIN__r.CLIN_Name__c,Parent_CLIN__r.Name FROM CLIN__c WHERE Parent_CLIN__c IN :parentClinIdSet AND Name IN :clinNameSet AND Id NOT IN :updatedCLINIdSet AND Contract__r.APXT_Redlining__Contract_Family_Parent__c IN :contractIdSet]){
            if(nameParentClinIdMap.containskey(c.Name+';'+c.Parent_CLIN__c)){
                c.CLIN_Name__c = nameParentClinIdMap.get(c.Name+';'+c.Parent_CLIN__c).CLIN_Name__c;
                c.CLIN_Type__c = nameParentClinIdMap.get(c.Name+';'+c.Parent_CLIN__c).CLIN_Type__c;
                c.CLIN_Unit__c = nameParentClinIdMap.get(c.Name+';'+c.Parent_CLIN__c).CLIN_Unit__c;
                c.Parent_CLIN__c = nameParentClinIdMap.get(c.Name+';'+c.Parent_CLIN__c).Parent_CLIN__c;
                CLINList.add(c);
            } 
        }
        
        system.debug('::CLINList::'+CLINList);
        if(CLINList != null && CLINList.size() > 0) {
            update CLINList;
        }
    }
   /*
    Created by Siva Prasanth on May 14 2019
    to  validate CLIN #s related to a contract to be unique from each other.
    */
    
    public static void validateChildClinsName(List<CLIN__c> clinsList, Map<Id,CLIN__c> oldCLINIdMap){
        Set<Id> contractIdSet = new Set<Id>();
        Map<Id,set<String>> contractChildValidationMap = new Map<Id,set<String>>();
        Map<String,Integer> validationNewMap = new Map<String,Integer>();
        List<CLIN__c> clinListToValidate = new List<CLIN__c>();
        
        for(CLIN__c c : clinsList){
            if(c.Contract__c != null && String.isNotBlank(c.Name) && (Trigger.isInsert || (Trigger.isUpdate && (oldCLINIdMap.get(c.Id).Name != c.Name || oldCLINIdMap.get(c.Id).Contract__c != c.Contract__c)))){
                contractIdSet.add(c.Contract__c);
                clinListToValidate.add(c);
                if(validationNewMap.containskey(c.Contract__c+'-'+c.Name)){
                    validationNewMap.put(c.Contract__c+'-'+c.Name ,validationNewMap.get(c.Contract__c+'-'+c.Name)+1);
                }else{
                    validationNewMap.put(c.Contract__c+'-'+c.Name,1);      
                }
            } 
        }
        System.debug('validationNewMap==='+validationNewMap);
        
        if(contractIdSet.size() > 0){
            
            for(CLIN__c c : [SELECT Id, Name, CLIN_Name__c,Contract__c FROM CLIN__c WHERE  Contract__c IN :contractIdSet]){
              
                if(contractChildValidationMap.containskey(c.Contract__c)){
                   contractChildValidationMap.get(c.Contract__c).add(c.Name);
                }else{
                    contractChildValidationMap.put(c.Contract__c,new set<String>{c.Name});
                }
            }
        }
        System.debug('contractChildValidationMap==='+contractChildValidationMap);
        if(clinListToValidate.size() > 0){
            
            for(CLIN__c c : clinListToValidate){
                
                if((contractChildValidationMap != null && contractChildValidationMap.containsKey(c.Contract__c) && contractChildValidationMap.get(c.Contract__c).contains(c.Name)) ||  (validationNewMap.containsKey(c.Contract__c+'-'+c.Name) && validationNewMap.get(c.Contract__c+'-'+c.Name) > 1)){
                    c.addError('CLIN record for the same Contract must have unique CLIN #\'s');
                }
            }       
        }
    }
    
    // Added By HL on June 03 2021
    // Work Item: W-006637 - Formula fields while adding CLINs on the Contract and Child Contract page
    public static void updateCLIN_Name(List<CLIN__c> newCLINs){
    
        if(newCLINs != NULL){
        
            Set<Id> contractIds = new Set<Id>();
            
            for(CLIN__c c : newCLINs){
            
                if(c.Contract__c != NULL){
                    contractIds.add(c.Contract__c);
                }
            }
            System.debug(':::::contractIds::::'+contractIds);
            
            if(contractIds.size() > 0){
            
                Map<Id, Contract> contractRecs = new Map<Id, Contract>([SELECT Id, Name, APXT_Redlining__Contract_Family_Parent__c FROM Contract WHERE Id IN : contractIds]); 
                System.debug(':::::contractRecs::::'+contractRecs);
                
                for(CLIN__c c : newCLINs){
                
                    if(contractRecs.containsKey(c.Contract__c) && contractRecs.get(c.Contract__c).APXT_Redlining__Contract_Family_Parent__c != NULL){
                    
                        c.Name = c.Name+'-'+contractRecs.get(c.Contract__c).Name.right(5);
                    }
                }
            }
        }
    }
}