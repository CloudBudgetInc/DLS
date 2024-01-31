/**********************************************************************
    Created by Vinitha on Jan 13 2017: Service class used for Materials_Request__c object
***********************************************************************/
public class MaterialRequestService {
    /*,DLS_Sales_Tax_Formula__c,DLS_Sales_Tax_Percentage__c,DLS_Sales_Tax_Applicable__c, Item_Price_Formula__c, Vendor_Total__c, Skip_Paid_Remaining_Check__c*/
    /* DLS_Sales_Tax__c,Total__c,Item_Price__c */
    public Static String fldStr = 'Accounting_Code__c,Agency__c,Billing_Notes__c,CD_Cost__c,Class_Name__c,Contact__c,Date_Delivered__c,Date_Loaned_Out__c,Date_Ordered__c,Date_Returned__c,'+
    'Delivery_Location__c,DLS_Class_Number__c,DLS_Sales_Tax_Applicable__c,DLS_Sales_Tax_Formula__c,DLS_Sales_Tax_Percentage__c,DLS_Total__c,DLS_Total_Invoice__c,Due_Date__c,Est_Arrival_Date__c,Estimated_Tax__c,G_A_Materials_Expense__c,'+
    'In_House_CD__c,In_House_CD_Total__c,Item_Price_Formula__c,Item_Title__c,Language__c,Materials_Budget_Remaining__c,Materials_G_A_Expense_from_Contract__c,'+
    'Materials_Paid_Remaining__c,Materials_Name__c,Name_of_CD__c,CD_Number__c,Power_Of_1__c,Project__c,Project_Task__c,Qty__c,Request_Notes__c,Request_Status__c,Request_type__c,Rush__c,Section__c,Shipper_Tracking__c,Shipping_Handling__c,Skip_Paid_Remaining_Check__c,'+
    'Training_Location__c,Vendor__c,Vendor_Name__c,Vendor_Order_No__c,Vendor_Total__c,Id,Name,CreatedDate,Last_Material_Merged_DateTime__c,Location__c,Materials_Source__c,Materials_Stock__c,Source_Inventory_Type__c,'+
    'Target_Inventory_Type__c,Target_Location__c,Target_Materials_Stock__c';
     /**********************************************************************
        Created by Vinitha on Jan 13 2017: This method return list of materialRequest 
        @filterQry - pass where condition
        return - list of materialRequest records
    ***********************************************************************/    
    public static list<Materials_Request__c> getMaterial(String fltrqryStr, String parentFields) {
    
        List<Materials_Request__c> materialRequestList = new List<Materials_Request__c>();        
        //String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Materials_Request__c');        
        String defaultQry = 'SELECT ' + fldStr + ' FROM Materials_Request__c';
        
        if(parentFields != null && parentFields != ''){
           defaultQry = 'SELECT '+ fldStr +' ,'+ parentFields + ' FROM Materials_Request__c';
        }                     
                            
        if(fltrqryStr != null && fltrqryStr != ''){
            defaultQry = defaultQry + fltrqryStr;            
        }       
        system.debug(':::::::defaultQry:::::::'+defaultQry);
        materialRequestList = Database.query(defaultQry);
        
        return materialRequestList;
    }
    
    /**********************************************************************
        Created by Vinitha on Jan 13 2017: This method return list of materialRequest 
        @materialId - set of Materials ids
        return - list of materialRequest records
    ***********************************************************************/    
    public static List<AggregateResult> getMaterialbyOppId(String filterQry, Set<Id> materialId) {
        List<AggregateResult> materialRequestList = new List<AggregateResult>();
        String query = '';
       if(materialId != null && materialId.size() > 0){
            query = 'SELECT count(Id) matCount FROM Materials_Request__c WHERE Materials_Name__c IN : materialId'+filterQry;
            materialRequestList = Database.query(query);
        }
        return materialRequestList;
    }       
                        
    
     /**********************************************************************
        Created by Vinitha on Jan 13 2017: This method return newly created list of materialRequest 
        @materialRequestList - List of materialRequest records
        return - list of materialRequest records
    ***********************************************************************/ 
    public static list<Materials_Request__c> insertMaterialrequest(list<Materials_Request__c> materialRequestList) {
    
        if(materialRequestList != null && materialRequestList.size() > 0){
            insert materialRequestList;            
        }
        return materialRequestList;    
    } 
    
