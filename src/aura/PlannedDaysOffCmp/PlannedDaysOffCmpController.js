({
    ContactLookupSearch : function(component, event, helper) {
        // Get the search server side action
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('ContactLookup').search(serverSearchAction);
    },
    searchPlannedOffRecords : function(component, event, helper) {
        
        helper.searchPDORecords(component, event, helper);
        
    },
    newPlannedOff : function(component,event,helper){
        
        helper.newPlannedOffDays(component,event,helper);
        
    },
    planOffAddEditCancel: function(component,helper,event){
        component.set("v.displayAddEditModel",false);
        if(component.get("v.isFromContactAssignment")){
            var appEvent = $A.get("e.c:reloadEvent");
            appEvent.fire();
        }
    },
    tabActionClick : function(component, event, helper){
        
        var actionId=event.getParam('actionId');
        var rowRecord=event.getParam("row");
        component.set("v.isDisplaycontactProOpp",false)
        console.log(':::::',JSON.stringify(rowRecord));
        
        if(actionId == 'edittask') {
            component.set("v.actionHeaderName",rowRecord.Name);
            component.set("v.plannedOffdayRecord",rowRecord); 
            component.set("v.displayAddEditModel",true);
            component.find("planOffAddEditModel").openModal();
        }else if(actionId == 'deltask'){
            component.set("v.plannedOffdayRecord",rowRecord);
            component.set("v.displayDeleteModel",true); 
            component.find("deletePDO").openModal();
        }
    },
    savePDOWithCancelEvent: function (component, event, helper) {
        component.set("v.isCancelEvents",true);
        component.set("v.displayInstructorPDOConfirmation",false);
        helper.savePDOClick(component,event,helper)
    },
    savePDOWithoutCancelEvent: function (component, event, helper) {
        component.set("v.isCancelEvents",false);
        component.set("v.displayInstructorPDOConfirmation",false);
        helper.savePDOClick(component,event,helper)
    },
    planOffAddEditSave: function(component, event, helper){
        
        var otherInputField = component.find("otherInputField");
        var dateInputField = component.find("dateInputField");
        var isValid = true;
        
        if(Array.isArray(dateInputField)){ 
            if (!dateInputField[0].get("v.value")) { 
                dateInputField[0].set("v.errors", [{message:" "}])
                isValid = false;
            } else {
                dateInputField[0].set("v.errors", null);
            }
            var fromDate = new Date(dateInputField[0].get("v.value"));
            var toDate= new Date(dateInputField[1].get("v.value"));
            if(toDate != null  || toDate != '' ){
                if(fromDate.getTime() > toDate.getTime() ){
                    isValid = false;  
                    dateInputField[1].set("v.errors", [{message:" End date must be greater than Start date "}])
                } else{
                    dateInputField[1].set("v.errors", null); 
                }
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
        }else  {
            if(!otherInputField.get("v.value")) {
                isValid =false;
                $A.util.addClass(otherInputField, 'slds-has-error');
            }else{
                $A.util.removeClass(otherInputField, 'slds-has-error')  
            }
        }
        if(isValid){
            var pdoDaysOffRec = component.get("v.plannedOffdayRecord");
            var recordTypeId = component.get("v.plannedOffRTNameIdMap")['Instructor_Planned_Days_Off'];
            console.log('pdoDaysOffRec:::::',pdoDaysOffRec);
            if(pdoDaysOffRec && pdoDaysOffRec.RecordTypeId == recordTypeId){
                component.set("v.displayInstructorPDOConfirmation",true);
                component.set("v.displayAddEditModel",false);
                component.find("instructorPDOConfirmation").openModal();
            }
             else {
                helper.savePDOClick(component,event,helper)
            }
        }
    },
    SelectedPDORecordType :function(component, event, helper){
        
        var  pDoRecTypeMap = component.get("v.plannedOffRTNameIdMap");
        var type = ''
        var rType = Object.keys(pDoRecTypeMap).find(key => pDoRecTypeMap[key] === component.get("v.plannedOffdayRecord").RecordTypeId);
        if(rType == 'Instructor_Planned_Days_Off'){
            type = 'Instructor';
            component.set("v.isDisplaycontactProOpp",true);
        }else if(rType == 'Staff_Planned_Days_Off') {
            type = 'Staff';
            component.set("v.isDisplaycontactProOpp",true);
        }else if(rType == 'Student_Planned_Days_Off'){
            type = 'Student';
            component.set("v.isDisplaycontactProOpp",true);
        }else{
            component.set("v.isDisplaycontactProOpp",false);   
        }
        if(type){
            helper.getCARelatedContacts(component,event,helper,type)
        }
    },
    deleteNoClick : function(component,event,helper){
        component.set("v.displayDeleteModel",false);  
    },
    deleteYesClick : function(component,event,helper){
        
        var isStaff = true;
        component.set("v.showSpinner",true);
        
        /*if(component.get("v.contactRec") && component.get("v.contactRec").RecordType.DeveloperName == 'DLS_Employee'){
            component.get("v.plannedOffdayRecord").Status__c = 'Delete';
            isStaff = true;   
        }else{
            isStaff = false;
        }*/
        component.get("v.plannedOffdayRecord").Status__c = 'Delete';
        component.set("v.plannedOffdayRecord", component.get("v.plannedOffdayRecord"));
        var deleteArray =[];
        deleteArray.push(component.get("v.plannedOffdayRecord"));
        
        var action = component.get("c.deletePlannedDaysOff");
        action.setParams({ 
            "plannedOffJson":JSON.stringify(deleteArray),
            "isStaff":isStaff,
        });
        action.setCallback(this, function(data) {
            var state=data.getState();
            if(state == "SUCCESS"){
                helper.searchPDORecords(component, event, helper);
                component.set("v.showSpinner",false);
                component.set("v.displayDeleteModel",false); 
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success",
                    message: (component.get("v.contactRec") && component.get("v.contactRec").RecordType.DeveloperName == 'DLS_Employee')?'Delete Request has been Submitted for Approval':"Planned Days Off was Deleted",
                    type:"success"
                });
                toastEvent.fire();
                
            }else{
                if(state == "ERROR"){
                    component.set("v.showSpinner",false);  
                    component.set("v.displayDeleteModel",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message :  data.getError()[0].message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();  
                }
            }
        });
        $A.enqueueAction(action);
    }
    
})