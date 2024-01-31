({  
    doInit: function(component, event, helper) {
        console.log('controller');
    	helper.getAccountInfo(component, event);  
    },
    syncVendor : function(component, event, helper){
        var accountRec = component.get("v.accountRecord");
        console.log(JSON.stringify(accountRec));
        if(accountRec.Status_Bill_com__c != 'Active'){
            component.set("v.message", 'We will only sync active accounts to Bill.com');              
        }else if(!(accountRec.AcctSeed__Accounting_Type__c == 'Vendor' || accountRec.AcctSeed__Accounting_Type__c == 'Customer and Vendor')){
            component.set("v.message", 'Only Vendor & Customer and Vendor accounting type accounts are synced to Bill.com');
        }else{
            helper.executeBatch(component, event, helper);  
        }
    },
    closeModal : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})