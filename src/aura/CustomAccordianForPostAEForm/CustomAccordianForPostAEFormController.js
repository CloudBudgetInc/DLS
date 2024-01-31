({
    doInit : function(cmp, event, helper) {
        var headerColumns = [];
        headerColumns = [
            {'Name' : 'Fixed Asset ID', 'fieldSort' : 'assetId', 'width':'width:11%'},
            {'Name' : 'Service Tag', 'fieldSort' : 'serviceTag', 'width':'width:9%'},
            {'Name' : 'Equipment', 'fieldSort' : 'equipName', 'width':'width:11%'},
            {'Name' : 'Fixed Asset', 'fieldSort' : 'fAName', 'width':'width:11%'},
            {'Name' : 'Amount', 'fieldSort' : 'amount', 'width':'width:9%'},
            {'Name' : 'GL Variable 1', 'fieldSort' : 'gLVar1Name', 'width':'width:11%'},
            {'Name' : 'Accounting Period', 'fieldSort' : 'periodName', 'width':'width:9%'},
            {'Name' : 'Credit GL Account', 'fieldSort' : 'creditGLAccName', 'width':'width:11%'},
            {'Name' : 'Debit GL Account', 'fieldSort' : 'debitGLAcctName', 'width':'width:11%'},
            {'Name' : 'Posting Status', 'fieldSort' : 'posted', 'width':'width:7%'}
        ];
      cmp.set("v.headerColumns",headerColumns); 
      helper.tableSortHelper(cmp, 'assetId');
    },
	hideAESection : function(component, event, helper) {
		component.set("v.showAE", false);
	},
    showAESection : function(component, event, helper) {
        component.set("v.showAE", true);
    },
    tableSort : function(cmp ,event, helper) {
        var target = event.currentTarget;
        var name = target.getAttribute("data-name");
        helper.tableSortHelper(cmp, name);
    },
})