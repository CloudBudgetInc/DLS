public class TimeSheetAppApexController {
    
    @AuraEnabled
    public static List<agf__ADM_Work__c> getWorkItems()
    {
        List<agf__ADM_Work__c> workTemp = new List<agf__ADM_Work__c>();
        List<agf__ADM_Work__c> closedWorkTemp = new List<agf__ADM_Work__c>();
        List<agf__ADM_Work__c> sharedWorkTemp = new List<agf__ADM_Work__c>();
        List<agf__ADM_Work__c> getWorkItems = new List<agf__ADM_Work__c >();
        
        //Get Profile of current running user
        List<Profile> currUserProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String currUserProfileName = currUserProfile[0].Name;
        
        if (currUserProfileName != 'MB&A Partner Community'){
            workTemp = [SELECT Id, agf__Assignee__c, agf__Subject__c,  Name, agf__Status__c, Shared_for_all_Employees__c 
                        FROM agf__ADM_Work__c 
                        WHERE ((agf__Assignee__c=:UserInfo.getUserId() OR agf__QA_Engineer__c = :UserInfo.getUserId()) AND agf__Status__c != 'Closed') order by agf__Subject__c];
            for(agf__ADM_Work__c temp : workTemp)
            {
                getWorkItems.add(temp);
            }
            system.debug(':::::::::getWorkItems:::::'+getWorkItems.size());
            sharedWorkTemp = [Select Id, agf__Assignee__c, agf__Subject__c, name, agf__Status__c, Shared_for_all_Employees__c From agf__ADM_Work__c where Shared_for_all_Employees__c = True]; 
            for(agf__ADM_Work__c temp : sharedWorkTemp)
            {
                getWorkItems.add(temp);
            }
            system.debug('::::::::getWorkItems:::::::::::::'+getWorkItems.size());
        } else {
            workTemp = [SELECT Id, agf__Assignee__c, agf__Subject__c,  Name, agf__Status__c, Shared_for_all_Employees__c 
                        FROM agf__ADM_Work__c 
                        WHERE ((ExAM_Work_Item__c = true) AND agf__Status__c != 'Closed') order by agf__Subject__c];
            for(agf__ADM_Work__c temp : workTemp)
            {
                getWorkItems.add(temp);
            }
            //block of code to (xx temporarily- changed to 48 hour access) allow access to closed work items within 48 hours (xx a week) of closed
            closedWorkTemp = [SELECT Id, agf__Assignee__c, agf__Subject__c,  Name, agf__Status__c, Shared_for_all_Employees__c 
                              FROM agf__ADM_Work__c 
                              WHERE ((ExAM_Work_Item__c = true) AND agf__Status__c = 'Closed' AND agf__Closed_On__c = LAST_N_DAYS:2) order by agf__Subject__c];
            for(agf__ADM_Work__c temp : closedWorkTemp)
            {
                getWorkItems.add(temp);
            }
        }
        
        return getWorkItems;
    }
    
    @AuraEnabled
    public static List<MBA_Timesheet__c> setAllTimeInputs(List<MBA_Timesheet__c> timeInputs){
        //Get Work record Ids
        System.debug('Time Input length: '+ timeInputs.size());
        List<Id> workIds = new List<Id>();
        Map<Id,String> workIdSubject = new Map<Id,String>();
        
        for (MBA_Timesheet__c timeTemp:timeInputs){
            system.debug('timeTemp.MBA_Work_Item_Lookup__c: '+timeTemp.MBA_Work_Item_Lookup__c );
            workIds.add(timeTemp.MBA_Work_Item_Lookup__c);
            system.debug('Work Id:' + workIds);
            system.debug('Time temp date: '+timeTemp.Date_of_Work__c);
        }
        System.debug('Work Ids:  ' + workIds);
        
        //Qry WorkItems information
        for(agf__ADM_Work__c work : [SELECT Id,agf__Subject__c FROM agf__ADM_Work__c WHERE Id IN :workIds]){
            if(!workIdSubject.containsKey(work.Id)){
                workIdSubject.put(work.Id,work.agf__Subject__c);
            }
        }
        system.debug('::::::::workIdSubject:::::'+workIdSubject);
        for (MBA_Timesheet__c timeInput:timeInputs){
            //timeInput.Subject__c = timeInput.Description__c;
            if(timeInput.Description__c != null && timeInput.Description__c.length() > 80){
                timeInput.Name = timeInput.Description__c.substring(0,80);
            }else if(timeInput.Description__c != null && timeInput.Description__c.length() < 80 && timeInput.Description__c.length() != 0){
                timeInput.Name = timeInput.Description__c;
            }else if(timeInput.Description__c.length() == 0){
                
                String subject = workIdSubject.containsKey(timeInput.MBA_Work_Item_Lookup__c) ? workIdSubject.get(timeInput.MBA_Work_Item_Lookup__c) : null;
                if(subject.length() > 80){
                    timeInput.Name = subject.substring(0,80);
                }else {
                    timeInput.Name = subject;
                }
            }
            timeInput.MBA_Assignee__c = UserInfo.getUserId();
        }
        System.debug('timeInputs: ' + timeInputs);
        try{
            insert timeInputs;
        }
        catch (DmlException e) {
            // "Convert" the exception into an AuraHandledException
            //throw new AuraHandledException('Darn it! Something went wrong: '
            //+ e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Error Id of Record: ' + e.getDmlId(0));
            System.debug('Error field names: ' + e.getDmlFieldNames(0));
            System.debug('Error DML Message: ' + e.getDmlMessage(0));
        }

        return timeInputs;
    }
    @AuraEnabled
    public static List<MBA_Timesheet__c> getTimeRecordsFromDb(String timePeriod){
        List<MBA_Timesheet__c> timeRecords = new List<MBA_Timesheet__c>();
        
        //construct list of time sheet records
        if(timePeriod == 'Today'){
            System.debug('Today');
            timeRecords = [SELECT Id, Name, MBA_Work_Item_Lookup__c, Work_Item_Name__c, Hours_Manual__c, Date_of_Work__c, Work_Item_Link__c, isNotEditable__c, Description__c
                           FROM MBA_Timesheet__c
                           WHERE MBA_Assignee__c  =:UserInfo.getUserId() AND Date_of_Work__c = TODAY];
            //System.debug('Time today: ' + timeRecords);
        } else if(timePeriod == 'Yesterday') {
            System.debug('Yesterday');
            timeRecords = [SELECT Id, Name, MBA_Work_Item_Lookup__c, Work_Item_Name__c, Hours_Manual__c, Date_of_Work__c, Work_Item_Link__c, isNotEditable__c, Description__c
                           FROM MBA_Timesheet__c
                           WHERE MBA_Assignee__c  =:UserInfo.getUserId() AND Date_of_Work__c = YESTERDAY];       
        } else if(timePeriod == 'This Week') {
            timeRecords = [SELECT Id, Name, MBA_Work_Item_Lookup__c, Work_Item_Name__c, Hours_Manual__c, Date_of_Work__c, Work_Item_Link__c, isNotEditable__c, Description__c
                           FROM MBA_Timesheet__c
                           WHERE MBA_Assignee__c  =:UserInfo.getUserId() AND Date_of_Work__c = THIS_WEEK];
        } else if(timePeriod == 'Last Week') {
            timeRecords = [SELECT Id, Name, MBA_Work_Item_Lookup__c, Work_Item_Name__c, Hours_Manual__c, Date_of_Work__c, Work_Item_Link__c, isNotEditable__c, Description__c 
                           FROM MBA_Timesheet__c
                           WHERE MBA_Assignee__c  =:UserInfo.getUserId() AND Date_of_Work__c = LAST_WEEK];
        } else if(timePeriod == 'This Month') {
            timeRecords = [SELECT Id, Name, MBA_Work_Item_Lookup__c, Work_Item_Name__c, Hours_Manual__c, Date_of_Work__c, Work_Item_Link__c, isNotEditable__c, Description__c
                           FROM MBA_Timesheet__c
                           WHERE MBA_Assignee__c  =:UserInfo.getUserId() AND Date_of_Work__c = THIS_MONTH];
        } else if(timePeriod == 'Last Month') {
            timeRecords = [SELECT Id, Name, MBA_Work_Item_Lookup__c, Work_Item_Name__c, Hours_Manual__c, Date_of_Work__c, Work_Item_Link__c, isNotEditable__c, Description__c
                           FROM MBA_Timesheet__c
                           WHERE MBA_Assignee__c  =:UserInfo.getUserId() AND Date_of_Work__c = LAST_MONTH];
        } 
        return timeRecords;
    }
    @AuraEnabled
    public static List<double> getTimeTotalsFromDb(){
        List<double> timePeriodTotal = new List<double>();
        //Today
        AggregateResult[] groupedResultsT = [Select sum(Hours_Manual__c) sum  FROM MBA_Timesheet__c  WHERE MBA_Assignee__c  =:UserInfo.getUserId() AND Date_of_Work__c = TODAY];
        if(double.valueOf(groupedResultsT[0].get('sum')) != null)
            timePeriodTotal.add(double.valueOf(groupedResultsT[0].get('sum')));
        else
            timePeriodTotal.add(double.valueOf(0));
        //Yesterday
        AggregateResult[] groupedResultsY = [Select sum(Hours_Manual__c) sum  FROM MBA_Timesheet__c  WHERE MBA_Assignee__c  =:UserInfo.getUserId() AND Date_of_Work__c = YESTERDAY];
        if(double.valueOf(groupedResultsY[0].get('sum')) != null)
            timePeriodTotal.add(double.valueOf(groupedResultsY[0].get('sum')));
        else
            timePeriodTotal.add(double.valueOf(0)); 
        //This Week
        AggregateResult[] groupedResultsTW = [Select sum(Hours_Manual__c) sum  FROM MBA_Timesheet__c  WHERE MBA_Assignee__c  =:UserInfo.getUserId() AND Date_of_Work__c = THIS_WEEK];
        if(double.valueOf(groupedResultsTW[0].get('sum')) != null)
            timePeriodTotal.add(double.valueOf(groupedResultsTW[0].get('sum')));
        else
            timePeriodTotal.add(double.valueOf(0));   
        //Last Week
        AggregateResult[] groupedResultsLW = [Select sum(Hours_Manual__c) sum  FROM MBA_Timesheet__c  WHERE MBA_Assignee__c  =:UserInfo.getUserId() AND Date_of_Work__c = LAST_WEEK];
        if(double.valueOf(groupedResultsLW[0].get('sum')) != null)
            timePeriodTotal.add(double.valueOf(groupedResultsLW[0].get('sum')));
        else
            timePeriodTotal.add(double.valueOf(0));  
        //This Month
        AggregateResult[] groupedResultsTM = [Select sum(Hours_Manual__c) sum  FROM MBA_Timesheet__c  WHERE MBA_Assignee__c  =:UserInfo.getUserId() AND Date_of_Work__c = THIS_MONTH];
        if(double.valueOf(groupedResultsTM[0].get('sum')) != null)
            timePeriodTotal.add(double.valueOf(groupedResultsTM[0].get('sum')));
        else
            timePeriodTotal.add(double.valueOf(0));  
        //Last Month
        AggregateResult[] groupedResultsLM = [Select sum(Hours_Manual__c) sum  FROM MBA_Timesheet__c  WHERE MBA_Assignee__c  =:UserInfo.getUserId() AND Date_of_Work__c = LAST_MONTH];
        if(double.valueOf(groupedResultsLM[0].get('sum')) != null)
            timePeriodTotal.add(double.valueOf(groupedResultsLM[0].get('sum')));
        else
            timePeriodTotal.add(double.valueOf(0));        
        return timePeriodTotal;
    }
    @AuraEnabled
    public static MBA_Timesheet__c getRecordToEditFromDb (String recId){
        system.debug('record Id: ' + recId);
        return [SELECT Id, Name, MBA_Work_Item_Lookup__c, Work_Item_Name__c, Hours_Manual__c, Date_of_Work__c, 
                       Work_Item_Link__c, isNotEditable__c, Description__c 
                FROM MBA_Timesheet__c
                WHERE Id = :recId];
    }
    @AuraEnabled
    public static void saveRecordToEditToDb (MBA_Timesheet__c recordToUpdate){
        if (recordToUpdate != NULL){
            update recordToUpdate;
        }
    }
    @AuraEnabled
    public static void deleteRecordFromDb (String recordToDelete){
        System.debug('Id of record to delete: ' + recordToDelete);
        if (recordToDelete != NULL){
            MBA_Timesheet__c recToDelete = [SELECT Id, isNotEditable__c FROM MBA_Timesheet__c 
                                            WHERE Id = :recordToDelete ];        
            if (!recToDelete.isNotEditable__c){
                system.debug('Record to delete Id: '+ recToDelete.Id);
                delete recToDelete;
            }
        }    
    }
}