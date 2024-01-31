({
    checkContactAffilationRecAccess : function(cmp ,event ,helper) {

        var actionPerform = cmp.get("v.actionPerform");
        var self = this;
        const server = cmp.find('server');
        var action = cmp.get("c.contactAffilationRecAccess");
        server.callServer(
            action, {
                'actionPerform' : actionPerform
            },
            false,
            $A.getCallback(function(response) {
                if(response){
                    if(actionPerform == 'Edit' || actionPerform == 'Create'){
                        self.cAAddEditRelInfo(cmp,event,helper);
                    }else if(actionPerform == 'Delete'){
                        cmp.set("v.showDeleteModal",true);
                        cmp.find("caDeleteModal").openModal();
                        cmp.set("v.showSpinner",false);
                    }
                }else{
                    cmp.set("v.showSpinner",false);
                    cmp.set("v.showPermissionAccessModal",true);
                    cmp.find("permissionModal").openModal();
                }
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,helper,errors[0].message,'info_alt','error','pester','');
            }),
            false,
            false,
            false
        );
    },
    deleteActionForAllTab : function(cmp ,event ,helper) {
        var  actionPerform = cmp.get("v.actionPerform");
        var self = this;
        const server = cmp.find('server');
        var action = cmp.get("c.deleteConAffilationRec");
        server.callServer(
            action, {
                'conAffilId' : cmp.get("v.selectedCAId")
            },
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.selectedCAId",'');

                self.showToast(cmp,event,helper,('Contact Affiliation was '+ actionPerform +'d'),'','success','','Success');
                var appEvent = $A.get("e.c:reloadEvent");
                appEvent.fire();
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,helper,errors[0].message,'info_alt','error','pester','');
            }),
            false,
            false,
            false
        );
    },
    cAAddEditRelInfo : function(cmp ,event ,helper) {
        var self = this;
        const server = cmp.find('server');
        var action = cmp.get("c.getConAffilAddEditInformation");
        server.callServer(
            action, {
                'cAId' : cmp.get("v.selectedCAId"),
                'recordTypeName' : cmp.get("v.recordTypeName"),
                'parentObjName' : cmp.get("v.parentObjName"),
                'parentId' : cmp.get("v.parentId")
            },
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                console.log(response);
                var cARecord = response.cARecord;
                var cAId = cmp.get("v.selectedCAId");
                
                if(response.positionValues){
                    var positionValues = JSON.parse(response.positionValues);
                    if(positionValues.length > 0){
                        cmp.set("v.positionValues",positionValues); 
                    }
                }
                if(response.statusValues){
                    var statusValues = JSON.parse(response.statusValues);
                    
                    if(statusValues.length > 0){
                        statusValues.unshift({'label' : '--None--',value : ''});
                        if(!cAId){
                            cARecord.Status__c = '';  
                        }
                        cmp.set("v.statusValues",statusValues); 
                    }
                }
                
                cmp.set("v.cARecord",cARecord);
                cmp.set("v.showAddEditModal",true);
                cmp.find("caAddEditModal").openModal();               
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,helper,errors[0].message,'info_alt','error','pester','');
            }),
            false,
            false,
            false
        );
        
    },
    validationToAddEditCA : function(cmp) {
        var dateInputField = cmp.find("dateInputField");
        var otherInputField = cmp.find("otherInputField");
        var cARecord = cmp.get("v.cARecord");
        var isValid = true;
        
        if(Array.isArray(dateInputField)){ 
            
            var fromDate = new Date(dateInputField[0].get("v.value")) || null;
            var toDate = new Date(dateInputField[1].get("v.value")) || null;
            
            if(!fromDate.getTime()){
                cARecord.Start_Date__c = null;
            }
            if(!toDate.getTime()){
                cARecord.End_Date__c = null;
            }
            
            if(fromDate.getTime() && toDate.getTime()){
                
                if(fromDate.getTime() >= toDate.getTime()){
                    isValid = false;
                    dateInputField[1].set("v.errors", [{message:" End date must be greater than Start date "}]);
                }else{
                    dateInputField[1].set("v.errors", null);
                }
                
            }else if((!fromDate.getTime()) && toDate.getTime()){
                isValid = false;
                dateInputField[1].set("v.errors", [{message:" End date must be greater than Start date "}]);
            }else{
                dateInputField[1].set("v.errors", null);
            }
            cmp.set("v.cARecord",cARecord);
        }
        
        if(Array.isArray(otherInputField)){ 
            for(var i = 0;i < otherInputField.length;i++){
               
                if(!otherInputField[i].get("v.value") || otherInputField[i].get("v.value") == '') {
                    $A.util.addClass(otherInputField[i], 'slds-has-error'); 
                    isValid = false;
                }else {   
                    $A.util.removeClass(otherInputField[i], 'slds-has-error');
                }
                
            }
        }
        
        return isValid;
    },
    upsertConAffilationRecord :  function(cmp , event , helper) {
        var cARecord = cmp.get("v.cARecord");
        var cAArray = [];
        var  actionPerform = cmp.get("v.actionPerform");
        cAArray.push(cARecord);
        console.log(cAArray);

        var self = this;
        const server = cmp.find('server');
        var action = cmp.get("c.upsertCARecord");
        server.callServer(
            action, {
                'cARecordJSON' : JSON.stringify(cAArray)
            },
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.showAddEditModal",false);
                
                self.showToast(cmp,event,helper,('Contact Affiliation was '+ actionPerform + (actionPerform == 'Edit' ?'ed':'d')),'','success','pester','Success');
                
                var appEvent = $A.get("e.c:reloadEvent");
                appEvent.fire();
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.showErrorMsg",errors[0].message);            
                cmp.set("v.visibleError",'slds-show');
            }),
            false,
            false,
            false
        );
    },
     showToast: function(cmp, event, helper, message, key,type, mode, title) {
         var toastEvent = $A.get("e.force:showToast");
         toastEvent.setParams({
             message : message,
             key : key,
             type : type,
             mode : mode,
             title : title
         });
         toastEvent.fire();
     }
})