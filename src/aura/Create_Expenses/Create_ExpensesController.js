({	
    doInit: function(component, event, helper){
        var tableHeaders = [{
            label: 'Date',
            name: 'postDate',
            style: 'width: 5.5rem;',
            isSortable: true
        },{
            label: 'Vendor',
            name: 'vendorName',
            style: 'width: 5rem;',
            isSortable: true
        },{
            label: 'Reference Number',
            name: 'referenceNo',
            style: '',
            isSortable: true
        },{
            label: 'Project',
            name: 'Project',
            style:'width: 11.5rem;',
            isSortable: false
        },{
            label: 'Project Task',
            name: 'Project Task',
            style:'width: 11.5rem;',
            isSortable: false
        },{
            label: 'Internal Comment',
            name: 'Internal_Comment',
            style:'width: 11.5rem;',
            isSortable: true
        },{
            label: 'Expense GL Account',
            name: 'Expense_GL_Account',
            style:'',
            isSortable: true
        },{
            label: 'GL Variable 1',
            name: 'GL_Account_Variable_1',
            style:'',
            isSortable: true
        },{
            label: 'Invoice Comment',
            name: 'invoiceComment',
            style:'',
            isSortable: true
        },{
            label: 'Total Amount',
            name: 'total',
            style:'',
            isSortable: true
        }];
        component.set('v.tableHeaders', tableHeaders);
        component.set('v.sortingDetails', {'column':'postDate','isASC':false});
        const server = component.find("server");
        const action = component.get("c.getExpensifyCreditCard");   
        component.set("v.loading", true);
        
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function (response) {
                component.set("v.loading", false);
                if(response){
                    var creditCard = JSON.parse(response);                    
                    component.set('v.creditCardIdWithVendorNameMap', creditCard);
                }else{
                    helper.showToast(component, event, "Error", response, "error");
                }				
            }),
            $A.getCallback(function (errors) {
                component.set("v.loading", false);
                helper.showToast(component, event, "Error", errors[0].message, "error");                
            }),
            false,
            false,
            false 
        );
    },
    getExpenseReports: function(component, event, helper){
        helper.getExportedReport(component, event, helper);
    },    
    lookupSearch : function(cmp, event, helper){
        
        const serverSearchAction = cmp.get('c.getLookupRecords');
        event.getSource().search(serverSearchAction);
    },
    selectAllExpenses: function(component, event, helper){
        helper.toggleSelectAll(component, event, component.get('v.selectAll'));                    
    },
    saveExpenses: function(component, event, helper){
        
        var expenseRowCmps = (!Array.isArray(component.find('expenseRowCmp'))) ? [component.find('expenseRowCmp')] : component.find('expenseRowCmp'),
            selectedExpenses = [];
        
        for(var index = 0; index < expenseRowCmps.length;index++){
            var selectedExpense = expenseRowCmps[index].getSelectedExpense();
            if(selectedExpense){
                selectedExpenses.push(selectedExpense);
            }
        }
        
        if(selectedExpenses.length > 0){
            component.set("v.selectedExpenses", selectedExpenses);
			helper.setPayableRecDefaultValue(component, event);
            component.find('openPayableDetail').open(); 
        }else{
            helper.showToast(component, event, "Error", 'Please select atleast one expense.', "error");
        }       
    },
    closeDetail: function(cmp, event, helper){
        cmp.set('v.payableSelection', false);
        cmp.set('v.payable', null);
        cmp.find('openPayableDetail').close();        
    },
    payableCreationInputValidations: function(component, event, helper){
        
        var isValid = true;
        
        if(!component.get('v.payableSelection')){
            var periodCmp = component.find('periodInput').validate(),
                vendorCmp = component.find('vendorInput').validate(),
                dateCmp = component.find('dateInput');
            
            for(var i = 0; i < dateCmp.length; i++){
                if(isValid){
                    isValid = dateCmp[i].checkValidity();
                }            
            }
            isValid = isValid ? periodCmp && vendorCmp : isValid;
        }else{
            isValid = component.find('payableInput').validate();
        }
        
        if(!isValid){
        	helper.showToast(component, event, "Error", 'Complete required fields.', "error");    
        }else{
            
            helper.createPayableRecord(component, event, helper);    
        }
    },
    sortExpenses: function(component, event, helper){
        
        if(event.currentTarget.dataset.sortable == 'true'){
            helper.sort(component, event, helper, event.currentTarget.name, component.get('v.expenses'));
        }
       	
    },    
    selectPayableRec: function(component, event, helper){
        var payableSelection = component.get('v.payableSelection');
        if(payableSelection){
            helper.setPayableRecDefaultValue(component, event);
        }else{
            component.set('v.payable', []);
        }
        
    	component.set('v.payableSelection', !payableSelection);    
    }
})