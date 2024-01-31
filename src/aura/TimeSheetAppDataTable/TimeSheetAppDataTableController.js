({
    init: function (cmp, event, helper) {
        var actions = helper.getRowActions.bind(this, cmp); 

        cmp.set('v.columns', [
            { label: 'Work Item', fieldName: 'Work_Item_Link__c', type: 'url', sortable: true,
              typeAttributes: {label: { fieldName: 'Work_Item_Name__c' }}},
            { label: 'Actual Hrs', fieldName: 'Hours_Manual__c', type: 'number', sortable: true,
              cellAttributes: { alignment: 'left' }},
            { label: 'Date Completed', fieldName: 'Date_of_Work__c', type: 'date-local', sortable: true},
            { label: 'Description', fieldName: 'Description__c', type: 'text', sortable: true },
            { type: 'action', typeAttributes: { rowActions: actions } }
        ]);
        
        console.log('Data table init');
        helper.fetchData(cmp, event, helper);
    },

    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'edit':
                console.log('Edit the record');
                helper.editRecord(cmp, row);
                break;
            case 'delete':
                console.log('Delete the record');
                helper.deleteRecord(cmp, row);
                break;
        }
    },
    handleUpdateDataTable: function (cmp, event, helper) {
        console.log('update data table event received');
        var actions = helper.getRowActions.bind(this, cmp);
        cmp.set("v.timePeriod", event.getParam('timePeriod'));
        helper.fetchData(cmp, event, helper);
    },
    saveEditModal : function(cmp, event, helper) {
        helper.saveModal(cmp,event, helper);
       },
    
    closeEditModal: function(cmp, event, helper) {
        var cmpTarget = cmp.find('editDialog');
        var cmpBack = cmp.find('dialogBack');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open'); 
     
    },
    updateColumnSorting: function(cmp, event, helper) {
        console.log('Change column sorting');
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        console.log('sorting variables: ' + fieldName + ' is being sorted ' + sortDirection);
        // assign the latest attribute with the sorted column fieldName and sorted direction
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    onPrev : function(cmp, event, helper) {        
        var pageNumber = cmp.get("v.currentPageNumber");
        cmp.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(cmp, helper);
    },
    
    processMe : function(cmp, event, helper) {
        cmp.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(cmp, helper);
    },
    
    onFirst : function(cmp, event, helper) {   
        console.log('onFirst');
        cmp.set("v.currentPageNumber", 1);
        helper.buildData(cmp, helper);
    },
    
    onLast : function(cmp, event, helper) {        
        cmp.set("v.currentPageNumber", cmp.get("v.totalPages"));
        helper.buildData(cmp, helper);
    },
    
    onNext : function(cmp, event, helper){
        var pageNumber = cmp.get("v.currentPageNumber");
        cmp.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(cmp, helper);
    },
    hoursValidation : function(cmp, event, helper){
        var data = cmp.get("v.EditTimeItem");
        var hour = (data.Hours_Manual__c * 100) % 100;
        var errMsg = '';
        if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
            console.log('invalid format');
            errMsg  = 'Allowed decimal values are 00, 25, 50, 75';
        }else {
            console.log('correct format');
            errMsg  = '';
        }
        cmp.set("v.errMsg",errMsg);
    },
    validateDescription : function(cmp, event, helper){
        var data = cmp.get("v.EditTimeItem");
        var description = data.Description__c;
        var cmtDiv = cmp.find("comments");
        if(!description){
            $A.util.addClass(cmtDiv,"slds-has-error");
        }else {
            if(description && description.length > 500){
                cmtDiv.setCustomValidity("Maximum 500 characters allowed");
                $A.util.addClass(cmtDiv,"slds-has-error");
            }else if(description && description.length <= 500){
                cmtDiv.setCustomValidity("");
                $A.util.removeClass(cmtDiv,"slds-has-error");
            }
            cmtDiv.reportValidity();
        }
    },
    calculateLength : function(cmp, event, helper){
        var data = cmp.get("v.EditTimeItem");
        var description = data.Description__c;
        var desDiv = cmp.find('comments');
        if(description && description.length > 500){
            desDiv.setCustomValidity("Maximum 500 characters allowed");
            $A.util.addClass(desDiv,"slds-has-error");
        }else if(description && description.length <= 500){
            desDiv.setCustomValidity("");
            $A.util.removeClass(desDiv,"slds-has-error");
        }
        desDiv.reportValidity();
    }
})