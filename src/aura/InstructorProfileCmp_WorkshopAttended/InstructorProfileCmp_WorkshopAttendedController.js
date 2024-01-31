({
	doInit : function(cmp, event, helper) {
		var action = cmp.get("c.getWorkshopAttededByContactId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                console.log(result);
                var tableColumns = [                
                    {
                        label: "Workshop Name",
                        name: "Professional_Development__r.Name",
                        type: "String",
                        truncate: {},
                        sortable: true
                    },
                    {
                        label: "Date",
                        name: "Professional_Development__r.Date__c",
                        type: "date",
                        truncate: {},
                        sortable: true,
                        format: "MM/DD/YYYY"
                    },
                    {
                        label: "Workshop Presenter",
                        name: "Professional_Development__r.Workshop_Presenter__c",
                        type: "string",
                        truncate: {},
                        visible: true,
                        sortable: true,
                        class:'tableHeaderTextWrap'
                    }
                ];
                
                cmp.set("v.tableColumns", tableColumns);
                
                //Configuration data for the table to enable actions in the table
                var tableConfig = {
                    massSelect: false,
                    globalAction: [],
                    rowAction: [],
                    paginate: true,
                    searchBox: false
                };
                cmp.set("v.tableConfig", tableConfig);
                
                cmp.set('v.workshopAttendanceList', result);
                
                
                if(result.length > 0){
                    cmp.find("workshopAttendanceTable").initialize({
                        "order":[1, 'desc'],
                    });
                }                                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        }); 
        $A.enqueueAction(action);
	}
})