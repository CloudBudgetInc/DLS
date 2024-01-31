({
	 getOpenCompletedToDoItemsInfo : function(cmp,event,helper) {
        cmp.set("v.showSpinner",true);
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getOpenCompletedToDoItems');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('response:::',response);
                cmp.set("v.showSpinner",false);
                cmp.set("v.openCompletedToDoItems",response);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
})