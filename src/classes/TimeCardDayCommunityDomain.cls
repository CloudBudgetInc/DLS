/**********************************************************************
    Created by Sukanya on Apr 4 2019: Domain class used for Time card Day object Community related wrapper class formation
***********************************************************************/
public class TimeCardDayCommunityDomain {
    
    /*****************************************************************
    - Created by NS on MAR 4 2019
    - For Instructor Time Entry Lightning Component Initial Filter Wrapper design
    *****************************************************************/
    public class InitialFilterValues {
        
        public List<String> weekFilter;
        public String selectedWeek;
        public String employeeName;
        public String contactId;
        public List<String> timeList;
        public String timekeepingTopicId;
        public List<String> attendancePickList;
        
        //Added By Dhinesh - 20/03/2023 - W-007729 - Timekeeping Fields to Indicate if the Time was entered On Time or Late
        public Integer timeEnteredOnTime;
        public Integer timeEnteredLate;
        public Integer timeSubmittedOnTime;
        public Integer timeSubmittedLate;
        public Boolean showStaffTimeEntry;
    }
    public class ProjectFilterInfo {
        public List<ProjectStudentInfo> projectFilter;
        public Map<Id,String> proIdSupervisorName;
        public Map<Id,String> proIdInstructorName;
        public Map<String,String> instructorRelatedProjects;
        public Map<Id,String> projectRelatedStudentNames;
        public Map<Id,String> projectIdInsPosition;
        public Map<Id,Boolean> projectIdTimeCompleted;    // To show msg based on this map in time entry complete btn click
        public Map<Id,String> proIdStuLeaderName;
    }
    
    public class ProjectStudentInfo {
    
        public String projectId;
        public String projectName;
        public String projectRTName;
        public String projectRTId;
        public Boolean noStudentApproval;
        public Boolean noStudentHrsVerification;
        
        //For Admin Time Entry Instructor View
        public String name;
        public String dlsClassNo;
        public String locationId;
        public String locationName;
    }
    
    /***********************************************************
    - Wrapper for Instructor Time Entry Day rows display
    - Added by NS on MAR 4 2019
    ************************************************************/
    
    public class DayEntries {
        public String chargeCode;
        public Decimal hours;
        public Id dayId;
        public Id lineId;
        public Id projectId;
        public Id taskId;
        public Id locationId;
        public Boolean isBillable;
        public String payrollItem;
        public String status;
        public Date dateVal;
        public String comments;
        public Id costrateId;
        public Id contactAssignid;
        public Integer sequenceNumber;
        public Boolean isNew;
        public Boolean isUpdated;
        public String projectRTName;
        public String projectName;
        public String taskName;
        public String taskType;
        public String locationName;
        public Boolean isHrsDisabled;
        
        public String cancellationReason;
        public String rejectionReason;
        public String studentApprovalStatus;
        public String color;
        public Boolean lateCancellation;
        public String startTime1;
        public String endTime1;
        public String startTime2;
        public String endTime2;
        public String displayDate;
        public String dayHours;
        public String dayType;
        public Boolean showEditIcon;
        public Boolean showReverseIcon;
        public Boolean showApproveRejectIcon;
        public String recallReason;
        public String studentNames; // For old TCD & New TCD comparision validation msg
        public Boolean isCompleted; //For Instructor Time Entry complete action purpose
        public String weekDay;    //Used in Review & Submit page
        public Boolean hideFromStudent;    //For Admin Time Entry usage
        public Boolean isUnposted;
        
        //For Mobile instructor time entry usage
        public Integer timeRowCount;
        public String timeType;
        public String chargeCode1;
        public String chargeCode2;
        public Integer startTime1Minutes;
        public Integer endTime1Minutes;
        public Integer startTime2Minutes;
        public Integer endTime2Minutes;
        public String scheduleTimezone;
        
