({
     doinit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        cmp.set("v.openModel",true);
         
        var  permissionAccess = cmp.get("v.actionPerform");
        var cARTName = cmp.get("v.recordTypeName");
        var action = cmp.get("c.cARecordAccess");
        action.setParams({
            "recordAccess" : permissionAccess
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                if(result) {
                    if(permissionAccess == 'Create' || permissionAccess == 'Edit' ){
                        helper.getExistingCARelInfo(cmp,event,helper);      
                    }else if(permissionAccess == 'Delete'){
                        if(cARTName == 'Instructor' && cmp.get("v.sObjectName") == 'AcctSeed__Project__c'){
                            helper.getExistingCARelInfo(cmp,event,helper);
                        }else {
                            if (permissionAccess == 'Delete'){
                                cmp.set("v.showSpinner",false);
                                cmp.set("v.showDeleteModel",true);
                                cmp.find("caDeleteModal").open();
                            }
                        }  
                    }
                }else {
                    
                    cmp.set("v.showSpinner",false);
                    cmp.set("v.displayPermissionModel",true);
                    cmp.find("permissionModal").open();
                }
            } else{
                cmp.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  data.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();  
            }
        });
        $A.enqueueAction(action);
        
    },

    instructorSaveBtnClick: function(cmp, event, helper){
        var isValid = helper.validationToCreateCA(cmp,event,helper)
        helper.instructorSaveBtnClkHelper(cmp, event, helper, isValid)
    },
    instructorCancelBtnClick : function(cmp, event, helper){
        
        cmp.set("v.openModel",false);
        cmp.set("v.displayAddModal",false);
        var appEvent = $A.get("e.c:reloadEvent");
        appEvent.fire();
    },
    otherSaveBtnClick: function(cmp, event, helper){
        
        var isValidinput = false;
        var isValidinput = helper.validationToCreateCA(cmp,event,helper);
        var parentRecordType = cmp.get("v.parentRecordType");
        
        if(isValidinput){
            
            if(parentRecordType == 'DLI_W_TO_Opportunities' && cmp.get("v.sObjectName") == 'Opportunity' &&  cmp.get("v.caRecord").Status__c != 'Awarded'){
                helper.upsertActionforOtherTab(cmp,event,helper) ;  
            }else if(cmp.get("v.recordTypeName") == 'Staff'){
                cmp.set("v.showSpinner",true);
                helper.staffUpsertActionConfirmation(cmp,event,helper);
            }else{
                helper.upsertActionforOtherTab(cmp,event,helper);   
            }
        }
    },
    otherCancelBtnClick : function(cmp, event, helper){
        cmp.set("v.openModel",false);
        cmp.set("v.displayAddModal",false);
        var appEvent = $A.get("e.c:reloadEvent");
        appEvent.fire(); 
    },
    caDeleteClick : function(cmp, event, helper){
        cmp.set("v.showSpinner",true); 
        helper.deleteActionForAllTab(cmp,event,helper);
    },
    caDeleteCancelClick:function(cmp, event, helper){
        cmp.set("v.displayAddModal",false);
        cmp.set("v.showDeleteModel",false);
    },
    permissionOkClick:function(cmp, event, helper){
        cmp.set("v.displayAddModal",false);
        cmp.set("v.displayPermissionModel",false);
    },
    updateExistingStaffRecord  :function(cmp, event, helper){
        
        cmp.set("v.showSpinner",true);
        var obj = {};
        obj = cmp.get("v.caRecord");
        
        if(Array.isArray(cmp.get("v.caRecord").Candidate_Name__c)) {
            obj.Candidate_Name__c = cmp.get("v.caRecord").Candidate_Name__c[0];
        }
        
        if(Array.isArray(cmp.get("v.caRecord").Location__c)) {
            obj.Location__c = cmp.get("v.caRecord").Location__c[0];
        }   
        var caArray = []; 
        caArray.push(obj);
        console.log(JSON.stringify(caArray)); 
        var action = cmp.get("c.staffStatusUpdate");
        action.setParams({
            "parentId" : cmp.get("v.parentId"),
            'conAssignJson': JSON.stringify(caArray)
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                cmp.set("v.showExistingLTSUpdateModel",false);
                cmp.set("v.showSpinner",false);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success",
                    message:"Contact Assignment was Created ",
                    type:"success"
                });
                toastEvent.fire();
                
                var appEvent = $A.get("e.c:reloadEvent");
                appEvent.fire();
            } else{
                cmp.set("v.showSpinner",false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  data.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    },
    saveExistingStaffRecord:function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        helper.upsertActionforOtherTab(cmp,event,helper); 
    },
    deleteSchedule:function(cmp, event, helper){
        cmp.set("v.showDeleteSchValidationModel",false);
        cmp.set("v.displayAddModal",false);
    },
    
    summaryInstructorTab: function(cmp, event, helper) {
        
        var tab1 = cmp.find('Summary');
        var TabOnedata = cmp.find('SummaryTabDataId');
        
        var tab2 = cmp.find('ProjectTracking');
        var TabTwoData = cmp.find('ProjectTrackingTabDataId');
        
        var tab3 = cmp.find('Description');
        var TabThreeData = cmp.find('DescriptionTabDataId');
        //show and Active Summary tab
        $A.util.addClass(tab1, 'slds-active');
        $A.util.addClass(TabOnedata, 'slds-show');
        $A.util.removeClass(TabOnedata, 'slds-hide');
        // Hide and deactivate others tab
        $A.util.removeClass(tab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-show');
        $A.util.addClass(TabTwoData, 'slds-hide');
        
        $A.util.removeClass(tab3, 'slds-active');
        $A.util.removeClass(TabThreeData, 'slds-show');
        $A.util.addClass(TabThreeData, 'slds-hide');
    },
    projectTrackingInstructorTab: function(cmp, event, helper) {
        
        var tab1 = cmp.find('Summary');
        var TabOnedata = cmp.find('SummaryTabDataId');
        
        var tab2 = cmp.find('ProjectTracking');
        var TabTwoData = cmp.find('ProjectTrackingTabDataId');
        
        var tab3 = cmp.find('Description');
        var TabThreeData = cmp.find('DescriptionTabDataId');
        
        //show and Active ProjectTracking Tab
        $A.util.addClass(tab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-hide');
        $A.util.addClass(TabTwoData, 'slds-show');
        // Hide and deactivate others tab
        $A.util.removeClass(tab1, 'slds-active');
        $A.util.removeClass(TabOnedata, 'slds-show');
        $A.util.addClass(TabOnedata, 'slds-hide');
        
        $A.util.removeClass(tab3, 'slds-active');
        $A.util.removeClass(TabThreeData, 'slds-show');
        $A.util.addClass(TabThreeData, 'slds-hide');
        
    },
    DescriptionInstructorTab: function(cmp, event, helper) {
        
        var tab1 = cmp.find('Summary');
        var TabOnedata = cmp.find('SummaryTabDataId');
        
        var tab2 = cmp.find('ProjectTracking');
        var TabTwoData = cmp.find('ProjectTrackingTabDataId');
        
        var tab3 = cmp.find('Description');
        var TabThreeData = cmp.find('DescriptionTabDataId');
        
        //show and Active Description Tab
        $A.util.addClass(tab3, 'slds-active');
        $A.util.removeClass(TabThreeData, 'slds-hide');
        $A.util.addClass(TabThreeData, 'slds-show');
        // Hide and deactivate others tab
        $A.util.removeClass(tab1, 'slds-active');
        $A.util.removeClass(TabOnedata, 'slds-show');
        $A.util.addClass(TabOnedata, 'slds-hide');
        
        $A.util.removeClass(tab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-show');
        $A.util.addClass(TabTwoData, 'slds-hide');
        
    },
    handleUploadFinished : function(cmp,event,helper){
        var uploadedFiles = event.getParam("files");
        var prefixUrl = $A.get("$Label.c.Org_Prefix_Start_URL");
        
        cmp.get("v.caRecord")['Invoice_URL__c'] = prefixUrl+'/'+uploadedFiles[0].documentId;
        cmp.set("v.caRecord",cmp.get("v.caRecord"));
    },
    closeSubInsModelClK : function(cmp,event,helper){
        cmp.set("v.validationSubstituteInsModal",false);   
        var appEvent = $A.get("e.c:reloadEvent");
        appEvent.fire();
    },
    assignCRValueToCA : function(cmp ,event ,helper) { 
        
        var costRateInfo = event.getParam("costRateInfo"); 
        var caRecord = cmp.get("v.caRecord");
        var parentObjName = cmp.get("v.sObjectName");
        var defaultCR = cmp.get("v.defaultCostRate");
        var isCACreatewithCR = false;
        
        console.log(costRateInfo);
        if(costRateInfo.costRateId && costRateInfo.costRateLabel){
            isCACreatewithCR = true;
            if(costRateInfo.costRateLabel == 'RateCost'){
                caRecord.Rate_Card_Rate__c = costRateInfo.costRateId;   
                caRecord.Drafted_Labor_Cost_Rate__c = null;
            }else {
                caRecord.Drafted_Labor_Cost_Rate__c = costRateInfo.costRateId; 
                caRecord.Rate_Card_Rate__c = null;
            }
            
            if(parentObjName == 'AcctSeed__Project__c' && defaultCR == 'Non-SCA Testing' && costRateInfo.nohrsExcepted != null){
                caRecord.Total_Qty_Planned__c = costRateInfo.nohrsExcepted;
                caRecord.Quantity_Unit__c = 'Hours'; 
            }
            
            cmp.set("v.caRecord",caRecord);
        }
        
        if(costRateInfo.isErrorFROMCRModal){
            cmp.set("v.showCostRateModal",false);
        }else if(isCACreatewithCR){
            helper.upsertActionforOtherTab(cmp,event,helper); 
        }else{
            var appEvent = $A.get("e.c:reloadEvent");
            appEvent.fire();
        }
    },
    caORvalCancelClick : function(cmp, event, helper){
        cmp.set("v.showObservationReportValModel",false);
    },
    caORvalClick : function(cmp, event, helper){
        cmp.set("v.showObservationReportValModel",false);
        helper.instructorSaveBtnClkHelper(cmp,event,helper,true); 
    },
    showErrorLogMsg : function(cmp, event, helper){
        var errorMsg = event.getParam("errorMsg"); 
        if(errorMsg){
            cmp.set("v.showErrorMsg", errorMsg);            
            cmp.set("v.visibleError",'slds-show');     
        }
        cmp.set("v.showCostRateModal",false);
    }
    
})