({
    doInit : function(component, event, helper) {
        
        var fullList = component.get("v.contactAssignList");
        var PRecordType = component.get("v.parentRecordType");
        var statusUpdatedList = [];
    
        if(PRecordType == 'Translation_Opportunities' || PRecordType == 'Interpretation_Opportunities' || PRecordType == 'Interpretation_Projects' || PRecordType == 'Translation_Projects'){
            component.set("v.selectedStatus",'Planned & Active') 
            
            for( var i = 0 ; i < fullList.length ;i++){
                if(fullList[i].Status__c == 'Planned' ||fullList[i].Status__c == 'Active'){
                    statusUpdatedList.push(fullList[i]);
                }
            }
            component.set("v.contactAssignTempList",statusUpdatedList);
        }else {
            component.set("v.contactAssignTempList",fullList);
        }
        
        if(component.get("v.contactAssignTempList").length > 0){
            component.find("contactAssignTable").initialize({"order":[]});   
        }
    } ,
    statusChange : function(cmp , event){

        var selectedStatus = cmp.get("v.selectedStatus");
        var contactAssignList = cmp.get("v.contactAssignList");
        console.log(' is full lisyt'+contactAssignList);
        var statusUpdatedList = [];
        if(selectedStatus == 'All'){
            statusUpdatedList = contactAssignList;
        }else if(selectedStatus == 'Planned & Active'){
            for( var i = 0 ; i < contactAssignList.length ; i++){
                if(contactAssignList[i].Status__c == 'Planned' ||contactAssignList[i].Status__c == 'Active'){
                    statusUpdatedList.push(contactAssignList[i]);
                }
            }
        }else {
            for( var i = 0 ; i < contactAssignList.length ; i++){
                if(contactAssignList[i].Status__c == selectedStatus){
                    statusUpdatedList.push(contactAssignList[i]);
                }
            }
        }
        cmp.set("v.contactAssignTempList",statusUpdatedList);
        if(cmp.get("v.selectedStatus") != 'All' && cmp.get("v.selectedStatus") != 'Planned & Active' ){
            for(var i=0;i<(cmp.get("v.header")).length;i++){
                if(cmp.get("v.header")[i].name == 'Status__c'){
                    cmp.get("v.header")[i]['visible']=false;
                } 
            }
        }else if(cmp.get("v.selectedStatus") == 'All' || cmp.get("v.selectedStatus") == 'Planned & Active' ){
            
            for(var i=0;i<(cmp.get("v.header")).length;i++){
                if(cmp.get("v.header")[i].name == 'Status__c'){
                    cmp.get("v.header")[i].visible=true;
                } 
            }
        }
        cmp.set("v.header",cmp.get("v.header"));
        if(cmp.find("contactAssignTable")){
            cmp.find("contactAssignTable").initialize({"order":[]});
        }    
    },
    addBtnClick : function(component, event,helper) {
        
        component.set("v.actionPerform",'Create')
        component.set("v.displayAddModal",true);
        component.set("v.CAId",null);
    },
    searchBtnClick : function(component, event, helper){
        var parentType;
        var parentId = component.get("v.parentId");
        if(component.get("v.sObjectName") == 'Opportunity'){
            parentType = 'OPPORTUNITY';
        }
        if(component.get("v.sObjectName") == 'AcctSeed__Project__c'){
            parentType = 'PROJECT';
        }
        
        //window.open('/apex/Instructor_Search_Managed?taskType=CONTACT_ASSIGNMENT&parentType='+parentType+'&parentId='+parentId+'&returnId='+parentId);
           window.open('/lightning/n/Candidate_Search?type=CA&parentType='+parentType+'&parentId='+parentId+'&returnId='+parentId);

    },
    tabActionClick : function(component, event, helper){
        
        var actionId=event.getParam('actionId');
        component.set("v.displayAddModal",false);
        var selectedTab = component.get("v.selectedTab");
        var rowRecord = event.getParam("row");
        component.set("v.CAId",rowRecord.Id);   
        component.set("v.contactId",rowRecord.Candidate_Name__c);
        component.set("v.caRecord",rowRecord);
        component.set("v.isPayRateModifyCRRateTypes",false);

        if(actionId == 'detailstask') {
            
            component.set("v.displayViewMoreInstructor",false);
            component.set("v.displayViewMoreTab",false);
            component.set("v.RecordType",rowRecord.RecordType.Name);
            if(component.get("v.RecordType") == 'Instructor'){
                
                component.set("v.displayViewMoreInstructor",true);
            }else{
                component.set("v.displayViewMoreTab",true);
            }
        }else if (actionId == 'studentTimeLine'){
            
            var action=component.get("c.cAStudentMailsend");
            action.setParams({'conId':rowRecord.Candidate_Name__c,
                              'oppId':rowRecord.Opportunity_Name__c
                             });
            action.setCallback(this,function(data){
                var state = data.getState();
                if(state === "SUCCESS") {
                    var appEvent = $A.get("e.c:reloadEvent");
                    appEvent.fire();
                } else if(state === "ERROR"){
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
            
        } else if(actionId == 'edittask' ) {
            
            component.set("v.actionPerform",'Edit');
            component.set("v.displayAddModal",true);
        }else if(actionId == 'deltask'){
            
            component.set("v.actionPerform",'Delete')
            component.set("v.displayAddModal",true);   
        }else if(actionId == 'viewRecord') {
            
            /*Modified By Dhinesh - 8/2/2023 - W-007709 - Fix Convert Circular Structure to JSON issue
            var sObectEvent = $A.get("e.force:navigateToSObject");
            sObectEvent .setParams({
                "recordId": window.open('/'+rowRecord.Id), 
                "slideDevName": "detail"
                
            });
            sObectEvent.fire(); */
            window.open('/'+rowRecord.Id);
            
        }else if(actionId == 'package') {
            
            /*var contactEvent = $A.get("e.force:navigateToSObject");
            contactEvent.setParams({
                "recordId": window.open('/'+rowRecord.Candidate_Name__c), 
                "contactEvent": "detail"
                
            });
            contactEvent.fire(); */
            component.set("v.contactId",rowRecord.Candidate_Name__c);
            component.set("v.displayPlannedOffDays",true);
        }else if(actionId == 'genOffer') {
            helper.genOfferMethod(component,event,helper);
        }else if(actionId == 'genTesterPaymentForm') {
            helper.genTesterPaymentForm(component,event,helper,'Tester Payment Form');
        }else if(actionId == 'genSendTesterPaymentForm') {
            if(rowRecord.Candidate_Name__r && rowRecord.Candidate_Name__r.Supervisor_Name__c) {
                helper.genTesterPaymentForm(component,event,helper,'send Tester Payment Form');       
            }else {
                component.set("v.isSendTesterPaymentModal",true);
                component.find('sendTesterPaymentWarningModal').openModal();
            }
        }else if(actionId == 'payRateModification') {
            // for Pay Rate Modification show only for 'LT','Non-SCA CD','Non-SCA CD (1099)' RateTypes
            var rateTypeSet = ['LT with Billable Prep','LT without Billable Prep','LT with Prep','LT without Prep','Non-SCA CD','Non-SCA CD (1099)','Non-SCA LT','DLI-W LT','DODA PS','DLI-W PS - Group 3','DLI-W PS - Group 4','FSI'];
            var defaultCR = component.get("v.defaultCR");
            
            if(rateTypeSet.includes(rowRecord.CRRateType)){
                component.set("v.isPayRateModifyCRRateTypes",true); 
                
                if(defaultCR == 'Non-SCA LT' || defaultCR == 'LT with Billable Prep'){
                    defaultCR = 'LT with Prep';
                }else if(defaultCR == 'LT without Billable Prep'){
                    defaultCR = 'LT without Prep';
                }
                component.set("v.defaultCR",defaultCR);
                
                if(defaultCR == 'LT with Prep' || defaultCR == 'LT without Prep' || defaultCR == 'DLI-W LT'){
                    component.set("v.fulLoadAmtFlag",true);
                }
            }
            component.set("v.isPayRateModifyAction",true);
            component.find('payRateModify').openModal();
        }else if(actionId == 'additionalCompensation') {
            if(rowRecord.Additional_Compensation_Type__c) {
                component.set("v.isDisplayExistCAAddComp",true);
            }else {
                var insIdWithTotalEventSumMap = component.get("v.insIdWithTotalEventSumMap");
                var addCompinputsMap = component.get("v.addCompinputsMap");
                component.set("v.showSpinner",true);

                if(insIdWithTotalEventSumMap){
                    if(insIdWithTotalEventSumMap[rowRecord.Candidate_Name__c]){
                        addCompinputsMap['TotalEligibleDayAddComp'] = insIdWithTotalEventSumMap[rowRecord.Candidate_Name__c]; 
                    }else{
                        addCompinputsMap['TotalEligibleDayAddComp'] = 0; 
                    }
                }else{
                     addCompinputsMap['TotalEligibleDayAddComp'] = 0;
                }
                component.set("v.isDisplayExistCAAddComp",false);
            }
            component.set("v.isAdditionalCompModal",true);
            component.set("v.addCompCARecord",{});
            component.set("v.addCompinputsMap",addCompinputsMap);
            component.find('addCompensation').openModal();
        }else if(actionId == 'languageTestingId'){
            var caId = component.get("v.CAId");  
            
            if(caId){            
                component.set("v.isLangTestingFlow",true);
                component.find("langTesting").open();
                
                var flow = component.find("flowData");
                var inputVariables = [
                    {
                        name : "contactAssignId",
                        type : "String",
                        value : caId
                    }
                ];
                flow.startFlow("Language_Testing_Creation",inputVariables);
            }
        }else if(actionId == 'transfer'){   
            var studentTransferCAMap =  component.get("v.studentTransferCAMap");
            
            studentTransferCAMap.projectLookup = [];   
            studentTransferCAMap.transferCASTDate = '';   
            studentTransferCAMap.transferCAOldEDDate = '';   
            studentTransferCAMap.isShowTransferStuCAVal = false; 
            studentTransferCAMap.isShowConfirmationModal = false;
            studentTransferCAMap.isTransferStudentCA = false;  
            studentTransferCAMap.projectName = '';
            studentTransferCAMap.studentCANames = [];
            studentTransferCAMap.selectedCLCAId = '';
            
            component.set("v.studentTransferCAMap",studentTransferCAMap);
            if(component.get("v.caRecord").Assignment_Position__c == 'Class Leader'){
                helper.getStudentNamesForClassLeader(component,event,helper);
            }else{
                component.set("v.studentTransferCAMap.isTransferStudentCA",true);
                component.find("transferCA").openModal();
            }
        }
    },
    closeTransferStuCA : function(component, event,helper) {
        var studentTransferCAMap =  component.get("v.studentTransferCAMap");
        
        if(studentTransferCAMap.isShowTransferStuCAVal){
            component.set("v.studentTransferCAMap.isShowTransferStuCAVal",false);
        }else{
            var appEvent = $A.get("e.c:reloadEvent");
            appEvent.fire();
        }

    },
    TransferStuCAValCheck : function(component, event,helper) {
        var studentTransferCAMap =  component.get("v.studentTransferCAMap");
        var transferDt = component.find('transferDt');
        var projectId = component.find("projectId");
        var isValid = true;
        
        if(Array.isArray(transferDt)){ 
            for(var i = 0;i < transferDt.length;i++) { 
                if(!transferDt[i].get("v.value")){
                    isValid = false;
                    transferDt[i].set("v.errors", [{message:" "}])       
                }else {
                    transferDt[i].set("v.errors", null);       
                }
            }
        }else {
            if(!transferDt.get("v.value")){
                isValid = false;
                transferDt.set("v.errors", [{message:" "}])       
            }else {
                transferDtset("v.errors", null)       
            }
        }
        
        if(studentTransferCAMap.studentCANames && (studentTransferCAMap.studentCANames).length > 0){
            var stuTransfer = component.find("stuTransfer");
            
            if(stuTransfer){
                if(!stuTransfer.get("v.value")){
                    isValid = false;
                    $A.util.addClass(stuTransfer, 'slds-has-error');   
                }else {
                    $A.util.removeClass(stuTransfer, 'slds-has-error');        
                }
            }
        }
        
        if(studentTransferCAMap.projectLookup.length == 0){
            isValid = false;
            $A.util.addClass(projectId, 'slds-has-error'); 
        }else {
            $A.util.removeClass(projectId, 'slds-has-error');
            studentTransferCAMap.projectName = studentTransferCAMap.projectLookup[0].Name;
        }
        
        if(isValid){
            helper.transferStudentCAUIValCheck(component,event,helper);
        }
    },
    proceedToTransferStuCA : function(component, event, helper) {
        helper.createNewStuCAWithNewProject(component,event,helper);
    },
    projectLookupSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.getLookupRecords');
        event.getSource().search(serverSearchAction);
    },
    childActionEvent : function(component, event, helper) {
        
        var message = event.getParam("typeOfAction");
        
        component.set("v.actionPerform",message);
        component.set("v.displayAddModal",true);
        component.set("v.displayViewMoreTab",false);
        
    },
    closefieldsEmpty : function(component,event,helper){
        
        component.find('fieldsEmpty').closeModal();  
    },
    closeConditionFailed : function(component,event,helper){
        
        component.find('ConditionFailed').closeModal();  
    },
    closePayRateModificationClk : function(component,event,helper){
        
        component.set("v.costRateRecord",{}); 
        component.set("v.fulLoadAmt",0.00); 
        component.set("v.isPayRateModifyAction",false);
        component.find('payRateModify').closeModal();  
    },
    savePayRateModificationClk : function(component,event,helper){
        
        var crInputfield = component.find("crInputs");
        var crInput = component.find("crInput");
        var isValidInputs = true;
        
        if(!crInput.get("v.value")){
            $A.util.addClass(crInput, 'slds-has-error'); 
            isValidInputs = false;
        }else {
            $A.util.removeClass(crInput, 'slds-has-error');
        }
        
        for(var i = 0;i < crInputfield.length;i++) {   
            if(!crInputfield[i].get("v.value")) {
                crInputfield[i].set("v.errors", [{message:""}]);
                isValidInputs = false;
            }else {   
                crInputfield[i].set("v.errors", null);
            }
        }
        if(isValidInputs) {
            
            var costRateRecord = component.get("v.costRateRecord");
            var caRecord = component.get("v.caRecord");
            var defaultCR = component.get("v.defaultCR");
            costRateRecord ['Prior_Version__c'] = caRecord['CrID'];
            component.set("v.showSpinner",true);
            
            var action = component.get("c.createPayRateModifyCostRate");
            action.setParams({
                'crRecord' : costRateRecord,
                'parentId' : component.get("v.parentId"),
                'caRecord' : caRecord,
                'defaultCR' : defaultCR,
            });
            action.setCallback(this, function(response) {
                console.log('response::::',response);
                var state = response.getState();
                if(state === "SUCCESS") {
                    var returnStr = response.getReturnValue();
                    var appEvent = $A.get("e.c:reloadEvent");
                    appEvent.fire();
                    
                } else {
                    if(state === "ERROR"){
                        component.set("v.showSpinner",false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message :  response.getError()[0].message,
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();  
                    }
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    addCompCloseClk : function(component,event,helper){
        var appEvent = $A.get("e.c:reloadEvent");
        appEvent.fire();
    },
    addCompBackClk : function(component,event,helper){
        var addCompinputsMap = component.get("v.addCompinputsMap");
        
        addCompinputsMap['isDisplayAddCompInputs'] = false;
        addCompinputsMap['DailyTravelAmtInput'] = false; 
        addCompinputsMap['bonusAmtInput'] = false; 
        component.set("v.addCompinputsMap",addCompinputsMap);
    },
      /*Work - W-001862
         Hiring Process: Additional Compensation (End of Training Bonuses, Client Site Travel Reimbursement, etc.) to validate inputd*/
    addCompProceedClk : function(component,event,helper){
        var isValid = true;
        var isValidInput = true;
        var displayAddComInputs = false;
        var addCompinputsMap = component.get("v.addCompinputsMap");
        
        if(addCompinputsMap['isDisplayAddCompInputs'] == false) {
            var addComp = component.find('additionalComp');
            
            if(Array.isArray(addComp)){
                for(var i = 0;i < addComp.length;i++) { 
                    if(!addComp[i].get("v.value")){
                        isValid = false;
                        $A.util.addClass(addComp[i], 'slds-has-error'); 
                    }else {
                        $A.util.removeClass(addComp[i], 'slds-has-error'); 
                    }
                }
            }else {
                if(!addComp.get("v.value")){
                    isValid = false;
                    $A.util.addClass(addComp, 'slds-has-error'); 
                }else {
                    $A.util.removeClass(addComp, 'slds-has-error'); 
                }
            }
        }else {
            var addCompInputs = component.find('addCompInputs');
            
            if(Array.isArray(addCompInputs)){
                for(var i = 0;i < addCompInputs.length;i++) { 
                    if(!addCompInputs[i].get("v.value")){
                        isValidInput = false;
                        $A.util.addClass(addCompInputs[i], 'slds-has-error'); 
                    }else {
                        displayAddComInputs = true;
                        $A.util.removeClass(addCompInputs[i], 'slds-has-error'); 
                    }  
                }
            }else {
                if(!addCompInputs.get("v.value")){
                    isValidInput = false;
                    $A.util.addClass(addCompInputs, 'slds-has-error'); 
                }else {
                    displayAddComInputs = true;
                    $A.util.removeClass(addCompInputs, 'slds-has-error'); 
                }  
            }
        }
        
        if(isValid) {
            var addCompCARecord = component.get("v.addCompCARecord");
            
            if(addCompCARecord['Additional_Compensation_Type__c'] == 'End of Training Bonus'){
                addCompinputsMap['bonusAmtInput'] = true;  
            }else if(addCompCARecord['Additional_Compensation_Type__c'] == 'Client Site Travel Reimbursement'){
                addCompinputsMap['DailyTravelAmtInput'] = true; 
            }
            addCompinputsMap['isDisplayAddCompInputs'] = true;
            component.set("v.addCompinputsMap",addCompinputsMap);
        } 
        if(displayAddComInputs && isValidInput){
            component.set("v.showSpinner",true);
            helper.saveAdditionalCompenseDetailsInCA(component,event,helper); 
        }
        
    },
    handleLoad : function(component,event,helper){
        component.set("v.showSpinner",false);
    },
    sendTesterPaymentClose : function(component,event,helper){
        component.set("v.isSendTesterPaymentModal",false);
    },
    closeLangTestingFlow : function(component,event,helper){
        if (event.getParam('status') === "FINISHED") {
            component.set("v.isLangTestingFlow",false);
        }
    },
    closeLangTestingFlowModal: function(component,event,helper){
        component.set("v.isLangTestingFlow",false);
    },
    getFullyLoadedValues : function(component,event,helper){
        var costRateRecord = component.get("v.costRateRecord");
        var defaultCR = component.get("v.defaultCR");
        var fullyLoadedAmt = 0.00;
        var sickLeave = $A.get("$Label.c.LT_Sick_Leave_Rate");
        
        if(defaultCR == 'Non-SCA LT' || defaultCR == 'LT with Billable Prep'){
            defaultCR = 'LT with Prep';
        }else if(defaultCR == 'LT without Billable Prep'){
            defaultCR = 'LT without Prep';
        }
        
        if(costRateRecord && costRateRecord.AcctSeed__Hourly_Cost__c &&  (defaultCR == 'LT with Prep' || defaultCR == 'LT without Prep' || defaultCR == 'DLI-W LT') && sickLeave){
            var sumOfVal = (parseFloat(sickLeave) * parseFloat(costRateRecord.AcctSeed__Hourly_Cost__c)).toFixed(2);
            fullyLoadedAmt = (parseFloat(sumOfVal) + parseFloat(costRateRecord.AcctSeed__Hourly_Cost__c)).toFixed(2);;
        }
        component.set("v.fulLoadAmt",fullyLoadedAmt);
    }
})