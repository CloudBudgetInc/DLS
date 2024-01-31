({
	validateRichTextArea : function(component, inputRichText) {
        var isValid = true;
		if(!inputRichText.get("v.value") && inputRichText.get("v.required")){
        	inputRichText.set("v.valid", false);
            inputRichText.set("v.messageWhenBadInput", "Please complete this field.");
            isValid = false;
        }else if(inputRichText.get("v.value") && inputRichText.get("v.value").length > parseInt(inputRichText.get("v.label"))){
            inputRichText.set("v.valid", false);
            inputRichText.set("v.messageWhenBadInput", "Maximum supported length is "+parseInt(inputRichText.get("v.label"))+ " but entered " +inputRichText.get("v.value").length+ " characters.");
            isValid = false;
            hasCharLimit = true;
        }else{
            inputRichText.set("v.valid", true);
        }
        return isValid;
	}
})