({
	attachementCall : function(cmp){
        var action =  cmp.get("c.alertForNotesAttachments");
        action.setParams({
            'projectId' : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                if(result != 'No records'){
                    cmp.set("v.infoMessage",result);
                }else {
                    var msg = 'Project and related child object records will be deleted. Once the action is complete, it will be redirected to related Opportunity. Please confirm.';
                    cmp.set("v.infoMessage",msg);
                }
            }else {
                console.log('::::error:notes:attachment:',response.getError()[0].message);
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