trigger UpdateMaterialRequestName on Materials_Request__c (before insert, before update, after update) {
        
    // To Update Name field with DlsClass-M1 format in before insert
    
    Set<Id> oppIdSet = new Set<Id>();
    Set<Id> proIdSet = new Set<Id>();
    Map<Id,Integer> oppIdCountMap = new Map<Id,Integer>();
    Map<Id,String> oppIdDlsclassRecMap = new Map<Id,String>();
    Set<Id> matReqIdtoUpdate = new Set<Id>();
    Map<Id,Set<String>> deliveredoldValue = new Map<Id,Set<String>>();
    Map<Id,String> rtIdNameMap = new Map<Id,String>();
    Decimal DLSsalesTax = Decimal.ValueOf(Label.DLS_Sales_Tax);
    Map<Id,Decimal> oppIdMBRMap = new Map<Id,Decimal>(); // MBR - Material Budget Remaining
    Map<Id,Decimal> projTIdMBRMap = new Map<Id,Decimal>(); // Project Task's Material Budget Remaining 
    
    Set<Id> locationIdSet = new Set<Id>();
    Set<Id> targetLocationIdSet = new Set<Id>();
    Set<Id> materialIdSet = new Set<Id>();
    Map<String,Id> stockForLocationAndMaterialMap = new Map<String,Id>();
    Map<String,Integer> stockId_RT_MRCntMap = new Map<String,Integer>();
    Map<Id,String> stockIdNameMap = new Map<Id,String>();
    List<Materials_Request__c> mrRecords = new List<Materials_Request__c>();
    
    List<Materials_Request__c> projectMRs = new List<Materials_Request__c>();
    Set<Id> projectIds = new Set<Id>();
    
    for(RecordType r : SObjectQueryService.getRecTypeListBySobjTypeAndDevName('','Materials_Request__c',new Set<String>{})){
        rtIdNameMap.put(r.Id,r.DeveloperName);
    }
    
    
    //Id materialTransferRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Material_Transfer').getRecordTypeId();
    
    for (Materials_Request__c mr : Trigger.new) {
        
        String mrRType = (mr.RecordTypeId != null && rtIdNameMap.containskey(mr.RecordTypeId)) ? rtIdNameMap.get(mr.RecordTypeId) : '';
        if(Trigger.isbefore) {
            
            // To update Material Request Name based on project / opp values
            if(Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(mr.Id).Project__c != mr.Project__c || Trigger.oldMap.get(mr.Id).Class_Name__c != mr.Class_Name__c))) {
                if(mr.Project__c != null){
                    proIdSet.add(mr.Project__c);    
                } else if(mr.Class_Name__c != null) {
                    oppIdSet.add(mr.Class_Name__c);
                }
            }
            
            // To update Material Budget Reamining
            if(Trigger.isInsert && mr.Project_Task__c != null) {
                projTIdMBRMap.put(mr.Project_Task__c,0);
            }
            
            //To update DLS_Sales_Tax_Percentage__c field
            if(Trigger.isInsert || (Trigger.isUpdate && (mr.DLS_Sales_Tax_Applicable__c != Trigger.oldMap.get(mr.Id).DLS_Sales_Tax_Applicable__c))){
                if(mrRType == 'Project_Materials_Request'){
                    if(mr.DLS_Sales_Tax_Applicable__c){
                        if(mr.DLS_Sales_Tax_Percentage__c != DLSsalesTax){
                            mr.DLS_Sales_Tax_Percentage__c = DLSsalesTax;
                        }
                    } else {
                        if(mr.DLS_Sales_Tax_Percentage__c != 0){
                            mr.DLS_Sales_Tax_Percentage__c = 0;
                        }
                    }
                }            
            } 
            
            // To remove the currency field values when the Status is updated to Canceled, Modified on 30 Jan, 2018 by GRK
            if(trigger.isUpdate && mrRType == 'Project_Materials_Request' && Trigger.oldMap.get(mr.Id).Request_Status__c != mr.Request_Status__c && mr.Request_Status__c == 'Canceled') {
                mr.Vendor_Total__c = 0;
                mr.DLS_Sales_Tax_Applicable__c = false;
                mr.DLS_Sales_Tax_Percentage__c = 0;
            }
            
            // To populate Material Stock value in Material Request based on Material & Location values
            if(Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(mr.Id).Location__c != mr.Location__c || Trigger.oldMap.get(mr.Id).Materials_Name__c != mr.Materials_Name__c))){
                locationIdSet.add(mr.Location__c);
                materialIdSet.add(mr.Materials_Name__c);
            }
            
            if(rtIdNameMap != null && rtIdNameMap.containsKey(mr.RecordTypeId) && rtIdNameMap.get(mr.RecordTypeId) == 'Material_Transfer'){
                if(Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(mr.Id).Target_Location__c != mr.Target_Location__c))){
                    targetLocationIdSet.add(mr.Target_Location__c);
                }
            }
            
            // Populate Date Returned values based on the Request field value changes
            // Added by NS on August 14 2018
            if((Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(mr.Id).Request_Status__c != mr.Request_Status__c))) && mr.Request_Status__c == 'Returned') {
                if(mr.Date_Returned__c == null) {
                    mr.Date_Returned__c = system.today();
                }
            }
            
            // To create Missing Material Stock, Inventory Purhcase & Item records on delivery status update (Only for DLS Library Projects & DLS Materials Inventory Projects)
            // Added by NS on Sep 5 2018
            // These records automation is to populate Purhcased Qty (Library) & Purchased Qty (Order) values population in Stock level
            if(Trigger.isUpdate && mrRType == 'Project_Materials_Request' && mr.Project_Record_Type_Name__c == 'Facilities_Project'
                && (Trigger.oldMap.get(mr.Id).Request_Status__c != mr.Request_Status__c && mr.Request_Status__c == 'Delivered') 
                && (mr.Materials_Stock__c == null || mr.Materials_Stock__c != null) && mr.Materials_Source__c == 'Vendor Purchase' 
                && (mr.Request_type__c == 'Library' || mr.Request_type__c == 'Stock')){
                
                mrRecords.add(mr);
            }
            
            // Added on Mar 03 2022 - Work Item: W-007376 - DODA GSA Materials Fee - New Field to add in the Materials Request
            if(Trigger.isInsert && rtIdNameMap.containsKey(mr.RecordTypeId) && rtIdNameMap.get(mr.RecordTypeId) == 'Project_Materials_Request' && mr.Project__c != null){
                projectMRs.add(mr);
                projectIds.add(mr.Project__c);
            }
        }
    }
    
    if(projectIds.size() > 0){
        Map<Id, AcctSeed__Project__c> projMap = new Map<Id, AcctSeed__Project__c>([SELECT Id, Name FROM AcctSeed__Project__c WHERE RecordType.DeveloperName = 'DODA_Projects']);
        if(projMap.size() > 0){
            System_Values__c gsaFeePercent = System_Values__c.getValues('GSA Fee Percentage');
            Decimal gsaFeePercentVal;
            if(gsaFeePercent != NULL && gsaFeePercent.Value__c != NULL){
                gsaFeePercentVal = Decimal.valueOf(gsaFeePercent.Value__c);
            }
            for(Materials_Request__c mr : projectMRs){
                if(projMap.containsKey(mr.Project__c)){
                    mr.GSA_Fee_Applicable__c = True;
                    mr.GSA_Fee_Percentage__c = gsaFeePercentVal;
                }
            }
        }
    }
    // Call MaterialsHandler class to create missing records before populating Materials Stock
    if(mrRecords.size() > 0){
        stockForLocationAndMaterialMap = MaterialsHandler.createMissingStockRecords(mrRecords);
    }
     
    //Added By Sangeetha G on June 08 2018 for Material Stock population
    if(materialIdSet.size() > 0 && (locationIdSet.size() > 0 || targetLocationIdSet.size() > 0)) {
        
        for(Materials_Stock__c stock : [ SELECT Id, Name, Location__c, Materials__c FROM Materials_Stock__c
                                                WHERE (Location__c IN : locationIdSet OR Location__c IN : targetLocationIdSet) 
                                                AND Materials__c IN :materialIdSet
                                                ]) {
        
            stockForLocationAndMaterialMap.put(stock.Location__c + '-' + stock.Materials__c, stock.Id); 
            stockIdNameMap.put(stock.Id,stock.Name);                                   
        
        }
        
        /*for(Materials_Request__c matRequest : [SELECT Id,Name,Materials_Stock__c,RecordTypeId FROM Materials_Request__c WHERE Materials_Stock__c != null AND Materials_Stock__c IN :stockForLocationAndMaterialMap.values()]){
            
            String mrKey = matRequest.Materials_Stock__c+'~'+matRequest.RecordTypeId;
            if(!stockId_RT_MRCntMap.containsKey(mrKey)) {
                stockId_RT_MRCntMap.put(mrKey,1);
            }else {
                stockId_RT_MRCntMap.put(mrKey,stockId_RT_MRCntMap.get(mrKey) + 1);
            }
        }*/
        
        // Modified by GRK to get the recent count from the MR record instead of the count of the MR record on 10/12/2018
        if( stockForLocationAndMaterialMap != null && stockForLocationAndMaterialMap.Values().size() > 0 ) {
            for(AggregateResult agg : [SELECT MAX(Stripped_Material_Request_Number__c) maxStrip,RecordTypeId recType,Materials_Stock__c  msId FROM Materials_Request__c 
                        WHERE 
                            Materials_Stock__c IN : stockForLocationAndMaterialMap.Values() 
                        GROUP BY 
                            Materials_Stock__c,RecordTypeId
                        ]) {
                Id msId = (Id) agg.get('msId');
                Id recType = (Id) agg.get('recType');
                Decimal count = (Decimal) agg.get('maxStrip');
                String tempKey = msId + '~' + recType;
                
                if(!stockId_RT_MRCntMap.containskey(tempKey)) {
                    stockId_RT_MRCntMap.put(tempKey,Integer.ValueOf(count));
                } else {
                    stockId_RT_MRCntMap.put(tempKey,Integer.ValueOf(count));
                }
            }
        }
        
        system.debug(':::::::stockIdNameMap::::'+stockIdNameMap);
        system.debug(':::::::stockId_RT_MRCntMap::::'+stockId_RT_MRCntMap);
    }
    system.debug(':::::::oppIdSet::::::;'+oppIdSet);
     
     
    List<Opportunity> oppolist = new List<Opportunity>();
    List<AcctSeed__Project__c> proolist = new List<AcctSeed__Project__c>(); 
    if(proIdSet != null){
        proolist = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',proIdSet,'');
        for(AcctSeed__Project__c pro : proolist) {
            if(!oppIdDlsclassRecMap.containsKey(pro.Id)) {
                oppIdDlsclassRecMap.put(pro.Id,pro.DLS_Ref__c);
            }
        }
    } 
     
    if(oppIdSet != null){
        oppolist = SObjectQueryService.SObjectQuery('Opportunity',oppIdSet,'');
        for(Opportunity opp : oppolist) {
    
            if(!oppIdDlsclassRecMap.containsKey(opp.Id)) {
                oppIdDlsclassRecMap.put(opp.Id,opp.DLS_Ref__c);
            }
            
            // Added to assign the Material Budget remaining values to the created Material Request Record.
            if(!oppIdMBRMap.containsKey(opp.Id)) {
                oppIdMBRMap.put(opp.Id,opp.Materials_Budget_Remaining__c);
            }
        }
    }
     // To form a map to capture the Remaining Amount in Project Task
    List<AcctSeed__Project_Task__c> projS = new List<AcctSeed__Project_Task__c>();
    if( projTIdMBRMap != null && projTIdMBRMap.size() > 0 ) {
        projS = SObjectQueryService.SObjectQuery('AcctSeed__Project_Task__c',projTIdMBRMap.keyset(),'');
        for( AcctSeed__Project_Task__c ap : projS ) {
            projTIdMBRMap.put(ap.Id,ap.Total_Remaining__c);
        }      
    }
    system.debug(':::::::oppIdDlsclassRecMap:::::'+oppIdDlsclassRecMap);
    
    // Added by Shalini on Aug 29 2017 for forming MaterialRequestNames like MR, ML based on RecordTypes
    
    Map<Id,Map<String,Integer>> matReqCount = MaterialRequestService.getMatReqCountbyOppAndRT(oppIdSet, proIdSet); 
    system.debug(':::matReqCount::'+matReqCount);
    
    if( Trigger.isbefore ) {
        
        for( Materials_Request__c mr : Trigger.new ) {
            
            if( stockForLocationAndMaterialMap != null && stockForLocationAndMaterialMap.containsKey(mr.Location__c + '-' + mr.Materials_Name__c) ){
                
                mr.Materials_Stock__c = stockForLocationAndMaterialMap.get(mr.Location__c + '-' + mr.Materials_Name__c);
                
                // Transfer & Disposal recor type related MR name population
                if(rtIdNameMap.get(mr.RecordTypeId) == 'Material_Disposal' || rtIdNameMap.get(mr.RecordTypeId) == 'Material_Transfer') {
                    
                    if(stockId_RT_MRCntMap.containsKey(mr.Materials_Stock__c +'~'+mr.RecordTypeId) && stockIdNameMap.containsKey(mr.Materials_Stock__c)){
                        
                        Integer currentCnt = stockId_RT_MRCntMap.get(mr.Materials_Stock__c +'~'+mr.RecordTypeId);
                        if(rtIdNameMap.get(mr.RecordTypeId) == 'Material_Disposal')
                            mr.Name = stockIdNameMap.get(mr.Materials_Stock__c)+'-DP-'+MaterialsHandler.appendZeroleft(currentCnt + 1,4);
                        else
                            mr.Name = stockIdNameMap.get(mr.Materials_Stock__c)+'-TF-'+MaterialsHandler.appendZeroleft(currentCnt + 1,4);
                            
                    }else if(!stockId_RT_MRCntMap.containsKey(mr.Materials_Stock__c +'~'+mr.RecordTypeId)){
                    
                        if(rtIdNameMap.get(mr.RecordTypeId) == 'Material_Disposal')
                            mr.Name = stockIdNameMap.get(mr.Materials_Stock__c)+'-DP-'+MaterialsHandler.appendZeroleft(1,4);
                        else
                            mr.Name = stockIdNameMap.get(mr.Materials_Stock__c)+'-TF-'+MaterialsHandler.appendZeroleft(1,4);
                    }
                }
                
                if(rtIdNameMap != null && rtIdNameMap.containsKey(mr.RecordTypeId) && rtIdNameMap.get(mr.RecordTypeId) == 'Material_Transfer') {
                    
                    mr.Target_Materials_Stock__c = stockForLocationAndMaterialMap.get(mr.Target_Location__c + '-' + mr.Materials_Name__c);

                } else {
                    //mr.Target_Materials_Stock__c = null;
                }
            } else {
            
                //mr.Materials_Stock__c = null;
            }
            
            // Material Request Name population for Loan & Order related RT
        
            if(Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(mr.Id).Project__c != mr.Project__c || Trigger.oldMap.get(mr.Id).Class_Name__c != mr.Class_Name__c))){
                String recType = rtIdNameMap.get(mr.RecordTypeId);
                if(mr.Project__c != null){
                    if(oppIdDlsclassRecMap.containsKey(mr.Project__c)) {
                        Integer newCount;
                        if(matReqCount.containsKey(mr.Project__c)) {
                            if(matReqCount.get(mr.Project__c).containsKey(recType)){
                                newCount = matReqCount.get(mr.Project__c).get(recType) + 1;
                                if(recType == 'Project_Materials_Request'){
                                    mr.Name = oppIdDlsclassRecMap.get(mr.Project__c)+'-MR'+newCount;
                                } else if(recType == 'Material_Loan_Request'){
                                    mr.Name = oppIdDlsclassRecMap.get(mr.Project__c)+'-ML'+newCount;
                                }
                                matReqCount.get(mr.Project__c).put(recType,newCount);
                            }else {
                                newCount = 1;
                                if(recType == 'Project_Materials_Request'){
                                    mr.Name = oppIdDlsclassRecMap.get(mr.Project__c)+'-MR'+newCount;
                                } else if(recType == 'Material_Loan_Request'){
                                    mr.Name = oppIdDlsclassRecMap.get(mr.Project__c)+'-ML'+newCount;
                                }
                                matReqCount.get(mr.Project__c).put(recType,newCount);
                            }
                            system.debug(':::::::mr:::::'+mr);
                        }else {
                            newCount = 1;
                            if(recType == 'Project_Materials_Request'){
                                mr.Name = oppIdDlsclassRecMap.get(mr.Project__c)+'-MR'+newCount;
                            } else if(recType == 'Material_Loan_Request'){
                                mr.Name = oppIdDlsclassRecMap.get(mr.Project__c)+'-ML'+newCount;
                            }
                            matReqCount.put(mr.Project__c,new Map<String,Integer>{recType => newCount});
                        }
                    }
                } else if(mr.Class_Name__c != null){
                    if(oppIdDlsclassRecMap.containsKey(mr.Class_Name__c)) {
                        Integer newCount;
                        if(matReqCount.containsKey(mr.Class_Name__c)) {
                            if(matReqCount.get(mr.Class_Name__c).containsKey(recType)){
                                newCount = matReqCount.get(mr.Class_Name__c).get(recType) + 1;
                                if(recType == 'Project_Materials_Request'){
                                    mr.Name = oppIdDlsclassRecMap.get(mr.Class_Name__c)+'-MR'+newCount;
                                } else if(recType == 'Material_Loan_Request'){
                                    mr.Name = oppIdDlsclassRecMap.get(mr.Class_Name__c)+'-ML'+newCount;
                                }
                                matReqCount.get(mr.Class_Name__c).put(recType,newCount);
                            } else {
                                newCount = 1;
                                if(recType == 'Project_Materials_Request'){
                                    mr.Name = oppIdDlsclassRecMap.get(mr.Class_Name__c)+'-MR'+newCount;
                                } else if(recType == 'Material_Loan_Request'){
                                    mr.Name = oppIdDlsclassRecMap.get(mr.Class_Name__c)+'-ML'+newCount;
                                }
                                matReqCount.get(mr.Class_Name__c).put(recType,newCount);
                            }
                            system.debug(':::::::mr:::::'+mr);
                        }else {
                            newCount = 1;
                            if(recType == 'Project_Materials_Request'){
                                mr.Name = oppIdDlsclassRecMap.get(mr.Class_Name__c)+'-MR'+newCount;
                            } else if(recType == 'Material_Loan_Request'){
                                mr.Name = oppIdDlsclassRecMap.get(mr.Class_Name__c)+'-ML'+newCount;
                            }
                            matReqCount.put(mr.Class_Name__c,new Map<String,Integer>{recType => newCount});
                        }
                    }
                }
            }
            if(Trigger.isInsert) {
                //System.debug('projTIdMBRMap::::'+projTIdMBRMap);
                //System.debug('oppIdMBRMap::::'+oppIdMBRMap);
                // To update Materials Budget Remaining
                if(projTIdMBRMap.containskey(mr.Project_Task__c)) {
                    mr.Materials_Budget_Remaining__c = projTIdMBRMap.get(mr.Project_Task__c);
                    projTIdMBRMap.put(mr.Project_Task__c, mr.Materials_Budget_Remaining__c - mr.DLS_Total__c);
                } else if(oppIdMBRMap.containskey(mr.Class_Name__c)) {
                    mr.Materials_Budget_Remaining__c = oppIdMBRMap.get(mr.Class_Name__c);
                    oppIdMBRMap.put(mr.Class_Name__c,mr.Materials_Budget_Remaining__c - mr.DLS_Total__c);
                }
            }
        }
    }
    
    if(Trigger.isAfter){
    
        Map<Id, Materials_Request__c> materialReqMap = new Map<Id, Materials_Request__c>();    
        Map<Id, Id> mrIdAndProjId = new Map<Id, Id>();
        
        for(Materials_Request__c mr : Trigger.new){
        
            if(Trigger.isUpdate && mr.Materials_Name_Formula__c != null && mr.Materials_Name_Formula__c == 'Student LMS Enrollment (Free)' && 
                mr.Request_Status__c != Trigger.oldMap.get(mr.Id).Request_Status__c && mr.Request_Status__c == 'Delivered' && mr.Project__c != null){
                
                mrIdAndProjId.put(mr.Id, mr.Project__c);
                materialReqMap.put(mr.Id, mr);  
            }
        }
        
        if(materialReqMap.size() > 0){
            
            MaterialsRequestTrigger_Handler.sendLMSEnrollmentEmail(materialReqMap, mrIdAndProjId);
        }
    }
}