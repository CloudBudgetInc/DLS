/**********************************************************************
    Created by Sukanya on Apr 4 2019: Translator class used for Time card Day object Community related wrapper class formation
***********************************************************************/
public class TimeCardDayCommunityTranslator {
    
    /*****************************************************************************
    - Created by NS on MAR 4 2019
    - For Instructor Time Entry Initial filter Wrapper class formation
    *****************************************************************************/
    public static TimeCardDayCommunityDomain.InitialFilterValues instructor_initialFilterFormation(List<Contact> contact,List<String> weekList,List<String> timeList,List<Topic> topicRecords){
        
        TimeCardDayCommunityDomain.InitialFilterValues initialFilter = new TimeCardDayCommunityDomain.InitialFilterValues();
        initialFilter.weekFilter = weekList;
        
        //W-006759 - To display future 2 weeks for UAE instructors to enter fringe times
        
        if(weekList.size() > 0 && weekList.size() == 5){
            initialFilter.selectedWeek = weekList[weekList.size() - 1];
        }else if(weekList.size() > 0 && weekList.size() == 7){
            initialFilter.selectedWeek = weekList[weekList.size() - 3];
        }else {
            initialFilter.selectedWeek = '';
        }
        
        if(contact.size() > 0) {
            initialFilter.employeeName = contact[0].Name+' - '+contact[0].PC_EE_ID__c;
            initialFilter.contactId = contact[0].Id;
        }
        
        initialFilter.timeList = timeList;
        
        if(topicRecords.size() > 0){
            initialFilter.timekeepingTopicId = topicRecords[0].Id;
        }
        
        return initialFilter;
    }
    
    /********************************************************
    - Week based Project filter formation - For Instructor Time Entry
    *********************************************************/
    public static TimeCardDayCommunityDomain.ProjectFilterInfo projectRelatedFilters(List<AcctSeed__Project__c> projectsForFilter,List<AcctSeed__Project__c> supervisorProjectList,List<AcctSeed__Project__c>  InstructorProjectList,Map<Id,Boolean> projIdTimeCompleted,  Map<String, Boolean>  projectIdWithNoStudHrsVerificationMap){
        
        TimeCardDayCommunityDomain.ProjectFilterInfo proInfo = new TimeCardDayCommunityDomain.ProjectFilterInfo();
        proInfo.projectFilter = projectFilterFormation(projectsForFilter, projectIdWithNoStudHrsVerificationMap);
        Map<Id,String> proIdStuLeaderName = new Map<Id,String>();
        
        Map<Id,String> proIdSupervisorName = new Map<Id,String>();
        Map<Id,String> proIdInsPosition = new Map<Id,String>();
        String projectInstructerName = '';

        
        for(AcctSeed__Project__c pro : supervisorProjectList){
            if(pro.Contact_Assignments__r.size() > 0){
                for(Contact_Assignments__c ca : pro.Contact_Assignments__r){
                    if(!proIdSupervisorName.containsKey(pro.Id)){
                        proIdSupervisorName.put(pro.Id,ca.Candidate_Name__r.Name);
                    }
                }
            }
        }
        
        proInfo.proIdSupervisorName = proIdSupervisorName;
        
        if(InstructorProjectList.size() > 0){
            for(AcctSeed__Project__c pro : InstructorProjectList){
                String position = '';
                if(pro.Contact_Assignments__r.size() > 0){
                    for(Contact_Assignments__c ca : pro.Contact_Assignments__r){
                        position = ca.Assignment_Position__c;
                    }
                    if(!proIdInsPosition.containsKey(pro.Id)){
                        proIdInsPosition.put(pro.Id,position);
                    }
                }
            }
        }
        proInfo.projectIdInsPosition = proIdInsPosition; 
        
        proInfo.projectIdTimeCompleted = projIdTimeCompleted;
        
        
        //Get Project related Class Leader Names
        for(AcctSeed__Project__c pro : projectsForFilter){
            
            String studentName = '';
            
            if(pro.Contact_Assignments__r.size() > 0 && pro.Contact_Assignments__r.size() == 1){
                studentName = pro.Contact_Assignments__r[0].Candidate_Name__r.FirstName+' '+pro.Contact_Assignments__r[0].Candidate_Name__r.LastName.subString(0,1)+'.';
             }else {
                if(pro.Contact_Assignments__r.size() > 0){
                    for(Contact_Assignments__c ca : pro.Contact_Assignments__r){
                        if(ca.Assignment_Position__c == 'Class Leader'){
                            studentName = ca.Candidate_Name__r.FirstName+' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.';
                        }
                    }
                }
            }
            
            if(!proIdStuLeaderName.containsKey(pro.Id)){
                proIdStuLeaderName.put(pro.Id,studentName);
            }
        }
        
        proInfo.proIdStuLeaderName = proIdStuLeaderName;
        
        return proInfo;
    }
    
    /****************************************************************************
    - Method to form Project Filter DLS Class # / Student Initial format
    - For Instructor Time Entry Page 
    - Created by NS on MAR 4 2019
    *****************************************************************************/
    public static List<TimeCardDayCommunityDomain.ProjectStudentInfo> projectFilterFormation(List<AcctSeed__Project__c> projectRecords, Map<String, Boolean>  projectIdWithNoStudHrsVerificationMap){
    
        List<TimeCardDayCommunityDomain.ProjectStudentInfo> projectFilter = new List<TimeCardDayCommunityDomain.ProjectStudentInfo>();
        
        for(AcctSeed__Project__c pro : projectRecords){
            
            TimeCardDayCommunityDomain.ProjectStudentInfo proStuInfo = new TimeCardDayCommunityDomain.ProjectStudentInfo();
            proStuInfo.projectId = pro.Id;
            proStuInfo.projectName = pro.DLS_Class__c+' / ';
            proStuInfo.projectRTName = pro.RecordType.DeveloperName;
            proStuInfo.projectRTId = pro.RecordTypeId;
            proStuInfo.noStudentApproval = pro.No_Student_Approval__c; 
            proStuInfo.noStudentHrsVerification = projectIdWithNoStudHrsVerificationMap.containsKey(pro.Id) ? (pro.No_Student_Hours_Verification__c || projectIdWithNoStudHrsVerificationMap.get(pro.Id)) : pro.No_Student_Hours_Verification__c;
            
            String studentNames = '';
            
            if(pro.RecordType.DeveloperName != 'CD_Projects'){
                if(pro.Contact_Assignments__r.size() > 0) {
                    for(Contact_Assignments__c ca : pro.Contact_Assignments__r){
                        if(String.isNotBlank(studentNames)){
                            studentNames += '; '+ca.Candidate_Name__r.FirstName+' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.';
                        }else {
                            studentNames = ca.Candidate_Name__r.FirstName+' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.';
                        }
                    }
                }
                proStuInfo.projectName += studentNames;
            }else {
                proStuInfo.projectName += pro.Name;
            }
            
            
            projectFilter.add(proStuInfo);
            
        }
        
        system.debug(':::::::::projectFilter:::::'+projectFilter);
        
        return projectFilter;
    }
    
    /******************************************************************************************
    - Method to form the existing TCD information as wrapper to display in cmp
    - Added by NS on MAR 5 2019 for Instructor Time Entry
    ******************************************************************************************/
    public static TimeCardDayCommunityDomain.InstructorRowDetails instructorTimeEntryRowWrapperFormation(Date startDate,Date endDate,String projectName,String studentNames,String contactId,List<AcctSeed__Time_Card_Line__c> lineDetails,List<Accounting_Seed_Time_Snapshot__c> snapshot,List<AcctSeed__Project_Task__c> taskRecords,List<Contact_Assignments__c> caRecord,Map<Id,Integer> taskIdTimeCount,Map<Id,String> taskIdTimeMap,List<Contact_Assignments__History> caHistory,List<AcctSeed__Cost_Rates__c> oldCRRecord,List<Contact_Assignments__c> studentCAs,Map<Id,List<Attendance__c>> stuAttendanceMap,Boolean alreadyCaseSubmitted,List<Planned_Days_Off__c> daysOffList,Set<Date> holidayDates,Map<Id,String> taskIdTimezone){
   
        TimeCardDayCommunityDomain.InstructorRowDetails weekDetails = new TimeCardDayCommunityDomain.InstructorRowDetails();
        weekDetails.federalHolidays = HolidayService.getHolidaysWithRecurrence(startDate,endDate);
        weekDetails.entries = instructorDayRowFormation(startDate,endDate,projectName,studentNames,lineDetails,taskRecords,caRecord,taskIdTimeCount,taskIdTimeMap,caHistory,oldCRRecord,taskIdTimezone,weekDetails.federalHolidays);
        weekDetails.notes = notesFormation(snapshot);
        weekDetails.defaultCostRateRateType = taskRecords.size() > 0 ? taskRecords[0].AcctSeed__Project__r.Default_Cost_Rate_Rate_Type__c : '';
        /*for(TimeCardDayCommunityDomain.NotesDetails note : weekDetails.notes){
            note.editedDT = note.Edited.format('mm/dd/yyyy h:mm:ss a');
        }*/
        
        Date st = startDate;
        Date ed = endDate;
        
        List<TimeCardDayCommunityDomain.WeekRangeValues> weekDates = new List<TimeCardDayCommunityDomain.WeekRangeValues>();
        
        while(st <= ed){
            TimeCardDayCommunityDomain.WeekRangeValues wkVal = new TimeCardDayCommunityDomain.WeekRangeValues();
            wkVal.dateValue = String.valueOf(st).split('-')[1]+'/'+String.valueOf(st).split('-')[2]+'/'+String.valueOf(st).split('-')[0];
            DateTime todayVal = DateTime.newInstance(st, Time.newInstance(0, 0, 0, 0));
            wkVal.dayVal = todayVal.format('EEE').toUppercase();
            
            weekDates.add(wkVal);
            
            st = st.addDays(1);
        }
        
        weekDetails.weekDates = weekDates;
        
        List<TimeCardDayCommunityDomain.DayEntries> entriesList = new List<TimeCardDayCommunityDomain.DayEntries>();
        for(TimeCardDayCommunityDomain.InstructorDayDetails row : weekDetails.entries){
            if(row.dayEntries != null && row.dayEntries.size() > 0) {
                entriesList.addAll(row.dayEntries);
            }
        }

        //Btns display logic
        TimeCardDayCommunityDomain.ButtonDisplay btnDisplay = buttonDisplayFunction(entriesList,startDate,endDate);
        
        system.debug(':::::::btnDisplay::::'+btnDisplay);
        
        weekDetails.displaySubmitBtn = btnDisplay.submitBtn;
        weekDetails.displayRecallBtn = btnDisplay.recallBtn;
        weekDetails.displayRequestEditLink = btnDisplay.displayRequestEditLink;
        weekDetails.alreadyCaseSubmitted = alreadyCaseSubmitted;
        weekDetails.displayCompleteBtn = btnDisplay.completeBtn;
        
        //Disable all the input field if the timesheet is submitted
        for(TimeCardDayCommunityDomain.InstructorDayDetails row : weekDetails.entries){
            if(row.dayEntries != null && row.dayEntries.size() > 0) {
                for(TimeCardDayCommunityDomain.DayEntries day : row.dayEntries){
                    if(btnDisplay.recallBtn && !day.isHrsDisabled){
                        day.isHrsDisabled = true;
                    }
                    
                    //to show edit icon for approved entries if there is a rejected entry exist
                    //W-004248
                    if(btnDisplay.showEditIconForApproved && !day.showEditIcon && !day.showReverseIcon 
                        && day.dayId != null){
                        
                        if(day.taskType != 'Preparation time' && day.status == 'Approved' || day.studentApprovalStatus == 'Approved') {
                            day.showReverseIcon = true;
                        }else {
                            day.showEditIcon = true;
                        }
                        
                    }
                }
            }
        }
        
        //Check approved CR is Exist in the CA or not
        if(caRecord.size() > 0 && caRecord[0].Rate_Card_Rate__c != null){
            weekDetails.validCRExistINCA = true;
        }else if(caRecord.size() > 0 && caRecord[0].Rate_Card_Rate__c == null){
            weekDetails.validCRExistINCA = false;
        }
        
        Boolean diableWholeStudentTime = false;
        if(btnDisplay.displayRequestEditLink || btnDisplay.recallBtn){
            diableWholeStudentTime = true;
        }
        system.debug('::::::::::diableWholeStudentTime::::'+diableWholeStudentTime);
        system.debug('::::::::btnDisplay::::'+btnDisplay);
        
        //Student time entry content formation
        weekDetails.studentEntries = studentTimeEntriesFormation(studentCAs,startDate,endDate,stuAttendanceMap,diableWholeStudentTime,btnDisplay.showEditIconForApproved);       
        
        if(daysOffList.size() > 0){
            
            Map<Date,TimeCardDayCommunityDomain.PlannedDaysOff> dateDaysOffValues = new Map<Date,TimeCardDayCommunityDomain.PlannedDaysOff>();
            
            for(Planned_Days_Off__c off : daysOffList){
                TimeCardDayCommunityDomain.PlannedDaysOff daysOff = new TimeCardDayCommunityDomain.PlannedDaysOff();
                daysOff.daysOffId = off.Id;
                daysOff.daysOffDate = String.valueOf(off.Date__c).split('-')[1]+'/'+String.valueOf(off.Date__c).split('-')[2]+'/'+String.valueOf(off.Date__c).split('-')[0];
                daysOff.contactName = off.Contact__r.Name;
                daysOff.description = off.Description__c;
                
                if(!dateDaysOffValues.containsKey(off.Date__c)){
                    dateDaysOffValues.put(off.Date__c,daysOff);
                }
            }
            
            weekDetails.dateDaysOffValues = dateDaysOffValues;
            
        }
        weekDetails.dliWLTHolidays = new List<Date>();
        weekDetails.dliWLTHolidays.addAll(holidayDates);
        
        
        return weekDetails;
        
    }
    
