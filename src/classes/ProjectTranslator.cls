/**********************************************************************
    Created by Vinitha on Feb 1 2017: Translator class used for Project object inner class formation
***********************************************************************/

global class ProjectTranslator {

    /**********************************************************************
        Modified by Vinitha on Feb 1 2017: Translator class used for ProjectDetailViewRouting_Component_Ctrl inner class formation
    ***********************************************************************/
    
    global static ProjectDomain.informationRelatedtoProject ProjectInfoMethod(List<AcctSeed__Project__c> projectList,List<AcctSeed__Project_Task__c> projectTaskList,List<User> userconList,List<Contact_Assignments__c> staffList,List<Contact_Assignments__c> insList,List<Contact_Assignments__c> stuList,List<Contact_Assignments__c> clientpartList,List<Events__c> CancelstuList,List<Events__c> LateCancelstuList,List<Events__c> CancelInsList,List<Events__c> CancelList,List<Contact> contactList,List<Request__c> BookRequestList,List<ContentVersion> contentVersionList,List<Attendance__c> attenList,List<AcctSeed__Time_Card_Day__c> timelineList,List<Assessment_Report__c> assessmentList) {
             
        ProjectDomain.informationRelatedtoProject projectInfo = new ProjectDomain.informationRelatedtoProject();
        projectInfo.proRecQry = projectList;
        projectInfo.projectQry = projectTaskList;
        projectInfo.UserQry = userconList;
        projectInfo.staffqry = staffList;
        projectInfo.insQry = insList;
        projectInfo.stuQry = stuList;
        projectInfo.clientpartqry = clientpartList;
        projectInfo.CancellationCountStudent = CancelstuList;
        projectInfo.LateCancellationCountStudent = LateCancelstuList;
        projectInfo.CancellationCountIns = CancelInsList;
        projectInfo.CancellationCount = CancelList;
        projectInfo.contactqry = contactList;
        projectInfo.BookRequestQry = BookRequestList;
        projectInfo.contentVersionQry = contentVersionList;
        projectInfo.attenQry = attenList;
        projectInfo.timelineqry = timelineList;
        projectInfo.AssessmentQry = assessmentList;
        
        return projectInfo;
        
    }
    
    /*************************************************************************************************
    
    - Method to form the wrapper for Instructor & Student Community list view
    - Added by NS on Mar 28 2019
    *************************************************************************************************/
    public static List<ProjectDomain.ProjectInfo> projectRecordsFormation(List<AcctSeed__Project__c> projects){
        
        List<ProjectDomain.ProjectInfo> projectRecords = new List<ProjectDomain.ProjectInfo>();
        
        for(AcctSeed__Project__c project : projects) {
            
            ProjectDomain.ProjectInfo projectWrap = new ProjectDomain.ProjectInfo();
            projectWrap.projectId = project.Id;
            projectWrap.dlsClass = getDLSClassName(project);
            if(project.Start_Date__c != null) {
                projectWrap.startDate = project.Start_Date__c.month()+'/'+project.Start_Date__c.day()+'/'+project.Start_Date__c.year();
            }
            if(project.End_Date__c != null) {
                projectWrap.endDate = project.End_Date__c.month()+'/'+project.End_Date__c.day()+'/'+project.End_Date__c.year();
            }
            projectWrap.stDate = project.Start_Date__c;
            projectWrap.edDate = project.End_Date__c;
            projectWrap.status = project.AcctSeed__Status__c;
            projectWrap.projectManager = project.Project_Manager__r.Name;
            projectWrap.trainingLocation = project.Training_Location__r.Name;
            projectWrap.accountName = project.AcctSeed__Account__r.Name;
            projectWrap.parentAccountName = project.AcctSeed__Account__r.Parent.Name;
            projectWrap.dliProjectType = project.DLI_Project_Type__c;
            
            projectRecords.add(projectWrap); 
        }
        return projectRecords;
    
    }
    
    public static String getDLSClassName(AcctSeed__Project__c project){
        String dlsClassName = project.DLS_Ref__c;
        
        if(project.Contact_Assignments__r.size() > 0){
            
            dlsClassName += '/';
            List<String> caNames = new List<String>();
            
            for(Contact_Assignments__c ca : project.Contact_Assignments__r){
                
                caNames.add(ca.Candidate_Name__r.FirstName+' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.'); 
            }
            
            dlsClassName += String.join( caNames, ',' );
        }
        
        return dlsClassName;
    }
    
    
    
}