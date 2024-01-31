({
    doinit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        helper.getFilterValues(cmp, event);
        var loanFilterValues = {};
        loanFilterValues.statusValues = [{'label':'All','value':'All'}];
        cmp.set("v.loanFilterValues",loanFilterValues);
        
        var loanFilter = {};
        loanFilter.selectedRecordType = 'All';
        loanFilter.selectedStatus = 'All';
        loanFilter.supervisor = [];
        loanFilter.relatedContact = [];
        loanFilter.selectedLocation = 'All';
        loanFilter.selectedProject = [];
        
        cmp.set("v.loanFilter",loanFilter);
    },
    getStatusValues : function(cmp,event,helper){
        
        cmp.set("v.showSpinner",true);
        if(cmp.get("v.loanFilter").selectedRecordType != 'All' && cmp.get("v.loanFilter").selectedRecordType != 'New Library Purchase'){
            const server = cmp.find('server');
            const action = cmp.get('c.getRecordTypeBased_PicklistValues');
            var param = {};
            param.objectName = 'Materials_Request__c';
            param.fieldName = 'Request_Status__c';
            param.recordTypeId = cmp.get("v.loanFilter").selectedRecordType;
            server.callServer(
                action, 
                param, 
                false, 
                $A.getCallback(function(response) { 
                    var result = JSON.parse(response);
                    console.log('status::Filter::values:::',result);
                    var loanFilterValues = cmp.get("v.loanFilterValues");
                    loanFilterValues.statusValues = result;
                    
                    loanFilterValues.statusValues.unshift({'label':'All','value':'All'});
                    cmp.set("v.loanFilterValues",loanFilterValues);
                    //cmp.set("v.materialRequestRecords",[]);
                    helper.clearTableContents(cmp);
                    cmp.set("v.showSpinner",false);
                }),
                $A.getCallback(function(errors) { 
                    console.log('error',errors);
                    cmp.set("v.showSpinner",false);
                    helper.showToast(cmp,event,'Error',errors[0].message,'error');
                }),
                false, 
                false, 
                false 
            );
        }else {
            cmp.set("v.materialRequestRecords",[]);
            cmp.set("v.showSpinner",false);
        }
        
    },
    clearTable : function(cmp, event, helper){
        console.log('clear table called');
        helper.clearTableContents(cmp);
    },
    supervisorLookupSearch : function(cmp, event, helper){
        // Get the search server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        cmp.find('supervisor').search(serverSearchAction);
        helper.clearTableContents(cmp);
    },
    contactLookupSearch : function(cmp, event, helper){
        // Get the search server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        cmp.find('contact').search(serverSearchAction);
        helper.clearTableContents(cmp);
    },
    searchBtnClick : function(cmp,event,helper){
        cmp.set("v.showSpinner",true);
        helper.getMaterialRequestRecords(cmp,event);
    },
    newLoanBtnClick : function(cmp,event,helper){
        cmp.set("v.isNewLoan",true);
    },
    newOrderBtnClick : function(cmp,event,helper){
        cmp.set("v.isNewRequest",true);
    },
    tabActionClicked: function(cmp, event, helper) {
        console.log('table action');
        var actionId = event.getParam('actionId');
        var row = event.getParam('row');
        console.log('::::::::actionId::::',actionId);
        cmp.set("v.materialRequestRecord",row);
        
        if(row.RecordType.DeveloperName == 'Material_Loan_Request'){
            if(row.Request_Status__c == 'Returned'){
                cmp.set("v.showSaveBtn",false);
            }else {
                cmp.set("v.showSaveBtn",true);
            }
            
            cmp.set("v.showLoanViewMore",true);
            if(Array.isArray(cmp.find("LoanModal"))){
                cmp.find("LoanModal")[0].open();
            }else {
                cmp.find("LoanModal").open();
            }
        }else {
            cmp.set("v.showViewMore",true);
            if(Array.isArray(cmp.find("viewMoreModal"))){
                cmp.find("viewMoreModal")[0].open();
            }else {
                cmp.find("viewMoreModal").open();
            }
        }
    },
    saveLoanDetails : function(cmp, event, helper){
        var statusCmp = cmp.find("loanStatus");
        var loanRec = cmp.get("v.materialRequestRecord");
        
        if(loanRec.Request_Status__c == 'Returned'){
            cmp.set("v.showSpinner",true);
            $A.util.removeClass(statusCmp,"slds-has-error");
            helper.updateLoanRecord(cmp,event);
            
            if(Array.isArray(cmp.find("LoanModal"))){
                cmp.find("LoanModal")[0].close();
            }else {
                cmp.find("LoanModal").close();
            }
            cmp.set("v.showLoanViewMore",false);
        }else {
            $A.util.addClass(statusCmp,"slds-has-error");
        }
    },
    closeLoanViewMore : function(cmp, event, helper){
        if(Array.isArray(cmp.find("LoanModal"))){
            cmp.find("LoanModal")[0].close();
        }else {
            cmp.find("LoanModal").close();
        }
        cmp.set("v.showLoanViewMore",false);
    },
    closeViewMore : function(cmp, event, helper){
        if(Array.isArray(cmp.find("viewMoreModal"))){
            cmp.find("viewMoreModal")[0].close();
        }else {
            cmp.find("viewMoreModal").close();
        }
        cmp.set("v.showViewMore",false);
    },
    openEditRecord : function(cmp,event, helper){
        cmp.set("v.showSpinner",true);
        cmp.set("v.displayEdit",true);
        if(Array.isArray(cmp.find("editModal"))){
            cmp.find("editModal")[0].open();
        }else {
            cmp.find("editModal").open();
        }
        
        if(Array.isArray(cmp.find("viewMoreModal"))){
            cmp.find("viewMoreModal")[0].close();
        }else {
            cmp.find("viewMoreModal").close();
        }
        cmp.set("v.showViewMore",false);
        cmp.set("v.showSpinner",false);
    },
    closeEdit : function(cmp,event, helper){
        
        if(Array.isArray(cmp.find("editModal"))){
            cmp.find("editModal")[0].close();
        }else {
            cmp.find("editModal").close();
        }
        cmp.set("v.displayEdit",false);
    },
    saveEditedRecord : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        cmp.find("edit").get("e.recordSave").fire();
        if(Array.isArray(cmp.find("editModal"))){
            cmp.find("editModal")[0].close();
        }else {
            cmp.find("editModal").close();
        }
        cmp.set("v.displayEdit",false);
    },
    handleSaveSuccess : function(cmp, event, helper){
        helper.getMaterialRequestRecords(cmp);
    },
    openDeleteConfimation : function(cmp, event,helper){
        cmp.set("v.displayDeleteConfirmation",true);
        if(Array.isArray(cmp.find("deleteModal"))){
            cmp.find("deleteModal")[0].open();
        }else {
            cmp.find("deleteModal").open();
        }
        
        //Close view model
        if(Array.isArray(cmp.find("viewMoreModal"))){
            cmp.find("viewMoreModal")[0].close();
        }else {
            cmp.find("viewMoreModal").close();
        }
        cmp.set("v.showViewMore",false);
    },
    deleteOkClick : function(cmp,event,helper){
        cmp.set("v.showSpinner",true);
        if(Array.isArray(cmp.find("deleteModal"))){
            cmp.find("deleteModal")[0].close();
        }else {
            cmp.find("deleteModal").close();
        }
        cmp.set("v.displayDeleteConfirmation",false);
        helper.deleteActionCall(cmp,event);
    },
    deleteCancel : function(cmp, event, helper){
        if(Array.isArray(cmp.find("deleteModal"))){
            cmp.find("deleteModal")[0].close();
        }else {
            cmp.find("deleteModal").close();
        }
        cmp.set("v.displayDeleteConfirmation",false);
    },
    isNewRequestChanged : function(cmp, event, helper){
        if(!cmp.get("v.isNewRequest")){
            helper.getMaterialRequestRecords(cmp);
        }
    },
    isNewLoanChanged : function(cmp, event, helper){
        if(!cmp.get("v.isNewLoan")){
            helper.getMaterialRequestRecords(cmp);
        }
    },
    loanStatusChanged : function(cmp, event, helper){
        var materialRequest = cmp.get("v.materialRequestRecord");
        if(materialRequest.Request_Status__c == 'Transferred to new Project'){
            
            helper.getProjectForInstructor(cmp,event);
        }
    },
    proceedClickOnProjectSelection : function(cmp, event, helper){
        var selectedProject = cmp.get("v.selectedProject");
        var isValid = true;
        
        if(!selectedProject){
            // Add error style
            isValid = false;
            var projectDiv = cmp.find("project");
            $A.util.addClass(projectDiv,"slds-has-error");
        }else {
            // remove error style
            var contactDiv = cmp.find("project");
            $A.util.removeClass(projectDiv,"slds-has-error");
        }
        
        if(isValid){
            
            if(Array.isArray(cmp.find("showProjectSelection"))){
                cmp.find("showProjectSelection")[0].close();
            }else {
                cmp.find("showProjectSelection").close();
            }
            cmp.set("v.displayProjectSelection",false);
            
            //Close view model
            if(Array.isArray(cmp.find("LoanModal"))){
                cmp.find("LoanModal")[0].close();
            }else {
                cmp.find("LoanModal").close();
            }
            cmp.set("v.showLoanViewMore",false);
            
            cmp.set("v.showSpinner",true);
            helper.createNewMaterialRequest(cmp,event);
        }
        
    },
    cancelClickProjectSelection : function(cmp, event, helper){
        
        if(Array.isArray(cmp.find("showProjectSelection"))){
            cmp.find("showProjectSelection")[0].close();
        }else {
            cmp.find("showProjectSelection").close();
        }
        cmp.set("v.displayProjectSelection",false);
    }
    
})