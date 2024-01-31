/**********************************************************************
    Created by vinitha on April 04, 2017: Class called from "Create Contract Modification" Button in Opportunity
***********************************************************************/
global class createContractModificationRecord {
    
    webservice static Id createContractModRec(Id oppId) { 
        
        system.debug('::::oppId:'+oppId);
        Id rtId;
        
        List<RecordType> recList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName(' AND DeveloperName','Contract_Modification__c',new Set<String>{'Task_Order'});
        system.debug(':::::recList'+recList);
        if(recList != null && recList.size() > 0){
            rtId = recList[0].Id;
        }
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = SObjectQueryService.SObjectQuery('Opportunity',new Set<Id>{oppId},'');
        
        if(oppList != null && oppList.size() > 0 ) {
            
            Contract_Modification__c conmod = new Contract_Modification__c(
                of_Instructors_active__c = oppList[0].of_Instructors_active__c,
                of_Instructors_awarded__c = oppList[0].of_Instructors_awarded__c,
                of_Instructors_requested__c = oppList[0].of_Instructors_requested__c,
                Classification__c = oppList[0].Classification__c,
                Name = oppList[0].Name,
                RecordTypeId = rtId,
                Default_Cost_Rate_Rate_Type__c = oppList[0].Default_Cost_Rate_Rate_Type__c,
                Task_Order_End_Date__c = oppList[0].End_Date__c,
                Program_type__c = oppList[0].Program_type__c,
                Project_Type__c = oppList[0].Project_Type__c,
                Qualification_Bundle__c = oppList[0].Qualification_Bundle__c,
                Task_Order_Start_Date__c = oppList[0].Start_Date__c,
                Task_Order_Name__c = oppList[0].Task_Order_Name__c,
                Total_Amount_Funded__c = oppList[0].Total_Amount_Funded__c,
                Total_Hours_Paid_Auth_New__c = oppList[0].Total_Hours_Paid_Auth_New__c,
                Total_Materials_Funded__c = oppList[0].Total_Materials_Funded__c,
                Total_Materials_Product__c = oppList[0].Total_Materials_Product__c,
                Total_ODcs_Funded__c = oppList[0].Total_ODcs_Funded__c,
                Total_ODCs_Products__c = oppList[0].Total_ODCs_Products__c,
                Total_Price_All_Products__c = oppList[0].Total_Price_All_Products__c,
                Hours__c = oppList[0].Hours__c,
                Total_Refund_Amount__c = oppList[0].Total_Refund_Amount__c,
                Total_Services_Funded__c = oppList[0].Total_Services_Funded__c,
                Total_Services_Products__c = oppList[0].Total_Services_Products__c,
                Total_Travel_Funded__c = oppList[0].Total_Travel_Funded__c,
                Total_Travel_Product__c = oppList[0].Total_Travel_Product__c,
                Location__c = oppList[0].Location__c,
                Travel_In_Date__c = oppList[0].Travel_In_Date__c,
                Travel_Out_Date__c = oppList[0].Travel_Out_Date__c,
                Task_Order__c = oppList[0].Task_Order__c,
                Supervisor__c = oppList[0].Supervisor__c,    
                Contract_Number__c = oppList[0].ContractId,
                Opportunity_Name__c = oppList[0].Id,
                Opportunity_Record_Type__c = oppList[0].RecordTypeId
            );
            
            Insert conmod;
            system.debug(':::::conmod'+conmod);
            return conmod.Id;
        }
        return null;
      
    }
}