({
	getSemiMonthlyWeekDetails : function(component) {
		var action = component.get("c.getSemiMontlyWeeks");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log("response:::::::::::",JSON.parse(response.getReturnValue()));
                var result = JSON.parse(response.getReturnValue());
                var weekArray = result.weekRanges;
                var index = weekArray.indexOf(result.currentWeek);
                
                component.set("v.WeekRanges",result.weekRanges);
                component.set("v.selectedWeek",result.currentWeek);
                component.set("v.currentIndex",index);
				this.getSpecificSemiMonthlyInfo(component);   
            }
        });
        $A.enqueueAction(action);
	},
    apexDateFormatFunction : function(dateval){
        return dateval.split('/')[2]+'-'+dateval.split('/')[0]+'-'+dateval.split('/')[1];
    },
    getSpecificSemiMonthlyInfo : function(component){
        component.set("v.showSpinner",true);
        var startDate = this.apexDateFormatFunction(component.get("v.selectedWeek").split(' / ')[0]);
		var endDate = this.apexDateFormatFunction(component.get("v.selectedWeek").split(' / ')[1]);
        var action = component.get("c.SemiMonthlyInformation");
        action.setParams({
            "startDate" : startDate,
            "endDate" : endDate
                         });
        action.setCallback(this,function(response){
			var state = response.getState();
            if(state == 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
                console.log('::::result:::getSpecificSemiMonthlyInfo::::::::',result);
                var contactId  = '';
                if(result.contactFilters.length == 0) {
                    component.set("v.selectedContact","");
                    contactId = "";
                }else {
                    component.set("v.selectedContact",result.contactFilters[0].Id);
                    contactId = result.contactFilters[0].Id;
                }
                component.set("v.wholeSummary",result.dateSummaryDetailMap);
                component.set("v.contactFilter",result.contactFilters);
                component.set("v.summaryEntries",result.dateSummaryDetailMap[contactId]);
                component.set("v.showSpinner",false);
                this.grandTotalCalculation(component);
            }            
        });
        $A.enqueueAction(action);
    },
    grandTotalCalculation : function(component){
        var summary = component.get("v.summaryEntries");
        var total = 0;
        for(var i = 0;i < summary.length;i++){
            total += summary[i].Hours;
        }
        component.set("v.grandTotal",total);
    },
    PreviousClick : function(component){
        component.set("v.showSpinner",true);
        var weekRanges = component.get("v.WeekRanges");
        var currIndex = component.get("v.currentIndex");
        var previousIndex = currIndex - 1;
        
        if(previousIndex === 0)
            component.set("v.displayPrevious",false);
        
        component.set("v.displayNext",true);
        component.set("v.selectedWeek",weekRanges[previousIndex]);
        component.set("v.currentIndex",previousIndex);
        this.getSpecificSemiMonthlyInfo(component);
    },
    NextClick : function(component){
        component.set("v.showSpinner",true);
        var weekRanges = component.get("v.WeekRanges");
        var currIndex = component.get("v.currentIndex");
        var nextIndex = currIndex + 1;
        
        if(nextIndex === weekRanges.length - 1)
            component.set("v.displayNext",false);
        
        component.set("v.displayPrevious",true);
        component.set("v.selectedWeek",weekRanges[nextIndex]);
        component.set("v.currentIndex",nextIndex);
        this.getSpecificSemiMonthlyInfo(component);
    },
    fireSummaryEvent : function(component){
        console.log('helper:::::::::');
        var summaryEve = component.getEvent("summaryEvent");
        summaryEve.setParams({"typeOfAction" : "From Summary"});
        summaryEve.fire();
    }
})