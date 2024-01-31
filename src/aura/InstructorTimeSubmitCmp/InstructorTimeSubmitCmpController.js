({
    doinit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        cmp.set("v.agreeTxt","I certify that the days and hours shown on this timesheet are true and accurate, and that I worked these hours for the projects noted");
        
        
        //Get the url params to prepopulate that week
        //if launched from instructor time entry
        var url = window.location.href;
        var formattedUrl = '';
        var urlMap = {};
        if(url.includes('+')){
            url = url.split('+').join('%20');
        }
        formattedUrl = decodeURIComponent(url);
        
        if(formattedUrl.includes('week')){
            urlMap.weekRange = formattedUrl.split('week=')[1];
        }
        console.log('::::::urlMap:::',JSON.stringify(urlMap));
        cmp.set("v.urlParams",urlMap);
        
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            cmp.set("v.displayDevice",'Mobile');
        } else {
            cmp.set("v.displayDevice",'PC');
        }
        
        helper.getFilterValues(cmp, event);
    },
    getSelectedWeekInfo : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        cmp.set("v.agreedCondition",false);
        helper.getTCDRecords(cmp, event);
    },
    submitBtnClick : function(cmp, event, helper){
        var agreedCmp = cmp.find("agreed");
        var valid = true;
        
        if(!cmp.get("v.agreedCondition")){
            $A.util.addClass(agreedCmp, "slds-has-error");
            valid = false;
        }else{
            $A.util.removeClass(agreedCmp,"");
        }
        
        if(valid){
            //check the current project is completed or not. if not show msg
            var notCompletedProject = cmp.get("v.notCompletedProjects");
            var msg = '';
            console.log(":::::keys::::",Object.keys(notCompletedProject));
            if(Object.keys(notCompletedProject).length > 0){
                var projectStudentNames = cmp.get("v.proIdStudentNames"); 
                
                msg = 'The following timesheets for this week have not yet been marked as completed, are you sure you want to Submit?';
                
                for(var key in notCompletedProject){
                    console.log(key,projectStudentNames[key]);
                    if(projectStudentNames[key] && notCompletedProject[key].RecordType.DeveloperName != 'CD_Projects'){
                    	msg += '<br/> - '+notCompletedProject[key].DLS_Class__c +' / '+projectStudentNames[key];
                    }else if(notCompletedProject[key].RecordType.DeveloperName == 'CD_Projects'){
                        msg += '<br/> - '+notCompletedProject[key].DLS_Class__c;
                    }
                }
            }else {
                msg = 'The total number of hours being submitted is <b>'+cmp.get("v.totalHrs")+'</b>. Would you like to Submit?';
            }
            console.log('::::::msg:::',msg);
            //call helper
            cmp.set("v.confirmMsg",msg);
            cmp.set("v.showSaveConfirmation",true);
            if(Array.isArray(cmp.find("confirmationModal"))) {
                cmp.find("confirmationModal")[0].open();
            }else{
                cmp.find("confirmationModal").open();
            }
        }
    },
    proceedBtnClick : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        helper.submitTimeEntries(cmp,event);
        if(Array.isArray(cmp.find("confirmationModal"))) {
            cmp.find("confirmationModal")[0].close();
        }else{
            cmp.find("confirmationModal").close();
        }
        cmp.set("v.showSaveConfirmation",false);
    },
    cancelBtnClick : function(cmp, event, helper){
        
        if(Array.isArray(cmp.find("confirmationModal"))) {
            cmp.find("confirmationModal")[0].close();
        }else{
            cmp.find("confirmationModal").close();
        }
        cmp.set("v.showSaveConfirmation",false);
    },
    closeClickOnSuccess : function(cmp, event, helper){
        if(Array.isArray(cmp.find("successModal"))) {
            cmp.find("successModal")[0].close();
        }else{
            cmp.find("successModal").close();
        }
        cmp.set("v.displaySuccessModal",false);
        cmp.set("v.dayRecords",[]);
        cmp.set("v.showSpinner",true);
        if(cmp.get("v.successTitle") == 'Success'){
            helper.getTCDRecords(cmp, event);
        }
    }
})