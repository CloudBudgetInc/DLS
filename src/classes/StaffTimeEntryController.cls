/**
 * @description       : Controller of component utilized by instructors to log their work hours for administrative tasks.
 * @author            : Dhinesh Kumar
 * @group             : Instructor Community
 * @last modified on  : 01/17/2024
 * @last modified by  : Dhinesh Kumar
**/
public without sharing class StaffTimeEntryController {
    
    /**
    * @description 
    * @author Dhinesh Kumar | 05/08/2023 
    * @return string 
    **/

    public static Map<Id,String> tcdIdNoteType = new Map<Id,String>();
    public static Boolean isGroupAction;
    public static String groupActionType;
    public static Map<String,String> timeCardLineKeyWithConAssignIdMap = new Map<String,String>();


    @AuraEnabled(cacheable = true)
    public static string getFilterInfo(){
        try {
            
            StaffTimeEntryDomain.Filter filter = StaffTimeEntryTranslator.StaffTimeEntry_initialFilterFormation();            

            Contact con = TimeEntryUtil.getUserContact();

            filter.employeeName = con.Name + (String.isNotBlank(con.PC_EE_ID__c) ? ' - '+con.PC_EE_ID__c : '');
            filter.supervisorName = con.Supervisor_Name__r.Name;
            filter.contactId = con.Id;

            filter.projectAndCA = (StaffTimeEntryDomain.projectAndCAInfo) JSON.deserialize(getProjectsByWeekrange(filter.contactId, filter.selectedWeek), StaffTimeEntryDomain.projectAndCAInfo.class);
            
            return JSON.serialize(filter);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Dhinesh Kumar | 05/10/2023 
    * @param conId 
    * @param weekRange 
    * @return List<ListViewController.PicklistWrap> 
    **/
    @AuraEnabled    
    public static String getProjectsByWeekrange(Id conId, String weekRange) {
        List<Date> dates = TimeEntryUtil.getDatesFromWeekRange(weekRange);
        Date startDate = dates[0];
        Date endDate = dates[1];
        Date caEndedFilterDate = startDate.addDays(-14);

        StaffTimeEntryDomain.projectAndCAInfo  projectAndCAInfo = new StaffTimeEntryDomain.projectAndCAInfo();
        List<ListViewController.PicklistWrap> projects = new List<ListViewController.PicklistWrap>(); 
        Map<Id, Contact_Assignments__c> projectIdWithCAMap = new Map<Id, Contact_Assignments__c>();

        for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Project__c, Project__r.Name, Project__r.DLS_Ref__c, Include_Fringe__c, Rate_Card_Rate__c 
                                        FROM Contact_Assignments__c 
                                        WHERE RecordType.DeveloperName = 'Staff' AND Candidate_Name__c = :conId AND
                                        ((Status__c IN ('Active','On Hold') AND Start_Date__c <= :endDate AND End_Date__c >= :startDate) OR
                                         (Status__c = 'Ended' AND End_Date__c >= :caEndedFilterDate))]){
            
            projects.add(new ListViewController.PicklistWrap(ca.Project__r.Name, ca.Project__c));
            projectIdWithCAMap.put(ca.Project__c, ca);
        }

        projectAndCAInfo.projectIdWithCAMap = projectIdWithCAMap;
        projectAndCAInfo.projects = projects;

        return JSON.serialize(projectAndCAInfo);
    }
    
    @AuraEnabled
    public static String getProjTaskAndTimeEnteredDetails(Id projectId, String weekRange, String caStr){
        try {

            Contact_Assignments__c ca = (Contact_Assignments__c) JSON.deserialize(caStr, Contact_Assignments__c.class);
            List<Date> dates = TimeEntryUtil.getDatesFromWeekRange(weekRange);
            Date startDate = dates[0];
            Date endDate = dates[1];

            AcctSeed__Project__c pro = [SELECT Id, Name, DLS_Ref__c, Training_Location__c, Training_Location__r.Name, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :projectId LIMIT 1];
        
            String projRecordType = '%' + pro.RecordType.DeveloperName + '%';
            Map<String, Project_Task_Master__c> projectTaskMasterMap = new Map<String, Project_Task_Master__c>();
            List<String> sortedProjTaskMaster = new List<String>();
    
            for(Project_Task_Master__c ptm : [SELECT Id,Name,Billable__c,Display_In_Time_Card__c,Labor_GL_Account__c, Payroll_Item__c,
                                            Project_Record_Type__c,Project_Task_Record_Type__c,Project_Task_Type__c, Project_Type__c,Unit__c,Sort_Order__c 
                                            FROM Project_Task_Master__c
                                            WHERE Project_Record_Type__c LIKE :projRecordType AND Internal_Staff_Entry_Sort_Order__c != null ORDER BY Internal_Staff_Entry_Sort_Order__c NULLS LAST]){
                
                String key = ptm.Name+'~'+ptm.Project_Task_Type__c;
                sortedProjTaskMaster.add(key);
                projectTaskMasterMap.put(key, ptm);
            }
    
            Map<String, AcctSeed__Project_Task__c> projTasksMap = new Map<String, AcctSeed__Project_Task__c>();
            Set<Id> projTaskIds = new Set<Id>();
            Set<String> excludeProjTaskTypes = new Set<String>{'Non-Compensatory','FMLA Non-Compensatory','FMLA','Fringe'};
            
            for(AcctSeed__Project_Task__c pt : [SELECT Id, Name, Project_Task_Type__c,Payroll_Item__c FROM AcctSeed__Project_Task__c 
                                                WHERE AcctSeed__Project__c = :projectId]){
                String ptKey = pt.Name+'~'+pt.Project_Task_Type__c;                
                if(projectTaskMasterMap.containsKey(ptKey) && (!excludeProjTaskTypes.contains(pt.Project_Task_Type__c) || ca.Include_Fringe__c )){
                    projTaskIds.add(pt.Id);
                    projTasksMap.put(ptKey, pt);
                }
            }
    
            TimeEntryUtil.TimeCardLineWrap timeCardLineWrapObj = TimeEntryUtil.getTCLAndTCDWithSnapShots(new Set<Id>{projectId}, projTaskIds, startDate, endDate, ca.Candidate_Name__c);
            
            List<AcctSeed__Time_Card_Line__c> timeCardLineList = TimeCardLineWrapObj.timeCardLineList;
            List<Accounting_Seed_Time_Snapshot__c> accTimesnapshot = TimeCardLineWrapObj.accTimesnapshot; 
                    
            TimeEntryUtil.WeekRangeEnteries weekRangeEnteries = TimeEntryUtil.getDateEntryForWeekRange(startDate, endDate);
            Map<Date,TimeCardDayCommunityDomain.DayEntries> dateEntryMap = weekRangeEnteries.dateEntryMap;
            Map<String,Map<Date,Id>> costRateAndContactAssignIdWithDateMap = TimeEntryUtil.getCostRateIdByDates(startDate, endDate, ca.Candidate_Name__c, projectId);
            Map<Date, Id> costRateIdAndDateMap = costRateAndContactAssignIdWithDateMap.get('CostRate');
            Map<Date, Id> contactAssignIdAndDateMap = costRateAndContactAssignIdWithDateMap.get('ContactAssignment');

            TimeCardDayCommunityDomain.InstructorRowDetails instructorRowDetails = StaffTimeEntryTranslator.getProjTaskAndTimeEnteredDetails(projectId, startDate, endDate, sortedProjTaskMaster,projTasksMap, projectTaskMasterMap, pro, dateEntryMap, costRateIdAndDateMap, contactAssignIdAndDateMap, timeCardLineList,  accTimesnapshot);

            List<TimeCardDayCommunityDomain.DayEntries> entriesList = new List<TimeCardDayCommunityDomain.DayEntries>();
            for(TimeCardDayCommunityDomain.InstructorDayDetails row : instructorRowDetails.entries){
                if(row.dayEntries != null && row.dayEntries.size() > 0) {
                    for (TimeCardDayCommunityDomain.DayEntries entry : row.dayEntries) {
                        if (entry.lineId != null) {
                            entriesList.add(entry);
                        }
                    }
                }
            }   

            TimeCardDayCommunityDomain.ButtonDisplay btnDisplay = TimeCardDayCommunityTranslator.buttonDisplayFunction(entriesList,startDate,endDate);
            instructorRowDetails.displayRecallBtn = btnDisplay.recallBtn;
            instructorRowDetails.displayCompleteBtn = btnDisplay.completeBtn;

            instructorRowDetails.weekDates = weekRangeEnteries.weekRangeValues;

            for(TimeCardDayCommunityDomain.InstructorDayDetails row : instructorRowDetails.entries){
                if(row.dayEntries != null && row.dayEntries.size() > 0) {
                    for(TimeCardDayCommunityDomain.DayEntries day : row.dayEntries){
                        if(instructorRowDetails.displayRecallBtn && !day.isHrsDisabled){
                            day.isHrsDisabled = true;
                            day.showEditIcon = false;
                        }
                    }
                }
            }
            
            return JSON.serialize(instructorRowDetails);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Used to save the internal time entries from instructor community page 
    * @author Dhinesh Kumar | 08/22/2023 
    * @param weekRange
    * @param conId 
    * @param timeCardDaysStr 
    * @param projectId 
    * @return string 
    **/
    @AuraEnabled
    public static String saveStaffTimeEntries(String weekRange, String conId,String timeCardDaysStr,String projectId){
        String result = 'success';
        try {
            List<TimeCardDayCommunityDomain.DayEntries> timeCardDays = (List<TimeCardDayCommunityDomain.DayEntries>) System.JSON.deserialize(timeCardDaysStr, List<TimeCardDayCommunityDomain.DayEntries>.class);
            List<Date> dates = TimeEntryUtil.getDatesFromWeekRange(weekRange);
            Date startDate = dates[0];
            Date endDate = dates[1];
            TimesheetPage_RelatedCtrl.accountingPeriodCreation(startDate,endDate);   
            String weekRangeStr = TimeEntryUtil.getOnlyDate(startDate)+'~'+TimeEntryUtil.getOnlyDate(endDate);
            Map<String, Id> startAndEndDateWithTimeCardPeriodIdMap = TimeEntryUtil.timeCardPeriodCreation(new Set<Date>{startDate}, new Set<Date>{endDate}, new Set<String>{weekRangeStr});
            Map<String, AcctSeed__Time_Card__c> insIdAndTimeCardPeriodIdWithTimeCardMap = TimeEntryUtil.getTimeCard(conId, new Set<Id>(startAndEndDateWithTimeCardPeriodIdMap.values()));
            String timeCardKey = conId+'~'+startAndEndDateWithTimeCardPeriodIdMap.get(weekRangeStr);
            Set<String> timeCardLineKeySet = new Set<String>();
            Set<Id> timeCardIds = new Set<Id>();
            Set<Id> projectTaskIds = new Set<Id>();
            Set<Boolean> billable = new Set<Boolean>();
            Set<String> payrollItem = new Set<String>();   
                    
            if(insIdAndTimeCardPeriodIdWithTimeCardMap.containsKey(timeCardKey)){
                
                String timeCardId = insIdAndTimeCardPeriodIdWithTimeCardMap.get(timeCardKey).Id;
                timeCardIds.add(timeCardId);
                for(TimeCardDayCommunityDomain.DayEntries day: timeCardDays){
                    timeCardLineKeySet.add(timeCardId+'~'+day.taskId+'~'+day.isBillable+'~'+day.payrollItem+'~'+day.locationId);
                    timeCardLineKeyWithConAssignIdMap.put(timeCardId+'~'+day.taskId+'~'+day.isBillable+'~'+day.payrollItem+'~'+day.locationId, day.contactAssignid);
                    projectTaskIds.add(day.taskId);
                    billable.add(day.isBillable);
                    payrollItem.add(day.payrollItem);
                }
            }

            if(timeCardIds.size() > 0){
                List<Accounting_Seed_Time_Snapshot__c> tcdSnapshot = new List<Accounting_Seed_Time_Snapshot__c>();
                List<AcctSeed__Time_Card_Day__c> dayListToUpsert = new List<AcctSeed__Time_Card_Day__c>();
                Map<String, AcctSeed__Time_Card_Line__c> insIdAndTimeCardPeriodIdWithTimeCardLineMap = TimeEntryUtil.getTimeCardLines(conId, projectId, timeCardIds, projectTaskIds, billable, payrollItem, timeCardLineKeySet);                
                String timeCardId = insIdAndTimeCardPeriodIdWithTimeCardMap.get(timeCardKey).Id;
                for(TimeCardDayCommunityDomain.DayEntries day: timeCardDays){
                    String lineKey = timeCardId+'~'+day.taskId+'~'+day.isBillable+'~'+day.payrollItem+'~'+day.locationId;
                    String lineId = insIdAndTimeCardPeriodIdWithTimeCardLineMap.get(lineKey).Id;
                    AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
                    newDay.AcctSeed__Time_Card_Line__c = lineId;
                    newDay.AcctSeed__Date__c = day.dateVal;
                    newDay.Total_Hours_Before_Approved__c = Decimal.valueOf(day.dayHours);
                    newDay.AcctSeed__Internal_Comment__c = day.comments;
                    newDay.Status__c = day.status;
                    newDay.AcctSeed__Hours__c = 0;
                    newDay.Labor_Cost_Rate__c = day.costrateId;

                    if(String.isNotEmpty(day.dayId)){
                        newDay.Id = day.dayId;
                        tcdIdNoteType.put(day.dayId,'TCD Edit');
                    }
                    dayListToUpsert.add(newDay);
                }
                upsert dayListToUpsert;
                
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<AcctSeed__Time_Card_Line__c> completeTimeEntries(String timeCardDaysStr){

        try {
            String result = 'Complete';
            List<TimeCardDayCommunityDomain.DayEntries> timeCardDays = (List<TimeCardDayCommunityDomain.DayEntries>) System.JSON.deserialize(timeCardDaysStr, List<TimeCardDayCommunityDomain.DayEntries>.class);
            List<AcctSeed__Time_Card_Line__c> updateTCLList = new List<AcctSeed__Time_Card_Line__c>();

            for (TimeCardDayCommunityDomain.DayEntries  day : timeCardDays) {
                if(!(new Map<Id, AcctSeed__Time_Card_Line__c>(updateTCLList).keySet().contains(day.lineId))){    
                    AcctSeed__Time_Card_Line__c cardlineRec = new AcctSeed__Time_Card_Line__c();
                    cardlineRec.Id = day.lineId;
                    cardlineRec.Completed__c = true;
                    updateTCLList.add(cardlineRec);
                }
            }
            if (updateTCLList.size()>0) {
                update updateTCLList;
            }
        return updateTCLList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    @AuraEnabled
    public static String recallExistingTimeEntries(String timeDayJson,String typeOfAction){
    
        try {
            
            isGroupAction = true;
            groupActionType = 'Recalled';
            InstructorTimeEntry_Controller.recallExistingTimeEntries(timeDayJson, typeOfAction);
            return 'SUCCESS';

        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}