/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 02/01/2023
 * @last modified by  : Dhinesh Kumar
**/
public class EventTranslator {

    /*********************************************************
    - Time Card Day info formation for Event Reconciliation page
    - Created by NS on Oct 30 2018
    ***********************************************************/
    
    public static List<EventDomain.TimeCardDayInfo> tcdRecordsFormation(List<AcctSeed__Time_Card_Day__c> dayRecords){
    
        List<EventDomain.TimeCardDayInfo> keyDayDetails = new List<EventDomain.TimeCardDayInfo>();
        
        for(AcctSeed__Time_Card_Day__c day : dayRecords){
            
            EventDomain.TimeCardDayInfo dayInfo = new EventDomain.TimeCardDayInfo();
            dayInfo.projectId = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            dayInfo.projectName = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name;
            dayInfo.instructorId = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
            dayInfo.instructorName = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name;
            dayInfo.taskId = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            dayInfo.taskName = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name;
            dayInfo.dayDate = String.valueOf(day.AcctSeed__Date__c).split('-')[1]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[2]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[0];
            dayInfo.hours = day.Total_Hours_Before_Approved__c;
            dayInfo.dayHours = string.valueOf(day.Total_Hours_Before_Approved__c);
            dayInfo.stuApproveStatus = day.Student_Approval_Status__c;
            dayInfo.skipStudentApprovalRequiredModal = true; //Modified By Dhinesh - 27/1/2023 - W-007702 - Skip Student Approval validation //(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName == 'Testing_Projects' || day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.No_Student_Approval__c || day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c == 'Preparation time');
            dayInfo.day = day.Week_Day__c;
            
            if(day.Start_Time1__c != null && day.End_Time1__c != null){
                dayInfo.startTime = day.Start_Time1__c;
                dayInfo.endTime = day.End_Time1__c;
            }
            if(day.Start_Time2__c != null && day.End_Time2__c != null){
                dayInfo.startTime2 = day.Start_Time2__c;
                dayInfo.endTime2 = day.End_Time2__c;
            }
            
            dayInfo.dayId = day.Id;
            dayInfo.status = day.Status__c;
            dayInfo.rejectionReason = day.AcctSeed__Invoice_Comment__c;
            dayInfo.taskType = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c;
            dayInfo.lateCancellation = day.Late_Cancellation__c;
            dayInfo.lineId = day.AcctSeed__Time_Card_Line__c;
            
            String billingType;
                    
            if(day.AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c) {
                billingType = 'Billable';
            } else {
                billingType = 'Non - Billable';
            }
            
            //String code = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name+' / '+day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name+' / ';
            String code = dayInfo.dayDate +' / '+day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name+' / ';
            code += day.AcctSeed__Time_Card_Line__r.Payroll_Item__c+' / '+billingType+' / '+day.AcctSeed__Time_Card_Line__r.Location__r.Name;
            
            
            
            String dayCode = dayInfo.dayDate +' / '+ day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name+' / ';
            dayCode += day.AcctSeed__Time_Card_Line__r.Payroll_Item__c+' / '+billingType;
            
            dayInfo.chargeCode = code;
            dayInfo.dayId = day.Id;
            dayInfo.dayChargeCode = dayCode;
            
            if(dayInfo.taskType == 'Language Training'){
                dayInfo.colorCode = 'trainingClass';
            }else if(dayInfo.taskType == 'Preparation time'){
                dayInfo.colorCode = 'prepClass';
            }
            
            keyDayDetails.add(dayInfo);
        
        }
        
        return keyDayDetails;
    }
    
