({
	showToast : function(cmp, event, title,message,type) {
        console.log(':::::::message:::',message);
        var mode = 'sticky';
        var duration  = 5000;
        cmp.set("v.type", type);
        cmp.set("v.message", message);
        
        $A.util.toggleClass(cmp.find("toast"),'slds-hide');
        if(type === 'success'){
            var toastTheme = cmp.find("toastTheme");
            $A.util.addClass(toastTheme, 'slds-theme--success');
            window.setTimeout($A.getCallback(function(){
                //helper.destroyComponent(cmp);
                $A.util.toggleClass(cmp.find("toast"),'slds-hide');
            }),duration);
            
        }else {
            var toastThemeError = cmp.find("toastTheme");
            $A.util.addClass(toastThemeError, 'slds-theme--error');
            if(mode !== 'sticky'){
                window.setTimeout($A.getCallback(function(){
                    //helper.destroyComponent(cmp);
                    $A.util.toggleClass(cmp.find("toast"),'slds-hide');
                }),duration);
            }
        }
    },
    destroyComponent : function(component) {
        $A.util.toggleClass(component.find("toast"),'slds-hide');
        //component.destroy();
    }
})