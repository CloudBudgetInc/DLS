({
	getFileDetail : function(cmp, event, helper) {
        cmp.set("v.showSpinner", true);
        var qry = JSON.parse(cmp.get("v.query")),
            finalQueryStr = JSON.stringify({query: qry.query});
		var action = cmp.get("c.getFileDetails");
        var qryList = qry.query.split('limit q '),
        limit = 2500;
        if(qryList.length > 1){
            limit = qryList[1].replace(';', '');
        }
        cmp.set("v.limit", limit);
        action.setParams({
            "queryStr" :  finalQueryStr          
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            cmp.set("v.showSpinner", false);
            if(state == 'SUCCESS'){
                
                var result = JSON.parse(response.getReturnValue());                
                var records = [];
                if(result.results && result.results['records']){
                    records = result.results['records']
                }                
                
                var parentIds = [];
                for(var i=0; i < records.length; i++){
                    
                    if(records[i].parent_id){
                        parentIds.push(records[i].parent_id); 
                    }                                       
                }
                this.getSalesforceId(cmp, parentIds, records);
                
            }else {
                this.showToast(cmp,response.getError()[0].message, 'Error');                       	
            }
        });
        $A.enqueueAction(action);
	},
    getSalesforceId: function(cmp, parentIds, records){
        cmp.set("v.showSpinner", true);
        
		var action = cmp.get("c.getRelatedSalesforceId");
        action.setParams({
            "parentIds" :  parentIds         
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            cmp.set("v.showSpinner", false);
            if(state == 'SUCCESS'){
                
                var result = response.getReturnValue();                
                for(var i=0; i < records.length; i++){
                    
                    if(records[i].parent_id && result[records[i].parent_id]){
                        records[i]['salesforce_id'] = result[records[i].parent_id]; 
                    }                    
                }
                console.log(records);
                cmp.set("v.fileDetails", records);                
                cmp.find("fileDuplicatesTable").initialize({
                    order: []
                });                       
            }else {
                this.showToast(cmp,response.getError()[0].message, 'Error');
            }
        });
        $A.enqueueAction(action);
    },
    excludeFromDuplicates: function(cmp, selectedRows){
        cmp.set("v.showSpinner", true);
        
		var action = cmp.get("c.excludeFilesFromDuplicates");
        action.setParams({
            "selectedRowsStr" :  JSON.stringify(selectedRows)          
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            cmp.set("v.showSpinner", false);
            if(state == 'SUCCESS'){
                
                var result = JSON.parse(response.getReturnValue());
                console.log(result);
                this.showToast(cmp,result.message, result.status);                          
            }else {
                this.showToast(cmp,response.getError()[0].message, 'Error');
            }
        });
        $A.enqueueAction(action);
    },
    getBaseURL:function(cmp, selectedRows){
        cmp.set("v.showSpinner", true);
        
		var action = cmp.get("c.getOrgBaseURLAndUserDetailsMap");        
        action.setCallback(this, function(response){
            var state = response.getState();
            cmp.set("v.showSpinner", false);
            if(state == 'SUCCESS'){
                
                var result = response.getReturnValue();
                cmp.set("v.userDetails", JSON.parse(result.userDetails));
                cmp.set("v.baseUrl", result.baseUrl);                        
            }else {
                this.showToast(cmp,response.getError()[0].message, 'Error');
            }
        });
        $A.enqueueAction(action);
    },
    showToast: function(cmp, message, header){
        var toast = {
            message: message, 
            header: header
        }
        cmp.set("v.toast", toast);
        cmp.find("toastModal").open(); 
    }
})