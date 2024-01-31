({
    getFilterInitialInformation : function(cmp,event,helper) {
        var action = cmp.get("c.getInitialFilterValues");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                var result = JSON.parse(response.getReturnValue());
                var weekFilterLst = result.weekFilter;
                var weekDateArray = [];
                console.log(':::',result);
                cmp.set("v.topicId",result.timekeepingTopicId);
                cmp.set("v.stuURLRedirectParamsMap",{});
                
                for(var i = 0;i < weekFilterLst.length;i++) {
                    weekDateArray.push({'label':weekFilterLst[i],'value':weekFilterLst[i]});
                }  
                cmp.set("v.weekDateOptions",weekDateArray); 
                cmp.set("v.studentId",result.contactId);
                cmp.set("v.selectedWeek",weekFilterLst[weekFilterLst.length -1]);
                
                if(cmp.get("v.selectedWeek") != null){
                    this.getProFilterDetails(cmp,event,helper);  
                }
            }else {
                cmp.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  response.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    apexDateFormatFunction : function(dateval){
        return dateval.split('/')[2]+'-'+dateval.split('/')[0]+'-'+dateval.split('/')[1];
    },
    getProFilterDetails  :  function(cmp,event,helper){
        var fromUrl = cmp.get("v.fromCommunityUrlMap");
        if(fromUrl && fromUrl['week']){
            cmp.set("v.selectedWeek",fromUrl['week']);
        }
        var dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);

        cmp.set("v.showSpinner",true);
        cmp.set("v.studentRowEntries",[]);
        cmp.set("v.projectManagerName",null);
        cmp.set("v.projectInstructorName",null);
        
        var action =  cmp.get("c.getProjectFilterValues");
        action.setParams({
            "startDate" : dt1,
            "endDate" : dt2,
            "studentId" : cmp.get("v.studentId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = JSON.parse(response.getReturnValue());
                var proRelatedInstructorList = [];
                var proRelatedInstructorList = (Object.keys(result['instructorRelatedProjects']));
                cmp.set("v.projectRelatedFilter",result);
                cmp.set("v.showSpinner",false);
                cmp.set("v.projectFilter",[]);
                cmp.set("v.selectedProject",'');
                console.log('::result::',result);
                
                cmp.set("v.projectFilter",[{'label':'     --None--     ','value':''}]);
                if(proRelatedInstructorList.length > 0) {
                    for(var i = 0;i < proRelatedInstructorList.length;i++) {
                        cmp.get("v.projectFilter").push({'label':result.instructorRelatedProjects[proRelatedInstructorList[i]],'value':proRelatedInstructorList[i]});
                    }  
                    cmp.set("v.projectIdSupMap",result.proIdSupervisorName);
                }else{
                    cmp.set("v.weekDetailList",{});  
                }
                cmp.set("v.projectFilter", cmp.get("v.projectFilter"));  
                
                // launch logged user Student Time Approval page for corresponding Instructor if projectId,InstructorId,WeekRange information in Community Url
                if(fromUrl && fromUrl['proIdAndInsId']){
                    if(proRelatedInstructorList.includes(fromUrl['proIdAndInsId'])){
                        cmp.set("v.selectedProject",fromUrl['proIdAndInsId']);
                        this.onChangeprojectHelper(cmp);
                    }
                }else if(cmp.get("v.projectFilter").length == 2){
                    var selectedProject = cmp.get("v.projectFilter")[1].value;
                    cmp.set("v.selectedProject",selectedProject);
                    this.onChangeprojectHelper(cmp);
                }
                
            }else {
                cmp.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  response.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    },
    onChangeprojectHelper : function(cmp, event, helper) {
        var selectedProject = cmp.get("v.selectedProject");
        cmp.set("v.studentRowEntries",[]);
        
        if(selectedProject){
            var selectedprojectId =  cmp.get("v.selectedProject").split('-')[0];
            var instructorId =  cmp.get("v.selectedProject").split('-')[1];
            
            cmp.set("v.projectId",selectedprojectId);
            cmp.set("v.instructorId",instructorId);
            
            if(cmp.get("v.projectIdSupMap")[selectedprojectId]){
                cmp.set("v.projectManagerName",cmp.get("v.projectIdSupMap")[selectedprojectId])
            }       
            cmp.set("v.projectInstructorName", cmp.get("v.projectRelatedFilter")['instructorRelatedProjects'][selectedProject].split('/')[1]);
            this.getDayRowsFormation(cmp, event, helper)
        }else{
            cmp.set("v.weekDetailList",{});  
            cmp.set("v.projectManagerName",null);
            cmp.set("v.projectInstructorName",null);
        }
    },
    getDayRowsFormation : function(cmp,event,helper){
        
        var dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]); 
        var action =  cmp.get("c.getTimeCardDayDetails");
        cmp.set("v.showSpinner",true);
        
        action.setParams({
            "proId" : cmp.get("v.projectId"),
            "startDate" : dt1,
            "endDate" : dt2,
            "instructorId":cmp.get("v.instructorId"),
            "studentNamesWithDlsClassNo":(cmp.get("v.projectRelatedFilter")['projectRelatedStudentNames'][cmp.get("v.projectId")])
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var weekDetails = JSON.parse(response.getReturnValue());
                cmp.set("v.showSpinner",false);
                console.log(':::::::getDayRowsFormation:::',weekDetails);
                cmp.set("v.weekDetailList",weekDetails);
                cmp.set("v.projectRTName",weekDetails.projectName);
                var proRecType = ['DLI_W_LT_Projects','DODA_Projects','ESL_LT_Projects'];
				
                //W-006649 - Student Hours for Language Training Projects
                if(proRecType.includes(weekDetails.projectName)
                  || (weekDetails.projectName == 'Language_Training_Projects' && weekDetails.displayStudentHrstable)){
                    this.studentTimeEntriesForDODADLWPjt(cmp);
                }else{
                    cmp.set("v.isDisplaySaveBtn",false);
                }
            }else {
                cmp.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  response.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    studentTimeEntriesForDODADLWPjt : function(cmp){
        var startDt = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var endDt = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
        var action =  cmp.get("c.studentTimeEntriesRowFormation");
     
        action.setParams({
            'projectRTName':cmp.get("v.projectRTName"),
            'projectId': cmp.get("v.projectId"),
            'startDt':startDt,
            'endDt':endDt,
            'instructorId':cmp.get("v.instructorId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log(JSON.parse(response.getReturnValue()));
                cmp.set("v.isDisplaySaveBtn",false);
                var isDisplaySaveBtn = true;
                cmp.set("v.studentRowEntries",JSON.parse(response.getReturnValue()));
                cmp.set("v.studentTotalColHrs",[]);
                var studentRowEntries = cmp.get("v.studentRowEntries");
                if(studentRowEntries){
                    for(var i = 0;i < studentRowEntries.length;i++){
                        if(cmp.get("v.studentId") == studentRowEntries[i].studentId){
                            if(studentRowEntries[i].isDisplayApproveText){
                                isDisplaySaveBtn = false;
                            }
                        }
                    }
                    cmp.set("v.isDisplaySaveBtn",isDisplaySaveBtn);
                    this.calculateStudentTotalHrs(cmp);
                }
            }else {
                cmp.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  response.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
  calculateStudentTotalHrs : function(cmp){
        var totalHrsMap = {};
        totalHrsMap.mondayTotalHrs = 0.00;
        totalHrsMap.tuesdayTotalHrs = 0.00;
        totalHrsMap.wednesdayTotalHrs = 0.00;
        totalHrsMap.thursdayTotalHrs = 0.00;
        totalHrsMap.fridayTotalHrs = 0.00;
        totalHrsMap.saturdayTotalHrs = 0.00;
        totalHrsMap.sundayTotalHrs = 0.00;
        var overAllHrs = 0.00;
        
        var studentRows = cmp.get("v.studentRowEntries");
        
        for(var i = 0;i < studentRows.length;i++){
            var entry = studentRows[i].entries;
            var rowTotal = 0.00;
            
            for(var j = 0;j < entry.length;j++){
                if(entry[j].hours){
                    
                    rowTotal += parseFloat(entry[j].hours);
                    
                    if(entry[j].dayValue == 'Monday'){
                        totalHrsMap.mondayTotalHrs += parseFloat(entry[j].hours);
                    }else if(entry[j].dayValue == 'Tuesday'){
                        totalHrsMap.tuesdayTotalHrs += parseFloat(entry[j].hours);
                    }else if(entry[j].dayValue == 'Wednesday'){
                        totalHrsMap.wednesdayTotalHrs += parseFloat(entry[j].hours);
                    }else if(entry[j].dayValue == 'Thursday'){
                        totalHrsMap.thursdayTotalHrs += parseFloat(entry[j].hours);
                    }else if(entry[j].dayValue == 'Friday'){
                        totalHrsMap.fridayTotalHrs += parseFloat(entry[j].hours);
                    }else if(entry[j].dayValue == 'Saturday'){
                        totalHrsMap.saturdayTotalHrs += parseFloat(entry[j].hours);
                    }else if(entry[j].dayValue == 'Sunday'){
                        totalHrsMap.sundayTotalHrs += parseFloat(entry[j].hours);
                    }
                }
            }
            
            studentRows[i].totalHours = ((rowTotal * 100) / 100).toFixed(2).toString();
            
            overAllHrs += rowTotal;
        }
        
        if(totalHrsMap.mondayTotalHrs.toString().indexOf('.') == -1){
            totalHrsMap.mondayTotalHrs = totalHrsMap.mondayTotalHrs+'.00';
        }
        if(totalHrsMap.tuesdayTotalHrs.toString().indexOf('.') == -1){
            totalHrsMap.tuesdayTotalHrs = totalHrsMap.tuesdayTotalHrs+'.00';
        }
        if(totalHrsMap.wednesdayTotalHrs.toString().indexOf('.') == -1){
            totalHrsMap.wednesdayTotalHrs = totalHrsMap.wednesdayTotalHrs+'.00';
        }
        if(totalHrsMap.thursdayTotalHrs.toString().indexOf('.') == -1){
            totalHrsMap.thursdayTotalHrs = totalHrsMap.thursdayTotalHrs+'.00';
        }
        if(totalHrsMap.fridayTotalHrs.toString().indexOf('.') == -1){
            totalHrsMap.fridayTotalHrs = totalHrsMap.fridayTotalHrs+'.00';
        }
        if(totalHrsMap.saturdayTotalHrs.toString().indexOf('.') == -1){
            totalHrsMap.saturdayTotalHrs = totalHrsMap.saturdayTotalHrs+'.00';
        }
        if(totalHrsMap.sundayTotalHrs.toString().indexOf('.') == -1){
            totalHrsMap.sundayTotalHrs = totalHrsMap.sundayTotalHrs+'.00';
        }
        
        overAllHrs =  ((overAllHrs * 100) / 100).toFixed(2);
        
      overAllHrs =  ((overAllHrs * 100) / 100).toFixed(2);
      cmp.set("v.studentOverAllSum",overAllHrs);
      
      cmp.set("v.studentColTHMap",totalHrsMap);
    },
    saveDayEntryAndAttendanceRecords : function(cmp, event, helper){
        var weekDetailList = cmp.get("v.weekDetailList");
        var studentRowEntries = cmp.get("v.studentRowEntries");
        var isValid = true;
        
        for(var i = 0;i < weekDetailList.entries.length;i++){
            for(var j = 0;j < weekDetailList.entries[i].dayEntries.length;j++){
                if(weekDetailList.entries[i].dayEntries[j].studentApprovalStatus == "Submitted"){
                    isValid = false;
                }
            }
        }
        if(studentRowEntries.length > 0){
            for(var i = 0;i < studentRowEntries.length;i++){
                for(var j = 0;j < studentRowEntries[i].entries.length;j++){
                    if(studentRowEntries[i].entries[j].studentApprovalStatus == "Submitted" && weekDetailList.studentId == studentRowEntries[i].entries[j].studentId){
                        isValid = false;
                    }
                }
            }
        }
        
        if(cmp.get("v.updateDayEntriesRecords").length == 0 && cmp.get("v.updateStuAttendanceRecords").length == 0){
            
            if(isValid){
                cmp.set("v.stuApprovalValMessage",'All time entries have already been approved or rejected for this week for this project');
            }else{
                cmp.set("v.stuApprovalValMessage",'Please update any of time entry to save the changes');
            }
            cmp.set("v.showStuApprovalValModal",true);
            cmp.find("stuApprovalValModal").openModal();
            
        }else if((cmp.get("v.updateDayEntriesRecords").length > 0 || cmp.get("v.updateStuAttendanceRecords").length > 0)){
            
            if(!isValid && cmp.get('v.weekDetailList').isStudentLeader && cmp.get("v.updateDayEntriesRecords").length != cmp.get("v.updateStuAttendanceRecords").length){
                cmp.set("v.stuApprovalValMessage",'You are also required to approve the "Attendance" entries provided by your instructor. Approve each entry then click Save.');
                cmp.set("v.showStuApprovalValModal",true);
            	cmp.find("stuApprovalValModal").openModal();                
            }else{
                cmp.set("v.showSpinner",true);
                var action =  cmp.get("c.updateDayAndAttendanceEntryRecord");
                action.setParams({
                    'tCDRecords':JSON.stringify(cmp.get("v.updateDayEntriesRecords")),
                    'projectRTName':cmp.get("v.projectRTName"),
                    'stuAttendanceRecords':JSON.stringify(cmp.get("v.updateStuAttendanceRecords"))
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        console.log(':::::::Result:::',response.getReturnValue());
                        cmp.set("v.updateDayEntriesRecords",[]);
                        cmp.set("v.updateStuAttendanceRecords",[]);
                        cmp.set("v.showSpinner",false);
                        cmp.set("v.saveSuccessModel",true);
                        cmp.find("successModal").openModal();
                    }else {
                        cmp.set("v.showSpinner",false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message :  response.getError()[0].message,
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }    });
                $A.enqueueAction(action);
            }
        }
    },
    openFilterChangeConfirmationModal: function(cmp){
        cmp.set("v.filterChangeConfirmationModal",true);
        if(Array.isArray(cmp.find("filterConfirmModal"))) {
            cmp.find("filterConfirmModal")[0].open();
        }else{
            cmp.find("filterConfirmModal").open();
        }
    },
    closeFilterChangeConfirmationModal: function(cmp){
        if(Array.isArray(cmp.find("filterConfirmModal"))) {
            cmp.find("filterConfirmModal")[0].close();
        }else{
            cmp.find("filterConfirmModal").close();
        }
        cmp.set("v.filterChangeConfirmationModal",false);
    }
})