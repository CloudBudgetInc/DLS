({
    doInit: function(component, event, helper) {
        
        var action = component.get("c.getTabRecs");
        action.setParams({
            recId: component.get("v.recordId"),
            sobjectName: component.get("v.sObjectName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result',result);
                var contactAssignRecs = [];
                
                if(result.wrapConAssignList && result.wrapConAssignList.length > 0){
                    for(var ca = 0; ca < result.wrapConAssignList.length; ca++) {
                        if(result.wrapConAssignList[ca].caRecs.Oral_Exam_Date_Time__c){
                            result.wrapConAssignList[ca].caRecs.Oral_Exam_Date_Time__c = result.wrapConAssignList[ca].oralExamDateTime;
                        };
                        contactAssignRecs.push(result.wrapConAssignList[ca].caRecs);
                    }
                }
                
                if(component.get("v.activeTab") == 'Instructor' && component.get("v.sObjectName") == 'AcctSeed__Project__c') {
                    component.set("v.contactAssignCRChildCountMap", result['cACostRAteChildCountMap']);
                    component.set("v.insIdWithTotalEventSumMap",result['insIdWithSumTotalEventMap']);
                }
                component.set("v.payRateModifyPermission",result.payRateModifyPermissionAccess);
                component.set("v.tabNames", result.wrapTabNames);
                component.set("v.activeTab", result.wrapActiveTab);
                component.set("v.contactAssignRecs",contactAssignRecs);
                component.set("v.parentRecordType",result.parentRecordType);
                component.set("v.defaultCostRate",result.defaultCostRate);
                
                if(result.parentRecordType == 'Admin_Projects' || component.get("v.sObjectName") == 'Contract'){
                    component.set("v.recordtypeName",'Staff');
                }
                component.set("v.opportunitylineItems", result.opliMap);
                helper.RateCardRateOPPt(component,event,helper); 
                component.set("v.statusPickList", result.wrapStatuspickList);
                component.set("v.isDisplayAction", result.wrapIsDisplayAction);
                component.set("v.projectRecId", result.wrapProjectId);

                helper.assignTable(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    activeTaChange: function(component, event, helper) {
        
        var action = component.get("c.getContactAssignRecs");
        component.set("v.displayTable", false);
        component.set("v.showSpinner", true);

        var recordtypeName = '';
        var selectedTab = component.get("v.activeTab");
        if(selectedTab == 'Student' ){
            recordtypeName = 'Student';
        }else if(selectedTab == 'Staff' || selectedTab =='Supervisor/LTS' || selectedTab == 'Overhead' || selectedTab =='DLS Staff'){
            recordtypeName = 'Staff';
        }else if(selectedTab == 'Instructor' || selectedTab =='Direct Labor'){
            recordtypeName = 'Instructor';
        }else if(selectedTab == 'Consultant'){
            recordtypeName = 'Consultant';
        }else if(selectedTab == 'Client/Partner'){
            recordtypeName = 'Client_Partner';
        }
        component.set("v.recordtypeName",recordtypeName);
        
        action.setParams({
            recordtypeName : recordtypeName,
            parentId: component.get("v.recordId"),
            objectName: component.get("v.sObjectName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(selectedTab == 'Instructor') {
                component.set("v.contactAssignCRChildCountMap", result['cACostRAteChildCountMap']);
            }

            if (state === "SUCCESS") {
                var contactAssignRecs = [];

                if(result.wrapConAssignList && result.wrapConAssignList.length > 0){
                    for(var ca = 0; ca < result.wrapConAssignList.length; ca++) {
                        if(result.wrapConAssignList[ca].caRecs.Oral_Exam_Date_Time__c){
                            result.wrapConAssignList[ca].caRecs.Oral_Exam_Date_Time__c = result.wrapConAssignList[ca].oralExamDateTime;
                        };
                        contactAssignRecs.push(result.wrapConAssignList[ca].caRecs);
                    }
                }
                if(component.get("v.parentRecordType") == 'DLI_W_TO_Opportunities'){
                    component.set("v.statusPickList",  result.wrapStatuspickList);
                }
                component.set("v.contactAssignRecs",contactAssignRecs);
                component.set("v.opportunitylineItems", result.opliMap);
                helper.RateCardRateOPPt(component,event,helper);    
                helper.assignTable(component, event);
            }
        });
        $A.enqueueAction(action);
    }
    
})