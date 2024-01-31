({
	getFormTemplateRec : function(component, event, helper) {
		component.set("v.showSpinner", true);
		const server = component.find("server");
		const action = component.get("c.getFormTemplate");  		
		console.log(component.get("v.formTemplateId"));
		var param = {
			formTemplateId: component.get("v.formTemplateId")
		};

		server.callServer(
		action,
		param,
		false,
		$A.getCallback(function (response) {
			component.set("v.showSpinner", false);	
			console.log(response);
			component.set("v.formTempEleIdwithOptionLimit", response.formTempEleIdwithOptionLimit);
			component.set("v.formTempEleIdWithResponseForUniqueResponse", response.formTempEleIdWithResponseForUniqueResponse);
			component.set("v.formTemplate", response.formTemplate);
		}),
		$A.getCallback(function (errors) {
			component.set("v.showSpinner", false);
			
			var toast = {show:true, message: errors[0].message, type: 'error'};
			component.set("v.toast",toast);			
		}),
		false,
		false,
		false 
		);
	},
	saveFormResponseAndResponseElements: function(component, event, helper, formResponse, formResponseElements) {
		component.set("v.showSpinner", true);
		const server = component.find("server");
		const action = component.get("c.saveFormResAndFormResElements");    
		var param = {
			"formResponse" : formResponse,
			"formResponseElements": formResponseElements
		};
		console.log(param);
		server.callServer(
		action,
		param,
		false,
		$A.getCallback(function (response) {
			component.set("v.showSpinner", false);
			console.log(response);
			if(response == 'success'){	
				var toast = {show:true, message: 'Your response recorded successfully', type: 'success'};
				component.set("v.toast",toast);
				helper.getFormTemplateRec(component, event, helper);
				window.open('https://www.dlsdc.com','_top')				
			}else{
				var toast = {show:true, message: response, type: 'error'};
				component.set("v.toast",toast);
			}	
		}),
		$A.getCallback(function (errors) {
			component.set("v.showSpinner", false);
			var toast = {show:true, message: errors[0].message, type: 'error'};
			component.set("v.toast",toast);
		}),
		false,
		false,
		false 
		);
	}
})