({
	getLessonPlans : function(component) {
		component.set("v.showSpinner", true);
        
        var projId = component.get('v.projectId'),
            communityName = component.get('v.communityName'),
            filterDate = component.get('v.filterDate');
        
        const server = component.find("server");        
        const action = component.get("c.getLessonPlanList");
        
        var param = {
        	projectId: projId,
            communityName:communityName,
            filterDate: filterDate ? filterDate : null//Modified By Dhinesh - 10/10/2023 - W-007894 - Request to Add Date Filters to the Lesson Plan Section in DLS Online 
        };
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (response) {
                component.set("v.showSpinner", false);
                console.log('here',response);
                component.set("v.lessonPlans", response);
                var tableColumns = [                    
                    {
                        label: "Date",
                        name: "Date__c",
                        type: "date",
                        truncate: {},
                        sortable: true,
                        format: "MM/DD/YYYY"
                    },
                    {
                        label: "Instructor",
                        name: "Instructor__r.Name",
                        type: "string",
                        truncate: {},
                        sortable: true
                    },
                    {
                        label: "Objective(s)",
                        name: "Objectives__c",
                        type: "string",
                        truncate: {},
                        sortable: true
                    },
                    {
                        label: "Topics",
                        name: "Topics__c",
                        type: "string",
                        truncate: {},
                        sortable: true
                    }                    
                ]; 
                
                if(communityName != 'student'){
                    tableColumns.push({
                        label: "Status",
                        name: "Status__c",
                        type: "string",
                        truncate: {},
                        sortable: true
                    });
                }
                
                component.set("v.tableColumns", tableColumns);
                
                var tableConfig = {
                    massSelect: false,
                    globalAction: [],
                    rowAction: [                        
                        {
                            "type": "image",
                            "class": "imgAction2",
                            "id": "viewLessonPlan",
                            "src": $A.get('$Resource.lessonPlan')
                        }
                    ],
                    "rowActionPosition":'right',
                    "rowActionWidth":'200',
                    paginate: true,
                    searchBox: false
                };
                component.set("v.tableConfig", tableConfig);
                
                if(response.length > 0){
                    component.find("lessonPlansTable").initialize({});
                }
            }),
            $A.getCallback(function (errors) {
                //helper.showToast(component, event, "Error", errors[0].message, "error");
                console.log( errors[0].message);
            }),
            false,
            false,
            false
        );
	}
})