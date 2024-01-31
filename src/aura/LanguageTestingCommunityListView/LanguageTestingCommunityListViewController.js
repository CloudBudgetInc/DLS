({
	doInit: function (component, event, helper) { 
        var tableColumns = [
            {
                label: "Examinee",
                name: "Testee__r.Name",
                type: "string",
                sortable: true
            },  
            {
                label: "Tester",
                name: "Tester__r.Name",
                type: "string",
                sortable: true
            },
            {
                label: "Test Type",
                name: "Test_Type__c",
                type: "string",
                sortable: true
            },
            {
                label: "Date & Time Scheduled",
                name: "Date_Time_Scheduled__c",
                type: "datetime",
                sortable: true,
                format: "MM/DD/YYYY HH:mm A"
            },
            {
                label: "L Score",
                name: "L_Score__c",
                type: "string",
                width: 120,
                sortable: false
            },
            {
                label: "R Score",
                name: "R_Score__c",
                type: "string",
                width: 120,
                sortable: false
            },
            {
                label: "S Score",
                name: "S_Score__c",
                type: "string",
                width: 120,
                sortable: false
            },
            {
                label: "W Score",
                name: "W_Score__c",
                type: "string",
                width: 130,
                sortable: false
            }
        ];
        
        component.set("v.tableColumns", tableColumns);
        
        //Configuration data for the table to enable actions in the table
        var tableConfig = {
            massSelect: false,
            globalAction: [],
            rowAction: [],
            paginate: true,
            searchBox: false
        };
        component.set("v.tableConfig", tableConfig);
        
        helper.getLanguageTestings(component, event, helper);    
    },
})