({
	doInit : function(component, event, helper) {
		helper.getAllFormResponseElementsAndFormTemplateElements(component, event, helper);
	},
    changeQuestion: function(component, event, helper){
        var action = event.getSource().get("v.name"),
            currentQuestionNo = component.get('v.currentQuestionNo');
        console.log(action);
        if(action == 'next'){
            component.set('v.currentQuestionNo', currentQuestionNo + 1);
        }else{
            component.set('v.currentQuestionNo', currentQuestionNo - 1);
        }
    },
    validateAndSaveFormResponse: function(component, event, helper){
        var formResElement = component.find('formResElement'),            
        	isValid = true,
            formResponseElements = [],
            status = event.getSource().get("v.name");
        
        for(var i = 0; i < formResElement.length; i++){
            var result = formResElement[i].validate();
			if(!result.isValid){
				isValid = false;
			}
            formResponseElements.push(result.formResElem);
        }
        
        isValid = status != 'Submitted' ? true : isValid;
        
        if(status == 'Decline'){
            formResponseElements = [];
        }
        
        if(isValid){
            helper.saveFormResponse(component, event, helper, formResponseElements, status);            
        }else{
            helper.showToast(component,  'Please complete all the required feedback.', 'error');
        }
    }
})