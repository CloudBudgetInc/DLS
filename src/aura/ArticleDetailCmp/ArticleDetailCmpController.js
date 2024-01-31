({
	doInit : function(cmp, event, helper) {
		helper.getInitialResponse(cmp,event,helper);
	},
    handleLikeResponse : function(component,event,helper){
        helper.updateResponse(component,event,helper,'Like');
    },
    handleDisLikeResponse : function(component,event,helper){
        helper.updateResponse(component,event,helper,'DisLike');
    }
})