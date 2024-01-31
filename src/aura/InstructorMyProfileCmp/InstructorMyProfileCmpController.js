({
    doInit : function(cmp, event, helper) {
        console.log('Do init');
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            cmp.set("v.displayDevice",'Mobile');
        } else {
            cmp.set("v.displayDevice",'PC');
        }
        cmp.set("v.showSpinner",true);
        helper.getMyProfileRecords(cmp, event, helper);
    },
    
    editContactInfo : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        cmp.set('v.viewMode',false);
        window.setTimeout(
            $A.getCallback(function() {
                cmp.set("v.showSpinner",false);
            }), 1000);
    },
    
    cancelEdit : function(cmp, event, helper) {
        
        console.log('Contact Rec:::',JSON.stringify(cmp.get("v.contactRec")));
        var conInputfields = cmp.find("inputFields");
        cmp.set("v.showSpinner",true);
        cmp.set('v.profileInfo.contactRec',JSON.parse(JSON.stringify(cmp.get("v.contactRec"))));
        cmp.set('v.viewMode',true);
        window.setTimeout(
            $A.getCallback(function() {
                if(Array.isArray(conInputfields)){
                    for(var i = 0;i < conInputfields.length;i++) {   
                        $A.util.removeClass(conInputfields[i], 'slds-has-error');
                    }
                } 
                cmp.set("v.showSpinner",false);
            }), 1000);
    },
    
    saveContact : function(cmp, event, helper){
        var conInputfields = cmp.find("inputFields");
        var isValidInputs = true;
        
        if(Array.isArray(conInputfields)){
            for(var i = 0;i < conInputfields.length;i++) {   
                if(!conInputfields[i].get("v.value")) {
                    $A.util.addClass(conInputfields[i], 'slds-has-error'); 
                    isValidInputs = false;
                }else {   
                    $A.util.removeClass(conInputfields[i], 'slds-has-error');
                }
            }
        } 
        
        if(isValidInputs) {
            var contactRec = cmp.get("v.profileInfo.contactRec");
            var oldContactRec = cmp.get("v.contactRec");
            
           
           
            if(oldContactRec.email != contactRec.email){
                
                cmp.set("v.showUserEmailUpdationModal",true);
                cmp.find("userMailUpdate").open();
            }else{
                helper.updateContact(cmp, event, helper);
             }
        }
    },
    updateContactAndUser : function(cmp, event, helper){
        helper.updateContact(cmp, event, helper);
        cmp.set("v.showUserEmailUpdationModal",false);
    },
    tabActionClicked : function(component, event, helper) {
        
        var rectarget = event.currentTarget;
        var rowInfo = rectarget.getAttribute("data-name");
        var rowId = rowInfo.split("/")[0];
        var sObjectName = rowInfo.split("/")[1];
        var rowAction = rowInfo.split("/")[2];
        var languageList = component.get("v.profileInfo.languageList");
        var skillList = component.get("v.profileInfo.skillList");
        var workExperianceList = component.get("v.profileInfo.workExperianceList");
        var educationList = component.get("v.profileInfo.educationList");
        var selectedObjLookup = component.get("v.selectedObjLookup");
        selectedObjLookup.fromLanguage = [];
        selectedObjLookup.toLanguage = [];
        component.set("v.selectedObjLookup",selectedObjLookup);
        component.set("v.eduExpTabObjName",'');
        var row = {};
        
        if(sObjectName == 'Language') {
            component.set("v.eduExpTabObjName",'Language');
            for(var i = 0; i < languageList.length;i++) {
                if(languageList[i].id == rowId) {
                    row = languageList[i];
                }
            }
        }else if(sObjectName == 'Skill') {
            component.set("v.eduExpTabObjName",'Skill');
            for(var i = 0; i < skillList.length;i++) {
                if(skillList[i].id == rowId) {
                    row = skillList[i];
                }
            }
        }else if(sObjectName == 'WorkExp') {
            component.set("v.eduExpTabObjName",'Work Experience');
            for(var i = 0; i < workExperianceList.length;i++) {
                if(workExperianceList[i].id == rowId) {
                    row = workExperianceList[i];
                }
            }
        }else if(sObjectName == 'Education') {
            component.set("v.eduExpTabObjName",'Education');
            for(var i = 0; i < educationList.length;i++) {
                if(educationList[i].id == rowId) {
                    row = educationList[i];
                }
            }
        }
        component.set("v.showSpinner",true);
        component.set("v.action",rowAction);
        console.log(JSON.stringify(row));
        component.set("v.selectedRec",row);
        if(rowAction == 'editAction'){
            if(sObjectName == 'Skill'){
                var selectedObjLookup = component.get("v.selectedObjLookup");
                var skillRecord = {};
                if(row.fromLanguage && row.toLanguage){
                    selectedObjLookup.fromLanguage.push({'Id':row.fromLanguageId,'Name':row.fromLanguage}); 
                    selectedObjLookup.toLanguage.push({'Id':row.toLanguageId,'Name':row.toLanguage}); 
                }else if(row.fromLanguage){
                    selectedObjLookup.fromLanguage.push({'Id':row.fromLanguage.Id,'Name':row.fromLanguage}); 
                }
                skillRecord['Id'] = row.id;
                skillRecord['Skill__c'] = row['skill'];
                component.set("v.selectedObjLookup",selectedObjLookup);
                component.set("v.skillRecord",skillRecord);
            }else if(sObjectName == 'WorkExp'){
                if(row['endDateStr'] && row['endDateStr'] != 'Present'){
                    component.set("v.isShowWrkExpEndDate",true);
                }else{
                    component.set("v.isShowWrkExpEndDate",false);
                }
            }else{
                helper.componentCreation(component ,event,helper,'force:recordEdit',row.id ,'editForm');
                component.set("v.showSpinner", true); 
            }
            component.find("EditModal").open();
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.showSpinner", false);
                }), 2000);
        }else if(rowAction=='deleteAction'){
            console.log('delete ')
            component.set("v.action",'deleteModal');
            console.log('modal opened');
            if(component.find("delete")){
                component.find("delete").open();
            }
            component.set("v.showSpinner",false);
        }else if(rowAction == 'viewMoreAction'){
            component.find("ViewModal").open();
            component.set("v.showSpinner",false);
        }
    },
    save : function(component, event, helper) {
        event.preventDefault(); 
        helper.checkCurrentUsrIsSessionExpired(component,event, helper,'Edit');
    },
    closeModel : function(component , event , helper){
        component.set("v.newRecModal",false);
        helper.closeModal(component,event,helper);
    },
    createNewRec : function(component , event , helper){
        component.set("v.showSpinner",true);
        component.set("v.newRecModal",true);
        var action = event.getSource().get("v.name");
        component.set("v.newRecord.language",false);
        component.set("v.newRecord.skill",false);
        component.set("v.newRecord.experience",false);
        component.set("v.newRecord.education",false);
        component.set("v.isShowWrkExpEndDate",true);
        
        var selectedObjLookup = component.get("v.selectedObjLookup");
        selectedObjLookup.fromLanguage = [];
        selectedObjLookup.toLanguage = [];
        component.set("v.selectedObjLookup",selectedObjLookup);
        
        console.log('label is',action);
        if(component.find("newRecModal")){
            if(action == 'Add Known Language'){
                component.set("v.newRecord.language",true);
                component.set("v.newRecord.choosen",'Add Known Language');
                component.set("v.objectName",'Known_Language__c');
            }else if(action == 'Add Skill'){
                component.set("v.skillRecord",{});
                component.set("v.newRecord.skill",true);
                component.set("v.objectName",'Skill__c');
                component.set("v.newRecord.choosen",'Add Skill');
            }else if(action == 'Add Experience'){
                component.set("v.newRecord.experience",true);
                component.set("v.objectName",'Experience__c');
                component.set("v.newRecord.choosen",'Add Experience');
            }else if(action == 'Add Education'){
                component.set("v.newRecord.education",true);
                component.set("v.objectName",'Experience__c');
                component.set("v.newRecord.choosen",'Add Education');
            }
        }
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.showSpinner", false);
            }), 2000
        );
        
    },
    
    Recsuccess : function(component , event,helper){
        
        var payload = event.getParams().response;
        console.log(payload.id);
        if(component.find("newRecModal")){
            component.find("newRecModal").close();
        }
        component.set("v.action", null);
        helper.getMyProfileRecords(component,event,helper);
    },
    handleSuccess : function(component ,event,helper){
        console.log('Success');
        var payload = event.getParams().response;
        console.log(payload.id);
        component.set("v.showSpinner", true);
        helper.closeModal(component,event,helper);
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.showSpinner", false);
                helper.getMyProfileRecords(component,event,helper);
            }), 1000
        );
    },
    handleError : function(component ,event,helper){
        console.log('error')
        var errors = event.getParams();
        console.log(JSON.stringify(errors));
        helper.showToast(component, event, helper, 'error',errors.message, 'Error Found',null);
    },
    deleteRecord : function(component ,event , helper){
        component.set("v.showSpinner", true);
        var row = component.get("v.selectedRec");
        helper.updateStatus(component,event,helper,row.id,'deleteicon');
        console.log('status updated')
        helper.getMyProfileRecords(component,event,helper);
        helper.closeModal(component,event,helper);
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.showSpinner", false);
            }), 2000
        );
    },
    onSubmit : function(component ,event,helper){
        event.preventDefault(); // stop form submission
        helper.checkCurrentUsrIsSessionExpired(component,event, helper,'Create');
    },   
    toggleTab: function(component, event, helper){
        component.set("v.tabName",event.currentTarget.dataset.tab)
    },
    skillFromLangLookupSearch : function(component ,event, helper){
        const serverSearchAction = component.get('c.getLookupRecords');
        component.find('fromLang').search(serverSearchAction);
    },
    skillToLangLookupSearch : function(component ,event, helper){
        const serverSearchAction = component.get('c.getLookupRecords');
        component.find('toLang').search(serverSearchAction);
    },
    skillLangLookupSearch : function(component ,event, helper){
        const serverSearchAction = component.get('c.getLookupRecords');
        component.find('lang').search(serverSearchAction);
    },
    showWorkExpEndDate : function(component ,event,helper){
        component.set("v.isShowWrkExpEndDate",true);
    },
    showPresentText : function(component ,event,helper){
        component.set("v.isShowWrkExpEndDate",false);
    }
})