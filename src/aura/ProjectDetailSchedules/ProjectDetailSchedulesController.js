({
    doInit : function(component, event, helper) {
        var projectRec = component.get("v.projectRec");
        console.log('Project Rec::::::',projectRec);
        if(projectRec != null){
            /*if(projectRec.status != null && projectRec.status != ''){
                component.set("v.",projectRec.status);  
            }*/
            helper.getSchedules(component, event, helper,projectRec.projectId);
        }
    },
    
    handleStatusChange : function(component, event, helper) {
        var projectRec = component.get("v.projectRec");
        helper.getSchedules(component, event, helper,projectRec.projectId);
    }
    
    
})