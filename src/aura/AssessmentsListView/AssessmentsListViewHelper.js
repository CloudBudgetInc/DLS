({
    
    getCommunityName: function(component, event, helper){
        component.set("v.showSpinner", true);
        const server = component.find("server");
        const action = component.get("c.getCommunityType");    
        var param = {};
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (response) {
                component.set("v.communityType", response); 
                var projId = component.get('v.projectId');
                /*if(response == 'student' || projId){
                    console.log(component.get('v.projectId'));
                    var selectedFilterValues = component.get("v.selectedFilterValues");
                    selectedFilterValues.status = 'Completed';
                    component.set("v.selectedFilterValues", selectedFilterValues);
                }*/              
                if(response == 'client'){
                    var selectedFilterValues = component.get("v.selectedFilterValues");
                    selectedFilterValues.status = 'Completed';
                    component.set("v.selectedFilterValues", selectedFilterValues);
                }
                component.set("v.showSpinner", false);
                helper.getAssesmentRecords(component, event, helper);
            }),
            $A.getCallback(function (errors) {
                helper.showToast(component, event, "Error", errors[0].message, "error");
            }),
            false,
            false,
            false 
        );
    },
    getAssesmentRecords: function (component, event, helper) {
        component.set("v.showSpinner", true);
        var selectedFilterValues = component.get("v.selectedFilterValues");
        var projId = component.get('v.projectId');
        console.log(projId);
        let communityType = component.get("v.communityType");
        const server = component.find("server");        
        const action = component.get("c.getAssessments");

        var status =
            (!projId || communityType == "student" || communityType == 'client') ? selectedFilterValues.status : "";
        
        projId = !projId && selectedFilterValues.project != 'All' ? selectedFilterValues.project : ( projId ? projId : '');
        
        var param = {
            status: (selectedFilterValues.reportType == 'Student Progress Reports' ||  selectedFilterValues.reportType == 'Test Reports' || selectedFilterValues.reportType == 'Assessment by Instructor' || selectedFilterValues.reportType == 'Student Self-Assessment' || selectedFilterValues.reportType == 'All') ? status : 'Completed',
            projectId: projId,
            reportType: selectedFilterValues.reportType
        };
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (response) {
                component.set("v.assessments", response.assessments);
                var filterPicklistValues = response.filterPicklistValues;
                filterPicklistValues['typeOfReport'] = communityType == 'instructor' ? ['All','Student Progress Reports','My Observation Report','My Annual Reports', 'Test Reports','Assessment by Instructor','Student Self-Assessment'] : ['All','Student Progress Reports','Test Reports','Assessment by Instructor','Student Self-Assessment'];
                component.set("v.filterPicklistValues", filterPicklistValues);
                component.set("v.showSpinner", false);
                if(selectedFilterValues.reportType == 'Student Progress Reports' || selectedFilterValues.reportType == 'Assessment by Instructor' || selectedFilterValues.reportType == 'Student Self-Assessment' || selectedFilterValues.reportType == 'Test Reports' || selectedFilterValues.reportType == 'All'){
                    helper.initStudentProgressReportTable(component, event, helper);
                }else if(selectedFilterValues.reportType == 'My Observation Report'){
                    helper.initObservationReportTable(component, event, helper);
                }else if(selectedFilterValues.reportType == 'My Annual Reports'){
                    helper.initAnnualReviewReportTable(component, event, helper);
                }
                
                var assessments = component.get("v.assessments");
                
                if(assessments.length > 0){
                    var init = selectedFilterValues.reportType == 'All' ? {"order":[3,"desc"]} : {};                    
                    component.find("assessmentTable").initialize(init);
                }
            }),
            $A.getCallback(function (errors) {
                helper.showToast(component, event, "Error", errors[0].message, "error");
            }),
            false,
            false,
            false
        );
    },
    initStudentProgressReportTable: function(component, event, helper){
        var selectedFilterValues = component.get("v.selectedFilterValues");
        var tableColumns = [
            {
                label: "Name",
                name: "Name",
                type: "url",
                truncate: {},
                sortable: true,
                enableCellClickEvt: true,
                class:'tableHeaderTextWrap'
            }
        ];
        
        if (!component.get("v.projectId")) {
            tableColumns.push({
                label: "Class #",
                name: "projectClassNo",
                type: "url",
                truncate: {},
                sortable: true,
                enableCellClickEvt: true,
                class:'tableHeaderTextWrap'
            });
        }
        
        if(selectedFilterValues.reportType == 'All'){
            tableColumns.push({
                label: "Type of Report",
                name: "typeOfReport",
                type: "string",
                truncate: {},
                visible: true,
                sortable: true,
                class:'tableHeaderTextWrap'
            },{
                label: "Due Date",
                name: "dueDate",
                type: "date",
                truncate: {},
                sortable: true,
                format: "MM/DD/YYYY",
                class:'tableHeaderTextWrap'
            });
        }
        
        if(selectedFilterValues.reportType == 'Student Progress Reports'){
             tableColumns.push({
                label: "Evaluation Period From",
                name: "EvaluationPeriodFrom",
                type: "date",
                truncate: {},
                sortable: true,
                format: "MM/DD/YYYY",
                class:'tableHeaderTextWrap'
            },
            {
                label: "Evaluation Period To",
                name: "EvaluationPeriodTo",
                type: "date",
                truncate: {},
                sortable: true,
                format: "MM/DD/YYYY",
                class:'tableHeaderTextWrap'
            });
        }
        
        tableColumns.push(            
            {
                label: "Status",
                name: "Status",
                type: "string",
                truncate: {},
                visible: true,
                sortable: true,
                class:'tableHeaderTextWrap'
            }
        );
        
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
    },
    initObservationReportTable: function(component, event, helper){
        var tableColumns = [
            {
                label: "Name",
                name: "Name",
                type: "url",
                truncate: {},
                sortable: true,
                enableCellClickEvt: true,
                class:'tableHeaderTextWrap'
            },
            {
                label: "Class #",
                name: "projectClassNo",
                type: "url",
                truncate: {},
                sortable: true,
                enableCellClickEvt: true,
                class:'tableHeaderTextWrap'
            },
            {
                label: "Date Completed",
                name: "dateCompleted",
                type: "date",
                truncate: {},
                sortable: true,
                format: "MM/DD/YYYY",
                class:'tableHeaderTextWrap'
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
    },
    initAnnualReviewReportTable: function(component, event, helper){
        var tableColumns = [
            {
                label: "Name",
                name: "Name",
                type: "url",
                truncate: {},
                sortable: true,
                enableCellClickEvt: true,
                class:'tableHeaderTextWrap'
            },
            {
                label: "Review Period",
                name: "reviewPeriod",
                type: "text",                
                class:'tableHeaderTextWrap'
            },
            {
                label: "Language Training Supervisor",
                name: "supervisorName",
                type: "text",
                truncate: {},
                sortable: true,
                class:'tableHeaderTextWrap'
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
    },
    showToast: function (component, event, title, message, type) {
        component.set("v.showSpinner", false);
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
            mode: "sticky"
        });
        toastEvent.fire();
    }
});