({
	doInit : function(component, event, helper) {
		var urlString = window.location.href;        
			component.set("v.formTemplateId", urlString.split("=")[1]);
		component.set('v.toast',{show:false});

		helper.getFormTemplateRec(component, event, helper);
		
	},
	validateAndSaveFormResponse : function(component, event, helper){
		var childComponent = component.find("formResElement");
		var isValid = true,
			formResponseElements = [],
			formResName;
			
		for(var i = 0; i < childComponent.length; i++){
			var result = childComponent[i].validate();
			if(!result.isValid){
				isValid = false;
			}
			if(result.formResName != '')
				formResName = result.formResName;
			formResponseElements.push(result.formResElem);
		}

		if(isValid){
			var formTemp = component.get("v.formTemplate"),
				formResponse = {"Name":formResName,"Form_Template__c":formTemp.Id};
			helper.saveFormResponseAndResponseElements(component, event, helper, formResponse, formResponseElements);
		}else{
			var toast = {show:true, message: 'Review the Errors!', type: 'error'};
			component.set("v.toast",toast);
		}
	},
	hideToast : function(component){
		component.set('v.toast',{show:false});
	}
})