({
	doInit : function(cmp, event, helper) {
        helper.getMyProfileRecords(cmp, event, helper);
         cmp.set('v.viewMode',false);
    },
    cancelEdit : function(cmp, event, helper) {
       
        // Switch Edit mode and View Mode 
        
        cmp.set("v.showSpinner",true);
        cmp.set('v.profileInfo.contactRec',cmp.get("v.contactRec"));
        cmp.set('v.viewMode',true);
        window.setTimeout(
            $A.getCallback(function() {
                cmp.set("v.showSpinner",false);
            }), 1000);
    },
    
    saveContact : function(cmp, event, helper){
        helper.updateContact(cmp, event, helper);
    },
    editContactInfo : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        cmp.set('v.viewMode',false);
        window.setTimeout(
            $A.getCallback(function() {
                cmp.set("v.showSpinner",false);
            }), 1000);
    },
    
    tabActionClicked : function(component, event, helper) {
        
        
        var row = event.getParam('row');
        component.set("v.selectedRec",row);
        var actionId = event.getParam('actionId');
        if(actionId == 'editicon'){
            var rowIdx = event.getParam("index");
            component.set("v.rowIndex",rowIdx);
            component.set("v.action",'EditAction');
            component.find('EditModal').open();
        }else if(actionId == 'deleteicon'){
            component.set("v.action",'DeleteAction');
            component.find('delete').open();
        }
    },
    closeEdit : function(component , event,helper){
        //Close the all opended modals 
        
        component.set("v.action",'');
        if(component.find('EditModal')){
            component.find('EditModal').close();
        }
        if(component.find('delete')){
            component.find('delete').close();
        }
    },
    
    saveFieldChanges : function(component ,event,helper){
         
        component.set("v.showSpinner",true);
        var selectedRec = component.get("v.selectedRec");
        var updatedRec = component.get("v.fieldsList");
        console.log('updatedRec',JSON.stringify(updatedRec));
        var isRowUpdated = component.get("v.isRowUpdated");
        var sectionName = selectedRec.sobjectName;
        var apiLabelMap = {};
        if(sectionName == 'Education'){
            apiLabelMap = component.get("v.educationWrapper");
            console.log('api',apiLabelMap);
            for(var i = 0; i < updatedRec.length; i++){
                var rowRecApi = apiLabelMap[updatedRec[i].apiName]; //Will return the wrappername which is in table 
                var selectedValue = updatedRec[i].selectedValue;   //get the table value 
                if(selectedRec[rowRecApi] != selectedValue){		//Compare the table value with new value , if changes happen update it in table record
                    selectedRec[rowRecApi] = selectedValue;
                }
            }
        }
        if(sectionName == 'Known Language'){
            apiLabelMap = component.get("v.languageWrapper");
            for(var i = 0; i < updatedRec.length; i++){
                console.log(JSON.stringify(updatedRec[i]));
                var selectedValue;
                var rowRecApi = apiLabelMap[updatedRec[i].apiName];
                if(updatedRec[i].fieldType == 'REFERENCE'){
                    selectedValue = updatedRec[i].lookUpList[0].Name;
                    
                }else{
                    selectedValue = updatedRec[i].selectedValue;
                }
                if(selectedRec[rowRecApi] != selectedValue){
                    selectedRec[rowRecApi] = selectedValue;
                    isRowUpdated = true;
                }
            }
        }
        if(sectionName == 'Skill'){
            apiLabelMap = component.get("v.skillWrapper");
            for(var i = 0; i < updatedRec.length; i++){
                var rowRecApi = apiLabelMap[updatedRec[i].apiName];
                var selectedValue = updatedRec[i].selectedValue;
                if(selectedRec[rowRecApi] != selectedValue){
                    selectedRec[rowRecApi] = selectedValue;
                }
            }
        }
        if(sectionName == 'Experience'){
            apiLabelMap = component.get("v.expWrapper");
            for(var i = 0; i < updatedRec.length; i++){
                var rowRecApi = apiLabelMap[updatedRec[i].apiName];
                var selectedValue = updatedRec[i].selectedValue;
                if(selectedRec[rowRecApi] != selectedValue){
                    selectedRec[rowRecApi] = selectedValue;
                }
            }
        }
        component.set("v.selectedRec",selectedRec);
        component.set("v.isRowUpdated",false);     //set false the recordupdate boolean
        if(isRowUpdated){
            selectedRec.isChanged = true;
            var rowIndex = component.get("v.rowIndex");
            component.find(sectionName).updateRow(rowIndex,selectedRec);  //Update with changed values by table row index
            var finalRecsList = component.get("v.updatedRecords");
            var recObj = {};
            
            //Form the updated records with its api name , it will easuer to update in apex controller
            
            for(var i = 0; i < updatedRec.length;i++){
                recObj['Id'] = selectedRec.id;
                if(updatedRec[i].apiName == 'Language__c' && sectionName == 'Known Language'){
                    recObj[updatedRec[i].apiName] = updatedRec[i].lookUpList[0].Id;
                }else{
                    recObj[updatedRec[i].apiName] = updatedRec[i].selectedValue;
                }
                
            }
           
            var isDuplicate = false;
            if(sectionName == 'Skill'){
                for(var i = 0;i < finalRecsList.skill.length;i++){
                console.log((finalRecsList.skill[i].Id));
                    if(finalRecsList.skill[i].Id == selectedRec.id){
                        isDuplicate = true;                           //If any  record already in the final list  duplicate error will raise , so update the existing record
                        finalRecsList.skill[i] = recObj;
                    }
            }
                if(!isDuplicate){
                    finalRecsList.skill.push(recObj);
                }
            }else if(sectionName == 'Known Language'){
                
                for(var i = 0;i < finalRecsList.languages.length;i++){
                    console.log((finalRecsList.languages[i].Id));
                    if(finalRecsList.languages[i].Id == selectedRec.id){
                        isDuplicate = true;
                        finalRecsList.languages[i] = recObj;
                    }
                }
                if(!isDuplicate){
                    finalRecsList.languages.push(recObj);
                }
            }else if(sectionName == 'Experience'){
                for(var i = 0;i < finalRecsList.experience.length;i++){
                    console.log((finalRecsList.experience[i].Id));
                    if(finalRecsList.experience[i].Id == selectedRec.id){
                        isDuplicate = true;
                        finalRecsList.experience[i] = recObj;
                    }
                }
                if(!isDuplicate){
                    finalRecsList.experience.push(recObj);
                }
            }else if(sectionName == 'Education'){
                for(var i = 0;i < finalRecsList.education.length;i++){
                    console.log((finalRecsList.education[i].Id));
                    if(finalRecsList.education[i].Id == selectedRec.id){
                        isDuplicate = true;
                        finalRecsList.education[i] = recObj;
                    }
                }
                if(!isDuplicate){
                    finalRecsList.education.push(recObj);
                }
            }
            component.set("v.updatedRecords",finalRecsList);
            
        }
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.showSpinner",false);
                component.set("v.action",'');
            }), 1000);
    },
    finalSubmit : function(cmp ,event,helper){
        
        var sectionName = event.getSource().get("v.name");
        var finalRecsList = {};
        finalRecsList = cmp.get("v.updatedRecords");
        var updateList = [];
        if(sectionName == 'Skill'){
           updateList = finalRecsList.skill;
        }else if(sectionName == 'Known Language'){
            updateList = finalRecsList.languages;
        }else if(sectionName == 'Experience'){
            updateList = finalRecsList.experience;
        }else if(sectionName == 'Education'){
            updateList = finalRecsList.education;
        }
        console.log('update list',updateList)
        if(updateList != null && updateList.length > 0){
            cmp.set("v.showSpinner",true);
            var self = this;
            const server = cmp.find('server');
            const action = cmp.get('c.updateRecords');
            server.callServer(
                action, {finalRecsList : updateList},
                false,
                $A.getCallback(function(response) {
                    var result = response;
                    cmp.set("v.fieldsList",[]);
                    cmp.set("v.updatedRecords",[]);
                    helper.getMyProfileRecords(cmp, event, helper);
                    window.setTimeout(
                        $A.getCallback(function() {
                            cmp.set("v.showSpinner",false);
                        }), 1000);
                }),
                $A.getCallback(function(errors) {
                    helper.showToast(cmp, event, helper, 'error','Error Found',errors[0].message,null);
                    window.setTimeout(
                        $A.getCallback(function() {
                            cmp.set("v.showSpinner",false);
                        }), 1000);
                }),
                false,
                false,
                false
            ); 
        }else{
            helper.showToast(cmp, event, helper, 'info','Warning','No Records found for update',null);
        }
        
        
    },
    
    cancel : function(cmp ,event,helper){
        var conId = cmp.get("v.profileInfo.contactRec.contactId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": conId,
            "slideDevName": "details"
        });
        navEvt.fire();
    },
    deleteRecord : function(component,event,helper){
                
        if(component.find('delete')){
            component.find('delete').close();
        }
        component.set("v.action",'');
        var row = component.get("v.selectedRec");
        component.set("v.showSpinner",true);
        var self = this;
            const server = component.find('server');
            const action = component.get('c.recordDelete');
            server.callServer(
                action, {recId : row.id},
                false,
                $A.getCallback(function(response) {
                    var result = response;
                    helper.getMyProfileRecords(component, event, helper);
                    window.setTimeout(
                        $A.getCallback(function() {
                            component.set("v.showSpinner",false);
                        }), 1000); 
                }),
                $A.getCallback(function(errors) {
                    helper.showToast(component, event, helper, 'error','Error Found',errors[0].message,null);
                    window.setTimeout(
                        $A.getCallback(function() {
                            component.set("v.showSpinner",false);
                            if(component.find('delete')){
                                component.find('delete').close();
                            }
                            component.set("v.action",'');
                        }), 1000);
                }),
                false,
                false,
                false
            ); 
        console.log(row.id);
    }
})