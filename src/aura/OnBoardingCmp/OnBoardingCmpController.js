({
    doInit : function(cmp, event, helper) {
        helper.getToDoItemsInfo(cmp,event,helper);
        helper.getDLIProjectInfo(cmp,event);
        helper.getAssessmentReports(cmp, event);
    },
    navigateTODO : function(cmp, event, helper) {
        var toDOId = event.currentTarget.name;
        var toDoItemsList = cmp.get("v.toDoItemsList");
        console.log('::toDOList::'+toDoItemsList);
        var selectedToDO = {};
        
        for(var i = 0; i < toDoItemsList.length; i++){
            if(toDoItemsList[i].Id == toDOId){
                selectedToDO = toDoItemsList[i];
            }
        }
        if(selectedToDO.hasOwnProperty('Id')){
            if(selectedToDO['todotype']) {  //Modified by Dhinesh - 09/08/2021 - selectedToDO['To_Do_Type__c']
                var toDoType = selectedToDO['todotype'];
                if(toDoType.includes('Confirm your Contact Information') || toDoType.includes('Review and complete your Profile')){
                    helper.updateToDoItemStatus(cmp, event, helper, toDOId);
                    helper.navigateMyProfilePage(cmp,event,helper);  
                }else if(toDoType.includes('Student Policies & Procedures')){
                    cmp.set("v.studentPolicyInfoModal",true);
                    cmp.find("studentPolicy").open();
                }else {
                    helper.updateToDoItemStatus(cmp, event, helper, toDOId);
                    //W-003068 - Watch Training Video To-do Items Link Update
                    if(toDoType.includes('Watch Timekeeping Approval Training Video')){
                        window.open('https://dlsdc.wistia.com/medias/kts88qlh4f', '_blank');
                    }else if(toDoType.includes('Watch Timekeeping Training Video')){
                        window.open('https://dlsdc.wistia.com/medias/hlcb5ks3lx', '_blank');
                    }else if(toDoType.includes('Check out the Student Language Studies Program')){
                        window.open('https://lms.dlsdc.com/course/view.php?id=288', '_blank');
                    }
                }
            }
        }
    },
    closeStudentPolicy : function(cmp, event, helper) {
        cmp.set("v.studentPolicyInfoModal",false);
    },
    navigateCompleteToDoItems : function(cmp, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/to-do-items"
        });
        urlEvent.fire();
    },
    redirectToAttendance : function(cmp, event, helper){
        var index = event.currentTarget.name;
        console.log(':::index:::',index);
        
        var dliSummary = cmp.get("v.dliSummaryDetail");
        
        var record = dliSummary[index];
        
        var proId = record.projectId;
        var insId = record.instructorId;
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/dli-attendance?projectId="+proId+"&instructorId="+insId
        });
        urlEvent.fire();
    },
    redirectToAssessmentReport : function(component, event){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/reports"
        });
        urlEvent.fire();
    }
})