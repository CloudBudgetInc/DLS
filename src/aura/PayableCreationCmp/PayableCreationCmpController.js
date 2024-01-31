({
    doinit : function(cmp, event, helper) {
        helper.getInfoFromBillDotCom(cmp,event);
    },
    submitClick : function(cmp, event,helper){
        var stDate = cmp.get("v.fromDate");
        var edDate = cmp.get("v.toDate");
        var isValid = true;
        
        var stCmp = cmp.find("fromDate");
        if(!stDate){
            isValid = false;
            $A.util.addClass(stCmp,"slds-has-error");
        }else {
            $A.util.removeClass(stCmp,"slds-has-error");
        }
        
        var edCmp = cmp.find("toDate");
        if(!edDate){
            isValid = false;
            
            $A.util.addClass(edCmp,"slds-has-error");
        }else {
            $A.util.removeClass(edCmp,"slds-has-error");
        }
        
        if(isValid){
            helper.getInfoFromBillDotCom(cmp,event);
        }
    },
    openLineDetail : function(cmp, event,helper){
        var target = event.currentTarget;
        var index = target.getAttribute("data-name");
        var payableList = cmp.get("v.payableList");
        var cashDisbursementList = cmp.get("v.billPaymentList");
        var vendorRelCashDisbursement = [];
        var pay = payableList[index];
        console.log(pay);
        var payRec = pay.payable;
        
        cmp.set("v.visibleError",false);
        payRec.vendorName = pay.vendorName;
        payRec.amount = pay.amount;
        payRec.dateVal = pay.dateVal;
        payRec.dueDateVal = pay.dueDateVal;
        payRec.glPostingDate = pay.glPostingDate;
        payRec.accountingPeriod = pay.accountingPeriod;
        payRec.payableName = pay.payableName;
        payRec.isPayableExist = pay.isPayableExist;
        payRec.isPayableWithPayableLineExist = pay.isPayableWithPayableLineExist;
        payRec.billAPApprovalStatus = pay.billAPApprovalStatus;
       
        if(payRec.AcctSeed__Vendor__c){
           payRec.projectCondition = ' AcctSeed__Account__c = \''+payRec.AcctSeed__Vendor__c+'\'';
        }else{
           payRec.projectCondition = '';  
        }
        
        if(payRec.AcctSeed__Payee_Reference__c){
            for(var i = 0;i < cashDisbursementList.length;i++){
                var cashDisbursement = cashDisbursementList[i].cash;
                if(cashDisbursement.AcctSeed__Reference__c && cashDisbursement.AcctSeed__Reference__c == payRec.AcctSeed__Payee_Reference__c){
                    /*cashDisbursement.vendorName = cashDisbursementList[i].vendorName;
                    cashDisbursement.bankGLAccName = cashDisbursementList[i].bankGlAccName;
                    cashDisbursement.debitGlAccName = cashDisbursementList[i].debitGlAccName;
                    cashDisbursement.isCashDisbursementExist = cashDisbursementList[i].isCashDisbursementExist;
                    cashDisbursement.cashDisburseId = cashDisbursementList[i].cashDisBurseId;
                    cashDisbursement.cashDisburseName = cashDisbursementList[i].cashDisBurseName;*/
                    vendorRelCashDisbursement.push(cashDisbursementList[i]);
                }
            }
        }
        
        var payableLines = pay.payableLine;
        var payableLineList = [];
        for(var i = 0;i < payableLines.length;i++){
            var payableLine = {};
			payableLine = payableLines[i].payLine;
            payableLine.projectName = payableLines[i].projectName;
            payableLine.projectTaskName = payableLines[i].projectTaskName;
            payableLine.projectTaskName = payableLines[i].projectTaskName; 
            payableLine.expenseGlAccName = payableLines[i].expenseGlAccName;
            payableLine.glAccountVarName = payableLines[i].glAccountVarName;
            payableLine.gl2AccountVarName = payableLines[i].gl2AccountVarName;
            payableLine.isPayableLineExist = payableLines[i].isPayableLineExist;
            payableLine.payableLineId = payableLines[i].payableLineId;
            payableLine.payableLineName = payableLines[i].payableLineName;
            payableLine.accountingPeriod =  payableLines[i].accountingPeriod;
            payableLine.isProTaskRelatedProject =  payableLines[i].isProTaskRelatedProject;
            if(payableLine.AcctSeed__Amount__c){                
                payableLine.AcctSeed__Amount__c = helper.formatAmntStr(cmp, payableLine.AcctSeed__Amount__c.toString());
            }
            payableLine.projectLookup = payableLines[i].projectLookup;;
            payableLine.proTaskLookup = payableLines[i].projectLookup;;
            payableLine.projectTaskCondition = '';
            payableLineList.push(payableLine);
        }
        //console.log('::::::::::vendorRelCashDisbursement::::',vendorRelCashDisbursement);
        cmp.set("v.payRelCashDisburseList",vendorRelCashDisbursement);
        cmp.set("v.payable",payRec);
        cmp.set("v.payableLineList",payableLineList);
        cmp.find('openLineDetail').open();
    },
    closeDetail : function(cmp, event, helper){
        cmp.find('openLineDetail').close();
        helper.getInfoFromBillDotCom(cmp,event);
    },
    addDecimalPointToQty : function(cmp, event, helper){
        var payableLineList = cmp.get("v.payableLineList");
        var index = event.getSource().get("v.name");
        var lineIndex = parseInt(index);
        var payLine = payableLineList[index];
        
        if(payLine.AcctSeed__Amount__c){ 
            payLine.AcctSeed__Amount__c = helper.formatAmntStr(cmp, payLine.AcctSeed__Amount__c.toString());
        }
        payableLineList[index] = payLine;
        cmp.set("v.payableLineList",payableLineList);
    },
    addDecimalPointToAmount : function(cmp, event, helper){
        var payable = cmp.get("v.payable");
        if(payable.amount){
            payable.amount = helper.formatAmntStr(cmp, payable.amount.toString());
        }
        cmp.set("v.payable",payable);
    },
    calculateAmtperQuantity : function(cmp, event, helper){
        var payableLineList = cmp.get("v.payableLineList");
        var index = event.getSource().get("v.name");
        var lineIndex = parseInt(index);
        var payLine = payableLineList[index];
        
        if(payLine.AcctSeed__Amount__c && payLine.AcctSeed__Quantity__c){  
          
            payLine.AcctSeed__Amount__c = payLine.AcctSeed__Amount__c;
            payLine.AcctSeed__Quantity__c = payLine.AcctSeed__Quantity__c; 
            payLine.Amount_per_Quantity__c = (parseFloat(payLine.AcctSeed__Amount__c) * parseFloat(payLine.AcctSeed__Quantity__c));
          
        }else{
            payLine.Amount_per_Quantity__c = 0.00;
        }
        
        payableLineList[index] = payLine;
        cmp.set("v.payableLineList",payableLineList);
    },
    payableCreationInputValidations : function(cmp, event, helper){
        var isValid = true;
        var payInput = cmp.find("payInput");
        var payableLineList = cmp.get("v.payableLineList");
        
        if(payableLineList.length > 0){
            if(Array.isArray(payInput)){
                
                for(var i = 0;i < payInput.length;i++) { 
                    if(!payInput[i].get("v.value") && payInput[i].get("v.value") != 0){
                        isValid = false;
                        $A.util.addClass(payInput[i], 'slds-has-error'); 
                    }else {
                        $A.util.removeClass(payInput[i], 'slds-has-error'); 
                    }
                }
                
            }else {
                
                if(!payInput.get("v.value") && payInput.get("v.value") != 0){
                    isValid = false;
                    $A.util.addClass(payInput, 'slds-has-error'); 
                }else {
                    $A.util.removeClass(payInput, 'slds-has-error'); 
                }
                
            }
        }
        
        if(isValid){
            cmp.set("v.visibleError",false);
            var payableLineList = cmp.get("v.payableLineList");
            var isProTaskRelatedProject = false;
            var payable = cmp.get("v.payable");
            var payableAmt = 0.00;
            var totalAmt = 0.00;
            
            if(payable && payable.amount){
                payableAmt = parseFloat(payable.amount);
            }
            
            for(var i = 0;i < payableLineList.length;i++){
                if(payableLineList[i].AcctSeed__Amount__c){
                    totalAmt = totalAmt + (parseFloat(payableLineList[i].AcctSeed__Amount__c));
                }
                if((!payableLineList[i].isProTaskRelatedProject) && ((payableLineList[i].AcctSeed__Project_Task__c || payableLineList[i].projectLookup.length > 0) &&  payableLineList[i].proTaskLookup.length == 0)){
                    isProTaskRelatedProject = true;
                }
            }
            
            //console.log('Payable Amount :',payableAmt);
            //console.log('Sum of Payable Line Amount', totalAmt);

            if(payableLineList.length == 0 || isProTaskRelatedProject){
                var message = '';
                cmp.set("v.successErrorModal",true);
                cmp.set("v.successTitle",'Warning');
                
                if(isProTaskRelatedProject){
                    message = 'Project Task is not related the Project in Payable Line.';
                }else{
                    message = 'Unable to sync payable without payable lines.'; 
                }
                cmp.set("v.successMsg",message);
                cmp.find('successModel').open();
            }else if(totalAmt.toFixed(2) == payableAmt.toFixed(2)){
                helper.payableCreationHelper(cmp, event, helper)
            }else{
                cmp.set("v.visibleError",true);
                cmp.set("v.showErrorMsg","Sum of Payable Line amount should be equal to Payable amount.");
            }
        }
    },
    successClose : function(cmp, event, helper){
        var title = cmp.get("v.successTitle");
        cmp.set("v.successErrorModal",false);
        var payableId = cmp.get("v.payableId"); 
        
        if(title == 'Success'){
            helper.goToSObjPageHelper(cmp,payableId); 
        }    
        helper.getInfoFromBillDotCom(cmp,event);
    },
    goToSObjPage : function(cmp, event, helper){
        var rowId = event.currentTarget.name;
        helper.goToSObjPageHelper(cmp, rowId);
    },
    tableSort : function(cmp, event ,helper) {
        var target = event.currentTarget;
        var name = target.getAttribute("data-name"); 
        helper.tableSortHelper(cmp,name);
    },
   projectLookupSearch : function(cmp, event, helper){
       var index = event.getSource().get("v.selectedIndex");
       
       if(index >= 0){
           var payableLineList = cmp.get("v.payableLineList");
           var payLine = payableLineList[index];
           
           if(payLine.projectLookup && payLine.projectLookup.length == 0){  
               payLine.proTaskLookup = [];
           }
           payableLineList[index] = payLine;
           cmp.set("v.payableLineList",payableLineList);
        }
       const serverSearchAction = cmp.get('c.getLookupRecords');
       event.getSource().search(serverSearchAction);
   },
    projectTaskLookupSearch : function(cmp, event, helper){
        var index = event.getSource().get("v.selectedIndex");
        
        if(index >= 0){
            var payableLineList = cmp.get("v.payableLineList");
            var payLine = payableLineList[index];
            
            if(payLine.projectLookup && payLine.projectLookup.length > 0){  
                payLine.projectTaskCondition = 'AcctSeed__Project__c = \''+payLine.projectLookup[0].Id+'\'';
            }else if(payLine.AcctSeed__Project__c && payLine.AcctSeed__Project__c != null){
                payLine.projectTaskCondition = 'AcctSeed__Project__c = \''+payLine.AcctSeed__Project__c+'\'';
            }
            payableLineList[index] = payLine;
            cmp.set("v.payableLineList",payableLineList);
            //console.log(payLine);
        }
        
        const serverSearchAction = cmp.get('c.getLookupRecords');
        event.getSource().search(serverSearchAction);
    }
})