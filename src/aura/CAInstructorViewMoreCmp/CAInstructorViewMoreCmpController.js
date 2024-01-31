({
    
    doInit : function(component, event, helper) {
        
        var action = component.get("c.contactAssignmentView");
        component.set("v.showSpinner",true);
        var sObjectName = component.get("v.sObjectName")
        action.setParams({'conAssignId' : component.get("v.conAssignId"),
                          'parentRecordType': component.get("v.sObjectName")});
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS") {
                var result = data.getReturnValue();
                console.log(result);
                component.set("v.caDetail",result);
                component.set("v.CAViewMoreInstructor",result.lstConAssignment); 
                component.set("v.CAViewMoreInstructCitizen",result.lstConAssignContactCitizen);
                component.set("v.EquipmentDataRows",result.lstEquiAssignment); 
                component.find("EditRecordComponent").openModal();
                component.set("v.showSpinner",false);
            } else if(state === "ERROR"){
                console.log(data.getError());  
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
     getCARelatedEquipmentInfo : function(component, event, helper) {
         
        var selectedTab = component.get("v.selectTabName");
        if(selectedTab === 'EQUIPMENTS'){
            component.set("v.showSpinner",true);
            helper.getEquipmentHeaderTab(component, event, helper);
        }
    },
    navigateToRecord:function(component, event, helper) {
        
        var recordId = event.target.getAttribute('name');
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent .setParams({
            "recordId": window.open('/'+recordId) , 
            "slideDevName": "detail"
        });
        sObectEvent.fire(); 
    },
    tabActionClicked : function(component, event, helper){
        
        var actionId = event.getParam('actionId');   
        var rowRecord = event.getParam("row");
        if(actionId === 'fund' ) {
            var EquipmentViewEvent = $A.get("e.force:navigateToSObject");
            EquipmentViewEvent .setParams({
                "recordId": window.open('/'+rowRecord.Id) , 
                "slideDevName": "detail"             
            });
            EquipmentViewEvent.fire(); 
        } else if(actionId === 'equiEditTask') {
            component.set("v.forceEditCheck",true);
            component.set("v.ViewEditModal",'slds-show');
            component.set("v.ViewModel",'slds-hide');
            component.find("EditEquipmentRecordComponent").openModal();    
            component.set("v.equipmentId",rowRecord.Id); 
        }else{
            var createEquipmentRecordEvent = $A.get("e.force:createRecord");
            createEquipmentRecordEvent.setParams({
                "entityApiName": "Equipment_Assignment__c",
                "defaultFieldValues": {             
                    'Contact_Assignment__c' :component.get("v.conAssignId"),
                    'Contact__c':component.get("v.contactId")
                }
            });
            createEquipmentRecordEvent.fire();     
        }
        event.stopPropagation();
    } ,
    EditEquiClose : function(component, event, helper){
        
        component.set("v.forceEditCheck",false);
        component.find("EditEquipmentRecordComponent").closeModal(); 
        component.set("v.ViewModel",'slds-show');
        component.set("v.ViewEditModal",'slds-hide');
    },
    EditEquiSave : function(component, event, helper){
        
        component.set("v.showSpinner",true);
        component.find("editRecord").get("e.recordSave").fire(); 
        helper.saveEquiRecord(component, event, helper);  
    },
    instructorClose : function(component, event, helper){
        
        component.find("EditRecordComponent").closeModal(); 
    }
})