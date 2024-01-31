({
    getEquipmentHeaderTab : function(component,event,helper) {
        
        var header = [
            {
                'label':'Equipment Name',
                'name':'Equipment__r.Name',
                'type':'reference',  
                'target':'_blank',
                'value':'Equipment__c',
                'width':'160px',
                'sortable':false,
                'truncate' : {
                    "characterLength" :20
                },
            },
            {
                'label':'Date Requested	',
                'name':'Date_Requested__c', 
                'type':'date',
                'format':'MM/DD/YYYY',
                'visible':'true',
                'sortable':false,
            },
            {
                'label':'Date Assigned',
                'name':'Date_Assigned__c',
                'type':'date',
                'format':'MM/DD/YYYY',
                'sortable':false
            },
            {
                'label':'Date Returned',
                'name':'Date_Returned__c',
                'type':'date',
                'format':'MM/DD/YYYY',
                'sortable':false
            },
            {
                'label':'Deposit Amount',
                'name':'Deposit_Amount__c',
                'type':'text',
                'sortable':false
            }    
        ];
        var taskTableConfig = {
            
            "massSelect":false,
            "globalAction":[
                {
                    "label":"Add Equipment Assignment",
                    "type":"button",
                    "class":"slds-button slds-button_brand",
                    "id":"EquipmentBtn",
                    "visible":true
                }
            ],
            "rowAction":[
                {
                    "type":"image",
                    "class":"imgAction2",
                    "id":"fund",
                    "src":"/resource/1482987504000/Detail_Icon",
                },
                {
                    "type":"image",
                    "class":"imgAction2",
                    "id":"equiEditTask",
                    "src":"/resource/1482987504000/Edit_Icon",
                }],
            
            "paginate":false,
            "searchByColumn":false,
            "searchBox":false,
            "rowActionPosition":'right',
            "sortable":false,
            
        };
        component.set("v.eventTableConfig",taskTableConfig); 
        component.set("v.EquipmentDataHeader",header);
        component.set("v.showSpinner",false); 
        component.find("equiTable").initialize({'order':[]});
    },
    saveEquiRecord : function(component,event,helper){
        
        var action = component.get("c.getEABasedonCA");
        action.setParams({
            "conAssignId":component.get("v.conAssignId"),   
        });
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS"){
                var result = data.getReturnValue();
                component.set("v.showSpinner",false);
                component.find("EditEquipmentRecordComponent").closeModal();
                component.set("v.EquipmentDataRows",result); 
                component.set("v.forceEditCheck",false); 
                component.set("v.ViewEditModal",'slds-hide');
                component.set("v.ViewModel",'slds-show');
                component.find("equiTable").initialize({'order':[]});    
            }
            else if(state === "ERROR"){
                console.log(data.getError());  
            }
        });
        $A.enqueueAction(action);
    }
})