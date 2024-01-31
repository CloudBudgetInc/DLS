({
	doinit : function(cmp, event, helper) {
		helper.getListViewValues(cmp,event);
	},
    listOptionChange : function(cmp, event, helper){
        helper.getSobjectRecords(cmp,event);
    }
})