    /*****************************************************************************
    - Event details formation for Event Reconciliation page
    - Created by NS on Oct 30 2018
    *****************************************************************************/
    public static List<EventDomain.EventInfo> eventDetailsFormation(List<Events__c> eventRecords){
        
        List<EventDomain.EventInfo> keyEventDetails = new List<EventDomain.EventInfo>();
        
        for(Events__c eve : eventRecords){
            
            EventDomain.EventInfo eventInfo = new EventDomain.EventInfo();
           
            eventInfo.eventId = eve.Id;
            eventInfo.name = eve.Name;
            eventInfo.scheduleId = eve.Schedule__c;
            eventInfo.scheduleName = eve.Schedule__r.Name;
            eventInfo.taskId = eve.Schedule__r.Project_Task__c;
            eventInfo.taskName = eve.Schedule__r.Project_Task__r.Name;
            eventInfo.instructorId = eve.Instructor__c;
            eventInfo.instructorName = eve.Instructor__r.Name;
            eventInfo.eventDate = String.valueOf(eve.Date__c).split('-')[1]+'/'+String.valueOf(eve.Date__c).split('-')[2]+'/'+String.valueOf(eve.Date__c).split('-')[0];
            eventInfo.startTime = eve.Start_Time__c;
            eventInfo.endTime = eve.End_Time__c;
            eventInfo.duration = eve.Duration__c;
            eventInfo.eventDuration = string.valueOf(eve.Duration__c);
            eventInfo.projectId = eve.Project__c;
            eventInfo.projectName = eve.Project__r.Name;
            eventInfo.status = eve.Status__c;
            
            DateTime evDate = DateTime.newInstance(eve.Date__c, Time.newInstance(0, 0, 0, 0));
            eventInfo.day = evDate.format('EEEE');
            
            if(eve.Time_Card_Day__c != null){
                eventInfo.tcdId = eve.Time_Card_Day__c;
                String billingType;
                    
                if(eve.Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c) {
                    billingType = 'Billable';
                } else {
                    billingType = 'Non - Billable';
                }
                
                Date tcdDtValue = eve.Time_Card_Day__r.AcctSeed__Date__c;
                
                string tcdDate = String.valueOf(tcdDtValue).split('-')[1]+'/'+String.valueOf(tcdDtValue).split('-')[2]+'/'+String.valueOf(tcdDtValue).split('-')[0];
                
                //String code = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name+' / '+day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name+' / ';
                String code = tcdDate +' / '+eve.Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name+' / ';
                code += eve.Time_Card_Day__r.AcctSeed__Time_Card_Line__r.Payroll_Item__c+' / '+billingType+' / '+eve.Time_Card_Day__r.AcctSeed__Time_Card_Line__r.Location__r.Name;
                
                eventInfo.tcdName = code;
            }
            
            keyEventDetails.add(eventInfo);
        }
        
        return keyEventDetails;
    }
    
    /***********************************************************************
    - Method form the total event records count per project
    - Created by NS on Nov 2 2018
    **********************************************************************/
    public static Map<String,Decimal> eventsCountCalculationPerProject(List<Events__c> eventRecords){
        
        Map<String,Decimal> projectIdEventsCnt = new Map<String,Decimal>();
        
        for(Events__c eve : eventRecords){
            if(!projectIdEventsCnt.containsKey(eve.Instructor__c+'-'+eve.Project__c)){
                projectIdEventsCnt.put(eve.Instructor__c+'-'+eve.Project__c,1);
            }else {
                projectIdEventsCnt.put(eve.Instructor__c+'-'+eve.Project__c,projectIdEventsCnt.get(eve.Instructor__c+'-'+eve.Project__c) + 1);
            }
        }
        
        return projectIdEventsCnt;
    }
    
