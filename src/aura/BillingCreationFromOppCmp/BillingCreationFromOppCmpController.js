({
	doInit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        helper.getBillingTableInformation(cmp, event, helper);
    },
    createBillings : function(cmp, event, helper) {
        let showStudentSelection = cmp.get('v.showStudentSelection');
        
        if(!showStudentSelection){
            helper.createBillingRec(cmp, event, helper);
        }else{
            if(cmp.find('studentCA').checkValidity()){
                helper.createBillingRec(cmp, event, helper);
            }else{
                cmp.find('studentCA').checkValidity();
                cmp.find('studentCA').showHelpMessageIfInvalid();
            }
        }
    },
    calculateTotal : function(cmp, event, helper) {
        var index = parseInt(event.getSource().get("v.name"));
        var billingRowInfo = cmp.get("v.billingRowInfo");
        var overallTotal = 0;
        if(billingRowInfo.opliItemsList && billingRowInfo.opliItemsList.length > 0){
            var opli = billingRowInfo.opliItemsList;
            for(var i = 0; i < opli.length; i++){
                
                if(index == i && opli[i].unitPrice && opli[i].quantity){
                    opli[i].total = (parseFloat(opli[i].unitPrice) * parseFloat(opli[i].quantity));
                }else if(!(opli[i].unitPrice && opli[i].quantity)){
                    opli[i].total = 0;
                }
                overallTotal +=  opli[i].total; 
            }
            billingRowInfo.opliItemsLists = opli;
            billingRowInfo.billingColumnTotal = overallTotal;
            cmp.set("v.billingRowInfo", billingRowInfo);
        }   
    }
})