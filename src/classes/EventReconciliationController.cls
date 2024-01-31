public with sharing class EventReconciliationController {
    
    //static map to hold the TCD & types of changes related info to form the Notes
    //Work Item No : W-001481
    public static Map<Id,String> tcdIdNoteType = new Map<Id,String>();
    
    //Below static variables for mentions the group action type from timesheet page
    public static Boolean isGroupAction;
    public static String groupActionType;
    
    @AuraEnabled
    public static EventDomain.TimeEventDetails getWholeDetails(String fromDate,String toDate,String supervisorId,String viewType, String projSection){
        system.debug('::::::::filters::::::'+fromDate+'/'+toDate+'/'+supervisorId+'/'+projSection);
        system.debug(':::::viewType::::'+viewType);
             system.debug(':::::projSection::::'+projSection+supervisorId);
        
        Map<String,Integer> proIdEventCount = new Map<String,Integer>();
        Map<String,Integer> proIdDayCount = new Map<String,Integer>();
        Map<String,Integer> proIdStuApprovedDayCount = new Map<String,Integer>();
        Set<Id> projectId = new Set<Id>();
        List<AcctSeed__Project__c> projectRecords = new List<AcctSeed__Project__c>();
        
        Map<Id,String> proIdTimesheetStatus = new Map<Id,String>();
        
        Set<Id> ltsRelatedProIds = new Set<Id>();
        
        Date stDate = fromDate != null ? Date.valueOf(fromDate) : null;
        Date endDate = toDate != null ? Date.valueOf(toDate) : null;
        
        //Qry logged in user related contact to prepopulate as default option on LTS filter
        List<Contact> conRecList = new List<Contact>();
        if(String.isBlank(supervisorId) && String.isBlank(projSection)){
            
            Id usrId = UserInfo.getUserId();
            String firstName = UserInfo.getFirstName();
            String lastName = UserInfo.getLastName();
            
            String fname = firstName != null ? '%'+String.escapeSingleQuotes(firstName)+'%' : null;
            String lName = lastName != null ? '%'+String.escapeSingleQuotes(lastName)+'%' : null;
            
             if(firstName != null && lastName != null){                  
                conRecList = ContactService.getContactByName(' WHERE FirstName LIKE \''+fname+'\' AND LastName LIKE \''+lName+'\'',',Home_Department_Project__r.Name,Supervisor_Name__r.Name,Supervisor_Name__r.ManagerId,Supervisor_Name__r.Manager.Name,RecordType.DeveloperName',new Set<String>{},'');
            } else if(lastName != null){
                conRecList = ContactService.getContactByName(' WHERE LastName LIKE \''+lName+'\'',',Home_Department_Project__r.Name,Supervisor_Name__r.Name,Supervisor_Name__r.ManagerId,Supervisor_Name__r.Manager.Name,RecordType.DeveloperName',new Set<String>{},'');
            }
            system.debug('::::::conRecList::::'+conRecList);
            
            if(conRecList.size() > 0){
                supervisorId = conRecList[0].Id;
            }
            
        }
        
        String tcdQry = 'SELECT Id,Name,AcctSeed__Date__c,Total_Hours_Before_Approved__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Status__c,'
                            +'AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,'
                            +'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,'
                            +'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c,'
                            +'AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c,AcctSeed__Time_Card_Line__r.Location__r.Name,AcctSeed__Time_Card_Line__r.Payroll_Item__c,Late_Cancellation__c,Student_Approval_Status__c'
                            +' FROM AcctSeed__Time_Card_Day__c ';
        String dayFilter = '';
        
        String eveQry = 'SELECT Id,Name,Date__c,Duration__c,Start_Time__c,End_Time__c,Status__c,Project__c,Project__r.Name,Schedule__c,Schedule__r.Name,'
                            +'Schedule__r.Project_Task__c,Schedule__r.Project_Task__r.Name,Instructor__c,Instructor__r.Name,Time_Card_Day__c'
                            +' FROM Events__c ';
        String eventFilter = '';
        String eventFilter1 = '';
        
        if(stDate == null && endDate == null){                
            Date thisWeekStart = system.today().toStartofWeek() + 1;
            stDate = thisWeekStart.addDays(-7);
            endDate = stDate.addDays(6);                       
        }
        
        if(viewType == 'Pending Approval' || viewType == 'Pending Approval - Student Approved' || viewType == 'Pending Approval - Student Not Approved'){
            dayFilter = 'WHERE AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :endDate AND Status__c IN (\'Submitted\',\'Save - Approved\',\'Save - Rejected\')';              
        }else if(viewType == 'Approved'){
            dayFilter = 'WHERE AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :endDate AND Status__c IN (\'Approved\',\'Admin Approved\')';            
        }else if(viewType == 'Rejected'){            
            dayFilter = 'WHERE AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :endDate AND Status__c = \'Rejected\'';            
        }else if(viewType == 'Pending Submission'){            
            dayFilter = 'WHERE AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :endDate AND Status__c IN (\'Draft\',\'Rejected\',\'Recalled\',\'Reverted\')';            
        }else if(viewType == 'All'){            
            dayFilter = 'WHERE AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :endDate AND Status__c != \'Unposted\'';
        }
        
        if(viewType != 'No Time Entries') {
            eventFilter = 'WHERE Date__c >= :stDate AND Date__c <= :endDate AND Status__c IN (\'Scheduled\',\'Completed\',\'Late Cancellation\',\'No class\')';
        }else {
            eventFilter = 'WHERE Date__c >= :stDate AND Date__c <= :endDate AND Status__c IN (\'Scheduled\')';
        }
        
        String conAssignFilter = ' AND Status__c IN (\'Active\',\'On Hold\',\'Ended\') ';
        if(String.isNotBlank(projSection)){
            conAssignFilter += ' AND Project__r.Section__c = \''+projSection+'\'';
        }
        List<Contact_Assignments__c> conAssignments = new List<Contact_Assignments__c>();
        
        //Supervisor Filter
        if(String.isNotEmpty(supervisorId)){
            conAssignments = ContactAssignmentService.getContactAssignmentByContIds(new Set<Id>{supervisorId},new Set<String>{'Staff'},conAssignFilter,',Candidate_Name__r.Name,Project__r.On_Hold_Date__c,Project__r.AcctSeed__Status__c');                        
        }else if(String.isNotBlank(projSection)){
            conAssignFilter = conAssignFilter.replaceFirst('AND', 'WHERE');
            conAssignments = ContactAssignmentService.getContactassignmentRec(conAssignFilter,'Candidate_Name__r.Name,Project__r.On_Hold_Date__c,Project__r.AcctSeed__Status__c');
        }
        
        for(Contact_Assignments__c conAss : conAssignments){
                
            // exclude these DLS library project related request records if the record type is project materials request
            if(conAss.Project__c != null) {
                
                if(conAss.Status__c == 'Ended' && conAss.End_Date__c != null){
                    
                    DateTime dt = DateTime.newInstance(conAss.End_Date__c, Time.newInstance(0, 0, 0, 0));
                    String dayOfWeek = dt.format('EEEE');
                    
                    if(((dayOfWeek == 'Friday' || dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') && conAss.End_Date__c >= stDate && conAss.End_Date__c <= endDate) 
                       || ((conAss.Start_Date__c <= endDate && conAss.End_Date__c >= stDate) /*&& conAss.End_Date__c >= endDate*/)){
                           
                           ltsRelatedProIds.add(conAss.Project__c);
                       }
                    
                }else if( conAss.Status__c != 'Ended' && ((conAss.Project__r.AcctSeed__Status__c == 'On Hold' && conAss.Project__r.On_Hold_Date__c != null && (endDate <= conAss.Project__r.On_Hold_Date__c.addDays(14) || stDate <= conAss.Project__r.On_Hold_Date__c.addDays(14) || (endDate >= conAss.Project__r.On_Hold_Date__c.addDays(14) && stDate <= conAss.Project__r.On_Hold_Date__c.addDays(14)))) || (conAss.Project__r.AcctSeed__Status__c != 'On Hold' && ((conAss.Start_Date__c <= endDate && conAss.End_Date__c >= stDate) || (conAss.Oral_Exam_Date_Time__c <= endDate && conAss.Oral_Exam_Date_Time__c >= stDate))))){
                    
                    ltsRelatedProIds.add(conAss.Project__c);
                }
            }
        }
        
        system.debug(':::::::::ltsRelatedProIds:::'+ltsRelatedProIds);
        system.debug(':::::::::ltsRelatedProIds:::'+ltsRelatedProIds.size());
        
        if(ltsRelatedProIds.size() > 0){
            dayFilter += ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c IN :ltsRelatedProIds';
            eventFilter += ' AND Project__c != null AND Project__c IN :ltsRelatedProIds';
        }
        
        if(String.isNotBlank(projSection)){
            eventFilter += ' AND Project__r.Section__c = :projSection';
            dayFilter += ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Section__c = :projSection';
        }        
        
        String eventQry = eveQry + eventFilter;
        String dayQry = tcdQry + dayFilter;
        system.debug('::::::eventQry::::'+eventQry);
        system.debug('::::::dayQry::::'+dayQry);
        
        Map<Id,Set<String>> proIdTCDStatus = new Map<Id,Set<String>>();
        
        if(viewType != 'No Time Entries'){
        
            for(AcctSeed__Time_Card_Day__c day : database.query(dayQry)){

                Id proId = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                Id insId = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
                Boolean isCountProRelDay = false;
                projectId.add(proId);
                
                if(viewType == 'Pending Approval - Student Approved' || viewType == 'Pending Approval - Student Not Approved'){
                    if(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c != null && day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c != 'Preparation time'){
                        isCountProRelDay = true;
                    }
                }else{
                    isCountProRelDay = true;
                }
                
                if(isCountProRelDay == true){
                    if(!proIdDayCount.containsKey(insId+'-'+proId)){
                        proIdDayCount.put(insId+'-'+proId,1);
                    }else {
                        proIdDayCount.put(insId+'-'+proId,proIdDayCount.get(insId+'-'+proId) + 1);
                    }
                }
                
                if(!proIdTCDStatus.containsKey(proId)){
                    proIdTCDStatus.put(proId,new Set<String>{day.Status__c});
                }else {
                    proIdTCDStatus.get(proId).add(day.Status__c);
                }
                
                if(day.Student_Approval_Status__c == 'Approved'){
                    if(!proIdStuApprovedDayCount.containsKey(insId+'-'+proId)){
                        proIdStuApprovedDayCount.put(insId+'-'+proId,1);
                    }else {
                        proIdStuApprovedDayCount.put(insId+'-'+proId,proIdStuApprovedDayCount.get(insId+'-'+proId) + 1);
                    }
                }
            }
        }
        
        //Work item: W-004244
        if(viewType == 'All') {
        
            Set<String> pendingApprovalStatus = new Set<String>{'Submitted','Save - Approved','Save - Rejected'};
            Set<String> pendingSubmissionStatus = new Set<String>{'Draft','Rejected','Recalled','Reverted'};
            Set<String> approvedStatus = new Set<String>{'Approved','Admin Approved'};
            Set<String> rejectedStatus = new Set<String>{'Rejected'};
            
            //If viewtype is All then for this map
            for(Id proId : proIdTCDStatus.keySet()){
                
                for(String status : proIdTCDStatus.get(proId)){
                    
                    if(pendingApprovalStatus.contains(status)){
                        proIdTimesheetStatus.put(proId,'Pending LTS Approval');
                    }
                    
                    if(pendingSubmissionStatus.contains(status)){
                        proIdTimesheetStatus.put(proId,'Pending Submission');
                    }
                    
                    if(approvedStatus.contains(status)){
                        proIdTimesheetStatus.put(proId,'LTS Approved');
                    }
                    
                    if(rejectedStatus.contains(status)){
                        proIdTimesheetStatus.put(proId,'LTS Rejected');
                    }
                    
                }
            }
        
        }
        
        system.debug('proIdDayCount'+proIdDayCount);

        for(Events__c eve : database.query(eventQry)){
            projectId.add(eve.Project__c);
            
            if(!proIdEventCount.containsKey(eve.Instructor__c+'-'+eve.Project__c)){
                proIdEventCount.put(eve.Instructor__c+'-'+eve.Project__c,1);
            }else {
                proIdEventCount.put(eve.Instructor__c+'-'+eve.Project__c,proIdEventCount.get(eve.Instructor__c+'-'+eve.Project__c) + 1);
            }
            
        }
        
        system.debug('proIdEventCount'+proIdEventCount);
        
        //Qry LTS project related Instructor CA's to filter the Project records for summary table
        Set<Id> filteredProIds = new Set<Id>();
        
        Date caFilterDate = stDate.addDays(-14);
        
        for(Contact_Assignments__c ca : [SELECT Id, Name, Project__c, Start_Date__c, End_Date__c, Status__c FROM Contact_Assignments__c 
                                                WHERE Project__c IN :ltsRelatedProIds AND RecordType.DeveloperName = 'Instructor' 
                                                AND ((Status__c IN ('Active','On Hold') AND ((Start_Date__c <= :endDate AND End_Date__c >= :stDate) OR (Oral_Exam_Date_Time__c <= :endDate AND Oral_Exam_Date_Time__c >= :stDate))) 
                                                    OR (Status__c = 'Ended' AND ((Start_Date__c <= :endDate AND End_Date__c >= :stDate) OR (Oral_Exam_Date_Time__c <= :endDate AND Oral_Exam_Date_Time__c >= :stDate))))]){
        
            filteredProIds.add(ca.Project__c);
        }
        
        projectRecords = [SELECT Id,Name,AcctSeed__Status__c,Start_Date__c,End_Date__c,DLS_Class__c,Service_Item__c, RecordType.Name, RecordType.DeveloperName,
                                QB_Classification__c,Instructors__c,Scheduled_Hours_Week__c,Hours_Remaining__c,
                                 (SELECT Project__c,Candidate_Name__c ,Candidate_Name__r.name,Project_Task__c,Paper_Timesheet__c FROM Contact_Assignments__r 
                                     WHERE RecordType.DeveloperName ='Instructor' 
                                         AND ((Status__c IN ('Active','On Hold') AND ((Start_Date__c <= :endDate AND End_Date__c >= :stDate) OR (Oral_Exam_Date_Time__c <= :endDate AND Oral_Exam_Date_Time__c >= :stDate))) 
                                                    OR (Status__c = 'Ended' AND ((Start_Date__c <= :endDate AND End_Date__c >= :stDate) OR (Oral_Exam_Date_Time__c <= :endDate AND Oral_Exam_Date_Time__c >= :stDate)))))
                         FROM AcctSeed__Project__c 
                         WHERE AcctSeed__Status__c IN ('Active','Ended','On Hold') AND RecordType.DeveloperName != 'Admin_Projects' AND Id IN :filteredProIds];
       
        Set<Id> tcdProIds = new Set<Id>();
        Set<Id> InsCAProIds = new Set<Id>();
        for(AcctSeed__Project__c pro : projectRecords){
            tcdProIds.add(pro.Id);
            for(Contact_Assignments__c conAssign : pro.Contact_Assignments__r){
                InsCAProIds.add(conAssign.Candidate_Name__c);
            }
        }
        
        // Qry TCD records group by Project to display the Total hours values per project & for selected week in project summary table
        Map<String,Decimal> projectIdTCDHours = new Map<String,Decimal>();
        for(AcctSeed__Time_Card_Day__c day : [SELECT Id,Total_Hours_Before_Approved__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c 
                                                    FROM AcctSeed__Time_Card_Day__c                  
                                                    WHERE Status__c != 'Unposted' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c  IN :tcdProIds AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c IN :InsCAProIds
                                                        AND AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :endDate]) {
               
            String key = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c+'-'+day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
               
            if(!projectIdTCDHours.containsKey(key)){
                projectIdTCDHours.put(key,day.Total_Hours_Before_Approved__c);
            }else if(projectIdTCDHours.containsKey(key)) {
                Decimal hrs = projectIdTCDHours.get(key) + day.Total_Hours_Before_Approved__c;
                projectIdTCDHours.put(key,hrs);
            }                                                                       
        }
        
        Map<String,Decimal> projectIdTCDStuApprovedHrs = new Map<String,Decimal>();
        for(AcctSeed__Time_Card_Day__c day : [SELECT Id,Total_Hours_Before_Approved__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c
                                                    FROM AcctSeed__Time_Card_Day__c 
                                                    WHERE Status__c != 'Unposted' AND Student_Approval_Status__c = 'Approved' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c IN :tcdProIds
                                                        AND AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :endDate]) {
            
            String key = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c+'-'+day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            
            if(!projectIdTCDStuApprovedHrs.containsKey(key)){
                projectIdTCDStuApprovedHrs.put(key,day.Total_Hours_Before_Approved__c);
            }else if(projectIdTCDStuApprovedHrs.containsKey(key)) {
                Decimal hrs = projectIdTCDStuApprovedHrs.get(key) + day.Total_Hours_Before_Approved__c;
                projectIdTCDStuApprovedHrs.put(key,hrs);
            }
        }
        
        //Qry project related schedules related to selected week range to for No Time Entries & All view type options
        Map<Id,Boolean> projectIdEventExist = new Map<Id,Boolean>();
        Map<Id,Decimal> projIdEventsHrs = new Map<Id,Decimal>();
        
        if(viewType == 'All'){
        
            for(Events__c eve : [SELECT Id,Name,Date__c,Project__c FROM Events__c WHERE Project__c IN :tcdProIds 
                                        AND Status__c IN ('Scheduled','Completed','Late Cancellation','No class') AND (Date__c >= :stDate AND Date__c <= :endDate)]){
                
                if(!projectIdEventExist.containsKey(eve.Project__c)){
                    projectIdEventExist.put(eve.Project__c,true);
                }
            }
        }else if(viewType == 'No Time Entries'){
        
            for(Events__c eve : [SELECT Id,Name,Date__c,Duration__c,Project__c FROM Events__c WHERE Project__c IN :tcdProIds 
                                        AND Status__c IN ('Scheduled','Canceled','No class') AND (Date__c >= :stDate AND Date__c <= :endDate)]){
                
                if(!projectIdEventExist.containsKey(eve.Project__c)){
                    projectIdEventExist.put(eve.Project__c,true);
                }
                
                if(!projIdEventsHrs.containsKey(eve.Project__c)){
                    projIdEventsHrs.put(eve.Project__c,eve.Duration__c);
                }else {
                    projIdEventsHrs.put(eve.Project__c,(projIdEventsHrs.get(eve.Project__c) + eve.Duration__c));
                }
            }
            
            system.debug('::::projIdEventsHrs::::'+projIdEventsHrs);
        }
        
        Map<Id, Map<Id, Schedule__c>> projectIdWithInstructorAndScheduleMap = new Map<Id, Map<Id, Schedule__c>>();
        for(Schedule__c sch : [SELECT Id, Project__c, Varied_Day__c, Varied_Time__c, Instructor__c 
                               FROM Schedule__c 
                               WHERE End_Date__c >= :stDate AND Start_Date__c <= :endDate AND Status__c = 'Active' 
                               AND Project__c IN :tcdProIds AND Project_Task__r.Project_Task_Type__c != 'Preparation time']){
                                   
            if(!projectIdWithInstructorAndScheduleMap.containsKey(sch.Project__c)){
                projectIdWithInstructorAndScheduleMap.put(sch.Project__c, new Map<Id, Schedule__c>());                           
            }
            
            projectIdWithInstructorAndScheduleMap.get(sch.Project__c).put(sch.Instructor__c, sch);                                   
        }
        
        EventDomain.TimeEventDetails timeEveDetails = EventTranslator.timeEventGroupedDetails(proIdDayCount,proIdEventCount,projectRecords,stDate,endDate,projectIdTCDHours,conRecList,projectIdTCDStuApprovedHrs,viewType,projectIdEventExist,projIdEventsHrs,proIdTimesheetStatus, projectIdWithInstructorAndScheduleMap, proIdStuApprovedDayCount);
        system.debug(':::::::::timeEveDetails:::'+timeEveDetails);
        
        return timeEveDetails;
    }
    
    /********************************************************************
    - Method to construct the Week range values from Time Lock Log date to current week
    - Added by NS on Nov 8 2018
    *********************************************************************/
    @AuraEnabled
    public static String weekRangeFormation() {
        
        // Get TimeLog_Locking_Date custom setting value    
        System_Values__c sysVal = System_Values__c.getValues('TimeLog_Locking_Date');    
        Date lockingDate;   
        if (sysVal != null && sysVal.Value__c != null) {
            lockingDate = Date.valueOf(sysVal.Value__c);
        } 
        
        Set<Date> wholeDateSet = new Set<Date>();
        Set<String> weekRangeSet = new Set<String>();
        
        // Get the dates between after locking date & current date
        
        Date stDateAfterlock = lockingDate.addDays(1);
        //Date endDateuptoToday = system.today().toStartofWeek().addDays(1);
        Date endDateuptoToday;
        if(system.today() >= system.today().toStartofWeek().addDays(1)) {
            endDateuptoToday = system.today().toStartofWeek().addDays(1).addDays(6);
        }else {
            endDateuptoToday = system.today();
        }
        
        while(stDateAfterlock < endDateuptoToday) {
            wholeDateSet.add(stDateAfterlock);
            stDateAfterlock = stDateAfterlock.addDays(1);
        }
        
        system.debug(':::wholeDateSet::::::'+wholeDateSet);
        system.debug(':::wholeDateSet::size::::'+wholeDateSet.size());
        
        // Get Week ranges for all the above date values
        
        for(Date dt : wholeDateSet) {
        
            Date st;
            
            if(dt.toStartofWeek().addDays(1) < dt) {
                st = dt.toStartofWeek().addDays(1);
            } else {
                st = dt.addDays(-1).toStartofWeek().addDays(1);
            }
            
            Date ed = st.addDays(6); 
            
            if(!weekRangeSet.contains(String.valueOf(st).split(' ')[0]+' to '+String.valueOf(ed).split(' ')[0])) {
                weekRangeSet.add(String.valueOf(st).split(' ')[0]+' to '+String.valueOf(ed).split(' ')[0]);
            }
        }
        
        system.debug('::::::::weekRangeSet:::::::'+weekRangeSet);
        system.debug('::::::::weekRangeSet::::size:::'+weekRangeSet.size());
        Set<String> allSections = new Set<String>();
        for(ListViewController.PicklistWrap picklist : ListViewController.getPickListValues('Acctseed__Project__c','Section__c')){
           allSections.add(picklist.value);
        }
        
        Map<String, Set<String>> resultMap  = new Map<String, Set<String>>();
        resultMap.put('weekrange',weekRangeSet);
        resultMap.put('sections', allSections);
        return JSON.serialize(resultMap);
    }
    
    /******************************************************
     - Get Lookup search related records
     - Added by NS on Nov 1 2018
    *******************************************************/
    @AuraEnabled
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(searchString,objectName,fieldName,condition,selectedIds);
    }   
    
    /***************************************************************
    - Method to update the Event records
    - Added by NS on Nov 8 2018
    *****************************************************************/
    @AuraEnabled
    public static String eventUpdate(String eventJson){
        
         try {
            List<Events__c> eventList = (List<Events__c>) System.JSON.deserialize(eventJson, List<Events__c>.class);
            system.debug('::::::::eventList:::::::'+eventList);
            
            if(eventList.size() > 0){
                update eventList;
            }
            
            return 'SUCCESS';
            
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    
    }
    
    /********************************************************************
    - Method to get the Event & Time Card Day details based on the project row click
    - Added by NS on Dec 13 2018
    ***********************************************************************/
    @AuraEnabled
    public static EventDomain.ProjectTimeEventInfo getProjectBasedEventTimeDetails(String fromDate,String toDate,String supervisorId,String projectId,String viewType,String instructorId,String taskId){
        
        List<Events__c> eventRecords = new List<Events__c>();
        List<AcctSeed__Time_Card_Day__c> dayRecords = new List<AcctSeed__Time_Card_Day__c>();
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        List<Accounting_Seed_Time_Snapshot__c> accTimesnapshot = new List<Accounting_Seed_Time_Snapshot__c>();
        List<EventDomain.WeekRangeValues> weekDates = new List<EventDomain.WeekRangeValues>();
        
        Date stDate = fromDate != null ? Date.valueOf(fromDate) : null;
        Date endDate = toDate != null ? Date.valueOf(toDate) : null;
        
        String tcdQry = 'SELECT Id,Name,AcctSeed__Date__c,Total_Hours_Before_Approved__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Late_Cancellation__c,'
                            +'AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.No_Student_Approval__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,'
                            +'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Invoice_Comment__c,'
                            +'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c,End_Time1__c,Start_Time1__c,'
                            +'AcctSeed__Time_Card_Line__r.Location__r.Name,AcctSeed__Time_Card_Line__r.Payroll_Item__c,Student_Approval_Status__c,Week_Day__c,Status__c,Start_Time2__c,End_Time2__c '
                            +'FROM AcctSeed__Time_Card_Day__c ';
        
        String eveQry = 'SELECT Id,Name,Date__c,Duration__c,Start_Time__c,End_Time__c,Status__c,Project__c,Project__r.Name,Schedule__c,Schedule__r.Name,'
                            +'Schedule__r.Project_Task__c,Schedule__r.Project_Task__r.Name,Instructor__c,Instructor__r.Name,Time_Card_Day__c,Time_Card_Day__r.Name,'
                            +'Time_Card_Day__r.AcctSeed__Time_Card_Line__r.Location__r.Name,Time_Card_Day__r.AcctSeed__Time_Card_Line__r.Payroll_Item__c,Time_Card_Day__r.AcctSeed__Date__c,'
                            +'Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c'
                            +' FROM Events__c ';
                            
        String dayFilter = '';
        String eventFilter = 'WHERE Project__c = \''+projectId+'\' AND Instructor__c = \''+instructorId+'\' AND Date__c >= :stDate AND Date__c <= :endDate AND Status__c IN (\'Scheduled\',\'Completed\',\'Late Cancellation\') ORDER BY Date__c ASC';

        
   
        if((viewType == 'Pending Approval' || viewType == 'Pending Approval - Student Approved' || viewType == 'Pending Approval - Student Not Approved') && String.isNotBlank(projectId) && String.isNotBlank(instructorId)) {
        
            dayFilter = 'WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = \''+projectId+'\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = \''+instructorId+'\' AND AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :endDate AND Status__c IN (\'Submitted\',\'Save - Approved\',\'Save - Rejected\')';
        
        }else if(viewType == 'Approved' && String.isNotBlank(projectId) && String.isNotBlank(instructorId)) {
            
            dayFilter = 'WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = \''+projectId+'\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = \''+instructorId+'\' AND AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :endDate AND Status__c IN (\'Approved\',\'Admin Approved\')';
        
        }else if(viewType == 'Rejected' && String.isNotBlank(projectId) && String.isNotBlank(instructorId)) {    //included approved entries for work item:W-004248
            
            dayFilter = 'WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = \''+projectId+'\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = \''+instructorId+'\' AND AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :endDate AND Status__c IN (\'Rejected\',\'Approved\',\'Admin Approved\')';
        
        }else if(viewType == 'Pending Submission' && String.isNotBlank(projectId) && String.isNotBlank(instructorId)) {
            
            dayFilter = 'WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = \''+projectId+'\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = \''+instructorId+'\' AND AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :endDate AND Status__c IN (\'Draft\',\'Rejected\',\'Recalled\',\'Reverted\')';
        
        }else if(viewType == 'All' && String.isNotBlank(projectId) && String.isNotBlank(instructorId)){
        
            dayFilter = 'WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = \''+projectId+'\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = \''+instructorId+'\' AND AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :endDate AND Status__c != \'Unposted\'';
        }
        
        dayFilter += ' ORDER BY AcctSeed__Date__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c ASC';
        
        String eventQry = eveQry + eventFilter;
        String dayQry = tcdQry + dayFilter;
        system.debug('::::::eventQry::::'+eventQry);
        system.debug('::::::dayQry::::'+dayQry);
        
        eventRecords = database.query(eventQry);
        
        if(viewType != 'No Time Entries'){
            dayRecords = database.query(dayQry);
        }
        
        set<Id> tcdIds = new  set<Id>();
        for(AcctSeed__Time_Card_Day__c tcd : dayRecords){
            tcdIds.add(tcd.Id);
        }
        
        // Time Snapshot formation
        if(tcdIds.size() > 0){
            accTimesnapshot = TimeSnapshotService.getSnpshotWithDaysIds(tcdIds);
        }
        
        String projectRTName = '';
        
        if(projectId != null){
        List<AcctSeed__Project__c> projectRecord = [SELECT Id,Name,RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :projectId];
            projectRTName = projectRecord[0].RecordType.DeveloperName;            
        }
        
        Date st = Date.valueOf(fromDate);
        Date ed =  Date.valueOf(toDate);

        while(st <= ed){
            EventDomain.WeekRangeValues wkVal = new EventDomain.WeekRangeValues();
            
            wkVal.dateValue = String.valueOf(st).split('-')[1]+'/'+String.valueOf(st).split('-')[2]+'/'+String.valueOf(st).split('-')[0];
            DateTime todayVal = DateTime.newInstance(st, Time.newInstance(0, 0, 0, 0));
            wkVal.dayVal = todayVal.format('EEE').toUppercase();
            weekDates.add(wkVal);
            st = st.addDays(1);
        }
        
        EventDomain.ProjectTimeEventInfo proTimeEventInfo = EventTranslator.formEventTimeDetails(dayRecords,eventRecords);
        proTimeEventInfo.notes = JSON.serialize(TimeCardDayCommunityTranslator.notesFormation(accTimesnapshot));
        
        if((projectRTName == 'DLI_W_LT_Projects' || projectRTName == 'DODA_Projects') || (projectRTName == 'Language_Training_Projects')){
            proTimeEventInfo.studentTimeEntry = StudentApproval_Controller.studentTimeEntriesRowFormation(projectRTName,projectId,Date.valueOf(fromDate),Date.valueOf(toDate),instructorId);
        }else{
            proTimeEventInfo.studentTimeEntry = '[]';  
        } 
        
        proTimeEventInfo.weekDetails = JSON.serialize(weekDates);
        proTimeEventInfo.projectRTName = projectRTName;
        
        //check whether we have to show send reminder for the current week
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        DateTime todayVal = DateTime.newInstance(system.today(), Time.newInstance(0, 0, 0, 0));
        
        proTimeEventInfo.showSendReminderBtn = false;
        
        if((currStart == stDate && currEnd == endDate) 
            && (todayVal.format('EEEE') == 'Friday' || todayVal.format('EEEE') == 'Saturday' || todayVal.format('EEEE') == 'Sunday')){
            
            proTimeEventInfo.showSendReminderBtn = true;
            
        }else if(currStart > stDate && currEnd > endDate){
            proTimeEventInfo.showSendReminderBtn = true;
        }
        
        return proTimeEventInfo;
    }
    
    @AuraEnabled
    public static String saveTimeCardEntryRecords(String tCDRecords,String actionType,String comment){
        
        List<AcctSeed__Time_Card_Day__c> tCDRecordsList = (List<AcctSeed__Time_Card_Day__c>) System.JSON.deserialize(TCDRecords, List<AcctSeed__Time_Card_Day__c>.class);
        
        try{
            if(TCDRecordsList.size() > 0){
                List<Contact> conRecList = new List<Contact>();
                
                Set<Id> dayIds = new Set<Id>();
                List<AcctSeed__Time_Card_Line__c> lineRecords = new List<AcctSeed__Time_Card_Line__c>();
                Set<Id> lineIds = new Set<Id>();
                
                for(AcctSeed__Time_Card_Day__c tcd : tCDRecordsList){
                    if(actionType != 'Save Changes') {
                        tcd.Approved_Date__c = System.today();
                        dayIds.add(tcd.Id);
                    }else if(actionType == 'Save Changes'){
                    
                        if(tcd.Status__c == 'Rejected'){
                            if(!tcdIdNoteType.containsKey(tcd.Id)) {
                                tcdIdNoteType.put(tcd.Id,'Weekly Reject');
                            } 
                        }
                    }
                    tcd.Approved_by__c = UserInfo.getUserId();
                    
                    //For Notes Formation static Map
                    
                    if(actionType == 'Approve All') {
                        if(!tcdIdNoteType.containsKey(tcd.Id)) {
                            tcdIdNoteType.put(tcd.Id,'Weekly Approval');
                        }
                    }else if(actionType == 'Reject All') {
                        if(!tcdIdNoteType.containsKey(tcd.Id)) {
                            tcdIdNoteType.put(tcd.Id,'Weekly Reject');
                        }
                    }
                }
                
                if(actionType == 'Approve All') {
                    isGroupAction = true;
                    groupActionType = 'Approved'; 
                }else if(actionType == 'Reject All') {
                    isGroupAction = true;
                    groupActionType = 'Rejected';
                }
                
                update tCDRecordsList;
                
                //Qry day related line records to update supervisor Approval cmt field
                for(AcctSeed__Time_Card_Day__c day : [SELECT Id,Name,AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c WHERE Id IN :dayIds]){
                    if(!lineIds.contains(day.AcctSeed__Time_Card_Line__c)){
                        
                        AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                        line.Id = day.AcctSeed__Time_Card_Line__c;
                        line.Supervisor_Approval_Comment__c = comment;
                        
                        lineRecords.add(line);
                        
                        lineIds.add(day.AcctSeed__Time_Card_Line__c);
                    }
                }
                
                if(lineRecords.size() > 0){
                    update lineRecords;
                }
                
                return JSON.serialize(tCDRecordsList);
            }
            return 'SUCCESS';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    //Method to send email notification to students & instructors from LTS
    @AuraEnabled
    public static string sendReminderEmailToStudentInstructor(String projectId, String instructorId, String startDate, String endDate, String source, List<String> selectedEmailTobeSend){
    
        system.debug(':::::::::::::'+projectId+' '+instructorId+' '+startDate+' '+endDate+' '+source+' '+selectedEmailTobeSend);
        
        try {
        
            Date stDate = Date.valueOf(startDate);
            Date edDate = Date.valueOf(endDate);
            
            Set<Id> tcdIds = new Set<Id>();
            Set<Id> instructorPendingIds = new Set<Id>();
            Set<String> dayStatus = new Set<String>{'Draft','Rejected','Recalled'};
            Boolean sendEmailToInstructor = false;
            Map<Id,AcctSeed__Time_Card_Day__c> dayIdRecMap = new Map<Id,AcctSeed__Time_Card_Day__c>();
            Map<Id,Set<Id>> studentIdDayMap = new Map<Id,Set<Id>>();
            List<EmailTobeSend> emailToBeSendList = new List<EmailTobeSend>();
            
            String dlsClassNo;
            String instructorName;
            
            //For Event based email content formation
            Set<Id> eventIds = new Set<Id>();
            Map<Id,Events__c> eventIdRecMap = new Map<Id,Events__c>();
            Map<Id,Set<Id>> studentIdEventMap = new Map<Id,Set<Id>>();
            
            List<Contact> instructorRec = [SELECT Id,Name FROM Contact WHERE Id = :instructorId];
            List<AcctSeed__Project__c> projectRec = [SELECT Id,Name,DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :projectId];
            
            instructorName = instructorRec.size() > 0 ? instructorRec[0].Name : '';
            dlsClassNo = projectRec.size() > 0 ? projectRec[0].Name : '';
            
                        
            for(AcctSeed__Time_Card_Day__c day : [SELECT Id,Name,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.DLS_Class__c,
                                                        Student_Approval_Status__c,Status__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c,
                                                        Instructor_Name__c,AcctSeed__Date__c
                                                    FROM AcctSeed__Time_Card_Day__c 
                                                    WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = :projectId
                                                        AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :instructorId
                                                        AND AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :edDate 
                                                        AND (Status__c IN :dayStatus OR Student_Approval_Status__c IN ('Rejected','Submitted'))]){
                
                if(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c != 'Preparation time' 
                        && (day.Student_Approval_Status__c == 'Submitted' || day.Student_Approval_Status__c == 'Rejected')){
                    tcdIds.add(day.Id);
                    
                    if(!dayIdRecMap.containsKey(day.Id)){
                        dayIdRecMap.put(day.Id,day);
                    }
                }
                
                if(dayStatus.contains(day.Status__c)){
                    instructorPendingIds.add(day.Id);
                }
                
            }
            
            
            //If no time entries exist and user clicked Send Reminder btn then we need to get project related students 
            // form the contents based on the event details
            //Added by NS on Feb 20 2020
            if(tcdIds.size() == 0){
            
                for(Events__c eve : [SELECT Id,Date__c,Project__c,Duration__c,Status__c,Schedule__r.Project_Task__r.Project_Task_Type__c 
                                        FROM Events__c
                                        WHERE Project__c = :projectId AND Instructor__c = :instructorId AND 
                                                Date__c >= :stDate AND Date__c <= :edDate AND Status__c = 'Scheduled']){
                    
                    if(eve.Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time'){
                        eventIds.add(eve.Id);
                        
                        if(!eventIdRecMap.containsKey(eve.Id)){
                            eventIdRecMap.put(eve.Id,eve);
                        }
                    }
                    
                    instructorPendingIds.add(eve.Id);
                }
            }
            
            system.debug('::::instructorPendingIds:::'+instructorPendingIds);
            system.debug(':::::tcdIds:::'+tcdIds);
            
            List<Messaging.SingleEmailMessage> emailSendingList = new List<Messaging.SingleEmailMessage>();
            String sDate = startDate.split('-')[1]+'/'+startDate.split('-')[2]+'/'+startDate.split('-')[0];
            String eDate = endDate.split('-')[1]+'/'+endDate.split('-')[2]+'/'+endDate.split('-')[0];
            String weekRange = sDate+' to '+eDate;
            
            if(source == 'Send Email' && selectedEmailTobeSend.contains(instructorId)) {
            
                //Send Email to instructor to submit their last week time
                if(instructorPendingIds.size() > 0){
                    
                    String urlRedirectToInsPage = '<a href="'+ System.Label.Instructor_Community_Site_Prefix+'/s/instructor-time-entry?week='+ weekRange + '&projectId='+ projectId+ '" target="_blank"> Click Here </a>';
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(instructorId);
                    mail.subject = 'DLS Timekeeping - Reminder to submit your timesheet for DLS Class #: '+dlsClassNo+' for last week';
                     
                    String htmlBody = '';
                    htmlBody += 'Hi '+instructorName+ ', <br/><br/>'; 
                    htmlBody += 'This is a reminder to submit your timesheet for DLS Class #: '+dlsClassNo+' for last week.<br/><br/>';
                    htmlBody += 'Please go to the Time Entry Page - '+ urlRedirectToInsPage +' to complete your timesheet and select the Submit button when you are finished.';
                    htmlBody += 'If you did not have class last week, please enter 0.00 for this class on your timesheet for all days you were scheduled and select the submit button.<br/><br/>';
                    htmlBody += 'If you have any questions or require any assistance, please contact your LTS or reply to timesheets@dlsdc.com to get help.<br/><br/>';
                    
                    htmlBody += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email';
        
                    mail.setHtmlBody(htmlBody);
                    mail.setSaveAsActivity(true);
                    emailSendingList.add(mail);
                }    
            }else {
                EmailTobeSend instructorEmail = new EmailTobeSend();
                instructorEmail.label = instructorName;
                instructorEmail.value = instructorId;
                emailToBeSendList.add(instructorEmail);
            }
            
           
           //If time entry exist for that week use below code
            
            //Send email to student to approve/reject their last week class hours
            if(tcdIds.size() > 0){
            
                Map<Id,Id> dayIdStudentIdMap = timeCardRelated_Email_Controller.getClassLeaderforTCD(tcdIds,true);
                for(Id dayId : dayIdStudentIdMap.keySet()){
                    if((selectedEmailTobeSend.contains(dayIdStudentIdMap.get(dayId)) && source == 'Send Email') || source != 'Send Email') {
                        if(!studentIdDayMap.containsKey(dayIdStudentIdMap.get(dayId))){
                            studentIdDayMap.put(dayIdStudentIdMap.get(dayId), new Set<Id>{dayId});
                        }else {
                            studentIdDayMap.get(dayIdStudentIdMap.get(dayId)).add(dayId);
                        }            
                    }
                }
                
                system.debug('::::::studentIdDayMap:::'+studentIdDayMap);
                
                Map<Id,Contact> studentIdRecMap = new Map<Id,Contact>();
                for(Contact con : [SELECT Id,Name FROM Contact WHERE Id IN :studentIdDayMap.keySet()]){
                    if(source == 'Send Email') {
                        if(!studentIdRecMap.containsKey(con.Id)){
                            studentIdRecMap.put(con.Id,con);
                        }
                    }else {
                        EmailTobeSend studentEmailList = new EmailTobeSend();
                        studentEmailList.label = con.Name;
                        studentEmailList.value = con.Id;
                        
                        emailToBeSendList.add(studentEmailList);
                    }
                    
                }
                system.debug(':::::studentIdRecMap:::'+studentIdRecMap);
                
                String urlRedirectToStdPage = '<a href="'+ System.Label.Student_Community_Site_Prefix +'/s/time-approval?week='+weekRange+'&projectId='+projectId+'&instructorId='+instructorId+'" target="_blank"> Click Here </a>';
                
                if(source == 'Send Email') {
                    for(Id stuId : studentIdDayMap.keySet()){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(stuId);
                        mail.subject = 'DLS Timekeeping - Reminder to approve all time entries for DLS Class #: '+dlsClassNo+' for the previous week';
                         
                        String htmlBody = '';
                        htmlBody += 'Hi '+studentIdRecMap.get(stuId).Name+ ', <br/><br/>';
                        
                        htmlBody += 'This is a reminder to review and approve or reject the time entries your instructor recently submitted for your class. ';
                        htmlBody += 'Please go to the Time Approval Page - '+ urlRedirectToStdPage +' to approve or reject these time entries.<br/><br/>';
                        
                        htmlBody += '<table border="1" style="border-collapse: collapse"><tr>';
                        htmlBody += '<th width="25%" style="text-align: center; vertical-align: middle;">Class #</th>';
                        htmlBody += '<th width="50%" style="text-align: center; vertical-align: middle;">Instructor Name</th>';
                        htmlBody += '<th width="25%" style="text-align: center; vertical-align: middle;">Date</th></tr>';
                        
                        for(Id dayId : studentIdDayMap.get(stuId)){
                            Date dayDt = dayIdRecMap.get(dayId).AcctSeed__Date__c;
                            String dt = String.valueOf(dayDt).split('-')[1]+'/'+String.valueOf(dayDt).split('-')[2]+'/'+String.valueOf(dayDt).split('-')[0];
                            
                            htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">'+dlsClassNo+'</td><td style="text-align: center; vertical-align: middle;">'+instructorName+'</td><td style="text-align: center; vertical-align: middle;">'+dt+'</td></tr>';
                        }
                        
                        htmlBody += '</table><br/><br/>';
                        
                        htmlBody += 'If you have any questions or require any assistance, please contact your LTS or reply to timesheets@dlsdc.com to get help.<br/><br/>';
                        
                        htmlBody += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email';
            
                        mail.setHtmlBody(htmlBody);
                        mail.setSaveAsActivity(true);
                        emailSendingList.add(mail);
                    }
                }
                
            }else if(eventIds.size() > 0){    //If no time entries exist and user clicked Send Reminder btn then we need to get project related students & form the contents based on the event details
                
                Map<Id,Id> eventIdStudentIdMap = timeCardRelated_Email_Controller.getClassLeaderforLTSApproval(eventIds,true);
                
                system.debug(':::::::::eventIdStudentIdMap::::'+eventIdStudentIdMap);
                
                for(Id eveId : eventIdStudentIdMap.keySet()){
                
                    if((selectedEmailTobeSend.contains(eventIdStudentIdMap.get(eveId)) && source == 'Send Email') || source != 'Send Email') {
                    
                        if(!studentIdEventMap.containsKey(eventIdStudentIdMap.get(eveId))){
                            studentIdEventMap.put(eventIdStudentIdMap.get(eveId), new Set<Id>{eveId});
                        }else {
                            studentIdEventMap.get(eventIdStudentIdMap.get(eveId)).add(eveId);
                        }            
                    }
                }
                
                system.debug('::::::studentIdEventMap:::'+studentIdEventMap);
                
                Map<Id,Contact> studentIdRecMap = new Map<Id,Contact>();
                
                for(Contact con : [SELECT Id,Name FROM Contact WHERE Id IN :studentIdEventMap.keySet()]){
                    if(source == 'Send Email') {
                        if(!studentIdRecMap.containsKey(con.Id)){
                            studentIdRecMap.put(con.Id,con);
                        }
                    }else {
                        EmailTobeSend studentEmailList = new EmailTobeSend();
                        studentEmailList.label = con.Name;
                        studentEmailList.value = con.Id;
                        
                        emailToBeSendList.add(studentEmailList);
                    }
                    
                }
                system.debug(':::::studentIdRecMap:::'+studentIdRecMap);
                
                String urlRedirectToStdPage = '<a href="'+ System.Label.Student_Community_Site_Prefix +'/s/time-approval?week='+weekRange+'&projectId='+projectId+'&instructorId='+instructorId+'" target="_blank"> Click Here </a>';
                
                if(source == 'Send Email') {
                
                    for(Id stuId : studentIdEventMap.keySet()){
                    
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(stuId);
                        mail.subject = 'DLS Timekeeping - Reminder to approve all time entries for DLS Class #: '+dlsClassNo+' for the previous week';
                         
                        String htmlBody = '';
                        htmlBody += 'Hi '+studentIdRecMap.get(stuId).Name+ ', <br/><br/>';
                        
                        htmlBody += 'This is a reminder to review and approve or reject the time entries your instructor recently submitted for your class. ';
                        htmlBody += 'Please go to the Time Approval Page - '+ urlRedirectToStdPage +' to approve or reject these time entries.<br/><br/>';
                        
                        htmlBody += '<table border="1" style="border-collapse: collapse"><tr>';
                        htmlBody += '<th width="25%" style="text-align: center; vertical-align: middle;">Class #</th>';
                        htmlBody += '<th width="50%" style="text-align: center; vertical-align: middle;">Instructor Name</th>';
                        htmlBody += '<th width="25%" style="text-align: center; vertical-align: middle;">Date</th></tr>';
                        
                        for(Id eveId : studentIdEventMap.get(stuId)){
                            Date eveDt = eventIdRecMap.get(eveId).Date__c;
                            String dt = String.valueOf(eveDt).split('-')[1]+'/'+String.valueOf(eveDt).split('-')[2]+'/'+String.valueOf(eveDt).split('-')[0];
                            
                            htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">'+dlsClassNo+'</td><td style="text-align: center; vertical-align: middle;">'+instructorName+'</td><td style="text-align: center; vertical-align: middle;">'+dt+'</td></tr>';
                        }
                        
                        htmlBody += '</table><br/><br/>';
                        
                        htmlBody += 'If you have any questions or require any assistance, please contact your LTS or reply to timesheets@dlsdc.com to get help.<br/><br/>';
                        
                        htmlBody += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email';
            
                        mail.setHtmlBody(htmlBody);
                        mail.setSaveAsActivity(true);
                        emailSendingList.add(mail);
                    }
                }
            }
            
            
            system.debug(':::::::emailSendingList:::'+emailSendingList);
            
            if(emailSendingList.size() > 0 && source == 'Send Email'){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailSendingList);
                return 'SUCCESS';
            }else {
                return json.serialize(emailToBeSendList);
            }
            
        
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public class EmailTobeSend {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
}