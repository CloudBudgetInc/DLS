({
	scriptsLoaded : function(cmp, event, helper){
        helper.fetchTimeData(cmp, event, helper);
    },
    filterTableToday : function(cmp, event, helper) {
		helper.filterTableToday(cmp, event);
	},
    filterTableYesterday : function(cmp, event, helper) {
		helper.filterTableYesterday(cmp, event);
	},
    filterTableThisWeek : function(cmp, event, helper) {
		helper.filterTableThisWeek(cmp, event);
	},
    filterTableLastWeek : function(cmp, event, helper) {
		helper.filterTableLastWeek(cmp, event);
	},
    filterTableThisMonth : function(cmp, event, helper) {
		helper.filterTableThisMonth(cmp, event);
	},
    filterTableLastMonth : function(cmp, event, helper) {
		helper.filterTableLastMonth(cmp, event);
	},
    handleUpdateChart : function(cmp, event, helper){
        console.log('Handle Chart update');
        var a = cmp.get('c.scriptsLoaded');
        $A.enqueueAction(a);
    }
})