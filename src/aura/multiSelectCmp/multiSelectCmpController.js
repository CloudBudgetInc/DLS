({
	doInit : function(component, event, helper) {
        var optionsList = component.get("v.optionsList") || [],
            selectedList = component.get("v.selectedvalue") || [],
        	options = [];
        
        if( Array.isArray(optionsList)){
            for(var i=0;i<optionsList.length;i++){
                var opt = {};
                
                opt.label = optionsList[i];
                if(selectedList.indexOf(optionsList[i]) != -1){
                    opt.selected = true;
                }
                else{
                     opt.selected = false;
                }
                options.push(opt);
            }
        }
        
        component.set("v.options", options);
        let inputClass = component.get('v.isForCommunity') ? 'slds-input-community slds-select white-border' : 'slds-input slds-select white-border';
        component.set("v.inputClass", inputClass);
    },
	showList : function(component, event, helper) {
		event.stopPropagation(); 
        var optionsList = component.find("optionList");
        $A.util.toggleClass(optionsList, 'slds-hide');
        helper.clearError(component,event,helper);
    },
    selectOption : function(component, event, helper) {
        event.stopPropagation(); 
        var index = event.currentTarget.getAttribute("data-index"),
        	options = component.get("v.options"),
       		selectedvalue = component.get("v.selectedvalue");
        if(selectedvalue == null)
            selectedvalue = [];
            
        if(options[index].selected){
            options[index].selected = false;
            for(var i in selectedvalue){
                if(selectedvalue[i] == options[index].label){
                    selectedvalue.splice(i, 1);
                }
            }
        }else{
            options[index].selected = true;
            selectedvalue.push(options[index].label);
        }
        component.set("v.options", options);
        component.set("v.selectedvalue", selectedvalue);
    },
    checkForValue: function(cmp,event,helper){
        return helper.checkForNullValues(cmp,event,helper);
    }
})