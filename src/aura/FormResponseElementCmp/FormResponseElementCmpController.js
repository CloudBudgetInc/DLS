({
    doInit : function(component, event, helper) {
        var formResElement = component.get("v.formResponseElement"),
            formTempElement = component.get("v.formTempElement"),
            allFormTempEleIdwithOptionLimit = component.get("v.formTempEleIdwithOptionLimit"),
            formTempEleIdwithOptionLimit,
            formTempIdWithFormResElement = component.get('v.formTempIdWithFormResElement');
        
        if(allFormTempEleIdwithOptionLimit){
            formTempEleIdwithOptionLimit = allFormTempEleIdwithOptionLimit[formTempElement.Id];
        }
		
             
        if(formTempIdWithFormResElement && formTempIdWithFormResElement[formTempElement.Id]){
            formResElement = formTempIdWithFormResElement[formTempElement.Id];
            if(formTempElement.Question_Type__c == 'Multiple Choice'){                
                var selectedValues = formResElement.Feedback__c ? formResElement.Feedback__c.replaceAll(/&amp;/ig, "&").replaceAll(/&lt;/ig, "<").replaceAll(/&gt;/ig, ">").replaceAll(/&quot;/ig, '"').replaceAll(/&#39;/ig, "'").split(";") : [];                   
                component.set("v.selectedValues", selectedValues);
            }
        }else{
            formResElement.Question__c = formTempElement.Id;
            formResElement.Name = formTempElement.Question__c.replace(/<[^>]*>?/gm, '').slice(0, 80); 
            formResElement.Form_Response__c = component.get('v.formResponseId');
        }
        
        if(formTempElement.Question_Type__c == 'Picklist' && formTempElement.Answer_Options__c){
            var allOptions = formTempElement.Answer_Options__c.split(";");
            var options = [];
            for(var i = 0; i < allOptions.length; i++){
                if(!formTempEleIdwithOptionLimit || (formTempEleIdwithOptionLimit[allOptions[i]] > 0)){
                    options.push({'label': allOptions[i], 'value': allOptions[i]});
                }
            }
			
            if((allOptions.indexOf('Other') > -1 || allOptions.indexOf('other') > -1) && formResElement.Feedback__c){
                var index = formResElement.Feedback__c.indexOf(" - ");
                var option = formResElement.Feedback__c.substring(0, index);
                var other = formResElement.Feedback__c.substring(index+3, formResElement.Feedback__c.length);
                formResElement.Feedback__c = option;
                component.set('v.other', other);
            }
            component.set("v.options", options);
        }else if(formTempElement.Question_Type__c == 'Multiple Choice' && formTempElement.Answer_Options__c){
            var options = formTempElement.Answer_Options__c.split(";");            
            component.set("v.options", options);
        }        
        
        component.set("v.formResponseElement", formResElement);
        component.set("v.showQuestion", true);
    },
    validateFormResponse : function(component, event, helper){
        var inputCmp = component.find("inputCmp"),
            otherInputCmp = component.find("otherInputCmp");
        var formTempElement = component.get("v.formTempElement"),
            formResName = '',
            formResElement = component.get("v.formResponseElement"),
            allFormTempEleIdWithResponseForUniqueResponse = component.get("v.formTempEleIdWithResponseForUniqueResponse"),
            formTempEleIdWithResponseForUniqueResponse,
            other = component.get('v.other'),
            valid = true;
		
        if(formTempElement.Question_Type__c == 'Multiple Choice'){
            valid = formTempElement.Required__c ? !inputCmp.checkForValues() : valid;
            formResElement.Feedback__c = component.get('v.selectedValues').join(';');
        }else if(formTempElement.Question_Type__c == 'Rating' || formTempElement.Question_Type__c == 'Rich Text Area'){
            valid = formTempElement.Required__c ? formResElement.Feedback__c : valid;
            if(!valid && inputCmp){
                inputCmp.set('v.valid',false);
            }else if(valid && inputCmp){                
                inputCmp.set('v.valid',true);
            }
        }else{
            if(!inputCmp.checkValidity()){
                inputCmp.reportValidity();
            }
            if(allFormTempEleIdWithResponseForUniqueResponse && allFormTempEleIdWithResponseForUniqueResponse[formTempElement.Id] ){
                formTempEleIdWithResponseForUniqueResponse = allFormTempEleIdWithResponseForUniqueResponse[formTempElement.Id];
                
                if(formTempEleIdWithResponseForUniqueResponse.indexOf(formResElement.Feedback__c.toUpperCase()) != -1){
                    inputCmp.setCustomValidity('Value already exist!');
                    inputCmp.reportValidity();
                }else{
                    inputCmp.setCustomValidity('');
                    inputCmp.reportValidity();
                }            
            }
            valid = inputCmp.checkValidity();
            if(otherInputCmp && formTempElement.Required__c){
                valid = formTempElement.Required__c ? other : valid;
                if(!valid && otherInputCmp){
                    otherInputCmp.set('v.valid',false);
                }else if(valid && otherInputCmp){ 
                    formResElement.Feedback__c += (' - ' + other);
                    otherInputCmp.set('v.valid',true);
                }                
            }
        }
        if(formTempElement.Set_As_Response_Name__c){
            formResName = formResElement.Feedback__c;
        }
        
        return {"isValid":valid, "formResElem":formResElement, "formResName": formResName};
        
    },
    showErrorMessage : function(component, event, helper){
        var params = event.getParam('arguments');
        
        if (params && params.tempEleIds) {
            var tempEleIds = params.tempEleIds.split("~"),
                formTempElement = component.get("v.formTempElement");
            
            if(tempEleIds.indexOf(formTempElement.Id) != -1){
                var inputCmp = component.find("inputCmp");                
                inputCmp.setCustomValidity('Value already exist!');
                inputCmp.reportValidity();
            }

        }
    }
})