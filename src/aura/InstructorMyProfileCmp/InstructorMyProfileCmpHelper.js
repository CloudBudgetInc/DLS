({
    getMyProfileRecords: function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        var workExpTableColumns = [{
                'label': 'Company Name',
                'name': 'nameOfCompany',
                'type': 'String',
                'truncate': {
                    "characterLength": 10,
                },
                'sortable': true,
               	'visible': true,
            
            },
            {
                'label': 'Name',
                'name': 'name',
                'type': 'String',
                'sortable': true,
                'visible': false,
            },{
                'label': 'RecordType',
                'name': 'recordType',
                'type': 'String',
                'sortable': true,
                'visible': false,
            },
            {
                'label': 'Role/Job title',
                'name': 'roleTitle',
                'type': 'String',
                'truncate': {},
                'sortable': true,
                'visible': true,
            },
            {
                'label': 'Start Date',
                'name': 'stardDateStr',
                'type': 'String',
                'truncate': {},
                'sortable': true,
                'visible': true,
            },
            {
                'label': 'End Date',
                'name': 'endDateStr',
                'type': 'String',
                'truncate': {},
                'sortable': true,
                'visible': true,
            },
            {
                'label': 'Service(S)',
                'name': 'services',
                'type': 'String',
                'truncate': {},
                'visible': true,
                'sortable': true
            },
            {
                'label': 'City',
                'name': 'city',
                'type': 'String',
                'truncate': {},
                'visible': true,
                'sortable': true
            },
            {
                'label': 'State',
                'name': 'state',
                'type': 'String',
                'truncate': {},
                'visible': true,
                'sortable': true
            },
            {
                'label': 'Country',
                'name': 'country',
                'type': 'String',
                'truncate': {},
                'visible': true,
                'sortable': true
            },
            {
                'label': 'FT/PT',
                'name': 'ftPt',
                'type': 'String',
                'truncate': {},
                'visible': false,
                'sortable': true
            },
            {
                'label': 'Average Hrs Per Week',
                'name': 'averageHrsPerWeek',
                'type': 'String',
                'truncate': {},
                'visible': false,
                'sortable': true
            },
            {
                'label': 'Total # of Hours',
                'name': 'totalHoursPerformed',
                'type': 'String',
                'truncate': {},
                'visible': false,
                'sortable': true
            },
            {
                'label': 'Description',
                'name': 'description',
                'type': 'String',
                'truncate': {},
                'visible': false,
                'sortable': true
            }


        ];

        var educationTableColumns = [{
                'label': 'College/School Name',
                'name': 'collegeSchool',
                'type': 'String',
                'width': 150,
                'truncate': {},
                'sortable': true,
                'visible': true
            },
            {
                'label': 'Name',
                'name': 'name',
                'type': 'String',
                'sortable': true,
                'visible': false,
            },
            {
                'label':'College/School Type',
                'name': 'collegeSchoolType',
                'type': 'String',
                'width': 150,
                'truncate': {},
                'sortable': true,
                'visible': true
            },
            {
                'label': 'Location',
                'name': 'location',
                'type': 'String',
                'truncate': {},
                'width': 100,
                'sortable': true,
                'visible': true
            },
            {
                'label': 'Degree',
                'name': 'degree',
                'type': 'String',
                'truncate': {},
                'visible': true,
                'width': 100,
                'sortable': true
            },
            {
                'label': 'Degree Level',
                'name': 'degreeLevel',
                'type': 'String',
                'truncate': {},
                'visible': true,
                'width': 150,
                'sortable': true
            },
            {
                'label': 'Field Of Concentration',
                'name': 'fieldOfConcentration',
                'type': 'String',
                'truncate': {},
                'visible': true,
                'width': 150,
                'sortable': true
            },
            {
                'label': 'Year Of Completion',
                'name': 'yearOfCompletion',
                'type': 'String',
                'truncate': {},
                'visible': true,
                'width': 165,
                'sortable': true
            }
        ];


        var languageTableColumns = [{
                'label': 'Language Name',
            	'name': 'languageName',
            	'type': 'String',
            	'sortable': false,
            	'visible': true,
                'width': 415,
            },
            {
                'label': 'Name',
                'name': 'name',
                'type': 'String',
                'sortable': false,
                'visible': false,
            },
            {
                'label': 'Native Language',
                'name': 'nativeLanguage',
                'sortable': false,
                'type': 'checkbox',
                'width': 550,
                'visible': true
            }
        ];
        



        var skillTableColumns = [{
                'label': 'Skill Name',
                'name': 'skillName',
                'type': 'String',
                'truncate': {},
                'visible': true,
            },
            {
                'label': 'Name',
                'name': 'name',
                'type': 'String',
                
                'sortable': false,
                'visible': false,
            },
        ];

        //Configuration data for the table to enable actions in the table
        var tableConfig = {
            "massSelect": false,
            "rowAction": [{
                    "type": "image",
                    "class": "imgAction2",
                    "id": "editicon",
                    "src": "/instructor/resource/SLDS_2_1_3/assets/icons/action/edit_60.png",
                },
                {
                    "type": "image",
                    "class": "imgAction1",
                    "id": "deleteicon",
                    "src": "/instructor/resource/SLDS_2_1_3/assets/icons/action/delete_60.png",
                },
            ],
            "rowActionPosition": 'right',
            "paginate": false,
            "searchBox": false

        };

        //configuration for experience
        var experienceTableConfig = {
            "massSelect": false,
            "globalAction": [],
            "rowAction": [{
                    "type": "image",
                    "class": "imgAction2",
                    "id": "editicon",
                    "src": "/instructor/resource/SLDS_2_1_3/assets/icons/action/edit_60.png",
                },
                {
                    "type": "image",
                    "class": "imgAction1",
                    "id": "deleteicon",
                    "src": "/instructor/resource/SLDS_2_1_3/assets/icons/action/delete_60.png",
                },
                {
                    "type": "image",
                    "class": "imgAction2",
                    "id": "viewicon",
                    "src": "/instructor/resource/SLDS_2_1_3/assets/icons/action/more_60.png",
                }
            ],
            "rowActionPosition": 'right',
            "paginate": false,
            "searchBox": false

        };


        // Configuration table for Education and Experience
        var eduTableConfig = {
            "massSelect": false,
            "globalAction": [],
            "rowAction": [{
                    "type": "image",
                    "class": "imgAction2",
                    "id": "editicon",
                    "src": "/instructor/resource/SLDS_2_1_3/assets/icons/action/edit_60.png"
                },
                {
                    "type": "image",
                    "class": "imgAction1",
                    "id": "deleteicon",
                    "src": "/instructor/resource/SLDS_2_1_3/assets/icons/action/delete_60.png"
                },

            ],
            "rowActionPosition": 'right',
            "paginate": false

        };

        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getProfileInformation');
        server.callServer(
            action, {},
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                console.log(JSON.parse(response));
                var result = JSON.parse(response);
                cmp.set("v.contactRec", JSON.parse(JSON.stringify(result.contactRec)));
                cmp.set("v.tableConfig", tableConfig);
                cmp.set("v.eduTableConfig", eduTableConfig);
                cmp.set("v.experienceTableConfig", experienceTableConfig);
                cmp.set("v.languageTableColumns", languageTableColumns);
                cmp.set("v.skillTableColumns", skillTableColumns);
                cmp.set("v.workExpColumns", workExpTableColumns);
                cmp.set("v.educationTableColumns", educationTableColumns);
                cmp.set("v.profileInfo", result);
                cmp.find("languageTable").initialize({
                    "order": "asc"
                });
                cmp.find("skillTable").initialize({
                    "order": "asc"
                });
                cmp.find("workExperience").initialize({
                    "order": "asc"
                });
                cmp.find("educationTable").initialize({
                    "order": "asc"
                });
            }),
            $A.getCallback(function(errors) {
                console.log('errorss',errors);
                cmp.set("v.showSpinner",false);
                helper.showToast(cmp,event, helper,'Error', 'Error found', errors[0].message, null);
            }),
            false,
            false,
            false
        );
    },
    validateUserInputs : function(component,event,helper){
        var validInputs = true;
        var reqInputs = component.find('reqInputs');
        
        if(Array.isArray(reqInputs)){
            for(var i = 0;i < reqInputs.length;i++) {  
                if(!reqInputs[i].get("v.value")) {
                    $A.util.addClass(reqInputs[i], 'slds-has-error'); 
                    validInputs = false;
                }else {   
                    $A.util.removeClass(reqInputs[i], 'slds-has-error');
                }
            }
        }else {
            if(!reqInputs.get("v.value")) {
                $A.util.addClass(reqInputs, 'slds-has-error'); 
                validInputs = false;
            }else {   
                $A.util.removeClass(reqInputs, 'slds-has-error');
            }           
        }
        if(validInputs){
            return true;
        }else{
            return false;
        }
    },
    updateContact: function(cmp, event, helper) {
        
        cmp.set("v.showSpinner", true);
        const server = cmp.find('server');
        const action = cmp.get('c.updateContactRecord');
        var param = {};
        var profileInfo = cmp.get("v.profileInfo");
        param.contactRecord = JSON.stringify(profileInfo.contactRec);
        console.log('after record', JSON.stringify(profileInfo.contactRec));
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                console.log('Contact saved', JSON.stringify(response));
                helper.showToast(cmp, event, helper, 'success', '', 'Contact Information updated successfully', 'sticky');
                // cmp.set("v.profileInfo.contactRec",JSON.stringify(response));
                cmp.set("v.contactRec", JSON.parse(JSON.stringify(cmp.get("v.profileInfo.contactRec"))));
                cmp.set('v.viewMode', true);
                cmp.set("v.showSpinner", false);
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner", false);
                var errmsg;
                
                if(errors.length > 0) {
                    if(errors[0]['message']) {
                        errmsg = errors[0].message;
                    }else if(errors[0]['pageErrors'] && errors[0].pageErrors.length > 0 && errors[0].pageErrors[0].message){
                        errmsg = errors[0].pageErrors[0].message;
                    }else if(errors[0]['fieldErrors'] && errors[0].fieldErrors['Email'] && errors[0].fieldErrors.Email[0].message) {
                        errmsg =  errors[0].fieldErrors.Email[0].message;
                    }
                    helper.showToast(cmp,event, helper,'Error', 'Error found', errmsg, null);
                }
               
            }),
            false,
            false,
            false
        );
    },

    showToast: function(component, event, helper, type, title, message, mode) {
        console.log('msg',message);
                          console.log('typ',type);
		console.log('title',title);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            
            message: message,
            title: title,
            type: type
        });
        toastEvent.fire();
    },
    updateStatus: function(component, event, helper, recordId, actionId) {
        
		//Update the sttaus value if edited or deleted
		
        const server = component.find('server');
        const action = component.get('c.updateStatus');
        server.callServer(
            action, {
                recordId: recordId,
                action: actionId
            },
            false,
            $A.getCallback(function(response) {
                var result = (response);
                console.log('success', result);
            }),
            $A.getCallback(function(errors) {
                console.log('Errors::', errors);
                helper.showToast(cmp,event, helper,'Error', 'Error found', errors[0].message, null);
            }),
            false,
            false,
            false
        );
    },

    componentCreation: function(component, event, helper, tagName, recordId, divId) {
                          
	   //Create Custom Components to render within Aura if condition 
                          
        var db = component.find(divId);
        $A.createComponent(
            tagName, {
                "recordId": recordId,
                "aura:id": tagName
            },
            function(forceTag, status, errorMessage) {
                if (status === "SUCCESS") {
                    var bdy = db.get("v.body");
                    bdy.push(forceTag);
                    db.set("v.body", bdy);
                    window.setTimeout(
                        $A.getCallback(function() {
                            component.set("v.showSpinner", false);
                        }), 2000
                    );

                } else if (status === "INCOMPLETE") {
                    console.log("No response from the server!")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

    closeModal: function(component, event, helper) {

        component.set("v.selectedRec", null);
        if (component.find("EditModal")) {
            component.find("EditModal").close();
        }
        if (component.find("ViewModal")) {
            component.find("ViewModal").close();
        }
        if(component.find("delete")){
            component.find("delete").open();
         }
		component.set("v.newRecModal",false);
        component.set("v.action", null);
        component.set("v.newRecord.language",false);
        component.set("v.newRecord.skill",false);
        component.set("v.newRecord.experience",false);
        component.set("v.newRecord.education",false);
    },
    saveSkill : function(cmp,event,helper){
        var skillrecord = cmp.get("v.skillRecord");
        var skillList = [];
        skillList.push(skillrecord);
        
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.upsertSkill');
        server.callServer(
            action, {'skillJSON' : JSON.stringify(skillList)},
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.newRecModal",false);
                cmp.set("v.action",'');
                self.getMyProfileRecords(cmp, event, helper);
            }),
            $A.getCallback(function(errors) {
                console.log('errorss',errors);
                cmp.set("v.showSpinner",false);
                helper.showToast(cmp,event, helper,'Error', 'Error found', errors[0].message, null);
            }),
            false,
            false,
            false
        );
    },
     checkCurrentUsrIsSessionExpired : function(cmp,event,helper,typeOfAction){
         var self = this;
         const server = cmp.find('server');
         const action = cmp.get('c.checkCurrentUsrIsValid');
         server.callServer(
             action, {},
             false,
             $A.getCallback(function(response) {
                 if(response){
                     if(typeOfAction == 'Edit'){
                         helper.saveRecords(cmp,event,helper);
                     }else if(typeOfAction == 'Create'){
                         helper.onSubmitHelper(cmp,event,helper);
                     }else{
                         cmp.set("v.showSpinner",false);
                     }
                 }else{
                     var objName = '';
                     
                     if(typeOfAction == 'Create'){
                         if(cmp.get("v.newRecord.language")){
                             objName = 'language';
                         }else if(cmp.get("v.newRecord.skill")){
                             objName = 'skill';
                         }else if(cmp.get("v.newRecord.experience")){
                             objName = 'experience';
                         }else if(cmp.get("v.newRecord.education")){
                             objName = 'education';
                         }
                     }else if(typeOfAction == 'Edit'){
                         var tabName =   cmp.set("v.eduExpTabObjName");
                         if(component.set("v.eduExpTabObjName") == 'Language'){
                             objName = 'language';
                         }else if(component.set("v.eduExpTabObjName") == 'Skill'){
                             objName = 'skill';
                         }else if(component.set("v.eduExpTabObjName") == 'Work Experience'){
                             objName = 'experience';
                         }else if(component.set("v.eduExpTabObjName") == 'Education'){
                             objName = 'education';
                         }
                     }
                     
                     var expiredMsg = 'Your session is expried and the changes will not be saved. Please login to add/edit '+objName+' information.';
                     helper.showToast(cmp,event, helper,'Error', 'Error found',expiredMsg, null);
                 }             
             }),
             $A.getCallback(function(errors) {
                 console.log('errorss',errors);
                 cmp.set("v.showSpinner",false);
                 helper.showToast(cmp,event, helper,'Error', 'Error found', errors[0].message, null);
             }),
             false,
             false,
             false
         );
     },
     saveRecords : function(component,event,helper){
         var selectedObj = component.get("v.eduExpTabObjName");
         
         if(selectedObj == 'Skill'){
             var validateInputs = helper.validateUserInputs(component,event,helper);
             if(validateInputs){
                 component.set("v.showSpinner",true);
                 var skillRecord = {};
                 var fromLang = component.get("v.selectedObjLookup").fromLanguage;
                 var toLang = component.get("v.selectedObjLookup").toLanguage;
                 
                 skillRecord['Skill__c'] = component.get("v.skillRecord").Skill__c;
                 skillRecord['Id'] = component.get("v.skillRecord").Id;
                 
                 if(skillRecord.Skill__c == 'Language Training' || skillRecord.Skill__c == 'Curriculum Development' || skillRecord.Skill__c == 'Language Testing' ){
                     if(fromLang.length > 0){
                         skillRecord['From_Language_LU__c'] = fromLang[0].Id;
                     }else{
                         skillRecord['From_Language_LU__c'] = null;
                     }
                 }else if(skillRecord.Skill__c == 'Translation' || skillRecord.Skill__c == 'Interpretation' || skillRecord.Skill__c == 'Localization' ){
                     if(fromLang.length > 0){
                         skillRecord['From_Language_LU__c'] = fromLang[0].Id;
                     }else{
                         skillRecord['From_Language_LU__c'] = null;
                     }
                     if(toLang.length > 0){
                         skillRecord['To_Language_LU__c'] = toLang[0].Id;
                     }else{
                         skillRecord['To_Language_LU__c'] = null;
                     }
                 }
                 component.set("v.skillRecord",skillRecord);
                 helper.saveSkill(component,event,helper);
             }
         }else if(selectedObj == 'Work Experience'){
             event.preventDefault(); // stop form submission
             var eventFields = event.getParam("fields");
             var validateInputs = helper.validateUserInputs(component,event,helper);
             if(validateInputs){
                 component.set("v.showSpinner",true);
                 var isShowWrkExpEndDate = component.get("v.isShowWrkExpEndDate");
                 if((!isShowWrkExpEndDate)){
                     eventFields.End_Date__c = null;  
                 }
                 component.find('Edit Experience').submit(eventFields);
             }
         }else{
             component.set("v.showSpinner",true);
             component.find("force:recordEdit").get("e.recordSave").fire();
             var rec = component.get("v.selectedRec");
             helper.updateStatus(component,event,helper,rec.id,'editicon');
             helper.getMyProfileRecords(component,event,helper);
             helper.closeModal(component,event,helper);
             window.setTimeout(
                 $A.getCallback(function() {
                     component.set("v.showSpinner", false);
                 }), 2000
             ); 
         } 
     },
     onSubmitHelper : function(component,event,helper){
         var eventFields = event.getParam("fields");
         var objName = component.get("v.eduExpTabObjName");
         var validInputs = helper.validateUserInputs(component,event,helper);
         if(validInputs){
             console.log('events fields',component.get("v.profileInfo.contactRec.contactId"))
             
             if(component.get("v.newRecord.skill")){
                 var skillRecord = {};
                 var fromLang = component.get("v.selectedObjLookup").fromLanguage;
                 var toLang = component.get("v.selectedObjLookup").toLanguage;
                 
                 skillRecord.Contact__c = component.get("v.profileInfo.contactRec.contactId");
                 skillRecord.Skill__c = component.get("v.skillRecord").Skill__c;
                 
                 if(skillRecord.Skill__c == 'Language Training' || skillRecord.Skill__c == 'Curriculum Development' || skillRecord.Skill__c == 'Language Testing' ){
                     if(fromLang.length > 0){
                         skillRecord.From_Language_LU__c = fromLang[0].Id;
                     }
                 }else if(skillRecord.Skill__c == 'Translation' || skillRecord.Skill__c == 'Interpretation' || skillRecord.Skill__c == 'Localization' ){
                     if(fromLang.length > 0){
                         skillRecord.From_Language_LU__c = fromLang[0].Id;
                     }
                     if(toLang.length > 0){
                         skillRecord.To_Language_LU__c = toLang[0].Id;
                     }
                 }
                 skillRecord.SobjectType = 'Skill__c'; 
                 component.set("v.skillRecord",skillRecord);
                 component.set("v.showSpinner",true);
                 helper.saveSkill(component,event,helper);
             }else{
                 component.set("v.showSpinner", true);
                 eventFields.Contact__c = component.get("v.profileInfo.contactRec.contactId");
                 component.find(component.get("v.newRecord.choosen")).submit(eventFields);
             }
             console.log('',component.get("v.newRecord.choosen"))
         }
     }
})