({
	doInit : function(cmp, event, helper) {
		var url = $A.get('$Resource.CommunityHeader');
        cmp.set('v.backgroundImageURL', url);
        console.log('cc',cmp.get("v.navBar"));        
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getCommunityName');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('response:::',response);
                cmp.set("v.communityName",response);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                helper.showToast(cmp,event, helper,'Error', 'Error found', errors[0].message, null);
            }),
            false, 
            false,
            false
        );
	},
    redirectToHome : function(cmp, event, helper){
        window.location.href = '/'+cmp.get("v.communityName")+'/s/';
    }
})