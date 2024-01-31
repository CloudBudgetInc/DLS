({
	 getArticleRecords : function(component,event,helper) {
        
         var tableColumns = [
             {
                 'label':'Article Number',
                 'name':'ArticleNumber',
                 'type':'url',
                 'sortable':true,
                 'enableCellClickEvt':true,
                 'truncate':{}
             },
             {
                 'label':'Title',
                 'name':'Title',
                 'type':'text',
                 'sortable':true,
                 'truncate':{}
             },
             {
                 'label':'Language',
                'name':'Language',
                'type':'text',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'Category',
                'name':'Category__c',
                'type':'text',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'Sub Category',
                'name':'Sub_Category__c',
                'type':'test',
                'sortable':true,
                'truncate':{}
            }];
        
        //Configuration data for the table to enable actions in the table
        var tableConfig = {
            "massSelect":false,
            "globalAction":[],
            "rowAction":[],
            "rowActionPosition":'right',
            "paginate":true
            
        };   
        component.set("v.articleTableColumns",tableColumns);
        component.set("v.articleTableConfig",tableConfig);
         
        var action = component.get("c.getInitialArticleRecords");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                var result = JSON.parse(response.getReturnValue());
                console.log('result:::',result);
                if(result.length > 0){
                    component.set("v.articleRowList",result);
                    //Initialize the datatable
                    component.find("articletable").initialize({
                        "order":'asc'
                    });
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
})