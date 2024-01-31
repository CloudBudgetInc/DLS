({
	showMyContent : function(component, event, helper) {
        
		console.log(event.target.name);
        if(event.target.name == component.get("v.tabName")){
            return;
        }
        
        if(event.target.name == 'Request' || event.target.name == 'Loan'){
            component.set("v.subtabName", event.target.name);
            if(event.target.name === 'Request' && component.get('v.requestRecords').length > 0){
                component.find("ldtRequestTable").initialize({'order':[]});
            } else if(event.target.name === 'Loan' && component.get('v.loanRecords').length > 0){
                component.find("ldtLoanTable").initialize({'order':[]});
            }
            return;
        }
        component.set("v.subtabName", '');
        component.set("v.tabName", event.target.name);
        
        if(event.target.name === 'Materials' ){
            var serviceColumnConfig = component.get("v.serviceColumnConfig");
            var showMatDeleteIcon = component.get("v.showMatDeleteIcon");
            
        /* W-006415 - Remove Delete Icon from Budget Materials Detail View*/
            if(serviceColumnConfig.rowAction){
                for(var i = 0;i < (serviceColumnConfig.rowAction).length;i++){
                    if(serviceColumnConfig.rowAction[i].id == 'delete'){
                        serviceColumnConfig.rowAction[i].visible = function(row){
                            return ((row.Id && showMatDeleteIcon == true) ? true : false);
                        }
                    }
                }
                component.set("v.serviceColumnConfig",serviceColumnConfig);
            }
            
            if(component.get("v.sObjectName") == 'Opportunity' || (!component.get("v.activityChecked") && component.get("v.tabName") == 'Materials')){
                if(component.get('v.materialRecords').length > 0){
                    component.find("ldtMaterialTable").initialize({'order':[]});
                }
            } else {
                component.set("v.subtabName", 'Request');
                if(component.get('v.requestRecords').length > 0){
                    component.find("ldtRequestTable").initialize({'order':[]});
                }
            }
        } else if(event.target.name === 'Services' &&  component.get('v.serviceRecords').length > 0){
            if(component.get("v.sObjectName") == 'Opportunity'){ 
                component.find("ldtServiceTable").initialize({'order':[]});
            }
        } else if(event.target.name === 'Travel ODC' &&  component.get('v.odcRecords').length > 0 ){
            component.find("ldtOdcTable").initialize({'order':[]});
        } else if(event.target.name === 'Regular Hours' &&  component.get('v.regularHoursRecords').length > 0 ){
            component.find("ldtRegularHoursTable").initialize({'order':[]});
        }else if(event.target.name === 'Fringe' &&  component.get('v.fringeRecords').length > 0){
            component.find("ldtFringeTable").initialize({'order':[]});
        }
        
	},
    getActivityColumns : function(component, event, helper){
        if(component.get("v.sObjectName") != 'Opportunity' && component.get("v.activityChecked")
          && component.get("v.tabName") == 'Materials'){
            component.set("v.subtabName", 'Request');
            
        } else {
            component.set("v.subtabName", '');
        }
        helper.setServiceColumnList(component, event, helper,component.get("v.activityChecked"));
    },
    doInit: function(component, event, helper) {
        component.set("v.subtabName", '');
        console.log('sdf',component.get("v.sObjectName"));
        if(component.get("v.sObjectName") === 'Opportunity'){
            helper.launchOpportunityBudgetPage(component, event, helper);
        } else {
           console.log('sdf');
           helper.launchProjectBudgetPage(component, event, helper); 
        }        
        
	},
    addProjectTask: function(component, event, helper) {
        component.find('recTypeComponent').closeModal();
       
    },
    addFundingTask: function(component, event, helper) {
        //sforce.one.navigateToURL('/apex/PaymentAndPaymentItemCreation?CF'+temp+'='+$scope.reqName+'&CF'+temp+'_lkid='+$scope.parentId+'&scontrolCaching=1&retURL=/'+$scope.parentId+'&sfdc.override=1');
		helper.getCustomFieldId(component,event);
    },
    tabActionClicked: function(component, event, helper) {
       var actionId = event.getParam('actionId');
         var row = event.getParam('row');
        console.log('row Id::'+row.Id);
        if(actionId == 'editicon'){
			//helper.editRecord(component, event, helper,row.Id);
			component.set("v.editRecord",row);
             component.find('editRecordComponent').openModal();
        } 
        if(actionId == 'fund'){
          helper.getFundingItemRecords(component, event,event.getParam('row').Id);
        }
        if(actionId == 'delete'){
            component.set("v.deleteId",row.Id);
             component.find('deleteModalComponent').openModal(); 
             
        }
    },
    gotoURL : function(component, event, helper) {
        //sforce.one.navigateToURL('/apex/PaymentAndPaymentItemCreation?CF'+component.get("")+'='+$scope.reqName+'&CF'+temp+'_lkid='+$scope.parentId+'&scontrolCaching=1&retURL=/'+$scope.parentId+'&sfdc.override=1');

    },
    closeData: function(component, event, helper) {
        component.find('ModalComponent').closeModal();
    },
    closeDeleteData: function(component, event, helper) {
        
        component.find('deleteModalComponent').closeModal();
        
    },
    deleteRecord: function(component, event, helper) {
        component.find('deleteModalComponent').closeModal();
        helper.deleteRecord(component, event, helper);
        
    }, 
    closeRecTypeData: function(component, event, helper) {
        component.find('recTypeComponent').closeModal();
    },
    createTask: function(component, event, helper) {
        component.find('recTypeComponent').closeModal();
        const recordTypeId = component.find('comboRecordType').get('v.value');
        helper.createRecord(component, event, helper,'AcctSeed__Project_Task__c',recordTypeId);
    },
    addLoan: function(component, event, helper) {
       component.set("v.isNewLoan",true);
    },
    addRequest: function(component, event, helper) {
       
        let materialRecords = component.get("v.materialRecords");
        
        if(materialRecords.length == 2){
        	console.log('::::::::materialRecords[0]::::',materialRecords[0]);
            component.set("v.materialRecord",materialRecords[0]);
        } else if(materialRecords.length > 2){
            var tempMaterialRecords = [];
            let materialeRcordValues = materialRecords.map((record,index)=>{
                if(record.Id){
                	tempMaterialRecords.push({label:record.productName,value:record.Id,index:index});
        		}
                return tempMaterialRecords;
        	});
    
            component.set("v.materialRecordValues",tempMaterialRecords);
        } 
		component.find('requestTypeComponent').openModal();
        
    },
    createRequest: function(component, event, helper) {
        let materialRecords = component.get("v.materialRecords");
        if(materialRecords.length == 1){
            component.set("v.isNewRequest",true);
            component.find('requestTypeComponent').closeModal();
            return;
        }
       if(Object.keys(component.get("v.materialRecord")).length == 0 && materialRecords.length >= 2 && component.find('reqRecords').get("v.value") ){
           let materialRecord = materialRecords.filter(record => component.find('reqRecords').get("v.value") == record.Id);
           console.log(materialRecord,JSON.stringify(materialRecord[0]));
           component.set("v.materialRecord",materialRecord[0]);
           return;
        }
        if(Object.keys(component.get("v.materialRecord")).length > 0 && materialRecords.length >= 2){
          component.set("v.isNewRequest",true);
          component.find('requestTypeComponent').closeModal();
          return;
        }
        if(materialRecords.length == 0){
            component.find('requestTypeComponent').closeModal();
            return;
        }
        
    },
    closeReqTypeData: function(component, event, helper) {
         component.find('requestTypeComponent').closeModal();
        component.set('v.materialRecord',{});
    },
    cancelEditRecord: function(component, event, helper) {
         component.find('editRecordComponent').closeModal();
         component.set("v.editRecord",{});
    },
    saveEditRecord: function(component, event, helper) {
       component.find("edit").get("e.recordSave").fire();
    },
    onSaveSuccess: function(component, event, helper) {
        component.set("v.subtabName", '');
        component.set("v.showSpinner",true);
        component.find('editRecordComponent').closeModal();
        component.set("v.editRecord",{});
        if(component.get("v.sObjectName") === 'Opportunity'){
            helper.launchOpportunityBudgetPage(component, event, helper);
        } else {
            console.log('sdf');
            helper.launchProjectBudgetPage(component, event, helper); 
        }  
    },
    changeIsNewRequest: function(component, event, helper) {
        if(!component.get("v.isNewRequest")){
           component.set('v.materialRecord',{});
        }
    },
	changeIsNewLoan: function(component, event, helper){
		if(!component.get("v.isNewLoan")){
			component.set('v.materialRecord',{});
		}
	},
    addProduct : function(component, event, helper) {
       component.find('addProductComponent').openModal();
    },
    navigateToProject : function(component, event, helper) {
      helper.navigateToRecord(component, event, helper,component.get("v.projectList")[0].Id);
    },
    closeProductData : function(component, event, helper) {
       component.find('addProductComponent').closeModal();
    },
    //#W-001548  
    // As an LTS user, I would like to be able to export the Material Request Details from the Project page.
    exportMaterialRequestDataAsFile : function(component, event, helper) {
      var columns = component.get("v.requestColumns");
      var rows = component.get("v.requestRecords");
        if(rows.length > 0){
            var fileName = 'Material Requests - '+rows[0]['dlsClassNo'];
            helper.exportAsFileType(component,columns,rows,fileName,'csv',false); 
        }
    }

   
})