({
	doInit : function(component, event, helper) {
        
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            component.set("v.displayDevice",'Mobile');
        } else {
            component.set("v.displayDevice",'PC');
        }        
    },
    handleCommunityCmpVisibilitiesChange: function(cmp){
        let communityCmpVisibilities = cmp.get('v.communityCmpVisibilities'),
        	 homeCmpVisibility = communityCmpVisibilities.Home;
        console.log('homeCmpVisibility::>',homeCmpVisibility);
        cmp.set('v.homeCmpVisibility', homeCmpVisibility);
    }    
})