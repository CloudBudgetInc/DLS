({
    
    showToast: function (component, event, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
            mode: "dismissible"
        });
        toastEvent.fire();
    },
    createPayableRecord: function(component, event, helper){
        const server = component.find("server");
        const action = component.get("c.createPayableAndPayableLines");   
        component.set("v.loading", true);
        var payableRec = component.get('v.payableSelection') ? component.get('v.payable')[0] : component.get('v.payable');
        var param = {            
            payableRec: JSON.stringify(payableRec),
            payableLineRec: JSON.stringify(component.get('v.selectedExpenses'))
        };
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (responseStr) {
                component.set("v.loading", false);
                
                var response = JSON.parse(responseStr);
                if(response && response.result == 'success'){
                    component.set('v.payable', []);
    				component.set('v.payableSelection', false);
                    component.find('openPayableDetail').close();                    
                    window.open('/' + response.payableId, '_blank');  
                    helper.getExportedReport(component, event, helper);                     
                    helper.showToast(component, event, "Success", 'Payable created successfully!', "success");
                }else{
                    helper.showToast(component, event, "Error", response.result, "error");
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
    getExportedReport: function(component, event, helper){
        const server = component.find("server");
        const action = component.get("c.exportReport");   
        component.set("v.loading", true);
        
        var param = {            
            startDate: component.get('v.startDate'), 
            endDate: component.get('v.endDate')
        };
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (response) {
                component.set("v.loading", false);               
                if(response){
                    console.log(response)
                    var allExpenses = JSON.parse(response.replace(/\\/g, ""));
                    
                    var approvedExpenses = [],
                        transactionIds = [],
                        creditCardDetails = component.get('v.creditCardIdWithVendorNameMap');
                    
                    for(var expense of allExpenses){
                        
                        if(expense.status == "Approved"){                                                      
                            /*if(expense.postDate && expense.postDate.indexOf('-') == -1){                                
                                expense.postDate = expense.postDate.slice(0,4)+'-'+expense.postDate.slice(4,6)+'-'+expense.postDate.slice(6);                                
                            }
                            var splittedDate = expense.postDate.split("-");*/
                            if(expense.postDate && moment(expense.postDate).isValid()){
                                /*var postDate = new Date(splittedDate[0],splittedDate[1] - 1,splittedDate[2]),
                                    monthStr = postDate.toLocaleString('default', { month: 'short' }),
                                    yearStr = postDate.getFullYear();*/
                                let datStr = moment(expense.postDate).format('MMMYYYY');
                                expense['referenceNo'] = datStr+' '+expense.firstName.charAt(0)+expense.lastName;
                            }
                            expense['projectLookup'] = [];
                            expense['vendorName'] = creditCardDetails && creditCardDetails[expense.cardId+'~'+expense.empEmail] ? creditCardDetails[expense.cardId+'~'+expense.empEmail] : '';
                            transactionIds.push(expense['transactionId']);
                            approvedExpenses.push(expense);
                        }
                    }
                    
                    helper.getExistingPayableLineByTransactionId(component, event, helper, approvedExpenses, transactionIds);                    
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
    getExistingPayableLineByTransactionId: function(component, event, helper, expenses, transactionIds){
        const server = component.find("server");
        const action = component.get("c.getPayableLineByTransactionId");   
        component.set("v.loading", true);
        
        var param = {            
            expensifyTransactionIds: transactionIds
        };
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (response) {
                component.set("v.loading", false);
                
                if(response){
                    
                    var approvedExpenses = [],
                        existingTransactionIds = JSON.parse(response);
                    
                    for(const expense of expenses){
                        if(existingTransactionIds && existingTransactionIds.indexOf(expense['transactionId']) == -1){
                            
                            approvedExpenses.push(expense);
                        }
                    }
                                        
                    helper.sort(component, event, helper, component.get('v.sortingDetails').column, approvedExpenses);
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
    sort: function(component, event, helper, column, expenses){
        var sortingDetails = component.get('v.sortingDetails');
        
        if(sortingDetails.column != column || !sortingDetails.isASC){
        	expenses = expenses.sort((a,b) => (a[column] > b[column]) ? 1 : ((b[column] > a[column]) ? -1 : 0));
            sortingDetails.isASC = true;
        }else{
            expenses = expenses.sort((a,b) => (a[column] < b[column]) ? 1 : ((b[column] < a[column]) ? -1 : 0));
            sortingDetails.isASC = false;
        }
        sortingDetails.column = column;
        component.set('v.expenses', expenses);
        component.set('v.sortingDetails', sortingDetails);
        component.set('v.selectAll', false);
        if(expenses &&expenses.length > 0 ){
			helper.toggleSelectAll(component, event, false);   
        }
    },
    toggleSelectAll: function(component, event, selectAll){
        
        var expenseRowCmps = (Array.isArray(component.find('expenseRowCmp'))) ? component.find('expenseRowCmp') : [component.find('expenseRowCmp')];
        
        for(var index = 0; index < expenseRowCmps.length;index++){
            expenseRowCmps[index].selectAll(selectAll);
        } 
    },
    setPayableRecDefaultValue : function(component, event){
        var selectedExpenses = component.get('v.selectedExpenses'),
            d = new Date(),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear(),
            totalAmnt = 0;
        
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
        
        var todayStr = [year, month, day].join('-');
        
        for(var index = 0; index < selectedExpenses.length;index++){
            var selectedExpense = selectedExpenses[index];
            if(selectedExpense){
                totalAmnt += selectedExpense.total;
            }
        }
        
        component.set("v.payable", {accountingPeriod: [], vendor:[], totalAmount: totalAmnt, dateVal: todayStr, dueDate: todayStr});
    }
})