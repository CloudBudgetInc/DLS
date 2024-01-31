({
    doinit : function(component, event, helper) {
        
        var action = component.get("c.getInitialBudgetRecords");
        action.setParams({
            'projectId':component.get("v.projectId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                console.log('Budget',JSON.parse(response.getReturnValue()));
                var result = JSON.parse(response.getReturnValue());
                if(result){
                   	component.set('v.showBudgetSection', result['showBudgetSection']);
                    
                    if(result['serviceSectionInfo']){
                        component.set("v.serviceSectionList",result['serviceSectionInfo']);
                    }
                    if(result['materialSectionInfo']){
                        component.set("v.materialSectionList",result['materialSectionInfo']);
                    }
                    if(result['materialRequestSectionInfo']){
                        component.set("v.materialRequestSectionList",result['materialRequestSectionInfo']);
                    }
                    if(result['materialLoanSectionInfo']){
                        component.set("v.materialLoanSectionList",result['materialLoanSectionInfo']);
                    }
                    if(result['projectRTName']){
                        component.set("v.projectRTName",result['projectRTName']);
                    }
                }
            }else if(state == 'ERROR'){
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
    },
    handleCommunityCmpVisibilitiesChange: function(cmp){
        let communityCmpVisibilities = cmp.get('v.communityCmpVisibilities'),
        	 budgetCmpVisibility = communityCmpVisibilities.Budget;
        
        cmp.set('v.budgetCmpVisibility', budgetCmpVisibility);
    },
    tabClick : function(component, event, helper) {
        var tabName = event.currentTarget.name;
        
        if(tabName == 'Services') {
            component.set("v.activeTab",tabName);
        }else if(tabName == 'Material') {
            component.set("v.activeTab",tabName);  
        }
    },
    matReqLoanTabClk : function(component, event, helper) {
        var tabName = event.currentTarget.name;
        
        if(tabName == 'Request') {
            component.set("v.matReqLoanTab",tabName);
        }else if(tabName == 'Loan') {
            component.set("v.matReqLoanTab",tabName);  
        }
    },
    activityCheckedClk : function(component, event, helper) {
        var activityCheck = document.getElementById("customSwitch1").checked;
        component.set("v.activityChecked",activityCheck);
    }
})