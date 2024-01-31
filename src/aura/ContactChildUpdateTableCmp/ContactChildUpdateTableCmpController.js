({
    doInit : function(component, event, helper) {
        var obj = component.get("v.selectedRec");
        console.log('record is',obj.id)
        var self = this;
        const server = component.find('server');
        const action = component.get('c.fieldValuesFormation');
        server.callServer(
            action, {recId : obj.id},
            false,
            $A.getCallback(function(response) {
                var result = response;
                console.log('rsult',JSON.stringify(result));
                component.set("v.fieldsList",response);
            }),
            $A.getCallback(function(errors) {
                console.log('error',errors[0].message)
                helper.showToast(cmp, event, helper, 'error','Error Found',errors[0].message,null);
            }),
            false,
            false,
            false
        );
    },
})