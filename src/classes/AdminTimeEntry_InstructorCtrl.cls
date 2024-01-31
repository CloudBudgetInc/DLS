/***********************************************************************************
- Created by NS on Oct 14 2019
- For Admin Time Entry Instructor View related component usage
************************************************************************************/
public with sharing class AdminTimeEntry_InstructorCtrl {
    
    //Below static variables for mentions the group action type from timesheet page
    public static Boolean isGroupAction;
    public static String groupActionType;
    
    //static map to hold the TCD & types of changes related info to form the Notes
    public static Map<Id,String> tcdIdNoteType = new Map<Id,String>();
    public static String pageType;
    
    //Method to get initial filter values
    @AuraEnabled
    public static String getInitialFilterValues(){
        
        TimeCardDayDomain.AdminTimeEntryDetails filters = TimeKeeping_Admin_Controller.getWholeWeekRangeValues('Instructor');
        filters.attendancePickListValues = ScheduleCmpLightningController.getPickListValues('Attendance__c', 'Attendance__c');
        
       //#W-007763 - Admin Time Entry - DLS Online page access for LTS without access to edit/enter (MAY-1-2023)
        Id profileId = userinfo.getProfileId();
        Boolean readOnlyMode = false;
        
        if(String.isNotBlank(profileId)){ 
            String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
            if(profileName == 'LTS'){
                readOnlyMode = true;
            }
        }
        
        filters.readOnlyMode = readOnlyMode;
        system.debug(':::::::filters:::::'+filters);
        
        return JSON.serialize(filters);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,'RecordType.DeveloperName = \'Candidate\'',selectedIds);
    }  
    
    //Get Selected contact, week related project filter information
    @AuraEnabled 
    public static String getProjectFilterDetail(String startDate,String endDate,String contactId){
        
        system.debug(':::::::params::::'+startDate+' / '+endDate+' / '+contactId);
        
        
        List<TimeCardDayCommunityDomain.ProjectStudentInfo> projectFilter = new List<TimeCardDayCommunityDomain.ProjectStudentInfo>();
        
        Set<Id> projectIds = new Set<Id>();
        
        Date strtDate = Date.valueOf(startDate);
        Date weekStart = Date.valueOf(startDate).toStartofWeek().addDays(1);
        Date weekEnd = Date.valueOf(endDate);
        
        Date caFilterDate = weekStart.addDays(-14);
        
        String caEndDate = String.valueOf(caFilterDate).split(' ')[0]; 
        
        String startDT = strtDate.year()+'-'+('0' + strtDate.month()).right(2)+'-'+('0' + strtDate.day()).right(2)+'T00:00:00Z';
        String endDT = weekEnd.year()+'-'+('0' + weekEnd.month()).right(2)+'-'+('0' + weekEnd.day()).right(2)+'T00:00:00Z';
        
        String condition = ' WHERE Candidate_Name__c = \''+contactId+'\' AND RecordType.DeveloperName IN (\'Instructor\') AND Project__c != null AND ((Status__c IN (\'Active\') AND ((Start_Date__c <= '+startDate+' OR (Start_Date__c > '+startDate+' AND Start_Date__c <= '+endDate+') ) OR (Oral_Exam_Date_Time__c <= '+endDT+' AND Oral_Exam_Date_Time__c >= '+startDT+')) AND (End_Date__c >= '+endDate+'  OR (End_Date__c >= '+startDate+' AND End_Date__c <= '+endDate+'))) OR (Status__c IN (\'Ended\',\'On Hold\')  AND End_Date__c >= '+caEndDate+'))';
        
        for(Contact_Assignments__c assign : ContactAssignmentService.getContactassignmentRec(condition,'Project__r.RecordType.DeveloperName,Rate_Card_Rate__r.Payroll_Item__c,Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Rate_Card_Rate__r.Fringe_Payroll_Item__c,Rate_Card_Rate__r.Rate_Type__c,Candidate_Name__r.Home_Department_Project__c,RecordType.DeveloperName')) {
             
             projectIds.add(assign.Project__c);
        }
        
        system.debug(':::::::::::projectIds::::'+projectIds);
        
        //Qry project records with student information
        
        for(AcctSeed__Project__c pro : [SELECT Id,Name,DLS_Class__c,RecordType.DeveloperName,RecordTypeId,No_Student_Approval__c,Training_Location__c,Training_Location__r.Name,No_Student_Hours_Verification__c,
                                                                    (SELECT Id,Candidate_Name__r.FirstName,Candidate_Name__r.LastName,Assignment_Position__c 
                                                                        FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Student' AND ((Status__c IN ('Active') AND Start_Date__c <= :strtDate AND End_Date__c >= :weekEnd) OR (Status__c IN ('Ended','On Hold','Transferred')  AND End_Date__c > :caFilterDate))) 
                                                            FROM AcctSeed__Project__c WHERE Id IN :projectIds]){
            
            TimeCardDayCommunityDomain.ProjectStudentInfo proStuInfo = new TimeCardDayCommunityDomain.ProjectStudentInfo();
            proStuInfo.projectId = pro.Id;
            proStuInfo.projectName = pro.DLS_Class__c+' / '+pro.Name+' / ';
            proStuInfo.projectRTName = pro.RecordType.DeveloperName;
            proStuInfo.projectRTId = pro.RecordTypeId;
            proStuInfo.name = pro.Name;
            proStuInfo.dlsClassNo = pro.DLS_Class__c;
            proStuInfo.noStudentHrsVerification = pro.No_Student_Hours_Verification__c;
            
            if(pro.Training_Location__c != null){
                proStuInfo.locationId = pro.Training_Location__c;
                proStuInfo.locationName = pro.Training_Location__r.Name;
            }
            
            String studentNames = '';
            
            if(pro.RecordType.DeveloperName != 'CD_Projects'){
                if(pro.Contact_Assignments__r.size() > 0) {
                    for(Contact_Assignments__c ca : pro.Contact_Assignments__r){
                        if(String.isNotBlank(studentNames)){
                            studentNames += '; '+ca.Candidate_Name__r.FirstName+'.'+ca.Candidate_Name__r.LastName.subString(0,1);
                        }else {
                            studentNames = ca.Candidate_Name__r.FirstName+'.'+ca.Candidate_Name__r.LastName.subString(0,1);
                        }
                    }
                }
                proStuInfo.projectName += studentNames;
            }else {
                proStuInfo.projectName += pro.Name;
            }
            
            
            projectFilter.add(proStuInfo);
        }
        
        system.debug('::::::::projectFilter:::::'+projectFilter);
        
        return JSON.serialize(projectFilter);
        
    }
    
    //To check the selected contact have user or not
    @AuraEnabled
    public static Boolean getContactRelatedUser(String contactId) {
        
        Boolean alreadyUsrExist = false;
        
        List<Contact> conList = [SELECT Id,FirstName,LastName,Email FROM Contact WHERE Id = :contactId];
        
        system.debug(':::::::conList::::'+conList);
        
        String qry;
        
        if(conList[0].FirstName != null && conList[0].LastName != null) {
             qry = 'SELECT Id,Name FROM User WHERE FirstName LIKE \'%'+conList[0].FirstName+'%\' AND LastName LIKE \'%'+conList[0].LastName+'%\'';
        } else if(conList[0].LastName != null) {
             qry = 'SELECT Id,Name FROM User WHERE LastName LIKE \'%'+conList[0].LastName+'%\'';
        }
        for(User ur : database.query(qry)) {
            alreadyUsrExist = true;
        }
        system.debug('::::::::alreadyUsrExist:::::::'+alreadyUsrExist);
        return alreadyUsrExist;
    }
    
    /**************************************************************************************************************
    - Method to get the date range,project & contact related time card day details which is already exist
    ***************************************************************************************************************/
    @AuraEnabled
    public static String getSpecificWeekTCDDetials(String stDate, String endDate, String projectId,String contactId,String studentNames){
        
        Date startDt = Date.valueOf(stDate);
        Date endDt = Date.valueOf(endDate);
        
        system.debug(':::::::startDt:::;;'+startDt);
        system.debug(':::::::endDt:::;;'+endDt);
        
        Date caFilterDt = startDt.addDays(-14);
        DateTime caFilterDateTime = DateTime.newInstance(caFilterDt.year(), caFilterDt.month(), caFilterDt.day());
        
        Set<Id> filteredPTIds = new Set<Id>();
        
        List<AcctSeed__Project__c> projectRecord = [SELECT Id,Name,RecordType.DeveloperName,DLS_Class__c,No_Student_Approval__c FROM AcctSeed__Project__c WHERE Id = :projectId];
        String projectRTName = projectRecord[0].RecordType.DeveloperName;
        
        List<AcctSeed__Project_Task__c> taskRecords = new List<AcctSeed__Project_Task__c>();
        Map<Id,Integer> taskIdTimeCount = new Map<Id,Integer>();
        Map<Id,String> taskIdTimeMap = new Map<Id,String>();
      
        //Apply schedule based filter condition to get the PT  on the Instructor Time Entry Page
        for(Schedule__c sch : [SELECT Id,Name,Project_Task__c,Project_Task__r.Project_Task_Type__c,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c FROM Schedule__c 
                                    WHERE Status__c IN ('Active','Completed') AND (Start_Date__c <= :startDt OR End_Date__c >= :endDt) 
                                        AND Project__c = :projectId AND Instructor__c = :contactId]){
            filteredPTIds.add(sch.Project_Task__c);            
            
            if(sch.Project_Task__r.Project_Task_Type__c == 'Preparation time') {
                if(!taskIdTimeCount.containsKey(sch.Project_Task__c)){
                    taskIdTimeCount.put(sch.Project_Task__c,1);
                }else {
                    taskIdTimeCount.put(sch.Project_Task__c,taskIdTimeCount.get(sch.Project_Task__c) + 1);
                }
                
                if(!taskIdTimeMap.containsKey(sch.Project_Task__c)){
                    
                    if(sch.Start_Time__c != null && sch.End_Time__c != null) {
                    
                        if(sch.Start_Time__c.split(' ')[1] == 'PM' && sch.End_Time__c.split(' ')[1] == 'PM'){
                            taskIdTimeMap.put(sch.Project_Task__c,'PM');
                        }else {
                            taskIdTimeMap.put(sch.Project_Task__c,'AM');
                        }
                    }
                }else {
                    taskIdTimeMap.put(sch.Project_Task__c,'Both');
                }
            }
        }
        
        if(projectRTName == 'Testing_Projects'){
            for(Events__c eve : [SELECT Id,Name,Project_Task__c,Project_Task__r.Project_Task_Type__c,Date__c 
                                 FROM Events__c 
                                    WHERE Status__c IN ('Active','Completed') AND (Date__c >= :startDt AND Date__c <= :endDt) 
                                        AND Project__c = :projectId AND Instructor__c = :contactId]){
                filteredPTIds.add(eve.Project_Task__c);
            }
        }
        
        system.debug('::::::::::taskIdTimeCount::::'+taskIdTimeCount);
        system.debug(':::::::::taskIdTimeMap:::::'+taskIdTimeMap);
        system.debug('::::::filteredPTIds:::'+filteredPTIds);
        
        if(filteredPTIds.size() < 1){
            for(Schedule__c sch : [SELECT Id, Project_Task__c FROM Schedule__c]){
                filteredPTIds.add(sch.Project_Task__c);
            }                    
        }

        String taskQryStr = 'SELECT Id,Name,Billable__c,AcctSeed__Project__r.Training_Location__r.Name,AcctSeed__Project__r.Training_Location__c,Parent_Project_Task__c,'+
        'Project_Task_Type__c,AcctSeed__Project__r.DLS_Class__c,RecordType.DeveloperName,Payroll_Item__c,AcctSeed__Project__r.Default_Cost_Rate_Rate_Type__c'+
        ' FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projectId';
        taskQryStr += projectRTName == 'EFL_Projects' ? ' AND Project_Task_Type__c IN (\'Language Training\',\'Fringe\')' : ' AND Id IN :filteredPTIds';
        taskQryStr += ' ORDER BY Project_Task_Type__c ASC';
        
        //For display project task in order need to do some ordering
        Map<Integer,AcctSeed__Project_Task__c> sequenceNoPTRec = new Map<Integer,AcctSeed__Project_Task__c>();
        List<Integer> seqNums = new List<Integer>();
        
        Integer count = 0;
        
        for(AcctSeed__Project_Task__c task : Database.query(taskQryStr)){
            
            if(task.Project_Task_Type__c == 'Language Training'){
                sequenceNoPTRec.put(0,task);
            }else {
                sequenceNoPTRec.put((count + 1),task);
                count++;
            }
            
            filteredPTIds.add(task.Id);
        }
        
        for(Integer cnt : sequenceNoPTRec.keySet()){
            seqNums.add(cnt);
        }
        
        seqNums.sort();
        
        for(Integer seq : seqNums){
            
            if(sequenceNoPTRec.containsKey(seq)){
                taskRecords.add(sequenceNoPTRec.get(seq));        
            }
        }        
        
        
        //Qry currentWeek time card day records
        String filterCondition = ' ORDER BY AcctSeed__Date__c ASC';
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        List<Accounting_Seed_Time_Snapshot__c> accTimesnapshot = new List<Accounting_Seed_Time_Snapshot__c>();
        Set<Id> proIds = new Set<Id>{projectId};
        
        //Qry Existing TCL records with TCD
        if(contactId != null && proIds.size() > 0) {
            timeCardLineList = TimeCardLineService.getTCL_dayRecords(filterCondition,proIds,filteredPTIds,Date.valueOf(startDt),Date.valueOf(endDt),contactId);
        }
        
        system.debug(':::::::::timeCardLineList::::'+timeCardLineList.size());
        
        Set<Id> tcdIds = new Set<Id>();
        
        for(AcctSeed__Time_Card_Line__c timeLine : timeCardLineList) {
             if(timeLine.AcctSeed__Time_Card_Days__r.size() > 0){
                 for(AcctSeed__Time_Card_Day__c tcd : timeLine.AcctSeed__Time_Card_Days__r){
                     tcdIds.add(tcd.Id);
                 }
             }
        }
        
        // Time Snapshot formation
        if(tcdIds.size() > 0) {
            accTimesnapshot = TimeSnapshotService.getSnpshotWithDaysIds(tcdIds);
        }
        
        system.debug('::::::accTimesnapshot::::::'+accTimesnapshot);
        
        //Qry Instructor contact related CA for that project to get the CA & CR values
        List<Contact_Assignments__c> caRecord = [SELECT Id,Name,Rate_Card_Rate__c,Rate_Card_Rate__r.Payroll_Item__c,Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Project_Task__c,  Start_Date__c, End_Date__c, Oral_Exam_Date_Time__c
                                                        FROM Contact_Assignments__c 
                                                        WHERE Project__c = :projectId AND Candidate_Name__c = :contactId ORDER BY CreatedDate DESC];
        List<Contact_Assignments__History> caHistory = new List<Contact_Assignments__History>();
        List<AcctSeed__Cost_Rates__c> oldCRRecord = new List<AcctSeed__Cost_Rates__c>();
        
        if(caRecord.size() > 0) {
            caHistory = [SELECT CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue,ParentId 
                            FROM Contact_Assignments__History 
                            WHERE ParentId = :caRecord[0].Id AND Field = 'Rate_Card_Rate__c' AND DataType = 'EntityId' ORDER BY CreatedDate DESC LIMIT 1];
                      
            if(caHistory.size() > 0 && caHistory[0].OldValue != null){
                String oldId = (String) caHistory[0].OldValue;
                oldCRRecord = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c FROM AcctSeed__Cost_Rates__c WHERE Id = :oldId];
            }
        }
        
        //Qry project related student CAs for student attendance table formation
        List<Contact_Assignments__c> studentCAs = new List<Contact_Assignments__c>();
        Set<Id> studentIds = new Set<Id>();
        
         //W-005456 - added ESL LT Projects record type for ELT Pilot program
        
        if((projectRTName == 'DLI_W_LT_Projects' || projectRTName == 'DODA_Projects' || projectRTName == 'ESL_LT_Projects' || (projectRTName == 'Language_Training_Projects')) && filteredPTIds.size() > 0){
            studentCAs = [SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Name,Status__c FROM Contact_Assignments__c WHERE (Status__c = 'Active' OR (Status__c IN ( 'Ended','Transferred') AND  (End_Date__c >= :caFilterDt OR Oral_Exam_Date_Time__c >= :caFilterDateTime))) AND RecordType.DeveloperName = 'Student' AND Project__c = :projectId ORDER BY Candidate_Name__r.FirstName ASC];
            for(Contact_Assignments__c ca : studentCAs){
                studentIds.add(ca.Candidate_Name__c);
            }
        }
        
        //Qry Existing attendance records to prepopulate the values in student time table
        Map<Id,List<Attendance__c>> studentIdAttendanceList = new Map<Id,List<Attendance__c>>();
        
        if(studentIds.size() > 0 && filteredPTIds.size() > 0 && projectRecord.size() > 0 && !projectRecord[0].No_Student_Approval__c){
        
            for(Attendance__c att : [SELECT Id,Name,Student__c,Student__r.Name,Instructor__c,Date__c,Duration__c,Student_Approval_Status__c,
                                                Event__c,Time_Card_Day__c,Time_Card_Day__r.Status__c,Recall_Reason__c,Rejection_Reason__c,Comments__c,Time_Card_Day__r.Total_Hours_Before_Approved__c,Attendance__c  
                                        FROM Attendance__c 
                                        WHERE Student__c IN :studentIds AND (Date__c >= :startDt AND Date__c <= :endDt) AND Instructor__c = :contactId
                                                AND Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = :projectId ORDER BY Student__r.FirstName ASC]){
                
                if(!studentIdAttendanceList.containsKey(att.Student__c)){
                    studentIdAttendanceList.put(att.Student__c,new List<Attendance__c>{att});
                }else {
                    studentIdAttendanceList.get(att.Student__c).add(att);
                }
            }
        }
        
        
        //Query current contact related Planned Days off records
        List<Planned_Days_Off__c> daysOffRecords = [SELECT Id,Name,Date__c,Contact__c,Contact__r.Name,Description__c 
                                                            FROM Planned_Days_Off__c 
                                                            WHERE Status__c = 'Approved' AND RecordType.DeveloperName = 'Instructor_Planned_Days_Off' 
                                                            AND Date__c >= :startDt AND Date__c <= :endDt AND Contact__c = :contactId];
        
         //Qry DLI-W LT related planned days off
        Set<Date> holidayDates = new Set<Date>();
        
        if(projectRTName == 'DLI_W_LT_Projects'){
            for(Planned_Days_Off__c off : [SELECT Id,Date__c FROM Planned_Days_Off__c 
                                                WHERE RecordType.DeveloperName = 'DLI_W_LT_Training_Holidays' 
                                                                AND Date__c >= :startDt AND Date__c <= :endDt AND Type__c = 'DLI-W LT']){
                                                                
                holidayDates.add(off.Date__c);
            }
        }
        
        system.debug(':::::DLI-W:::LT:::::::holidayDates::::'+holidayDates);
        
        //Get Total Hours For selected week for that selected contact
        List<AcctSeed__Time_Card__c> cardRecord = [SELECT Id,Name,AcctSeed__Total_Hours__c FROM AcctSeed__Time_Card__c 
                                                        WHERE Intructor__c = :contactId AND AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c = :startDt AND 
                                                                AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c = :endDt];
        
        Decimal totalHrs = cardRecord.size() > 0 ? cardRecord[0].AcctSeed__Total_Hours__c : 0.00;
        
        TimeCardDayDomain.InstructorTimeEntryDetails dayDetails = TimeCardDayTranslator.admin_InstructorViewDayDetailsFormation(startDt,endDt,studentNames,contactId,timeCardLineList,accTimesnapshot,taskRecords,caRecord,taskIdTimeCount,taskIdTimeMap,caHistory,oldCRRecord,studentCAs,studentIdAttendanceList,daysOffRecords,holidayDates,totalHrs);
        
        return JSON.serialize(dayDetails);
    }
    
    /********************************************************************************************************
    - Method to for new row details with cost rate & details
    - Added by NS on OCT 20 2019
    **********************************************************************************************************/
    @AuraEnabled
    public static String newRowDetailFormation(String inputJson){
        
        Map<String,Object> inputMap = (Map<String,Object>) JSON.deserializeUntyped(inputJson);
        
        system.debug(':::::::inputMap::::'+inputMap);
        
        String projectId = (String) inputMap.get('project');
        
        String st = (String) inputMap.get('startDate');
        String ed = (String) inputMap.get('endDate');
        
        Date startDt = Date.newInstance(Integer.valueOf(st.split('-')[0]),Integer.valueOf(st.split('-')[1]),Integer.valueOf(st.split('-')[2]));
        Date endDt = Date.newInstance(Integer.valueOf(ed.split('-')[0]),Integer.valueOf(ed.split('-')[1]),Integer.valueOf(ed.split('-')[2]));
        
        String contactId = (String) inputMap.get('contactId');
        
        String taskId = (String) inputMap.get('task');
        
        
        List<AcctSeed__Project_Task__c> taskRecords = new List<AcctSeed__Project_Task__c>();
        Map<Id,Integer> taskIdTimeCount = new Map<Id,Integer>();
        Map<Id,String> taskIdTimeMap = new Map<Id,String>();
        Set<Id> filteredPTIds = new Set<Id>();
      
        //Apply schedule based filter condition to get the PT  on the Instructor Time Entry Page
        for(Schedule__c sch : [SELECT Id,Name,Project_Task__c,Project_Task__r.Project_Task_Type__c,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c FROM Schedule__c 
                                    WHERE Status__c IN ('Active','Completed') AND (Start_Date__c <= :startDt OR End_Date__c >= :endDt) 
                                        AND Project__c = :projectId AND Instructor__c = :contactId AND Project_Task__c = :taskId]){
            filteredPTIds.add(sch.Project_Task__c);
            
            system.debug(':::::start::date:'+sch.Start_Date__c);
            system.debug(':::::end::date:'+sch.End_Date__c);
            system.debug(':::::task::type:::'+sch.Project_Task__r.Project_Task_Type__c);
            
            if(sch.Project_Task__r.Project_Task_Type__c == 'Preparation time') {
                if(!taskIdTimeCount.containsKey(sch.Project_Task__c)){
                    taskIdTimeCount.put(sch.Project_Task__c,1);
                }else {
                    taskIdTimeCount.put(sch.Project_Task__c,taskIdTimeCount.get(sch.Project_Task__c) + 1);
                }
                
                if(!taskIdTimeMap.containsKey(sch.Project_Task__c)){
                    
                    if(sch.Start_Time__c != null && sch.End_Time__c != null) {
                    
                        if(sch.Start_Time__c.split(' ')[1] == 'PM' && sch.End_Time__c.split(' ')[1] == 'PM'){
                            taskIdTimeMap.put(sch.Project_Task__c,'PM');
                        }else {
                            taskIdTimeMap.put(sch.Project_Task__c,'AM');
                        }
                    }
                }else {
                    taskIdTimeMap.put(sch.Project_Task__c,'Both');
                }
            }
        }
        
        system.debug('::::::::::taskIdTimeCount::::'+taskIdTimeCount);
        system.debug(':::::::::taskIdTimeMap:::::'+taskIdTimeMap);
        system.debug('::::::filteredPTIds:::'+filteredPTIds);
        
        if(filteredPTIds.size() > 0){
            taskRecords = [SELECT Id,Name,Billable__c,AcctSeed__Project__r.Training_Location__r.Name,AcctSeed__Project__r.Training_Location__c,Parent_Project_Task__c,
                                    Project_Task_Type__c,AcctSeed__Project__r.DLS_Class__c,Payroll_Item__c
                                FROM AcctSeed__Project_Task__c 
                                WHERE AcctSeed__Project__c = :projectId AND Id IN :filteredPTIds ORDER BY Project_Task_Type__c ASC];
        }else {
            taskRecords = [SELECT Id,Name,Billable__c,AcctSeed__Project__r.Training_Location__r.Name,AcctSeed__Project__r.Training_Location__c,Parent_Project_Task__c,
                                    Project_Task_Type__c,AcctSeed__Project__r.DLS_Class__c,RecordType.DeveloperName,Payroll_Item__c
                                FROM AcctSeed__Project_Task__c 
                                WHERE AcctSeed__Project__c = :projectId AND Id = :taskId ORDER BY Project_Task_Type__c ASC];
        }
        
        //Qry Instructor contact related CA for that project to get the CA & CR values
        List<Contact_Assignments__c> caRecord = [SELECT Id,Name,Rate_Card_Rate__c,Rate_Card_Rate__r.Payroll_Item__c,Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Project_Task__c, Start_Date__c, End_Date__c, Oral_Exam_Date_Time__c
                                                        FROM Contact_Assignments__c 
                                                        WHERE Project__c = :projectId AND Candidate_Name__c = :contactId ORDER BY CreatedDate DESC];
        List<Contact_Assignments__History> caHistory = new List<Contact_Assignments__History>();
        List<AcctSeed__Cost_Rates__c> oldCRRecord = new List<AcctSeed__Cost_Rates__c>();
        
        if(caRecord.size() > 0) {
            caHistory = [SELECT CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue,ParentId 
                            FROM Contact_Assignments__History 
                            WHERE ParentId = :caRecord[0].Id AND Field = 'Rate_Card_Rate__c' AND DataType = 'EntityId' ORDER BY CreatedDate DESC LIMIT 1];
                      
            if(caHistory.size() > 0 && caHistory[0].OldValue != null){
                String oldId = (String) caHistory[0].OldValue;
                oldCRRecord = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c FROM AcctSeed__Cost_Rates__c WHERE Id = :oldId];
            }
        }
        
        //For one new row with all values
        TimeCardDayCommunityDomain.InstructorDayDetails newRow = TimeCardDayTranslator.formNewRowContents(startDt,endDt,taskRecords,caRecord,taskIdTimeCount,taskIdTimeMap,caHistory,oldCRRecord,inputMap);
        
        
        return JSON.serialize(newRow);    
    }
    
    /*********************************************************************************************
    - Method to get the Existing TCD records from other projects for the same week
    - Added by NS on Nov 4 2019
    **********************************************************************************************/
    @AuraEnabled
    public static String getExistingTCDsForOtherProjects(String instructorId,String startDate,String endDate,String projectId){
        
        return InstructorTimeEntry_Controller.getExistingTCDsForOtherProjects(instructorId,startDate,endDate,projectId);
    }
    
    /***************************************************************************************************
    - Method to perform TCD insert / update action
    - Added by NS on Nov 4 2019
    ***************************************************************************************************/
    @AuraEnabled
    public static String dmlOperationMethod(String startDate, String endDate, String instructorId,String projectId,String actionType,String timeDayJson,String studentJson,String comment,List<String> updatedTCDs){
    
        system.debug('::::::::::::instructorId:::::::'+instructorId);
        List<TimeCardDayCommunityDomain.DayEntries> dayRecords = (List<TimeCardDayCommunityDomain.DayEntries>) System.JSON.deserialize(timeDayJson, List<TimeCardDayCommunityDomain.DayEntries>.class);
        
        //Student Json deserialize
        List<TimeCardDayCommunityDomain.StudentEntry> studentRecords = (List<TimeCardDayCommunityDomain.StudentEntry>) System.JSON.deserialize(studentJson, List<TimeCardDayCommunityDomain.StudentEntry>.class);
        
        // Contact Id
        Id contactId = instructorId;
        
        //Get contact related user id
        List<User> useRec = [SELECT Id,Name FROM User WHERE ContactId = :contactId];
        
        Id usrRecId = useRec.size() > 0 ? useRec[0].Id : null;
        
        Date startDt = Date.valueOf(startDate);
        Date endDt = Date.valueOf(endDate);
        
        Set<String> updatedTCDIds = new Set<String>();
        updatedTCDIds.addAll(updatedTCDs);
        
         // Variable Initialization
        Set<Id> timeCardId = new Set<Id>();
        Map<Id,AcctSeed__Time_Card__c> instrutorIdandRecordMap = new Map<Id,AcctSeed__Time_Card__c>();
        Map<Id,Map<String,AcctSeed__Time_Card_Line__c>> instructIdTaskIdandLineRecMap = new Map<Id,Map<String,AcctSeed__Time_Card_Line__c>>();
        Map<Id,List<AcctSeed__Time_Card_Line__c>> instructorIdLineListMap = new Map<Id,List<AcctSeed__Time_Card_Line__c>>();
        Map<String,List<AcctSeed__Time_Card_Day__c>> instIdTaskIdStringDayLsitMap = new Map<String,List<AcctSeed__Time_Card_Day__c>>();
        Set<Id> timeCardLineId = new Set<Id>();
        Set<Id> insIdForRefer = new Set<Id>();
        Set<String> lineUniqueKeys = new Set<String>();
        
        
        Map<Id,Map<String,AcctSeed__Time_Card_Line__c>> insIdStringTimeLineMap = new Map<Id,Map<String,AcctSeed__Time_Card_Line__c>>();
        
        List<AcctSeed__Time_Card_Day__c> dayListToUpsert = new List<AcctSeed__Time_Card_Day__c>();
        List<AcctSeed__Time_Card_Line__c> timeLineCreation = new List<AcctSeed__Time_Card_Line__c>();
        List<AcctSeed__Time_Card__c> cardCreation = new List<AcctSeed__Time_Card__c>();
        
        List<AcctSeed__Time_Card_Day__c> daysForRevert = new List<AcctSeed__Time_Card_Day__c>();
        
        // Update time card Line Comments field based on UsrComment
        Map<Id, AcctSeed__Time_Card_Line__c> cardLineIdWithRecForCommentUpdate = new Map<Id, AcctSeed__Time_Card_Line__c>();                
        
        // Page name to use in Time Card Day Trigger for notes formation
        pageType = 'Admin Time Entry';
        
         // Account Period check & insertion
        TimesheetPage_RelatedCtrl.accountingPeriodCreation(startDt,endDt);
         
        // Time Card Period exist check & insertion
        Id timeCardPeriodId = TimesheetPage_RelatedCtrl.timeCardPeriodCreation(startDt,endDt);
        
         //Ledger record query for test class purpose
         List< AcctSeed__Ledger__c > ledger = [SELECT Id, Name, AcctSeed__Type__c FROM AcctSeed__Ledger__c LIMIT 1];
         
        //time card Period based existing time card records formation
        if(timeCardPeriodId != null) {
             for(AcctSeed__Time_Card__c card : TimecardService.getTimeCardByDate(' WHERE AcctSeed__Time_Card_Period__c = \''+timeCardPeriodId+'\'',new Set<Id>{},new Set<Id>{},'')) {
                 
                 timeCardId.add(card.Id);
                 if(!instrutorIdandRecordMap.containsKey(card.Intructor__c)) {
                     instrutorIdandRecordMap.put(card.Intructor__c,card);
                 }
             }
        }
         
        system.debug('::::::timeCardId::::::'+timeCardId);
        system.debug('::::::instrutorIdandRecordMap::::::'+instrutorIdandRecordMap);
        
        //Card based existing line records formation
        for(AcctSeed__Time_Card_Line__c line : [SELECT Id,AcctSeed__Project_Task__c,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c,
                                                 AcctSeed__Billable__c,Payroll_Item__c,Location__c,
                                                 AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c 
                                             FROM AcctSeed__Time_Card_Line__c 
                                             WHERE AcctSeed__Time_Card__c IN :timeCardId AND AcctSeed__Project__c = :projectId]){
            Id locId = null;
            
            system.debug(':::quried:::::existing::::lines::::'+line);
            
            if(line.Location__c != null) {
                locId = line.Location__c;
            } else if(line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c != null) {
                locId = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c;
            }
            
            if(!instructIdTaskIdandLineRecMap.containsKey(line.AcctSeed__Time_Card__r.Intructor__c)) {
                instructIdTaskIdandLineRecMap.put(line.AcctSeed__Time_Card__r.Intructor__c,new Map<String,AcctSeed__Time_Card_Line__c>{line.AcctSeed__Project_Task__c+'-'+line.AcctSeed__Billable__c+'-'+line.Payroll_Item__c+'-'+locId=>line});
            } 
            instructIdTaskIdandLineRecMap.get(line.AcctSeed__Time_Card__r.Intructor__c).put(line.AcctSeed__Project_Task__c+'-'+line.AcctSeed__Billable__c+'-'+line.Payroll_Item__c+'-'+locId,line);  
        }
        
        system.debug(':::::::::instructIdTaskIdandLineRecMap::::::::'+instructIdTaskIdandLineRecMap);
        
        // Formation of time card day records from UI list
        for(TimeCardDayCommunityDomain.DayEntries day : dayRecords){
            
            if(day.isUpdated && day.dayId != null && day.dayHours != null){// Check existing TCD records
            
                AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
                newDay = dayInstanceFormation(day,null,null);
                
                dayListToUpsert.add(newDay);
                                
            }else if(actionType == 'Revert' && !day.isUpdated && !day.isNew && day.dayId != null) {   
                //Add the records which are not updated in UI,but already exisit in database for revert action
                
                AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
                newDay.Id = day.dayId;
                newDay.AcctSeed__Date__c = day.dateVal;
                newDay.Total_Hours_Before_Approved__c = Decimal.valueOf(day.dayHours);
                newDay.AcctSeed__Internal_Comment__c = day.comments;
                newDay.Status__c = day.status;
                
                daysForRevert.add(newDay);                                
            }
            
            // If already TCD not exist - check already card,line exist if not create from parent to child
            //Check Card record already exist
            if(instrutorIdandRecordMap.containsKey(contactId) 
                && instrutorIdandRecordMap.get(contactId) != null 
                && instrutorIdandRecordMap.get(contactId).AcctSeed__Time_Card_Period__c == timeCardPeriodId){
                
                system.debug(':::::::::::enter card exist if::::::');
                
                AcctSeed__Time_Card__c cardRec = instrutorIdandRecordMap.get(contactId);
                
                // Check already card based line record exist
                if(instructIdTaskIdandLineRecMap.containsKey(cardRec.Intructor__c) 
                && instructIdTaskIdandLineRecMap.get(cardRec.Intructor__c).containsKey(day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId)
                ) {
                
                    system.debug(':::::::::::enter line exist if::::::');
                    
                    AcctSeed__Time_Card_Line__c lineRec = instructIdTaskIdandLineRecMap.get(cardRec.Intructor__c).get(day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId);
                    
                    String key = contactId+'-'+day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId;
                    
                    if(!lineUniqueKeys.contains(key)){
                        lineUniqueKeys.add(key);
                    }
                    lineRec.Comments__c = comment;
                    cardLineIdWithRecForCommentUpdate.put(lineRec.Id, lineRec);
                    
                    if(day.isNew && day.dayHours != null){
                
                        AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
                        newDay = dayInstanceFormation(day,lineRec.Id,day.costrateId);
                        
                        dayListToUpsert.add(newDay);
                    }
                }else { // Line record not exist, going to create new one
                
                    system.debug(':::::::::::card exist::but no line::part::');
                    
                    AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                    line = lineInstanceFormation(day,cardRec.Id, comment);
                    
                    String key = contactId+'-'+day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId;
                    
                    if(!lineUniqueKeys.contains(key)) {
                        timeLineCreation.add(line);
                        lineUniqueKeys.add(key);
                    }
                    
                    // Time Card Day map formation - after line creation we can map the line id in day records
                    if(!instIdTaskIdStringDayLsitMap.containsKey(key)) {
                        instIdTaskIdStringDayLsitMap.put(key,new List<AcctSeed__Time_Card_Day__c>());
                    }
                    
                    if(day.isNew && day.dayHours != null){
                    
                        AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
                        newDay = dayInstanceFormation(day,null,day.costrateId);
                        
                        instIdTaskIdStringDayLsitMap.get(key).add(newDay);
                    }
                }// End of line creation if
                
            }else {// Already card record not exist, we are going to create card record, then line and day records
            
                system.debug(':::::::::::no existing card:::::exist:part:::');
                
                //Card records creation
                if(!insIdForRefer.contains(contactId) && contactId != null) {
                
                    AcctSeed__Time_Card__c card = new AcctSeed__Time_Card__c();
                    card.AcctSeed__Employee__c = usrRecId;
                    card.Intructor__c = contactId;
                    card.AcctSeed__Time_Card_Period__c = timeCardPeriodId;
                    card.Comments__c = comment;
                    
                    if(Test.isRunningTest()){
                        card.AcctSeed__Ledger__c = ledger[0].Id;
                    }
                    
                    cardCreation.add(card);
                    insIdForRefer.add(contactId);
                }
                
                // Line record related Map formation
                AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                line = lineInstanceFormation(day,null, comment);
                
                String key = contactId+'-'+day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId;
                
                system.debug(':::::::line:::insert:::::key::'+key);
                system.debug('::::new:::line:::instance::'+line);
                
                if(!lineUniqueKeys.contains(key)) {
                    lineUniqueKeys.add(key);
                
                    if(!instructorIdLineListMap.containsKey(contactId)) {
                        instructorIdLineListMap.put(contactId,new List<AcctSeed__Time_Card_Line__c>());
                    }
                    instructorIdLineListMap.get(contactId).add(line);
                }
                
                // Time card Day Map formation
                if(!instIdTaskIdStringDayLsitMap.containsKey(key)) {
                    instIdTaskIdStringDayLsitMap.put(key,new List<AcctSeed__Time_Card_Day__c>());
                }
                
                if(day.isNew && day.dayHours != null){
                
                    AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
                    newDay = dayInstanceFormation(day,null,day.costrateId);
                    
                    instIdTaskIdStringDayLsitMap.get(key).add(newDay);
                }
            }// End of card creation if
            
        }//End of for loop
        
        system.debug(':::::::::::dayListToUpsert::admin::ins::time::::'+dayListToUpsert);
        system.debug('::::::cardCreation:admin::ins::time:::'+cardCreation);
        system.debug('::::::timeLineCreation::admin::ins::time::'+timeLineCreation);
        system.debug(':::instructorIdLineListMap:::admin::::ins:time::'+instructorIdLineListMap);
        system.debug('::::::instIdTaskIdStringDayLsitMap:::admin:::ins::time::'+instIdTaskIdStringDayLsitMap);
        
        try {
        
            if(cardCreation.size() > 0) { //Card creation
                insert cardCreation;
                
                for(AcctSeed__Time_Card__c timeCard : cardCreation) {
                
                    if(instructorIdLineListMap.containsKey(timeCard.Intructor__c)) {
                    
                        for(AcctSeed__Time_Card_Line__c timeLine : instructorIdLineListMap.get(timeCard.Intructor__c)) {
                            timeLine.AcctSeed__Time_Card__c = timeCard.Id;
                            
                            if(timeLine.AcctSeed__Project__c != null && timeLine.AcctSeed__Project_Task__c != null 
                                && timeLine.Contact_Assignment__c != null){    //Do not allow line creation if the project, project task, contact assignment are null
                                
                                timeLineCreation.add(timeLine);
                            }
                        }
                    }
                }
            }
            
            if(timeLineCreation.size() > 0) { // Line creation
                insert timeLineCreation;
                
                for(AcctSeed__Time_Card_Line__c cardLine :timeLineCreation) {
                    timeCardLineId.add(cardLine.Id);
                }
                
                system.debug(':::::timeCardLineId::::'+timeCardLineId);
                
                for(AcctSeed__Time_Card_Line__c lineRec : [SELECT Id,Name,AcctSeed__Project_Task__c,AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Billable__c,Payroll_Item__c,Location__c FROM AcctSeed__Time_Card_Line__c WHERE Id IN :timeCardLineId]) {
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
                                        dayListToUpsert.add(timeCardDay);
                                    }
                                }
                            }
                        }
                    }
                }
                
                system.debug('::::::::dayListToUpsert:::::'+dayListToUpsert);
                
                // Time card day upsertion
                if(dayListToUpsert.size() > 0){
                
                    //To find which TCDs are newly inserted & which are came for update
                    for(AcctSeed__Time_Card_Day__c tcd : dayListToUpsert) {
                        if(updatedTCDIds.contains(tcd.Id) && actionType != 'Submit'){
                            if(!tcdIdNoteType.containsKey(tcd.Id)) {
                                tcdIdNoteType.put(tcd.Id,'TCD Edit');
                            }
                        }
                    }
                
                    upsert dayListToUpsert;
                }
            }else {
                system.debug('::::::::dayListToUpsert:::::'+dayListToUpsert);
                
                // Time card day upsertion
                if(dayListToUpsert.size() > 0){
                   
                    //To find which TCDs are newly inserted & which are came for update
                    for(AcctSeed__Time_Card_Day__c tcd : dayListToUpsert) {
                        if(updatedTCDIds.contains(tcd.Id) && actionType != 'Submit'){
                            if(!tcdIdNoteType.containsKey(tcd.Id)) {
                                tcdIdNoteType.put(tcd.Id,'TCD Edit');
                            }
                        }
                    }
                
                    upsert dayListToUpsert;
                }
            }                        
            
            if(cardLineIdWithRecForCommentUpdate.size() > 0){
                update cardLineIdWithRecForCommentUpdate.values();
            }
            
            //Create / Update Student Attendance Records after TCD create / update action
            if(studentRecords.size() > 0){
                List<Attendance__c> attendanceList = new List<Attendance__c>();
                Map<Date,Id> dateDayIdMap = new Map<Date,Id>();
                Set<Id> dayIds = new Set<Id>();
                Map<Date,Id> dateEventIdMap = new Map<Date,Id>();
                Map<Id,AcctSeed__Time_Card_Day__c> dayIdDayRecMap = new Map<Id,AcctSeed__Time_Card_Day__c>();
                
                
                //Get Exisitng TCD which are not related to Preparation time PT
                if(dayListToUpsert.size() > 0) {
                    for(AcctSeed__Time_Card_Day__c day : dayListToUpsert){
                        dayIds.add(day.Id);
                    }
                    
                    for(AcctSeed__Time_Card_Day__c day : [SELECT Id,AcctSeed__Date__c,Total_Hours_Before_Approved__c,Project_Task_Type__c,Instructor_Position__c,Instructor_Name__c 
                                                            FROM AcctSeed__Time_Card_Day__c 
                                                            WHERE Id IN :dayIds AND Project_Task_Type__c != 'Preparation time']){
                                                            
                        if(!dateDayIdMap.containsKey(day.AcctSeed__Date__c)){
                            dateDayIdMap.put(day.AcctSeed__Date__c,day.Id);
                        }
                        
                        if(!dayIdDayRecMap.containsKey(day.Id)){
                            dayIdDayRecMap.put(day.Id,day);
                        }
                    }
                
                }else {
                    for(AcctSeed__Time_Card_Day__c day : [SELECT Id,AcctSeed__Date__c,Total_Hours_Before_Approved__c,Project_Task_Type__c,Instructor_Position__c,Instructor_Name__c 
                                                            FROM AcctSeed__Time_Card_Day__c 
                                                            WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = :projectId 
                                                                        AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :contactId AND Project_Task_Type__c != 'Preparation time' AND 
                                                                        (AcctSeed__Date__c >= :startDt AND AcctSeed__Date__c <= :endDt)]){
                        if(!dateDayIdMap.containsKey(day.AcctSeed__Date__c)){
                            dateDayIdMap.put(day.AcctSeed__Date__c,day.Id);
                        }
                        
                        if(!dayIdDayRecMap.containsKey(day.Id)){
                            dayIdDayRecMap.put(day.Id,day);
                        }
                    }
                }
                
                //Get Events for this date range
                for(Events__c eve : [SELECT Id,Name,Date__c FROM Events__c 
                                        WHERE Project__c = :projectId AND Instructor__c = :contactId AND (Date__c >= :startDt AND Date__c <= :endDt) 
                                        AND Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time']){
                                        
                    if(!dateEventIdMap.containsKey(eve.Date__c)){
                        dateEventIdMap.put(eve.Date__c,eve.Id);
                    }
                    
                }
                
                system.debug(':::::::dateDayIdMap::::::'+dateDayIdMap);
                system.debug(':::::::dateEventIdMap::::::'+dateEventIdMap);
                
                //Notes formation based on TCD Hrs & Student Hrs Missmatch
                Map<Id,Accounting_Seed_Time_Snapshot__c> tcdIdSnapshotRec = new Map<Id,Accounting_Seed_Time_Snapshot__c>();
                Map<Id,Set<Id>> tcdIdStudentIds = new Map<Id,Set<Id>>();
                
                String dtVal = system.now().format('MM/dd/yyyy hh:mm:ss a');
                
                //get student names values
                Map<Id,String> studentIdNameMap = new Map<Id,String>();
                Set<Id> studentIds = new Set<Id>();
                
                for(TimeCardDayCommunityDomain.StudentEntry stuRec : studentRecords){
                    studentIds.add(stuRec.studentId);
                    
                    if(dateDayIdMap.containsKey(stuRec.dateVal)){
                        Id dayId = dateDayIdMap.get(stuRec.dateVal);
                        
                        if(!tcdIdStudentIds.containsKey(dayId)){
                            tcdIdStudentIds.put(dayId,new Set<Id>{stuRec.studentId});
                        }else {
                            tcdIdStudentIds.get(dayId).add(stuRec.studentId);
                        }
                    }
                }
                
                system.debug('::::::tcdIdStudentIds:::'+tcdIdStudentIds);
                
                for(Contact con : [SELECT Id,FirstName,LastName FROM Contact WHERE Id IN :studentIds]){
                    if(!studentIdNameMap.containsKey(con.Id)){
                        studentIdNameMap.put(con.Id,con.FirstName+' '+con.LastName.subString(0,1));
                    }
                }
                
                system.debug(':::::::::studentIdNameMap:::::'+studentIdNameMap);
                
                for(TimeCardDayCommunityDomain.StudentEntry stuRec : studentRecords){
                    Attendance__c att = new Attendance__c();
                    
                    att.Student__c = stuRec.studentId;
                    att.Instructor__c = contactId;
                    att.Date__c = stuRec.dateVal;
                    att.Duration__c = Decimal.valueOf(stuRec.hours);
                    
                    att.Student_Approval_Status__c = stuRec.studentApprovalStatus;
                    
                    if(stuRec.isNew){
                        att.Time_Card_Day__c = dateDayIdMap.containsKey(stuRec.dateVal) ? dateDayIdMap.get(stuRec.dateVal) : null;
                    }else if(stuRec.isUpdated){
                        att.Time_Card_Day__c = stuRec.dayId;
                    }
                    
                    att.Comments__c = stuRec.comments;
                    
                    if(String.isNotEmpty(stuRec.attendance)){
                        att.Attendance__c = stuRec.attendance;
                    }
                    
                    
                    //Check for the Actual Class Hrs & Student Hrs miss match for Notes creation
                    
                    //if(!updatedTCDIds.contains(att.Time_Card_Day__c)){
                        
                        if(dayIdDayRecMap.containsKey(att.Time_Card_Day__c) 
                            /*&& dayIdDayRecMap.get(att.Time_Card_Day__c).Total_Hours_Before_Approved__c != att.Duration__c*/ && String.isNotBlank(stuRec.comments)){
                            
                            
                            AcctSeed__Time_Card_Day__c day = dayIdDayRecMap.get(att.Time_Card_Day__c);
                            
                            Accounting_Seed_Time_Snapshot__c tcdSnapshot = new Accounting_Seed_Time_Snapshot__c();
                            tcdSnapshot.Note_Type__c = 'Instructor Daily Entry Student Hours Mismatch';
                            tcdSnapshot.Time_Card_Day__c = att.Time_Card_Day__c;
                            tcdSnapshot.Date__c = att.Date__c;
                            
                            String formattedDt = String.valueOf(att.Date__c).split('-')[1]+'/'+String.valueOf(att.Date__c).split('-')[2]+'/'+String.valueOf(att.Date__c).split('-')[0];
                            
                            tcdSnapshot.Notes__c = day.Instructor_Position__c+' '+day.Instructor_Name__c+' submitted a time entry on '+formattedDt+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                            
                            if(dayIdDayRecMap.get(att.Time_Card_Day__c).Total_Hours_Before_Approved__c != att.Duration__c)
                                tcdSnapshot.Notes__c += ', with different hours for a student.';
                            
                            if(!tcdIdSnapshotRec.containsKey(att.Time_Card_Day__c)){
                                if(tcdIdStudentIds.containsKey(att.Time_Card_Day__c) && tcdIdStudentIds.get(att.Time_Card_Day__c).size() == 1) {
                                    tcdSnapshot.Notes__c += ' Notes: '+att.Comments__c;
                                }else if(tcdIdStudentIds.get(att.Time_Card_Day__c).size() > 1) {
                                    tcdSnapshot.Notes__c += ' Notes: '+studentIdNameMap.get(att.Student__c)+' - '+att.Comments__c;
                                }
                                tcdIdSnapshotRec.put(att.Time_Card_Day__c,tcdSnapshot);
                                
                            }else {
                                Accounting_Seed_Time_Snapshot__c existingSnapshot = tcdIdSnapshotRec.get(att.Time_Card_Day__c);
                                existingSnapshot.Notes__c += ', '+studentIdNameMap.get(att.Student__c)+' - '+att.Comments__c;
                                
                                tcdIdSnapshotRec.put(att.Time_Card_Day__c,existingSnapshot);
                            }
                        }
                    //}
                    
                    if(stuRec.isNew){
                        att.Event__c = dateEventIdMap.containsKey(stuRec.dateVal) ? dateEventIdMap.get(stuRec.dateVal) : null;
                    }
                    
                    if(stuRec.attendanceId != null){
                        att.Id = stuRec.attendanceId;
                    }
                    
                    system.debug(':::::::::att:::;;'+att);
                    
                    if(att.Time_Card_Day__c != null){
                        attendanceList.add(att);
                    }
                }
                
                system.debug('::::::::::::::attendanceList::::::'+attendanceList);
                system.debug('::::::::tcdIdSnapshotRec::::'+tcdIdSnapshotRec);
                
                List<Accounting_Seed_Time_Snapshot__c> snapshotRecords = new List<Accounting_Seed_Time_Snapshot__c>();
                
                if(tcdIdSnapshotRec.size() > 0){
                    for(Id tcdId : tcdIdSnapshotRec.keySet()){
                        snapshotRecords.add(tcdIdSnapshotRec.get(tcdId));
                    }
                }
                
                system.debug('::::::::::snapshotRecords:::'+snapshotRecords);
                
                if(snapshotRecords.size() > 0){
                    insert snapshotRecords;
                }
                
                if(attendanceList.size() > 0){
                    upsert attendanceList;
                }
            }// End of student time & notes map formation
            
            //If action type is revert then update the records status to reverted
            if(actionType == 'Revert'){
                
                List<AcctSeed__Time_Card_Day__c> dayRecordForRevert = new List<AcctSeed__Time_Card_Day__c>();
                
                //add the records which are already available in database
                dayListToUpsert.addAll(daysForRevert);
                
                if(dayListToUpsert.size() > 0) {
                    for(AcctSeed__Time_Card_Day__c day : dayListToUpsert){
                        day.Status__c = 'Reverted';
                        day.AcctSeed__Hours__c = 0;
                       
                        dayRecordForRevert.add(day);
                        
                        //For Notes Formation static Map
                        if(!tcdIdNoteType.containsKey(day.Id)) {
                            tcdIdNoteType.put(day.Id,'Weekly Revert');
                        }
                    }
                }
                
                isGroupAction = true;
                groupActionType = 'Reverted';
                
                if(dayRecordForRevert.size() > 0) {
                    update dayRecordForRevert;
                }
            }
            
            return 'SUCCESS';
            
        }catch(DmlException e){
           system.debug('::::::::exception msg:::::::'+e.getMessage());
           throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static AcctSeed__Time_Card_Day__c dayInstanceFormation(TimeCardDayCommunityDomain.DayEntries day,String lineId,String costRateId){
        
        AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
        
        if(day.dayId != null){
            newDay.Id = day.dayId;
        }
        
        if(lineId != null){
            newDay.AcctSeed__Time_Card_Line__c = lineId;
        }
        
        if(costRateId != null){
           newDay.Labor_Cost_Rate__c = costRateId;
        }
        
        newDay.AcctSeed__Date__c = day.dateVal;
        newDay.Total_Hours_Before_Approved__c = Decimal.valueOf(day.dayHours);
        newDay.AcctSeed__Internal_Comment__c = day.comments;
        newDay.Status__c = day.status;
        
        if(day.status != 'Approved' && day.status != 'Admin Approved') {
            newDay.AcctSeed__Hours__c = 0;
        } else if(day.status == 'Approved' || day.status == 'Admin Approved') {
            newDay.AcctSeed__Hours__c = newDay.Total_Hours_Before_Approved__c;
        }
        
        if(day.TaskType != 'Preparation time') {
            newDay.Student_Approval_Status__c = day.studentApprovalStatus;
            newDay.Start_Time1__c = day.startTime1;
            newDay.End_Time1__c = day.endTime1;
            newDay.Late_Cancellation__c = day.lateCancellation;
            newDay.Cancellation_Reason__c = day.cancellationReason;
            newDay.Hide_From_Student__c = day.hideFromStudent;
        }else {
            newDay.Start_Time1__c = day.startTime1;
            newDay.End_Time1__c = day.endTime1;
            newDay.Start_Time2__c = day.startTime2;
            newDay.End_Time2__c = day.endTime2;
        }
        
        return newDay;
    }
    
    public static AcctSeed__Time_Card_Line__c lineInstanceFormation(TimeCardDayCommunityDomain.DayEntries day,String cardId, String Comment){
        
        AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
        line.AcctSeed__Project_Task__c = day.taskId;
        line.AcctSeed__Project__c = day.projectId;
        
        if(cardId != null){
            line.AcctSeed__Time_Card__c = cardId;
        }
        
        line.AcctSeed__Billable__c = day.isBillable;
        line.Payroll_Item__c = day.payrollItem;
        line.Location__c = day.locationId;
        line.Display_in_Future_Weeks__c = true;
        line.Contact_Assignment__c = day.contactAssignId;
        line.Sequence_Number__c = day.sequenceNumber;
        line.Comments__c = comment;
        
        return line;
    } 
    
    /***********************************************************************************************
    - Method to revert whole week entry
    - Added by NS on Nov 5 2019
    ************************************************************************************************/ 
    @AuraEnabled
    public static String revertTCDEntries(String timeDayJson,String comment){
        
        List<TimeCardDayCommunityDomain.DayEntries> dayRecords = (List<TimeCardDayCommunityDomain.DayEntries>) System.JSON.deserialize(timeDayJson, List<TimeCardDayCommunityDomain.DayEntries>.class);
        
        Set<Id> lineIds = new Set<Id>();
        List<AcctSeed__Time_Card_Day__c> daysForRevert = new List<AcctSeed__Time_Card_Day__c>();
        List<AcctSeed__Time_Card__c> cardUpdationList = new List<AcctSeed__Time_Card__c>();
        List<AcctSeed__Time_Card_Line__c> lineRecords = new List<AcctSeed__Time_Card_Line__c>();
        
        for(TimeCardDayCommunityDomain.DayEntries day : dayRecords){
        
            AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
            newDay.Id = day.dayId;
            newDay.Status__c = 'Reverted';
            newDay.AcctSeed__Hours__c = 0;
            
            lineIds.add(day.lineId);
            
            daysForRevert.add(newDay);
            
            //For Notes Formation static Map
            if(!tcdIdNoteType.containsKey(day.dayId)) {
                tcdIdNoteType.put(day.dayId,'Weekly Revert');
            }
        }
        
        /*//Qry line related card to update comments
        for(AcctSeed__Time_Card__c card : [SELECT Id,Comments__c FROM AcctSeed__Time_Card__c 
                                                WHERE Id IN (SELECT AcctSeed__Time_Card__c FROM AcctSeed__Time_Card_Line__c WHERE Id IN :lineIds)]){
            card.Comments__c = comment;
            cardUpdationList.add(card);
        }*/
        
        //Qry line records to uncheck the completed action on revert action
        //Added by NS on July 13 2020
        for(AcctSeed__Time_Card_Line__c  line : [SELECT Id,Completed__c FROM AcctSeed__Time_Card_Line__c WHERE Id IN :lineIds AND Completed__c = true]){
            line.Completed__c = false;
            line.Comments__c = comment;
            lineRecords.add(line);
        }
        
        system.debug('::::::::cardUpdationList::::'+cardUpdationList);
        
        try {
        
            if(cardUpdationList.size() > 0){
                update cardUpdationList;
            }
            
            if(lineRecords.size() > 0){
                update lineRecords;
            }
            
            if(daysForRevert.size() > 0){
            
                isGroupAction = true;
                groupActionType = 'Reverted';
                
                // Page name to use in Time Card Day Trigger for notes formation
                pageType = 'Admin Time Entry';
            
                update daysForRevert;
            }
            
            return 'success';
            
        }catch(DmlException e){
           system.debug('::::::::exception msg:::::::'+e.getMessage());
           throw new AuraHandledException(e.getMessage());
        }
        
    } 
}