({
	showToast : function(cmp,event,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            type: type,
            mode: 'sticky'
        });
        toastEvent.fire();
    }
})