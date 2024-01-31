({
	getStudents : function(component, event, helper) {
		const server = component.find("server");        
        const action = component.get("c.getStudentListAndCongaSessionId");    
        var param = {projectId: component.get('v.recordId')};
        component.set("v.showSpinner",true);
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (response) {
                console.log(response);
                if(response.errorMsg == 'No Box Record'){
                    var recordId = component.get("v.recordId");
                    if(component.get('v.projRec').AcctSeed__Opportunity__c){
                        recordId = component.get('v.projRec').AcctSeed__Opportunity__c;
                    }
                    helper.subscribePlatformEvent(component, event, helper, recordId);
                }else if(response.errorMsg){
                    component.set("v.showSpinner",false);
                    component.set("v.errorMsg", response.errorMsg);
                }else{
                    component.set("v.showSpinner",false);
                    component.set("v.isLoaded", true);
                    component.set("v.contactAssignments", response.contactAssignmentList);
                    component.set("v.students", response.contactAssignments);
                    component.set("v.showSendTo", response.showSendTo);
                    component.set("v.congaBaseUrl", response.congaBaseUrl);
					component.set("v.emailParams", response.emailParams);  
                    component.set("v.caIdWithExaminerId", response.caIdWithExaminerId);
                    component.set("v.caIdWithLangTestingId", response.caIdWithLangTestingId);                                        
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
        var param = {conAssignmentStr: JSON.stringify(rows)};
        component.set("v.showSpinner",true);
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (response) {
                component.set("v.showSpinner",false);
				if(!component.get('v.isFromVFPage')){
                    helper.showToast(component, event,'Certificate Sent Successfully to Student(s)', "success", "Success");
                    $A.get("e.force:closeQuickAction").fire(); 
                }                
            }),
            $A.getCallback(function (errors) {
                
                helper.showToast(component, event,errors[0].message, "error", "Error");
            }),
            false,
            false,
            false 
        );
    },
    getBaseUrl: function(component, row, isForPreview){
        let projRec = component.get('v.projRec'),
             congaBaseUrl = component.get('v.congaBaseUrl'),
             baseUrl = '';
        
        let congaBaseUrlStr = congaBaseUrl.split('&id=');
        
        if(isForPreview){
            baseUrl = congaBaseUrlStr[0];
        }
        
        if(projRec.RecordType.DeveloperName == 'Testing_Projects'){
            let caIdWithExaminerId = component.get("v.caIdWithExaminerId"),
                 caIdWithLangTestingId = component.get("v.caIdWithLangTestingId"),
                 conId = row.Candidate_Name__c;
            
            baseUrl += '&id=' +caIdWithLangTestingId[conId] +congaBaseUrlStr[1]+caIdWithExaminerId[conId];
        }else{
            baseUrl += '&id='+congaBaseUrlStr[1]+row.Id;
        }
                
        return baseUrl;
    },
    getEmailToId: function(component, row){        
        let showSendTo = component.get("v.showSendTo"),
            isFCSProj = component.get('v.projRec').AcctSeed__Account__r.Name == 'USDoC-FCS',
            contactAssignments = component.get("v.contactAssignments"),
            emailToIdStr = '&EmailToId='+ ((showSendTo || isFCSProj)  ? '+&EmailAdditionalTo=' : row.Candidate_Name__c),
            emailBCCStr = '&EmailBCC=',
            isStart = true,
            isStaffStart = true;

        if(showSendTo || isFCSProj){
            
            for(let contactAssignment of contactAssignments){                
                if(contactAssignment.ca.Id == row.Id){
                    if(isFCSProj){
                        for (const sendToName in contactAssignment.sendToNameWithCAMap) {
                            let caRec = contactAssignment.sendToNameWithCAMap[sendToName];
                            if(!isStart){
                                emailToIdStr += ',';
                            } else {
                                isStart = false;
                            }
                            emailToIdStr += caRec.Candidate_Name__c;
                        }
                    }else{
                        contactAssignment.selectedSendTo.forEach(sendToName => {
                            let caRec = contactAssignment.sendToNameWithCAMap[sendToName];                        
                            if(caRec.RecordType.DeveloperName == 'Staff'){
                                if(!isStaffStart){
                                    emailBCCStr += ',';
                                } else {
                                    isStaffStart = false;
                                }
                                emailBCCStr += caRec.Candidate_Name__c;
                            }else{
                                if(!isStart){
                                    emailToIdStr += ',';
                                } else {
                                    isStart = false;
                                }
                                emailToIdStr += caRec.Candidate_Name__c;
                            }            		
                        }); 
                    }                    
                }
            }
        }
                                                        
        emailToIdStr = !isStaffStart ? emailToIdStr + emailBCCStr : emailToIdStr;
                                                        
        return emailToIdStr;
    },
    showToast : function(cmp,event,message,type,title){
        if(!cmp.get('v.isFromVFPage')){
            const toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : title,
                message : message,
                type : type,
                mode: 'sticky'
            });
            toastEvent.fire();
        }
    },
})