({
    ContactLookupSearch : function(component, event, helper) {
        // Get the search server side action
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('ContactLookup').search(serverSearchAction);
    },
    searchPlannedOffRecords : function(component, event, helper) {
        helper.searchPDORecords(component, event, helper);
    },
    planOffAddEditSave: function(component, event, helper){
        var otherInputField = component.find("otherInputField");
        var selectedContact = component.get("v.selectedContact");
        var dateInputField = component.find("dateInputField");
        var conLookup =  component.find('ContactLookup');
        var isValid = true;
          
        if(selectedContact && (selectedContact.length == 0)){
            isValid = false;
            $A.util.addClass(conLookup, 'slds-has-error');
        }else{
            $A.util.removeClass(conLookup, 'slds-has-error');
        }
        
        if(Array.isArray(dateInputField)){ 
            if (!dateInputField[0].get("v.value")) { 
                dateInputField[0].set("v.errors", [{message:" "}])
                isValid = false;
            } else {
                dateInputField[0].set("v.errors", null);
            }
            var fromDate = new Date(dateInputField[0].get("v.value"));
            var toDate= new Date(dateInputField[1].get("v.value"));
            if(toDate != null  || toDate != '' ){
                if(fromDate.getTime() > toDate.getTime() ){
                    isValid = false;  
                    dateInputField[1].set("v.errors", [{message:" End date must be greater than Start date "}])
                } else{
                    dateInputField[1].set("v.errors", null); 
                }
            }
        }
        
        if(Array.isArray(otherInputField)){
            for(var i = 0;i < otherInputField.length;i++) {      
                if(!otherInputField[i].get("v.value")) {
                    isValid = false;
                    $A.util.addClass(otherInputField[i], 'slds-has-error'); 
                }else {   
                    $A.util.removeClass(otherInputField[i], 'slds-has-error');
                    
                }
            }
        }else  {
            if(!otherInputField.get("v.value")) {
                isValid =false;
                $A.util.addClass(otherInputField, 'slds-has-error');
            }else{
                $A.util.removeClass(otherInputField, 'slds-has-error')  
            }
        }
        if(isValid){
            helper.savePDOClick(component,event,helper)
        }
    },
    filterChange : function(component, event, helper) {
        var selectedContact =  component.get("v.selectedContact");
        
        if(selectedContact.length > 0){
            component.set("v.showSpinner",true);
            var action = component.get("c.getContacts");
            
            action.setParams({ 
                "conId" : selectedContact[0].Id,
            });
            action.setCallback(this, function(data) {
                var state = data.getState();
                if(state == "SUCCESS"){
                    var result = data.getReturnValue();
                    component.set("v.showSpinner",false);
                    if(result.length > 0){
                        component.set("v.contactRec",result[0]);
                    }
                }else if(state == "ERROR"){
                        component.set("v.showSpinner",false);  
                        helper.showToast(component,event,helper,'error','',data.getError()[0].message,'pester','info_alt');
                }
            });
            $A.enqueueAction(action);
        }else{
            
        }
    },
    closeAction :  function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})