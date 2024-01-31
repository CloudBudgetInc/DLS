({
    doInit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        helper.getInitialFilterInformation(cmp);
    },
    accountingPeriodSearch : function(cmp ,event,helper){
        const serverSearchAction = cmp.get('c.getLookupRecords');
        cmp.find('apId').search(serverSearchAction);
    },
    accountLookupSearch : function(cmp ,event,helper){
        const serverSearchAction = cmp.get('c.getLookupRecords');
        cmp.find('accId').search(serverSearchAction);
    },
    changeBillingType : function(cmp ,event,helper){
        cmp.set("v.billingRowInfo",[]);
        cmp.set("v.billingRowDuplicateJSON",'');
        cmp.set("v.selectAllBillingLine",false);
        cmp.set("v.billingContact",'');
        cmp.set("v.isHideInvoicedPT",false);
    },
    projectLookupSearch : function(cmp ,event,helper){
        const serverSearchAction = cmp.get('c.getLookupRecords');
        cmp.find('projectId').search(serverSearchAction);
    },
    filterChange : function(cmp ,event, helper){
        var selectedObjLookup = cmp.get("v.selectedObjLookup");
        
        if((selectedObjLookup['account'] && selectedObjLookup['account'].length == 0) || (selectedObjLookup['accountingPeriod'] && selectedObjLookup['accountingPeriod'].length == 0)){
            cmp.set("v.billingRowInfo",[]);
            cmp.set("v.selectAllBillingLine",false);
            cmp.set("v.billingRowDuplicateJSON",'');
            cmp.set("v.billingContact",'');
            cmp.set("v.isHideInvoicedPT",false);
        }
    },
    // Accounding Period and Account Filter Validation
    billingSearchClick : function(cmp ,event,helper){
        var selectedObjLookup = cmp.get("v.selectedObjLookup");
        var accPeriodId = cmp.find('apId');
        var accountId = cmp.find('accId');
        var billingTypeId = cmp.find('billingTypeId');
        var isValid = true;
        
        if(selectedObjLookup && (selectedObjLookup['accountingPeriod'] && selectedObjLookup.accountingPeriod.length == 0)){
            isValid = false;
            $A.util.addClass(accPeriodId, 'slds-has-error');
        }else{
            $A.util.removeClass(accPeriodId, 'slds-has-error');
        }
        
        if(selectedObjLookup && (selectedObjLookup['account'] && selectedObjLookup.account.length == 0)){
            isValid = false;
            $A.util.addClass(accountId, 'slds-has-error');
        }else{
            $A.util.removeClass(accountId, 'slds-has-error');
        }
        
        if(billingTypeId){
            if(!billingTypeId.get("v.value")){
                isValid = false;
                $A.util.addClass(billingTypeId, 'slds-has-error');  
            }else{
                $A.util.removeClass(billingTypeId, 'slds-has-error');
            }
        }
        if(isValid){
            cmp.set("v.isHideInvoicedPT",false);
            cmp.set("v.billingColumnTotal","0.00");
            helper.getBillingTableInformation(cmp);
        }
    },// Open Billing Creation Modal
    openBillingModal : function(cmp,event,helper){
        var billingRowInfo = cmp.get("v.billingRowInfo");
        var isShowCreatingModel = false;
        var isValid = true;
        
        var qtyInput = cmp.find("qtyId");
        
        if(qtyInput){
            
            if(Array.isArray(qtyInput)){
                for(var i = 0;i < qtyInput.length;i++) { 
                    if(!qtyInput[i].get("v.value")){
                        isValid = false;
                        $A.util.addClass(qtyInput[i], 'slds-has-error'); 
                    }else {
                        $A.util.removeClass(qtyInput[i], 'slds-has-error'); 
                    }
                }
            }else {
                if(!qtyInput.get("v.value")){
                    isValid = false;
                    $A.util.addClass(qtyInput, 'slds-has-error'); 
                }else {
                    $A.util.removeClass(qtyInput, 'slds-has-error'); 
                }
            }
            
        }
        
        if(isValid){
            
            for(var i = 0;i < billingRowInfo.length;i++){
                var billingLineCreationInfo = [];
                var billingPT = billingRowInfo[i].projectTaskList;
                for(var j = 0;j < billingPT.length;j++){
                    if(billingPT[j]['isBillingLineChecked']){
                        isShowCreatingModel = true;
                    }
                }
            }
            
            if(isShowCreatingModel){
                var billingCreationOption = [];
                var billingType = cmp.get("v.billingType");
                
                if(billingType == '11001-Monthly Arrears'){
                    billingCreationOption.push('Create individual Billings for each Project');
                    billingCreationOption.push('Create single Billing for all Project');
                }else if(billingType == '11005-Prepayment' || (billingType == '11002-Billed at End')){
                    billingCreationOption.push('Create individual Journal Entries for each Project');
                }
                
                if(billingCreationOption.length > 0){
                    cmp.set("v.selectedBillingOption",billingCreationOption[0]);
                    cmp.set("v.billingCreationOption",billingCreationOption);
                    cmp.set("v.isCreateBilling",true);
                    cmp.find("createBill").open();
                }else{
                    cmp.set("v.selectedBillingOption",[]);
                }
            }
        }
    },
    closeBillings : function(cmp,event,helper){
        var billingCreationOption = cmp.get("v.billingCreationOption"); 
        if(billingCreationOption.length > 0){
            cmp.set("v.selectedBillingOption",billingCreationOption[0])
        }
        cmp.set("v.isCreateBilling",false);
        cmp.set("v.billingLineCreationMap",{});
        cmp.set("v.billingCreationMap",{});
    },// Billing and BillingLine Record Formation
    proceedToCreateBillingRec : function(cmp,event,helper){ 
        var billingRowInfo = cmp.get("v.billingRowInfo");
        var billingTypeGLAcc = cmp.get("v.billingTypeGLAcc");
        var projectIds = [];
        var billingLineCreationMap = {};
        var selectedBillingValue =  cmp.get("v.selectedBillingOption");
        var selectedObjLookup = cmp.get("v.selectedObjLookup");
        var billingCreationMap = {};
        var billingType = cmp.get("v.billingType");
        var accId = '';
        var accName = '';
        var accPeriodId = '';
        var isValid = false;
        var billingContactMap = {};
        var projectWithAccIdMap = {};
        
        if(billingType == '11001-Monthly Arrears'){
            
            if(selectedObjLookup.account.length > 0){
                accId = selectedObjLookup.account[0].Id;
                accName = selectedObjLookup.account[0].Name;
            }

            if(selectedBillingValue == "Create single Billing for all Project" && accName == "PVT"){
                helper.showToast(cmp,event,helper,'error','','"Single billing for each project" is not supported for "PVT", please use other option.','pester','info_alt');
            }else{
                
                for(var i = 0;i < billingRowInfo.length;i++){
                    
                    var billingLineCreationInfo = [];
                    var billingPT = billingRowInfo[i].projectTaskList;
                    for(var j = 0;j < billingPT.length;j++){
                        if(billingPT[j]['isBillingLineChecked'] && (!billingPT[j].isHidePTs)){
                            var billingLineCreationRec = {}; 
                            billingLineCreationRec.AcctSeed__Project__c = billingPT[j].parentProjectId;
                            billingLineCreationRec.AcctSeed__Project_Task__c = billingPT[j].projecTaskId;
                            billingLineCreationRec.AcctSeed__Rate__c = billingPT[j].unitPrice;
                            billingLineCreationRec.AcctSeed__Hours_Units__c = billingPT[j].quantity;
                            
                            if(billingPT[j].comment){
                                billingLineCreationRec.AcctSeed__Comment__c = billingPT[j].comment;
                            }
                            
                            if(billingPT[j].matRequestId){
                                billingLineCreationRec.Materials_Request__c = billingPT[j].matRequestId;
                            }
                            
                            if(billingPT[j].glAccountVar1){
                                billingLineCreationRec.AcctSeed__GL_Account_Variable_1__c = billingPT[j].glAccountVar1;
                            }
                            
                            if(billingPT[j].glAccountVar2){
                                billingLineCreationRec.AcctSeed__GL_Account_Variable_2__c = billingPT[j].glAccountVar2;
                            }
                            
                            if(billingPT[j].revenueGLAccount){
                                billingLineCreationRec.AcctSeed__Revenue_GL_Account__c = billingPT[j].revenueGLAccount;
                            }
                            
                            if(billingPT[j].projectTaskProductId){
                                billingLineCreationRec.AcctSeed__Product__c = billingPT[j].projectTaskProductId;
                            }
                            
                            if(billingPT[j].payableLineId){
                                billingLineCreationRec.Payable_Line__c = billingPT[j].payableLineId;                                
                            }
                            
                            if(billingPT[j].clinLookup && billingPT[j].clinLookup.length > 0){
                                billingLineCreationRec.CLIN__c = billingPT[j].clinLookup[0].Id;
                            }
                            billingLineCreationInfo.push(billingLineCreationRec);
                        }
                    }
                    if(billingLineCreationInfo.length  > 0) {
                        projectIds.push(billingRowInfo[i].projectId);
                        billingLineCreationMap[billingRowInfo[i].projectId] = billingLineCreationInfo;
                        billingContactMap[billingRowInfo[i].projectId] = billingRowInfo[i].billingContact;
                        projectWithAccIdMap[billingRowInfo[i].projectId] = billingRowInfo[i].accountId;
                        isValid = true;
                    }
                    
                }
                cmp.set("v.billingContactMap",billingContactMap);
                cmp.set("v.billingLineCreationMap",billingLineCreationMap);
                
                if(selectedObjLookup.accountingPeriod.length > 0){
                    accPeriodId = selectedObjLookup.accountingPeriod[0].Id;
                }
                var billingRec = {'AcctSeed__Customer__c' : accId,'AcctSeed__Accounting_Period__c' : accPeriodId};
                if(selectedBillingValue == 'Create individual Billings for each Project' 
                   	|| (selectedBillingValue == 'Create single Billing for all Project' && projectIds.length == 1)){
                   
                    for(var i = 0;i < projectIds.length;i++){
                        if(projectIds[i]){
                            billingRec.Project__c = projectIds[i];
                            billingRec.AcctSeed__Billing_Contact__c = billingContactMap[projectIds[i]];
                            billingRec.AcctSeed__Customer__c = projectWithAccIdMap[projectIds[i]];
                            billingCreationMap[projectIds[i]] = JSON.parse(JSON.stringify(billingRec));
                        }
                    }
                }else {
                    billingCreationMap['Single Billing'] = billingRec;
                }
                cmp.set("v.billingCreationMap",billingCreationMap);
                if(isValid){
                    cmp.set("v.isCreateBilling",false);
                    helper.checkBillORJournalRecsExist(cmp,event,helper,'Billing',JSON.stringify(projectIds),false)
                }else{
                    helper.showToast(cmp,event,helper,'error','','There is no Item selected','pester','info_alt');
                }
            }
        }else if(billingType == '11005-Prepayment' || billingType == '11002-Billed at End'){
            
            helper.journalRecordFormation(cmp);
        }
    },
    checkBillingLine : function(cmp, event, helper){
        var billingRowInfo = cmp.get("v.billingRowInfo");
        var isAllBillLine = true;
        
        for(var i = 0;i < billingRowInfo.length;i++){
            var billingPT = billingRowInfo[i].projectTaskList;
            var isBillingCheckedCount = 0;
            for(var j = 0;j < billingPT.length;j++){
                if(billingPT[j].isBillingLineChecked){
                    isBillingCheckedCount += 1;
                }
            }
            if(billingPT.length != isBillingCheckedCount){
                isAllBillLine = false;
            }
        }
        if(!isAllBillLine){
            cmp.set("v.selectAllBillingLine",isAllBillLine);
        }
        cmp.set("v.billingRowInfo",billingRowInfo)
    },
    closeBillingSuccessModal : function(cmp, event, helper){
        var billingRow = cmp.get("v.billingRowDuplicateJSON");
        var billingCreationOption = cmp.get("v.billingCreationOption"); 
        var billingType = cmp.get("v.billingType");
        var sObjectName = ((billingType == '11005-Prepayment'|| billingType == '11002-Billed at End') ? 'AcctSeed__Journal_Entry__c' : 'AcctSeed__Billing__c');
        
        if(billingCreationOption.length > 0){
            cmp.set("v.selectedBillingOption",billingCreationOption[0])
        }        
        cmp.set("v.billingRowInfo",JSON.parse(billingRow));
        cmp.set("v.isBillingSuccessModal",false);
        helper.redirectToBillingListView(cmp,sObjectName);
    },
    selectAllBillLine : function(cmp, event, helper){
        var billingRowInfo = cmp.get("v.billingRowInfo");
        var selectAllBillingLine = cmp.get("v.selectAllBillingLine");
        
        for(var i = 0;i < billingRowInfo.length;i++){
            var billingPT = billingRowInfo[i].projectTaskList;
            
            for(var j = 0;j < billingPT.length;j++){
                if(selectAllBillingLine && (!billingPT[j].isHidePTs)){
                    billingPT[j].isBillingLineChecked = true;
                }else{
                    billingPT[j].isBillingLineChecked = false;
                }
            }
        }
        cmp.set("v.billingRowInfo",billingRowInfo)
    },
    closeValModal : function(cmp, event, helper){
        cmp.set("v.creationValidationModal",false);
    },
    closeExistRecsModal : function(cmp, event, helper){
        cmp.set("v.billORJournalExistRecsModal",false);
    },
    clinLookupSearch : function(cmp, event, helper){
        const serverSearchAction = cmp.get('c.getLookupRecords');
        event.getSource().search(serverSearchAction);
    },
    hideInvoicedPTs : function(cmp, event, helper){
        
        var billingType = cmp.get("v.billingType");
        var billingJournalRowInfo = cmp.get("v.billingRowInfo");
        var projectIds = [];
        
        cmp.set("v.showSpinner",true);
        
        if(cmp.get("v.isHideInvoicedPT") && billingJournalRowInfo.length > 0){
            
            for(var i = 0;i < billingJournalRowInfo.length;i++){
                projectIds.push(billingJournalRowInfo[i].projectId);
            }
            cmp.set("v.billingRowDuplicateJSON",JSON.stringify(billingJournalRowInfo));
            if(billingType == '11005-Prepayment' || billingType == '11002-Billed at End'){
                helper.checkBillORJournalRecsExist(cmp,event,helper,'Journal',JSON.stringify(projectIds),true);
            }else if(billingType == '11001-Monthly Arrears'){
                helper.checkBillORJournalRecsExist(cmp,event,helper,'Billing',JSON.stringify(projectIds),true);
            }
        }else if(!cmp.get("v.isHideInvoicedPT")){
            
            var billJournRowInfo = cmp.get("v.billingRowInfo");
            var billColTotalAmt = 0.00;
            
            if(billJournRowInfo.length > 0){
                 helper.calculateBillingCoLTotalCnt(cmp, event, helper, billJournRowInfo, true);
            }else {
                if(cmp.get("v.billingRowDuplicateJSON")){
                    
                    var billingRow = JSON.parse(cmp.get("v.billingRowDuplicateJSON"));
                    helper.calculateBillingCoLTotalCnt(cmp, event, helper, billingRow, false);
                }
            }
            window.setTimeout(
                $A.getCallback(function() {
                    cmp.set("v.selectAllBillingLine",false);
                    cmp.set("v.showSpinner", false);
                }), 2500);
            
        }else {
            cmp.set("v.showSpinner", false);
        }
    },
    calculateTotal : function(cmp, event, helper){

        var billingRowInfo = cmp.get("v.billingRowInfo");
        var oldbillingRowInfo = JSON.parse(cmp.get("v.billingRowDuplicateJSON"));
        var billingColumnTotal = cmp.get("v.billingColumnTotal");
        
        var indexs = event.getSource().get("v.name");
        var proIndex = parseInt(indexs.split("~")[0]);
        var ptIndex = parseInt(indexs.split("~")[1]);

        var oldBillingPT = oldbillingRowInfo[proIndex].projectTaskList;
        var oldTotal = parseFloat(oldBillingPT[ptIndex].total);
        billingColumnTotal = billingColumnTotal - oldTotal;
        
        var newtotal = 0.00;
        var billingPT = billingRowInfo[proIndex].projectTaskList;
        
        if(billingPT[ptIndex].quantity && billingPT[ptIndex].unitPrice){
            newtotal = (parseFloat(billingPT[ptIndex].unitPrice) * parseFloat(billingPT[ptIndex].quantity));
        }
        
        billingPT[ptIndex].total = newtotal; 
        
        billingColumnTotal = billingColumnTotal + newtotal;
        
        if(!billingColumnTotal){
            billingColumnTotal = 0.00;
        }
        
        cmp.set("v.billingRowInfo",billingRowInfo);
        cmp.set("v.billingRowDuplicateJSON",JSON.stringify(billingRowInfo));
        cmp.set("v.billingColumnTotal",billingColumnTotal);
    },
    goToSObjPage : function(cmp, event, helper){
        var rowId = event.currentTarget.name;
        
        if(rowId){
            var sObjectEvent = $A.get("e.force:navigateToSObject");
            
            sObjectEvent .setParams({
                "recordId": window.open('/'+rowId), 
                "slideDevName": "detail"
            });
            sObjectEvent.fire(); 
        }
    },
    
})