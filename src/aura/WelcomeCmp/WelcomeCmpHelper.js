({
    getCurrentCommunityName : function(cmp, event, helper){
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getCommunityName');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                let welcomeMsg = '';
                if(response == 'instructor'){
                	welcomeMsg = 'This is a place to manage everything related to your classes. Enter your time, manage your schedules, and access resources for language learning.'
                }else if(response == 'student'){
                    welcomeMsg = 'This is a place to manage everything related to your classes. Approve your class time, manage your schedules, and access resources for language learning.';
                }else if(response == 'client'){
					welcomeMsg = 'This is the platform for language training program management at DLS. View class information, online meeting links, and access the LMS.';           
                }
                cmp.set("v.community",response);
                cmp.set('v.welcomeMsg', welcomeMsg);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                self.showToast(cmp,event, helper,'Error', 'Error found', errors[0].message, null);
            }),
            false, 
            false,
            false
        );
    },
    showToast: function(component, event, helper, type, title, message, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            
            message: message,
            title: title,
            type: type
        });
        toastEvent.fire();
    }
})