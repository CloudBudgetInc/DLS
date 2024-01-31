({
	filterTableToday : function(cmp, event) {
        console.log('filterTableToday helper');
        //set time period and call fireUpdateTableEvent
        var timePeriod = 'Today';
		this.fireUpdateTableEvent(timePeriod);
    },
    filterTableYesterday : function(cmp, event) {
		console.log('filterTableYesterday helper');
        //set time period and call fireUpdateTableEvent
        var timePeriod = 'Yesterday';
        this.fireUpdateTableEvent(timePeriod);
	},
    filterTableThisWeek : function(cmp, event) {
		console.log('filterTableThisWeek helper');
        //set time period and call fireUpdateTableEvent
        var timePeriod = 'This Week';
        this.fireUpdateTableEvent(timePeriod);
	},
    filterTableLastWeek : function(cmp, event) {
		console.log('filterTableLastWeek helper');
        //set time period and call fireUpdateTableEvent
        var timePeriod = 'Last Week';
        this.fireUpdateTableEvent(timePeriod);
	},
    filterTableThisMonth : function(cmp, event) {
		console.log('filterTableThisMonth helper');
        //set time period and call fireUpdateTableEvent
        var timePeriod = 'This Month';
        this.fireUpdateTableEvent(timePeriod);
	},
    filterTableLastMonth : function(cmp, event) {
		console.log('filterTableLastMonth helper');
        //set time period and call fireUpdateTableEvent
        var timePeriod = 'Last Month';
        this.fireUpdateTableEvent(timePeriod);
	},
    fireUpdateTableEvent : function(timePeriod){
        var updateTableEvent = $A.get("e.c:dataTableUpdate");
        updateTableEvent.setParams({"timePeriod": timePeriod});
        updateTableEvent.fire();
        console.log(timePeriod + ' click event to update table was fired')
    },
    generateTimeCharts : function(cmp){
        console.log('Generate Time Chart function');
        var timeTotals = cmp.get("v.timeTotals");
        //Today
        var chartdiv = cmp.find("todayChart").getElement();
        var todayChart = AmCharts.makeChart(chartdiv,{
            "type": "gauge",
            "arrows": [
                {
                    "value": timeTotals[0]
                }
            ],
            "titles": [
                {
                    "text": "Today",
                    "size": 15
                }
            ],
            "axes": [
                {
                    "bottomText": timeTotals[0],
                    "endValue": 12,
                    "valueInterval": 1,
                    "bands": [
                        {
                            "color": "#ea3838",
                            "endValue": 7,
                            "startValue": 0
                        },
                        {
                            "color": "#ffac29",
                            "endValue": 8,
                            "startValue": 7
                        },
                        {
                            "color": "#00CC00",
                            "endValue": 12,
                            "startValue": 8,
                            "innerRadius": "95%"
                        }
                    ]
                }
            ]
		});
        //Yesterday
        var chartdiv = cmp.find("yesterdayChart").getElement();
        var yesterdayChart = AmCharts.makeChart(chartdiv,{
            "type": "gauge",
            "arrows": [
                {
                    "value": timeTotals[1]
                }
            ],
            "titles": [
                {
                    "text": "Yesterday",
                    "size": 15
                }
            ],
            "axes": [
                {
                    "bottomText": timeTotals[1],
                    "endValue": 12,
                    "valueInterval": 1,
                    "bands": [
                        {
                            "color": "#ea3838",
                            "endValue": 7,
                            "startValue": 0
                        },
                        {
                            "color": "#ffac29",
                            "endValue": 8,
                            "startValue": 7
                        },
                        {
                            "color": "#00CC00",
                            "endValue": 12,
                            "startValue": 8,
                            "innerRadius": "95%"
                        }
                    ]
                }
            ]
		});
        //This Week
        var chartdiv = cmp.find("thisWeekChart").getElement();
        var thisWeekChart = AmCharts.makeChart(chartdiv,{
            "type": "gauge",
            "arrows": [
                {
                    "value": timeTotals[2]
                }
            ],
            "titles": [
                {
                    "text": "This Week",
                    "size": 15
                }
            ],
            "axes": [
                {
                    "bottomText": timeTotals[2],
                    "endValue": 60,
                    "valueInterval": 5,
                    "bands": [
                        {
                            "color": "#ea3838",
                            "endValue": 35,
                            "startValue": 0
                        },
                        {
                            "color": "#ffac29",
                            "endValue": 40,
                            "startValue": 35
                        },
                        {
                            "color": "#00CC00",
                            "endValue": 60,
                            "startValue": 40,
                            "innerRadius": "95%"
                        }
                    ]
                }
            ]
		});
        //Last Week
        var chartdiv = cmp.find("lastWeekChart").getElement();
        var lastWeekChart = AmCharts.makeChart(chartdiv,{
            "type": "gauge",
            "arrows": [
                {
                    "value": timeTotals[3]
                }
            ],
            "titles": [
                {
                    "text": "Last Week",
                    "size": 15
                }
            ],
            "axes": [
                {
                    "bottomText": timeTotals[3],
                    "endValue": 60,
                    "valueInterval": 5,
                    "bands": [
                        {
                            "color": "#ea3838",
                            "endValue": 35,
                            "startValue": 0
                        },
                        {
                            "color": "#ffac29",
                            "endValue": 40,
                            "startValue": 35
                        },
                        {
                            "color": "#00CC00",
                            "endValue": 60,
                            "startValue": 40,
                            "innerRadius": "95%"
                        }
                    ]
                }
            ]
		});
        //This Month
        var chartdiv = cmp.find("thisMonthChart").getElement();
        var thisMonthChart = AmCharts.makeChart(chartdiv,{
            "type": "gauge",
            "arrows": [
                {
                    "value": timeTotals[4]
                }
            ],
            "titles": [
                {
                    "text": "This Month",
                    "size": 15
                }
            ],
            "axes": [
                {
                    "bottomText": timeTotals[4],
                    "endValue": 280,
                    "valueInterval": 40,
                    "bands": [
                        {
                            "color": "#ea3838",
                            "endValue": 140,
                            "startValue": 0
                        },
                        {
                            "color": "#ffac29",
                            "endValue": 180,
                            "startValue": 140
                        },
                        {
                            "color": "#00CC00",
                            "endValue": 280,
                            "startValue": 180,
                            "innerRadius": "95%"
                        }
                    ]
                }
            ]
		});
        //Last Month
        var chartdiv = cmp.find("lastMonthChart").getElement();
        var lastMonthChart = AmCharts.makeChart(chartdiv,{
            "type": "gauge",
            "arrows": [
                {
                    "value": timeTotals[5]
                }
            ],
            "titles": [
                {
                    "text": "Last Month",
                    "size": 15
                }
            ],
            "axes": [
                {
                    "bottomText": timeTotals[5],
                    "endValue": 280,
                    "valueInterval": 40,
                    "bands": [
                        {
                            "color": "#ea3838",
                            "endValue": 140,
                            "startValue": 0
                        },
                        {
                            "color": "#ffac29",
                            "endValue": 180,
                            "startValue": 140
                        },
                        {
                            "color": "#00CC00",
                            "endValue": 280,
                            "startValue": 180,
                            "innerRadius": "95%"
                        }
                    ]
                }
            ]
		});
    },

    fetchTimeData : function(cmp,event,helper) {
        console.log('Fetch time data helper method');
        //Create action for call to getTimeTotalsFromDb apex controller method
        cmp.set("v.showSpinner", true);
        var action = cmp.get("c.getTimeTotalsFromDb");      
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State: ' + state);
            if (state === "SUCCESS") {
                var timeTotals = response.getReturnValue();
                cmp.set("v.timeTotals", timeTotals);
                cmp.set("v.showSpinner", false);
                console.log('Time total today: ' + timeTotals[0]);
                helper.generateTimeCharts(cmp);
            }
            else {
                console.log("Get Time Totals Failed with state: " + state);
            }
        });
        
        // Send action off to be executed
        $A.enqueueAction(action); 
	},
})