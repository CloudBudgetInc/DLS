({
    doInit : function(cmp, event, helper) {
        console.log('do intit in scheduler  '+(window.location.href));
        
        var device = $A.get("$Browser.formFactor");        
        cmp.set("v.displayDevice", device == 'PHONE' ? 'Mobile' : 'Pc');
       
        var url = window.location.href;
        if(url.includes('viewType')){
            cmp.set("v.selectedView",'Schedules');
        }
        
        var selectedView = cmp.get("v.selectedView");
        if(selectedView == 'Schedules') {
            
            
            helper.getCurrentCommunityName(cmp,event,helper);
            console.log('community name is',cmp.get("v.community"));
            
            cmp.set("v.filterObj.training",true);
            cmp.set("v.filterObj.selectedProject",'All');
            cmp.set("v.filterObj.preparation",true);
        }
    },
    
    tabActionClicked: function(component, event, helper) {
        var actionId = event.getParam('actionId');
        var row = event.getParam('row');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/scheduledetailview?recordId="+row.scheduleId
        });
        urlEvent.fire();
        
        console.log('After navigation');
    },
    
    handleFilterChange : function(component, event, helper) {
       
        var statusValues = component.get("v.selectedStatus");
        var selectedProject = component.get("v.selectedProject");
        var filterObj = component.get("v.filterObj");
        
        if(statusValues != null){
            filterObj['statusValues'] = statusValues;
        }
        
        if(selectedProject != null){
            filterObj['selectedProject'] = selectedProject;
        }
        console.log('filter',filterObj);
        component.set("v.filterObj",filterObj);
        if(component.get("v.selectedView") == 'Schedules'){
            component.set("v.showSpinner",true);
            helper.getItemsByFilters(component ,event,helper);
            component.find("scheduleTable").initialize({
                "order":'asc'
            });
            window.setTimeout(function(){
                component.set("v.showSpinner",false);
            },1000);
        } 
    },
    
    
    filterEvents : function(cmp, event, helper){    
        console.log('filteringgg...')
        helper.getItemsByFilters(cmp,event,helper);
        var currentType = event.getSource().get("v.label");
                console.log('filteringgg...')

        var type = cmp.get("v.filterObj");
                console.log('filteringgg...')

        if(currentType == 'Language Training') {
            var trainingCmp = cmp.find("training");
            if(Array.isArray(trainingCmp)){
                trainingCmp = trainingCmp[0];
            }
            if(!type.training){
                $A.util.removeClass(trainingCmp,'training');
                console.log('removing styles');
            }else {
                $A.util.addClass(trainingCmp,'training');
            }
            
        }else if(currentType == 'Preparation Time') {
            var trainingCmp = cmp.find("preparation");
            if(Array.isArray(trainingCmp)){
                trainingCmp = trainingCmp[0];
            }
            if(!type.preparation){
                $A.util.removeClass(trainingCmp,'preparation');
            }else {
                $A.util.addClass(trainingCmp,'preparation');
            }
        }
        
    },
    
    eventStatusChange : function(cmp, event, helper){
        /*console.log('event status change');
                console.log('fire event value start',cmp.get("v.fireEventChange"));*/
        cmp.set("v.showSpinner",true);
        var oldStatus = cmp.get("v.oldStatusValues");
        var newStatus = cmp.get("v.selectedStatus");
        
        console.log('::::::oldStatus:::',oldStatus);
        console.log('::::::newStatus:::',newStatus);
        console.log('type ::::::newStatus:::',typeof newStatus);
        
        var statusChanged = false;
        
        if(oldStatus.length != newStatus.length) {
            console.log('length varies');
            statusChanged = true;
        }else {
            for(var i = 0;i < newStatus.length;i++){
                
                if(!(oldStatus.indexOf(newStatus[i]) != -1)){
                    console.log('enter if',newStatus[i]);
                    statusChanged = true;
                    break;
                }
            }
        }
        
        //if(statusChanged) {
            console.log('status changed')
            cmp.set("v.oldStatusValues",JSON.parse(JSON.stringify(newStatus)));
            cmp.set("v.initialLoad",false);
            helper.getItemsByFilters(cmp,event,helper);
            console.log('items ')
       /* }else {
            cmp.set("v.fireEventChange",false);
        }
        window.setTimeout(function(){
            cmp.set("v.showSpinner",false);
        },1000)
        console.log('fire event value final',cmp.get("v.fireEventChange"));*/
        
    },
    handleRequestEvent: function(component, event, helper){
        component.find('eventCalendarCmp').requestEventBtnClicked();
    }
})