public class CreateDeliveryOrderController {
    
    
    /*W-002025 Create button: “Create Delivery Order” Child Contract record from an Existing Parent Contract record*/

    @AuraEnabled 
    public static Boolean isContractLevelisParent(String parentContractId){
        List<Contract> parentContractLst = [SELECT Id,AccountId,ContractNumber,Contract_Level__c FROM Contract WHERE Id =: parentContractId];
        if(parentContractLst.size() > 0){
            if(parentContractLst[0].Contract_Level__c == 'Parent'){
                return true;    
            }
        }
        return false;
    }
    
    /******************************************************
    - Get Lookup search related records
    - Added by Siva Prasanth on June 14 2019
    *******************************************************/
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    }  
     /******************************************************
    - Insert child Contract and get child Contract Id
    - Added by Siva Prasanth on June 14 2019
    *******************************************************/
    @AuraEnabled
    public static String saveNewContract(String contractJSON,String parentContractId){
        try{ 
            List<Contract> childContractLst = (List<Contract>)JSON.deserialize(contractJSON,List<Contract>.class);
            List<Contract> parentContractLst = new List<Contract>();
            String dLSFedChildRT = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Federal_DLS_Prime_Child').getRecordTypeId(); 
            
            if(parentContractId != null && parentContractId != ''){
                parentContractLst = [SELECT Id,AccountId,Contract_No__c	 FROM Contract WHERE Id =: parentContractId];
            }
            if(parentContractLst.size() > 0){
                childContractLst[0].Contract_No__c = parentContractLst[0].Contract_No__c+'-'+childContractLst[0].Task_Order__c;
                childContractLst[0].Name = parentContractLst[0].Contract_No__c+'-'+childContractLst[0].Task_Order__c;
                childContractLst[0].AccountId = parentContractLst[0].AccountId;
                childContractLst[0].APXT_Redlining__Contract_Family_Parent__c = parentContractLst[0].Id;
                childContractLst[0].IDIQ_Contract_No__c = parentContractLst[0].Contract_No__c;
            }
            if(childContractLst.size() > 0){
                childContractLst[0].RecordTypeId = dLSFedChildRT;
                childContractLst[0].Prime__c = true;
                childContractLst[0].Status = 'Completed Draft';
                childContractLst[0].Contract_Level__c = 'Delivery Order';
                childContractLst[0].Contract_Type__c = 'Time and Materials (T&M)'; 
                insert childContractLst;
                return childContractLst[0].Id;
            }
            return null;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}