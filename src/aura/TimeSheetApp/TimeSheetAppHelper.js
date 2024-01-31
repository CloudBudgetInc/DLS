({
    addInput : function(cmp,event) {
        console.log('AddInput Start');
        
        //set Add button to not display
        cmp.set("v.add", false);
        
        // Get variables to update
        const workItems = cmp.get("v.workItems");
        var numberTimeInputs = cmp.get("v.numTimeInputs");
        console.log('AddInput Get Work Items');
        
        //Set array to track time input indices
        var timeInputIndices = cmp.get("v.timeInputIndices");
        timeInputIndices.push(numberTimeInputs);
        console.log('Add '+ numberTimeInputs + ' to timeInputIndices array.  Result: '+ timeInputIndices);
        cmp.set("v.timeInputIndices", timeInputIndices);
        console.log('Time Input Indices: '+ timeInputIndices);
        
        cmp.set("v.showSpinner", true);
        
        //Set the variables for the new component
        var timeEntryPanel = cmp.find("timeEntryPanel");
        var attributes = { 'workItems':workItems,
                          'lineNumber':numberTimeInputs
                         };
        var createdCmp = "TimeSheetAppTimeInput";
        console.log('Attributes: ' + attributes);
        
        //Create the new component
        $A.createComponent(
            "c:" + createdCmp, attributes,
            function(retCmp, status, message) {
                timeEntryPanel = cmp.find("timeEntryPanel");
                var body = timeEntryPanel.get("v.body");
                body.push(retCmp);
                console.log('AddInput', retCmp);
                timeEntryPanel.set("v.body", body);
                cmp.set("v.showSpinner", false);
                
            });       
    },
    getWorkItem : function(cmp, event){
        console.log('getWorkItems before');
        
        // Create the action
        var action = cmp.get("c.getWorkItems");
        console.log('After var action');
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State: ' + state);
            if (state === "SUCCESS") {
                cmp.set("v.workItems", response.getReturnValue());
            }
            else {
                console.log("Get Work Failed with state: " + state);
            }
        });
        
        // Send action off to be executed
        $A.enqueueAction(action); 
    },
    
    handleUpdateTimeInput : function(cmp,event){
        console.log('handleUpdateTimeInput');
        
        //Get the array to be updated and the element to be added 
        var timeInput = event.getParam("timeInput");
        var lineNumber = event.getParam("lineNumber");
        console.log('timeInput work item: ' + timeInput.MBA_Work_Item_Lookup__c);
        var timeInputs = cmp.get("v.timeInputs");
        
        var timeInputIndices = cmp.get("v.timeInputIndices");
        
        //Check to see if lineNumber is in timeInputIndices to see if timeInput 
        //should be added to array or update existing line
        if(timeInputIndices.includes(lineNumber)){
            //Update existing line in array
            var positionToEdit = timeInputIndices.indexOf(lineNumber);
            console.log('Position to Edit: ' + positionToEdit);
            timeInputs[positionToEdit] = timeInput;
        } else {
            //Add the new element to the array
        	timeInputs.push(timeInput);
        }
        
        
        //Set the array back to lightning component and show add button
        cmp.set("v.timeInputs", timeInputs);
        cmp.set("v.add", true);
    },
    
    handleDeleteTimeInput : function(cmp,event){
        console.log('handleDeleteTimeInput');
        
        //Get arrays to update and line to be deleted
        var lineToDelete = event.getParam("lineToDelete");
        var timeInputIndices = cmp.get("v.timeInputIndices");
        var timeInputs = cmp.get("v.timeInputs");
        
        console.log('Line to Delete: ' + lineToDelete);
        console.log('Time Input Indices: '+ timeInputIndices);
        
        //Check to see if line to be deleted was added to array
        if (timeInputIndices.includes(lineToDelete)){
            var positionToDelete = timeInputIndices.indexOf(lineToDelete);
            console.log('Position to Delete: ' + positionToDelete);
            
            //Remove element from Indices array as well as timeInputs array
            timeInputIndices.splice(positionToDelete, 1);
            timeInputs.splice(positionToDelete, 1);
        }
        console.log('Time Inputs: '+ timeInputs);
        console.log('Time Input Indices: ' + timeInputIndices);
        
        // set the arrays back to lightning component
        cmp.set("v.timeInputIndices", timeInputIndices);
        cmp.set("v.timeInputs", timeInputs);
    },
    
    saveAllItems : function(cmp,event){
        console.log('Save All Items'); 
        
        //setup action to call Apex server side controller
        var timeInputs = cmp.get("v.timeInputs");
        console.log(':::::::::timeInputs[0]:::',timeInputs);
        timeInputs[0].sobjectType = 'MBA_Timesheet__c';
        console.log('timeInputs 0 Name: '+ timeInputs[0].Description__c);
        console.log('timeInputs 0 MBA_Work_Item_Lookup__c: '+ timeInputs[0].MBA_Work_Item_Lookup__c)
        var action = cmp.get("c.setAllTimeInputs");
        action.setParams({
            "timeInputs": timeInputs 
        });
        
        //Setup what happens upon callback of action
        action.setCallback(this, function(response){
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if (state==="SUCCESS"){
                console.log("Time inputs successfully saved!");
                resultsToast.setParams({
                    "title": "Saved",
                    "type": "success",
                    "message": "Time inputs successfully saved."
                });
                resultsToast.fire();
                
                //fire event to update data table and chart
                var timePeriod = 'Today';
                var updateEventDT = $A.get("e.c:dataTableUpdate");
                updateEventDT.setParams({"timePeriod": timePeriod});
        		updateEventDT.fire();
                console.log('SaveAll event to update date table fired');
                
                var updateEventChart = $A.get("e.c:chartUpdate");
        		updateEventChart.fire();
                console.log('SaveAll event to update date table fired');
                
                //reset timeInputs array
                cmp.set("v.timeInputs", []);
                cmp.set("v.numTimeInputs", 0);
                
                //destroy lines
                cmp.find("timeEntryPanel").set("v.body",[]);  
                this.addInput(cmp, event);
            }
            else {
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
        
        //Fire action
        $A.enqueueAction(action);
    },
})