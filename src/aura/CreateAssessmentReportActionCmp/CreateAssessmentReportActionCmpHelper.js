({
    getReportTypes : function(cmp, event, helper) {
        var self = this;
        cmp.set("v.showSpinner",true);
        const server = cmp.find('server');
        var action = cmp.get("c.getPRTestReportTypes");
        server.callServer(
            action, {projId: cmp.get("v.recordId")},
            false,
            $A.getCallback(function(response) {
                console.log(response);
                var result = JSON.parse(response);
                
                if(result  && (result).length > 0){
                    cmp.set("v.reportTypes",result);
                }
                cmp.set("v.showSpinner",false);
                cmp.set("v.card",{'title' : 'Create Training Report', 'message' : '', 'showCloseBtn' : false});
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.card",{'title' : 'Error', 'message' : errors[0].message, 'showCloseBtn' : true,showMsg:true});
            }),
            false,
            false,
            false
        );
    }
})