({
    genOfferMethod : function(component, event, helper) {
        var action = component.get("c.congaButton");
        action.setParams({
            'caId' : component.get("v.CAId"),
            'Template1':'Offer Letter - Staff - Exempt',
            'Template2':'Offer Letter - Staff - Non-Exempt',
            'Conquery':'ICA Agreement Contact Assign Query,Contact Query for Supervisor in Offer Letter'
        });
        
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS"){
                console.log(data.getReturnValue());
                var result = data.getReturnValue();
                var seId = (JSON.parse(result.getServerUrlSessionId)).sessionId;
                var url = (JSON.parse(result.getServerUrlSessionId)).serverUrl;
                var conQuery1 = result.getQryMap['ICA Agreement Contact Assign Query'];
                var conQuery2 = result.getQryMap['Contact Query for Supervisor in Offer Letter'];
                var OffLetterTemId = result.OffLetterTemId || '';
                var ConditionFailed = result.ConditionFailed || '';
                var caId = result.contactAssigns.Id;
                var conId = result.contactAssigns.Candidate_Name__c; 
                var supName = result.contactAssigns.Candidate_Name__r.Supervisor_Name__r?
                   result.contactAssigns.Candidate_Name__r.Supervisor_Name__r.Name : '';
                component.set("v.fieldsEmpty",result.fieldsEmpty);
                component.set("v.ConditionFailed",result.ConditionFailed);

                if(OffLetterTemId != ''){
                    window.open('https://composer.congamerge.com?sessionId='+seId+'&serverUrl='+url+'&id='+conId+'&DS7=3&templateId='+OffLetterTemId+'&queryId=[Ins]'+conQuery1+'?pv0='+caId,"_blank");  
                }else if(ConditionFailed !=''){
                    component.find('ConditionFailed').openModal(); 
                }else if(data.getReturnValue().fieldsEmpty.length > 0) {
                    
                    component.find('fieldsEmpty').openModal();                       
                }             
            }else {   
                console.log('error')
                if(state === "ERROR"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message :  data.getError()[0].message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();  
                }}
        });
        $A.enqueueAction(action);
        
    },
    genTesterPaymentForm : function(component, event, helper,docFor) {
      
        var action=component.get("c.genPaymentFormCongaDocument");
        action.setParams({
            'caId':component.get("v.CAId"),
            'docFor':docFor,
            'parentId':component.get("v.parentId")
        });
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS"){
                var result = data.getReturnValue();
                window.open(result,'_self');   
            }else{
                if(state === "ERROR"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message :  data.getError()[0].message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();  
                }
            }
        });
        $A.enqueueAction(action);
    },
    /*Work - W-001862
         Hiring Process: Additional Compensation (End of Training Bonuses, Client Site Travel Reimbursement, etc.) to save Additional  Compensation detais*/
    saveAdditionalCompenseDetailsInCA : function(component,event,helper) {
        
        var caArray = [];
        var addCompCARecord = component.get("v.addCompCARecord");
        addCompCARecord['Candidate_Name__c'] =  component.get("v.contactId");
        addCompCARecord['Id'] = component.get("v.CAId");
        addCompCARecord['Additional_Compensation_Status__c'] = 'Draft';
        caArray.push(addCompCARecord);
        
        var action=component.get("c.saveContactAssignment");
        action.setParams({
            'conAssignJson':JSON.stringify(caArray),
            'parentRecordType':'',
            'cARecordType':''
        });
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS"){
                var result = data.getReturnValue();
                var appEvent = $A.get("e.c:reloadEvent");
                appEvent.fire();
            }else{
                if(state === "ERROR"){
                    component.set("v.showSpinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message :  data.getError()[0].message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();  
                }
            }
        });
        $A.enqueueAction(action);
    },
    /* W-007721 - Process to Transfer a Student from One Project to Another Project (MAR-15-2023)*/
    createNewStuCAWithNewProject : function(component,event,helper) {
        component.set("v.showSpinner",true);
        var studentTransferCAMap = component.get("v.studentTransferCAMap");
        var action=  component.get("c.transferStudentCAtoAnotherProject");
        action.setParams({
            'caId':component.get("v.CAId"),
            'oldCAEndDt':studentTransferCAMap.transferCAOldEDDate,
            'newCAStartDt':studentTransferCAMap.transferCASTDate,
            'newCAProjectId': studentTransferCAMap.projectLookup[0].Id,
            'cAStudentCL': studentTransferCAMap.selectedCLCAId
        });
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS"){
                var appEvent = $A.get("e.c:reloadEvent");
                appEvent.fire();
                component.set("v.showSpinner",false);
            }else{
                if(state === "ERROR"){
                    component.set("v.showSpinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message :  data.getError()[0].message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();  
                }
            }
        });
        $A.enqueueAction(action);
    },
    transferStudentCAUIValCheck : function(component,event,helper) {
        component.set("v.showSpinner",true);
        var studentTransferCAMap = component.get("v.studentTransferCAMap");
        var action=  component.get("c.transferStudentCAValidationCheck");

        action.setParams({
            'newCAStartDt':studentTransferCAMap.transferCASTDate,
            'newCAProjectId': studentTransferCAMap.projectLookup[0].Id,
            'stuConId': component.get("v.contactId")
        });
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS"){
                var result = data.getReturnValue();

                if(!result){
                    studentTransferCAMap.isShowConfirmationModal = true;
                    studentTransferCAMap.isShowTransferStuCAVal = false;
                    studentTransferCAMap.transferCAValMsg = null;
                }else{
                    studentTransferCAMap.isShowConfirmationModal = false;
                    studentTransferCAMap.isShowTransferStuCAVal = true;
                    studentTransferCAMap.transferCAValMsg = result;
                }
                component.set("v.studentTransferCAMap",studentTransferCAMap);
                component.set("v.showSpinner",false);
            }else{
                if(state === "ERROR"){
                    component.set("v.showSpinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message :  data.getError()[0].message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();  
                }
            }
        });
        $A.enqueueAction(action);
    },
    getStudentNamesForClassLeader : function(component,event,helper) {
        component.set("v.showSpinner",true);
        var studentTransferCAMap = component.get("v.studentTransferCAMap");
        var action = component.get("c.getStudentCAsForClassLeader");
        action.setParams({
            'currentCAProjectId': component.get("v.parentId"),
            'oldCAPosition' : component.get("v.caRecord").Assignment_Position__c
        });
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS"){
                studentTransferCAMap.studentCANames = JSON.parse(data.getReturnValue());
                studentTransferCAMap.isTransferStudentCA = true;
                component.set("v.studentTransferCAMap",studentTransferCAMap);
                component.set("v.showSpinner",false);
                component.find("transferCA").openModal();
            }else{
                if(state === "ERROR"){
                    component.set("v.showSpinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message :  data.getError()[0].message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();  
                }
            }
        });
        $A.enqueueAction(action);
    }
})