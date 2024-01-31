({
    init : function(component, event, helper) {
        helper.getWeeklySummaryData(component, event, helper);  
        let showCon = {showWeekSummary:true, showInsSummary:false, showDaySummary: false}
        component.set('v.showContent', showCon);
        if(component.get('v.weekRange')){
        	component.set('v.weekRange', "");
            component.set('v.instructor', "");
        }
    },
    
    getNextSummaryDetails : function(component, event, helper) {        
        component.set('v.showSpinner', true);
        console.log('called::::');                       
        console.log('event:::', event);
        let periodId;
        if(event.target && event.target.getAttribute("name")) {
            var index = event.target.getAttribute("name"); 
            periodId = component.get('v.weeklyTimeSummary.WeeklySummary')[index].periodId;
            component.set('v.periodId', periodId); 
            component.set('v.weekRange', component.get('v.weeklyTimeSummary.WeeklySummary')[index].dateRange);         
        }
        console.log('periodId:::', periodId);
        console.log('isInstructor:::::>',component.get('v.isInstructor'));
        if(component.get("v.instructor")) {
            component.set('v.instructor', "");
        }
        if(component.get('v.isInstructor')) {
            helper.daySummaryData(component, event, helper);    
        } else {
            helper.instructorData(component, event, helper);
        }
    },
    
    handleActivityClick : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/timekeeping-activity?projectId='+component.get("v.projectId")
        });
        urlEvent.fire();
    },
    
    getDaySummaryData : function(component, event, helper) {        
        var index = event.target.getAttribute("name");
        console.log('event:::', event);
        let timeCardId;
        if(event.target && event.target.getAttribute("name")){
            timeCardId = component.get('v.insSummary.InstructorSummary')[index].timeCardId;
            component.set('v.timeCardId', timeCardId);
            component.set('v.instructor', component.get('v.insSummary.InstructorSummary')[index].insName);        
        }
        console.log('timeCardId:::', timeCardId);
        helper.daySummaryData(component, event, helper);
    }
    
})