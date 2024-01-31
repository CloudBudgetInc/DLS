({
    handleRecordUpdated: function(cmp, event, helper) {
        console.log('::***:::');
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.",JSON.stringify(cmp.get("v.simpleRecord")));
            cmp.set("v.oppId",cmp.get("v.simpleRecord").AcctSeed__Opportunity__c);
        	helper.createMissedTimeLog(cmp, event, helper);
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
    
    closeAction : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    }
})