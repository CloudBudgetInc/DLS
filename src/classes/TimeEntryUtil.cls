/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 11/17/2023
 * @last modified by  : Dhinesh Kumar
**/
public class TimeEntryUtil {
    
    public static Boolean checkOnly = false;
    
    public static Map<String, Id> timeCardPeriodCreation(Set<Date> startDates,Set<Date> endDates, Set<String> startAndEndDateSet) {
          
        Map<String, Id> startAndEndDateWithTimeCardPeriodIdMap = new Map<String, Id>();
        
        for(AcctSeed__Time_Card_Period__c timeCardPeriod :TimecardPeriodService.getTimeCardPeriodByDate('',startDates,endDates)) {            
            String key = getOnlyDate(timeCardPeriod.AcctSeed__Start_Date__c)+'~'+getOnlyDate(timeCardPeriod.AcctSeed__End_Date__c);
            startAndEndDateWithTimeCardPeriodIdMap.put(key, timeCardPeriod.Id);
            startAndEndDateSet.remove(key);
        }
        
        if(startAndEndDateSet.size() > 0 && !checkOnly){
            List<AcctSeed__Time_Card_Period__c> timeCardPeriodToInsert = new List<AcctSeed__Time_Card_Period__c>();
            
            for(String startAndEndDateStr : startAndEndDateSet){
                List<String> startAndEndDateStrList = startAndEndDateStr.split('~');
                Date startDate = Date.valueOf(startAndEndDateStrList[0]);
                Date EndDate = Date.valueOf(startAndEndDateStrList[1]);
                AcctSeed__Time_Card_Period__c period = new AcctSeed__Time_Card_Period__c();
                period.name = startDate.year()+'-' + startDate.Month();
                period.AcctSeed__Start_Date__c = startDate;
                period.AcctSeed__End_Date__c = endDate;
                
                timeCardPeriodToInsert.add(period);
            }
            
            insert timeCardPeriodToInsert;  
             
            for(AcctSeed__Time_Card_Period__c timeCardPeriod : timeCardPeriodToInsert){
                String key = getOnlyDate(timeCardPeriod.AcctSeed__Start_Date__c)+'~'+getOnlyDate(timeCardPeriod.AcctSeed__End_Date__c);
                startAndEndDateWithTimeCardPeriodIdMap.put(key, timeCardPeriod.Id);
            }
        }
        
        return startAndEndDateWithTimeCardPeriodIdMap;
    } 
    
    public static Map<String, AcctSeed__Time_Card__c> getTimeCard(String instructorId, Set<Id> timeCardPeriodIds){
        return getTimeCard(new Set<Id>{instructorId}, timeCardPeriodIds);
    }

    public static Map<String, AcctSeed__Time_Card__c> getTimeCard(Set<Id> instructorId, Set<Id> timeCardPeriodIds){
         
        Map<String, AcctSeed__Time_Card__c> insIdAndTimeCardPeriodIdWithTimeCardMap = new Map<String, AcctSeed__Time_Card__c>(); 
        Set<String> timeCardPeriodAndInstIds = new Set<String>();                
        for(AcctSeed__Time_Card__c timeCard : [SELECT Id,Name,Intructor__c,AcctSeed__Time_Card_Period__c 
                                            FROM AcctSeed__Time_Card__c 
                                            WHERE AcctSeed__Time_Card_Period__c IN :timeCardPeriodIds AND Intructor__c IN :instructorId]){
                                                                                                                                                              
            String key  = timeCard.Intructor__c+'~'+timeCard.AcctSeed__Time_Card_Period__c;    

            insIdAndTimeCardPeriodIdWithTimeCardMap.put(key, timeCard);
            timeCardPeriodAndInstIds.add(key);            
        }
        
        if(timeCardPeriodIds.size() > 0 && !checkOnly){
            List<User> users = UserService.getUserRecByNameAndContactId(new Set<String>(),instructorId, '','');
            Map<Id, Id> contactIdWithUserIdMap = new Map<Id, Id>();
            for(User user : users){
                contactIdWithUserIdMap.put(user.ContactId, user.Id);
            }
            List<AcctSeed__Time_Card__c> timeCardToInsert = new List<AcctSeed__Time_Card__c>();
            for(Id instId : instructorId){
                for(Id timeCardPeriodId: timeCardPeriodIds){ 
                    String key  = instId+'~'+timeCardPeriodId;    
                    if(!timeCardPeriodAndInstIds.contains(key)){               
                        AcctSeed__Time_Card__c card = new AcctSeed__Time_Card__c();                  
                        
                        card.AcctSeed__Employee__c = contactIdWithUserIdMap.get(instId);
                        card.Intructor__c = instId;
                        card.AcctSeed__Time_Card_Period__c = timeCardPeriodId;
                        
                        if(Test.isRunningTest()){
                            List< AcctSeed__Ledger__c > ledger = [SELECT Id, Name, AcctSeed__Type__c FROM AcctSeed__Ledger__c LIMIT 1];                
                            card.AcctSeed__Ledger__c = ledger[0].Id;
                        }                
                        timeCardToInsert.add(card);
                        timeCardPeriodAndInstIds.add(key);
                    }
                }  
            }
            
            insert timeCardToInsert;
            
            for(AcctSeed__Time_Card__c timeCard : timeCardToInsert){
                String key  = timeCard.Intructor__c+'~'+timeCard.AcctSeed__Time_Card_Period__c;       
                insIdAndTimeCardPeriodIdWithTimeCardMap.put(key, timeCard);
            }
        }
        
        return insIdAndTimeCardPeriodIdWithTimeCardMap;
    }  

