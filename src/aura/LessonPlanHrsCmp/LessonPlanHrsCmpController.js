({
    doInit: function(component, event, helper){
        var selectedSkillFocusValues = [],
            selectedActivities = [],
            lessonPlanHrs = component.get('v.lessonPlanHrs');
        
        if(lessonPlanHrs.Skill_Focus__c)
        	selectedSkillFocusValues = lessonPlanHrs.Skill_Focus__c.split(';'); 
        if(lessonPlanHrs.Activities__c)
        	selectedActivities = lessonPlanHrs.Activities__c.split(';'); 
       
        component.set('v.selectedSkillFocusValues', selectedSkillFocusValues);
        component.set('v.selectedActivities', selectedActivities);
    },
    onInputChange: function(component, event, helper){       
       helper.validateRichTextArea(component, event.getSource());
    },
	deleteLessonPlanHrs : function(component, event, helper) {        
		var compEvent = component.getEvent("deleteLessonHrs");
		compEvent.setParams({"index1" : component.get('v.index') });
		compEvent.fire();
	},
    populateSkillFocusChange: function(component, event, helper){
        var selectedSkillFocusValues = component.get('v.selectedSkillFocusValues'),
            lessonPlanHrs = component.get('v.lessonPlanHrs');
        
        lessonPlanHrs.Skill_Focus__c = selectedSkillFocusValues.join(";");
        component.set('v.lessonPlanHrs', lessonPlanHrs);
        
    },
    populateActivitiesChange: function(component, event, helper){
        var selectedActivities = component.get('v.selectedActivities'),
            lessonPlanHrs = component.get('v.lessonPlanHrs');
        
        lessonPlanHrs.Activities__c = selectedActivities.join(";");
        component.set('v.lessonPlanHrs', lessonPlanHrs);
        
    },
    validateLessonPlanHrs : function(component, event, helper){
        var inputCmps=component.find("inputCmp"),
            inputRichText = component.find("input"),
        	isValid = true,
            hasCharLimit = false;
        
        for(var inputCmp of inputCmps){
            if(inputCmp.checkForValues())
        		isValid = false;
        }
        var isRichTextValid = helper.validateRichTextArea(component, inputRichText);
        isValid = isRichTextValid ? isValid : isRichTextValid;
        return {isValid: isValid, hasCharLimit: hasCharLimit};
    }
})