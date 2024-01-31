({
	doinit : function(cmp, event, helper) {
        
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            cmp.set("v.displayDevice",'Mobile');
        } else {
            cmp.set("v.displayDevice",'PC');
        }
        
		cmp.set("v.showSpinner",true);
        var url = window.location.href;
        var formattedUrl = decodeURIComponent(url);
        
        var proId = '';
        var insId = '';
        
        if(formattedUrl.includes('projectId')){
            proId = formattedUrl.split('projectId=')[1].split('&instructorId')[0];
        }
        if(formattedUrl.includes('instructorId')){
            insId = formattedUrl.split('instructorId=')[1];
        }
        
        cmp.set("v.proId",proId);
        cmp.set("v.instructorId",insId);
        
        helper.getDLIAttendanceDetail(cmp,event);
	},
    saveBtnClick : function(cmp, event, helper){
        helper.validateInput(cmp);
    },
    okayClick : function(cmp, event, helper){
        
        if(Array.isArray(cmp.find("confirmationModal"))) {
            cmp.find("confirmationModal")[0].close();
        }else{
            cmp.find("confirmationModal").close();
        }
        cmp.set("v.displayConfirmation",false);
        cmp.set("v.showSpinner",true);
        helper.createDLIAttendance(cmp);
    },
    cancelClick : function(cmp, event, helper){
        if(Array.isArray(cmp.find("confirmationModal"))) {
            cmp.find("confirmationModal")[0].close();
        }else{
            cmp.find("confirmationModal").close();
        }
        cmp.set("v.displayConfirmation",false);
    },
    closeClickOnSuccess: function(cmp, event, helper){
        if(Array.isArray(cmp.find("successModal"))) {
            cmp.find("successModal")[0].close();
        }else{
            cmp.find("successModal").close();
        }
        cmp.set("v.displaySuccessModal",false);
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"
        });
        urlEvent.fire();
    },
    back : function(cmp, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"
        });
        urlEvent.fire();
    },
    closeErrorModal: function(cmp, event, helper){
        if(Array.isArray(cmp.find("errorModal"))) {
            cmp.find("errorModal")[0].close();
        }else{
            cmp.find("errorModal").close();
        }
        cmp.set("v.displayErrorModal",false);
    }
})