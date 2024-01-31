({
    validateInput : function(component, event, helper) {
        
        var ValidateRichText = component.find("richText").get("v.value");
        var isValidInput = true;
        
        if(ValidateRichText.includes('*DATE*') || ValidateRichText.includes('*PAID*') || ValidateRichText.includes('*USED*') || ValidateRichText.includes('*REMAINING*')){
            isValidInput = false;
            helper.showToast(component,event,'Warning','Please replace the * quoted text with actual values','warning');
            document.getElementById('topscrollable').scrollIntoView();
        }
        if(isValidInput){
            
            var isValid = helper.inputValidationFunction(component);
            console.log(':::::::isValid:after:::',isValid);
            if(component.get("v.buttonType") == 'New Class Announcement'){
                if(isValid){
                    var file = component.find("fileId").getElement().files[0];
                    if(file){
                        console.log('file--->',file);
                        // create a FileReader object 
                        var objFileReader = new FileReader();
                        // set onload function of FileReader object   
                        objFileReader.onload = $A.getCallback(function() {
                            var fileContents = objFileReader.result;
                            //console.log('fileContents--->',fileContents);
                            var base64 = 'base64,';
                            var dataStart = fileContents.indexOf(base64) + base64.length;
                            
                            fileContents = fileContents.substring(dataStart);
                            console.log("in if")
                            // call the uploadProcess method 
                            helper.sendEmailBtnClick(component,event,file,fileContents);
                        });
                        
                        objFileReader.readAsDataURL(file);
                    }else {
                        helper.sendEmailBtnClick(component,event,null,null);
                    }
                }
            }else if(component.get("v.buttonType") == 'Student Payment Remainder'){
                helper.callStudentPaymentRemainder(component);
            }else if(component.get("v.buttonType") == 'Send Materials Ordered Email'){
                helper.callSendMaterialOrderEmail(component);
            }else if(component.get("v.buttonType") == 'Student On Hold Quarterly Reminder'){
                helper.callStudentOnHoldQuarterlyReminderEmail(component);
            }else if(component.get("v.buttonType") == 'Translator Payment Email Confirmation'){
                helper.callTranslatorPaymentConfirmationEmail(component);
            }
        }
    },
    closeToast : function(cmp, event, helper) {
        //helper.destroyComponent(cmp);
        $A.util.toggleClass(cmp.find("toast"),'slds-hide');
    },
    handleFilesChange : function(component, event, helper){
        var fileName = 'No File Selected..';
        var fileInput = component.find("fileId").getElement().files[0];
        component.set("v.fileName",fileInput.name);
    },
    uploadIconclick : function(component, event, helper){
        component.find("fileId").getElement().click();
    },
    lookupSearch : function(component, event, helper){
        console.log("enter lookup search");
        // Get the getLookupRecords server side action
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('lookup').search(serverSearchAction);
    },
})