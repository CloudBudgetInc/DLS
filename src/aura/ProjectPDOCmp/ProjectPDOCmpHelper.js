({
	getPlannedDaysOffRows : function(component, event, helper) {
		component.set("v.plannedOffRecordType",[]);
        
        var parentId = component.get("v.recordId");
        
        var action = component.get("c.getPlannedDaysOffInfo");
        action.setParams({             
            "projectId":parentId
        });
        action.setCallback(this, function(data) {
            var state=data.getState();
            if(state == "SUCCESS"){
                
                var plannedOff = data.getReturnValue();
                for( var i = 0 ;i < plannedOff.length ;i++){
                    
                    var date = this.dateFormatValue(plannedOff[i].Date__c);
                    if(date != null){
                        plannedOff[i].Date  = date;
                    }
                    
                    if(plannedOff[i].Contact__r && plannedOff[i].RecordType && plannedOff[i].RecordType.DeveloperName == 'Student_Planned_Days_Off'){
                        plannedOff[i].contactName = this.studentNameFormat(plannedOff[i].Contact__r);    
                    }else if(plannedOff[i].Contact__r){
                        plannedOff[i].contactName = plannedOff[i].Contact__r.Name;
                    }
                }
                
                component.set("v.plannedOffRows",plannedOff);  
                if(plannedOff.length > 0){
                    component.find("plannedOffTable").initialize({'order':[]}); 
                }                
            } 
            if(state == "ERROR"){
                component.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  data.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();  
                
            }
        });
        $A.enqueueAction(action);
	},
	dateFormatValue:function(date){
        if(date && date.split('-').length > 2){
        	return (date.split('-')[1]+'/'+date.split('-')[2]+'/'+date.split('-')[0]);
        }
    }, 
    studentNameFormat: function(contact){
        
        if(contact){
            return contact.FirstName+' '+contact.LastName.substring(0,1)+'.';
        }
    }
})