({
    approveEventWithConflictCheck : function(cmp, event, helper){
        var p = cmp.get("v.parent");
        p.approveConflictModal();
    },
    cancelConflictClk : function(cmp, event, helper){
        var p = cmp.get("v.parent");
        p.cancelConflictModal();
    },
    doInit : function(cmp, event, helper){
        var showConflict = cmp.get("v.showConflict");
        
        if(showConflict){
            cmp.find("showConflictModal").open();
        }
    }

})