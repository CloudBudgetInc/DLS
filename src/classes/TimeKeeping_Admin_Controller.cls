global with sharing class TimeKeeping_Admin_Controller {
     
    
    // Declared the variables for Revert action notes formation in snapshot obj
    // Added by NS on May 31 2017
    public static Boolean isGroupAction;
    public static String groupActionType;
    
    /************
    - Added By HL on June 08 2021
    - Work Item: W-006755 - Email for Reverted Timesheet Missing Reason Note
    - Used in GetCommentsFromTCLCmp visualforce component 
    - To return the Comments field value in Time Card Line object
        *****************/
    global String timecardIdVal{ get; set; }
    
    global String commentsVal {
    
        get{
        
            if(timecardIdVal != '' && timecardIdVal != NULL){
            
                List<AcctSeed__Time_Card_Line__c> tcl = [SELECT Id, Comments__c 
                                                            FROM AcctSeed__Time_Card_Line__c 
                                                            WHERE AcctSeed__Time_Card__c = :timecardIdVal];
                if(tcl != NULL && tcl.size() > 0){
                
                    String comments = tcl[0].Comments__c;
                    if(String.isNotBlank(comments)){
                        return comments;
                    }else{
                        return '';
                    }
                }else{
                    return '';
                }
            }else {
                return '';
            }
        }
        set;
    }
    
    /**********************************************************************
        Created by Sukanya on March 16 2017: For Admin Time Entry Page restructure
    ***********************************************************************/
    @RemoteAction
    global static TimeCardDayDomain.AdminTimeEntryDetails getWholeWeekRangeValues(String userType) {
        
        system.debug(':::::userType:::::::::'+userType);
        
        Set<Id> timeCardLineIds = new Set<Id>();
        Set<Date> WholeDateSet = new Set<Date>();
        Set<String> weekRangeSet = new Set<String>();
        Map<Id,String> contactIdnameMap = new Map<Id,String>();
        
        
        // Get User timezone offset value
        String timezoneValue = UserInfo.getTimeZone().getID();
        
         // Get TimeLog_Locking_Date custom setting value    
         System_Values__c sysVal = System_Values__c.getValues('TimeLog_Locking_Date');    
         Date lockingDate;   
         if (sysVal != null && sysVal.Value__c != null) {
             lockingDate = Date.valueOf(sysVal.Value__c);
         } 
         
         system.debug(':::::lockingDate:::::::'+lockingDate);
         system.debug(':::ate:::after:::lockingdate:::'+lockingDate.addDays(1));
         
         //Get Profile Ids from Custom Labels (TimeLog_Admin_ProfileIds)
         String timelogAdminProfIds = label.TimeLog_Admin_ProfileIds;    
         Set<Id> adminProfileIdSet = new Set<Id>();
         
         if (String.isNotEmpty(timelogAdminProfIds)) {
            if (timelogAdminProfIds.contains(',')) {  
                for(String str : timelogAdminProfIds.split(',')) {
                    if (!adminProfileIdSet.contains(Id.valueOf(str.trim()))){
                        adminProfileIdSet.add(Id.valueOf(str.trim()));
                    }
                }
            } else {
                adminProfileIdSet.add(Id.valueOf(timelogAdminProfIds));
            }
         }
         
         system.debug(':::::adminProfileIdSet::::::'+adminProfileIdSet);
         
         Boolean userPermissiionValue = false;
         
         String loggedInuserProfileId = UserInfo.getProfileId();
         system.debug('::::::::::loggedInuserProfileId::::::'+loggedInuserProfileId);
         
         if(adminProfileIdSet.contains(loggedInuserProfileId)){
             userPermissiionValue = true;
         }else {
             userPermissiionValue = false;
         }
         system.debug(':::userPermissiionValue::::'+userPermissiionValue);
         
         // Get the dates between after locking date & current date
         
         Date stDateAfterlock = lockingDate.addDays(1);
         Date endDateuptoToday = system.today().addDays(14);
         
         while(stDateAfterlock <= endDateuptoToday) {
           WholeDateSet.add(stDateAfterlock);
           stDateAfterlock = stDateAfterlock.addDays(1);
         }
         
         system.debug(':::WholeDateSet::::::'+WholeDateSet);
         system.debug(':::WholeDateSet::size::::'+WholeDateSet.size());
         
         // Get Week ranges for all the above date values
         
         for(Date dt : WholeDateSet) {
             
            Date st;
            
            if(dt.toStartofWeek().addDays(1) < dt)
                 st = dt.toStartofWeek().addDays(1);
            else
                 st = dt.addDays(-1).toStartofWeek().addDays(1);
            
            Date ed = st.addDays(6); 
            
            if(!weekRangeSet.contains(String.valueOf(st).split(' ')[0]+' to '+String.valueOf(ed).split(' ')[0])) {
                weekRangeSet.add(String.valueOf(st).split(' ')[0]+' to '+String.valueOf(ed).split(' ')[0]);
            }
         }
         
         system.debug('::::::::weekRangeSet:::::::'+weekRangeSet);
         system.debug('::::::::weekRangeSet::::size:::'+weekRangeSet.size());
         
         // Added user type condition for instructor contact related admin time entry process
         // Added by Sukanya on June 30 2017 
         
         // Get all the contact records for Contact section
         List<Contact> contactRecords = new List<Contact>();
         
         if(userType == 'Internal') {
             for(Contact con : ContactService.getContactByparentId(' WHERE RecordType.DeveloperName = \'DLS_Employee\'','',new Set<Id>{})) {
                 if(!contactIdnameMap.containsKey(con.Id))
                     contactIdnameMap.put(con.Id,con.Name);
             }
         }else if(userType == 'Instructor') {
             for(Contact con : ContactService.getContactByparentId(' WHERE RecordType.DeveloperName = \'Candidate\' ORDER BY Name ASC LIMIT 200 ','',new Set<Id>{})) {
                 if(!contactIdnameMap.containsKey(con.Id)) {
                     contactIdnameMap.put(con.Id,con.Name);
                 }
                 
                 contactRecords.add(con);
             }
         }
         
         system.debug('::::::contactIdnameMap:::::::'+contactIdnameMap);
         
        // Qry Project Task Master - Custom setting for Fringe PT payroll item values
        // Added by NS - July 18 2017
        List<Project_Task_Master__c> PTMValues = [SELECT Id,Name,Billable__c,Display_In_Time_Card__c,Labor_GL_Account__c,
                                                     Payroll_Item__c,Project_Record_Type__c,Project_Task_Record_Type__c,Project_Task_Type__c,
                                                     Project_Type__c,Unit__c 
                                                 FROM Project_Task_Master__c
                                                 WHERE  (Project_Record_Type__c = 'Admin_Projects' OR Project_Record_Type__c = 'Admin_Projects;EFL_Projects;CD_Projects' OR Project_Record_Type__c = 'Admin_Projects;CD_Projects' 
                                                     OR Project_Record_Type__c = 'EFL_Projects' OR Project_Record_Type__c = 'Admin_Projects;CD_Projects;Linguist_Support_Projects')];
                                                 
        system.debug('::::::PTMValues::::::'+PTMValues);
        
      
        TimeCardDayDomain.AdminTimeEntryDetails timeEntrydetails = TimeCardDayTranslator.adminEntrypage_Recordsformation(new List<AcctSeed__Time_Card_Line__c>(),weekRangeSet,true,new List<Accounting_Seed_Time_Snapshot__c>(),null,null,timezoneValue,contactIdnameMap,lockingDate,'',new List<AcctSeed__Project__c>(),new List<AcctSeed__Project_Task__c>(),userPermissiionValue,new List<Contact_Assignments__c>{},PTMValues,'',contactRecords);
          
        system.debug(':::::timeEntrydetails::::::'+timeEntrydetails);
        
        return timeEntrydetails;
    }
    
    // Method to get time card day record for specific Week interval
     @RemoteAction
     global static TimeCardDayDomain.AdminTimeEntryDetails getspecificeWeekRecords(String startDate,String endDate,String contactId,String userType) {
         
         Date weekStart = Date.valueOf(startDate).toStartofWeek().addDays(1);
         Date weekEnd = Date.valueOf(endDate);
         
         system.debug(':::::::weekStart:::::'+weekStart);
         system.debug(':::::::weekStart:::::'+weekEnd);
         
         Set<Id> timeCardLineIds = new Set<Id>();
         Set<Id> projectId = new Set<Id>();
         List<AcctSeed__Project_Task__c> projectTaskList = new List<AcctSeed__Project_Task__c>();
         List<AcctSeed__Project__c> projectList = new List<AcctSeed__Project__c>();
         
         // Get User timezone offset value
         String timezoneValue = UserInfo.getTimeZone().getID();
         
         // Get TimeLog_Locking_Date custom setting value    
         System_Values__c sysVal = System_Values__c.getValues('TimeLog_Locking_Date');    
         Date lockingDate;   
         if (sysVal != null && sysVal.Value__c != null) {
             lockingDate = Date.valueOf(sysVal.Value__c);
         } 
         
         //Get TimeCardLine Ids for specific Week
         
         for(AcctSeed__Time_Card_Line__c lineRec : TimeCardLineService.getLineRec_DayRecExist(weekStart,weekEnd,contactId)) {
            timeCardLineIds.add(lineRec.Id);
         }
         system.debug(':::::::timeCardLineIds:::::::::'+timeCardLineIds);
         
         String filterCdn = ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = \''+contactId+'\' ORDER BY AcctSeed__Date__c ASC';
         
         List<AcctSeed__Time_Card_Line__c> timeCardlineList = new List<AcctSeed__Time_Card_Line__c>();
         
         if(timeCardLineIds.size() > 0) {
             timeCardlineList = TimeCardLineService.getLineWithCardday(weekStart,weekEnd,timeCardLineIds,filterCdn);
         }
             
         system.debug('::::timeCardlineList:::::::::'+timeCardlineList);
         
         // Qry time card day with time snapshot records
         List<Accounting_Seed_Time_Snapshot__c> accTimesnapshot = new List<Accounting_Seed_Time_Snapshot__c>();
         
          for(AcctSeed__Time_Card_Day__c day : TimeCardDayService.getDayWithDate_timeLinefilter(timeCardLineIds,weekStart,weekEnd) ) {
            
            if(day.Accounting_Seed_Time_Snapshots__r != null && day.Accounting_Seed_Time_Snapshots__r.size() > 0) {
                for(Accounting_Seed_Time_Snapshot__c snapShot : day.Accounting_Seed_Time_Snapshots__r) {
                    accTimesnapshot.add(snapShot);
                }
            }
         }
         system.debug('::::::accTimesnapshot::::::'+accTimesnapshot);
         
         // Get project ids from contact Assignment
         
         
         String condition = '';
         
         // Qry contact assingment based on the user type

         //Thie date condition to filter the Projects based on the CA End Date values
         // Added by NS on Dec 8 2018
         String caFilterDate = String.valueOf(weekStart.addDays(-14)).split(' ')[0];
         
         if(userType == 'Internal') {
             condition = ' WHERE RecordType.DeveloperName IN (\'Staff\',\'Instructor\') AND (Status__c = \'Active\' OR (Status__c = \'Ended\' AND End_Date__c >= '+caFilterDate+')) AND Project__c != null AND Candidate_Name__c = \''+contactId+'\'';
         } else if(userType == 'Instructor') {
             condition = ' WHERE RecordType.DeveloperName IN (\'Staff\',\'Instructor\') AND (Status__c = \'Active\' OR (Status__c = \'Ended\' AND End_Date__c >= '+caFilterDate+')) AND Project__c != null AND Candidate_Name__c = \''+contactId+'\'';
         }
         
         List<Contact_Assignments__c> conAssingmentList = new List<Contact_Assignments__c>();
           
         for(Contact_Assignments__c assign : ContactAssignmentService.getContactassignmentRec(condition,'Project__r.RecordType.DeveloperName,Rate_Card_Rate__r.Payroll_Item__c,Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Rate_Card_Rate__r.Fringe_Payroll_Item__c,Rate_Card_Rate__r.Rate_Type__c,Candidate_Name__r.Home_Department_Project__c,RecordType.DeveloperName')) {
             
             if(userType == 'Internal') {
                 
                 if(assign.Project__c == assign.Candidate_Name__r.Home_Department_Project__c || assign.RecordType.DeveloperName == 'Instructor'
                     || assign.Project__r.RecordType.DeveloperName == 'Admin_Projects'
                     || (assign.RecordType.DeveloperName == 'Staff' && (assign.Project__r.RecordType.DeveloperName == 'Testing_Projects' 
                     || assign.Project__r.RecordType.DeveloperName == 'CD_Projects'))) {
                     
                     projectId.add(assign.Project__c);
                     conAssingmentList.add(assign);
                 }
                 
             }else if(userType == 'Instructor') {
                 projectId.add(assign.Project__c);
                 conAssingmentList.add(assign);
             }
         }
         
         system.debug('::::::::projectId:::::'+projectId);
         
         // Get Project task values by project ids
         
          if(projectId != null && projectId.size() > 0) {
              for(AcctSeed__Project_Task__c task : ProjectTaskService.getProjecttasksByfilters(projectId,new Set<String>{},'',',AcctSeed__Project__r.Name,AcctSeed__Project__r.RecordType.DeveloperName,RecordType.DeveloperName')) {
                  projectTaskList.add(task);
              }
          }
          
          projectList = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',projectId,',Training_Location__r.Name,RecordType.DeveloperName');
          
         // Qry selected contact related cost rate records for Fringe PT Cost rate population
         // Added by NS - August 29 2017
         List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id,Name,Contact__c,Contact__r.Name,Payroll_Item__c,Rate_Type__c,SCA_Type__c,Status__c 
                                                         FROM AcctSeed__Cost_Rates__c 
                                                         WHERE Contact__c = :contactId AND Rate_Type__c IN ('PT Hourly (OH & G&A)','FT Hourly & Benefits')];
         system.debug(':::::::::costRateList::::::'+costRateList);
         
         // get Contact related Home Department Project Id
         List<Contact> con = [SELECT Id,Name,Home_Department_Project__c FROM Contact WHERE Id = :contactId];
         
         Id homeDeptId;
         
         if(con != null && con.size() > 0) {
             homeDeptId = con[0].Home_Department_Project__c;
         }
         
         TimeCardDayDomain.AdminTimeEntryDetails specificTimedetails = TimeCardDayTranslator.adminEntrypage_Recordsformation(timeCardlineList,new Set<String>(),false,accTimesnapshot,weekStart,weekEnd,timezoneValue,new Map<Id,String>{},lockingDate,contactId,projectList,projectTaskList,false,conAssingmentList,new List<Project_Task_Master__c>{},homeDeptId,new List<Contact>{});
          
         system.debug(':::::specificTimedetails::::::'+specificTimedetails);
        
         return specificTimedetails;
    }
    
    // Remote action to Query already existing time card day and events
    
     @RemoteAction
     global static List<TimeCardDayDomain.TimeCardDay> getExistingdayRecord(Id projectId,Id taskId,Id instructorId,String st,String ed,Boolean billableValue,String payRoll) {
         
         Date StartDate = Date.valueOf(st).toStartofWeek().addDays(1);
         Date EndDate = Date.valueOf(ed);
         Date weekStart = StartDate.toStartofWeek().addDays(1);
         Date weekEnd = EndDate;
         
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
                                     ' AND AcctSeed__Time_Card_Line__r.Payroll_Item__c = \''+payRoll+'\' AND Status__c != \'Unposted\' ORDER BY AcctSeed__Date__c ASC';
                                     
         String ParentField = ',AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,'+
                               'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,'+
                               'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c,'+
                               'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,'+
                               'AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c,AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c,'+
                               'AcctSeed__Time_Card_Line__r.Payroll_Item__c,'+
                               'AcctSeed__Time_Card_Line__r.Location__c,AcctSeed__Time_Card_Line__r.Location__r.Name,'+
                               'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name';
         
         List<AcctSeed__Time_Card_Day__c> timeCardEventList = TimeCardDayService.getDayWithPro_Task_Ins_Datefilters(filterCondition,ParentField,StartDate,EndDate);
                                                
        system.debug('::::::timeCardEventList:::::::'+timeCardEventList);
        
        List<TimeCardDayDomain.TimeCardDay> existingTimeCardDays = TimeCardDayTranslator.existingTimeDayFormation(timeCardEventList,daysList,instructorId,projectId,taskId);
        
        system.debug(':::::::::existingTimeCardDays::::::::::::'+existingTimeCardDays);
        
        return existingTimeCardDays;
     }
     
     // Save operation code
     @RemoteAction
     global static void dmlOperationFunction(String timeCardDayJson,String fromDate,String toDate,List<Id> updateDayRecIds,String selectedContact,String actionType,String Usrcomments) {
         //system.debug('::::::timeCardDayJson:::::'+timeCardDayJson);
         system.debug('::::::fromDate:::::'+fromDate);
         system.debug('::::::toDate:::::'+toDate);
         system.debug('::::::updateDayRecIds::::::'+updateDayRecIds);
         List<TimeCardDayDomain.TimeCardDay> InnerClassList = (List<TimeCardDayDomain.TimeCardDay>) System.JSON.deserialize(timeCardDayJson, List<TimeCardDayDomain.TimeCardDay>.class);
         system.debug('::::::::InnerClassList:::::::'+InnerClassList);
         
         Id timeCardPeriodId;
         Set<Id> timeCardId = new Set<Id>();
         Map<Id,AcctSeed__Time_Card__c> InstrutorIdandRecordMap = new Map<Id,AcctSeed__Time_Card__c>();
         Map<Id,Map<String,AcctSeed__Time_Card_Line__c>> InstructIdTaskIdandLineRecMap = new Map<Id,Map<String,AcctSeed__Time_Card_Line__c>>();
         Set<Id> InstructorId = new Set<Id>();
         Map<Id,Id> ContactIdUserIdMap = new Map<Id,Id>();
         
         Map<Id,List<AcctSeed__Time_Card_Line__c>> InstructorIdLineListMap = new Map<Id,List<AcctSeed__Time_Card_Line__c>>();
         Map<String,List<AcctSeed__Time_Card_Day__c>> InstIdTaskIdStringDayLsitMap = new Map<String,List<AcctSeed__Time_Card_Day__c>>();
         Set<Id> timeCardLineId = new Set<Id>();
         Set<Id> InsIdForRefer = new Set<Id>();
         
         //Map<Id,Map<Id,AcctSeed__Time_Card_Line__c>> InsIdTaskIdTimeLineMap = new Map<Id,Map<Id,AcctSeed__Time_Card_Line__c>>();
         Map<Id,Map<String,AcctSeed__Time_Card_Line__c>> InsIdStringTimeLineMap = new Map<Id,Map<String,AcctSeed__Time_Card_Line__c>>();
         
         List<AcctSeed__Time_Card__c> cardCreation = new List<AcctSeed__Time_Card__c>();
         List<AcctSeed__Time_Card_Line__c> timeLineCreation = new List<AcctSeed__Time_Card_Line__c>();
         List<AcctSeed__Time_Card_Day__c> timeCardDayCreationList = new List<AcctSeed__Time_Card_Day__c>();
         
         // This list to update existing records
         List<AcctSeed__Time_Card_Day__c> UpdateTimeCardDayList = new List<AcctSeed__Time_Card_Day__c>();
         
         // This list is to Update existing time card line with billable & non billable values
         Map<Id, AcctSeed__Time_Card_Line__c> UpdateTimeCardLineMap = new Map<Id, AcctSeed__Time_Card_Line__c>();
         
         // List to get all records for email notification
         List<AcctSeed__Time_Card_Day__c> wholeRecordEmaillList = new List<AcctSeed__Time_Card_Day__c>();
         
         Set<Id> updationRecIdSet = new Set<Id>();
         updationRecIdSet.addAll(updateDayRecIds);
         
         system.debug(':::::::updationRecIdSet::::::'+updationRecIdSet);
         
         /*// Update time card Comments field based on UsrComment
         List<AcctSeed__Time_Card__c> cardUpdationList = new List<AcctSeed__Time_Card__c>();
         Set<Id> cardId_ForUpdate = new Set<Id>();*/
         
         // List to capture the Modified records - For email sending purpose
         List<AcctSeed__Time_Card_Day__c> modifiedRecordList = new List<AcctSeed__Time_Card_Day__c>();
         
         
         // Set this variable for trigger usage
         if(actionType == 'From Revert'){
             isGroupAction = true;
             groupActionType = 'Reverted';
         }else {
             isGroupAction = false;
         }
         
         Date fromDt = Date.valueOf(fromDate);
         Date toDt = Date.valueOf(toDate);
         
         String month;
    
         date monthStart = fromDt.toStartofMonth();
         date monthEnd = fromDt.addMonths(1).toStartofMonth().addDays(-1);
         date monthStart1 = toDt.toStartofMonth();
         date monthEnd1 = toDt.addMonths(1).toStartofMonth().addDays(-1);
         
         // Already Existing Records Query Function
         
         // Added by Sukanya for future date records creation 
         // To check Account period records are exist or not & create if not
         
         // Account Period Query
         
            List<AcctSeed__Accounting_Period__c> accPeriodList = new List<AcctSeed__Accounting_Period__c>();
            List<AcctSeed__Accounting_Period__c> accPeriodNextMonthList = new List<AcctSeed__Accounting_Period__c>();
            
            if(monthStart == monthStart1 && monthEnd == monthEnd1) {
                //accPeriodList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c,AcctSeed__Status__c FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c =: monthStart AND AcctSeed__End_Date__c =: monthEnd];
                accPeriodList = AccountingPeriodService.getAccountperiodRec(new Set<Date>{monthStart},new Set<Date>{monthEnd});
                
                system.debug('::::accPeriodList::::'+accPeriodList.size());
            } else {
            
                //accPeriodList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c,AcctSeed__Status__c FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c =: monthStart AND AcctSeed__End_Date__c =: monthEnd];
                accPeriodList = AccountingPeriodService.getAccountperiodRec(new Set<Date>{monthStart},new Set<Date>{monthEnd});
                
                //accPeriodNextMonthList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c,AcctSeed__Status__c FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c =: monthStart1 AND AcctSeed__End_Date__c =: monthEnd1];
                accPeriodNextMonthList = AccountingPeriodService.getAccountperiodRec(new Set<Date>{monthStart1},new Set<Date>{monthEnd1});
                
                system.debug('::::accPeriodList::::'+accPeriodList.size());
            }
            
            if (accPeriodList == null || accPeriodList.size() == 0) {
                
                if(monthStart.month() < 10){
                    month = '0'+monthStart.month();
                }else {
                    month = String.valueOf(monthStart.month());
                }
                
                AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c();
                accPeriod.name = fromDt.year()+'-' +month;
                accPeriod.AcctSeed__Start_Date__c = monthStart;
                accPeriod.AcctSeed__End_Date__c = monthEnd;
                system.debug(':::::::::accPeriod::iggg::::'+accPeriod);
                Insert accPeriod;
                system.debug('****'+accPeriod.id);
            } 
            
            if (monthStart != monthStart1 && monthEnd != monthEnd1 && (accPeriodNextMonthList == null || accPeriodNextMonthList.size() == 0)) {
                
                if(monthStart1.month() < 10){
                    month = '0'+monthStart1.month();
                }else {
                    month = String.valueOf(monthStart1.month());
                }
                
                AcctSeed__Accounting_Period__c accPeriod1 = new AcctSeed__Accounting_Period__c();
                accPeriod1.name = fromDt.year()+'-' +month;
                accPeriod1.AcctSeed__Start_Date__c = monthStart1;
                accPeriod1.AcctSeed__End_Date__c = monthEnd1;
                system.debug(':::::::::accPeriod1::iggg::::'+accPeriod1);
                Insert accPeriod1;
                system.debug('****'+accPeriod1.id);
            }   
         
         
         //Time card Period Query
         
         /*for(AcctSeed__Time_Card_Period__c timePrd : [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Time_Card_Period__c WHERE AcctSeed__Start_Date__c = :fromDt AND AcctSeed__End_Date__c = :toDt]) {
             timeCardPeriodId = timePrd.Id;     
         }*/
         for(AcctSeed__Time_Card_Period__c timePrd :TimecardPeriodService.getTimeCardPeriodByDate(' AcctSeed__Start_Date__c = '+String.valueof(fromDt).split(' ')[0]+' AND AcctSeed__End_Date__c = '+String.valueof(toDt).split(' ')[0]+'',new Set<Date>{},new Set<Date>{})) {
             timeCardPeriodId = timePrd.Id;     
         }
         system.debug('::::::timeCardPeriodId:::::::'+timeCardPeriodId);
         
         //Time card Query
         
         /*for(AcctSeed__Time_Card__c card : [SELECT Id,AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card__c WHERE AcctSeed__Time_Card_Period__c = :timeCardPeriodId]) {
             
             timeCardId.add(card.Id);
             if(!InstrutorIdandRecordMap.containsKey(card.Intructor__c))
                 InstrutorIdandRecordMap.put(card.Intructor__c,card);
         }*/
         
         if(timeCardPeriodId != null) {
             for(AcctSeed__Time_Card__c card : TimecardService.getTimeCardByDate(' WHERE AcctSeed__Time_Card_Period__c = \''+timeCardPeriodId+'\'',new Set<Id>{},new Set<Id>{},'')) {
                 
                 timeCardId.add(card.Id);
                 if(!InstrutorIdandRecordMap.containsKey(card.Intructor__c))
                     InstrutorIdandRecordMap.put(card.Intructor__c,card);
             }
         }
         
         system.debug('::::::timeCardId::::::'+timeCardId);
         system.debug('::::::InstrutorIdandRecordMap::::::'+InstrutorIdandRecordMap);
         
         // Time Card Line Query
         
         for(AcctSeed__Time_Card_Line__c line : [SELECT Id,AcctSeed__Project_Task__c,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Billable__c,Payroll_Item__c,Location__c FROM AcctSeed__Time_Card_Line__c WHERE AcctSeed__Time_Card__c IN :timeCardId]){
              if(!InstructIdTaskIdandLineRecMap.containsKey(line.AcctSeed__Time_Card__r.Intructor__c)) {
                  InstructIdTaskIdandLineRecMap.put(line.AcctSeed__Time_Card__r.Intructor__c,new Map<String,AcctSeed__Time_Card_Line__c>{line.AcctSeed__Project_Task__c+'-'+line.AcctSeed__Billable__c+'-'+line.Payroll_Item__c+'-'+line.Location__c=>line});
              } 
              InstructIdTaskIdandLineRecMap.get(line.AcctSeed__Time_Card__r.Intructor__c).put(line.AcctSeed__Project_Task__c+'-'+line.AcctSeed__Billable__c+'-'+line.Payroll_Item__c+'-'+line.Location__c,line);  
         }
         
         system.debug(':::::::::InstructIdTaskIdandLineRecMap::::::::'+InstructIdTaskIdandLineRecMap);
         
         for(TimeCardDayDomain.TimeCardDay day : InnerClassList) {
            InstructorId.add(day.SelectedInstructor);    
         }
         
         Id usrRecId = UserInfo.getUserId();
         
         List<Contact> conRec = new List<Contact>();
        
         conRec = ContactService.getContactByparentId(' WHERE Id = \''+selectedContact+'\'','',new Set<Id>{});
         
         String firstName = conRec[0].FirstName;
         String lastName = conRec[0].LastName;
         
         String fname = '%'+firstName+'%';
         String lName = '%'+lastName+'%'; 
         
         String qry = '';
         
         // Below qry to get the contact related user record
         if(firstName != null && lastName != null) {
             qry = 'SELECT Id,Name FROM User WHERE FirstName LIKE \''+fname+'\' AND LastName LIKE \''+lName+'\'';
         } else if(lastName != null) {
             qry = 'SELECT Id,Name FROM User WHERE LastName LIKE \''+lName+'\'';
         }
         
         for(User ur : database.query(qry)) {
             if(!ContactIdUserIdMap.containsKey(selectedContact))
                 ContactIdUserIdMap.put(selectedContact,ur.Id);
         }
         
         system.debug('::::::ContactIdUserIdMap::::::'+ContactIdUserIdMap);
        
         system.debug('::::::conRec::::::::'+conRec);
        
         if(timeCardPeriodId == null) {
             
            AcctSeed__Time_Card_Period__c period = new AcctSeed__Time_Card_Period__c();
            period.name = fromDt.year()+'-' + fromDt.Month();
            period.AcctSeed__Start_Date__c = fromDt;
            period.AcctSeed__End_Date__c = toDt;
            
            insert period;  
            system.debug(':::::::::created::Period::::'+period);  
                    
            timeCardPeriodId = period.Id;
         }
         
         for(TimeCardDayDomain.TimeCardDay day : InnerClassList) {
         
             //Check If any existing Time card day record Exist
             
             if(day.Hrs1Day1Id != null || day.Hrs2Day2Id != null 
                 || day.Hrs3Day3Id != null || day.Hrs4Day4Id != null 
                 || day.Hrs5Day5Id != null || day.Hrs6Day6Id != null 
                 || day.Hrs7Day7Id != null) {
                 
                AcctSeed__Time_Card_Line__c CardlineRec = new AcctSeed__Time_Card_Line__c();
                CardlineRec.Id = day.timeCardLineId;
                CardlineRec.Comments__c = Usrcomments;
                //CardlineRec.AcctSeed__Billable__c = day.isBillable;
                
                UpdateTimeCardLineMap.put(CardlineRec.Id, CardlineRec);
                
                /*// Add the existing time card value from day record
                AcctSeed__Time_Card__c cardRec = new AcctSeed__Time_Card__c();
                cardRec.Id = day.timeCardId;
                cardRec.Comments__c = Usrcomments;
                
                if(!cardId_ForUpdate.contains(day.timeCardId)) {
                    cardUpdationList.add(cardRec);
                    cardId_ForUpdate.add(day.timeCardId);
                }*/
            }
            //system.debug(':::::::UpdateTimeCardLineMap:::::'+UpdateTimeCardLineMap);
            //system.debug(':::::cardUpdationList:::::::'+cardUpdationList);
             
             if(day.Hrs1Day1Id != null) {
                 
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay.Id = day.Hrs1Day1Id;
                timeDay.AcctSeed__Date__c = day.Day1;
                timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours1);
                timeDay.AcctSeed__Internal_Comment__c = day.comment1;
                
                //For Late Cancellation
                timeDay.Late_Cancellation__c = day.lateCancellation1;
                timeDay.Cancellation_Reason__c = day.cancellationReason1;
                
                if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                    
                    if(actionType == 'From Revert'){
                        timeDay.Status__c = 'Reverted';
                    }else {
                        timeDay.Status__c = 'Approved';
                    }
                    
                    timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                } else {
                    if(actionType == 'From Save') {
                        timeDay.Status__c = day.status1;
                    } else if(actionType == 'From Revert') {
                        timeDay.Status__c = 'Reverted';
                    }
                    
                    if(day.status1 != 'Approved' && day.status1 != 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(day.status1 == 'Approved' || day.status1 == 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    }
                        
                }
               
                if(actionType == 'From Save' && updationRecIdSet.contains(day.Hrs1Day1Id)) {
                    UpdateTimeCardDayList.add(timeDay);
                } else if(actionType == 'From Revert') {
                    UpdateTimeCardDayList.add(timeDay);
                }
                    
             }
             
             if(day.Hrs2Day2Id != null) {
                 
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay.Id = day.Hrs2Day2Id;
                timeDay.AcctSeed__Date__c = day.Day2;
                timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours2);
                timeDay.AcctSeed__Internal_Comment__c = day.comment2;
                
                //For Late Cancellation
                timeDay.Late_Cancellation__c = day.lateCancellation2;
                timeDay.Cancellation_Reason__c = day.cancellationReason2;
                
                if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')){
                    
                    if(actionType == 'From Revert'){
                        timeDay.Status__c = 'Reverted';
                    }else {
                        timeDay.Status__c = 'Approved';
                    }
                    
                    timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                } else {
                    if(actionType == 'From Save') {
                        timeDay.Status__c = day.status2;
                    }else if(actionType == 'From Revert') {
                        timeDay.Status__c = 'Reverted';
                    }
                    
                    if(day.status2 != 'Approved' && day.status2 != 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(day.status2 == 'Approved' || day.status2 == 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    }
                }
                
                if(actionType == 'From Save' && updationRecIdSet.contains(day.Hrs2Day2Id)) {
                    UpdateTimeCardDayList.add(timeDay);
                } else if(actionType == 'From Revert') {
                    UpdateTimeCardDayList.add(timeDay);
                }
                    
             }
             
             if(day.Hrs3Day3Id != null) {
                 
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay.Id = day.Hrs3Day3Id;
                timeDay.AcctSeed__Date__c = day.Day3;
                timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours3);
                timeDay.AcctSeed__Internal_Comment__c = day.comment3;
                
                //For Late Cancellation
                timeDay.Late_Cancellation__c = day.lateCancellation3;
                timeDay.Cancellation_Reason__c = day.cancellationReason3;
                
                if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                    
                    if(actionType == 'From Revert'){
                        timeDay.Status__c = 'Reverted';
                    }else {
                        timeDay.Status__c = 'Approved';
                    }
                    
                    timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                } else {
                    if(actionType == 'From Save') {
                        timeDay.Status__c = day.status3;
                    }else if(actionType == 'From Revert') {
                        timeDay.Status__c = 'Reverted';
                    }
                    
                    if(day.status3 != 'Approved' && day.status3 != 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(day.status3 == 'Approved' || day.status3 == 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    }
                }
                
                if(actionType == 'From Save' && updationRecIdSet.contains(day.Hrs3Day3Id)) {
                    UpdateTimeCardDayList.add(timeDay);
                } else if(actionType == 'From Revert') {
                    UpdateTimeCardDayList.add(timeDay);
                }
                    
             }
             
             if(day.Hrs4Day4Id != null) {
                 
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay.Id = day.Hrs4Day4Id;
                timeDay.AcctSeed__Date__c = day.Day4;
                timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours4);
                timeDay.AcctSeed__Internal_Comment__c = day.comment4;
                
                //For Late Cancellation
                timeDay.Late_Cancellation__c = day.lateCancellation4;
                timeDay.Cancellation_Reason__c = day.cancellationReason4;
                
                if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                    
                    if(actionType == 'From Revert'){
                        timeDay.Status__c = 'Reverted';
                    }else {
                        timeDay.Status__c = 'Approved';
                    }
                    
                    timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                } else {
                    if(actionType == 'From Save') {
                        timeDay.Status__c = day.status4;
                    }else if(actionType == 'From Revert') {
                        timeDay.Status__c = 'Reverted';
                    }
                    
                    if(day.status4 != 'Approved' && day.status4 != 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(day.status4 == 'Approved' || day.status4 == 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    }
                }
                    
                if(actionType == 'From Save' && updationRecIdSet.contains(day.Hrs4Day4Id)) {
                    UpdateTimeCardDayList.add(timeDay);
                } else if(actionType == 'From Revert') {
                    UpdateTimeCardDayList.add(timeDay);
                }
                    
             }
             
             if(day.Hrs5Day5Id != null) {
                 
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay.Id = day.Hrs5Day5Id;
                timeDay.AcctSeed__Date__c = day.Day5;
                timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours5);
                timeDay.AcctSeed__Internal_Comment__c = day.comment5;
                
                //For Late Cancellation
                timeDay.Late_Cancellation__c = day.lateCancellation5;
                timeDay.Cancellation_Reason__c = day.cancellationReason5;
                
                if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                    
                    if(actionType == 'From Revert'){
                        timeDay.Status__c = 'Reverted';
                    }else {
                        timeDay.Status__c = 'Approved';
                    }
                    
                    timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                } else {
                    if(actionType == 'From Save') {
                        timeDay.Status__c = day.status5;
                    }else if(actionType == 'From Revert') {
                        timeDay.Status__c = 'Reverted';
                    }
                    
                    if(day.status5 != 'Approved' && day.status5 != 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(day.status5 == 'Approved' || day.status5 == 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    }
                }
                
                if(actionType == 'From Save' && updationRecIdSet.contains(day.Hrs5Day5Id)) {
                    UpdateTimeCardDayList.add(timeDay);
                } else if(actionType == 'From Revert') {
                    UpdateTimeCardDayList.add(timeDay);
                }
             }
             
             if(day.Hrs6Day6Id != null) {
                 
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay.Id = day.Hrs6Day6Id;
                timeDay.AcctSeed__Date__c = day.Day6;
                timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours6);
                timeDay.AcctSeed__Internal_Comment__c = day.comment6;
                
                //For Late Cancellation
                timeDay.Late_Cancellation__c = day.lateCancellation6;
                timeDay.Cancellation_Reason__c = day.cancellationReason6;
                
                if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')){
                    
                    if(actionType == 'From Revert'){
                        timeDay.Status__c = 'Reverted';
                    }else {
                        timeDay.Status__c = 'Approved';
                    }
                    
                    timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                } else {
                    if(actionType == 'From Save') {
                        timeDay.Status__c = day.status6;
                    }else if(actionType == 'From Revert') {
                        timeDay.Status__c = 'Reverted';
                    }
                    
                    if(day.status6 != 'Approved' && day.status6 != 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(day.status6 == 'Approved' || day.status6 == 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    }
                }
                
                if(actionType == 'From Save' && updationRecIdSet.contains(day.Hrs6Day6Id)) {
                    UpdateTimeCardDayList.add(timeDay);
                } else if(actionType == 'From Revert') {
                    UpdateTimeCardDayList.add(timeDay);
                }
                    
             }
             
             if(day.Hrs7Day7Id != null) {
                 
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                timeDay.Id = day.Hrs7Day7Id;
                timeDay.AcctSeed__Date__c = day.Day7;
                timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours7);
                timeDay.AcctSeed__Internal_Comment__c = day.comment7;
                
                //For Late Cancellation
                timeDay.Late_Cancellation__c = day.lateCancellation7;
                timeDay.Cancellation_Reason__c = day.cancellationReason7;
                
                if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                    
                    if(actionType == 'From Revert'){
                        timeDay.Status__c = 'Reverted';
                    }else {
                        timeDay.Status__c = 'Approved';
                    }
                    
                    timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                } else {
                    if(actionType == 'From Save') {
                        timeDay.Status__c = day.status7;
                    }else if(actionType == 'From Revert') {
                        timeDay.Status__c = 'Reverted';
                    }
                    
                    if(day.status7 != 'Approved' && day.status7 != 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = 0;
                    } else if(day.status7 == 'Approved' || day.status7 == 'Admin Approved') {
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    }
                }
                    
                if(actionType == 'From Save' && updationRecIdSet.contains(day.Hrs7Day7Id)) {
                    UpdateTimeCardDayList.add(timeDay);
                } else if(actionType == 'From Revert') {
                    UpdateTimeCardDayList.add(timeDay);
                }
                    
             }
             
             // Check alerady Time card Exist
             if(InstrutorIdandRecordMap.containsKey(day.SelectedInstructor) 
                 && InstrutorIdandRecordMap.get(day.SelectedInstructor) != null 
                 && InstrutorIdandRecordMap.get(day.SelectedInstructor).AcctSeed__Time_Card_Period__c == timeCardPeriodId) {
                 
                 AcctSeed__Time_Card__c cardRec = InstrutorIdandRecordMap.get(day.SelectedInstructor);
                 
                 if(InstructIdTaskIdandLineRecMap.containsKey(cardRec.Intructor__c) 
                     && InstructIdTaskIdandLineRecMap.get(cardRec.Intructor__c).containsKey(day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId)
                   ) {
                     
                     AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                     AcctSeed__Time_Card_Line__c lineRec = InstructIdTaskIdandLineRecMap.get(cardRec.Intructor__c).get(day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId);
                     
                     
                     if(String.isNotBlank(day.Hours1) && day.Hrs1Day1Id == null) {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay.AcctSeed__Date__c = day.Day1;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours1);
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        timeDay.AcctSeed__Internal_Comment__c = day.comment1;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status1;
                            }else if(actionType == 'From Revert') {
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status1 != 'Approved' && day.status1 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status1 == 'Approved' || day.status1 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
                        }
                        
                        timeCardDayCreationList.add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours2) && day.Hrs2Day2Id == null) {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay.AcctSeed__Date__c = day.Day2;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours2);
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        timeDay.AcctSeed__Internal_Comment__c = day.comment2;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status2;
                            }else if(actionType == 'From Revert') {
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status2 != 'Approved' && day.status2 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status2 == 'Approved' || day.status2 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
                        }
                        
                        timeCardDayCreationList.add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours3) && day.Hrs3Day3Id == null) {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay.AcctSeed__Date__c = day.Day3;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours3);
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        timeDay.AcctSeed__Internal_Comment__c = day.comment3;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status3;
                            }else if(actionType == 'From Revert') {
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status3 != 'Approved' && day.status3 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status3 == 'Approved' || day.status3 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
                        }
                        
                        timeCardDayCreationList.add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours4) && day.Hrs4Day4Id == null) {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay.AcctSeed__Date__c = day.Day4;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours4);
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        timeDay.AcctSeed__Internal_Comment__c = day.comment4;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status4;
                            }else if(actionType == 'From Revert'){
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status4 != 'Approved' && day.status4 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status4 == 'Approved' || day.status4 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
                        }
                        
                        timeCardDayCreationList.add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours5) && day.Hrs5Day5Id == null) {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay.AcctSeed__Date__c = day.Day5;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours5);
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        timeDay.AcctSeed__Internal_Comment__c = day.comment5;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status5;
                            }else if(actionType == 'From Revert') {
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status5 != 'Approved' && day.status5 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status5 == 'Approved' || day.status5 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
                        }
                        
                        timeCardDayCreationList.add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours6) && day.Hrs6Day6Id == null) {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay.AcctSeed__Date__c = day.Day6;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours6);
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        timeDay.AcctSeed__Internal_Comment__c = day.comment6;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status6;
                            }else if(actionType == 'From Revert') {
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status6 != 'Approved' && day.status6 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status6 == 'Approved' || day.status6 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
                        }
                        
                        timeCardDayCreationList.add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours7) && day.Hrs7Day7Id == null) {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay.AcctSeed__Date__c = day.Day7;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours7);
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                        timeDay.AcctSeed__Internal_Comment__c = day.comment7;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status7;
                            }else if(actionType == 'From Revert') {
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status7 != 'Approved' && day.status7 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status7 == 'Approved' || day.status7 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
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
                    line.Comments__c = Usrcomments;
                    
                    timeLineCreation.add(line);
                    
                    // Time card Day Map formation
        
                    if(!InstIdTaskIdStringDayLsitMap.containsKey(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.payRollItem+'-'+day.locationId)) {
                        InstIdTaskIdStringDayLsitMap.put(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId,new List<AcctSeed__Time_Card_Day__c>());
                    }
                    
                    AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                    
                    if(String.isNotBlank(day.Hours1) && day.Hrs1Day1Id == null) {
                        
                        timeDay.AcctSeed__Date__c = day.Day1;
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours1);
                        timeDay.AcctSeed__Internal_Comment__c = day.comment1;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status1;
                            }else if(actionType == 'From Revert') {
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status1 != 'Approved' && day.status1 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status1 == 'Approved' || day.status1 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
                        }
                        
                        InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);
                    }
                    
                    if(String.isNotBlank(day.Hours2) && day.Hrs2Day2Id == null) {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay.AcctSeed__Date__c = day.Day2;
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours2);
                        timeDay.AcctSeed__Internal_Comment__c = day.comment2;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status2;
                            }else if(actionType == 'From Revert') {
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status2 != 'Approved' && day.status2 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status2 == 'Approved' || day.status2 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
                        }
                        
                        InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                    }
                    
                    if(String.isNotBlank(day.Hours3) && day.Hrs3Day3Id == null) {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay.AcctSeed__Date__c = day.Day3;
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours3);
                        timeDay.AcctSeed__Internal_Comment__c = day.comment3;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status3;
                            }else if(actionType == 'From Revert') {
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status3 != 'Approved' && day.status3 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status3 == 'Approved' || day.status3 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
                        }
                        
                        InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                    }
                    
                    if(String.isNotBlank(day.Hours4) && day.Hrs4Day4Id == null) {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay.AcctSeed__Date__c = day.Day4;
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours4);
                        timeDay.AcctSeed__Internal_Comment__c = day.comment4;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status4;
                            }else if(actionType == 'From Revert') {
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status4 != 'Approved' && day.status4 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status4 == 'Approved' || day.status4 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
                        }
                        
                        InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                    }
                    
                    if(String.isNotBlank(day.Hours5) && day.Hrs5Day5Id == null) {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay.AcctSeed__Date__c = day.Day5;
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours5);
                        timeDay.AcctSeed__Internal_Comment__c = day.comment5;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status5;
                            }else if(actionType == 'From Revert') {
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status5 != 'Approved' && day.status5 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status5 == 'Approved' || day.status5 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
                        }
                        
                        InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                    }
                    
                    if(String.isNotBlank(day.Hours6) && day.Hrs6Day6Id == null) {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay.AcctSeed__Date__c = day.Day6;
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours6);
                        timeDay.AcctSeed__Internal_Comment__c = day.comment6;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status6;
                            }else if(actionType == 'From Revert') {
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status6 != 'Approved' && day.status6 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status6 == 'Approved' || day.status6 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
                        }
                        
                        InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                    }
                    
                    if(String.isNotBlank(day.Hours7) && day.Hrs7Day7Id == null) {
                        timeDay = new AcctSeed__Time_Card_Day__c();
                        timeDay.AcctSeed__Date__c = day.Day7;
                        //timeDay.AcctSeed__Hours__c = 0;
                        timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours7);
                        timeDay.AcctSeed__Internal_Comment__c = day.comment7;
                        timeDay.Labor_Cost_Rate__c = day.costRateId;
                        
                        if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                            timeDay.Status__c = 'Approved';
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        } else {
                            if(actionType == 'From Save') {
                                timeDay.Status__c = day.status7;
                            }else if(actionType == 'From Revert') {
                                timeDay.Status__c = 'Reverted';
                            }
                            
                            if(day.status7 != 'Approved' && day.status7 != 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = 0;
                            } else if(day.status7 == 'Approved' || day.status7 == 'Admin Approved') {
                                timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                            }
                        }
                        
                        InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                    }
                     //End of 2nd if's else
                 }
             //End of 1st if
             }else {// Create a Time Card for the instructor,Time Card Line and Time Card Day
             
                 // Time card creation formation
                 
                 // In this first if ContactIdUSerIdMap is not used - for single contact use
                
                if(!InsIdForRefer.contains(day.SelectedInstructor) && ContactIdUserIdMap.containsKey(day.SelectedInstructor)) {
                    
                    AcctSeed__Time_Card__c card = new AcctSeed__Time_Card__c();
                    card.AcctSeed__Employee__c = ContactIdUserIdMap.get(day.SelectedInstructor);
                    card.Intructor__c = day.SelectedInstructor;
                    card.AcctSeed__Time_Card_Period__c = timeCardPeriodId;
                    card.Comments__c = Usrcomments;
                    
                    cardCreation.add(card);
                    InsIdForRefer.add(day.SelectedInstructor);
                }
                
                // Time card Line Map formation
                
                AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                line.AcctSeed__Project_Task__c = day.SelectedProTask;
                line.AcctSeed__Project__c = day.SelectedProject;
                line.AcctSeed__Billable__c = day.isBillable;
                line.Payroll_Item__c = day.payRollItem;
                line.Location__c = day.locationId;
                line.Display_in_Future_Weeks__c = true;
                //line.Labor_Cost_Rate__c = day.costRateId;
                line.Contact_Assignment__c = day.contactAssignId;
                line.Sequence_Number__c = day.sequenceNumber;
                line.Comments__c = Usrcomments;
                
                if(!InstructorIdLineListMap.containsKey(day.SelectedInstructor)) {
                    InstructorIdLineListMap.put(day.SelectedInstructor,new List<AcctSeed__Time_Card_Line__c>());
                }
                InstructorIdLineListMap.get(day.SelectedInstructor).add(line);
                
                // Time card Day Map formation
                
                if(!InstIdTaskIdStringDayLsitMap.containsKey(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId)) {
                    InstIdTaskIdStringDayLsitMap.put(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId,new List<AcctSeed__Time_Card_Day__c>());
                }
                
                AcctSeed__Time_Card_Day__c timeDay = new AcctSeed__Time_Card_Day__c();
                
                if(String.isNotBlank(day.Hours1) && day.Hrs1Day1Id == null) {
                    
                    timeDay.AcctSeed__Date__c = day.Day1;
                    //timeDay.AcctSeed__Hours__c = 0;
                    timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours1);
                    timeDay.AcctSeed__Internal_Comment__c = day.comment1;
                    timeDay.Labor_Cost_Rate__c = day.costRateId;
                    
                    if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                        timeDay.Status__c = 'Approved';
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    } else {
                        if(actionType == 'From Save') {
                            timeDay.Status__c = day.status1;
                        }else if(actionType == 'From Revert') {
                            timeDay.Status__c = 'Reverted';
                        }
                        
                        if(day.status1 != 'Approved' && day.status1 != 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(day.status1 == 'Approved' || day.status1 == 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        }
                    }
                    
                    InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);
                }
                
                if(String.isNotBlank(day.Hours2) && day.Hrs2Day2Id == null) {
                    timeDay = new AcctSeed__Time_Card_Day__c();
                    timeDay.AcctSeed__Date__c = day.Day2;
                    //timeDay.AcctSeed__Hours__c = 0;
                    timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours2);
                    timeDay.AcctSeed__Internal_Comment__c = day.comment2;
                    timeDay.Labor_Cost_Rate__c = day.costRateId;
                    
                    if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                        timeDay.Status__c = 'Approved';
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    } else {
                        if(actionType == 'From Save') {
                            timeDay.Status__c = day.status2;
                        }else if(actionType == 'From Revert') {
                            timeDay.Status__c = 'Reverted';
                        }
                        
                        if(day.status2 != 'Approved' && day.status2 != 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(day.status2 == 'Approved' || day.status2 == 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        }
                    }
                    
                    InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                }
                
                if(String.isNotBlank(day.Hours3) && day.Hrs3Day3Id == null) {
                    timeDay = new AcctSeed__Time_Card_Day__c();
                    timeDay.AcctSeed__Date__c = day.Day3;
                    //timeDay.AcctSeed__Hours__c = 0;
                    timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours3);
                    timeDay.AcctSeed__Internal_Comment__c = day.comment3;
                    timeDay.Labor_Cost_Rate__c = day.costRateId;
                    
                    if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                        timeDay.Status__c = 'Approved';
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    } else {
                        if(actionType == 'From Save') {
                            timeDay.Status__c = day.status3;
                        }else if(actionType == 'From Save') {
                            timeDay.Status__c = 'Reverted';
                        }
                        
                        if(day.status3 != 'Approved' && day.status3 != 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(day.status3 == 'Approved' || day.status3 == 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        }
                    }
                    
                    InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                }
                
                if(String.isNotBlank(day.Hours4) && day.Hrs4Day4Id == null) {
                    timeDay = new AcctSeed__Time_Card_Day__c();
                    timeDay.AcctSeed__Date__c = day.Day4;
                    //timeDay.AcctSeed__Hours__c = 0;
                    timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours4);
                    timeDay.AcctSeed__Internal_Comment__c = day.comment4;
                    timeDay.Labor_Cost_Rate__c = day.costRateId;
                    
                    if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                        timeDay.Status__c = 'Approved';
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    } else {
                        if(actionType == 'From Save') {
                            timeDay.Status__c = day.status4;
                        }else if(actionType == 'From Revert'){
                            timeDay.Status__c = 'Reverted';
                        }
                        
                        if(day.status4 != 'Approved' && day.status4 != 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(day.status4 == 'Approved' || day.status4 == 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        }
                    }
                    
                    InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                }
                
                if(String.isNotBlank(day.Hours5) && day.Hrs5Day5Id == null) {
                    timeDay = new AcctSeed__Time_Card_Day__c();
                    timeDay.AcctSeed__Date__c = day.Day5;
                    //timeDay.AcctSeed__Hours__c = 0;
                    timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours5);
                    timeDay.AcctSeed__Internal_Comment__c = day.comment5;
                    timeDay.Labor_Cost_Rate__c = day.costRateId;
                    
                    if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                        timeDay.Status__c = 'Approved';
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    } else {
                        if(actionType == 'From Save') {
                            timeDay.Status__c = day.status5;
                        }else if(actionType == 'From Revert') {
                            timeDay.Status__c = 'Reverted';
                        }
                        
                        if(day.status5 != 'Approved' && day.status5 != 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(day.status5 == 'Approved' || day.status5 == 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        }
                    }
                    
                    InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                }
                
                if(String.isNotBlank(day.Hours6) && day.Hrs6Day6Id == null) {
                    timeDay = new AcctSeed__Time_Card_Day__c();
                    timeDay.AcctSeed__Date__c = day.Day6;
                    //timeDay.AcctSeed__Hours__c = 0;
                    timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours6);
                    timeDay.AcctSeed__Internal_Comment__c = day.comment6;
                    timeDay.Labor_Cost_Rate__c = day.costRateId;
                    
                    if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                        timeDay.Status__c = 'Approved';
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    } else {
                        if(actionType == 'From Save') {
                            timeDay.Status__c = day.status6;
                        }else if(actionType == 'From Revert') {
                            timeDay.Status__c = 'Reverted';
                        }
                        
                        if(day.status6 != 'Approved' && day.status6 != 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(day.status6 == 'Approved' || day.status6 == 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        }
                    }
                        
                    InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                }
                
                if(String.isNotBlank(day.Hours7) && day.Hrs7Day7Id == null) {
                    timeDay = new AcctSeed__Time_Card_Day__c();
                    timeDay.AcctSeed__Date__c = day.Day7;
                    //timeDay.AcctSeed__Hours__c = 0;
                    timeDay.Total_Hours_Before_Approved__c = Decimal.ValueOf(day.Hours7);
                    timeDay.AcctSeed__Internal_Comment__c = day.comment7;
                    timeDay.Labor_Cost_Rate__c = day.costRateId;
                    
                    if(day.TaskType == 'Fringe' && day.TaskName.contains('Bonus Leave Taken')) {
                        timeDay.Status__c = 'Approved';
                        timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                    } else {
                        if(actionType == 'From Save') {
                            timeDay.Status__c = day.status7;
                        }else if(actionType == 'From Revert') {
                            timeDay.Status__c = 'Reverted';
                        }
                        
                        if(day.status7 != 'Approved' && day.status7 != 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = 0;
                        } else if(day.status7 == 'Approved' || day.status7 == 'Admin Approved') {
                            timeDay.AcctSeed__Hours__c = timeDay.Total_Hours_Before_Approved__c;
                        }
                    }
                    
                    InstIdTaskIdStringDayLsitMap.get(day.SelectedInstructor+'-'+day.SelectedProTask+'-'+day.isBillable+'-'+day.payRollItem+'-'+day.locationId).add(timeDay);    
                }
                
             }//End of 1st If's else
         
         }// End of Inner class For Loop
         
         system.debug(':::::::::::UpdateTimeCardDayList::::::::::'+UpdateTimeCardDayList);
         system.debug('::::::cardCreation::::::::'+cardCreation);
         system.debug('::::::timeLineCreation::::::::'+timeLineCreation);
         system.debug('::::::::timeCardDayCreationList:::::::::'+timeCardDayCreationList);
         system.debug(':::InstructorIdLineListMap::::::::::'+InstructorIdLineListMap);
         system.debug('::::::InstIdTaskIdStringDayLsitMap::::::'+InstIdTaskIdStringDayLsitMap);
         //system.debug('::::UpdateTimeCardLineList:::::::::'+UpdateTimeCardLineList);
         
         if(cardCreation.size() > 0) {
            insert cardCreation;
            
            for(AcctSeed__Time_Card__c timeCard : cardCreation) {
            
                if(InstructorIdLineListMap.containsKey(timeCard.Intructor__c)) {
                
                    for(AcctSeed__Time_Card_Line__c timeLine : InstructorIdLineListMap.get(timeCard.Intructor__c)) {
                        
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
                if(!InsIdStringTimeLineMap.containsKey(lineRec.AcctSeed__Time_Card__r.Intructor__c)) {
                    InsIdStringTimeLineMap.put(lineRec.AcctSeed__Time_Card__r.Intructor__c,new Map<String,AcctSeed__Time_Card_Line__c>{lineRec.AcctSeed__Project_Task__c+'-'+lineRec.AcctSeed__Billable__c+'-'+lineRec.Payroll_Item__c+'-'+lineRec.Location__c=>lineRec});
                }
                InsIdStringTimeLineMap.get(lineRec.AcctSeed__Time_Card__r.Intructor__c).put(lineRec.AcctSeed__Project_Task__c+'-'+lineRec.AcctSeed__Billable__c+'-'+lineRec.Payroll_Item__c+'-'+lineRec.Location__c,lineRec);
            }
            system.debug('::::::InsIdStringTimeLineMap:::::::'+InsIdStringTimeLineMap);
            
            for(String InsIdTaskId : InstIdTaskIdStringDayLsitMap.keySet()) {
                
                String InsId = InsIdTaskId.split('-')[0];
                String TaskId = InsIdTaskId.split('-')[1];
                Boolean billValue = Boolean.valueOf(InsIdTaskId.split('-')[2]);
                String payRollItemList = InsIdTaskId.split('-')[3];
                String locationId = InsIdTaskId.split('-')[4];
                
                for(AcctSeed__Time_Card_Day__c timeCardDay : InstIdTaskIdStringDayLsitMap.get(InsIdTaskId)) {
                    
                    if(InsIdStringTimeLineMap.containsKey(InsId)) {
                        
                        if(InsIdStringTimeLineMap.get(InsId).containsKey(TaskId+'-'+billValue+'-'+payRollItemList+'-'+locationId)) {
                            
                            AcctSeed__Time_Card_Line__c timeLineRec = InsIdStringTimeLineMap.get(InsId).get(TaskId+'-'+billValue+'-'+payRollItemList+'-'+locationId);
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
        
        /*// Update the time card comments field values
        // Added by NS on May 8 2017 - For Revert & Save action user's reason update in time card
        if(cardUpdationList.size() > 0) {
            update cardUpdationList;
        }*/
        
        /*// Update time card line with billable values
        if(UpdateTimeCardLineList.size() > 0) {
            system.debug('::::::enter::line :Update::');
            //update UpdateTimeCardLineList;
        }*/
        if(UpdateTimeCardLineMap.size() > 0){
            update UpdateTimeCardLineMap.values();
        }
        
        system.debug(':::::::UpdateTimeCardDayList::::::'+UpdateTimeCardDayList);
        
        if(UpdateTimeCardDayList.size() > 0) {
           update UpdateTimeCardDayList;
           
           // add updated time card days which have "Reverted" status
           if(updationRecIdSet.size() > 0) {
                for(AcctSeed__Time_Card_Day__c dayRec : UpdateTimeCardDayList) {
                   if(dayRec.Status__c == 'Reverted')
                       wholeRecordEmaillList.add(dayRec);
                       
                   // Added modifed record from Admin page  
                   modifiedRecordList.add(dayRec);
               }
           }else {
               for(AcctSeed__Time_Card_Day__c dayRec : UpdateTimeCardDayList) {
                   if(dayRec.Status__c == 'Reverted')
                       wholeRecordEmaillList.add(dayRec);
                   
                   // Added modifed record from Admin page  
                   modifiedRecordList.add(dayRec);
               }
           }
           
        }
        system.debug('::::::modifiedRecordList::::::'+modifiedRecordList);
        system.debug('::::::wholeRecordEmaillList::::::'+wholeRecordEmaillList);
        system.debug(':::::timeCardDayCreationList:::::::'+timeCardDayCreationList);
            
        if(timeCardDayCreationList.size() > 0) {
            //insert timeCardDayCreationList;
           
           //Update the existing unposted time card day records with new values
           
           Database.SaveResult[] srList = Database.insert(timeCardDayCreationList, false);
           system.debug(':::::srList:insert:::::'+srList);
           
           Map<String,Map<Date,AcctSeed__Time_Card_Day__c>> lineName_Date_DayRecMap = new Map<String,Map<Date,AcctSeed__Time_Card_Day__c>>();
           List<AcctSeed__Time_Card_Day__c> dayUpdationList = new List<AcctSeed__Time_Card_Day__c>();
           
           for (Database.SaveResult sr : srList) {
               system.debug(':::::::sr::::::'+sr);
               
               if(sr.isSuccess()) {
                    AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c();
                    day.Id = sr.getId();
                    
                    // Added to email list
                    wholeRecordEmaillList.add(day);
                    
                    // Added modifed record from Admin page  
                   modifiedRecordList.add(day);
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
                        
                        if(newDay.Status__c == 'Approved' || newDay.Status__c == 'Admin Approved')
                            dayVal.AcctSeed__Hours__c = newDay.Total_Hours_Before_Approved__c;
                        
                        dayUpdationList.add(dayVal);
                    }
                }
            }
            
            system.debug(':::::::::dayUpdationList:::::'+dayUpdationList);
            
            if(dayUpdationList.size() > 0) {
                update dayUpdationList;
                
                // add updated time card days which have "Reverted" status
               if(updationRecIdSet.size() > 0) {
                    for(AcctSeed__Time_Card_Day__c dayRec : dayUpdationList) {
                       if(dayRec.Status__c == 'Reverted')
                           wholeRecordEmaillList.add(dayRec);
                           
                       // Added modifed record from Admin page  
                       modifiedRecordList.add(dayRec);
                   }
               }
            }
        }
        
        // Email send method calling
        if(wholeRecordEmaillList.size() > 0 && actionType == 'From Revert') {
                
            Set<Id> revertedDayIds = new Set<Id>();
            for(AcctSeed__Time_Card_Day__c day : wholeRecordEmaillList) {
                revertedDayIds.add(day.Id);
            }
            
            if(revertedDayIds.size() > 0) {
                try {
                    timeCardRelated_Email_Controller.adminModification_Notifications(revertedDayIds,'Revert Action');
                }catch(Exception e){
                    system.debug('::::Error:::on revert::action:::Mail::admin::time::entry::::'+e.getMessage());
                }
            }
        }
        
        system.debug('::::::modifiedRecordList::::::'+modifiedRecordList);
        
        // Admin Modification notification to Employee & theri Supervisor
        if(modifiedRecordList.size() > 0 && actionType == 'From Save'){
            Set<Id> modifiedRecIds = new Set<Id>();
            
            for(AcctSeed__Time_Card_Day__c day : modifiedRecordList){
                modifiedRecIds.add(day.Id);
            }
            
            if(modifiedRecIds.size() > 0) {
                try {
                    timeCardRelated_Email_Controller.adminModification_Notifications(modifiedRecIds,'Save Action');
                }catch(Exception e) {
                    system.debug('::::Error:::on::save::action::Mail:::admin::time::entry:::'+e.getMessage());
                }
            }
        } 
        
     }
     
     
    @RemoteAction
    global static List<sObject> getLookupRecords(String objectName, String searchString, String condition) {
        
        system.debug('::::::::::objectName::::::::::'+objectName);
        system.debug('::::::::::searchString::::::::::'+searchString);
        system.debug('::::::::::condition::::::::::'+condition);
        
        List<sObject> lookupRecords = new List<sObject>();
        String query = 'SELECT Id, Name FROM ' + objectName;
        if(searchString != null && searchString != '') {
            query += ' WHERE Name LIKE \'%' + searchString + '%\'';
        }
        if(condition != null && condition != '') {
            if(searchString != null && searchString != '') {
                query += ' AND ' + condition;
            } else {
                query += ' WHERE ' + condition;
            }
        }
        query += ' LIMIT 10';
        System.debug('query log ' + query);
        
        if(objectName != 'Account' && objectName != 'Contact') {
            lookupRecords = Database.query(query);
        }else {
            String searchQry = 'FIND {'+searchString+'} IN NAME Fields Returning '+objectName+' (Id,Name';
    
            if(condition != null && condition != '') {
                searchQry = searchQry + ' WHERE '+condition+')';
            }else {
                searchQry = searchQry + ')';
            }
            
            searchQry += ' LIMIT 10';
            
            if(searchString != null) {
                lookupRecords = search.query(searchQry)[0];
            }
        }
        
        return lookupRecords;
    }
    
    // Qry contact related user record with selected contact
    @RemoteAction
    global static Boolean getContactRelatedUser(String conId) {
        
        Boolean alreadyUsrExist = false;
        
        List<Contact> conList = [SELECT Id,FirstName,LastName,Email FROM Contact WHERE Id = :conId];
        
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

}