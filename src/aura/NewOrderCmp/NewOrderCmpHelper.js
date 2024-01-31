({
    validateInputValues : function(component) {
        var newOrder = component.get("v.newOrderObj");
        var isValid = true;
        
        if(newOrder.selectedProject.length == 0){
            // Add error style
            isValid = false;
            var projectDiv = component.find("projectLookup");
            $A.util.addClass(projectDiv,"slds-has-error");
        }else {
            // remove error style
            var projectDiv = component.find("projectLookup");
            $A.util.removeClass(projectDiv,"slds-has-error");
        }
        
        if(newOrder.studentCAPicklist.length > 0 && (!newOrder.selectedStudentCA)){
            // Add error style
            isValid = false;
            var stuCAId = component.find("studentCALookup");
            $A.util.addClass(stuCAId,"slds-has-error");
        }else {
            // remove error style
            var stuCAId = component.find("studentCALookup");
            $A.util.removeClass(stuCAId,"slds-has-error");
        }
        
        if(newOrder.selectedMaterials.length == 0){
            // Add error style
            isValid = false;
            var materialDiv = component.find("materialLookup");
            $A.util.addClass(materialDiv,"slds-has-error");
        }else {
            //remove error style    
            var materialDiv = component.find("materialLookup");
            $A.util.removeClass(materialDiv,"slds-has-error");        
        }
        
        if(!newOrder.Qty && !component.get("v.qtyEntered")){
            // Add error style
            isValid = false;
            var qtyDiv = component.find("qtyVal");
            $A.util.addClass(qtyDiv,"slds-has-error");    
        }else {
            // remove errro style
            var qtyDiv = component.find("qtyVal");
            $A.util.removeClass(qtyDiv,"slds-has-error");    
        }
        
        if(newOrder.selectedLocation.length == 0){
            // Add error style
            isValid = false;
            var locationDiv = component.find("locationLookup");
            $A.util.addClass(locationDiv,"slds-has-error");    
        }else {
            // remove error style
            var locationDiv = component.find("locationLookup");
            $A.util.removeClass(locationDiv,"slds-has-error");    
        }
        
        if(!newOrder.dueDate){
            // Add error style
            isValid = false;
            var dateDiv = component.find("dueDate");
            $A.util.addClass(dateDiv,"datePickerError");    
        }else {
            // remove error style
            var dateDiv = component.find("dueDate");
            $A.util.removeClass(dateDiv,"datePickerError");    
        }
        
        if(!newOrder.materialSource){
            // Add error style
            isValid = false;
            var matSourceDiv = component.find("materialSource");
            $A.util.addClass(matSourceDiv,"slds-has-error");
        }else {
            // remove error style
            var matSourceDiv = component.find("materialSource");
            $A.util.removeClass(matSourceDiv,"slds-has-error");
        }
        
        if(!newOrder.requestType){
            // Add error style
            isValid = false;
            var typeDiv = component.find("requestType");
            $A.util.addClass(typeDiv,"slds-has-error");    
        }else {
            // remove error style
            var typeDiv = component.find("requestType");
            $A.util.removeClass(typeDiv,"slds-has-error");    
        }
        
        // Project Task check
        if(newOrder.selectedProject.length > 0 && component.get("v.projectTaskDetails") && component.get("v.projectTaskDetails").length == 0){
            isValid = false;
            component.set("v.taskErroMsg",'This Project does not have Material Budget Project task.');
        }else {
            component.set("v.taskErroMsg",'');
        }
        
        if(isValid){
            component.set("v.displayNewOrderModel",false);
            if(Array.isArray(component.find("newOrderModel"))) {
                component.find("newOrderModel")[0].close();
            }else{
                component.find("newOrderModel").close();
            }
            component.set("v.showSpinner",true);
            this.createMaterialRequests(component);
        }
    },
    createMaterialRequests : function(component){
        console.log("enter create materials requests method");
        var newOrderObj = component.get("v.newOrderObj");
        var orderRecords = [];
        var obj = {};
        var studentIds = [];
        
        if(newOrderObj.selectedMaterials.length > 1){
            for(var  i = 0;i < newOrderObj.selectedMaterials.length; i++){
                obj = this.orderRecordsFormation(component,newOrderObj,true,i);                    
                
                if(newOrderObj.selectedStudentCA && newOrderObj.selectedStudentCA.length > 0){
                    
                    for(var studentNo = 0; studentNo < newOrderObj.selectedStudentCA.length; studentNo++){
                        var obj1 = JSON.parse(JSON.stringify(obj));
                        obj1.Contact__c = newOrderObj.selectedStudentCA[studentNo].Id; 
                        studentIds.push(obj1.Contact__c);
                        orderRecords.push(obj1);
                    }
                }else{
                    orderRecords.push(obj);
                }
                
            }
        }else {
            obj = this.orderRecordsFormation(component,newOrderObj,false,0);
            
            if(newOrderObj.selectedStudentCA && newOrderObj.selectedStudentCA.length > 0){
                    
                for(var studentNo = 0; studentNo < newOrderObj.selectedStudentCA.length; studentNo++){
                    var obj1 = JSON.parse(JSON.stringify(obj));
                    obj1.Contact__c = newOrderObj.selectedStudentCA[studentNo].Id; 
                    studentIds.push(obj1.Contact__c);
                    orderRecords.push(obj1);
                }
            }else{
                orderRecords.push(obj);
            }            
        }
        
        console.log('::::::orderRecords::::',orderRecords);
        if(orderRecords.length > 0){
            var action  = component.get("c.materialsRequestCreation");
            action.setParams({
                "type" : 'Order',
                "requestJson" : JSON.stringify(orderRecords),
                "studentCAIds" : studentIds
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state == 'SUCCESS'){
                    //var obj = {};
                    //component.set("v.newOrderObj",obj);
                    component.set("v.showSpinner",false);
                    component.set("v.successMsg",'Material Request records created successfully.');
                    component.set("v.successTitle",'Success');
                    component.set("v.displaySuccessModal",true);
                    
                    var result = response.getReturnValue();
                    component.set("v.matReqIds",JSON.parse(result));

                    if(Array.isArray(component.find("successModal"))) {
                        component.find("successModal")[0].open();
                    }else{
                        component.find("successModal").open();
                    }                    
                }else {
                    console.log('::::error:::::',response.getError()[0].message);
                    component.set("v.showSpinner",false);
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
        }
    },
    orderRecordsFormation : function(cmp,orderObj,MutlipleMaterial,index){
        var obj = {};
        
        obj.Project__c = orderObj.selectedProject[0].Id;
        obj.Request_Status__c = 'Requested by LTS';
        obj.Due_Date__c = orderObj.dueDate;
        obj.Reimbursements__c = orderObj.isReimbursement;//W-007578 Added by Dinesh on 30.09.2022
        
        if(MutlipleMaterial){
            if(cmp.get("v.qtyEntered")){
                obj.Qty__c = orderObj.selectedMaterials[index].qty;
            }else {
                obj.Qty__c = orderObj.Qty;
            }
			
            if(cmp.get("v.notesEntered")){
                obj.Request_Notes__c = orderObj.selectedMaterials[index].notes;
            }else {
                obj.Request_Notes__c = orderObj.requestNotes;
            }
            
            if(cmp.get("v.contentInLMSEntered")){
                obj.Content_in_LMS__c = orderObj.selectedMaterials[index].contentInLms;
            }else {
                obj.Content_in_LMS__c = orderObj.contentInLms;
            }   
            
             if(cmp.get("v.contentInLMSEntered")){
                 obj.LMS_Only__c = orderObj.selectedMaterials[index].lmsOnly;
             }else {
                 obj.LMS_Only__c = orderObj.lmsOnly;
             }   
            
            obj.Materials_Name__c = orderObj.selectedMaterials[index].Id;
        }else {
            obj.Request_Notes__c = orderObj.requestNotes;
            obj.Qty__c = orderObj.Qty;
            obj.Materials_Name__c = orderObj.selectedMaterials[0].Id;
            obj.Content_in_LMS__c = orderObj.contentInLms;
            obj.LMS_Only__c = orderObj.lmsOnly;
        }
        
        obj.Location__c = orderObj.selectedLocation[0].Id;
        obj.Request_type__c = orderObj.requestType;
        obj.Rush__c = orderObj.rush;
        obj.Materials_Source__c = orderObj.materialSource;
        obj.Project_Task__c = cmp.get("v.projectTaskDetails")[0].Id;  
        
        return obj;
    },
    getProjectDetails : function(component, event, helper){
        var projectTaskId = component.get("v.projectTaskId");
        var action = component.get("c.getProjectInfo");
        action.setParams({
            "projectId" : component.get("v.projectId") 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                console.log("result::::::project:::::::",response.getReturnValue());
                var result = response.getReturnValue();
                var orderObj = component.get("v.newOrderObj");
                orderObj.selectedProject = result;
                component.set("v.newOrderObj",orderObj);
                //this.getTaskRecords(component);
            }else {
                console.log(":::::error:::;",response.getError()[0].message);
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
    },
    getStudentCADetails : function(component){
        /*W-005442 - Materials Request - Delivery Location Autofill*/
        /* if project location is DLS Online then get  Planned,Active  Status Student CA*/
        
        var projectId = component.get("v.projectId");
        var action = component.get("c.getStudentCAInfo");
        action.setParams({
            "projectId" : projectId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                console.log("result:::::::StudentCA::::::",response.getReturnValue());
                component.set("v.showSpinner",false);
                var result = response.getReturnValue();
                //W-007578 Modified by Dinesh on 06.10.2022
                //Since student should be shown based on Reimbursement checkbox,modifying these lines
                var stuCAPickList = result;
                var showStudentCAOptions = false;
                
                var orderObj = component.get("v.newOrderObj");
                if(stuCAPickList.length > 0){
                    showStudentCAOptions = true;
                    component.set("v.newOrderObj.studentCAPicklist",stuCAPickList);
                }
                if(stuCAPickList.length == 1){
                     component.set("v.newOrderObj.selectedStudentCA",stuCAPickList);
                }
                component.set("v.showStudentCAOptions",showStudentCAOptions);

            }else {
                component.set("v.showSpinner",false);
                console.log(":::::error:::;",response.getError()[0].message);
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
    },
    getmaterialDetails : function(component){
        var action = component.get("c.getMaterialInfo");
        action.setParams({
            "materialId" : component.get("v.materialId") 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                console.log("result:::::::material::::::",response.getReturnValue());
                var result = response.getReturnValue();
                var orderObj = component.get("v.newOrderObj");
                orderObj.selectedMaterials = result;
                orderObj.materialDisabled = true;
                component.set("v.newOrderObj",orderObj);
            }else {
                console.log(":::::error:::;",response.getError()[0].message);
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
    }
})