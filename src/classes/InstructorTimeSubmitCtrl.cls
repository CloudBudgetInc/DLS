/************************************************************************************
- Class to Review & Submit the Instructor Time Entries
- Created by NS on July 28 2019
************************************************************************************/

public without sharing class InstructorTimeSubmitCtrl {
    
    //Below static variables for mentions the group action type from timesheet page
    public static Boolean isGroupAction;
    public static String groupActionType;
    
    //static map to hold the TCD & types of changes related info to form the Notes
    //Work Item No : W-001481
    public static Map<Id,String> tcdIdNoteType = new Map<Id,String>();
    
    /****************************************************************************************
    - Method to get the Weeks which time entries are not submitted to the Supervisor
    ****************************************************************************************/
    @AuraEnabled
    public static String getWeekRangeFilterValues(){
        
        Id usrId = UserInfo.getUserId();
        
        //Qry User record to get the Email address to get the exact match for the user in contact level
        List<User> usrRec = [SELECT Id,Name,Email,ContactId FROM User WHERE Id = :usrId];
        system.debug(':::::::::usrRec:::::'+usrRec);
        
        List<Contact> conRecList = new List<Contact>();
        
        if(usrRec.size() > 0 && usrRec[0].ContactId != null) {
            conRecList = [SELECT Id,Name,PC_EE_ID__c FROM Contact WHERE Id = :usrRec[0].ContactId];
        }
        
        Set<Date> dateSet = new Set<Date>();
        Set<String> weekRangeSet = new Set<String>();
        List<String> weekRangeList = new List<String>();
        Set<Date> wholeDateSet = new Set<Date>();
        
        //Week Range formation
        Date today = system.today();
        Date currst;
        
        //if today = sunday need to load the last week data - because saleforce start of the week is sunday
        if(today.toStartofWeek() == today) {
            currst = today.addDays(-1).toStartofWeek().addDays(1);
        }else {
            currst = today.toStartofWeek().addDays(-6);
        }
        
        Date currend = currst.addDays(6);
        
        Date stDate = currst;
        Date endDate = currend.addDays(7);
        
        //W-006759 - To display future 2 weeks for UAE instructors to enter fringe times
        //Added by NS on June 16 2021
        Boolean displayFutureWeeks = false;
        
        if(conRecList.size() > 0){
            
            List<Contact_Assignments__c> conAssignList = [SELECT Id,Name,Status__c FROM Contact_Assignments__c 
                                                            WHERE Candidate_Name__c = :conRecList[0].Id AND Project__r.RecordType.DeveloperName = 'EFL_Projects' 
                                                            AND End_Date__c > :currend];
            
            if(conAssignList.size() > 0 && conAssignList.size() == 1){
                displayFutureWeeks = true;
            }
        }
        
        if(displayFutureWeeks){
            endDate = currend.addDays(14);
        }/*else {
            endDate = currend;
        }*/

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
            
            if(!weekRangeSet.contains(stFinal+' to '+endFinal)) {
                weekRangeSet.add(stFinal+' to '+endFinal);
            }
        }
        system.debug('::::::::weekRangeSet:::::::'+weekRangeSet);
        weekRangeList.addAll(weekRangeSet);
        
        system.debug('::::::::::::weekRangeList::::'+weekRangeList);
        
        TimeCardDayCommunityDomain.InitialFilterValues initialFilter = TimeCardDayCommunityTranslator.instructor_initialFilterFormation(conRecList,weekRangeList,new List<String>{},new List<Topic>{});
        
        return JSON.serialize(initialFilter);
    }
    
    /****************************************************************************************
    - Method to get the non submitted time entries for submission based on the week selection
    ****************************************************************************************/
    @AuraEnabled
    public static string getCompletedTCDRecords(String startDt,String endDt){
        
        Date dt1 = Date.valueOf(startDt); 
        Date dt2 = Date.valueOf(endDt);
        
        Id usrId = UserInfo.getUserId();
            
        //Qry User record to get the Email address to get the exact match for the user in contact level
        List<User> usrRec = [SELECT Id,Name,Email,ContactId FROM User WHERE Id = :usrId];
        
        system.debug(':::::::::usrRec:::::'+usrRec);
        
        List<Contact> conRecList = new List<Contact>();
        
        Id contactId;
        
        if(usrRec.size() > 0 && usrRec[0].ContactId != null) {
            contactId = usrRec[0].ContactId;
        }
        
        
         List<AcctSeed__Time_Card_Day__c> tcdRecords = [SELECT Id,Name,AcctSeed__Date__c,Start_Time1__c,End_Time1__c,Start_Time2__c,End_Time2__c,Status__c,Total_Hours_Before_Approved__c,Week_Day__c,
                                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.DLS_Class__c, 
                                                                    AcctSeed__Time_Card_Line__r.Contact_Assignment__r.RecordType.DeveloperName, Submitted_Date_Time__c, 
                                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,
                                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c,Student_Approval_Status__c,AcctSeed__Time_Card_Line__r.Completed__c
                                                        FROM AcctSeed__Time_Card_Day__c
                                                        WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :contactId
                                                                AND AcctSeed__Date__c >= :dt1 AND AcctSeed__Date__c <= :dt2 AND Status__c != 'Unposted' ORDER BY AcctSeed__Date__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.DLS_Class__c ASC];
        
        Set<Id> projectIds = new Set<Id>();
        
        for(AcctSeed__Time_Card_Day__c day : tcdRecords){
            projectIds.add(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c);
        }
        
        system.debug('::::::::projectIds::::'+projectIds);
        
        //Thie date condition to filter the Projects based on the CA End Date values
        String caFilterDate = String.valueOf(dt1.addDays(-14)).split(' ')[0];
        Date caEndDate = Date.valueOf(caFilterDate);
        
        system.debug('::::::caEndDate:::'+caEndDate);
        
        List<AcctSeed__Project__c> projectRecords = [SELECT Id,Name,DLS_Class__c,RecordType.DeveloperName,RecordTypeId,
                                                        (SELECT Id,Candidate_Name__r.FirstName,Candidate_Name__r.LastName,Assignment_Position__c 
                                                            FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Student' AND (Status__c = 'Active' OR (Status__c = 'Ended' AND End_Date__c > :caEndDate))) 
                                                FROM AcctSeed__Project__c WHERE Id IN :projectIds];
        
        TimeCardDayCommunityDomain.ReviewSubmitTCDDetails details = TimeCardDayCommunityTranslator.timeSubmissionTableFormation(tcdRecords,projectRecords);
        
        return JSON.serialize(details);
    }
    
    /****************************************************************************************
    - Method to submit the time entries to Supervisor
    ****************************************************************************************/
    @AuraEnabled
    public static string submitSelectedWeekTimeEntries(String timeDayJson){
    
        List<TimeCardDayCommunityDomain.DayEntries> dayRecords = (List<TimeCardDayCommunityDomain.DayEntries>) System.JSON.deserialize(timeDayJson, List<TimeCardDayCommunityDomain.DayEntries>.class);
        
        List<AcctSeed__Time_Card_Day__c> dayRecordForSubmit = new List<AcctSeed__Time_Card_Day__c>();
        
        // Static map initialization to use in Time Card Day Trigger
        //Work Item No : W-001481
        tcdIdNoteType = new Map<Id,String>(); 
        
        for(TimeCardDayCommunityDomain.DayEntries day : dayRecords){
            if(day.dayId != null && day.status != 'Submitted' && day.status != 'Approved' && day.status != 'Admin Approved'){
                AcctSeed__Time_Card_Day__c dayRec = new AcctSeed__Time_Card_Day__c();
                dayRec.Id = day.dayId;
                dayRec.Status__c = 'Submitted';
                
                if(day.taskType != 'Preparation time' && day.studentApprovalStatus != 'Approved' 
                    && day.studentApprovalStatus != 'Submitted' && day.studentApprovalStatus != 'N/A'){
                    
                    dayRec.Student_Approval_Status__c = 'Submitted';
                }
                dayRecordForSubmit.add(dayRec);
                
                //For Notes Formation
                if(!tcdIdNoteType.containsKey(day.dayId)) {
                    tcdIdNoteType.put(day.dayId,'Weekly Submit');
                }
            }
        }
        
        try {
            isGroupAction = true;
            groupActionType = 'Submitted';
            
            if(dayRecordForSubmit.size() > 0){
                update dayRecordForSubmit;
            }
            return 'SUCCESS';
        }catch(DmlException e){
            system.debug('::::::::exception msg::submit:::::'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}