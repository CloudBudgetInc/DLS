({
	congaUrl : function(cmp,event,helper,template) {
		var val = cmp.get("v.returnValue");
        var returnvalue = val.valueReturn;
        var serverUrlSessionId = val.serverUrlSessionId;
        var idRec = cmp.get("v.recordId");
         var congaUrl;
        
        if(template == 'Job Summary Report - Labor Actual' ){
            if(returnvalue.congaWrap.projectTaskName == 'Preparation time'){
                congaUrl = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                    "&serverUrl="+serverUrlSessionId["serverUrl"]+"&id="+idRec+"&templateId="+
                    returnvalue.congaWrap.tempNameIdMap["Job Summary Report - Labor Actual"]+"&queryId=[Pro]"+
                    returnvalue.congaWrap.queryNameIdMap["Project Query for Job Summary Report"]+"?pv0="+
                    idRec+",[Ins]"+returnvalue.congaWrap.queryNameIdMap["ContactAssign Query for Job Summary Report - Actual"]+
                    "?pv0="+idRec+",[PrepIns]"+returnvalue.congaWrap.queryNameIdMap["ContactAssign Prep Time Query for Job Summary Report - Actual"]+
                    "?pv0="+idRec+"~pv1="+returnvalue.congaWrap.parentProjectTaskId+"&OFN=Job Summary Report - Labor Actual - "+returnvalue.congaWrap.projectName;  // &DS7=1  
            }else {
                congaUrl = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                    "&serverUrl="+serverUrlSessionId["serverUrl"]+"&id="+idRec+"&templateId="+
                    returnvalue.congaWrap.tempNameIdMap["Job Summary Report - Labor Actual"]+"&queryId=[Pro]"+
                    returnvalue.congaWrap.queryNameIdMap["Project Query for Job Summary Report"]+"?pv0="+
                    idRec+",[Ins]"+returnvalue.congaWrap.queryNameIdMap["ContactAssign Query for Job Summary Report - Actual"]+
                    "?pv0="+idRec+"&OFN=Job Summary Report - Labor Actual - "+returnvalue.congaWrap.projectName;  // &DS7=13
            }
        }else if(template == 'Job Summary Report - Labor Planned'){
            if(returnvalue.congaWrap.projectTaskName == 'Preparation time'){
                congaUrl = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                    "&serverUrl="+serverUrlSessionId["serverUrl"]+"&id="+idRec+"&templateId="+
                    returnvalue.congaWrap.tempNameIdMap["Job Summary Report - Labor Planned"]+"&queryId=[Pro]"+
                    returnvalue.congaWrap.queryNameIdMap["Project Query for Job Summary Report"]+"?pv0="+
                    idRec+",[Ins]"+returnvalue.congaWrap.queryNameIdMap["ContactAssign Query for Job Summary Report"]+
                    "?pv0="+idRec+",[PrepIns]"+returnvalue.congaWrap.queryNameIdMap["ContactAssign Prep Time Query for Job Summary Report"]+
                    "?pv0="+idRec+"~pv1="+returnvalue.congaWrap.parentProjectTaskId+"&OFN=Job Summary Report - Labor Planned - "+returnvalue.congaWrap.projectName; // &DS7=13
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
        $A.get("e.force:closeQuickAction").fire();
    },
    getCongaForJobSummaryReport : function(cmp,event,helper,templateName){

        var action = cmp.get("c.jobSummaryReport");
        var idRec = cmp.get("v.recordId");
        cmp.set("v.showiframe", false);
        
        action.setParams({
            recId : idRec,
            queryName : cmp.get("v.congaQueryName"),
            templateName : templateName,
        });
        
        action.setCallback(this, function(response) {
            var status = response.getState(); 

            if(status == "SUCCESS") {
                var returnValue = response.getReturnValue();
                var returnVal = cmp.get("v.returnValue");
                returnVal.valueReturn = returnValue;
                returnVal.serverUrlSessionId = JSON.parse(returnValue.congaWrap.sessionIdServerURL);
                cmp.set("v.returnValue", returnVal);
                console.log('returnValue'+JSON.stringify(returnValue));
               if(returnValue.status == 'error') {   
                   $A.get("e.force:closeQuickAction").fire();
                   if(templateName == 'Job Summary Report - Labor Actual'){
                       //  window.open("/apex/contactAssignmentHoursValidation?projectId="+idRec+"&web=true&templateType=Actual",'_self');
                       window.open("/lightning/n/Manage_Planned_Hours?templateType=Actual&web=true&projectId="+idRec,'_self');
                   }else if(templateName == 'Job Summary Report - Labor Planned'){
                       //  window.open("/apex/contactAssignmentHoursValidation?projectId="+idRec+"&web=true&templateType=Planned",'_self');
                       window.open("/lightning/n/Manage_Planned_Hours?templateType=Planned&web=true&projectId="+idRec,'_self');
                   }
               }else if(returnValue.status == 'warning'){
                    if(templateName == 'Job Summary Report - Labor Planned'){
                        cmp.set("v.isCongaPickist",false);
                        cmp.set("v.returnStatus",returnValue.status);
                    }
                }else {
                   this.congaUrl(cmp,event,helper,templateName,cmp.get("v.congaQueryName"));
                }
            } else {
                cmp.set("v.isCongaPickist",false);
                cmp.set("v.showErrorMsg",true);
                var str = cmp.get("v.card");
                str.title = "Error";
                str.message = response.getError()[0].message;
                str.buttonName = "Okay";
                cmp.set("v.card", str);
                
            }
        });
        $A.enqueueAction(action);
    }
})