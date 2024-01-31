({
	getDLIAttendanceDetail : function(cmp, event) {
		var self = this;
        
        var param = {};
        param.projectId = cmp.get("v.proId");
        param.instructorId = cmp.get("v.instructorId");
        
        const server = cmp.find('server');
        const action = cmp.get('c.getDLIAttendanceInfo');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                
                for(var i = 0;i < result.allStudentDetails.length;i++){
                    result.allStudentDetails[i].options = cmp.get("v.options");
                }
                
                console.log(':::::::::allStudentDetails:::',result.allStudentDetails);
                
                cmp.set("v.detailMap",result);
                
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log(':::::error::::::::::',response.getError()[0].message);
                cmp.set("v.successMsg",response.getError()[0].message);
                cmp.set("v.successTitle",'Error');
                cmp.set("v.showSpinner",false);
                cmp.set("v.displaySuccessModal",true);
                
                if(Array.isArray(cmp.find("successModal"))) {
                    cmp.find("successModal")[0].open();
                }else{
                    cmp.find("successModal").open();
                }
            }),
            false, 
            false,
            false
        );
	},
    validateInput : function(cmp){
        var isValid = true;
        
        var details = cmp.get("v.detailMap");
        
        var studentDetails = details.allStudentDetails;
        for(var i = 0;i < studentDetails.length;i++){
            
            if(studentDetails[i].studentPresent != 'no' && studentDetails[i].studentPresent != 'yes'){
                isValid = false;
                 cmp.set("v.displayErrorModal",true);
                if(Array.isArray(cmp.find("errorModal"))) {
                    cmp.find("errorModal")[0].open();
                }else{
                    cmp.find("errorModal").open();
                }               
            }
            if(studentDetails[i].studentPresent == 'no'){
                var attendanceCmt;
                
                if(Array.isArray(cmp.find("attendanceCmt"))) {
                    attendanceCmt = cmp.find("attendanceCmt")[i];
                }else{
                    attendanceCmt = cmp.find("attendanceCmt");
                }
                
                if(!attendanceCmt.get("v.value")){
                    isValid = false;
                	$A.util.addClass(attendanceCmt,'slds-has-error');
                }else {
                    $A.util.removeClass(attendanceCmt,'slds-has-error');
                }
            }
        }
        
        //techincal issue & Acadamic issue check
        var technicalIssue = details.technicalIssue;
        if(technicalIssue){
            var techcmt = cmp.find("techComment");
            if(!techcmt.get("v.value")){
            	isValid = false;
            	$A.util.addClass(techcmt,'slds-has-error');    
            }else {
            	$A.util.removeClass(techcmt,'slds-has-error');    
            }
        }
        
        var acadamicIssue = details.academicIssue;
        if(acadamicIssue){
            var acadamicCmt = cmp.find("acadamicComment");
            if(!acadamicCmt.get("v.value")){
            	isValid = false;
            	$A.util.addClass(acadamicCmt,'slds-has-error');    
            }else {
            	$A.util.removeClass(acadamicCmt,'slds-has-error');    
            }
        }
        
        if(isValid){
            
            cmp.set("v.displayConfirmation",true);
            if(Array.isArray(cmp.find("confirmationModal"))) {
                cmp.find("confirmationModal")[0].open();
            }else{
                cmp.find("confirmationModal").open();
            }
        }
    },
    createDLIAttendance : function(cmp){
        var self = this;
        
        var param = {};
        param.inputJSON = JSON.stringify(cmp.get("v.detailMap"));
        
        const server = cmp.find('server');
        const action = cmp.get('c.createDLIAttendance');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                console.log('::::::create::::',response);
                cmp.set("v.showSpinner",false);
                cmp.set("v.successMsg",'Attendance records created successfully');
                cmp.set("v.successTitle",'Success');
                cmp.set("v.displaySuccessModal",true);
                
                if(Array.isArray(cmp.find("successModal"))) {
                    cmp.find("successModal")[0].open();
                }else{
                    cmp.find("successModal").open();
                }
            }),
            $A.getCallback(function(errors) { 
                console.log(':::::error::::::::::',response.getError()[0].message);
                cmp.set("v.successMsg",response.getError()[0].message);
                cmp.set("v.successTitle",'Error');
                cmp.set("v.showSpinner",false);
                cmp.set("v.displaySuccessModal",true);
                
                if(Array.isArray(cmp.find("successModal"))) {
                    cmp.find("successModal")[0].open();
                }else{
                    cmp.find("successModal").open();
                }
            }),
            false, 
            false,
            false
        );
    }
})