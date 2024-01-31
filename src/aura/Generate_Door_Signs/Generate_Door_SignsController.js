({
    doinit : function(cmp, event, helper) {
        var action = cmp.get("c.generateDoorSigns");
        var idRec = cmp.get("v.recordId");
        
        action.setParams({
            recId : idRec,
            queryName : 'Language Query for Door Signs,Schedule Query for Project Cover Letter',
            tempName : 'Door Signs for Project'
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state == "SUCCESS") {
                var returnValue = response.getReturnValue();
                var serverUrlSessionId = JSON.parse(returnValue.congaWrap.sessionIdServerURL);
                
                var url = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                    	  "&serverUrl="+serverUrlSessionId["serverUrl"]+"&id="+idRec+"&DS7=13&templateId="+
                   		  returnValue.congaWrap.tempNameIdMap["Door Signs for Project"]+"&queryId=[Lang]"+
                   		  returnValue.congaWrap.queryNameIdMap["Language Query for Door Signs"];
                
                if(returnValue.langId) {
                    url += "?pv0="+returnValue.langId;
                }
                
                for(var i = 0; i < returnValue.scheList.length; i++) {
                    if(i == 0){ 
                    	url += ",[SCH"+i+"]"+returnValue.congaWrap.queryNameIdMap["Schedule Query for Project Cover Letter"]+"?pv0="+returnValue.scheList[i].Id;
                    } else if((returnValue.scheList[i-1].Room__c == returnValue.scheList[i].Room__c) && (returnValue.scheList[i-1].Instructor__c == returnValue.scheList[i].Instructor__c)) {
                        url += ",[SCH"+i+"]"+returnValue.congaWrap.queryNameIdMap["Schedule Query for Project Cover Letter"]+"?pv0="+returnValue.scheList[i].Id; 
                    }  
                }
               
                /*var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": url
                });
                urlEvent.fire();*/
                window.open(url,'_self');
                $A.get("e.force:closeQuickAction").fire(); 
                
            } else {
                
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