({
    doInit : function(component, event, helper) {
        
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            component.set("v.displayDevice",'Mobile');
        } else {
            component.set("v.displayDevice",'PC');
        }
        helper.getProjects(component, event, helper);
    },
    
    tabActionClicked: function(component, event, helper) {
        //console.log('In tab action event:::::');
        var actionId = event.getParam('actionId');
        var row = event.getParam('row');
        //console.log('row Id::'+row);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/projectdetailview?recordId="+row.projectId
        });
        urlEvent.fire();
        
        console.log('After navigation');
    },
    
    handleFilterChange : function(component, event, helper) {
        component.set("v.showSpinner",true);
        let filter = component.get("v.selectedStatus");
        //console.log('filter::::',filter);
        if(filter === ''){
            component.set("v.projectList",component.get("v.dummyProjectList"));
        }else{
            helper.getItemsByStatus(component, event,filter);
        }
        component.find("projectTable").initialize({
            "order":"asc"
        });
        window.setTimeout(function(){
            component.set("v.showSpinner",false);
        },1000);
    }
})