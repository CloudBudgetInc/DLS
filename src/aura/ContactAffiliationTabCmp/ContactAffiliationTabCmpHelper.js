({
	getInitialTabInformation : function(cmp ,event ,helper) {
        
        var self = this;
        const server = cmp.find('server');
        var action = cmp.get("c.getTabInfo");
        server.callServer(
            action,{
                'recId' : cmp.get("v.recordId"),
                'sObjName'  : cmp.get("v.sObjectName")
            },
            false,
            $A.getCallback(function(response) {
                console.log(response);
                cmp.set("v.tabNames",response.tabNames);
                cmp.set("v.statusPickList",response.defaultStatusPicklist);
                cmp.set("v.contactAffilationList",response.contactAffilationRecs);
                cmp.set("v.contactAffilationJSON",JSON.stringify(response.contactAffilationRecs));
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,helper,errors[0].message,'info_alt','error','pester');
            }),
            false,
            false,
            false
        );
    },
    getContactAffilationInfo : function(cmp ,event ,helper) {

        var self = this;
        const server = cmp.find('server');
        var action = cmp.get("c.getContactAffiliationRecs");
        server.callServer(
            action,{
                'recId' : cmp.get("v.recordId"),
                'sObjName'  : cmp.get("v.sObjectName"),
                'recordTypeName'  : cmp.get("v.recordTypeName"),
            },
            false,
            $A.getCallback(function(response) {
                cmp.set("v.contactAffilationList",response.contactAffilationRecs);
                cmp.set("v.contactAffilationJSON",JSON.stringify(response.contactAffilationRecs));
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,helper,errors[0].message,'info_alt','error','pester');
            }),
            false,
            false,
            false
        );
    },
    showToast: function(cmp, event, helper, message,key,type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            key: key,
            type: type,
            mode: mode
        });
        toastEvent.fire();
    }
})