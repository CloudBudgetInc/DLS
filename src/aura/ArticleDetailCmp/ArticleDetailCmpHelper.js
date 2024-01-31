({
	getInitialResponse : function(cmp,event,helper) {
		const server = cmp.find('server');
        const action = cmp.get('c.getVotesForArticle');
        console.log(cmp.get("v.recordId"))
        var self = this;
        server.callServer(
            action, 
            {articleId : cmp.get("v.recordId")}, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
				cmp.set("v.votesInfo",result);
            }),
            $A.getCallback(function(errors) { 
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
	},
    showToast : function(cmp,event,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            type: type,
            mode: 'sticky'
        });
        toastEvent.fire();
    },
    updateResponse : function(cmp,event,helper,response){
		const server = cmp.find('server');
        const action = cmp.get('c.updateArticle');
        console.log('::::::recordId:::',cmp.get("v.recordId"));
        console.log('::::::response:::',response);
        
        var self = this;
        server.callServer(
            action, 
            {articleId : cmp.get("v.recordId"),
             response : response}, 
            false, 
            $A.getCallback(function(response) { 
                self.getInitialResponse(cmp,event,helper);
            }),
            $A.getCallback(function(errors) { 
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
	}
})