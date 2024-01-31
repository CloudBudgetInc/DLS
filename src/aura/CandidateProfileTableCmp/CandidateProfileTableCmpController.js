({
    tableIntialize : function(component, event, helper) {
        
        console.log(':::***::::child doinit:::');
        //console.log('::::****::::set::::',JSON.stringify(component.get("v.dataRows")));
        
        var taskTableConfig = {
            "massSelect":false,
            "rowAction":[
                {
                    "type":"image",
                    "class":"imgAction2",
                    "id":"edittask",
                    "src":"/resource/1482987504000/Edit_Icon",
                     
                   
                },
                {
                    "type":"image",
                    "class":"imgAction2",
                    "id":"deltask",
                    "src":"/resource/1482987503000/Delete_Icon",
                     
                }],
            
            "paginate":false,
            "searchByColumn":false,
            "searchBox":false,
            "rowActionPosition":'right',
            "sortable":false,
            
        };
        component.set("v.eventTableConfig",taskTableConfig); 
        component.find("eventsTable").initialize({'order':[]});  
    },
    tabActionClicked: function(component, event, helper){
        
        var rowIdx = component.get("v.index")
        var actionId = event.getParam('actionId');  
        var dataRows = component.get("v.dataRows");
        var SobjectName = component.get("v.SobjectName");
        var rowRecord = event.getParam("row");
        
        for(var i = 0;i < component.get("v.dataRows").length;i++) {
            if(dataRows[i].Id === rowRecord.Id) {
                component.set("v.index",i);
            }
        }
        console.log(JSON.stringify((rowRecord)));
        
        if(actionId === 'deltask' ) {
            
            dataRows[component.get("v.index")]['SObjectType'] = SobjectName;
            component.set("v.dataRows",  dataRows);
            component.find('closeDeleteComponent').openModal();
        } else if(actionId === 'edittask') {
            
            component.set("v.recordId",rowRecord.Id); 
            component.set("v.forceEditCheck",true);
            component.find('EditRecordComponent').openModal();      
        }
        
    },
    
    closePromptDelete: function(component, event, helper) {
        component.find('closeDeleteComponent').closeModal();
    },
    
    deleteTask: function(component, event, helper) { 
        var rowIdx = component.get("v.index"); 
        var dataRows = component.get("v.dataRows");
        component.set("v.showSpinner",true);
        helper.deleteCandidateDetails(component,event,helper,dataRows[rowIdx],rowIdx);    
    },
    EditClose: function(component, event, helper) { 
        component.set("v.forceEditCheck",false);
        component.find('EditRecordComponent').closeModal();
    },
    EditSave : function(component, event, helper) {     
        component.set("v.showSpinner",true);
        component.find("editRecord").get("e.recordSave").fire(); 
        helper.saveRecord(component, event, helper);  
    }
})