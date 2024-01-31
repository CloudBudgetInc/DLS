({
	doinit : function(cmp, event, helper) {
		helper.getSummaryValues(cmp, event);
        helper.orderTableHeaderFormation(cmp);
        helper.loanTableHeaderFormation(cmp);
        var taskTableConfig = {
            "massSelect":false,
            "rowAction":[],
            "paginate":true,
            "searchByColumn":false,
            "searchBox":false,
            "sortable":false,
        };
        cmp.set("v.tableConfig",taskTableConfig);
	},
    redirectToMaterialDetail : function(cmp, event , helper){
        console.log(':::::::material::Id::',event.currentTarget.getAttribute("data-value"));
        var recordId = event.currentTarget.getAttribute("data-value")
        
        var compEvent = cmp.getEvent("childClickEvent");
        compEvent.setParams({"typeOfAction" : 'HardCopy',
                             "recordId" : recordId});  
        compEvent.fire();
    },
    showFavoriteDetail : function(cmp, event, helper){
        var compEvent = cmp.getEvent("childClickEvent");
        compEvent.setParams({"typeOfAction" : 'Favorite'});  
        compEvent.fire();
    },
    showTopRatedDetail : function(cmp, event, helper){
        var compEvent = cmp.getEvent("childClickEvent");
        compEvent.setParams({"typeOfAction" : 'Top Rated'});  
        compEvent.fire();
    },
    tabClick : function(cmp, event, helper){
        var tabName = event.currentTarget.name;
        cmp.set("v.tabName",tabName);
        if(tabName == 'Order'){
            cmp.find("orderTable").initialize({
                "itemMenu":[3,6,10,20,30],
                "itemsPerPage" : 3
            });
        }else {
            helper.filterRequestRecords(cmp);
        }
    },
    statusChanged : function(cmp, event, helper){
        helper.filterRequestRecords(cmp);
    }
})