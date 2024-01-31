({
    validateStartAndEndDate: function(cmp, event, helper) {
        var self = this;
        cmp.set("v.showSpinner",true);
        const server = cmp.find('server');
        var action = cmp.get("c.validateOppStartAndEndDateForPolicyAndProcedure");
        server.callServer(
            action, {recId : cmp.get("v.recordId")},
            false,
            $A.getCallback(function(response) {               
                cmp.set("v.showSpinner",false);
                if(response == 'success'){
                    helper.getStudentPolicyInfo(cmp, event, helper);
                }else{
                    var errorLog = cmp.get("v.errorLog");
                    errorLog.message = response;
                    errorLog.showError = true;
                    cmp.set("v.errorLog",errorLog)
                }
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                var errorLog = cmp.get("v.errorLog");
                errorLog.message = errors[0].message;
                errorLog.showError = true;
                cmp.set("v.errorLog",errorLog);
            }),
            false,
            false,
            false
        );
    },
	getStudentPolicyInfo : function(cmp, event, helper) {
		
        var self = this;
        cmp.set("v.showSpinner",true);
        const server = cmp.find('server');
        var action = cmp.get("c.getStudentProcedureInfo");
        server.callServer(
            action, {objName : cmp.get("v.sObjectName"),objId : cmp.get("v.recordId")},
            false,
            $A.getCallback(function(response) {
                console.log(response);
                var returnValue = response;
                if(returnValue.objRecordId){
                    cmp.set("v.obJRecordId",returnValue.objRecordId);
                }
                
               if(returnValue.errorMsg){
                    if(returnValue.errorMsg == 'No Box Record'){
                       helper.subscribePlatformEvent(cmp, event, helper, returnValue.objRecordId);
                    }else{
                        var errorLog = cmp.get("v.errorLog");
                        errorLog.message = errors[0].message;
                        errorLog.showError = true;
                        cmp.set("v.errorLog",errorLog);   
                    }
                }else{
                    var serverUrlSessionId = JSON.parse(returnValue.sessionIdServerURL);
                    
                    if(serverUrlSessionId){
                        var congaUrl = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                            "&serverUrl="+serverUrlSessionId["serverUrl"];
                        
                        cmp.set("v.sessionCongaUrl",congaUrl)
                    }
                    
                    if(returnValue.congaUrlInfo && returnValue.congaUrlInfo.length > 0){
                        cmp.set("v.congaDetailList",returnValue.congaUrlInfo)
                    } 
                    
                    cmp.set("v.conAssign",returnValue.contactAssignments);
                    cmp.set("v.conAssignIdWithCongaUrlMap",returnValue.conAssignIdWithCongaUrlMap);
                    cmp.set("v.showSpinner",false);
                }
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                var errorLog = cmp.get("v.errorLog");
                errorLog.message = errors[0].message;
                errorLog.showError = true;
                cmp.set("v.errorLog",errorLog);
            }),
            false,
            false,
            false
        );
    },
     updateOppProjectsRecords :function(cmp, event, helper , congaUrl) {
        var self = this;
        cmp.set("v.showSpinner",true);
        const server = cmp.find('server');
        var action = cmp.get("c.updateOppProjects");
        server.callServer(
            action, {oppProId : cmp.get("v.recordId") , objName : cmp.get("v.sObjectName")},
            false,
            $A.getCallback(function(response) {
                var sessionCongaUrl = cmp.get("v.sessionCongaUrl");
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": sessionCongaUrl + congaUrl
                });
                urlEvent.fire()
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                var errorLog = cmp.get("v.errorLog");
                errorLog.message = errors[0].message;
                errorLog.showError = true;
                cmp.set("v.errorLog",errorLog);
            }),
            false,
            false,
            false
        );
     }
})