    /*******************************************************************************
    - Method to form total tcd records count per project
    - Created by NS on Nov 2 2018
    *******************************************************************************/
    public static Map<Id,Decimal> dayCountCalculationPerProject(List<AcctSeed__Time_Card_Day__c> tcdRecords){
        
        Map<Id,Decimal> projectIdTCDCnt = new Map<Id,Decimal>();
        
        for(AcctSeed__Time_Card_Day__c day : tcdRecords){
            if(!projectIdTCDCnt.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c)){
                projectIdTCDCnt.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,1);
            }else {
                projectIdTCDCnt.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,projectIdTCDCnt.get(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c) + 1);
            }
        }
        
        return projectIdTCDCnt;
    }
    
    /*********************************************************************************
    - Project summary table data formation
    - Created by NS on Oct 30 2018
    **********************************************************************************/
    public static EventDomain.TimeEventDetails timeEventGroupedDetails(Map<String,Integer> pendingDayCount,Map<String,Integer> pendingEventCount,List<AcctSeed__Project__c> projectDetails,Date stDate,Date endDate,Map<String,Decimal> proIdTCDHrs,List<Contact> contactRecords,Map<String,Decimal> projectIdTCDApprovedHrs,String viewType,Map<Id,Boolean> projectIdEventExist,Map<Id,Decimal> projIdEventsHrs,Map<Id,String> proIdTimesheetStatus, Map<Id, Map<Id, Schedule__c>> projectIdWithInstructorAndScheduleMap, Map<String,Integer> proIdStuApprovedDayCount){
        
        Map<Id,String> projectIdName = new Map<Id,String>();
        EventDomain.TimeEventDetails timeEventInfo = new EventDomain.TimeEventDetails();
        Set<String> recordTypeSet = new Set<String>();
        List<EventDomain.ProjectTimeEventInfo> proTimeEventInfo = new List<EventDomain.ProjectTimeEventInfo>();
        List<AcctSeed__Project__c> proList = new  List<AcctSeed__Project__c>();
        for(AcctSeed__Project__c pro : projectDetails){
           
            for(Contact_Assignments__c conAssign : pro.Contact_Assignments__r){
                
                EventDomain.ProjectTimeEventInfo proTimeEvent = new EventDomain.ProjectTimeEventInfo();
                proTimeEvent.projectId = pro.Id;
                proTimeEvent.proTaskId = conAssign.Project_Task__c;
                proTimeEvent.projectName = pro.Name;
                proTimeEvent.projectStatus = pro.AcctSeed__Status__c;
                proTimeEvent.dlsClass = pro.DLS_Class__c;
                proTimeEvent.serviceItem = pro.Service_Item__c;
                proTimeEvent.classification = pro.QB_Classification__c;
                proTimeEvent.paperTimesheet = conAssign.Paper_Timesheet__c;
                proTimeEvent.recordType = pro.RecordType.DeveloperName;
                
                if(pro.Start_Date__c != null) {
                    proTimeEvent.startDate = String.valueOf(pro.Start_Date__c).split('-')[1]+'/'+String.valueOf(pro.Start_Date__c).split('-')[2]+'/'+String.valueOf(pro.Start_Date__c).split('-')[0];
                }
                
                if(pro.End_Date__c != null) {
                    proTimeEvent.endDate = String.valueOf(pro.End_Date__c).split('-')[1]+'/'+String.valueOf(pro.End_Date__c).split('-')[2]+'/'+String.valueOf(pro.End_Date__c).split('-')[0];
                }
                if(proIdTCDHrs.containsKey(conAssign.Candidate_Name__c+'-'+pro.Id)) {
                    proTimeEvent.hoursUsed = proIdTCDHrs.get(conAssign.Candidate_Name__c+'-'+pro.Id);
                }else {
                    proTimeEvent.hoursUsed = 0;
                }
                
                if(projectIdTCDApprovedHrs.containsKey(conAssign.Candidate_Name__c+'-'+pro.Id)) {
                    proTimeEvent.HoursApproved = projectIdTCDApprovedHrs.get(conAssign.Candidate_Name__c+'-'+pro.Id);
                }else {
                    proTimeEvent.HoursApproved = 0;
                }
                
                //Project related Events Hours
                if(projIdEventsHrs.containsKey(pro.Id)){
                    proTimeEvent.eventHours = projIdEventsHrs.get(pro.Id);
                }else {
                    proTimeEvent.eventHours = 0;
                }
                
                proTimeEvent.scheduledHrs = pro.Scheduled_Hours_Week__c;
                proTimeEvent.instructorName = conAssign.Candidate_Name__r.name;
                proTimeEvent.instructorId = conAssign.Candidate_Name__c;
                
                //Pending Count
                proTimeEvent.pendingTCDCount = pendingDayCount.containsKey(conAssign.Candidate_Name__c+'-'+pro.Id) ? pendingDayCount.get(conAssign.Candidate_Name__c+'-'+pro.Id) : 0;
                proTimeEvent.pendingEventCount = pendingEventCount.containsKey(conAssign.Candidate_Name__c+'-'+pro.Id) ? pendingEventCount.get(conAssign.Candidate_Name__c+'-'+pro.Id) : 0;
                
                proTimeEvent.isPending = false; 
                proTimeEvent.variedDay = false;
                proTimeEvent.variedTime = false;
                
                //W-006901 - Modified by Dhinesh - 22-09-2021
                if(projectIdWithInstructorAndScheduleMap.get(pro.Id) != null && projectIdWithInstructorAndScheduleMap.get(pro.Id).get(conAssign.Candidate_Name__c) != null){
                    proTimeEvent.variedDay = projectIdWithInstructorAndScheduleMap.get(pro.Id).get(conAssign.Candidate_Name__c).Varied_Day__c;
                    proTimeEvent.variedTime = projectIdWithInstructorAndScheduleMap.get(pro.Id).get(conAssign.Candidate_Name__c).Varied_Time__c;
                } 
                
                Boolean addCurrentProject = false;
                
                if(viewType != 'All' && viewType != 'No Time Entries'){
                    if(viewType == 'Pending Approval - Student Approved' && proTimeEvent.pendingTCDCount > 0 &&  proIdStuApprovedDayCount.containsKey(conAssign.Candidate_Name__c+'-'+pro.Id) && proIdStuApprovedDayCount.get(conAssign.Candidate_Name__c+'-'+pro.Id) == proTimeEvent.pendingTCDCount){
                        addCurrentProject = true;
                    }else if(viewType == 'Pending Approval - Student Not Approved' && proTimeEvent.pendingTCDCount > 0 &&  ((!proIdStuApprovedDayCount.containsKey(conAssign.Candidate_Name__c+'-'+pro.Id)) || (proIdStuApprovedDayCount.containsKey(conAssign.Candidate_Name__c+'-'+pro.Id) && proIdStuApprovedDayCount.get(conAssign.Candidate_Name__c+'-'+pro.Id) != proTimeEvent.pendingTCDCount))){
                        addCurrentProject = true;
                    }else if(viewType != 'Pending Approval - Student Approved' && viewType != 'Pending Approval - Student Not Approved' && proTimeEvent.pendingTCDCount > 0){
                        addCurrentProject = true;
                    }
                }else if(viewType == 'No Time Entries'){                    
                    
                    //W-006752 - Added events count 0 & events not existing conditions to include the projects which have varied day & time schedules                   
                    if(proTimeEvent.pendingTCDCount == 0  && (proTimeEvent.pendingEventCount > 0 || (proTimeEvent.pendingEventCount == 0 && (proTimeEvent.variedDay || proTimeEvent.variedTime || pro.RecordType.DeveloperName == 'Testing_Projects'))) 
                        && (!projectIdEventExist.containsKey(pro.Id) || (projectIdEventExist.containsKey(pro.Id) && projectIdEventExist.get(pro.Id)))
                        && (!proIdTCDHrs.containsKey(conAssign.Candidate_Name__c+'-'+pro.Id) /*|| (proIdTCDHrs.containsKey(conAssign.Candidate_Name__c+'-'+pro.Id) 
                            && proIdTCDHrs.get(conAssign.Candidate_Name__c+'-'+pro.Id) == 0)*/)){
                            
                        addCurrentProject = true;                              
                    }
                }else if(viewType == 'All'){
                    if(proTimeEvent.pendingTCDCount > 0 || (projectIdEventExist.containsKey(pro.Id) && projectIdEventExist.get(pro.Id)) 
                    || proTimeEvent.pendingEventCount > 0 || (proTimeEvent.pendingEventCount == 0 && (proTimeEvent.variedDay || proTimeEvent.variedTime || pro.RecordType.DeveloperName == 'Testing_Projects'))){
                        addCurrentProject = true;
                    }
                }
                
                if(viewType == 'All'){
                
                    if(proIdTimesheetStatus.containsKey(pro.Id)){
                        proTimeEvent.timesheetStatus = proIdTimesheetStatus.get(pro.Id);
                    }else {
                        proTimeEvent.timesheetStatus = 'No Time Entries';
                        //W-006901 - Modified by Dhinesh - 22-09-2021
                        if(projectIdWithInstructorAndScheduleMap.get(pro.Id) != null && projectIdWithInstructorAndScheduleMap.get(pro.Id).get(conAssign.Candidate_Name__c) != null){
                            proTimeEvent.variedDay = projectIdWithInstructorAndScheduleMap.get(pro.Id).get(conAssign.Candidate_Name__c).Varied_Day__c;
                            proTimeEvent.variedTime = projectIdWithInstructorAndScheduleMap.get(pro.Id).get(conAssign.Candidate_Name__c).Varied_Time__c;
                        } 
                    }   
                }
                
                if(addCurrentProject){
                    proTimeEventInfo.add(proTimeEvent);
                    if(!projectIdName.containsKey(pro.Id)){
                        proList.add(pro);
                    }                    
                }
            }
            
            if(!recordTypeSet.contains(pro.RecordType.DeveloperName)) {
                EventDomain.PicklistValues recordTypeWrap = new EventDomain.PicklistValues();
                recordTypeWrap.label = pro.RecordType.Name;
                recordTypeWrap.value = pro.RecordType.DeveloperName;
                timeEventInfo.projectRecordTypeList.add(recordTypeWrap);
                
                recordTypeSet.add(pro.RecordType.DeveloperName);
            }
            
        }
        timeEventInfo.projectList = proList;
        timeEventInfo.timeEventInfo = proTimeEventInfo;
        timeEventInfo.fromDate = stDate;
        timeEventInfo.toDate = endDate;
        timeEventInfo.ltsContact = contactRecords;
        
        return timeEventInfo;
    }
    
    /*****************************************
    - Project based Event & Time Card day formation
    - Added by NS on Dec 13 2018
    *******************************************/
    public static EventDomain.ProjectTimeEventInfo formEventTimeDetails(List<AcctSeed__Time_Card_Day__c> dayList,List<Events__c> eventList){
    
        EventDomain.ProjectTimeEventInfo proInfo = new EventDomain.ProjectTimeEventInfo();
        proInfo.timeDayInfo = tcdRecordsFormation(dayList);
        proInfo.eventInfo = eventDetailsFormation(eventList);
        
        return proInfo;
    }
    
     /**********************************************************************
    - Added by Mohana on Apr 05,2019
    - For Instructor & Student Community Calendar view
    ***********************************************************************/
    
    public static List<EventDomain.EventCalendarInfo> eventCalendarInfo(List<Events__c> eventList,List<Holiday> holidays,Map<Id,String> proIdStudentNames,List<Planned_Days_Off__c> planedLeaves,Date startDate,Date endDate,Set<Id> childEventRelParentIds, Map<Id,Date> transferedCAWithDatesMap){
        List<EventDomain.EventCalendarInfo> eventCalendarInfoList = new List<EventDomain.EventCalendarInfo>();
        String communityName = EventCalendarController.getCommunityPathPrefix();
        TimezoneUtilClass utilCls = new TimezoneUtilClass();        
        Contact con;
        List<String> rescheduleNotAllowedProjectRecordType = new List<String>{'DLI_W_LT_Projects', 'DODA_Projects'};
        
        Map<Id, Boolean> eventIdWithShowLessonPlanMap = new Map<Id, Boolean>();
        
        if(communityName == 'student'){
            Id contactId = EventCalendarController.getLoggedUserContactId();
            con = [SELECT Id, Account.Name FROM Contact WHERE Id = :contactId LIMIT 1];            
        }
        
        Set<Id> eventIds = (new Map<Id, Events__c>(eventList)).keySet();
        for(Lesson_Plan__c lp : [SELECT Event__c, Share_with_my_student_s__c FROM Lesson_Plan__c WHERE Event__c IN :eventIds]){
            eventIdWithShowLessonPlanMap.put(lp.Event__c, lp.Share_with_my_student_s__c);
        }
        
        DateTime dT = utilCls.getUserTimeZoneDateTime(System.now());
		Date todayDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        for(Events__c event : eventList){
            EventDomain.EventCalendarInfo eventInfo = new EventDomain.EventCalendarInfo();
            eventInfo.eventId = event.Id;
            eventInfo.eventName = event.Name;
            eventInfo.color = event.Id;
            eventInfo.duration = String.valueOf(event.Duration__c);
            Boolean showEvents = true;
            
            /* Current User TimeZone DateTime Convertion */
            eventInfo.endDateTime = utilCls.getUserTimeZoneDateTime(event.End_Date_Time__c);
            eventInfo.startDateTime = utilCls.getUserTimeZoneDateTime(event.Start_Date_Time__c);
            eventInfo.startTime = utilCls.getTimeStringFromDatetime(eventInfo.startDateTime);
            eventInfo.endTime = utilCls.getTimeStringFromDatetime(eventInfo.endDateTime);
            
            if(eventInfo.startDateTime != null){
                 event.Date__c = date.newinstance(eventInfo.startDateTime.year(), eventInfo.startDateTime.month(), eventInfo.startDateTime.day());
            }
            
            if(event.Date__c != null){
                eventInfo.dateStr = String.valueOf(event.Date__c).split('-')[1]+'/'+String.valueOf(event.Date__c).split('-')[2]+'/'+String.valueOf(event.Date__c).split('-')[0];
            } 
            
            eventInfo.eventDate = event.Date__c;
            eventInfo.title =  eventInfo.startTime+'-'+eventInfo.endTime+' / '+event.project__r.DLS_Ref__c+' / '+event.Room__r.Name;
            eventInfo.instructor = event.Instructor__r.Name;
            eventInfo.project = event.project__r.DLS_Ref__c;
            eventInfo.room = event.Schedule__c != null && event.Schedule__r.Create_Zoom_Meetings__c ? 'Zoom - Online/'+event.Room__r.Name : event.Room__r.Name;
            eventInfo.roomId = event.Room__c;
            eventInfo.schedule = event.Schedule__r.Name;
            eventInfo.status = event.Status__c;
            eventInfo.timezone = UserInfo.getTimeZone().getID();//event.Timezone__c;
            eventInfo.projectTask = event.Schedule__c != null ? event.Schedule__r.Project_Task__r.Name : event.Project_Task__r.Name;
            eventInfo.eventType = event.Schedule__c != null ? event.Schedule__r.Project_Task__r.Project_Task_Type__c : event.Project_Task__r.Project_Task_Type__c;
            eventInfo.dayOfWeek = event.Day_of_Week__c;
            eventInfo.projectId = event.Project__c;
            eventInfo.instructorId = event.Instructor__c;
            eventInfo.parentEventId = event.Parent_Event__c;
            eventInfo.scheduleId = event.Schedule__c;
            eventInfo.approvalStatus = event.Approval_Status__c;
            eventInfo.rejectComment = event.Reject_Comment__c;
            eventInfo.showPendingApprovalIcon = false;
            eventInfo.isHybridRoom = event.Schedule__r.Create_Zoom_Meetings__c;
            
            //Modified By Dhinesh - W-006013 - Zoom Integration - show meeting url for the event in community 
            //eventInfo.meetingUrl = event.Schedule__r.Meeting_URL__c;
            eventInfo.meetingUrl = event.Meeting_URL__c;
            eventInfo.showMeetingIcons = event.Meeting_URL__c == null && event.Status__c == 'Scheduled' && eventInfo.eventType != 'Preparation time';
            eventInfo.allowToJoinMeeting = (todayDate == event.Date__c);
            eventInfo.parentEventStatus= event.Parent_Event__r.Status__c;
            
            if(communityName == 'student' && event.Status__c == 'Scheduled' && isEventAllowedForReschedule(event.Start_Date_Time__c, event.Timezone__c) && (!childEventRelParentIds.contains(event.Id)) && event.Project__r.AcctSeed__Account__r.Name == 'Softsquare ELT' && con != null && con.Account.Name == 'Softsquare ELT' && ( (event.Project__r.RecordType.DeveloperName == 'DODA_Projects' && event.Project__r.Project_Type__c == 'JMAS') || !(rescheduleNotAllowedProjectRecordType.contains(event.Project__r.RecordType.DeveloperName)))){
                eventInfo.showRescheduleBtn = true;
            }else {
                eventInfo.showRescheduleBtn = false;
            }
            
            //Modified By Dhinesh - W-006142 - Request an Event feature for Student Community - show the requested events in grey as like as rescheduled events
            if((event.Parent_Event__c != null  || (eventInfo.approvalStatus == 'Pending LTS Approval' || eventInfo.approvalStatus == 'LTS Approved')) //&& event.Approval_Status__c == 'Submitted for Approval'
                && event.Status__c == 'Draft'){
                
                eventInfo.eventType = 'PendingApproval';
                eventInfo.color = '#6c757d';
                eventinfo.classColour = 'pendingApproval';
            }else {
                
                if(eventInfo.eventType == 'Language Training'){
                    // if(eventInfo.eventType == 'Pending LTS Approval' || eventInfo.eventType == 'LTS Approved') {
                    //     eventInfo.color = '#1D4588';
                    // } else {
                    //     eventInfo.color = '#1D4588';
                    // }
                    eventInfo.color = '#1D4588';
                    eventinfo.classColour = 'trainingClass';
                }else if(eventInfo.eventType == 'Preparation time') {
                    eventInfo.color = '#8E24AA';
                    eventinfo.classColour = 'preparationClass';
                }else if(eventInfo.eventType == 'Language Testing') {
                    eventInfo.color = '#ABD25A';
                    eventinfo.classColour = 'testingClass';
                }    
                
            }
            
            eventInfo.allDay = false;   
            eventInfo.studentNames = proIdStudentNames.containsKey(event.Project__c) ? proIdStudentNames.get(event.Project__c) : null;
            eventInfo.LTSName = event.Project__r.Project_Manager__c != null ? event.Project__r.Project_Manager__r.Name : '';
            String instructorName = '';
                
            instructorName = (event.Instructor__r.FirstName == null ? '' : event.Instructor__r.FirstName);
            instructorName += (event.Instructor__r.LastName != null ? ' '+ event.Instructor__r.LastName.subString(0,1) +'.' : '');
            eventInfo.instructorName = instructorName;
            eventInfo.showLessonPlan = communityName == 'instructor' ? eventIdWithShowLessonPlanMap.keySet().contains(event.Id) : (eventIdWithShowLessonPlanMap.get(event.Id) != null ? eventIdWithShowLessonPlanMap.get(event.Id) : false);
                
            if(communityName == 'student' || communityName == ''){//W-007991 - Update to Transfer Button Functionality on Student CA
                if(transferedCAWithDatesMap.size() > 0 && transferedCAWithDatesMap.containsKey(event.Project__c)){
                    Date transferedDate = transferedCAWithDatesMap.get(event.Project__c);
                    if(event.Date__c != null && transferedDate != null && (event.Date__c > transferedDate)){
                        showEvents = false;   
                    }
                }
            } 
            
            if(showEvents == true){
                eventCalendarInfoList.add(eventInfo);
            }
        }
        
        if(holidays.size() > 0){
            for(Holiday hol : holidays){
                
                EventDomain.EventCalendarInfo holInfo = new EventDomain.EventCalendarInfo();
                holInfo.title = hol.Name;
                holInfo.eventId = hol.Id;
                holInfo.eventName = hol.Name;
                holInfo.eventDate = hol.ActivityDate;
                holInfo.eventType = 'Holiday';
                holInfo.color = '#4D4D4D';
                holinfo.classColour = 'holidayClass';
                holInfo.allDay = true;
                
                if(startDate != null && endDate != null){
                    if(hol.ActivityDate >= startDate && hol.ActivityDate <= endDate){
                        eventCalendarInfoList.add(holInfo);   
                    }
                }else{
                    eventCalendarInfoList.add(holInfo);   
                }
            }
        }
       
        if(planedLeaves.size() > 0){
            
            for(Planned_Days_Off__c plan : planedLeaves){
                
                EventDomain.EventCalendarInfo plannedleaveInfo = new EventDomain.EventCalendarInfo();
                plannedleaveInfo.title = 'Planned Day Off / '+plan.Contact__r.Name;
                plannedleaveInfo.eventId = plan.Id;
                plannedleaveInfo.eventName = plan.Name;
                plannedleaveInfo.eventDate = plan.Date__c;
                plannedleaveInfo.eventType = ((plan.Type__c == 'Student') ? 'StudentPDO' : 'InstructorPDO');
                plannedleaveInfo.color = ((plan.Type__c == 'Student') ? '#8B0000' : '#F37321');
                plannedleaveInfo.classColour = ((plan.Type__c == 'Student') ? 'studentPDOClass' : 'instructorPDOClass');
                plannedleaveInfo.allDay = true;
                plannedleaveInfo.status = plan.Status__c;
                
                if(plan.Date__c != null){
                    plannedleaveInfo.dateStr = String.valueOf(plan.Date__c).split('-')[1]+'/'+String.valueOf(plan.Date__c).split('-')[2]+'/'+String.valueOf(plan.Date__c).split('-')[0];
                }
                
                plannedleaveInfo.description = plan.Description__c;
                plannedleaveInfo.type = plan.Type__c;
                plannedleaveInfo.leaveType = plan.Leave_Type__c;
                
                if(startDate != null && endDate != null){
                    if(plan.Date__c >= startDate && plan.Date__c <= endDate){
                        eventCalendarInfoList.add(plannedleaveInfo);  
                    }
                }else{
                    eventCalendarInfoList.add(plannedleaveInfo);   
                }
            }
        }
        return eventCalendarInfoList;
    } 
    
    public static Boolean isEventAllowedForReschedule(DateTime eventStartTime, String eventTimeZone){
        TimezoneUtilClass utilCls = new TimezoneUtilClass(); 
        DateTime minDateTimeToRescheduleInEventTimeZone = utilCls.convertTimeZoneDateTime(System.now().addDays(1), eventTimeZone);        
        DateTime eventStartTimeInEventTimeZone = utilCls.convertTimeZoneDateTime(eventStartTime, eventTimeZone);
        
        return eventStartTimeInEventTimeZone > minDateTimeToRescheduleInEventTimeZone;
    }
}