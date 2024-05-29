public class UpdateContAssignStatusAsEnded{
    
    public static Map<String, Id> glVariableNameWithIdMap;
    public static Map<String,Project_Task_GL_Variable_Mapping__c> glVariableNameWithMappingRec;
    public static Map<String, List<Project_Task_GL_Variable_Mapping__c>> projRecordTypeNameWithMappingRecMap;
    public static Set<Id> projTaskStaticIdSet = new Set<Id>();
    public Static Map<Id, Account> accountIdWithRecMap;
    public Static Map<Id, String> projRTIdWithDeveloperNameMap;
    public static Set<Id> projectStaticIdSet = new Set<Id>();
    
    public void updateStatusUponClientPartnerEnded(Set<Id> ProjectTaskIdSet) {
    
        List<Contact_Assignments__c> UpdatedContAssignmentsList = new List<Contact_Assignments__c>();
        
        if(ProjectTaskIdSet != null && ProjectTaskIdSet.size() > 0){
            for(AcctSeed__Project_Task__c pt: [
            
                SELECT Id,Name,Total_Hours__c,Total_Qty_Invoiced__c,AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Status__c,
                (SELECT Id,Name,RecordTypeId,RecordType.DeveloperName FROM Contact_Assignments__r 
                WHERE Project_Task__c != null AND RecordType.DeveloperName = 'Client_Partner' AND Status__c != 'Ended') 
                FROM AcctSeed__Project_Task__c 
                WHERE Id IN:ProjectTaskIdSet AND AcctSeed__Project__r.AcctSeed__Status__c = 'Ended'
                
            ]){
                system.debug('pt:::'+pt);
                if(pt.Total_Hours__c != null && pt.Total_Qty_Invoiced__c != null && pt.Total_Hours__c == pt.Total_Qty_Invoiced__c){
                
                    for(Contact_Assignments__c conAssign : pt.Contact_Assignments__r){
                        system.debug('conAssign:::'+conAssign);
                        conAssign.Status__c = pt.AcctSeed__Project__r.AcctSeed__Status__c;
                        UpdatedContAssignmentsList.add(conAssign);   
                    }
                }
            
            }
        
        }
        
        if(UpdatedContAssignmentsList != null && UpdatedContAssignmentsList.size() > 0)
            update UpdatedContAssignmentsList;
        
    }
    
    public static Id getGLVariable2IdForProject(AcctSeed__Project__c proj){
        Id glVariable2Id;
        
        if(glVariableNameWithIdMap == null){
            getGLVariableNameWithIdMap();
        }
        
        String projRT = projRTIdWithDeveloperNameMap.get(proj.RecordTypeId);
        String accName = proj.AcctSeed__Account__r.Name != null ? proj.AcctSeed__Account__r.Name : ((accountIdWithRecMap != null && accountIdWithRecMap.get(proj.AcctSeed__Account__c) != null) ? accountIdWithRecMap.get(proj.AcctSeed__Account__c).Name : null);
        
        if(projRT != null && projRecordTypeNameWithMappingRecMap.get(projRT) != null){
            String glVariableName;
            for(Project_Task_GL_Variable_Mapping__c glvm : projRecordTypeNameWithMappingRecMap.get(projRT)){
                if(String.isNotBlank(glvm.Account__c)){
                    List<String> accountNameList = glvm.Account__c.split(',');                    
                    if(glvm.Account_Condition__c == '=' && accName != null){
                         
                        if(accountNameList.contains(accName)){
                            glVariableName = getGLVariableNameBasedOnQBClassificationOrContractType(proj, glvm);
                        }                    
                    }else if(glvm.Account_Condition__c == '!=' && accName != null){
                        
                        if(!accountNameList.contains(accName)){                            
                            glVariableName = getGLVariableNameBasedOnQBClassificationOrContractType(proj, glvm);
                        }
                    }else if(glvm.Account_Condition__c == 'LIKE'){
                        for(String acc : accountNameList){
                            if( accName != null && accName.containsIgnoreCase(acc)){
                                glVariableName = getGLVariableNameBasedOnQBClassificationOrContractType(proj, glvm);
                                break;
                            }
                        }
                    }else{
                        Boolean isValid = true;
                        for(String acc : accountNameList){
                            if( accName != null && accName.containsIgnoreCase(acc)){
                                isValid = false;
                            }
                        }
                        
                        if(isValid){
                            glVariableName = getGLVariableNameBasedOnQBClassificationOrContractType(proj, glvm);
                        }
                    }
                }else{                
                    glVariableName = glvm.GL_Variable_Name__c;
                }
                
                if(String.isNotBlank(glVariableName)){
                    break;
                }
            }
            
            if(String.isNotBlank(glVariableName) && glVariableNameWithIdMap.get(glVariableName) != null){
                glVariable2Id = glVariableNameWithIdMap.get(glVariableName);
            }
        }
        
        return glVariable2Id;
    }
    
    public static void getGLVariableNameWithIdMap(){
        glVariableNameWithMappingRec = Project_Task_GL_Variable_Mapping__c.getAll();
        glVariableNameWithIdMap = new Map<String, Id>();
        projRecordTypeNameWithMappingRecMap = new Map<String, List<Project_Task_GL_Variable_Mapping__c>>();
        projRTIdWithDeveloperNameMap = new Map<Id, String>();
        
        for(AcctSeed__Accounting_Variable__c av : [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c 
                                                  WHERE Name IN :glVariableNameWithMappingRec.keySet() AND AcctSeed__Type__c = 'GL Account Variable 2' 
                                                  AND AcctSeed__Active__c = TRUE]){
            
            glVariableNameWithIdMap.put(av.Name, av.Id);                                              
        }
        
        for(Project_Task_GL_Variable_Mapping__c glvm: glVariableNameWithMappingRec.values()){
            for(String rt : glvm.Project_Record_Type__c.split(',')){
                if(!projRecordTypeNameWithMappingRecMap.containsKey(rt)){
                    projRecordTypeNameWithMappingRecMap.put(rt, new List<Project_Task_GL_Variable_Mapping__c>());
                }
                projRecordTypeNameWithMappingRecMap.get(rt).add(glvm);
            }
        }   
        
         
        Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Acctseed__Project__c.getRecordTypeInfosById(); 
        for(Id rtId : rtMapById.keySet()){
            projRTIdWithDeveloperNameMap.put(rtId, rtMapById.get(rtId).getDeveloperName());
        }                
    }
    
    public static String getGLVariableNameBasedOnQBClassificationOrContractType(Acctseed__Project__c proj, Project_Task_GL_Variable_Mapping__c glvm){
  
        String glVariableName;
        if(glvm.QB_Classification__c != null && glvm.QB_Classification_Condition__c == '=' && proj.QB_Classification__c == glvm.QB_Classification__c){
            glVariableName = glvm.GL_Variable_Name__c;
        }else if(glvm.QB_Classification__c != null && glvm.QB_Classification_Condition__c == '!=' && proj.QB_Classification__c != glvm.QB_Classification__c){
            glVariableName = glvm.GL_Variable_Name__c;
        }else if(glvm.QB_Contract_Type__c != null && glvm.QB_Contract_Type_Condition__c == '=' && proj.QB_Contract_Type__c == glvm.QB_Contract_Type__c){            
            glVariableName = glvm.GL_Variable_Name__c;
        }else if(glvm.QB_Contract_Type__c != null && glvm.QB_Contract_Type_Condition__c == '!=' && proj.QB_Contract_Type__c != glvm.QB_Contract_Type__c){
            glVariableName = glvm.GL_Variable_Name__c;
        }else if(glvm.QB_Classification__c == null && glvm.QB_Contract_Type__c == null){
            glVariableName = glvm.GL_Variable_Name__c;
        }
        return glVariableName;
    }
    
    public static void updateProjAndProjTaskGLV2Field(Map<Id, Id> projIdWithGLV2ToUpdate){
        List<Acctseed__Project__c> projToUpdate = new List<Acctseed__Project__c>();
        List<AcctSeed__Project_Task__c> projTaskToUpdate = new List<AcctSeed__Project_Task__c>();
        
        for(Acctseed__Project__c proj : [SELECT Id, GL_Variable_2__c, (SELECT Id, AcctSeed__GL_Account_Variable_2__c FROM AcctSeed__Project_Tasks__r WHERE Id NOT IN :projTaskStaticIdSet) FROM Acctseed__Project__c WHERE Id IN :projIdWithGLV2ToUpdate.keySet()]){
            if(!projectStaticIdSet.contains(proj.Id)){
                if(proj.GL_Variable_2__c != projIdWithGLV2ToUpdate.get(proj.Id)){
                    proj.GL_Variable_2__c = projIdWithGLV2ToUpdate.get(proj.Id);
                    projToUpdate.add(proj);
                    projectStaticIdSet.add(proj.Id);
                }
            }
            for(AcctSeed__Project_Task__c projTask : proj.AcctSeed__Project_Tasks__r){
                if(projTask.AcctSeed__GL_Account_Variable_2__c != projIdWithGLV2ToUpdate.get(proj.Id)){
                    projTask.AcctSeed__GL_Account_Variable_2__c = projIdWithGLV2ToUpdate.get(proj.Id);
                    projTaskToUpdate.add(projTask);
                    UpdateContAssignStatusAsEnded.projTaskStaticIdSet.add(projTask.Id);
                }
            }
        }
        
        if(projToUpdate.size() > 0){
            update projToUpdate;
        }
        if(projTaskToUpdate.size() > 0){
            update projTaskToUpdate;
        }
    }
    
    /***************
        - W-007692 : Email Notification Request
        - To send an email notification to accounting group and HR users when someone adds the Preparation Project task to the Project where the Default Cost rate as "LT without Prep" or remove the Preparation project task where the Default Cost rate as "LT with Prep"
        *************/
    public static void lTWith_withoutPrepEmailAlert(Set<Id> prepProjIds, List<AcctSeed__Project_Task__c> prepProjectTasks){
        
        Map<Id, Acctseed__Project__c> projMap = new Map<Id, Acctseed__Project__c>([SELECT Id, Name, Default_Cost_Rate_Rate_Type__c FROM Acctseed__Project__c WHERE Id IN : prepProjIds]);
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        
        try{            
            String orgWideEmailId = ProjectTrigger_Handler.getOrgWideEmailId('support@dlsdc.com');
            List<String> toAddresses = ProjectTrigger_Handler.getSystemValuesList('LT With_without Prep Email To Address');
            
            String subject = 'Default Cost Rate Alert';
            String starting_Content = 'Hello '+ ', <br/><br/>';
            starting_Content += 'Following Project found with Default Cost Rate mismatched with Project Task(s) in the Project. Please, check and fix the issue.<br/>';
            String ending_Content = 'Thank you,<br/><br/>System Generated Email<br/>';
            
            for(AcctSeed__Project_Task__c pt : prepProjectTasks){
                
                if(projMap.containsKey(pt.AcctSeed__Project__c)){
                    
                    // W-008006 : Default Cost Rate and Project Task Mismatch
                    Acctseed__Project__c proj = projMap.get(pt.AcctSeed__Project__c);
                    if(((proj.Default_Cost_Rate_Rate_Type__c == 'LT without Prep' || proj.Default_Cost_Rate_Rate_Type__c == 'LT without Billable Prep') && Trigger.isInsert) || 
                        ((proj.Default_Cost_Rate_Rate_Type__c == 'LT with Prep' || proj.Default_Cost_Rate_Rate_Type__c == 'LT with Billable Prep') && Trigger.isDelete)){
                        
                        String proj_URL = '<br/><a href="'+ System.Label.Org_Prefix_Start_URL +'/lightning/r/AcctSeed__Project__c/' + proj.Id +'/view" target="_blank">'+ proj.Name +'</a><br/><br/>';
                        String dynamicContent = '';
                        dynamicContent += starting_Content;
                        dynamicContent += proj_URL;
                        dynamicContent += ending_Content;
                                
                        Messaging.SingleEmailMessage mail = ProjectTrigger_Handler.getSingleEmail(orgWideEmailId, '', toAddresses, new List<String>(), '', '', dynamicContent, subject, true, false);
                        sendEmailList.add(mail);
                    }
                }    
            }
            if(sendEmailList.size() > 0) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailList);
            }
        }catch(Exception e) {
                            
            String errorMessage = '';
            errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
            
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on LT With_without Prep Email Alert');
        }       
    }
    
    /*********
        - W-007786 : GLAV2 Missing on TCDs
        - To populate GLAV2 value in time card days if project task's GLAV2 value is filled after TCD creation
        ********/
    public static void populateGLAV2InTCDs(Map<Id, Id> projTaskIdAndGLAV2Id){
        
        List<AcctSeed__Time_Card_Day__c> updateTCDs = new List<AcctSeed__Time_Card_Day__c>();
        
        for(AcctSeed__Time_Card_Day__c t : [SELECT Id, GL_Variable_2__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Day__c WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c IN : projTaskIdAndGLAV2Id.keySet() AND GL_Variable_2__c = null]){
           
           if(projTaskIdAndGLAV2Id.containsKey(t.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c) && t.GL_Variable_2__c != projTaskIdAndGLAV2Id.get(t.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c)){
           
                t.GL_Variable_2__c = projTaskIdAndGLAV2Id.get(t.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c);
                updateTCDs.add(t);
            }
        }
        
        if(updateTCDs.size() > 0){
            update updateTCDs;
        }
    }
}