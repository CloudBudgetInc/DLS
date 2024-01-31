/**
 * @description       : 
 * @author            : Vasanthram
 * @group             : 
 * @last modified on  : 11/27/2023
 * @last modified by  : Dhinesh Kumar
**/
public with sharing class StaffTimeEntryTranslator {

    public static StaffTimeEntryDomain.Filter StaffTimeEntry_initialFilterFormation() {

        StaffTimeEntryDomain.Filter filter = new StaffTimeEntryDomain.Filter();            
        Date weekStart = Date.today().toStartofWeek().addDays(1);
        Date weekEnd = weekStart.addDays(6);
        
        List<ListViewController.PicklistWrap> weekList = new List<ListViewController.PicklistWrap>();
        for (Integer i = -4; i <= 4; i++) {
            Date startDate = weekStart.addDays(i*7);
            Date endDate = startDate.addDays(6);            
            String startDateFormat = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('MM/dd/yyyy');
            String endDateFormat = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day()).format('MM/dd/yyyy');
            
            String formattedStr = startDateFormat + ' to ' + endDateFormat;                
            weekList.add(new ListViewController.PicklistWrap(formattedStr, formattedStr));
            if(startDate == weekStart && endDate == weekEnd){
                filter.selectedWeek = formattedStr;
            }
        }
        filter.weekRanges = weekList;

        return filter;
    }

    public static TimeCardDayCommunityDomain.InstructorRowDetails getProjTaskAndTimeEnteredDetails(Id projectId,Date startDate, Date endDate, List<String> sortedProjTaskMaster, Map<String, AcctSeed__Project_Task__c> projTasksMap, Map<String, Project_Task_Master__c> projectTaskMasterMap, AcctSeed__Project__c pro, Map<Date,TimeCardDayCommunityDomain.DayEntries> dateEntryMap,Map<Date, Id> costRateIdAndDateMap,Map<Date, Id> contactAssignIdAndDateMap, List<AcctSeed__Time_Card_Line__c> timeCardLineList, List<Accounting_Seed_Time_Snapshot__c> accTimesnapshot) {


         //check selected week range is before last week
         Date currStart = system.today().toStartofWeek().addDays(1);
         Date currEnd = currStart.addDays(6);
         
         Date isOlderThanLast2WeekStart = currStart.addDays(-14);
         Date isOlderThanLast2WeekEnd = currEnd.addDays(-14);
                     
         Boolean isCurrentWeek = false;
         Boolean isBeforeLastWeek = false;
         
         if(startDate == currStart && endDate == currEnd) {
             isCurrentWeek = true;
         }
         
         if(startDate <= isOlderThanLast2WeekStart && endDate <= isOlderThanLast2WeekEnd){
             isBeforeLastWeek = true;
         }

        TimeCardDayCommunityDomain.InstructorRowDetails instructorRowDetails = new TimeCardDayCommunityDomain.InstructorRowDetails();

        Map<String,TimeCardDayCommunityDomain.InstructorDayDetails> instructorDayDetailsMap = new Map<String,TimeCardDayCommunityDomain.InstructorDayDetails>();            
        Map<String,Map<Date,TimeCardDayCommunityDomain.DayEntries>> chargeCodedateEntryMap = new Map<String,Map<Date,TimeCardDayCommunityDomain.DayEntries>>();                        

        Set<Date> holidayDates = HolidayService.getHolidaysWithRecurrence(startDate,endDate);           

        for(String ptKey : sortedProjTaskMaster){
            if(projTasksMap.containsKey(ptKey)){
                AcctSeed__Project_Task__c pt = projTasksMap.get(ptKey);
                String code = projectId+'~'+pt.Id;
                Project_Task_Master__c ptm = projectTaskMasterMap.get(ptKey);
                Decimal totHrs = 0;
                TimeCardDayCommunityDomain.InstructorDayDetails instructorDayDetails = new TimeCardDayCommunityDomain.InstructorDayDetails(); 
                instructorDayDetails.chargeCode1 = pro.Name +'/'+ pt.Name + ( String.isNotBlank(pt.Payroll_Item__c) ? '/'+ pt.Payroll_Item__c : '') +'/'+ pro.Training_Location__r.Name;                  
                instructorDayDetails.taskType = pt.Project_Task_Type__c;
                instructorDayDetails.isNewRow = true;
                Map<Date,TimeCardDayCommunityDomain.DayEntries> dateEntryMapClone = new Map<Date,TimeCardDayCommunityDomain.DayEntries>();
                for(Date dt: dateEntryMap.keySet()){
                    TimeCardDayCommunityDomain.DayEntries dayEntry = dateEntryMap.get(dt).clone();
                    dayEntry.chargeCode = pro.Name +'/'+ pt.Name + ( String.isNotBlank(pt.Payroll_Item__c) ? '/'+ pt.Payroll_Item__c : '') +'/'+ pro.Training_Location__r.Name;                        
                    dayEntry.projectId = projectId;                        
                    dayEntry.taskId = pt.Id;                        
                    dayEntry.locationId = pro.Training_Location__c;                                            
                    dayEntry.isBillable = ptm.Billable__c;
                    dayEntry.payrollItem = pt.Payroll_Item__c;
                    dayEntry.dateVal = dt;
                    dayEntry.costrateId = costRateIdAndDateMap.get(dt); 
                    dayEntry.contactAssignid = contactAssignIdAndDateMap.get(dt);
                    dayEntry.sequenceNumber = Integer.valueOf(ptm.Sort_Order__c);                                                                      
                    dayEntry.TaskType = pt.Project_Task_Type__c;
                    dayEntry.ProjectName = pro.Name;
                    dayEntry.TaskName = pt.Name;  
                                                                    
                    if(!(dayEntry.dateVal > system.today())){
                        //fringe -> future always open, past based on line status
                        dayEntry.isHrsDisabled = TimeCardDayCommunityTranslator.hrsDisableFunction(dayEntry,isCurrentWeek,isBeforeLastWeek); //need disable change based on project task type

                    }

                    if(dayEntry.TaskName.contains('Holiday') && holidayDates.contains(dt)){
                        DateTime holidayDT = datetime.newInstance(dt, Time.newInstance(0,0,0,0));
                        String dayValue = holidayDT.format('E');// Exclude the 8 hours population for saturday and sunday if holidays occurs in saturday and sunday.
                        
                        if(dayValue != 'Sat' && dayValue != 'Sun'){
                            dayEntry.dayHours = 8 + '.00';
                            totHrs +=  Decimal.valueOf(dayEntry.dayHours); 
                        }
                    }   
                    dayEntry.isHrsDisabled = (dayEntry.TaskType != 'Fringe' && dayEntry.dateVal > system.today()) || dayEntry.TaskName.contains('Holiday');
                                                                                       
                    dateEntryMapClone.put(dt,dayEntry);    
                }
                instructorDayDetails.dayEntries = dateEntryMapClone.values();
                instructorDayDetails.totalHours = String.valueOf(totHrs);
                chargeCodedateEntryMap.put(code, dateEntryMapClone);
                instructorDayDetailsMap.put(code, instructorDayDetails);
            }
        }

        Set<Id> tcdIds = new Set<Id>();
        Map<Id,Boolean> taskIdLineCompleted = new Map<Id,Boolean>();

        for(AcctSeed__Time_Card_Line__c tcl : timeCardLineList){
            String chargeCodeKey = tcl.AcctSeed__Project__c+'~'+ tcl.AcctSeed__Project_Task__c;  
            
            
            //For Line completed check for other non created entries
            if(!taskIdLineCompleted.containsKey(tcl.AcctSeed__Project_Task__c)){
                taskIdLineCompleted.put(tcl.AcctSeed__Project_Task__c,tcl.Completed__c);
            }

            if(chargeCodedateEntryMap.containsKey(chargeCodeKey)){
                Map<Date,TimeCardDayCommunityDomain.DayEntries> dateEntriesMap = chargeCodedateEntryMap.get(chargeCodeKey);
                Decimal totHrs = 0;
                for(AcctSeed__Time_Card_Day__c day: tcl.AcctSeed__Time_Card_Days__r){
                    TimeCardDayCommunityDomain.DayEntries dayEntry = dateEntriesMap.get(day.AcctSeed__Date__c);
                    dayEntry.dayHours = String.valueOf(day.Total_Hours_Before_Approved__c);
                    if(!dayEntry.dayHours.contains('.')){
                        dayEntry.dayHours = dayEntry.dayHours+'.00';
                    }
                    dayEntry.dayId = day.Id;
                    tcdIds.add(day.Id);
                    dayEntry.lineId = day.AcctSeed__Time_Card_Line__c;
                    dayEntry.comments = day.AcctSeed__Internal_Comment__c;
                    dayEntry.costrateId = day.Labor_Cost_Rate__c; 
                    dayEntry.contactAssignid = tcl.Contact_Assignment__c;
                    dayEntry.isNew = false;
                    dayEntry.isUpdated = true; 
                    
                    //For TCL based input disable action
                    dayEntry.isCompleted = tcl.Completed__c ? tcl.Completed__c : false;

                    //Edit Icon display related conditions
                    dayEntry.status = day.Status__c;                                         
                    dayEntry.showEditIcon = TimeCardDayCommunityTranslator.editIconDisplay(dayEntry,isCurrentWeek,isBeforeLastWeek);
                    dayEntry.isHrsDisabled = true;
                    if (day.Status__c == 'Unposted') {
                        dayEntry.isHrsDisabled = false;
                        dayEntry.showEditIcon = false;
                    }
                    if( dayEntry.taskName == 'Fringe-Holiday') {
                        if(holidayDates.contains(dayEntry.dateVal)){
                            DateTime holidayDT = datetime.newInstance(dayEntry.dateVal, Time.newInstance(0,0,0,0));
                            String dayValue = holidayDT.format('E');// Exclude the 8 hours population for saturday and sunday if holidays occurs in saturday and sunday.
                        
                            if(dayValue != 'Sat' && dayValue != 'Sun'){
                                dayEntry.dayHours = 8 + '.00';
                            }
                        }
                        dayEntry.showEditIcon = false;
                        dayEntry.isHrsDisabled = true;
                    }
                    totHrs += day.Total_Hours_Before_Approved__c;                   
                    dateEntriesMap.put(day.AcctSeed__Date__c,dayEntry);    
                }
                chargeCodedateEntryMap.put(chargeCodeKey, dateEntriesMap);
                instructorDayDetailsMap.get(chargeCodeKey).dayEntries = dateEntriesMap.values();   
                instructorDayDetailsMap.get(chargeCodeKey).totalHours = String.valueOf(totHrs);
            }

            for (String chargeCdKey : chargeCodedateEntryMap.keySet()) {
                Map<Date, TimeCardDayCommunityDomain.DayEntries> dateEntriesMap = chargeCodedateEntryMap.get(chargeCdKey);
            
                for (Date dayEntry : dateEntriesMap.keySet()) {
                    TimeCardDayCommunityDomain.DayEntries entry = dateEntriesMap.get(dayEntry);
                    entry.isCompleted = taskIdLineCompleted.containsKey(entry.taskId) ? taskIdLineCompleted.get(entry.taskId) : false;
                }
                instructorDayDetailsMap.get(chargeCdKey).dayEntries = dateEntriesMap.values();  
            }
    
        }  
        
        if (tcdIds.size()>0) {
            List<Accounting_Seed_Time_Snapshot__c> snapshot = accTimesnapshot;
            instructorRowDetails.notes = TimeCardDayCommunityTranslator.notesFormation(snapshot);
        }

        instructorRowDetails.entries = instructorDayDetailsMap.values();

        return instructorRowDetails;
    }
}