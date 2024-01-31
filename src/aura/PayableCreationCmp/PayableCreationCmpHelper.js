({
    getInfoFromBillDotCom : function(cmp,event) {
        var payableRowHeader = [{'label':'Sync Status','name':'isPayableExist'},
                                {'label':'Payable','name':'payableName'},
                                {'label':'Payee Reference','name':'payReference'},
                                {'label':'Vendor','name':'vendorName'},
                                {'label':'AP Active Status','name':'billApActiveStatus'},
                                {'label':'AP Approval Status','name':'billAPApprovalStatus'},
                                {'label':'Date','name':'dateVal'},
                                {'label':'Due Date','name':'dueDateVal'},
                                {'label':'AP GL Posting Date','name':'glPostingDate'}, 
                                {'label':'Accounting Period','name':'accountingPeriod'},
                                {'label':'Total','name':'amount'}];
        var self = this;
        var param = {};
        param.startDate = cmp.get("v.fromDate");
        param.endDate = cmp.get("v.toDate");
        cmp.set("v.showSpinner",true);
        cmp.set("v.payableRowHeader",payableRowHeader);
        
        const server = cmp.find('server');
        const action = cmp.get('c.getPayableInfo');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                var result = response;
                console.log(':::::::result::::',result);
                cmp.set("v.payableList",result.pay);
                cmp.set("v.billPaymentList",result.cashDisbursements);
                
                var filterObj =  cmp.get("v.payableSort");
                filterObj.arrowDirection = 'arrowup';
                filterObj.fieldToSort = 'dateVal';
                filterObj.sortingOrder = 'Desc';
                cmp.set("v.payableSort",filterObj);
                self.tableSortHelper(cmp,'dateVal');
                
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                console.log('Error n comp',errors[0].message);
                cmp.set("v.successErrorModal",true);
                cmp.set("v.successTitle",'Error');
                cmp.set("v.successMsg",errors[0].message);
                cmp.find('successModel').open();
            }),
            false, 
            false,
            false
        );
    },
    showToast : function(cmp,event,message,type,title){
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message : message,
            type : type,
            mode: 'sticky'
        });
        toastEvent.fire();
    },
    payableCreationHelper : function(cmp,event,helper){
        var self = this;
        cmp.set("v.showSpinner",true);
        cmp.find("openLineDetail").close();
        var payLines = [];
        var cashDisbursements = [];
        var payable = cmp.get("v.payable");
        var payRelCashDisburseList = cmp.get("v.payRelCashDisburseList");
        var payableLineList = cmp.get("v.payableLineList");
        
        
        if(payableLineList.length > 0){
            for(var i = 0;i < payableLineList.length;i++){
                if((!payableLineList[i].isPayableLineExist) || (payableLineList[i].isPayableLineExist && payable.Bill_com_AP_Approval_Status__c == 'Waiting For Approval')){
                    if(payableLineList[i].projectLookup && payableLineList[i].projectLookup.length > 0){  
                        payableLineList[i].AcctSeed__Project__c = payableLineList[i].projectLookup[0].Id;
                        payableLineList[i].projectLookup = [];
                    }
                    if(payableLineList[i].proTaskLookup && payableLineList[i].proTaskLookup.length > 0){  
                        payableLineList[i].AcctSeed__Project_Task__c = payableLineList[i].proTaskLookup[0].Id;
                        payableLineList[i].proTaskLookup = [];
                    }
                    payLines.push(payableLineList[i]);
                }
            }
        }
        
        if(payRelCashDisburseList.length > 0){
            for(var i = 0;i < payRelCashDisburseList.length;i++){
                if(!payRelCashDisburseList[i].isCashDisbursementExist){
                    cashDisbursements.push(payRelCashDisburseList[i].cash);
                }
            }
        }
        console.log('payLines::',payLines);
        console.log('payable::',payable);
        console.log('cashDisbursements::',cashDisbursements);
        
        const server = cmp.find('server');
        const action = cmp.get('c.payableCreationRec');
        server.callServer(
            action,
            {
                'payableJSON' : JSON.stringify(payable),
                'payableLineJSON' : JSON.stringify(payLines),
                'cashDisbursementJSON' : JSON.stringify(cashDisbursements)
            },
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.successErrorModal",true);
                cmp.set("v.payableId",response);
                cmp.set("v.successTitle",'Success');
                cmp.set("v.successMsg",'Payable, Payable Lines & Cash Disbursement records are synced successfully.');
                cmp.find('successModel').open();
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                console.log('Error n comp',errors[0].message);
                cmp.set("v.successErrorModal",true);
                cmp.set("v.successTitle",'Error');
                cmp.set("v.successMsg",errors[0].message);
                cmp.find('successModel').open();       
            }),
            false, 
            false,
            false
        );
    },
    tableSortHelper : function(cmp ,name) {
        var filterObj =  cmp.get("v.payableSort");
        var payableList = cmp.get("v.payableList");
        var ascendingRecs = false;
        
        if(filterObj.fieldToSort != name){
            filterObj.arrowDirection = 'arrowdown';
        }
        filterObj.fieldToSort = name;  
        
        var currentDir = filterObj.arrowDirection; 
        
        if (currentDir == 'arrowdown') {
            filterObj.arrowDirection = 'arrowup';
            filterObj.sortingOrder = 'Asc';
            ascendingRecs = true;
        } else {
            filterObj.arrowDirection = 'arrowdown';
            filterObj.sortingOrder = 'Desc';
        }
        
        payableList.sort((a, b) => {
            let fa = a[name],
            fb = b[name];
            
            if (fa === fb) {// equal items sort equally
            return 0;
        }else if (!fa) {// nulls sort after anything else
            return 1;
        }else if (!fb) {
            return -1;
        }else if (ascendingRecs) {// otherwise, if we're ascending, lowest sorts first
            return fa < fb ? -1 : 1;
        }else {// if descending, highest sorts first
            return fa < fb ? 1 : -1;
        }
    });
    
    cmp.set("v.payableSort",filterObj);
    cmp.set("v.payableList",payableList);
},
 goToSObjPageHelper : function(cmp,rowId){
    
    if(rowId){
        window.open('/lightning/r/'+rowId+'/view','_blank');
    }
 },
formatAmntStr : function(cmp, amnt){
		
    const dec = amnt.split('.')[1];
    const len = dec && dec.length > 2 ? dec.length : 2;
    return Number(amnt).toFixed(len);
}
})