/**********************************************************************
    Created by Karthiga on Feb 10, 2017: Class called from "convert to MTT" Button in Task Statement
***********************************************************************/
global class CreateMTTRecord {
    
    webservice static String createMTTRec(Id toId) { 
        List<Task_Order__c> tos = new List<Task_Order__c>();
        tos = SObjectQueryService.SObjectQuery('Task_Order__c',new Set<Id>{toId},'');
        
        if(tos != null && tos.size() > 0 ) {
            try{
                MTT__c m = new MTT__c();
                m.Pay_Rate__c = tos[0].Pay_Rate__c;
                m.Name = tos[0].Name;
                m.Stage__c='Active';  
                m.Start_Date__c = tos[0].Start_Date__c;
                m.End_Date__c = tos[0].End_Date__c;
                m.MTT_Location__c = tos[0].MTT_LocationID__c;
                m.Language__c = tos[0].Language__c;
                m.Task_Order__c = tos[0].Requirement_Description__c;
                
                Insert m;
                return m.Id;
            } catch(Exception ex) {
                System.debug('Exception::::'+ex);
                return 'Failure-'+ex.getMessage();
            }
        } else {
            return 'Failure-No Records Found';
        }      
    }
}