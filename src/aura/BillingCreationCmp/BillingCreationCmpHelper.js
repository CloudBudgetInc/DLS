({
    getInitialFilterInformation : function(cmp) {
        var sObjectName = cmp.get("v.sObjectName");
        var self = this;
        const server = cmp.find('server');
        var action = cmp.get("c.getInitialFilterValues");
        server.callServer(
            action, {},
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                var selectedObjLookup = cmp.get("v.selectedObjLookup");
                var initialInfo = {};
                if(result){
                    if(result.accountingPeriodFilter && result.accountingPeriodFilter.length > 0){
                        selectedObjLookup.accountingPeriod = result.accountingPeriodFilter;
                    }
                    cmp.set("v.selectedObjLookup",selectedObjLookup);
                    cmp.set("v.billingTypePickList",result.billingTypePickList);
                    cmp.set("v.showSpinner",false);
                }                    
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,helper,'error','',errors[0].message,'pester','info_alt');
            }),
            false,
            false,
            false
        );
    },
    getBillingTableInformation : function(cmp){
        var selectedObjLookup = cmp.get("v.selectedObjLookup");
        var projectId = null
        var accId = null;
        var accPeriodId = null;
        
        cmp.set("v.showSpinner",true);
        if(selectedObjLookup.project.length > 0){
            projectId = selectedObjLookup.project[0].Id;
        }
        if(selectedObjLookup.account.length > 0){
            accId = selectedObjLookup.account[0].Id;
        }
        if(selectedObjLookup.accountingPeriod.length > 0){
            accPeriodId = selectedObjLookup.accountingPeriod[0].Id;
        }
        console.log(accPeriodId);
        
        var self = this;
        const server = cmp.find('server');
        var action = cmp.get("c.getBillingRowInfo");
        server.callServer(
            action, {
                'projectId' : projectId,
                'accId' : accId,
                'accountPeriodId' : accPeriodId,
                'billingType' : cmp.get("v.billingType")
            },
            false,
            $A.getCallback(function(response) {
                cmp.set("v.billingContact",'');
                var result = JSON.parse(response);
                console.log(result);
                cmp.set("v.billingRowDuplicateJSON",JSON.stringify(result.billingRowInfo));
                cmp.set("v.showSpinner",false);
                if(result){
                    cmp.set("v.billingRowInfo",result.billingRowInfo);
                    cmp.set("v.billingContact",result.billingContact);
                    cmp.set("v.billingTypeGLAcc",result.debitGLAccount);
                    cmp.set("v.isShowCLIN",result.isShowCLIN);
                    cmp.set("v.billingColumnTotal",result.billingColumnTotal)
                    cmp.set("v.selectAllBillingLine",false);
                    cmp.set("v.isEditableCLIN",result.isEditableClin);
                    cmp.set("v.accountCodeMap",result.accountCodeMap);
                    cmp.set("v.billingRecordsCnt",result.billingRecordsCnt);
                }                
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,helper,'error','',errors[0].message,'pester','info_alt');        
            }),
            false,
            false,
            false
        );
    },// Billing and BillingLine creation callback
    createBillingsRecs : function(cmp,event,helper){
        var selectedObjLookup = cmp.get("v.selectedObjLookup");
        var accPeriodId = null;
        var accId = null;
        
        if(selectedObjLookup.accountingPeriod.length > 0){
            accPeriodId = selectedObjLookup.accountingPeriod[0].Id;
        }
        if(selectedObjLookup.account.length > 0){
            accId = selectedObjLookup.account[0].Id;
        }
        cmp.set("v.showSpinner",true);

        var self = this;
        const server = cmp.find('server');
        var action = cmp.get("c.createBillings");
        server.callServer(
            action, {
                'billingLineJSON' : JSON.stringify(cmp.get("v.billingLineCreationMap")),
                'billingJSON' : JSON.stringify(cmp.get("v.billingCreationMap")),
                'accPeriod' : accPeriodId,
                'accId'  : accId,
                'billingContactMapJSON' : JSON.stringify(cmp.get("v.billingContactMap"))
            },
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.isBillingSuccessModal",true);
                cmp.find("successBilling").open();
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,helper,'error','',errors[0].message,'pester','info_alt');
            }),
            false,
            false,
            false
        );
    },
    redirectToBillingListView : function(cmp,sObjectName){
        var action = cmp.get("c.getListViews");
        cmp.set("v.showSpinner",true);
        
        var self = this;
        const server = cmp.find('server');
        server.callServer(
            action, {
                'sObjectName' : sObjectName
            },
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                var listviewId = response;
                cmp.set("v.selectAllBillingLine",false);
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviewId,
                    "listViewName": null,
                    "scope": sObjectName
                });
                navEvent.fire();
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,helper,'error','',errors[0].message,'pester','info_alt');
            }),
            false,
            false,
            false
        );
    },
    creatingJournalRecs : function(cmp,event,helper){
        var selectedObjLookup = cmp.get("v.selectedObjLookup");
        
        var accId = '';
        var accPeriodId = '';
        var accName = '';
        
        if(selectedObjLookup.account.length > 0){
            accId = selectedObjLookup.account[0].Id;
            accName = selectedObjLookup.account[0].Name;
        }
        if(selectedObjLookup.accountingPeriod.length > 0){
            accPeriodId = selectedObjLookup.accountingPeriod[0].Id;
        }
        
        var journalCreationMap = cmp.get("v.journalCreationMap");
        var journalEntryLineCreationMap  = cmp.get("v.journalEntryLineCreationMap");
        cmp.set("v.showSpinner",true);
        
        var self = this;
        var action = cmp.get("c.journalEntryCreation");
        const server = cmp.find('server');
        server.callServer(
            action, {
                'journalEntryJSON' : JSON.stringify(journalCreationMap),
                'journalEntryLineJSON' : JSON.stringify(journalEntryLineCreationMap),
                'accId' : accId,
                'accPeriod' : accPeriodId
            },
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.isBillingSuccessModal",true);
                cmp.find("successBilling").open();
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,helper,'error','',errors[0].message,'pester','info_alt');
            }),
            false,
            false,
            false
        );
    },
    journalRecordFormation : function(cmp,event,helper){
        var journalRowInfo = cmp.get("v.billingRowInfo");
        var billingTypeGLAcc = cmp.get("v.billingTypeGLAcc");
        var projectIds = [];
        var journalEntryLineCreationMap = {};
        var selectedJournalValue =  cmp.get("v.selectedBillingOption");
        var selectedObjLookup = cmp.get("v.selectedObjLookup");
        var journalCreationMap = {};
        var billingType = cmp.get("v.billingType");
        var accId = '';
        var accPeriodId = '';
        var isValid = false;
        var validationErrorList = [];
        var venderNameList = [];
        var accPeriodName = '';
        var accNameCodeSet = [];
        
        cmp.set("v.showSpinner",true);
        cmp.set("v.isCreateBilling",false);
        cmp.set("v.journalCreationMap",{});
        cmp.set("v.journalEntryLineCreationMap",{});
        
        
        if(selectedObjLookup.account.length > 0){
            accId = selectedObjLookup.account[0].Id;
        }
        if(selectedObjLookup.accountingPeriod.length > 0){
            accPeriodId = selectedObjLookup.accountingPeriod[0].Id
            accPeriodName = selectedObjLookup.accountingPeriod[0].Name;
        }
        
        
        for(var i = 0;i < journalRowInfo.length;i++){
            var journalEntryLineCreationInfo = [];
            var billingPT = journalRowInfo[i].projectTaskList;
            
            for(var j = 0;j < billingPT.length;j++){
                if(billingPT[j].isBillingLineChecked){
                    var journalCreditLineCreationRec = {}; 
                    var journalDebitLineCreationRec = {};
                    var journalLineCreationRec = {};
                    
                    if(journalRowInfo[i].accountId){
                        journalLineCreationRec.AcctSeed__Account__c = journalRowInfo[i].accountId;
                        journalDebitLineCreationRec.AcctSeed__Account__c = journalRowInfo[i].accountId;
                    }
                       
                    if(billingPT[j].projectTaskProductId){
                        journalLineCreationRec.AcctSeed__Product__c = billingPT[j].projectTaskProductId;
                    }
                    
                    if(billingPT[j].glAccountVar1){
                        journalLineCreationRec.AcctSeed__GL_Account_Variable_1__c = billingPT[j].glAccountVar1;
                    }
                    
                    if(billingPT[j].glAccountVar2){
                        journalLineCreationRec.AcctSeed__GL_Account_Variable_2__c = billingPT[j].glAccountVar2;
                    }
                    
                    if(billingPT[j].comment){
                        journalLineCreationRec.AcctSeed__Reference__c = billingPT[j].comment;
                        journalDebitLineCreationRec.AcctSeed__Reference__c = billingPT[j].comment;
                    }
                    
                    journalLineCreationRec.AcctSeed__Credit__c =  billingPT[j].total;
                    journalDebitLineCreationRec.AcctSeed__Debit__c = billingPT[j].total;
                    
                    if(billingPT[j].matRequestId){
                        journalLineCreationRec.Materials_Request__c = billingPT[j].matRequestId;
                    }
                    
                    journalLineCreationRec.AcctSeed__Units__c = billingPT[j].quantity;
                    journalDebitLineCreationRec.AcctSeed__Units__c = billingPT[j].quantity;
                    
                    journalLineCreationRec.AcctSeed__Project__c = billingPT[j].parentProjectId;
                    journalLineCreationRec.AcctSeed__Project_Task__c = billingPT[j].projecTaskId;
                    
                    journalDebitLineCreationRec.AcctSeed__Project__c = billingPT[j].parentProjectId;
                    journalDebitLineCreationRec.AcctSeed__Project_Task__c = billingPT[j].projecTaskId;
                    
                    if(billingPT[j].clinLookup && billingPT[j].clinLookup.length > 0){
                        journalLineCreationRec.CLIN__c = billingPT[j].clinLookup[0].Id;
                    }
                    
                    if(billingPT[j].payableLineId){
                        journalLineCreationRec.Payable_Line__c = billingPT[j].payableLineId;                                
                    }
                    
                    journalCreditLineCreationRec = JSON.parse(JSON.stringify(journalLineCreationRec));

                    if(accNameCodeSet.indexOf(journalRowInfo[i].proAccIdWithName) == -1) {
                        accNameCodeSet.push(journalRowInfo[i].proAccIdWithName);
                    }   
                    
                    if(billingPT[j].revenueGLAccount){
                        journalCreditLineCreationRec.AcctSeed__GL_Account__c = billingPT[j].revenueGLAccount;
                    }else{
                        if(!billingPT[j].vendorName){
                            validationErrorList.push('Revenue GL Account is required for the project task <b>'+billingPT[j].projecTaskName+'</b> of '+journalRowInfo[i].proName+'.');
                        }else if(billingPT[j].vendorName && venderNameList.indexOf(billingPT[j].vendorName) == -1){
                            venderNameList.push(billingPT[j].vendorName);
                            
                            if(billingPT[j].vendorName = 'D2L'){
                                validationErrorList.push('<b>40540 - Learning Mngmt System Revenue </b> GL Account is not available.');
                            }else if(billingPT[j].vendorName = 'In-house'){
                                validationErrorList.push('<b>40520 - In-house Materials Revenue </b> GL Account is not available.');
                            }else if(billingPT[j].vendorName = 'SalesTax'){
                                validationErrorList.push('<b>25501 - Sales Tax Payable - New </b> GL Account is not available.');
                            }else if(billingPT[j].vendorName = 'External'){
                                validationErrorList.push('<b>12853 - RE - Language Materials </b> GL Account is not available.');
                            }
                            
                        }
                    }
                    
                    if(billingTypeGLAcc[billingType]){
                        journalDebitLineCreationRec.AcctSeed__GL_Account__c = billingTypeGLAcc[billingType];
                    }
                    
                    journalEntryLineCreationInfo.push(journalCreditLineCreationRec);
                    journalEntryLineCreationInfo.push(journalDebitLineCreationRec);
                }
            }
            
            if(journalEntryLineCreationInfo.length > 0){
                projectIds.push(journalRowInfo[i].projectId);
                journalEntryLineCreationMap[journalRowInfo[i].projectId] = journalEntryLineCreationInfo;
            }
        }
        
        var journalEntry = {'AcctSeed__Accounting_Period__c' : accPeriodId ,'AcctSeed__Status__c' : 'Posted'};
        if(selectedJournalValue == 'Create individual Journal Entries for each Project'){
            for(var i = 0;i < projectIds.length;i++){
                if(projectIds[i]){
                    journalEntry.Project__c = projectIds[i];
                    journalCreationMap[projectIds[i]] = JSON.parse(JSON.stringify(journalEntry));
                }
            }
        }
        
        if(accNameCodeSet){  
            var accountCodeMap = cmp.get("v.accountCodeMap");
            var accNames = '';
            var accNameCnt = 0;
            
            for(var i = 0;i < accNameCodeSet.length;i++){
                if(!(accountCodeMap[accNameCodeSet[i]])){
                   var accNameList = (accNameCodeSet[i]).split("~");
                    if(accNameList[1]){
                        accNames += (accNameCnt > 0 ? ', ' : '') +  accNameList[1];
                        accNameCnt += 1;
                    }
                }
            }
            if(accNames){
                validationErrorList.unshift('Account Code is required for Account: <b>'+accNames+'</b>.'); 
            }
        }
        console.log(journalCreationMap);
        console.log(journalEntryLineCreationMap);
        console.log(validationErrorList);
        
        cmp.set("v.journalCreationMap",journalCreationMap);
        cmp.set("v.journalEntryLineCreationMap",journalEntryLineCreationMap);
        if(validationErrorList.length == 0){
            
         	this.checkBillORJournalRecsExist(cmp,event,helper,'Journal',JSON.stringify(projectIds),false);
            
        }else{
            cmp.set("v.creationValidationModal",true);
            cmp.set("v.showSpinner",false);
            var valMsg = '';
            
            if(!billingTypeGLAcc[billingType]){
                valMsg = (billingType == '11002-Billed at End' ? '<div><b>11002 - Unbilled Accounts Receivable </b> GL Account is not available.</div> <br/>' : '<div><b>11005 - AR - Deferred Revenue</b> GL Account is not available.</div> <br/>');
            }
            
            for(var i = 0;i < validationErrorList.length;i++){
                valMsg += '<div>'+validationErrorList[i]+'</div>';
            }
            cmp.set("v.validationMsg",valMsg);
            cmp.find("createVal").open();
        }
    },
    checkBillORJournalRecsExist : function(cmp,event,helper,objectType,projectIdsJSON,hidePTs){
        var selectedObjLookup = cmp.get("v.selectedObjLookup");
        var accPeriodId = '';
        
        if(selectedObjLookup.accountingPeriod.length > 0){
            accPeriodId = selectedObjLookup.accountingPeriod[0].Id;
        }
        
        var self = this;
        var action = cmp.get("c.checkBillORJournalExist");
        const server = cmp.find('server');
        server.callServer(
            action, {
                'objectType' : objectType,
                'projectIdsJSON' :projectIdsJSON,
                'accPeriod' : accPeriodId
            },
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                
                var result = response;
                var billORJournalExistMap = JSON.parse(result);
                var billingRowInfo = cmp.get("v.billingRowInfo");
                var displayExistRecsMsg = '';
                var displayCnt = 0;
                var isHideInvoicedPT = cmp.get("v.isHideInvoicedPT");
                var hidePTsCount = 0;
                var actualPTsCount = 0;
                var billingColTotal = 0.00;
                
                console.log(billORJournalExistMap); 
                for(var i = 0;i < billingRowInfo.length;i++){
                    var billingPT = billingRowInfo[i].projectTaskList;
                    var existRecString = '';

                    for(var j = 0;j < billingPT.length;j++){
                        var billORJournalineId = '';
                        actualPTsCount = actualPTsCount + 1;
                        
                        if((!hidePTs) && billingPT[j].isBillingLineChecked && ((isHideInvoicedPT == false) || (isHideInvoicedPT == true && billingPT[j].isHidePTs == false))){
                            if(billORJournalExistMap[billingPT[j].parentProjectId+'~'+billingPT[j].projecTaskId+'~'+billingPT[j].comment]){
                                
                                billORJournalineId = billORJournalExistMap[billingPT[j].parentProjectId+'~'+billingPT[j].projecTaskId+'~'+billingPT[j].comment];
                                existRecString += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+billingPT[j].projecTaskName+' - '+'<a href='+'\'/'+billORJournalineId+'\' target ='+'\'_blank\'>'+billingPT[j].comment+'</a><br/>'
                                
                            }else if(billORJournalExistMap[billingPT[j].parentProjectId+'~'+billingPT[j].projecTaskId+'~'+billingPT[j].matRequestId]){
                                
                                billORJournalineId = billORJournalExistMap[billingPT[j].parentProjectId+'~'+billingPT[j].projecTaskId+'~'+billingPT[j].matRequestId];
                                existRecString += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+billingPT[j].projecTaskName+' - '+'<a href='+'\'/'+billORJournalineId+'\' target ='+'\'_blank\'>'+billingPT[j].comment+'</a><br/>'
                                
                            }else if(billORJournalExistMap[billingPT[j].parentProjectId+'~'+billingPT[j].projecTaskId+'~'+billingPT[j].payableLineId]){
                                
                                billORJournalineId = billORJournalExistMap[billingPT[j].parentProjectId+'~'+billingPT[j].projecTaskId+'~'+billingPT[j].payableLineId];
                                existRecString += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+billingPT[j].projecTaskName+' - '+'<a href='+'\'/'+billORJournalineId+'\' target ='+'\'_blank\'>'+billingPT[j].comment+'</a><br/>'
                                
                            }else if(billORJournalExistMap[billingPT[j].parentProjectId+'~'+billingPT[j].projecTaskId+'~'+billingPT[j].glAccountVar1]){
                                
                                billORJournalineId = billORJournalExistMap[billingPT[j].parentProjectId+'~'+billingPT[j].projecTaskId+'~'+billingPT[j].glAccountVar1];
                                existRecString += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+billingPT[j].projecTaskName+' - '+'<a href='+'\'/'+billORJournalineId+'\' target ='+'\'_blank\'>'+billingPT[j].comment+'</a><br/>'
                                
                            }
                        }else if(hidePTs){
                            if((billORJournalExistMap[billingPT[j].parentProjectId+'~'+billingPT[j].projecTaskId+'~'+billingPT[j].comment] 
                                 || billORJournalExistMap[billingPT[j].parentProjectId+'~'+billingPT[j].projecTaskId+'~'+billingPT[j].matRequestId] 
                                 || billORJournalExistMap[billingPT[j].parentProjectId+'~'+billingPT[j].projecTaskId+'~'+billingPT[j].payableLineId]
                                 || billORJournalExistMap[billingPT[j].parentProjectId+'~'+billingPT[j].projecTaskId+'~'+billingPT[j].glAccountVar1])){
                                
                                billingPT[j].isHidePTs = true;
                                hidePTsCount = hidePTsCount + 1;
                            }else {
                                billingColTotal = billingColTotal + parseFloat(billingPT[j].total);
                            }
                        }
                    }
                    
                    if(existRecString && (!hidePTs)){
                        displayCnt = displayCnt + 1;
                        displayExistRecsMsg += '<br/><b><h2>'+(displayCnt)+') '+billingRowInfo[i].proName+'</h2></b>'+existRecString;
                    }
                }
                
                if(hidePTs){
                    
                    if(hidePTsCount == actualPTsCount){
                        billingRowInfo = [];
                    }
                    
                }
                
                if(!hidePTs){
                    if(!(displayExistRecsMsg)){
                        if(objectType == 'Billing'){
                            self.createBillingsRecs(cmp,event,helper);
                        }else{
                            self.creatingJournalRecs(cmp,event,helper);
                        }
                    }else{
                        cmp.set("v.displayExistRecsMsg",displayExistRecsMsg);
                        cmp.set("v.billORJournalExistRecsModal",true);
                        cmp.find("existRecModal").open();
                    }
                }else{
                    cmp.set("v.showSpinner",false);
                    cmp.set("v.billingColumnTotal",billingColTotal);
                    cmp.set("v.billingRowInfo",billingRowInfo);
                    var recordsCnt = actualPTsCount - hidePTsCount;
                    cmp.set("v.billingRecordsCnt",recordsCnt);
                }
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,helper,'error','',errors[0].message,'pester','info_alt');
            }),
            false,
            false,
            false
        );
    },
     showToast: function(component, event, helper, type, title, message, mode,key) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            key: key,
            title: title,
            type: type,
            mode: mode
        });
        toastEvent.fire();
    },
    calculateBillingCoLTotalCnt : function(cmp, event, helper, billingRowInfo, isHidePTs){
        var totalColAmount = 0.00;
        var billingRecordsCnt = 0;
        
        for(var i = 0;i < billingRowInfo.length;i++){
            
            var billingPT = billingRowInfo[i].projectTaskList;
            for(var j = 0;j < billingPT.length;j++){
                
                if(billingPT[j].quantity && billingPT[j].unitPrice){
                    var total = (parseFloat(billingPT[j].quantity) * parseFloat(billingPT[j].unitPrice));
                    
                    if(isHidePTs){
                        billingPT[j].isHidePTs = false;  
                    }
                    
                    if(!billingPT[j].isHidePTs){
                        totalColAmount += total;
                    }
                    
                    billingPT[j].total = total;
                }else {
                    billingPT[j].total = 0.00;  
                }
                
                if(!billingPT[j].isHidePTs){
                    billingRecordsCnt += 1;
                }
            }
        }
       
        cmp.set("v.billingRowInfo",billingRowInfo);
        cmp.set("v.billingRecordsCnt",billingRecordsCnt);
        cmp.set("v.billingColumnTotal",totalColAmount);
    },
})