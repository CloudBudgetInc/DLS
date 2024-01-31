global class ProjectTaskCreationContr{ 
    
    public class InitialParameters {
        public List<AcctSeed__Project_Task__c> proTaList;
        //public Decimal OHApplied; 
        //public Decimal GAApplied;  
    }
    
    @RemoteAction
    public static InitialParameters projecttask(String projId){ 
        Set<String> projRT = new Set<String>();
        //Map<String,String> projRTMap = new Map<String,String>{'Admin_Projects' => 'Internal Cost Jobs','Test' => 'Test'};
        List<AcctSeed__Project_Task__c> proList = new List<AcctSeed__Project_Task__c>();
        Set<String> ExitaskSet = new Set<String>();
        Map<String,Id> rectypeMap = new Map<String,Id>();       
        List<Project_Task_Master__c> masterPTList = new List<Project_Task_Master__c>();
        String recdevname;
        String protmasRT;
        List<String> multiprorecRT = new List<String>(); 
        /*Decimal OHValue; 
        Decimal GAValue;    
        Decimal EESCValue;*/
        
          
        List<RecordType> rtTypeList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName('','AcctSeed__Project_Task__c',new Set<String>{});
        for(RecordType rtType : rtTypeList){
            if(!rectypeMap.containsKey(rtType.DeveloperName))
                rectypeMap.put(rtType.DeveloperName, rtType.Id);
        }
        system.debug(';;rectypeMap;;;;;;'+rectypeMap);
        
        //Added by vinitha on Apr 26,2017
        //To query project record type by using project_Task_Master__c Custom Setting
        
        if(projId != null){
        
            masterPTList = [Select Id,Name,Project_Type__c, Unit__c, Project_Task_Type__c, Project_Task_Record_Type__c, Display_In_Time_Card__c, Sort_Order__c, Project_Record_Type__c, Billable__c, OH_Applied__c, G_A_Applied__c From Project_Task_Master__c]; 
            system.debug(':::masterPTList ::'+masterPTList );
            for(Project_Task_Master__c pt : masterPTList){
                
                protmasRT = pt.Project_Record_Type__c;
                if(protmasRT != null && protmasRT.contains(';')){
                    multiprorecRT = protmasRT.Split(';'); 
                    
                    for(String a : multiprorecRT){
                       projRT.add(a);    
                    }     
                }    
                projRT.add(protmasRT);                
            }  
        }
               
        List<AcctSeed__Project__c> proj = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',new Set<Id>{projId},',RecordType.DeveloperName,Language__r.Name,Training_Location__r.RecordType.DeveloperName');
        
        List<Project_Task_Master__c> projTasklist = new List<Project_Task_Master__c>();
        
        if(masterPTList.size() > 0){
            //Applied field population logic moved to PR Trigger
            //By NS on FEB 14 2019
            
            /*System_Values__c OHDLS = System_Values__c.getValues('OH Applied - DLS-Site');
            System_Values__c OHNonDLS = System_Values__c.getValues('OH Applied - Non-DLS-Site');
            System_Values__c GANonICJ = System_Values__c.getValues('GA Applied - Non-ICJ'); 
            System_Values__c EESC = System_Values__c.getValues('EESC Applied');
            
            if(proj[0].Training_Location__c != null){
                if(proj[0].Training_Location__r.RecordType.DeveloperName == 'DLS_Site'){
                    OHValue = Decimal.ValueOf(OHDLS.Value__c);
                } else {
                    OHValue = Decimal.ValueOf(OHNonDLS.Value__c);
                }
            }
            if(proj[0].RecordType.DeveloperName != 'Admin_Projects'){
                GAValue = Decimal.ValueOf(GANonICJ.Value__c);    
            }
            
            if(EESC != null && EESC.Value__c != null){
                EESCValue = Decimal.ValueOf(EESC.Value__c);
            }*/
            
            List<AcctSeed__Project_Task__c> proTaskList = ProjectTaskService.getProjectTasksByProjIdsAndProjTaskTypes(new Set<Id>{projId},new Set<String>{},'',', CLIN__r.Name, Parent_Project_Task__r.Name'); 
                        
            for(AcctSeed__Project_Task__c act : proTaskList){
                proList.add(act);
                ExitaskSet.add(act.Name);
            }
               
            for(Project_Task_Master__c pt : masterPTList ){
                
                if(pt.Project_Record_Type__c != null && pt.Project_Record_Type__c.Contains(proj[0].RecordType.DeveloperName))
                {
                    if(pt.Name == 'Language Training- {Language}'){
                        if(!ExitaskSet.contains('Language Training- '+proj[0].Language__r.Name)){    
                            projTasklist.add(pt);
                        }
                    } else {
                        projTasklist.add(pt);
                    }
                    
                }          
            }
            
            for(Project_Task_Master__c pt : projTasklist ){ 
                AcctSeed__Project_Task__c pro = new AcctSeed__Project_Task__c();               
                if(!ExitaskSet.Contains(pt.Name)) {
                    if(pt.Name == 'Language Training- {Language}'){
                        if(proj[0].Language__c != null){                   
                            pro.Name = 'Language Training- '+proj[0].Language__r.Name;
                        }
                    } else { 
                        pro.Name = pt.Name;
                    }
                    //pro.OH_Applied__c = OHValue;
                    pro.Project_Task_Type__c = pt.Project_Task_Type__c;
                    pro.Unit__c = pt.Unit__c;
                    pro.AcctSeed__Project__c = projId;
                    pro.RecordTypeId = rectypeMap.containsKey(pt.Project_Task_Record_Type__c)?rectypeMap.get(pt.Project_Task_Record_Type__c):null;
                    pro.AcctSeed__Display_in_Time_Card__c = pt.Display_In_Time_Card__c;
                    pro.AcctSeed__Sort_Order__c = pt.Sort_Order__c;
                    pro.Billable__c = pt.Billable__c;
                    pro.Language_LU__c = proj[0].Language__c;
                    //pro.G_A_Applied__c = GAValue;
                    //pro.EESC_Applied__c = EESCValue;
                    
                    proList.add(pro);
                }
            }
        }    
        system.debug('::proList::::::'+proList);
        InitialParameters init = new initialParameters();
        init.proTaList = proList;
        //init.OHApplied = OHValue;
        //init.GAApplied = GAValue;
        
        return init;        
    }
    
    @RemoteAction
    global static List<String> picklistvalues(String ObjectName, String PickListName){
        List<String> payrollList = StudentTestResult_ReportPage_Controller.PicklistValues(ObjectName, PickListName);
        return payrollList;  
    }
    
    @RemoteAction
    global static Boolean checkRecordTypeName(String projId){
        System.debug('projId=================='+projId);
        Boolean isTransInterpretationProj ;
        AcctSeed__Project__c project= [SELECT Id, Name, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id =:projId];
        if(project.RecordType.DeveloperName == 'Translation_Projects' || project.RecordType.DeveloperName == 'Interpretation_Projects'){
            isTransInterpretationProj = TRUE;
        }else{
            isTransInterpretationProj = FALSE;
        }
        return isTransInterpretationProj ;  
    }
    
    @RemoteAction
    global static String createprojecttask(List<AcctSeed__Project_Task__c> accprtList){
        
        try {
            List<AcctSeed__Project_Task__c> projTaskList = ProjectTaskService.upsertProjectTask(accprtList);
            return 'Inserted';
        } catch (Exception ex) {
            system.debug('::ex::::'+ex);
            return 'Failed';
        } 
    }
    
    @RemoteAction
    global static Map<Id,String> laborrec(String laborJson){
        List<Id> lablist = (List<Id>) System.JSON.deserialize(laborJson, List<Id>.class);
        Map<Id,String> laboraccMap = new Map<Id,String>();
        Set<Id> laborset = new Set<Id>(lablist);
        system.debug('::lablist::::'+lablist);
        List<AcctSeed__GL_Account__c> laborList = SObjectQueryService.SObjectQuery('AcctSeed__GL_Account__c',laborSet,'');
        system.debug('::::laborList'+laborList);
        for(AcctSeed__GL_Account__c at : laborList){
                laboraccMap.put(at.Id,at.Name);
                system.debug('::::at.Name:'+laboraccMap);
            }        
        return laboraccMap; 
    }
    
    @RemoteAction
    global static Map<String,Id> getRecordType() {
        Map<String,Id> recordTypeMap = new Map<String,Id>();
        List<RecordType> rtTypeList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName('','AcctSeed__Project_Task__c',new Set<String>{});
        for(RecordType rtType : rtTypeList){
            if(!recordTypeMap.containsKey(rtType.Name))
                recordTypeMap.put(rtType.Name, rtType.Id);
        }
        return recordTypeMap;
    }
    
    @RemoteAction
    global static List<sObject> getLookupRecords(String objectName, String searchString, String condition) {
        List<sObject> lookupRecords = new List<sObject>();
        String query = 'SELECT Id, Name FROM ' + objectName;
        if(searchString != null && searchString != '') {
            query += ' WHERE Name LIKE \'%' + searchString + '%\'';
        }
        if(condition != null && condition != '') {
            if(searchString != null && searchString != '') {
                query += ' AND ' + condition;
            } else {
                query += ' WHERE ' + condition;
            }
        }
        query += ' LIMIT 10';
        System.debug('query log:::::::::::: ' + query);
        lookupRecords = Database.query(query);
        system.debug(':::::::::lookupRecords:::::::'+lookupRecords);
        return lookupRecords;
    }   
}