    /**********************************************************************
        Created by Vinitha on Jan 13 2017: This method return list of materialRequest 
        @materialRequestList - List of materialRequest records
        return - list of materialRequest records
    *********************************************************************** 
    public static list<Materials_Request__c> updateMaterialrequest(list<Materials_Request__c> materialRequestList) {
    
        if(materialRequestList != null && materialRequestList.size() > 0){
            update materialRequestList;            
        }
        return materialRequestList;    
    }
    */
    
    /**********************************************************************
        Created by Vinitha on Jan 13 2017: This method return list of materialRequest 
        @materialRequestList - List of materialRequest records
        return - list of materialRequest records
    ***********************************************************************/ 
    public static list<Materials_Request__c> deleteMaterialrequest(list<Materials_Request__c> materialRequestList) {
    
        if(materialRequestList != null && materialRequestList.size() > 0){
            delete materialRequestList;            
        }
        return materialRequestList;    
    }
    
    /**********************************************************************
        Created by Shalini on Aug 24 2017 
        This method returns map of oppId with map of Material Request RecordType with RecordType based count
    ***********************************************************************/ 
    
    /*public static Map<Id,Map<String,Integer>> getMatReqCountbyOppAndRT(Set<Id> oppIdSet, Set<Id> proIdSet) {
        List<AggregateResult> materialRequestListPro = new List<AggregateResult>();
        List<AggregateResult> materialRequestListOpp = new List<AggregateResult>();
        Map<Id,Map<String,Integer>> oppIdCountMap = new Map<Id,Map<String,Integer>>();
        if(proIdSet != null && proIdSet.size() > 0){
            materialRequestListPro = [
                        SELECT 
                            Project__c proId,RecordType.DeveloperName recType,
                            count(Id) matCount 
                        FROM 
                            Materials_Request__c 
                        WHERE 
                            Project__c IN : proIdSet 
                        GROUP BY 
                            Project__c,RecordType.DeveloperName
                        ];
        }  
        if(oppIdSet != null && oppIdSet.size() > 0){
            materialRequestListOpp = [
                        SELECT 
                            Class_Name__c oppId,RecordType.DeveloperName recType,
                            count(Id) matCount 
                        FROM 
                            Materials_Request__c 
                        WHERE 
                            Class_Name__c IN : oppIdSet 
                        GROUP BY 
                            Class_Name__c,RecordType.DeveloperName
                        ];
            
        }
        if(materialRequestListPro.size() > 0){
            for(AggregateResult agg : materialRequestListPro) {
                Id proId = (Id) agg.get('proId');
                String recType = (String) agg.get('recType');
                Integer count = (Integer) agg.get('matCount');
                if(!oppIdCountMap.containsKey(proId)){
                    oppIdCountMap.put(proId,new Map<String,Integer>());
                }
                if(recType == 'Project_Materials_Request'){
                    oppIdCountMap.get(proId).put('Project_Materials_Request',count);
                } else {
                    oppIdCountMap.get(proId).put('Material_Loan_Request',count);
                }
                if(!oppIdCountMap.get(proId).containsKey('Project_Materials_Request')){
                    oppIdCountMap.get(proId).put('Project_Materials_Request',0);   
                }
                if(!oppIdCountMap.get(proId).containsKey('Material_Loan_Request')){
                    oppIdCountMap.get(proId).put('Material_Loan_Request',0);
                }
            }
        } else {
            for(Id prId : proIdSet){
                if(!oppIdCountMap.containsKey(prId)){
                    oppIdCountMap.put(prId,new Map<String,Integer>());
                    oppIdCountMap.get(prId).put('Project_Materials_Request',0);
                    oppIdCountMap.get(prId).put('Material_Loan_Request',0);
                } 
            }
        }
        if(materialRequestListOpp.size() > 0){
            for(AggregateResult agg : materialRequestListOpp) {
                Id oppId = (Id) agg.get('oppId');
                String recType = (String) agg.get('recType');
                Integer count = (Integer) agg.get('matCount');
                if(!oppIdCountMap.containsKey(oppId)){
                    oppIdCountMap.put(oppId,new Map<String,Integer>());
                }
                if(recType == 'Project_Materials_Request'){
                    oppIdCountMap.get(oppId).put('Project_Materials_Request',count);
                } else {
                    oppIdCountMap.get(oppId).put('Material_Loan_Request',count);
                }
                if(!oppIdCountMap.get(oppId).containsKey('Project_Materials_Request')){
                    oppIdCountMap.get(oppId).put('Project_Materials_Request',0);   
                }
                if(!oppIdCountMap.get(oppId).containsKey('Material_Loan_Request')){
                    oppIdCountMap.get(oppId).put('Material_Loan_Request',0);
                }
            }
        } else {
            for(Id oppId : oppIdSet){
                if(!oppIdCountMap.containsKey(oppId)){
                    oppIdCountMap.put(oppId,new Map<String,Integer>());
                    oppIdCountMap.get(oppId).put('Project_Materials_Request',0);
                    oppIdCountMap.get(oppId).put('Material_Loan_Request',0);
                } 
            }
        }
        return oppIdCountMap;
    }*/
    
