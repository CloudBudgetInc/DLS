({
    doinit : function(cmp, event, helper) {
        var recId = cmp.get("v.recordId");
        window.open('/apex/FundingReceiptPDF?recordId='+recId);
        $A.get("e.force:closeQuickAction").fire(); 
    }
})