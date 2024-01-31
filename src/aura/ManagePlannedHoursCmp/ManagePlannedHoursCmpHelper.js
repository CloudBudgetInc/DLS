({
    
    totalQtyplannedHoursValidation : function(cmp, event, helper) { 
        
        var proTaskList = cmp.get("v.projectTaskList");
        var error = 0;
        var warning = 0; 
        var errorList = [];
        var warningList = [];
        var errorWarningList  = [];
        
        for(var i = 0;i < proTaskList.length;i++){
            var totalHrs = parseFloat(proTaskList[i].totalQtyPlanned);
            var hrs = 0;
            for(var j = 0;j < proTaskList[i].conAssignList.length;j++){
                if(proTaskList[i].proTaskType == 'Preparation time'){
                    if(parseFloat(proTaskList[i].conAssignList[j].prepTotalQtyPlanned)){
                        hrs =  parseFloat(hrs) + parseFloat(proTaskList[i].conAssignList[j].prepTotalQtyPlanned);
                    }
                }else{
                    if(parseFloat(proTaskList[i].conAssignList[j].totalQtyPlanned)){
                        hrs = parseFloat(hrs) + parseFloat(proTaskList[i].conAssignList[j].totalQtyPlanned);
                    }
                }
            }
            if(totalHrs < hrs){
                error += 1;
                errorList.push(proTaskList[i].proTaskId);
            }
            if(totalHrs > hrs){
                warning += 1;
                warningList.push(proTaskList[i].proTaskId);
            }
        }
        if(error == 0 && warning > 0){
            cmp.set("v.isProceedBtn",true);
        }
        if(error > 0 || warning > 0){
            
            if(error > 0) {
                for(var i = 0;i < proTaskList.length;i++){
                    if(errorList.includes(proTaskList[i].proTaskId)){
                        proTaskList[i]['showMsg'] = proTaskList[i].proTaskId+'-'+'error';
                    }
                }
            }
            if(warning > 0) {
                for(var i = 0;i < proTaskList.length;i++){
                    if(warningList.includes(proTaskList[i].proTaskId)){
                        proTaskList[i]['showMsg'] = proTaskList[i].proTaskId+'-'+'warning';
                    }
                }
            }
            errorWarningList = errorList.concat(warningList);
            if(errorWarningList.length > 0){
                for(var i = 0;i < proTaskList.length;i++){
                    if(!errorWarningList.includes(proTaskList[i].proTaskId)){
                        proTaskList[i]['showMsg'] = '';
                    }
                }
            }
        }else{
            for(var i = 0;i < proTaskList.length;i++){
                proTaskList[i]['showMsg'] = '';
            }
        }
        cmp.set("v.projectTaskList",proTaskList);
        if(error == 0 && warning == 0) {
            this.saveCARecords(cmp, event, helper);
        }
        
    },
    saveCARecords : function(cmp, event, helper) {
        var proTaskList = cmp.get("v.projectTaskList");
        cmp.set("v.showSpinner",true);
        console.log(JSON.stringify(proTaskList));       
        var cARecordList = [];       
        
        for(var i = 0;i < proTaskList.length;i++){
            for(var j = 0;j < proTaskList[i].conAssignList.length;j++){
                if(cARecordList.length > 0){
                    if(proTaskList[i].proTaskType == 'Preparation time'){
                       var index = cARecordList.findIndex(x => x.Id === proTaskList[i].conAssignList[j].cAId);                        
                        if(proTaskList[i].conAssignList[j].prepTotalQtyPlanned && index){                            
                            cARecordList[index] ['Total_Prep_Qty_Planned__c'] = proTaskList[i].conAssignList[j].prepTotalQtyPlanned;  
                        }
                    }else{
                        if(proTaskList[i].conAssignList[j].totalQtyPlanned) {
                            cARecordList.push({'Id':proTaskList[i].conAssignList[j].cAId,'Candidate_Name__c':proTaskList[i].conAssignList[j].conId,'Total_Qty_Planned__c':proTaskList[i].conAssignList[j].totalQtyPlanned});
                        }
                    }
                }else{
                    if(proTaskList[i].conAssignList[j].totalQtyPlanned) {
                        cARecordList.push({'Id':proTaskList[i].conAssignList[j].cAId,'Candidate_Name__c':proTaskList[i].conAssignList[j].conId,'Total_Qty_Planned__c':proTaskList[i].conAssignList[j].totalQtyPlanned});
                    }
                }
            }
        }
        cmp.set("v.saveContactAssignments",cARecordList);
        console.log(cmp.get("v.saveContactAssignments"));
        
        if(cmp.get("v.saveContactAssignments").length > 0){
            var action = cmp.get("c.saveContactAssignment");
            
            action.setParams({
                conAssign : cmp.get("v.saveContactAssignments")
            });
            action.setCallback(this, function(response) {
                var status = response.getState(); 
                if(status == "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    cmp.set("v.showSpinner",false);
                    
                    if(cmp.get("v.isSaveAndGenAction")){
                        this.getCongaUrlHelper(cmp);
                    }else {
                        var sObjectEvent = $A.get("e.force:navigateToSObject");
                        sObjectEvent .setParams({
                            "recordId":cmp.get("v.projectId"), 
                            "slideDevName": "detail"
                        });
                        sObjectEvent.fire(); 
                    }
                } else {
                    cmp.set("v.showSpinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message :  response.getError()[0].message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();  
                }
            });
            $A.enqueueAction(action);
            
        }
    },
    getCongaUrlHelper : function(cmp){
        var templateName;
        var congaQueryName;
        
        if(cmp.get("v.templateType") == 'Actual'){
            templateName = 'Job Summary Report - Labor Actual';
            congaQueryNmae = 'Project Query for Job Summary Report,Job Summary Report - Project Task Query,ContactAssign Prep Time Query for Job Summary Report - Actual,ContactAssign Query for Job Summary Report - Actual';
        }else if(cmp.get("v.templateType") == 'Planned'){
            templateName = 'Job Summary Report - Labor Planned';
            congaQueryName = 'Project Query for Job Summary Report,Job Summary Report - Project Task Query,ContactAssign Prep Time Query for Job Summary Report,ContactAssign Query for Job Summary Report'; 
        }
        
        var action = cmp.get("c.getCongaUrl");
        action.setParams({
            queryName : congaQueryName,
            templateName : templateName,
            projectId : cmp.get("v.projectId")
        });
        
        action.setCallback(this, function(response) {
            var status = response.getState(); 
            
            if(status == "SUCCESS") {
                
                var returnvalue = JSON.parse(response.getReturnValue());
                var serverUrlSessionId = JSON.parse(returnvalue.congaWrap.sessionIdServerURL);
                var idRec = cmp.get("v.projectId");
                var congaUrl
                
                
                if(templateName == 'Job Summary Report - Labor Actual' ){
                    if(returnvalue.congaWrap.projectTaskName == 'Preparation time'){
                        congaUrl = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                            "&serverUrl="+serverUrlSessionId["serverUrl"]+"&id="+idRec+"&templateId="+
                            returnvalue.congaWrap.tempNameIdMap["Job Summary Report - Labor Actual"]+"&queryId=[Pro]"+
                            returnvalue.congaWrap.queryNameIdMap["Project Query for Job Summary Report"]+"?pv0="+
                            idRec+",[Ins]"+returnvalue.congaWrap.queryNameIdMap["ContactAssign Query for Job Summary Report - Actual"]+
                            "?pv0="+idRec+",[PrepIns]"+returnvalue.congaWrap.queryNameIdMap["ContactAssign Query for Job Summary Report - Actual"]+
                            "?pv0="+idRec+"~pv1="+returnvalue.congaWrap.parentProjectTaskId+",[PrepTime]"+returnvalue.congaWrap.queryNameIdMap["Job Summary Report - Project Task Query"]+"?pv0="+returnvalue.congaWrap.projectTaskId+"&OFN=Job Summary Report - Labor Actual - "+returnvalue.congaWrap.projectName;  // &DS7=1  
                    }else {
                        congaUrl = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                            "&serverUrl="+serverUrlSessionId["serverUrl"]+"&id="+idRec+"&templateId="+
                            returnvalue.congaWrap.tempNameIdMap["Job Summary Report - Labor Actual"]+"&queryId=[Pro]"+
                            returnvalue.congaWrap.queryNameIdMap["Project Query for Job Summary Report"]+"?pv0="+
                            idRec+",[Ins]"+returnvalue.congaWrap.queryNameIdMap["ContactAssign Query for Job Summary Report - Actual"]+
                            "?pv0="+idRec+"&OFN=Job Summary Report - Labor Actual - "+returnvalue.congaWrap.projectName;  // &DS7=13
                    }
                }else if(templateName == 'Job Summary Report - Labor Planned'){
                    if(returnvalue.congaWrap.projectTaskName == 'Preparation time'){
                        congaUrl = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                            "&serverUrl="+serverUrlSessionId["serverUrl"]+"&id="+idRec+"&templateId="+
                            returnvalue.congaWrap.tempNameIdMap["Job Summary Report - Labor Planned"]+"&queryId=[Pro]"+
                            returnvalue.congaWrap.queryNameIdMap["Project Query for Job Summary Report"]+"?pv0="+
                            idRec+",[Ins]"+returnvalue.congaWrap.queryNameIdMap["ContactAssign Query for Job Summary Report"]+
                            "?pv0="+idRec+",[PrepIns]"+returnvalue.congaWrap.queryNameIdMap["ContactAssign Query for Job Summary Report"]+
                            "?pv0="+idRec+"~pv1="+returnvalue.congaWrap.parentProjectTaskId+",[PrepTime]"+returnvalue.congaWrap.queryNameIdMap["Job Summary Report - Project Task Query"]+"?pv0="+returnvalue.congaWrap.projectTaskId+"&OFN=Job Summary Report - Labor Planned - "+returnvalue.congaWrap.projectName; // &DS7=13
                    }else{
                        congaUrl = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                            "&serverUrl="+serverUrlSessionId["serverUrl"]+"&id="+idRec+"&templateId="+
                            returnvalue.congaWrap.tempNameIdMap["Job Summary Report - Labor Planned"]+"&queryId=[Pro]"+
                            returnvalue.congaWrap.queryNameIdMap["Project Query for Job Summary Report"]+"?pv0="+
                            idRec+",[Ins]"+returnvalue.congaWrap.queryNameIdMap["ContactAssign Query for Job Summary Report"]+
                            "?pv0="+idRec+"&OFN=Job Summary Report - Labor Planned - "+returnvalue.congaWrap.projectName; // &DS7=13
                    }
                }
                window.open(congaUrl,'_self');
            } else {
                cmp.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  response.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();  
            }
        });
        $A.enqueueAction(action);
    }
})