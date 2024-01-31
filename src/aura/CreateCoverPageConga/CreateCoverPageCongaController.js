({
    doinit : function(cmp, event, helper) {
        
        var action = cmp.get("c.createCoverPageConga");
        var idRec = cmp.get("v.recordId");

        action.setParams({
            recId : idRec,
            queryName : 'Room Query For Cover Letter,Schedule Query for Project Cover Letter',
            tempName : 'Cover Page,Cover Page for Project'
        });
        
        action.setCallback(this, function(response) {
            var status = response.getState(); 
            
            if(status == "SUCCESS") {
                var returnvalue = response.getReturnValue();
                var serverUrlSessionId = JSON.parse(returnvalue.congaWrap.sessionIdServerURL);
                var url = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                          "&serverUrl="+serverUrlSessionId["serverUrl"]+"&id="+idRec+"&DS7=13&templateId=";
               
                if(returnvalue.parentType == 'Opportunity') {
                    url += returnvalue.congaWrap.tempNameIdMap["Cover Page"];
                } else if(returnvalue.parentType == 'AcctSeed__Project__c') {
                    url += returnvalue.congaWrap.tempNameIdMap["Cover Page for Project"];
                }
                
                url += "&queryId=[Room]"+returnvalue.congaWrap.queryNameIdMap["Room Query For Cover Letter"];
               
                if(returnvalue.roomId) {
                    url += "?pv0="+returnvalue.congaWrap.roomId;
                } 
                
                if(returnvalue.scheList.length > 0 && returnvalue.parentType == 'AcctSeed__Project__c') {
                    for(var i = 0; i < returnvalue.scheList.length; i++) {
                        url +=",[SCH"+i+"]"+returnvalue.congaWrap.queryNameIdMap["Schedule Query for Project Cover Letter"]+
                            "?pv0="+returnvalue.scheList[i].Id;
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