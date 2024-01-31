({
    createAccount : function(cmp, event) {
        
        cmp.set("v.showSpinner",true);
        const server = cmp.find('server');
        var action = cmp.get("c.createAccount");
        var self = this;
        
        server.callServer(
            action, {contactId : cmp.get("v.recordId")},
            false,
            $A.getCallback(function(response) {
                console.log('Response::::',response);
                if(response) {
                    if(response == 'Invalid RecordType') {
                        cmp.set("v.showSpinner",false);
                        self.showToast(cmp,event,'error','','You can only create account for DLS Employee and Candidate record type','pester','info_alt');
                    }else if(response.includes('~')) {
                        var accountId = response.split('~')[1];
                        self.showToast(cmp,event,'success','','This Contact already have account with id '+accountId,'dismissible','info_alt');
                        self.redirectToRecord(cmp, event, accountId);
                        
                    }else {
                        self.showToast(cmp,event,'success','','Account record successfully created','dismissible','info_alt');
                        self.redirectToRecord(cmp, event, response);
                    }
                }else {
                    cmp.set("v.showSpinner",false);
                }             
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,'error','',errors[0].message,'pester','info_alt');
                window.setTimeout($A.getCallback(function(){
                    $A.get("e.force:closeQuickAction").fire();
                }),3000); 
                
            }),
            false,
            false,
            false
        );
    },
    
    showToast: function(component, event, type, title, message, mode,key) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            key: key,
            title: title,
            type: type,
            mode: mode
        });
        toastEvent.fire();
    },
    
    redirectToRecord : function(cmp, event, recordId){
        window.setTimeout(
            $A.getCallback(function() {
                 cmp.set("v.showSpinner",false);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": recordId,
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }), 5000);    
    }
})