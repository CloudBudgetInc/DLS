({
    doInit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        
        var device = $A.get("$Browser.formFactor");
        if (device == 'PHONE') {
            cmp.set("v.displayDevice",'Mobile');
        }else {
            cmp.set("v.displayDevice",'Pc');
        }
        
        helper.getPDORecords(cmp, event);
    },
    
    dateFilter : function(cmp ,event ,helper){
        cmp.set("v.showSpinner",true);
        helper.getPDORecords(cmp,event);
        /*window.setTimeout(function(){
            cmp.set("v.showSpinner",false);
        },1000);*/
    },
    
    tabActionClick : function(cmp, event, helper){
        //console.log('in function:::');
        var actionId = event.getParam('actionId') || null;
        var rowRecord = event.getParam("row");
        cmp.set("v.multiDaysOff",true);
        cmp.set("v.allowParentPlanToUpdate",false);
        
        cmp.set("v.plannedOffdayRecord",{});
        cmp.set("v.typeOfAction",actionId);
        if(rowRecord) {
            cmp.set("v.currentPlannedDay", rowRecord.id);
        }
        //console.log('actionId:::',actionId);
        
        if(actionId == 'deltask') {
            cmp.set("v.plannedOffdayRecord",rowRecord);
            cmp.set("v.showDeleteModel",true);
            cmp.find("deletePDO").open();
            
        }else{
            if(actionId == 'edittask') {
                var plannedOffDays = [];
                var plannedDaysMap = cmp.get("v.plannedDaysMap");
                console.log(JSON.stringify(rowRecord));
                var plannedDays = plannedDaysMap[rowRecord.id];
                //console.log('plannedDaysMap!!',JSON.stringify(plannedDaysMap));
                //console.log('plannedDaysMap:::::',plannedDaysMap[rowRecord.id]);
                
                if(plannedDays && plannedDays.length > 0) {                    
                    var plannedOffdayRecord = {};
                    plannedOffdayRecord.From_Date__c = rowRecord.fromDate;
                    plannedOffdayRecord.To_Date__c = rowRecord.toDate;
                    plannedOffdayRecord.Project__c = (rowRecord.projectId != null ? rowRecord.projectId : 'All');
                    plannedOffdayRecord['All_Projects__c'] = (rowRecord.projectId == null ? true : false);                    
                    plannedOffdayRecord.Type__c = rowRecord.type;
                    plannedOffdayRecord.Description__c =  rowRecord.description;
                    plannedOffdayRecord.Id = rowRecord.id;
                    
                    for(var i = 0; i < plannedDays.length ; i++) {
                        var pdoRec = {};
                        pdoRec.Id = plannedDays[i].id;
                        //console.log('Date value::::',plannedDays[i].dateValue);
                        if(plannedDays[i].dateValue) {
                            pdoRec.Date__c = plannedDays[i].dateValue;  
                        }
                        pdoRec.Project__c = (plannedDays[i].projectId ? plannedDays[i].projectId : 'All');
                        //pdoRec.Project__c = (pdoRec.Project__c == 'All' ? null : pdoRec.Project__c);
                        pdoRec['All_Projects__c'] = (pdoRec.Project__c == 'All' ? true : false);
                        pdoRec.Type__c = plannedDays[i].type;
                        pdoRec.Description__c = plannedDays[i].description;
                        
                        plannedOffDays.push(pdoRec);
                    }
                    cmp.set("v.allowParentPlanToUpdate",true);
                    cmp.set("v.plannedOffdayRecord", plannedOffdayRecord);
                }else {
                    
                    var pdoRec = {};
                    pdoRec.Id = rowRecord.id;
                    if(rowRecord.dateValue){
                        pdoRec.Date__c = rowRecord.dateValue;  
                    }else {
                        pdoRec.Date__c = rowRecord.fromDate; 
                    }
                    //console.log('From Date:::', rowRecord.fromDate);
                    //console.log('toDate:::', rowRecord.toDate);
                    if(rowRecord.fromDate != rowRecord.toDate){
                        pdoRec.From_Date__c = rowRecord.fromDate;
                        pdoRec.To_Date__c = rowRecord.toDate;
                        cmp.set("v.multiDaysOff",false);
                    }
                    pdoRec.Project__c = (rowRecord.projectId ? rowRecord.projectId : 'All');
                    pdoRec.Project__c = (pdoRec.Project__c == 'All' ? null : pdoRec.Project__c);
                    pdoRec['All_Projects__c'] = (pdoRec.Project__c == 'All' ? true : false);
                    pdoRec.Type__c = rowRecord.type;
                    pdoRec.requestOffRT = rowRecord.requestOffRT;
                    pdoRec.Description__c = rowRecord.description;
                    
                    plannedOffDays.push(pdoRec);
                }
                
                console.log('Planned days off records::',plannedOffDays);
                // cmp.set("v.plannedOffdayRecord",pdoRec);
                cmp.set("v.plannedOffDays",plannedOffDays);
                cmp.set("v.modalHeaderName",rowRecord.dateStr +' - '+rowRecord.description);
                cmp.set("v.showAddEditModel",true);
            	cmp.find("editOffModel").open();
            }else{
                var contactRecord = cmp.get("v.contactRec");
                //Modified By Siva Prasanth - 24/04/2024 - W-006581 - Planned Days Off Message Specific for DODA Students
                var projectValues = cmp.get('v.projectValues');
                var filteredproList = [];
                
                for(var pro = 0;pro < projectValues.length;pro++){
                    if(projectValues[pro].label && (projectValues[pro].label != '--None--' && projectValues[pro].label != 'All')){
                        filteredproList.push(projectValues[pro]);
                    }
                }
                //Modified By Dhinesh - 19/03/2021 - W-006581 - Planned Days Off Message Specific for DODA Students
                if(contactRecord.RecordType.DeveloperName == 'Student' && contactRecord.Account.Name == 'DODA' && filteredproList.length < 1){
                    
                    cmp.set("v.successHeader", 'Warning');                    
                    cmp.set("v.successTitle" ,"Per your class type, any requests for planned days off need to be directly coordinated and pre-approved with your agency's Language Manager (not DLS). If you have further questions, please contact your DLS Language Training Supervisor.");
                    cmp.set("v.showSuccessModel",true);
                	cmp.find("successModel").open();
                }else{
                    var offRecord = {};
                    
                    if(contactRecord.RecordType.DeveloperName == 'Candidate'){
                        offRecord.Type__c = 'Instructor';
                    }else if(contactRecord.RecordType.DeveloperName == 'Student'){
                        offRecord.Type__c = 'Student';
                    }
                    offRecord.RecordTypeId = cmp.get("v.requestOffRT");
                    cmp.set("v.plannedOffdayRecord",offRecord);
                    cmp.set("v.modalHeaderName",'New Planned Days Off');
                    cmp.set("v.showAddModal",true);
                    cmp.find("newOffModel").open();
                }
            }
            
            cmp.set("v.visibleError",'slds-hide'); 
            
        }
        
    },
    saveBtnClick : function(cmp, event, helper){
        //console.log('::::::new:::record:::',cmp.get("v.plannedOffdayRecord"));
        //validate the inputs
        var otherInputField = cmp.find("otherInputField");
        var dateInputField = cmp.find("dateInputField");
        var isValid = true;
        
        cmp.set("v.visibleError",'slds-hide');
        if(Array.isArray(dateInputField)){
            for(var i = 0;i < dateInputField.length;i++){
                if (!dateInputField[i].get("v.value")) { 
                    dateInputField[i].set("v.errors", [{message:" "}])
                    isValid = false;
                } else {
                    dateInputField[i].set("v.errors", null);
                }
            }
            var fromDate = new Date(dateInputField[0].get("v.value"));
            var toDate= new Date(dateInputField[1].get("v.value"));
            if(!isNaN(toDate)){
                if(fromDate.getTime() > toDate.getTime() ){
                    isValid = false;  
                    dateInputField[1].set("v.errors", [{message:" End date must be greater than Start date "}])
                } else{
                    dateInputField[1].set("v.errors", null); 
                }
            }
        }else{
            if(!dateInputField.get("v.value")) { 
                dateInputField.set("v.errors", [{message:" "}])
                isValid = false;
            } else {
                dateInputField.set("v.errors", null);
            }
        }
        
        if(Array.isArray(otherInputField)){
            for(var i = 0;i < otherInputField.length;i++) {      
                if(!otherInputField[i].get("v.value")) {
                    isValid = false;
                    $A.util.addClass(otherInputField[i], 'slds-has-error'); 
                }else {   
                    $A.util.removeClass(otherInputField[i], 'slds-has-error');
                    
                }
            }
        }
        
        if(isValid){
            var plannedOffdayRecord = cmp.get("v.plannedOffdayRecord");
            
            helper.findPDODayDiffernceHelper(cmp, plannedOffdayRecord.Date__c)
            .then(function(noOfDays) {
                if((noOfDays < 1)){
                    cmp.set("v.showWarningMsg",'Planned days off must be submitted more than 24 hours/one business day in advance. Please contact your LTS for assistance.');
                    cmp.set("v.visibleError",'slds-show'); 
                }else {
                    cmp.set("v.showSpinner",true);
                    helper.createNewOffRecord(cmp, event);
                    cmp.find("newOffModel").close();
                    cmp.set("v.showAddModal",false); 
                }
            });
           /* var plannedDaysOffRecord = cmp.get("v.plannedOffdayRecord");
            var currentDate = moment(new Date()).format('YYYY-MM-DD');
            var plannedDaysOffStartDt;
            var dt;
            var isDisplayWarningMsg = false;
                        
            if(moment(plannedDaysOffRecord.Date__c).weekday() == 1){
                var difference = moment(plannedDaysOffRecord.Date__c).diff(currentDate,'days');
                if(difference < 4){
                    isDisplayWarningMsg = true;
                }
            }else if(moment(plannedDaysOffRecord.Date__c).weekday() == 2){
                var difference = moment(plannedDaysOffRecord.Date__c).diff(currentDate,'days');
                if(difference < 3){
                    isDisplayWarningMsg = true;
                }
            }else {
                var difference = moment(plannedDaysOffRecord.Date__c).diff(currentDate,'days');
                if(difference < 2){
                    isDisplayWarningMsg = true;
                }
            }
            
            if(isDisplayWarningMsg) {
                cmp.set("v.showWarningMsg",'Planned days off must be submitted more than one business day in advance.');
                cmp.set("v.visibleError",'slds-show'); 
            }else {
                cmp.set("v.showSpinner",true);
                helper.createNewOffRecord(cmp, event);
                cmp.find("newOffModel").close();
                cmp.set("v.showAddModal",false); 
            }*/
        }
    },
    cancelBtnClick : function(cmp, event, helper){
        cmp.find("newOffModel").close();
        cmp.set("v.showAddModal",false);
        cmp.set("v.plannedOffdayRecord",{});
    },
    deleteNoClick : function(cmp,event,helper){
        cmp.set("v.showDeleteModel",false);  
    },
    cancelEditClick : function(cmp, event, helper) {
        cmp.set("v.viewMode", true);
        cmp.set("v.parentViewMode", true);
        cmp.set("v.showSaveButton", false);
        cmp.find("editOffModel").close();
        cmp.set("v.showAddEditModel",false);
    },
    
    saveEditBtnClick : function(cmp, event, helper) {
        var PODate;
        if(!cmp.get('v.parentViewMode')){
            var plannedOffdayRecord = cmp.get('v.plannedOffdayRecord');
            PODate = plannedOffdayRecord.From_Date__c;
        }else{
            var plannedOffdayRecord = cmp.get("v.plannedOffDays");
            PODate = plannedOffdayRecord[0].Date__c;
        }
            
        helper.findPDODayDiffernceHelper(cmp, PODate)
        .then(function(noOfDays) {
            if((noOfDays < 1)){
                cmp.set("v.showWarningMsg",'Planned days off must be submitted more than one business day in advance. Please contact your LTS for assistance.');
                cmp.set("v.visibleError",'slds-show'); 
            }else {
                helper.updateEditRecords(cmp, event); 
            }
        });
        
    },
    
    deleteYesClick : function(cmp,event,helper){
        cmp.set("v.showSpinner",true);
        helper.updatePDOStatusAsDeleteHelper(cmp);
    },
    closeClickOnSuccess : function(cmp, event, helper){
        cmp.find("successModel").close();
        cmp.set("v.showSuccessModel",false);
        helper.getPDORecords(cmp, event);
    },
    handleToggleSaveButton: function(cmp,event,helper){
        cmp.set("v.showSaveButton", event.getParam("isEdit"));
    }
})