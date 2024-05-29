/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 03/21/2024
 * @last modified by  : Dhinesh Kumar
**/
// Used in Lightning Component - related to Conga Custom Buttons
// Developed by E.Keerthika on 5th, October 2018

public class CongaButtonsController {
    
    // For getting the Conga Query based on the name
    @AuraEnabled
    public static Id getCongaQuery(String queryName) {
        return CongaTranslator.getCongaQuery(queryName);
    }
    
    // For getting the Conga Template based on the name
    @AuraEnabled
    public static Id getCongaTemplate(String tempName) {
        return CongaTranslator.getCongaTemplate(tempName);
    }
    
    // For getting the Server Url and Session Id
    @AuraEnabled
    public static String getServerUrlSessionId() {
        
        String urlId='';
        PageReference ref = Page.Conga_SessionIdServerUrl;
        if(!test.isRunningTest()){
            urlId = ref.getContent().toString();
        } else {
            urlId = 'Start_Of_Session_Id test End_Of_Session_Id';
        }
        Integer startIndex = urlId.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                endIndex = urlId.indexOf('End_Of_Session_Id');
        
        return urlId.substring(startIndex, endIndex);
    }
    
    // For Conga Query Map
    @AuraEnabled
    public static Map<String, Id> getQryMap(String queryName) {
        
        Map<String, Id> qryNameIdMap = new Map<String, Id>();
        
        for(String qryName : queryName.split(',')) {
            
            if(!qryNameIdMap.containsKey(qryName)) {
                qryNameIdMap.put(qryName, getCongaQuery(qryName));
            }
        }
        return qryNameIdMap;
    } 
    
    // For Conga Template Map
    @AuraEnabled
    public static Map<String, Id> getTempMap(String tempName) {
        
        Map<String, Id> temNameIdMap = new Map<String, Id>();
        
        for(String temName : tempName.split(',')) {
            
            if(!temNameIdMap.containsKey(temName)) {
                temNameIdMap.put(temName, getCongaTemplate(temName));
            }
        }
        return temNameIdMap;
    } 
    
    // For creating the Cover Page 
    @AuraEnabled
    public static congaWrapper createCoverPageConga(String recId, String queryName, String tempName) {
        
        qryTempServerSessionWrapper wrapConga = new qryTempServerSessionWrapper();
        congaWrapper wrap = new congaWrapper();
        
        List<Sobject> objList = new List<Sobject>();
        List<Schedule__c> schList = new List<Schedule__c>();
        Id recordId = (Id)recId;
        
        if(String.valueOf(recordId.getSobjectType()) == 'Opportunity') {
            objList = [SELECT Id, Name, Room__c FROM Opportunity WHERE Id = :recId];
        } else {
            objList = [SELECT Id, Name, Room__c FROM AcctSeed__Project__c WHERE Id = :recId];
        }
        
        if(String.valueOf(recordId.getSobjectType()) == 'AcctSeed__Project__c') {
            schList = [SELECT Id, Name FROM Schedule__c WHERE Project__c = :recId];
        }
       
        wrapConga.queryNameIdMap.putAll(getQryMap(queryName));
        wrapConga.tempNameIdMap.putAll(getTempMap(tempName));
        wrapConga.sessionIdServerURL = getServerUrlSessionId();
        
        wrap.congaWrap = wrapConga;
        wrap.parentType = String.valueOf(recordId.getSobjectType());
        wrap.roomId = String.valueOf(objList[0].get('Room__c'));
        wrap.scheList = schList;
        
        return wrap;
    }
    
    // For DLI TOEP in Opportunity
    @AuraEnabled
    public static congaWrapper dliToep(String recId, String queryName, String tempName) {
    
        qryTempServerSessionWrapper wrapConga = new qryTempServerSessionWrapper();
        congaWrapper wrap = new congaWrapper();
        
        List<Opportunity> oppList = [SELECT Id, Name, Language__c FROM Opportunity WHERE Id = :recId];
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c FROM Contact_Assignments__c WHERE Opportunity_Name__c = :recId AND RecordType.DeveloperName = 'Instructor'];
        
        wrapConga.queryNameIdMap.putAll(getQryMap(queryName));
        wrapConga.tempNameIdMap.putAll(getTempMap(tempName));
        wrapConga.sessionIdServerURL = getServerUrlSessionId();
        
