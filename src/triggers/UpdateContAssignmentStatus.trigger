trigger UpdateContAssignmentStatus on AcctSeed__Project_Task__c (before insert, before update, after update, after insert, after delete) {
    Set<Id> ProjectTaskIdSet = new Set<Id>();
    
    //For OH, G&A & EESC Applied field values population from Custom Setting
    //Moved this logic from Manage Project Task page to here
    // By NS on FEB 14 2019
    System_Values__c OHDLS = System_Values__c.getValues('OH Applied - DLS-Site');
    System_Values__c OHNonDLS = System_Values__c.getValues('OH Applied - Non-DLS-Site');
    System_Values__c GANonICJ = System_Values__c.getValues('GA Applied - Non-ICJ'); 
    System_Values__c EESC = System_Values__c.getValues('EESC Applied'); 
    
    // static Map to store the Mapping for the Project Task Type and Default Cost Rate Rate Type field in Project Task
    Map<String,String> taskTypeWithRateTypeMap = new Map<String,String> {
        'Transcription (per hr)' =>  'Non-SCA Translation (Per Hour)',
        'Translation (per hr)' => 'Non-SCA Translation (Per Hour)',
        'Translation (per word)' => 'Non-SCA Translation (Per Word)',
        'Interpretation (per hr)' => 'Non-SCA Interpretation (Per Hour)',
        'Translation (per FFP)' => 'Non-SCA Translation (FFP)',
        'Interpretation (per FFP)' => 'Non-SCA Interpretation (FFP)'
    };
    Id transRTypeId = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Translation').getRecordTypeId();  
    Id langTrainRTId = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();  
    
    // Variable to update Assessment Report records
    //Set<Id> projIdsToUpdateARRs = new Set<Id>();
    Map<Id, List<AcctSeed__Project_Task__c>> projPTMapToCreateAR = new Map<Id,List<AcctSeed__Project_Task__c>>();
    
    // Variables to populate Revenue GL Account and Inventory GL Account
    Map<Id, Product2> productRec;
    Set<Id> proIds = new Set<Id>();
    
    // Variables to populate PC_Job_Code__c field in project task records
    Set<Id> projectIds = new Set<Id>();
    
    // Variables to populate GL Variable 1 field based on the related Project's QB_Classification__c field
    Set<Id> projIds = new Set<Id>();
    Map<Id, String> projIdAndClassification = new Map<Id, String>();
    Map<String, Id> accVarNameAndId = new Map<String, Id>();
    
    Map<Id, Id> projIdAndGLAV2IdMap = new Map<Id, Id>();
    Map<Id, Id> projIdWithGLV2ToUpdate = new Map<Id, Id>();
    
    
    Set<Id> prepProjIds = new Set<Id>();
    List<AcctSeed__Project_Task__c> prepProjectTasks = new List<AcctSeed__Project_Task__c>();
    
    Map<Id, Id> projTaskIdAndGLAV2Id = new Map<Id, Id>();
    
    
    if(Trigger.isDelete){
        
        for(AcctSeed__Project_Task__c pt : Trigger.old){
            
            if(Trigger.isAfter){
                
                if(pt.Project_Task_Type__c == 'Preparation time'){
                    prepProjIds.add(pt.Acctseed__Project__c);
                    prepProjectTasks.add(pt);
                }
            }
        }
    }else{
    
        for(AcctSeed__Project_Task__c Ptask : Trigger.new) {
            
            if(Trigger.isAfter && Trigger.isUpdate) {
                if((Trigger.oldmap.get(Ptask.Id).Total_Hours__c != Trigger.newmap.get(Ptask.Id).Total_Hours__c) || (Trigger.oldmap.get(Ptask.Id).Total_Qty_Invoiced__c != Trigger.newmap.get(Ptask.Id).Total_Qty_Invoiced__c)){
                
                    ProjectTaskIdSet.add(Ptask.Id);    
                }
                // Added By HL on Dec 14 2020
                // To update the Status of the Assessment Report to Cancelled when increase the Project Task's Total Qty Planned
                /* Commented since we started to create final reports for all hours related projects
                if(Ptask.RecordTypeId == langTrainRTId && Ptask.Project_Task_Type__c == 'Language Training' && !Ptask.Name.contains('Additional') && 
                    Ptask.Total_Qty_Planned__c != Trigger.oldMap.get(Ptask.Id).Total_Qty_Planned__c && Trigger.oldMap.get(Ptask.Id).Total_Qty_Planned__c < 300 &&
                    Ptask.Total_Qty_Planned__c > 300){
                    
                    projIdsToUpdateARRs.add(Ptask.AcctSeed__Project__c);
                }*/
                
                // To create new set of Assessment Reports when the hours used Language Training is updated
                if(Ptask.RecordTypeId == langTrainRTId && Ptask.Project_Task_Type__c == 'Language Training' && !Ptask.Name.contains('Additional') && Ptask.Total_Hours_Used_For_Language_Training__c != null &&
                    Ptask.Total_Hours_Used_For_Language_Training__c != Trigger.oldMap.get(Ptask.Id).Total_Hours_Used_For_Language_Training__c && !Ptask.Account_Name__c.contains('FSI') && Ptask.Project_Record_Type_Name__c != 'FSI_Projects' && 
                    ((Ptask.Total_Qty_Planned__c > 300 && !Ptask.Account_Name__c.contains('PGLS') && (!Ptask.Account_Name__c.contains('FCS') || Ptask.Account_Name__c.contains('FCS2'))) || 
                    (Ptask.Account_Name__c.contains('PGLS') && ((Trigger.oldMap.get(Ptask.Id).Total_Hours_Used_For_Language_Training__c < 150 && Ptask.Total_Hours_Used_For_Language_Training__c >= 150 ) || 
                    (Trigger.oldMap.get(Ptask.Id).Total_Hours_Used_For_Language_Training__c < 350 && Ptask.Total_Hours_Used_For_Language_Training__c >= 350))))){ // W-007432 to create Midterm reports for the DEA Projects
                    
                    if(!projPTMapToCreateAR.containskey(Ptask.AcctSeed__Project__c)) {
                        projPTMapToCreateAR.put(Ptask.AcctSeed__Project__c, new List<AcctSeed__Project_Task__c>{Ptask});
                    } else {
                        projPTMapToCreateAR.get(Ptask.AcctSeed__Project__c).add(Ptask);
                    }                
                }
                
                if(Ptask.AcctSeed__GL_Account_Variable_2__c != Trigger.oldMap.get(Ptask.Id).AcctSeed__GL_Account_Variable_2__c){
                   projTaskIdAndGLAV2Id.put(Ptask.Id, Ptask.AcctSeed__GL_Account_Variable_2__c);
                }
            }
            
            // Added by HL on Oct 14 2019
            // To populate PC Job Code field in project task records
            // Work Item : W-002986 - Create text field on Project Task object labeled "PC Job Code"
            if(Trigger.isAfter && Trigger.isInsert){
                
                if(Ptask.AcctSeed__Project__c != NULL){
                    projectIds.add(Ptask.AcctSeed__Project__c);
                }
                
                if(Ptask.Project_Task_Type__c == 'Preparation time'){
                    prepProjIds.add(Ptask.Acctseed__Project__c);
                    prepProjectTasks.add(Ptask);
                }
            }
            
            //For Applied field value population
            if(Trigger.isBefore && Trigger.isInsert) {
                
                //  Added by HL on Dec 19 2019
                // Work Item : W-002702 - Payable related changes
                // Added GLAV2 By Dhinesh - 24/11/2021 - W-007183
                if((Ptask.AcctSeed__GL_Account_Variable_1__c == NULL || Ptask.AcctSeed__GL_Account_Variable_2__c == NULL) && Ptask.AcctSeed__Project__c != NULL){
                
                    projIds.add(Ptask.AcctSeed__Project__c);
                }
                
                // For OH Applied
                if(Ptask.Project_Training_Location_RT_Name__c == 'DLS_Site' && OHDLS != null && OHDLS.Value__c != null){
                    Ptask.OH_Applied__c = Decimal.ValueOf(OHDLS.Value__c);
                } else if(Ptask.Project_Training_Location_RT_Name__c != 'DLS_Site' && OHNonDLS != null && OHNonDLS.Value__c != null){
                    Ptask.OH_Applied__c = Decimal.ValueOf(OHNonDLS.Value__c);
                }
                
                //G&A Applied
                if(Ptask.Project_Record_Type_Name__c != 'Admin_Projects' && GANonICJ != null && GANonICJ.Value__c != null){
                    Ptask.G_A_Applied__c = Decimal.ValueOf(GANonICJ.Value__c);
                }
                
                //EESC Applied
                if(EESC != null && EESC.Value__c != null){
                    Ptask.EESC_Applied__c = Decimal.ValueOf(EESC.Value__c);
                }
                
                //to assign Default Cost Rate Rate Type field in Project Task based on the Project Task Type
                if(Ptask.RecordTypeId == transRTypeId && Ptask.Project_Task_Type__c != null && taskTypeWithRateTypeMap.containskey(Ptask.Project_Task_Type__c)) {
                    Ptask.Default_Cost_Rate_Rate_Type__c = taskTypeWithRateTypeMap.get(Ptask.Project_Task_Type__c);
                }
            }
            
            if(Trigger.isBefore && Trigger.isUpdate) {
                //to assign Default Cost Rate Rate Type field in Project Task based on the Project Task Type
                if( ( Ptask.RecordTypeId != Trigger.oldMap.get(Ptask.Id).RecordTypeId || Ptask.Project_Task_Type__c != Trigger.oldMap.get(Ptask.Id).Project_Task_Type__c ) && Ptask.RecordTypeId == transRTypeId  ) {
                    if(Ptask.Project_Task_Type__c != null && taskTypeWithRateTypeMap.containskey(Ptask.Project_Task_Type__c)) {
                        Ptask.Default_Cost_Rate_Rate_Type__c = taskTypeWithRateTypeMap.get(Ptask.Project_Task_Type__c);
                    } 
                } 
                
                //To update the Bill.com Last Sync Status - if the account is updated after bill.com sync update status to Pending
                if((Ptask.Bill_com_Sync_Status__c == 'Success' || Ptask.Bill_com_Sync_Status__c == 'Failure') 
                    && !BillDotComUtil.updateFromBillDotComSync){
                    
                    Ptask.Bill_com_Sync_Status__c = 'Pending';
                }
            }
            
            // Added by HL on Oct 08 2019
            // Work Item : W-002992 - Revenue GL Account field auto-population on Opportunity Product Line Item and Project Task
            // To populate Revenue GL Account and Inventory GL Account
            if(Trigger.isBefore){
                if(Ptask.Product__c != NULL && (Trigger.isInsert || (Trigger.isUpdate && Ptask.Product__c != Trigger.oldMap.get(Ptask.Id).Product__c))){
                    proIds.add(Ptask.Product__c);
                }
            }
            
            if(Trigger.isAfter && Trigger.isUpdate){
                if(!UpdateContAssignStatusAsEnded.projTaskStaticIdSet.contains(Ptask.Id)
                   && Ptask.AcctSeed__GL_Account_Variable_2__c != Trigger.oldMap.get(Ptask.Id).AcctSeed__GL_Account_Variable_2__c){
                    
                    projIdWithGLV2ToUpdate.put(Ptask.AcctSeed__Project__c, Ptask.AcctSeed__GL_Account_Variable_2__c);
                    UpdateContAssignStatusAsEnded.projTaskStaticIdSet.add(Ptask.Id);
                }
            }
        }
        
        if(projIds != NULL && projIds.size() > 0){
        
            for(AcctSeed__Project__c p : [SELECT Id, RecordTypeId, RecordType.DeveloperName, AcctSeed__Account__r.Name, QB_Contract_Type__c, QB_Classification__c, GL_Variable_2__c FROM AcctSeed__Project__c WHERE Id IN : projIds]){
                        
                if(String.isNotBlank(p.QB_Classification__c)){
                
                    projIdAndClassification.put(p.Id, p.QB_Classification__c);
                }
                
                Id glV2 = p.GL_Variable_2__c != null ? p.GL_Variable_2__c : UpdateContAssignStatusAsEnded.getGLVariable2IdForProject(p);            
                projIdAndGLAV2IdMap.put(p.Id, glV2);
                
                if(p.GL_Variable_2__c == null){
                    projIdWithGLV2ToUpdate.put(p.Id, glV2);
                }
            }
            
            if(projIdAndClassification != NULL && projIdAndClassification.size() > 0){
            
                for(AcctSeed__Accounting_Variable__c a : [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c WHERE Name IN : projIdAndClassification.values() AND AcctSeed__Type__c = 'GL Account Variable 1' AND AcctSeed__Active__c = TRUE]){
                
                    accVarNameAndId.put(a.Name, a.Id);
                }
            }
        }
    
        if(proIds.size() > 0){
    
            productRec = new Map<Id, Product2>([SELECT Id, AcctSeed__Revenue_GL_Account__c, AcctSeed__Inventory_GL_Account__c FROM Product2 WHERE Id IN :proIds]);
        }
           
        if(Trigger.isBefore){
        
            for( AcctSeed__Project_Task__c t : trigger.new ) {
        
                if(t.Product__c != NULL && productRec != NULL && productRec.containsKey(t.Product__c)){
                    t.Revenue_GL_Account__c = productRec.get(t.Product__c).AcctSeed__Revenue_GL_Account__c;
                    t.Inventory_GL_Account__c = productRec.get(t.Product__c).AcctSeed__Inventory_GL_Account__c;
                }
                
                if(Trigger.isInsert && t.AcctSeed__GL_Account_Variable_1__c == NULL && t.AcctSeed__Project__c != NULL && projIdAndClassification.containsKey(t.AcctSeed__Project__c) && 
                    accVarNameAndId.containsKey(projIdAndClassification.get(t.AcctSeed__Project__c))){
                
                    t.AcctSeed__GL_Account_Variable_1__c = accVarNameAndId.get(projIdAndClassification.get(t.AcctSeed__Project__c));
                }
                
                if(Trigger.isInsert && t.AcctSeed__GL_Account_Variable_2__c == NULL && t.AcctSeed__Project__c != NULL ){
                    t.AcctSeed__GL_Account_Variable_2__c = projIdAndGLAV2IdMap.get(t.AcctSeed__Project__c);
                }
            }
        }   
    }
    /* Commented since we started to create final reports for all hours related projects
    System.debug('::::projIdsToUpdateARRs::::'+projIdsToUpdateARRs);
    if(projIdsToUpdateARRs != NULL && projIdsToUpdateARRs.size() > 0){
        
        Assessment_Report_Helper.updateStatusOfARRs(projIdsToUpdateARRs);
    }*/
    System.debug('projPTMapToCreateAR:::::'+projPTMapToCreateAR);
    if(projPTMapToCreateAR != null && projPTMapToCreateAR.size() > 0) {
        Assessment_Report_Helper.createHoursbasedTR(projPTMapToCreateAR,Trigger.OldMap);
    }
    
    if(ProjectTaskIdSet != null && ProjectTaskIdSet.size() > 0){
        UpdateContAssignStatusAsEnded updateContAssign = new UpdateContAssignStatusAsEnded();
        updateContAssign.updateStatusUponClientPartnerEnded(ProjectTaskIdSet);    
    }
    
    List<AcctSeed__Project__c> projToUpdate = new List<AcctSeed__Project__c>();
    if(projectIds.size() > 0 && Trigger.isInsert && Trigger.isAfter){
        
        Map<Id, AcctSeed__Project__c> projectRec = new Map<Id, AcctSeed__Project__c>([SELECT Id, DLS_Class__c, RecordType.DeveloperName,CreatedDate,Registration_Fee__c FROM AcctSeed__Project__c WHERE ID IN :projectIds]);
        List<AcctSeed__Project_Task__c> updateProjTaskRecs = new List<AcctSeed__Project_Task__c>();
        
        for(AcctSeed__Project_Task__c t : Trigger.new){
        
            if(t.AcctSeed__Project__c != NULL && projectRec.containsKey(t.AcctSeed__Project__c)){
                
                AcctSeed__Project_Task__c newPT = new AcctSeed__Project_Task__c();
                newPT.Id = t.Id;
                
                // Modified By HL on July 24 2020
                // Work Item : W-005757 - New concat for PC Job Code
                if(projectRec.get(t.AcctSeed__Project__c).RecordType.DeveloperName == 'DLI_W_LT_Projects'){
                    newPT.PC_Job_Code__c = projectRec.get(t.AcctSeed__Project__c).DLS_Class__c+'-DLI-'+t.Id;
                }else{
                    newPT.PC_Job_Code__c = projectRec.get(t.AcctSeed__Project__c).DLS_Class__c+'-'+t.Id;
                }
                updateProjTaskRecs.add(newPT);
                
                if(t.Name.contains('Registration Fee') && projectRec.get(t.AcctSeed__Project__c).Registration_Fee__c != True) { 
                    AcctSeed__Project__c pr = projectRec.get(t.AcctSeed__Project__c);
                    pr.Registration_Fee__c = true;
                    projToUpdate.add(pr);
                }
            }
        }
        System.debug(':::updateProjTaskRecs::::'+updateProjTaskRecs);
        
        if(updateProjTaskRecs.size() > 0){
        
            update updateProjTaskRecs;
        }
        System.debug('projToUpdate:::'+projToUpdate);
        if(projToUpdate.size() > 0) {
            update projToUpdate;
        }
    } 
        
    // Logic moved in to Time Card Day Trigger
    /*
    // Added By HL on June 09 2020
    if(Trigger.isAfter && Trigger.isUpdate){
     
        Map<Id, Date> projtaskIdAndLastModifiedDate = new Map<Id, Date>();
        
        for(AcctSeed__Project_Task__c pt : Trigger.new){
            
            if(pt.Total_Hours_Used_For_Language_Training__c != Trigger.oldMap.get(pt.Id).Total_Hours_Used_For_Language_Training__c){
            
                projtaskIdAndLastModifiedDate.put(pt.Id, Date.valueOf(pt.LastModifiedDate));
            }    
        }
        System.debug('::::projtaskIdAndLastModifiedDate::::::'+projtaskIdAndLastModifiedDate);
        
        if(projtaskIdAndLastModifiedDate.size() > 0) {
            timeCardRelated_Email_Controller.weeklyApprovedNotificationToInstructor(projtaskIdAndLastModifiedDate);
        }
    }
    */
    if(projIdWithGLV2ToUpdate.size() > 0){
        UpdateContAssignStatusAsEnded.updateProjAndProjTaskGLV2Field(projIdWithGLV2ToUpdate);
    }    
    
    if(prepProjIds.size() > 0 && prepProjectTasks.size() > 0){
        UpdateContAssignStatusAsEnded.lTWith_withoutPrepEmailAlert(prepProjIds, prepProjectTasks);    
    }
    
    if(projTaskIdAndGLAV2Id.size() > 0){
        UpdateContAssignStatusAsEnded.populateGLAV2InTCDs(projTaskIdAndGLAV2Id);
    }
}