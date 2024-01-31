({
    doInit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        
        var device = $A.get("$Browser.formFactor");
        if (device == 'PHONE') {
            cmp.set("v.displayDevice",'Mobile');
        }else {
            cmp.set("v.displayDevice",'Pc');
        }
        console.log('In Upcoming Planned days off');
        helper.getPDORecords(cmp, event);
    },
    

    cancelBtnClick : function(cmp, event, helper){
        cmp.find("newOffModel").close();
        cmp.set("v.showAddEditModel",false);
        cmp.set("v.plannedOffdayRecord",{});
    },
    deleteNoClick : function(cmp,event,helper){
        cmp.set("v.showDeleteModel",false);  
    },
    cancelEditClick : function(cmp, event, helper) {
        cmp.find("editOffModel").close();
        cmp.set("v.showAddEditModel",false);
    },
    
    saveEditBtnClick : function(cmp, event, helper) {
        helper.updateEditRecords(cmp, event);
    },
    
    deleteYesClick : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        helper.updatePDOStatusAsDeleteHelper(cmp);
    },
    
    onEditClick : function(cmp, event, helper) {
        var plannedOffRows = cmp.get("v.plannedOffRows");
        var rowRecord = plannedOffRows[event.currentTarget.getAttribute("data-name")];
        var plannedOffDays = [];
        var plannedDaysMap = cmp.get("v.plannedDaysMap");
        var plannedDays = plannedDaysMap[rowRecord.id];
        cmp.set("v.multiDaysOff",true);
        cmp.set("v.allowParentPlanToUpdate",false);
        
        cmp.set("v.plannedOffdayRecord",{});
        
        if(plannedDays && plannedDays.length > 0) {
            for(var i = 0; i < plannedDays.length ; i++) {
                var pdoRec = {};
                pdoRec.Id = plannedDays[i].id;
                //console.log('Date value::::',plannedDays[i].dateValue);
                if(plannedDays[i].dateValue){
                    pdoRec.Date__c = plannedDays[i].dateValue;  
                }else {
                    pdoRec.Date__c = rowRecord.fromDate; 
                }
                
                pdoRec.Project__c = (plannedDays[i].projectId ? plannedDays[i].projectId : 'All');
                pdoRec.Project__c = (pdoRec.Project__c == 'All' ? null : pdoRec.Project__c);
                pdoRec['All_Projects__c'] = (pdoRec.Project__c == 'All' ? true : false);
                pdoRec.Type__c = plannedDays[i].type;
                pdoRec.Description__c = plannedDays[i].description;
                
                plannedOffDays.push(pdoRec);
            }
            cmp.set("v.allowParentPlanToUpdate",true);
        }else {
            var pdoRec = {};
            pdoRec.Id = rowRecord.id;
            if(rowRecord.dateValue){
                pdoRec.Date__c = rowRecord.dateValue;  
            }else{
                pdoRec.Date__c = rowRecord.fromDate; 
            }
            
            if(rowRecord.fromDate != rowRecord.toDate){
                pdoRec.From_Date__c = rowRecord.fromDate;
                pdoRec.To_Date__c = rowRecord.toDate;
                cmp.set("v.multiDaysOff",false);
            }
            
            pdoRec.Project__c = (rowRecord.projectId ? rowRecord.projectId : 'All');
            pdoRec.Project__c = (pdoRec.Project__c == 'All' ? null : pdoRec.Project__c);
            pdoRec['All_Projects__c'] = (pdoRec.Project__c == 'All' ? true : false);
            pdoRec.Type__c = rowRecord.type;
            pdoRec.Description__c = rowRecord.description;
            
            plannedOffDays.push(pdoRec);
        }
        
        //console.log('Planned days off records::',plannedOffDays);
        // cmp.set("v.plannedOffdayRecord",pdoRec);
        cmp.set("v.plannedOffDays",plannedOffDays);
        cmp.set("v.modalHeaderName",rowRecord.name);
        cmp.set("v.showAddEditModel",true);
        cmp.find("editOffModel").open();
    },
    
    onDeleteClick : function(cmp, event, helper) {
        var plannedOffRows = cmp.get("v.plannedOffRows");
        var rowRecord = plannedOffRows[event.currentTarget.getAttribute("data-name")];
        cmp.set("v.plannedOffdayRecord",rowRecord);
        cmp.set("v.showDeleteModel",true);
        cmp.find("deletePDO").open();
        
    },
    
    closeClickOnSuccess : function(cmp, event, helper) {
        cmp.find("successModel").close();
        cmp.set("v.showSuccessModel",false);
        helper.getPDORecords(cmp, event);
    }
})