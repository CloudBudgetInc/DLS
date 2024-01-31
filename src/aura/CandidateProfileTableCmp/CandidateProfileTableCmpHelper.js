({
    
    deleteCandidateDetails : function(component,event,helper,deleteRecord,rowIdx) {
        
        var index = component.get("v.index");
        var action = component.get("c.deleteCandidateRecord");
        
        action.setParams({'del':deleteRecord});
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS"){
                component.find('closeDeleteComponent').closeModal();
                component.get("v.dataRows").splice(index,1);
                component.set("v.dataRows",component.get("v.dataRows"));
                console.log(component.get("v.dataRows"));
                component.set("v.showSpinner",false);
                component.find("eventsTable").initialize({'order':[]});
            }
            else if(state === "ERROR"){
                console.log(data.getError());   
            }
        });
        $A.enqueueAction(action);
    },
    
    saveRecord:function(component,event,helper){
        
        var action = component.get("c.saveEditRecord");
        action.setParams({
            "objectName":component.get("v.SobjectName"),
            "recordId":component.get("v.ParentId"),
            "recordType":component.get("v.RecordType")
        });
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS"){
                console.log(data.getReturnValue()); 
                component.set("v.dataRows",data.getReturnValue());
                component.set("v.forceEditCheck",false);
                component.set("v.showSpinner",false);
                component.find('EditRecordComponent').closeModal();
                component.find("eventsTable").initialize({'order':[]});    
            }
            else if(state === "ERROR"){
                console.log(data.getError());  
            }
        });
        $A.enqueueAction(action);
    }
})