/************************************************************
- Developed by Siva Prasanth on MAR 5 2019
- For Student Approval Lightning Component Usage
************************************************************/
public without sharing class StudentApproval_Controller {

    
    //static map to hold the TCD & types of changes related info to form the Notes
    //Work Item No : W-001481
    //Added by NS on Apr 17 2019
    public static Map<Id,String> tcdIdNoteType = new Map<Id,String>();
    

    /***************************************************************
     - Method to get the Week filter information
    ****************************************************************/
    @AuraEnabled
    public static String getInitialFilterValues(){
        
        return InstructorTimeEntry_Controller.getInitialFilterValues();  
        
    }
    /**************************************************************************
    - Method to get Week & Student based project filter data
   **************************************************************************/
    @AuraEnabled
    public static String  getProjectFilterValues(String startDate,String endDate,String studentId){
        
        try {
            Date stDate = Date.valueOf(startDate);
            Date edDate = Date.valueOf(endDate);
            
            Set<Id> projectId = new Set<Id>();
            Set<Id> tcdRelprojectId = new Set<Id>();
            Set<Id> instructorId = new Set<Id>();
            Set<Id> tcdInstructorId = new Set<Id>();
            Set<String> tcdInstructorWithProId = new Set<String>();
            
            List<AcctSeed__Project__c> projectRelatedCAStuNames = new List<AcctSeed__Project__c>();
            List<AcctSeed__Project__c> projectForSupervisor = new List<AcctSeed__Project__c>();
            List<AcctSeed__Project__c> projectRelatedCAInsRecords = new List<AcctSeed__Project__c>();
            
            //ThiS date condition to filter the Projects based on the ContactAssignment End Date values
            String caFilterDate = String.valueOf(stDate.addDays(-14)).split(' ')[0];
            
            //W-007991 - if a Student is Transferring out of a particular class a week from today, and the LTS perform a Transfer action, the student should continue to have access to the class they are transferring out of; until the End Date of their Contact assignment has passed.
            String currentDate = String.valueOf(System.today());

            
            Date caEndDate = Date.valueOf(caFilterDate);
            
            if(studentId != null) {           
                String parentFields = 'Candidate_Name__r.Home_Dept__c,Candidate_Name__r.Home_Department_Project__c,Candidate_Name__r.Home_Department_Project__r.Name,Candidate_Name__r.Name,'+
                    'Candidate_Name__r.Supervisor_Name__c,Candidate_Name__r.Supervisor_Name__r.Name,Candidate_Name__r.Supervisor_Name__r.ManagerId,Candidate_Name__r.Supervisor_Name__r.Manager.Name,'+
                    'Project__r.Name,Rate_Card_Rate__r.Name,Project__r.RecordType.DeveloperName,Rate_Card_Rate__r.Payroll_Item__c,Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Rate_Card_Rate__r.Rate_Type__c,RecordType.DeveloperName'; 
                
                String condition = ' WHERE RecordType.DeveloperName IN (\'Student\') AND ((Status__c = \'Active\' OR (Status__c IN (\'Ended\',\'On Hold\') AND End_Date__c >= '+caFilterDate+') OR (Status__c = \'Transferred\' AND (End_Date__c >= '+currentDate+' OR End_Date__c <= '+currentDate+')))) AND Project__c != null AND Project__r.RecordType.DeveloperName IN (\'DLI_W_LT_Projects\',\'DODA_Projects\',\'Language_Training_Projects\',\'ESL_LT_Projects\') AND Candidate_Name__c = \''+studentId+'\' AND Project__r.No_Student_Approval__c = false';
                
                for(Contact_Assignments__c assign : ContactAssignmentService.getContactassignmentRec(condition,parentFields)) {
                    projectId.add(assign.Project__c); 
                }
                
                 //W-002990 -Internal User Time Entries for LT Projects - Student Approval
                 //
                for(Contact_Assignments__c conAssignIns : [SELECT Id,Candidate_Name__c 
                                                                FROM Contact_Assignments__c 
                                                                WHERE RecordType.DeveloperName = 'Instructor' AND (Status__c = 'Active' OR (Status__c IN ('Ended','On Hold') AND End_Date__c > :caEndDate)) AND  Project__c IN:projectId AND Paper_Timesheet__c = false]){
                    instructorId.add(conAssignIns.Candidate_Name__c);
                }
                   System.debug(':::instructorId:::'+instructorId);
                for(AcctSeed__Time_Card_Day__c tcdList : [SELECT Id,AcctSeed__Date__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,
                                                          AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,
                                                          Student_Approval_Status__c FROM AcctSeed__Time_Card_Day__c 
                                                          WHERE AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :edDate 
                                                          AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c IN :projectId 
                                                          AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c IN :instructorId 
                                                          AND Student_Approval_Status__c IN('Approved','Rejected','Submitted') 
                                                          AND Status__c != 'Unposted' AND  Hide_From_Student__c = false]){
                                                              
                    tcdRelprojectId.add(tcdList.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c);
                    tcdInstructorId.add(tcdList.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
                    tcdInstructorWithProId.add(tcdList.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c+'-'+tcdList.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
                }
            }
            system.debug('tcdRelprojectId'+tcdRelprojectId);
            system.debug('tcdInstructorId'+tcdInstructorId);
            system.debug('tcdInstructorWithProId'+tcdInstructorWithProId);
            
            if(tcdRelprojectId.size() > 0){
                
                
                projectRelatedCAStuNames = [SELECT Id,Name,DLS_Class__c,
                                            (SELECT Id,Candidate_Name__r.Name ,Candidate_Name__r.FirstName,Candidate_Name__r.LastName
                                             FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Student' AND (Status__c = 'Active' OR ((Status__c IN ('Ended','On Hold') AND End_Date__c > :caEndDate) OR (Status__c = 'Transferred' AND (End_Date__c >= :System.today() OR End_Date__c <= :System.today()))))) 
                                            FROM AcctSeed__Project__c WHERE Id IN :tcdRelprojectId];
                
                projectForSupervisor = [SELECT Id,Name,DLS_Class__c,
                                        (SELECT Id,Candidate_Name__r.Name 
                                         FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Staff' AND (Status__c = 'Active' OR (Status__c IN ('Ended','On Hold') AND End_Date__c > :caEndDate))) 
                                        FROM AcctSeed__Project__c WHERE Id IN :tcdRelprojectId];
                
                projectRelatedCAInsRecords = [SELECT Id,Name,DLS_Class__c,
                                              (SELECT Id,Candidate_Name__r.Name,Candidate_Name__c
                                               FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Instructor' AND (Status__c = 'Active' OR (Status__c IN ('Ended','On Hold') AND End_Date__c > :caEndDate)) AND Candidate_Name__c  IN :tcdInstructorId AND Paper_Timesheet__c = false) 
                                              FROM AcctSeed__Project__c WHERE Id IN :tcdRelprojectId];
                
                System.debug(':::projectRelatedCAInsRecords'+projectRelatedCAInsRecords);
            }
            TimeCardDayCommunityDomain.ProjectFilterInfo proInfo = TimeCardDayCommunityTranslator.projectRelatedFilterStuApproval(projectRelatedCAStuNames,projectForSupervisor,projectRelatedCAInsRecords,tcdInstructorWithProId);
            return JSON.Serialize(proInfo); 
        }catch(Exception e){
            system.debug(':exception::::'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    /************************************************************
   - Method to get the TCL Rows related information from TCD 
   - Added by Siva Prasanth on MAR 8 2019
   *************************************************************/
    @AuraEnabled
    public static String getTimeCardDayDetails(String proId,Date startDate,Date endDate,String instructorId,String studentNamesWithDlsClassNo){
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        List<Accounting_Seed_Time_Snapshot__c> accTimesnapshot = new List<Accounting_Seed_Time_Snapshot__c>();

        Set<Id> projectIds = new Set<Id>{proId};
        Set<Id> taskId = new Set<Id>();

        String filterCondition = ' AND Status__c != \'Unposted\' AND Hide_From_Student__c = false AND Student_Approval_Status__c IN (\'Approved\',\'Rejected\',\'Submitted\') ORDER BY AcctSeed__Date__c ASC';
        
        List<AcctSeed__Project_Task__c>  proTask = [SELECT Id ,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :proId];
        for(AcctSeed__Project_Task__c proTsk : proTask){
            taskId.add(proTsk.Id);
        }
        if(projectIds.size() > 0) {
            timeCardLineList = TimeCardLineService.getTCL_dayRecords(filterCondition,projectIds,taskId,Date.valueOf(startDate),Date.valueOf(endDate),instructorId);      
        }
        system.debug('timeCardLineList'+timeCardLineList.size());
        // Time Snapshot formation
        Set<Id> tcdIds = new Set<Id>();
        
        for(AcctSeed__Time_Card_Line__c timeLine : timeCardLineList) {
            if(timeLine.AcctSeed__Time_Card_Days__r.size() > 0){
                for(AcctSeed__Time_Card_Day__c tcd : timeLine.AcctSeed__Time_Card_Days__r){
                    tcdIds.add(tcd.Id);
                }
            }
        }
        
        Map<Id, Boolean> tcdIdAndEvtNoStdApprovalFlag = timeCardRelated_Email_Controller.tcdIdAndNoStdApprovalFlag(tcdIds);
        
        for(Id tcdId : tcdIdAndEvtNoStdApprovalFlag.keySet()){
            if(tcdIdAndEvtNoStdApprovalFlag.get(tcdId)){
                tcdIds.remove(tcdId);
            }
        }
        
        if(tcdIds.size() > 0){
            accTimesnapshot = TimeSnapshotService.getSnpshotWithDaysIds(tcdIds);
        }
        Id usrId = UserInfo.getUserId();
        List<User> userLst = [Select ContactId from User where Id = :usrId];
        List<Contact_Assignments__c> cALst = [SELECT Id,Candidate_Name__c,Candidate_Name__r.Name,Project__c,Assignment_Position__c FROM Contact_Assignments__c WHERE Project__c = :proId AND RecordType.DeveloperName = 'Student'];
        
        //W-003066 - Create DLI-W Planned Days Off records automatically for all Active DLI-W LT Projects
        List<Planned_Days_Off__c> dliTHolidayPDOList = [SELECT Id,Type__c,Date__c FROM Planned_Days_Off__c WHERE Type__c = 'DLI-W LT' AND 
                                                       RecordType.DeveloperName = 'DLI_W_LT_Training_Holidays' AND Contact__c = null AND 
                                                       Project__c = null AND Opportunity__c = null AND (Date__c >= :startDate AND Date__c <= :endDate)];
      
        TimeCardDayCommunityDomain.InstructorRowDetails weekEntryDetails = TimeCardDayCommunityTranslator.StuApprovalInstructorDayRowEntries(proId,startDate,endDate,studentNamesWithDlsClassNo,accTimesnapshot,userLst,projectIds,timeCardLineList,cALst,dliTHolidayPDOList,tcdIdAndEvtNoStdApprovalFlag);
        
        List<AcctSeed__Project__c> projectRecord = [SELECT Id,Name,RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id IN :projectIds];
        String projectRTName = projectRecord[0].RecordType.DeveloperName;
        weekEntryDetails.projectName = projectRTName;
        weekEntryDetails.displayStudentHrstable = projectRecord[0].RecordType.DeveloperName == 'Language_Training_Projects';
        
        return JSON.serialize(weekEntryDetails);
    }
    @AuraEnabled
    public static String studentTimeEntriesRowFormation(String projectRTName,String projectId,Date startDt, Date endDt,String instructorId){
        
        List<Contact_Assignments__c> studentCAs = [SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Name,Status__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE Status__c IN ('Active','Ended','Transferred') AND RecordType.DeveloperName = 'Student' AND Project__c = :projectId];
        Set<Id> studentIds = new Set<Id>();
        Set<String> proRecType = new Set<String>{'DLI_W_LT_Projects','DODA_Projects','ESL_LT_Projects'};
        
        //W-006649 - Student Hours for Language Training Projects (Added LT Project condition to display student table by NS on June 3 2021)
        
        List<AcctSeed__Project__c> projectRecord = [SELECT Id,Name,RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :projectId];
        
        if(proRecType.contains(projectRTName) || (projectRecord.size() > 0 
            && projectRecord[0].RecordType.DeveloperName == 'Language_Training_Projects')){
            
            for(Contact_Assignments__c ca : studentCAs){
                studentIds.add(ca.Candidate_Name__c);
            }
        }
        
        Id usrId = UserInfo.getUserId();
        List<User> userLst = [Select ContactId from User where Id = :usrId];
        
        List<Attendance__c> stuAttendanceList = [SELECT Id,Name,Student__c,Instructor__c,Date__c,Duration__c,Student_Approval_Status__c,Event__c,Event__r.No_Student_Approval__c,
                                                 Time_Card_Day__c,Rejection_Reason__c,Time_Card_Day__r.Status__c,Recall_Reason__c,Comments__c,Student__r.Name,Time_Card_Day__r.Total_Hours_Before_Approved__c,Time_Card_Day__r.Late_Cancellation__c, Time_Card_Day__r.AcctSeed__Time_Card_Line__r.Completed__c,Attendance__c FROM Attendance__c 
                                                 WHERE Student__c IN :studentIds AND (Date__c >= :startDt AND Date__c <= :endDt) AND Instructor__c = :instructorId
                                                 AND Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = :projectId AND Time_Card_Day__r.Hide_From_Student__c = false
                                                 AND Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c != 'Preparation time'];
         
        //W-003066 - Create DLI-W Planned Days Off records automatically for all Active DLI-W LT Projects
        List<Planned_Days_Off__c> dliTHolidayPDOList = [SELECT Id,Type__c,Date__c FROM Planned_Days_Off__c WHERE Type__c = 'DLI-W LT' AND 
                                                        RecordType.DeveloperName = 'DLI_W_LT_Training_Holidays' AND Contact__c = null AND 
                                                        Project__c = null AND Opportunity__c = null AND (Date__c >= :startDt AND Date__c <= :endDt)];
       
        Set<Date> dliHoliPDODates = new Set<Date>();
        
        for(Planned_Days_Off__c pdo : dliTHolidayPDOList){
            dliHoliPDODates.add(pdo.Date__c);
        }
        
        List<Attendance__c> stuAtnList = new List<Attendance__c>();
        for( Attendance__c att : stuAttendanceList){
            if(!(projectRTName == 'DLI_W_LT_Projects' && dliHoliPDODates.contains(att.Date__c) && att.Time_Card_Day__r.Late_Cancellation__c == true)){
                stuAtnList.add(att);  
            }
        }
        return TimeCardDayCommunityTranslator.studentTimeRowEntriesFormation(startDt,endDt,studentCAs,stuAtnList,studentIds,userLst);
    }
    /*******************************************************************************************
   - Method to update the Time Card Day and Student Attendance record
   - Added by Siva Prasanth on Mar 11 2019
   - For Student Approval Component
  ********************************************************************************************/
    @AuraEnabled
    public static String updateDayAndAttendanceEntryRecord(String tCDRecords,String projectRTName, String stuAttendanceRecords){
        
        List<AcctSeed__Time_Card_Day__c> tCDRecordsList = (List<AcctSeed__Time_Card_Day__c>) System.JSON.deserialize(TCDRecords, List<AcctSeed__Time_Card_Day__c>.class);
        
        // Static map initialization to use in Time Card Day Trigger
        //Work Item No : W-001481
        //tcdIdNoteType = new Map<Id,String>();
       // pageType = 'Student Approval';
        
        try{
            if(TCDRecordsList.size() > 0){
                for(AcctSeed__Time_Card_Day__c tcd : tCDRecordsList){
                    if(tcd.Student_Approval_Status__c == 'Approved' || tcd.Student_Approval_Status__c == 'Rejected') {
                        tcd.Student_Approved_Date__c = System.now();
                    }
                    
                    if(tcd.Student_Approval_Status__c == 'Rejected' && !tcdIdNoteType.containsKey(tcd.Id)){
                        tcdIdNoteType.put(tcd.Id,'Student Rejection');
                    }
                }
                update tCDRecordsList;                
                
            }
            if(projectRTName == 'DLI_W_LT_Projects' || projectRTName == 'DODA_Projects' || projectRTName == 'Language_Training_Projects'){
                List<Attendance__c> stuAttendanceList = (List<Attendance__c>) System.JSON.deserialize(stuAttendanceRecords, List<Attendance__c>.class);
                
                if(stuAttendanceList.size() > 0){
                    update stuAttendanceList;
                }
            }
            return 'SUCCESS';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
   /************************************************************
   - Method to get the Schedule Records related Project
   - Added by Siva Prasanth on June 7 2019
   *************************************************************/
    @AuraEnabled
    public static String getProjectRelatedSchedules(String projectId,String startDate, String endDate){
    
        Date stDate = Date.valueOf(startDate);
        Date edDate = Date.valueOf(endDate);
        
        List<Schedule__c> scheduleRec = [SELECT Id, Name,Project__c, Status__c, Days__c,Start_Date__c,Instructor__r.Name,End_Date__c, Start_Time__c, End_Time__c, Project_Task__r.Name 
                                            FROM Schedule__c WHERE Project__c = :ProjectId AND (Status__c IN ('Drafted','Active') AND End_Date__c > :stDate)];
        return JSON.serialize(scheduleRec);
    }
    
}