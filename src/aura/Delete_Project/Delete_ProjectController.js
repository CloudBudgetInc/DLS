({
    closeAction : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    },
    
    deletePro : function(cmp, event, helper) {
        
        var action =  cmp.get("c.deleteRecords");
        action.setParams({
            'projectId' : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var oppUrl = '';
                if(cmp.get("v.oppId")){
                    oppUrl = '/'+cmp.get("v.simpleRecord").AcctSeed__Opportunity__c;
                }else {
                    oppUrl = '/a48';
                }
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": oppUrl
                });
                urlEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }else {
                console.log('::::error::delete:::Project:',response.getError()[0].message);
                var str = cmp.get("v.card");
                str.title = "Error";
                str.message = response.getError()[0].message;
                str.buttonName = "Okay";
                cmp.set("v.card", str);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleRecordUpdated: function(component, event, helper) {
       
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.",JSON.stringify(component.get("v.simpleRecord")));
            component.set("v.oppId",component.get("v.simpleRecord").AcctSeed__Opportunity__c);
            helper.attachementCall(component);
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