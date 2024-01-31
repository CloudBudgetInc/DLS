({
    getInitialFilterValues : function(cmp,event){
        cmp.set("v.showSpinner",true);
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getProjectRecords');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('response::::::',JSON.parse(response));
                var result = JSON.parse(response);
                var projects = result.projectRecords;
                cmp.set("v.projectList",projects);    
                cmp.set("v.communityName",result.communityName);
                cmp.set("v.startDate",result.fromDate);
                cmp.set("v.endDate",result.toDate);
                
                window.setTimeout(
                    $A.getCallback(function() {
                        if(cmp.get("v.projectId")){
                            cmp.set("v.selectedProject",cmp.get("v.projectId"));
                            self.getTimeActivityList(cmp, event);
                        }else if(cmp.get("v.startDate") && cmp.get("v.endDate")){
                            self.getTimeActivityList(cmp, event);
                        }
                    }),500);
                
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,response.getError()[0].message,'error');
            }),
            false, 
            false,
            false
        );
    },
    getTimeActivityList : function(cmp, event) {
        cmp.set("v.showSpinner",true);
        var params = {};
        params.projectId = cmp.get("v.selectedProject") != '--None--' ? cmp.get("v.selectedProject") : '';
        params.startDate = cmp.get("v.startDate");
        params.endDate = cmp.get("v.endDate");
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getTimeCardDaysList');
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                console.log('response::::::',JSON.parse(response));
                cmp.set("v.showSpinner",false);
                var result = JSON.parse(response);
                //if(cmp.get("v.conditionCheck")){
                cmp.set("v.timeCardDays",result.timeRecords);    
                cmp.set("v.totalHrs",result.totalHrs);
                //}
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,response.getError()[0].message,'error');
            }),
            false, 
            false,
            false
        );
        
    },
    
    showToast : function(cmp, event, message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    }
    
})