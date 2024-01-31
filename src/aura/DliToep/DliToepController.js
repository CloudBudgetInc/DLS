({
    doinit : function(cmp, event, helper) {
        var action = cmp.get("c.dliToep");
        var idRec = cmp.get("v.recordId");
        
        console.log(':::***:::Enter:**::');
        
        action.setParams({
            recId : idRec,
            queryName : 'DLI TOEP OPLI Sum,DLI TOEP Contact Query,DLI TOEP Work Experience Query',
            tempName : 'DLI TOEP'
        });
        
        console.log(':::***:::Enter::1::');
        action.setCallback(this, function(response) {
            var status = response.getState();
            
            if(status == "SUCCESS") {
                var returnValue = response.getReturnValue();
                var serverUrlSessionId = JSON.parse(returnValue.congaWrap.sessionIdServerURL);
                var url = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                          "&serverUrl="+serverUrlSessionId["serverUrl"]+"&id="+idRec+"&DS7=3&templateId="+
                    	  returnValue.congaWrap.tempNameIdMap["DLI TOEP"]+"&queryId=[OPLI]"+
                    	  returnValue.congaWrap.queryNameIdMap["DLI TOEP OPLI Sum"]+"?pv0="+idRec;
                
                for(var i = 0; i < returnValue.conAssignList.length; i++) {
                    url += ",[Instr"+i+"]"+returnValue.congaWrap.queryNameIdMap["DLI TOEP Contact Query"]+
                           "?pv0="+returnValue.conAssignList[i].Candidate_Name__c+"~pv1=";
                    if(returnValue.langId) {
                    	url += returnValue.langId;
                    }
                    url += ",[WorkExp"+i+"]"+returnValue.congaWrap.queryNameIdMap["DLI TOEP Work Experience Query"]+
                           "?pv0="+returnValue.conAssignList[i].Candidate_Name__c+"~pv1=Professional_Work_Experience";
                }
                
                console.log(':::***:::URL:::',url);
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": url
                });
                urlEvent.fire();
                $A.get("e.force:closeQuickAction").fire(); 
                    
            } else {
                console.log(":::DliToep init Error:::",response.getError());
                var str = cmp.get("v.card");
                str.title = "Error";
                str.message = response.getError()[0].message;
                str.buttonName = "Okay";
                
                cmp.set("v.card", str);
            }
        });
        $A.enqueueAction(action);
    },
    
    closeAction : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    }
})