        wrap.congaWrap = wrapConga;
        wrap.conAssignList = conAssList;
        wrap.langId = (oppList.size() > 0) ? oppList[0].Language__c : '';
        return wrap;
    }
    
    // For Generate Door Signs in Project
    @AuraEnabled
    public static congaWrapper generateDoorSigns(String recId, String queryName, String tempName) {
        
        qryTempServerSessionWrapper wrapConga = new qryTempServerSessionWrapper();
        congaWrapper wrap = new congaWrapper();
        
        List<AcctSeed__Project__c> proList = [SELECT Id, Name, Language__c FROM AcctSeed__Project__c WHERE Id = :recId];
        List<Schedule__c> schList = [SELECT Id, Name, Days__c, Start_Time__c, End_Time__c, Room__c, Instructor__c FROM Schedule__c WHERE Project__c = :recId AND Status__c = 'Active' ORDER BY CreatedDate DESC];
        
        wrapConga.queryNameIdMap.putAll(getQryMap(queryName));
        wrapConga.tempNameIdMap.putAll(getTempMap(tempName));
        wrapConga.sessionIdServerURL = getServerUrlSessionId();
        
        wrap.congaWrap = wrapConga;
        wrap.scheList = schList;
        wrap.langId = (proList.size() > 0) ? proList[0].Language__c : '';
        return wrap;
    }
    
    // For Gen & Send DocuSign in Contact Assignment and Cost Rate
    @AuraEnabled
    public static generateWrapper genSendDocuSign(String recId) {
        
        generateWrapper wrap = new generateWrapper();
        Id recordId = (Id)recId;
        
        if(string.valueOf(recordId.getSobjectType()) == 'Contact_Assignments__c') {
            wrap.congaURL = GenSendDocusign.returnsUrlToSendDocusign(recordId);
        } else if(string.valueOf(recordId.getSobjectType()) == 'AcctSeed__Cost_Rates__c') {
            //wrap.congaURL = GenSendDocusign.returnsTheUrl(recordId);
        }
        
        wrap.sessionIdServerURL = getServerUrlSessionId();
        return wrap;
    }
    
    /* For Generate Form in Cost Rate
    @AuraEnabled
    public static generateWrapper generateForm(String recId) {
        
        generateWrapper wrap = new generateWrapper();        
        wrap.congaURL = GenSendDocusign.returnsUrlToGenForm(recId,'');        
        wrap.sessionIdServerURL = getServerUrlSessionId();
        return wrap;
    }*/
    
     
    // For Job Summary Report in Project Call from QuickAction
    @AuraEnabled
    public static congaWrapper jobSummaryReport(String recId, String queryName,String templateName) {
        
        qryTempServerSessionWrapper wrapConga = new qryTempServerSessionWrapper();
        congaWrapper wrap = new congaWrapper();
        List<AcctSeed__Project__c> projectList = [SELECT Id,Name FROM AcctSeed__Project__c WHERE Id = :recId];
        
        wrapConga.queryNameIdMap.putAll(getQryMap(queryName));
        wrapConga.TempNameIdMap.putAll(getTempMap(templateName));
        wrapConga.sessionIdServerURL = getServerUrlSessionId();
        if(projectList.size() > 0){
            wrapConga.projectName = projectList[0].Name;
            List<AcctSeed__Project_Task__c> proTask = [SELECT Id,Name,Project_Task_Type__c, Rate__c,Billable__c,Parent_Project_Task__r.Id,Parent_Project_Task__r.Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Parent_Project_Task__c != null AND Project_Task_Type__c = 'Preparation time' AND Parent_Project_Task__r.Project_Task_Type__c = 'Language Training' AND AcctSeed__Project__c = :projectList[0].Id];
            if(proTask.size() > 0){
                wrapConga.projectTaskId = proTask[0].Id;
                wrapConga.projectTaskName =  proTask[0].Project_Task_Type__c;
                wrapConga.parentProjectTaskId = proTask[0].Parent_Project_Task__r.Id;

                if(templateName == 'Job Summary Report - Labor Actual' ||templateName == 'Job Summary Report - Labor Planned'){
                    List<Contact_Assignments__c> cAList = [SELECT Id,Project_Task__c,Prep_Time_billable__c,Prep_Time_Rate__c FROM Contact_Assignments__c WHERE Project_Task__c = :proTask[0].Parent_Project_Task__r.Id];
                    if(cAList.size() > 0){
                        for(Contact_Assignments__c ca : cAList){
                            ca.Prep_Time_billable__c = proTask[0].Billable__c;
                            ca.Prep_Time_Rate__c = proTask[0].Rate__c;
                        }
                        update cAList;
                    }
                    
                }
            }
        }
        wrap.congaWrap = wrapConga;
        wrap.status = contactAssignmentHoursValidation_Ctrl.callApproval(recId,templateName);        
        return wrap;
    }
    
    public class qryTempServerSessionWrapper {
        @AuraEnabled public Map<String, Id> queryNameIdMap = new Map<String, Id>();
        @AuraEnabled public Map<String, Id> tempNameIdMap = new Map<String, Id>();
        @AuraEnabled public String sessionIdServerURL;
        @AuraEnabled public String projectName;
        @AuraEnabled public String projectTaskId;
        @AuraEnabled public String projectTaskName;
        @AuraEnabled public String parentProjectTaskId;
    }
    
    public class generateWrapper {
        @AuraEnabled public String sessionIdServerURL;
        @AuraEnabled public String congaURL;
        @AuraEnabled public Boolean isErrorMsg;
        @AuraEnabled public String objRecordId;
        @AuraEnabled public String errorMsg; 
        @AuraEnabled public List<String> valErrors;
        @AuraEnabled public List<congaUrlFormationWrapper> congaUrlInfo;
        
        //Added By Dhinesh - 08/03/2022
	    @AuraEnabled public List<Contact_Assignments__c> contactAssignments;
        @AuraEnabled public Map<String, String> conAssignIdWithCongaUrlMap;
        
        //Added By Dhinesh - 18/04/2022
        @AuraEnabled public Assessment_Report__c assessmentReport;

        //Added By Dhinesh - 21/03/2024
        @AuraEnabled public Boolean showProceedBtn;
    }
    
    public class congaWrapper {
        @AuraEnabled public qryTempServerSessionWrapper congaWrap = new qryTempServerSessionWrapper();
        @AuraEnabled public List<Contact_Assignments__c> conAssignList = new List<Contact_Assignments__c>();
        @AuraEnabled public List<Schedule__c> scheList = new List<Schedule__c>();
        @AuraEnabled public String parentType;
        @AuraEnabled public String roomId;
        @AuraEnabled public String langId;
        @AuraEnabled public String status;
    }
  
    public class congaUrlFormationWrapper{
        @AuraEnabled 
        public String label;
        @AuraEnabled 
        public String value;
        @AuraEnabled 
        public String congaUrl;
        @AuraEnabled
        public String customMessage;
    }
}