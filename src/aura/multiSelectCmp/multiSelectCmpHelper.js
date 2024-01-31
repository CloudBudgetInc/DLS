({
	helperMethod : function(cmp, event) {
        event.stopPropagation(); 
        var optionsList = cmp.find("optionList");
        //console.log(optionsList);
        if(!$A.util.hasClass(optionsList, 'slds-hide')){
            cmp.set("v.handleChange",true);            
        }
        $A.util.addClass(optionsList, 'slds-hide');
        
        
    },
    
    checkForNullValues: function(cmp,event,helper){
        let inputClass = cmp.get('v.isForCommunity') ?  'slds-input-community slds-select' : 'slds-input slds-select';
        if(cmp.get('v.selectedvalue').length == 0){            
            inputClass += ' red-border';  
            cmp.set('v.inputClass', inputClass);
            cmp.set('v.showError', true);
            return true;
        } else{
            helper.clearError(cmp,event,helper);
            cmp.set('v.showError', false);
            return false;
        }
    },
    clearError : function(cmp,event,helper){
         let inputClass = cmp.get('v.isForCommunity') ?  'slds-input-community slds-select white-border' : 'slds-input slds-select white-border';
         cmp.set('v.inputClass', inputClass);
        cmp.set('v.showError', false);
    }

})