    /***************************************************************************************
     - Instructor Time Entry Day rows formation 
    ****************************************************************************************/
    public static List<TimeCardDayCommunityDomain.InstructorDayDetails> instructorDayRowFormation(Date st,Date ed,String projectName,String studentNames,List<AcctSeed__Time_Card_Line__c> timeCardLines,List<AcctSeed__Project_Task__c> taskRecords,List<Contact_Assignments__c> caRecord,Map<Id,Integer> taskIdTimeCount,Map<Id,String> taskIdTimeMap,List<Contact_Assignments__History> caHistory,List<AcctSeed__Cost_Rates__c> oldCRRecord,Map<Id,String> taskIdTimezone, Set<Date> federalHolidays){
        
        Map<String,Map<Date,TimeCardDayCommunityDomain.DayEntries>> chargeCodedateEntryMap = new Map<String,Map<Date,TimeCardDayCommunityDomain.DayEntries>>();
        List<TimeCardDayCommunityDomain.InstructorDayDetails> dayDetailsList = new List<TimeCardDayCommunityDomain.InstructorDayDetails>();
        
        Map<Date,TimeCardDayCommunityDomain.DayEntries> dateEntryMap = new Map<Date,TimeCardDayCommunityDomain.DayEntries>();
        
        Map<Id,Boolean> taskIdLineCompleted = new Map<Id,Boolean>();
        
        Date startDt = st;
        Date endDt = ed;
        
        //check selected week range is before last week
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        Date previuosWkStart = currStart.addDays(-7);
        Date previuosWkEnd = currEnd.addDays(-7);
        
        Date isOlderThanLast2WeekStart = currStart.addDays(-14);
        Date isOlderThanLast2WeekEnd = currEnd.addDays(-14);
        
        
        Boolean isCurrentWeek = false;
        Boolean isBeforeLastWeek = false;
        
        if(startDt == currStart && endDt == currEnd) {
            isCurrentWeek = true;
        }
        
        if(startDt <= isOlderThanLast2WeekStart && endDt <= isOlderThanLast2WeekEnd){
            isBeforeLastWeek = true;
        }
        
        TimeCardDayCommunityDomain.DayEntries dayRec = new TimeCardDayCommunityDomain.DayEntries();
        dayRec.dayHours = null;
        dayRec.dayId = null;
        dayRec.lineId = null;
        dayRec.projectId = null;
        dayRec.taskId = null;
        dayRec.locationId = null;
        dayRec.isBillable = false;
        dayRec.payrollItem = '';
        dayRec.status = '';
        dayRec.dateVal = null;
        dayRec.comments = '';
        dayRec.costrateId = null;
        dayRec.contactAssignid = null;
        dayRec.sequenceNumber = 0;
        dayRec.cancellationReason = '';
        dayRec.startTime1 = null;
        dayRec.endTime1 = null;
        dayRec.startTime2 = null;
        dayRec.endTime2 = null;
        dayRec.lateCancellation = false;
        dayRec.isHrsDisabled = false;
        dayRec.showEditIcon = false;
        dayRec.showReverseIcon = false;
        dayRec.isCompleted = false;
        dayRec.isUnposted = false;
        
        dayRec.isNew = false;
        dayRec.isUpdated = false;
        
        while(startDt <= endDt){
            system.debug('startDt::::'+startDt);
            TimeCardDayCommunityDomain.DayEntries day = new TimeCardDayCommunityDomain.DayEntries();
            day.dateVal = startDt;
            
            //date formatting for display
            day.displayDate = String.valueOf(startDt).split('-')[1]+'/'+String.valueOf(startDt).split('-')[2]+'/'+String.valueOf(startDt).split('-')[0];
            
            //date type finding - mon, tues, ...
            DateTime currentDt = DateTime.newInstance(startDt, Time.newInstance(0, 0, 0, 0));
            day.dayType = currentDt.format('EEEE');
            
            dateEntryMap.put(startDt,day);
            startDt = startDt.addDays(1);
        }
        
        Map<Date,Boolean> dateLateCancellationMap = new Map<Date,Boolean>();
        
        system.debug(':::::::::::::dateEntryMap:::::::::'+dateEntryMap);
        
        Integer totalRecCnt = 0;
        Integer submitCnt = 0;
        Integer approvedCnt = 0;
        
        String tclLocationId = '';
        String tclLocationName = '';
     
        //Existing records based date & day wrapper map formation
        for(AcctSeed__Time_Card_Line__c line : timeCardLines) {
            
            String code = line.AcctSeed__Project__c+'~'+line.AcctSeed__Project_Task__c;
            
            //For Line completed check for other non created entries
            if(!taskIdLineCompleted.containsKey(line.AcctSeed__Project_Task__c)){
                taskIdLineCompleted.put(line.AcctSeed__Project_Task__c,line.Completed__c);
            }
            
            tclLocationId = line.Location__c;
            tclLocationName = line.Location__r.Name;
            
            Map<Date,TimeCardDayCommunityDomain.DayEntries> dayMap = new Map<Date,TimeCardDayCommunityDomain.DayEntries>();
            //Modified By Dhinesh  - 15/12/2022 - W-007660 - Missing Day Entries if we have more than 1 Time Card Line in Instructor Time Entry Page
            dayMap = !chargeCodedateEntryMap.containsKey(code) ? dateEntryMap.clone() : chargeCodedateEntryMap.get(code);
            
            if(line.AcctSeed__Time_Card_Days__r != null || line.AcctSeed__Time_Card_Days__r.size() > 0) {
                
                for(AcctSeed__Time_Card_Day__c day : line.AcctSeed__Time_Card_Days__r) {
                    
                    TimeCardDayCommunityDomain.DayEntries dayWrap = new TimeCardDayCommunityDomain.DayEntries();
                    
                    dayWrap.dayHours = String.valueOf(day.Total_Hours_Before_Approved__c);
                    if(!dayWrap.dayHours.contains('.')){
                        dayWrap.dayHours = dayWrap.dayHours+'.00';
                    }
                    
                    dayWrap.dayId = day.Id;
                    dayWrap.lineId = day.AcctSeed__Time_Card_Line__c;
                    dayWrap.projectId = line.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                    dayWrap.taskId = line.AcctSeed__Project_Task__c;
                    dayWrap.locationId = line.Location__c;
                    dayWrap.isBillable = line.AcctSeed__Billable__c;
                    dayWrap.payrollItem = line.Payroll_Item__c;
                    dayWrap.status = day.Status__c;
                    dayWrap.dateVal = day.AcctSeed__Date__c;
                    dayWrap.comments = day.AcctSeed__Internal_Comment__c;
                    dayWrap.costrateId = line.Labor_Cost_Rate__c;
                    dayWrap.contactAssignid = line.Contact_Assignment__c;
                    dayWrap.sequenceNumber = Integer.valueOf(line.Sequence_Number__c);
                    dayWrap.cancellationReason = day.Cancellation_Reason__c;
                    dayWrap.startTime1 = day.Start_Time1__c;
                    dayWrap.endTime1 = day.End_Time1__c;
                    dayWrap.locationId = line.Location__c;
                    dayWrap.TaskType = line.AcctSeed__Project_Task__r.Project_Task_Type__c;
                    dayWrap.lateCancellation = day.Late_Cancellation__c;
                    dayWrap.studentApprovalStatus = day.Student_Approval_Status__c;
                    dayWrap.ProjectName = projectName;
                    dayWrap.TaskName = line.AcctSeed__Project_Task__r.Name;
                    dayWrap.recallReason = day.Recall_Reason__c;
                    
                    if(line.AcctSeed__Project_Task__r.Name == 'Language Training- Preparation' && line.AcctSeed__Project_Task__r.Project_Task_Type__c == 'Preparation time') {
                        dayWrap.startTime2 = day.Start_Time2__c;
                        dayWrap.endTime2 = day.End_Time2__c;
                    }
                    
                    dayWrap.isNew = false;
                    dayWrap.isUpdated = false;
                    dayWrap.displayDate = String.valueOf(day.AcctSeed__Date__c).split('-')[1]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[2]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[0];
                    
                    DateTime actualDt = DateTime.newInstance(day.AcctSeed__Date__c, Time.newInstance(0, 0, 0, 0));
                    dayWrap.dayType = actualDt.format('EEEE');
                    
                    dayWrap.showEditIcon = false;
                    dayWrap.showReverseIcon = false;
                    
                    //For TCL based input disable action
                    dayWrap.isCompleted = line.Completed__c ? line.Completed__c : false;
                    dayWrap.isUnposted = false;
                    
                    //Input values disable based on date & Supervisor Status field
                    if(dayWrap.dateVal > system.today()){
                        dayWrap.isHrsDisabled = true;
                    }else {
                        dayWrap.isHrsDisabled = hrsDisableFunction(dayWrap,isCurrentWeek,isBeforeLastWeek);
                    }
                    
                    //Student Approval Status related colour coding for input
                    if(dayWrap.TaskType != 'Preparation time' && dayWrap.status != 'Rejected'){
                        if(dayWrap.studentApprovalStatus == 'Approved'){
                            dayWrap.color = 'Green';
                        }else if(dayWrap.studentApprovalStatus == 'Rejected'){
                            dayWrap.color = 'Red';
                        }
                    }                    

                    //Edit Icon display related conditions
                    dayWrap.showEditIcon = editIconDisplay(dayWrap,isCurrentWeek,isBeforeLastWeek);
                    
                    //Reverse Icon display related conditions
                    dayWrap.showReverseIcon = reverseIconDisplay(dayWrap,isCurrentWeek,isBeforeLastWeek);
                    
                    if(day.Late_Cancellation__c){
                        dateLateCancellationMap.put(day.AcctSeed__Date__c,day.Late_Cancellation__c);
                    }
                    
                    //To use for last week hrs disable, if there is no entry on that date
                    if(dayWrap.status == 'Submitted'){
                        submitCnt += 1;
                    }else if(dayWrap.status == 'Approved' || dayWrap.status == 'Admin Approved'){
                        approvedCnt += 1;
                    }

                    
                    if(dayWrap.TaskType == 'fringe' && (dayWrap.TaskName == 'Fringe-PTO' || dayWrap.TaskName == 'Fringe-Holiday' )) {
                        dayWrap.showEditIcon = true;
                        dayWrap.showReverseIcon = false;
                        if( dayWrap.TaskName == 'Fringe-Holiday') {
                            dayWrap.isHrsDisabled = true;
                            dayWrap.showEditIcon = false;
                        }
                    }
                    
                    totalRecCnt += 1;
                    
                    dayMap.put(day.AcctSeed__Date__c,dayWrap);                    
                }
            }
            
            system.debug('::::::::dayMap:::::'+dayMap);
            
            chargeCodedateEntryMap.put(code,dayMap);
            
        }
        
        system.debug(':::::::chargeCodedateEntryMap::::::'+chargeCodedateEntryMap);
        
        system.debug(':::::::tclLocationId::::::::'+tclLocationId);
        system.debug(':::::::tclLocationName::::::::'+tclLocationName);
        
        Integer sequenceNum = 0;
        
        Map<Integer,TimeCardDayCommunityDomain.InstructorDayDetails> seqNum_DetailsMap = new Map<Integer,TimeCardDayCommunityDomain.InstructorDayDetails>();
        
        List<TimeCardDayCommunityDomain.InstructorDayDetails> tempDetailsList = new List<TimeCardDayCommunityDomain.InstructorDayDetails>();
        List<Integer> seqNumbers = new List<Integer>();
        
        system.debug(':::::::::::caHistory:::::::'+caHistory);
        system.debug(':::::::::::caRecord:::::::'+caRecord);
        
        for(AcctSeed__Project_Task__c task : taskRecords){
            
            String key = task.AcctSeed__Project__c+'~'+task.Id;
            
            TimeCardDayCommunityDomain.InstructorDayDetails detail = new TimeCardDayCommunityDomain.InstructorDayDetails();
            //detail.chargeCode = projectName+' / <b>'+task.Name+'</b> / '+studentNames+' / '+task.AcctSeed__Project__r.Training_Location__r.Name;
            detail.chargeCode1 = projectName+' / <b>'+task.Name+'</b> / ';
            //To fix the duplicate TCL Creation when project location is changed mid of the week
            if(String.isNotBlank(tclLocationId) && tclLocationId != task.AcctSeed__Project__r.Training_Location__c){
                detail.chargeCode2 = studentNames+' / '+tclLocationName;
            }else {
                detail.chargeCode2 = studentNames+' / '+task.AcctSeed__Project__r.Training_Location__r.Name;
            }
            
            detail.totalHours = '0.00';
            detail.dayEntries = new List<TimeCardDayCommunityDomain.DayEntries>();
            
            if(task.Project_Task_Type__c == 'Language Training') {
                if(sequenceNum == 0){
                    detail.sequenceNumber = 1;    
                }else {
                    detail.sequenceNumber = sequenceNum + 1;
                }
                
            }else if(task.Project_Task_Type__c == 'Preparation time'){
                if(sequenceNum == 1){
                    detail.sequenceNumber = 2;    
                }else {
                    detail.sequenceNumber = sequenceNum + 1;
                }
                
            }else if(task.Project_Task_Type__c == 'Language Testing') {
                if(sequenceNum == 2){
                    detail.sequenceNumber = 3;    
                }else {
                    detail.sequenceNumber = sequenceNum + 1;
                }
                
            }else {
                detail.sequenceNumber = sequenceNum + 1;
            }
            
            sequenceNum = sequenceNum + detail.sequenceNumber;
            detail.taskType = task.Project_Task_Type__c;
            detail.taskName = task.Name;
            
            Decimal totalHr = 0.00;
            
            if(chargeCodedateEntryMap.containsKey(key)){
                
                for(Date dt : chargeCodedateEntryMap.get(key).keySet()){
                    
                    TimeCardDayCommunityDomain.DayEntries day = chargeCodedateEntryMap.get(key).get(dt).clone();
                    
                    if(day.dayId == null){
                        
                        day.projectId = task.AcctSeed__Project__c;
                        day.taskId = task.Id;
                        
                        if(String.isNotBlank(tclLocationId) && tclLocationId != task.AcctSeed__Project__r.Training_Location__c){
                            day.locationId = tclLocationId;
                        }else {
                            day.locationId = task.AcctSeed__Project__r.Training_Location__c;
                        }
                        
                        day.isBillable = task.Billable__c;
                        day.sequenceNumber = detail.sequenceNumber;
                        day.isNew = true;
                        day.isUpdated = false;
                        day.TaskType = detail.taskType;
                        day.lateCancellation = false;
                        day.TaskName = task.Name;
                        
                        if((day.dateVal > system.today() && task.Project_Task_Type__c != 'Fringe') || isBeforeLastWeek) {
                            day.isHrsDisabled = true;
                            
                        }else if(totalRecCnt != 0 && (submitCnt == totalRecCnt ||  approvedCnt == totalRecCnt)) {
                            day.isHrsDisabled = true;
                        
                        } else {
                            day.isHrsDisabled = false;
                        }
                        
                        day.showEditIcon = false;
                        day.showReverseIcon = false;
                        day.isCompleted = taskIdLineCompleted.containsKey(task.Id) ? taskIdLineCompleted.get(task.Id) : false;
                        day.isUnposted = false;
                        
                        //Payroll, CR values assigning
                        if(caHistory.size() == 0 || (caHistory.size() > 0 && caHistory[0].OldValue == null)){
                            if(caRecord.size() > 0 && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c
                                || task.Project_Task_Type__c == 'Fringe') 
                                    && caRecord[0].Rate_Card_Rate__c != null){
                                    
                                system.debug('::::::::if:::1::');
                                for(Contact_Assignments__c ca : caRecord){
                                    Date oralExamDate;
                                    if(ca.Oral_Exam_Date_Time__c != null){
                                        oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                                    }
                                    Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                                    if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                                        day.costrateId = (Id) ca.Rate_Card_Rate__c;
                                        day.contactAssignid = (Id) ca.Id;
                                        
                                        if(day.isBillable){
                                            day.payrollItem = ca.Rate_Card_Rate__r.Payroll_Item__c;
                                        }else {
                                            day.payrollItem = ca.Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                                        }
                                    }
                                }
                            }
                        }else if(caHistory.size() > 0 && caRecord.size() > 0 
                                && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c
                                    || task.Project_Task_Type__c == 'Fringe')){
                            
                            system.debug('::::::::else:::1::');
                                
                            Date historyDate = Date.newInstance(caHistory[0].createdDate.year(),caHistory[0].createdDate.month(),caHistory[0].createdDate.day());
                            
                            system.debug('::::::dt:::::'+dt);
                            system.debug('::::::historyDate:::::'+historyDate);
                            
                            if(dt <= historyDate && caHistory[0].OldValue != null){
                            
                                day.contactAssignid = (Id) caHistory[0].parentId;
                                
                                if(oldCRRecord.size() > 0){
                                    day.costrateId = oldCRRecord[0].Id;
                                    
                                    if( oldCRRecord[0].Id == day.costrateId){
                                        if(day.isBillable){
                                            day.payrollItem = oldCRRecord[0].Payroll_Item__c;
                                        }else {
                                            day.payrollItem = oldCRRecord[0].Non_Billable_Payroll_Item__c;
                                        }
                                    }
                                }
                            }else {    //If the history date is older then populate current CR value
                                
                                system.debug('::::::::else:::2::');
                                
                                if(caRecord.size() > 0 && (caRecord[0].Project_Task__c == task.Id 
                                        || caRecord[0].Project_Task__c == task.Parent_Project_Task__c || task.Project_Task_Type__c == 'Fringe') 
                                    && caRecord[0].Rate_Card_Rate__c != null){
                                    
                                    system.debug('::::inside::else:::::2::');
                                    
                                    for(Contact_Assignments__c ca : caRecord){
                                        Date oralExamDate;
                                        if(ca.Oral_Exam_Date_Time__c != null){
                                            oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                                        }
                                        Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                                        if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                                            day.costrateId = (Id) ca.Rate_Card_Rate__c;
                                            day.contactAssignid = (Id) ca.Id;
                                            
                                            if(day.isBillable){
                                                day.payrollItem = ca.Rate_Card_Rate__r.Payroll_Item__c;
                                            }else {
                                                day.payrollItem = ca.Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        //For Fringe Project Task get payroll item from project task
                        if(task.RecordType.DeveloperName == 'Cost' && task.Project_Task_Type__c == 'Fringe'){
                            day.payrollItem = task.Payroll_Item__c;
                        }

                        //For Fringe Project Task get payroll item from project task
                        // W-007860 - Modified by Vasanthram
                        if(task.Project_Task_Type__c == 'Fringe'){
                            day.payrollItem = task.Payroll_Item__c;
                        }
                        
                        /*system.debug('::::::::payrollItem:::'+day.payrollItem);
                        system.debug('::::::::contactassignment:::'+day.contactAssignid);
                        system.debug('::::::::costrateId:::'+day.costrateId);*/
                        
                        //W-005456 - added ESL LT Projects record type for ELT Pilot program
                        
                        if(dateLateCancellationMap.containsKey(dt) && task.Project_Task_Type__c == 'Preparation time' 
                            && task.AcctSeed__Project__r.RecordType.DeveloperName != 'DODA_Projects' 
                            && task.AcctSeed__Project__r.RecordType.DeveloperName != 'DLI_W_LT_Projects'
                            && task.AcctSeed__Project__r.RecordType.DeveloperName != 'ESL_LT_Projects'){
                            
                            day.isHrsDisabled = true; 
                        }

                        if(day.TaskType == 'fringe' && (day.TaskName == 'Fringe-PTO' || day.TaskName == 'Fringe-Holiday')) {
                            if(day.TaskName == 'Fringe-Holiday'){
                                if(federalHolidays.contains(day.dateVal)){
                                    DateTime holidayDT = datetime.newInstance(day.dateVal, Time.newInstance(0,0,0,0));
                                    String dayValue = holidayDT.format('E');// Exclude the 8 hours population for saturday and sunday if holidays occurs in saturday and sunday.

                                    if(dayValue != 'Sat' && dayValue != 'Sun'){
                                        day.dayHours = 8 + '.00';
                                    }
                                }
                                day.isHrsDisabled = true;
                            }
                            day.showEditIcon = false;
                            day.showReverseIcon = false;
                        }
                    }
                    
                    if(day.hours != null){
                        totalHr += Decimal.valueOf(day.dayHours);
                    }
                    detail.dayEntries.add(day);
                }
            }else {
                for(Date dt : dateEntryMap.keySet()){
                    TimeCardDayCommunityDomain.DayEntries day = new TimeCardDayCommunityDomain.DayEntries();
                    day = dateEntryMap.get(dt).clone();
                    
                    day.projectId = task.AcctSeed__Project__c;
                    day.taskId = task.Id;
                    
                    if(String.isNotBlank(tclLocationId) && tclLocationId != task.AcctSeed__Project__r.Training_Location__c){
                        day.locationId = tclLocationId;
                    }else {
                        day.locationId = task.AcctSeed__Project__r.Training_Location__c;
                    }
                        
                    day.isBillable = task.Billable__c;
                    day.sequenceNumber = detail.sequenceNumber;
                    day.TaskType = detail.taskType;
                    day.lateCancellation = false;
                    day.TaskName = task.Name;
                    
                    day.isNew = true;
                    day.isUpdated = false;
                    
                    //Payroll, CR values assigning
                    if(caHistory.size() == 0 || (caHistory.size() > 0 && caHistory[0].OldValue == null)){
                    
                        if(caRecord.size() > 0 && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c
                            || task.Project_Task_Type__c == 'Fringe') && caRecord[0].Rate_Card_Rate__c != null){
                        
                            for(Contact_Assignments__c ca : caRecord){
                                Date oralExamDate;
                                if(ca.Oral_Exam_Date_Time__c != null){
                                    oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                                }
                                Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                                if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                                    day.costrateId = (Id) ca.Rate_Card_Rate__c;
                                    day.contactAssignid = (Id) ca.Id;
                                    
                                    if(day.isBillable){
                                        day.payrollItem = ca.Rate_Card_Rate__r.Payroll_Item__c;
                                    }else {
                                        day.payrollItem = ca.Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                                    }
                                }
                            }
                        }
                    }else if(caHistory.size() > 0 && caRecord.size() > 0 
                                && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c 
                                || task.Project_Task_Type__c == 'Fringe')){
                    
                        Date historyDate = Date.newInstance(caHistory[0].createdDate.year(),caHistory[0].createdDate.month(),caHistory[0].createdDate.day());
                        
                        if(dt <= historyDate && caHistory[0].OldValue != null){
                        
                            day.contactAssignid = (Id) caHistory[0].parentId;
                            
                            if(oldCRRecord.size() > 0){
                                day.costrateId = oldCRRecord[0].Id;
                                
                                if(oldCRRecord[0].Id == day.costrateId){
                                    if(day.isBillable){
                                        day.payrollItem = oldCRRecord[0].Payroll_Item__c;
                                    }else {
                                        day.payrollItem = oldCRRecord[0].Non_Billable_Payroll_Item__c;
                                    }
                                }
                            }
                        }else {
                            
                            if(caRecord.size() > 0 && caRecord[0].Rate_Card_Rate__c != null 
                                && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c 
                                    || task.Project_Task_Type__c == 'Fringe')){
                                
                                for(Contact_Assignments__c ca : caRecord){
                                    Date oralExamDate;
                                    if(ca.Oral_Exam_Date_Time__c != null){
                                        oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                                    }
                                    Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                                    if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                                        day.costrateId = (Id) ca.Rate_Card_Rate__c;
                                        day.contactAssignid = (Id) ca.Id;
                                        
                                        if(day.isBillable){
                                            day.payrollItem = ca.Rate_Card_Rate__r.Payroll_Item__c;
                                        }else {
                                            day.payrollItem = ca.Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    //For Fringe Project Task get payroll item from project task
                    if(task.RecordType.DeveloperName == 'Cost' && task.Project_Task_Type__c == 'Fringe'){
                        day.payrollItem = task.Payroll_Item__c;
                    }
                    
                    //For all Fringe Project Task get payroll item from project task
                    if(task.Project_Task_Type__c == 'Fringe'){
                        day.payrollItem = task.Payroll_Item__c;
                    }

                    if((day.dateVal > system.today() && task.Project_Task_Type__c != 'Fringe') || isBeforeLastWeek) {
                        day.isHrsDisabled = true;
                        
                    }else if(totalRecCnt != 0 && (submitCnt == totalRecCnt ||  approvedCnt == totalRecCnt)) {
                        day.isHrsDisabled = true;
                    
                    } else {
                        day.isHrsDisabled = false;
                    }
                    
                    day.showEditIcon = false;
                    day.showReverseIcon = false;
                    day.isCompleted = false;
                    day.isUnposted = false;
                    
                     //W-005456 - added ESL LT Projects record type for ELT Pilot program
                    
                    if(dateLateCancellationMap.containsKey(dt) && task.Project_Task_Type__c == 'Preparation time' 
                        && task.AcctSeed__Project__r.RecordType.DeveloperName != 'DODA_Projects' 
                        && task.AcctSeed__Project__r.RecordType.DeveloperName != 'DLI_W_LT_Projects'
                        && task.AcctSeed__Project__r.RecordType.DeveloperName != 'ESL_LT_Projects'){
                        
                        day.isHrsDisabled = true; 
                    }

                    if(day.TaskType == 'fringe' && (day.TaskName == 'Fringe-PTO' || day.TaskName == 'Fringe-Holiday')) {
                        if(day.TaskName == 'Fringe-Holiday'){
                            if(federalHolidays.contains(day.dateVal)){
                                DateTime holidayDT = datetime.newInstance(day.dateVal, Time.newInstance(0,0,0,0));
                                String dayValue = holidayDT.format('E');// Exclude the 8 hours population for saturday and sunday if holidays occurs in saturday and sunday.
                                if(dayValue != 'Sat' && dayValue != 'Sun'){
                                    day.dayHours = 8 + '.00';
                                }
                            }
                            day.isHrsDisabled = true;
                        }
                        day.showEditIcon = false;
                        day.showReverseIcon = false;
                    }          
                    detail.dayEntries.add(day);
                }
            }
            
            if(task.Project_Task_Type__c == 'Preparation time' && taskIdTimeCount.containsKey(task.Id)){
                detail.timeRowCount = taskIdTimeCount.get(task.Id);
                
                if(taskIdTimeCount.get(task.Id) != 1 && taskIdTimeMap.containsKey(task.Id)){
                    detail.timeType = taskIdTimeMap.get(task.Id);
                }else if(taskIdTimeCount.get(task.Id) == 1){
                    detail.timeType = 'Single';
                }
                
            }else if(task.Project_Task_Type__c != 'Preparation time'){
                detail.timeRowCount = 1;
                detail.timeType = 'AM';
            }
            
            //Timezone
            if(taskIdTimezone.containsKey(task.Id)){
                detail.scheduleTimezone = taskIdTimezone.get(task.Id);
            }
            
            detail.totalHours = String.valueOf(totalHr);
            
            tempDetailsList.add(detail);
        }
        
        system.debug(':::::::::tempDetailsList:::::'+tempDetailsList);
        
        //To display the row details in order 
        for(TimeCardDayCommunityDomain.InstructorDayDetails detail : tempDetailsList){
            if(!seqNum_DetailsMap.containsKey(detail.sequenceNumber)){
                seqNum_DetailsMap.put(detail.sequenceNumber,detail);
            }
            seqNumbers.add(detail.sequenceNumber);
        }
        
        seqNumbers.sort();
        for(Integer num : seqNumbers){
            if(seqNum_DetailsMap.containsKey(num)){
                dayDetailsList.add(seqNum_DetailsMap.get(num));
            }
        }
        
        return dayDetailsList;
    }
    
    
    //Methods to find wheather edit icon, reverse icon & disable hrs based on supervisor & student approval status values
    //Added by NS on Mar 16 2019
    public static Boolean hrsDisableFunction(TimeCardDayCommunityDomain.DayEntries day,Boolean isCurrentWeek,Boolean isBeforeLastWeek){
        
        Set<String> statusValues = new Set<String>{'Draft','Submitted','Save - Approved','Save - Rejected','Approved','Rejected','Admin Approved','Recalled','Reverted','N/A'};
        
        Boolean disableInput = false;
       
        if(!isBeforeLastWeek || isCurrentWeek) {
            if(day.TaskType != 'Preparation time') {
                if(statusValues.contains(day.status) && statusValues.contains(day.studentApprovalStatus) || day.isCompleted){
                    disableInput = true;
                }
            }else {
                if(statusValues.contains(day.status) || day.isCompleted){
                    disableInput = true;
                }
            }
        }else if(isBeforeLastWeek){
            disableInput = true;
        }
        
        return disableInput;
    }
    
    //Edit icon display logic
    public static Boolean editIconDisplay(TimeCardDayCommunityDomain.DayEntries day,Boolean isCurrentWeek,Boolean isBeforeLastWeek){
        Boolean displayEditIcon = false;
        
        Set<String> studentStatus = new Set<String>{'Submitted','Approved','Rejected','Recalled','N/A'};
        
        if(!isBeforeLastWeek || isCurrentWeek) {
        
            if(day.TaskType != 'Preparation time') {
               System.debug('day::'+day);
                if(((day.status == 'Draft' && day.studentApprovalStatus != 'Approved')
                    || (day.status == 'Rejected' && (studentStatus.contains(day.studentApprovalStatus) || day.studentApprovalStatus == null))
                    || day.status == 'Recalled' || day.status == 'Reverted') 
                    && (!day.isCompleted || (day.isCompleted && (day.status == 'Rejected' || day.status == 'Recalled' || day.status == 'Reverted')))
                ){
                    displayEditIcon = true;
                }
            }else {
                if((day.status == 'Draft' || day.status == 'Rejected' || day.status == 'Recalled' || day.status == 'Reverted') 
                    && (!day.isCompleted || (day.isCompleted && (day.status == 'Rejected' || day.status == 'Recalled' || day.status == 'Reverted')))){
                    displayEditIcon = true;
                }
            }
        }
        return displayEditIcon;
    }
    
    //Reverse icon display logic
    public static Boolean reverseIconDisplay(TimeCardDayCommunityDomain.DayEntries day,Boolean isCurrentWeek,Boolean isBeforeLastWeek){
        Boolean displayReverseIcon = false;
       
        if(!isBeforeLastWeek || isCurrentWeek) {
            if(day.TaskType != 'Preparation time' && day.status == 'Draft' && day.studentApprovalStatus == 'Approved' && !day.isCompleted){
                displayReverseIcon = true;
            }
        }
        
        return displayReverseIcon;
    }
    
    //Student time entries table formation
    public static List<TimeCardDayCommunityDomain.StudentTimeDetail> studentTimeEntriesFormation(List<Contact_Assignments__c> studentCAs,Date st,Date ed,Map<Id,List<Attendance__c>> stuAttendanceMap,Boolean disbleWholeHrs,Boolean showEditIconBasedOnTCD){
        
        List<TimeCardDayCommunityDomain.StudentTimeDetail> studentEntries = new List<TimeCardDayCommunityDomain.StudentTimeDetail>();
        Map<Id,Map<Date,TimeCardDayCommunityDomain.StudentEntry>> stuIdDtEntryMap = new Map<Id,Map<Date,TimeCardDayCommunityDomain.StudentEntry>>();
        String communityType = ListViewController.getCommunityPathPrefix();
        
        Date startDt = st;
        Date endDt = ed;
        
        //check for before last week if selected date range
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        Date previuosWkStart = currStart.addDays(-7);
        Date previuosWkEnd = currEnd.addDays(-7);
        
        Date isOlderThanLast2WeekStart = currStart.addDays(-14);
        Date isOlderThanLast2WeekEnd = currEnd.addDays(-14);
        
        Boolean isCurrentWeek = false;
        Boolean isBeforeLastWeek = false;
        
        if(startDt == currStart && endDt == currEnd) {
            isCurrentWeek = true;
        }
        
        if(startDt <= isOlderThanLast2WeekStart && endDt <= isOlderThanLast2WeekEnd){
            isBeforeLastWeek = true;
        }
        
        system.debug(':::::::::isCurrentWeek::::'+isCurrentWeek);
        system.debug(':::::::::isBeforeLastWeek::::'+isBeforeLastWeek);
        
        Set<Date> weekDates = new Set<Date>();
        
        while(startDt <= endDt){
            weekDates.add(startDt);
            startDt = startDt.addDays(1);
        }
        
        for(Id key : stuAttendanceMap.keySet()){
            for(Attendance__c att : stuAttendanceMap.get(key)){
                if(communityType != 'student' || (communityType == 'student' && !att.Event__r.No_Student_Approval__c)){
                    TimeCardDayCommunityDomain.StudentEntry entry = new TimeCardDayCommunityDomain.StudentEntry();
                    entry.dateVal = att.Date__c;
                    
                    DateTime attDate = DateTime.newInstance(att.Date__c, Time.newInstance(0, 0, 0, 0));
                    entry.dayValue = attDate.format('EEEE');
                    
                    entry.displayDate = String.valueOf(att.Date__c).split('-')[1]+'/'+String.valueOf(att.Date__c).split('-')[2]+'/'+String.valueOf(att.Date__c).split('-')[0];
                    
                    entry.hours = String.valueOf(att.Duration__c);
                    entry.attendanceId = att.Id;
                    entry.eventId = att.Event__c;
                    entry.instructorId = att.Instructor__c;
                    entry.studentId = att.Student__c;
                    entry.studentApprovalStatus = att.Student_Approval_Status__c;
                    entry.dayId = att.Time_Card_Day__c;
                    entry.isNew = false;
                    entry.isUpdated = false;
                    entry.rejectionReason = att.Rejection_Reason__c;
                    entry.recallReason = att.Recall_Reason__c;
                    entry.comments = att.Comments__c;
                    entry.studentName = att.Student__r.Name;
                    entry.lateCancellation = att.Time_Card_Day__r.Late_Cancellation__c;
                    entry.eventNoStuApprovalFlag = att.Event__r.No_Student_Approval__c;
                    entry.attendance = att.Attendance__c;
    
                    
                    if(!isBeforeLastWeek || isCurrentWeek) {
                        
                        if(att.Date__c > system.today()){
                            entry.isHrsDisabled = true;
                        }else if(att.Student_Approval_Status__c != null) {
                            entry.isHrsDisabled = true;
                        }else if(disbleWholeHrs){
                            entry.isHrsDisabled = true;
                        }else {
                            entry.isHrsDisabled = false;
                        }
                        
                        if(att.Student_Approval_Status__c != 'Approved' && (att.Time_Card_Day__r.Status__c != 'Approved' && att.Time_Card_Day__r.Status__c != 'Submitted' 
                                && att.Time_Card_Day__r.Status__c != 'Admin Approved') && !att.Time_Card_Day__r.AcctSeed__Time_Card_Line__r.Completed__c){
                                
                            entry.showEditIcon = true;
                            
                            if(att.Student_Approval_Status__c == 'Rejected'){
                                entry.color = 'Red';
                            }
                            
                        }else {
                            if(att.Time_Card_Day__r.Status__c != 'Approved' && att.Time_Card_Day__r.Status__c != 'Submitted' 
                                && att.Time_Card_Day__r.Status__c != 'Admin Approved' && !att.Time_Card_Day__r.AcctSeed__Time_Card_Line__r.Completed__c) {
                                entry.showReverseIcon = true;
                            }else {
                                entry.showReverseIcon = false;
                            }
                            
                            entry.showEditIcon = false; 
                            
                            if(att.Student_Approval_Status__c == 'Approved'){
                                entry.color = 'Green';
                            }
                            
                            if(att.Student_Approval_Status__c == 'Rejected'){
                                entry.color = 'Red';
                            }
                        }
                        
                        if(att.Comments__c != null /*&& att.Time_Card_Day__r.Total_Hours_Before_Approved__c != att.Duration__c*/){
                            entry.displayNotesLink = 'true';
                        }else {
                            entry.displayNotesLink = 'false';
                        }
                        
                        //show edit for student based on TCD status value
                        //If approved tcd is present with rejected entry, then show edit icon for all approved tcd
                        if(showEditIconBasedOnTCD && entry.studentId != null && !entry.showEditIcon && !entry.showReverseIcon){
                            
                            if(att.Student_Approval_Status__c == 'Approved'){
                                entry.showReverseIcon = true;
                            }else {
                                entry.showEditIcon = true;
                            }
                        }
                        
                    }else {
                        entry.showReverseIcon = false;
                        entry.showEditIcon = false;
                        entry.isHrsDisabled = true;
                    }
                    
                    if(!stuIdDtEntryMap.containsKey(att.Student__c)){
                        stuIdDtEntryMap.put(att.Student__c,new Map<Date,TimeCardDayCommunityDomain.StudentEntry>{att.Date__c => entry});
                    }else {
                        stuIdDtEntryMap.get(att.Student__c).put(att.Date__c,entry);
                    }
                }
            }
        }
        
        for(Contact_Assignments__c ca : studentCAs){
        
            TimeCardDayCommunityDomain.StudentTimeDetail stuEntries = new TimeCardDayCommunityDomain.StudentTimeDetail();
            stuEntries.studentId = ca.Candidate_Name__c;
            stuEntries.studentName = ca.Candidate_Name__r.Name;
            stuEntries.entries = new List<TimeCardDayCommunityDomain.StudentEntry>();
            stuEntries.totalHours = '0.00';
            
            Decimal totalHrs = 0.00;
            
            for(Date dt : weekDates){
                if(stuIdDtEntryMap.containsKey(ca.Candidate_Name__c)) {
                    if(stuIdDtEntryMap.get(ca.Candidate_Name__c).containsKey(dt)) {
                    
                        totalHrs += Decimal.valueOf(stuIdDtEntryMap.get(ca.Candidate_Name__c).get(dt).hours);
                        
                        stuEntries.entries.add(stuIdDtEntryMap.get(ca.Candidate_Name__c).get(dt));
                        
                    }else {
                        TimeCardDayCommunityDomain.StudentEntry entry = new TimeCardDayCommunityDomain.StudentEntry();
                        entry.dateVal = dt;
                        
                        DateTime attDate = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0));
                        entry.dayValue = attDate.format('EEEE');
                        
                        entry.displayDate = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0];
                        
                        entry.hours = '';
                        entry.attendanceId = null;
                        entry.eventId = null;
                        entry.instructorId = null;
                        entry.studentId = ca.Candidate_Name__c;
                        entry.studentApprovalStatus = '';
                        entry.dayId = null;
                        entry.isNew = true;
                        entry.isUpdated = false;
                        
                        if(!isBeforeLastWeek || isCurrentWeek) {
                        
                            //W-004824 - student hours disable based on CA end date
                            
                            if(dt > system.today() || (ca.Status__c == 'Ended' && dt > ca.End_Date__c) 
                                || (ca.Status__c != 'Ended' && dt < ca.Start_Date__c)){
                                
                                entry.isHrsDisabled = true;
                            }else if(disbleWholeHrs){
                                entry.isHrsDisabled = true;
                            }else {
                                entry.isHrsDisabled = false;
                            }
                        }else {
                            entry.isHrsDisabled = true;
                        }
                        
                        entry.showReverseIcon = false;
                        entry.showEditIcon = false;
                        entry.rejectionReason = '';
                        entry.recallReason = '';
                        entry.comments = '';
                        entry.studentName = ca.Candidate_Name__r.Name;
                        entry.displayNotesLink = 'false';
                        entry.attendance = null;
                       
                        stuEntries.entries.add(entry);
                    }
                }else {
                    TimeCardDayCommunityDomain.StudentEntry entry = new TimeCardDayCommunityDomain.StudentEntry();
                    entry.dateVal = dt;
                    
                    DateTime attDate = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0));
                    entry.dayValue = attDate.format('EEEE');
                    
                    entry.displayDate = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0];
                    
                    entry.hours = '';
                    entry.attendanceId = null;
                    entry.eventId = null;
                    entry.instructorId = null;
                    entry.studentId = ca.Candidate_Name__c;
                    entry.studentApprovalStatus = '';
                    entry.dayId = null;
                    entry.isNew = true;
                    entry.isUpdated = false;
                    
                    if(!isBeforeLastWeek || isCurrentWeek) {
                    
                        //W-004824 - student hours disable based on CA end date
                    
                         if(dt > system.today() || (ca.Status__c == 'Ended' && dt > ca.End_Date__c)
                            || (ca.Status__c != 'Ended' && dt < ca.Start_Date__c)){
                            
                            entry.isHrsDisabled = true;
                        }else if(disbleWholeHrs){
                            entry.isHrsDisabled = true;
                        }else {
                            entry.isHrsDisabled = false;
                        }
                    }else {
                        entry.isHrsDisabled = true;
                    }
                    
                    entry.showReverseIcon = false;
                    entry.showEditIcon = false;
                    entry.rejectionReason = '';
                    entry.recallReason = '';
                    entry.comments = '';
                    entry.studentName = ca.Candidate_Name__r.Name;
                    entry.displayNotesLink = 'false';
                    entry.attendance = null;
                    
                    stuEntries.entries.add(entry);
                }
            }
            
            stuEntries.totalHours = String.valueOf(totalHrs);
            
            studentEntries.add(stuEntries);
        }
        
        return studentEntries;
    }
    
    //Notes Wrapper formation
    public static List<TimeCardDayCommunityDomain.NotesDetails> notesFormation(List<Accounting_Seed_Time_Snapshot__c> snapshotList){
        List<TimeCardDayCommunityDomain.NotesDetails> notesDetails = new List<TimeCardDayCommunityDomain.NotesDetails>();
        List<TimeCardDayCommunityDomain.NotesDetails> tempList = new List<TimeCardDayCommunityDomain.NotesDetails>();
        Map<String,List<TimeCardDayCommunityDomain.NotesDetails>> tempMap = new Map<String,List<TimeCardDayCommunityDomain.NotesDetails>>();
        
        
        for(Accounting_Seed_Time_Snapshot__c snapshot : snapshotList) {
            if(snapshot.Note_Type__c != null) {
                
                TimeCardDayCommunityDomain.NotesDetails notes = new TimeCardDayCommunityDomain.NotesDetails();
                notes.referenceId = snapshot.Reference_Id__c;
                notes.userName = snapshot.CreatedBy.Name;
                notes.dayId = snapshot.Time_Card_Day__c;
                notes.noteType = snapshot.Note_Type__c;
                notes.notes = formatNotes(snapshot.Notes__c,snapshot.Note_Type__c);
                notes.comment = snapshot.Invoice_Comment__c;
                
                String dt = String.valueOf(snapshot.Date__c);
                notes.daydate = dt.split('-')[1]+'/'+dt.split('-')[2]+'/'+dt.split('-')[0];
                
                notes.editedDT = snapshot.CreatedDate.format('MM/dd/yyyy HH:mm:ss a', UserInfo.getTimeZone().getID());
                
                tempList.add(notes);
            }
        }
        
        system.debug('::::::tempList:::::::::'+tempList.size());
        
        Map<String,TimeCardDayCommunityDomain.NotesDetails> refIdNoteMap = new Map<String,TimeCardDayCommunityDomain.NotesDetails>();
        
        for(TimeCardDayCommunityDomain.NotesDetails temp : tempList){
            if(temp.referenceId != null){
                if(!refIdNoteMap.containsKey(temp.referenceId)) {
                    TimeCardDayCommunityDomain.NotesDetails newNote = temp;
                    TimeCardDayCommunityDomain.NotesDetails newNote1 = new TimeCardDayCommunityDomain.NotesDetails();
                    
                    newNote1.referenceId = newNote.referenceId;
                    
                    newNote1.notes = newNote.notes;
                    newNote1.noteType = newNote.noteType;
                    newNote1.userName = newNote.userName;
                    
                    notesDetails.add(newNote1);
                    tempMap.put(temp.referenceId,new List<TimeCardDayCommunityDomain.NotesDetails>{temp});
                    
                    refIdNoteMap.put(temp.referenceId,newNote1);
                    
                }else {
                    tempMap.get(temp.referenceId).add(temp);
                    
                    if(temp.referenceId.contains('Partial Reject')){
                        
                        for(TimeCardDayCommunityDomain.NotesDetails formatedNotes : notesDetails){
                            
                            if(formatedNotes.referenceId == temp.referenceId && formatedNotes.referenceId.contains('Partial Reject')){
                                formatedNotes.notes += '<br/> &nbsp;&nbsp;&nbsp;&nbsp;<b>'+temp.dayDate+'</b> rejected on '+temp.editedDT+' for <b>Reason: </b>'+temp.comment;
                            
                            }
                        }
                        
                    }
                }
            }else {
                notesDetails.add(temp);
            }
        }
      
        system.debug('::::::::notesDetails::::::'+notesDetails);
        
        return notesDetails;
    }
    
    public static string formatNotes(string note, string type){
        String formattedNote = '';
        
        if(type == 'Instructor Daily Entry Late Cancellation'){
        
            formattedNote = note.replace('Cancellation Reason Notes:','<b>Cancellation Reason Notes:</b>');
            
        }else if(type == 'Instructor Daily Entry Student Hours Mismatch') {
        
            formattedNote = note.replace('Notes:','<b>Notes:</b>');
            
        }else if(type == 'Daily Entry Edit'){
        
            formattedNote = note.replace('Project Task:','<b style = "color: #055E89 !important;font-weight: bold !important;font-size: 1rem;">Project Task:</b>');
            
            formattedNote = formattedNote.replace('Date:','<b style = "color: #055E89 !important;font-weight: bold !important;font-size: 1rem;">Date:</b>');
            formattedNote = formattedNote.replace('Old Hours:','<b style = "color: #055E89 !important;font-weight: bold !important;font-size: 1rem;">Old Hours:</b>');
            formattedNote = formattedNote.replace('New Hours:','<b style = "color: #055E89 !important;font-weight: bold !important;font-size: 1rem;">New Hours:</b>');
            formattedNote = formattedNote.replace('Old Status:','<b style = "color: #055E89 !important;font-weight: bold !important;font-size: 1rem;">Old Status:</b>');
            formattedNote = formattedNote.replace('New Status:','<b style = "color: #055E89 !important;font-weight: bold !important;font-size: 1rem;">New Status:</b>');
            formattedNote = formattedNote.replace('Comment:','<b style = "color: #055E89 !important;font-weight: bold !important;font-size: 1rem;">Comment:</b>');
            
        }else if(type == 'Student Daily Entry Reject'){
        
            formattedNote = note.replace('Reason:','<b>Reason:</b>');
            
        }else if(type == 'Instructor Daily Entry Recall') {
        
            formattedNote = note.replace('Project Task:','<b>Project Task:</b>');
            formattedNote = formattedNote.replace('Date:','<b>Date:</b>');
            formattedNote = formattedNote.replace('Hours:','<b>Hours:</b>');
            
        }else {
            formattedNote = note;
        }
        
        return formattedNote;
    }
    
    /**********************************************************************************
    - Method to check which buttons are need to be displayed in instructor time entry page
    ************************************************************************************/
    public static TimeCardDayCommunityDomain.ButtonDisplay buttonDisplayFunction(List<TimeCardDayCommunityDomain.DayEntries> entryDetails,Date startDate,Date endDate){
        
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        Date previuosWkStart = currStart.addDays(-7);
        Date previuosWkEnd = currEnd.addDays(-7);
        
        Date weekBeforeLastWeekStart = previuosWkStart.addDays(-7);
        Date weekBeforeLastWeekEnd = previuosWkEnd.addDays(-7);
        
        Date olderpast2weekStart = weekBeforeLastWeekStart.addDays(-7);
        Date olderpast2weekEnd = weekBeforeLastWeekEnd.addDays(-7);
        
        Boolean isCurrentWeek = false;
        Boolean isLastWeek = false;
        Boolean isBeforeLastWeek = false;
        
        if(startDate == currStart && endDate == currEnd){
            isCurrentWeek = true;
        }
        
        if(previuosWkStart == startDate && previuosWkEnd == endDate){
            isLastWeek = true;
        }
        
        if((weekBeforeLastWeekStart == startDate && weekBeforeLastWeekEnd == endDate) || (startDate <= olderpast2weekStart && endDate <= olderpast2weekEnd)){
            isBeforeLastWeek = true;
        }        
        
        system.debug(':::::::::isCurrentWeek::::::'+isCurrentWeek);
        system.debug(':::::::::isBeforeLastWeek::::::'+isBeforeLastWeek);
        system.debug('::::::isLastWeek:::::'+isLastWeek);
        
        TimeCardDayCommunityDomain.ButtonDisplay btnDisp = new TimeCardDayCommunityDomain.ButtonDisplay();
        btnDisp.submitBtn = false;
        btnDisp.recallBtn = false;
        btnDisp.displayRequestEditLink = false;
        btnDisp.completeBtn = false;
        btnDisp.showEditIconForApproved = false;
        
        Integer submitCnt = 0;
        Integer approvedCnt = 0;
        Integer rejectedCnt = 0;
        Integer recallCnt = 0;
        Integer revertCnt = 0;
        Integer otherStatusCnt = 0;
        Integer totalCnt = 0;
        
        //Student Status count
        Integer studentRejectedCnt = 0;
        
        Boolean timesheetCompleted = true;
        
        List<String> statusList = new List<String>();
        

        for(TimeCardDayCommunityDomain.DayEntries entry : entryDetails){
            if(String.isNotBlank(entry.status) && entry.status != 'Unposted' && entry.dayId != null) {

                totalCnt += 1; 
                
                // This is for Submit
                if(entry.status == 'Submitted') {
                    submitCnt = submitCnt + 1;
                }
                // This is for approved
                if(entry.status == 'Approved' || entry.status == 'Admin Approved') {
                    approvedCnt = approvedCnt + 1;
                }
                
                // This is for Rejected
                if(entry.status == 'Rejected') {
                    rejectedCnt = rejectedCnt + 1;
                }
                
                // This for Recalled
                if(entry.status == 'Recalled') {
                    recallCnt = recallCnt + 1;
                }
                
                // This is for Draft / Reverted
                if(entry.status == 'Draft') {
                    otherStatusCnt = otherStatusCnt + 1;
                }
                
                // This is for Reverted
                if(entry.status == 'Reverted') {
                    revertCnt = revertCnt + 1;
                }
                
                if(timesheetCompleted && !entry.isCompleted){
                    timesheetCompleted = false;
                }
            }
            
            if(entry.studentApprovalStatus == 'Rejected'){
                studentRejectedCnt += 1;
            }
        }
        System.debug('rejectedCnt::>'+rejectedCnt);
        System.debug('approvedCnt::>'+approvedCnt);
        System.debug('totalCnt::>'+totalCnt);
        System.debug('submitCnt::>'+submitCnt);
        System.debug('otherStatusCnt::>'+otherStatusCnt);
        System.debug('timesheetCompleted ::>'+timesheetCompleted );
        System.debug('recallCnt::>'+recallCnt);
        if(totalCnt > 0){
            
            if(!isBeforeLastWeek) { // This condition to check selected week range is before last week - then dont show any btns
                
                if(rejectedCnt == 0 && recallCnt < 1 && ((timesheetCompleted && otherStatusCnt > 0)  || otherStatusCnt < 1) && (timesheetCompleted || submitCnt > 0) && approvedCnt != totalCnt){    
                    btnDisp.recallBtn = true;
                }
                
                if(!btnDisp.recallBtn && (submitCnt == 0 || rejectedCnt > 0 || recallCnt > 0 || otherStatusCnt > 0 || revertCnt > 0 || submitCnt != totalCnt) && approvedCnt != totalCnt){                                                                                                                                 
                    btnDisp.submitBtn = true;
                    btnDisp.completeBtn = true;    //For complete btn display
                }
                
                // For all approved / Admin appoved conditions
                /*if(approvedCnt > 0 && approvedCnt == totalCnt) {
                    btnDisp.recallBtn = true;
                  }*/
                
                //For Request Edit Link display
                if(!btnDisp.recallBtn && !btnDisp.submitBtn && !btnDisp.completeBtn /*&& studentRejectedCnt > 0*/){
                    btnDisp.displayRequestEditLink = true;
                }
                
                //For displaying edit icon if 1 rejected entry exist with approved entries
                if(approvedCnt > 0 && rejectedCnt > 0){
                    btnDisp.showEditIconForApproved = true;
                }                    
            }else {
            
                // For all other past weeks btns display
                if(revertCnt > 0) {
                    btnDisp.submitBtn = true;
                    btnDisp.completeBtn = true;    //For complete btn display
                }else{
                    btnDisp.displayRequestEditLink = true;
                }
            }
        }else {
            if(!isBeforeLastWeek) {
                btnDisp.recallBtn = false;
                btnDisp.submitBtn = true;
                btnDisp.completeBtn = true;
                
            }else {
                btnDisp.recallBtn = false;
                btnDisp.submitBtn = false;
                btnDisp.completeBtn = false;
                btnDisp.displayRequestEditLink = true;
            }            
        }
        
        return btnDisp;
    }
    
    /********************************************************
    - Week based Project filter formation - For Instructor Time Entry(Student Approval)
    *********************************************************/
    public static TimeCardDayCommunityDomain.ProjectFilterInfo projectRelatedFilterStuApproval(List<AcctSeed__Project__c> projectRelatedCAStuNames,List<AcctSeed__Project__c> supervisorProjectList,List<AcctSeed__Project__c>  projectWithInstructorRecords,Set<String> tcdInstructorWithProId){
        
        TimeCardDayCommunityDomain.ProjectFilterInfo proInfo = new TimeCardDayCommunityDomain.ProjectFilterInfo();
        
        Map<Id,String> proIdSupervisorName = new Map<Id,String>();
        Map<Id,String> projectRelatedCAStuNamesMap = new Map<Id,String>();
        Map<String,String> instructorRelatedProjectsMap = new Map<String,String>();
        
        
        for(AcctSeed__Project__c pro : supervisorProjectList){
            if(pro.Contact_Assignments__r.size() > 0){
                for(Contact_Assignments__c ca : pro.Contact_Assignments__r){
                    if(!proIdSupervisorName.containsKey(pro.Id)){
                        proIdSupervisorName.put(pro.Id,ca.Candidate_Name__r.Name);
                    }
                }
            }
        }
        
        proInfo.proIdSupervisorName = proIdSupervisorName;
        
        for(AcctSeed__Project__c pro : projectWithInstructorRecords){
            if(pro.Contact_Assignments__r.size() > 0) {
                for(Contact_Assignments__c ca : pro.Contact_Assignments__r){
                    if(!instructorRelatedProjectsMap.containsKey(pro.Id+'-'+ca.Candidate_Name__r.Name)){
                        if(tcdInstructorWithProId.contains(pro.Id+'-'+ca.Candidate_Name__c)){
                            instructorRelatedProjectsMap.put(pro.Id+'-'+ca.Candidate_Name__c, pro.DLS_Class__c+' / '+ ca.Candidate_Name__r.Name);
                        }
                    }
                }
            }
        }
       proInfo.instructorRelatedProjects = instructorRelatedProjectsMap;
        
        for(AcctSeed__Project__c pro : projectRelatedCAStuNames){
            if(pro.Contact_Assignments__r.size() > 0) {
                for(Contact_Assignments__c ca : pro.Contact_Assignments__r){
                    if(projectRelatedCAStuNamesMap.containsKey(pro.Id)){
                        projectRelatedCAStuNamesMap.put(pro.Id, projectRelatedCAStuNamesMap.get(pro.Id)+ca.Candidate_Name__r.FirstName+' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.; ');
                    }else{
                        projectRelatedCAStuNamesMap.put(pro.Id, pro.DLS_Class__c+'/'+ca.Candidate_Name__r.FirstName+' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.; ');
                    }
                }
            }
        }
        proInfo.projectRelatedStudentNames = projectRelatedCAStuNamesMap;
        return proInfo;
    }
    
   
    /***************************************************************************************
    - Method to get Instructor row entries for StudentApproval
    - Added by Siva Prasanth on Mar 6,2019
    *************************************************************************************************/
    public static TimeCardDayCommunityDomain.InstructorRowDetails StuApprovalInstructorDayRowEntries(String proId, Date startDate, Date endDate, String studentNamesWithDlsClassNo, List<Accounting_Seed_Time_Snapshot__c> accTimesnapshot,List<User> userLst,set<Id> projectIds,List<AcctSeed__Time_Card_Line__c> timeCardLineList, List<Contact_Assignments__c> cALst, List<Planned_Days_Off__c> dliTHolidayPDOList, Map<Id, Boolean> tcdIdAndEvtNoStdApprovalFlag){
        
        Map<String, Map<Date,TimeCardDayCommunityDomain.DayEntries>> chargeCodeDateEntryMap = new Map<String, Map<Date,TimeCardDayCommunityDomain.DayEntries>>();
        Map<Date,TimeCardDayCommunityDomain.DayEntries> dateEntryMap = new Map<Date,TimeCardDayCommunityDomain.DayEntries>();
        
        Date st = startDate;
        Date ed = endDate;
        
        TimeCardDayCommunityDomain.InstructorRowDetails weekDetails = new  TimeCardDayCommunityDomain.InstructorRowDetails();
        List<TimeCardDayCommunityDomain.WeekRangeValues> weekDates = new List<TimeCardDayCommunityDomain.WeekRangeValues>();
        
        String DlsClassNo = studentNamesWithDlsClassNo.split('/')[0];
        String studentNames = studentNamesWithDlsClassNo.split('/')[1];
        
        Date today = system.today();
        Date currst;
        
        //if today = sunday need to load the last week data - because saleforce start of the week is sunday
        if(today.toStartofWeek() == today) {
            currst = today.addDays(-1).toStartofWeek().addDays(1);
        }else {
            currst = today.toStartofWeek().addDays(1);
        } 
        Date currend = currst.addDays(6);
        
        
        while(st <= ed){
            TimeCardDayCommunityDomain.WeekRangeValues wkVal = new TimeCardDayCommunityDomain.WeekRangeValues();
            TimeCardDayCommunityDomain.DayEntries day = new TimeCardDayCommunityDomain.DayEntries();
            
            wkVal.dateValue = String.valueOf(st).split('-')[1]+'/'+String.valueOf(st).split('-')[2]+'/'+String.valueOf(st).split('-')[0];
            DateTime todayVal = DateTime.newInstance(st, Time.newInstance(0, 0, 0, 0));
            wkVal.dayVal = todayVal.format('EEE').toUppercase();
            
            day.dayHours = '0.00';
            day.dateVal = st;
            day.lateCancellation = false;
            day.status = '';
            day.displayDate = wkVal.dateValue;
            dateEntryMap.put(st,day);
            weekDates.add(wkVal);
            st = st.addDays(1);
        }
        weekDetails.weekDates = weekDates;
        
        TimeCardDayCommunityDomain.TotalHrsDayWrapper TotalHrsDayColumn = new TimeCardDayCommunityDomain.TotalHrsDayWrapper();  
        
        TotalHrsDayColumn.monHrs = '0.00';
        TotalHrsDayColumn.tueHrs = '0.00';
        TotalHrsDayColumn.wedHrs = '0.00';
        TotalHrsDayColumn.thuHrs = '0.00';
        TotalHrsDayColumn.friHrs = '0.00';
        TotalHrsDayColumn.satHrs = '0.00';
        TotalHrsDayColumn.sunHrs = '0.00';
        TotalHrsDayColumn.TotaldayHrs = '0.00';
        
        Set<Date> dliHoliPDODates = new Set<Date>();
        for(Planned_Days_Off__c pdo : dliTHolidayPDOList){
            dliHoliPDODates.add(pdo.Date__c);
        }
        
        List<TimeCardDayCommunityDomain.InstructorDayDetails> dayDetailEntryLst  = new List<TimeCardDayCommunityDomain.InstructorDayDetails>();
        
        Set<Id> timeLineIdSet = new Set<Id>();
        Set<String> studentApproveStatusSet = new Set<String>{'Approved','Rejected','Submitted'};
        Integer totalDayEntriesApprovalCount = 0;
        Integer totalDayEntriesCount = 0;
        
        Map<String, TimeCardDayCommunityDomain.InstructorDayDetails> chargeCodeDayDetailsMap  = new Map<String, TimeCardDayCommunityDomain.InstructorDayDetails>();
        
        //Query Existing TimeCardLine records         
        if(projectIds.size() > 0) {           
            
            for(AcctSeed__Time_Card_Line__c  line: timeCardLineList){
                
                Decimal totalHrs = 0.00;
                Integer timeRowCount = 1;
                Date stDate = startDate;
                Date edDate = endDate;
                Integer dayEntriesApprovalCount = 0;    
                String projectRT = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName;
                Integer dayEntriesCount = 0;
                
                String code = line.AcctSeed__Project__c+'~'+line.AcctSeed__Project_Task__c;
                
                TimeCardDayCommunityDomain.InstructorDayDetails dayDetails  = chargeCodeDayDetailsMap.containsKey(code) ? chargeCodeDayDetailsMap.get(code) : new TimeCardDayCommunityDomain.InstructorDayDetails();
                Map<Date,TimeCardDayCommunityDomain.DayEntries> dayMap = new Map<Date,TimeCardDayCommunityDomain.DayEntries>();
                List<TimeCardDayCommunityDomain.DayEntries> dayDetailsList = new List<TimeCardDayCommunityDomain.DayEntries>();
                
                dayMap = !chargeCodeDateEntryMap.containsKey(code) ? dateEntryMap.clone() : chargeCodeDateEntryMap.get(code);
                
                if(line.AcctSeed__Project_Task__r.Project_Task_Type__c != 'Preparation time' 
                   && (line.AcctSeed__Time_Card_Days__r != null && line.AcctSeed__Time_Card_Days__r.size() > 0)) {
                   
                    dayDetails.chargeCode1 = DlsClassNo+'/'+line.AcctSeed__Project_Task__r.Name+'/'+studentNames+'/'+line.Location__r.Name;
                    timeLineIdSet.add(line.Id);
                   
                       for(AcctSeed__Time_Card_Day__c day : line.AcctSeed__Time_Card_Days__r) {
                       
                           if(day.Status__c != 'Unposted' &&(studentApproveStatusSet.contains(day.Student_Approval_Status__c))
                              && (!(projectRT == 'DLI_W_LT_Projects' && dliHoliPDODates.contains(day.AcctSeed__Date__c) && day.Late_Cancellation__c == true)) && (tcdIdAndEvtNoStdApprovalFlag.containsKey(day.Id) && tcdIdAndEvtNoStdApprovalFlag.get(day.Id) == false)){
                                  
                                  TimeCardDayCommunityDomain.DayEntries dayRec = new TimeCardDayCommunityDomain.DayEntries();
                                  dayRec.dayHours = ''+day.Total_Hours_Before_Approved__c;
                                  dayRec.dayId = day.Id;
                                  dayRec.studentApprovalStatus = day.Student_Approval_Status__c;
                                  dayRec.dateVal = day.AcctSeed__Date__c;
                                  dayRec.lineId = day.AcctSeed__Time_Card_Line__c; 
                                  dayRec.endTime1 = day.End_Time1__c;
                                  dayRec.startTime1 =  day.Start_Time1__c;
                                  dayRec.displayDate =  day.AcctSeed__Date__c != null ?  String.valueOf(day.AcctSeed__Date__c).split('-')[1]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[2]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[0] : null; 
                                  dayRec.lateCancellation = day.Late_Cancellation__c;
                                  dayRec.rejectionReason = day.Student_Notes__c;
                                  dayRec.dayType = day.Week_Day__c;
                                  dayEntriesCount = dayEntriesCount + 1;
                                  dayRec.showApproveRejectIcon = true;
                                  
                                  // W-006419 - Add "No Student Approval" to the Event Edit Page

                                  if(tcdIdAndEvtNoStdApprovalFlag.containsKey(dayRec.dayId) && tcdIdAndEvtNoStdApprovalFlag.get(dayRec.dayId) == true){
                                      dayRec.showApproveRejectIcon = false;
                                  }
                                  
                                  totalHrs = totalHrs + day.Total_Hours_Before_Approved__c;
                               
                                  if(day.Student_Approval_Status__c == 'Approved'){
                                      dayEntriesApprovalCount = dayEntriesApprovalCount+ 1;
                                      dayRec.color = 'Green';
                                  }else if(day.Student_Approval_Status__c == 'Rejected'){
                                      dayRec.color = 'Red';
                                  }

                                  dayMap.put(day.AcctSeed__Date__c,dayRec);                                  
                              }
                       }
                       dayDetails.timeRowCount = dayDetails.timeRowCount != null ? dayDetails.timeRowCount + timeRowCount : timeRowCount;
                       dayDetails.totalHours = dayDetails.totalHours != null ? String.valueOf(Decimal.valueOf(dayDetails.totalHours)+totalHrs) : String.valueOf(totalHrs);
                       dayDetails.dayEntriesCount = dayDetails.dayEntriesCount != null ? dayDetails.dayEntriesCount +dayEntriesCount : dayEntriesCount;
                       dayDetails.dayEntriesApprovalCount = dayDetails.dayEntriesApprovalCount != null ? dayDetails.dayEntriesApprovalCount + dayEntriesApprovalCount : dayEntriesApprovalCount;
                       totalDayEntriesApprovalCount = totalDayEntriesApprovalCount + dayDetails.dayEntriesApprovalCount;
                       totalDayEntriesCount = totalDayEntriesCount + dayDetails.dayEntriesCount;
                       if((startDate != currst && endDate != currend) && dayDetails.dayEntriesCount == dayDetails.dayEntriesApprovalCount){
                           dayDetails.isDisplayApproveText = true;
                       }else{
                           dayDetails.isDisplayApproveText = false;  
                       }
                                              
                       /*Map<Date,TimeCardDayCommunityDomain.DayEntries> tempMap = dateEntryMap;
                       tempMap.putAll(dayMap);*/
                  
                       while(stDate <= endDate){
                           if(dayMap.containsKey(stDate)){
                               dayDetailsList.add(dayMap.get(stDate));  
                           }
                           stDate = stDate.addDays(1);                  
                       }
                       dayDetails.dayEntries = dayDetailsList;

                       chargeCodeDateEntryMap.put(code, dayMap);
                       
                       chargeCodeDayDetailsMap.put(code, dayDetails);
                   }                    
            }             
            dayDetailEntryLst.addAll(chargeCodeDayDetailsMap.values());
        }
        
        if((startDate == currst && endDate == currend) ||  totalDayEntriesCount != totalDayEntriesApprovalCount ){
            weekDetails.displaySaveButton = true;   
        }else{
            weekDetails.displaySaveButton = false;    
        }
        
        weekDetails.entries = dayDetailEntryLst;
        // get column Total values
        for(TimeCardDayCommunityDomain.InstructorDayDetails tcl : dayDetailEntryLst){
            for(TimeCardDayCommunityDomain.DayEntries tcd : tcl.dayEntries) {
                if(tcd.dayType == 'Monday'){
                    TotalHrsDayColumn.monHrs =  String.valueOf(Decimal.valueOf(TotalHrsDayColumn.monHrs) +Decimal.valueOf(tcd.dayHours));
                }else if(tcd.dayType == 'Tuesday'){
                    TotalHrsDayColumn.tueHrs =  String.valueOf(Decimal.valueOf(TotalHrsDayColumn.tueHrs) +Decimal.valueOf(tcd.dayHours));
                }else if(tcd.dayType == 'Wednesday'){
                    TotalHrsDayColumn.wedHrs =  String.valueOf(Decimal.valueOf(TotalHrsDayColumn.wedHrs) +Decimal.valueOf(tcd.dayHours));
                }else if(tcd.dayType == 'Thursday'){
                    TotalHrsDayColumn.thuHrs =  String.valueOf(Decimal.valueOf(TotalHrsDayColumn.thuHrs) +Decimal.valueOf(tcd.dayHours));
                }else if(tcd.dayType == 'Friday'){
                    TotalHrsDayColumn.friHrs =  String.valueOf(Decimal.valueOf(TotalHrsDayColumn.friHrs) +Decimal.valueOf(tcd.dayHours));
                }else if(tcd.dayType == 'Saturday'){
                    TotalHrsDayColumn.satHrs =  String.valueOf(Decimal.valueOf(TotalHrsDayColumn.satHrs) +Decimal.valueOf(tcd.dayHours));
                }else if(tcd.dayType == 'Sunday'){
                    TotalHrsDayColumn.sunHrs =  String.valueOf(Decimal.valueOf(TotalHrsDayColumn.sunHrs) +Decimal.valueOf(tcd.dayHours));
                }
                TotalHrsDayColumn.TotaldayHrs = String.valueOf(Decimal.valueOf(TotalHrsDayColumn.TotaldayHrs) +  Decimal.valueOf(tcd.dayHours));
            }
        }
        
        weekDetails.TotalHrsDayColEntries = TotalHrsDayColumn; 
        
        if( userLst != null && userLst.size() > 0 ){
            if(userLst[0].ContactId != null){
                weekDetails.isStudentLeader = getClassLeaderforLoggedInUser(proId,userLst,cALst);
                weekDetails.studentId = userLst[0].ContactId ;
            }
        }
        
        WeekDetails.notes =  notesFormation(accTimesnapshot);
        return WeekDetails;
    }
    
     /*************************************************************************************************
    - Method to get Student row entries for StudentApproval
    - Added by Siva Prasanth on Mar 14,2019
    *************************************************************************************************/

    public static String studentTimeRowEntriesFormation(Date startDt, Date endDt,List<Contact_Assignments__c> studentCAs,List<Attendance__c> stuAttendanceList,Set<Id> studentIds,List<User> userLst){
        
        //Qry project related student CAs for student attendance table formation
    
        
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        Integer approvalCnt = 0;
        Integer loggedStuAttCnt = 0;
        Boolean isDisplayApproveText = false;
            
        Map<Id,List<Attendance__c>> studentIdAttendanceList = new Map<Id,List<Attendance__c>>();
       
        if(studentIds.size() > 0){
            for(Attendance__c att : stuAttendanceList){
                
                if(!studentIdAttendanceList.containsKey(att.Student__c)){
                    studentIdAttendanceList.put(att.Student__c,new List<Attendance__c>{att});
                }else {
                    studentIdAttendanceList.get(att.Student__c).add(att);
                } // display 'Approved' text in student Attendence action row if user selected week is not current week and Attendance approve count equal to  Attendance record count
               
                
                if( userLst != null && userLst.size() > 0 ){
                    if(userLst[0].ContactId != null){
                        if(att.Student__c == userLst[0].ContactId) {
                            loggedStuAttCnt = loggedStuAttCnt + 1;
                            if(att.Student_Approval_Status__c == 'Approved') {
                                approvalCnt = approvalCnt + 1;
                            }
                        }
                    }
                }
            }
            if(loggedStuAttCnt != 0 && ((startDt != currStart && endDt != currEnd) && approvalCnt == loggedStuAttCnt)){
                isDisplayApproveText = true;
            }else{
                isDisplayApproveText = false;
            }
            
            List<TimeCardDayCommunityDomain.StudentTimeDetail> stuTimeEntries = studentTimeEntriesFormation(studentCAs,startDt,endDt,studentIdAttendanceList,true,false);
            for(TimeCardDayCommunityDomain.StudentTimeDetail stuEntries : stuTimeEntries){
                for(TimeCardDayCommunityDomain.StudentEntry  stuAtn : stuEntries.entries){
                    stuAtn.showApproveRejectIcon = true;
                    
                   // W-006419 - Add "No Student Approval" to the Event Edit Page
                    if(stuAtn.eventNoStuApprovalFlag == true){
                        stuAtn.showApproveRejectIcon = false;
                    }
                    
                    if(stuAtn.studentApprovalStatus == 'Approved'){
                        stuAtn.color = 'Green';
                    }else if(stuAtn.studentApprovalStatus == 'Rejected'){
                        stuAtn.color = 'Red';
                    }
                }
                
                if( userLst != null && userLst.size() > 0 && userLst[0].ContactId != null){
                    if(stuEntries.studentId == userLst[0].ContactId) {
                        stuEntries.isDisplayApproveText = isDisplayApproveText;
                    }
                }
            }
            
            return JSON.serialize(stuTimeEntries);
        }
        return null;
    }
    
    /***************************************************************************************
   - Method to get Current Logged User Assignment Position
   - Added by Siva Prasanth on Mar 13,2019
   *************************************************************************************************/
    public static Boolean getClassLeaderforLoggedInUser(String proId,List<user>userLst,List<Contact_Assignments__c> cALst){
        
        Boolean isStudentLeader = false ;
        if(cALst.size() == 1){
            isStudentLeader = true;  
        }else if(cALst.size() > 0){
            for(Contact_Assignments__c  ca : cALst){
                if(ca.Assignment_Position__c == 'Class Leader' && ca.Candidate_Name__c == userLst[0].ContactId ){
                    isStudentLeader = true;  
                }
            }
            if(isStudentLeader == true){
                isStudentLeader = true;      
            }else {
                isStudentLeader = false;    
            }
        }else {
            isStudentLeader = false;    
        }
        return isStudentLeader;
    }
    
    /*************************************************************************************************
    
    - Method to form the wrapper for Instructor & Student Community Time card day list view
    - Added by Mohana on Apr 03,2019
    *************************************************************************************************/
    public static TimeCardDayCommunityDomain.TimeDetails timeActivityRecordsFormation(List<AcctSeed__Time_Card_Day__c> dayList){
        
        List<TimeCardDayCommunityDomain.TimeCardDayInfo> timeCardRecords = new List<TimeCardDayCommunityDomain.TimeCardDayInfo>();
        Decimal totalHrs = 0.00;
        
        for(AcctSeed__Time_Card_Day__c day : dayList) {
            
            TimeCardDayCommunityDomain.TimeCardDayInfo timeCardWrap = new TimeCardDayCommunityDomain.TimeCardDayInfo();
            
            timeCardWrap.dayId = day.Id;
            timeCardWrap.dayDate = day.AcctSeed__Date__c;
            timeCardWrap.dayDtVal = day.AcctSeed__Date__c.month()+'/'+day.AcctSeed__Date__c.day()+'/'+day.AcctSeed__Date__c.year();
            timeCardWrap.weekDay = day.Week_Day__c;
            timeCardWrap.submittedHours = String.valueOf(day.Total_Hours_Before_Approved__c);
            timeCardWrap.studentAprroval = day.Student_Approval_Status__c;
            timeCardWrap.supervisorAprroval= day.Status__c;
            timeCardWrap.projectTask = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name;
            timeCardWrap.instructor = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name;
            timeCardWrap.location = day.AcctSeed__Time_Card_Line__r.Location__r.Name;
            timeCardWrap.projectId = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            timeCardWrap.dlsClass = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.DLS_Ref__c;
            
            totalHrs += day.Total_Hours_Before_Approved__c;
            
            timeCardRecords.add(timeCardWrap); 
        }
        
        TimeCardDayCommunityDomain.TimeDetails detail = new TimeCardDayCommunityDomain.TimeDetails();
        detail.timeRecords = timeCardRecords;
        detail.totalHrs = String.valueOf(totalHrs);
        
        return detail;
    
    }
    
    /*****************************************************************************************************
    - Method to form wrapper class for Time review & submit page in instructor community
    - Added by NS on July 29 2019
    ******************************************************************************************************/
    public static TimeCardDayCommunityDomain.ReviewSubmitTCDDetails timeSubmissionTableFormation(List<AcctSeed__Time_Card_Day__c> dayRecords,List<AcctSeed__Project__c> projectRecords){
        
        TimeCardDayCommunityDomain.ReviewSubmitTCDDetails submitDetail = new TimeCardDayCommunityDomain.ReviewSubmitTCDDetails();
        
        List<TimeCardDayCommunityDomain.DayEntries> entries = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        Decimal totalHrs = 0.00;
        
        Boolean allSubmitted = false;
        DateTime submittedDt;
        Boolean displaySubmitBtn = false;
        
        Decimal submittedCnt = 0;
        Decimal approvedCnt = 0;
        Map<Id,AcctSeed__Project__c> nonCompletedProjects = new Map<Id,AcctSeed__Project__c>();
        Set<Id> notCompletedProIds = new Set<Id>();
        
        
        Set<String> statusValues = new Set<String>{'Submitted','Approved','Admin Approved'};
        
        for(AcctSeed__Time_Card_Day__c day : dayRecords){
            TimeCardDayCommunityDomain.DayEntries entry = new TimeCardDayCommunityDomain.DayEntries();
            entry.dayId = day.Id;
            entry.weekDay = day.Week_Day__c;
            entry.dayType = day.Week_Day__c.substring(0, 3);
            entry.displayDate = String.valueOf(day.AcctSeed__Date__c).split('-')[1]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[2]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[0];
            entry.startTime1 = day.Start_Time1__c;
            entry.endTime1 = day.End_Time1__c;
            entry.startTime2 = day.Start_Time2__c;
            entry.endTime2 = day.End_Time2__c;
            entry.hours = day.Total_Hours_Before_Approved__c;
            
            entry.dayHours = String.valueOf(day.Total_Hours_Before_Approved__c);
            if(!entry.dayHours.contains('.')){
                entry.dayHours = entry.dayHours+'.00';
            }
            
            entry.projectId = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            entry.projectName = day.AcctSeed__Time_Card_Line__r.Contact_Assignment__r.RecordType.DeveloperName == 'Staff' ? day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name : day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.DLS_Class__c;
            entry.taskName = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name;
            entry.taskId = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            entry.status = day.Status__c;
            entry.taskType = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c;
            entry.studentApprovalStatus = day.Student_Approval_Status__c;
            
            totalHrs += Decimal.valueOf(entry.dayHours);
            
            if(!statusValues.contains(day.Status__c)){
                displaySubmitBtn = true;
            }
            
            if(day.Status__c == 'Submitted'){
                submittedCnt += 1;
            }
            
            if(day.Status__c == 'Approved' || day.Status__c == 'Admin Approved'){
                approvedCnt += 1;
            }
            
            submittedDt = day.Submitted_Date_Time__c;
            
            if(!day.AcctSeed__Time_Card_Line__r.Completed__c && !statusValues.contains(day.Status__c)){
                notCompletedProIds.add(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c);
            }
            
            entries.add(entry);
        }
        
        String dtVal = '';
        
        if(submittedDt != null){
            dtVal = submittedDt.format('MM/dd/yyyy hh:mm:ss a');
        }
        
        if(submittedCnt == dayRecords.size() || approvedCnt == dayRecords.size()) {
            allSubmitted = true;
        }else {
            allSubmitted = false;
        }
        
        if(allSubmitted) {
            submitDetail.submittedMsg = 'Submitted for Approval on '+dtVal+'.';
        }else {
            submitDetail.submittedMsg = '';
        }
        
        
        //Project Student Name formation
        Map<Id,String> proIdStudentNames = new Map<Id,String>();
        
        for(AcctSeed__Project__c pro : projectRecords){
            String studentNames = '';
            if(pro.Contact_Assignments__r.size() > 0){
                for(Contact_Assignments__c ca : pro.Contact_Assignments__r){
                    if(String.isNotBlank(studentNames)){
                        studentNames += '; '+ca.Candidate_Name__r.FirstName+' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.';
                    }else {
                        studentNames = ca.Candidate_Name__r.FirstName+' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.';
                    }
                }
            }
            
            if(!proIdStudentNames.containsKey(pro.Id)){
                proIdStudentNames.put(pro.Id,studentNames);
            }
            
            if(notCompletedProIds.contains(pro.Id)){
                if(!nonCompletedProjects.containsKey(pro.Id)){
                    nonCompletedProjects.put(pro.Id,pro);
                }
            }
        }
        
        submitDetail.entries = entries;
        submitDetail.totalHrs = String.valueOf(totalHrs);
        submitDetail.allSubmitted = allSubmitted;
        submitDetail.displaySubmitBtn = displaySubmitBtn;
        submitDetail.proIdStudentNames = proIdStudentNames;
        submitDetail.notCompletedProjects = nonCompletedProjects;
        
        return submitDetail;
    }
    
    /**********************************************************************************************************************
    - Method to form mobile instructor time entry wrapper formation
    - Added by NS on Feb 7 2020 
    ***********************************************************************************************************************/
    public static TimeCardDayCommunityDomain.WeekSummaryDetail weekSummaryDetailFormation(Date startDate,Date endDate,String projectName,String studentNames,String contactId,List<AcctSeed__Time_Card_Line__c> lineDetails,List<Accounting_Seed_Time_Snapshot__c> snapshot,List<AcctSeed__Project_Task__c> taskRecords,List<Contact_Assignments__c> caRecord,Map<Id,Integer> taskIdTimeCount,Map<Id,String> taskIdTimeMap,List<Contact_Assignments__History> caHistory,List<AcctSeed__Cost_Rates__c> oldCRRecord,List<Contact_Assignments__c> studentCAs,List<Attendance__c> studentAttendanceList,Boolean alreadyCaseSubmitted,List<Planned_Days_Off__c> daysOffList,Set<Date> holidayDates,Map<Id,String> taskIdTimezone){
        
        TimeCardDayCommunityDomain.WeekSummaryDetail weekSummary = new TimeCardDayCommunityDomain.WeekSummaryDetail();
        
        weekSummary.summary = summaryDetailFormation(startDate,endDate,projectName,studentNames,lineDetails,taskRecords,caRecord,taskIdTimeCount,taskIdTimeMap,caHistory,oldCRRecord,taskIdTimezone);
        weekSummary.defaultCostRateRateType = taskRecords[0].AcctSeed__Project__r.Default_Cost_Rate_Rate_Type__c;

        
        List<TimeCardDayCommunityDomain.DayEntries> entriesList = new List<TimeCardDayCommunityDomain.DayEntries>();
        for(TimeCardDayCommunityDomain.SummaryDetail row : weekSummary.summary){
            if(row.dayEntries != null && row.dayEntries.size() > 0) {
                entriesList.addAll(row.dayEntries);
            }
        }
        
        //Btns display logic
        TimeCardDayCommunityDomain.ButtonDisplay btnDisplay = buttonDisplayFunction(entriesList,startDate,endDate);
        
        system.debug(':::::::btnDisplay::::'+btnDisplay);
        
        weekSummary.displaySubmitBtn = btnDisplay.submitBtn;
        weekSummary.displayRecallBtn = btnDisplay.recallBtn;
        weekSummary.displayRequestEditLink = btnDisplay.displayRequestEditLink;
        weekSummary.alreadyCaseSubmitted = alreadyCaseSubmitted;
        weekSummary.displayCompleteBtn = btnDisplay.completeBtn;
        
        Map<Date,String> dateInsColorMap = new Map<Date,String>();
        Map<Date,String> dateStudentColorMap = new Map<Date,String>();
        
         //Disable all the input field if the timesheet is submitted
        for(TimeCardDayCommunityDomain.SummaryDetail row : weekSummary.summary){
        
            if(row.dayEntries != null && row.dayEntries.size() > 0) {
                for(TimeCardDayCommunityDomain.DayEntries day : row.dayEntries){
                    if(btnDisplay.recallBtn && !day.isHrsDisabled){
                        day.isHrsDisabled = true;
                    }
                    
                    //to show edit icon for approved entries if there is a rejected entry exist
                    //W-004248
                    if(btnDisplay.showEditIconForApproved && !day.showEditIcon && !day.showReverseIcon 
                        && day.dayId != null){
                        
                        if(day.taskType != 'Preparation time' && day.status == 'Approved' || day.studentApprovalStatus == 'Approved') {
                            day.showReverseIcon = true;
                        }else {
                            day.showEditIcon = true;
                        }
                        
                    }
                    
                    if(day.taskType != 'Preparation time' && String.isNotBlank(day.color)){
                        dateInsColorMap.put(day.dateVal,day.color);
                    }

                    // to show edit icon for PTO , disable and Non-Editabe for Holiday
                    // W-007860 Modified by Vasanthram R
                    if(day.taskType == 'fringe' && (day.taskName == 'Fringe-PTO' || day.taskName == 'Fringe-Holiday' )) {
                        if(day.dayHours != null) {
                            day.showEditIcon = true;
                            day.isHrsDisabled = true;
                        } else {
                            day.showEditIcon = false;
                            day.isHrsDisabled = false;
                        }
                        day.showReverseIcon = false;
                        if( day.taskName == 'Fringe-Holiday') {
                            if(holidayDates.contains(day.dateVal)){
                                DateTime holidayDT = datetime.newInstance(day.dateVal, Time.newInstance(0,0,0,0));
                                String dayValue = holidayDT.format('E');// Exclude the 8 hours population for saturday and sunday if holidays occurs in saturday and sunday.

                                if(dayValue != 'Sat' && dayValue != 'Sun'){
                                    day.dayHours = 8 + '.00';
                                }
                            }
                            day.showEditIcon = false;
                            day.isHrsDisabled = true;
                        }
                    }
                }
            }
        }
        
        Boolean diableWholeStudentTime = false;
        if(btnDisplay.displayRequestEditLink || btnDisplay.recallBtn){
            diableWholeStudentTime = true;
        }
        system.debug('::::::::::diableWholeStudentTime::::'+diableWholeStudentTime);
        
        //Student time entry content formation
        Map<Date,List<TimeCardDayCommunityDomain.StudentEntry>> dateStudentEntries = mobileStudentTimeEntriesFormation(studentCAs,startDate,endDate,studentAttendanceList,diableWholeStudentTime,btnDisplay.showEditIconForApproved);
        
        //Date based notes formation
        Map<Date,List<TimeCardDayCommunityDomain.NotesDetails>> dateNotesEntry = mobileNotesFormation(startDate,endDate,snapshot);
        
        weekSummary.totalHrs = '0.00';
        
        Decimal weekTotal = 0.00;
        
        weekSummary.studentTotal = '0.00';
        Decimal stuTotal = 0.00;
        
        Boolean showStudentHrs = false;
        
        for(TimeCardDayCommunityDomain.SummaryDetail summary : weekSummary.summary){
            
            summary.studentEntries = new List<TimeCardDayCommunityDomain.StudentEntry>();
            
            summary.notes = new List<TimeCardDayCommunityDomain.NotesDetails>();
            
            summary.studentTotalHrs = '0.00';
            Decimal total = 0.00;
            
            //Student entry add
            if(dateStudentEntries.containsKey(summary.dateVal)){
                summary.studentEntries = dateStudentEntries.get(summary.dateVal);
                
                for(TimeCardDayCommunityDomain.StudentEntry stuEntry : summary.studentEntries){
                    if(String.isNotBlank(stuEntry.hours)){
                        total += Decimal.valueOf(stuEntry.hours);
                    }
                    
                    if(String.isNotBlank(stuEntry.color)){
                        dateStudentColorMap.put(stuEntry.dateVal,stuEntry.color);
                    }
                }
                
                summary.studentTotalHrs = String.valueOf(total);
            }
            
            //notes details add
            if(dateNotesEntry.containsKey(summary.dateVal)){
                summary.notes = dateNotesEntry.get(summary.dateVal);
            }
            
            weekTotal += Decimal.valueOf(summary.insTotalHrs);
            stuTotal += Decimal.valueOf(summary.studentTotalHrs);
            
            if(summary.studentEntries.size() > 0){
                showStudentHrs = true;
            }
            
            //instructor hours color
            if(dateInsColorMap.containsKey(summary.dateVal)){
                summary.instructorColor = dateInsColorMap.get(summary.dateVal);
            }
            
            //student hours color
            if(dateStudentColorMap.containsKey(summary.dateVal)){
                summary.studentColor = dateStudentColorMap.get(summary.dateVal);
            }
        }
        
        weekSummary.totalHrs = String.valueOf(weekTotal);
        
        weekSummary.studentTotal = String.valueOf(stuTotal);
        
        weekSummary.displayStudentHrs = showStudentHrs;
        
        //Check approved CR is Exist in the CA or not
        if(caRecord.size() > 0 && caRecord[0].Rate_Card_Rate__c != null){
            weekSummary.validCRExistINCA = true;
        }else if(caRecord.size() > 0 && caRecord[0].Rate_Card_Rate__c == null){
            weekSummary.validCRExistINCA = false;
        }
        
        if(daysOffList.size() > 0){
        
            Map<Date,TimeCardDayCommunityDomain.PlannedDaysOff> dateDaysOffValues = new Map<Date,TimeCardDayCommunityDomain.PlannedDaysOff>();
            
            for(Planned_Days_Off__c off : daysOffList){
                TimeCardDayCommunityDomain.PlannedDaysOff daysOff = new TimeCardDayCommunityDomain.PlannedDaysOff();
                daysOff.daysOffId = off.Id;
                daysOff.daysOffDate = String.valueOf(off.Date__c).split('-')[1]+'/'+String.valueOf(off.Date__c).split('-')[2]+'/'+String.valueOf(off.Date__c).split('-')[0];
                daysOff.contactName = off.Contact__r.Name;
                daysOff.description = off.Description__c;
                
                if(!dateDaysOffValues.containsKey(off.Date__c)){
                    dateDaysOffValues.put(off.Date__c,daysOff);
                }
            }
            
            weekSummary.dateDaysOffValues = dateDaysOffValues;
        
        }
        weekSummary.dliWLTHolidays = new List<Date>();
        weekSummary.dliWLTHolidays.addAll(holidayDates);
        weekSummary.federalHolidays = HolidayService.getHolidaysWithRecurrence(startDate,endDate);
        weekSummary.wholeNotes = notesFormation(snapshot);
        
        return weekSummary;
        
    }
    
    //Method to form summary information along with entry formation
    public static List<TimeCardDayCommunityDomain.SummaryDetail> summaryDetailFormation(Date st,Date ed,String projectName,String studentNames,List<AcctSeed__Time_Card_Line__c> timeCardLines,List<AcctSeed__Project_Task__c> taskRecords,List<Contact_Assignments__c> caRecord,Map<Id,Integer> taskIdTimeCount,Map<Id,String> taskIdTimeMap,List<Contact_Assignments__History> caHistory,List<AcctSeed__Cost_Rates__c> oldCRRecord,Map<Id,String> taskIdTimezone){
        
        List<TimeCardDayCommunityDomain.SummaryDetail> summaryDetail = new List<TimeCardDayCommunityDomain.SummaryDetail>();
        
        Map<Date,Map<Id,TimeCardDayCommunityDomain.DayEntries>> dateTaskIdEntryMap = new Map<Date,Map<Id,TimeCardDayCommunityDomain.DayEntries>>();
        Set<Date> weekDates = new Set<Date>();
        
        Set<Date> federalHolidays = HolidayService.getHolidaysWithRecurrence(st, ed);

        Map<Id,Boolean> taskIdLineCompleted = new Map<Id,Boolean>();
        
        Date startDt = st;
        Date endDt = ed;
        
        //check selected week range is before last week
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        Date previuosWkStart = currStart.addDays(-7);
        Date previuosWkEnd = currEnd.addDays(-7);
        
        Date isOlderThanLast2WeekStart = currStart.addDays(-14);
        Date isOlderThanLast2WeekEnd = currEnd.addDays(-14);
        
        
        Boolean isCurrentWeek = false;
        Boolean isBeforeLastWeek = false;
        
        if(startDt == currStart && endDt == currEnd) {
            isCurrentWeek = true;
        }
        
        if(startDt <= isOlderThanLast2WeekStart && endDt <= isOlderThanLast2WeekEnd){
            isBeforeLastWeek = true;
        }
        
        while(startDt <= endDt){
            system.debug('startDt::::'+startDt);
            
            weekDates.add(startDt);
            
            startDt = startDt.addDays(1);
        }
        
        Map<Date,Boolean> dateLateCancellationMap = new Map<Date,Boolean>();
        
        system.debug(':::::::::::::weekDates:::::::::'+weekDates);
        
        Integer totalRecCnt = 0;
        Integer submitCnt = 0;
        Integer approvedCnt = 0;
        
        String tclLocationId = '';
        String tclLocationName = '';
        
        EventHandler eveHandler = new EventHandler();
        
         //Existing records based date & day wrapper map formation
        for(AcctSeed__Time_Card_Line__c line : timeCardLines) {
            
            //For Line completed check for other non created entries
            if(!taskIdLineCompleted.containsKey(line.AcctSeed__Project_Task__c)){
                taskIdLineCompleted.put(line.AcctSeed__Project_Task__c,line.Completed__c);
            }
            
            tclLocationId = line.Location__c;
            tclLocationName = line.Location__r.Name;
            
            if(line.AcctSeed__Time_Card_Days__r != null || line.AcctSeed__Time_Card_Days__r.size() > 0) {
                
                for(AcctSeed__Time_Card_Day__c day : line.AcctSeed__Time_Card_Days__r) {
                    
                    TimeCardDayCommunityDomain.DayEntries dayWrap = new TimeCardDayCommunityDomain.DayEntries();
                    
                    dayWrap.hours = day.Total_Hours_Before_Approved__c;
                    dayWrap.dayHours = String.valueOf(day.Total_Hours_Before_Approved__c);
                    if(!dayWrap.dayHours.contains('.')){
                        dayWrap.dayHours = dayWrap.dayHours+'.00';
                    }
                    
                    dayWrap.dayId = day.Id;
                    dayWrap.lineId = day.AcctSeed__Time_Card_Line__c;
                    dayWrap.projectId = line.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                    dayWrap.taskId = line.AcctSeed__Project_Task__c;
                    dayWrap.locationId = line.Location__c;
                    dayWrap.isBillable = line.AcctSeed__Billable__c;
                    dayWrap.payrollItem = line.Payroll_Item__c;
                    dayWrap.status = day.Status__c;
                    dayWrap.dateVal = day.AcctSeed__Date__c;
                    dayWrap.comments = day.AcctSeed__Internal_Comment__c;
                    dayWrap.costrateId = line.Labor_Cost_Rate__c;
                    dayWrap.contactAssignid = line.Contact_Assignment__c;
                    dayWrap.sequenceNumber = Integer.valueOf(line.Sequence_Number__c);
                    dayWrap.cancellationReason = day.Cancellation_Reason__c;
                    dayWrap.startTime1 = day.Start_Time1__c;
                    dayWrap.endTime1 = day.End_Time1__c;
                    dayWrap.locationId = line.Location__c;
                    dayWrap.TaskType = line.AcctSeed__Project_Task__r.Project_Task_Type__c;
                    dayWrap.lateCancellation = day.Late_Cancellation__c;
                    dayWrap.studentApprovalStatus = day.Student_Approval_Status__c;
                    dayWrap.ProjectName = projectName;
                    dayWrap.TaskName = line.AcctSeed__Project_Task__r.Name;
                    dayWrap.recallReason = day.Recall_Reason__c;
                    
                    dayWrap.startTime1Minutes = eveHandler.convertToMinutes(day.Start_Time1__c);
                    dayWrap.endTime1Minutes = eveHandler.convertToMinutes(day.End_Time1__c);
                    
                    
                    if(line.AcctSeed__Project_Task__r.Name == 'Language Training- Preparation' && line.AcctSeed__Project_Task__r.Project_Task_Type__c == 'Preparation time') {
                        dayWrap.startTime2 = day.Start_Time2__c;
                        dayWrap.endTime2 = day.End_Time2__c;
                        
                        dayWrap.startTime2Minutes = eveHandler.convertToMinutes(day.Start_Time2__c);
                        dayWrap.endTime2Minutes = eveHandler.convertToMinutes(day.End_Time2__c);
                    }
                    
                    dayWrap.isNew = false;
                    dayWrap.isUpdated = false;
                    dayWrap.displayDate = String.valueOf(day.AcctSeed__Date__c).split('-')[1]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[2]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[0];
                    
                    DateTime actualDt = DateTime.newInstance(day.AcctSeed__Date__c, Time.newInstance(0, 0, 0, 0));
                    dayWrap.dayType = actualDt.format('EEEE');
                    
                    dayWrap.showEditIcon = false;
                    dayWrap.showReverseIcon = false;
                    
                    //For TCL based input disable action
                    dayWrap.isCompleted = line.Completed__c ? line.Completed__c : false;
                    dayWrap.isUnposted = false;
                    
                    //Input values disable based on date & Supervisor Status field
                    if(dayWrap.dateVal > system.today()){
                        dayWrap.isHrsDisabled = true;
                    }else {
                        dayWrap.isHrsDisabled = hrsDisableFunction(dayWrap,isCurrentWeek,isBeforeLastWeek);
                    }
                    
                    //Student Approval Status related colour coding for input
                    if(dayWrap.TaskType != 'Preparation time' && dayWrap.status != 'Rejected'){
                        if(dayWrap.studentApprovalStatus == 'Approved'){
                            dayWrap.color = 'Green';
                        }else if(dayWrap.studentApprovalStatus == 'Rejected'){
                            dayWrap.color = 'Red';
                        }
                    }
                    
                    //Edit Icon display related conditions
                    dayWrap.showEditIcon = editIconDisplay(dayWrap,isCurrentWeek,isBeforeLastWeek);
                    
                    //Reverse Icon display related conditions
                    dayWrap.showReverseIcon = reverseIconDisplay(dayWrap,isCurrentWeek,isBeforeLastWeek);
                    
                    if(day.Late_Cancellation__c){
                        dateLateCancellationMap.put(day.AcctSeed__Date__c,day.Late_Cancellation__c);
                    }
                    
                    //To use for last week hrs disable, if there is no entry on that date
                    if(dayWrap.status == 'Submitted'){
                        submitCnt += 1;
                    }else if(dayWrap.status == 'Approved' || dayWrap.status == 'Admin Approved'){
                        approvedCnt += 1;
                    }
                    
                    if(taskIdTimezone.containsKey(line.AcctSeed__Project_Task__c)){
                        dayWrap.scheduleTimezone = taskIdTimezone.get(line.AcctSeed__Project_Task__c);
                    }
                    
                    totalRecCnt += 1;
                    
                    if(!dateTaskIdEntryMap.containsKey(day.AcctSeed__Date__c)) {
                        
                        dateTaskIdEntryMap.put(day.AcctSeed__Date__c,new Map<Id,TimeCardDayCommunityDomain.DayEntries>{line.AcctSeed__Project_Task__c => dayWrap});
                    
                    }else if(dateTaskIdEntryMap.containsKey(day.AcctSeed__Date__c) 
                        && !dateTaskIdEntryMap.get(day.AcctSeed__Date__c).containsKey(line.AcctSeed__Project_Task__c)){
                        
                        dateTaskIdEntryMap.get(day.AcctSeed__Date__c).put(line.AcctSeed__Project_Task__c,dayWrap);
                    }
                    
                }
            }
        }
        system.debug('::::::::dateTaskIdEntryMap:::::'+dateTaskIdEntryMap);
        
        system.debug(':::::::tclLocationId::::::::'+tclLocationId);
        system.debug(':::::::tclLocationName::::::::'+tclLocationName);
        
        
        
        List<TimeCardDayCommunityDomain.SummaryDetail> tempDetailsList = new List<TimeCardDayCommunityDomain.SummaryDetail>();
        List<Integer> seqNumbers = new List<Integer>();
        
        for(Date dt : weekDates){
            
            Integer sequenceNum = 0;
            
            TimeCardDayCommunityDomain.SummaryDetail summary = new TimeCardDayCommunityDomain.SummaryDetail();
            
            summary.dateVal = dt;
            summary.dateToDisplay = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0].right(2);
            
            summary.displayDate = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0];
            
            //date type finding - mon, tues, ...
            DateTime currentDt = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0));
            summary.dayType = currentDt.format('EEE').toUpperCase();
            
            summary.dayValue = currentDt.format('EEEE').toUpperCase();
            
            summary.dayEntries = new List<TimeCardDayCommunityDomain.DayEntries>();
            
            summary.insTotalHrs = '0.00';
            
            Decimal totalHr = 0.00;
            
            
            for(AcctSeed__Project_Task__c task : taskRecords){
                
                String chargeCode1 = projectName+' / <b>'+task.Name+'</b> / ';
                String chargeCode2 = '';
                
                //To fix the duplicate TCL Creation when project location is changed mid of the week
                if(String.isNotBlank(tclLocationId) && tclLocationId != task.AcctSeed__Project__r.Training_Location__c){
                    chargeCode2 = studentNames+' / '+tclLocationName;
                }else {
                    chargeCode2 = studentNames+' / '+task.AcctSeed__Project__r.Training_Location__r.Name;
                }
                
                Integer sequenceNumber = 0;
                
                if(task.Project_Task_Type__c == 'Language Training') {
                    if(sequenceNumber == 0){
                        sequenceNumber = 1;    
                    }else {
                        sequenceNumber = sequenceNumber + 1;
                    }
                
                }else if(task.Project_Task_Type__c == 'Preparation time'){
                    if(sequenceNumber == 1){
                        sequenceNumber = 2;    
                    }else {
                        sequenceNumber = sequenceNumber + 1;
                    }
                
                }else if(task.Project_Task_Type__c == 'Language Testing') {
                    if(sequenceNumber == 2){
                        sequenceNumber = 3;    
                    }else {
                        sequenceNumber = sequenceNumber + 1;
                    }
                
                }else {
                    sequenceNumber = sequenceNumber + 1;
                }
                
                //If already time exist for this date
                if(dateTaskIdEntryMap.containsKey(dt)){
                    
                    if(dateTaskIdEntryMap.get(dt).containsKey(task.Id)){
                    
                        TimeCardDayCommunityDomain.DayEntries day = dateTaskIdEntryMap.get(dt).get(task.Id);
                        
                        day.chargeCode1 = chargeCode1;
                        day.chargeCode2 = chargeCode2;
                        
                        if(task.Project_Task_Type__c == 'Preparation time' && taskIdTimeCount.containsKey(task.Id)){
                            day.timeRowCount = taskIdTimeCount.get(task.Id);
                            
                            if(taskIdTimeCount.get(task.Id) != 1 && taskIdTimeMap.containsKey(task.Id)){
                                day.timeType = taskIdTimeMap.get(task.Id);
                            }else if(taskIdTimeCount.get(task.Id) == 1){
                                day.timeType = 'Single';
                            }
                            
                        }else if(task.Project_Task_Type__c != 'Preparation time'){
                            day.timeRowCount = 1;
                            day.timeType = 'AM';
                        }
                        
                        if(taskIdTimezone.containsKey(task.Id)){
                            day.scheduleTimezone = taskIdTimezone.get(task.Id);
                        }
                        
                        totalHr += Decimal.valueOf(day.dayHours);
                        
                        summary.dayEntries.add(day);
                        
                    }else {
                        
                        TimeCardDayCommunityDomain.DayEntries day = new TimeCardDayCommunityDomain.DayEntries();
                        
                        day.chargeCode1 = chargeCode1;
                        day.chargeCode2 = chargeCode2;
                        
                        day.projectId = task.AcctSeed__Project__c;
                        day.taskId = task.Id;
                        
                        if(String.isNotBlank(tclLocationId) && tclLocationId != task.AcctSeed__Project__r.Training_Location__c){
                            day.locationId = tclLocationId;
                        }else {
                            day.locationId = task.AcctSeed__Project__r.Training_Location__c;
                        }
                        
                        day.isBillable = task.Billable__c;
                        day.sequenceNumber = sequenceNumber;
                        day.isNew = true;
                        day.isUpdated = false;
                        day.taskType = task.Project_Task_Type__c;
                        day.lateCancellation = false;
                        day.taskName = task.Name;
                        day.dateVal = dt;
                        day.displayDate = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0];
                        
                        if(day.dateVal > system.today() || isBeforeLastWeek) {
                            day.isHrsDisabled = true;
                            
                        }else if(totalRecCnt != 0 && (submitCnt == totalRecCnt ||  approvedCnt == totalRecCnt)) {
                            day.isHrsDisabled = true;
                        
                        } else {
                            day.isHrsDisabled = false;
                        }
                        
                        day.showEditIcon = false;
                        day.showReverseIcon = false;
                        day.isCompleted = taskIdLineCompleted.containsKey(task.Id) ? taskIdLineCompleted.get(task.Id) : false;
                        day.isUnposted = false;
                        
                        //Payroll, CR values assigning
                        if(caHistory.size() == 0 || (caHistory.size() > 0 && caHistory[0].OldValue == null)){
                            if(caRecord.size() > 0 && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c 
                            || task.Project_Task_Type__c == 'Fringe') && caRecord[0].Rate_Card_Rate__c != null){
                                    
                                system.debug('::::::::if:::1::');
                                
                                for(Contact_Assignments__c ca : caRecord){
                                    Date oralExamDate;
                                    if(ca.Oral_Exam_Date_Time__c != null){
                                        oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                                    }
                                    Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                                    if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                                        day.costrateId = (Id) ca.Rate_Card_Rate__c;
                                        day.contactAssignid = (Id) ca.Id;
                                        
                                        if(day.isBillable){
                                            day.payrollItem = ca.Rate_Card_Rate__r.Payroll_Item__c;
                                        }else {
                                            day.payrollItem = ca.Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                                        }
                                    }
                                }
                            }
                        }else if(caHistory.size() > 0 && caRecord.size() > 0 
                                && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c
                                    || task.Project_Task_Type__c == 'Fringe')){
                            
                            system.debug('::::::::else:::1::');
                                
                            Date historyDate = Date.newInstance(caHistory[0].createdDate.year(),caHistory[0].createdDate.month(),caHistory[0].createdDate.day());
                            
                            system.debug('::::::dt:::::'+dt);
                            system.debug('::::::historyDate:::::'+historyDate);
                            
                            if(dt <= historyDate && caHistory[0].OldValue != null){
                            
                                day.contactAssignid = (Id) caHistory[0].parentId;
                                
                                if(oldCRRecord.size() > 0){
                                    day.costrateId =  oldCRRecord[0].Id;
                                    
                                    if(oldCRRecord[0].Id == day.costrateId){
                                        if(day.isBillable){
                                            day.payrollItem = oldCRRecord[0].Payroll_Item__c;
                                        }else {
                                            day.payrollItem = oldCRRecord[0].Non_Billable_Payroll_Item__c;
                                        }
                                    }
                                }
                            }else {    //If the history date is older then populate current CR value
                                
                                system.debug('::::::::else:::2::');
                                
                                if(caRecord.size() > 0 && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c
                                    || task.Project_Task_Type__c == 'Fringe') && caRecord[0].Rate_Card_Rate__c != null){
                                    
                                    system.debug('::::inside::else:::::2::');
                                    
                                    for(Contact_Assignments__c ca : caRecord){
                                        Date oralExamDate;
                                        if(ca.Oral_Exam_Date_Time__c != null){
                                            oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                                        }
                                        Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                                        if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                                            day.costrateId = (Id) ca.Rate_Card_Rate__c;
                                            day.contactAssignid = (Id) ca.Id;
                                            
                                            if(day.isBillable){
                                                day.payrollItem = ca.Rate_Card_Rate__r.Payroll_Item__c;
                                            }else {
                                                day.payrollItem = ca.Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                                            }
                                        }
                                    }
                                }
                            }

                            //to add payroll from Project Task
                            //W-007860 Modified by Vasanthram R
                            if(task.Project_Task_Type__c == 'Fringe'){
                                day.payrollItem = task.Payroll_Item__c;
                            }

                        }
                        
                        //For Fringe Project Task get payroll item from project task
                        if(task.RecordType.DeveloperName == 'Cost' && task.Project_Task_Type__c == 'Fringe'){
                            day.payrollItem = task.Payroll_Item__c;
                        }
                        
                        /*system.debug('::::::::payrollItem:::'+day.payrollItem);
                        system.debug('::::::::contactassignment:::'+day.contactAssignid);
                        system.debug('::::::::costrateId:::'+day.costrateId);*/
                        
                         //W-005456 - added ESL LT Projects record type for ELT Pilot program
                        
                        if(dateLateCancellationMap.containsKey(dt) && task.Project_Task_Type__c == 'Preparation time' 
                            && task.AcctSeed__Project__r.RecordType.DeveloperName != 'DODA_Projects' 
                            && task.AcctSeed__Project__r.RecordType.DeveloperName != 'DLI_W_LT_Projects'
                            && task.AcctSeed__Project__r.RecordType.DeveloperName != 'ESL_LT_Projects'){
                            
                            day.isHrsDisabled = true; 
                        }

                        if(day.TaskType == 'fringe' && (day.TaskName == 'Fringe-PTO' || day.TaskName == 'Fringe-Holiday')) {
                            if(day.TaskName == 'Fringe-Holiday'){
                                DateTime holidayDT = datetime.newInstance(dt, Time.newInstance(0,0,0,0));
                                String dayValue = holidayDT.format('E');// Exclude the 8 hours population for saturday and sunday if holidays occurs in saturday and sunday.
                                
                                if(dayValue != 'Sat' && dayValue != 'Sun'){
                                    
                                    if(federalHolidays.contains(day.dateVal)){
                                        day.hours = 8;
                                        day.dayHours = 8 + '.00';
                                    }
                                }
                                day.isHrsDisabled = true;
                            }
                            day.showEditIcon = false;
                            day.showReverseIcon = false;
                        }
                        
                        if(day.hours != null){
                            totalHr += Decimal.valueOf(day.dayHours);
                        }
                        
                        if(task.Project_Task_Type__c == 'Preparation time' && taskIdTimeCount.containsKey(task.Id)){
                            day.timeRowCount = taskIdTimeCount.get(task.Id);
                            
                            if(taskIdTimeCount.get(task.Id) != 1 && taskIdTimeMap.containsKey(task.Id)){
                                day.timeType = taskIdTimeMap.get(task.Id);
                            }else if(taskIdTimeCount.get(task.Id) == 1){
                                day.timeType = 'Single';
                            }
                            
                        }else if(task.Project_Task_Type__c != 'Preparation time'){
                            day.timeRowCount = 1;
                            day.timeType = 'AM';
                        }
                        
                        if(taskIdTimezone.containsKey(task.Id)){
                            day.scheduleTimezone = taskIdTimezone.get(task.Id);
                        }
                        
                        summary.dayEntries.add(day);
                        
                    }
                    
                }else {    //no time for this date
                    
                    TimeCardDayCommunityDomain.DayEntries day = new TimeCardDayCommunityDomain.DayEntries();
                        
                    day.chargeCode1 = chargeCode1;
                    day.chargeCode2 = chargeCode2;
                    
                    day.projectId = task.AcctSeed__Project__c;
                    day.taskId = task.Id;
                    
                    if(String.isNotBlank(tclLocationId) && tclLocationId != task.AcctSeed__Project__r.Training_Location__c){
                        day.locationId = tclLocationId;
                    }else {
                        day.locationId = task.AcctSeed__Project__r.Training_Location__c;
                    }
                    
                    day.isBillable = task.Billable__c;
                    day.sequenceNumber = sequenceNumber;
                    day.isNew = true;
                    day.isUpdated = false;
                    day.taskType = task.Project_Task_Type__c;
                    day.lateCancellation = false;
                    day.taskName = task.Name;
                    day.dateVal = dt;
                    day.displayDate = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0];
                    
                    if(day.dateVal > system.today() || isBeforeLastWeek) {
                        day.isHrsDisabled = true;
                        
                    }else if(totalRecCnt != 0 && (submitCnt == totalRecCnt ||  approvedCnt == totalRecCnt)) {
                        day.isHrsDisabled = true;
                    
                    } else {
                        day.isHrsDisabled = false;
                    }
                    
                    day.showEditIcon = false;
                    day.showReverseIcon = false;
                    day.isCompleted = taskIdLineCompleted.containsKey(task.Id) ? taskIdLineCompleted.get(task.Id) : false;
                    day.isUnposted = false;
                    
                    //Payroll, CR values assigning
                    if(caHistory.size() == 0 || (caHistory.size() > 0 && caHistory[0].OldValue == null)){
                        if(caRecord.size() > 0 && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c || task.Project_Task_Type__c == 'Fringe') 
                                && caRecord[0].Rate_Card_Rate__c != null){
                                
                            
                            for(Contact_Assignments__c ca : caRecord){
                                Date oralExamDate;
                                if(ca.Oral_Exam_Date_Time__c != null){
                                    oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                                }
                                Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                                if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                                    day.costrateId = (Id) ca.Rate_Card_Rate__c;
                                    day.contactAssignid = (Id) ca.Id;
                                    
                                    if(day.isBillable){
                                        day.payrollItem = ca.Rate_Card_Rate__r.Payroll_Item__c;
                                    }else {
                                        day.payrollItem = ca.Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                                    }
                                }
                            }
                        }
                    }else if(caHistory.size() > 0 && caRecord.size() > 0 
                            && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c
                             || task.Project_Task_Type__c == 'Fringe')){
                        
                        system.debug('::::::::else:::1::');
                            
                        Date historyDate = Date.newInstance(caHistory[0].createdDate.year(),caHistory[0].createdDate.month(),caHistory[0].createdDate.day());
                        
                        system.debug('::::::dt:::::'+dt);
                        system.debug('::::::historyDate:::::'+historyDate);
                        
                        if(dt <= historyDate && caHistory[0].OldValue != null){
                        
                            day.contactAssignid = (Id) caHistory[0].parentId;
                            
                            if(oldCRRecord.size() > 0){
                                day.costrateId = oldCRRecord[0].Id;
                                
                                if(oldCRRecord[0].Id == day.costrateId){
                                    if(day.isBillable){
                                        day.payrollItem = oldCRRecord[0].Payroll_Item__c;
                                    }else {
                                        day.payrollItem = oldCRRecord[0].Non_Billable_Payroll_Item__c;
                                    }
                                }
                            }
                        }else {    //If the history date is older then populate current CR value
                            
                            system.debug('::::::::else:::2::');
                            
                            if(caRecord.size() > 0 && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c
                             || task.Project_Task_Type__c == 'Fringe') && caRecord[0].Rate_Card_Rate__c != null){
                                
                                system.debug('::::inside::else:::::2::');
                                
                                for(Contact_Assignments__c ca : caRecord){
                                    Date oralExamDate;
                                    if(ca.Oral_Exam_Date_Time__c != null){
                                        oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                                    }
                                    Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                                    if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                                        day.costrateId = (Id) ca.Rate_Card_Rate__c;
                                        day.contactAssignid = (Id) ca.Id;
                                        
                                        if(day.isBillable){
                                            day.payrollItem = ca.Rate_Card_Rate__r.Payroll_Item__c;
                                        }else {
                                            day.payrollItem = ca.Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    //For Fringe Project Task get payroll item from project task
                    if(task.RecordType.DeveloperName == 'Cost' && task.Project_Task_Type__c == 'Fringe'){
                        day.payrollItem = task.Payroll_Item__c;
                    }

                    //For Fringe Project Task get payroll item from project task
                    // W-007860 - Modified by Vasanthram R
                    if(task.Project_Task_Type__c == 'Fringe'){
                        day.payrollItem = task.Payroll_Item__c;
                    }
                    
                    /*system.debug('::::::::payrollItem:::'+day.payrollItem);
                    system.debug('::::::::contactassignment:::'+day.contactAssignid);
                    system.debug('::::::::costrateId:::'+day.costrateId);*/
                    
                     //W-005456 - added ESL LT Projects record type for ELT Pilot program
                    
                    if(dateLateCancellationMap.containsKey(dt) && task.Project_Task_Type__c == 'Preparation time' 
                        && task.AcctSeed__Project__r.RecordType.DeveloperName != 'DODA_Projects' 
                        && task.AcctSeed__Project__r.RecordType.DeveloperName != 'DLI_W_LT_Projects'
                        && task.AcctSeed__Project__r.RecordType.DeveloperName != 'ESL_LT_Projects'){
                        
                        day.isHrsDisabled = true; 
                    }

                    if(day.TaskType == 'fringe' && (day.TaskName == 'Fringe-PTO' || day.TaskName == 'Fringe-Holiday')) {
                        if(day.TaskName == 'Fringe-Holiday'){
                            DateTime holidayDT = datetime.newInstance(dt, Time.newInstance(0,0,0,0));
                            String dayValue = holidayDT.format('E');// Exclude the 8 hours population for saturday and sunday if holidays occurs in saturday and sunday.
                            
                            if(dayValue != 'Sat' && dayValue != 'Sun'){
                                if(federalHolidays.contains(day.dateVal)){
                                    day.dayHours = 8 + '.00';
                                    day.hours = 8;
                                }
                            }
                            day.isHrsDisabled = true;
                        }
                        day.showEditIcon = false;
                        day.showReverseIcon = false;
                    }
                    
                    if(day.hours != null){
                        totalHr += Decimal.valueOf(day.dayHours);
                    }
                    
                    if(task.Project_Task_Type__c == 'Preparation time' && taskIdTimeCount.containsKey(task.Id)){
                        day.timeRowCount = taskIdTimeCount.get(task.Id);
                        
                        if(taskIdTimeCount.get(task.Id) != 1 && taskIdTimeMap.containsKey(task.Id)){
                            day.timeType = taskIdTimeMap.get(task.Id);
                        }else if(taskIdTimeCount.get(task.Id) == 1){
                            day.timeType = 'Single';
                        }
                        
                    }else if(task.Project_Task_Type__c != 'Preparation time'){
                        day.timeRowCount = 1;
                        day.timeType = 'AM';
                    }
                    
                    if(taskIdTimezone.containsKey(task.Id)){
                        day.scheduleTimezone = taskIdTimezone.get(task.Id);
                    }
                    
                    summary.dayEntries.add(day);
                }
                
            }
            
            summary.insTotalHrs = String.valueOf(totalHr);
            
            summaryDetail.add(summary);
        }
        
        system.debug(':::::::::::summaryDetail:::::::::::::'+summaryDetail);
        
        return summaryDetail;
    }
    
    //Method to form the student information based on date for mobile instructor time entry
    public static Map<Date,List<TimeCardDayCommunityDomain.StudentEntry>> mobileStudentTimeEntriesFormation(List<Contact_Assignments__c> studentCAs,Date st,Date ed,List<Attendance__c> studentAttendanceList,Boolean disbleWholeHrs,Boolean showEditIconBasedOnTCD){
    
        Map<Date,Map<Id,TimeCardDayCommunityDomain.StudentEntry>> dateStudentIdEntryMap = new Map<Date,Map<Id,TimeCardDayCommunityDomain.StudentEntry>>();
        
        Map<Date,List<TimeCardDayCommunityDomain.StudentEntry>> dateStudentEntries = new Map<Date,List<TimeCardDayCommunityDomain.StudentEntry>>();
        
        Date startDt = st;
        Date endDt = ed;
        
        //check for before last week if selected date range
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        Date previuosWkStart = currStart.addDays(-7);
        Date previuosWkEnd = currEnd.addDays(-7);
        
        Date isOlderThanLast2WeekStart = previuosWkStart.addDays(-14);
        Date isOlderThanLast2WeekEnd = currEnd.addDays(-14);
        
        Boolean isCurrentWeek = false;
        Boolean isBeforeLastWeek = false;
        
        if(startDt == currStart && endDt == currEnd) {
            isCurrentWeek = true;
        }
        
        if(startDt <= isOlderThanLast2WeekStart && endDt <= isOlderThanLast2WeekEnd){
            isBeforeLastWeek = true;
        }
        
        system.debug(':::::::::isCurrentWeek::::'+isCurrentWeek);
        system.debug(':::::::::isBeforeLastWeek::::'+isBeforeLastWeek);
        
        Set<Date> weekDates = new Set<Date>();
        
        while(startDt <= endDt){
            weekDates.add(startDt);
            startDt = startDt.addDays(1);
        }
        
        for(Attendance__c att : studentAttendanceList){
        
            TimeCardDayCommunityDomain.StudentEntry entry = new TimeCardDayCommunityDomain.StudentEntry();
            entry.dateVal = att.Date__c;
            
            DateTime attDate = DateTime.newInstance(att.Date__c, Time.newInstance(0, 0, 0, 0));
            entry.dayValue = attDate.format('EEEE');
            
            entry.displayDate = String.valueOf(att.Date__c).split('-')[1]+'/'+String.valueOf(att.Date__c).split('-')[2]+'/'+String.valueOf(att.Date__c).split('-')[0];
            
            entry.hours = String.valueOf(att.Duration__c);
            entry.attendanceId = att.Id;
            entry.eventId = att.Event__c;
            entry.instructorId = att.Instructor__c;
            entry.studentId = att.Student__c;
            entry.studentApprovalStatus = att.Student_Approval_Status__c;
            entry.dayId = att.Time_Card_Day__c;
            entry.isNew = false;
            entry.isUpdated = false;
            entry.rejectionReason = att.Rejection_Reason__c;
            entry.recallReason = att.Recall_Reason__c;
            entry.comments = att.Comments__c;
            entry.studentName = att.Student__r.Name;
            entry.lateCancellation = att.Time_Card_Day__r.Late_Cancellation__c;
            entry.attendance = att.Attendance__c;
            
            if(!isBeforeLastWeek || isCurrentWeek) {
                
                if(att.Date__c > system.today()){
                    entry.isHrsDisabled = true;
                }else if(att.Student_Approval_Status__c != null) {
                    entry.isHrsDisabled = true;
                }else if(disbleWholeHrs){
                    entry.isHrsDisabled = true;
                }else {
                    entry.isHrsDisabled = false;
                }
                
                if(att.Student_Approval_Status__c != 'Approved' && (att.Time_Card_Day__r.Status__c != 'Approved' && att.Time_Card_Day__r.Status__c != 'Submitted' 
                        && att.Time_Card_Day__r.Status__c != 'Admin Approved')){
                        
                    entry.showEditIcon = true;
                    
                    if(att.Student_Approval_Status__c == 'Rejected'){
                        entry.color = 'Red';
                    }
                    
                }else {
                    if(att.Time_Card_Day__r.Status__c != 'Approved' && att.Time_Card_Day__r.Status__c != 'Submitted' 
                        && att.Time_Card_Day__r.Status__c != 'Admin Approved') {
                        entry.showReverseIcon = true;
                    }else {
                        entry.showReverseIcon = false;
                    }
                    
                    entry.showEditIcon = false; 
                    
                    if(att.Student_Approval_Status__c == 'Approved'){
                        entry.color = 'Green';
                    }
                    
                    if(att.Student_Approval_Status__c == 'Rejected'){
                        entry.color = 'Red';
                    }
                }
                
                if(att.Comments__c != null /*&& att.Time_Card_Day__r.Total_Hours_Before_Approved__c != att.Duration__c*/){
                    entry.displayNotesLink = 'true';
                }else {
                    entry.displayNotesLink = 'false';
                }
                
                //show edit for student based on TCD status value
                //If approved tcd is present with rejected entry, then show edit icon for all approved tcd
                if(showEditIconBasedOnTCD && entry.studentId != null && !entry.showEditIcon && !entry.showReverseIcon){
                    
                    if(att.Student_Approval_Status__c == 'Approved'){
                        entry.showReverseIcon = true;
                    }else {
                        entry.showEditIcon = true;
                    }
                }
                
            }else {
                entry.showReverseIcon = false;
                entry.showEditIcon = false;
                entry.isHrsDisabled = true;
            }
            
            if(!dateStudentIdEntryMap.containsKey(att.Date__c)){
                dateStudentIdEntryMap.put(att.Date__c,new Map<Id,TimeCardDayCommunityDomain.StudentEntry>{att.Student__c => entry});
            
            }else if(dateStudentIdEntryMap.containsKey(att.Date__c) && !dateStudentIdEntryMap.get(att.Date__c).containsKey(att.Student__c)){
                
                dateStudentIdEntryMap.get(att.Date__c).put(att.Student__c,entry);
            }
        }
        
        system.debug('::::::::dateStudentIdEntryMap::::::::::::'+dateStudentIdEntryMap);
        
        for(Date dt : weekDates){
            
            List<TimeCardDayCommunityDomain.StudentEntry> entries = new List<TimeCardDayCommunityDomain.StudentEntry>();
            
            for(Contact_Assignments__c ca : studentCAs){
                
                if(dateStudentIdEntryMap.containsKey(dt)){
                    
                    if(dateStudentIdEntryMap.get(dt).containsKey(ca.Candidate_Name__c)){
                        
                        TimeCardDayCommunityDomain.StudentEntry stuEntries = dateStudentIdEntryMap.get(dt).get(ca.Candidate_Name__c);
                        stuEntries.studentId = ca.Candidate_Name__c;
                        stuEntries.studentName = ca.Candidate_Name__r.Name;
                        
                        entries.add(stuEntries);
                        
                    }else {
                        
                        TimeCardDayCommunityDomain.StudentEntry entry = new TimeCardDayCommunityDomain.StudentEntry();
                        entry.dateVal = dt;
                        
                        DateTime attDate = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0));
                        entry.dayValue = attDate.format('EEEE');
                        
                        entry.displayDate = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0];
                        
                        entry.hours = '';
                        entry.attendanceId = null;
                        entry.eventId = null;
                        entry.instructorId = null;
                        entry.studentId = ca.Candidate_Name__c;
                        entry.studentApprovalStatus = '';
                        entry.dayId = null;
                        entry.isNew = true;
                        entry.isUpdated = false;
                        
                        if(!isBeforeLastWeek || isCurrentWeek) {
                        
                            //W-004824 - student hours disable based on CA end date
                            
                            if(dt > system.today() || (ca.Status__c == 'Ended' && dt > ca.End_Date__c) 
                                || (ca.Status__c != 'Ended' && dt < ca.Start_Date__c)){
                                
                                entry.isHrsDisabled = true;
                            }else if(disbleWholeHrs){
                                entry.isHrsDisabled = true;
                            }else {
                                entry.isHrsDisabled = false;
                            }
                        }else {
                            entry.isHrsDisabled = true;
                        }
                        
                        entry.showReverseIcon = false;
                        entry.showEditIcon = false;
                        entry.rejectionReason = '';
                        entry.recallReason = '';
                        entry.comments = '';
                        entry.studentName = ca.Candidate_Name__r.Name;
                        entry.displayNotesLink = 'false';
                        
                        entries.add(entry);
                    }
                    
                }else {
                
                    TimeCardDayCommunityDomain.StudentEntry entry = new TimeCardDayCommunityDomain.StudentEntry();
                    entry.dateVal = dt;
                    
                    DateTime attDate = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0));
                    entry.dayValue = attDate.format('EEEE');
                    
                    entry.displayDate = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0];
                    
                    entry.hours = '';
                    entry.attendanceId = null;
                    entry.eventId = null;
                    entry.instructorId = null;
                    entry.studentId = ca.Candidate_Name__c;
                    entry.studentApprovalStatus = '';
                    entry.dayId = null;
                    entry.isNew = true;
                    entry.isUpdated = false;
                    
                    if(!isBeforeLastWeek || isCurrentWeek) {
                    
                        //W-004824 - student hours disable based on CA end date
                        
                        if(dt > system.today() || (ca.Status__c == 'Ended' && dt > ca.End_Date__c) 
                            || (ca.Status__c != 'Ended' && dt < ca.Start_Date__c)){
                            
                            entry.isHrsDisabled = true;
                        }else if(disbleWholeHrs){
                            entry.isHrsDisabled = true;
                        }else {
                            entry.isHrsDisabled = false;
                        }
                    }else {
                        entry.isHrsDisabled = true;
                    }
                    
                    entry.showReverseIcon = false;
                    entry.showEditIcon = false;
                    entry.rejectionReason = '';
                    entry.recallReason = '';
                    entry.comments = '';
                    entry.studentName = ca.Candidate_Name__r.Name;
                    entry.displayNotesLink = 'false';
                    
                    entries.add(entry);
                    
                }
                
            }
            
            dateStudentEntries.put(dt,entries);
        }
        
        system.debug(':::::::dateStudentEntries:::::'+dateStudentEntries);
        
        return dateStudentEntries;
    }
    
    //Method to form the notes based on the date for mobile instructor time entry
    public static Map<Date,List<TimeCardDayCommunityDomain.NotesDetails>> mobileNotesFormation(Date st,Date ed,List<Accounting_Seed_Time_Snapshot__c> snapshotList){
        
        List<TimeCardDayCommunityDomain.NotesDetails> notesDetails = new List<TimeCardDayCommunityDomain.NotesDetails>();
        List<TimeCardDayCommunityDomain.NotesDetails> tempList = new List<TimeCardDayCommunityDomain.NotesDetails>();
        Map<String,List<TimeCardDayCommunityDomain.NotesDetails>> tempMap = new Map<String,List<TimeCardDayCommunityDomain.NotesDetails>>();
        
        Map<Date,List<TimeCardDayCommunityDomain.NotesDetails>> dateNotesDetails = new Map<Date,List<TimeCardDayCommunityDomain.NotesDetails>>();
        
        Set<Date> weekDates = new Set<Date>();
        
        Date startDt = st;
        Date endDt = ed;
        
        while(startDt <= endDt){
            weekDates.add(startDt);
            startDt = startDt.addDays(1);
        }
        
        for(Accounting_Seed_Time_Snapshot__c snapshot : snapshotList) {
            if(snapshot.Note_Type__c != null) {
                
                TimeCardDayCommunityDomain.NotesDetails notes = new TimeCardDayCommunityDomain.NotesDetails();
                notes.referenceId = snapshot.Reference_Id__c;
                
                notes.dayId = snapshot.Time_Card_Day__c;
                notes.noteType = snapshot.Note_Type__c;
                notes.notes = formatNotes(snapshot.Notes__c,snapshot.Note_Type__c);
                notes.comment = snapshot.Invoice_Comment__c;
                
                String dt = String.valueOf(snapshot.Date__c);
                notes.daydate = dt.split('-')[1]+'/'+dt.split('-')[2]+'/'+dt.split('-')[0];
                notes.dateValue = snapshot.Time_Card_Day__r.AcctSeed__Date__c;
                
                notes.editedDT = snapshot.CreatedDate.format('MM/dd/yyyy HH:mm:ss a', UserInfo.getTimeZone().getID());
                notes.userName = snapshot.CreatedBy.Name;
                
                tempList.add(notes);
            }
        }
        
        system.debug('::::::tempList:::::::::'+tempList.size());
        
        Map<String,TimeCardDayCommunityDomain.NotesDetails> refIdNoteMap = new Map<String,TimeCardDayCommunityDomain.NotesDetails>();
        
        for(TimeCardDayCommunityDomain.NotesDetails temp : tempList){
            if(temp.referenceId != null){
                if(!refIdNoteMap.containsKey(temp.referenceId)) {
                    TimeCardDayCommunityDomain.NotesDetails newNote = temp;
                    TimeCardDayCommunityDomain.NotesDetails newNote1 = new TimeCardDayCommunityDomain.NotesDetails();
                    
                    newNote1.referenceId = newNote.referenceId;
                    
                    newNote1.notes = newNote.notes;
                    newNote1.noteType = newNote.noteType;
                    newNote1.dateValue = newNote.dateValue;
                    newNote1.userName = newNote.userName;
                    
                    if(!dateNotesDetails.containsKey(newNote1.dateValue)){
                        dateNotesDetails.put(newNote1.dateValue,new List<TimeCardDayCommunityDomain.NotesDetails>{newNote1});
                    }else {
                        dateNotesDetails.get(newNote1.dateValue).add(newNote1);
                    }
                    
                    notesDetails.add(newNote1);
                    
                    tempMap.put(temp.referenceId,new List<TimeCardDayCommunityDomain.NotesDetails>{temp});
                    
                    refIdNoteMap.put(temp.referenceId,newNote1);
                    
                }else {
                    tempMap.get(temp.referenceId).add(temp);
                    
                    if(temp.referenceId.contains('Partial Reject')){
                        
                        for(TimeCardDayCommunityDomain.NotesDetails formatedNotes : notesDetails){
                            
                            if(formatedNotes.referenceId == temp.referenceId && formatedNotes.referenceId.contains('Partial Reject')){
                                formatedNotes.notes += '<br/> &nbsp;&nbsp;&nbsp;&nbsp;<b>'+temp.dayDate+'</b> rejected on '+temp.editedDT+' for <b>Reason: </b>'+temp.comment;
                            
                            }
                        }
                        
                    }
                }
            }else {
                
                notesDetails.add(temp);
                
                if(!dateNotesDetails.containsKey(temp.dateValue)){
                    dateNotesDetails.put(temp.dateValue,new List<TimeCardDayCommunityDomain.NotesDetails>{temp});
                }else {
                    dateNotesDetails.get(temp.dateValue).add(temp);
                }
            }
        }
        
        system.debug('::::::::dateNotesDetails::::::'+dateNotesDetails);
        
        return dateNotesDetails;
    }
}