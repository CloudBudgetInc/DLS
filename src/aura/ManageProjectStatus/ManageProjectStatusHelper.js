({
    projectRecordUpdate : function(cmp) {
        cmp.set("v.showSpinner",true);
        var params = {};
        var caRecords  = [];
        
        var showInactiveCRRelCAs = cmp.get("v.showInactiveCRRelCAs");
        caRecords = cmp.get("v.caRecords");
        
        for(var i = 0;i < showInactiveCRRelCAs.length;i++){
            caRecords.push(showInactiveCRRelCAs[i]); 
        }
        
        params.proId = cmp.get("v.recordId");
        params.conAssignsJSON = JSON.stringify(caRecords);
        params.dateValue = cmp.get("v.selectedStatus") == 'On Hold' ? cmp.get("v.onHoldDt") : cmp.get("v.cancelledDt");
        params.reason = cmp.get("v.cancellationReason");
        params.status = cmp.get("v.selectedStatus");
        params.sendStudentReminder = cmp.get("v.sendStudentRemainder");
        var self = this;
        
        const server = cmp.find('server');
        const action = cmp.get('c.updateProStatusToOnHold');
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,'Success','Project status updated successfully. Please reload this page to see the changes.','success');
                window.setTimeout(
                    $A.getCallback(function() {
                        $A.get("e.force:closeQuickAction").fire();
                    }),2000);
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false,
            false
        );
    },
    showToast : function(cmp, event, title,message,type) {
        console.log(':::::::message:::',message);
        var mode = 'sticky';
        var duration  = 7000;
        cmp.set("v.type", type);
        cmp.set("v.message", message);
        
        $A.util.toggleClass(cmp.find("toast"),'slds-hide');
        if(type === 'success'){
            var toastTheme = cmp.find("toastTheme");
            $A.util.addClass(toastTheme, 'slds-theme--success');
            window.setTimeout($A.getCallback(function(){
                $A.util.toggleClass(cmp.find("toast"),'slds-hide');
            }),duration);
            
        }else {
            var toastThemeError = cmp.find("toastTheme");
            $A.util.addClass(toastThemeError, 'slds-theme--error');
            if(mode !== 'sticky'){
                window.setTimeout($A.getCallback(function(){
                    $A.util.toggleClass(cmp.find("toast"),'slds-hide');
                }),duration);
            }
        }
    },
    getInctiveCostRateRelatedCAs : function(cmp) {
        cmp.set("v.showSpinner",true);
        var params = {};
        params.proId = cmp.get("v.recordId");
      
        var self = this;
        
        const server = cmp.find('server');
        const action = cmp.get('c.getInactiveLCRRelatedConAssigns');
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                console.log(result);
                cmp.set("v.showInactiveCRRelCAs",result.conAssign);
                cmp.set("v.caRecords",result.endedCAFromOnHoldForInActiveLCR);
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false,
            false
        ); 
    }
})