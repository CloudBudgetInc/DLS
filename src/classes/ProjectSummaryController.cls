/**************************************************************************************************
- Work Item No: W-002179
- Rebuild the Project Summary VF version to Lightning
***************************************************************************************************/
public class ProjectSummaryController {
    
    @AuraEnabled
    public static FilterInfo getFilters(){
        try{
            
            List<recordTypeIdPickList> contactAssignmentRecList = new List<recordTypeIdPickList>();
            List<recordTypeIdPickList> projectRTList = new List<recordTypeIdPickList>();
            List<Saved_Search__c> savedFiltersList = [SELECT Id,Name,Filter_Value__c FROM Saved_Search__c ORDER BY Name ASC];
            
            
            recordTypeIdPickList pick = new recordTypeIdPickList();
            pick.label = 'All';
            pick.value = 'All';
            contactAssignmentRecList.add(pick);
            //projectRTList.add(pick);
            
            for(RecordType recType : [SELECT Id,name from recordtype where sobjecttype = 'Contact_Assignments__c' AND IsActive = true]){
                recordTypeIdPickList pickList = new recordTypeIdPickList();
                pickList.label = recType.name;
                pickList.value = recType.Id;
                contactAssignmentRecList.add(pickList);
            }
            
            for(RecordType rtType : [SELECT Id,name from recordtype where sobjecttype = 'AcctSeed__Project__c' AND IsActive = true]){
                recordTypeIdPickList pickLst = new recordTypeIdPickList();
                pickLst.label = rtType.name;
                pickLst.value = rtType.Id;
                projectRTList.add(pickLst);
            }
            
            FilterInfo filter = new FilterInfo();
            filter.savedFiltersList = savedFiltersList;
            filter.defaultFilterId = getUserContactFilterId();
            filter.projectStatus = getPickListValuesIntoList('AcctSeed__Project__c','AcctSeed__Status__c');
            filter.contactAssStatus = getPickListValuesIntoList('Contact_Assignments__c','Status__c');
            filter.contactAssignmentTypeList = contactAssignmentRecList;
            filter.projectTypeList = projectRTList;
            filter.projectSectionList = getPickListValuesIntoList('AcctSeed__Project__c','Section__c');
            
            return filter;
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static projectSummaryFullInfo getProjectList(String proSummaryInputs){
        
        List<AcctSeed__Project__c> projectRecords = new List<AcctSeed__Project__c>();
        List<recordTypeIdPickList> contactAssignmentRecList = new List<recordTypeIdPickList>();
        
        ProjectSummaryInputDetails  pSInputs = (ProjectSummaryInputDetails)JSON.deserialize(proSummaryInputs,ProjectSummaryInputDetails.class);
        
        String proQry = 'SELECT Id,Name,RecordType.Name,DLS_Ref__c,Start_Date__c,Program_type__c,End_Date__c,AcctSeed__Status__c,Hours_Remaining__c,'+
            ' Project_Manager__c,Scheduled_Hours_Week__c, Project_Manager__r.Name,Total_Program_Hours__c,Hours_Week__c,Students__c,Staffs__c,Instructors__c,'+
            'All_Active_Rooms__c,Room__c,Room__r.Name,AcctSeed__Account__c,AcctSeed__Account__r.Name,Language__c,Language__r.Name,'+
            'Training_Location__c,Training_Location__r.Name, Last_Date_of_Attendance__c '+
            'FROM AcctSeed__Project__c WHERE ';
        
        String filter = '';
        
        system.debug('pSInputs::'+pSInputs.accountId);
        
        //Account filter
        List<Account> accIdList = new List<Account>();
        accIdList.addAll(pSInputs.accountId);
        if(accIdList.size() > 0 && String.isEmpty(filter)) {
            filter = 'AcctSeed__Account__c IN :accIdList';
        }
        
        // Location filter
        if(!String.isEmpty(pSInputs.locationId)) {
            if(!String.isEmpty(filter)) {
                filter += ' AND Training_Location__c = \''+pSInputs.locationId+'\'';
            }else {
                filter = 'Training_Location__c = \''+pSInputs.locationId+'\'';
            }
        }

        //Modified by Dhinesh - 12/8/2022 - W-007549
        // Section filter
        if(String.isNotBlank(pSInputs.selectedSection) && pSInputs.selectedSection != 'All'){
            if(!String.isEmpty(filter)) {
                filter += ' AND Section__c = \''+pSInputs.selectedSection+'\'';
            }else {
                filter = 'Section__c = \''+pSInputs.selectedSection+'\'';
            }
        }
        
        // Project Record Type Filter
        if(pSInputs.projectRTNames != null && pSInputs.projectRTNames.size() > 0) {
            
            Set<String> recordTypeNames = new Set<String>();
            
            for(String rtName : pSInputs.projectRTNames){
                if(rtName != 'All'){
                    recordTypeNames.add(rtName);
                }
            } 
            
            if(recordTypeNames.size() > 0){
                
                if(!String.isEmpty(filter)) {
                    filter += ' AND RecordType.Name IN :recordTypeNames';
                } else {
                    filter += 'RecordType.Name IN :recordTypeNames';
                }
            }
        }
        
        // Project Status filter
        if(pSInputs.projectStatus != null && (pSInputs.projectStatus).size() > 0) {
            Set<String> statusSet = new Set<String>();
            statusSet.addAll(pSInputs.projectStatus);
            Set<String> cancelEndedProStatus = new Set<String>();
            Set<String> otherProjectStatus = new Set<String>();
            
            if(statusSet.size() > 0) {
                for(String proStatus : statusSet){
                    if(proStatus == 'Canceled' || proStatus == 'Ended'){
                        cancelEndedProStatus.add(proStatus);
                    }else {
                        otherProjectStatus.add(proStatus); 
                    }
                }
            }
            if(!String.isEmpty(filter)) {
                filter += ' AND (AcctSeed__Status__c IN :otherProjectStatus OR (AcctSeed__Status__c IN :cancelEndedProStatus AND End_Date__c = LAST_90_DAYS)) ';
            }else {
                filter = ' (AcctSeed__Status__c IN :otherProjectStatus OR (AcctSeed__Status__c IN :cancelEndedProStatus AND End_Date__c = LAST_90_DAYS)) ';
            }
        }
        
        String CACondition = 'SELECT Project__c FROM Contact_Assignments__c WHERE ';
        Boolean conditionAdded = false;
        if(!String.isEmpty(pSInputs.contactId)) {
            CACondition += 'Candidate_Name__c = \''+pSInputs.contactId+'\'';
            conditionAdded = true;
        }
        
        if(!String.isEmpty(pSInputs.cARTId) && pSInputs.cARTId != 'All') {
            if(conditionAdded) {
                CACondition += ' AND RecordTypeId = \''+pSInputs.cARTId+'\'';
            } else {
                CACondition += 'RecordTypeId = \''+pSInputs.cARTId+'\'';
                conditionAdded = true;
            }
        }
        
        if(!String.isEmpty(pSInputs.cAPosition) && pSInputs.cAPosition != 'All') {
            if(conditionAdded) {
                CACondition += ' AND Assignment_Position__c = \''+pSInputs.cAPosition+'\'';
            } else {
                CACondition += 'Assignment_Position__c = \''+pSInputs.cAPosition+'\'';
                conditionAdded = true;
            }
        }
        
        if(pSInputs.cAStatus != null && pSInputs.cAStatus.size() > 0) {
            Set<String> caStatusSet = new Set<String>();
            caStatusSet.addAll(pSInputs.cAStatus);
            
            if(conditionAdded) {
                CACondition += ' AND Status__c IN :caStatusSet';
            } else {
                CACondition += 'Status__c IN :caStatusSet';
                conditionAdded = true;
            }
        }
        
        system.debug('::::::CACondition::::'+CACondition);
        system.debug(':::::::::proQry:::::;;'+proQry);
        
        if((pSInputs.cAPosition != 'All' || pSInputs.cARTId != 'All' || (pSInputs.cAStatus).size() > 0 || !String.isEmpty(pSInputs.contactId)) && conditionAdded) {
            if(!String.isEmpty(filter)) {
                filter += ' AND Id IN (' + CACondition + ')';
            }else {
                filter = 'Id IN (' + CACondition + ')';
            }
        }
        
        system.debug(':::::::filter::::'+filter);
        
        proQry = proQry + filter;
        
        system.debug('::::::::sortingFieldName:::::'+pSInputs.sortingFieldName);
        system.debug('::::::::sortingOrder:::::'+pSInputs.sortingOrder);
        
        if(String.isNotBlank(pSInputs.sortingFieldName) && String.isNotBlank(pSInputs.sortingOrder)){
            proQry += ' ORDER BY '+pSInputs.sortingFieldName+' '+pSInputs.sortingOrder +' NULLS LAST  LIMIT 5000' ;
        }
        
        system.debug(':::::::::proQry:::::;;'+proQry);
        projectRecords = Database.query(proQry);
        
        Decimal hoursWeek = 0,remainingHours = 0;
        List<Id> projectIds = new List<Id>();
        Map<String,Decimal> activeCounts = new Map<String,Decimal>();
        
        for(AcctSeed__Project__c project : projectRecords){
            
            if(project.Hours_Week__c > 0) {
                hoursWeek += project.Hours_Week__c;
            }
            if(project.Hours_Remaining__c > 0){
                remainingHours += project.Hours_Remaining__c;
            }       
            projectIds.add(project.Id);
        }
        
        activeCounts = getActiveStudentInstructorCount(projectIds);
        
        projectSummaryFullInfo projectInfo = new projectSummaryFullInfo();
        
        projectInfo.projectSummaryList = projectSummaryRecordsFormation(projectRecords);
        
        projectInfo.noOfProjects = projectInfo.projectSummaryList.size();
        projectInfo.activeInstructors = activeCounts.get('Instructor');
        projectInfo.activeStudents = activeCounts.get('Student');
        projectInfo.remainingHours = remainingHours;
        projectInfo.hoursWeek = hoursWeek;
        projectInfo.savedSearchList = [SELECT Id,Name,Filter_Value__c FROM Saved_Search__c];
        System.debug('projectInfo======'+projectInfo);
        
        return projectInfo;
    }
    
    
    public static List<String> getPickListValuesIntoList(String objectName ,String FieldApiName){       //  Form picklist values suitable for select option
        
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); 
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); 
        List<Schema.PicklistEntry> pick_list_values = field_map.get(FieldApiName).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a : pick_list_values) { 
            lstPickvals.add(a.getValue());
        }
        
