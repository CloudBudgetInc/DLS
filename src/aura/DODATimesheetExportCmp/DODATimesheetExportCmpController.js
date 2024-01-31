({
    doinit :  function(cmp, event, helper){
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getInitialDate');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('response::::::created:',response);
                var result = response.split('/');
                cmp.set("v.fromDate",result[0]);
                cmp.set("v.toDate",result[1]);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
            }),
            false, 
            false,
            false
        );
    },
	validateInput : function(cmp, event, helper) {
		var frmDt = cmp.get("v.fromDate");
        var toDt = cmp.get("v.toDate");
        
        console.log('::::::frmDt:::',frmDt);
        console.log('::::::toDt:::',toDt);
        
        var isValid = true;
        
        var dt1Cmp = cmp.find("fromdtVal");
        if(!frmDt){            
            $A.util.addClass(dt1Cmp, 'slds-has-error');
            isValid = false;
        }else{
            $A.util.removeClass(dt1Cmp, 'slds-has-error');
        }
        
        var dt2Cmp = cmp.find("todtVal");
        if(!toDt){            
            $A.util.addClass(dt2Cmp, 'slds-has-error');
            isValid = false;
        }else{
            $A.util.removeClass(dt2Cmp, 'slds-has-error');
        }
        
        //var dt1 = frmDt.split('/')[2]+'-'+frmDt.split('/')[0]+'-'+frmDt.split('/')[1];
        //var dt2 = toDt.split('/')[2]+'-'+toDt.split('/')[0]+'-'+toDt.split('/')[1];
        
        if(isValid){
            window.open('/apex/DODATimesheetExportPDF?accountId='+cmp.get("v.recordId")+'&dt1='+frmDt+'&dt2='+toDt);
            $A.get("e.force:closeQuickAction").fire();
        }
	}
})