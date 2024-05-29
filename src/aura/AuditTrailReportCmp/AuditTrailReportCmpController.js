({
    doInit : function(component, event, helper) {
        component.set("v.spinner", true);
        var filterObj = component.get("v.filterObj");
        filterObj.fromDateVal = null;
        filterObj.toDateVal = null;
        filterObj.selectedConName = [];
        filterObj.selectedUser = [];
        filterObj.selectedProjName = [];
        
        component.set("v.filterObj", filterObj);
        helper.formHeader(component, event, helper);
        helper.applyFilter(component, event, helper);
    },
    applyBtnClick : function(component, event, helper){
        component.set("v.spinner", true);
        helper.applyFilter(component, event, helper);
    },
    tcFieldTypeSelection : function(component, event, helper){
        var tcType = component.get("v.timeCardTypeValue");
                var filterObj = component.get("v.filterObj");


        if(tcType == 'Time Card Day'){
            component.set("v.tcdFields",component.get("v.tcdFieldWithLabels"));
        }
        if(tcType == 'Time Card Line'){
            component.set("v.tcdFields", component.get("v.tclFieldWithLabels"));
        }
        filterObj.toDateVal = '';
        filterObj.fromDateVal = ''

        component.set("v.selectedTCDLField",'');
        component.set("v.tcdHistoryRecs", []);
        component.set("v.filterObj", filterObj);
    },
    contactLookupSearch : function(cmp, event, helper){
        // Get the search server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        cmp.find('insId').search(serverSearchAction);
    },
    userLookupSearch : function(cmp, event, helper){
        // Get the search server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        cmp.find('byUserId').search(serverSearchAction);
    },
    projectLookupSearch : function(cmp, event, helper){
        // Get the search server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        cmp.find('projId').search(serverSearchAction);
    }, 
    exportAuditTrailReportFile : function(component, event, helper){
        helper.getRecsToDownload(component, event, helper);
    }
})