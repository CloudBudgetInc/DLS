({
    
    getExistingCARelInfo :function(cmp,event,helper) {
        
        var  permissionAccess = cmp.get("v.actionPerform");
        console.log('::::::sObjectName::::',cmp.get("v.sObjectName"));
        console.log('::::::recordId::::',cmp.get("v.recordId"));
        console.log('::::::recordTypeName',cmp.get("v.recordTypeName"));
        var action = cmp.get("c.getCARelatedInformation");
        action.setParams({
            "caRecordId" :cmp.get("v.caRecordId"),
            "caRTName" : cmp.get("v.recordTypeName"),
            "parentType" :cmp.get("v.sObjectName"),
            "parentId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                cmp.set("v.defaultCostRate","");
                var result = response.getReturnValue();
                console.log("result::::::",result);
                var caRecord = {};
                var cRCreationObj = {};
                
                caRecord = result.caRecord;
                
                if(result.dliProjectType){
                    caRecord.dliProjectType = result.dliProjectType;
                }else{
                    caRecord.dliProjectType = null; 
                }
                caRecord.showSchObservation = result.showSchObservation;
                                
                console.log(caRecord);
                cRCreationObj.isOPIPT = result.isOPLIPT;
                cRCreationObj.isNewCA = result.isNew;
                cRCreationObj.existingAwarded = result.existingAwarded;
                cmp.set("v.cRCreationObj", cRCreationObj);
                
                cmp.set("v.oppStageName",result.oppStageName);
                cmp.set("v.parentRecordType",result.parentRecordType);
                cmp.set("v.caRecord",caRecord);
                cmp.set("v.oldCARecord",JSON.parse(JSON.stringify(result.caRecord)));
                cmp.set("v.cADetails",result);
                cmp.set("v.defaultCostRate",result.defaultCostRate);
                cmp.set("v.displayCRPicklist",result.displayCRPicklist);
                cmp.set("v.profileName",result.profileName);
                cmp.set("v.parentStartDate",result.parentStDate);
                cmp.set("v.parentEndDate",result.parentEdDate);
                
                var  picklistValues = (result.pickValues);
                console.log('inputPicklistValues',picklistValues);
                helper.inputPicklistValues(cmp,event,helper,picklistValues);
                
                cmp.set("v.showSpinner",false);
                
                if(permissionAccess == 'Edit'){
                    
                    if(cmp.get("v.caRecord").Rate_Card_Rate__c != null){
                        cmp.set("v.costlookup",'Approved');
                    }else if(cmp.get("v.caRecord").Drafted_Labor_Cost_Rate__c != null){
                        cmp.set("v.costlookup" ,'NOTApproved');
                    }
                }  
                if(permissionAccess == 'Delete'){
                    this.validateInsEndStatusEditDel(cmp,event,helper);
                }else{
                    if(Array.isArray(cmp.find("addModel"))) {
                        cmp.find("addModel")[0].open();
                    }else{
                        cmp.find("addModel").open();
                    }                    
                    cmp.set("v.scorePicklist",true);
                }
                
            }else {
                console.log("::::::::error:::",response.getError()[0].message);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message : response.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();  
            }
        });
        $A.enqueueAction(action);
    },
    
    validationToCreateCA : function(cmp,event,helper) {
        
        var otherInputField = cmp.find('otherInputField');
        var dateInputField = cmp.find('dateInputField');
        var isValid = true;
        var parentRecordType = cmp.get("v.parentRecordType");
        var profileName = cmp.get("v.profileName");
        var parentStartDate = cmp.get("v.parentStartDate") || '';
        var parentEndDate = cmp.get("v.parentEndDate") || '';
        var cARTName = cmp.get("v.recordTypeName");
        var caRecord = cmp.get("v.caRecord");
        var actionPerform = cmp.get("v.actionPerform");
        var caDetail = cmp.get("v.cADetails")
        
        if((parentRecordType == 'Interpretation_Projects' || parentRecordType == 'Translation_Projects') && cARTName == 'Instructor'){
            var qtyInput = cmp.find("qtyInput");
            var invoiceInput = cmp.find("invoiceInput");
            
            if(caRecord.Status__c == 'Ended'){
                if(!invoiceInput.get("v.value")){
                    isValid = false;
                    invoiceInput.set("v.errors", [{message:" "}]);
                }else{
                    invoiceInput.set("v.errors", null);
                }
                if(!qtyInput.get("v.value")){
                    $A.util.addClass(qtyInput, 'slds-has-error'); 
                }else {
                    $A.util.removeClass(qtyInput, 'slds-has-error'); 
                }
            }else if( cmp.get("v.caRecord").Status__c != 'Ended'){
                invoiceInput.set("v.errors", null);
                $A.util.removeClass(qtyInput, 'slds-has-error'); 
            }
        }
        
        if(!invoiceInput){
            cmp.get("v.caRecord").Invoice_Date__c = null; 
        }
        
        if(actionPerform == 'Create' && (cmp.get("v.caRecord").Assignment_Position__c == 'Substitute Instructor'
                                     || cmp.get("v.caRecord").Assignment_Position__c == 'Tester') 
           						     && cARTName  == 'Instructor'){
            cmp.get("v.caRecord").Schedule_Observation__c = null; 
        }
        
        cmp.set("v.caRecord",  cmp.get("v.caRecord"));
        if(Array.isArray(otherInputField)){
            for(var i = 0;i < otherInputField.length;i++) { 
                
                if(Array.isArray(otherInputField[i].get("v.value")) && otherInputField[i].get("v.value").length == 0){
                    $A.util.addClass(otherInputField[i], 'slds-has-error'); 
                    isValid = false;   
                }
                
                if(!otherInputField[i].get("v.value")) {
                    $A.util.addClass(otherInputField[i], 'slds-has-error'); 
                    isValid = false;
                }else {   
                    $A.util.removeClass(otherInputField[i], 'slds-has-error');
                }
            }
        }else  {
            if(!otherInputField.get("v.value")) {
                $A.util.addClass(otherInputField, 'slds-has-error');
                isValid = false;
            }
        }
        if(cmp.get("v.oppStageName") == "Inquiry - Responded"){
            
            var stDate = caRecord.Start_Date__c;
            var edDate = caRecord.End_Date__c;
            
            if(!stDate){
                caRecord.Start_Date__c = null;
            }
            if(!edDate){
                caRecord.End_Date__c = null; 
            }
            cmp.set("v.caRecord", caRecord);
            isValid = true;  
        }else if(parentStartDate != '' && parentEndDate != ''){

            if(dateInputField.length > 1){
                if(Array.isArray(dateInputField)){ 
                    for(var i = 0;i < dateInputField.length;i++) {
                        if (!dateInputField[i].get("v.value")) { 
                            dateInputField[i].set("v.errors", [{message:" "}])
                            isValid = false;
                        } else {
                            dateInputField[i].set("v.errors", null);
                        }
                    }
                    var fromDate = new Date(dateInputField[0].get("v.value"));
                    var toDate = new Date(dateInputField[1].get("v.value"));

                    if(fromDate.getTime() > toDate.getTime()){
                        isValid = false;  
                        dateInputField[1].set("v.errors", [{message:" End date must be greater than Start date "}])
                    }
                    
                    if(caRecord.Assignment_Position__c != 'Tester' && fromDate.getTime() == toDate.getTime() ){    
                        if(cmp.get("v.caRecord").Assignment_Position__c != "Substitute Instructor" 
                           && (parentRecordType != "Testing_Opportunities" || parentRecordType != "Testing_Projects")) { 
                            
                            dateInputField[1].set("v.errors", [{message:" End date must be greater than Start date "}])
                            isValid = false;  
                        }
                    }
                } 
            }
            
        }else {
            if(cmp.get("v.sObjectName") == 'AcctSeed__Project__c' && cmp.get("v.parentRecordType") != 'Testing_Projects' || cmp.get("v.sObjectName") == 'Opportunity' && cmp.get("v.parentRecordType") != 'Testing_Opportunities'){
                var stDate = caRecord.Start_Date__c;
                var edDate = caRecord.End_Date__c;
                if(parentStartDate != ''){
                    if (!dateInputField[0].get("v.value")) { 
                        dateInputField[0].set("v.errors", [{message:" "}])
                        isValid = false;
                    }else {
                        dateInputField[0].set("v.errors", null);
                    }
                }else if(parentStartDate = ''){
                    if (!stDate) { 
                       caRecord.Start_Date__c = null;
                    }
                }
                if(parentEndDate != ''){
                    if (!dateInputField[1].get("v.value")) { 
                        dateInputField[1].set("v.errors", [{message:" "}])
                        isValid = false;
                    }else {
                        dateInputField[1].set("v.errors", null);
                    }
                }else if(parentEndDate == '') {
                    if (!edDate) { 
                       caRecord.End_Date__c = null;   
                    }
                }
                if(stDate && edDate){
                    var fromDate = new Date(dateInputField[0].get("v.value"));
                    var toDate = new Date(dateInputField[1].get("v.value"));
                    
                    if(fromDate.getTime() > toDate.getTime() ){
                        isValid = false;  
                        dateInputField[1].set("v.errors", [{message:" End date must be greater than Start date "}]);
                    }else {
                        dateInputField[1].set("v.errors", null);
                    }
                }
                
                cmp.set("v.caRecord", cmp.get("v.caRecord"));
            }else{
                var stDate = caRecord.Start_Date__c;
                var edDate = caRecord.End_Date__c;
                if (!stDate) { 
                    caRecord.Start_Date__c = null;
                }
                if (!edDate) { 
                    caRecord.End_Date__c = null;   
                }
                cmp.set("v.caRecord", cmp.get("v.caRecord"));
            }
        }
        
        if(cARTName  == 'Instructor' && cmp.get("v.actionPerform") =='Edit' && cmp.get("v.cADetails")['isCostRateTClTCD']){
            var caRecord = cmp.get("v.caRecord");
            var cADetails =cmp.get("v.cADetails")
            
            if(caRecord['Drafted_Labor_Cost_Rate__c']){
                
                if(cADetails['cRId'] != caRecord['Drafted_Labor_Cost_Rate__c']){
                    cmp.set("v.TimeEntryExistingLCR",true);
                    isValid = false;
                }else{
                    cmp.set("v.TimeEntryExistingLCR",false); 
                }
                
            }else if(caRecord['Rate_Card_Rate__c']){
                
                if(cADetails['cRId'] != caRecord['Rate_Card_Rate__c']){
                    cmp.set("v.TimeEntryExistingLCR",true);
                    isValid = false;
                }else{
                    cmp.set("v.TimeEntryExistingLCR",false); 
                }
                
            }else if(cADetails['cRId'] && caRecord['Drafted_Labor_Cost_Rate__c'] == null){
                cmp.set("v.TimeEntryExistingLCR",true);
                isValid = false;
            }
            
        }else{
            cmp.set("v.TimeEntryExistingLCR",false); 
        }
        // W-002107 -Make the "Project Task" field required on Projects when creating Instructor Contact Assignments
        if(cmp.get("v.sObjectName") == 'AcctSeed__Project__c' && cARTName  == 'Instructor'){
            var protaskInputField = cmp.find('proTask');
            
            if(Array.isArray(protaskInputField)){
                for(var i = 0;i < protaskInputField.length;i++) {      
                    if(!protaskInputField[i].get("v.value")) {
                        $A.util.addClass(protaskInputField[i], 'slds-has-error'); 
                        isValid = false;
                    }else {   
                        $A.util.removeClass(protaskInputField[i], 'slds-has-error');
                    }
                }
            }else  {
                if(!protaskInputField.get("v.value")) {
                    $A.util.addClass(protaskInputField, 'slds-has-error');
                    isValid = false;
                }
            }
            
           if(actionPerform == 'Create' && ( parentRecordType == 'DODA_Projects' || parentRecordType == 'MTT_Projects'
              										   || parentRecordType == 'EFL_Projects' || parentRecordType == 'Language_Training_Projects')
              										   && (caRecord.Schedule_Observation__c && caRecord.Schedule_Observation__c == 'No')  
              										   && (caDetail.requestedHrWeek) && (caRecord.Assignment_Position__c 
                                                       && (caRecord.Assignment_Position__c != 'Substitute Instructor'
                                                       && caRecord.Assignment_Position__c != 'Tester'))){  
               if(caDetail.requestedHrWeek >= 15){
                    isValid = false;
                    cmp.set("v.visibleError",true);
                    cmp.set("v.showErrorMsg",'This is a full-time Project and an Observation Report is required.');
                    
                }else if(caDetail.requestedHrWeek < 15 && isValid){
                    isValid = false;
                    helper.getObservReportInsCAInfo(cmp,event,helper);
            }
          }                                                    
        }
        
        return isValid;
    },
   
    insActionAfterInputValidation: function(cmp,event,helper) {
        
        cmp.set("v.showSpinner",true); 
        var permission = cmp.get("v.actionPerform");  
        var isChangedContact = cmp.get("v.isChangedContact");
        var caRecord = cmp.get("v.caRecord");
        var defaultCR = cmp.get("v.defaultCostRate");

        isChangedContact = (cmp.get("v.oldCARecord").Candidate_Name__c) != (cmp.get("v.caRecord").Candidate_Name__c);
        cmp.set("v.isChangedContact",isChangedContact);
        
        var cARTName = cmp.get("v.recordTypeName");
        var sObjectName =  cmp.get("v.sObjectName");
        var pRecordType = cmp.get("v.parentRecordType");
     
        
        if(cARTName == 'Instructor' && sObjectName == 'AcctSeed__Project__c'){
            if( permission == 'Edit'){
                if(cmp.get("v.caRecord").Status__c == 'Ended'){
                    this.validateInsEndStatusEditDel(cmp,event,helper);
                }else {
                    this.crInstructorValidation(cmp,event,helper);     
                }
                
            }else if(permission == 'Create'){
                if(pRecordType == 'DODA_Projects' && isChangedContact){
                    this.isContactCitizenshipisUSCitizen(cmp); 
                }else{
                    this.crInstructorValidation(cmp,event,helper); 
                }
            }
        }else if(cARTName == 'Instructor' && sObjectName == 'Opportunity'){
            this.crInstructorValidation(cmp,event,helper); 
        }
    },
    deleteActionForAllTab : function(cmp,event,helper){
        cmp.set("v.showSpinner",true);
        var permission = cmp.get("v.actionPerform");
        var action = cmp.get("c.cADeleteRecord");
        action.setParams({
            "cAId" :cmp.get("v.caRecordId")
        });
        action.setCallback(this, function(data){
            var state = data.getState();
            if(state == 'SUCCESS'){
                var result = data.getReturnValue();
                cmp.set("v.showSpinner",false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success",
                    message:"Contact Assignment was deleted",
                    type:"success"
                });
                cmp.set("v.showSpinner",false);
                var appEvent = $A.get("e.c:reloadEvent");
                appEvent.fire();
            }else{
                cmp.set("v.showSpinner",false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  data.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();  
                
            }
        });
        $A.enqueueAction(action);
    },
    upsertActionforOtherTab:function(cmp,event,helper){  
        
        cmp.set("v.showSpinner",true);
        var obj = {};
        var defaultCR = cmp.get("v.defaultCostRate");
        var  actionPerform = cmp.get("v.actionPerform");
        var dliProjectType = null;
        var sObjName = cmp.get("v.sObjectName");

        console.log('::::CA Record',JSON.stringify(cmp.get("v.caRecord")));
        obj = cmp.get("v.caRecord");

        cmp.set("v.showSpinner",true);
        if(Array.isArray(cmp.get("v.caRecord").Candidate_Name__c)) {
            obj.Candidate_Name__c = cmp.get("v.caRecord").Candidate_Name__c[0];
        }
        
        if(cmp.get("v.caRecord").dliProjectType){
          dliProjectType = cmp.get("v.caRecord").dliProjectType;   
        }
        
        if(Array.isArray(cmp.get("v.caRecord").Location__c)) {
            obj.Location__c = cmp.get("v.caRecord").Location__c[0];
        }   
        
        //call helper to populate value in CR field based on the selected CR record name
        if(cmp.get("v.recordTypeName") == 'Staff'){
            obj = this.updateCRFieldBasedonSelectedCRRecord(cmp,obj);
        }
        
        var caArray = []; 
        caArray.push(obj);
        console.log(':::::upsertActionforOtherTab:::caArray::::;',JSON.stringify(caArray));
        
        var action = cmp.get("c.saveContactAssignment");
        action.setParams({
            'sObjName' : sObjName,
            'conAssignJson': JSON.stringify(caArray),
            'parentRecordType' : cmp.get("v.parentRecordType"),
            'cARecordType' : cmp.get("v.recordTypeName"),
            'defaultCR' : defaultCR,
            'actionPerform' : actionPerform,
            'dliProjectType' : dliProjectType
        });
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS"){
                
                if(cmp.get("v.recordTypeName") == 'Instructor' && (cmp.get("v.actionPerform") =='Create' 
                                                               ||(cmp.get("v.actionPerform") =='Edit'
                                                               && cmp.get("v.oldCARecord")['Assignment_Position__c'] != 'Substitute Instructor'))
                  											   && caArray[0].Assignment_Position__c == 'Substitute Instructor'){
                    
                    cmp.set("v.showSpinner", false);
                    cmp.set("v.openModel",false);
                    cmp.set("v.showCostRateModal",false);
                    cmp.set("v.validationSubstituteInsModal",true);
                    cmp.find('valSubIns').open();     
                    
                }
                
                if(cmp.get("v.validationSubstituteInsModal") == false){
                    
                    cmp.set("v.showExistingLTSUpdateModel",false);  
                    cmp.set("v.displayAddModal",false);
                    cmp.set("v.showSpinner",false);
                    cmp.set("v.openModel",false);
                    var appEvent = $A.get("e.c:reloadEvent");
                    appEvent.fire();
                }
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success",
                    message:"Contact Assignment was "+cmp.get("v.actionPerform")+ (cmp.get("v.actionPerform") == 'Edit' ?'ed':'d'),
                    type:"success"
                });
                toastEvent.fire();
            }else if(state === "ERROR"){
                cmp.set("v.showSpinner",false); 
                console.log(data.getError());
                var errors = data.getError();
                var msg = '';
                errors.forEach(function (element){     
                    msg = element.message + ' \n ';
                });
                cmp.set("v.showCostRateModal",false);
                cmp.set("v.showErrorMsg",  msg);            
                cmp.set("v.visibleError",'slds-show'); 
                document.getElementById('topscrollable').scrollIntoView();
            }
        });
        $A.enqueueAction(action);
    },
    validateInsEndStatusEditDel : function(cmp,event,helper){
        
        var obj = {};
        obj = cmp.get("v.caRecord");
        var permission = cmp.get("v.actionPerform");
        if(Array.isArray(cmp.get("v.caRecord").Candidate_Name__c)) {
            obj.Candidate_Name__c = cmp.get("v.caRecord").Candidate_Name__c[0];
        }
        var action = cmp.get("c.validateInsEndStatusEditDelete");
        action.setParams({
            "contactId" : obj.Candidate_Name__c,
            "projectId": cmp.get("v.parentId"),
            "caId": obj.Id
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var showScheduleEndEditDel = response.getReturnValue();
                cmp.set("v.showScheduleEndEditDeleteVal",showScheduleEndEditDel);
                cmp.set("v.showSpinner",false); 
                
                if(showScheduleEndEditDel){    
                    if(permission != 'Edit'){
                        cmp.set("v.showDeleteSchValidationModel",true);
                        cmp.find('deleteSchedule').open();
                    }
                }else {
                    if(permission != 'Delete'){ 
                        this.upsertActionforOtherTab(cmp,event,helper);
                    }else {
                        cmp.set("v.showDeleteModel",true); 
                        cmp.find("caDeleteModal").open();
                    }
                }
            }else{
                cmp.set("v.showSpinner",false);  
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  data.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();  
            }
        });
        $A.enqueueAction(action);
    },
    upsertActionforInstructor : function(cmp,event,helper){
        
        var  permissionAccess = cmp.get("v.actionPerform");
        var  isChangedContact = cmp.get("v.isChangedContact");
        var cRCreationOptionModalRateType = ['LT with Prep','LT without Prep','Non-SCA CD'];
        var caRecord = cmp.get("v.caRecord");
        var pRecordType = cmp.get("v.parentRecordType");
        var caDetail = cmp.get("v.caDetail");
        
        cmp.set("v.showSpinner",false);
        if(!caRecord.Drafted_Labor_Cost_Rate__c && !caRecord.Rate_Card_Rate__c && (cRCreationOptionModalRateType.includes(cmp.get("v.defaultCostRate")))
           && (caRecord.Opportunity_Product_Id__c != null || caRecord.Project_Task__c != null)){
            
            cmp.set("v.showCostRateModal",true);
        
        }else if(!caRecord.Drafted_Labor_Cost_Rate__c && !caRecord.Rate_Card_Rate__c){
            var recordTypeName = cmp.get("v.parentRecordType");
            var hasOPLIPT = cmp.get("v.cRCreationObj").isOPIPT;
            var isAwarded = cmp.get("v.cRCreationObj").existingAwarded;
            var isNew =  cmp.get("v.cRCreationObj").isNewCA;
            var allow = false; 

             //W-007837 - Create new FSI Labor Cost Rate Rate Type & Offer Letter (SEP-1-2023)
            if(isNew){
                if(((recordTypeName != 'DLI_W_TO_Opportunities' && hasOPLIPT == false) || (recordTypeName == 'DLI_W_TO_Opportunities'
                                                                && caRecord.Status__c == 'Awarded' && (isAwarded == false || hasOPLIPT == false))) 
                                                                && (caRecord.Project_Task__c != null || caRecord.Opportunity_Product_Id__c != null) && caRecord.Status__c != 'Canceled'){
                       allow = true;
                   }
            }else {
                if(((recordTypeName == 'DLI_W_TO_Opportunities' && caRecord.Status__c == 'Awarded') || recordTypeName != 'DLI_W_TO_Opportunities') 
                                                                && (caRecord.Project_Task__c != null || caRecord.Opportunity_Product_Id__c != null) && caRecord.Status__c != 'Canceled'){
                       allow = true;
                   }
            }
             
            if(allow){
                cmp.set("v.showCostRateModal",true);   
            }else {
                this.upsertActionforOtherTab(cmp,event,helper); 
            }
            
            }else {
                this.upsertActionforOtherTab(cmp,event,helper); 
            }
    },
    
    crInstructorValidation : function(cmp,event,helper){
        
        var permission = cmp.get("v.actionPerform"); 
        var isChangedContact = cmp.get("v.isChangedContact");
        var caRecord = cmp.get("v.caRecord");
        var cARTName = cmp.get("v.recordTypeName");
        var defaultCR = cmp.get("v.defaultCostRate");
        var sObjectName = cmp.get("v.sObjectName");
        var pRecordType = cmp.get("v.parentRecordType");
        var defaultCR = cmp.get("v.defaultCostRate");
        var isChangedAccount = false;

        cmp.set("v.showSpinner",true); 

        if(cARTName == 'Instructor'){

            //W-006039 -  Process change when DLI projects are sub-contracted
            if((sObjectName == 'AcctSeed__Project__c'|| sObjectName == 'Opportunity') && (pRecordType == 'DLI_W_LT_Projects' || pRecordType == 'DLI_W_TO_Opportunities') 
               && caRecord.Account__c && ((caRecord.dliProjectType && caRecord.dliProjectType == 'Partner School' && defaultCR == 'SubK-LT')
                || (caRecord.Assignment_Position__c == 'Partner School EI' || caRecord.Assignment_Position__c  == 'Partner School Instructor'))){

                isChangedAccount = (cmp.get("v.oldCARecord").Account__c != caRecord.Account__c);
               
                if(isChangedAccount){
                    isChangedContact = true;
                }else{
                    isChangedContact = false;
                }
            }
            
            if(defaultCR != null  && (caRecord.Opportunity_Product_Id__c != null || caRecord.Project_Task__c != null )){
                if(isChangedContact) {
                    caRecord.Drafted_Labor_Cost_Rate__c = null;
                    caRecord.Rate_Card_Rate__c = null;
                    cmp.set("v.caRecord",caRecord);
                    this.upsertActionforInstructor(cmp,event,helper);
                    
                }else if(permission == 'Create') {
                    this.upsertActionforInstructor(cmp,event,helper);
                }else if(isChangedContact == false && cmp.get("v.cRCreationObj").isOPIPT == false 
                         						   || cmp.get("v.cRCreationObj").existingAwarded == false 
                                                   || cmp.get("v.cRCreationObj").existingAwarded 
                                                   && (caRecord.Drafted_Labor_Cost_Rate__c == null && caRecord.Rate_Card_Rate__c == null)) {
                    
                    this.upsertActionforInstructor(cmp,event,helper);
                    
                }else {
                    this.upsertActionforOtherTab(cmp,event,helper);   
                }
            }else {
                this.upsertActionforOtherTab(cmp,event,helper);   
            } 
        } 
    },
    staffUpsertActionConfirmation:function(cmp, event, helper){
        
        var permission = cmp.get("v.actionPerform"); 
        var cARTName = cmp.get("v.recordTypeName");
        var caRecord = cmp.get("v.caRecord");
        
        if(cARTName == 'Staff' && cmp.get("v.sObjectName") == 'AcctSeed__Project__c' && permission == 'Create'){    
            if(caRecord.Status__c == 'Active'){//we should not show the message “Would you like to make status as ended for existing LTS records?”
 											   //They will not be replacing the LTS, they are an additional separate Staff contact assignments that is optional.
                if(cmp.get("v.parentRecordType") != 'Admin_Projects' && (caRecord.Assignment_Position__c != 'LT Coordinator')){
                    
                    this.validateActiveStaff(cmp);
                } else{
                    this.upsertActionforOtherTab(cmp,event,helper); 
                }
            }else{
                this.assignCRForNONSCATesting(cmp,event,helper); 
            }
        }else if(cARTName == 'Staff' && cmp.get("v.sObjectName") == 'AcctSeed__Project__c' && permission == 'Edit'){
            this.assignCRForNONSCATesting(cmp,event,helper); 
        } else {
            this.upsertActionforOtherTab(cmp,event,helper);  
        }
        
    },
    validateActiveStaff : function(cmp, event, helper) {
        
        var action = cmp.get("c.validateStaffActiveStatus");
        action.setParams({
            "parentId" : cmp.get("v.parentId")
        });
        action.setCallback(this, function(data) {
            var state = data.getState();
            if(state == "SUCCESS") {
                var result = data.getReturnValue();
                if(result > 0) {
                    cmp.set("v.showExistingLTSUpdateModel",true);
                    cmp.find("existingStaffUpdateConfirmation").open();     
                    cmp.set("v.openModel",false);
                    cmp.set("v.showSpinner",false);
                } else {
                    this.upsertActionforOtherTab(cmp,event,helper);  
                }
            } else {
                
                cmp.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  data.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();  
            }
        });
        $A.enqueueAction(action);
    },
    assignCRForNONSCATesting : function(cmp,event,helper){
        
        var obj = {};
        var contactId = null;
        var projectTaskId = null;

        obj = cmp.get("v.caRecord");    
        if(Array.isArray(obj.Candidate_Name__c)) {
            obj.Candidate_Name__c = obj.Candidate_Name__c[0];
        }

        if(obj && obj.Project_Task__c){
            projectTaskId = obj.Project_Task__c;
        }

        //call helper to populate value in CR field based on the selected CR record name
        obj = this.updateCRFieldBasedonSelectedCRRecord(cmp,obj);

        if((!cmp.get("v.cRCreationObj").isOPIPT) && projectTaskId != null){
            
            var action = cmp.get("c.staffNonScaTestingmethod");
            action.setParams({
                'contactId': obj.Candidate_Name__c,
                'defaultCR':cmp.get("v.defaultCostRate")
            });
            action.setCallback(this, function(data) {
                var state = data.getState();
                if(state == "SUCCESS"){
                    var costRateInfo = data.getReturnValue();
                    console.log(JSON.stringify(costRateInfo));
                    if(costRateInfo.isAlreadyCRExist){
                        if(costRateInfo.costLabel == 'RateCost'){
                            obj.Rate_Card_Rate__c = costRateInfo.rateCardRate;
                        }else{
                            obj.Drafted_Labor_Cost_Rate__c = costRateInfo.rateCardRate;
                        }                        
                    }
                    cmp.set("v.caRecord",obj); 
                    this.upsertActionforOtherTab(cmp,event,helper);
                } else {
                    cmp.set("v.showSpinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message :  data.getError()[0].message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();  
                }
            });
            $A.enqueueAction(action);
        }else{
            this.upsertActionforOtherTab(cmp,event,helper);
        }
        
    },
    inputPicklistValues:function(cmp,event,helper,picklistValues){
        
        var permissionAccess = cmp.get("v.actionPerform");
        var Statuspicklist = picklistValues.statusValues;
        var caRTName = cmp.get("v.recordTypeName");
        var defaultCR = cmp.get("v.defaultCostRate");
        
        var options=[];
        options.push({'label': '--None--', 'value':''});
        for(var i = 0;i < Statuspicklist.length;i++){
            options.push({'label': Statuspicklist[i], 'value':Statuspicklist[i]});
        }
        cmp.set("v.statusOptions", options);
        
        var  projectTaskField = [];
        if(cmp.get("v.sObjectName") == 'AcctSeed__Project__c'){
            
            var projectTaskPick = picklistValues.taskRecords;  
            projectTaskField.push({'label': '--None--', 'value':''});
            for(var i = 0;i < projectTaskPick.length;i++){
                projectTaskField.push({'label': projectTaskPick[i].Name, 'value':projectTaskPick[i].Id});           
            }
            cmp.set("v.projectTaskField", projectTaskField);
            console.log(cmp.get("v.projectTaskField"));
            
        }else if(cmp.get("v.sObjectName") == 'Opportunity'){
            var  oppProductLst = [];
            var oppProductList = picklistValues.opliRecords;
            oppProductLst.push({'label': '--None--', 'value':''});
            for(var i = 0;i < oppProductList.length;i++){                           
                oppProductLst.push({'label': oppProductList[i].name, 'value':oppProductList[i].id});      
            }
            cmp.set("v.oppProductList",oppProductLst);
        }
        
        if(permissionAccess == 'Edit'){
            var costRateLst = [];
            var costRateList = picklistValues.costRateLst;
            costRateLst.push({'label': '--None--', 'value':''});
            for(var i = 0;i < costRateList.length;i++){ 
                costRateLst.push({'label': costRateList[i].costName, 'value':costRateList[i].cRID});  
            }
            cmp.set("v.costRateList", costRateLst);
            
            // Time Approval PickList Formation  
            var timeAppPrep = [];
            var timeAppPrefences = picklistValues.timeApprovalPreferences;
            for(var i = 0;i < timeAppPrefences.length;i++){ 
                timeAppPrep.push({'label': timeAppPrefences[i], 'value':timeAppPrefences[i]});  
            }
            cmp.set("v.timePreferncesPicklist", timeAppPrep);
        }
        
        var positionLst = [];
        var positionList =  picklistValues.positionValues;
        positionLst.push({'label': '--None--', 'value':''});
        for(var i = 0;i < positionList.length;i++){   
            positionLst.push({'label': positionList[i], 'value':positionList[i]});      
        }
        
        cmp.set("v.positionList", positionLst);
        cmp.set("v.noOfLaptopIssues",picklistValues.noOfLaptopIssues);
    },
    
    updateCRFieldBasedonSelectedCRRecord : function(cmp,obj){
        //Check the selected CR status and assign to related field in CA
        var crList = cmp.get("v.costRateList");
        console.log('::::::assignCRForNONSCATesting:::::::',crList);
        var crMap = {};
        for(var i = 0;i < crList.length;i++){
            if(!crMap[crList[i].value]){
                crMap[crList[i].value] = crList[i].label;
            }
        }
        var name;
        var crId;
        if(obj.Rate_Card_Rate__c && crMap[obj.Rate_Card_Rate__c]){
            name = crMap[obj.Rate_Card_Rate__c];
            if(name.indexOf('Draft') != -1 || name.indexOf('Submitted for Approval') != -1){
                crId = obj.Rate_Card_Rate__c;
                obj.Rate_Card_Rate__c = null;
                obj.Drafted_Labor_Cost_Rate__c = crId;
            }
        }else if(obj.Drafted_Labor_Cost_Rate__c && crMap[obj.Drafted_Labor_Cost_Rate__c]){
            name = crMap[obj.Drafted_Labor_Cost_Rate__c];
            if(name.indexOf('Draft') == -1 && name.indexOf('Submitted for Approval') == -1){
                crId = obj.Drafted_Labor_Cost_Rate__c;
                obj.Drafted_Labor_Cost_Rate__c = null;
                obj.Rate_Card_Rate__c = crId;
            }
        }
        
        return obj;
    },
    
    /*W-002019 - User Story - DODA Projects - Instructor Contact Assignments, US Citizen
      On DODA Projects, when adding an Instructor Contact Assignment, upon save check the Contact page 
      if the Citizenship field has the "US Citizen" value. If the Contact does not have the "US Citizen" value, 
      throw warning message: "This Candidates Citizenship is not US Citizen. Please assign a Candidate with US Citizenship." 
      Do not allow the user to save. */
    isContactCitizenshipisUSCitizen : function(cmp){
        
        var obj = {};
        obj = cmp.get("v.caRecord");
        if(Array.isArray(cmp.get("v.caRecord").Candidate_Name__c)) {
            obj.Candidate_Name__c = cmp.get("v.caRecord").Candidate_Name__c[0];
        }
        
        var permission = cmp.get("v.actionPerform"); 
        var action = cmp.get("c.isConCitizenshipisUSCitizen");
        action.setParams({
            "conId" : obj.Candidate_Name__c
        });
        action.setCallback(this, function(data){
            var state = data.getState();
            if(state == 'SUCCESS'){
                var result = data.getReturnValue();
                if(result){
                    if( permission == 'Create'){
                        this.crInstructorValidation(cmp); 
                    }
                }else {
                    cmp.set("v.showSpinner",false);   
                    cmp.set("v.showErrorMsg",'This Candidates Citizenship is not US Citizen. Please assign a Candidate with US Citizenship.');            
                    cmp.set("v.visibleError",'slds-show');
                    window.setTimeout($A.getCallback(function(){
                        document.getElementById('topscrollable').scrollIntoView();     
                    }), 1000);
                }
            }else{
                cmp.set("v.showSpinner",false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  data.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();  
            }
        });
        $A.enqueueAction(action);
    },
     getObservReportInsCAInfo : function(cmp, event, helper){
        var obj = {};
        obj = cmp.get("v.caRecord");
        
        if(Array.isArray(cmp.get("v.caRecord").Candidate_Name__c)) {
            obj.Candidate_Name__c = cmp.get("v.caRecord").Candidate_Name__c[0];
        }
        var action = cmp.get("c.getObservationReportInsCAInfo");
        action.setParams({
            "conId" : obj.Candidate_Name__c
        });
        action.setCallback(this, function(data){
            var state = data.getState();
            if(state == 'SUCCESS'){
                var result = data.getReturnValue();
                cmp.set("v.showObervationReportValMsg",result);
                cmp.set("v.showObservationReportValModel",true);
                cmp.find('caORValModal').open();   
            }else{
                cmp.set("v.showSpinner",false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  data.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();  
            }
        });
        $A.enqueueAction(action);
    },
     instructorSaveBtnClkHelper: function(cmp, event,helper, isValidinput){
        var caRecord = cmp.get("v.caRecord");
        var isRateCardRate = (!caRecord.Drafted_Labor_Cost_Rate__c && !caRecord.Rate_Card_Rate__c);
        var proTask =  cmp.get("v.caRecord").Project_Task__c;
        var permissionAccess = cmp.get("v.actionPerform");
        var isOPIPT = cmp.get("v.cRCreationObj").isOPIPT;
        var existAward = (cmp.get("v.cRCreationObj").existingAwarded);
        var cAStatus = cmp.get("v.caRecord").Status__c;
        var pRecordType = cmp.get("v.parentRecordType");
        var defaultCR = cmp.get("v.defaultCostRate");
        
        if(isValidinput){  
                
           if((pRecordType == 'Interpretation_Projects' || pRecordType == 'Translation_Projects')){
                
                if(cAStatus == 'Ended'){
                    helper.upsertActionforOtherTab(cmp,event,helper);
                }else if(proTask != null && (permissionAccess == 'Create' || permissionAccess == 'Edit')){
                    cmp.set("v.showCostRateModal",true);
                }else {
                    helper.upsertActionforOtherTab(cmp,event,helper);  
                }
            }else if(pRecordType == 'DLI_W_TO_Opportunities' && cmp.get("v.sObjectName") == 'Opportunity'){
                
                if(cAStatus != 'Awarded'){
                    helper.upsertActionforOtherTab(cmp,event,helper); 
                }else if((isRateCardRate && permissionAccess == 'Edit' && (isOPIPT && existAward == false  || isOPIPT == false )&& cAStatus == 'Awarded')|| (permissionAccess == 'Create' && cAStatus == 'Awarded')){
                    helper.insActionAfterInputValidation(cmp,event,helper);
                }else {
                    helper.upsertActionforOtherTab(cmp,event,helper); 
                }
                
            }else if(isRateCardRate && permissionAccess == 'Edit' && isOPIPT){
                helper.upsertActionforOtherTab(cmp,event,helper); 
            }else if(cmp.get("v.recordTypeName") == 'Instructor'){
                
                if(defaultCR == 'International Salary'){//(exclude the CR Creation)
                    helper.upsertActionforOtherTab(cmp,event,helper); 
                }else{
                    helper.insActionAfterInputValidation(cmp,event,helper);
                }
            }
        }
    }
    
})