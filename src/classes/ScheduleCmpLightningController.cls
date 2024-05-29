public with sharing class ScheduleCmpLightningController {
    
    // To store the prior schedule of the schedule where the schedule type is 'Replace Instructor', 'Schedule Change', 'Room Change' and 'Substitute'
    public static Set<Id> parentIds; 
    
    // To get the parent type
    @AuraEnabled
    public static ScheduleDomain.ParTypeSchRecWrapper getParentType(String parentId, String scheStatus) {
        
        Id parId = (Id)parentId;
     
        ScheduleDomain.ParTypeSchRecWrapper wrap = new ScheduleDomain.ParTypeSchRecWrapper();
        
        wrap.parentType = String.valueOf(parId.getSobjectType());
        wrap.schOpliWrap = getScheduleRecords(parentId, scheStatus ,wrap.parentType);
        wrap.statusValue = getPickListValues('Schedule__c', 'Status__c');
        wrap.onlineRoomId = ZoomUtil.getOnlineRoomId();
        wrap.isDLSOnlineProject = false;
        Set<String> roomsForLTS = new Set<String>{'Zoom - Online', 'GoToMeeting - Online', 'Teams - Online'};
        Map<String, Room__c> roomIdWithRecMap = new Map<String, Room__c>([SELECT Id,Name FROM Room__c WHERE Name IN :roomsForLTS]);
        wrap.roomIdsFilterConditionForLTS = 'Id IN (\''+String.join(new List<String>(roomIdWithRecMap.keySet()), '\',\'')+'\')';
        
        if(wrap.parentType == 'Opportunity'){
            
            List<AcctSeed__Project__c> proList = [SELECT Id,Name,RecordType.DeveloperName FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :parentId];
            
            List<Opportunity> oppRec = [SELECT Id,DLS_Class__c,RecordType.DeveloperName FROM Opportunity WHERE Id = :parentId];
            
            if(oppRec != null && oppRec[0].DLS_Class__c != null) {
                wrap.haveDLSClassNo = true;
            } else {
                wrap.haveDLSClassNo = false;
            }
            
            wrap.parentRecordType = oppRec[0].RecordType.DeveloperName;
            
            if(proList.size() > 0){
                wrap.isProjectExist = true;
                wrap.projectId = proList[0].Id;
            }else {
                wrap.isProjectExist = false;
            }
        }else {
            wrap.isProjectExist = true;
            List<AcctSeed__Project__c> proList = [SELECT Id,Name,Training_Location__c,Training_Location__r.Name, DLS_Class__c,RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :parentId];
            if(proList != null && proList[0].DLS_Class__c != null) {
                wrap.haveDLSClassNo = true;
            } else {
                wrap.haveDLSClassNo = false;
            }
            
            if(proList != null && proList[0].Training_Location__c != null &&  proList[0].Training_Location__r.Name == 'DLS - Online'){
                wrap.isDLSOnlineProject = true;
            }
            wrap.parentRecordType = proList[0].RecordType.DeveloperName;
        }
        
        //Get loggedin user profile name
        List<User> usrRec = [SELECT Id,Name,Profile.Name FROM User WHERE Id = :userinfo.getUserId()];
        wrap.currentUsrProfileName = usrRec[0].Profile.Name;
        
        //Added By Dhinesh - 03/03/2022 - W-007381
        Map<String, Boolean> scheduleActionPermissionMap = new Map<String, Boolean>();
        Map<String, Schedule_Action_Permissions__c> scheduleActionPermissionsMap = Schedule_Action_Permissions__c.getAll();
        //Added By Siva Prasanth - 26/06/2023 - W-007816
        List<String> grantedLTSForRoomChange = new List<String>();
        String currentUserId = UserInfo.getUserId();
        System_Values__c schRoomChangeAllowLTS = System_Values__c.getValues('Schedule Room Change allowed LTS');
        
        if(schRoomChangeAllowLTS != NULL && schRoomChangeAllowLTS.Value__c != NULL){
            grantedLTSForRoomChange = schRoomChangeAllowLTS.Value__c.split(',');
        } 
        
        for(String schAction : scheduleActionPermissionsMap.keySet()){
            Schedule_Action_Permissions__c sap = scheduleActionPermissionsMap.get(schAction);
            List<String> profileNames = sap.Values__c.split(', ');
            Boolean showSchAction = false;
            
            if(profileNames.contains(wrap.currentUsrProfileName)){
                showSchAction = true;
                if(schAction == 'Room Change'  && wrap.currentUsrProfileName == 'LTS'){
                    if(!(grantedLTSForRoomChange.contains(currentUserId))){
                        showSchAction = false;
                    }
                }
            }
            
            scheduleActionPermissionMap.put(schAction.replaceAll(' ','_'),showSchAction);
        }
        
        wrap.scheduleActionPermissionMap = scheduleActionPermissionMap;
        
        return wrap;
    }
    
    // To get the schedule records based on id and status and Parent OPLI Records
    @AuraEnabled
    public static List<ScheduleDomain.SchOpliWrapper> getScheduleRecords(String parentId, String schStatus, String parentType) {
        
        Set<String> statusSet = new Set<String>();
        List<ScheduleDomain.SchOpliWrapper> wrap = new List<ScheduleDomain.SchOpliWrapper>();
        
        Map<Id, OpportunityLineItem> opliIdMap = new Map<Id, OpportunityLineItem>();
        List<Schedule__c> scheList = new List<Schedule__c>();
        
        if(schStatus != null) {
            statusSet.addAll(schStatus.split(' & '));
        }
        
        String queryStr = 'SELECT Id, Name, Days__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Project_Task__c, Status__c, Travel_Out__c,'+ 
                          'Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Total_Hours_per_Session__c, Total_Hours__c, Travel_In__c,'+
                          'Timezone__c, Project_Task__r.Name, Project_Task__r.Unit__c, Project_Task__r.Total_Qty_Planned__c, Opportunity_Product_Id__c,'+
                          'Opportunity__r.RecordType.DeveloperName, Project__r.RecordType.DeveloperName,Parent_Schedule__c,Schedule_Type__c,Hours_Planned__c,'+
                          'Cancellation_Reason__c,Cancellation_Date__c,Meeting_URL__c,Project_Task_Stage__c FROM Schedule__c '+
                          'WHERE ';
        
        if(schStatus == 'All'){
            queryStr += 'Status__c != null AND';
        }else{
            queryStr += 'Status__c IN :statusSet AND';
        }
        
        if(parentType == 'Opportunity'){
            queryStr += ' Opportunity__c =:parentId';
        }else{
            queryStr += ' Project__c =:parentId';
        }
        
        queryStr += ' ORDER BY CreatedDate ASC';
        
        System.debug(':::***:::queryStr:::'+queryStr);
        
        scheList = database.query(queryStr);
        
        if(parentType == 'Opportunity') {            
            for(OpportunityLineItem opli : [SELECT Id, Name,Product2.Name,Quantity FROM OpportunityLineItem WHERE OpportunityId = :parentId]) {
                opliIdMap.put(opli.Id, opli);
            }
        }
        
        // To check whether the logged in user has the permission to Edit/Assign the Room
        Boolean roomEditPermission = FeatureManagement.checkPermission('Permission_to_Edit_Rooms');
        
        EventHandler eveHandle = new EventHandler();
        
        for(Schedule__c sche : scheList) {
            ScheduleDomain.SchOpliWrapper wr = new ScheduleDomain.SchOpliWrapper();
            wr.startTimeMinutes = eveHandle.convertToMinutes(sche.Start_Time__c);
            wr.endTimeMinutes = eveHandle.convertToMinutes(sche.End_Time__c);
            wr.stDt = sche.Start_Date__c != null ? String.valueOf(sche.Start_Date__c).split('-')[1]+'/'+String.valueOf(sche.Start_Date__c).split('-')[2]+'/'+String.valueOf(sche.Start_Date__c).split('-')[0] : null;
            wr.endDt = sche.End_Date__c != null ? String.valueOf(sche.End_Date__c).split('-')[1]+'/'+String.valueOf(sche.End_Date__c).split('-')[2]+'/'+String.valueOf(sche.End_Date__c).split('-')[0] : null;
            wr.sch = sche;
            wr.startDate = sche.Start_Date__c;
            wr.endDate = sche.End_Date__c;
            wr.travelIn = sche.Travel_In__c;
            wr.travelOut = sche.Travel_Out__c;
            wr.opli = (opliIdMap.containsKey(sche.Opportunity_Product_Id__c)) ? opliIdMap.get(sche.Opportunity_Product_Id__c) : null;
            wr.allowRoomEdit = roomEditPermission;
            
            if(sche.Room__c != null && sche.Room__r.Name.contains('Zoom')){
                wr.isZoomRoom = true;
            }
            wrap.add(wr);
        }
        
        return wrap;
    }
    
     // Method to get the pick list values
    @AuraEnabled
    public static List<String> getPickListValues(String objName, String pickListName) {
    
        List<String> pickListValues = new List<String>();
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        
        Schema.DescribeFieldResult picklistFieldDescribe = fieldMap.get(pickListName).getDescribe();
        for(Schema.PicklistEntry pickListVal : picklistFieldDescribe.getPicklistValues()){
            if(pickListVal.isActive()){
                pickListValues.add(pickListVal.getValue());
            }
        }
        return pickListValues;
    } 
    
    // Method to Activate the Schedule
    @AuraEnabled
    public static String scheduleActivate(String schId) {
       try{
            List<Schedule__c> schList = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{schId},', Instructor__r.Name, Room__r.Name, Project_Task__r.Total_Qty_Planned__c, Project_Task__r.Name, Project_Task__r.Unit__c');
            
            for(Schedule__c sch : schList) {
                sch.Status__c = 'Active';
            }
            //update schList;
            
            schList = ScheduleService.updateSchedule(schList);
            EventHandler.handleEventRecords(new Set<Id>{schId});
            return 'SUCCESS';
        }catch(Exception e){ 
            /*if(e.getMessage().contains('Schedule cannot be activated since student not available for the project')){
                throw new AuraHandledException('Schedule cannot be activated since student not available for the project');
            }else{*/
                throw new AuraHandledException(e.getMessage());
            //}
        }
    }
    
    @AuraEnabled
    public static List<Contact_Assignments__c> getActiveAssignments(Id projectId, String recordTypeName){
        system.debug('project Id:::'+projectId);
        List<Contact_Assignments__c> contactAssignmentList = new List<Contact_Assignments__c>();
        
        if(recordTypeName == 'Instructor') {
            contactAssignmentList = [SELECT Id,Name,Status__c,Candidate_Name__r.Name,Candidate_Name__c FROM Contact_Assignments__c 
                                          WHERE Project__c = :projectId AND Status__c IN ('Active','Planned') AND RecordType.DeveloperName = :recordTypeName]; 
        }else if(recordTypeName == 'Student'){
            contactAssignmentList = [SELECT Id,Name,Status__c,Candidate_Name__r.Name,Candidate_Name__c FROM Contact_Assignments__c 
                                          WHERE Project__c = :projectId AND Status__c IN ('Active','Planned') AND RecordType.DeveloperName = :recordTypeName]; 
        }
        system.debug('contact List:::'+contactAssignmentList);
        return contactAssignmentList;          
    }
    
    @AuraEnabled
    public static String deleteSchedule(String scheduleStr,String cancelType){
        
        Schedule__c sch = (Schedule__c)System.JSON.deserialize(scheduleStr, Schedule__c.class); 
        system.debug('schedule record to be deleted:::'+sch);
        
        try {
            if(cancelType == 'delete'){
                if(sch.Id != null){
                    
                    if(sch.Schedule_Type__c == 'Substitute'){
                        delete [SELECT Id,Name FROM Events__c WHERE Schedule__c = :sch.Id];
                    }
                    
                    delete sch;
                }   
            }else if(cancelType == 'cancel' || cancelType == 'complete'){
                if(sch != null){
                    update sch;
                }   
            }
            return 'SUCCESS';
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<Id> selectedIds){
        searchString = '%'+searchString+'%';
        String queryString;
        queryString = 'SELECT Id,Name FROM '+objectName+' WHERE '+fieldName+' LIKE :searchString LIMIT 100';
        System.debug('Query--'+queryString);
        List<SObject> lookupRecords = Database.query(queryString);
        String lookupRecordStr = '';
        if(lookupRecords != null && !lookupRecords.isEmpty()){
            lookupRecordStr =  JSON.serialize(lookupRecords);
        }
        return lookupRecords;
    }
    
    @AuraEnabled
    public static Schedule__c assignInstructorRec(Schedule__c schRecord){
        if(schRecord != null){
            update schRecord;
        }
        
        return [SELECT Id, Name, Days__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Project_Task__c, 
        Status__c, Travel_Out__c, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Total_Hours_per_Session__c, 
        Total_Hours__c, Travel_In__c, Timezone__c, Project_Task__r.Name, Project_Task__r.Unit__c,Hours_Planned__c, 
        Project_Task__r.Total_Qty_Planned__c, Opportunity_Product_Id__c, Opportunity__r.RecordType.DeveloperName,
        Project__r.RecordType.DeveloperName,Schedule_Type__c,Cancellation_Reason__c,Cancellation_Date__c,Meeting_URL__c FROM Schedule__c WHERE Id = :schRecord.Id];
    }
    
    @AuraEnabled
    public static Schedule__c assignRoomRec(Schedule__c schRecord){
         if(schRecord != null){
            update schRecord;
        }
        
        return [SELECT Id, Name, Days__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Project_Task__c, 
        Status__c, Travel_Out__c, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Total_Hours_per_Session__c, 
        Total_Hours__c, Travel_In__c, Timezone__c, Project_Task__r.Name, Project_Task__r.Unit__c,Hours_Planned__c,
        Project_Task__r.Total_Qty_Planned__c, Opportunity_Product_Id__c, Opportunity__r.RecordType.DeveloperName,
        Project__r.RecordType.DeveloperName,Schedule_Type__c,Cancellation_Reason__c,Cancellation_Date__c,Meeting_URL__c FROM Schedule__c WHERE Id = :schRecord.Id];
    }
    
    /******************************************************
     - Method to check Hrs / Days related Product / Project Task exist
     - Added by NS on Nov 22 2018
     *****************************************************/
    @AuraEnabled
    public static Boolean checkProductOrPTExist(String parentId,String parentType){
        Boolean productOrPTExist = false;
        
        system.debug('::::parentId::::::'+parentId);
        system.debug('::::parentType::::::'+parentType);
        
        Set<String> excludedNames = new Set<String>{'Language Training- Each Additional Student','Additional Student 1','GSA Additional Student 1','Language Materials'};
        String parentRTName = '';
            
        if(parentType == 'Opportunity'){
            List<OpportunityLineItem> opliRecords = [SELECT Id, Name, Quantity, Product2.Family, Product2.Name, Unit__c 
                                                        FROM OpportunityLineItem 
                                                     WHERE OpportunityId = :parentId AND (Unit__c = 'Hrs' OR Unit__c = 'Days') 
                                                            AND Product2.Name NOT IN :excludedNames ORDER BY CreatedDate];
            if(opliRecords.size() > 0){
                productOrPTExist = true;
            }
        }else if(parentType == 'AcctSeed__Project__c'){
            List<AcctSeed__Project__c> projectRecord = [SELECT Id,Name,RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :parentId];
            parentRTName = projectRecord[0].RecordType.DeveloperName;
            
            List<AcctSeed__Project_Task__c> taskRecords = new List<AcctSeed__Project_Task__c>();
            
            if(parentRTName == 'Admin_Projects'){
                taskRecords = [SELECT Id,Name FROM AcctSeed__Project_Task__c 
                                                                WHERE AcctSeed__Project__c = :parentId AND (Unit__c = 'Hrs' OR Unit__c = 'Days' OR RecordType.DeveloperName LIKE '%Cost%') 
                                                               AND Name NOT IN :excludedNames];
            }else {
                taskRecords = [SELECT Id,Name FROM AcctSeed__Project_Task__c 
                                                                WHERE AcctSeed__Project__c = :parentId AND (Unit__c = 'Hrs' OR Unit__c = 'Days') 
                                                               AND Name NOT IN :excludedNames];
            }
            
            if(taskRecords.size() > 0){
                productOrPTExist = true;
            }
        }
        
        return productOrPTExist;
    }
    
    /*********************************************************************************
    - Method to get the Add & Edit Schedule related information
    - Added by NS on Nov 23 2018
    ************************************************************************************/
    @AuraEnabled
    public static String getScheduleRelatedInformation(String parentId,String parentType,String scheduleId,String scheduleType,String priorScheduleId,String parentScheduleId){
        ScheduleDomain.SheduleDetailInfo details = new ScheduleDomain.SheduleDetailInfo();
        
        Id oppId;
        Id projectId;
        String parentRTName = '';
        Date stDate;
        Date endDate;
        String defaultCR = '';
        Set<String> excludedNames = new Set<String>{'Language Training- Each Additional Student','Additional Student 1','GSA Additional Student 1','Language Materials'};
        
        List<OpportunityLineItem> opliRecords = new List<OpportunityLineItem>();
        List<AcctSeed__Project_Task__c> taskRecords = new List<AcctSeed__Project_Task__c>();
        Map<Id,Decimal> opliTaskIdAlottedHrs = new Map<Id,Decimal>();
        Map<Id,Decimal> totalPlannedHrsMap = new Map<Id,Decimal>();
        
        //Qry Parent Record details
        //Qry OPLI & Project Task details
        if(parentType == 'Opportunity'){
            List<Opportunity> oppList = [SELECT Id,Name,RecordType.DeveloperName,Start_Date__c,End_Date__c,Default_Cost_Rate_Rate_Type__c FROM Opportunity WHERE Id = :parentId];
            
            for(OpportunityLineItem opli : [SELECT Id, Name, Quantity, Product2.Family, Product2.Name, Unit__c 
                                                        FROM OpportunityLineItem 
                                                     WHERE OpportunityId = :parentId AND (Unit__c = 'Hrs' OR Unit__c = 'Days') 
                                                            AND Product2.Name NOT IN :excludedNames ORDER BY CreatedDate]){
                
                
                opliRecords.add(opli);
                totalPlannedHrsMap.put(opli.Id,opli.Quantity);
            }
            
            parentRTName = oppList[0].RecordType.DeveloperName;
            oppId = parentId;
            stDate = oppList[0].Start_Date__c;
            endDate = oppList[0].End_Date__c;
            defaultCR = oppList[0].Default_Cost_Rate_Rate_Type__c;
        }else if(parentType == 'AcctSeed__Project__c'){
            List<AcctSeed__Project__c> projectRecord = [SELECT Id,Name,RecordType.DeveloperName,AcctSeed__Opportunity__c,Start_Date__c,End_Date__c,Default_Cost_Rate_Rate_Type__c FROM AcctSeed__Project__c WHERE Id = :parentId];
            parentRTName = projectRecord[0].RecordType.DeveloperName;
            projectId = parentId;
            oppId = projectRecord[0].AcctSeed__Opportunity__c;
            stDate = projectRecord[0].Start_Date__c;
            endDate = projectRecord[0].End_Date__c;
            defaultCR = projectRecord[0].Default_Cost_Rate_Rate_Type__c;
            
            if(parentRTName == 'Admin_Projects'){
                taskRecords = [SELECT Id,Name,Total_Qty_Planned__c,Language__c,Parent_Project_Task__c FROM AcctSeed__Project_Task__c 
                                                                WHERE (Unit__c = 'Hrs' OR Unit__c = 'Days' OR RecordType.DeveloperName LIKE '%Cost%') 
                                                               AND Name NOT IN :excludedNames AND AcctSeed__Project__c = :parentId];
            }else {
                taskRecords = [SELECT Id,Name,Total_Qty_Planned__c,Language__c,Parent_Project_Task__c FROM AcctSeed__Project_Task__c 
                                                                WHERE (Unit__c = 'Hrs' OR Unit__c = 'Days') 
                                                               AND Name NOT IN :excludedNames AND AcctSeed__Project__c = :parentId];
            }
            
            for(AcctSeed__Project_Task__c task : taskRecords){
                totalPlannedHrsMap.put(task.Id,task.Total_Qty_Planned__c);
            }
        }
        
        //Get Time Values
        List<String> timeList = new List<String>();
        List<Schema.PicklistEntry> scorePickList = Schedule__c.Start_Time__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : scorePickList) {
            timeList.add(entry.getValue());
        }
        
        List<Schedule__c> scheduleRecord = new List<Schedule__c>();
        //Qry if the schedule is prensent
        if(String.isNotBlank(scheduleId)){
            scheduleRecord = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{scheduleId},', Instructor__r.Name, Room__r.Name, Project_Task__r.Total_Qty_Planned__c, Project_Task__r.Name, Project_Task__r.Unit__c');
        }
        
        //Qry parent related existing schedule records for the calculate btn existing hrs comparision
        List<AggregateResult> agrResult = new List<AggregateResult>();
        if(parentType == 'Opportunity'){
            agrResult = [SELECT SUM(Total_Hours__c), Opportunity_Product_Id__c FROM Schedule__c WHERE Opportunity__c = :parentId AND Opportunity_Product_Id__c != null GROUP BY Opportunity_Product_Id__c];
        }else if(parentType == 'AcctSeed__Project__c'){
            agrResult = [SELECT SUM(Total_Hours__c), Project_Task__c FROM Schedule__c WHERE Project__c = :parentId AND Project_Task__c != null GROUP BY Project_Task__c];
        }
        system.debug(':::agrResult'+agrResult);
        for(AggregateResult agr : agrResult){
            Id key;
            if(parentType == 'Opportunity'){
                key = (Id) agr.get('Opportunity_Product_Id__c');
            }else if(parentType == 'AcctSeed__Project__c'){
                key = (Id) agr.get('Project_Task__c');
            }
            if(!opliTaskIdAlottedHrs.containsKey(key)){
                opliTaskIdAlottedHrs.put(key,(Decimal) agr.get('expr0'));
            }
        }
        
        List<Holiday> holidays = [SELECT Name, ActivityDate FROM Holiday];
        
        //Qry exisitng schedule records under the project/ Opportunity
        String schQry = 'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('Schedule__c')+',Project_Task__r.Project_Task_Type__c,Instructor__r.Name, Room__r.Name, Project_Task__r.Total_Qty_Planned__c, Project_Task__r.Name, Project_Task__r.Unit__c '
                            +'FROM Schedule__c WHERE ';
        
        if(parentType == 'Opportunity'){
            schQry += ' Opportunity__c = \''+parentId+'\' ORDER BY CreatedDate';
        } else {
            schQry += ' Project__c = \''+parentId+'\' ORDER BY CreatedDate';
        }
        
        List<Schedule__c> existingSchedules = database.query(schQry);                
        
        details = ScheduleTranslator.scheduleDetailsFormation(opliRecords,taskRecords,oppId,projectId,timeList,scheduleRecord,parentRTName,scheduleType,opliTaskIdAlottedHrs,stDate,endDate,priorScheduleId,parentScheduleId,holidays,totalPlannedHrsMap,existingSchedules,defaultCR);
        
        system.debug(':::::::::::opliRecords:::::'+opliRecords);
        system.debug(':::::::::::taskRecords:::::'+taskRecords);
        system.debug(':::::::::::parentRTName:::::'+parentRTName);
        system.debug(':::::::::::projectId:::::'+projectId);
        system.debug('::::::::::scheduleRecord::::::'+details.schDetail);
        
        return JSON.serialize(details);
    }
    /************************************************************************
    - To get the conflict information
    ************************************************************************/
    @AuraEnabled
    public static String getScheduleConflicts(String schWrapperJson,String schRecJson,String instructorId,String parentType,String parentId,String parentRT,String daysOffJson){
        
        try {
            List<ScheduleDomain.ScheduleDetail> scheduleWrapperRecords = (List<ScheduleDomain.ScheduleDetail>) System.JSON.deserialize(schWrapperJson, List<ScheduleDomain.ScheduleDetail>.class);
            
            List<Schedule__c> schRecords = (List<Schedule__c>) System.JSON.deserialize(schRecJson, List<Schedule__c>.class);
            
            Map<String,Integer> conflictType_Count = new Map<String,Integer>();
            
            List<Schedule__c> schList = new List<Schedule__c>();
            if(scheduleWrapperRecords.size() > 0){
                schList.add(ScheduleTranslator.OriginalScheduleRecordFormation(scheduleWrapperRecords[0]));
            }
            if(schRecords.size() > 0){
                schList.addAll(schRecords);
            }
            
            conflictType_Count = EventManagementController.getConflictsonSchedules(JSON.serialize(schList),instructorId,parentType,parentId,parentRT,daysOffJson);
            return JSON.serialize(conflictType_Count);
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /************************************************************************************
    - Method to created regular schedule records
    - Added by NS on Nov 28 2018
    ************************************************************************************/
    @AuraEnabled
    public static String createdRegularSchedule(String scheduleJson,String parentType,String parentId){
        
            List<ScheduleDomain.ScheduleDetail> scheduleRecords = (List<ScheduleDomain.ScheduleDetail>) System.JSON.deserialize(scheduleJson, List<ScheduleDomain.ScheduleDetail>.class);
        
       try {
            if(scheduleRecords[0].isNew) {
                scheduleRecords[0].scheduleName = scheduleNameFormation(parentType,parentId);
            }
            List<Schedule__c> scheduleForInsert = new List<Schedule__c>();
            scheduleForInsert.add(ScheduleTranslator.OriginalScheduleRecordFormation(scheduleRecords[0]));
            if(scheduleForInsert.size() > 0){
                upsert scheduleForInsert;
            }
            return 'SUCCESS';
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }   
    /************************************************************
     - Qry recently created schedule record under that project/opp
     -  To form the scheudle name
    ************************************************************/
    public static String scheduleNameFormation(String parentType,String parentId){
        
        String dlsClassNo;  
        Integer scheduleNo = 1;     
        List<Schedule__c> recentSchRec = new List<Schedule__c>();
        if(parentType == 'Opportunity'){
            List<Opportunity> oppRec = [SELECT DLS_Class__c, (SELECT Name FROM Schedules__r) FROM Opportunity WHERE Id = :parentId];
            dlsClassNo = oppRec[0].DLS_Class__c;
            recentSchRec = oppRec[0].Schedules__r;
        }else if(parentType == 'AcctSeed__Project__c'){
            List<AcctSeed__Project__c> projectRec = [SELECT DLS_Class__c, (SELECT Name FROM Schedules__r) FROM AcctSeed__Project__c WHERE Id = :parentId];
            dlsClassNo = projectRec[0].DLS_Class__c;
            recentSchRec = projectRec[0].Schedules__r;
        }
        system.debug(':::::::::recentSchRec::::'+recentSchRec);
        if(recentSchRec.size() > 0){
            scheduleNo = recentSchRec.size() + 1;
        }
        
        String scheduleName = dlsClassNo +'-SH'+scheduleNo;
        System.debug('scheduleName::::::'+scheduleName);
        return scheduleName;
    }
    
    /*****************************************************************
    - Schedule create for all type of schedule records 
    - Added by NS on Dec 3 2018
    ******************************************************************/
    @AuraEnabled
    public static String createScheduleForOtherTypes(String schedule,String schType,String rateType,String parentType,String parentId,List<String> eventDates,String costRateId,String CRType){
        String returnMsg = '';
        try {
            Map<String,String> result = new Map<String,String>();
            System.debug('Schedule::::::'+Schedule);
            List<Schedule__c> schList = new List<Schedule__c>();
            ScheduleDomain.ScheduleDetail schWrapper = (ScheduleDomain.ScheduleDetail) System.JSON.deserialize(Schedule, ScheduleDomain.ScheduleDetail.class);
            
            if(schWrapper.isNew){
                schWrapper.scheduleName = scheduleNameFormation(parentType,parentId);
            }
            
            Schedule__c sch = ScheduleTranslator.OriginalScheduleRecordFormation(schWrapper);
            
            System.debug('eventDates::::'+eventDates);
            String returnStr ='';
            parentIds = new Set<Id>();
            Date tempDate;
            Id oldInsId;
            
            if(schType != 'Substitute') {
                parentIds.add(sch.Prior_Schedule__c);
                if(schWrapper.isNew){
                    schList.add(new Schedule__c(Id = sch.Prior_Schedule__c));
                }
                //Modified By Dhinesh - W-006013 - Zoom Integration - to set Room as Zoom - Online when Move Online is clicked in the schedule related tab in Project detail page
                if(schType == 'Schedule Change' || schType == 'Replace Instructor' || schType == 'Room Change' || schType == 'Move Online') {
                
                    //Qry prior schedule details to check its is started or not
                    //If not we have to set the status as canceled & need to delete all the events under that schedule
                    List<Schedule__c> priorSchedule = [SELECT Id,Start_Date__c,End_Date__c,Status__c,Instructor__c FROM Schedule__c WHERE Id = :sch.Prior_Schedule__c];
                    oldInsId = priorSchedule[0].Instructor__c;
                    
                    if(priorSchedule.size() > 0 && priorSchedule[0].Start_Date__c >= sch.Start_Date__c){
                        schList[0].Status__c = 'Canceled';
                        schList[0].Cancellation_Reason__c = schType; 
                        schList[0].Cancellation_Date__c = system.today();
                    }else {
                        system.debug(':::enddate'+sch.Start_Date__c+'::::'+System.Today());
                        tempDate = sch.Start_Date__c;
                        
                        Datetime dt = DateTime.newInstance(tempDate, Time.newInstance(0, 0, 0, 0));
                        // To check the End date is not in a working Day.
                        while(dt.format('EEEE') == 'Saturday' || dt.format('EEEE') == 'Sunday') {
                            tempDate = tempDate.addDays(-1);
                            dt = DateTime.newInstance(tempDate, Time.newInstance(0, 0, 0, 0));
                        }
                        
                        if(schList.size() > 0){
                            if(priorSchedule[0].Start_Date__c < tempDate){
                                schList[0].End_Date__c =  tempDate.addDays(-1);
                                
                                if(schList[0].End_Date__c < System.today()){
                                    schList[0].Status__c = 'Completed';
                                }
                            }
                        }
                    }
                    
                    //ScheduleTriggerHandler.isFromScheduleComponent = true;
                }
                System.debug('schList:::::'+schList);
            }
            
            //sch.Id = null; // To insert a new Schedule
             
            schList.add(sch);
            System.debug('schType:::::'+schType);
            System.debug('schList:::::'+schList);
            upsert schList;
            
            //Call the Event creation method with newly created Sustitute Schedule Id & eventdates
            // Added by NS on OCT 1 2018
            if(schType == 'Substitute' && schList.size() == 1 && schList[0].Schedule_Type__c == 'Substitute') {
                parentIds.add(sch.Id);
                Set<Date> eventDts = new Set<Date>();
                for(String str : eventDates){
                    eventDts.add(Date.valueOf(str));
                }
                system.debug(':::::::::eventDts::::::'+eventDts);
                EventHandler eveHandler = new EventHandler();
                
                //Updating Prior Schedule events with cancelled status
                eveHandler.cancelPriorScheduleEventsList(new Map<Id,Set<Date>>{sch.Prior_Schedule__c => eventDts});
                //Creating new events and schedule records for substitute
                eveHandler.createSubstitueScheduleEvts(new Map<Id,Set<Date>>{schList[0].Id => eventDts});
            }
            
            returnStr = 'Schedule has been created succesfully';
            if(schType != 'Extended' && schType != 'Room Change' && sch.Instructor__c != null) {
                List<Contact> conList = ContactService.getContactByparentId(' WHERE Id ', 'RecordType.DeveloperName', new Set<Id>{sch.Instructor__c});
                // Added CA status condition on Feb 28 2024 : W-007996 - Tester Schedule Action Issue
                // The system should automatically generate a new Tester CA for the Tester if they have an existing Tester or Instructor CA on the Project that has ended in the past.
                List<Contact_Assignments__c> contactList = ContactAssignmentService.getContactassignmentRec(' WHERE RecordType.DeveloperName = \'Instructor\' AND Candidate_Name__c = \''+sch.Instructor__c+'\' AND (Project__c = \''+parentId +'\' OR Opportunity_Name__c = \''+parentId +'\') AND Status__c NOT IN (\'Canceled\', \'Ended\')','Rate_Card_Rate__r.Status__c');
                List<AcctSeed__Cost_Rates__c> crList = new List<AcctSeed__Cost_Rates__c>();
                Boolean isCreateNewCA = false;
                List<Contact_Assignments__c> allConAssigns = new List<Contact_Assignments__c>();

                // To assign "FT Salary & Benefits" Cost Rate for DLS Employees
                if(conList != null && conList.size() > 0 && conList[0].RecordType.DeveloperName == 'DLS_Employee'){
                    rateType = 'FT Salary & Benefits';
                }
                if(String.isNotBlank(rateType)) {
                    crList = CostRateService.getCRByParentId(' WHERE Status__c IN (\'Approved\') AND Rate_Type__c =\'' +rateType+ '\' AND Contact__c', '', new Set<Id>{sch.Instructor__c});
                }
                 system.debug('::contactList'+contactList + (schType == 'Replace Instructor') );
                
                
                if(contactList.size() == 0){
                    String protaskLT = null;
                    List<AcctSeed__Project_Task__c> proTask = [SELECT Id,Parent_Project_Task__c FROM AcctSeed__Project_Task__c WHERE Name = 'Language Training- Preparation' AND Id = :sch.Project_Task__c AND Parent_Project_Task__c != null LIMIT 1]; 
                    
                    if(proTask.size() > 0){
                        protaskLT = proTask[0].Parent_Project_Task__c;
                    }    
                   
                    Contact_Assignments__c newInstructor = new Contact_Assignments__c();
                    newInstructor.Candidate_Name__c = sch.Instructor__c;
                    
                    if(schType == 'Substitute') {
                        newInstructor.Assignment_Position__c = 'Substitute Instructor';
                    } else if(schType == 'Replace Instructor') {
                        newInstructor.Assignment_Position__c = 'Instructor'; 
                    }else if(schType == 'Tester') {
                        newInstructor.Assignment_Position__c = 'Tester'; 
                    }
                    
                    newInstructor.Status__c = 'Active';
                    newInstructor.Start_Date__c = sch.Start_Date__c;
                    newInstructor.End_Date__c = sch.End_Date__c;
                    
                    if(sch.Project__c != null) {
                        
                        newInstructor.Project__c = sch.Project__c;
                        
                        if(protaskLT != null){
                            newInstructor.Project_Task__c = protaskLT; 
                        }else{
                            newInstructor.Project_Task__c = sch.Project_Task__c;
                        }
                        
                        //Comment by NS on Jan 6 2020
                        //W-004361
                        /*if(crList != null && crList.size() > 0 ) {
                            newInstructor.Rate_Card_Rate__c = crList[0].Id;
                            returnStr = 'Schedule has been created succesfully and a Contact Assignment has been created and mapped to the Schedule.';
                        } else {
                            returnStr = 'Schedule has been created succesfully and a Contact Assignment has been created and mapped to the Schedule. Please create Cost Rate record and assign to the Instructor ' + (conList != null && conList.size() > 0 ? conList[0].Name : '');
                        }*/
                        
                        if(String.isNotBlank(costRateId)){
                            
                            if(CRType == 'Approved CR'){
                                newInstructor.Rate_Card_Rate__c = costRateId;
                            }else if(CRType == 'Draft CR'){
                                newInstructor.Drafted_Labor_Cost_Rate__c = costRateId;
                            }
                        }
                        
                        returnStr = 'Schedule has been created succesfully and a Contact Assignment has been created and mapped to the Schedule.';
                    } else {
                        newInstructor.Opportunity_Name__c = sch.Opportunity__c;
                    }
                    
                    newInstructor.RecordTypeId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByName().get('Instructor').getRecordTypeId();
                    allConAssigns.add(newInstructor);
                    //insert newInstructor;
                }
                
                System.debug(':::schType:::'+schType);
                System.debug(':::oldInsId:::'+oldInsId);
                System.debug(':::sch.Prior_Schedule__c:::'+sch.Prior_Schedule__c);
                // Added on Feb 20 2024
                // W-007978 : Update to Replace Instructor Action Functionality
                // If the Contact Assignment of the Replaced Instructor does not have any other schedules, we would like the system to update their CA Status and End Date.
                if(schType == 'Replace Instructor' && oldInsId != null){
                    
                    List<Schedule__c> schRecs = [SELECT Id FROM Schedule__c WHERE Project__c = : sch.Project__c AND Instructor__c = : oldInsId AND Status__c NOT IN ('Canceled', 'Completed') AND Id != : sch.Prior_Schedule__c AND End_Date__c >= TODAY AND Project_Task__r.Project_Task_Type__c != 'Preparation time'];
                    System.debug(':::schRecs:::'+schRecs);
                    
                    if(schRecs == null || schRecs.size() == 0){
                    
                        List<Contact_Assignments__c> oldCARec = [SELECT Id, Candidate_Name__c FROM Contact_Assignments__c WHERE Project__c = : sch.Project__c AND Candidate_Name__c = : oldInsId AND Status__c NOT IN ('Canceled', 'Ended') AND End_Date__c >= TODAY];
                        System.debug(':::oldCARec:::'+oldCARec);
                         
                        if(oldCARec.size() > 0 && tempDate != null){
                            
                            Contact_Assignments__c oldCA = new Contact_Assignments__c();
                            oldCA.Id = oldCARec[0].Id;
                            oldCA.End_Date__c = tempDate.addDays(-1);
                            // If the Contact Assignment End Date of the Replaced Instructor is in the Past, we would like the system to update their CA Status to Ended.
                            if(oldCA.End_Date__c < System.Today()){
                                oldCA.Status__c = 'Ended';
                            }
                            allConAssigns.add(oldCA);
                        } //else {  tempDate = null //priorSchedule[0].Start_Date__c >= sch.Start_Date__c
                            // We have cancelled the previous schedule for future dates. What will be done with CA?
                        //}
                    }
                }
                System.debug('allConAssigns:::'+allConAssigns);
                upsert allConAssigns;
            }
            
            system.debug('result:::'+returnStr);
            if(returnStr != null) {
                return returnStr;
            }else {
                return 'SUCCESS';
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
       // return returnMsg;
    }
    
    /******************************************************
     - Get Lookup search related records
     - Added by NS on Dec 3 2018
    *******************************************************/
    @AuraEnabled
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(searchString,objectName,fieldName,condition,selectedIds);
    }   
    
    /********************************************************
    - Get Schedule related events for Sustitute schedule calender ui formation
    - Added by NS on Dec 4 2018
    **********************************************************/
    @AuraEnabled
    public static String getEventsFromSchedule(String scheduleId, String sDate, String eDate, List<String> status){
        try {
            System.debug(sDate+'::::'+eDate);
            System.debug('status::::'+status);
            System.debug('ScheduleId:::::'+ScheduleId);
            Map<String, List<Date>> statusWithDates = new Map<String, List<Date>>();
            List<Events__c> events = EventService.getEventsBySchIdAndDateRange(new Set<Id>{scheduleId}, sDate, eDate ,'', status); //Date.newInstance(sD.year(),sD.month(),sD.day()), Date.newInstance(eD.year(),eD.month(),eD.day())
            for(Events__c e : events) {
                if(!statusWithDates.containskey(e.Status__c)) {
                    statusWithDates.put(e.Status__c, new List<Date>{e.Date__c});
                }else {
                    statusWithDates.get(e.Status__c).add(e.Date__c);
                }
            }
            return JSON.serialize(statusWithDates);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /****************************************************************
    - To create Events for the newly selected events for an existing Substitute Events
    - Added by NS on Dec 5 2018
    ****************************************************************/
    @AuraEnabled
    public Static String createEventsForSubstituteSchEdit(String schedule,List<String> newEventDates) {
        ScheduleDomain.ScheduleDetail schWrapper = (ScheduleDomain.ScheduleDetail) System.JSON.deserialize(schedule, ScheduleDomain.ScheduleDetail.class);
        Schedule__c sch = ScheduleTranslator.OriginalScheduleRecordFormation(schWrapper);
        
        system.debug('sch ::::'+sch);
        try {
            if(sch != null) {
                
                Set<Date> eventDts = new Set<Date>();
                for(String str : newEventDates){
                    eventDts.add(Date.valueOf(str));
                }
                system.debug(':::::::::eventDts::::::'+eventDts);
                EventHandler eveHandler = new EventHandler();
                //Updating Prior Schedule events with cancelled status
                eveHandler.cancelPriorScheduleEventsList(new Map<Id,Set<Date>>{sch.Prior_Schedule__c => eventDts});
                
                eveHandler.createSubstitueScheduleEvts(new Map<Id,Set<Date>>{sch.Id => eventDts});

                return 'SUCCESS';
            } else {
                return 'No Substitute Schedule Record';
            }
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /******************************************************************
     - Prep Time PT parent task related schedule list to display in Parent Schedule input
     - Added by NS on Dec 13 2018
    *******************************************************************/
    @AuraEnabled
    public static String getPTRelatedScheduleRecord(String prepPTId){
        List<Schedule__c> scheduleRecords = new List<Schedule__c>();
        
        String result = '';
        
        if(String.isNotBlank(prepPTId)){
            //Check currently selected PT is Prep PT
            List<AcctSeed__Project_Task__c> currentPT = [SELECT Id,Name,Project_Task_Type__c,Parent_Project_Task__c FROM AcctSeed__Project_Task__c WHERE Id = :prepPTId];
            
            if(currentPT != null && currentPT[0].Project_Task_Type__c == 'Preparation time' && currentPT[0].Parent_Project_Task__c != null){
                scheduleRecords = [SELECT Id,Name,Project_Task__c,Project_Task__r.Name FROM Schedule__c 
                                    WHERE Project_Task__c = :currentPT[0].Parent_Project_Task__c 
                                    AND Status__c IN ('Drafted','Active') AND Project_Task__r.Project_Task_Type__c = 'Language Training'];
                result = JSON.serialize(scheduleRecords);
            }else {
                result = 'Not Prep PT';
            }
        }
        
        return result;
    }
    
    /******************************************************************
     - Added by NS on Dec 29 2018
     - To create zoom meeting id
     * ****************************************************************/   
    @AuraEnabled
    public static String createZoomMeetingUrl(String scheduleId,String projectTaskName){
       return null;
    }
    
    /***********************************************************************************
    - Added by NS on August 21 2019
    - To display msg on Schedule detail page, to show other than System Admin users
    ***********************************************************************************/
    @AuraEnabled
    public static String getCurrentUserProfileName(){
        return [SELECT Id,Name,Profile.Name FROM User WHERE Id = :userInfo.getUserId()].Profile.Name;
    }
    
    /****************************************************************************************
    - Method to check contact assignment exist or not for the instructor selected in new schedule creation
    - Added by NS on Jan 6 2020
    *****************************************************************************************/
    @AuraEnabled
    public static Boolean checkContactAssignmentExist(String contactId,String parentId,String schType,Date cAEndDate){
        Boolean isActiveCA = false;
        
        System.debug(':;contactId::'+contactId);
        String conJSON = ' WHERE RecordType.DeveloperName = \'Instructor\' AND Candidate_Name__c = \''+contactId+'\' AND (Project__c = \''+parentId +'\' OR Opportunity_Name__c = \''+parentId +'\') ';
        
        if(schType == 'Replace Instructor' || schType == 'Substitute'){
            conJSON = conJSON +  ' AND Status__c != null ORDER BY End_Date__c DESC';             
        }else{
            conJSON = conJSON +  ' AND Status__c != \'Ended\'';              
        }
        
        //W-008039 - When A Substitute or Replace Instructor Action is triggered and the Instructor populated in the Instructor field of the Action page has an Existing CA in Ended Status and with a Cost Rate record = Active, we would like the system to Extend the existing Ended
        // CA End Date to = the Instructor's New schedule End Date and update his CA from Ended to Active.
           
        List<Contact_Assignments__c> contactAssignment = ContactAssignmentService.getContactassignmentRec(conJSON,'Rate_Card_Rate__r.Status__c');
        
        System.debug('schType:::'+schType);
        System.debug('cAEndDate:::'+cAEndDate); 

        if(schType == 'Replace Instructor' || schType == 'Substitute'){
            List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
            
            for(Contact_Assignments__c ca : contactAssignment){

                if(ca.Status__c == 'Ended' && (ca.Rate_Card_Rate__r.Status__c == 'Approved') && updateCAs.size() == 0){
                    
                    Contact_Assignments__c updateCA = new Contact_Assignments__c();
                    updateCA.Id = ca.Id; 
                    updateCA.Status__c = 'Active';
                    updateCA.End_Date__c = cAEndDate;
                    updateCAs.add(updateCA);
                }else if(ca.Status__c != 'Ended'){
                    isActiveCA = true;
                }
            }
            
            if(updateCAs.size() > 0){
                update updateCAs;
                isActiveCA = true;
            }
        }else{
            isActiveCA = contactAssignment.size() > 0;
        }

        if(isActiveCA == true){
            return true;
        }else {
            return false;
        }
    }
    
    /****************************************************************************************
    - Method to send to notify FEO Team to Assign a Room to a Schedule
    - Added by SP on Mar 31 2023
    - W-007725 - Button to Notify FEO to Assign a Room to a Schedule (APR-1-2023)
    *****************************************************************************************/
    @AuraEnabled
    public static void sendMailtoNotifyFEOTeam(String projectId){
        try{
            if(projectId != null){
                List<AcctSeed__Project__c> projects = [SELECT Id,Name,Start_Date__c FROM AcctSeed__Project__c WHERE Id = :projectId];
                System_Values__c schNotifyMail = System_Values__c.getValues('Schedule Update Notify Mail');

                if(projects.size() > 0 && (schNotifyMail != null && schNotifyMail.Value__c != null)){
                    Date stDate = projects[0].Start_Date__c;
                    String proStDate = String.valueOf(stDate).split('-')[1]+'/'+String.valueOf(stDate).split('-')[2]+'/'+String.valueOf(stDate).split('-')[0];
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                    //mail.setToAddresses(new String[] {'SukanyaN@softsquare.biz'});
                    mail.setToAddresses(new String[] {schNotifyMail.Value__c});
                    mail.setSubject('Assign Room for Project with Start Date '+proStDate); 
                    
                    String htmlBody = '';                
                    htmlBody += '<html>Hi FEO Team,<br/><br/>Please assign a Room for the Schedule(s) on Project ';
                    htmlBody +=  '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+projects[0].Id+'" target="_blank">'+projects[0].Name+'</a>';
                    htmlBody += ' which starts on '+proStDate+'.';
                    htmlBody += '<br/><br/><br/><br/>Thank you,<br/>'+ UserInfo.getName()+'</html>';
                    mail.setHtmlBody(htmlBody);
                    
                    System.debug('htmlBody =============='+htmlBody);
                    
                    if(!Test.isRunningTest()){
                        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    }
                }
            }
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /***********************************************************************************************
    - Method to use in ScheduleCmp to get the parent info
    - Added by NS on March 11 2020
    ************************************************************************************************/
    @AuraEnabled
    public static String getParentRecord(String objectName,String parentId){
        
        String result = '';
        
        if(objectName == 'Project'){
            List<AcctSeed__Project__c> projects = [SELECT Id,Name,RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :parentId];
            
            result = JSON.serialize(projects);
        }else {
            List<Opportunity> opportunity = [SELECT Id,Name,RecordType.DeveloperName FROM Opportunity WHERE Id = :parentId];
            
            result = JSON.serialize(opportunity);
        }
        
        return result;
        
    }
}