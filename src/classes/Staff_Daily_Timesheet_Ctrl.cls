/*****************************************************
    - Created by Sukanya on Feb 21 2018
    - For Staff Daily time entry page controller
    - Different wrapper class formation for Mobile UI
******************************************************/
public without sharing class Staff_Daily_Timesheet_Ctrl {
    
    // For submit & recall process identification
    public static Boolean isGroupAction;
    public static String groupActionType;
    
    /**********************************************************************
        Created by Sukanya on Feb 21 2018: Domain class used for Staff_Daily_Timesheet_Ctrl- Mobile view common information for all weeks
    ***********************************************************************/
    
    @AuraEnabled
    public static String getInitialInformation() {
    
        Date today = system.today();
        Date currst = today.toStartofWeek().addDays(1);
        Date currend = currst.addDays(6);
        
        Date stDate = currst.addDays(-28);
        Date endDate = currend.addDays(28);
             
        Set<String> weekRangeSet = new Set<String>();
        Set<Date> wholeDateSet = new Set<Date>();
        
        while(stDate <= endDate) {
            wholeDateSet.add(stDate);
            stDate = stDate.addDays(1);
        }
        system.debug(':::wholeDateSet::::::'+wholeDateSet);
        
        // Get Week ranges for all the above date values
        for(Date dt : wholeDateSet) {
         
            Date st;
            if(dt.toStartofWeek().addDays(1) < dt) {
                 st = dt.toStartofWeek().addDays(1);
            } else {
                 st = dt.addDays(-1).toStartofWeek().addDays(1);
            }
            
            Date ed = st.addDays(6); 
            
            String stVal = String.valueOf(st).split(' ')[0];
            String endVal = String.valueOf(ed).split(' ')[0];
            String stFinal = stVal.split('-')[1]+'/'+stVal.split('-')[2]+'/'+stVal.split('-')[0];
            String endFinal = endVal.split('-')[1]+'/'+endVal.split('-')[2]+'/'+endVal.split('-')[0];
            
            if(!weekRangeSet.contains(stFinal+' - '+endFinal)) {
                weekRangeSet.add(stFinal+' - '+endFinal);
            }
        }
        system.debug('::::::::weekRangeSet:::::::'+weekRangeSet);
        
        Id usrId = UserInfo.getUserId();
        String firstName = UserInfo.getFirstName();
        String lastName = UserInfo.getLastName();
        
        String fname = firstName != null ? '%'+String.escapeSingleQuotes(firstName)+'%' : null;
        String lName = lastName != null ? '%'+String.escapeSingleQuotes(lastName)+'%' : null;
        
        List<Contact_Assignments__c> relatedConAssign = new List<Contact_Assignments__c>();
        List<Contact> conRecList = new List<Contact>();
        List<AcctSeed__Project_Task__c> projectTaskList = new List<AcctSeed__Project_Task__c>();
        List<AcctSeed__Project__c> projectList = new List<AcctSeed__Project__c>();
        Set<Id> projectId = new Set<Id>();
        // Separate set for filtering projects on new row adding functionality
        Set<Id> filteredProjectId = new Set<Id>();
        
        //Qry User record to get the Email address to get the exact match for the user in contact level
        List<User> usrRec = [SELECT Id,Name,Email FROM User WHERE Id = :usrId];
         
        if(firstName != null && lastName != null) {                  
            conRecList = ContactService.getContactByName(' WHERE Email = \''+usrRec[0].Email+'\' AND FirstName LIKE \''+fname+'\' AND LastName LIKE \''+lName+'\'',',Home_Department_Project__r.Name,Supervisor_Name__r.Name,Supervisor_Name__r.ManagerId,Supervisor_Name__r.Manager.Name,RecordType.DeveloperName',new Set<String>{},'');
        } else if(lastName != null) {
            conRecList = ContactService.getContactByName(' WHERE Email = \''+usrRec[0].Email+'\' AND LastName LIKE \''+lName+'\'',',Home_Department_Project__r.Name,Supervisor_Name__r.Name,Supervisor_Name__r.ManagerId,Supervisor_Name__r.Manager.Name,RecordType.DeveloperName',new Set<String>{},'');
        }
        system.debug('::::::conRecList::::'+conRecList);
        
        
        if(conRecList != null && conRecList.size() > 0) {
            String parentFields = 'Candidate_Name__r.Home_Dept__c,Candidate_Name__r.Home_Department_Project__c,Candidate_Name__r.Home_Department_Project__r.Name,Candidate_Name__r.Name,'+
                                   'Candidate_Name__r.Supervisor_Name__c,Candidate_Name__r.Supervisor_Name__r.Name,Candidate_Name__r.Supervisor_Name__r.ManagerId,Candidate_Name__r.Supervisor_Name__r.Manager.Name,'+
                                     'Project__r.Name,Rate_Card_Rate__r.Name,Project__r.RecordType.DeveloperName,Rate_Card_Rate__r.Payroll_Item__c,Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Rate_Card_Rate__r.Rate_Type__c,RecordType.DeveloperName';
                                     
            String condition = ' WHERE RecordType.DeveloperName IN (\'Staff\',\'Instructor\') AND Project__c != null AND Candidate_Name__c = \''+conRecList[0].Id+'\'';
             
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
        
         if(conRecList != null && conRecList.size() > 0) {
             
             for(AcctSeed__Project_Task__c task : ProjectTaskService.getProjectTaskByInnerQueryOnTimeCardLineDetails(',AcctSeed__Project__r.Name,AcctSeed__Project__r.RecordType.DeveloperName',projectId,null,null,conRecList[0].Id)) {
                 projectTaskList.add(task);
             }
         }
         
         system.debug(':::::::projectTaskList::::::::'+projectTaskList);
         
         projectList = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',filteredProjectId,',Training_Location__r.Name,RecordType.DeveloperName');
         
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
         holidayDateSet = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
         
         system.debug('::::::::::holidayDateSet:::::::::'+holidayDateSet);
         
        List<Project_Task_Master__c> ptmValues = [SELECT Id,Name,Billable__c,Display_In_Time_Card__c,Labor_GL_Account__c,
                                                     Payroll_Item__c,Project_Record_Type__c,Project_Task_Record_Type__c,Project_Task_Type__c,
                                                     Project_Type__c,Unit__c 
                                                 FROM Project_Task_Master__c
                                                 WHERE (Project_Record_Type__c = 'Admin_Projects' OR Project_Record_Type__c = 'Admin_Projects;EFL_Projects;CD_Projects' OR Project_Record_Type__c = 'Admin_Projects;CD_Projects' 
                                                     OR Project_Record_Type__c = 'EFL_Projects' OR Project_Record_Type__c = 'Admin_Projects;CD_Projects;Linguist_Support_Projects')];
                                                
        system.debug('::::::ptmValues::::::'+ptmValues);
        
        List<MTT_Location__c> locationList = [SELECT Id,Name FROM MTT_Location__c];
        
        // Qry "Timekeeping Training Presentation" & "Timekeeping Policies & Procedures" documents
        System_Values__c sysValDoc = System_Values__c.getValues('Timekeeping Document Names');    
        Set<String> docName = new Set<String>();
        if (sysValDoc != null && sysValDoc.Value__c != null) {
            docName.add(sysValDoc.Value__c.split(',')[0].trim());
            docName.add(sysValDoc.Value__c.split(',')[1].trim());
        }
        
        List<ContentDocument> documentList = new List<ContentDocument>();
        documentList = [SELECT Id,Title FROM ContentDocument WHERE Title IN :docName];
        system.debug('::::::::documentList:::::'+documentList);
        
        TimeCardDayDomain.dailyInitialInfo dailyInfo = new TimeCardDayDomain.dailyInitialInfo();
        dailyInfo = TimeCardDayTranslator.Daily_InitialData(weekRangeSet,lockingDate,conRecList,new List<Date>(holidayDateSet),ptmValues,documentList);
        system.debug('::::::::::dailyInfo::::::'+dailyInfo);
        return JSON.serialize(dailyInfo);
    }
    
    /**********************************************************************
        Created by Sukanya on Feb 22 2018: Domain class used for Staff_Daily_Timesheet_Ctrl- Mobile view weekly view info formation
    ***********************************************************************/
    @AuraEnabled
    public static String specificWeekInformation(String startDt, String endDt,Id contactId) {
        
        system.debug('::::startDt:::::::endDt:::::'+startDt+','+endDt);
        
        Set<Id> projectId = new Set<Id>();
        Set<Id> timeLineIdSet = new Set<Id>();
        List<AcctSeed__Project__c> projectList = new List<AcctSeed__Project__c>();
        List<AcctSeed__Project_Task__c> taskList = new List<AcctSeed__Project_Task__c>();
        List<Contact_Assignments__c> conAssign = new List<Contact_Assignments__c>();
        List<AcctSeed__Time_Card_Line__c> previousWeekLines = new List<AcctSeed__Time_Card_Line__c>();
        List<Project_Task_Master__c> ptmValues = new List<Project_Task_Master__c>();
        Set<Id> previousWeekLineId = new Set<Id>();
        Set<Id> filteredProjectId = new Set<Id>();
        
        List<Accounting_Seed_Time_Snapshot__c> accTimesnapshot = new List<Accounting_Seed_Time_Snapshot__c>();
        
        Date previousStart = Date.valueOf(startDt).addDays(-7);
        Date previousEnd = Date.valueOf(endDt).addDays(-7);
        
        //Thie date condition to filter the Projects based on the CA End Date values
        String caFilterDate = String.valueOf(Date.valueOf(startDt).addDays(-14)).split(' ')[0];
        
        String parentFields = 'Candidate_Name__r.Home_Dept__c,Candidate_Name__r.Home_Department_Project__c,Candidate_Name__r.Home_Department_Project__r.Name,Candidate_Name__r.Name,'+
                               'Candidate_Name__r.Supervisor_Name__c,Candidate_Name__r.Supervisor_Name__r.Name,Candidate_Name__r.Supervisor_Name__r.ManagerId,Candidate_Name__r.Supervisor_Name__r.Manager.Name,'+
                                 'Project__r.Name,Rate_Card_Rate__r.Name,Project__r.RecordType.DeveloperName,Rate_Card_Rate__r.Payroll_Item__c,Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Rate_Card_Rate__r.Rate_Type__c,RecordType.DeveloperName';
                                 
        String condition = ' WHERE RecordType.DeveloperName IN (\'Staff\',\'Instructor\') AND (Status__c = \'Active\' OR (Status__c = \'Ended\' AND End_Date__c >= '+caFilterDate+')) AND Project__c != null AND Candidate_Name__c = \''+contactId+'\'';
        
        for(Contact_Assignments__c assign : ContactAssignmentService.getContactassignmentRec(condition,parentFields)) {
            projectId.add(assign.Project__c);
            if(assign.Project__c == assign.Candidate_Name__r.Home_Department_Project__c || assign.Project__r.RecordType.DeveloperName == 'Admin_Projects' 
                 || assign.RecordType.DeveloperName == 'Instructor' 
                 || (assign.RecordType.DeveloperName == 'Staff' && (assign.Project__r.RecordType.DeveloperName == 'Testing_Projects' 
                 || assign.Project__r.RecordType.DeveloperName == 'CD_Projects'))) {
                 
                 filteredProjectId.add(assign.Project__c);
                 conAssign.add(assign);
             }
        }
       
        //Qry currentWeek time card day records
        String filterCondition = ' ORDER BY AcctSeed__Date__c ASC';
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        
        
        if(contactId != null && projectId.size() > 0) {
            timeCardLineList = TimeCardLineService.getTimeCardLine_dayRecords(filterCondition,projectId,Date.valueOf(startDt),Date.valueOf(endDt),contactId);
        }
        
        for(AcctSeed__Time_Card_Line__c timeLine : timeCardLineList) {
             timeLineIdSet.add(timeLine.Id);
        }
        
        // Time Snapshot formation
        for(AcctSeed__Time_Card_Day__c day : TimeCardDayService.getDayWithDate_timeLinefilter(timeLineIdSet,Date.valueOf(startDt),Date.valueOf(endDt)) ) {
            
            if(day.Accounting_Seed_Time_Snapshots__r != null && day.Accounting_Seed_Time_Snapshots__r.size() > 0) {
                for(Accounting_Seed_Time_Snapshot__c snapShot : day.Accounting_Seed_Time_Snapshots__r) {
                    accTimesnapshot.add(snapShot);
                }
            }
        }
        system.debug('::::::accTimesnapshot::::::'+accTimesnapshot);
        
        // qry project records
        if(filteredProjectId.size() > 0) {
            projectList = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',filteredProjectId,',Training_Location__r.Name,RecordType.DeveloperName');
        }
        if(contactId != null && projectId.size() > 0) {
         
            for(AcctSeed__Project_Task__c task : ProjectTaskService.getProjectTasksByProjIdsAndProjTaskTypes(projectId,new Set<String>{},'',',AcctSeed__Project__r.Name,AcctSeed__Project__r.RecordType.DeveloperName')) {
                taskList.add(task);
            }
            
            // Qry previous week project tasks with time card line ids
            for(AcctSeed__Project_Task__c task : ProjectTaskService.getProjectTaskByInnerQueryOnTimeCardLineDetails(',AcctSeed__Project__r.Name,AcctSeed__Project__r.AcctSeed__Status__c,AcctSeed__Project__r.End_Date__c',projectId,previousStart,previousEnd,contactId)) {
                if(task.AcctSeed__Project__r.AcctSeed__Status__c == 'Active' && task.AcctSeed__Project__r.End_Date__c >= Date.valueOf(startDt)) {
                    for(AcctSeed__Time_Card_Line__c timeLine : task.AcctSeed__Time_Card_Line_Details__r) {
                        previousWeekLineId.add(timeLine.Id);
                    }
                }
            }
        }

        if(previousWeekLineId.size() > 0) {
            previousWeekLines = TimeCardLineService.getLineWithCardday(previousStart,previousEnd,previousWeekLineId,' ORDER BY AcctSeed__Date__c ASC');
        }
        
        ptmValues = [SELECT Id,Name,Billable__c,Display_In_Time_Card__c,Labor_GL_Account__c,
                                                     Payroll_Item__c,Project_Record_Type__c,Project_Task_Record_Type__c,Project_Task_Type__c,
                                                     Project_Type__c,Unit__c 
                                                 FROM Project_Task_Master__c
                                                 WHERE (Project_Record_Type__c = 'Admin_Projects' OR Project_Record_Type__c = 'Admin_Projects;EFL_Projects;CD_Projects' OR Project_Record_Type__c = 'Admin_Projects;CD_Projects' OR Project_Record_Type__c = 'EFL_Projects')];
        
        
        List<Contact> contactRec = [SELECT Id,Name,EE_Pay_Status__c,Home_Department_Project__c,Home_Department_Project__r.RecordType.DeveloperName FROM Contact WHERE Id = :contactId];
        
        Set<Date> holidayDateSet = new Set<Date>();
         // Get Holiday list of dates for Fringe-Holiday disable function
         /*for(Holiday holi : [SELECT ActivityDate,Description FROM Holiday]) {
             holidayDateSet.add(holi.ActivityDate);
         }*/
         
        //Recurrence method call to get correct holiday dates for these date interval
        // Modified by NS on Jan 07 2019
        holidayDateSet = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
        system.debug('::::::::::holidayDateSet:::::::::'+holidayDateSet);
        
        TimeCardDayDomain.WeekViewDetails weekDetail = new TimeCardDayDomain.WeekViewDetails();
        weekDetail = TimeCardDayTranslator.WeekDetailsFormation(Date.valueOf(startDt),Date.valueOf(endDt),timeCardLineList,accTimesnapshot,contactRec,previousWeekLines,projectList,taskList,conAssign,ptmValues,holidayDateSet);
        
        return JSON.serialize(weekDetail);
    }
    
   /**********************************************************************
        Created by Sukanya on Mar 3 2018: Domain class used for Staff_Daily_Timesheet_Ctrl- Mobile view save operation
    ***********************************************************************/
    
    @AuraEnabled
    public static String dmlOperationFunction(String timeDayJson,String conId,String startDate,String endDate){
        
        //system.debug('::::::::::::timeDayJson:::::::'+timeDayJson);
        system.debug('::::::::::::conId:::::::'+conId);
        List<TimeCardDayDomain.DayEntries> dayRecords = (List<TimeCardDayDomain.DayEntries>) System.JSON.deserialize(timeDayJson, List<TimeCardDayDomain.DayEntries>.class);
        // Contact Id
        Id contactId = conId;
        // Logged in User id
        Id usrRecId = UserInfo.getUserId();
        
        Date startDt = Date.valueOf(startDate);
        Date endDt = Date.valueOf(endDate);
        
        // Variable Initialization
        Set<Id> timeCardId = new Set<Id>();
        Map<Id,AcctSeed__Time_Card__c> instrutorIdandRecordMap = new Map<Id,AcctSeed__Time_Card__c>();
        Map<Id,Map<String,AcctSeed__Time_Card_Line__c>> instructIdTaskIdandLineRecMap = new Map<Id,Map<String,AcctSeed__Time_Card_Line__c>>();
        Map<Id,List<AcctSeed__Time_Card_Line__c>> instructorIdLineListMap = new Map<Id,List<AcctSeed__Time_Card_Line__c>>();
        Map<String,List<AcctSeed__Time_Card_Day__c>> instIdTaskIdStringDayLsitMap = new Map<String,List<AcctSeed__Time_Card_Day__c>>();
        Set<Id> timeCardLineId = new Set<Id>();
        Set<Id> insIdForRefer = new Set<Id>();
        
        Map<Id,Map<String,AcctSeed__Time_Card_Line__c>> insIdStringTimeLineMap = new Map<Id,Map<String,AcctSeed__Time_Card_Line__c>>();
        
        List<AcctSeed__Time_Card_Day__c> dayListToUpsert = new List<AcctSeed__Time_Card_Day__c>();
        List<AcctSeed__Time_Card_Line__c> timeLineCreation = new List<AcctSeed__Time_Card_Line__c>();
        List<AcctSeed__Time_Card__c> cardCreation = new List<AcctSeed__Time_Card__c>();
         
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
                                             WHERE AcctSeed__Time_Card__c IN :timeCardId]){
            Id locId = null;
            
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
        
        for(TimeCardDayDomain.DayEntries day : dayRecords){
            
            AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
            
            // Check existing TCD records
            if(day.isUpdated && day.dayId != null && day.hours != null){
                
                newDay.Id = day.dayId;
                newDay.AcctSeed__Date__c = day.dateVal;
                newDay.Total_Hours_Before_Approved__c = day.hours;
                newDay.AcctSeed__Internal_Comment__c = day.comments;
                newDay.Status__c = day.status;
                newDay.AcctSeed__Hours__c = 0;
                
                dayListToUpsert.add(newDay);
            }
            
            // If already TCD not exist - check already card,line exist if not create from parent to child
           //Check Card record already exist
           if(instrutorIdandRecordMap.containsKey(contactId) 
                 && instrutorIdandRecordMap.get(contactId) != null 
                 && instrutorIdandRecordMap.get(contactId).AcctSeed__Time_Card_Period__c == timeCardPeriodId){
               
               AcctSeed__Time_Card__c cardRec = instrutorIdandRecordMap.get(contactId);
               // Check already card based line record exist
               if(instructIdTaskIdandLineRecMap.containsKey(cardRec.Intructor__c) 
                     && instructIdTaskIdandLineRecMap.get(cardRec.Intructor__c).containsKey(day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId)
               ) {
                   
                   AcctSeed__Time_Card_Line__c lineRec = instructIdTaskIdandLineRecMap.get(cardRec.Intructor__c).get(day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId);
                   
                   if(day.isNew && day.hours != null){
                       
                       newDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                       newDay.AcctSeed__Date__c = day.dateVal;
                       newDay.Total_Hours_Before_Approved__c = day.hours;
                       newDay.AcctSeed__Internal_Comment__c = day.comments;
                       newDay.Status__c = day.status;
                       newDay.AcctSeed__Hours__c = 0;
                       
                       dayListToUpsert.add(newDay);
                   }
               }else { // Line record not exist, going to create new one
                    AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                    line.AcctSeed__Project_Task__c = day.taskId;
                    line.AcctSeed__Project__c = day.projectId;
                    line.AcctSeed__Time_Card__c = cardRec.Id;
                    line.AcctSeed__Billable__c = day.isBillable;
                    line.Payroll_Item__c = day.payrollItem;
                    line.Location__c = day.locationId;
                    line.Display_in_Future_Weeks__c = true;
                    line.Labor_Cost_Rate__c = day.costrateId;
                    line.Contact_Assignment__c = day.contactAssignId;
                    line.Sequence_Number__c = day.sequenceNumber;
                    
                    timeLineCreation.add(line);
                    
                    // Time Card Day map formation - after line creation we can map the line id in day records
                    if(!instIdTaskIdStringDayLsitMap.containsKey(contactId+'-'+day.taskId+'-'+day.payrollItem+'-'+day.locationId)) {
                        instIdTaskIdStringDayLsitMap.put(contactId+'-'+day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId,new List<AcctSeed__Time_Card_Day__c>());
                    }
                    
                    if(day.isNew && day.hours != null){
                       newDay.AcctSeed__Date__c = day.dateVal;
                       newDay.Total_Hours_Before_Approved__c = day.hours;
                       newDay.AcctSeed__Internal_Comment__c = day.comments;
                       newDay.Status__c = day.status;
                       newDay.AcctSeed__Hours__c = 0;
                       
                       instIdTaskIdStringDayLsitMap.get(contactId+'-'+day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId).add(newDay);
                    }
               }// End of line creation if
           }else {// Already card record not exist, we are going to create card record, then line and day records
               
                //Card records creation
                if(!insIdForRefer.contains(contactId) && contactId != null) {
                
                    AcctSeed__Time_Card__c card = new AcctSeed__Time_Card__c();
                    card.AcctSeed__Employee__c = usrRecId;
                    card.Intructor__c = contactId;
                    card.AcctSeed__Time_Card_Period__c = timeCardPeriodId;
                    
                    if(Test.isRunningTest()){
                        card.AcctSeed__Ledger__c = ledger[0].Id;
                    }
                    
                    cardCreation.add(card);
                    insIdForRefer.add(contactId);
                }
                
                // Line record related Map formation
                AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                line.AcctSeed__Project_Task__c = day.taskId;
                line.AcctSeed__Project__c = day.projectId;
                line.AcctSeed__Billable__c = day.isBillable;
                line.Payroll_Item__c = day.payrollItem;
                line.Location__c = day.locationId;
                line.Display_in_Future_Weeks__c = true;
                line.Labor_Cost_Rate__c = day.costrateId;
                line.Contact_Assignment__c = day.contactAssignId;
                line.Sequence_Number__c = day.sequenceNumber;
                
                if(!instructorIdLineListMap.containsKey(contactId)) {
                    instructorIdLineListMap.put(contactId,new List<AcctSeed__Time_Card_Line__c>());
                }
                instructorIdLineListMap.get(contactId).add(line);
                
                // Time card Day Map formation
                if(!instIdTaskIdStringDayLsitMap.containsKey(contactId+'-'+day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId)) {
                    instIdTaskIdStringDayLsitMap.put(contactId+'-'+day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId,new List<AcctSeed__Time_Card_Day__c>());
                }
                
                if(day.isNew && day.hours != null){
                   newDay.AcctSeed__Date__c = day.dateVal;
                   newDay.Total_Hours_Before_Approved__c = day.hours;
                   newDay.AcctSeed__Internal_Comment__c = day.comments;
                   newDay.Status__c = day.status;
                   newDay.AcctSeed__Hours__c = 0;
                   
                   instIdTaskIdStringDayLsitMap.get(contactId+'-'+day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId).add(newDay);
                }
           }// End of card creation if
            
        } //End of for loop
        
        system.debug(':::::::::::dayListToUpsert::::daily::::::'+dayListToUpsert);
        system.debug('::::::cardCreation:::daily:::::'+cardCreation);
        system.debug('::::::timeLineCreation::::daily::::'+timeLineCreation);
        system.debug(':::instructorIdLineListMap:::::::daily:::'+instructorIdLineListMap);
        system.debug('::::::instIdTaskIdStringDayLsitMap::daily::::'+instIdTaskIdStringDayLsitMap);
        
        try {
        
            if(cardCreation.size() > 0) { //Card creation
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
            
            system.debug('::::::timeLineCreation::after::card::create::'+timeLineCreation);
            
            if(timeLineCreation.size() > 0) { // Line creation
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
                    upsert dayListToUpsert;
                }
            }else {
                system.debug('::::::::dayListToUpsert:::::'+dayListToUpsert);
                
                // Time card day upsertion
                if(dayListToUpsert.size() > 0){
                    upsert dayListToUpsert;
                }
            }
            
            return 'SUCCESS';
        }catch(DmlException e){
            system.debug('::::::::exception msg:::::::'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**********************************************************************
        Created by Sukanya on Mar 3 2018: Domain class used for Staff_Daily_Timesheet_Ctrl- Mobile view Submit Action
    ***********************************************************************/
    @AuraEnabled
    public static String submitActionFunction(String submitdayJson){
        
        List<TimeCardDayDomain.DayEntries> timeDayRecords = (List<TimeCardDayDomain.DayEntries>) System.JSON.deserialize(submitdayJson, List<TimeCardDayDomain.DayEntries>.class);
        
        List<AcctSeed__Time_Card_Day__c> submitList = new List<AcctSeed__Time_Card_Day__c>();
        
        Set<Id> tcdIds = new Set<Id>();
        
        for(TimeCardDayDomain.DayEntries day : timeDayRecords){
            if(day.status != 'Submitted' && !tcdIds.contains(day.dayId)) {
                AcctSeed__Time_Card_Day__c dayRec = new AcctSeed__Time_Card_Day__c();
                dayRec.Id = day.dayId;
                dayRec.Status__c = 'Submitted';
                submitList.add(dayRec);
                
                tcdIds.add(day.dayId);
            }
        }
        
        isGroupAction = true;
        groupActionType = 'Submitted';
        
        try {
            if(submitList.size() > 0){
                update submitList;
            }
            return 'SUCCESS';
        }catch(DmlException e) {
            system.debug('::::::::exception msg:::::::'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
     /**********************************************************************
        Created by Sukanya on Mar 3 2018: Domain class used for Staff_Daily_Timesheet_Ctrl- Mobile view Recall Action
    ***********************************************************************/
    @AuraEnabled
    public static String recallActionFunction(String recallJson){
        
        List<TimeCardDayDomain.DayEntries> timeDayRecords = (List<TimeCardDayDomain.DayEntries>) System.JSON.deserialize(recallJson, List<TimeCardDayDomain.DayEntries>.class);
        List<AcctSeed__Time_Card_Day__c> recallList = new List<AcctSeed__Time_Card_Day__c>();
        
        for(TimeCardDayDomain.DayEntries day : timeDayRecords){
            if(day.status == 'Submitted' || day.status == 'Approved' || day.status == 'Admin Approved') {
                AcctSeed__Time_Card_Day__c dayRec = new AcctSeed__Time_Card_Day__c();
                dayRec.Id = day.dayId;
                dayRec.Status__c = 'Recalled';
                recallList.add(dayRec);
            }
        }
        
        isGroupAction = true;
        groupActionType = 'Recalled';
        
        try {
            if(recallList.size() > 0){
                update recallList;
            }
            return 'SUCCESS';
        }catch(DmlException e) {
            system.debug('::::::::exception msg:::recallList::::'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**********************************************************************
        Created by Sukanya on Mar 20 2018: Domain class used for Staff_Daily_Timesheet_Ctrl- Updating previous week line records display behaviour on current week
    ***********************************************************************/
    @AuraEnabled
    public static String previousWeekLineUpdation(String lineJson){
        
        List<TimeCardDayDomain.DayEntries> previousEntries = (List<TimeCardDayDomain.DayEntries>) System.JSON.deserialize(lineJson, List<TimeCardDayDomain.DayEntries>.class);
        
        List<AcctSeed__Time_Card_Line__c> lineRecords = new List<AcctSeed__Time_Card_Line__c>();
        Set<Id> lineIds = new Set<Id>();
        
        for(TimeCardDayDomain.DayEntries entry : previousEntries){
            
            if(entry.lineId != null && !entry.isAvailable_FutureWeek){
                AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                line.Id = entry.lineId;
                line.Display_in_Future_Weeks__c = entry.isAvailable_FutureWeek;
                
                if(!lineIds.contains(entry.lineId)){
                    lineRecords.add(line);
                    lineIds.add(entry.lineId);
                }
            }
        }
        
        system.debug(':::::::lineRecords:::::'+lineRecords);
        try {
            if(lineRecords.size() > 0){
                update lineRecords;
            }
            return 'SUCCESS';
        }catch(DmlException e) {
            system.debug('::::::::exception msg::past:charge:code:updation::'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /***********************************************
     - To get the selected input related records for the lookup search
     ***********************************************/
    @AuraEnabled
    public static List<sObject> search(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds) {
        system.debug('::::::searchTerm::::'+searchString);
        system.debug(':::objNAme:::fieldName::::'+objectName+' '+fieldName);
        // Prepare query paramters
        List<sObject> lookupRecords = new List<sObject>();
        String query = 'SELECT Id, Name FROM ' + objectName;
        if(fieldName != null && fieldName != '' && searchString != null && searchString != '') {
            query += ' WHERE '+fieldName+' LIKE \'%' + searchString + '%\'';
        }
        system.debug('condition'+condition);
        if(condition != null && condition != '') {
            if(searchString != null && searchString != '') {
                
                query += ' AND ' + condition;
            } else {
                
                query += ' WHERE ' + condition;
            }
        }
        
        if(selectedIds != null && selectedIds.size() > 0) {
            query += ' AND Id NOT IN :selectedIds';
        }
        
        query += ' LIMIT 10';
        System.debug('query log ' + query);
        
        if(objectName != 'Account' && objectName != 'Contact') {
            system.debug('query is '+query);
            lookupRecords = Database.query(query);
        }else {
            String searchQry = 'FIND {'+searchString+'} IN NAME Fields Returning '+objectName+' (Id,Name';
    
            if(condition != null && condition != '') {
                searchQry = searchQry + ' WHERE '+condition;
            }
            
            if(selectedIds != null && selectedIds.size() > 0){
                if(condition != null && condition != '') {
                    searchQry += ' AND Id NOT IN :selectedIds';
                } else {
                    searchQry += ' WHERE Id NOT IN :selectedIds';
                }
            }
            
            searchQry = searchQry + ')';
            
            searchQry += ' LIMIT 10';
            system.debug('sosl is '+searchQry);
            if(searchString != null) {
                lookupRecords = search.query(searchQry)[0];
            }
        }
        system.debug('lookup records'+lookupRecords);
        return lookupRecords;
    }
}