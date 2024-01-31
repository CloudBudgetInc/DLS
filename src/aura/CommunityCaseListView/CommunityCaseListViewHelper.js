({
    getCasesRecords : function(component,event,helper) {
        
        var tableColumns = [
            {
                'label':'Case #',
                'name':'CaseNumber',
                'type':'url',
                'sortable':true,
                'enableCellClickEvt':true,
                'truncate':{}
            },
            {
                'label':'Subject',
                'name':'Subject',
                'type':'text',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'Status',
                'name':'Status',
                'type':'text',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'Priority',
                'name':'Priority',
                'type':'text',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'Date/Time Opened',
                'name':'CreatedDate',
                'type':'date',
                'format':'MM/DD/YYYY  HH:mm A',     
                'sortable':true,
                'truncate':{}
            }
        ];
        
        //Configuration data for the table to enable actions in the table
        var caseTableConfig = {
            "massSelect":false,
            "globalAction":[],
            "rowAction":[],
            "rowActionPosition":'right',
            "paginate":true,
            "searchBox" : false
            
        };   
        component.set("v.caseTableColumns",tableColumns);
        component.set("v.caseTableConfig",caseTableConfig);
        var action = component.get("c.getInitialCaseRecords");
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state:::',state);
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                console.log('::'+JSON.stringify(result));
                if(result){
                    component.set("v.filterCasePicklist",result.filterPickList);
                    //component.set("v.caseRowList",result.caseListRecords);
                    component.set("v.dummyCaseList",result.caseListRecords);
                    component.set("v.communityName",result.communityName);
                    helper.filterCaseRecords(component, event);
                }
                component.set("v.showSpinner",false); 
            }else if(state == 'ERROR'){
                var errors = response.getError();
                var message;
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                component.set("v.showSpinner",false); 
                // Display the message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },		
    filterCaseRecords : function(cmp, event){
        
        var  selectedCase = cmp.get("v.selectedCaseFilter");
        var dummyCaseList = cmp.get("v.dummyCaseList");
        var caseArray = [];
        
        if(selectedCase == 'All Cases'){
            cmp.set("v.caseRowList",cmp.get("v.dummyCaseList"));
        }else if(selectedCase == 'Open Cases'){
            for(var i = 0;i < dummyCaseList.length;i++){
                if(dummyCaseList[i].IsClosedOnCreate == false){
                    caseArray.push(dummyCaseList[i]);
                }
            }
            cmp.set("v.caseRowList",caseArray);
        }else if(selectedCase == 'Closed Cases'){
            for(var i = 0;i < dummyCaseList.length;i++){
                if(dummyCaseList[i].IsClosedOnCreate == true){
                    caseArray.push(dummyCaseList[i]);
                } 
            }
            cmp.set("v.caseRowList",caseArray);
        }
        //ReInitialize the datatable
        cmp.find("caseTable").initialize({
            "order":[0,'desc']
        });
        cmp.set("v.showSpinner",false); 
    }
    
})