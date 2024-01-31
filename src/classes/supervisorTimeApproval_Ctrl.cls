// This class is created for Supervisor time Approval Page Wrapper formation'
// Created by Sukanya on Dec 9 2016
global without sharing class supervisorTimeApproval_Ctrl {
    
    public static Boolean isGroupAction;
    public static String groupActionType;
    
    public static String ParentFileds = ',AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.DLS_Class__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c,'+
                                     'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,'+
                                     'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c,'+
                                     'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.Name,'+
                                     'AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,'+
                                     'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,AcctSeed__Time_Card_Line__r.Location__c,AcctSeed__Time_Card_Line__r.Location__r.Name,'+
                                     'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name';
    
    public static String parentCondition = ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c IN :';
    
    // Added by to handle the expception in web & mobile pages
    public class AllException extends Exception {}
    
     //Remote action to Query time card day details
    @RemoteAction
     global static TimeCardDayDomain.WrapperClass getTimeCardDayDetails(String selectedUser) {
         
         //List<TimeCardDayDomain.TimeCardDayDetails> dayDetailsList = new List<TimeCardDayDomain.TimeCardDayDetails>();
         
         Set<Id> timeCardlineId = new Set<Id>();
         Set<Id> projectIdSet = new Set<Id>();
         
         // this following code for summary data formation
         Date todayDt = system.today();
         Date weekStart = todayDt.toStartofWeek().addDays(1);
         Date weekEnd = weekStart.addDays(6);
         
         // the following map to find instructor & internal related summary data
         Map<Id,String> lineIduserTypeMap = new Map<Id,String>();
         
         Id usrId;
         String firstName;
         String lastName;
         
         // For Delegated Approver use case - Added by NS on May 3 2018
         if(selectedUser != '--None--'){
             usrId = selectedUser;
             
             List<User> usrRec = [SELECT Id,FirstName,LastName FROM User WHERE Id = :selectedUser];
             
             if(usrRec.size() > 0) {
                 firstName = usrRec[0].FirstName;
                 lastName = usrRec[0].LastName;
             }
         }else {
             usrId = UserInfo.getUserId();
             firstName = UserInfo.getFirstName();
             lastName = UserInfo.getLastName();
         }
         
         String fname = '%'+firstName+'%';
         String lName = '%'+lastName+'%';
         
         // Get User timezone offset value
         String timezoneValue = UserInfo.getTimeZone().getID();
         
         system.debug('::::::firstName:::::'+firstName);
         system.debug('::::::lastName:::::'+lastName);
         
         // Query time card day for Intenals
         // Used service method for time card day qry 
         // Used same prent string for both qry, because same set of fields are queried
         // This qry for Summary table - get already approved / Rejected data
         // Added by Sukanya on JAN 25 2017
         
         // For Internal Staff entries
         
         //Added by NS on Nov 1 2023 for Staff time entry for instructor community - W-007742
         
         String internalfilterConditions1 = ' WHERE Status__c = \'Submitted\' AND (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'DLS_Employee\' OR (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'Candidate\' AND AcctSeed__Time_Card_Line__r.Contact_Assignment__r.RecordType.DeveloperName = \'Staff\')) AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c = \''+usrId+'\' ORDER BY AcctSeed__Date__c ASC';
         //List<AcctSeed__Time_Card_Day__c> timeCardDayInternal = TimeCardDayService.getDayWithParentFilterConditions(internalfilterConditions1,ParentFileds,'',new Set<Id>{});
         
         for(AcctSeed__Time_Card_Day__c internalDay : TimeCardDayService.getDayWithParentFilterConditions(internalfilterConditions1,ParentFileds,'',new Set<Id>{})) {
             if(internalDay.AcctSeed__Time_Card_Line__c != null) {
                 timeCardlineId.add(internalDay.AcctSeed__Time_Card_Line__c);
             }
             
             /*if(!lineIduserTypeMap.containsKey(internalDay.AcctSeed__Time_Card_Line__c) 
                 && internalDay.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName == 'DLS_Employee') {
                 lineIduserTypeMap.put(internalDay.AcctSeed__Time_Card_Line__c,'Internal');
             }*/
         }  
         
        // For Instructor related time entries
        
        //Developed separate approval page for instructor time approval process
        //commented by NS on Sep 11 2019
         /*if(firstName != null && lastName != null) {
             for(Contact_Assignments__c conAssign : ContactAssignmentService.getContactassignmentRec(' WHERE Candidate_Name__r.FirstName LIKE \''+fname+'\' AND Candidate_Name__r.LastName LIKE \''+lName+'\' AND Project__c != null AND RecordType.DeveloperName = \'Staff\' AND Status__c = \'Active\'','RecordType.DeveloperName,Candidate_Name__r.Name,Candidate_Name__r.RecordType.DeveloperName')) {
                
                 if(conAssign.Project__c != null)
                     projectIdSet.add(conAssign.Project__c);
             }
         }else if(lastName != null) {
             for(Contact_Assignments__c conAssign : ContactAssignmentService.getContactassignmentRec(' WHERE Candidate_Name__r.LastName LIKE \''+lName+'\' AND Project__c != null AND RecordType.DeveloperName = \'Staff\' AND Status__c = \'Active\'','RecordType.DeveloperName,Candidate_Name__r.Name')) {
               
                 if(conAssign.Project__c != null)
                     projectIdSet.add(conAssign.Project__c);
             }
         } 
         
         String internalfilterConditions2 = ' WHERE Status__c = \'Submitted\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'Candidate\'';
         
         if(projectIdSet != null && projectIdSet.size() > 0) {
             
             for(AcctSeed__Time_Card_Day__c dayRec : TimeCardDayService.getDayWithParentFilterConditions(internalfilterConditions2,ParentFileds,parentCondition,projectIdSet)) {
                 if(dayRec.AcctSeed__Time_Card_Line__c != null) {
                     timeCardlineId.add(dayRec.AcctSeed__Time_Card_Line__c);
                 }
             }  
         }*/
         
         
         system.debug('::::::timeCardlineId:::::::::::'+timeCardlineId);
         system.debug(':::::lineIduserTypeMap:::::::'+lineIduserTypeMap);
            
         // Qry time card day for current week intenrval - Summary approval & reject
         // The qry conditions are modified to show already approved/rejected time card days for Summary view
         
         String filterCdn = ' AND Status__c = \'Submitted\' ORDER BY AcctSeed__Date__c ASC';
         
         //List<AcctSeed__Time_Card_Line__c> timeCardlineList = TimeCardLineService.getLineWithCardday(weekStart,weekEnd,timeCardlineId,filterCdn);
         
         //system.debug('::::::timeCardlineList::::::::::::'+timeCardlineList);
         
         // Qry to get Week Range values for all past weeks
         List<AcctSeed__Time_Card_Line__c> WeekRangeLineList = new List<AcctSeed__Time_Card_Line__c>();
         
         if(timeCardlineId.size() > 0)
             WeekRangeLineList = TimeCardLineService.getLineWithCardday(null,null,timeCardlineId,filterCdn);
         
         // Get the Week Start date & End date from all past weeks
         Set<String> WeekRangeSet = new Set<String>();
         Set<Date> dateSet = new Set<Date>();
         List<String> weekRangeList = new List<String>();
        
         for(AcctSeed__Time_Card_Line__c LineRec : WeekRangeLineList) {
             if(LineRec.AcctSeed__Time_Card_Days__r != null && LineRec.AcctSeed__Time_Card_Days__r.size() > 0) {
                 for(AcctSeed__Time_Card_Day__c td : LineRec.AcctSeed__Time_Card_Days__r) {
                   
                    dateSet.add(td.AcctSeed__Date__c);
                 }
             }
         }
        
         system.debug('::::::dateSet:::getTimeCardDayDetails:::::'+dateSet);
        
         for(Date dt : dateSet) {
             
             Date st;
             
             if(dt.toStartofWeek().addDays(1) < dt)
                 st = dt.toStartofWeek().addDays(1);
             else
                 st = dt.addDays(-1).toStartofWeek().addDays(1);
                 
             Date ed = st.addDays(6); 
            
             if(!WeekRangeSet.contains(String.valueOf(st).split(' ')[0]+' to '+String.valueOf(ed).split(' ')[0])) {
                 WeekRangeSet.add(String.valueOf(st).split(' ')[0]+' to '+String.valueOf(ed).split(' ')[0]);
                 weekRangeList.add(String.valueOf(st).split(' ')[0]+' to '+String.valueOf(ed).split(' ')[0]);
             }
         }
        
         system.debug('::::::WeekRangeSet:::getTimeCardDayDetails:::::'+WeekRangeSet);
         system.debug(':::::weekRangeList::::'+weekRangeList);
        
         Date OverAllStdate;
         Date OverAllEndDate;
        
         if(WeekRangeSet != null && WeekRangeSet.size() > 0) {
         
             Integer index = weekRangeList.size() - 1;
             String dateValue = weekRangeList.get(0);
             String dateValue2 = weekRangeList.get(index);
             
             String date1 = dateValue.split(' to ')[0];
             String date2 = dateValue2.split(' to ')[1];
             OverAllStdate = Date.valueOf(date1);
             OverAllEndDate = Date.valueOf(date2);
         }
        
         system.debug('::::::::OverAllStdate:::::::'+OverAllStdate);
         system.debug('::::::::OverAllEndDate:::::::'+OverAllEndDate);
         
         // Qry timeCard line with past week range get Count of hrs,timesheets
         List<AcctSeed__Time_Card_Line__c> CountCalculationList = new List<AcctSeed__Time_Card_Line__c>();
         if(timeCardlineId.size() > 0)
             CountCalculationList = TimeCardLineService.getLineWithCardday(OverAllStdate,OverAllEndDate,timeCardlineId,filterCdn);
         
         TimeCardDayDomain.WrapperClass wrClass = TimeCardDayTranslator.approvalPagewrapperMethod(new List<Attendance__c>(),new List<AcctSeed__Time_Card_Day__c>(),new List<AcctSeed__Time_Card_Day__c>(),new List<AcctSeed__Time_Card_Line__c>(),lineIduserTypeMap,weekStart,weekEnd,true,WeekRangeLineList,CountCalculationList,WeekRangeSet,new List<Accounting_Seed_Time_Snapshot__c>(),timezoneValue);
          
         system.debug(':::::wrClass::::::'+wrClass);
         
         return wrClass;
     }
     
     // Added by Sukanya on June 29 2017
     // Qry Instructor time entry records for approval process
     @RemoteAction
     global static TimeCardDayDomain.WrapperClass getInstructor_WholeWeekValues(String selectedUser) {
         
         Set<Id> timeCardlineId = new Set<Id>();
         Set<Id> projectIdSet= new Set<Id>();
         
         // this following code for summary data formation
         Date todayDt = system.today();
         Date weekStart = todayDt.toStartofWeek().addDays(1);
         Date weekEnd = weekStart.addDays(6);
         
         // the following map to find instructor & internal related summary data
         Map<Id,String> lineIduserTypeMap = new Map<Id,String>();
         
         Id usrId;
         String firstName;
         String lastName;
         Id contactId;
         
         // For Delegated Approver use case - Added by NS on May 3 2018
         if(selectedUser != '--None--'){
             usrId = selectedUser;
             
             List<User> usrRec = [SELECT Id,FirstName,LastName FROM User WHERE Id = :selectedUser];
             
             if(usrRec.size() > 0) {
                 firstName = usrRec[0].FirstName;
                 lastName = usrRec[0].LastName;
             }
         }else {
             usrId = UserInfo.getUserId();
             firstName = UserInfo.getFirstName();
             lastName = UserInfo.getLastName();
         }
         
         String fname = '%'+firstName+'%';
         String lName = '%'+lastName+'%';
         
         // Get User timezone offset value
         String timezoneValue = UserInfo.getTimeZone().getID();
         
         system.debug('::::::firstName::getInstructor_WholeWeekValues:::'+firstName);
         system.debug('::::::lastName::getInstructor_WholeWeekValues:::'+lastName);
        
         // Get the time card day records which having logged in user as supervisor & instrcutor RT = Candidate
         // these time card line ids are used for further qry operation
         
         // Qry contact Assignments - For Logged user related pro
         if(firstName != null && lastName != null) {
             for(Contact_Assignments__c conAssign : ContactAssignmentService.getContactassignmentRec(' WHERE Candidate_Name__r.FirstName LIKE \''+fname+'\' AND Candidate_Name__r.LastName LIKE \''+lName+'\' AND Project__c != null AND RecordType.DeveloperName = \'Staff\' AND Status__c = \'Active\'','RecordType.DeveloperName,Candidate_Name__r.Name,Candidate_Name__r.RecordType.DeveloperName')) {
                 contactId = conAssign.Candidate_Name__c;
                 if(conAssign.Project__c != null)
                     projectIdSet.add(conAssign.Project__c);
             }
         }else if(lastName != null) {
             for(Contact_Assignments__c conAssign : ContactAssignmentService.getContactassignmentRec(' WHERE Candidate_Name__r.LastName LIKE \''+lName+'\' AND Project__c != null AND RecordType.DeveloperName = \'Staff\' AND Status__c = \'Active\'','RecordType.DeveloperName,Candidate_Name__r.Name')) {
                 contactId = conAssign.Candidate_Name__c;
                 if(conAssign.Project__c != null)
                     projectIdSet.add(conAssign.Project__c);
             }
         } 
         
         system.debug(':::::projectIdSet::::::::::::getInstructor_WholeWeekValues::::::'+projectIdSet);
        
         String internalfilterConditions1 = ' WHERE Status__c = \'Submitted\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'Candidate\'';
         
         if(projectIdSet != null && projectIdSet.size() > 0) {
             
             for(AcctSeed__Time_Card_Day__c dayRec : TimeCardDayService.getDayWithParentFilterConditions(internalfilterConditions1,ParentFileds,parentCondition,projectIdSet)) {
                 if(dayRec.AcctSeed__Time_Card_Line__c != null) {
                     timeCardlineId.add(dayRec.AcctSeed__Time_Card_Line__c);
                 }
                 
                 /*if(!lineIduserTypeMap.containsKey(dayRec.AcctSeed__Time_Card_Line__c) 
                     && dayRec.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName == 'Candidate') {
                     lineIduserTypeMap.put(dayRec.AcctSeed__Time_Card_Line__c,'Instructor');
                 }*/
             }  
         }
         
         system.debug('::::::timeCardlineId:::::getInstructor_WholeWeekValues::::::'+timeCardlineId);
         system.debug(':::::lineIduserTypeMap::::getInstructor_WholeWeekValues:::'+lineIduserTypeMap);
         
         String filterCdn = ' AND Status__c = \'Submitted\' ORDER BY AcctSeed__Date__c ASC';
         
         //List<AcctSeed__Time_Card_Line__c> timeCardlineList = TimeCardLineService.getLineWithCardday(weekStart,weekEnd,timeCardlineId,filterCdn);
         
         //system.debug('::::::timeCardlineList::::getInstructor_WholeWeekValues::::::::'+timeCardlineList);
         
         // Qry to get Week Range values for all past weeks
         List<AcctSeed__Time_Card_Line__c> WeekRangeLineList = new List<AcctSeed__Time_Card_Line__c>();
         if(timeCardlineId.size() > 0)
             WeekRangeLineList = TimeCardLineService.getLineWithCardday(null,null,timeCardlineId,filterCdn);
         
         // Get the Week Start date & End date from all past weeks
         Set<String> WeekRangeSet = new Set<String>();
         Set<Date> dateSet = new Set<Date>();
        
         for(AcctSeed__Time_Card_Line__c LineRec : WeekRangeLineList) {
             if(LineRec.AcctSeed__Time_Card_Days__r != null && LineRec.AcctSeed__Time_Card_Days__r.size() > 0) {
                 for(AcctSeed__Time_Card_Day__c td : LineRec.AcctSeed__Time_Card_Days__r) {
                   
                    dateSet.add(td.AcctSeed__Date__c);
                 }
             }
         }
        
         system.debug('::::::dateSet:::::getInstructor_WholeWeekValues:::'+dateSet);
        
         for(Date dt : dateSet) {
             
             Date st;
             
             if(dt.toStartofWeek().addDays(1) < dt)
                 st = dt.toStartofWeek().addDays(1);
             else
                 st = dt.addDays(-1).toStartofWeek().addDays(1);
                 
             Date ed = st.addDays(6); 
            
             if(!WeekRangeSet.contains(String.valueOf(st).split(' ')[0]+' to '+String.valueOf(ed).split(' ')[0])) {
                 WeekRangeSet.add(String.valueOf(st).split(' ')[0]+' to '+String.valueOf(ed).split(' ')[0]);
             }
         }
        
         system.debug('::::::WeekRangeSet:::getInstructor_WholeWeekValues:::::'+WeekRangeSet);
        
         Date OverAllStdate;
         Date OverAllEndDate;
        
         if(WeekRangeSet != null && WeekRangeSet.size() > 0) {
             Integer index = WeekRangeSet.size() - 1;
             String dateValue = new List<String> (WeekRangeSet).get(0);
             String dateValue2 = new List<String> (WeekRangeSet).get(index);
             
             String date1 = dateValue.split(' to ')[0];
             String date2 = dateValue2.split(' to ')[1];
             OverAllStdate = Date.valueOf(date1);
             OverAllEndDate = Date.valueOf(date2);
         }
        
         system.debug('::::::::OverAllStdate::getInstructor_WholeWeekValues:::::'+OverAllStdate);
         system.debug('::::::::OverAllEndDate:::getInstructor_WholeWeekValues::::'+OverAllEndDate);
         
         // Qry timeCard line with past week range get Count of hrs,timesheets
         List<AcctSeed__Time_Card_Line__c> CountCalculationList = new List<AcctSeed__Time_Card_Line__c>();
         if(timeCardlineId.size() > 0)
             CountCalculationList = TimeCardLineService.getLineWithCardday(OverAllStdate,OverAllEndDate,timeCardlineId,filterCdn);
                          
         TimeCardDayDomain.WrapperClass Instrcutor_wrClass = TimeCardDayTranslator.approvalPagewrapperMethod(new List<Attendance__c>(),new List<AcctSeed__Time_Card_Day__c>(),new List<AcctSeed__Time_Card_Day__c>(),new List<AcctSeed__Time_Card_Line__c>(),lineIduserTypeMap,weekStart,weekEnd,true,WeekRangeLineList,CountCalculationList,WeekRangeSet,new List<Accounting_Seed_Time_Snapshot__c>(),timezoneValue);         
         system.debug(':::::wrClass::::::'+Instrcutor_wrClass);  
         
         return Instrcutor_wrClass;
     }
     
     // Added by sukanya on JAN 25 2017
     // For Summary information Qry for Last week & This Week filter conditions
     @RemoteAction
     global static TimeCardDayDomain.WrapperClass getSummaryInfoForWeekRange(String startDate,String endDate,String userType,String selectedUser) {
         
         Set<Id> timeCardlineId = new Set<Id>();
         Set<Id> projectIdSet = new Set<Id>();
        
         Date weekStart = Date.valueOf(startDate);
         Date weekEnd = Date.valueOf(endDate);
         
         system.debug(':::::::weekStart:::::'+weekStart);
         system.debug(':::::::weekStart:::::'+weekEnd);
         System.debug('::selectedUser::'+selectedUser);
         
         // the following map to find instructor & internal related summary data
         Map<Id,String> lineIduserTypeMap = new Map<Id,String>();
         
         Id usrId;
         String firstName;
         String lastName;
         Id contactId;
         // For Delegated Approver use case - Added by NS on May 3 2018
         if(selectedUser != '--None--'){
             usrId = selectedUser;
             
             List<User> usrRec = [SELECT Id,FirstName,LastName FROM User WHERE Id = :selectedUser];
             
             if(usrRec.size() > 0) {
                 firstName = usrRec[0].FirstName;
                 lastName = usrRec[0].LastName;
             }
         }else {
             usrId = UserInfo.getUserId();
             firstName = UserInfo.getFirstName();
             lastName = UserInfo.getLastName();
         }
         
         String fname = '%'+firstName+'%';
         String lName = '%'+lastName+'%';
         
         // Get User timezone offset value
         String timezoneValue = UserInfo.getTimeZone().getID();
         
         system.debug('::::::firstName:::::'+firstName);
         system.debug('::::::lastName:::::'+lastName);
         
         // Qry contact Assignments - For Logged user related pro
         if(firstName != null && lastName != null) {
             for(Contact_Assignments__c conAssign : ContactAssignmentService.getContactassignmentRec(' WHERE Candidate_Name__r.FirstName LIKE \''+fname+'\' AND Candidate_Name__r.LastName LIKE \''+lName+'\' AND Project__c != null AND RecordType.DeveloperName = \'Staff\' AND Status__c = \'Active\'','RecordType.DeveloperName,Candidate_Name__r.Name,Candidate_Name__r.RecordType.DeveloperName')) {
                contactId = conAssign.Candidate_Name__c;
                 if(conAssign.Project__c != null)
                     projectIdSet.add(conAssign.Project__c);
             }
         }else if(lastName != null) {
             for(Contact_Assignments__c conAssign : ContactAssignmentService.getContactassignmentRec(' WHERE Candidate_Name__r.LastName LIKE \''+lName+'\' AND Project__c != null AND RecordType.DeveloperName = \'Staff\' AND Status__c = \'Active\'','RecordType.DeveloperName,Candidate_Name__r.Name')) {
                 contactId = conAssign.Candidate_Name__c;
                 if(conAssign.Project__c != null)
                     projectIdSet.add(conAssign.Project__c);
             }
         } 
         
         system.debug(':::::projectIdSet::::::::::::getSummaryInfoForWeekRange::::::'+projectIdSet);
         
         // Qry timecardline ids based on internal & instructor related records
         //Added by NS on Nov 1 2023 for Staff time entry for instructor community - W-007742
         
         
         //if(userType == 'Internal') {
             String internalfilterConditions1 = ' WHERE Status__c != \'Draft\' AND Status__c != \'Unposted\' AND (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'DLS_Employee\' OR (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'Candidate\' AND AcctSeed__Time_Card_Line__r.Contact_Assignment__r.RecordType.DeveloperName = \'Staff\')) AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c = \''+usrId+'\' AND AcctSeed__Date__c >= '+String.valueOf(weekStart).split(' ')[0]+' AND AcctSeed__Date__c <= '+String.valueOf(weekEnd).split(' ')[0]+' ORDER BY AcctSeed__Date__c ASC';
             
             for(AcctSeed__Time_Card_Day__c internalDay : TimeCardDayService.getDayWithParentFilterConditions(internalfilterConditions1,ParentFileds,'',new Set<Id>{})) {
                 if(internalDay.AcctSeed__Time_Card_Line__c != null) {
                     timeCardlineId.add(internalDay.AcctSeed__Time_Card_Line__c);
                 }
                 
                 /*if(!lineIduserTypeMap.containsKey(internalDay.AcctSeed__Time_Card_Line__c)) {
                     string type = '';
                     if(internalDay.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName == 'DLS_Employee')
                         type = 'Internal';
                    
                     lineIduserTypeMap.put(internalDay.AcctSeed__Time_Card_Line__c,type);
                 }*/
             } 
             
         //}else if(userType == 'Instructor') {
             
             //Developed separate approval page for instructor time approval process
             //commented by NS on Sep 11 2019
             /*String internalfilterConditions2 = ' WHERE Status__c != \'Draft\' AND Status__c != \'Unposted\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'Candidate\' AND AcctSeed__Date__c >= '+String.valueOf(weekStart).split(' ')[0]+' AND AcctSeed__Date__c <= '+String.valueOf(weekEnd).split(' ')[0]+'';
         
             if(projectIdSet != null && projectIdSet.size() > 0) {
                 
                 for(AcctSeed__Time_Card_Day__c dayRec : TimeCardDayService.getDayWithParentFilterConditions(internalfilterConditions2,ParentFileds,parentCondition,projectIdSet)) {
                     if(dayRec.AcctSeed__Time_Card_Line__c != null) {
                         timeCardlineId.add(dayRec.AcctSeed__Time_Card_Line__c);
                     }
                 }  
             }*/
         //}
         
         String filterCdn = ' AND Status__c != \'Draft\' AND Status__c != \'Unposted\' AND Status__c != \'Reverted\' AND Status__c != \'Admin Approved\' ORDER BY AcctSeed__Date__c ASC';
         List<AcctSeed__Time_Card_Line__c> timeCardlineList = new List<AcctSeed__Time_Card_Line__c>();
         if(timeCardlineId.size() > 0)
             timeCardlineList = TimeCardLineService.getLineWithCardday(weekStart,weekEnd,timeCardlineId,filterCdn);
         
         // Get the time card line ids to qry Timesnapshot for notes section
         // Added by Sukanya on March 9 2017
         
         Set<Id> lineIdforSnapshot = new Set<Id>();
         
         system.debug('::::::timeCardlineId:::'+timeCardlineId);
         if(timeCardlineId.size() > 0) {
             for(AcctSeed__Time_Card_Line__c lineValues : TimeCardLineService.getLineWithCardday(weekStart,weekEnd,timeCardlineId,' AND Status__c != \'Draft\' ORDER BY AcctSeed__Date__c ASC')) {
                 if(lineValues.AcctSeed__Time_Card_Days__r != null && lineValues.AcctSeed__Time_Card_Days__r.size() > 0) {
                     for(AcctSeed__Time_Card_Day__c dayValues : lineValues.AcctSeed__Time_Card_Days__r) {
                         lineIdforSnapshot.add(dayValues.AcctSeed__Time_Card_Line__c);
                     }
                 }
             }
             
         }
         system.debug('::::::lineIdforSnapshot:::::'+lineIdforSnapshot);
         
         // Qry time card day with time snapshot records
         List<Accounting_Seed_Time_Snapshot__c> accTimesnapshot = new List<Accounting_Seed_Time_Snapshot__c>();
         
          for(AcctSeed__Time_Card_Day__c day : TimeCardDayService.getDayWithDate_timeLinefilter(lineIdforSnapshot,weekStart,weekEnd) ) {
            
            if(day.Accounting_Seed_Time_Snapshots__r != null && day.Accounting_Seed_Time_Snapshots__r.size() > 0) {
                for(Accounting_Seed_Time_Snapshot__c snapShot : day.Accounting_Seed_Time_Snapshots__r) {
                    accTimesnapshot.add(snapShot);
                }
            }
         }
         
         
         //Added By Dhinesh - 21/03/2023 - W-007729 - Timekeeping Fields to Indicate if the Time was entered On Time or Late
         Set<Id> contIds = new Set<Id>();
        for(AcctSeed__Time_Card_Line__c lineRec : timeCardlineList){
            contIds.add(LineRec.AcctSeed__Time_Card__r.Intructor__c);
        }
        
        Map<Id, TimeEntryUtil.TimeEnteredCountWrap> conIdWithTimeEnteredCountMap = TimeEntryUtil.getTimeEnteredCountByContactIds(contIds);         
         
         system.debug('::::::accTimesnapshot::::::'+accTimesnapshot);
         
         TimeCardDayDomain.WrapperClass summarywrClass = TimeCardDayTranslator.approvalPagewrapperMethod(new List<Attendance__c>(),new List<AcctSeed__Time_Card_Day__c>(),new List<AcctSeed__Time_Card_Day__c>(),timeCardlineList,lineIduserTypeMap,weekStart,weekEnd,false,new List<AcctSeed__Time_Card_Line__c>(),new List<AcctSeed__Time_Card_Line__c>(),new Set<String>(),accTimesnapshot,timezoneValue);
         summarywrClass.conIdWithTimeEnteredCountMap = conIdWithTimeEnteredCountMap;
         system.debug(':::::summarywrClass::::::'+summarywrClass);
         
         return summarywrClass;
     }
     
     // Method for Specific date range semi monthly view data formation
     // Added by Sukanya on August 18 2017
     @RemoteAction
     global static TimeCardDayDomain.Approval_SemiMonthlyWrapper getSemiMonthly_TimeRecords(String fromDate,String toDate,String userType) {
     
         system.debug('::::::date1::::'+fromDate);
         system.debug('::::::date1::::'+toDate);
         system.debug('::::::date1::::'+userType);
         
         Set<Id> projectIdSet = new Set<Id>();
         
         Date StartDate = Date.valueOf(fromDate);
         Date EndDate = Date.valueOf(toDate);
         Date MonthStart = StartDate;
         Date MonthEnd = EndDate;
         
         Date date1 = MonthStart;
         Date date2 = MonthEnd;
         
         if(Date.valueOf(fromDate).toStartofWeek().addDays(1) < Date.valueOf(fromDate)) {
             if(Date.valueOf(fromDate) != Date.valueOf(fromDate).toStartOfMonth()) {
                 system.debug(':::::Month:start:::&::Weekstart::not:::same:');
                 StartDate = Date.valueOf(fromDate).toStartofWeek().addDays(1);
             }
         }else {
             StartDate = Date.valueOf(fromDate).addDays(-1).toStartofWeek().addDays(1);
         }  
         
         system.debug('::getSemiMonthly_TimeRecords:::::StartDate::::::::'+StartDate);
         system.debug('::getSemiMonthly_TimeRecords:::::EndDate::::::::'+EndDate);
         system.debug('::getSemiMonthly_TimeRecords:::::MonthStart::::::::'+MonthStart);
         system.debug(':::getSemiMonthly_TimeRecords::::MonthEnd::::::::'+MonthEnd);
         
         
         List<Date> MonthdaysList = new List<Date>();
         
         while(MonthStart <= MonthEnd) {
           MonthdaysList.add(MonthStart);
           MonthStart = MonthStart.addDays(1);
         }
         
         Id usrId = UserInfo.getUserId();
         String firstName = UserInfo.getFirstName();
         String lastName = UserInfo.getLastName();
         
         String fname = '%'+firstName+'%';
         String lName = '%'+lastName+'%';
         
         system.debug(':::getSemiMonthly_TimeRecords:::firstName:::::'+firstName);
         system.debug(':::getSemiMonthly_TimeRecords:::lastName:::::'+lastName);
         
         // Qry contact Assignments - For Logged user related pro
         if(firstName != null && lastName != null) {
             for(Contact_Assignments__c conAssign : ContactAssignmentService.getContactassignmentRec(' WHERE Candidate_Name__r.FirstName LIKE \''+fname+'\' AND Candidate_Name__r.LastName LIKE \''+lName+'\' AND Project__c != null AND RecordType.DeveloperName = \'Staff\' AND Status__c = \'Active\'','RecordType.DeveloperName,Candidate_Name__r.Name,Candidate_Name__r.RecordType.DeveloperName')) {
                
                 if(conAssign.Project__c != null)
                     projectIdSet.add(conAssign.Project__c);
             }
         }else if(lastName != null) {
             for(Contact_Assignments__c conAssign : ContactAssignmentService.getContactassignmentRec(' WHERE Candidate_Name__r.LastName LIKE \''+lName+'\' AND Project__c != null AND RecordType.DeveloperName = \'Staff\' AND Status__c = \'Active\'','RecordType.DeveloperName,Candidate_Name__r.Name')) {
               
                 if(conAssign.Project__c != null)
                     projectIdSet.add(conAssign.Project__c);
             }
         } 
         system.debug(':::::projectIdSet::::::::::::getSemiMonthly_TimeRecords::::::'+projectIdSet);
         
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = new List<AcctSeed__Time_Card_Day__c>();
        
        String parentFields = ',AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,'+
                            'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName,'+
                            'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Rate__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId,'+
                            'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,'+
                            'AcctSeed__Time_Card_Line__r.Location__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c,'+
                            'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c,AcctSeed__Time_Card_Line__r.Payroll_Item__c';
        
        // User type based records filter is not needed now - Commented by NS on June 6 2018
        //if(userType == 'Internal') {
            
            String filterCondition = ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c = \''+usrId+'\' AND Status__c != \'Unposted\' ORDER BY AcctSeed__Date__c ASC';
            
            timeCardDayList = TimeCardDayService.getTimeCardDayRecords_Withfilters(filterCondition,parentFields,date1,date2,new Set<Id>{});
        
        /*}else if(userType == 'Instructor') {
        
            String filterCondition1 = ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'Candidate\' AND Status__c != \'Unposted\' ORDER BY AcctSeed__Date__c ASC';
            
            if(projectIdSet != null && projectIdSet.size() > 0)
                timeCardDayList.addAll(TimeCardDayService.getTimeCardDayRecords_Withfilters(filterCondition1,parentFields,date1,date2,projectIdSet));
        }*/
        
        system.debug(':::::timeCardDayList:::::::'+timeCardDayList);
        
        TimeCardDayDomain.Approval_SemiMonthlyWrapper approvalWrapper = TimeCardDayTranslator.approvalSemiMonthlyFormation(timeCardDayList,MonthdaysList);
        
        system.debug('::::::approvalWrapper:::::::'+approvalWrapper);
        
         return approvalWrapper;
     }
     
     //Remote action to update time card day records
    @RemoteAction
     global static String updateTimecardDayrecords(String updateString,String actionType,String EmailType) {
         try {
             
             if(actionType == 'ApproveAll') {
                 groupActionType = 'Approved';
                 isGroupAction = true;
             }else if(actionType == 'RejectAll') {
                 groupActionType = 'Rejected';
                 isGroupAction = true;
             }else {
                 isGroupAction = false;
             }
             
             system.debug('::::::actionType::::::'+actionType);
             system.debug('::::::isGroupAction::::::'+isGroupAction);
             system.debug('::::::groupActionType::::::'+groupActionType);
             system.debug('::::::::EmailType:::::'+EmailType);
                 
             List<AcctSeed__Time_Card_Day__c> dayUpdateList = (List<AcctSeed__Time_Card_Day__c>) System.JSON.deserialize(updateString, List<AcctSeed__Time_Card_Day__c>.class);
             system.debug('::::::::dayUpdateList:::::::'+dayUpdateList);
             
             if(dayUpdateList.size() > 0) {
                 update dayUpdateList;
                 
                 system.debug(':::::::after::update::dayUpdateList::::'+dayUpdateList);
                 Set<Id> dayIds = new Set<Id>();
                 
                 for(AcctSeed__Time_Card_Day__c  dayRec : dayUpdateList) {
                     dayIds.add(dayRec.Id);
                 }
                 system.debug('::::::dayIds::::::::'+dayIds);
                 // For Approve & Reject All email send purpose
                 
                 if(dayIds.size() > 0){
                     
                     if(actionType == 'ApproveAll' || actionType == 'RejectAll' || EmailType == 'ApproveAll' || EmailType == 'RejectAll')
                         timeCardRelated_Email_Controller.approve_RejectAll_EmailMethod(dayIds,EmailType);
                     else if(EmailType == 'Partial')
                         timeCardRelated_Email_Controller.partial_approve_Reject_EmailMethod(dayIds);
                 }
                 return 'SUCCESS';
             }else {
                 return null;
             }
         }catch(Exception e) {
             system.debug(':::::::e.getMessage():::::'+e.getMessage());
             throw new AllException(e.getMessage());
         }
     }
     
     // Method to get the logged in user (Gelegated approver) related user records
     // Added by NS on May 3 2018
     @RemoteAction
     global static List<User> getDelegatedApproverRelatedUsrs() {
         Id loggedInUsrId = UserInfo.getUserId();
         List<User> usersList = new List<User>();
         List<User> filteredUsrList = new List<User>();
         Set<Id> usrIds = new Set<Id>();
         Map<Id,Boolean> usrIdFlagMap = new Map<Id,Boolean>();
         
         usersList = [SELECT Id,Name FROM User WHERE DelegatedApproverId = :loggedInUsrId];
         // Based on Planned days off records display the users in approval page for delegated approver use case
         // Added by NS on May 4 2018
         
         for(User usr : usersList) {
             usrIds.add(usr.Id);
         }
         
         for(Planned_Days_Off__c pdo : [SELECT Id,Name,Date__c,Contact__c,Contact__r.DLS_User__c,Description__c,Opportunity__c,Project__c,Type__c 
                                         FROM Planned_Days_Off__c 
                                         WHERE Date__c = TODAY AND RecordType.DeveloperName = 'Staff_Planned_Days_Off' AND Contact__r.DLS_User__c IN :usrIds]){
             
         
             if(!usrIdFlagMap.containsKey(pdo.Contact__r.DLS_User__c)){
                 usrIdFlagMap.put(pdo.Contact__r.DLS_User__c,true);
             }
         }
         system.debug(':::::usrIdFlagMap::::'+usrIdFlagMap);
         
         for(User usr : usersList){
             if(usrIdFlagMap.containsKey(usr.Id) && usrIdFlagMap.get(usr.Id)){
                 filteredUsrList.add(usr);
             }
         }
         return filteredUsrList;
     }
}