({
    
    getContactRec : function(cmp, event, helper){
        cmp.set("v.showSpinner", true);
        var self = this;
        console.log('in serveer init');
        const server = cmp.find('server');
        const action = cmp.get('c.getProfileInformation');
        server.callServer(
            action, {},
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner", false);
                var result = JSON.parse(response);
                console.log('success', result);
                cmp.set('v.dummyContactRec',JSON.parse(JSON.stringify(result)));
                cmp.set('v.profileInfo',result);
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner", true);
                console.log('Errors::', errors);
            }),
            false,
            false,
            false
        );
    },
    
    updateContact: function(cmp, event, helper) {
        cmp.set("v.showSpinner", true);
        const server = cmp.find('server');
        var profileInfo = cmp.get("v.profileInfo");
        
        if(profileInfo.timeApprovalPreference){
            const action = cmp.get('c.updateContactRecord');
            var param = {};
            param.contactRecord = JSON.stringify(profileInfo);
            server.callServer(
                action,
                param,
                false,
                $A.getCallback(function(response) {
                    console.log('Contact saved', JSON.stringify(response));
                    helper.showToast(cmp, event, helper, 'success', '', 'Contact Information updated successfully', 'sticky');
                    cmp.set("v.dummyContactRec", JSON.parse(JSON.stringify(cmp.get("v.profileInfo"))));
                    cmp.set('v.viewMode', true);
                    cmp.set("v.showSpinner", false);
                }),
                $A.getCallback(function(errors) {
                    cmp.set("v.showSpinner", false);
                    var errmsg;
                    
                    if(errors.length > 0) {
                        if(errors[0]['message']) {
                            errmsg = errors[0].message;
                        }else if(errors[0]['pageErrors'] && errors[0].pageErrors.length > 0 && errors[0].pageErrors[0].message){
                            errmsg = errors[0].pageErrors[0].message;
                        }else if(errors[0]['fieldErrors'] && errors[0].fieldErrors['Email'] && errors[0].fieldErrors.Email[0].message) {
                            errmsg =  errors[0].fieldErrors.Email[0].message;
                        }
                        helper.showToast(cmp,event, helper,'Error', 'Error found', errmsg, null);
                    }
                    console.log('Errors::', errors);
                }),
                false,
                false,
                false
            );
        }else{
            cmp.set("v.showSpinner", false);
            cmp.set('v.viewMode', true);
            cmp.set('v.profileInfo',JSON.parse(JSON.stringify(cmp.get("v.dummyContactRec"))));
        }
    },
    
    showToast: function(cmp, event, helper, type, title, message, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: mode,
            message: message,
            title: title,
            type: type
        });
        toastEvent.fire();
    },
})