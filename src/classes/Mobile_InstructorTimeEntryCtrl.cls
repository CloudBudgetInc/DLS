/*****************************************************************************
- Class to handler mobile instructor time entry process
- Added by NS on Feb 5 2020
*****************************************************************************/
public without sharing class Mobile_InstructorTimeEntryCtrl {


    /***************************************************************
     - Method to get the Week filter information
    ****************************************************************/
    @AuraEnabled
    public static string getInitialFilterValues(){
    
        return InstructorTimeEntry_Controller.getInitialFilterValues();
    }
    
    /**************************************************************************
    - Method to get Week & Instructor based project filter data
    **************************************************************************/
    @AuraEnabled
    public static String getProjectFilterValues(String startDate,String endDate,String contactId){
    
        return InstructorTimeEntry_Controller.getProjectFilterValues(startDate,endDate,contactId);
    }
    
     /************************************************************
    - Method to get the TCL Rows related information from TCD / PT (based in schedule information)
    *************************************************************/
    
    @AuraEnabled
    public static String getTimeRowsRelatedInformation(String stDate,String endDate,String projectId,String contactId,String projectName,String studentNames){
    
        Date startDt = Date.valueOf(stDate);
        Date endDt = Date.valueOf(endDate);
        
        system.debug(':::::::startDt:::;;'+startDt);
        system.debug(':::::::endDt:::;;'+endDt);
        
        Set<Id> filteredPTIds = new Set<Id>();
        
        List<AcctSeed__Project__c> projectRecord = [SELECT Id,Name,RecordType.DeveloperName,DLS_Class__c,No_Student_Approval__c,AcctSeed__Status__c,No_Student_Hours_Verification__c FROM AcctSeed__Project__c WHERE Id = :projectId];
        String projectRTName = projectRecord[0].RecordType.DeveloperName;
        String projectStatus = projectRecord[0].AcctSeed__Status__c;
        
        List<AcctSeed__Project_Task__c> taskRecords = new List<AcctSeed__Project_Task__c>();
        Map<Id,Integer> taskIdTimeCount = new Map<Id,Integer>();
        Map<Id,String> taskIdTimeMap = new Map<Id,String>();
        Map<Id,String> taskIdTimezone = new Map<Id,String>();
      
        //Apply schedule based filter condition to get the PT  on the Instructor Time Entry Page
        for(Schedule__c sch : [SELECT Id,Name,Project_Task__c,Project_Task__r.Project_Task_Type__c,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c,Timezone__c FROM Schedule__c 
                                    WHERE Status__c IN ('Active','Completed') AND (Start_Date__c <= :endDt AND End_Date__c >= :startDt) 
                                        AND Project__c = :projectId AND Instructor__c = :contactId]){
            
            filteredPTIds.add(sch.Project_Task__c);
            
            if(!taskIdTimezone.containsKey(sch.Project_Task__c)){
                taskIdTimezone.put(sch.Project_Task__c,sch.Timezone__c);
            }
            
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
        
        for(Events__c eve : [SELECT Id,Name,Project_Task__c,Project_Task__r.Project_Task_Type__c,Date__c,Start_Time__c,End_Time__c,Timezone__c FROM Events__c
                                    WHERE Project__c = :projectId AND Instructor__c = :contactId AND Schedule__c = null AND Status__c IN ('Scheduled','Completed') //Added Completed Status - Dhinesh - 30-09-2021 - W-007020 
                                    AND Project_Task__r.Project_Task_Type__c != 'Material budget' AND (Date__c <= :endDt AND Date__c >= :startDt)]){ //Added Project Task Type filter - Dhinesh - 7/4/2022 - W-007427
            
            filteredPTIds.add(eve.Project_Task__c);
            
            if(!taskIdTimezone.containsKey(eve.Project_Task__c)){
                taskIdTimezone.put(eve.Project_Task__c,eve.Timezone__c);
            }
            
            if(eve.Project_Task__r.Project_Task_Type__c == 'Preparation time') {
                if(!taskIdTimeCount.containsKey(eve.Project_Task__c)){
                    taskIdTimeCount.put(eve.Project_Task__c,1);
                }else {
                    taskIdTimeCount.put(eve.Project_Task__c,taskIdTimeCount.get(eve.Project_Task__c) + 1);
                }
                
                if(!taskIdTimeMap.containsKey(eve.Project_Task__c)){
                    
                    if(eve.Start_Time__c != null && eve.End_Time__c != null) {
                    
                        if(eve.Start_Time__c.split(' ')[1] == 'PM' && eve.End_Time__c.split(' ')[1] == 'PM'){
                            taskIdTimeMap.put(eve.Project_Task__c,'PM');
                        }else {
                            taskIdTimeMap.put(eve.Project_Task__c,'AM');
                        }
                    }
                }else {
                    taskIdTimeMap.put(eve.Project_Task__c,'Both');
                }
            }
        }
        
        system.debug('::::::::::taskIdTimeCount::::'+taskIdTimeCount);
        system.debug(':::::::::taskIdTimeMap:::::'+taskIdTimeMap);
        system.debug('::::::filteredPTIds:::'+filteredPTIds);
        
        if(filteredPTIds.size() > 0){
            
            // taskRecords = [SELECT Id,Name,Billable__c,AcctSeed__Project__r.Training_Location__r.Name,AcctSeed__Project__r.Training_Location__c,
            //                         Parent_Project_Task__c,Project_Task_Type__c,AcctSeed__Project__r.RecordType.DeveloperName,RecordType.DeveloperName,Payroll_Item__c
            //                     FROM AcctSeed__Project_Task__c 
            //                     WHERE AcctSeed__Project__c = :projectId AND Id IN :filteredPTIds ORDER BY Project_Task_Type__c ASC];

            Map<Integer,AcctSeed__Project_Task__c> sequenceNoPTRec = new Map<Integer,AcctSeed__Project_Task__c>();
            List<Integer> seqNums = new List<Integer>();
            
            Integer count = 0;
            
            for(AcctSeed__Project_Task__c task : [SELECT Id,Name,Billable__c,AcctSeed__Project__r.Training_Location__r.Name,AcctSeed__Project__r.Training_Location__c,Payroll_Item__c,
                                                        Parent_Project_Task__c,Project_Task_Type__c,AcctSeed__Project__r.RecordType.DeveloperName,RecordType.DeveloperName, AcctSeed__Project__r.Default_Cost_Rate_Rate_Type__c //W-007882
                                                    FROM AcctSeed__Project_Task__c 
                                                    WHERE AcctSeed__Project__c = :projectId AND Id IN :filteredPTIds ORDER BY Project_Task_Type__c ASC]){
                
                if(task.Name == 'Fringe-PTO'){
                    sequenceNoPTRec.put(500,task);
                } 
                else if(task.Name=='Fringe-Holiday'){
                    sequenceNoPTRec.put(501,task);
                    System.debug('Fringe-Holiday');
                } 
                else {
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
        
        }else if(projectRTName == 'EFL_Projects'){    //To include EFL Projects in instructor time entry. They dont have student &schedule details - W-005036
            
            //For display project task in order need to do some ordering
            Map<Integer,AcctSeed__Project_Task__c> sequenceNoPTRec = new Map<Integer,AcctSeed__Project_Task__c>();
            List<Integer> seqNums = new List<Integer>();
            
            Integer count = 0;
            
            for(AcctSeed__Project_Task__c task : [SELECT Id,Name,Billable__c,AcctSeed__Project__r.Training_Location__r.Name,AcctSeed__Project__r.Training_Location__c,
                                    Parent_Project_Task__c,Project_Task_Type__c,AcctSeed__Project__r.RecordType.DeveloperName,RecordType.DeveloperName,Payroll_Item__c, AcctSeed__Project__r.Default_Cost_Rate_Rate_Type__c //W-007882
                                FROM AcctSeed__Project_Task__c 
                                WHERE AcctSeed__Project__c = :projectId AND Project_Task_Type__c IN ('Language Training','Fringe') ORDER BY Project_Task_Type__c ASC]){
                
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
        List<Contact_Assignments__c> caRecord = [SELECT Id,Name,Rate_Card_Rate__c,Rate_Card_Rate__r.Payroll_Item__c,Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Project_Task__c,
                                                            Start_Date__c, End_Date__c, Oral_Exam_Date_Time__c
                                                        FROM Contact_Assignments__c 
                                                        WHERE Project__c = :projectId AND Candidate_Name__c = :contactId AND (Start_Date__c <= :endDt AND End_Date__c >= :startDt)];
        
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
        
        Set<String> studentStatus = new Set<String>{'Active','On Hold','Ended'};
        
        //W-004822 - to display ended students only upto the ended week
        //W-005456 - added ESL LT Projects record type for ELT Pilot program
         
        if((projectRTName == 'DLI_W_LT_Projects' || projectRTName == 'DODA_Projects' || projectRTName == 'ESL_LT_Projects' || projectRTName == 'Language_Training_Projects') && filteredPTIds.size() > 0){
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Name,Status__c,Start_Date__c,End_Date__c 
                                                FROM Contact_Assignments__c 
                                                WHERE Status__c IN :studentStatus AND RecordType.DeveloperName = 'Student' 
                                                    AND Project__c = :projectId ORDER BY Candidate_Name__r.FirstName ASC]){
                                
                if((ca.Status__c == 'Active' || ca.Status__c == 'On Hold') || (ca.Status__c == 'Ended' && ca.End_Date__c >= startDt)){//&& ca.End_Date__c <= endDt
                    studentCAs.add(ca);
                    studentIds.add(ca.Candidate_Name__c);
                }                                        
            }
        }
        
        //Qry Existing attendance records to prepopulate the values in student time table
        List<Attendance__c> studentAttendanceList = new List<Attendance__c>();
        
        if(studentIds.size() > 0 && filteredPTIds.size() > 0 && projectRecord.size() > 0 && !projectRecord[0].No_Student_Approval__c){
            
            studentAttendanceList = [SELECT Id,Name,Student__c,Student__r.Name,Instructor__c,Date__c,Duration__c,Student_Approval_Status__c,
                                                Event__c,Time_Card_Day__c,Time_Card_Day__r.Late_Cancellation__c,Time_Card_Day__r.Status__c,Recall_Reason__c,Rejection_Reason__c,Comments__c,Time_Card_Day__r.Total_Hours_Before_Approved__c,Attendance__c  
                                        FROM Attendance__c 
                                        WHERE Student__c IN :studentIds AND (Date__c >= :startDt AND Date__c <= :endDt) AND Instructor__c = :contactId
                                                AND Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = :projectId ORDER BY Student__r.FirstName ASC];
            
        }
        
        //Display selected week & project & current contact related case record to show warning msg when they try to submit a case again
        List<Case> editRequestCase = [SELECT Id,Type,ContactId,Subject FROM Case WHERE ContactId = :contactId AND Type = 'Timesheet Edit Request'];
        
        Boolean alreadyCaseSubmitted = false;
        
        if(editRequestCase.size() > 0){
            String weekRange = stDate.split('-')[1]+'/'+stDate.split('-')[2]+'/'+stDate.split('-')[0]+' to '+endDate.split('-')[1]+'/'+endDate.split('-')[2]+'/'+endDate.split('-')[0];
            if(editRequestCase[0].Subject.contains(projectRecord[0].DLS_Class__c) && editRequestCase[0].Subject.contains(weekRange)){
                alreadyCaseSubmitted = true;
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
        
        TimeCardDayCommunityDomain.WeekSummaryDetail weekSummaryDetails = TimeCardDayCommunityTranslator.weekSummaryDetailFormation(startDt,endDt,projectName,studentNames,contactId,timeCardLineList,accTimesnapshot,taskRecords,caRecord,taskIdTimeCount,taskIdTimeMap,caHistory,oldCRRecord,studentCAs,studentAttendanceList,alreadyCaseSubmitted,daysOffRecords,holidayDates,taskIdTimezone);
        
        return JSON.serialize(weekSummaryDetails);
    }
    
    /************************************************************************************
    - Method to get project based Active, Draft & completed(last 14 days) schedule records
    ************************************************************************************/
    @AuraEnabled
    public static List<Schedule__c> getProjectBasedSchedules(string projectId,String startDate, String endDate,String contactId){
        
        return InstructorTimeEntry_Controller.getProjectBasedSchedules(projectId,startDate,endDate,contactId);
    }
    
    /****************************************************************************************
    - Method for group & individual time entry recall action
    *****************************************************************************************/
    @AuraEnabled
    public static String recallTimeEntries(String timeDayJson,String typeOfAction){
        
        return InstructorTimeEntry_Controller.recallExistingTimeEntries(timeDayJson,typeOfAction);
    }
    
    /****************************************************************************************
    - Method to recall student time entries
    ****************************************************************************************/
    @AuraEnabled
    public static String recallStudentEntries(String studentJson){
        return InstructorTimeEntry_Controller.recallStudentAttendanceEntry(studentJson);
    }
    
    /****************************************************************************************
    - Get project related events for a specific date
    *****************************************************************************************/
    @AuraEnabled
    public static String getProjectRelatedEvents(String projectId, String instructorId, String startDate, String endDate, String timeDayJson){
        
        return InstructorTimeEntry_Controller.getProjectRelatedEvents(projectId,instructorId,startDate,endDate,timeDayJson);
    }
    
    /****************************************************************************************
    - Get other time entries for same date range for this instructor
    *****************************************************************************************/
    @AuraEnabled
    public static String getExistingTCDsForOtherProjects(String instructorId,String startDate,String endDate,String projectId){
    
        return InstructorTimeEntry_Controller.getExistingTCDsForOtherProjects(instructorId,startDate,endDate,projectId);
    }
    
    /************************************************************************************
    - Save action related method
    *************************************************************************************/
    @AuraEnabled
    public static String saveTimeEntryRecords(String startDate, String endDate, String conId,String timeDayJson,String projectId,String actionType,String studentJson,List<String> updatedTCDs){
    
        return InstructorTimeEntry_Controller.dmlOperationMethod(startDate,endDate,conId,timeDayJson,projectId,actionType,studentJson,updatedTCDs);
    }
    
    /*******************************************************************************
    - Method to get the selected week & project related scheduled events
    ***********************************************************************************/
    @AuraEnabled
    public static string getScheduledEvents(String startDt, String endDt, String projectId, String contactId){
    
        return InstructorTimeEntry_Controller.getScheduledEvents(startDt,endDt,projectId,contactId);
    }
    
    /**********************************************************************************
    - Method to complete time card day entries
    ***********************************************************************************/
    @AuraEnabled
    public static String completeTimeCardDayEnties(String timeDayJson){
    
        return InstructorTimeEntry_Controller.completeTCDEntries(timeDayJson);
    }
}