({
	valueChange :function(component,event,helper){
         component.set("v.showSpinner",true);
        component.set("v.isRowUpdated",true);
        var choosenValue = event.getSource().get("v.value");
        var fieldInfo = component.get("v.fieldInfo");
        if(fieldInfo.fieldType == 'REFERENCE' && fieldInfo.apiName == 'Language__c'){
            component.set("v.fieldInfo.lookUpList",choosenValue);
        }else{
         	component.set("v.fieldInfo.selectedValue",choosenValue);   
        }
         window.setTimeout(
            $A.getCallback(function() {
                component.set("v.showSpinner",false);
            }), 1000);
    },
    inputChange: function(component ,event,helper){
        component.set("v.isRowUpdated",true);
    },
    
    lookupSearch : function(component ,event , helper){
        // Get the search server side action
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('lookup').search(serverSearchAction);
    }
})