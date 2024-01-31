/**
 * @description       : 
 * @author            : Vasanthram
 * @group             : 
 * @last modified on  : 09-14-2023
 * @last modified by  : Vasanthram
**/
public without sharing class ListViewController {
    
    @AuraEnabled
    public static String getProjectList() {
        String contactId = getLoggedUserContactId(); // Get Currently logged user's contact Id
        String communityName = getCommunityPathPrefix();
        List<String> excludeProStatusOptions = new List<String>{'Order','Staffing'};
        List<PicklistWrap> pickListValues = new List<PicklistWrap>();
        ProjectViewWrapper listView = new ProjectViewWrapper();
        
        try{
            
            String recordTypeName;
                                    
            recordTypeName = (communityName == 'instructor') ?  'Instructor'  :  ((communityName == 'client') ? 'Client_Partner' : 'Student');  
                
            String contactAssignmentRecordType = communityName == 'student' ? 'Instructor' : 'Student';
            
            Set<Id> projectIds = new Set<Id>();
            Map<Id, String> projectIdWithCAStatus = new Map<Id, String>();
            
            if(String.isNotBlank(contactId)){
                String caQryStr = 'SELECT Id,Name,Status__c,Project__c,RecordType.DeveloperName FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId AND RecordType.DeveloperName =  :recordTypeName AND Project__c != null';
                if(communityName == 'student') {
                    caQryStr += ' AND Project__r.No_Student_Approval__c = false';
                }
                if(communityName == 'client'){
                    caQryStr += ' AND Candidate_Name__r.RecordType.DeveloperName IN (\'USG_Client\', \'Commercial_Client\')';
                }
                caQryStr += ' ORDER BY End_Date__c ASC';
                for(Contact_Assignments__c ca : Database.query(caQryStr)){
                    projectIds.add(ca.Project__c);
                    if(!projectIdWithCAStatus.containsKey(ca.Project__c) || (projectIdWithCAStatus.containsKey(ca.Project__c) && projectIdWithCAStatus.get(ca.Project__c) != 'Active')){
                      projectIdWithCAStatus.put(ca.Project__c, ca.Status__c);
                    }
                }                
            }
            System.debug('projectIds::>'+projectIds);
            List<AcctSeed__Project__c> projects = new List<AcctSeed__Project__c>();
            
            if(projectIds.size() > 0){
                projects = [SELECT Id,Name,AcctSeed__Account__r.Name,AcctSeed__Account__r.Parent.Name,DLS_Ref__c,Start_Date__c,End_Date__c, AcctSeed__Status__c,Project_Manager__c,Project_Manager__r.Name,Training_Location__c,Training_Location__r.Name, DLI_Project_Type__c,
                            (SELECT Id,Name,Project__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName FROM Contact_Assignments__r WHERE RecordType.DeveloperName = :contactAssignmentRecordType ORDER BY Start_Date__c ASC) 
                            FROM AcctSeed__Project__c WHERE Id IN : projectIds];
            }
            
            listView.projectRecords = ProjectTranslator.projectRecordsFormation(projects);
            List<PicklistWrap> pickWrap = getPickListValues('AcctSeed__Project__c','AcctSeed__Status__c');
            
            if(pickWrap.size() > 0){
                for(PicklistWrap pick : pickWrap){
                    if(!excludeProStatusOptions.contains(pick.label)){
                        PicklistWrap pickListVal = new PicklistWrap();
                        
                        pickListVal.label = pick.label;
                        pickListVal.value = pick.value;
                        pickListValues.add(pickListVal);
                    }
                }
            }
            
            
            listView.statusValues = pickListValues;
            listView.projectIdWithCAStatus = projectIdWithCAStatus;
            return JSON.serialize(listView);
            
        }catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage());    
        }
        
    }
    
    @AuraEnabled
    public static String getScheduleList(list<String> statusValues , List<String> taskTypes) {
        
        String contactId = getLoggedUserContactId(); // Get Currently logged user's contact Id
        String communityName = getCommunityPathPrefix();
        List<PicklistWrap> pickListValues = new List<PicklistWrap>();
        List<String> projectRefsList = new List<String>();
        ScheduleViewWrapper listView = new ScheduleViewWrapper();
        system.debug('::communityName::'+communityName);
        
        if(Test.isRunningTest()){
            communityName = 'Instructor';
        }
        
        if(communityName == 'client'){
            communityName = 'Client_Partner';
        }
        
        String projectListStr = 'SELECT Id, Project__r.Name,Project__c, Project__r.Start_Date__c, Project__r.End_Date__c, Project__r.DLS_Ref__c, Project__r.AcctSeed__Status__c,Candidate_Name__c, RecordType.DeveloperName FROM Contact_Assignments__c WHERE RecordType.DeveloperName =:communityName'; 
        
        if(contactId != null && contactId != '') {
            projectListStr += ' and Candidate_Name__c =:contactId';
        }
        
        projectListStr += ' ORDER BY Candidate_Name__r.FirstName ASC';
        
        
        //ProjectFilter formation
        
        List<Contact_Assignments__c> projectList = Database.query(projectListStr);
        Set<Id> projectIdSet = new Set<Id>();
        PicklistWrap pickListVal = new PicklistWrap();
        pickListVal.label = 'All';
        pickListVal.value = 'All';
        pickListValues.add(pickListVal);
        for(Contact_Assignments__c assign : projectList){                                   
            if(assign.Project__c != null){
                projectIdSet.add(assign.Project__c);
            }
        }
        system.debug('projectIdSet'+projectIdSet);
        
        //Picklist for prooject filter
        
        
        for(AcctSeed__Project__c proj : [SELECT Id,Name,AcctSeed__Account__r.Name,DLS_Ref__c,Start_Date__c,End_Date__c, AcctSeed__Status__c,Project_Manager__c,Project_Manager__r.Name,Training_Location__c,Training_Location__r.Name FROM AcctSeed__Project__c WHERE Id IN : projectIdSet] ){
            
            PicklistWrap pickListVal1 = new PicklistWrap();
                if(proj.DLS_Ref__c != null){
                    pickListVal1.label = proj.DLS_Ref__c;
                    pickListVal1.value = proj.id;
                    pickListValues.add(pickListVal1);
                }
        }
        
        system.debug('pickListValues'+pickListValues);
        
        /*List<Schedule__c> scheduleList = [SELECT Id, Name, Project__c,Project__r.DLS_Ref__c, Status__c, Days__c, Start_Date__c, End_Date__c, Start_Time__c, DLS_Ref__c,
                                          End_Time__c, Project_Task__r.Name,Project_Task__r.Project_Task_Type__c, Instructor__r.Name,Room__r.Name, Total_Hours_per_Session__c, 
                                          Total_Hours__c, Timezone__c, Project_Task__r.Unit__c FROM Schedule__c WHERE Project__c IN :projectIdSet  ORDER BY Start_Time__c ASC];
       listView.scheduleRecords = ScheduleTranslator.scheduleRecordsFormation(scheduleList);*/
        
        listView.projectValues = pickListValues;

        system.debug('listView'+listView);
        return JSON.serialize(listView);
        
        /*}catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
            }*/
        
    } 
    
    @AuraEnabled
    public static String getSchedule(String projectId, String status) {
        try{
            ScheduleViewWrapper listView = new ScheduleViewWrapper();
            List<String> statusValues = new List<String>();
            String scheduleQry = 'SELECT Id, Name, Project__c, Instructor__c, Status__c, Days__c,DLS_Ref__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Project_Task__r.Name, Instructor__r.Name,Room__r.Name, Total_Hours_per_Session__c, Total_Hours__c, Hours_Planned__c, Timezone__c, Project_Task__r.Unit__c,Project_Task__r.Project_Task_Type__c FROM Schedule__c WHERE Project__c = :projectId';
            String communityName = getCommunityPathPrefix();
            String contactId = getLoggedUserContactId();
            
            Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Schedule__c').getDescribe().fields.getMap();
            
            Schema.DescribeFieldResult picklistFieldDescribe = fieldMap.get('Status__c').getDescribe();
            
            if((communityName == 'instructor' && contactId != null && contactId != '') || Test.isRunningTest()) {
                scheduleQry +=' AND Instructor__c =:contactId';
            }
            if(status != null && status != ''){
                scheduleQry +=' AND Status__c =:status';
            }
            if(communityName != 'instructor'){
                scheduleQry += ' AND Project_Task__r.Project_Task_Type__c != \'Preparation Time\'';
            }
            scheduleQry += ' ORDER BY Start_Time__c ASC';
            
            listView.scheduleRecords = ScheduleTranslator.scheduleRecordsFormation(database.query(scheduleQry));
            
            
            for(Schema.PicklistEntry loop_var : picklistFieldDescribe.getPicklistValues()){
                if(loop_var.isActive()){
                    statusValues.add((String)loop_var.getLabel());
                }
            } 
            listView.statusValues = statusValues;
            return JSON.serialize(listView);
            
        }catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage());    
        }
    }
    
    @AuraEnabled
    public static String getProjectRecord(String projectId){
        try{
            AcctSeed__Project__c projectRec = [SELECT Id, Name,DLS_Ref__c, Start_Date__c, End_Date__c, AcctSeed__Status__c, DLI_Project_Type__c,
                                               Project_Manager__r.Name, Training_Location__r.Name,AcctSeed__Account__r.Name, AcctSeed__Account__r.Parent.Name
                                               FROM AcctSeed__Project__c  WHERE Id = :projectId];  
            return json.serialize(ProjectTranslator.projectRecordsFormation(new List<AcctSeed__Project__c>{projectRec})[0]);
        }catch (Exception e) {
            
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage());    
        }
    }
    
    @AuraEnabled
    public static String getSchduleRecord(String scheduleId){
        try{
            Schedule__c scheduleRec = [SELECT Id, Name, Project__c, Status__c, Days__c, Start_Date__c, End_Date__c, Start_Time__c, DLS_Ref__c,
                                       End_Time__c, Project_Task__r.Name,Project_Task__r.Project_Task_Type__c, Instructor__r.Name,Room__r.Name, Total_Hours_per_Session__c, 
                                       Total_Hours__c, Hours_Planned__c, Timezone__c, Project_Task__r.Unit__c FROM Schedule__c WHERE Id =:scheduleId];
            
            return json.serialize(ScheduleTranslator.scheduleRecordsFormation(new List<Schedule__c>{scheduleRec})[0]);
        }catch (Exception e) {
            
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage());    
        }
    }
    
    public static String getLoggedUserContactId() {
        return [Select Id,ContactId FROM User where Id =: userInfo.getUserId()].ContactId;
    }
    
    public static String getCommunityPathPrefix() {
        String communityName = '';
        
        List<NetWork> networkRecord = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId()];
        
        if(networkRecord.size() > 0){
            communityName = networkRecord[0].UrlPathPrefix;
        }
        
        return communityName;
    }
    
    @AuraEnabled
    public static List<PicklistWrap> getPickListValues(String sObjectName, String picklistName){
        List<PicklistWrap> pickListValues = new List<PicklistWrap>();
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        
        Schema.DescribeFieldResult picklistFieldDescribe = fieldMap.get(picklistName).getDescribe();
        for(Schema.PicklistEntry loop_var : picklistFieldDescribe.getPicklistValues()){
            PicklistWrap pickListVal = new PicklistWrap();
            if(loop_var.isActive()){
                pickListVal.label = (String)loop_var.getLabel();
                pickListVal.value = (String)loop_var.getValue();
                pickListValues.add(pickListVal);
            }
        }   
        
        return pickListValues;
    }
    @AuraEnabled
    public static String getScheduleByFilter(String projectId, List<String> statusList ,List<String> projectTask){
        
        system.debug('projectId'+projectId);
        system.debug('statusList'+statusList);
        system.debug('projectTask'+projectTask);
        
        String contactId = getLoggedUserContactId(); // Get Currently logged user's contact Id
        String communityName = getCommunityPathPrefix();
        Map<String ,String> projectIdNameMap = new Map<String,String>();
        List<String> statusValues = new List<String>();
        List<PicklistWrap> pickListValues = new List<PicklistWrap>();
        List<String> projectRefsList = new List<String>();
        set<Id> projectIdSet = new Set<Id>();
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Schedule__c').getDescribe().fields.getMap();
        
        Schema.DescribeFieldResult picklistFieldDescribe = fieldMap.get('Status__c').getDescribe();
        
        if(Test.isRunningTest()){
            communityName = 'Instructor';
        }
         if(communityName == 'client'){
            communityName = 'Client_Partner';
        }

        String contactAssignStr = 'SELECT Id, Project__r.Name,Project__c, Project__r.Start_Date__c, Project__r.End_Date__c, Project__r.DLS_Ref__c, Project__r.AcctSeed__Status__c,Candidate_Name__c, RecordType.DeveloperName FROM Contact_Assignments__c WHERE RecordType.DeveloperName = :communityName'; 
        
        if(contactId != null && contactId != '') {
            contactAssignStr += ' AND Candidate_Name__c = :contactId';
        }
        
        contactAssignStr += ' ORDER BY Candidate_Name__r.FirstName ASC';
        
        
        //ProjectFilter formation
        
        List<Contact_Assignments__c> caList = Database.query(contactAssignStr);
        
            for(Contact_Assignments__c assign : caList){                                   
            if(assign.Project__c != null){
                projectIdSet.add(assign.Project__c);
            }
        }
        
        
        ScheduleViewWrapper schedule = new ScheduleViewWrapper();
        if(projectId == 'All'){
            projectId = null;
        }
        
        String scheduleQuery = 'SELECT Id, Name, Project__c, Status__c, Days__c, Start_Date__c, End_Date__c, Start_Time__c, DLS_Ref__c,'+
            'End_Time__c, Project_Task__r.Name, Instructor__r.Name,Room__r.Name,Project_Task__r.Project_Task_Type__c, Total_Hours_per_Session__c,'+ 
            'Total_Hours__c, Hours_Planned__c, Timezone__c, Project_Task__r.Unit__c FROM Schedule__c WHERE ';
            
        String condition = '';
        
        if(communityName == 'instructor'){
            condition += 'Instructor__c = :contactId';
        }
        
        if(projectId != null && String.isNotBlank(condition)){
        
            condition = condition+' AND Project__c = :projectId';
            
        }else if(projectId != null && String.isBlank(condition)){
        
            condition = condition+'Project__c = :projectId';
            
        }else if(String.isNotBlank(condition)){
        
            condition += ' AND Project__c IN :projectIdSet';
            
        }else if(String.isBlank(condition)){
        
            condition += 'Project__c IN :projectIdSet';
        }
        
        if(statusList.size() > 0 && String.isNotBlank(condition)){
            condition = condition+' AND Status__c IN :statusList';
        }else if(statusList.size() > 0 && String.isBlank(condition)){
            condition = condition+'Status__c IN :statusList';
        }
        
        if(String.isNotBlank(condition)) {
            if(projectTask.size() > 0){
                condition = condition+' AND Project_Task__r.Project_Task_Type__c IN :projectTask';
            }else{
                projectTask.add('Language Training');
                projectTask.add('Preparation Time');
                condition = condition+' AND Project_Task__r.Project_Task_Type__c NOT IN :projectTask';
            }
        }else {
            if(projectTask.size() > 0){
                condition = condition+'Project_Task__r.Project_Task_Type__c IN :projectTask';
            }else{
                projectTask.add('Language Training');
                projectTask.add('Preparation Time');
                condition = condition+'Project_Task__r.Project_Task_Type__c NOT IN :projectTask';
            }
        }
        
        if(String.isNotBlank(condition)){
            scheduleQuery += condition;
        }
        
        system.debug('::::::::scheduleQuery::::::::'+scheduleQuery);
        List<Schedule__c> scheduleList = Database.query(scheduleQuery);
        schedule.scheduleRecords = ScheduleTranslator.scheduleRecordsFormation(scheduleList);
        
        return  JSON.serialize(schedule);   
    }
    
    //This method to get the instructor session id for the VR autorization
    //Added by NS on Feb 10 2020
    @AuraEnabled
    public static String payloadConstructionMethod(String dlsClass,String projectId){
        
        String payloadUrl = '';
        
        Id userId = UserInfo.getUserId();
        String contactId = getLoggedUserContactId();
        String sessionId = UserInfo.getOrganizationId()+''+UserInfo.getSessionId().SubString(15);
        
        payloadUrl = 'class#='+dlsClass+'&projectId='+projectId+'&instructorContactId='+contactId+'&instructorUserId='+userId+'&sessionId='+sessionId;
        
        system.debug(':::::::payloadUrl::::'+payloadUrl);
        
        String encodedUrl = EncodingUtil.urlEncode(payloadUrl, 'UTF-8');
        
        system.debug(':::::::encodedUrl:::::'+encodedUrl);
        
        return encodedUrl;
    }
    
    @AuraEnabled 
    public static List<Contact_Assignments__c> getPolicyAndCertificateDetails(String projectId){
        String contactId = getLoggedUserContactId();
        String communityName = getCommunityPathPrefix();
       
        List<Contact_Assignments__c> ca = new List<Contact_Assignments__c>();
        
        if(communityName == 'client'){
            ca = [SELECT Id, Candidate_Name__r.Name, DLS_Policies_and_Procedures_Agreed_Date__c, Certificate_Generated_Date__c
                     FROM Contact_Assignments__c 
                     WHERE Project__c = :projectId AND RecordType.DeveloperName = 'Student' AND (Certificate_Box_Share_URL__c != null OR Policies_and_Procedure_Box_Share_URL__c != null)];
        }else{
            ca = [SELECT Id, Candidate_Name__r.Name, Name, Policies_and_Procedure_Box_Share_URL__c, Certificate_Box_Share_URL__c 
                      FROM Contact_Assignments__c 
                      WHERE Project__c = :projectId AND Candidate_Name__c = :contactId AND (Certificate_Box_Share_URL__c != null OR Policies_and_Procedure_Box_Share_URL__c != null)];
        }
        
        return ca;
    }
    
    //Added By Dhinesh - 11/11/2021 - W-007178 - To Display Language Testing Recs in Student and Instructor Community
    @AuraEnabled
    public static List<Language_Testing__c> getLanguageTestingRecords(String projectId){
        String contactId = getLoggedUserContactId();
        String communityName = getCommunityPathPrefix();
        
        String queryStr = 'SELECT Id,Testee__c,Testee__r.Name,Tester__c,Tester__r.Name,Test_Type__c,Date_Time_Scheduled__c,'+
                    'L_Score__c,R_Score__c,S_Score__c,W_Score__c FROM Language_Testing__c '+
                    'WHERE Project__c = :projectId';
        
        queryStr += communityName == 'student' ? ' AND Testee__c = :contactId' : ( communityName == 'instructor' ? ' AND Tester__c = :contactId' : '');       
        
        return Database.query(queryStr);
    }
    
    
    @AuraEnabled
    public static string getCommunityName(){
        return EventCalendarController.getCommunityPathPrefix();
    }
    public class ProjectViewWrapper{
        @AuraEnabled
        public List<ProjectDomain.ProjectInfo> projectRecords = new List<ProjectDomain.ProjectInfo>();
        @AuraEnabled
        public List<PicklistWrap> statusValues = new List<PicklistWrap>();
        @AuraEnabled
        public Map<Id, String> projectIdWithCAStatus = new  Map<Id, String>();
    }
    
    public class ScheduleViewWrapper{
        @AuraEnabled
        public List<ScheduleDomain.ScheduleInfo> scheduleRecords = new List<ScheduleDomain.ScheduleInfo>();
        @AuraEnabled
        public List<PicklistWrap> projectValues = new List<PicklistWrap>();
        @AuraEnabled
        public List<String> statusValues = new List<String>();
    }
    
    public class PicklistWrap{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        
        public PicklistWrap(String label, String value){
            this.label = label;
            this.value = value;
        }
        
        public PicklistWrap(){}
    }
}