/**********************************************************************
    Created by Vinitha on Feb 1 2017: Domain class used for Project object inner class formation
***********************************************************************/

global class ProjectDomain {

    /**********************************************************************
        Modified by Vinitha on Feb 1 2017: Domain class used for ProjectDetailViewRouting_Component_Ctrl inner class formation
    ***********************************************************************/
    global class informationRelatedtoProject{
         global List<AcctSeed__Project__c> proRecQry;
         global List<AcctSeed__Project_Task__c> projectQry;
         global List<User> UserQry;
         global List<Contact_Assignments__c> staffqry;
         global List<Contact_Assignments__c> insQry;
         global List<Contact_Assignments__c> stuQry;
         global List<Contact_Assignments__c> clientpartqry;
         global List<Events__c> CancellationCountStudent;
         global List<Events__c> LateCancellationCountStudent;
         global List<Events__c> CancellationCountIns;
         global List<Events__c> CancellationCount;
         global List<Contact> contactqry;
         global List<Request__c> BookRequestQry;
         global List<ContentVersion> contentVersionQry;
         global List<Attendance__c> attenQry;
         global List<AcctSeed__Time_Card_Day__c> timelineqry;
         global List<Assessment_Report__c> AssessmentQry;
    }
    
    /**********************************************************************
        Modified by Vinitha on March 20 2017: Domain class used for ProjectBudgetInfoComponent_Ctrl inner class formation
    ***********************************************************************/
    global class budgetInfo{
        global String RequestName;
        global List<AcctSeed__Project__c> ProjectRec;
        global String oppName;
    }
    
    /**********************************************************************
    - Added by NS on Mar 28 2019
    - For Instructor & Student Community Project List view changes
    ***********************************************************************/
    public class ProjectInfo {
    
        public Id projectId;
        public String dlsClass;
        public String startDate;
        public String endDate;
        public Date stDate;
        public Date edDate;
        public String status;
        public String projectManager;
        public String trainingLocation;
        public String accountName;
        public String parentAccountName;
        public string dliProjectType;
    }
}