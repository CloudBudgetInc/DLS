({
	getCAs : function(component, event, helper) {
		const server = component.find("server");        
        const action = component.get("c.getRecordsAndCongaUrlForSendDLSOfficeProcedure");    
        var param = {projectId: component.get('v.recordId')};
        component.set("v.showSpinner",true);
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (responseStr) {
                var response = JSON.parse(responseStr);
                console.log(response);                
                if(response.errorMsg == 'No Box Record'){
                    var recordId = component.get("v.recordId");
                    if(component.get('v.projRec').AcctSeed__Opportunity__c){
                        recordId = component.get('v.projRec').AcctSeed__Opportunity__c;
                    }
                    helper.subscribePlatformEvent(component, event, helper, recordId);
                }else{
                    component.set("v.showSpinner",false);
                    component.set("v.isLoaded", true);
                    component.set("v.contactAssignments", response.contactAssignments);
                    component.set("v.congaBaseUrl", response.congaBaseUrl);
					component.set("v.emailParams", response.emailParams);                    
                }                
            }),
            $A.getCallback(function (errors) {
                component.set("v.showSpinner",false);
                helper.showToast(component, event,errors[0].message, "error", "Error");
            }),
            false,
            false,
            false 
        );
	},   
    updateCA: function(component, event, helper, rows){        
        const server = component.find("server");
        const action = component.get("c.updateContactRecords");    
        var param = {conAssignmentStr: JSON.stringify(rows), initCAFRUPCheck: true};
        component.set("v.showSpinner",true);
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (response) {
                component.set("v.showSpinner",false);
				helper.showToast(component, event,'DLS Covid Procedure Sent Successfully', "success", "Success");                              
            }),
            $A.getCallback(function (errors) {
                helper.showToast(component, event,errors[0].message, "error", "Error");
            }),
            false,
            false,
            false 
        );
    }   
})