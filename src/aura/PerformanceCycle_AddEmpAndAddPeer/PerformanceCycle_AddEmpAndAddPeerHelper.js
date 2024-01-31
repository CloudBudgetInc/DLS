({
    getFormResponse: function(cmp, event, helper){
        cmp.set('v.showSpinner', true);
        var action = cmp.get("c.getFormResponseRecord");
        action.setParams({ recordId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set('v.showSpinner', false);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set('v.formResponse', result.formResponse);
                
                if(result.formResponse.Question_Set__r.Feedback_Type__c == 'Self Summary'){
                    /*if(result.formResponse.Is_Feedback_By_Me__c){//Removed the validation to give option to employee to add peer
                    	helper.showToast(cmp, "Please ask your manager to Add Peers for your Self Summary.", 'error'); 
                    	$A.get("e.force:closeQuickAction").fire();
                    }else{*/
                    	
                        cmp.set('v.showAddEmployees', true);
                        /*if(result.formResponse.Feedback_From__r && result.formResponse.Feedback_From__r.Supervisor_Name__c){
                            var employeeFilterCondition = cmp.get('v.employeeFilterCondition') + " AND Supervisor_Name__c = '"+result.formResponse.Feedback_From__r.Supervisor_Name__c+"'";
                            cmp.set('v.employeeFilterCondition', employeeFilterCondition);
                        }*/
                        cmp.set('v.employeeFilterCondition', result.contactFilter);
                        cmp.set('v.tableRecords', result.peerSummaryFormResponses);
                        cmp.set('v.showAllEmpTable', true);
                        helper.setPeerTableConfigs(cmp, event, helper);
                        
                        if(result.peerSummaryFormResponses.length > 0){
                            cmp.find("formResponseTable").initialize({
                                order: "asc"
                            });
                        }
                    //}
                }else{
                    helper.showToast(cmp, 'Peer will be added only for Self Summary feedback', 'error'); 
                    $A.get("e.force:closeQuickAction").fire();
                }
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        }); 
        $A.enqueueAction(action);
    },
    getDLSEmployees:  function(cmp, event, helper){
        cmp.set('v.showSpinner', true);
        var action = cmp.get("c.getEmployees"); 
        action.setParams({ recordId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set('v.showSpinner', false);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set('v.employeesMap', result.dlsEmp);
                cmp.set('v.employeeFilterCondition', result.contactFilter);
                helper.setEmpTableConfigs(cmp, event, helper);                                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        }); 
        $A.enqueueAction(action);
    },
    createPeerResponse : function(cmp, event, helper, empIds) {
        cmp.set('v.showSpinner', true);
        var action = cmp.get("c.createPeerFormResponse");
        action.setParams({ 
            selectedEmployeeIds :  empIds, 
            formResStr: JSON.stringify(cmp.get('v.formResponse'))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set('v.showSpinner', false);
            if (state === "SUCCESS") {
                var resultObj = response.getReturnValue();
                helper.showToast(cmp, resultObj.message, resultObj.result); 
                cmp.set("v.selectedEmployees", []);
                helper.getFormResponse(cmp, event, helper);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast(cmp,   errors[0].message, 'error');                
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        }); 
        $A.enqueueAction(action); 
    },
    createEmpResponse: function(cmp, event, helper, empIds){        
        cmp.set('v.showSpinner', true);
        var action = cmp.get("c.createEmpFormResponse");
        action.setParams({ 
            selectedEmployeeIds :  empIds, 
            recordId: cmp.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set('v.showSpinner', false);
            if (state === "SUCCESS") {
                var resultObj = response.getReturnValue();
                helper.showToast(cmp, resultObj.message, resultObj.result); 
                cmp.set("v.selectedEmployees", []);
                helper.getDLSEmployees(cmp, event, helper);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast(cmp,   errors[0].message, 'error');                
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        }); 
        $A.enqueueAction(action);        
    },
    showToast : function(component, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            message: message,
            type: type
        });
        toastEvent.fire();
    },
    setPeerTableConfigs: function(component, event, helper){
        var tableColumns = [                    
            {
                label: "Feedback About",
                name: "Feedback_About__r.Name",
                type: "string",
                truncate: {},
                sortable: true
            },
            {
                label: "Feedback From",
                name: "Feedback_From__r.Name",
                type: "string",
                truncate: {},
                sortable: false
            },
            {
                label: "Status",
                name: "Status__c",
                type: "string",
                truncate: {},
                visible: true,
                sortable: true
            }
        ];
        
        component.set("v.tableColumns", tableColumns);
        
        //Configuration data for the table to enable actions in the table
        var tableConfig = {
            massSelect: false,
            globalAction: [],
            rowAction: [],
            paginate: false,
            searchBox: false
        };
        component.set("v.tableConfig", tableConfig);
    },
    setEmpTableConfigs: function(component, event, helper){
        var tableColumns = [                    
            {
                label: "Name",
                name: "Name",
                type: "string",
                truncate: {},
                sortable: true
            },
            {
                label: "Supervisor Name",
                name: "Supervisor_Name__r.Name",
                type: "string",
                truncate: {},
                sortable: false
            }
        ];
        
        component.set("v.tableColumns", tableColumns);
        
        //Configuration data for the table to enable actions in the table
        var tableConfig = {
            massSelect: true,
            globalAction: [],
            rowAction: [],
            paginate: true,
            searchBox: false
        };
        component.set("v.tableConfig", tableConfig);
    }
})