public class PartnerSchoolTimeSheetUploadCtrl {
    
    @AuraEnabled(cacheable=true)
    public static String getInstructorIdsByProjectId(String projectId){
        Set<String> instructorIds = new Set<String>();
        for(Contact_Assignments__c caRecord : [SELECT Id,Name,Candidate_Name__c
                                               FROM Contact_Assignments__c 
                                               WHERE Project__c = :projectId AND RecordType.DeveloperName = 'Instructor']){
                                                   instructorIds.add(caRecord.Candidate_Name__c);                                           
                                               }
        
        return JSON.serialize(instructorIds);
    }
    
    @AuraEnabled
    public static String saveTimeEntries(String projectId, String instructorId,String taskStr,String weekRangeStrWithDayMapStr, Boolean checkOnly){
        try{            
            Set<Date> startDates = new Set<Date>();
            Set<Date> endDates = new Set<Date>();       
            Map<String, List<TimeCardDayCommunityDomain.DayEntries>> weekRangeStrWithDayMap = (Map<String,List<TimeCardDayCommunityDomain.DayEntries>>) System.JSON.deserialize(weekRangeStrWithDayMapStr, Map<String,List<TimeCardDayCommunityDomain.DayEntries>>.class);
            AcctSeed__Project_Task__c task = (AcctSeed__Project_Task__c) JSON.deserialize(taskStr, AcctSeed__Project_Task__c.class);
            Set<String> timeCardLineKeySet = new Set<String>();
            Set<Id> projectTaskIds = new Set<Id>();
            Set<Boolean> billable = new Set<Boolean>();
            Set<String> payrollItem = new Set<String>();
            Set<String> dateAlreadyExists = new Set<String>();
            Map<String, List<TimeCardDayCommunityDomain.DayEntries>> existingDayRec = new Map<String, List<TimeCardDayCommunityDomain.DayEntries>>();
            List<Contact_Assignments__c> caRecord = [SELECT Id,Name,Rate_Card_Rate__c,Rate_Card_Rate__r.Payroll_Item__c,Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Project_Task__c, Start_Date__c, End_Date__c, Oral_Exam_Date_Time__c
                                                     FROM Contact_Assignments__c 
                                                     WHERE Project__c = :projectId AND Candidate_Name__c = :instructorId];
            
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
            Date startDt;
            Date endDt;
            for(String weekRangeStr : weekRangeStrWithDayMap.keySet()){
                List<String> startAndEndDateStrList = weekRangeStr.split('~');
                Date startDate = Date.valueOf(startAndEndDateStrList[0]);
                Date EndDate = Date.valueOf(startAndEndDateStrList[1]);
                startDates.add(startDate);
                endDates.add(EndDate);  
                if(startDt == null || startDate < startDt){
                    startDt = startDate;
                }
                if(endDt == null || EndDate > endDt ){
                    endDt = EndDate;
                }
            }
            TimeEntryUtil.checkOnly = checkOnly;
            TimesheetPage_RelatedCtrl.accountingPeriodCreation(startDt,endDt);
            Map<String, Id> startAndEndDateWithTimeCardPeriodIdMap = TimeEntryUtil.timeCardPeriodCreation(startDates, endDates, weekRangeStrWithDayMap.keySet());
            if(startAndEndDateWithTimeCardPeriodIdMap.size() > 0){
                Map<String, AcctSeed__Time_Card__c> insIdAndTimeCardPeriodIdWithTimeCardMap = TimeEntryUtil.getTimeCard(instructorId, new Set<Id>(startAndEndDateWithTimeCardPeriodIdMap.values()));
                Set<Id> timeCardIds = new Set<Id>();
                weekRangeStrWithDayMap = (Map<String,List<TimeCardDayCommunityDomain.DayEntries>>) System.JSON.deserialize(weekRangeStrWithDayMapStr, Map<String,List<TimeCardDayCommunityDomain.DayEntries>>.class);
                for(String weekRangeStr : weekRangeStrWithDayMap.keySet()){
                    
                    if(startAndEndDateWithTimeCardPeriodIdMap.containsKey(weekRangeStr)){
                        String timeCardKey = instructorId+'~'+startAndEndDateWithTimeCardPeriodIdMap.get(weekRangeStr);
                        
                        if(insIdAndTimeCardPeriodIdWithTimeCardMap.containsKey(timeCardKey)){
                            String timeCardId = insIdAndTimeCardPeriodIdWithTimeCardMap.get(timeCardKey).Id;
                            timeCardIds.add(timeCardId);
                            for(TimeCardDayCommunityDomain.DayEntries day: weekRangeStrWithDayMap.get(weekRangeStr)){
                                day = TimeEntryUtil.populateCostRateAndPayRollItemInDayEntry(day.dateVal , day, caHistory, oldCRRecord, caRecord, task);
                                timeCardLineKeySet.add(timeCardId+'~'+day.taskId+'~'+day.isBillable+'~'+day.payrollItem+'~'+day.locationId);
                                projectTaskIds.add(day.taskId);
                                billable.add(day.isBillable);
                                payrollItem.add(day.payrollItem);
                            }
                        }
                    }
                }
                System.debug('timeCardIds::>'+timeCardIds);
                System.debug('instructorId::>'+instructorId);
                System.debug('projectId::>'+projectId);
                System.debug('projectTaskIds::>'+projectTaskIds);
                System.debug('billable::>'+billable);
                System.debug('payrollItem::>'+payrollItem);
                System.debug('timeCardLineKeySet::>'+timeCardLineKeySet);
                if(timeCardIds.size() > 0){
                    Map<String, AcctSeed__Time_Card_Line__c> insIdAndTimeCardPeriodIdWithTimeCardLineMap = TimeEntryUtil.getTimeCardLines(instructorId, projectId, timeCardIds, projectTaskIds, billable, payrollItem, timeCardLineKeySet);
                    if(insIdAndTimeCardPeriodIdWithTimeCardLineMap.size() > 0){
                        Map<String, Id> timeCardDayIdMap = TimeEntryUtil.getTimeCardDayByTimeCardLine((new Map<Id, AcctSeed__Time_Card_Line__c>(insIdAndTimeCardPeriodIdWithTimeCardLineMap.values())).keySet());
                        List<AcctSeed__Time_Card_Day__c> dayListToUpsert = new List<AcctSeed__Time_Card_Day__c>();
                        for(String weekRangeStr : weekRangeStrWithDayMap.keySet()){
                            if(startAndEndDateWithTimeCardPeriodIdMap.containsKey(weekRangeStr)){
                                String timeCardKey = instructorId+'~'+startAndEndDateWithTimeCardPeriodIdMap.get(weekRangeStr);
                                String timeCardId = insIdAndTimeCardPeriodIdWithTimeCardMap.get(timeCardKey).Id;
                                for(TimeCardDayCommunityDomain.DayEntries day: weekRangeStrWithDayMap.get(weekRangeStr)){
                                    String lineKey = timeCardId+'~'+day.taskId+'~'+day.isBillable+'~'+day.payrollItem+'~'+day.locationId;
                                    String lineId = insIdAndTimeCardPeriodIdWithTimeCardLineMap.get(lineKey).Id;
                                    if(!checkOnly && !timeCardDayIdMap.containsKey(lineId+'~'+TimeEntryUtil.getOnlyDate(day.dateVal))){
                                        AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
                                        newDay.AcctSeed__Time_Card_Line__c = lineId;
                                        newDay.AcctSeed__Date__c = day.dateVal;
                                        newDay.Total_Hours_Before_Approved__c = Decimal.valueOf(day.dayHours);
                                        newDay.AcctSeed__Internal_Comment__c = day.comments;
                                        newDay.Status__c = day.status;
                                        newDay.AcctSeed__Hours__c = Decimal.valueOf(day.dayHours);
                                        newDay.Labor_Cost_Rate__c = day.costrateId;
                                        
                                        if(timeCardDayIdMap.containsKey(lineId+'~'+TimeEntryUtil.getOnlyDate(day.dateVal))){
                                            newDay.Id = timeCardDayIdMap.get(lineId+'~'+TimeEntryUtil.getOnlyDate(day.dateVal));
                                        }
                                        
                                        if(day.TaskType != 'Preparation time') {
                                            newDay.Student_Approval_Status__c = day.studentApprovalStatus;
                                            newDay.Late_Cancellation__c = day.lateCancellation != null ? day.lateCancellation : false;
                                            newDay.Cancellation_Reason__c = day.cancellationReason;
                                        }
                                        System.debug('newDay::>'+newDay);
                                        dayListToUpsert.add(newDay);
                                    }else{
                                        dateAlreadyExists.add(TimeEntryUtil.getOnlyDate(day.dateVal));
                                    }
                                }
                            }
                        }
                        
                        if(dayListToUpsert.size() > 0 && !checkOnly){
                            upsert dayListToUpsert;
                        }
                    }
                }
            }
            
            if(dateAlreadyExists.size() > 0 && checkOnly){
             return 'Time is already available for the following dates: <br></br> ' + String.join(new List<String>(dateAlreadyExists), ', ') + '.<br></br>'; 
            }
            
            return 'success';
        }catch(Exception exe){
            return exe.getMessage();
        }
    }
}