({
    fetchData: function (cmp, event, helper) {
		console.log('Fetch table data');
        
        //Create the action
        const timePeriod = cmp.get("v.timePeriod");
        var action = cmp.get("c.getTimeRecordsFromDb");
        action.setParams({
            timePeriod: timePeriod
        });
        cmp.set("v.showSpinner", true);
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.totalPages", Math.ceil(response.getReturnValue().length/cmp.get("v.pageSize")));
                cmp.set("v.allData", response.getReturnValue());
                cmp.set("v.currentPageNumber",1);
                cmp.set("v.showSpinner", false);
                console.log('Finished data fetch');
                helper.buildData(cmp, helper);
            } 
            else {
                console.log("Get Work Failed with state: " + state);
                cmp.set("v.showSpinner", false);
            }
        });
		$A.enqueueAction(action);
    },
    /*
     * this function will build table data
     * based on current page selection
     * */
    buildData : function(cmp, helper) {
        console.log('Enter Build data');
        var data = [];
        var pageNumber = cmp.get("v.currentPageNumber");
        var pageSize = cmp.get("v.pageSize");
        var allData = cmp.get("v.allData");
        var x = (pageNumber-1)*pageSize;
        
        //creating data-table data
        for(; x<(pageNumber)*pageSize; x++){
            if(allData[x]){
            	data.push(allData[x]);
            }
        }
        cmp.set("v.data", data);
        
        helper.generatePageList(cmp, pageNumber);
    },
     /*
     * this function generate page list
     * */
    generatePageList : function(cmp, pageNumber){
        console.log('Generate Page List');
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPage = cmp.get("v.totalPages");
        if((totalPage-1)<2){
            pageList.push(pageNumber);
            console.log('Push page number');
        } else if((totalPage-1) < 6){
                   console.log('page number: '+ pageNumber + ', totalPage = '+totalPage);
                   for (var i = 2; i<totalPage; i++){
                        pageList.push(i);
                   }
                   console.log('Page List: ' + pageList);
               } else if(pageNumber<5){
            			   pageList.push(2,3,4,5,6);
        			  } else if(pageNumber>(totalPage-5)){
                                  pageList.push(totalPage-5, totalPage-4, totalPage-3, totalPage-2, totalPage-1);
                             } else{
                                   pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                               }
        cmp.set("v.pageList", pageList);
    },   
    getRowActions: function (cmp, row, doneCallback) {
        var actions = [];
        var disableRow = row.isNotEditable__c;
        console.log('disable row: ' + disableRow);
        actions.push({
            label: 'Edit',
            name: 'edit',
            disabled: disableRow            
        });
        actions.push({
            label: 'Delete',
            name: 'delete',
            disabled: disableRow            
        });
        
        doneCallback(actions);
    },
    editRecord: function(cmp, row){
        console.log('Edit record helper method');
        
        cmp.set("v.showSpinner", true);
        var recordId = row.Id;
        console.log('recordId: ' + recordId);
        
        cmp.set('v.recId',recordId);
        
        var action = cmp.get("c.getRecordToEditFromDb");
        action.setParams({
            "recId": recordId
        });
        console.log('after action setup in edit record helper method');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                cmp.set("v.showSpinner", false);
                var resultData = response.getReturnValue();
                console.log('resultData..'+JSON.stringify(resultData));
                cmp.set("v.EditTimeItem", resultData);
                var cmpTarget = cmp.find('editDialog');
                var cmpBack = cmp.find('dialogBack');
                $A.util.addClass(cmpTarget, 'slds-fade-in-open');
                $A.util.addClass(cmpBack, 'slds-backdrop--open');
                cmp.find("dataTableEditSelect").set("v.value", resultData.MBA_Work_Item_Lookup__c);
             }
            else {
                console.log("Get EditTimeItem Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    saveModal: function(cmp, event, helper){
        console.log('Save button clicked on modal');
        var recordToSave = cmp.get("v.EditTimeItem");
        var action = cmp.get("c.saveRecordToEditToDb");
        action.setParams({
            "recordToUpdate": recordToSave
        });
        console.log('after action setup in save modal helper method');
        action.setCallback(this, function(response) {
            var resultsToast = $A.get("e.force:showToast");
            var state = response.getState();
            if (state === "SUCCESS" ) {
                console.log("Save EditTimeItem to DB Successful!!");
                resultsToast.setParams({
                    "title": "Saved",
                    "type": "success",
                    "message": "Item successfully saved."
                });
                resultsToast.fire();
                cmp.set("v.showSpinner", false);
                var cmpTarget = cmp.find('editDialog');
                var cmpBack = cmp.find('dialogBack');
                $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
                $A.util.removeClass(cmpBack, 'slds-backdrop--open');
                var updateEventChart = $A.get("e.c:chartUpdate");
        		updateEventChart.fire();
                var a = cmp.get('c.init');
        		$A.enqueueAction(a);
             }
            else {
                console.log("Save EditTimeItem to DB Failed with state: " + state);
                resultsToast.setParams({
                    "title": "Error",
                    "type":"error",
                    "message": "There was an error saving the record: " + JSON.stringify(result.error)
                });
                resultsToast.fire();
            }
        });
        $A.enqueueAction(action);
    },
    deleteRecord: function(cmp, row){
        console.log('Delete record helper method');
        
        cmp.set("v.showSpinner", true);
        var recordId = row.Id;
        console.log('recordId: ' + recordId);
        
        cmp.set('v.recId',recordId);
        
        var action = cmp.get("c.deleteRecordFromDb");
        action.setParams({
            "recordToDelete": recordId
        });
        console.log('after action setup in delete record helper method');
        action.setCallback(this, function(response) {
            var resultsToast = $A.get("e.force:showToast");
            var state = response.getState();
            if (state === "SUCCESS" ) {
                cmp.set("v.showSpinner", false);
				console.log('Item successfully deleted');
                resultsToast.setParams({
                    "title": "Saved",
                    "type": "success",
                    "message": "Item successfully deleted."
                });
                resultsToast.fire();
                var updateEventChart = $A.get("e.c:chartUpdate");
        		updateEventChart.fire();
                var a = cmp.get('c.init');
        		$A.enqueueAction(a);
             }
            else {
                console.log("Delete Item Failed with state: " + state);
                resultsToast.setParams({
                    "title": "Error",
                    "type":"error",
                    "message": "There was an error deleting the record: " + JSON.stringify(result.error)
                });
                resultsToast.fire();
            }
        });
        $A.enqueueAction(action);
    },
    sortData: function (cmp, fieldName, sortDirection) {
        console.log('Sort Data');
        var data = cmp.get("v.allData");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.allData", data);
        var onFirst = cmp.get('c.onFirst');
        $A.enqueueAction(onFirst);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ? function(x) {return primer(x[field])} : function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})