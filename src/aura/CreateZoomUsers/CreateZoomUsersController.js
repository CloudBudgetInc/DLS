({
	instructorLookupSearch : function(component, event, helper) {
		const serverSearchAction = component.get('c.getLookupRecords');
        component.find('instructorLookup').search(serverSearchAction);
	},
    createZoomUsers: function(component, event, helper){
        var isValid = component.find('instructorLookup').validate();
        if(isValid){
            component.set("v.showSpinner",true);
            
            var selectedInstructors = component.get('v.selectedInstructors'),
            	instructorIds = [];
            
            for(var i = 0; i < selectedInstructors.length; i++){
                instructorIds.push(selectedInstructors[i].Id);
            }
            
            var action  = component.get("c.checkAndCreateZoomUsers");
            action.setParams({
                "instructorIdStr" : JSON.stringify(instructorIds)
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                component.set("v.showSpinner",false);
                
                if(state == 'SUCCESS'){
                    var result = response.getReturnValue(),
                        msg = result == 'success' ? 'Zoom User creation initiated successfully.' : result;
                    
					helper.showModal(component, 'Success', msg);                    
                }else {
                    
                    helper.showModal(component, 'Error', response.getError()[0].message);                    
                }
            });
            $A.enqueueAction(action);
        }
    },
    closeClickOnSuccess: function(component, event, helper){
        component.set('v.selectedInstructors', []);
        
        if(Array.isArray(component.find("successModal"))) {
            component.find("successModal")[0].close();
        }else{
            component.find("successModal").close();
        }  
    }
})