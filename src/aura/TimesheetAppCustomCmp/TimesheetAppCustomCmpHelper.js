({
    getWorkItem : function(cmp, event){
        console.log('getWorkItems before');
        
        var action = cmp.get("c.getWorkItems");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State: ' + state);
            if (state === "SUCCESS") {
                console.log(':::::::response.getReturnValue()::::',response.getReturnValue());
                cmp.set("v.workItems", response.getReturnValue());
                
                var self = this;
                window.setTimeout(
                    $A.getCallback(function() {
                        if(cmp.get("v.sObjectName") == 'agf__ADM_Work__c'){
                            var timeInput = cmp.get("v.timeInput");
                            timeInput.MBA_Work_Item_Lookup__c = cmp.get("v.recordId");
                            cmp.set("v.timeInput",timeInput);
                            
                            var cmpTarget = cmp.find('editDialog');
                            var cmpBack = cmp.find('dialogBack');
                            $A.util.addClass(cmpTarget, 'slds-fade-in-open');
                            $A.util.addClass(cmpBack, 'slds-backdrop--open');
                        }else {
                            self.getCurrentTimeRecord(cmp);
                        }
                    }),100);
                
            }else {
                console.log("Get Work Failed with state: " + state);
            }
        });
        $A.enqueueAction(action); 
    },
    getCurrentTimeRecord : function(cmp){
        var action = cmp.get("c.getRecordToEditFromDb");
        action.setParams({
            "recId": cmp.get("v.recordId")
        });
        console.log('after action setup in edit record helper method');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                console.log('resultData..'+JSON.stringify(resultData));
                cmp.set("v.timeInput", resultData);
                var cmpTarget = cmp.find('editDialog');
                var cmpBack = cmp.find('dialogBack');
                $A.util.addClass(cmpTarget, 'slds-fade-in-open');
                $A.util.addClass(cmpBack, 'slds-backdrop--open');
            }else {
                console.log("Get EditTimeItem Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    saveTimerecord : function(cmp){
        console.log('Save All Items'); 
        var timeInput = cmp.get("v.timeInput");
        var allTimeInputs = [];
        allTimeInputs.push(timeInput);
        console.log(':::::::::timeInputs:::',JSON.stringify(timeInput));
        var action = cmp.get("c.setAllTimeInputs");
        action.setParams({
            "timeInputs": allTimeInputs 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if (state==="SUCCESS"){
                console.log("Time inputs successfully saved!",response.getReturnValue());
                var result = response.getReturnValue();
                resultsToast.setParams({
                    "title": "Saved",
                    "type": "success",
                    "message": "Time inputs successfully saved."
                });
                resultsToast.fire();
                var cmpTarget = cmp.find('editDialog');
                var cmpBack = cmp.find('dialogBack');
                $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
                $A.util.removeClass(cmpBack, 'slds-backdrop--open');
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result[0].Id
                });
                navEvt.fire();
            }else {
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                console.log("Save All Failed with state: " + state);
                console.log("Error: "+ message);
                resultsToast.setParams({
                    "title": "Error",
                    "type":"error",
                    "message": "There was an error saving the record: " + message
                });
                resultsToast.fire();
            }
        });
        $A.enqueueAction(action);
    },
    updateTimeRecord : function(cmp){
        var recordToSave = cmp.get("v.timeInput");
        var action = cmp.get("c.saveRecordToEditToDb");
        action.setParams({
            "recordToUpdate": recordToSave
        });
        action.setCallback(this, function(response) {
            var resultsToast = $A.get("e.force:showToast");
            var state = response.getState();
            if (state === "SUCCESS" ) {
                console.log("Save EditTimeItem to DB Successful!!");
                resultsToast.setParams({
                    "title": "Saved",
                    "type": "success",
                    "message": "Item successfully saved."
                });
                resultsToast.fire();
                var cmpTarget = cmp.find('editDialog');
                var cmpBack = cmp.find('dialogBack');
                $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
                $A.util.removeClass(cmpBack, 'slds-backdrop--open');
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": cmp.get("v.recordId")
                });
                navEvt.fire();
            }else {
                console.log("Save EditTimeItem to DB Failed with state: " + state);
                resultsToast.setParams({
                    "title": "Error",
                    "type":"error",
                    "message": "There was an error saving the record: " + JSON.stringify(result.error)
                });
                resultsToast.fire();
            }
        });
        $A.enqueueAction(action);
    }
})