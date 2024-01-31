({
    getSchedulers : function(component, event, helper) {
        console.log('do intit scheduler');
        component.set("v.showSpinner",true);
        var action = component.get("c.getScheduleList");
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state:::',state);
            if(state == "SUCCESS"){
                let res = response.getReturnValue();
                if(res){
                    let listViewWrapper = JSON.parse(res);
                    console.log('listViewWrapper',listViewWrapper)
                    component.set("v.showSpinner",false);
                    component.set("v.projectValues",listViewWrapper.projectValues);
                    this.getSchedulesColumnInfo(component);
                    helper.getItemsByFilters(component,event,helper);
                    component.set("v.showCalendar",true);
                }
            }else if(state == 'ERROR'){
                component.set("v.showSpinner",false);
                
                let errors = response.getError();
                console.log('error',errors[0].message)
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
    
    getItemsByStatus : function(component, event, helper, filter){
        /*   var items = component.get("v.dummyScheduleList");
        console.log('items',items)
        var itemList = [];
        items.forEach(function(item){
            if(item.status == filter){
                itemList.push(item);
            }                                   
        });
        
        console.log('item list::::',itemList);
        component.set("v.scheduleList",itemList); */
    },
    
    getSchedules : function (component ,event ,helper){
        
        var filterObj = component.get("v.filterObj");
        var statusValues = component.get("v.selectedStatus");
        console.log();
        param.statusValues = [];
        if(statusValues != null){
            param.statusValues.push(statusValues);
        }
        param.taskType = [];
        if(filterObj.training){
            param.taskType.push('Language Training');
        }
        
        if(filterObj.testing){
            param.taskType.push('Language Testing');
        }
        
        if(filterObj.preparation && component.get("v.community") != 'student'){
            param.taskType.push('Preparation time');
        }
        
    },
    getItemsByFilters : function(component ,event,helper){
        var self = this;
        var filterobject = component.get("v.filterObj");
        var StatusFilter =  component.get("v.selectedStatus");
        var projectId =  component.get("v.filterObj.selectedProject");
        var projectTask = [];
        
        component.set("v.showSpinner",true);
        if(filterobject.training){
            projectTask.push('Language Training');
        }
        if(filterobject.preparation && component.get("v.community") != 'student'){
            projectTask.push('Preparation Time');
        }
        console.log('StatusFilter',StatusFilter)
        console.log('projectId',projectId)
        console.log('filterobject',filterobject)
        
        component.set("v.scheduleList",[]);
        const server = component.find('server');
        const action = component.get('c.getScheduleByFilter');
        server.callServer(
            action,
            {projectId : projectId,statusList : StatusFilter,projectTask :projectTask},
            false,
            $A.getCallback(function(response) {
                var listWrapper = JSON.parse(response);
                console.log('schedule List Result Response',listWrapper);
                component.set("v.showSpinner",false);
                component.set("v.dummyScheduleList",listWrapper.scheduleRecords);
                component.find("scheduleTable").initialize({
                    "order":[2,'asc']
                });
                component.set("v.fireEventChange",false); 
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors[0].message);
                component.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
    recordTypeChanges : function(component ,event,helper){
        var filterObj = component.get("v.filterObj");
        console.log('updated events are ');
        var filteredEvents = [];
        var wholeEvents = component.get("v.dummyScheduleList");
        for(var i = 0;i < wholeEvents.length;i++){
            if(filterObj.training && wholeEvents[i].projectTaskType == 'Language Training'){
                filteredEvents.push(wholeEvents[i]);
            }
            if(filterObj.preparation && wholeEvents[i].projectTaskType == 'Preparation time'){
                filteredEvents.push(wholeEvents[i]);
            }
        }
        console.log('updated events are ',filteredEvents);
        component.set("v.dummyScheduleList",filteredEvents);
        component.find("scheduleTable").rerenderRows();
    },
    
    showToast :  function(cmp,event,message,type,title){
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message : message,
            type : type,
            mode: 'sticky'
        });
        toastEvent.fire();
    },
    
    getCurrentCommunityName : function(cmp,event,helper){
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getCommunityName');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('response:::',response);
                cmp.set("v.community",response);
                helper.getSchedulers(cmp, event, helper);
                self.getEventRecords(cmp,event);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
    getSchedulesColumnInfo : function(component) {
        var tableColumns = [
            
            {
                'label':'Name',
                'name':'name',
                'type':'url',
                'sortable':true,
                'enableCellClickEvt':true,
                'truncate':{}
            },
            {
                'label':'Days',
                'name':'days',
                'type':'String',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'Start Date',
                'name':'startDate',
                'type':'String',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'End Date',
                'name':'endDate',
                'type':'String',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'Start Time',
                'name':'startTime',
                'type':'String',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'End Time',
                'name':'endTime',
                'type':'String',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'Project Task',
                'name':'projectTask',
                'type':'String',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'Instructor',
                'name':'instructor',
                'type':'String',
                'sortable':true,
                'truncate':{}
            },
            /*  {
                'label':'Room',
                'name':'room',
                'type':'String',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'Qty Per Session',
                'name':'totalHoursPerSession',
                'type':'String',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'Total Scheduled Qty',
                'name':'totalHours',
                'type':'String',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'Unit',
                'name':'unit',
                'type':'String',
                'sortable':true,
                'truncate':{}
            },
            {
                'label':'TimeZone',
                'name':'timezone',
                'type':'String',
                'sortable':true,
                'truncate':{}
            },*/
            {
                'label':'Status',
                'name':'status',
                'type':'String',
                'sortable':true,
                'truncate':{}
            }
            
        ];
        
        //Configuration data for the table to enable actions in the table
        var scheduleTableConfig = {
            "massSelect":false,
            "globalAction":[],
            "rowAction":[],
            "rowActionPosition":'right',
            "paginate":true
            
        }; 
        component.set("v.tableColumns",tableColumns);
        component.set("v.scheduleTableConfig",scheduleTableConfig);
    }
})