({
	doinit : function(cmp, event, helper) {
		cmp.set("v.showSpinner",true);
        cmp.set("v.initialLoad",true);
        
        //Get the url params to prepopulate that week & project
        //if launched from email click here link
        var url = window.location.href;
        var formattedUrl = '';
        var urlMap = {};
        if(url.includes('+')){
            url = url.split('+').join('%20');
        }
        formattedUrl = decodeURIComponent(url);
        
        if(formattedUrl.includes('week')){
            if(!cmp.get("v.internalView")){
                urlMap.weekRange = formattedUrl.split('week=')[1];
            }else {
                urlMap.weekRange = formattedUrl.split('week=')[1].split('&c__projectId')[0];
            }
        }
        if(formattedUrl.includes('projectId')){
            urlMap.projectId = formattedUrl.split('projectId=')[1].split('&week')[0];
        }
        
        console.log('::::::urlMap:::',JSON.stringify(urlMap));
        cmp.set("v.urlParams",urlMap);
        
        helper.getFilterInformation(cmp);
	},
    getRowDetails : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        cmp.set("v.initialLoad",false);
        
        var manager = cmp.get("v.projectSupervisorMap")[cmp.get("v.selectedProject")];
        cmp.set("v.projectManager",manager);
        
        helper.getTimeRowsFormation(cmp);
        //Call schedule details query method
        helper.getClassScheduleDetails(cmp);
    },
    getProjectFilter : function(cmp, event, helper){
        console.log(':::::initialLoad:::',cmp.get("v.initialLoad"));
        cmp.set("v.showSpinner",true);
        cmp.set("v.initialLoad",false);
        helper.clearValues(cmp);
        helper.getProjectFilterDetails(cmp);
    },
    viewMoreClick : function(cmp, event, helper){
        var index = event.currentTarget.getAttribute("data-value");
        //console.log(':::::index::::',index);
        
        var summaryList = cmp.get("v.summaryList");
        var selectedRecord = summaryList[index];
        //console.log(':::::record::::',selectedRecord);
        
        var projectData = cmp.get("v.projectFilter").filter(obj => {
            return obj.projectId === cmp.get("v.selectedProject");
        });
        
        var detailMap = {};
        detailMap.dayRecord = selectedRecord;
        detailMap.amTimeList = cmp.get("v.amTimeList");
        detailMap.pmTimeList = cmp.get("v.pmTimeList");
        detailMap.timeList = cmp.get("v.timeList");
        detailMap.dliWLTHolidays = cmp.get("v.dliWLTHolidays");
        detailMap.federalHolidays = cmp.get("v.federalHolidays");
        detailMap.scheduleRecords = cmp.get("v.scheduleRecords");
        detailMap.showDetail = true;
        detailMap.projectData = projectData;
        detailMap.plannedDaysOffMap = cmp.get("v.plannedDaysOffMap");
        detailMap.projectStuLeaderMap = cmp.get("v.projectStuLeaderMap");
        detailMap.studentNames = cmp.get("v.studentNames");
        detailMap.selectedWeek = cmp.get("v.selectedWeek");
        detailMap.projectId = cmp.get("v.selectedProject");
        detailMap.contactId = cmp.get("v.contactId");
        detailMap.topicId = cmp.get("v.topicId");
        detailMap.defaultCostRateRateType = cmp.get("v.defaultCostRateRateType");
        cmp.set("v.dayRecord",selectedRecord);
        cmp.set("v.selectedIndex",index);
        cmp.set("v.detailMap",detailMap);
        window.scrollTo(0,0);
        cmp.set("v.showDetail",true);
    },
    handleEntryDetailActions : function(cmp, event, helper){
        //console.log("event::entry:details::::",event.getParam("typeOfAction"));
        var eventType = event.getParam("typeOfAction");
        if(eventType == 'Back'){
            helper.destoryChild(cmp);
        }
    },
    completeBtnClick : function(cmp, event, helper){        
        cmp.set("v.actionType",'Complete');
        
        var isEntryExist = helper.checkTimeEntriesExist(cmp);
        
        if(isEntryExist){
            var projectIdTimeCompleted = cmp.get("v.projectIdTimeCompleted");
                        
            var allTimesAreCompleted = true;
            for(var key in projectIdTimeCompleted){
                if(key != cmp.get("v.selectedProject") && !projectIdTimeCompleted[key]){
                    allTimesAreCompleted = false;
                }
            }
            
            cmp.set("v.redirectToSubmitPage",allTimesAreCompleted);
            helper.getScheduledEventsForThisWeek(cmp);
        }else {
            helper.getScheduledEventsForThisWeek(cmp);
        }
    },
    proceedOnConfirmation : function(cmp, event, helper){
        if(Array.isArray(cmp.find("groupActionModal"))) {
            cmp.find("groupActionModal")[0].close();
        }else{
            cmp.find("groupActionModal").close();
        }
        cmp.set("v.showGroupActionModal",false);
        cmp.set("v.showSpinner",true);
        
        if(cmp.get("v.actionType") == 'Complete'){
            helper.completeTCDEntries(cmp);
        }else if(cmp.get("v.actionType") == 'Recall'){
            helper.recallActionFunction(cmp);
        }
        
    },
    cancelOnConfirmation : function(cmp, event, helper){
        if(Array.isArray(cmp.find("groupActionModal"))) {
            cmp.find("groupActionModal")[0].close();
        }else{
            cmp.find("groupActionModal").close();
        }
        cmp.set("v.showGroupActionModal",false);
        cmp.set("v.showSpinner",false);
    },
    closeClickOnSuccess : function(cmp, event, helper){
        if(Array.isArray(cmp.find("successModal"))) {
            cmp.find("successModal")[0].close();
        }else{
            cmp.find("successModal").close();
        }
        cmp.set("v.displaySuccessModal",false);
        
        if(cmp.get("v.successTitle") == 'Success'){
            helper.clearValues(cmp);
            cmp.set("v.showSpinner",true);
            console.log('::::::::success:::::',cmp.get("v.redirectToSubmitPage"));
            if(!cmp.get("v.redirectToSubmitPage")){
            	helper.getTimeRowsFormation(cmp);
            }else if(cmp.get("v.actionType") == 'Complete' && cmp.get("v.redirectToSubmitPage")){
                
               var urlVal = '/instructor/s/time-submit?week='+cmp.get("v.selectedWeek");
                    
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": urlVal
                });
                urlEvent.fire();
            }
        }
    },
    recallBtnClick : function(cmp, event, helper){
        cmp.set("v.groupActionMsg",'Would you like to recall the time entries?');
        cmp.set("v.actionType",'Recall');
        cmp.set("v.groupActionTitle","Confirmation");
        cmp.set("v.isValidEntryExist",true);
        
        cmp.set("v.showGroupActionModal",true);
        if(Array.isArray(cmp.find("groupActionModal"))) {
            cmp.find("groupActionModal")[0].open();
        }else{
            cmp.find("groupActionModal").open();
        }
    },
    requestEditLinkClick : function(cmp,event, helper){
        cmp.set("v.showCaseReasonModal",true);
        if(Array.isArray(cmp.find("caseReasonModal"))){
            cmp.find("caseReasonModal")[0].open();
        }else {
            cmp.find("caseReasonModal").open();
        }
    },
    submitCase : function(cmp, event, helper){
        console.log('submit case');
        var isValid = true;
        var caseReasonCmp = cmp.find("caseReason");
        if(!caseReasonCmp.get("v.value") || caseReasonCmp.get("v.value").trim() == ''){
            $A.util.addClass(caseReasonCmp,"slds-has-error");
            isValid = false;
        }else {
            $A.util.removeClass(caseReasonCmp,"slds-has-error");
        }
        
        if(isValid){
            helper.createCaseRecordMethod(cmp);
            if(Array.isArray(cmp.find("caseReasonModal"))){
                cmp.find("caseReasonModal")[0].close();
            }else {
                cmp.find("caseReasonModal").close();
            }
            cmp.set("v.showCaseReasonModal",false);
            cmp.set("v.showSpinner",true);
        }
    },
    cancelSubmitCase : function(cmp, event, helper){
        
        if(Array.isArray(cmp.find("caseReasonModal"))){
            cmp.find("caseReasonModal")[0].close();
        }else {
            cmp.find("caseReasonModal").close();
        }
        cmp.set("v.showCaseReasonModal",false);
    },
    
})