({
    doInit : function(cmp, event, helper) {
        // get projectId,InstructorId,Week information from community URL if launched url from mail
        var regex = /[?&]([^=#]+)=([^&#]*)/g,
            url = (decodeURIComponent(window.location)),
            params = {},
            match;
        while(match = regex.exec(url)) {
            params [match[1]] = match[2].replace(/[+]/g,' ');
        }
        params['proIdAndInsId'] = params['projectId']+'-'+params['instructorId'];
        cmp.set("v.fromCommunityUrlMap",params);
        helper.getFilterInitialInformation(cmp,event,helper);
    },
    onChangeWeekClk : function(cmp, event, helper) {
        var weeklyViewRowsInfo = cmp.get("v.weeklyViewRowsInfo");
        
        weeklyViewRowsInfo.weeklyViewRow = [];
        weeklyViewRowsInfo.showStuHrs = true;
        
        cmp.set("v.weeklyViewRowsInfo",weeklyViewRowsInfo);
        cmp.set("v.fromCommunityUrlMap",{});
        helper.getProFilterDetails(cmp);
    },
    onchangeProject : function(cmp, event, helper){
        helper.onChangeprojectHelper(cmp);
    },
    dateRowclick : function(cmp, event, helper) {
        var summaryDetails = cmp.get("v.studentSummaryDetails");
        var weekDateRange = cmp.get("v.weekDateRange");
        var selectedRowVal = event.currentTarget.dataset.myid
        var date = selectedRowVal.split("~")[0];
        var selectedWKIndex = parseInt(selectedRowVal.split("~")[1]);
        var day = cmp.get("v.weekDay");  
        
        if(weekDateRange.length > 0){
            summaryDetails['displayPreviousIcon'] = true;
            summaryDetails['displayNextIcon'] = true;
        }

        if(selectedWKIndex + 1 == weekDateRange.length){
            summaryDetails['displayNextIcon'] = false;
        }else if(selectedWKIndex == 0){
            summaryDetails['displayPreviousIcon'] = false;  
        }       
        summaryDetails['selectedWkDate'] = date;
        summaryDetails['selectedWKIndex'] = selectedWKIndex;
        summaryDetails['selectedWkDay'] = day[selectedWKIndex];
        summaryDetails.isHomeView = false;
        summaryDetails.isDailyView = true;
        
        cmp.set("v.studentSummaryDetails",summaryDetails);
    },
    notesModal : function(cmp, event, helper){
        var summaryDetails = cmp.get("v.studentSummaryDetails");
        summaryDetails['isNotesModal'] = true;
        cmp.set("v.studentSummaryDetails",summaryDetails);
        cmp.find("notesComment").open();
    },
    closeNotes : function(cmp, event, helper){
        var summaryDetails = cmp.get("v.studentSummaryDetails");
        summaryDetails['isNotesModal'] = false;
        cmp.set("v.studentSummaryDetails",summaryDetails);
    },
    handleChildEvent : function(cmp, event, helper){
        var weeklyViewRowsInfo = cmp.get("v.weeklyViewRowsInfo");
        
        weeklyViewRowsInfo.weeklyViewRow = [];
        weeklyViewRowsInfo.showStuHrs = true;
        
        cmp.set("v.weeklyViewRowsInfo",weeklyViewRowsInfo);
        cmp.set("v.studentRowEntries",[]);
        cmp.set("v.studentOverAllSum","0.00");
        helper.getDayRowsFormation(cmp);
    }
})