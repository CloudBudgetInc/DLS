({
    doinit : function(component, event, helper){
        var obj = {};
        obj.selectedContact = [];
        obj.projectRecords = [];
        obj.selectedMaterials = [];
        obj.searchByName = '';
        obj.selectedProject = '';
        obj.Qty = '';
        obj.selectedLocation = [];
        obj.loanedOutDate = null;
        obj.requestType = '';
        obj.requestNotes = '';
        obj.materialDisabled = false;
        component.set("v.newLoanObj",obj);
        component.set("v.searchByField","Name");
        
        // to open the model on initial load
        component.set("v.displayNewLoanModel",true);
        if(Array.isArray(component.find("newLoanModel"))) {
            component.find("newLoanModel")[0].open();
        }else{
            component.find("newLoanModel").open();
        }
        
        if(component.get("v.projectId")){
            helper.getProjectDetails(component);
        }
        console.log('::::::::::component.get("v.materialId"):::',component.get("v.materialId"));
        if(component.get("v.materialId")){
            helper.getmaterialDetails(component);
        }
        component.set("v.showSpinner",false);
    },
    openNewLoanModel : function(component, event, helper) {
        component.set("v.displayNewLoanModel",true);
        if(Array.isArray(component.find("newLoanModel"))) {
            component.find("newLoanModel")[0].open();
        }else{
            component.find("newLoanModel").open();
        }
    },
    lookupSearch : function(component, event, helper) {
        // Get the search server side action
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('lookup').search(serverSearchAction);
    },
    materialLookupSearch : function(component, event, helper){
        // Get the search server side action
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('materialLookup').search(serverSearchAction);
    },
    locationLookupSearch : function(component, event, helper){
        // Get the search server side action
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('locationLookup').search(serverSearchAction);
    },
    cancelClick : function(component, event, helper){
        var obj = {};
        component.set("v.newLoanObj",obj);
        component.set("v.displayNewLoanModel",false);
        if(Array.isArray(component.find("newLoanModel"))) {
            component.find("newLoanModel")[0].close();
        }else{
            component.find("newLoanModel").close();
        }
        component.set("v.isNewLoan",false);
    },
    getRelatedProjects : function(component, event, helper){
        console.log(":contact:::",component.get("v.newLoanObj").selectedContact);
        if(component.get("v.newLoanObj").selectedContact != null && component.get("v.newLoanObj").selectedContact.length > 0
          && !component.get("v.projectId")){
            var action =  component.get("c.contactRelatedProjects");
            action.setParams({
                'contactId' : component.get("v.newLoanObj").selectedContact[0].Id
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state == 'SUCCESS'){
                    console.log('::::::response::::',response.getReturnValue());
                    component.set("v.projectRecords", response.getReturnValue());
                }else {
                    console.log(":::error::::");
                }
            });
            $A.enqueueAction(action);
        }
    },
    changeSearchByField : function(component, event, helper){
        if(component.get("v.searchByField") == 'Name')
        	component.set("v.placeHolderName",'Material Name');
        else
            component.set("v.placeHolderName",'ISBN #');
    },
    submitClick : function(component, event, helper){
        console.log("new Loan::::::::::", JSON.stringify(component.get("v.newLoanObj")));
        console.log("materials details::::",component.get("v.materialsDetails"));
        helper.validateInputValues(component);
    },
    getQtyValues : function(component, event, helper){
        console.log(":::::::::",component.get("v.newLoanObj").selectedMaterials);
        var materialsList = component.get("v.newLoanObj").selectedMaterials;
        if(materialsList.length > 0){
            component.set("v.materialsDetails",materialsList);
            component.set("v.displayQty",true);
            component.set("v.showinputDetails",false);
            component.set("v.fromType",'Qty');
        }
    },
    okayClickOnQty : function(component, event, helper){
        var materialList = component.get("v.materialsDetails");
        var isValid = true;
        console.log(":::materialList::",materialList);
        if(component.get("v.displayQty")){
            var qtyList = component.find("qtyInput");
            console.log(":::qty::::",qtyList);
            for(var i = 0; i < qtyList.length; i++){
                var value = qtyList[i].get("v.value");
                if(!value) {
                    $A.util.addClass(qtyList[i], 'slds-has-error');
                    isValid = false;
                }else {
                    $A.util.removeClass(qtyList[i], 'slds-has-error');
                }
            }
        }else {
            var notesList = component.find("notesInput");
            console.log(":::notes::::",notesList);
            for(var i = 0; i < notesList.length; i++){
                var value = notesList[i].get("v.value");
                if(!value) {
                    $A.util.addClass(notesList[i], 'slds-has-error');
                    isValid = false;
                }else {
                    $A.util.removeClass(notesList[i], 'slds-has-error');
                }
            }
        }
        
        if(isValid) {
            if(component.get("v.displayQty")){
                component.set("v.qtyEntered",true);
            }else {
                component.set("v.notesEntered",true);
            }
            
            component.set("v.showinputDetails",true);
            var newLoanRec = component.get("v.newLoanObj");
            newLoanRec.selectedMaterials = materialList;
            component.set("v.newLoanObj",newLoanRec);
        }
    },
    cancelOnQty : function(component, event, helper){
        component.set("v.showinputDetails",true);
        var materials = component.get("v.newLoanObj").selectedMaterials;
        for(var i = 0;i < materials.length;i++){
            if(component.get("v.fromType") == 'Qty'){
                materials[i].qty = '';
            }else if(component.get("v.fromType") == 'Notes'){
                materials[i].notes = '';
            }
        }
    },
    closeClickOnSuccess: function(component, event, helper){
        component.set("v.displaySuccessModal",false);
        
        if(Array.isArray(component.find("successModal"))) {
            component.find("successModal")[0].close();
        }else{
            component.find("successModal").close();
        }
        
        if(component.get("v.successTitle") == 'Success'){
            component.set("v.isNewLoan",false);
            var reloadEvent = $A.get("e.c:reloadEvent");
            reloadEvent.fire();
        }
    },
    //Method to get different notes for each materials
    getNotesValues : function(cmp, event, helper){
        var materialsList = cmp.get("v.newLoanObj").selectedMaterials;
        if(materialsList.length > 1){
            cmp.set("v.materialsDetails",materialsList);
            cmp.set("v.displayQty",false);
            cmp.set("v.showinputDetails",false);
            cmp.set("v.fromType",'Notes');
        }
    }
})