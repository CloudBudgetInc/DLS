public class EventDomain {
    
    /***********************************************************
    - Event Reconciliation Page related wrapper
    *************************************************************/
    public class TimeCardDayInfo {
        @AuraEnabled public Id projectId;
        @AuraEnabled public String projectName;
        @AuraEnabled public Id instructorId;
        @AuraEnabled public String instructorName;
        @AuraEnabled public Id taskId;
        @AuraEnabled public String taskName;
        @AuraEnabled public String dayDate;
        @AuraEnabled public String day;
        @AuraEnabled public String dayHours;
        @AuraEnabled public Decimal hours;
        @AuraEnabled public String chargeCode;
        @AuraEnabled public Id dayId;
        @AuraEnabled public String dayChargeCode;
        @AuraEnabled public String stuApproveStatus;
        @AuraEnabled public String startTime;
        @AuraEnabled public String endTime;
        @AuraEnabled public String startTime2;
        @AuraEnabled public String endTime2;
        @AuraEnabled public String rejectionReason;
        @AuraEnabled public String status;
        @AuraEnabled public String taskType;
        @AuraEnabled public String colorCode;
        @AuraEnabled public Boolean lateCancellation;
        @AuraEnabled public Id lineId;
        @AuraEnabled public Boolean skipStudentApprovalRequiredModal; //W-007190 - Added By Dhinesh - 30/11/2021
    }
    
    public class EventInfo {
        @AuraEnabled public Id eventId;
        @AuraEnabled public String name;
        @AuraEnabled public Id scheduleId;
        @AuraEnabled public String scheduleName;
        @AuraEnabled public Id taskId;
        @AuraEnabled public String taskName;
        @AuraEnabled public Id instructorId;
        @AuraEnabled public String instructorName;
        @AuraEnabled public String eventDate;
        @AuraEnabled public String startTime;
        @AuraEnabled public String endTime;
        @AuraEnabled public Decimal duration;
        @AuraEnabled public Id projectId;
        @AuraEnabled public String projectName;
        @AuraEnabled public Id tcdId;
        @AuraEnabled public String tcdName;
        @AuraEnabled public String eventDuration;
        @AuraEnabled public String status;
        @AuraEnabled public String day;
    }
    
    public class ProjectTimeEventInfo {
        @AuraEnabled public List<TimeCardDayInfo> timeDayInfo;
        @AuraEnabled public List<EventInfo> eventInfo;
        @AuraEnabled public String projectId;
        @AuraEnabled public String projectName;
        @AuraEnabled public String projectStatus;
        @AuraEnabled public Decimal totalTCDCount;
        @AuraEnabled public Decimal totoalEventCount;
        @AuraEnabled public Decimal pendingTCDCount;
        @AuraEnabled public Decimal pendingEventCount;
        @AuraEnabled public String dlsClass;
        @AuraEnabled public String serviceItem;
        @AuraEnabled public String classification;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        @AuraEnabled public Decimal hoursUsed;
        @AuraEnabled public Decimal HoursApproved;
        @AuraEnabled public Decimal scheduledHrs;
        @AuraEnabled public String instructorName;
        @AuraEnabled public Id instructorId;
        @AuraEnabled public Boolean isPending;
        @AuraEnabled public Id proTaskId;
        @AuraEnabled public String notes;
        @AuraEnabled public String studentTimeEntry;
        @AuraEnabled public String weekDetails;
        @AuraEnabled public String projectRTName;
        @AuraEnabled public Boolean paperTimesheet;
        @AuraEnabled public Decimal eventHours;
        @AuraEnabled public Boolean showSendReminderBtn;
        @AuraEnabled public String recordType;
        @AuraEnabled public String timesheetStatus;
        @AuraEnabled public Boolean variedDay;
        @AuraEnabled public Boolean variedTime;
    }
    
    public class TimeEventDetails {
        @AuraEnabled public List<ProjectTimeEventInfo> timeEventInfo;
        @AuraEnabled public Date fromDate;
        @AuraEnabled public Date toDate;
        @AuraEnabled public List<Contact> ltsContact;
        @AuraEnabled public List<AcctSeed__Project__c> projectList;
        @AuraEnabled public List<PicklistValues> projectRecordTypeList = new List<PicklistValues>();        
    }
    
     /**********************************************************************
    - Added by Mohana on Apr 05,2019
    - For Instructor & Student Community Calendar view
    ***********************************************************************/
    
    public class EventCalendarInfo {
        @AuraEnabled
        public String eventId;
        @AuraEnabled
        public String title; 
        @AuraEnabled
        public Date eventDate;
        @AuraEnabled
        public String dateStr;
        @AuraEnabled
        public String color;
        @AuraEnabled
        public String duration;
        @AuraEnabled
        public DateTime endDateTime;
        @AuraEnabled
        public String endTime; 
        @AuraEnabled
        public DateTime startDateTime;
        @AuraEnabled
        public String startTime ;
        @AuraEnabled
        public String instructor;
        @AuraEnabled
        public String project;
        @AuraEnabled
        public String room;
        @AuraEnabled
        public String roomId;
        @AuraEnabled
        public String schedule;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String timezone;
        @AuraEnabled
        public String projectTask;
        @AuraEnabled
        public String eventType;
        @AuraEnabled
        public Boolean allDay;
        @AuraEnabled
        public String studentNames;
        @AuraEnabled
        public String eventName;
        @AuraEnabled
        public String classColour;
        @AuraEnabled
        public String dayOfWeek;
        @AuraEnabled
        public String projectId;
        @AuraEnabled
        public String instructorId;
        @AuraEnabled
        public String parentEventId;
        @AuraEnabled
        public String scheduleId;
        @AuraEnabled
        public Boolean showRescheduleBtn;
        @AuraEnabled
        public Boolean showPendingApprovalIcon;
        @AuraEnabled
        public String approvalStatus;
        @AuraEnabled
        public String rejectComment;
        @AuraEnabled
        public String parentStatusChangeTo;
        @AuraEnabled
        public string meetingUrl;
        @AuraEnabled
        public string roomName;
        @AuraEnabled
        public string parentEventStatus;
        @AuraEnabled
        public Boolean isHybridRoom;

        //For Planned Days off
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String leaveType;
        
        @AuraEnabled
        public String LTSName;
        @AuraEnabled
        public Boolean showMeetingIcons;
        @AuraEnabled
        public Boolean allowToJoinMeeting;
        @AuraEnabled
        public String instructorName;
        
        @AuraEnabled
        public Boolean showLessonPlan; //Added By Dhinesh - 23/02/2022 - Show Lesson Plan only when Share to student checkbox is true for Student community
    }
    
     public class WeekRangeValues {
        public String dateValue;
        public String dayVal;
    } 
    
    public class PicklistValues {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
    
    public class EventConflictDetail {
    
        @AuraEnabled public String eventDate;
        @AuraEnabled public String startTime;
        @AuraEnabled public String endTime;
        @AuraEnabled public String personName;
        @AuraEnabled public String roomName;
        @AuraEnabled public String instructorName;
        @AuraEnabled public String dlsClass;
    }
    
    public class EventConflictInfo {
       @AuraEnabled public Boolean isAllowForReschedule;
       @AuraEnabled public Map<String,List<EventConflictDetail>> EventConflicts;
    }
    
    public class PendingEventsInfo {
        @AuraEnabled public EventCalendarInfo selectedEvent;
        @AuraEnabled public EventCalendarInfo parentEvent;
    }
    
}