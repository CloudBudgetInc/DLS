({
    getWeeklySummaryData : function(cmp, event, helper) {
        var params = {};
        params.projectId = cmp.get("v.projectId"); 
        console.log('projectId:::', params)
        var self = this;        
        const server = cmp.find('server');
        const action = cmp.get('c.getWeekSummaryDetails');
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {    
                console.log('response', response);
                let res = JSON.parse(response);
                console.log('res:::::>>>>>', res);
                cmp.set('v.weeklyTimeSummary', res);   
                cmp.set('v.isInstructor', res.isInstructor);
                cmp.set('v.insId', res.insId);
                cmp.set('v.showSpinner', false);
            }),
            $A.getCallback(function(errors) { 
                cmp.set('v.showSpinner', false);
                console.log('error', errors);
            }),
            false, 
            false,
            false
        );
    },
    
    instructorData : function(cmp, event, helper) {
        console.log('instructor called');        
        var params = {};
        params.projectId = cmp.get("v.projectId"); 
        params.periodId = cmp.get("v.periodId"); 
        console.log('projectId:::>>>', params)
        var self = this;        
        const server = cmp.find('server');
        const action = cmp.get('c.getInstructorDetails');
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {    
                console.log('response>>>>>>>>>>>>>>>>>>>>>>>>>>>', response);
                cmp.set('v.insSummary', JSON.parse(response));
                let contentSum = {showWeekSummary:false, showInsSummary:true, showDaySummary: false};
                cmp.set('v.showSpinner', false);
                cmp.set('v.showContent', contentSum);
            }),
            $A.getCallback(function(errors) { 
                cmp.set('v.showSpinner', false);
                console.log('error', errors);
            }),
            false, 
            false,
            false
        );
    },
    
    daySummaryData : function(cmp, event, helper) {
        console.log('called:::>> helper :::>>');        
        cmp.set('v.showSpinner', true);
        var params = {};
        params.projectId = cmp.get("v.projectId"); 
        params.periodId = cmp.get("v.periodId"); 
        params.timeCardId = cmp.get("v.timeCardId");
        if(cmp.get('v.isInstructor')) {
        	params.insId = cmp.get('v.insId');
        }
        console.log('params:::>>>', params)
        var self = this;        
        const server = cmp.find('server');
        const action = cmp.get('c.getDaySummaryDetails');
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {    
                console.log('response>>>>>>>>>>>>>>>>>>>>>>>>>>>', JSON.parse(response));
                let res = JSON.parse(response);
                //cmp.set('v.insSummary', JSON.parse(response));
                let contentSum = {showWeekSummary:false, showInsSummary:false, showDaySummary: true};
                cmp.set('v.showContent', contentSum);
                cmp.set('v.daySummary', res);
                cmp.set('v.showSpinner', false);
            }),
            $A.getCallback(function(errors) { 
                cmp.set('v.showSpinner', false);
                console.log('error', errors);
            }),
            false, 
            false,
            false
        );
    }
})