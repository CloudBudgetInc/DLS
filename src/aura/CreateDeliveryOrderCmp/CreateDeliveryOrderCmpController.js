({
    doinit : function(component, event, helper) {
        
        var action = component.get("c.isContractLevelisParent");
        component.set("v.showSpinner",true);
        action.setParams({
            "parentContractId" : component.get("v.recordId")
        });
        action.setCallback(this, function(data){
            var state = data.getState();
            if(state == 'SUCCESS'){
                var result = data.getReturnValue();
                component.set("v.showSpinner",false);
                component.set("v.isContractLevelParent",result); 
                if(!result){
                    component.set("v.showValidationMsg","Delivery Order creation is only applicable for parent contract");
                }
            }else{
                component.set("v.showSpinner",false);
                //component.set("v.showValidationMsg","Something Happened. Please try again later");
                component.set("v.showErrorMsg",data.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    proceedClk : function(component, event, helper) {
        var newContract = component.get("v.newContract");
        var selectedLangList = component.get("v.selectedLanguages");
        var  otherInputs = component.find("otherInput");
        var  dateInputs = component.find("dateInput");
        var isValid = true;
        
        for(var i = 0;i < otherInputs.length;i++) {
            if(!otherInputs[i].get("v.value")){
                isValid = false;
                $A.util.addClass(otherInputs[i], 'slds-has-error'); 
            }else {
                $A.util.removeClass(otherInputs[i], 'slds-has-error'); 
            }
        }
        
        for(var i = 0;i < dateInputs.length;i++) {
            if (!dateInputs[i].get("v.value")) { 
                dateInputs[i].set("v.errors", [{message:" "}])
                isValid = false;
            } else {
                dateInputs[i].set("v.errors", null);
            }
        }
        
        if(isValid && selectedLangList.length > 0) {
            if(selectedLangList.length > 0){
                newContract['Language__c'] = selectedLangList[0].Id;
            }
            component.set("v.visibleError",'slds-hide');
            component.set("v.newContract",newContract);
            helper.saveNewContractHelper(component,event,helper);
        }
    },
    closeClk : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    },
    languageLookupSearch : function(component, event, helper) {
        // Get the search server side action
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('languageLookup').search(serverSearchAction);
    }
})