        public DayEntries(){
            this.dayHours = null;
            this.dayId = null;
            this.lineId = null;
            this.projectId = null;
            this.taskId = null;
            this.locationId = null;
            this.isBillable = false;
            this.payrollItem = '';
            this.status = 'Draft';
            this.dateVal = null;
            this.comments = '';
            this.costrateId = null;
            this.contactAssignid = null;
            this.sequenceNumber = 0;
            this.cancellationReason = '';
            this.startTime1 = null;
            this.endTime1 = null;
            this.startTime2 = null;
            this.endTime2 = null;
            this.lateCancellation = false;
            this.isHrsDisabled = false;
            this.showEditIcon = false;
            this.showReverseIcon = false;
            this.isCompleted = false;
            this.isUnposted = false;                        
            this.isNew = true;
            this.isUpdated = false;
        }
    }
    
     public class NotesDetails {
        
        public String daydate;
        public String comment;
        public String referenceId;
        
        public String editedDT;
        public String dayId;
        public String noteType;
        public String notes;
        public Date dateValue;    // For Mobile instructor time entry wrapper purpose
        public String userName;
    }
    
     public class ButtonDisplay {
        public Boolean submitBtn;
        public Boolean recallBtn;
        public Boolean displayRequestEditLink;
        public Boolean completeBtn;
        public Boolean showEditIconForApproved;    //temprorly use in transltor level to show edit icon for approval
    }
    
    public class InstructorRowDetails {
        public List<WeekRangeValues> weekDates;
        public List<InstructorDayDetails> entries;
        public List<NotesDetails> notes;
        public Boolean displaySubmitBtn;
        public Boolean displayRecallBtn;
        public Boolean displayRequestEditLink; // for Past week edit request access
        public Boolean alreadyCaseSubmitted;    // for Past week edit request access
        public Boolean validCRExistINCA;
        public Boolean displaySaveButton;
        public Boolean displayCompleteBtn;    //For Instructor Time Entry
        
        //Student Time Table related attributes
        public List<StudentTimeDetail> studentEntries;
        
        //For Planned Days off check
        public Map<Date,PlannedDaysOff> dateDaysOffValues;
        public List<Date> dliWLTHolidays;
        
        //W-007882 For LT with Prep Validation
        public String defaultCostRateRateType;

        //For Student Approval
        public TotalHrsDayWrapper TotalHrsDayColEntries;
        public Integer totalDayEntriesCount;
        public Integer totaldayEntriesApprovalCount;
        public String projectName;
        public Boolean isStudentLeader;
        public String studentId;
        public Boolean displayStudentHrstable;    //W-006649 - Student Hours for Language Training Projects
        public Set<Date> federalHolidays; //W-007200 - Added By Dhinesh - 06/12/2021 - to add validation when time entered on Federal Holidays
    }
    public class InstructorDayDetails {
        public String chargeCode1;
        public String chargeCode2;
        public List<DayEntries> dayEntries;
        public String totalHours;
        public Integer sequenceNumber;
        public Integer timeRowCount;
        public String timeType;
        public String taskType;
        public String taskName;
        public String scheduleTimezone;
        
        //For Student Approval
        public Integer dayEntriesApprovalCount;
        public Integer dayEntriesCount;
        public Boolean isDisplayApproveText;
        
        //For LT with Prep Validation
        public String defaultCostRateRateType;

        //For Admin Time Entry Instructor View
        public Boolean isNewRow;
    }
    
    public class WeekRangeValues {
        public String dateValue;
        public String dayVal;

        public WeekRangeValues(){
            this.dateValue = '';
            this.dayVal = '';
        }

