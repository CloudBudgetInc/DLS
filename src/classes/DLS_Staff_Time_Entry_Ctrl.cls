// This class created by Sukanya on November 15 2016
// For DLS Staff Time Entry Page usage

global without sharing class DLS_Staff_Time_Entry_Ctrl {
    
    public static Boolean isGroupAction;
    public static String groupActionType;
   
     //Remote action to Query Project task and Contact assignment,Projects
    @RemoteAction
     global static TimeCardDayDomain.EmployeeDetails getEmployeeRelatedInfo(String stDate,String ed) {
         Set<Id> projectId = new Set<Id>();
         Set<Id> timeLineIdSet = new Set<Id>();
         Set<Id> timeDayIdSet = new Set<Id>();
         
         // For previous week Project Task formation
         Set<Id> previousWeekLineId = new Set<Id>();
         
         Map<Id,List<AcctSeed__Time_Card_Day__c>> timeLineWithTimeCardListMap = new Map<Id,List<AcctSeed__Time_Card_Day__c>>();
         
         List<Accounting_Seed_Time_Snapshot__c> accTimesnapshot = new List<Accounting_Seed_Time_Snapshot__c>();
         
         system.debug(':::::::::::::stDate:::::::'+stDate);
         system.debug(':::::::::::::ed:::::::'+ed);
         
         String stDt = stDate.split('-')[1];
         String stMnt = stDate.split('-')[0];
         String styear = stDate.split('-')[2];
         
         String edDt = ed.split('-')[1];
         String edMnt = ed.split('-')[0];
         String edyear = ed.split('-')[2];
         
         String fromDt = styear+'-'+stMnt+'-'+stDt;
         String toDt = edyear+'-'+edMnt+'-'+edDt;
         
         Date startDate = Date.valueOf(stDate).toStartofWeek().addDays(1);
         Date endDate = Date.valueOf(ed);
         Date weekStart = startDate.toStartofWeek().addDays(1);
         Date weekEnd = endDate;
         
         Date todayDate = system.today();
         
         List<Date> daysList = new List<Date>();
         
         while(weekStart <= weekEnd) {
           daysList.add(weekStart);
           weekStart = weekStart.addDays(1);
        }
        system.debug('::::::::daysList:::::::::'+daysList);
        
        // Get Previous Week dates
        
         Date currentStart = todayDate.toStartofWeek().addDays(1);
         Date currentEnd = currentStart.addDays(6);
         Date previousStart = currentStart.addDays(-7);
         Date previousEnd = previousStart.addDays(6);
         
         // Get User timezone offset value
         
         String timezoneValue = UserInfo.getTimeZone().getID();
         
         Id usrId = UserInfo.getUserId();
         String firstName = UserInfo.getFirstName();
         String lastName = UserInfo.getLastName();
         
         String fname = firstName != null ? '%'+String.escapeSingleQuotes(firstName)+'%' : null;
         String lName = lastName != null ? '%'+String.escapeSingleQuotes(lastName)+'%' : null;
         
         system.debug(':::::::usrId::::::'+usrId);
         system.debug(':::::::fname::::::'+fname);
         system.debug(':::::::lName::::::'+lName);
         
         List<Contact> conRecList = new List<Contact>();
         
         List<Contact_Assignments__c> relatedConAssign = new List<Contact_Assignments__c>();
         
         // Separate set for filtering projects on new row adding functionality
         Set<Id> filteredProjectId = new Set<Id>();
         
        //Qry User record to get the Email address to get the exact match for the user in contact level
        List<User> usrRec = [SELECT Id,Name,Email FROM User WHERE Id = :usrId];
           
        if(firstName != null && lastName != null){                  
            conRecList = ContactService.getContactByName(' WHERE Email = \''+usrRec[0].Email+'\' AND FirstName LIKE \''+fname+'\' AND LastName LIKE \''+lName+'\'',',Home_Department_Project__r.Name,Supervisor_Name__r.Name,Supervisor_Name__r.ManagerId,Supervisor_Name__r.Manager.Name,RecordType.DeveloperName',new Set<String>{},'');
        }else if(lastName != null) { 
            conRecList = ContactService.getContactByName(' WHERE Email = \''+usrRec[0].Email+'\' AND LastName LIKE \''+lName+'\'',',Home_Department_Project__r.Name,Supervisor_Name__r.Name,Supervisor_Name__r.ManagerId,Supervisor_Name__r.Manager.Name,RecordType.DeveloperName',new Set<String>{},'');
        }
        system.debug('::::::conRecList::::'+conRecList);
        
        //Thie date condition to filter the Projects based on the CA End Date values
        String caFilterDate = String.valueOf(startDate.addDays(-14)).split(' ')[0];
            
         if(conRecList != null && conRecList.size() > 0) {
             String parentFields = 'Candidate_Name__r.Home_Dept__c,Candidate_Name__r.Home_Department_Project__c,Candidate_Name__r.Home_Department_Project__r.Name,Candidate_Name__r.Name,'+
                                   'Candidate_Name__r.Supervisor_Name__c,Candidate_Name__r.Supervisor_Name__r.Name,Candidate_Name__r.Supervisor_Name__r.ManagerId,Candidate_Name__r.Supervisor_Name__r.Manager.Name,'+
                                     'Project__r.Name,Rate_Card_Rate__r.Name,Project__r.RecordType.DeveloperName,Rate_Card_Rate__r.Payroll_Item__c,Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Rate_Card_Rate__r.Rate_Type__c,RecordType.DeveloperName';
                                     
             String condition = ' WHERE RecordType.DeveloperName IN (\'Staff\',\'Instructor\') AND (Status__c = \'Active\' OR (Status__c = \'Ended\' AND End_Date__c >= '+caFilterDate+')) AND Project__c != null AND Candidate_Name__c = \''+conRecList[0].Id+'\'';
             
             for(Contact_Assignments__c assign : ContactAssignmentService.getContactassignmentRec(condition,parentFields)) {                
                 projectId.add(assign.Project__c);
                 
                 if(assign.Project__c == assign.Candidate_Name__r.Home_Department_Project__c || assign.Project__r.RecordType.DeveloperName == 'Admin_Projects' 
                     || assign.RecordType.DeveloperName == 'Instructor' 
                     || (assign.RecordType.DeveloperName == 'Staff' && (assign.Project__r.RecordType.DeveloperName == 'Testing_Projects' 
                     || assign.Project__r.RecordType.DeveloperName == 'CD_Projects'))) {
                     
                     filteredProjectId.add(assign.Project__c);
                     relatedConAssign.add(assign);
                 }                                  
             }
         }
         
         List<AcctSeed__Project_Task__c> projectTaskList = new List<AcctSeed__Project_Task__c>();
         List<AcctSeed__Project__c> projectList = new List<AcctSeed__Project__c>();
         
         if(conRecList != null && conRecList.size() > 0 && projectId.size() > 0) {
             
             for(AcctSeed__Project_Task__c task : ProjectTaskService.getProjectTaskByInnerQueryOnTimeCardLineDetails(',AcctSeed__Project__r.Name,AcctSeed__Project__r.RecordType.DeveloperName',projectId,startDate,endDate,conRecList[0].Id)) {
                 projectTaskList.add(task);
             }
             
             // Qry previous week project tasks with time card line ids
             for(AcctSeed__Project_Task__c task : ProjectTaskService.getProjectTaskByInnerQueryOnTimeCardLineDetails(',AcctSeed__Project__r.Name,AcctSeed__Project__r.AcctSeed__Status__c,AcctSeed__Project__r.End_Date__c',projectId,previousStart,previousEnd,conRecList[0].Id)) {
                 if(task.AcctSeed__Project__r.AcctSeed__Status__c == 'Active' && task.AcctSeed__Project__r.End_Date__c >= currentStart) {
                     for(AcctSeed__Time_Card_Line__c timeLine : task.AcctSeed__Time_Card_Line_Details__r) {
                         previousWeekLineId.add(timeLine.Id);
                     }
                 }
             }
         }
         
         system.debug(':::::::projectTaskList::::::::'+projectTaskList);
         system.debug(':::::::previousWeekLineId:::::::::'+previousWeekLineId);
         
         if(filteredProjectId.size() > 0) {
             projectList = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',filteredProjectId,',Training_Location__r.Name,RecordType.DeveloperName');
         }
         
         String filterCondition = ' ORDER BY AcctSeed__Date__c ASC';
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        
        if(conRecList != null && conRecList.size() > 0 && projectId.size() > 0) {
            timeCardLineList = TimeCardLineService.getTimeCardLine_dayRecords(filterCondition,projectId,startDate,endDate,conRecList[0].Id);
        }
        
        for(AcctSeed__Time_Card_Line__c timeLine : timeCardLineList) {
             timeLineIdSet.add(timeLine.Id);
        }
        
        system.debug(':::::::::timeLineIdSet:::::::'+timeLineIdSet);
        
        // Get Previous Week Time Card day detail for Project task formation on Page
        List<AcctSeed__Time_Card_Line__c> previousWeektimeCardLines = new List<AcctSeed__Time_Card_Line__c>();
        
        if(previousWeekLineId.size() > 0) {
            previousWeektimeCardLines = TimeCardLineService.getLineWithCardday(previousStart,previousEnd,previousWeekLineId,filterCondition);
        }
        
        system.debug('::::previousWeektimeCardLines:::::::::::'+previousWeektimeCardLines);
        
        // Time Snapshot formation
        if(timeLineIdSet.size() > 0) {
            for(AcctSeed__Time_Card_Day__c day : TimeCardDayService.getDayWithDate_timeLinefilter(timeLineIdSet,startDate,endDate) ) {
                
                if(day.Accounting_Seed_Time_Snapshots__r != null && day.Accounting_Seed_Time_Snapshots__r.size() > 0) {
                    for(Accounting_Seed_Time_Snapshot__c snapShot : day.Accounting_Seed_Time_Snapshots__r) {
                        accTimesnapshot.add(snapShot);
                    }
                }
             }
         }
         
         system.debug('::::::accTimesnapshot::::::'+accTimesnapshot);
        
         // Get TimeLog_Locking_Date custom setting value    
         System_Values__c sysVal = System_Values__c.getValues('TimeLog_Locking_Date');    
         Date lockingDate;   
         if (sysVal != null && sysVal.Value__c != null) {
             lockingDate = Date.valueOf(sysVal.Value__c);
         } 
         
         Set<Date> holidayDateSet = new Set<Date>();
         // Get Holiday list of dates for Fringe-Holiday disable function
         
         /*for(Holiday holi : [SELECT ActivityDate,Description,EndTimeInMinutes,Id,IsAllDay,IsRecurrence,Name,RecurrenceDayOfMonth,RecurrenceDayOfWeekMask,RecurrenceEndDateOnly,RecurrenceInstance,RecurrenceInterval,RecurrenceMonthOfYear,RecurrenceStartDate,RecurrenceType,StartTimeInMinutes FROM Holiday]) {
             holidayDateSet.add(holi.ActivityDate);
         }*/
         //Recurrence method call to get correct holiday dates for these date interval
         // Modified by NS on Jan 07 2019
         holidayDateSet = HolidayService.getHolidaysWithRecurrence(startDate,endDate);
         system.debug('::::::::::holidayDateSet:::::::::'+holidayDateSet);
         
         // Qry "Timekeeping Training Presentation" & "Timekeeping Policies & Procedures" documents
         List<Document> documentList = [SELECT Id,Name,ContentType FROM Document WHERE DeveloperName = 'Timekeeping_Policies_Procedures' OR DeveloperName = 'Timekeeping_Training_Presentation'];
         system.debug('::::::::documentList:::::'+documentList);
         
         
         // Qry Project Task Master - Custom setting for Fringe PT payroll item values
         // Added by NS - July 18 2017
         List<Project_Task_Master__c> ptmValues = [SELECT Id,Name,Billable__c,Display_In_Time_Card__c,Labor_GL_Account__c,
                                                         Payroll_Item__c,Project_Record_Type__c,Project_Task_Record_Type__c,Project_Task_Type__c,
                                                         Project_Type__c,Unit__c 
                                                     FROM Project_Task_Master__c
                                                     WHERE (Project_Record_Type__c = 'Admin_Projects' OR Project_Record_Type__c = 'Admin_Projects;EFL_Projects;CD_Projects' OR Project_Record_Type__c = 'Admin_Projects;CD_Projects' 
                                                         OR Project_Record_Type__c = 'EFL_Projects' OR Project_Record_Type__c = 'Admin_Projects;CD_Projects;Linguist_Support_Projects')];
                                                    
         system.debug('::::::ptmValues::::::'+ptmValues);
         
         //Added By Dhinesh - 21/03/2023 - W-007729 - Timekeeping Fields to Indicate if the Time was entered On Time or Late
        TimeEntryUtil.TimeEnteredCountWrap timeEnteredCount = TimeEntryUtil.getTimeEnteredCountByContactId(conRecList[0].Id);
         
         TimeCardDayDomain.EmployeeDetails emyDetails = new TimeCardDayDomain.EmployeeDetails();
         emyDetails = TimeCardDayTranslator.employeeDetailsMethod(projectTaskList,projectList,conRecList,timeCardLineList,timezoneValue,lockingDate,accTimesnapshot,daysList,holidayDateSet,previousWeektimeCardLines,documentList,relatedConAssign,new List<Contact_Assignments__c>{},ptmValues);
         emyDetails.timeEnteredLate = timeEnteredCount.timeEnteredLate;
         emyDetails.timeEnteredOnTime = timeEnteredCount.timeEnteredOnTime;
         emyDetails.timeSubmittedOnTime = timeEnteredCount.timeSubmittedOnTime;
         emyDetails.timeSubmittedLate = timeEnteredCount.timeSubmittedLate;
         
         system.debug('::::::::emyDetails:::::::'+emyDetails);
         
         return emyDetails;
     }
     
     // Remote action to Query already existing time card day and events
    
     @RemoteAction
     global static List<TimeCardDayDomain.TimeCardDay> getExistingTimeCardRecords(Id projectId,Id taskId,Id instructorId,String st,String ed,Boolean billableValue,String payRoll) {
         
         String stDt = st.split('-')[1];
         String stMnt = st.split('-')[0];
         String styear = st.split('-')[2];
         
         String edDt = ed.split('-')[1];
         String edMnt = ed.split('-')[0];
         String edyear = ed.split('-')[2];
         
         String fromDt = styear+'-'+stMnt+'-'+stDt;
         String ToDt = edyear+'-'+edMnt+'-'+edDt;
         
         Date startDate = Date.valueOf(st).toStartofWeek().addDays(1);
         Date endDate = Date.valueOf(ed);
         Date weekStart = startDate.toStartofWeek().addDays(1);
         Date weekEnd = endDate;
         
         List<Date> daysList = new List<Date>();
         
         while(weekStart <= weekEnd) {
           daysList.add(weekStart);
           weekStart = weekStart.addDays(1);
        }
         
         String filterCondition = ' AND '+
                                     'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c = \''+taskId+'\' AND '+
                                     'AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = \''+projectId+'\' AND '+
                                     'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = \''+instructorId+'\' AND '+
                                     'AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c = '+billableValue+
                                     ' AND AcctSeed__Time_Card_Line__r.Payroll_Item__c = \''+payRoll+'\' ORDER BY AcctSeed__Date__c ASC';
                                     
         String parentField = ',AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,'+
                               'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,'+
                               'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c,'+
                               'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,'+
                               'AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c,AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c,'+
                               'AcctSeed__Time_Card_Line__r.Payroll_Item__c,AcctSeed__Time_Card_Line__r.Location__c,AcctSeed__Time_Card_Line__r.Location__r.Name,'+
                               'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__c,AcctSeed__Time_Card_Line__r.Contact_Assignment__c,'+
                               'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,AcctSeed__Time_Card_Line__r.Sequence_Number__c';
         
         List<AcctSeed__Time_Card_Day__c> timeCardEventList = TimeCardDayService.getDayWithPro_Task_Ins_Datefilters(filterCondition,parentField,startDate,endDate);
                                                
        system.debug('::::::timeCardEventList:::::::'+timeCardEventList);
        
        List<TimeCardDayDomain.TimeCardDay> existingTimeCardDays = new List<TimeCardDayDomain.TimeCardDay>();
        
        if(timeCardEventList.size() > 0) {
            existingTimeCardDays = TimeCardDayTranslator.existingTimeDayFormation(timeCardEventList,daysList,instructorId,projectId,taskId);
        }else {
            String filterCondition1 = ' ORDER BY AcctSeed__Date__c ASC';
            
            List<AcctSeed__Time_Card_Line__c> timeCardLineList = TimeCardLineService.getTCL_TCD_withfilters(filterCondition1,projectId,taskId,startDate,endDate,instructorId);
            
            existingTimeCardDays = TimeCardDayTranslator.existingLineFormation_WithoutDay(timeCardLineList,daysList,instructorId);
        }
        system.debug(':::::::::existingTimeCardDays::::::::::::'+existingTimeCardDays);
        
        return existingTimeCardDays;
     }
     
     
      /**********************************************************************
        Created by Sukanya on Jan 12 2017: Domain class used for DLS_Staff_Time_Entry_Ctrl - Summary details inner class formation
    ***********************************************************************/
     @RemoteAction
     global static TimeCardDayDomain.userSummaryDetails getSummaryTimeRecords(String fromDate,String toDate) {
     
         system.debug(':::::::::::::enter::getSummaryTimeRecords:::::'+fromDate);
         system.debug(':::::::::::::enter::getSummaryTimeRecords:::::'+toDate);
         
         TimeCardDayDomain.userSummaryDetails timeSummaryList = new TimeCardDayDomain.userSummaryDetails();
         
         Set<Id> projectId = new Set<Id>();
         Set<Id> timeLineIdSet = new Set<Id>();
         
         Date startDate = Date.valueOf(fromDate);
         Date endDate = Date.valueOf(toDate);
         Date monthStart = startDate;
         Date monthEnd = endDate;
         
         Date date1 = monthStart;
         Date date2 = monthEnd;
         
         if(Date.valueOf(fromDate).toStartofWeek().addDays(1) < Date.valueOf(fromDate)) {
             if(Date.valueOf(fromDate) != Date.valueOf(fromDate).toStartOfMonth()) {
                 system.debug(':::::Month:start:::&::Weekstart::not:::same:');
                 startDate = Date.valueOf(fromDate).toStartofWeek().addDays(1);
             }
         }else {
             startDate = Date.valueOf(fromDate).addDays(-1).toStartofWeek().addDays(1);
         }  
         
         system.debug(':::::::startDate::::::::'+startDate);
         system.debug(':::::::endDate::::::::'+endDate);
         system.debug(':::::::monthStart::::::::'+monthStart);
         system.debug(':::::::monthEnd::::::::'+monthEnd);
         
         
         List<Date> monthdaysList = new List<Date>();
         
         while(monthStart <= monthEnd) {
           monthdaysList.add(monthStart);
           monthStart = monthStart.addDays(1);
        }
        
        Id usrId = UserInfo.getUserId();
        String firstName = UserInfo.getFirstName();
        String lastName = UserInfo.getLastName();
        
        String fname = firstName != null ? '%'+String.escapeSingleQuotes(firstName)+'%' : null;
        String lName = lastName != null ? '%'+String.escapeSingleQuotes(lastName)+'%' : null;
         
        system.debug(':::::fname:::::::::::'+fname);
        system.debug(':::::lName:::::::::::'+lName);
        
        //Qry User record to get the Email address to get the exact match for the user in contact level
        List<User> usrRec = [SELECT Id,Name,Email FROM User WHERE Id = :usrId];
        
         List<Contact> conRecList = new List<Contact>();
         
         if(firstName != null && lastName != null){                 
            conRecList = ContactService.getContactByName(' WHERE Email = \''+usrRec[0].Email+'\' AND FirstName LIKE \''+fname+'\' AND LastName LIKE \''+lName+'\'',',Home_Department_Project__r.Name,Supervisor_Name__r.Name,Supervisor_Name__r.ManagerId,Supervisor_Name__r.Manager.Name,RecordType.DeveloperName',new Set<String>{},'');
         } else if(lastName != null) {
            conRecList = ContactService.getContactByName(' WHERE Email = \''+usrRec[0].Email+'\' AND LastName LIKE \''+lName+'\'',',Home_Department_Project__r.Name,Supervisor_Name__r.Name,Supervisor_Name__r.ManagerId,Supervisor_Name__r.Manager.Name,RecordType.DeveloperName',new Set<String>{},'');
         }
         system.debug('::::::conRecList::::'+conRecList);
        
         if(conRecList != null && conRecList.size() > 0) {
             
             String parentFields = 'Candidate_Name__r.Home_Dept__c,Candidate_Name__r.Home_Department_Project__c,Candidate_Name__r.Home_Department_Project__r.Name,Candidate_Name__r.Name,'+
                                   'Candidate_Name__r.Supervisor_Name__c,Candidate_Name__r.Supervisor_Name__r.Name,Candidate_Name__r.Supervisor_Name__r.ManagerId,Candidate_Name__r.Supervisor_Name__r.Manager.Name,'+
                                     'Project__r.Name,Rate_Card_Rate__r.Payroll_Item__c,Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Rate_Card_Rate__r.Rate_Type__c';
                                     
             String condition = ' WHERE RecordType.DeveloperName IN (\'Staff\',\'Instructor\') AND Project__c != null AND Candidate_Name__c = \''+conRecList[0].Id+'\'';
             
             for(Contact_Assignments__c assign : ContactAssignmentService.getContactassignmentRec(condition,parentFields)) {
                 
                 projectId.add(assign.Project__c);
             }
             
             system.debug('::::::::::projectId::::::'+projectId);
             
         }
         
         system.debug(':::::::::timeLineIdSet:::::::'+timeLineIdSet);
         
         String filterCondition = ' AND Status__c != \'Unposted\' ORDER BY AcctSeed__Date__c ASC';
         
         system.debug('::date1:::::::::::::'+date1);
         system.debug('::date2:::::::::::::'+date2);
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        
        if(conRecList != null && conRecList.size() > 0) {
            timeCardLineList = TimeCardLineService.getTimeCardLine_dayRecords(filterCondition,projectId,date1,date2,conRecList[0].Id);
        }
        system.debug(':::::timeCardLineList:::::::'+timeCardLineList);
        timeSummaryList = TimeCardDayTranslator.userSummaryformation(conRecList,timeCardLineList,monthdaysList,null);
        
        return timeSummaryList;
     }
    
    public static AcctSeed__Time_Card_Day__c dayRecFormation(TimeCardDayDomain.TimeCardDay day,String actionType,Date dateVal,String hrsVal,String cmtVal,String statusVal) {
        
        AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
        timeDay.AcctSeed__Date__c = dateVal;
        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(hrsVal);
        timeDay.AcctSeed__Internal_Comment__c = cmtVal;
        timeDay.Labor_Cost_Rate__c = day.costRateId;
        
        /*if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
            timeDay.Status__c = 'Approved';
            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
        } else {*/
            
            // Added these if condition for submission,Save,Recall operation
            if(actionType == 'FromSave') {
                //timeDay.Status__c = 'Draft';
                timeDay.Status__c = statusVal;
            } else if(actionType == 'FromSubmit') {
                timeDay.Status__c = statusVal;
            }else if(actionType == 'FromRecall') {
                if(statusVal == 'Submitted' || statusVal == 'Approved' || statusVal == 'Admin Approved')
                    timeDay.Status__c = 'Recalled';
            }
            timeDay.AcctSeed__Hours__c = 0;
        //}
        
        return timeDay;
    }
     
      @RemoteAction
     global static void timeCardDayCreation(String timeCardDayJson,String fromDate,String toDate,String actionType,List<Id> updateDayRecIds,List<AcctSeed__Time_Card_Line__c> lineRecordUpdate) {
         //system.debug('::::::timeCardDayJson:::::'+timeCardDayJson);
         system.debug('::::::fromDate:::::'+fromDate);
         system.debug('::::::toDate:::::'+toDate);
         system.debug('::::::updateDayRecIds::::::'+updateDayRecIds);
         system.debug('::::::actionType::::::'+actionType);
         List<TimeCardDayDomain.TimeCardDay> innerClassList = (List<TimeCardDayDomain.TimeCardDay>) System.JSON.deserialize(timeCardDayJson, List<TimeCardDayDomain.TimeCardDay>.class);
         system.debug('::::::::innerClassList:::::::'+innerClassList);
        
         Id timeCardPeriodId;
         Set<Id> timeCardId = new Set<Id>();
         Map<Id,AcctSeed__Time_Card__c> instrutorIdandRecordMap = new Map<Id,AcctSeed__Time_Card__c>();
         Map<Id,Map<String,AcctSeed__Time_Card_Line__c>> instructIdTaskIdandLineRecMap = new Map<Id,Map<String,AcctSeed__Time_Card_Line__c>>();
         Set<Id> instructorId = new Set<Id>();
         Map<Id,Id> contactIdUserIdMap = new Map<Id,Id>();
         
         Map<Id,List<AcctSeed__Time_Card_Line__c>> instructorIdLineListMap = new Map<Id,List<AcctSeed__Time_Card_Line__c>>();
         Map<String,List<AcctSeed__Time_Card_Day__c>> instIdTaskIdStringDayLsitMap = new Map<String,List<AcctSeed__Time_Card_Day__c>>();
         Set<Id> timeCardLineId = new Set<Id>();
         Set<Id> insIdForRefer = new Set<Id>();
         
         //Map<Id,Map<Id,AcctSeed__Time_Card_Line__c>> InsIdTaskIdTimeLineMap = new Map<Id,Map<Id,AcctSeed__Time_Card_Line__c>>();
         Map<Id,Map<String,AcctSeed__Time_Card_Line__c>> insIdStringTimeLineMap = new Map<Id,Map<String,AcctSeed__Time_Card_Line__c>>();
         
         List<AcctSeed__Time_Card__c> cardCreation = new List<AcctSeed__Time_Card__c>();
         List<AcctSeed__Time_Card_Line__c> timeLineCreation = new List<AcctSeed__Time_Card_Line__c>();
         List<AcctSeed__Time_Card_Day__c> timeCardDayCreationList = new List<AcctSeed__Time_Card_Day__c>();
         
         // This list to update existing records
         List<AcctSeed__Time_Card_Day__c> updateTimeCardDayList = new List<AcctSeed__Time_Card_Day__c>();
         
         // This list is to Update existing time card line with billable & non billable values
         List<AcctSeed__Time_Card_Line__c> updateTimeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
         
         // Whole list of day records for updation 
         List<AcctSeed__Time_Card_Day__c> wholeDayRecForUpdate = new List<AcctSeed__Time_Card_Day__c>();
         
         // For Submit action list
         List<AcctSeed__Time_Card_Day__c> submitActiondayList = new List<AcctSeed__Time_Card_Day__c>();
         
         Set<Id> updationRecIdSet = new Set<Id>();
         updationRecIdSet.addAll(updateDayRecIds);
         
         //For time card line display in Future week field  & sequence number updation purpose
         List<AcctSeed__Time_Card_Line__c> lineRecordUpdateList = lineRecordUpdate;
         /*Set<Id> lineRecIdSet = new Set<Id>();
         lineRecIdSet.addAll(lineIdsForUpdate);*/
         
         system.debug(':::::::updationRecIdSet::::::'+updationRecIdSet);
         system.debug(':::::::lineRecordUpdateList::::::::'+lineRecordUpdateList);
         
         //Ledger record query for test class purpose
         List< AcctSeed__Ledger__c > ledger = [SELECT Id, Name, AcctSeed__Type__c FROM AcctSeed__Ledger__c LIMIT 1];
         
         // Set this variable for trigger usage
         if(actionType == 'FromRecall'){
             isGroupAction = true;
             groupActionType = 'Recalled';
         }else {
             isGroupAction = false;
         }
         
         Date fromDt = Date.valueOf(fromDate);
         Date toDt = Date.valueOf(toDate);
         
        // Account Period check & insertion
        TimesheetPage_RelatedCtrl.accountingPeriodCreation(fromDt,toDt);
        
        // Time Card Period exist check & insertion
        timeCardPeriodId = TimesheetPage_RelatedCtrl.timeCardPeriodCreation(fromDt,toDt); 
         
         if(timeCardPeriodId != null) {
             for(AcctSeed__Time_Card__c card : TimecardService.getTimeCardByDate(' WHERE AcctSeed__Time_Card_Period__c = \''+timeCardPeriodId+'\'',new Set<Id>{},new Set<Id>{},'')) {
                 
                 timeCardId.add(card.Id);
                 if(!instrutorIdandRecordMap.containsKey(card.Intructor__c))
                     instrutorIdandRecordMap.put(card.Intructor__c,card);
             }
         }
         
         system.debug('::::::timeCardId::::::'+timeCardId);
         system.debug('::::::instrutorIdandRecordMap::::::'+instrutorIdandRecordMap);
         
         // Time Card Line Query
         
         // Added location value for the string formation - April 29 2017 By Sukanya
         
         for(AcctSeed__Time_Card_Line__c line : [SELECT Id,AcctSeed__Project_Task__c,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c,
                                                     AcctSeed__Billable__c,Payroll_Item__c,Location__c,
                                                     AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c 
                                                 FROM AcctSeed__Time_Card_Line__c 
                                                 WHERE AcctSeed__Time_Card__c IN :timeCardId]){
            Id locId = null;
            
            if(line.Location__c != null)
                locId = line.Location__c;
            else if(line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c != null)
                locId = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c;
                 
            if(!instructIdTaskIdandLineRecMap.containsKey(line.AcctSeed__Time_Card__r.Intructor__c)) {
              instructIdTaskIdandLineRecMap.put(line.AcctSeed__Time_Card__r.Intructor__c,new Map<String,AcctSeed__Time_Card_Line__c>{line.AcctSeed__Project_Task__c+'-'+line.AcctSeed__Billable__c+'-'+line.Payroll_Item__c+'-'+locId=>line});
            } 
            instructIdTaskIdandLineRecMap.get(line.AcctSeed__Time_Card__r.Intructor__c).put(line.AcctSeed__Project_Task__c+'-'+line.AcctSeed__Billable__c+'-'+line.Payroll_Item__c+'-'+locId,line);  
         }
         
         system.debug(':::::::::instructIdTaskIdandLineRecMap::::::::'+instructIdTaskIdandLineRecMap);
         
         for(TimeCardDayDomain.TimeCardDay day : innerClassList) {
            instructorId.add(day.SelectedInstructor);    
         }
         
         Id usrRecId = UserInfo.getUserId();
         String firstName = UserInfo.getFirstName();
         String lastName = UserInfo.getLastName();
         
        String fname = firstName != null ? '%'+String.escapeSingleQuotes(firstName)+'%' : null;
        String lName = lastName != null ? '%'+String.escapeSingleQuotes(lastName)+'%' : null;
         
        //Qry User record to get the Email address to get the exact match for the user in contact level
        List<User> usrRec = [SELECT Id,Name,Email FROM User WHERE Id = :usrRecId];

         //List<Contact> conRec = [SELECT Id,Name FROM Contact WHERE Name LIKE :name LIMIT 1];
         List<Contact> conRec = new List<Contact>();
         //List<Contact> conRec = ContactService.getContactByName('','',new Set<String>{},name);
         
         if(firstName != null && lastName != null){                  
            conRec = ContactService.getContactByName(' WHERE Email = \''+usrRec[0].Email+'\' AND FirstName LIKE \''+fname+'\' AND LastName LIKE \''+lName+'\'','',new Set<String>{},'');
         } else if(lastName != null) { 
            conRec = ContactService.getContactByName(' WHERE Email = \''+usrRec[0].Email+'\' AND LastName LIKE \''+lName+'\'','',new Set<String>{},'');
         }
         
         for(TimeCardDayDomain.TimeCardDay day : innerClassList) {
         
             //Check If any existing Time card day record Exist
             
             if(day.Hrs1Day1Id != null || day.Hrs2Day2Id != null 
                 || day.Hrs3Day3Id != null || day.Hrs4Day4Id != null 
                 || day.Hrs5Day5Id != null || day.Hrs6Day6Id != null 
                 || day.Hrs7Day7Id != null) {
                 
                AcctSeed__Time_Card_Line__c cardlineRec = new AcctSeed__Time_Card_Line__c();
                cardlineRec.Id = day.timeCardLineId;
                cardlineRec.AcctSeed__Billable__c = day.isBillable;
                
                updateTimeCardLineList.add(cardlineRec);
            }
            system.debug(':::::::updateTimeCardLineList:::::'+updateTimeCardLineList);
             
             if(day.Hrs1Day1Id != null && String.isNotBlank(day.Hours1)) {
                 
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay = dayRecFormation(day,actionType,day.Day1,day.Hours1,day.comment1,day.status1);
                timeDay.Id = day.Hrs1Day1Id;
                
                if(actionType == 'FromRecall' || updationRecIdSet.contains(day.Hrs1Day1Id)) {
                    updateTimeCardDayList.add(timeDay);
                } else if(day.status1 != 'Approved' && day.status1 != 'Admin Approved') {
                    wholeDayRecForUpdate.add(timeDay);
                }
             }
             
             if(day.Hrs2Day2Id != null && String.isNotBlank(day.Hours2)) {
                 
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay = dayRecFormation(day,actionType,day.Day2,day.Hours2,day.comment2,day.status2);
                timeDay.Id = day.Hrs2Day2Id;
                
                if(actionType == 'FromRecall' || updationRecIdSet.contains(day.Hrs2Day2Id)) {
                    updateTimeCardDayList.add(timeDay);
                } else if(day.status2 != 'Approved' && day.status2 != 'Admin Approved') {
                   wholeDayRecForUpdate.add(timeDay);
                }
             }
             
             if(day.Hrs3Day3Id != null && String.isNotBlank(day.Hours3)) {
                 
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay = dayRecFormation(day,actionType,day.Day3,day.Hours3,day.comment3,day.status3);
                timeDay.Id = day.Hrs3Day3Id;
                
                if(actionType == 'FromRecall' || updationRecIdSet.contains(day.Hrs3Day3Id)) {
                    updateTimeCardDayList.add(timeDay);
                } else if(day.status3 != 'Approved' && day.status3 != 'Admin Approved') {
                    wholeDayRecForUpdate.add(timeDay);
                }
             }
             
             if(day.Hrs4Day4Id != null && String.isNotBlank(day.Hours4)) {
                 
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay = dayRecFormation(day,actionType,day.Day4,day.Hours4,day.comment4,day.status4);
                timeDay.Id = day.Hrs4Day4Id;
                
                if(actionType == 'FromRecall' || updationRecIdSet.contains(day.Hrs4Day4Id)) {
                    updateTimeCardDayList.add(timeDay);
                } else if(day.status4 != 'Approved' && day.status4 != 'Admin Approved') {
                    wholeDayRecForUpdate.add(timeDay);
                }
             }
             
             if(day.Hrs5Day5Id != null && String.isNotBlank(day.Hours5)) {
                
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay = dayRecFormation(day,actionType,day.Day5,day.Hours5,day.comment5,day.status5);
                timeDay.Id = day.Hrs5Day5Id;
                
                if(actionType == 'FromRecall' || updationRecIdSet.contains(day.Hrs5Day5Id)) {
                    updateTimeCardDayList.add(timeDay);
                } else if(day.status5 != 'Approved' && day.status5 != 'Admin Approved') {
                    wholeDayRecForUpdate.add(timeDay);
                }
             }
             
             if(day.Hrs6Day6Id != null && String.isNotBlank(day.Hours6)) {
                 
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay = dayRecFormation(day,actionType,day.Day6,day.Hours6,day.comment6,day.status6);
                timeDay.Id = day.Hrs6Day6Id;
                
                if(actionType == 'FromRecall' || updationRecIdSet.contains(day.Hrs6Day6Id)) {
                    updateTimeCardDayList.add(timeDay);
                } else if(day.status6 != 'Approved' && day.status6 != 'Admin Approved') {
                    wholeDayRecForUpdate.add(timeDay);
                }
             }
             
             if(day.Hrs7Day7Id != null && String.isNotBlank(day.Hours7)) {
                 
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay = dayRecFormation(day,actionType,day.Day7,day.Hours7,day.comment7,day.status7);
                timeDay.Id = day.Hrs7Day7Id;
                    
                if(actionType == 'FromRecall' || updationRecIdSet.contains(day.Hrs7Day7Id)) {
                    updateTimeCardDayList.add(timeDay);
                } else if(day.status7 != 'Approved' && day.status7 != 'Admin Approved') {
                    wholeDayRecForUpdate.add(timeDay);
                }
             }
             
             // Check alerady Time card Exist
             if(instrutorIdandRecordMap.containsKey(day.SelectedInstructor) 
                 && instrutorIdandRecordMap.get(day.SelectedInstructor) != null 
                 && instrutorIdandRecordMap.get(day.SelectedInstructor).AcctSeed__Time_Card_Period__c == timeCardPeriodId) {
                 
                 AcctSeed__Time_Card__c cardRec = instrutorIdandRecordMap.get(day.SelectedInstructor);
                 
                 if(instructIdTaskIdandLineRecMap.containsKey(cardRec.Intructor__c) 
                     && instructIdTaskIdandLineRecMap.get(cardRec.Intructor__c).containsKey(day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId)
                   ) {
                     
                     AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                     AcctSeed__Time_Card_Line__c lineRec = instructIdTaskIdandLineRecMap.get(cardRec.Intructor__c).get(day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId);
                     
                     if(String.isNotBlank(day.Hours1) && day.Hrs1Day1Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day1,day.Hours1,day.comment1,day.status1);
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        
                        timeCardDayCreationList.add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours2) && day.Hrs2Day2Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day2,day.Hours2,day.comment2,day.status2);
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        
                        timeCardDayCreationList.add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours3) && day.Hrs3Day3Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day3,day.Hours3,day.comment3,day.status3);
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        
                        timeCardDayCreationList.add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours4) && day.Hrs4Day4Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day4,day.Hours4,day.comment4,day.status4);
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        
                        timeCardDayCreationList.add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours5) && day.Hrs5Day5Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day5,day.Hours5,day.comment5,day.status5);
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        
                        timeCardDayCreationList.add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours6) && day.Hrs6Day6Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day6,day.Hours6,day.comment6,day.status6);
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        
                        timeCardDayCreationList.add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours7) && day.Hrs7Day7Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day7,day.Hours7,day.comment7,day.status7);
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        
                        timeCardDayCreationList.add(timeDay);
                    }
                 //End of 2nd If
                 }else {
                   
                    AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                    line.AcctSeed__Project_Task__c = day.SelectedProTask;
                    line.AcctSeed__Project__c = day.SelectedProject;
                    line.AcctSeed__Time_Card__c = cardRec.Id;
                    line.AcctSeed__Billable__c = day.isBillable;
                    line.Payroll_Item__c = day.payRollItem;
                    line.Location__c = day.locationId;
                    line.Display_in_Future_Weeks__c = true;
                    //line.Labor_Cost_Rate__c = day.costRateId;
                    line.Contact_Assignment__c = day.contactAssignId;
                    line.Sequence_Number__c = day.sequenceNumber;
                    
                    if(actionType != 'FromRecall') {
                        timeLineCreation.add(line);
                    }
                    
                    // Time card Day Map formation
        
                    if(!instIdTaskIdStringDayLsitMap.containsKey(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.payRollItem+'-'+day.locationId)) {
                        instIdTaskIdStringDayLsitMap.put(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId,new List<AcctSeed__Time_Card_Day__c>());
                    }
                    
                    AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                    
                    if(String.isNotBlank(day.Hours1) && day.Hrs1Day1Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day1,day.Hours1,day.comment1,day.status1);
                        
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        
                        instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours2) && day.Hrs2Day2Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day2,day.Hours2,day.comment2,day.status2);
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                    }
                    
                    if(String.isNotBlank(day.Hours3) && day.Hrs3Day3Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day3,day.Hours3,day.comment3,day.status3);
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                    }
                    
                    if(String.isNotBlank(day.Hours4) && day.Hrs4Day4Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day4,day.Hours4,day.comment4,day.status4);
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                    }
                    
                    if(String.isNotBlank(day.Hours5) && day.Hrs5Day5Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day5,day.Hours5,day.comment5,day.status5);
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                    }
                    
                    if(String.isNotBlank(day.Hours6) && day.Hrs6Day6Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day6,day.Hours6,day.comment6,day.status6);
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                    }
                    
                    if(String.isNotBlank(day.Hours7) && day.Hrs7Day7Id == null && actionType != 'FromRecall') {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay = dayRecFormation(day,actionType,day.Day7,day.Hours7,day.comment7,day.status7);
                        if(actionType == 'FromSave') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(actionType == 'FromSubmit') {
                            timeDay.Status__c = 'Draft';
                            timeDay.AcctSeed__Hours__c = 0;
                        }
                        instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                    }
                     //End of 2nd if's else
                 }
             //End of 1st if
             }else {// Create a Time Card for the instructor,Time Card Line and Time Card Day
             
                 // Time card creation formation
                 
                 // In this first if contactIdUserIdMap is not used - for single contact use
                
                if(!insIdForRefer.contains(day.SelectedInstructor) && conRec != null && conRec.size() > 0 && conRec[0].Id == day.SelectedInstructor && actionType != 'FromRecall') {
                    
                    AcctSeed__Time_Card__c card = new AcctSeed__Time_Card__c();
                    card.AcctSeed__Employee__c = usrRecId;
                    card.Intructor__c = day.SelectedInstructor;
                    card.AcctSeed__Time_Card_Period__c = timeCardPeriodId;
                    
                    if(Test.isRunningTest()){
                        card.AcctSeed__Ledger__c = ledger[0].Id;
                    }
                    
                    cardCreation.add(card);
                    insIdForRefer.add(day.SelectedInstructor);
                }
                
                // Time card Line Map formation
                
                AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                line.AcctSeed__Project_Task__c = day.SelectedProTask;
                line.AcctSeed__Project__c = day.SelectedProject;
                line.AcctSeed__Billable__c = day.isBillable;
                line.Payroll_Item__c = day.payRollItem;
                line.Location__c = day.locationId;
                line.Display_in_Future_Weeks__c = true;
                line.Labor_Cost_Rate__c = day.costRateId;
                line.Contact_Assignment__c = day.contactAssignId;
                line.Sequence_Number__c = day.sequenceNumber;
                
                if(actionType != 'FromRecall') {
                    if(!instructorIdLineListMap.containsKey(day.SelectedInstructor)) {
                        instructorIdLineListMap.put(day.SelectedInstructor,new List<AcctSeed__Time_Card_Line__c>());
                    }
                    instructorIdLineListMap.get(day.SelectedInstructor).add(line);
                }
                
                // Time card Day Map formation
                
                if(!instIdTaskIdStringDayLsitMap.containsKey(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId)) {
                    instIdTaskIdStringDayLsitMap.put(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId,new List<AcctSeed__Time_Card_Day__c>());
                }
                
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                
                if(String.isNotBlank(day.Hours1) && day.Hrs1Day1Id == null && actionType != 'FromRecall') {
                    
                    timeDay = new AcctSeed__Time_Card_Day__c();
                    timeDay = dayRecFormation(day,actionType,day.Day1,day.Hours1,day.comment1,day.status1);
                    if(actionType == 'FromSave') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(actionType == 'FromSubmit') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    }
                    instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);
                }
                
                if(String.isNotBlank(day.Hours2) && day.Hrs2Day2Id == null && actionType != 'FromRecall') {
                    timeDay = new AcctSeed__Time_Card_Day__c();
                    timeDay = dayRecFormation(day,actionType,day.Day2,day.Hours2,day.comment2,day.status2);
                    if(actionType == 'FromSave') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(actionType == 'FromSubmit') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    }
                    instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                }
                
                if(String.isNotBlank(day.Hours3) && day.Hrs3Day3Id == null && actionType != 'FromRecall') {
                    timeDay = new AcctSeed__Time_Card_Day__c();
                    timeDay = dayRecFormation(day,actionType,day.Day3,day.Hours3,day.comment3,day.status3);
                    if(actionType == 'FromSave') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(actionType == 'FromSubmit') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    }
                    instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                }
                
                if(String.isNotBlank(day.Hours4) && day.Hrs4Day4Id == null && actionType != 'FromRecall') {
                    timeDay = new AcctSeed__Time_Card_Day__c();
                    timeDay = dayRecFormation(day,actionType,day.Day4,day.Hours4,day.comment4,day.status4);
                    if(actionType == 'FromSave') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(actionType == 'FromSubmit') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    }
                    instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                }
                
                if(String.isNotBlank(day.Hours5) && day.Hrs5Day5Id == null && actionType != 'FromRecall') {
                    timeDay = new AcctSeed__Time_Card_Day__c();
                    timeDay = dayRecFormation(day,actionType,day.Day5,day.Hours5,day.comment5,day.status5);
                    if(actionType == 'FromSave') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(actionType == 'FromSubmit') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    }
                    instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                }
                
                if(String.isNotBlank(day.Hours6) && day.Hrs6Day6Id == null && actionType != 'FromRecall') {
                    timeDay = new AcctSeed__Time_Card_Day__c();
                    timeDay = dayRecFormation(day,actionType,day.Day6,day.Hours6,day.comment6,day.status6);
                    if(actionType == 'FromSave') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(actionType == 'FromSubmit') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    }
                    instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                }
                
                if(String.isNotBlank(day.Hours7) && day.Hrs7Day7Id == null && actionType != 'FromRecall') {
                    timeDay = new AcctSeed__Time_Card_Day__c();
                    timeDay = dayRecFormation(day,actionType,day.Day7,day.Hours7,day.comment7,day.status7);
                    if(actionType == 'FromSave') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(actionType == 'FromSubmit') {
                        timeDay.Status__c = 'Draft';
                        timeDay.AcctSeed__Hours__c = 0;
                    }
                    instIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                }
                
             }//End of 1st If's else
         
         }// End of Inner class For Loop
         
         system.debug(':::::::::::updateTimeCardDayList::::::::::'+updateTimeCardDayList);
         system.debug('::::::cardCreation::::::::'+cardCreation);
         system.debug('::::::timeLineCreation::::::::'+timeLineCreation);
         system.debug('::::::::timeCardDayCreationList:::::::::'+timeCardDayCreationList);
         system.debug(':::instructorIdLineListMap::::::::::'+instructorIdLineListMap);
         system.debug('::::::instIdTaskIdStringDayLsitMap::::::'+instIdTaskIdStringDayLsitMap);
         system.debug('::::updateTimeCardLineList:::::::::'+updateTimeCardLineList);
         
         if(cardCreation.size() > 0) {
            insert cardCreation;
            
            for(AcctSeed__Time_Card__c timeCard : cardCreation) {
            
                if(instructorIdLineListMap.containsKey(timeCard.Intructor__c)) {
                
                    for(AcctSeed__Time_Card_Line__c timeLine : instructorIdLineListMap.get(timeCard.Intructor__c)) {
                        
                        timeLine.AcctSeed__Time_Card__c = timeCard.Id;
                        timeLineCreation.add(timeLine);
                    }
                }
            }
        }
        
        system.debug('::::::timeLineCreation::::::'+timeLineCreation);
                
        if(timeLineCreation.size() > 0) {
            insert timeLineCreation;
            
            for(AcctSeed__Time_Card_Line__c cardLine :timeLineCreation) {
                timeCardLineId.add(cardLine.Id);
            }
            
            system.debug(':::::timeCardLineId::::'+timeCardLineId);
            
            for(AcctSeed__Time_Card_Line__c lineRec : [SELECT Id,Name,AcctSeed__Project_Task__c,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Billable__c,Payroll_Item__c,Location__c FROM AcctSeed__Time_Card_Line__c WHERE Id IN :timeCardLineId]) {
                if(!insIdStringTimeLineMap.containsKey(lineRec.AcctSeed__Time_Card__r.Intructor__c)) {
                    insIdStringTimeLineMap.put(lineRec.AcctSeed__Time_Card__r.Intructor__c,new Map<String,AcctSeed__Time_Card_Line__c>{lineRec.AcctSeed__Project_Task__c+'-'+lineRec.AcctSeed__Billable__c+'-'+lineRec.Payroll_Item__c+'-'+lineRec.Location__c=>lineRec});
                }
                insIdStringTimeLineMap.get(lineRec.AcctSeed__Time_Card__r.Intructor__c).put(lineRec.AcctSeed__Project_Task__c+'-'+lineRec.AcctSeed__Billable__c+'-'+lineRec.Payroll_Item__c+'-'+lineRec.Location__c,lineRec);
            }
            system.debug('::::::insIdStringTimeLineMap:::::::'+insIdStringTimeLineMap);
            
            for(String insIdTaskId : instIdTaskIdStringDayLsitMap.keySet()) {
                
                String insId = insIdTaskId.split('-')[0];
                String taskId = insIdTaskId.split('-')[1];
                Boolean billValue = Boolean.valueOf(insIdTaskId.split('-')[2]);
                String payRollItemList = insIdTaskId.split('-')[3];
                String locationId = insIdTaskId.split('-')[4];
                
                for(AcctSeed__Time_Card_Day__c timeCardDay : instIdTaskIdStringDayLsitMap.get(insIdTaskId)) {
                    
                    if(insIdStringTimeLineMap.containsKey(insId)) {
                        
                        if(insIdStringTimeLineMap.get(insId).containsKey(taskId+'-'+billValue+'-'+payRollItemList+'-'+locationId)) {
                            
                            AcctSeed__Time_Card_Line__c timeLineRec = insIdStringTimeLineMap.get(insId).get(taskId+'-'+billValue+'-'+payRollItemList+'-'+locationId);
                            String linePayRoll = timeLineRec.Payroll_Item__c;
                            
                            if(timeLineRec.AcctSeed__Billable__c != null && linePayRoll != null && timeLineRec.Location__c != null){
                                
                                if(timeLineRec.AcctSeed__Billable__c ==  billValue && linePayRoll == payRollItemList && timeLineRec.Location__c == locationId) {
                                    timeCardDay.AcctSeed__Time_Card_Line__c = timeLineRec.Id;
                                    timeCardDayCreationList.add(timeCardDay);
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
        // Update time card line with billable values
        if(updateTimeCardLineList.size() > 0) {
            system.debug('::::::enter::line :Update::');
            //update updateTimeCardLineList;
        }
        
        system.debug(':::::::updateTimeCardDayList::::::'+updateTimeCardDayList);
        system.debug(':::::::wholeDayRecForUpdate:::::::::'+wholeDayRecForUpdate);
        
        if(updateTimeCardDayList.size() > 0){
           update updateTimeCardDayList;
           
           // Added to another list perform submit action
           
           if(updationRecIdSet.size() > 0) {
               for(AcctSeed__Time_Card_Day__c dayRec : updateTimeCardDayList) {
                   if(dayRec.Status__c != 'Unposted' && dayRec.Status__c != 'Approved' 
                       && dayRec.Status__c != 'Admin Approved')
                       submitActiondayList.add(dayRec);
               }
           }
           
           submitActiondayList.addAll(wholeDayRecForUpdate);
               
        }else {
            submitActiondayList.addAll(wholeDayRecForUpdate);
        } 
        
        system.debug(':::::timeCardDayCreationList:::::::'+timeCardDayCreationList);
        system.debug(':::::::after:update::::::list::'+submitActiondayList.size());
            
        if(timeCardDayCreationList.size() > 0) {
           //insert timeCardDayCreationList;
           
           //Update the existing unposted time card day records with new values
           // Added on March 2 2017 by Sukanya
           
           Database.SaveResult[] srList = Database.insert(timeCardDayCreationList, false);
           system.debug(':::::srList:insert:::::'+srList);
           
           Map<String,Map<Date,AcctSeed__Time_Card_Day__c>> lineName_Date_DayRecMap = new Map<String,Map<Date,AcctSeed__Time_Card_Day__c>>();
           List<AcctSeed__Time_Card_Day__c> dayUpdationList = new List<AcctSeed__Time_Card_Day__c>();
           Set<Id> newDayIdsSet = new Set<Id>();
           
           for (Database.SaveResult sr : srList) {
               system.debug(':::::::sr::::::'+sr);
                
                if(sr.isSuccess()) {
                    //AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c();
                    //day.Id = sr.getId();
                    
                    // Added to another list perform submit action
                    //submitActiondayList.add(day);
                    newDayIdsSet.add(sr.getId());
                }
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('::::::::::::::: ' + err.getMessage());
                        if(err.getMessage().contains('TCL-')){
                            String lineName = 'TCL-'+err.getMessage().split('TCL-')[1];
                            system.debug('::::::lineName:::::'+lineName);
                            
                            String dateValueStr = err.getMessage().split('day record for ')[1].split(' already exists')[0];
                            
                            String mnth = dateValueStr.split('/')[0];
                            String dt = dateValueStr.split('/')[1];
                            String yr = dateValueStr.split('/')[2];
                            
                            String dtValue = yr+'-'+mnth+'-'+dt;
                            
                            if(!lineName_Date_DayRecMap.containsKey(lineName)) {
                                lineName_Date_DayRecMap.put(lineName,new Map<Date,AcctSeed__Time_Card_Day__c>{Date.valueOf(dtValue)=>new AcctSeed__Time_Card_Day__c()});
                            }else {
                                lineName_Date_DayRecMap.get(lineName).put(Date.valueOf(dtValue),new AcctSeed__Time_Card_Day__c());
                            }
                        }
                    }
                }
            }
            system.debug(':::::::lineName_Date_DayRecMap:::::'+lineName_Date_DayRecMap);
            
            for(AcctSeed__Time_Card_Line__c line : [SELECT Id,Name,(SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Days__r WHERE Status__c = 'Unposted') FROM AcctSeed__Time_Card_Line__c WHERE Name IN :lineName_Date_DayRecMap.keySet()]) {
                
                if(line.AcctSeed__Time_Card_Days__r != null && line.AcctSeed__Time_Card_Days__r.size() > 0) {
                    for(AcctSeed__Time_Card_Day__c dayRec : line.AcctSeed__Time_Card_Days__r) {
                    
                        if(lineName_Date_DayRecMap.containsKey(line.Name) && lineName_Date_DayRecMap.get(line.Name).containsKey(dayRec.AcctSeed__Date__c)) {
                             lineName_Date_DayRecMap.get(line.Name).put(dayRec.AcctSeed__Date__c,dayRec);
                        }
                    }
                }
            }
            
            system.debug(':::::::::lineName_Date_DayRecMap::::::'+lineName_Date_DayRecMap);
            
            for(AcctSeed__Time_Card_Day__c newDay : timeCardDayCreationList) {
                
                for(String lineName : lineName_Date_DayRecMap.keySet()) {
                    if(lineName_Date_DayRecMap.get(lineName).containsKey(newDay.AcctSeed__Date__c) 
                        && newDay.AcctSeed__Time_Card_Line__c == lineName_Date_DayRecMap.get(lineName).get(newDay.AcctSeed__Date__c).AcctSeed__Time_Card_Line__c) {
                        
                        AcctSeed__Time_Card_Day__c dayVal = new AcctSeed__Time_Card_Day__c();
                        dayVal.Id = lineName_Date_DayRecMap.get(lineName).get(newDay.AcctSeed__Date__c).Id;
                        dayVal.Total_Hours_Before_Approved__c = newDay.Total_Hours_Before_Approved__c;
                        dayVal.Status__c = newDay.Status__c;
                        dayVal.AcctSeed__Internal_Comment__c = newDay.AcctSeed__Internal_Comment__c;
                        
                        dayUpdationList.add(dayVal);
                    }
                }
            }
            
            system.debug(':::::::::dayUpdationList:::::'+dayUpdationList);
            system.debug(':::::::database:::srresult::after:::'+submitActiondayList.size());
            
            if(dayUpdationList.size() > 0) {
                update dayUpdationList;
                
                // Added to another list perform submit action
                submitActiondayList.addAll(dayUpdationList);
            }
            
            // Qry newly inserted time card day for submit action (Exclude Bonus Leave Taken - already approved records)
            if(newDayIdsSet.size() > 0) {
                for(AcctSeed__Time_Card_Day__c dayval : [SELECT Id,Name,Status__c FROM AcctSeed__Time_Card_Day__c WHERE Id IN :newDayIdsSet]) {
                    
                    // Add newly created & not approved record for submission
                    if(dayval.Status__c != 'Approved' && dayval.Status__c != 'Admin Approved')
                        submitActiondayList.add(dayVal);
                }
            }
        }
        
        system.debug(':::::::::::after:::'+submitActiondayList.size());
        
        // After save action performe the submit for capturing 2 different snapshot records
         if(actionType == 'FromSubmit') {
            for(AcctSeed__Time_Card_Day__c cardDay : submitActiondayList) {
                cardDay.Status__c = 'Submitted';
            }
            
            system.debug('::submitActiondayList::::::aftr::::status:::change:::'+submitActiondayList);
            
            if(submitActiondayList.size() > 0) {
                // Set this variable for trigger usage
                 if(actionType == 'FromSubmit'){
                     isGroupAction = true;
                     if(actionType == 'FromSubmit') {
                         groupActionType = 'Submitted';
                     }
                 }else {
                     isGroupAction = false;
                 }
                 
                 update submitActiondayList;
            }
        }
        
        // For time card line Display_in_Future_Week field updation
        /*List<AcctSeed__Time_Card_Line__c> lineFieldUpdate = new List<AcctSeed__Time_Card_Line__c>();
        for(Id lineId : lineRecIdSet) {
            AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
            line.Id = lineId;
            line.Display_in_Future_Weeks__c = false;
            lineFieldUpdate.add(line);
        }*/
        
        if(lineRecordUpdateList.size() > 0){
            update lineRecordUpdateList;
        }
     }
     
    // Get Lookup record values for Sobject
    @RemoteAction
    global static List<sObject> getLookupRecords(String objectName, String searchString, String condition) {
        return LibraryContentSearch.getLookupRecords(objectName,searchString,condition);
    }
    
}