({
    getUrlParameter : function(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;
        
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            
            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    },
    getLessonPlans : function(cmp, helper, fromInit) {
        cmp.set("v.showSpinner", true); 
        console.log('lesson plan');
        const server = cmp.find('server');
        const action = cmp.get('c.getLessonPlansFromEventId');
        server.callServer(
            action,
            {'eventId' : cmp.get('v.eventId')},
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner", false);                
                var result = JSON.parse(response);                    
                if(result.errorMsg != ''){
                    helper.showToast(cmp,result.errorMsg,'Error');
                }else{
                    var lessonPlan = result.lessonPlan,
                        lessonPlanHrs = lessonPlan.Lesson_Plan_Hours__r ? lessonPlan.Lesson_Plan_Hours__r.records : [],                    
                        filterValuesMap = Object.assign(result.fieldAPIWithMultiPicklistValuesMap,result.fieldAPIWithPicklistValuesMap); 
                    
                    cmp.set('v.lessonPlanStr', JSON.stringify(lessonPlan));
                    
                    delete lessonPlan.Lesson_Plan_Hours__r;
                    console.log('lessonPlan',JSON.stringify(lessonPlan));
                    cmp.set('v.filterValuesMap', filterValuesMap);
                    cmp.set('v.lessonPlan', lessonPlan);
                    cmp.set('v.lessonPlanHrs', lessonPlanHrs);
                    
                    if(lessonPlan.Box_File_Shared_URL__c != undefined){
                        var sharedURL = lessonPlan.Box_File_Shared_URL__c;
                        var split = sharedURL.split('/');
                        var boxSharedId = split[(split.length - 1)];
                        console.log('boxSharedId : ',boxSharedId);
                        cmp.set("v.sharedLinkId", boxSharedId);
                        cmp.set("v.showBoxCmp", true);
                    }
                    
                    if(fromInit){
                        //cmp.find("lessonPlanModal").open();
                        //cmp.set('v.init', false);
                    }
                }
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                helper.showToast(cmp,errors[0].message,'Error');                
            }),
            false, 
            false,
            false
        );
    },
    saveLessonPlan: function(cmp, event, helper){
        cmp.set("v.showSpinner", true);
        var self = this;
        var lessonPlan = cmp.get('v.lessonPlan');
        lessonPlan.Status__c = 'Completed';
        const server = cmp.find('server');
        const action = cmp.get('c.saveLessonPlansAndLessonPlanHrs');
        server.callServer(
            action,
            {
                'lessonPlan' : JSON.stringify(lessonPlan), 
                'lessonPlanHrs': JSON.stringify(cmp.get('v.lessonPlanHrs')), 
                'lessonPlanHrsToDelete': JSON.stringify(cmp.get('v.lessonPlanHrsToDelete'))
            },
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner", false);
                if(response == 'success'){
                    helper.showToast(cmp,'Lesson Plan and Lesson Plan Hours saved successfully.','SUCCESS');                
                    cmp.set('v.viewMode', !cmp.get('v.viewMode'));
                    helper.getLessonPlans(cmp, helper);
                }else{
                    helper.showToast(cmp,response,'Error');
                }
            }),
            $A.getCallback(function(errors) { 
                console.log(errors);
                cmp.set("v.showSpinner",false);
                console.log(errors[0]);
                helper.showToast(cmp,errors[0].message,'Error');
            }),
            false, 
            false,
            false
        );
    },
    copyPreviousDay: function(cmp, event, helper){
        cmp.set("v.showSpinner", true);
        var self = this;        
        var lessonPlanStr = cmp.get('v.lessonPlanStr');        
        const server = cmp.find('server');
        const action = cmp.get('c.getPreviousDayLessonPlanAndLessonPlanHrs');
        server.callServer(
            action,
            {'lessonPlanStr' : lessonPlanStr},
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner", false);	                
                var result = JSON.parse(response);                
                cmp.set('v.lessonPlan', result.lessonPlan);
                cmp.set('v.lessonPlanHrs', result.lessonPlanHours);                
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                helper.showToast(cmp,errors[0].message,'ERROR');
            }),
            false, 
            false,
            false
        );
    },
    validateRichTextInput: function(component, inputRichText){
        var isValid = true;
    	if(inputRichText.get("v.required") && !inputRichText.get("v.value")){
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
    },
    validateInput: function(component, input){
    	
        var label = input.get("v.label"),
        	  isValid = true;
        $A.util.removeClass(input, "hide-error-message"); 
        if(input.get("v.value") && (label == 'Topic(s)' || label == 'Objective(s)' || label == 'Assessment') && input.get("v.value").length > parseInt(input.get("v.name"))){
            input.setCustomValidity("Maximum supported length is "+parseInt(input.get("v.name"))+ " but entered " +input.get("v.value").length+ " characters.");    			
            hasCharLimit = true;
            isValid = false;
        }else{
            input.setCustomValidity('');
        }
        
        if(!input.checkValidity()){
            isValid = false;
        }
        
        input.reportValidity();
        
        return isValid;
    },
    showToast: function(cmp, msg, type){
        var toast = cmp.get('v.toast');
        toast.isShow = true;
        toast.type = type;
        toast.msg = msg;
		cmp.set('v.toast', toast);
        cmp.find("toastModal").open();
    }
})