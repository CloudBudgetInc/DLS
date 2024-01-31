/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 09/26/2023
 * @last modified by  : Dhinesh Kumar
**/
public without sharing class AssessmentReport_Ctrl {
    
    @auraEnabled
    public static String getCommunityType(){
        
        return ListViewController.getCommunityPathPrefix();
    }
    
    @auraEnabled
    public static assessmentCmpWrap getAssessments(String status,String projectId, String reportType){
        String contactId = ListViewController.getLoggedUserContactId();
        String communityType =  Test.isRunningTest() ? 'instructor' : ListViewController.getCommunityPathPrefix();
        String caRecordType = communityType == 'student' ? 'Instructor' : 'Student';
        
        assessmentCmpWrap wrap = new assessmentCmpWrap();
        Map<String, List<ListViewController.PicklistWrap>> filterPicklistValues = new Map<String, List<ListViewController.PicklistWrap>>();  
        List<String> allStatus = new List<String>();      
        ListViewController.PicklistWrap allPicklist = new ListViewController.PicklistWrap();
        allPicklist.label='All';
        allPicklist.value='All';
        filterPicklistValues.put('status', new List<ListViewController.PicklistWrap>());
        filterPicklistValues.get('status').add(allPicklist);
        filterPicklistValues.put('project', new List<ListViewController.PicklistWrap>());
        filterPicklistValues.get('project').add(allPicklist);
        List<String> includeRecordTypes = new List<String>{}; //Added By Dhinesh Kumar - 25/11/2020,
                
        if(communityType == 'client'){
            includeRecordTypes.addAll(new List<String>{'DLI_W_Progress','Language_Training_Progress','Test_Report','APMO_Progress','DEA_Progress','DLI_W_Progress_2022','DLI_W_Test_Report','DLI_W_Self_Assessment_Test_Report'}); //Added DEA Progress - Dhinesh - 13/10/2022, Added DLI_W_Progress_2022 - 26/10/2022
        }else{
            if(reportType == 'Student Progress Reports'){               
                includeRecordTypes.addAll(new Set<String>{'DLI_W_Progress', 'Language_Training_Progress','APMO_Progress','DEA_Progress','DLI_W_Progress_2022'});                
            }else if(reportType == 'My Annual Reports'){
                includeRecordTypes.add('Annual_Instructor_Performance_Review');
            }else if(reportType == 'Test Reports'){
                includeRecordTypes.addAll(new Set<String>{'Test_Report'});                
            }else if(reportType == 'Assessment by Instructor'){
                includeRecordTypes.addAll(new Set<String>{'DLI_W_Test_Report'});
            }else if(reportType == 'Student Self-Assessment'){
                includeRecordTypes.addAll(new Set<String>{ 'DLI_W_Self_Assessment_Test_Report'});                
            }else if(reportType == 'All'){
                includeRecordTypes.addAll(new List<String>{'DLI_W_Progress','Language_Training_Progress','Test_Report','APMO_Progress', 'DEA_Progress','DLI_W_Progress_2022','DLI_W_Test_Report','DLI_W_Self_Assessment_Test_Report'});
            }
        }
        
        if(communityType == 'instructor'){
            for(ListViewController.PicklistWrap picklist : ListViewController.getPickListValues('Assessment_Report__c','Status__c')){
                if(picklist.value != 'Draft' && picklist.value != 'Canceled'){
                    allStatus.add(picklist.value);
                    picklist.label = picklist.value;
                    filterPicklistValues.get('status').add(picklist);
                }
            }
        }else{
            List<String> statusForStudentCommunity = new List<String>{'Draft', 'Scheduled', 'Submitted to LTS', 'Submitted to Student', 'Completed'};
            allStatus.addAll(statusForStudentCommunity);
            for(String statusStr : statusForStudentCommunity){
                ListViewController.PicklistWrap picklist = new ListViewController.PicklistWrap();
                picklist.label = statusStr;
                picklist.value = statusStr;
                filterPicklistValues.get('status').add(picklist);
            }
        }
        
        String filterStr = '';
        List<String> filterSet = new List<String>();
        if(String.isNotBlank(contactId) && communityType != 'client'){            
            if(communityType == 'instructor' && (reportType == 'Test Reports' || reportType == 'All')){
               filterStr = '(Instructor__c = \''+ contactId +'\' OR Tester__c = \''+contactId+'\') ';
            }else{
               filterStr = (communityType == 'instructor' ? 'Instructor__c' : 'Student__c') + ' = \''+contactId+'\' ';
            }
        }        
        
        filterSet.add(String.isNotBlank(status) && status != 'All' ? 'Status__c = \''+status+'\' ' : 'Status__c IN (\''+String.join(allStatus, '\',\'')+'\')');
                
        if(String.isNotBlank(projectId)){
            filterSet.add('Project__c = \''+projectId+'\' ');
        }else if(String.isNotBlank(contactId) && communityType == 'client'){
            List<Id> clientProjectIds = new List<Id>();
            for(Contact_Assignments__c contAssignment : [SELECT Id, Project__c FROM Contact_Assignments__c 
                                                                                              WHERE Candidate_Name__r.RecordType.DeveloperName IN ('USG_Client', 'Commercial_Client')
                                                                                              AND Candidate_Name__c = :contactId AND RecordType.DeveloperName = 'Client_Partner' 
                                                                                              AND Assignment_Position__c IN ('Coordinator','Client','Training Officer','Billing Contact','Academic Adviser','COR','KO','Contracting POC','Technical POC')                                                                                                 
                                                                                            ]){
                                                             
                clientProjectIds.add(contAssignment.Project__c);
            }
            filterSet.add('Project__c IN (\''+String.join(clientProjectIds, '\',\'')+'\')');
        }
        
        if(includeRecordTypes.size() > 0){
            filterSet.add('RecordType.DeveloperName IN (\''+String.join(includeRecordTypes, '\',\'')+'\')');
        }        
        
        //Modified by Dhinesh - 30/11/2022 - W-007644 - Show only completed - Observation Report or Annual Instructor performance review reports to instructor.        
        if(communityType == 'instructor' && (reportType == 'All' || reportType == 'My Observation Report' || reportType == 'My Annual Reports') && (status == 'Completed' || status == 'All')){            
            filterStr += ' AND (( ' + String.join( filterSet , ' AND ' ) + ' ) ';  
            filterStr += reportType == 'All' ? ' OR ' : ' AND ';
            String recTypeStr = reportType == 'My Annual Reports' ? 'RecordType.DeveloperName = \'Annual_Instructor_Performance_Review\'' : (reportType == 'My Observation Report' ? 'RecordType.DeveloperName IN (\'Observation_Report\', \'DLI_Observation_Report\')' : 'RecordType.DeveloperName IN (\'Observation_Report\', \'DLI_Observation_Report\', \'Annual_Instructor_Performance_Review\')'); //Added DLI_Observation_Report - By Dhinesh - 26/09/2023 - W-007881
            filterStr += '  ('+recTypeStr+' AND Status__c = \'Completed\'))';
        }else{
            if(communityType != 'client')    //W-007727 by NS on Feb 23 2023
                filterStr += ' AND ';
                
            filterStr += '( ' + String.join( filterSet , ' AND ' ) + ' ) ';  
        }
        
        system.debug('filterStrL::>'+filterStr);
        
        List<Assessment_Report__c> assessmentReportList = AssessmentReportService.getAssessmentReports(filterStr, ', Student__r.FirstName, Student__r.LastName, Project__r.DLS_Ref__c, Project__r.Name, Language_LU__r.Name, Project_Task__r.Total_Hours_Used_For_Language_Training__c, Project_Manager__r.Name, RecordType.DeveloperName');
        Set<Id> projectIds = new Set<Id>();
        for(Assessment_Report__c assessmentreport : assessmentReportList ){
            projectIds.add(assessmentreport.Project__c);
        }
        
        Map<Id, String> proIdCanditateNames = new Map<Id, String>();
        for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName FROM Contact_Assignments__c WHERE Status__c != 'Canceled' AND RecordType.DeveloperName = :caRecordType AND Project__c IN :projectIds]){
            String candidateName = '';
            
            candidateName = (ca.Candidate_Name__r.FirstName == null ? '' : ca.Candidate_Name__r.FirstName);
            candidateName += (ca.Candidate_Name__r.LastName != null ? ' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.' : '');
            
            if(!proIdCanditateNames.containsKey(ca.Project__c)){
                proIdCanditateNames.put(ca.Project__c,candidateName);
            }else {
                String existingName = proIdCanditateNames.get(ca.Project__c);
                
                proIdCanditateNames.put(ca.Project__c,(existingName+', '+candidateName));
            }
        }
        
        if(communityType == 'student' || communityType == 'client'){
            List<ProjectDomain.ProjectInfo> projectDetails = ((ListViewController.ProjectViewWrapper)JSON.deserialize(ListViewController.getProjectList(), ListViewController.ProjectViewWrapper.class)).projectRecords;
            for(ProjectDomain.ProjectInfo pro : projectDetails){
                ListViewController.PicklistWrap picklist = new ListViewController.PicklistWrap();
                picklist.label = pro.dlsClass;
                picklist.value = pro.projectId;
                filterPicklistValues.get('project').add(picklist);
            }
        }
        
        Map<String, String> rtMap = new Map<String, String>{
            'Observation_Report'=>'Observation Report',
            'DLI_Observation_Report'=>'Observation Report', //Added By Dhinesh - 26/09/2023 - W-007881
            'DLI_W_Progress'=>'Student Progress Report',
            'Language_Training_Progress'=>'Student Progress Report',
            'APMO_Progress' => 'Student Progress Report',
            'DEA_Progress' => 'Student Progress Report',
            'DLI_W_Progress_2022' => 'Student Progress Report',
            'DLI_W_Test_Report' => 'Assessment by Instructor',
            'DLI_W_Self_Assessment_Test_Report' => 'Student Self-Assessment',
            'Annual_Instructor_Performance_Review'=>'Annual Report',
            'Test_Report'=>'Test Report'
        };
        List<assessmentRec> assessmentReports = new List<assessmentRec>();
        for(Assessment_Report__c assessmentreport : assessmentReportList ){
            if(assessmentreport.RecordType.DeveloperName != 'Test_Report' || (assessmentreport.Tester__c == contactId || assessmentreport.Status__c == 'Completed')){ //Added By Dhinesh - 10/01/2023 - W-007679 - Restrict Instructor Visibility for Scheduled Test Reports in DLS Online
                assessmentRec assRec = new assessmentRec();
                assRec.Id = assessmentreport.Id;
                assRec.Name = assessmentreport.Name;
                assRec.Status = assessmentreport.Status__c;
                assRec.EvaluationPeriodTo = assessmentreport.Evaluation_Period_To__c;
                assRec.EvaluationPeriodFrom = assessmentReport.Evaluation_Period_From__c;
                assRec.ProjectId = assessmentReport.Project__c;
                assRec.projectClassNo = assessmentreport.Project__r.DLS_Ref__c+' - '+proIdCanditateNames.get(assessmentReport.Project__c);
                assRec.boxURL = assessmentreport.Box_File_Shared_URL__c;
                assRec.dateCompleted = assessmentreport.Date_Completed__c;
                assRec.reviewPeriod = assessmentreport.Review_Period_Year__c;
                assRec.supervisorName = assessmentreport.Project_Manager__r.Name;
                assRec.typeOfReport = rtMap.get(assessmentreport.RecordType.DeveloperName);
                assRec.recordTypeDevName = assessmentreport.RecordType.DeveloperName;
                assRec.dueDate = assessmentreport.Report_Date__c;            
                assessmentReports.add(assRec);
            }
        }        
        wrap.assessments = assessmentReports;
        wrap.filterPicklistValues = filterPicklistValues;
        
        return wrap;
    }
    
    public class AssessmentCmpWrap{
        @auraEnabled public List<assessmentRec> assessments;
        @auraEnabled public Map<String, List<ListViewController.PicklistWrap>> filterPicklistValues;
    }
    
    public Class assessmentRec{
        @auraEnabled public String Name;
        @auraEnabled public String Id;
        @auraEnabled public String projectClassNo;
        @auraEnabled public String Status;
        @auraEnabled public Date EvaluationPeriodTo;
        @auraEnabled public Date EvaluationPeriodFrom;
        @auraEnabled public Date dateCompleted;
        @auraEnabled public String ProjectId;
        @auraEnabled public String boxURL;        
        
        //Added By Dhinesh - 07/10/2021 - Annual Performance Review Report
        @auraEnabled public String reviewPeriod;
        @auraEnabled public String supervisorName;
        
        //Added By Dhinesh - 21/01/2022 - Add All value in Type of Reports
        @auraEnabled public String typeOfReport;
        
        //Added By Dhinesh - 22/03/2022 - W-007325 - Show date field
        @auraEnabled public Date dueDate;   
        
        @auraEnabled public String recordTypeDevName; //Added By - Dhinesh -  03/11/2022
    }

    @auraEnabled
    public static assessmentRecForEdit getAssessmentReportById(String recordId){
        assessmentRecForEdit assessmentRecForEditWrap = new assessmentRecForEdit();
        String contactId = ListViewController.getLoggedUserContactId();
        
        Assessment_Report__c assessment = new Assessment_Report__c();
        if(String.isNotBlank(recordId)){
            String filterStr = 'Id = \''+recordId+'\'';
            String parentFields = ', Project__r.AcctSeed__Account__c, Project__r.AcctSeed__Account__r.Name, Training_officer__r.Name, Student__r.Name, Sponser__r.Name, RecordType.Name, Instructor__r.Name, Language_LU__r.Name, Project_Task__r.Total_Hours_Used_For_Language_Training__c';
            List<Assessment_Report__c> assessmentReports = AssessmentReportService.getAssessmentReports(filterStr, parentFields);
            if(assessmentReports.size() > 0){
                assessment = assessmentReports[0];
                
                //Modified by Dhinesh - 27/02/2023 - W-007723 update total hrs absent
                if(assessment.Report_Type__c == 'DEA'){
                    List<Contact_Assignments__c> caList = [SELECT Id, Student_Hours_Absent__c FROM Contact_Assignments__c WHERE Project__c = :assessment.Project__c AND Candidate_Name__c = :assessment.Student__c];
                    if(caList.size() > 0){
                        assessmentRecForEditWrap.studentCA = caList[0];
                    }
                }
            }
        }
        assessmentRecForEditWrap.assessmentRec = assessment;
        assessmentRecForEditWrap.isAllowEdit = assessment.RecordType.Name == 'Test Report' ? contactId == assessment.Tester__c : contactId == assessment.Instructor__c;
        if(assessment.RecordType.Name == 'DLI-W Self-Assessment Test Report'){
            assessmentRecForEditWrap.isAllowEdit = true;
        }
        return assessmentRecForEditWrap;
    }
    
     public Class assessmentRecForEdit{
        @auraEnabled public Assessment_Report__c assessmentRec;        
        @auraEnabled public Boolean isAllowEdit;
        @auraEnabled public Contact_Assignments__c studentCA; //Modified by Dhinesh - 27/02/2023 - W-007723 update total hrs absent
     }
    
    @AuraEnabled
    public static ActionPlanAndTestScoreWrap getActionPlanAndTestScoreByAssessmentId(String assessmentId){
        ActionPlanAndTestScoreWrap wrapObj = new ActionPlanAndTestScoreWrap();
        wrapObj.actionPlans = ActionPlanService.getActionplan(' WHERE Assessment_Report__c = \''+assessmentId+'\'');
        wrapObj.testScores = TestScoreService.getTestscore(' WHERE Assessment_Report__c = \''+assessmentId+'\'', null);

        return wrapObj;
    }

    public class ActionPlanAndTestScoreWrap{
        @AuraEnabled
        public List<Action_Plan__c> actionPlans;
        @AuraEnabled
        public List<Test_Score__c> testScores;
    }

    public class SaveReportWrap{
        public Assessment_Report__c assessmentReport;
        public List<Action_Plan__c> actionPlans; 
        public List<Test_Score__c> testScores; 
        public List<Id> recordsToDelete;
    }

    @AuraEnabled
    public static string saveAssessmentReport(String saveChangeStr){

        String result = 'success';
        try{
            SaveReportWrap wrapObj = (SaveReportWrap)JSON.deserializeStrict(saveChangeStr, SaveReportWrap.class);
            update wrapObj.assessmentReport;

            if(wrapObj.actionPlans != null && wrapObj.actionPlans.size() > 0){
                
                upsert wrapObj.actionPlans;
            }

            if(wrapObj.testScores != null && wrapObj.testScores.size() > 0){
                upsert wrapObj.testScores;
            }

            if(wrapObj.recordsToDelete != null && wrapObj.recordsToDelete.size() > 0){
                database.delete(wrapObj.recordsToDelete);
            }

        }catch(Exception exe){
            result = exe.getMessage();            
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('AssessmentReport_Ctrl','saveAssessmentReport','',result+' at line number '+exe.getLineNumber(),saveChangeStr,'Lightning Web Component')});
        }

        return result;
    }    
}