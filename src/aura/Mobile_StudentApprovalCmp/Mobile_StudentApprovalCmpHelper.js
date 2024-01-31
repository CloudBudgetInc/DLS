({
    getFilterInitialInformation : function(cmp,event,helper) {
        cmp.set("v.showSpinner",true);
        var action = cmp.get("c.getInitialFilterValues");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                var result = JSON.parse(response.getReturnValue());
                var weekFilterLst = result.weekFilter;
                var weekDateArray = [];
                
                for(var i = 0;i < weekFilterLst.length;i++) {
                    weekDateArray.push({'label':weekFilterLst[i],'value':weekFilterLst[i]});
                }  
                cmp.set("v.weekDateFilters",weekDateArray); 
                cmp.set("v.topicId",result.timekeepingTopicId);
                cmp.set("v.studentId",result.contactId);
                cmp.set("v.selectedWeek",weekFilterLst[weekFilterLst.length -1]);
                
                if(cmp.get("v.selectedWeek")){
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
    getProFilterDetails  :  function(cmp, event, helper){
        
        var fromUrl = cmp.get("v.fromCommunityUrlMap");
        if(fromUrl && fromUrl['week']){
            cmp.set("v.selectedWeek",fromUrl['week']);
        }
        var dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
        var action =  cmp.get("c.getProjectFilterValues");
        
        cmp.set("v.showSpinner",true);
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
                }
                cmp.set("v.projectFilter", cmp.get("v.projectFilter"));  
                
                // launch logged user Student Time Approval page for corresponding Instructor if projectId,InstructorId,WeekRange information in Community Url
                if(fromUrl && fromUrl['proIdAndInsId']){
                    if(proRelatedInstructorList.includes(fromUrl['proIdAndInsId'])){
                        cmp.set("v.selectedProject",fromUrl['proIdAndInsId']);
                        this.onChangeprojectHelper(cmp);
                    }
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
    // get Time Card Day Records
    getDayRowsFormation : function(cmp){
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
                cmp.set("v.weekDetailInfo",weekDetails);
                cmp.set("v.weekDateRange",weekDetails.weekDates);
                cmp.set("v.projectRTName",weekDetails.projectName);
                cmp.set("v.studentColTHMap",{});
                var proRecType = ['DLI_W_LT_Projects','DODA_Projects','ESL_LT_Projects','Language_Training_Projects'];

                if(proRecType.includes(weekDetails.projectName)){
                    this.studentTimeEntriesForDODADLWPjt(cmp);
                }else {
                    this.getColorCodeForWeeklyView(cmp);
                    this.weeklyViewRowInfo(cmp);
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
    // get Student Attendence Records
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
                var studentRowEntries = JSON.parse(response.getReturnValue());
                cmp.set("v.studentRowEntries",studentRowEntries);
                var isDisplaySaveBtn = true;
                if(studentRowEntries){
                    for(var i = 0;i < studentRowEntries.length;i++){
                        if(cmp.get("v.studentId") == studentRowEntries[i].studentId){
                            if(studentRowEntries[i].isDisplayApproveText){
                                isDisplaySaveBtn = false;
                            }
                        }
                    }
                }
                cmp.set("v.isDisplaySaveBtn",isDisplaySaveBtn)
                this.calculateStudentTotalHrs(cmp);
                this.getColorCodeForWeeklyView(cmp);
                this.weeklyViewRowInfo(cmp);
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
    //weeklyViewRowInfo formation
    weeklyViewRowInfo : function(cmp){
        var  weeklyViewRows = [];
        var weeklyViewRowsInfo = cmp.get("v.weeklyViewRowsInfo");
        var instructorColTotalEntries = cmp.get("v.weekDetailInfo")['TotalHrsDayColEntries']|| {}
        var studentColTotalEntries =  cmp.get("v.studentColTHMap");
        var weekDateRange = cmp.get("v.weekDateRange");
        var instructorDayRows = [];
        var weeklyViewColorCode = cmp.get("v.weeklyViewColorCodeMap");
        var dateSpiltArray = [];
        var displayDate = '';
        
        if(weekDateRange.length > 0){
            for(var i = 0;i < weekDateRange.length;i++){
                
                if(weekDateRange[i].dateValue){
                    dateSpiltArray = weekDateRange[i].dateValue.split('/');
                    displayDate = dateSpiltArray[0] + '/'+dateSpiltArray[1]+'/' + dateSpiltArray[2].substring((dateSpiltArray[2].length-2), dateSpiltArray[2].length);
                }
                
                if(weekDateRange[i].dayVal == 'MON'){
                    weeklyViewRows.push({
                        'displayDate': displayDate,
                        'date': weekDateRange[i].dateValue,
                        'day': weekDateRange[i].dayVal ,
                        'studentHrs' : ((studentColTotalEntries && studentColTotalEntries['Monday']) ? (studentColTotalEntries['Monday']).toFixed(2) : '0.00' ), 
                        'instructorHrs' : ((instructorColTotalEntries && instructorColTotalEntries['monHrs']) ? instructorColTotalEntries['monHrs'] : '0.00'),
                        'studentColorCode': ((weeklyViewColorCode && weeklyViewColorCode['studentColorCode'] && weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue] :''),
                        'instructorColorCode' : ((weeklyViewColorCode && weeklyViewColorCode['instructorColorCode'] && weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue] :'')
                    });
                }else if(weekDateRange[i].dayVal == 'TUE'){
                    weeklyViewRows.push({
                        'displayDate': displayDate,
                        'date': weekDateRange[i].dateValue,
                        'day': weekDateRange[i].dayVal ,
                        'studentHrs': ((studentColTotalEntries && studentColTotalEntries['Tuesday']) ? (studentColTotalEntries['Tuesday']).toFixed(2) : '0.00' ),
                        'instructorHrs': ((instructorColTotalEntries && instructorColTotalEntries['tueHrs']) ? instructorColTotalEntries['tueHrs'] : '0.00'),
                        'studentColorCode': ((weeklyViewColorCode && weeklyViewColorCode['studentColorCode'] && weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue] :''),
                        'instructorColorCode' : ((weeklyViewColorCode && weeklyViewColorCode['instructorColorCode'] && weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue] :'')
                    });
                }else if(weekDateRange[i].dayVal == 'WED'){
                    weeklyViewRows.push({
                        'displayDate': displayDate,
                        'date': weekDateRange[i].dateValue,
                        'day': weekDateRange[i].dayVal ,
                        'studentHrs': ((studentColTotalEntries && studentColTotalEntries['Wednesday']) ? (studentColTotalEntries['Wednesday']).toFixed(2) : '0.00' ), 
                        'instructorHrs': ((instructorColTotalEntries && instructorColTotalEntries['wedHrs']) ? instructorColTotalEntries['wedHrs'] : '0.00'),
                        'studentColorCode': ((weeklyViewColorCode && weeklyViewColorCode['studentColorCode'] && weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue] :''),
                        'instructorColorCode' : ((weeklyViewColorCode && weeklyViewColorCode['instructorColorCode'] && weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue] :'')
                    });
                }else if(weekDateRange[i].dayVal == 'THU'){
                    weeklyViewRows.push({
                        'displayDate': displayDate,
                        'date': weekDateRange[i].dateValue,
                        'day': weekDateRange[i].dayVal ,
                        'studentHrs': ((studentColTotalEntries && studentColTotalEntries['Thursday']) ? (studentColTotalEntries['Thursday']).toFixed(2) : '0.00' ), 
                        'instructorHrs': ((instructorColTotalEntries && instructorColTotalEntries['thuHrs']) ? instructorColTotalEntries['thuHrs'] : '0.00'),
                        'studentColorCode': ((weeklyViewColorCode && weeklyViewColorCode['studentColorCode'] && weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue] :''),
                        'instructorColorCode' : ((weeklyViewColorCode && weeklyViewColorCode['instructorColorCode'] && weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue] :'')
                    });
                }else if(weekDateRange[i].dayVal == 'FRI'){
                    weeklyViewRows.push({
                        'displayDate': displayDate,
                        'date': weekDateRange[i].dateValue,
                        'day': weekDateRange[i].dayVal ,
                        'studentHrs': ((studentColTotalEntries && studentColTotalEntries['Friday']) ? (studentColTotalEntries['Friday']).toFixed(2) : '0.00' ),
                        'instructorHrs': ((instructorColTotalEntries && instructorColTotalEntries['friHrs']) ? instructorColTotalEntries['friHrs'] : '0.00'),
                        'studentColorCode': ((weeklyViewColorCode && weeklyViewColorCode['studentColorCode'] && weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue] :''),
                        'instructorColorCode' : ((weeklyViewColorCode && weeklyViewColorCode['instructorColorCode'] && weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue] :'')
                    });
                }else if(weekDateRange[i].dayVal == 'SAT'){
                       
                    weeklyViewRows.push({
                        'displayDate': displayDate,
                        'date': weekDateRange[i].dateValue,
                        'day': weekDateRange[i].dayVal ,
                        'studentHrs': ((studentColTotalEntries && studentColTotalEntries['Saturday']) ? (studentColTotalEntries['Saturday']).toFixed(2) : '0.00' ),
                        'instructorHrs': ((instructorColTotalEntries && instructorColTotalEntries['satHrs']) ? instructorColTotalEntries['satHrs'] : '0.00'),
                        'studentColorCode': ((weeklyViewColorCode && weeklyViewColorCode['studentColorCode'] && weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue] :''),
                        'instructorColorCode' : ((weeklyViewColorCode && weeklyViewColorCode['instructorColorCode'] && weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue] :'')
                    });
                }else if(weekDateRange[i].dayVal == 'SUN'){
                    weeklyViewRows.push({
                        'displayDate': displayDate,
                        'date': weekDateRange[i].dateValue,
                        'day': weekDateRange[i].dayVal ,
                        'studentHrs': ((studentColTotalEntries && studentColTotalEntries['Sunday']) ? (studentColTotalEntries['Sunday']).toFixed(2) : '0.00' ),
                        'instructorHrs': ((instructorColTotalEntries && instructorColTotalEntries['sunHrs']) ? instructorColTotalEntries['sunHrs'] : '0.00'),
                        'studentColorCode': ((weeklyViewColorCode && weeklyViewColorCode['studentColorCode'] && weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['studentColorCode'][weekDateRange[i].dateValue] :''),
                        'instructorColorCode' : ((weeklyViewColorCode && weeklyViewColorCode['instructorColorCode'] && weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue]) ? weeklyViewColorCode['instructorColorCode'][weekDateRange[i].dateValue] :'')
                    });
                }
            }
            
            var studentRowEntries = cmp.get("v.studentRowEntries");
            var summaryDetails = cmp.get("v.studentSummaryDetails");
            
            if(studentRowEntries.length == 0){
                weeklyViewRowsInfo.showStuHrs = false;    
            }

            weeklyViewRowsInfo.weeklyViewRow = weeklyViewRows;
            cmp.set("v.weeklyViewRowsInfo",weeklyViewRowsInfo);
            
            summaryDetails.isHomeView = true;
            summaryDetails.isBackFromDailyView = false;       
            summaryDetails.isDailyView = false;
            cmp.set("v.studentSummaryDetails",summaryDetails);
        }
    },
    calculateStudentTotalHrs : function(cmp){
        var totalHrsMap = {};
        var overAllHrs = 0.00;
        
        var studentRows = cmp.get("v.studentRowEntries");
        
        for(var i = 0;i < studentRows.length;i++){
            var entry = studentRows[i].entries;
            var rowTotal = 0.00;
            
            for(var j = 0;j < entry.length;j++){
                if(!totalHrsMap[entry[j].dayValue]){
                    totalHrsMap[entry[j].dayValue] = 0.00;
                }
                if(entry[j].hours && (cmp.get("v.studentId") == entry[j].studentId)){
                    rowTotal += parseFloat(entry[j].hours);
                    totalHrsMap[entry[j].dayValue] += parseFloat(entry[j].hours);
                }else {
                    totalHrsMap[entry[j].dayValue] += 0.00;
                }
                
            }
            studentRows[i].totalHours = ((rowTotal * 100) / 100).toFixed(2).toString();
            overAllHrs += rowTotal;
        }
        
        overAllHrs =  ((overAllHrs * 100) / 100).toFixed(2);
        cmp.set("v.studentOverAllSum",overAllHrs);
        cmp.set("v.studentColTHMap",totalHrsMap);
    },
    onChangeprojectHelper : function(cmp){
        var selectedProject = cmp.get("v.selectedProject");
        var projectRelatedFilter = cmp.get("v.projectRelatedFilter");
        var weeklyViewRowsInfo = cmp.get("v.weeklyViewRowsInfo");
        
        weeklyViewRowsInfo.weeklyViewRow = [];
        weeklyViewRowsInfo.showStuHrs = true;
        
        cmp.set("v.weeklyViewRowsInfo",weeklyViewRowsInfo);
        cmp.set("v.studentRowEntries",[]);
        cmp.set("v.studentOverAllSum","0.00")
        
        if(selectedProject){
            var selectedprojectId =  cmp.get("v.selectedProject").split('-')[0];
            var instructorId =  cmp.get("v.selectedProject").split('-')[1];
            
            if(projectRelatedFilter && projectRelatedFilter['instructorRelatedProjects'] && projectRelatedFilter['instructorRelatedProjects'][selectedProject]) {
                cmp.set("v.projectInstructorName", projectRelatedFilter['instructorRelatedProjects'][selectedProject].split('/')[1]);
            }
            cmp.set("v.projectId",selectedprojectId);
            cmp.set("v.instructorId",instructorId);
            this.getDayRowsFormation(cmp);
        }else{
            cmp.set("v.projectId",'');
            cmp.set("v.instructorId",'');
            cmp.set("v.projectInstructorName",'');
            cmp.set("v.weekDetailInfo",{});
        }
    },
    getColorCodeForWeeklyView : function(cmp){
        var weekDetailInfo = cmp.get("v.weekDetailInfo");
        var studentSummaryDetails = cmp.get("v.studentSummaryDetails");
        var studentRows = cmp.get("v.studentRowEntries");
        
        var weeklyViewColorCodeMap = {};
        var instructorColorCode = {};
        var studentColorCode = {};
        
        //get Instructor Color code
        if(weekDetailInfo && weekDetailInfo.entries){
            for(var i = 0;i < weekDetailInfo.entries.length;i++){
                if(weekDetailInfo.entries[i].dayEntries){
                    for(var j = 0;j < weekDetailInfo.entries[i].dayEntries.length;j++){
                        if(weekDetailInfo.entries[i].dayEntries[j].studentApprovalStatus == 'Approved'){
                            instructorColorCode[weekDetailInfo.entries[i].dayEntries[j].displayDate] = '#ABD25A';
                        }
                        else if(weekDetailInfo.entries[i].dayEntries[j].studentApprovalStatus == 'Rejected'){
                            instructorColorCode[weekDetailInfo.entries[i].dayEntries[j].displayDate] = '#FA8072';
                        }else{
                            instructorColorCode[weekDetailInfo.entries[i].dayEntries[j].displayDate]  = ''                    
                        }
                    }
                }
            }
        }
        
        //get Student Color code
        if(studentRows.length > 0){
            var studentId = cmp.get("v.studentId");
            for(var i = 0;i < studentRows.length;i++){
                var entry = studentRows[i].entries;
                
                if(studentId == studentRows[i].studentId){
                    for(var j = 0;j < entry.length;j++){
                        if(entry[j].studentApprovalStatus == 'Approved'){
                            studentColorCode[entry[j].displayDate] = '#ABD25A';
                        }else if(entry[j].studentApprovalStatus == 'Rejected'){
                            studentColorCode[entry[j].displayDate] = '#FA8072';
                        }else{
                            studentColorCode[entry[j].displayDate] = '';
                        }
                    }
                }
            }
        }
        weeklyViewColorCodeMap['studentColorCode'] = studentColorCode;
        weeklyViewColorCodeMap['instructorColorCode'] = instructorColorCode;
        cmp.set("v.weeklyViewColorCodeMap",weeklyViewColorCodeMap);
    }
})