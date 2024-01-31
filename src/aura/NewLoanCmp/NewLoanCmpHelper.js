({
	validateInputValues : function(component) {
		var newLoan = component.get("v.newLoanObj");
        var isValid = true;
        
        if(newLoan.selectedContact.length == 0){
            // Add error style
            isValid = false;
            var contactDiv = component.find("lookup");
            $A.util.addClass(contactDiv,"slds-has-error");
        }else {
            // remove error style
            var contactDiv = component.find("lookup");
            $A.util.removeClass(contactDiv,"slds-has-error");
        }
        
        if(!newLoan.selectedProject){
            // Add error style
            isValid = false;
            var projectDiv = component.find("projectSelect");
            $A.util.addClass(projectDiv,"slds-has-error");
        }else {
            // remove error style
            var projectDiv = component.find("projectSelect");
            $A.util.removeClass(projectDiv,"slds-has-error");
        }
        
        if(newLoan.selectedMaterials.length == 0){
            // Add error style
            isValid = false;
            var materialDiv = component.find("materialLookup");
            $A.util.addClass(materialDiv,"slds-has-error");
        }else {
			//remove error style    
			var materialDiv = component.find("materialLookup");
            $A.util.removeClass(materialDiv,"slds-has-error");        
        }
        
        if(!newLoan.Qty && !component.get("v.qtyEntered")){
            // Add error style
            isValid = false;
            var qtyDiv = component.find("qtyVal");
            $A.util.addClass(qtyDiv,"slds-has-error");    
        }else {
            // remove errro style
            var qtyDiv = component.find("qtyVal");
            $A.util.removeClass(qtyDiv,"slds-has-error");    
        }
        
        if(newLoan.selectedLocation.length == 0){
            // Add error style
            isValid = false;
            var locationDiv = component.find("locationLookup");
            $A.util.addClass(locationDiv,"slds-has-error");    
        }else {
            // remove error style
            var locationDiv = component.find("locationLookup");
            $A.util.removeClass(locationDiv,"slds-has-error");    
        }
        
        if(!newLoan.loanedOutDate){
            // Add error style
            isValid = false;
            var dateDiv = component.find("loanedOut");
            $A.util.addClass(dateDiv,"datePickerError");    
        }else {
            // remove error style
            var dateDiv = component.find("loanedOut");
            $A.util.removeClass(dateDiv,"datePickerError");    
        }
        
        
        if(!newLoan.requestType){
            // Add error style
            isValid = false;
            var typeDiv = component.find("requestType");
            $A.util.addClass(typeDiv,"slds-has-error");    
        }else {
            // remove error style
            var typeDiv = component.find("requestType");
            $A.util.removeClass(typeDiv,"slds-has-error");    
        }
        
        if(isValid){
            component.set("v.displayNewLoanModel",false);
            if(Array.isArray(component.find("newLoanModel"))) {
                component.find("newLoanModel")[0].close();
            }else{
                component.find("newLoanModel").close();
            }
            component.set("v.showSpinner",true);
            this.createMaterialRequests(component);
        }
	},
    createMaterialRequests : function(component){
        console.log("enter create materials requests method");
        var newLoanObj = component.get("v.newLoanObj");
        var loanRecords = [];
        //Create separate Loan records if Qty > 1
        //To Track the materials returned status separated Loan records created
        //Added by NS on Feb 28 2019 - Work Item No : W-001105
        var obj = {};
        if(newLoanObj.selectedMaterials.length > 1){
            for(var  i = 0;i < newLoanObj.selectedMaterials.length; i++){
                if(newLoanObj.selectedMaterials[i].qty > 1){
                    for(var j = 0; j < newLoanObj.selectedMaterials[i].qty;j++){
                        obj = this.loanRecordsFormation(component,newLoanObj,true,i);
                    	loanRecords.push(obj);
                    }
                }else {
                    obj = this.loanRecordsFormation(component,newLoanObj,true,i);
                    loanRecords.push(obj);
                }
            }
        }else {
            if(newLoanObj.Qty > 1){
                for(var j = 0; j < newLoanObj.Qty;j++){
                    obj = this.loanRecordsFormation(component,newLoanObj,false,0);
                    loanRecords.push(obj);
                }
                
            }else {
                obj = this.loanRecordsFormation(component,newLoanObj,false,0);
                loanRecords.push(obj);
            }
        }
        console.log('::::::loanRecords::::',loanRecords);
        if(loanRecords.length > 0){
            var action  = component.get("c.materialsRequestCreation");
            action.setParams({
                "type" : 'Loan',
                "requestJson" : JSON.stringify(loanRecords)
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state == 'SUCCESS'){
                    var obj = {};
        			component.set("v.newLoanObj",obj);
                    component.set("v.showSpinner",false);
                    component.set("v.successMsg",'Material Request records created successfully.');
                    component.set("v.successTitle",'Success');
                    component.set("v.displaySuccessModal",true);
                    
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
    loanRecordsFormation : function(cmp,loanObj,MutlipleMaterial,index){
        var obj = {};
        
        obj.Contact__c = loanObj.selectedContact[0].Id;
        if(MutlipleMaterial){
            obj.Materials_Name__c = loanObj.selectedMaterials[index].Id;
            
            if(cmp.get("v.notesEntered")){
                obj.Request_Notes__c = loanObj.selectedMaterials[index].notes;
            }else {
                obj.Request_Notes__c = loanObj.requestNotes;
            }
        }else {
            obj.Materials_Name__c = loanObj.selectedMaterials[0].Id;
            obj.Request_Notes__c = loanObj.requestNotes;
        }
        obj.Project__c = loanObj.selectedProject;
        obj.Request_Status__c = 'Loaned Out';        
        obj.Date_Loaned_Out__c = loanObj.loanedOutDate;
        obj.Qty__c = 1;
        obj.Location__c = loanObj.selectedLocation[0].Id;
        obj.Request_type__c = loanObj.requestType;
        
        return obj;
    },
    getProjectDetails : function(component){
        var action = component.get("c.getProjectInfo");
        action.setParams({
            "projectId" : component.get("v.projectId") 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                console.log("result::::::project:::::::",response.getReturnValue());
                var result = response.getReturnValue();
                component.set("v.projectRecords",result);
                
                component.find("projectSelect").set("v.value",result[0].Id);
                component.set("v.newLoanObj.selectedProject",result[0].Id);
                
            }else {
                console.log(":::::error:::;",response.getError()[0].message);
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
                var loanObj = component.get("v.newLoanObj");
                loanObj.selectedMaterials = result;
                loanObj.materialDisabled = true;
                component.set("v.newLoanObj",loanObj);
            }else {
                console.log(":::::error:::;",response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    }
})