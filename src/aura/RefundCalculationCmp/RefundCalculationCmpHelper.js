({ 
    getRefundCalculationInfoHelper : function(cmp, event, helper) {
        var self = this;
        cmp.set("v.showSpinner",true);
        const server = cmp.find('server');
        var action = cmp.get("c.getRefundCalculationInfo");
        server.callServer(
            action, {proRecId : cmp.get("v.recordId")},
            false,
            $A.getCallback(function(response) {
                console.log(response);
                var returnValue = response;
                if(returnValue.errorMsg){
                    cmp.set("v.card",{'title' : 'Warning', 'message' : returnValue.errorMsg});
                    cmp.set("v.showErrorMsg",true);   
                    cmp.set("v.showSpinner",false);
                }else{
                    cmp.set("v.isLoad",true);
                    cmp.set("v.showSpinner",false);
                    var serverUrlSessionId = JSON.parse(returnValue.sessionIdServerURL);
                    var url = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                        "&serverUrl="+serverUrlSessionId["serverUrl"] + returnValue.congaURL;
                    cmp.set("v.congaUrl",url);
                }
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.showErrorMsg",true);
                cmp.set("v.card",{'title' : 'Error', 'message' : errors[0].message});
            }),
            false,
            false,
            false
        );
    }
})