    public static Map<String, AcctSeed__Time_Card_Line__c> getTimeCardLines(String instructorId, String projectId, Set<Id> timeCardIds, Set<Id> projectTaskIds, Set<Boolean> billable, Set<String> payrollItems, Set<String> timeCardLineKeySet){
        Map<String, String> timeCardLineKeyWithProjectIdMap = new Map<String, String>();
        for(String timeCardLineKey : timeCardLineKeySet){
            timeCardLineKeyWithProjectIdMap.put(timeCardLineKey, projectId);
        }
        return getTimeCardLines(new Set<Id>{instructorId}, timeCardLineKeyWithProjectIdMap, timeCardIds, projectTaskIds, billable, payrollItems, timeCardLineKeySet);
    }

    public static Map<String, AcctSeed__Time_Card_Line__c> getTimeCardLines(Set<Id> instructorId, Map<String, String> timeCardLineKeyWithProjectIdMap, Set<Id> timeCardIds, Set<Id> projectTaskIds, Set<Boolean> billable, Set<String> payrollItems, Set<String> timeCardLineKeySet){
                
        Map<String, AcctSeed__Time_Card_Line__c> insIdAndTimeCardPeriodIdWithTimeCardLineMap = new Map<String, AcctSeed__Time_Card_Line__c>(); 
        Set<String> timeCardLineKeySetCpy = timeCardLineKeySet;
                
        for(AcctSeed__Time_Card_Line__c line : [SELECT Id,AcctSeed__Project_Task__c,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c,
                                                                                          AcctSeed__Billable__c,Payroll_Item__c,Location__c, Contact_Assignment__c, Sequence_Number__c
                                                                                          FROM AcctSeed__Time_Card_Line__c 
                                                                                          WHERE AcctSeed__Time_Card__c IN :timeCardIds AND AcctSeed__Project_Task__c IN :projectTaskIds 
                                                                                          AND AcctSeed__Billable__c IN :billable AND Payroll_Item__c IN  :payrollItems]){
                                                                                                                                                              
            string key = line.AcctSeed__Time_Card__c+'~'+line.AcctSeed__Project_Task__c+'~'+line.AcctSeed__Billable__c+'~'+line.Payroll_Item__c+'~'+line.Location__c;
            insIdAndTimeCardPeriodIdWithTimeCardLineMap.put(key, line);
            timeCardLineKeySetCpy.remove(key);
        }
        
        if(timeCardLineKeySetCpy.size() > 0 && !checkOnly){
            
            List<AcctSeed__Time_Card_Line__c> timeCardLineToInsert = new List<AcctSeed__Time_Card_Line__c>();
            
            for(String timeCardLineKey: timeCardLineKeySetCpy){ 
                List<String> lineKeyList = timeCardLineKey.split('~');
                
                AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                line.AcctSeed__Project__c = timeCardLineKeyWithProjectIdMap.get(timeCardLineKey);
                line.AcctSeed__Time_Card__c = lineKeyList[0];
                line.AcctSeed__Project_Task__c = lineKeyList[1];                
                line.AcctSeed__Billable__c = Boolean.valueOf(lineKeyList[2]);
                line.Payroll_Item__c = lineKeyList[3];
                line.Location__c = lineKeyList[4];
                //line.Display_in_Future_Weeks__c = true;
                if (StaffTimeEntryController.timeCardLineKeyWithConAssignIdMap.get(timeCardLineKey) != null) {
                    line.Contact_Assignment__c = StaffTimeEntryController.timeCardLineKeyWithConAssignIdMap.get(timeCardLineKey);//day.contactAssignId;
                }
                //line.Sequence_Number__c = day.sequenceNumber;                
                timeCardLineToInsert.add(line);
            }  
            
            insert timeCardLineToInsert;
            
            for(AcctSeed__Time_Card_Line__c line : timeCardLineToInsert){
                string key = line.AcctSeed__Time_Card__c+'~'+line.AcctSeed__Project_Task__c+'~'+line.AcctSeed__Billable__c+'~'+line.Payroll_Item__c+'~'+line.Location__c;
                insIdAndTimeCardPeriodIdWithTimeCardLineMap.put(key, line);
            }
        }
        
        return insIdAndTimeCardPeriodIdWithTimeCardLineMap;
    }
    
