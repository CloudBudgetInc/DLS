({
    doinit: function(component, event, helper) {
        
        //set community name
        var communityName = window.location.pathname.split('/s/')[0].split('/')[1];
        component.set("v.communityName",communityName);
        component.set("v.showSpinner",true);
        
        var device = $A.get("$Browser.formFactor");
        if (device == 'PHONE') {
            component.set("v.displayDevice",'Mobile');
        } else {
            component.set("v.displayDevice",'PC');
        }
        
        var urlString = window.location.href;
        var action = component.get("c.getProjectRecord");
        action.setParams({'projectId' : urlString.split("=")[1]});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                let res = response.getReturnValue();
                console.log('::::::res::::',res);
                component.set("v.showSpinner",false);
                if(res){
                    component.set("v.projectRec",JSON.parse(res));
                    
                    if(communityName == 'student' || communityName == 'client'){                        
                        helper.getPolicies(component, event, helper);
                    }
                }
            }else if(state == 'ERROR'){
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                component.set("v.showSpinner",false);
                // Display the message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },    
    handleCommunityCmpVisibilitiesChange: function(cmp){
        let communityCmpVisibilities = cmp.get('v.communityCmpVisibilities'),
        	 projCmpVisibility = communityCmpVisibilities.My_Projects;
        console.log('projCmpVisibility::>',projCmpVisibility);
        cmp.set('v.projCmpVisibility', projCmpVisibility);
    },
    back : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/projects"
        });
        urlEvent.fire();
    },
    authorizeVRDevice : function(cmp,event, helper){
        cmp.set("v.showSpinner",true);
        var action = cmp.get("c.payloadConstructionMethod");
        action.setParams({
            "dlsClass" : cmp.get("v.projectRec").dlsClass,
            "projectId" : cmp.get("v.projectRec").projectId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                let result = response.getReturnValue();
                cmp.set("v.showSpinner",false);
                //console.log('::::::::result:::::',result);
                window.open('yarrow://'+result,'_blank');
            }else if(state == 'ERROR'){
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                  cmp.set("v.showSpinner",false);
                // Display the message
             	var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    previewPolicy: function(component, event, helper){
        var boxUrl = event.currentTarget.dataset.boxlink.split("/s/"),
            boxId = boxUrl.length > 1 ? boxUrl[1] : undefined;
        console.log(boxUrl);
        console.log(boxId);
        if(boxId){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                url: "/file-preview?linkId=" + boxId
            });
            urlEvent.fire(); 
        }
    }
})