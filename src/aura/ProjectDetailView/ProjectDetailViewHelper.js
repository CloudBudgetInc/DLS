({
	getPolicies : function(component, event, helper) {
        component.set("v.showSpinner",true);        
        var urlString = window.location.href;
		var action = component.get("c.getPolicyAndCertificateDetails");        
        action.setParams({'projectId' : urlString.split("=")[1]});
        action.setCallback(this,function(response){
            var state = response.getState(); 
            if(state == "SUCCESS"){
                let res = response.getReturnValue();
                console.log('CA res::>',res);
                let communityName = component.get('v.communityName');
                component.set("v.showSpinner",false);
                if(res.length > 0){
                    if(communityName == 'client'){                        
                        component.set("v.studentCAs",res);
                        var tableConfig = {
                            searchBox: false,
                            searchByColumn: false,
                            paginate: false,
                            sortable: true
                        };
                        let header = [{
                            'label':'Contact',
                            'name':'Candidate_Name__r.Name',
                            'type':'string',
                             'sortable':true 
                        }];
                        let policyAndProcedureHeader = [...header];
                        let certificateHeader = [...header];
                        policyAndProcedureHeader.push({
                            'label':'DLS Policies and Procedures Date Signed',
                            'name':'DLS_Policies_and_Procedures_Agreed_Date__c',
                            'type':'date',
                            'format':'MM/DD/YYYY',
                            'sortable':true                
                        });
                        certificateHeader.push({
                            'label':'Certificate Received Date',
                            'name':'Certificate_Generated_Date__c',
                            'type':'date',
                            'format':'MM/DD/YYYY',
                            'sortable':true                
                        });
                        
                        component.set('v.policyAndProcedureHeader', policyAndProcedureHeader);
                        component.set('v.certificateHeader', certificateHeader);
                        component.set('v.config', tableConfig);
                        
                        component.find("contactAssignTable").initialize({"order":[]});   
                        component.find("certificateCATable").initialize({"order":[]});
                    }else{
                    	component.set("v.ca",res[0]);     
                    }
                }
            }else if(state == 'ERROR'){
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                component.set("v.showSpinner",false);
                console.log('error::>',message);
            }
        });
        $A.enqueueAction(action);
	}
})