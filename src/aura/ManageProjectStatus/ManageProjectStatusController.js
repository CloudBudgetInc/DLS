({
    proceedBtnClick : function(cmp, event, helper){
        var proStatusInput = cmp.find("proStatusInput");
        var isValidInputs = true;
        var url = null;

        //get community name
        var communityName = window.location.pathname.split('/s/')[0].split('/')[1];

        if(!proStatusInput.get("v.value")) {
            $A.util.addClass(proStatusInput, 'slds-has-error'); 
            isValidInputs = false;
        } else {
            $A.util.removeClass(proStatusInput, 'slds-has-error');
        }
        
        if(isValidInputs){
            var status = cmp.get("v.selectedStatus");
            if(status == 'Ended'){
                
                if(communityName == 'lightning'){
                    url = '/apex/Manage_Project_Dates?Id='+cmp.get("v.recordId")+'&SetProjectStatus=Ended&return=ToDetailPage'; 
                }else{
                    url = "/manage-project-dates?recordId="+cmp.get("v.recordId")+'_Ended';
                }
                
                //window.open('/apex/Manage_Project_Dates?Id='+cmp.get("v.recordId")+'&SetProjectStatus=Ended&return=ToDetailPage','_self');
               
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": url
                })
                urlEvent.fire();
                
                $A.get("e.force:closeQuickAction").fire();
            }else if(status == 'On Hold'){
                cmp.set("v.showOnHoldSection",true);
                cmp.set("v.showStatusSelection",false);
            }else if(status == 'Canceled'){
                cmp.set("v.showCancelSection",true);
                cmp.set("v.showStatusSelection",false);
            }else if(status == 'Active'){
                //window.open('/apex/Manage_Project_Dates?Id='+cmp.get("v.recordId"),'_self');

                if(communityName == 'lightning'){
                    url = '/apex/Manage_Project_Dates?Id='+cmp.get("v.recordId")+'&SetProjectStatus=Active&return=ToDetailPage'; 
                }else{
                    url = "/manage-project-dates?recordId="+cmp.get("v.recordId")+'_Active';
                }
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": url
                });
                urlEvent.fire();
                $A.get("e.force:closeQuickAction").fire(); 
            }else if(status == 'Order'){
                helper.projectRecordUpdate(cmp);     
            }
        }
    },
    closeBtnClick : function(cmp, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    onHoldOkayClick : function(cmp, event, helper){
        var dtCmp = cmp.find("dtVal");
        var isValid = true;        
        if(!dtCmp.get("v.value")){
            dtCmp.set("v.errors", [{message:" "}]);
            isValid = false;
        }else {
            dtCmp.set("v.errors", null);
        }
        
        if(isValid){
        	helper.projectRecordUpdate(cmp);
        }
    },
    closeOnHoldSection : function(cmp, event, helper){
        cmp.set("v.onHoldDt","");
        cmp.set("v.showOnHoldSection",false);
        cmp.set("v.showStatusSelection",true);
    },
    cancelOkayClick : function(cmp, event, helper){
        var dtCmp = cmp.find("cancelDt");
        var isValid = true;        
        if(!dtCmp.get("v.value")){
            dtCmp.set("v.errors", [{message:" "}]);
            isValid = false;
        }else {
            dtCmp.set("v.errors", null);
        }
        
        var reasoncmp = cmp.find("cancelReason");
        if(!reasoncmp.get("v.value")){
            $A.util.addClass(reasoncmp,"slds-has-error");
            isValid = false;
        }else {
            $A.util.removeClass(reasoncmp,"slds-has-error");
        }
        
        if(isValid){
        	helper.projectRecordUpdate(cmp);
        }
    },
    closeCancelSection : function(cmp, event, helper){
        cmp.set("v.cancelledDt","");
        cmp.set("v.cancellationReason","");
        cmp.set("v.showCancelSection",false);
        cmp.set("v.showStatusSelection",true);
    },
    closeToast : function(cmp, event, helper) {
        $A.util.toggleClass(cmp.find("toast"),'slds-hide');
    },
    goToSObjPage : function(cmp, event, helper){
        var rowId = event.currentTarget.name;
        var communityName = window.location.pathname.split('/s/')[0].split('/')[1];

        if(rowId){
            var sObjectEvent = $A.get("e.force:navigateToSObject");
            var url = null;
            
            if(communityName == 'lightning'){
                url = '/lightning/r/'+rowId+'/view';
            }else{
                url = '/s/'+rowId;
            }        
            
            sObjectEvent .setParams({
                "recordId": window.open(url), 
                "slideDevName": "detail"
            });
            sObjectEvent.fire(); 
        }
    },
    statusChange : function(cmp, event, helper){
        var status = cmp.get("v.selectedStatus");
        
        if(status == 'Order'){
            helper.getInctiveCostRateRelatedCAs(cmp); 
        }
    }
})