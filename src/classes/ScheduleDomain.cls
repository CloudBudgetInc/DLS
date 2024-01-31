/**********************************************************************
Created by Vinitha on Mar 29 2017: class used for Schedule__c object
***********************************************************************/
global with sharing class ScheduleDomain {
    
    /**********************************************************************
Modified by Vinitha on March 29 2017: Domain class used for EventsByRoomCloneCtrl inner class formation
***********************************************************************/
    
    global class roomRelatedinfo{
        global String RoomNumber;
        global String RoomName;        
        global String EndTime;
        global String StratTime;
        global String customInfo;
        global String RoomId;
        global String ScheduleId;  
        global String sectionType;      
    }
    
    public class ParTypeSchRecWrapper {
        @AuraEnabled public String parentType;
        @AuraEnabled public List<String> statusValue = new List<String>();
        @AuraEnabled public List<schOpliWrapper> schOpliWrap = new List<schOpliWrapper>();
        @AuraEnabled public Boolean isProjectExist;
        @AuraEnabled public Id projectId;
        @AuraEnabled public String currentUsrProfileName;
        @AuraEnabled public Boolean haveDLSClassNo;
        @AuraEnabled public String parentRecordType;
        @AuraEnabled public String onlineRoomId;
        @AuraEnabled public String roomIdsFilterConditionForLTS;
        @AuraEnabled public Boolean isDLSOnlineProject;
        
        @AuraEnabled public Map<String, Boolean> scheduleActionPermissionMap; //Added By Dhinesh - 03/03/2022 - W-007381
    }
    
    public class SchOpliWrapper {
        @AuraEnabled public Schedule__c sch = new Schedule__c();
        @AuraEnabled public OpportunityLineItem opli = new OpportunityLineItem();
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public Date travelIn;
        @AuraEnabled public Date travelOut;
        @AuraEnabled public Integer startTimeMinutes;
        @AuraEnabled public Integer endTimeMinutes;
        @AuraEnabled public String stDt;
        @AuraEnabled public String endDt;
        @AuraEnabled public Boolean allowRoomEdit;
        @AuraEnabled public Boolean isZoomRoom;
    }
    
    //Class to hold the New & Existing schedule informations
    
    public class Days {
        @AuraEnabled public Boolean monday;
        @AuraEnabled public Boolean tuesday;
        @AuraEnabled public Boolean wednesday;
        @AuraEnabled public Boolean thursday;
        @AuraEnabled public Boolean friday;
        @AuraEnabled public Boolean saturday;
        @AuraEnabled public Boolean sunday;
    }
    
    public class ScheduleDetail {
        @AuraEnabled public String scheduleId;
        @AuraEnabled public String scheduleName;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public String startTime;
        @AuraEnabled public String endTime;
        @AuraEnabled public Integer startTimeMinutes;
        @AuraEnabled public Integer endTimeMinutes; 
        @AuraEnabled public Decimal hoursPlanned;
        @AuraEnabled public String timezone;
        @AuraEnabled public Boolean variedTime;
        @AuraEnabled public Boolean variedDay;
        @AuraEnabled public String status;
        @AuraEnabled public String scheduleType;
        @AuraEnabled public String projectId;
        @AuraEnabled public String oppId;
        @AuraEnabled public String opliId;
        @AuraEnabled public String projectTaskId;
        @AuraEnabled public String instructorId;
        @AuraEnabled public String roomId;
        @AuraEnabled public Days dayVal; 
        @AuraEnabled public Date travelInDate;
        @AuraEnabled public Date travelOutDate;
        @AuraEnabled public Boolean isTravelRequired;
        @AuraEnabled public Boolean excludeFederalHoliday;
        @AuraEnabled public Decimal breakTimeHrs;
        @AuraEnabled public Decimal totalHrsPerSession;
        @AuraEnabled public String parentScheduleId;
        @AuraEnabled public String priorScheduleId;
        @AuraEnabled public Boolean isNew;
        @AuraEnabled public Boolean isUpdate;
        @AuraEnabled public Boolean isChanged;
        @AuraEnabled public Decimal totalHrsPlanned;
        @AuraEnabled public String cancellationReason;
        @AuraEnabled public String instructorName;
        @AuraEnabled public String roomName;
        @AuraEnabled public Boolean biWeekly;
        @AuraEnabled public Boolean createZoomMeetings; //W-006819 - Hybrid Class Room Scheduling
    }
    
    public class TotalOffs {
        @AuraEnabled public Date activityDate;
        @AuraEnabled public String name;
        @AuraEnabled public Date rescheduleDate;
        @AuraEnabled public String type = '';
        
        public TotalOffs(String name, Date activityDate, String type, Date rescheduleDate) {
            this.name = name;
            this.activityDate = activityDate;
            this.rescheduleDate = rescheduleDate;
            this.type = type;
        }
        
        public TotalOffs(String name, Date activityDate, String type) {
            this.name = name;
            this.activityDate = activityDate;
            this.type = type;
        }
    }
    
    public class SheduleDetailInfo {
        
        @AuraEnabled public ScheduleDetail schDetail;
        @AuraEnabled public List<String> timeValues;
        @AuraEnabled public List<String> timezoneValues;
        @AuraEnabled public List<OpportunityLineItem> opliRecords;
        @AuraEnabled public List<AcctSeed__Project_Task__c> projectTaskRecords;
        @AuraEnabled public Map<Id,Decimal> opliTaskIdAlottedHrs;
        @AuraEnabled public Date stDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public String scheduleType;
        @AuraEnabled public String parentRTName;
        @AuraEnabled public List<TotalOffs> holidays;
        @AuraEnabled public Map<Id,Decimal> totalPlannedHrsMap;
        @AuraEnabled public Map<Id,ScheduleDetail> exisitngSchedules;
        @AuraEnabled public String defaultCRRateType;
    }
    
     /**********************************************************************
    - Added by Mohana on Mar 28 2019
    - For Instructor & Student Community Schedule List view changes
    ***********************************************************************/
    public class ScheduleInfo {
    
        public Id scheduleId;
        public String name;
        public String dlsClass;
        public String status;
        public String days;
        public String startDate;
        public String endDate;
        public Date stDate;
        public Date edDate;
        public String startTime;
        public String endTime;
        public String projectTask;
        public String instructor;
        public String room;
        public Decimal totalHoursPerSession;
        public Decimal totalHours;
        public String unit;
        public String timezone;
        public string projectTaskType;
    }
    
}