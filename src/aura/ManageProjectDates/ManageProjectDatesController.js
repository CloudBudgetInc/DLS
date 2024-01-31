({
        doinit : function(cmp, event, helper) {
            
            var action = cmp.get("c.isProjectExist");
            var recId = cmp.get("v.recordId");
            var communityName = window.location.pathname.split('/s/')[0].split('/')[1];
            
            action.setParams({
                oppId  : recId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var returnValue = response.getReturnValue();                
                
                if(state == "SUCCESS") {
                    var retId = '';
                    
                    if(returnValue == "No") {
                        retId = recId;
                    } else {
                        retId = returnValue;
                    }
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": (communityName == 'lightning') ? "/apex/Manage_Project_Dates?Id="+retId+'&return=ToDetailPage' : "/manage-project-dates?recordId="+retId
                    });
                    
                    urlEvent.fire();
                    $A.get("e.force:closeQuickAction").fire(); 
                    
                } else {
                    console.log(":::ManageProjectDates init Error:::", response.getError());
                    var str = cmp.get("v.card");
                    str.title = "Error";
                    str.message = response.getError()[0].message;
                    str.buttonName = "Okay";
                    str.showErrorMsg = true;
                    
                    cmp.set("v.card", str);
                }
            });
            $A.enqueueAction(action);
        },
        
        closeAction : function(cmp, event, helper) {
            $A.get("e.force:closeQuickAction").fire(); 
        }
    })