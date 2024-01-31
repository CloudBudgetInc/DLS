({
	doInit : function(cmp, event, helper) {
        let record = cmp.get('v.simpleRecord');
        console.log('simpleRecord::>'+record);
		cmp.set("v.showSpinner",true);
        const server = cmp.find('server');
        var action = cmp.get("c.validateAndInitiateBoxFolderCreation");
        server.callServer(
            action, {recordId: record.Id,folderName : record.Cost_Rate_Name__c+'-' + record.Name, boxParentFolderName: 'Labor Cost Rates', sObjectApiName: 'AcctSeed__Cost_Rates__c'},
            false,
            $A.getCallback(function(response) {  
                if(response == 'No Box Record'){                                       
                    helper.subscribePlatformEvent(cmp, event, helper, record.Id);
                }else{
                    cmp.set("v.showSpinner",false);
                    cmp.set('v.isBoxFolderAvailable', true);                                      
                }
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                console.log(errors[0].message);
                helper.showToast(cmp, event,errors[0].message, "error", "Error");
            }),
            false,
            false,
            false
        );
	}
})