({
	addInput : function(cmp, event, helper) {
        //Increment Line number counter
        var numberTimeInputs = cmp.get("v.numTimeInputs");
        numberTimeInputs++;
        console.log('Number of time inputs: ' + numberTimeInputs);
        cmp.set("v.numTimeInputs", numberTimeInputs); 
        //add the Input Line
		helper.addInput(cmp, event);
	},
    saveAllItems : function(cmp, event, helper){
        helper.saveAllItems(cmp, event);
    },
    handleUpdateTimeInput : function(cmp, event, helper){
        helper.handleUpdateTimeInput(cmp, event);
    },
    handleDeleteTimeInput : function(cmp, event, helper){
        helper.handleDeleteTimeInput(cmp, event);
    },
    doInit : function(cmp, event, helper){
        helper.getWorkItem(cmp,event);
    },
})