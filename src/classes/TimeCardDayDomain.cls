/**********************************************************************
    Created by Sukanya on Jan 12 2017: Domain class used for Time card Day object inner class formation
***********************************************************************/

global class TimeCardDayDomain {
    
    /**********************************************************************
        Created by Sukanya on Jan 11 2017: Domain class used for DLS_Staff_Time_Entry_Ctrl inner class formation
    ***********************************************************************/
    
    global class EmployeeDetails {
        public List<AcctSeed__Project_Task__c> projectTasks;
        public List<AcctSeed__Project__c> projects;
        public List<TimeCardDay> timeCardDayDetails;
        public Id ContactId;
        Public String Name;
        public Id HomeDeptProId;
        public String HomeDepartProName;
        public Id supervisorId;
        public String supervisorName;
        public String UserName;
        public String UserTimezoneValue;
        public Date timeLogLockDate;
        public String EEPayStatus;
        public String ContactRecordType;
        public List<Accounting_Seed_Time_Snapshot__c> timeSnapshotDetails;
        public List<String> payRollItemList;
        public Set<Date> holidayList;
        public Map<String,TimeCardDay> previousWeekprojectTasks;
        public List<Document> timekeepingRelatedDocuments;
        public List<Contact_Assignments__c> contactAssignmentList;
        public List<Contact_Assignments__c> projectRelatedSupervisors;
        public Map<String,List<String>> taskName_PayrollItemMap;
        public String PaycomId;
        
        //Added By Dhinesh - 21/03/2023 - W-007729 - Timekeeping Fields to Indicate if the Time was entered On Time or Late
        public Integer timeEnteredOnTime;
        public Integer timeEnteredLate;
        public Integer timeSubmittedLate;
        public Integer timeSubmittedOnTime;
    } 
    
     /**********************************************************************
        Created by Sukanya on Jan 12 2017: Domain class used for DLS_Staff_Time_Entry_Ctrl inner class formation
    ***********************************************************************/
    
     global class TimeCardDay {
        
        public Id SelectedProject;
        public Id SelectedProTask;
        public Id SelectedInstructor;
        public String Hours1;
        public String Hours2;
        public String Hours3;
        public String Hours4;
        public String Hours5;
        public String Hours6;
        public String Hours7;
        public Date Day1;
        public Date Day2;
        public Date Day3;
        public Date Day4;
        public Date Day5;
        public Date Day6;
        public Date Day7;
        public Decimal TotalHours;
        public Id Hrs1Day1Id;
        public Id Hrs2Day2Id;
        public Id Hrs3Day3Id;
        public Id Hrs4Day4Id;
        public Id Hrs5Day5Id;
        public Id Hrs6Day6Id;
        public Id Hrs7Day7Id;
        
        public Boolean IsAdminProTask;
        public String TaskName;
        public String ProjectName;
        
        public String comment1;
        public String comment2;
        public String comment3;
        public String comment4;
        public String comment5;
        public String comment6;
        public String comment7;
        
        public Boolean isBillable;
        public String TaskType;
        public Id timeCardLineId;
        public String payRollItem;
        
        public String status1;
        public String status2;
        public String status3;
        public String status4;
        public String status5;
        public String status6;
        public String status7;
        
        public List<Accounting_Seed_Time_Snapshot__c> timeSnapshotList;
        
        public Id locationId;
        public String locationName;
        public Boolean display_LineRec_Future;
        public Id timeCardId;
        public Id costRateId;
        public Id contactAssignId;
        public Decimal sequenceNumber;
        public String CRRateType;
        
        //For parter school time entry from VF admin time entry instructor part
        public Boolean lateCancellation1;
        public Boolean lateCancellation2;
        public Boolean lateCancellation3;
        public Boolean lateCancellation4;
        public Boolean lateCancellation5;
        public Boolean lateCancellation6;
        public Boolean lateCancellation7;
        
        public String cancellationReason1;
        public String cancellationReason2;
        public String cancellationReason3;
        public String cancellationReason4;
        public String cancellationReason5;
        public String cancellationReason6;
        public String cancellationReason7;
        
    }
    
    /**********************************************************************
        Created by Sukanya on Jan 12 2017: Domain class used for DLS_Staff_Time_Entry_Ctrl - Summary details inner class formation
    ***********************************************************************/
    global class TimeDaySummary {
        public Date dateValue;
        public Decimal Hours;
        public Decimal Payrate;
        public Decimal TotalAmount;
        public String Status;
        public String ProjectName;
        public String TaskName;
        public Id ProjectId;
        public Id TaskId;
        public Id DayId;
        public String PayrollItem;
        public String LocationName;
        public String Billable; 
        public String ChargeCode;
        public String contactId;
        public String contactName;
        
        // Mobile Approval Summary
        public String entryDate;
        public String dayType;
        
    }
    
    /**********************************************************************
        Created by Sukanya on Jan 13 2017: Domain class used for DLS_Staff_Time_Entry_Ctrl - Summary table - bonus,vocation,sick leave 
        details inner class formation
        Modified by Sukanya on Jan 27 2017: For Summary view grouping table Json formation
    ***********************************************************************/
    global class userSummaryDetails {
        public String userName;
        public Decimal bonusLeavebalance;
        public Decimal bonusLeaveearned;
        public Decimal bonusLeavetaken;
        public Decimal vocationLeavebalance;
        public Decimal vocationLeaveearned;
        public Decimal vocationLeavetaken;
        public Decimal sickLeavebalance;
        public Decimal sickLeaveearned;
        public Decimal sickLeavetaken;
        public Map<String,List<TimeDaySummary>> timeSummaryData;
        public List<TimeDaySummary> showDetailsummaryData;
        public Date timeLogLockDate;
    }
    
    /**********************************************************************
        Created by Sukanya on Jan 18 2017: Domain class used for TimeSheet_Internlas_Component - Approval Page changes
        details inner class formation
    ***********************************************************************/
    
    global class WrapperClass {
         
         public List<Attendance__c> attendanceDetails;
         public List<TimeCardDayDetails> dayDetails;
         public List<TimeCardDayForApproval> summaryViewJsonData;
         public Map<Id,AcctSeed__Time_Card_Day__c> dayIddayRecordMap;
         public Set<String> weekRangeValues;
         public Map<String,Decimal> WeekRangeUserId_HrsCountMap;
         public List<Accounting_Seed_Time_Snapshot__c> timeSnapshotDetails;
         public String UserTimezoneValue;
        
        //Added By Dhinesh - 21/03/2023 - W-007729 - Timekeeping Fields to Indicate if the Time was entered On Time or Late
        public Map<Id, TimeEntryUtil.TimeEnteredCountWrap> conIdWithTimeEnteredCountMap;
    } 
    
    /**********************************************************************
        Created by Sukanya on Jan 18 2017: Domain class used for TimeSheet_Internlas_Component - Approval Page - TimeCardDayDetails inner class changes
        details inner class formation
    ***********************************************************************/
    
    global class TimeCardDayDetails {
        
        public String Instructor;
        public Id InstructorId;
        public String ProjectTaskName;
        public String DLS_Class;
        public Id ProjectTaskId;
        public Date timeDayDate;
        public String HrsBeforedApproved;
        public String StartTime;
        public String EndTime;
        public String lateCancellation;
        public String internalComment;
        public Boolean isDisabled;
        public Id timeDayId;
        public Id EventId;
        public String hrsCompareColor;
        public Id ProjectRTId;
        public String ProjectRTName;
        public Boolean Billable;
        public String ProjectName;
        public Id ProjectId;
        public String ContactRecTypeName;
        public String UserType;
        public Decimal HrsScheduled;
    }
    
    /**********************************************************************
        Created by Sukanya on Jan 18 2017: Domain class used for TimeSheet_Internlas_Component - Approval Page - TimeCardDayForApproval inner class changes
        details inner class formation
    ***********************************************************************/
    
    global class TimeCardDayForApproval {
        
        public Id ProjectId;
        public Id ProjectTaskId;
        public Id InstructorId;
        public String ProjectName;
        public String ProjectTaskName;
        public String Instructor;
        public String TaskType;
        public String ProjectRTName;
        public String ContactRecTypeName;
        public Id ProjectRTId;
        
        public String Hours1;
        public String Hours2;
        public String Hours3;
        public String Hours4;
        public String Hours5;
        public String Hours6;
        public String Hours7;
        
        public Date Day1;
        public Date Day2;
        public Date Day3;
        public Date Day4;
        public Date Day5;
        public Date Day6;
        public Date Day7;
        
        public Decimal TotalHours;
        
        public Id Hrs1Day1Id;
        public Id Hrs2Day2Id;
        public Id Hrs3Day3Id;
        public Id Hrs4Day4Id;
        public Id Hrs5Day5Id;
        public Id Hrs6Day6Id;
        public Id Hrs7Day7Id;
        
        public String UserType;
        public Boolean isBillable;
        
        public String comment1;
        public String comment2;
        public String comment3;
        public String comment4;
        public String comment5;
        public String comment6;
        public String comment7;
        
        public String status1;
        public String status2;
        public String status3;
        public String status4;
        public String status5;
        public String status6;
        public String status7;
        
        public String payRollItem;
        public Id locationId;
        public String locationName;
        public Decimal sequenceNumber;
        
    }
    
    /**********************************************************************
        Created by Sukanya on March 16 2017: Domain class used for Admin Time Entry Page
        Wrapper class structure
    ***********************************************************************/
    global class AdminTimeEntryDetails {
    
        public Set<String> weekRangeValues;
        public List<TimeCardDay> timeCardDayRecords;
        public List<Accounting_Seed_Time_Snapshot__c> timeSnapshotDetails;
        public String UserTimezoneValue;
        public String UserName;
        public Map<Id,String> contactIdNameMap;
        public Date timelockLockingDate;
        public List<AcctSeed__Project_Task__c> projectTasks;
        public List<AcctSeed__Project__c> projects;
        public List<String> payRollItemList;
        public Boolean userHaspermission;
        public List<Contact_Assignments__c> contactAssignements;
        public Map<String,List<String>> taskName_PayrollItemMap;
        public String HomeDeptProId;
        public List<String> contactStatusValues;
        public List<Contact> contactRecords;
        public List<String> studentStatusValues; //Added by Mohana on November 15
        public List<String> attendancePickListValues;      
        public Boolean readOnlyMode;      
    }
    
    /**********************************************************************
        Created by Sukanya on August 16 2017: Domain class used for Supervisor approval page  - semi monthly view data
        Wrapper class structure
    ***********************************************************************/
    global class Approval_SemiMonthlyWrapper {
        
        public Map<Id,String> contactIdNameMap;
        public Map<String,List<TimeDaySummary>> dateSummaryDetailMap;
        public List<TimeDaySummary> summaryList;
        
        // For Mobile Approval Page summary usage
        // Added by NS on June 27 2018
        public List<String> weekRanges;
        public String currentWeek;
        public List<Contact> contactFilters;
    }
    
    /**********************************************************************
        Created by Sukanya on Feb 16 2018: Domain class used for Daily Time Entry
        Wrapper class structure
    ***********************************************************************/
    public class dailyInitialInfo {
        public List<String> weekRange;
        //public List<AcctSeed__Project__c> projectList;
        //public List<AcctSeed__Project_Task__c> taskList;
        public List<Project_Task_Master__c> taskMasterList;
        public Date lockingDate;
        public List<Date> holidays;
        //public List<Contact_Assignments__c> relatedContactAssign;
        public Date currWeekStart;
        public Date currWeekEnd;
        public Id contactId;
        //public List<MTT_Location__c> locationList;
        public Contact conRec;
        public Date currDate;
        public List<ContentDocument> documentList;
        
        // For Mobile Approval Page
        public Id userId;
    }
    
    public class DateBasedEntries {
        public String dateVal;
        public String dateToDisplay;
        public Decimal totalHrs;
        public String dayType;
        public List<DayEntries> entries;
        public Set<Id> dayRecIds;
        
        // For mobile approval page usage
        // Added by NS on June 8 2018
        public Decimal pendingHrs;
        public Decimal approvedHrs;
        public Decimal rejectedHrs;
        public Id instructorId;
        public String instructorName;
    }
    
    public class WeekViewDetails {
        public Date startDate;
        public Date endDate;
        public List<DateBasedEntries> entryDetails;
        public List<NotesDetails> notes;
        public List<String> weekDates;
        public Boolean displaySubmitBtn;
        public Boolean displayRecallBtn;
        public List<DayEntries> previousWeekEntries;
        public List<AcctSeed__Project__c> projectList;
        public List<AcctSeed__Project_Task__c> taskList;
        public List<Contact_Assignments__c> relatedContactAssign;
        
        // For Mobile Approval page usage
        // Added by NS on June 8 2018
        public List<ProjectBasedEntries> projectEntryDetails;
        public Map<Id,List<AcctSeed__Project__c>> insIdProjectList;
        public List<Contact> contactList;
        public Map<Id,List<ProjectBasedEntries>> insIdProEntries;
        public Map<Id,List<DateBasedEntries>> insIdDateEntries;
        public Map<Id,List<NotesDetails>> insIdNotesDetails;
    }
    
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
        public Boolean isAdminProTask;
        public Boolean isHoliday;
        public Boolean isHomeDepartment;
        public Boolean isAvailable_FutureWeek;
        public Boolean isNew;
        public Boolean isUpdated;
        public String projectRTName;
        public String ProjectName;
        public String TaskName;
        public String TaskType;
        public List<String> PayRollItemList;
        public String locationName;
        public Boolean isHrsDisabled;
        public String CRRateType;
        
        // For Mobile Approval Page usage
        public Id InstructorId;
        public String InstructorName;
        
        //For Instructor Time Entry usage
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
        public String recallReason;
    }
    
    public class NotesDetails {
        
        public String UserName;
        public DateTime Edited;
        public String ChargeCode;
        public String TaskName;
        public String Daydate;
        public String OldHours;
        public String NewHours;
        public String OldStatus;
        public String NewStatus;
        public String Comment;
        public DateTime createdDate;
        public String ReferenceId;
        // For Mobile Approval Page
        public Id InstructorId;
        
        //For Instructor Time Entry
        public String editedDT;
        public String dayId;
        public String projectName;
        public String oldStartTime1;
        public String newStartTime1;
        public String oldEndTime1;
        public String newEndTime1;
        public String oldStartTime2;
        public String newEndTime2;
        public Boolean lateCancellation;
        public String cancellationReason;
    }
    
    public class ButtonDisplay {
        public Boolean submitBtn;
        public Boolean recallBtn;
    }
    
    /**************************
     - Created by NS on June 8 2018
     - For Mobile approval page usage
     - To display summary information based on project
    *************************************/
    public class ProjectBasedEntries {
        public String projectName;
        public Id projectId;
        public Decimal pendingHrs;
        public Decimal approvedHrs;
        public Decimal rejectedHrs;
        public List<DayEntries> entries;
        public Id instructorId;
        public String instructorName;
    }
    
    /************************
        - Created by HL on Jul 30 2019
        - For Audit Trail Report Page
        - To display time card day history records
        - W-002110 : Timekeeping Audit Trail Reports
    ******************/
    public class TCDHistoryReport{
        @AuraEnabled
        public String dateAndTime;
        @AuraEnabled
        public DateTime createdDate;
        @AuraEnabled
        public String byUser;
        @AuraEnabled
        public String fieldEdited;
        @AuraEnabled
        public String oldValue;
        @AuraEnabled
        public String newValue;
        @AuraEnabled
        public String contactName;
        @AuraEnabled
        public String project;
        @AuraEnabled
        public String projectTask;
        @AuraEnabled
        public String tclName;
    }
    
    /***********************************************************************************
    - Created by NS on OCT 18 2019
    - For Admin Time Entry instructor view component
    ************************************************************************************/
    
    public class InstructorTimeEntryDetails {
    
        @AuraEnabled public TimeCardDayCommunityDomain.InstructorRowDetails rowDetails;
        @AuraEnabled public List<AcctSeed__Project_Task__c> taskRecords;
        @AuraEnabled public Map<Id,Id> taskIdCAIdMap;
        @AuraEnabled public Map<Id,AcctSeed__Cost_Rates__c> taskIdCostRateMap;
        @AuraEnabled public List<String> timeList;
        @AuraEnabled public List<String> uniqueKeySet;
        @AuraEnabled public Boolean isWeekIs3weeksOlder;
        @AuraEnabled public Decimal totalHours;
        @AuraEnabled public String timeCardId;
    }
    
}