    /** Created to get the Stripped Class Number for count on Dec 8, 2018*/
    public static Map<Id,Map<String,Integer>> getMatReqCountbyOppAndRT(Set<Id> oppIdSet, Set<Id> proIdSet) {
        Map<Id,Map<String,Integer>> oppIdCountMap = new Map<Id,Map<String,Integer>>();
        
        if( oppIdSet != null && oppIdSet.size() > 0 ) {
            for(AggregateResult agg : [SELECT MAX(Stripped_Material_Request_Number__c) maxStrip,RecordType.DeveloperName recType,Class_Name__c oppId FROM Materials_Request__c 
                        WHERE 
                            Class_Name__c IN : oppIdSet 
                        GROUP BY 
                            Class_Name__c,RecordType.DeveloperName
                        ]) {
                Id oppId = (Id) agg.get('oppId');
                String recType = (String) agg.get('recType');
                Decimal count = (Decimal) agg.get('maxStrip');
                
                if(!oppIdCountMap.containskey(oppId)) {
                    oppIdCountMap.put(oppId, new Map<String,Integer>{recType => Integer.ValueOf(count)});
                } else if(!oppIdCountMap.get(oppId).containskey(recType)) {
                    oppIdCountMap.put(oppId, new Map<String,Integer>{recType => Integer.ValueOf(count)});
                }
            }
        }
        if( proIdSet != null && proIdSet.size() > 0 ) {
            for(AggregateResult agg : [SELECT MAX(Stripped_Material_Request_Number__c) maxStrip,RecordType.DeveloperName recType,Project__c proId FROM Materials_Request__c 
                        WHERE 
                            Project__c IN : proIdSet 
                        GROUP BY 
                            Project__c,RecordType.DeveloperName
                        ]) {
                Id proId = (Id) agg.get('proId');
                String recType = (String) agg.get('recType');
                Decimal count = (Decimal) agg.get('maxStrip');
                
                if(!oppIdCountMap.containskey(proId)) {
                    oppIdCountMap.put(proId, new Map<String,Integer>{recType => Integer.ValueOf(count)});
                } else if(!oppIdCountMap.get(proId).containskey(recType)) {
                    oppIdCountMap.get(proId).put(recType,Integer.ValueOf(count));
                }
            }
        } 
        System.debug('oppIdCountMap::::'+oppIdCountMap);
        return oppIdCountMap;
    }
    
    /*****************************************************************************
    - Method to get the Materials request records based on the projects
    - Added by NS on August 28 2018
    - return list of Materials Request records
    - Input - filterQry,parentFields,parentConditionField, includeParentcondition, parentIds
    ******************************************************************************/
    public static List<Materials_Request__c> getMRrecordsByParentIds(String filterQry, String parentFields, String parentConditionField,Boolean includeParentcondition, Set<Id> parentIds,String limitQry) {
        
        List<Materials_Request__c> materialRequestList = new List<Materials_Request__c>();
        
        String defaultQry = 'SELECT ' + fldStr + ' FROM Materials_Request__c';
        
        if(parentFields != null && parentFields != ''){
           defaultQry = 'SELECT '+ fldStr +' ,'+ parentFields + ' FROM Materials_Request__c';
        }                     
                            
        if(filterQry != null && filterQry != ''){
            defaultQry = defaultQry + filterQry;            
        } 
        
        if(String.isNotEmpty(parentConditionField) && parentIds != null && parentIds.size() > 0){
            if(includeParentcondition)
                defaultQry += ' AND '+parentConditionField+' IN :parentIds';
            else
                defaultQry += ' AND '+parentConditionField+' NOT IN :parentIds';
        }
        
        if(String.isNotEmpty(limitQry)){
            defaultQry += limitQry;
        }
              
        system.debug(':::::::defaultQry:::::::'+defaultQry);
        materialRequestList = Database.query(defaultQry);
        
        return materialRequestList;
    
    }
}