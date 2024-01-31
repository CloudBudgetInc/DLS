({
    doInit: function(component, event, helper){
        if(component.get("v.sObjectName") == 'Form_Response__c'){
        	component.set('v.actionName', 'Peers');
            
            helper.getFormResponse(component, event, helper);
            
        }else{
            helper.getDLSEmployees(component, event, helper);
            component.set('v.showAddEmployees', true);
        }
    },
    lookupSearch : function(component, event, helper){
        
        const serverSearchAction = component.get('c.getLookupRecords');
        component.find('employeeLookup').search(serverSearchAction);
    },
    initTable: function(cmp, event){
        cmp.set("v.selectedEmployees", []);
        var employeesMap = cmp.get('v.employeesMap');
        
        if(!event.getSource().get("v.checked")){
            cmp.set('v.tableRecords', []);
        }
        
        if(event.getSource().get("v.name") == 'active' && event.getSource().get("v.checked")){
			if(cmp.get('v.showNewHiresTable'))  cmp.set('v.showNewHiresTable', false);        
            cmp.set('v.tableRecords', employeesMap.active);
        }else if(event.getSource().get("v.name") == 'new' && event.getSource().get("v.checked")){
			if(cmp.get('v.showAllEmpTable'))  cmp.set('v.showAllEmpTable', false);                    
            cmp.set('v.tableRecords', employeesMap.new);        
        }
        
        if(cmp.get('v.tableRecords').length > 0 && cmp.find("formResponseTable")){
            cmp.find("formResponseTable").initialize({
                order: "asc"
            });
        }
    },
    clearSelection: function(cmp, event, helper){
        cmp.set("v.selectedEmployees", []);
    },
    handleAction: function(component, event, helper){
        var selectedEmpInTable = component.find("formResponseTable") ? component.find("formResponseTable").get("v.selectedRows") : [],
            isValid = true;        
        
        if(component.get('v.actionName') == 'Peers' || !(component.get('v.showAllEmpTable') || component.get('v.showNewHiresTable'))){
           isValid = component.find('employeeLookup').validate(); 
        }else{
           isValid = selectedEmpInTable.length > 0;
        }
        
        if(isValid){
            var sOjectName = component.get("v.sObjectName"),
                selectedEmployees = component.get("v.selectedEmployees"),                                
            	empIds = [];
        
            for (const selectedEmp of selectedEmployees) {
                empIds.push(selectedEmp.Id);
            }
            
            for (const selectedEmp of selectedEmpInTable) {
                empIds.push(selectedEmp.Id);
            }
            
            if(sOjectName == 'Form_Response__c'){
                helper.createPeerResponse(component, event, helper, empIds);
            }else{
                helper.createEmpResponse(component, event, helper, empIds);
            }
        }else{
            helper.showToast(component, 'Please select atleast one '+component.get('v.actionName') , 'error'); 
        }
        
    }
})