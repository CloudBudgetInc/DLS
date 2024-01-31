({
    toggleModal : function(cmp, event, helper) {
        console.log('open');
        $A.util.toggleClass(cmp.find("modal"),'slds-fade-in-open');
        $A.util.toggleClass(cmp.find("modal-backdrop"),'slds-backdrop--open');
    }
})