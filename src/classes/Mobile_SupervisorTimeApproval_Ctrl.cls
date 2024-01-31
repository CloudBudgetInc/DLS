/**********************************************************
- For Mobile Supervisor Approval Lightning Component Usage
- Created by NS on June 8 2018
**********************************************************/

public without sharing class Mobile_SupervisorTimeApproval_Ctrl {
    
    public static String ParentFileds = ',AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.DLS_Class__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c,'+
        'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,'+
        'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c,'+
        'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.Name,'+
        'AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,'+
        'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,AcctSeed__Time_Card_Line__r.Location__c,AcctSeed__Time_Card_Line__r.Location__r.Name,'+
        'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name';
    
    public static String parentCondition = ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c IN :';
    
    /***************************************************
- Method to get the pending weeks details, Contact list based on the logged in user
- Created by NS on June 8 2018
****************************************************/
    
    @AuraEnabled
    public static String getWholeWeekInformation(String selectedUser){
        system.debug('::::::::selectedUser::::::'+selectedUser);
        
        Set<Id> timeCardlineId = new Set<Id>();
        Set<Id> projectIdSet = new Set<Id>();
        
        // this following code for summary data formation
        Date todayDt = system.today();
        Date weekStart = todayDt.toStartofWeek().addDays(1);
        Date weekEnd = weekStart.addDays(6);
        
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
        
        // For Internal Staff entries
        String internalfilterConditions1 = ' WHERE Status__c = \'Submitted\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c = \''+usrId+'\' ORDER BY AcctSeed__Date__c ASC';
        //List<AcctSeed__Time_Card_Day__c> timeCardDayInternal = TimeCardDayService.getDayWithParentFilterConditions(internalfilterConditions1,ParentFileds,'',new Set<Id>{});
        
        for(AcctSeed__Time_Card_Day__c internalDay : TimeCardDayService.getDayWithParentFilterConditions(internalfilterConditions1,ParentFileds,'',new Set<Id>{})) {
            if(internalDay.AcctSeed__Time_Card_Line__c != null) {
                timeCardlineId.add(internalDay.AcctSeed__Time_Card_Line__c);
            }
        }  
        
        // For Instructor related time entries
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
        String internalfilterConditions2 = ' WHERE Status__c = \'Submitted\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'Candidate\'';
        
        if(projectIdSet != null && projectIdSet.size() > 0) {
            
            for(AcctSeed__Time_Card_Day__c dayRec : TimeCardDayService.getDayWithParentFilterConditions(internalfilterConditions2,ParentFileds,parentCondition,projectIdSet)) {
                if(dayRec.AcctSeed__Time_Card_Line__c != null) {
                    timeCardlineId.add(dayRec.AcctSeed__Time_Card_Line__c);
                }
            }  
        }
        
        system.debug('::::::timeCardlineId:::::::::::'+timeCardlineId);
        
        // Qry time card day for current week intenrval - Summary approval & reject
        // The qry conditions are modified to show already approved/rejected time card days for Summary view
        
        String filterCdn = ' AND Status__c = \'Submitted\' ORDER BY AcctSeed__Date__c ASC';
        
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
            
            String stFormated = String.valueOf(st).split(' ')[0].split('-')[1]+'/'+String.valueOf(st).split(' ')[0].split('-')[2]+'/'+String.valueOf(st).split(' ')[0].split('-')[0];
            String edFormated = String.valueOf(ed).split(' ')[0].split('-')[1]+'/'+String.valueOf(ed).split(' ')[0].split('-')[2]+'/'+String.valueOf(ed).split(' ')[0].split('-')[0];
            if(!WeekRangeSet.contains(stFormated+' / '+edFormated)) {
                WeekRangeSet.add(stFormated+' / '+edFormated);
                weekRangeList.add(stFormated+' / '+edFormated);
            }
        }
        
        system.debug('::::::WeekRangeSet:::getTimeCardDayDetails:::::'+WeekRangeSet);
        system.debug(':::::weekRangeList::::'+weekRangeList);
        
        TimeCardDayDomain.dailyInitialInfo dailyInfo = new TimeCardDayDomain.dailyInitialInfo();
        dailyInfo = TimeCardDayTranslator.Daily_InitialData(WeekRangeSet,null,new List<Contact>(),new List<Date>(),new List<Project_Task_Master__c>(),new List<ContentDocument>());
        system.debug('::::::::::dailyInfo::::::'+dailyInfo);
        
        return JSON.serialize(dailyInfo);
    }
    
    /**************************************************************
- Get specific week start date & End Date based entries result display
- created by NS on June 8 2018 
*************************************************************/
    @AuraEnabled
    public static String getSpecificWeekDetails(String selectedUser,String summaryType,String startDate,String endDate){
        system.debug(':::start:::end::daye:::::'+startDate+ ' ' +endDate);
        system.debug('::::sleetced:::user:::summary:type::'+selectedUser+' '+summaryType);
        
        Set<Id> timeCardlineId = new Set<Id>();
        Set<Id> projectIdSet = new Set<Id>();
        
        Date weekStart = Date.valueOf(startDate).toStartofWeek().addDays(1);
        Date weekEnd = Date.valueOf(endDate);
        
        system.debug(':::::::weekStart:::::'+weekStart);
        system.debug(':::::::weekStart:::::'+weekEnd);
        
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
        
        system.debug(':::::projectIdSet::::::::::::getSummaryInfoForWeekRange::::::'+projectIdSet);
        
        // Qry timecardline ids based on internal & instructor related records
        String internalfilterConditions1 = ' WHERE Status__c != \'Draft\' AND Status__c != \'Unposted\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c = \''+usrId+'\' AND AcctSeed__Date__c >= '+String.valueOf(weekStart).split(' ')[0]+' AND AcctSeed__Date__c <= '+String.valueOf(weekEnd).split(' ')[0]+' ORDER BY AcctSeed__Date__c ASC';
        
        for(AcctSeed__Time_Card_Day__c internalDay : TimeCardDayService.getDayWithParentFilterConditions(internalfilterConditions1,ParentFileds,'',new Set<Id>{})) {
            if(internalDay.AcctSeed__Time_Card_Line__c != null) {
                timeCardlineId.add(internalDay.AcctSeed__Time_Card_Line__c);
            }
        }
        
        String internalfilterConditions2 = ' WHERE Status__c != \'Draft\' AND Status__c != \'Unposted\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'Candidate\' AND AcctSeed__Date__c >= '+String.valueOf(weekStart).split(' ')[0]+' AND AcctSeed__Date__c <= '+String.valueOf(weekEnd).split(' ')[0]+'';
        
        if(projectIdSet != null && projectIdSet.size() > 0) {
            for(AcctSeed__Time_Card_Day__c dayRec : TimeCardDayService.getDayWithParentFilterConditions(internalfilterConditions2,ParentFileds,parentCondition,projectIdSet)) {
                if(dayRec.AcctSeed__Time_Card_Line__c != null) {
                    timeCardlineId.add(dayRec.AcctSeed__Time_Card_Line__c);
                }
            }  
        }
        
        String filterCdn = ' AND Status__c != \'Draft\' AND Status__c != \'Unposted\' AND Status__c != \'Reverted\' AND Status__c != \'Admin Approved\' ORDER BY AcctSeed__Date__c ASC';
        List<AcctSeed__Time_Card_Line__c> timeCardlineList = new List<AcctSeed__Time_Card_Line__c>();
        if(timeCardlineId.size() > 0)
            timeCardlineList = TimeCardLineService.getLineWithCardday(weekStart,weekEnd,timeCardlineId,filterCdn);
        
        // Get the time card line ids to qry Timesnapshot for notes section
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
        system.debug('::::::accTimesnapshot::::::'+accTimesnapshot);
        
        TimeCardDayDomain.WeekViewDetails weekDetail = new TimeCardDayDomain.WeekViewDetails();
        weekDetail = TimeCardDayTranslator.approvalWeekDetailFormation(Date.valueOf(startDate),Date.valueOf(endDate),summaryType,timeCardLineList,accTimesnapshot);
      
        return JSON.serialize(weekDetail);
    }
    
    /******************************************************************************
    - Get Delegated Approver information for approval
    - Added by NS on June 19 2018
    ********************************************************************************/
    @AuraEnabled
    public static String getDelegatedApproverRelatedUsrs(){
        List<User> usersList = supervisorTimeApproval_Ctrl.getDelegatedApproverRelatedUsrs();        
        return JSON.serialize(usersList);
    }
    
    /*****************************************************************************
     - TCD records status update based on the supervisor approval
     - Added by NS on June 19 2018
    ******************************************************************************/
    @AuraEnabled
    public static String updateTCDStatus(String updateString,String actionType,String EmailType){
        try {
            String result = supervisorTimeApproval_Ctrl.updateTimecardDayrecords(updateString,actionType,EmailType);
            return result;
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*****************************************************************************
    - Semi Monthly Week formation for Mobile Approval Summary info
    - Added by NS on June 27 2018
    ******************************************************************************/
    @AuraEnabled
    public static String getSemiMontlyWeeks(){
        
        Date todayDt = system.today();
        Date actualMnthStart = todayDt.toStartOfMonth();
        Date actualMnthEnd = todayDt.addMonths(1).toStartOfMonth().addDays(-1);
        
        Date monthFrom;
        Date monthTo;
        
        if(todayDt > actualMnthStart.addDays(15)){
            monthFrom = actualMnthStart.addDays(15);
            monthTo = actualMnthEnd;
        }else {
            monthFrom = actualMnthStart;
            monthTo = actualMnthStart.addDays(14);
        }
        
        system.debug(':::::::::pastStartDate::::::'+monthFrom);
        system.debug(':::::::::monthTo::::::'+monthTo);
        
        Date pastStartDate = todayDt.addMonths(-3).toStartOfMonth();
        Date futureEndDate = todayDt.addMonths(2).toStartOfMonth().addDays(-1);
        
        system.debug(':::::::::pastStartDate::::::'+pastStartDate);
        system.debug(':::::::::futureEndDate::::::'+futureEndDate);
        
        List<String> weekRanges = new List<String>();
        
        while(pastStartDate <= futureEndDate){
            Date dt1 = pastStartDate;
            Date dt2 = dt1.addDays(14);
            
            Date dt3 = dt2.addDays(1);
            Date dt4 = dt3.addMonths(1).toStartOfMonth().addDays(-1);
            
            system.debug(':::::::::1:::2:::;'+dt1+' '+dt2);
            system.debug('::::::::3:::4:::;'+dt3+' '+dt4);
            
            String str1 = String.valueOf(dt1);
            String str2 = String.valueOf(dt2);
            String str3 = String.valueOf(dt3);
            String str4 = String.valueOf(dt4);
          
            weekRanges.add(str1.split('-')[1]+'/'+str1.split('-')[2]+'/'+str1.split('-')[0]+' / '+str2.split('-')[1]+'/'+str2.split('-')[2]+'/'+str2.split('-')[0]);
            weekRanges.add(str3.split('-')[1]+'/'+str3.split('-')[2]+'/'+str3.split('-')[0]+' / '+str4.split('-')[1]+'/'+str4.split('-')[2]+'/'+str4.split('-')[0]);
            
            pastStartDate = pastStartDate.addMonths(1);
        }
        
        system.debug('::::::::weekRanges::::'+weekRanges);
        String currentdtStart = String.valueOf(monthFrom);
        String currentdtEnd = String.valueOf(monthTo);
        
        
        
        TimeCardDayDomain.Approval_SemiMonthlyWrapper semiMonthly = new TimeCardDayDomain.Approval_SemiMonthlyWrapper();
        semiMonthly.weekRanges = weekRanges;
        semiMonthly.currentWeek = currentdtStart.split('-')[1]+'/'+currentdtStart.split('-')[2]+'/'+currentdtStart.split('-')[0]+' / '+currentdtEnd.split('-')[1]+'/'+currentdtEnd.split('-')[2]+'/'+currentdtEnd.split('-')[0];
        
        
        return JSON.serialize(semiMonthly);
    }
    
    /**************************************************************************
    - Semi monthly summary information related method - used in mobile approval page semi monthly summary
    - Added by NS on June 27 2018
    ***************************************************************************/
    @AuraEnabled
    public static String SemiMonthlyInformation(String startDate,String endDate){
        Date MonthStart = Date.valueOf(startDate);
        Date MonthEnd = Date.valueOf(endDate);
        
        system.debug('::::::statrt:::date:::'+MonthStart+' '+MonthEnd);
        Id usrId = UserInfo.getUserId();
        String firstName = UserInfo.getFirstName();
        String lastName = UserInfo.getLastName();
        
        String fname = '%'+firstName+'%';
        String lName = '%'+lastName+'%';
        
        List<Date> MonthdaysList = new List<Date>();
        Set<Id> projectIdSet = new Set<Id>();
        
        Date date1 = MonthStart;
        Date date2 = MonthEnd;
         
        while(MonthStart <= MonthEnd) {
            MonthdaysList.add(MonthStart);
            MonthStart = MonthStart.addDays(1);
        }
        
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
        
        String filterCondition = ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c = \''+usrId+'\' AND Status__c != \'Unposted\' ORDER BY AcctSeed__Date__c ASC';
        
        timeCardDayList = TimeCardDayService.getTimeCardDayRecords_Withfilters(filterCondition,parentFields,date1,date2,new Set<Id>{});
        
        /*String filterCondition1 = ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'Candidate\' AND Status__c != \'Unposted\' ORDER BY AcctSeed__Date__c ASC';
        
        if(projectIdSet != null && projectIdSet.size() > 0)
            timeCardDayList.addAll(TimeCardDayService.getTimeCardDayRecords_Withfilters(filterCondition1,parentFields,date1,date2,projectIdSet));*/
        
        system.debug(':::::timeCardDayList:::::::'+timeCardDayList);
        
        TimeCardDayDomain.Approval_SemiMonthlyWrapper entrySummary = new TimeCardDayDomain.Approval_SemiMonthlyWrapper();
        entrySummary = TimeCardDayTranslator.MobileApproval_SemiMonthlyFormation(timeCardDayList,MonthdaysList);
        
        return JSON.serialize(entrySummary);
    }
}