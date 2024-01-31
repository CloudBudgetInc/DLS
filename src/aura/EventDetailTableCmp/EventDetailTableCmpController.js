({
	cancelChange: function(component, event, helper){
        var index = event.getSource().get("v.name");
        var event = component.get("v.event");
        var changedIds = component.get("v.updatedEventIds");
        
        if(event.cancelSelection == 'Canceled'){
            event.selectedTCD = '--Select--';
            event.disableTimeSelection = true;
        }else {
            event.disableTimeSelection = false;
        }
        
        if(event.cancelSelection != '--Select--'){
            if(changedIds.indexOf(event.eventId) == -1){
                changedIds.push(event.eventId);
            }
        }else if(changedIds.indexOf(event.eventId) != -1){
            if(event.cancelSelection == '--Select--' && event.selectedTCD == '--Select--'){
                changedIds.splice(changedIds.indexOf(event.eventId),1);
            }
        }
        
        component.set("v.event",event);
        component.set("v.updatedEventIds",changedIds);
    },
    timeMapped: function(component, event, helper){
        var index = event.getSource().get("v.name");
        var event = component.get("v.event");
        var changedIds = component.get("v.updatedEventIds");
        
        if(event.selectedTCD != '--Select--'){
            var options = ['Late Cancellation'];
            component.set("v.cancelType",options);
        }else {
            event.cancelDisabled = false;
            component.set("v.cancelType",component.get("v.cancellationType"));
        }
        
        if(event.selectedTCD != '--Select--'){
            if(changedIds.indexOf(event.eventId) == -1){
                changedIds.push(event.eventId);
            }
        }else if(changedIds.indexOf(event.eventId) != -1){
            if(event.cancelSelection == '--Select--' && event.selectedTCD == '--Select--'){
                changedIds.splice(changedIds.indexOf(event.eventId),1);
            }
        }
        
        component.set("v.event",event);
        component.set("v.updatedEventIds",changedIds);
    },
    toggleHasError : function(cmp, event) {
        var params = event.getParam('arguments');
        if (params) {
            var hasError = params.hasError,
            	matchTimeCmp = cmp.find('matchTime'),
                cancelSelect = cmp.find('cancelSelect');
            
            if(hasError){
               $A.util.addClass(cancelSelect, 'slds-has-error'); 
               $A.util.addClass(matchTimeCmp, 'slds-has-error'); 
            }else{
               $A.util.removeClass(cancelSelect, 'slds-has-error');
               $A.util.removeClass(matchTimeCmp, 'slds-has-error');
            }                                 
        }
    }
})