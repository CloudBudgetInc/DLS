({
	addLineToParentOrEdit : function(cmp, event) {
        //Setup variables to fire updateTimeInput event that TimeSheetApp.cmp is listening for
        var timeInput = cmp.get("v.timeInput");
        const lineToEdit = cmp.get('v.lineNumber');
        //timeInput.Date_of_Work__c = new Date(timeInput.Date_of_Work__c);
        var dtow = timeInput.Date_of_Work__c;
        console.log(':::::::::dtow:::::',dtow);
        var yr = dtow.split('-')[0];
        var mnth = dtow.split('-')[1];
        var day = dtow.split('-')[2];
        if(day.indexOf('0') == -1 && day < 10){
            day = '0'+day;
        }
        timeInput.Date_of_Work__c = yr+'-'+mnth+'-'+day;
        console.log(':::::::::date:::::',timeInput.Date_of_Work__c);
        console.log('Time Input work Item add to array: '+timeInput.MBA_Work_Item_Lookup__c);
        var updateEvent = cmp.getEvent("updateTimeInput");
        updateEvent.setParams({"timeInput": timeInput,
                               "lineNumber": lineToEdit
                              });
        updateEvent.fire();
        
        //hide Check icon, show Edit icon 
        cmp.set("v.checkShowHide", false);
        cmp.set("v.editShowHide", true);
	},
    editLineInArray : function(cmp, event){
        //hide Check icon, show Edit icon 
        cmp.set("v.checkShowHide", true);
        cmp.set("v.editShowHide", false);
    },
    deleteLine : function(cmp, event) {
        //Setup variables to fire deleteTimeInput event that TimeSheetApp.cmp is listening for
		const lineToDelete = cmp.get('v.lineNumber');
        var deleteEvent = cmp.getEvent("deleteTimeInput");
        deleteEvent.setParams({"lineToDelete" : lineToDelete});
        deleteEvent.fire();
        
        //delete the component that corresponds to the line to delete
        cmp.destroy();
	},
})