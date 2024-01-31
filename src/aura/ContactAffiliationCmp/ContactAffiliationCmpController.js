({
    statusChange : function(cmp, event, helper) {
        var selectedStatus = cmp.get("v.selectedStatus");
        var contactAffilationList = JSON.parse(cmp.get("v.contactAffilationJSON"));
        var cAStatusUpdatedList = [];
        
        cmp.set("v.isShowStatusColumn",true);
        if(selectedStatus == 'All'){
            cAStatusUpdatedList = contactAffilationList;
        }else {
            for( var i = 0 ; i < contactAffilationList.length ;i++){
                if(contactAffilationList[i].Status__c == selectedStatus){
                    cAStatusUpdatedList.push(contactAffilationList[i]);
                }
            }
            cmp.set("v.isShowStatusColumn",false);
        }
        cmp.set("v.contactAffilationList",cAStatusUpdatedList);
    },
    createCABtn : function(cmp, event, helper) {
        cmp.set("v.actionPerform",'Create');
        cmp.set("v.showSpinner",true);
        cmp.set("v.visibleError",'slds-hide');
        cmp.set("v.cARecord",{});
        cmp.set("v.selectedCAId",'');
        helper.checkContactAffilationRecAccess(cmp, event, helper);
    },
    tableEditActionClk : function(cmp, event, helper) {
        var rectarget = event.currentTarget;
        var rowId = rectarget.getAttribute("data-name");
        var contactAffilationList = cmp.get("v.contactAffilationList");
        
        cmp.set("v.actionPerform",'Edit');
        cmp.set("v.showSpinner",true);
        cmp.set("v.selectedCAId",rowId);
        cmp.set("v.visibleError",'slds-hide');
        helper.checkContactAffilationRecAccess(cmp, event, helper);
    },
    tableDeleteActionClk : function(cmp, event, helper) {
        var rectarget = event.currentTarget;
        var rowId = rectarget.getAttribute("data-name");
        var contactAffilationList = cmp.get("v.contactAffilationList");
        
        cmp.set("v.actionPerform",'Delete');
        cmp.set("v.showSpinner",true);
        cmp.set("v.selectedCAId",rowId);
        helper.checkContactAffilationRecAccess(cmp, event, helper, 'Delete');
    },
    caDeleteCancelBtn : function(cmp, event, helper) {
        cmp.set("v.selectedCAId",'');
        cmp.set("v.showDeleteModal",false);
    },
    caDeleteBtn : function(cmp, event, helper) {
        var selectedCAId = cmp.get("v.selectedCAId");
        
        if(selectedCAId){
            cmp.set("v.showDeleteModal",false);
            cmp.set("v.showSpinner",true);
            helper.deleteActionForAllTab(cmp,event,helper);
        }
    },
    addEditCancelBtn : function(cmp, event, helper) {
        cmp.set("v.showAddEditModal",false);
        cmp.set("v.selectedCAId",'');
        cmp.set("v.visibleError",'slds-hide');
        cmp.set("v.cARecord",{});
    },
    addEditSaveBtn : function(cmp, event, helper) {
        var isValid = helper.validationToAddEditCA(cmp);
        
        if(isValid){
            cmp.set("v.showSpinner",true);
            helper.upsertConAffilationRecord(cmp);
        }else{
            cmp.set("v.showSpinner",false);
        }
    },
    permissionOkBtn : function(cmp, event, helper) {
        cmp.set("v.showPermissionAccessModal",false);
    },
    tableViewActionClk :function(cmp, event, helper) {
        var rectarget = event.currentTarget;
        var rowId = rectarget.getAttribute("data-name");
        
        var conAfillEvent = $A.get("e.force:navigateToSObject");
        conAfillEvent .setParams({
            "recordId": window.open('/'+rowId), 
            "slideDevName": "detail"
            
        });
        conAfillEvent.fire(); 
    }
})