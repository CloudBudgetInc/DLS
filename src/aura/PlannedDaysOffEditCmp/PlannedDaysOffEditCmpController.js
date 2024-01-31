({
    doInit : function(cmp, event, helper) {
        cmp.set("v.dummyPlannedDayRecord",JSON.parse(JSON.stringify(cmp.get("v.plannedOffdayRecord"))));
    },
    
    onEditClick : function(cmp, event, helper) {
        cmp.set("v.viewMode",false);
        
        helper.fireEditEvent(cmp, true);       
    },
    
    onCancelClick : function(cmp, event, helper) {
        cmp.set("v.plannedOffdayRecord",cmp.get("v.dummyPlannedDayRecord"));
        cmp.set("v.viewMode",true);
        
		helper.fireEditEvent(cmp, false);        
    },
    
    onDeleteClick : function(cmp, event, helper) {
        
        var recordTobeDeleted = cmp.get("v.plannedOffdayRecord");        
        recordTobeDeleted.Status__c = 'Delete';
        cmp.set("v.plannedOffdayRecord",recordTobeDeleted);
        console.log("recordTobeDeleted::::",JSON.stringify(recordTobeDeleted));
        cmp.set("v.deleteMode",false);
        cmp.set("v.viewMode",false);
        helper.fireEditEvent(cmp, true);
    },
    
    onDeleteRemove : function(cmp, event, helper) {
        var recordTobeRestored = cmp.get("v.plannedOffdayRecord");
        delete recordTobeRestored['Status__c'];
        cmp.set("v.plannedOffdayRecord",recordTobeRestored);
        //console.log("recordTobeRestored::::",JSON.stringify(recordTobeRestored));
        cmp.set("v.deleteMode",true);
        cmp.set("v.viewMode",true);
        helper.fireEditEvent(cmp, false);
    }
})