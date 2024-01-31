({
    inputValidationFunction : function(cmp){
        var contentVal = cmp.get("v.contentInput");
        var isValid = true;
        
        if(!contentVal.fromAddress){
            isValid = false;
            var fromtag = cmp.find("fromVal");
            $A.util.addClass(fromtag,"slds-has-error");
        }else{
            var fromtag = cmp.find("fromVal");
            $A.util.removeClass(fromtag,"slds-has-error");
        }
        
        if(!contentVal.subject){
            isValid = false;
            var subjectcmp = cmp.find("subject");
            $A.util.addClass(subjectcmp,"slds-has-error");
        }else {
            var subjectcmp = cmp.find("subject");
            $A.util.removeClass(subjectcmp,"slds-has-error");
        }
        console.log('::isValid:::::::',isValid);
        return isValid;
    },
    sendEmailBtnClick : function(component,event,file,fileContents) {
        var contentArray = [];
        contentArray.push(component.get("v.contentInput"));
        
        var action = component.get("c.sendNewClassAnnouncementEmail");
        if(fileContents){
            action.setParams({
                "contentJson" : JSON.stringify(contentArray),
                "fileName" : file.name,
                "contentType" : file.type,
                "base64Data" : encodeURIComponent(fileContents)
            });
        }else{
            action.setParams({
                "contentJson" : JSON.stringify(contentArray),
                "fileName" : null,
                "contentType" : null,
                "base64Data" : null
            });
        }
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                this.showToast(component,event,'Success','Email Send Successfully','success');
                $A.get("e.force:closeQuickAction").fire();
            }else {
                console.log('::::::error::::',response.getError()[0]);
                this.showToast(component,event,'Error',response.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(cmp, event, title,message,type) {
        console.log(':::::::message:::',message);
        var mode = 'sticky';
        var duration  = 5000;
        cmp.set("v.type", type);
        cmp.set("v.message", message);
        
        $A.util.toggleClass(cmp.find("toast"),'slds-hide');
        if(type === 'success'){
            var toastTheme = cmp.find("toastTheme");
            $A.util.addClass(toastTheme, 'slds-theme--success');
            window.setTimeout($A.getCallback(function(){
                //helper.destroyComponent(cmp);
                $A.util.toggleClass(cmp.find("toast"),'slds-hide');
            }),duration);
            
        }else {
            var toastThemeError = cmp.find("toastTheme");
            $A.util.addClass(toastThemeError, 'slds-theme--error');
            if(mode !== 'sticky'){
                window.setTimeout($A.getCallback(function(){
                    //helper.destroyComponent(cmp);
                    $A.util.toggleClass(cmp.find("toast"),'slds-hide');
                }),duration);
            }
        }
        
    },
    destroyComponent : function(component) {
        $A.util.toggleClass(component.find("toast"),'slds-hide');
        //component.destroy();
    },
    callStudentPaymentRemainder : function(cmp){
		var contentArray = [];
        contentArray.push(cmp.get("v.contentInput"));
        
        var action =  cmp.get("c.sendStudentPaymentRemainderEmail");
        action.setParams({
            "contentJson" : JSON.stringify(contentArray)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                 this.showToast(cmp,event,'Success','Email Send Successfully','success');
                $A.get("e.force:closeQuickAction").fire();
            }else {
                console.log('::::::error::::',response.getError()[0]);
                this.showToast(cmp,event,'Error',response.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(action);
    },
    callStudentOnHoldQuarterlyReminderEmail: function(cmp){
		
        var action =  cmp.get("c.sendStudentOnHoldQuarterlyReminderEmail");
        action.setParams({
            "contentJson" : JSON.stringify(cmp.get("v.contentInput"))
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                 this.showToast(cmp,event,'Success','Email Send Successfully','success');
                $A.get("e.force:closeQuickAction").fire();
            }else {
                console.log('::::::error::::',response.getError()[0]);
                this.showToast(cmp,event,'Error',response.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(action);
    },
    callSendMaterialOrderEmail : function(cmp){
        var contentArray = [];
        contentArray.push(cmp.get("v.contentInput"));
        
        var action =  cmp.get("c.sendMaterialOrderEmail");
        action.setParams({
            "contentJson" : JSON.stringify(contentArray)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                 this.showToast(cmp,event,'Success','Email Send Successfully','success');
                $A.get("e.force:closeQuickAction").fire();
            }else {
                console.log('::::::error::::',response.getError()[0]);
                this.showToast(cmp,event,'Error',response.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(action);
    },
    callTranslatorPaymentConfirmationEmail : function(cmp){
        
        var action =  cmp.get("c.sendTranslatorPaymentConfirmationEmail");
        action.setParams({
            "contentJson" : JSON.stringify(cmp.get("v.contentInput"))
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                 this.showToast(cmp,event,'Success','Email Send Successfully','success');
                $A.get("e.force:closeQuickAction").fire();
            }else {
                console.log('::::::error::::',response.getError()[0]);
                this.showToast(cmp,event,'Error',response.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(action);
    }
    
})