    public static Map<String, Id> getTimeCardDayByTimeCardLine(Set<Id> timeCardLineIds){
        Map<String, Id> timeCardDayIdMap = new Map<String, Id>();
        for(AcctSeed__Time_Card_Day__c cardDay : [SELECT Id, AcctSeed__Time_Card_Line__c, AcctSeed__Date__c FROM AcctSeed__Time_Card_Day__c 
                                                                                 WHERE AcctSeed__Time_Card_Line__c IN :timeCardLineIds]){
            
            timeCardDayIdMap.put(cardDay.AcctSeed__Time_Card_Line__c+'~'+getOnlyDate(cardDay.AcctSeed__Date__c), cardDay.Id);
        }
        
        return timeCardDayIdMap;
    }
    
    public static TimeCardDayCommunityDomain.DayEntries populateCostRateAndPayRollItemInDayEntry(Date dt, TimeCardDayCommunityDomain.DayEntries day, List<Contact_Assignments__History> caHistory,List<AcctSeed__Cost_Rates__c> oldCRRecord, List<Contact_Assignments__c> caRecord, AcctSeed__Project_Task__c task){
        if(caHistory.size() == 0 || (caHistory.size() > 0 && caHistory[0].OldValue == null)){
            if(caRecord.size() > 0 && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c
                                       || task.Project_Task_Type__c == 'Fringe') 
               && caRecord[0].Rate_Card_Rate__c != null){
                   
                   for(Contact_Assignments__c ca : caRecord){
                       Date oralExamDate;
                       if(ca.Oral_Exam_Date_Time__c != null){
                           oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                       }
                       Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                       if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                           day.costrateId = (Id) ca.Rate_Card_Rate__c; 
                           day.contactAssignid = (Id) ca.Id;
                           
                           if(day.isBillable){
                               day.payrollItem = ca.Rate_Card_Rate__r.Payroll_Item__c;
                           }else {
                               day.payrollItem = ca.Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                           }
                       }
                   }
               }
        }else if(caHistory.size() > 0 && caRecord.size() > 0 
                 && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c
                     || task.Project_Task_Type__c == 'Fringe')){                                                  
                         
                        Date historyDate = Date.newInstance(caHistory[0].createdDate.year(),caHistory[0].createdDate.month(),caHistory[0].createdDate.day());
                        
                        if(dt <= historyDate && caHistory[0].OldValue != null){
                            
                            day.costrateId = (Id) caHistory[0].OldValue;
                            day.contactAssignid = (Id) caHistory[0].parentId;
                            
                            if(oldCRRecord.size() > 0 && oldCRRecord[0].Id == day.costrateId){
                                if(day.isBillable){
                                    day.payrollItem = oldCRRecord[0].Payroll_Item__c;
                                }else {
                                    day.payrollItem = oldCRRecord[0].Non_Billable_Payroll_Item__c;
                                }
                            }
                        }else {    //If the history date is older then populate current CR value                                                        
                            
                            if(caRecord.size() > 0 && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c || task.Project_Task_Type__c == 'Fringe') 
                            && caRecord[0].Rate_Card_Rate__c != null){                             
                                for(Contact_Assignments__c ca : caRecord){
                                    Date oralExamDate;
                                    if(ca.Oral_Exam_Date_Time__c != null){
                                        oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                                    }
                                    Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                                    if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                                        day.costrateId = (Id) ca.Rate_Card_Rate__c;
                                        day.contactAssignid = (Id) ca.Id;
                                        
                                        if(day.isBillable){
                                            day.payrollItem = ca.Rate_Card_Rate__r.Payroll_Item__c;
                                        }else {
                                            day.payrollItem = ca.Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                                        }
                                    }
                                }
                            }
                        }
                     }
        
        //For Fringe Project Task get payroll item from project task
        if(task.RecordType.DeveloperName == 'Cost' && task.Project_Task_Type__c == 'Fringe'){
            day.payrollItem = task.Payroll_Item__c;
        }
        
        return day;
    }
    
    public static String getOnlyDate(Date dt){
        return dt.year() + '-' + String.valueOf(dt.month()).leftPad(2, '0') + '-' + String.valueOf(dt.day()).leftPad(2, '0');
    }
    
    //Added By Dhinesh - 20/03/2023 - W-007729 - Timekeeping Fields to Indicate if the Time was entered On Time or Late
    public static timeEnteredCountWrap getTimeEnteredCountByContactId(Id conId){
        Map<Id, TimeEnteredCountWrap> conIdWithTimeEnteredCountMap = getTimeEnteredCountByContactIds(new Set<Id>{conId});
        TimeEnteredCountWrap timeEnteredCount = new TimeEnteredCountWrap();
        
        if(conIdWithTimeEnteredCountMap.containsKey(conId)){
            timeEnteredCount = conIdWithTimeEnteredCountMap.get(conId);
        }
        
        return timeEnteredCount;
    }
    
    
    public static Map<Id, TimeEnteredCountWrap> getTimeEnteredCountByContactIds(Set<Id> conIds){    
        Set<Id> timeCardLineIds = new Set<Id>();
        Map<Id, TimeEnteredCountWrap> conIdWithTimeEnteredCountMap = new Map<Id, TimeEnteredCountWrap>();
                
        for(AcctSeed__Time_Card_Day__c day: [SELECT Id, AcctSeed__Time_Card_Line__c, AcctSeed__Time_Card_Line__r.Submitted_On_Time__c,
                                                                         AcctSeed__Time_Card_Line__r.Submitted_Late__c, Entered_Late__c, Entered_On_Time__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c 
                                                                         FROM Acctseed__Time_Card_Day__c 
                                                                         WHERE AcctSeed__Date__c = THIS_MONTH 
                                                                         AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c IN :conIds
                                                                         AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c NOT IN ('Preparation time','Fringe')]){
            
            TimeEnteredCountWrap timeEnteredCount = new TimeEnteredCountWrap();
            
            if(conIdWithTimeEnteredCountMap.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c)){
                timeEnteredCount = conIdWithTimeEnteredCountMap.get(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
            }
                                                         
            timeEnteredCount.timeEnteredLate += day.Entered_Late__c ? 1 : 0;
            timeEnteredCount.timeEnteredOnTime += day.Entered_On_Time__c ? 1 : 0;
            
            if(!timeCardLineIds.contains(day.AcctSeed__Time_Card_Line__c)){
                timeCardLineIds.add(day.AcctSeed__Time_Card_Line__c);
                timeEnteredCount.timeSubmittedOnTime += day.AcctSeed__Time_Card_Line__r.Submitted_On_Time__c ? 1 : 0;
                timeEnteredCount.timeSubmittedLate += day.AcctSeed__Time_Card_Line__r.Submitted_Late__c ? 1 : 0;
            }
            
            conIdWithTimeEnteredCountMap.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, timeEnteredCount);
         }    
        
        return conIdWithTimeEnteredCountMap;
    }
    
    public static Contact getUserContact(){
        List<User> usrRec = [SELECT Id,Name,FirstName,LastName,Email,ContactId FROM User WHERE Id = :UserInfo.getUserId()];        
        
        List<Contact> conRecList = new List<Contact>();
        Boolean internalUser = false;
        
        if(usrRec.size() > 0 && usrRec[0].ContactId != null) {
            
            conRecList = [SELECT Id,Name,Supervisor_Name__r.Name,PC_EE_ID__c FROM Contact WHERE Id = :usrRec[0].ContactId];
            
        }else if(usrRec[0].ContactId == null){ 
            
            internalUser = true;
            
            String fname = usrRec[0].FirstName != null ? '%'+String.escapeSingleQuotes(usrRec[0].FirstName)+'%' : null;
            String lName = usrRec[0].LastName != null ? '%'+String.escapeSingleQuotes(usrRec[0].LastName)+'%' : null;
            
            if(usrRec[0].FirstName != null && usrRec[0].LastName != null){                  
                conRecList = ContactService.getContactByName(' WHERE Email = \''+usrRec[0].Email+'\' AND FirstName LIKE \''+fname+'\' AND LastName LIKE \''+lName+'\'',',RecordType.DeveloperName,Supervisor_Name__r.Name',new Set<String>{},'');
            }else if(usrRec[0].LastName != null) { 
                conRecList = ContactService.getContactByName(' WHERE Email = \''+usrRec[0].Email+'\' AND LastName LIKE \''+lName+'\'',',RecordType.DeveloperName,Supervisor_Name__r.Name',new Set<String>{},'');
            }
            
        }
        
        return conRecList[0];
    }
    
    public static List<Date> getDatesFromWeekRange(String weekRange){       

        String[] dateStr = weekRange.split(' to ');
        String[] startDateStr = dateStr[0].split('/');
        String[] endDateStr = dateStr[1].split('/');
                
        Date startDate = Date.newInstance(Integer.valueOf(startDateStr[2]), Integer.valueOf(startDateStr[0]), Integer.valueOf(startDateStr[1]));
        Date endDate = Date.newInstance(Integer.valueOf(endDateStr[2]), Integer.valueOf(endDateStr[0]), Integer.valueOf(endDateStr[1]));
        
        return new List<Date>{startDate, endDate};
    }

    /**
    * @description 
    * @author Dhinesh Kumar | 05/16/2023 
    * @param proIds 
    * @param projTaskIds 
    * @param startDate 
    * @param endDate 
    * @param conId 
    * @return TimeCardLineWrap 
    **/
    public static TimeCardLineWrap getTCLAndTCDWithSnapShots(Set<Id> proIds,Set<Id> projTaskIds,Date startDate,Date endDate, Id conId) {
        
        TimeCardLineWrap TimeCardLineWrapObj = new TimeCardLineWrap();

        //Qry currentWeek time card day records
        String filterCondition = 'ORDER BY AcctSeed__Date__c ASC';
        
        TimeCardLineWrapObj.timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        TimeCardLineWrapObj.accTimesnapshot = new List<Accounting_Seed_Time_Snapshot__c>();        
        
        //Qry Existing TCL records with TCD
        if(conId != null && proIds.size() > 0) {
            TimeCardLineWrapObj.timeCardLineList = TimeCardLineService.getTCL_dayRecords(filterCondition,proIds,projTaskIds,startDate,endDate,conId);
        }
        
        Set<Id> tcdIds = new Set<Id>();
        
        for(AcctSeed__Time_Card_Line__c timeLine : TimeCardLineWrapObj.timeCardLineList) {
            if(timeLine.AcctSeed__Time_Card_Days__r.size() > 0){                 
                tcdIds.addAll((new Map<Id, AcctSeed__Time_Card_Day__c>(timeLine.AcctSeed__Time_Card_Days__r)).keySet());
            }
        }
        
        // Time Snapshot formation
        if(tcdIds.size() > 0) {
            TimeCardLineWrapObj.accTimesnapshot = TimeSnapshotService.getSnpshotWithDaysIds(tcdIds);
        }

        return TimeCardLineWrapObj;
    }

    public Class TimeCardLineWrap{
        public List<AcctSeed__Time_Card_Line__c> timeCardLineList;
        public List<Accounting_Seed_Time_Snapshot__c> accTimesnapshot;
    }


    /**
    * @description 
    * @author Dhinesh Kumar | 05/22/2023 
    * @param startDt 
    * @param endDt 
    * @return Map<Date, TimeCardDayCommunityDomain.DayEntries> 
    **/
    public static WeekRangeEnteries getDateEntryForWeekRange(Date startDt, Date endDt) {
        
        Map<Date,TimeCardDayCommunityDomain.DayEntries> dateEntryMap = new Map<Date,TimeCardDayCommunityDomain.DayEntries>();
        List<TimeCardDayCommunityDomain.WeekRangeValues> weekRangeValues = new List<TimeCardDayCommunityDomain.WeekRangeValues>();
        
        while(startDt <= endDt){
            TimeCardDayCommunityDomain.WeekRangeValues weekDay = new TimeCardDayCommunityDomain.WeekRangeValues(startDt);
            TimeCardDayCommunityDomain.DayEntries day = new TimeCardDayCommunityDomain.DayEntries();
            day.dateVal = startDt;            
            day.displayDate = weekDay.dateValue;     
            day.dayType = weekDay.dayVal;
            dateEntryMap.put(startDt,day);
            weekRangeValues.add(weekDay);
            startDt = startDt.addDays(1);            
        }

        return new WeekRangeEnteries(dateEntryMap, weekRangeValues);
    }

    public class WeekRangeEnteries {
        public Map<Date,TimeCardDayCommunityDomain.DayEntries> dateEntryMap;
        public List<TimeCardDayCommunityDomain.WeekRangeValues> weekRangeValues;
        
        public WeekRangeEnteries(Map<Date,TimeCardDayCommunityDomain.DayEntries> dateEntryMap, List<TimeCardDayCommunityDomain.WeekRangeValues> weekRangeValues){
            this.dateEntryMap = dateEntryMap;
            this.weekRangeValues = weekRangeValues;
        }
    }


    /**
    * @description To get the Cost Rate Id by Date from CA for Time Card Day formation
    * @author Dhinesh Kumar | 06/19/2023 
    * @param startDt 
    * @param endDt 
    * @param conId 
    * @param projId 
    **/
    public static  Map<String,Map<Date,Id>> getCostRateIdByDates(Date startDt, Date endDt, String conId, String projId) {
       
        Map<String,Map<Date,Id>> costRateAndContactAssignIdWithDateMap = new Map<String,Map<Date,Id>>();
        Map<Date, Id> costRateIdAndDateMap = new Map<Date, Id>();
        Map<Date, Id> contactAssignIdAndDateMap = new Map<Date, Id>();

        for(Contact_Assignments__c ca: [SELECT Id, Rate_Card_Rate__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c 
                                        WHERE Start_Date__c <= :startDt AND End_Date__c >= :endDt 
                                        AND Candidate_Name__c = :conId AND Project__c = :projId]){
            
            while(startDt <= endDt){
                if(startDt >= ca.Start_Date__c && startDt <= ca.End_Date__c){
                    costRateIdAndDateMap.put(startDt, ca.Rate_Card_Rate__c);
                    contactAssignIdAndDateMap.put(startDt, ca.Id);
                    startDt = startDt.addDays(1);
                }else{
                    break;
                }                                            
            }            
        }
        costRateAndContactAssignIdWithDateMap.put('CostRate',costRateIdAndDateMap);
        costRateAndContactAssignIdWithDateMap.put('ContactAssignment',contactAssignIdAndDateMap);
        return costRateAndContactAssignIdWithDateMap;
    }
    
    public Class TimeEnteredCountWrap{
       
        public Integer timeEnteredOnTime = 0;
        public Integer timeEnteredLate = 0;
        public Integer timeSubmittedOnTime = 0;
        public Integer timeSubmittedLate = 0;
    }
}