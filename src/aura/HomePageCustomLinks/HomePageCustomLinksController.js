({
	candidateSearch : function(component, event, helper) {
        helper.redirectToPage(component,event,'/lightning/n/Candidate_Search');
	},
    LanguageSearch : function(component, event, helper) {
		helper.redirectToPage(component,event,'/apex/LanguageSearchFullList');
	},
    uploadResume : function(component, event, helper) {
        helper.redirectToPage(component,event,'/apex/RChilliResumeUploadWizardPage');
	},
    plannedOff : function(component, event, helper){
        helper.redirectToPage(component,event,'/lightning/n/Planned_Days_Off');
    },
    findSchools : function(component, event, helper) {
        helper.redirectToPage(component,event,'/apex/FindPartnerSchool_InternalPage');
	},
    roomSearch : function(component, event, helper) {
        helper.redirectToPage(component,event,'/apex/Room_Search');
	},
    progressReport : function(component, event, helper) {
        helper.redirectToPage(component,event,'/a5E');
	},
    dispositionForm : function(component, event, helper) {
        helper.redirectToPage(component,event,'/apex/AccountOpportunitySearchPage');
	},
    AnalyticsTool : function(component, event, helper) {
        helper.redirectToPage(component,event,'/apex/FeedbackPage');
	},
    library : function(component, event, helper) {
        helper.redirectToPage(component,event,'/apex/LibraryPage_Internals');
	},
    dlsCalculator : function(component, event, helper) {
        helper.redirectToPage(component,event,'/apex/MaterialsPriceCalculatorPage');
	},
    staffTimeEntry : function(component, event, helper) {
        helper.redirectToPage(component,event,'/apex/DLS_Staff_Time_Entry_Page');
	},
    ApprovalPage : function(component, event, helper) {
        helper.redirectToPage(component,event,'/apex/TimeSheet_Internals');
	},
    AdminTimeEntry : function(component, event, helper) {
        helper.redirectToPage(component,event,'/apex/TimeKeeping_Admin_Page');
	},
    timelogEntry : function(component, event, helper) {
        helper.redirectToPage(component,event,'/apex/timesheet');
	},
    timeLogLockDate : function(component, event, helper) {
        helper.redirectToPage(component,event,'/apex/TimeLog_Locking_Date_Page');
	},
    issueLog : function(component, event, helper) {
        helper.redirectToPage(component,event,'/a1o');
	},
    unresolvedItems : function(component, event, helper) {
        helper.redirectToPage(component,event,'/6AC');
	},
    paycomLogin : function(component, event, helper) {
        helper.redirectToPage(component,event,'https://www.paycomonline.net/v4/ee/web.php/app/login');
	},
    teamworkLogin : function(component, event, helper) {
        helper.redirectToPage(component,event,'https://diplomaticlanguageservices.teamwork.com');
	},
    createBilling : function(cmp, event, helper){
        helper.redirectToPage(cmp,event,'/lightning/n/Create_Billings');
    }
})