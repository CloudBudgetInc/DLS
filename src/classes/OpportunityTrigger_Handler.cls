/************************************************************************
 - Created by Karthiga on April 04, 2017
 - Commonly used for Opportunity & Project Trigger process
*************************************************************************/
public with Sharing class OpportunityTrigger_Handler {
    /*
    * Accessed for DLS Class Value in Opportunity and Project
    */
    public Static Map<String,Id> oppRecTypeMap = new Map<String,Id>();
    public Static List<PriceBook2> pbs = New List<PriceBook2>();
    public Static List<Sobject_Master_Field_Mapping__c> masterMap = new List<Sobject_Master_Field_Mapping__c>();
    public Static List<Program_Iteration__c> piList = new List<Program_Iteration__c>();
    
    public Static Boolean loadResource = false;
    
    public Map<String, Integer> getHighestNoForDLSClass(Boolean queryCdRtRec, Boolean queryOtherRtRec, Boolean queryTestRtRec, Boolean queryTransRtRec, Boolean queryInterPreRtRec) {
        Integer year = Date.Today().Year();
        Datetime endDT = System.now();
        DateTime startDT = DateTime.newInstance(year, 01, 01, 0, 0, 0);
        System.debug(':::startDT::::'+startDT+'endDT::::'+endDT);
        List<AcctSeed__Project__c> cdProjList = new List<AcctSeed__Project__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<AcctSeed__Project__c> projList = new List<AcctSeed__Project__c>();
        Map<String, Integer> countMap = new Map<String, Integer>();
        
        List<AcctSeed__Project__c> testProjList = new List<AcctSeed__Project__c>();
        List<AcctSeed__Project__c> transProjList = new List<AcctSeed__Project__c>();
        List<AcctSeed__Project__c> interPreProjList = new List<AcctSeed__Project__c>();
        
        System.debug('CPU Time in getHighestNoForDLSClass: before getProjectsCreatedThisYear::'+limits.getCpuTime());
        
        if(queryOtherRtRec) {
            oppList = OpportunityService.getOpportunitiesByStartAndEndDate('','',startDT,endDT);
            projList = ProjectService.getProjectsCreatedThisYear(' AND RecordType.DeveloperName NOT IN (\'CD_Projects\', \'MTT_Projects\', \'Testing_Projects\', \'Translation_Projects\', \'Interpretation_Projects\')','',startDT,endDT);
        }
        
        if(queryCdRtRec) {
            cdProjList = ProjectService.getProjectsCreatedThisYear(' AND RecordType.DeveloperName = \'CD_Projects\'','',startDT,endDT);
        }
        
        if(queryTestRtRec) {
            testProjList = ProjectService.getProjectsCreatedThisYear(' AND RecordType.DeveloperName = \'Testing_Projects\'','',startDT,endDT);
        }
        
        if(queryTransRtRec) {
            transProjList = ProjectService.getProjectsCreatedThisYear(' AND RecordType.DeveloperName = \'Translation_Projects\'','',startDT,endDT);
        }
        
        if(queryInterPreRtRec) {
            interPreProjList = ProjectService.getProjectsCreatedThisYear(' AND RecordType.DeveloperName = \'Interpretation_Projects\'','',startDT,endDT);
        }
        
        integer count = 0, cdCount = 0, testCount = 0, transCount = 0, interPreCount = 0;
        System.debug('projList ::::'+projList);
        if(oppList != null && projList != null && oppList.size() > 0 && projList.size() > 0) {
            //Integer oppDLS = (oppList[0].DLS_Class__c != null ? (oppList[0].DLS_Class__c.split('-').size() > 1 ? Integer.ValueOf(oppList[0].DLS_Class__c.split('-')[1]) : 0) : 0);
            //Integer projDLS = (projList[0].DLS_Class__c != null ? (projList[0].DLS_Class__c.split('-').size() > 1 ? Integer.ValueOf(projList[0].DLS_Class__c.split('-')[1]) : 0 ) : 0);
            Integer oppDLS = (oppList[0].Stripped_Class_Number_This_Year__c != null ? Integer.ValueOF(oppList[0].Stripped_Class_Number_This_Year__c) : 0);
            Integer projDLS = (projList[0].Stripped_Class_Number_This_Year__c != null ? Integer.ValueOf(projList[0].Stripped_Class_Number_This_Year__c) : 0);
            count = oppDLS > projDLS ? oppDLS : projDLS;
        } else if (oppList != null && oppList.size() > 0) {
            count = (oppList[0].Stripped_Class_Number_This_Year__c != null ? Integer.ValueOF(oppList[0].Stripped_Class_Number_This_Year__c) : 0);
            //count = (oppList[0].DLS_Class__c != null ? (oppList[0].DLS_Class__c.split('-').size() > 1 ? Integer.ValueOf(oppList[0].DLS_Class__c.split('-')[1]) : 0) : 0);
        } else if (projList != null && projList.size() > 0) {
            count = (projList[0].Stripped_Class_Number_This_Year__c != null ? Integer.ValueOf(projList[0].Stripped_Class_Number_This_Year__c) : 0);
            //count = (projList[0].DLS_Class__c != null ? (projList[0].DLS_Class__c.split('-').size() > 1 ? Integer.ValueOf(projList[0].DLS_Class__c.split('-')[1]) : 0 ) : 0);
        } 
        
        if(cdProjList != null && cdProjList.size() > 0) {
            cdCount = (cdProjList[0].Stripped_Class_Number_This_Year__c != null ? Integer.ValueOf(cdProjList[0].Stripped_Class_Number_This_Year__c) : 0);
        }
        
        if(testProjList != null && testProjList.size() > 0) {
            testCount = (testProjList[0].Stripped_Class_Number_This_Year__c != null ? Integer.ValueOf(testProjList[0].Stripped_Class_Number_This_Year__c) : 0);
        }
        
        if(transProjList != null && transProjList.size() > 0) {
            transCount = (transProjList[0].Stripped_Class_Number_This_Year__c != null ? Integer.ValueOf(transProjList[0].Stripped_Class_Number_This_Year__c) : 0);
        }
        
        if(interPreProjList != null && interPreProjList.size() > 0) {
            interPreCount = (interPreProjList[0].Stripped_Class_Number_This_Year__c != null ? Integer.ValueOf(interPreProjList[0].Stripped_Class_Number_This_Year__c) : 0);
        }
        
        countMap.put('otherRecCount', count);
        countMap.put('cdRecCount', cdCount);
        countMap.put('testRecCount', testCount);
        countMap.put('transRecCount', transCount);
        countMap.put('interPreRecCount', interPreCount);
        
        return countMap;
    }
    
    public Map<String,Id> getRecordTypeMap() {
        for(RecordType rt : SObjectQueryService.getRecTypeListBySobjTypeAndDevName('','Opportunity',new Set<String>())) {
            oppRecTypeMap.put(rt.DeveloperName,rt.Id);
        }
        return oppRecTypeMap;
    }
    
    public static void getSobjectMasterRecord() {
        masterMap = [SELECT Id,Name,Default_Field_Value__c,Field_Name__c,RecordType_Name__c FROM Sobject_Master_Field_Mapping__c WHERE Object_Name__c = 'Opportunity'];
    }
    
    public static void getProgramIteration() {
        piList = ProgramIterationService.getIterationRec('','');
    }
    
    public static void getPriceBook() {
       
        //pbs = [SELECT Id,Name,IsActive,IsStandard,Min_Education__c,Min_Experience__c FROM PriceBook2];
        // To fix the issue related to - System.QueryException: sObject type 'Pricebook2' is not supported
        List<sObject> sobjList = Database.query('SELECT Id,Name,IsActive,IsStandard,Min_Education__c,Min_Experience__c FROM PriceBook2');
        pbs = sobjList;
    }
    /******************************************************************
     - Clone global set of Planne days off for Opp / Project specific on Opp/Project creation
     - Added by NS on 21.12.2018
    ************************************************************************/
    public static void clonePlannedDaysOff(Map<Id,SObject> recIdRecMap,String fromType) {
        
        Set<Date> stDate = new Set<Date>();
        Set<Date> endDate = new Set<Date>();
        
        List<Planned_Days_Off__c> newCreationList = new List<Planned_Days_Off__c>();
        Map<Date,Planned_Days_Off__c> datedaysOffMap = new Map<Date,Planned_Days_Off__c>();
        
        system.debug('::::::::recIdRecMap::::::'+recIdRecMap);
        system.debug('::::::::fromType::::::'+fromType);
        
        // Qry Planne days off related Record Type Ids
        Id projectPDORTId;
        for(RecordType rt : [SELECT Id,Name,DeveloperName 
                                FROM RecordType 
                                WHERE SobjectType = 'Planned_Days_Off__c' AND DeveloperName = 'Project_Planned_Days_Off']){
            projectPDORTId = rt.Id;
        }
        
        for(Planned_Days_Off__c daysOff : [SELECT Id,Name,Date__c,RecordTypeId,Description__c 
                                            FROM Planned_Days_Off__c 
                                            WHERE RecordType.DeveloperName = 'DLI_W_LT_Training_Holidays' 
                                            AND Contact__c = NULL AND Opportunity__c = NULL AND Project__c = NULL]) {
            
            if(daysOff.Date__c != null && !datedaysOffMap.containsKey(daysOff.Date__c)) {
                datedaysOffMap.put(daysOff.Date__c,daysOff);
            }
        }
        
        for(SObject obj : recIdRecMap.values()) {
            for(Date dt : datedaysOffMap.keySet()) {
               
                if(dt >= Date.valueOf(obj.get('Start_Date__c')) && dt <= Date.valueOf(obj.get('End_Date__c'))) {
                        
                    Planned_Days_Off__c newOff = new Planned_Days_Off__c();
                    newOff.Date__c = datedaysOffMap.get(dt).Date__c;
                    newOff.RecordTypeId = projectPDORTId;
                    newOff.Description__c = datedaysOffMap.get(dt).Description__c;
                    newOff.Type__c = 'DLI-W LT';
                    newOff.Status__c = 'Approved';
                    
                    if(fromType == 'Opportunity') {
                        newOff.Opportunity__c = (Id) obj.get('Id');
                        newCreationList.add(newOff);
                        
                    }else if(fromType == 'Project') {
                        newOff.Project__c = (Id) obj.get('Id');
                        if(obj.get('AcctSeed__Opportunity__c') != null) {
                            newOff.Opportunity__c = (Id) obj.get('AcctSeed__Opportunity__c');
                        }
                        newCreationList.add(newOff);
                    }
                }
            }
        }
        
        system.debug('::::::::newCreationList::::'+newCreationList);
        
        if(newCreationList.size() > 0) {
            insert newCreationList;
        }
    }
    
    /******************************************************************
    - Method to update the Project status based on the start date / Oral Exam date time values on creation & updation
    - This method used in both Project Trigger & contact assignment status updation batch - which is running on daily basis
    - Added by NS on April 24 2018
    *******************************************************************/
    public static Boolean projectStatusUpdate(List<AcctSeed__Project__c> projectList){
        //system.debug('::::::::::::projectList:::::::::'+projectList);
        Boolean updateSuccess = false;
        if(projectList != null && projectList.size() > 0){
            for(AcctSeed__Project__c pro : projectList){
                if(pro.AcctSeed__Status__c == 'Order'){
                    pro.AcctSeed__Status__c = 'Active';
                }
            }
            
            //update projectList;
            Database.SaveResult[] srList = Database.update(projectList, false);
            
            for(Database.SaveResult sr : srList){
                if(sr.isSuccess()){
                    updateSuccess = true;
                }else {
                    updateSuccess = false;
                }
            }
            
            return updateSuccess;
        }
        return updateSuccess;
    }
    
    /******************************************************************
    - Method to update the Contact Assignment status to active when the Project status is activated before actual start date / oral exam date
    - This method used in both Project Trigger & contact assignment status updation batch - which is running on daily basis
    - Added by NS on April 24 2018
    *******************************************************************/
    public static void contactAssignmentStatusUpdate(Map<Id,String> proIdStatusMap){
        system.debug('::::::::proIdStatusMap:::::::::'+proIdStatusMap);
                
        List<Contact_Assignments__c> cAupdationList = new List<Contact_Assignments__c>();
        
        //Map to avoid ended CA with same contact updated to active
        Set<String> proIdConId = new Set<String>();
         
        if(proIdStatusMap != null && proIdStatusMap.size() > 0){
            
            for(Contact_Assignments__c conAssign : [SELECT Id,Name,Project__c,Status__c,RecordType.DeveloperName,Rate_Card_Rate__c,Rate_Card_Rate__r.Status__c,Candidate_Name__c FROM Contact_Assignments__c 
                                                        WHERE Project__c IN : proIdStatusMap.keySet() AND Status__c NOT IN ('Ended','Transferred') ORDER BY LastModifiedDate DESC]){
                                                      
                if(proIdStatusMap.containsKey(conAssign.Project__c) && proIdStatusMap.get(conAssign.Project__c) != conAssign.Status__c){
                    
                    
                    if(conAssign.RecordType.DeveloperName != 'Instructor') {
                        
                        if(proIdStatusMap.get(conAssign.Project__c) != 'Order') {
                            conAssign.Status__c = proIdStatusMap.get(conAssign.Project__c);
                        } else {
                            conAssign.Status__c = 'Planned';
                        }
                    
                        cAupdationList.add(conAssign);
                        
                    } else {
                        
                        // Commented By HL on May 06 2020
                        // Work Item : W-005327 - On Hold Project Contact Assignment Change Issue
                        // Don't update Ended Contact Assignment status, If the Contact Assignments are in the Status Ended, they should remain Ended
                        
                        /*
                        //To exclude the ended instructor ca for status update action to avoid errors
                        String key = conAssign.Project__c+'~'+conAssign.Candidate_Name__c;
                        
                        if(conAssign.Status__c == 'Ended' && !proIdConId.contains(key) && conAssign.Rate_Card_Rate__r.Status__c == 'Approved'){
                            
                            if(proIdStatusMap.get(conAssign.Project__c) != 'Order') {
                                conAssign.Status__c = proIdStatusMap.get(conAssign.Project__c);
                            } else {
                                conAssign.Status__c = 'Planned';
                            }
                            
                            cAupdationList.add(conAssign);
                            proIdConId.add(key);
                            
                        } 
                        */
                        // To exclude the Inactive assigned Instructor from status updation, this is handled in the Manage Project Status Page and Manage Project Dates
                        if(conAssign.Rate_Card_Rate__r.Status__c != 'Inactive') {                           
                            if(proIdStatusMap.get(conAssign.Project__c) != 'Order') {
                                conAssign.Status__c = proIdStatusMap.get(conAssign.Project__c);
                            } else {
                                conAssign.Status__c = 'Planned';
                            }
                            cAupdationList.add(conAssign);
                        }
                    
                        //cAupdationList.add(conAssign); commented to add it in the above condition
                    }
                }
            }
            System.debug('::::cAupdationList::::::'+cAupdationList);
            if(cAupdationList.size() > 0){
                update cAupdationList;
            }
        }
    }
    
    /***********************************************************
    - Separate method to avoid recursive update based on contact assignment oral exam date & project oral exam date
    - If the project oral exam date updated then related CA status will be updated.So CA will be updated 2 times in single execution.
    - To avoid this issue we have used the future method for CA status update.
    - If the project is directly updated without any CA dependency we will use the above method.
    - If the project update is invoked from CA update then we use this future method.
    ************************************************************/
    @future
    public static void contactAssignmentStatusUpdateFut(Map<Id,String> proIdStatusMap){
        contactAssignmentStatusUpdate(proIdStatusMap);
    }
    
    // To update the project_Status__c field in opportunity based on the project status
    public static void opportunityUpdateFut(Map<Id,String> oppIdStatusValueMap){
        System.debug(':::***:::handler:::');
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity WHERE Id IN :oppIdStatusValueMap.keySet()];
        
        if(oppList.size() > 0) {
            for(Opportunity opp : oppList) {
                opp.Project_Status__c = (oppIdStatusValueMap.containsKey(opp.Id)) ? oppIdStatusValueMap.get(opp.Id) : '';
            }
            update oppList;
        }
    }
}