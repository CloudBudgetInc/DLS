({
    getFilterValues : function(cmp, event){
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getWeekRangeFilterValues');
        server.callServer(
            action, 
            {}, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('result:::::::',result);
                cmp.set("v.weekRangeValues",result.weekFilter);
                cmp.set("v.instructorName",result.employeeName);
                cmp.set("v.instructorId",result.contactId);
                
                window.setTimeout(
                    $A.getCallback(function() {
                        //Commented by NS on OCT 14 2021 - W-007095
                        //if(result.selectedWeek){
                            var urlParam = cmp.get("v.urlParams");
                            if(Object.keys(urlParam).length > 0){
                                cmp.set("v.selectedWeek",urlParam.weekRange);
                            }else {
                                cmp.set("v.selectedWeek",result.weekFilter[0]);
                            }
                            
                        	self.getTCDRecords(cmp, event);
                        /*}else {
                            cmp.set("v.showSpinner",false);
                        }*/
                        
                    }),100);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    },
	getTCDRecords : function(cmp, event) {
		var self = this; 
        
        var dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
		 
        const server = cmp.find('server');
        const action = cmp.get('c.getCompletedTCDRecords');
        
        var params = {};
        params.startDt = dt1;
        params.endDt = dt2;
        server.callServer(
            action, 
            params, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log(':::::::::result:::::::',result);
                cmp.set("v.dayRecords",result.entries);
                cmp.set("v.totalHrs",result.totalHrs);
                cmp.set("v.showSubmitBtn",result.displaySubmitBtn);
                cmp.set("v.submitMsg",result.submittedMsg);
                cmp.set("v.proIdStudentNames",result.proIdStudentNames);
                cmp.set("v.notCompletedProjects",result.notCompletedProjects);
                
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
        
	},
    showToast : function(cmp,event,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            type: type,
            mode: 'sticky'
        });
        toastEvent.fire();
    },
    apexDateFormatFunction : function(dateval){
        return dateval.split('/')[2]+'-'+dateval.split('/')[0]+'-'+dateval.split('/')[1];
    },
    submitTimeEntries : function(cmp, event){
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.submitSelectedWeekTimeEntries');
        
        var timeEntries = cmp.get("v.dayRecords");
        var params = {};
        params.timeDayJson = JSON.stringify(timeEntries);
        
        server.callServer(
            action, 
            params, 
            false, 
            $A.getCallback(function(response) { 
                var result = response;
                cmp.set("v.successMsg",'Time entries are submitted to supervisor for approval.');
                cmp.set("v.successTitle",'Success');
                cmp.set("v.displaySuccessModal",true);
                cmp.set("v.showSpinner",false);
                if(Array.isArray(cmp.find("successModal"))) {
                    cmp.find("successModal")[0].open();
                }else{
                    cmp.find("successModal").open();
                }
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    }
})