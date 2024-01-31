({
	closeAction : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    },
    
    okAction : function(cmp, event, helper) {
        
        var recId = cmp.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        
        urlEvent.setParams({
            "url": "/lead/leadconvert.jsp?retURL="+recId+"&id="+recId
        });
        urlEvent.fire();
		
        $A.get("e.force:closeQuickAction").fire();
    }
})