        return lstPickvals;
    }
    
    @AuraEnabled
    public static String SaveSearches(String ssList) {
        system.debug('ssList'+ssList);
        List<Saved_Search__c> savedSearchList = (List<Saved_Search__c>) System.JSON.deserialize(ssList, List<Saved_Search__c>.class);
        
        try{
            
            if(savedSearchList.size() > 0) {
                Upsert savedSearchList;
            }
            
            return savedSearchList[0].Id;
            
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    @AuraEnabled
    public static void deleteFilter(String ssId) {
        
        try{
            delete [SELECT Id from saved_search__c where id = :ssId];
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static void updateContact(String newId , String operation) {
        
        try{
            
            User logUser = [Select Id,firstname,middlename,lastname from User  where Id = :UserInfo.getUserId()];            
            
            if( logUser != null) {
                
                String query = 'SELECT Id,FirstName,MiddleName,LastName,Name,Default_Project_Summary_Filter__c FROM Contact WHERE FirstName = \''+(logUser.FirstName != null ? logUser.FirstName :'')+'\' AND MiddleName = \''+(logUser.MiddleName != null ?logUser.MiddleName:'')+'\' AND LastName = \''+(logUser.LastName != null ? logUser.LastName : '')+'\''; 
                System.debug('query1=='+query);
                
                Contact con = database.query(query);
                System.debug('con=='+con);
                
                if(operation == 'Update'){
                    con.Default_Project_Summary_Filter__c = newId;
                }else{
                    con.Default_Project_Summary_Filter__c = null;
                }
                
                update con;
            }
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    
    //Updated by NS on April 27 2020
    //Same action as Manage Project Status quick action to update project status
    @AuraEnabled
    public static void updateProjectStatus(String proId,String dateValue,String reason,String status){
        try{
            
            CustomButtonService.isFromManageProjectStatus = true;
                
            AcctSeed__Project__c proRec = new AcctSeed__Project__c();
            proRec.Id = proId;
            proRec.AcctSeed__Status__c = status;
            
            update proRec;
        
            if(status == 'On Hold' || status == 'Canceled'){
            
                List<Schedule__c> schRecords = [SELECT Id,Name,Status__c,On_Hold_Date__c FROM Schedule__c WHERE Project__c = :proId AND Status__c IN ('Drafted','Active')];
                system.debug(':::::::schRecords::::'+schRecords);
                if(schRecords.size() > 0){
                    for(Schedule__c sch : schRecords){
                        
                        if(status == 'On Hold') {
                            sch.Status__c = 'Completed';
                            sch.End_Date__c = Date.valueOf(dateValue);
                            
                        }else if(status == 'Canceled'){
                            sch.Status__c = 'Canceled';
                            sch.Cancellation_Date__c = Date.valueOf(dateValue);
                            sch.Cancellation_Reason__c = reason;
                        }
                        
                    }
                    update schRecords;
                }
            }
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    }  
    
    @AuraEnabled
    public static Map<String, Integer> getActiveStudentInstructorCount(List<Id> proIds) {
        
        Map<String, Integer> countMap = new Map<String, Integer>{'Instructor' => 0, 'Student' => 0};
            
            if(proIds.size() > 0) {
                Set<Id> proIdsSet = new Set<Id>(proIds);
                List<Contact_Assignments__c> conAssList = [SELECT Id, Name, RecordType.DeveloperName FROM Contact_Assignments__c WHERE Project__c IN :proIdsSet AND RecordType.DeveloperName IN ('Instructor', 'Student') AND Status__c = 'Active'];
                
                for(Contact_Assignments__c conAss : conAssList) {
                    if(conAss.RecordType.DeveloperName == 'Instructor') {
                        countMap.put('Instructor', countMap.get('Instructor')+1);
                        
                    } else if(conAss.RecordType.DeveloperName == 'Student') {
                        countMap.put('Student', countMap.get('Student')+1);
                    }
                }
            }
        return countMap;
    }
    
    @AuraEnabled
    public static string getRecordTypeBased_PicklistValues(String objectName,String fieldName, String recordTypeId){
        //Get picklist value by its recordtypeid
        if(recordTypeId != 'All'){
            
            try {
                
                List<String> pickListValues = new List<String>();
                
                Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(CongaButtonsController.getServerUrlSessionId());
                
                String sessionId = (String) resultMap.get('sessionId');
                
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String host = System.Url.getSalesforceBaseURL().toExternalForm();
                String url = host+'/services/data/v42.0/ui-api/object-info/'+objectName+'/picklist-values/'+recordTypeId+'/'+fieldName;        
                request.setEndpoint(url);
                request.setMethod('GET');  
                request.setHeader('Authorization', 'OAuth '+sessionId);
                HttpResponse response;        
                response = http.send(request); 
                Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                if(meta.containsKey('values')) {
                    
                    for(Object o: (List<Object>)meta.get('values')) {
                        Set<String> tempDepIndex = new Set<String> ();
                        Map<String,Object> temp = (Map<String,Object>) o;
                        String val = (String) temp.get('value');
                        pickListValues.add(val);
                    }
                }
                system.debug(':::::::::pickListValues::::'+pickListValues);
                
                List<UtilDomain.FilterDetails> statusFilters = new List<UtilDomain.FilterDetails>();
                
                UtilDomain.FilterDetails filter1 = new UtilDomain.FilterDetails();
                filter1.label = 'All';
                filter1.value = 'All';
                statusFilters.add(filter1);
                
                for(String status : pickListValues){
                    UtilDomain.FilterDetails filter = new UtilDomain.FilterDetails();
                    filter.label = status;
                    filter.value = status;
                    
                    statusFilters.add(filter);
                }
                
                return JSON.serialize(statusFilters);
                
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }else{
            
            List<UtilDomain.FilterDetails> statusFilters = new List<UtilDomain.FilterDetails>();
            
            UtilDomain.FilterDetails filter1 = new UtilDomain.FilterDetails();
            filter1.label = 'All';
            filter1.value = 'All';
            statusFilters.add(filter1);
            
            return JSON.serialize(statusFilters);
        }
    }
    
    public static String  getUserContactFilterId(){
        
        User logUser = [Select Id,firstname,middlename,lastname from User  where Id = :UserInfo.getUserId()];            
        
        if(logUser != null) {
            
            String query = 'SELECT Id,FirstName,MiddleName,LastName,Name,Default_Project_Summary_Filter__c FROM Contact WHERE FirstName = \''+(logUser.FirstName != null ? logUser.FirstName :'')+'\' AND MiddleName = \''+(logUser.MiddleName != null ?logUser.MiddleName:'')+'\' AND LastName = \''+(logUser.LastName != null ? logUser.LastName : '')+'\''; 
            List<Contact> contactRecord = database.query(query);
            
            String defaultFilter = '';
            
            if(contactRecord.size() > 0 && contactRecord[0].Default_Project_Summary_Filter__c != null){
                defaultFilter = contactRecord[0].Default_Project_Summary_Filter__c;
            }else {
                defaultFilter = null;
            }
            
            return defaultFilter;
        }else{
            return null;
        }
    }
    @AuraEnabled
    public static List<CsvInfo> downloadCsvFile(List<String> projectIdList,String type){
        
        List<CsvInfo> csvList = new List<CsvInfo>();                                        //Generate csv file with active instructors and studeents
        Set<Id> caSet = new Set<Id>();
        system.debug('projectIdList'+projectIdList);
        system.debug('type'+type);
        
        for(Contact_Assignments__c  ca:[
            SELECT Id, Candidate_Name__c, Project__r.Language_Name__c, Candidate_Name__r.FirstName, Candidate_Name__r.LastName, Candidate_Name__r.Email, RecordTypeId, RecordType.DeveloperName, Candidate_Name__r.Account.Name
            FROM Contact_Assignments__c 
            WHERE Project__c IN:projectIdList AND Status__c = 'Active' AND RecordType.DeveloperName = :type]){
                
                if(!caSet.contains(ca.Candidate_Name__c)){  
                    
                    CsvInfo csvRec = new CsvInfo();
                    
                    csvRec.firstname = ca.Candidate_Name__r.FirstName;
                    csvRec.lastname = ca.Candidate_Name__r.LastName;
                    csvRec.email = ca.Candidate_Name__r.Email;
                    csvRec.recordType = ca.RecordType.DeveloperName;
                    csvRec.language = ca.Project__r.Language_Name__c;

                    
                    if(ca.RecordType.DeveloperName == 'Student'){
                        csvRec.accName = ca.Candidate_Name__r.Account.Name;
                    }
                    csvList.add(csvRec);
                    caSet.add(ca.Candidate_Name__c); 
                }            
            }
        
        //system.debug('wrapList::::::'+wrapList);
        //system.debug('wrapList.size:::'+wrapList.size());
        return csvList;
    }
    
    
    public static List<projectSummaryInfo> projectSummaryRecordsFormation(List<AcctSeed__Project__c> projectRecords){
        
        List<projectSummaryInfo> projectSUmmaryList = new List<projectSummaryInfo>();       //Form project records into wrapper
        Map<Id , Integer> projIdWithDueActivitiesCount = CustomActivityTimelineController.getPendingActivities((new Map<Id, Acctseed__Project__c>(projectRecords)).keySet()); //Added By Dhinesh - 12/12/2022 - W-007463 - Add Activity/Tasks to the Project Summary Lightning Page (SEP-1-2022)
        
        for(AcctSeed__Project__c project : projectRecords){
            
            projectSummaryInfo projectSum = new projectSummaryInfo();
            projectSum.dlsRef = project.DLS_Ref__c;
            
            if(project.Start_Date__c != null) {
                projectSum.stDate = String.valueOf(project.Start_Date__c).split('-')[1]+'/'+String.valueOf(project.Start_Date__c).split('-')[2]+'/'+String.valueOf(project.Start_Date__c).split('-')[0];
            }
            
            if(project.End_Date__c != null) {
                projectSum.endDate = String.valueOf(project.End_Date__c).split('-')[1]+'/'+String.valueOf(project.End_Date__c).split('-')[2]+'/'+String.valueOf(project.End_Date__c).split('-')[0];
            }
            
            if(project.Scheduled_Hours_Week__c != null) {
                projectSum.scheduledHour = String.valueof(project.Scheduled_Hours_Week__c);
            }
            
            projectSum.rooms = project.All_Active_Rooms__c;
            
            if(project.Hours_Remaining__c != null) {
                projectSum.remainingHrs = String.valueof(project.Hours_Remaining__c);
            }
            
            projectSum.projectStatus = project.AcctSeed__Status__c;
            projectSum.activeInstructors = project.Instructors__c;
            projectSum.activeStudents = project.Students__c;
            projectSum.lastDateOfAttendance = project.Last_Date_of_Attendance__c != null ? ('0' + project.Last_Date_of_Attendance__c.month()).right(2)+'/'+('0' + project.Last_Date_of_Attendance__c.day()).right(2)+'/'+project.Last_Date_of_Attendance__c.year() : '';            
            
            if(project.AcctSeed__Account__c != null) {
                projectSum.accountId = project.AcctSeed__Account__c;
                projectSum.accountName = project.AcctSeed__Account__r.Name;
            }
            
            if(project.Language__c != null) {
                projectSum.languageId = project.Language__c;
                projectSum.languageName = project.Language__r.Name;
            }
            
            projectSum.projectId = project;
            projectSum.dueActivitiesCount = projIdWithDueActivitiesCount.containsKey(project.Id) ? projIdWithDueActivitiesCount.get(project.Id) : 0; //Added By Dhinesh - 12/12/2022 - W-007463 - Add Activity/Tasks to the Project Summary Lightning Page (SEP-1-2022)
            projectSUmmaryList.add(projectSum);                        
        }
        
        return projectSUmmaryList;
        
    }
    
    
    public class projectSummaryInfo{
        @AuraEnabled
        public string dlsRef;
        @AuraEnabled
        public string stDate;
        @AuraEnabled
        public string endDate;
        @AuraEnabled
        public String scheduledHour;
        @AuraEnabled
        public string rooms;
        @AuraEnabled
        public string remainingHrs;
        @AuraEnabled
        public string projectStatus;
        @AuraEnabled
        public string activeInstructors;
        @AuraEnabled
        public string activeStudents;
        @AuraEnabled
        public AcctSeed__Project__c projectId;
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String languageId;
        @AuraEnabled
        public String languageName;
        @AuraEnabled
        public string lastDateOfAttendance;
        
        //Added By Dhinesh - 12/12/2022 - W-007463 - Add Activity/Tasks to the Project Summary Lightning Page (SEP-1-2022)
        @auraEnabled
        public Integer dueActivitiesCount;
    }
    
    public class projectSummaryFullInfo{
        @AuraEnabled
        public List<projectSummaryInfo> projectSummaryList;
        @AuraEnabled
        public List<String> projectStatus;
        @AuraEnabled
        public List<String> contactAssStatus;
        @AuraEnabled
        public Decimal noOfProjects;
        @AuraEnabled
        public Decimal remainingHours;
        @AuraEnabled
        public Decimal hoursWeek;
        @AuraEnabled
        public Decimal activeInstructors;
        @AuraEnabled
        public Decimal activeStudents;
        @AuraEnabled
        public List<Saved_Search__c> savedSearchList;
        @AuraEnabled
        public List<recordTypeIdPickList> contactAssignmentTypeList;
    }
    public class recordTypeIdPickList{
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
    }
    public class FilterInfo{
        @AuraEnabled
        public List<Saved_Search__c> savedFiltersList;
        @AuraEnabled
        public string defaultFilterId;
        @AuraEnabled
        public List<String> projectStatus;
        @AuraEnabled
        public List<String> contactAssStatus;        
        @AuraEnabled
        public List<recordTypeIdPickList> contactAssignmentTypeList;
        @AuraEnabled
        public List<recordTypeIdPickList> projectTypeList;
        //Added By Dhinesh - 12/8/2022 - W-007549
        @AuraEnabled
        public List<String> projectSectionList;
    }
    public class CsvInfo{
        @AuraEnabled
        public String firstname;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String recordType;
        @AuraEnabled
        public String accName;
        @AuraEnabled
        public String language;
    }
    public class ProjectSummaryInputDetails{
        @AuraEnabled
        public List<Account> accountId;
        @AuraEnabled
        public String contactId;
        @AuraEnabled
        public String cAPosition;
        @AuraEnabled
        public String cARTId;
        @AuraEnabled
        public List<String> projectRTNames;
        @AuraEnabled
        public List<String> cAStatus;
        @AuraEnabled
        public String locationId;
        @AuraEnabled
        public List<String> projectStatus;
        @AuraEnabled
        public String sortingFieldName;
        @AuraEnabled
        public  String sortingOrder;
        //Modified by Dhinesh - 12/8/2022 - W-007549
        @AuraEnabled
        public String selectedSection;
    }
}