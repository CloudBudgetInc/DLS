({
    goToLightningPage : function(component, event, helper) {
        var recordId = component.get("v.recordId"); 
      /*  console.log(':::::::recordId:::',recordId);
        var pageReference = {
            "type": "standard__navItemPage",
            attributes: {
                "apiName": "Update_Community_Profile" ,
            },
            state: {
                "recordId" : recordId
            }
        };
        var navService = component.find("navService");
       // event.preventDefault();
       console.log('page reference',pageReference);
        navService.navigate(pageReference); */
        var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
        componentDef : "c:ContactChildUpdateCmp",
        componentAttributes: {
            recordId : recordId
        }
    });
    evt.fire();
    }
})