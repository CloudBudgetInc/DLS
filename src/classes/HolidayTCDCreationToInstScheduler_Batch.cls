/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 11/17/2023
 * @last modified by  : Dhinesh Kumar
**/
public with sharing class HolidayTCDCreationToInstScheduler_Batch implements Database.Batchable<SObject>, Schedulable, Database.Stateful{
    public Date startDate;
    public Date endDate;
    public Set<Date> holidayDates;

    public void execute(SchedulableContext sc){
        HolidayTCDCreationToInstScheduler_Batch b = new HolidayTCDCreationToInstScheduler_Batch();
        database.executebatch(b,50);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {  
        String projectRT_HolidayTCDCreation = System_Values__c.getValues('ProjectRT_HolidayTCDCreation').Value__c;
        List<String> projectRT = projectRT_HolidayTCDCreation.split(',');
        Date today = system.today();       
        Datetime dtime = datetime.newInstance(today.toStartofWeek(), Time.newInstance(0,0,0,0));
        String startOfWeek = dtime.format('EEE');      
        if(today.toStartofWeek() == today) {
            startDate = today.addDays(-1).toStartofWeek().addDays((startOfWeek == 'Sat') ? 2 : 1);
        }else {
            startDate = today.toStartofWeek().addDays((startOfWeek == 'Sat') ? 2 : 1);
        }        
        endDate = startDate.addDays(6); 
        holidayDates = HolidayService.getHolidaysWithRecurrence(startDate,endDate); 
        
        if(holidayDates.size() < 1){
            return Database.getQueryLocator([SELECT Id FROM Schedule__c WHERE Name = null]);
        }else{
            return Database.getQueryLocator(
                'SELECT Id, Project__c, Project__r.Training_Location__c, Project_Task__c, Instructor__c, Project_Task__r.Payroll_Item__c, '+
                'Project_Task__r.Billable__c FROM Schedule__c '+
                'WHERE Instructor__c != null AND Instructor__r.RecordType.DeveloperName = \'Candidate\' AND '+
                'Project_Task__r.Project_Task_Type__c = \'Fringe\' AND Project_Task__r.Name = \'Fringe-Holiday\' AND '+
                'Project__r.RecordType.DeveloperName IN :projectRT AND Status__c IN (\'Active\',\'Completed\') AND Start_Date__c <= :endDate '+
                'AND End_Date__c >= :startDate'            
            );
        }
    }

    public void execute(Database.BatchableContext context, List<Schedule__c> schedules) {
        Set<Id> instructorIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();
        
        for(Schedule__c sch: schedules){
            instructorIds.add(sch.Instructor__c);
            projectIds.add(sch.Project__c);
        }
                
        Date caFilterDt = startDate.addDays(-14);
        Map<String, Id> costRateIdAndDateMap = new Map<String, Id>();
        Map<String, Id> contactAssignIdAndDateMap = new Map<String, Id>();     
        
        for(Contact_Assignments__c ca : [SELECT Id, Project__c, Candidate_Name__c, Start_Date__c, End_Date__c, Rate_Card_Rate__c FROM Contact_Assignments__c 
                                        WHERE Candidate_Name__c IN :instructorIds AND Project__c IN :projectIds 
                                        AND ((Status__c IN ('Active','On Hold') AND (Start_Date__c <= :endDate AND End_Date__c >= :startDate)) 
                                        OR (Status__c IN ('Ended') AND  End_Date__c >= :caFilterDt)) AND Paper_Timesheet__c = false]){
            for(Date holidayDate: holidayDates){                                
                if(holidayDate >= ca.Start_Date__c && holidayDate <= ca.End_Date__c){
                    costRateIdAndDateMap.put(String.valueOf(holidayDate)+'~'+ca.Project__c+'~'+ca.Candidate_Name__c, ca.Rate_Card_Rate__c);
                    contactAssignIdAndDateMap.put(ca.Project__c+'~'+ca.Candidate_Name__c, ca.Id);                    
                }
            }
        }	
        
        TimesheetPage_RelatedCtrl.accountingPeriodCreation(startDate,endDate);  
        String weekRangeStr = TimeEntryUtil.getOnlyDate(startDate)+'~'+TimeEntryUtil.getOnlyDate(endDate);
        Map<String, Id> startAndEndDateWithTimeCardPeriodIdMap = TimeEntryUtil.timeCardPeriodCreation(new Set<Date>{startDate}, new Set<Date>{endDate}, new Set<String>{weekRangeStr});
        Map<String, AcctSeed__Time_Card__c> insIdAndTimeCardPeriodIdWithTimeCardMap = TimeEntryUtil.getTimeCard(instructorIds, new Set<Id>(startAndEndDateWithTimeCardPeriodIdMap.values()));        
        Set<String> timeCardLineKeySet = new Set<String>();
        Set<Id> timeCardIds = new Set<Id>();
        Set<Id> projectTaskIds = new Set<Id>();
        Set<Boolean> billable = new Set<Boolean>();
        Set<String> payrollItem = new Set<String>();
        Map<String, String> timeCardLineKeyWithProjectIdMap = new Map<String, String>();
        
        for(Schedule__c sch: schedules){
            String timeCardKey = sch.Instructor__c+'~'+startAndEndDateWithTimeCardPeriodIdMap.get(weekRangeStr);
            String timeCardId = insIdAndTimeCardPeriodIdWithTimeCardMap.get(timeCardKey).Id;
            timeCardIds.add(timeCardId);
            String timeCardLineKey = timeCardId+'~'+sch.Project_Task__c+'~'+sch.Project_Task__r.Billable__c+'~'+sch.Project_Task__r.Payroll_Item__c+'~'+sch.Project__r.Training_Location__c;
            timeCardLineKeySet.add(timeCardLineKey); 
            StaffTimeEntryController.timeCardLineKeyWithConAssignIdMap.put(timeCardLineKey, contactAssignIdAndDateMap.get(sch.Project__c+'~'+sch.Instructor__c));
            timeCardLineKeyWithProjectIdMap.put(timeCardLineKey, sch.Project__c);           
            projectTaskIds.add(sch.Project_Task__c);
            billable.add(sch.Project_Task__r.Billable__c);
            payrollItem.add(sch.Project_Task__r.Payroll_Item__c);
        }

        if(timeCardIds.size() > 0){
            List<Accounting_Seed_Time_Snapshot__c> tcdSnapshot = new List<Accounting_Seed_Time_Snapshot__c>();
            List<AcctSeed__Time_Card_Day__c> dayListToUpsert = new List<AcctSeed__Time_Card_Day__c>();
            Map<String, AcctSeed__Time_Card_Line__c> insIdAndTimeCardPeriodIdWithTimeCardLineMap = TimeEntryUtil.getTimeCardLines(instructorIds, timeCardLineKeyWithProjectIdMap, timeCardIds, projectTaskIds, billable, payrollItem, timeCardLineKeySet);                
            
            for(Schedule__c sch: schedules){
                String timeCardKey = sch.Instructor__c+'~'+startAndEndDateWithTimeCardPeriodIdMap.get(weekRangeStr);
                String timeCardId = insIdAndTimeCardPeriodIdWithTimeCardMap.get(timeCardKey).Id;
                for(Date holidayDate: holidayDates){
                    String lineKey = timeCardId+'~'+sch.Project_Task__c+'~'+sch.Project_Task__r.Billable__c+'~'+sch.Project_Task__r.Payroll_Item__c+'~'+sch.Project__r.Training_Location__c;
                    String lineId = insIdAndTimeCardPeriodIdWithTimeCardLineMap.get(lineKey).Id;
                    AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
                    newDay.AcctSeed__Time_Card_Line__c = lineId;
                    newDay.AcctSeed__Date__c = holidayDate;
                    newDay.Total_Hours_Before_Approved__c = 8;
                    newDay.Status__c = 'Draft';
                    newDay.AcctSeed__Hours__c = 0;
                    newDay.Labor_Cost_Rate__c = costRateIdAndDateMap.get(String.valueOf(holidayDate)+'~'+sch.Project__c+'~'+sch.Instructor__c);
                    dayListToUpsert.add(newDay);
                }
            }
            
            upsert dayListToUpsert;           
        }                
    }

    public void finish(Database.BatchableContext context) {
        
    }
}