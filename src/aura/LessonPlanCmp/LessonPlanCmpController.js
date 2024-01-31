({
	doInit : function(component, event, helper) {
        var communityName = component.get('v.communityName');
        if(!communityName){
            component.set('v.communityName', helper.getUrlParameter('communityName'));
            component.set('v.eventId', helper.getUrlParameter('eventId'));
            component.set('v.modalHeader', helper.getUrlParameter('modalHeader'));
            component.set('v.tabName', helper.getUrlParameter('modalHeader'));
            if(component.get('v.communityName') != 'instructor'){
                component.set('v.allowEdit', false);
            }
        }        
        if(component.get('v.eventId') != null){
            helper.getLessonPlans(component, helper, true);                  
        }
        var toast = {isShow:false,mode:'sticky',type:'',msg:''};
        component.set('v.toast', toast); 
	},
    back: function(component){
        window.close();
    },
    addLessonPlanHrs: function(component, event, helper){
        var lessonPlanHrs = component.get('v.lessonPlanHrs'),
            lessonPlan = component.get('v.lessonPlan');
        lessonPlanHrs.push({Lesson_Plan__c:lessonPlan.Id, Name: 'Hour '+(lessonPlanHrs.length + 1)});
        component.set('v.lessonPlanHrs', lessonPlanHrs);
    },
    onRichTextInputChange: function(component, event, helper){       
       helper.validateRichTextInput(component, event.getSource());
    },
    onInputChange: function(component, event, helper){   
       helper.validateInput(component, event.getSource());
    },
    clearErrorMsg:function(component, event, helper){
        event.getSource().set("v.valid", true);
    },
    removeHideMessageClass: function(component, event, helper){
         $A.util.removeClass( event.getSource(), "hide-error-message"); 
    },
    handleDeleteLessonPlanHrs: function(component, event, helper){
        var lessonPlanHrs = component.get('v.lessonPlanHrs'),
            index = event.getParam("index1"),
            lessonPlanHrsToDelete = component.get('v.lessonPlanHrsToDelete'),
            lessonPlanHr = lessonPlanHrs[index];
        
        lessonPlanHrsToDelete = lessonPlanHrsToDelete ? lessonPlanHrsToDelete : [];
        
        if(lessonPlanHr.Id){
            lessonPlanHrsToDelete.push(lessonPlanHr);
        }
        lessonPlanHrs.splice(index, 1);
        
        for(var i = 0; i < lessonPlanHrs.length;i++){
            lessonPlanHrs[i].Name = 'Hour '+(i+1);
        }
        component.set('v.lessonPlanHrs', lessonPlanHrs);
        component.set('v.lessonPlanHrsToDelete',lessonPlanHrsToDelete);
    },
    handleFileUpload: function(component, event, helper){
        let files = component.get('v.files') ? component.get('v.files') : [],
        	 uploadFiles = event.getSource().get("v.files");
        
        if (uploadFiles.length > 0) {
            for(var i=0; i< uploadFiles.length; i++){                
                let file = uploadFiles[i];
                if (file.size > 2097152) {
                    console.error('File size exceeded the upload size limit.');                    
                }                
                let reader = new FileReader();
                reader.onload = e => {
                    let base64 = reader.result.split(',')[1]
                    let fileData = {
                        'filename': file.name,
                        'base64Str': base64,
                        'tempId': 'file_' + files.length
                    }
                    console.log(fileData);
                    files.push(fileData); 
                	component.set('v.files', files);
                };
                reader.readAsDataURL(file);
            }            
        }      	
    },
    validateFieldsAndSave:function(component, event, helper){
        var inputs = component.find("input"),
            inputRichTexts = component.find('inputRichText'),
            lessonPlanHrsCmps = component.find("lphrs"),
        	isValid = true,
        	hasCharLimit = false;       	
    	console.log(JSON.parse(JSON.stringify(component.get('v.files'))));
        for(let input of inputs){
            
        	var isValidInput = helper.validateInput(component, input);                            
            isValid = isValidInput ? isValid : isValidInput;             
        }
        
        for(let inputRichText of inputRichTexts){
            var isValidRichTextInput = helper.validateRichTextInput(component, inputRichText);
            isValid = isValidRichTextInput ? isValid : isValidRichTextInput;
        }
        
        if(lessonPlanHrsCmps){            
            if(!Array.isArray(lessonPlanHrsCmps))lessonPlanHrsCmps = [lessonPlanHrsCmps];
            for(let lessonPlanHrsCmp of lessonPlanHrsCmps){
                var validationResult = lessonPlanHrsCmp.validate();
                if(!validationResult.isValid){
                    isValid = false;
                }
                if(validationResult.hasCharLimit){
                    hasCharLimit = true;
                }
            }
        }
        
        if(isValid){
            helper.saveLessonPlan(component, event, helper);
        }else{
            helper.showToast(component,'Please complete the required fields.','Error');
        }
    },
	closeLessonPlanModal: function(cmp){        
        //cmp.find("lessonPlanModal").close();
        cmp.set("v.showLessonPlan", false);
    },
    toggleMode: function(cmp){
        var  lessonPlan = JSON.parse(cmp.get('v.lessonPlanStr')),
             lessonPlanHrs = lessonPlan.Lesson_Plan_Hours__r ? lessonPlan.Lesson_Plan_Hours__r.records : [],
             inputs = cmp.find("input"),
             viewMode = cmp.get('v.viewMode');
        
        delete lessonPlan.Lesson_Plan_Hours__r;
        
        cmp.set('v.lessonPlan', lessonPlan);
        cmp.set('v.lessonPlanHrs', lessonPlanHrs);
        
       for(let input of inputs){
           input.setCustomValidity('');
           input.reportValidity();
           input.set('v.validity', true);
           $A.util.removeClass(input, "slds-has-error"); // remove red border
           $A.util.addClass(input, "hide-error-message"); // hide error message
       }
               
        cmp.set('v.viewMode', !viewMode);
    },
    getPreviousDayRec: function(cmp, event, helper){
        helper.copyPreviousDay(cmp, event, helper);
    },
    downloadLessonPlan: function(cmp, event, helper){
        var lessonPlan = cmp.get('v.lessonPlan'),
            communityName = cmp.get('v.communityName'),
            baseUrl = communityName == 'internal' ?  $A.get("$Label.c.Org_Prefix_Start_URL") : (communityName == 'instructor' ? $A.get("$Label.c.Instructor_Community_Site_Prefix") : $A.get("$Label.c.Student_Community_Site_Prefix")),
            url = baseUrl +'/apex/DailyLessonPlanExportPDF?lessonPlanId='+lessonPlan.Id+'&communityname='+communityName;        
       window.open(url, '_blank');      
    },
    closeToast: function(cmp){
        var toast = cmp.get('v.toast');
        toast.isShow = false;
		//cmp.set('v.toast', toast);        
        cmp.find("toastModal").close();
        if(cmp.get('v.init')){
            //cmp.find("lessonPlanModal").close();
        	cmp.set("v.showLessonPlan", false);
        }
    },
    toggleTab: function(component, event, helper){
        component.set("v.tabName",event.currentTarget.dataset.tab)
    },
    handleShowSpinner: function(component, event, helper){
        component.set("v.showSpinner", true);
    },
    handleHideSpinner: function(component, event, helper){
        component.set("v.showSpinner", false);
    },
    handleRefresh: function(component, event, helper){
        var sharedLinkId = event.getParam('sharedLinkId');
        var lessonPlan = component.get('v.lessonPlan');
        if(lessonPlan.Box_File_Shared_URL__c == undefined){
            component.set("v.sharedLinkId", sharedLinkId);
        }

        component.set("v.showBoxCmp", false);
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.showBoxCmp", true);
                component.set("v.showSpinner", false);
            }), 500
       );
    },
})