({
	doInit : function(component, event, helper) {
        var url = $A.get('$Resource.CommunityHeader');
        component.set('v.backgroundImageURL', url);
    }
})