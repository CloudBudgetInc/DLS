({
	toggleSelectAll : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            component.find('selectExpenses').set('v.checked', params.checked);
        }		
	},
    getSelectedExpenseRec : function(component, event, helper){
        
        if(component.find('selectExpenses').get('v.checked')){
            return component.get('v.expense');
        }
    },
	projectLookupSearch : function(component, event, helper){
       var payLine = component.get('v.expense');
           
        if(payLine.projectLookup && payLine.projectLookup.length == 0){  
            payLine.proTaskLookup = [];
        }
        component.set("v.expense",payLine); 
        
       const serverSearchAction = component.get('c.getLookupRecords');
       event.getSource().search(serverSearchAction);
    },
    projectTaskLookupSearch : function(component, event, helper){
        var payLine = component.get('v.expense');
            
        if(payLine.projectLookup && payLine.projectLookup.length > 0){  
            payLine.projectTaskCondition = 'AcctSeed__Project__c = \''+payLine.projectLookup[0].Id+'\'';
        }else if(payLine.AcctSeed__Project__c && payLine.AcctSeed__Project__c != null){
            payLine.projectTaskCondition = 'AcctSeed__Project__c = \''+payLine.AcctSeed__Project__c+'\'';
        }            
        
        component.set("v.expense",payLine); 
        
        const serverSearchAction = component.get('c.getLookupRecords');
        event.getSource().search(serverSearchAction);
    }    
})