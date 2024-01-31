({
    doinit : function(component, event, helper) {
        
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            component.set("v.displayDevice",'Mobile');
        } else {
            component.set("v.displayDevice",'PC');
        }
        
        var obj = {};
        obj.selectedProject = [];
        obj.selectedMaterials = [];
        obj.searchByName = '';
        obj.Qty = '';
        obj.selectedLocation = [];
        obj.dueDate = null;
        obj.requestType = '';
        obj.materialSource = '';
        obj.contentInLms = '';
        obj.lmsOnly = false;
        obj.requestNotes = '';
        obj.rush = false;
        obj.selectedStudentCA = [];
        obj.studentCAPicklist = [];
        obj.materialDisabled = false;
        obj.isReimbursement = false;//W-007578 Added by Dinesh on 30.09.2022
        component.set("v.newOrderObj",obj);
        component.set("v.searchByField","Name");
        console.log('Test');
        if(component.get("v.projectId")){
            helper.getProjectDetails(component, event, helper);
        }
        if(component.get("v.materialId")){
            helper.getmaterialDetails(component);
        }
        
        component.set("v.displayNewOrderModel",true);
        if(Array.isArray(component.find("newOrderModel"))) {
            component.find("newOrderModel")[0].open();
        }else{
            component.find("newOrderModel").open();
        }
        component.set("v.showSpinner",false);
    },
    openNewOrderModel : function(component, event, helper){
        component.set("v.displayNewOrderModel",true);
        if(Array.isArray(component.find("newOrderModel"))) {
            component.find("newOrderModel")[0].open();
        }else{
            component.find("newOrderModel").open();
        }
    },
    getRelatedTasks : function(component, event, helper){
        if(component.get("v.newOrderObj.selectedProject").length > 0 && component.get("v.allowApexCall")){
            var action  = component.get("c.getTaskInfomation");
            action.setParams({
                'projectId' : component.get("v.newOrderObj.selectedProject")[0].Id
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state == 'SUCCESS'){
                    console.log('::::::projectTask:::::',response.getReturnValue());
                    component.set("v.projectTaskDetails",response.getReturnValue());
                    
                    //Set Request Type field value based on the project selection
                    var orderObj = component.get("v.newOrderObj");
                    var dlsLibraryProIds = $A.get("$Label.c.DLS_Library_Projects").split(', ');
                    var proId = component.get("v.newOrderObj.selectedProject")[0].Id;
                    
                    // For DLS Materials Inventory Project check
                    var dlsIventoryPro = $A.get("$Label.c.DLS_Materials_Inventory_Projects");
                    console.log(':::::::::dlsIventoryPro::::',dlsIventoryPro);
                    if(dlsLibraryProIds.indexOf(proId.substring(0,15)) != -1){
                        orderObj.requestType = 'Library';
                    }else if(dlsIventoryPro == proId.substring(0,15)){
                        orderObj.requestType = 'Stock';
                    }else {
                        orderObj.requestType = 'Student';
                    }
                    component.set("v.allowApexCall",false);
                    component.set("v.newOrderObj",orderObj);
                    
                }else {
                    console.log("::::error::::",response.getError()[0].message);
                    component.set("v.successMsg",response.getError()[0].message);
                    component.set("v.successTitle",'Error');
                    component.set("v.displaySuccessModal",true);
                    
                    if(Array.isArray(component.find("successModal"))) {
                        component.find("successModal")[0].open();
                    }else{
                        component.find("successModal").open();
                    }
                }
            });
            $A.enqueueAction(action);
        }else if(!component.get("v.allowApexCall")){
            component.set("v.allowApexCall",true);
        }
    },
    projectLookupSearch : function(component, event, helper) {
        // Get the search server side action
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('projectLookup').search(serverSearchAction);
    },
    materialLookupSearch : function(component, event, helper){
        // Get the search server side action
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('materialLookup').search(serverSearchAction);
    },
    studentLookupSearch : function(component, event, helper){
        var projectId = component.get('v.newOrderObj.selectedProject')[0].Id,
            studentPicklist = component.get('v.newOrderObj.studentCAPicklist'),
        	studentCondition = 'Id IN (';
            
        for(var i = 0; i < studentPicklist.length; i++){
			studentCondition += "'" + studentPicklist[i].Id +"',";           
        }
        studentCondition = studentCondition.substring(0, studentCondition.length - 1) + ')';  
        component.set('v.studentCondition',studentCondition);
        //commented by Dinesh on 06.09.2022 for W-007578.
        //this code was needed when there is only one student and it was not shown
        /*var newOrderObj = component.get('v.newOrderObj');
        if(!newOrderObj.selectedStudentCA || newOrderObj.selectedStudentCA.length < 1)
        	newOrderObj.selectedStudentCA = [];
        component.set('v.newOrderObj', newOrderObj);*/
        const serverSearchAction = component.get('c.getLookupRecords');
        component.find('studentCALookup').search(serverSearchAction);
    },
    locationLookupSearch : function(component, event, helper){
        // Get the search server side action
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('locationLookup').search(serverSearchAction);
    },
    submitClick : function(component, event, helper){
        console.log("new Order::::::::::", JSON.stringify(component.get("v.newOrderObj")));
        console.log("materials details::::",component.get("v.materialsDetails"));
        helper.validateInputValues(component);
    },
    cancelBtnClick : function(component, event, helper){
        var obj = {};
        obj.selectedProject = [];
        obj.selectedLocation = [];
        obj.selectedMaterials = [];
        component.set("v.newOrderObj",obj);
        component.set("v.displayNewOrderModel",false);
        if(Array.isArray(component.find("newOrderModel"))) {
            component.find("newOrderModel")[0].close();
        }else{
            component.find("newOrderModel").close();
        }
        component.set("v.isNewRequest",false);
        
    },
    changeSearchByField : function(component, event, helper){
        if(component.get("v.searchByField") == 'Name')
            component.set("v.placeHolderName",'Material Name');
        else
            component.set("v.placeHolderName",'ISBN #');
    },
    getQtyValues : function(component, event, helper){
        console.log(":::::::::",component.get("v.newOrderObj").selectedMaterials);
        var materialsList = component.get("v.newOrderObj").selectedMaterials;
        if(materialsList.length > 0){
            component.set("v.materialsDetails",materialsList);
            component.set("v.displayQty",true);
            component.set("v.displayLMSOnly",false);
            component.set("v.displayContentInLMS",false);
            component.set("v.showinputDetails",false);
            component.set("v.fromType",'Qty');
        }
    },
    getLMSValues : function(component, event, helper){ 
        console.log(":::::::::",component.get("v.newOrderObj").selectedMaterials);
        var materialsList = component.get("v.newOrderObj").selectedMaterials;
        if(materialsList.length > 0){
            component.set("v.materialsDetails",materialsList);
            component.set("v.displayQty",false);
            component.set("v.displayLMSOnly",true);
            component.set("v.displayContentInLMS",false);
            component.set("v.showinputDetails",false);
            component.set("v.fromType",'LMSOnly');
        }
    },
    getContentInLMSValues : function(component, event, helper){
        
        var materialsList = component.get("v.newOrderObj").selectedMaterials;
        if(materialsList.length > 0){
            component.set("v.materialsDetails",materialsList);
            component.set("v.displayQty",false);
            component.set("v.displayContentInLMS",true);
            component.set("v.displayLMSOnly",false);
            component.set("v.showinputDetails",false);
            component.set("v.fromType",'ContentInLMS');
        }
    },
    okayClickOnQty : function(component, event, helper){
        var materialList = component.get("v.materialsDetails"),
            isValid = true,
            inputId = component.get("v.displayQty") ? 'qtyInput' : component.get('v.displayContentInLMS') ? 'contentInLMSInput' : (component.get('v.displayLMSOnly'))? 'lmsInput' : 'notesInput';

        var inputList = component.find(inputId);

        if(inputId != 'contentInLMSInput' && inputId != 'lmsInput'){
            for(var i = 0; i < inputList.length; i++){
                var value = '';
                if(inputId == 'lmsInput'){
                    value = inputList[i].get("v.checked");
                }else{
                    value = inputList[i].get("v.value");
                }
                if(!value) {
                    $A.util.addClass(inputList[i], 'slds-has-error');
                    isValid = false;
                }else {
                    $A.util.removeClass(inputList[i], 'slds-has-error');
                }
            }
        }
        
        if(isValid) {
            if(component.get("v.displayQty")){
            	component.set("v.qtyEntered",true);
            }else if(component.get('v.displayContentInLMS')){
                component.set('v.contentInLMSEntered', true);
            }else if(component.get('v.displayLMSOnly')){
                component.set('v.LMSonlyEntered', true);
            }else {
                component.set("v.notesEntered",true);
            }
            component.set("v.showinputDetails",true);
            var newOrderRec = component.get("v.newOrderObj");
            newOrderRec.selectedMaterials = materialList;
            component.set("v.newOrderObj",newOrderRec);
        }
    },
    cancelBtnOnQty : function(component, event, helper){
        component.set("v.showinputDetails",true);
        var materials = component.get("v.newOrderObj").selectedMaterials;
        for(var i = 0;i < materials.length;i++){
            if(component.get("v.fromType") == 'Qty'){
                materials[i].qty = '';
            }else if(component.get("v.fromType") == 'Notes'){
                materials[i].notes = '';
            }else if(component.get("v.fromType") == 'ContentInLMS'){
                materials[i].contentInLms = '';
            }else if(component.get("v.fromType") == 'LMSOnly'){
                materials[i].lmsOnly = false;
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
        
        var matReqIds = component.get("v.matReqIds");
        
        if(component.get("v.projectId")){
        	var matReqIds = component.get("v.matReqIds");
        
            if(matReqIds.length > 0){
                for(var i = 0;i < matReqIds.length;i++){
                    window.open('/lightning/r/Materials_Request__c/'+matReqIds[i]+'/view?0.source=alohaHeader','_blank');
                }
            }    
        }
        
        if(component.get("v.successTitle") == 'Success'){
            component.set("v.isNewRequest",false);
            var reloadEvent = $A.get("e.c:reloadEvent");
            reloadEvent.fire();
        }
    },
    applyStartDate : function(component, event, helper){
        var projectTasks = component.get("v.projectTaskDetails");
        var newOrderObj = component.get("v.newOrderObj");
        if(projectTasks.length > 0){
            newOrderObj.dueDate = projectTasks[0].AcctSeed__Project__r.Start_Date__c;
            component.set('v.newOrderObj',newOrderObj);
        }
    },
    goToMaterialCreate : function(component, event, helper){
        var objId = $A.get("$Label.c.Materials_Object_Id");
        var prefixUrl = $A.get("$Label.c.Org_Prefix_Start_URL");
        var communityPrefix = $A.get("$Label.c.Community_Site_Prefix");
        var isSite = window.location.pathname.split('/apex')[0];
        if(isSite != '/staff'){
            window.open(prefixUrl+'/lightning/o/Materials__c/list?','_blank');
        }else {
            window.open(communityPrefix+'/s/recordlist/Materials__c/Recent','_blank');
        }
    },
    //Method to get different notes for each materials
    getNotesValues : function(cmp, event, helper){
        var materialsList = cmp.get("v.newOrderObj").selectedMaterials;
        if(materialsList.length > 0){
            cmp.set("v.materialsDetails",materialsList);
            cmp.set("v.displayQty",false);
            cmp.set("v.displayLMSOnly",false);
            cmp.set("v.displayContentInLMS",false);
            cmp.set("v.showinputDetails",false);
            cmp.set("v.fromType",'Notes');
        }
    },
    getRelatedCAStudents : function(cmp, event, helper){
        var newOrderObj = cmp.get("v.newOrderObj");
        var selectedLocation = newOrderObj.selectedLocation;
        
        if( (selectedLocation.length > 0 && selectedLocation[0].Name == 'DLS - Online' ) ||  (newOrderObj.isReimbursement) ){
            cmp.set("v.showSpinner",true);
            helper.getStudentCADetails(cmp);
        }else{
            cmp.set("v.newOrderObj.selectedStudentCA",[]);
            cmp.set("v.showStudentCAOptions",false);
        }
    }
})