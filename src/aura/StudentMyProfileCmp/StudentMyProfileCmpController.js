({
    doInit : function(cmp, event, helper) {
        console.log('Do init');
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            cmp.set("v.displayDevice",'Mobile');
        } else {
            cmp.set("v.displayDevice",'PC');
        }
        helper.getContactRec(cmp, event, helper);
    },
    
    editContactInfo : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        cmp.set('v.viewMode',false);
        window.setTimeout(
            $A.getCallback(function() {
                cmp.set("v.showSpinner",false);
            }), 1000);
    },
    
    cancelEdit : function(cmp, event, helper) {
        var conInputfields = cmp.find("inputFields");
        console.log('Contact Rec:::',JSON.stringify(cmp.get("v.dummyContactRec")));
        cmp.set("v.showSpinner",true);
        cmp.set('v.profileInfo',JSON.parse(JSON.stringify(cmp.get("v.dummyContactRec"))));
        cmp.set('v.viewMode',true);
        window.setTimeout(
            $A.getCallback(function() {
                if(Array.isArray(conInputfields)){
                    for(var i = 0;i < conInputfields.length;i++) {   
                        $A.util.removeClass(conInputfields[i], 'slds-has-error');
                    }
                } 
                cmp.set("v.showSpinner",false);
            }), 1000);
    },
    
    saveContact : function(cmp, event, helper){
        var conInputfields = cmp.find("inputFields");
        var isValidInputs = true;
        
        if(Array.isArray(conInputfields)){
            for(var i = 0;i < conInputfields.length;i++) {   
                if(!conInputfields[i].get("v.value")) {
                    $A.util.addClass(conInputfields[i], 'slds-has-error'); 
                    isValidInputs = false;
                }else {   
                    $A.util.removeClass(conInputfields[i], 'slds-has-error');
                }
            }
        } 
        
        if(isValidInputs) {
            var oldContactRec = cmp.get("v.dummyContactRec");
            var contactRec = cmp.get("v.profileInfo");
            
            
            if(oldContactRec.email != contactRec.email){
                
                cmp.set("v.showUserEmailUpdationModal",true);
                cmp.find("userUpdate").open();
            }else{
                helper.updateContact(cmp, event, helper);
             }
        }
    },
    updateContactAndUser : function(cmp, event, helper){
        helper.updateContact(cmp, event, helper);
        cmp.set("v.showUserEmailUpdationModal",false);
    }
})