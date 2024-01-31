({
    createMissedTimeLog : function(cmp, event, helper) {
      
        var action =  cmp.get("c.TimelogToTCDConversion");
        action.setParams({
            OppId : cmp.get("v.oppId"), 
            projectId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state == 'SUCCESS'){
                var str = cmp.get("v.card");
                str.title = "Information";
                str.message = "Batch process initiated successfully. You will receive an email sortly";
                str.buttonName = "Okay";
                cmp.set("v.card", str);
                
            }else {
                console.log('::::createMissedTime:helper error:::',response.getError());
                var str = cmp.get("v.card");
                str.title = "Error";
                str.message = response.getError()[0].message;
                str.buttonName = "Okay";
                cmp.set("v.card", str);
            }
        });
        $A.enqueueAction(action);
    }
})