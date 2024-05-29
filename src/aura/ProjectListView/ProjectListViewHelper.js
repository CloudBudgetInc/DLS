({
    getProjects : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var tableColumns = [
            {
                'label':'DLS Class',
                'name':'dlsClass',
                'type':'url',
                'truncate':{},
                'sortable':true,
                'enableCellClickEvt':true
            },
            {
                'label':'Start Date',
                'name':'startDate',
                'type':'String',
                'truncate':{},
                'sortable':true
            },
            {
                'label':'End Date',
                'name':'endDate',
                'type':'string',
                'truncate':{},
                'sortable':true
            }, 
            {
                'label':'Status',
                'name':'status',
                'type':'String',
                'truncate':{},
                'visible':true,
                'sortable':true
            }
            /*{
                'label':'Project Manager',
                'name':'projectManager',
                'type':'String',
                'truncate':{},
                'visible':true,
                'sortable':true
            },
            {
                'label':'Training Location',
                'name':'trainingLocation',
                'type':'String',
                'truncate':{},
                'visible':true,
                'sortable':true
            }*/
            
        ];
        
        //Configuration data for the table to enable actions in the table
        var projectTableConfig = {
            "massSelect":false,
            "globalAction":[],
            "rowAction":[],
            "paginate":true,
            "searchBox" : false
            
        }; 
        var action = component.get("c.getProjectList");
        action.setCallback(this,function(response){
            var state = response.getState();
            //console.log('state:::',state);
            console.log('respoinse',response.getReturnValue());
            if(state == "SUCCESS"){
                let res = response.getReturnValue();
                if(res){
                    let listViewWrapper = JSON.parse(res);
                    //console.log('project List:::',listViewWrapper.projectRecords);
                    setTimeout(function(){ 
                        component.set("v.showSpinner",false);
                    }, 1000); 
                    component.set("v.projectList",listViewWrapper.projectRecords);
                    component.set("v.dummyProjectList",listViewWrapper.projectRecords);
                    component.set("v.statusPicklist",listViewWrapper.statusValues);
                    component.set("v.projectIdWithCAStatus", listViewWrapper.projectIdWithCAStatus);
                    component.set("v.tableColumns",tableColumns);
                    component.set("v.projectTableConfig",projectTableConfig);
                    this.getItemsByStatus(component, event,component.get("v.selectedStatus"));
                    
                    if(listViewWrapper.projectRecords.length > 0){
                        component.find("projectTable").initialize({
                            "order":"asc"
                        });
                    }
                }
            }else if(state == 'ERROR'){
                component.set("v.showSpinner",false);
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
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
    
    getItemsByStatus : function(component, event,filter) {
        var items = component.get("v.dummyProjectList"),
              projectIdWithCAStatus = component.get('v.projectIdWithCAStatus');
        var itemList = [];
        console.log(filter);

        items.forEach(function(item){

            var caStatus = projectIdWithCAStatus[item.projectId];

            filter = filter == 'Order' ? 'Planned' : filter;
            if(caStatus == filter){ //item.status == filter && 
                itemList.push(item);
            }      
        });
        component.set("v.projectList",itemList);
    }
})