({
	doInit : function(component, event, helper) {
        //Modified By Dhinesh - 10/10/2023 - W-007894 - Request to Add Date Filters to the Lesson Plan Section in DLS Online 
        component.set('v.filterDate', {from:null,to:null});
		helper.getLessonPlans(component);
    },
    validateDates: function(component, event, helper){ //Modified By Dhinesh - 10/10/2023 - W-007894 - Request to Add Date Filters to the Lesson Plan Section in DLS Online 
        let isValid = true,
            filterDate = component.get('v.filterDate'),
            inputCmp = component.find("toDateInput");
            
        
        if(filterDate.from && filterDate.to){
            let dateDiff = (moment(filterDate.to)).diff(moment(filterDate.from), "days");
            if(dateDiff < 0){
                isValid = false;
                inputCmp.setCustomValidity("To Date should be greater than or equal to From Date.");                                    
            }else{
                inputCmp.setCustomValidity("");
            }
        }else{
            inputCmp.setCustomValidity("");
        }
        inputCmp.reportValidity();    	
        
        if(isValid){
        	helper.getLessonPlans(component);
        }
    },
    tabActionClicked: function (component, event, helper) {
        var actionId = event.getParam("actionId");
        var row = event.getParam("row");
        console.log(actionId);
        if (actionId == "viewLessonPlan") {
            var dateStr = '';
            if(row.Date__c){
                var date = row.Date__c.split('-');
                dateStr = date[1]+'/'+date[2]+'/'+date[0];
            }
            row.dateStr = dateStr;
            component.set('v.selectedRecord', row);
            //component.set('v.showLessonPlan', true);  
            
             var communityName = component.get('v.communityName'),
              selectedRecord = component.get('v.selectedRecord');
            
            var urlString = window.location.href;
            var baseURL = urlString.substring(0, urlString.indexOf("/s/"))+'/s/lesson-plan?';
            
            var url = baseURL+'communityName='+communityName+'&eventId='+selectedRecord.Event__c+'&modalHeader=Lesson Plan ' +dateStr;   
            window.open(url, '_blank');
        }
           
    },
})