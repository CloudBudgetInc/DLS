({
	doInit : function(cmp, event, helper) {
        console.log('In doinit');
        cmp.set("v.conditionCheck",false);
        var urlString = window.location.href;
        var device = $A.get("$Browser.formFactor");
        var projectId = '';
        if(urlString.indexOf('projectId') != -1){
            projectId = urlString.split("=")[1];
            cmp.set("v.projectId",projectId);
        }
        if (device == 'PHONE') {
            cmp.set("v.displayDevice",'Mobile');
        } else {
            cmp.set("v.displayDevice",'PC');
        }
        helper.getInitialFilterValues(cmp,event);
	},
    
    searchRecords : function(cmp, event, helper){
        console.log('pfojec::::',cmp.get("v.selectedProject"),cmp.get("v.startDate") ,cmp.get("v.endDate"));
        if(cmp.get("v.selectedProject") != '--None--' || (cmp.get("v.startDate") && cmp.get("v.endDate"))){
            cmp.set("v.conditionCheck",true);
            
            if(cmp.get("v.startDate") > cmp.get("v.endDate")){
                cmp.find("dates").forEach(function(d){
                    d.showHelpMessageIfInvalid();
                });
                helper.showToast(cmp, event,'Start date should be less than the end date','error');
            }else{
            	helper.getTimeActivityList(cmp, event);    
            }
        }else{
            console.log('else');
            //cmp.find('projectSel').showHelpMessageIfInvalid();
            helper.showToast(cmp,event,'Please select Project or Date Range to see the history','error');
        }
    },
    clearFilters : function(cmp,event, helper){
        cmp.set("v.selectedProject",'--None--');
        cmp.set("v.startDate","");
        cmp.set("v.endDate","");
        cmp.set("v.timeCardDays",[]);
    }
})