        public WeekRangeValues(Date dt){
            this.dateValue = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0];                        
            this.dayVal = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0)).format('EEE');
        }
    } 
    
    //For Student Approval
     public class TotalHrsDayWrapper{
         public String monHrs;
         public String tueHrs;     
         public String wedHrs;
         public String thuHrs;
         public String friHrs;
         public String satHrs;
         public String sunHrs;
         public String TotaldayHrs;
    }
    
    //For Student Attendance Time Details
    public class StudentTimeDetail {
        public Id studentId;
        public String studentName;
        public List<StudentEntry> entries;
        public String totalHours;
        public Boolean isDisplayApproveText;
    }
    
    public class StudentEntry {
        public Date dateVal;
        public String dayValue;
        public String displayDate;
        public String hours;
        public Id attendanceId;
        public Id eventId;
        public Id instructorId;
        public Id studentId;
        public String studentName;
        public string studentApprovalStatus;
        public Id dayId;
        public Boolean isNew;
        public Boolean isUpdated;
        public Boolean isHrsDisabled;
        public Boolean showEditIcon;
        public Boolean showReverseIcon;
        public Boolean showApproveRejectIcon;
        public Boolean lateCancellation;
        public String rejectionReason;
        public String recallReason;
        public String comments;
        public String color;
        public String displayNotesLink;
        public Boolean eventNoStuApprovalFlag;
        public String attendance;
    }
    
     /**********************************************************************
    - Added by Mohana on Apr 04,2019
    - For Instructor & Student Community Time Card Day List view changes
    ***********************************************************************/
    public class TimeCardDayInfo{
    
        public Id dayId;
        public Date dayDate;
        public String dayDtVal;
        public String weekDay;
        public String submittedHours;
        public String studentAprroval;
        public String supervisorAprroval;
        public String projectTask;
        public String instructor;
        public String location;
        public String projectId;
        public String dlsClass;
    }
    
    public class TimeDetails {
        public List<TimeCardDayInfo> timeRecords;
        public String totalHrs;
    }
    
    public Class InitialValues {
        public List<ProjectInfo> projectRecords;
        public String communityName;
        public Date fromDate;
        public Date toDate;
    }
    
    public Class ProjectInfo{
        public String projectName;
        public String projectId;
        public String dlsClass;
        public Date startDate;
    }
    
    public Class PlannedDaysOff {
        
        public String daysOffId;
        public String daysOffDate;
        public String contactName;
        public String description;
    }
    
    
    /************************************************************************************************
    - Added by NS on July 31 2019
    - For Instructor Time Review & Submit Page
    **************************************************************************************************/
    public Class ReviewSubmitTCDDetails {
    
        public List<TimeCardDayCommunityDomain.DayEntries> entries;
        public String totalHrs;
        public Boolean allSubmitted;
        public String submittedMsg;
        public Boolean displaySubmitBtn;
        public Map<Id,String> proIdStudentNames;
        public Map<Id,AcctSeed__Project__c> notCompletedProjects;
    }
    
    
    /*********************************************************************************************************
    - Below wrapper class used in Mobile Instructor Time Entry cmp
    - Added by NS on Feb 7 2020
    **********************************************************************************************************/
    
    public class WeekSummaryDetail {
    
        public List<SummaryDetail> summary;
        public String totalHrs;
        public String studentTotal;
        public Boolean displayStudentHrs;
        
        public Boolean displaySubmitBtn;
        public Boolean displayRecallBtn;
        public Boolean displayRequestEditLink; // for Past week edit request access
        public Boolean alreadyCaseSubmitted;    // for Past week edit request access
        public Boolean validCRExistINCA;
        public Boolean displaySaveButton;
        public Boolean displayCompleteBtn; 
        
        //W-007882 For LT with Prep Validation
        public String defaultCostRateRateType;

        //For Planned Days off check
        public Map<Date,PlannedDaysOff> dateDaysOffValues;
        public List<Date> dliWLTHolidays;
        public List<NotesDetails> wholeNotes;
        public Set<Date> federalHolidays; //W-007200 - Added By Dhinesh - 06/12/2021 - to add validation when time entered on Federal Holidays
    }
    
    public class SummaryDetail {
        
        public Date dateVal;
        public String dateToDisplay;
        public String insTotalHrs;
        public String studentTotalHrs;
        public String dayType;
        public List<DayEntries> dayEntries;
        public List<StudentEntry> studentEntries;
        public List<NotesDetails> notes;
        
        //Daily View
        public String displayDate;
        public String dayValue;
        public String instructorColor;
        public String studentColor;
    }
}