({
    doInit: function (component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        
        if (device == "PHONE") {
            component.set("v.displayDevice", "Mobile");
        } else {
            component.set("v.displayDevice", "PC");
        }
        var urlStr = window.location.href.split("=");       
        if(urlStr.length > 1 && urlStr[1] == 'observation'){
            var selectedFilterValues = component.get("v.selectedFilterValues");
            selectedFilterValues.reportType = 'My Observation Report';
            component.set("v.selectedFilterValues", selectedFilterValues);
        }else if(urlStr.length > 1 && urlStr[1] == 'test'){
            var selectedFilterValues = component.get("v.selectedFilterValues");
            selectedFilterValues.reportType = 'Test Reports';
            component.set("v.selectedFilterValues", selectedFilterValues);
        }
        helper.getCommunityName(component, event, helper);    
    },
    
    tabActionClicked: function (component, event, helper) {
        var fieldApiName = event.getParam("fieldApiName");
        var row = event.getParam("row");
        var path;
        var selectedFilterValues = component.get("v.selectedFilterValues");
        let communityType = component.get("v.communityType");
        //console.log(JSON.stringify(row), fieldApiName,selectedFilterValues.reportType);        
        var showBoxFile = (row.typeOfReport != 'Student Progress Report' && row.typeOfReport != 'Student Self-Assessment' && row.typeOfReport != 'Assessment by Instructor' && row.typeOfReport != 'Test Report' && selectedFilterValues.reportType != 'Student Progress Reports' && selectedFilterValues.reportType != 'Test Reports') || (row.recordTypeDevName == 'DLI_W_Self_Assessment_Test_Report' && communityType == "instructor") || (row.recordTypeDevName != 'DLI_W_Self_Assessment_Test_Report' && communityType == "student");
        console.log(showBoxFile);
        if (fieldApiName == "Name") {            
            if((communityType == "student" && row.recordTypeDevName != 'DLI_W_Self_Assessment_Test_Report') || communityType == 'client' || showBoxFile){
                if(row.Status != 'Completed'){
                   var modal = {header:'Notice', message:'You will be able to view this Report once the Status is changed to Completed.'};
                    component.set('v.modal', modal);
                    component.find("msgModal").open(); 
                }else{
                    var boxUrl = row.boxURL.split("/s/"),
                        boxId = boxUrl.length > 1 ? boxUrl[1] : undefined;
                    
                    if(boxId){
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            url: "/file-preview?linkId=" + boxId
                        });
                        urlEvent.fire();                                         
                    }
                }                
            } else{                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": row.Id
                });
                navEvt.fire();
            }
        } else {
            
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                url: "/projectdetailview?recordId=" + row.ProjectId
            });
            urlEvent.fire();     
        }
    },
    closeModal : function(component, event, helper) {
        component.find("msgModal").close();        
    },
    handleFilterChange: function (component, event, helper) {
        helper.getAssesmentRecords(component, event, helper);
    }
});