({
	doinit : function(cmp, event, helper){
        
        if( cmp.get("v.sObjectName") == 'Metric__c'){
        	helper.refreshMetrics(cmp);
        } else{
            cmp.set('v.showDates', true);
        }       
    },
    validateInputs: function(cmp, event, helper){
        var dateinputs = cmp.find('dateinput'),
        	  isValid = true;
        
        for(var dateinput of dateinputs){
            if(!dateinput.checkValidity()){
                isValid = false;
            }
            dateinput.reportValidity();
        }
        
        if(isValid){
             helper.refreshMetrics(cmp);
        }
    },
	closeAction : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    }
})