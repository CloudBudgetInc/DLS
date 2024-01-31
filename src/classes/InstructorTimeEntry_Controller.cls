/************************************************************
 - Developed by NS on MAR 4 2019
 - For Instructor Time Entry Lightning Component Usage
************************************************************/
public without sharing class InstructorTimeEntry_Controller {

    //Below static variables for mentions the group action type from timesheet page
    public static Boolean isGroupAction;
    public static String groupActionType;
    
    //static map to hold the TCD & types of changes related info to form the Notes
    //Work Item No : W-001481
    public static Map<Id,String> tcdIdNoteType = new Map<Id,String>();
    public static String pageType;
    
    /***************************************************************
     - Method to get the Week filter information
    ****************************************************************/
    @AuraEnabled
    public static String getInitialFilterValues(){
        try {
            Set<String> weekRangeSet = new Set<String>();
            Set<Date> wholeDateSet = new Set<Date>();
            
            Date today = system.today();
            Date currst;
            
            //W-007818 - difference timezone handling
            Datetime dtime = datetime.newInstance(today.toStartofWeek(), Time.newInstance(0,0,0,0));
            String startOfWeek = dtime.format('EEE'); 
            
            //if today = sunday need to load the last week data - because saleforce start of the week is sunday
            //W-007818 - difference timezone handling
            if(today.toStartofWeek() == today) {
                currst = today.addDays(-1).toStartofWeek().addDays((startOfWeek == 'Sat') ? 2 : 1);
            }else {
                currst = today.toStartofWeek().addDays((startOfWeek == 'Sat') ? 2 : 1);
            }
            
            Date currend = currst.addDays(6);
            
            Id usrId = UserInfo.getUserId();
            
            //Qry User record to get the Email address to get the exact match for the user in contact level
            List<User> usrRec = [SELECT Id,Name,FirstName,LastName,Email,ContactId FROM User WHERE Id = :usrId];
            system.debug(':::::::::usrRec:::::'+usrRec);
            
            List<Contact> conRecList = new List<Contact>();
            Boolean internalUser = false;
            
            if(usrRec.size() > 0 && usrRec[0].ContactId != null) {
            
                conRecList = [SELECT Id,Name,PC_EE_ID__c FROM Contact WHERE Id = :usrRec[0].ContactId];
                
            }else if(usrRec[0].ContactId == null){    //include logic to get internal user related contact
                
                internalUser = true;
                
                String fname = usrRec[0].FirstName != null ? '%'+String.escapeSingleQuotes(usrRec[0].FirstName)+'%' : null;
                String lName = usrRec[0].LastName != null ? '%'+String.escapeSingleQuotes(usrRec[0].LastName)+'%' : null;
                
                if(usrRec[0].FirstName != null && usrRec[0].LastName != null){                  
                    conRecList = ContactService.getContactByName(' WHERE Email = \''+usrRec[0].Email+'\' AND FirstName LIKE \''+fname+'\' AND LastName LIKE \''+lName+'\'',',RecordType.DeveloperName',new Set<String>{},'');
                }else if(usrRec[0].LastName != null) { 
                    conRecList = ContactService.getContactByName(' WHERE Email = \''+usrRec[0].Email+'\' AND LastName LIKE \''+lName+'\'',',RecordType.DeveloperName',new Set<String>{},'');
                }
         
            }
            
            //W-006759 - To display future 2 weeks for UAE instructors to enter fringe times
            //Added by NS on June 11 2021
            Boolean displayFutureWeeks = false;
            
            if(conRecList.size() > 0){
                
                List<Contact_Assignments__c> conAssignList = [SELECT Id,Name,Status__c FROM Contact_Assignments__c 
                                                                WHERE Candidate_Name__c = :conRecList[0].Id AND Project__r.RecordType.DeveloperName = 'EFL_Projects' 
                                                                AND End_Date__c > :currend];
                
                if(conAssignList.size() > 0 && conAssignList.size() == 1){
                    displayFutureWeeks = true;
                }
            }
            
            
            //Week Range formation
            Date stDate = currst.addDays(-28);
            Date endDate;
            
            if(displayFutureWeeks){
                endDate = currend.addDays(14);
            }else {
                endDate = currend;
            }
            
            while(stDate <= endDate) {
                wholeDateSet.add(stDate);
                stDate = stDate.addDays(1);
            }
            system.debug(':::wholeDateSet::::::'+wholeDateSet);
            
            // Get Week ranges for all the above date values 
            for(Date dt : wholeDateSet) {
                Date st;
                
                if(dt.toStartofWeek().addDays(1) < dt) {
                    st = dt.toStartofWeek().addDays((startOfWeek == 'Sat') ? 2 : 1);
                } else {
                    st = dt.addDays(-1).toStartofWeek().addDays((startOfWeek == 'Sat') ? 2 : 1);
                }
                
                Date ed = st.addDays(6); 
                
                String stVal = String.valueOf(st).split(' ')[0];
                String endVal = String.valueOf(ed).split(' ')[0];
                String stFinal = stVal.split('-')[1]+'/'+stVal.split('-')[2]+'/'+stVal.split('-')[0];
                String endFinal = endVal.split('-')[1]+'/'+endVal.split('-')[2]+'/'+endVal.split('-')[0];
                
                if((!weekRangeSet.contains(stFinal+' to '+endFinal)) &&  ed <= endDate) {
                    weekRangeSet.add(stFinal+' to '+endFinal);
                }
            }
            system.debug('::::::::weekRangeSet:::::::'+weekRangeSet);
            
            
            List<String> weekRangeList = new List<String>();
            weekRangeList.addAll(weekRangeSet);
            
            List<String> timeList = ScheduleCmpLightningController.getPickListValues('AcctSeed__Time_Card_Day__c','Start_Time1__c');
            List<String> attendancePickList = ScheduleCmpLightningController.getPickListValues('Attendance__c', 'Attendance__c');
            List<NetWork> currentNetwork = new List<NetWork>();
            
            //Qry network if the current user is community user
            if(!internalUser){
                currentNetwork = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId()];
            }
            
            //Get Timekeeping topic id to use it in Need Help btn
            List<Topic> topicRecord = new List<Topic>();
            
            if(currentNetwork.size() > 0){
                topicRecord = [SELECT Id,ManagedTopicType,Name,NetworkId FROM Topic WHERE Name = 'Timekeeping' AND NetworkId = :currentNetwork[0].Id];
            }       
            
            StaffTimeEntryDomain.projectAndCAInfo projectAndCAInfo = (StaffTimeEntryDomain.projectAndCAInfo)JSON.deserialize(StaffTimeEntryController.getProjectsByWeekrange(conRecList[0].Id, weekRangeList[4]), StaffTimeEntryDomain.projectAndCAInfo.class);
             //Added By Dhinesh - 21/03/2023 - W-007729 - Timekeeping Fields to Indicate if the Time was entered On Time or Late
            TimeEntryUtil.TimeEnteredCountWrap timeEnteredCount = TimeEntryUtil.getTimeEnteredCountByContactId(conRecList[0].Id);
                        
            TimeCardDayCommunityDomain.InitialFilterValues initialFilter = TimeCardDayCommunityTranslator.instructor_initialFilterFormation(conRecList,weekRangeList,timeList,topicRecord);
            initialFilter.attendancePickList = attendancePickList;
            initialFilter.timeEnteredLate = timeEnteredCount.timeEnteredLate;
            initialFilter.timeEnteredOnTime = timeEnteredCount.timeEnteredOnTime;          
            initialFilter.timeSubmittedOnTime = timeEnteredCount.timeSubmittedOnTime;
            initialFilter.timeSubmittedLate = timeEnteredCount.timeSubmittedLate;
            
            initialFilter.showStaffTimeEntry = projectAndCAInfo.projects.size()>0 ? true : false;
            system.debug(':::::::initialFilter::::'+initialFilter);
            
            return JSON.serialize(initialFilter);
        }catch(Exception e){
            system.debug('::::::exception:::::::::'+e.getMessage());
            system.debug('::::::exception:::::::::'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
       
    }
    
    /**************************************************************************
    - Method to get Week & Instructor based project filter data
    **************************************************************************/
    @AuraEnabled
    public static String getProjectFilterValues(String startDate,String endDate,String contactId){
        
        try {
            Date stDate = Date.valueOf(startDate);
            Date edDate = Date.valueOf(endDate);
            
            String startDT = stDate.year()+'-'+('0' + stDate.month()).right(2)+'-'+('0' + stDate.day()).right(2)+'T00:00:00Z';
            String endDT = edDate.year()+'-'+('0' + edDate.month()).right(2)+'-'+('0' + edDate.day()).right(2)+'T00:00:00Z';
            
            system.debug(':::::::stDate::::'+stDate);
            system.debug(':::::::edDate::::'+edDate);
            
            Set<Id> projectId = new Set<Id>();
            List<AcctSeed__Project__c> projectRecords = new List<AcctSeed__Project__c>();
            List<AcctSeed__Project__c> projectForSupervisor = new List<AcctSeed__Project__c>();
            List<AcctSeed__Project__c> projectWithInsCA = new List<AcctSeed__Project__c>();
            
            
            //Set to get the total no.of project available for this week with valid data
            Set<Id> validProjectIds = new Set<Id>();
            Map<Id,Boolean> projectIdTimeEntered = new Map<Id,Boolean>();
            Set<Id> testingProjectIds = new Set<Id>();
            
            //Thie date condition to filter the Projects based on the CA End Date values
            String caFilterDate = String.valueOf(stDate.addDays(-14)).split(' ')[0];
            Date caFilterDt = stDate.addDays(-14);
            String caFilterDateTime = caFilterDt.year()+'-'+('0' + caFilterDt.month()).right(2)+'-'+('0' + caFilterDt.day()).right(2)+'T00:00:00Z';
            
            Map<String, Boolean>  projectIdWithNoStudHrsVerificationMap = new Map<String, Boolean>();
            
            if(contactId != null) {
                String parentFields = 'Candidate_Name__r.Home_Dept__c,Candidate_Name__r.Home_Department_Project__c,Candidate_Name__r.Home_Department_Project__r.Name,Candidate_Name__r.Name,'+
                                       'Candidate_Name__r.Supervisor_Name__c,Candidate_Name__r.Supervisor_Name__r.Name,Candidate_Name__r.Supervisor_Name__r.ManagerId,Candidate_Name__r.Supervisor_Name__r.Manager.Name,'+
                                         'Project__r.Name,Rate_Card_Rate__r.Name,Project__r.RecordType.DeveloperName,Rate_Card_Rate__r.Payroll_Item__c,Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Rate_Card_Rate__r.Rate_Type__c,RecordType.DeveloperName,No_Student_Hours_Verification__c';
                   
               //For active status used similar condition as ET2 >= ST1 && ST2 < ET1 - applied in reverse to add this in query             
                String condition = ' WHERE Candidate_Name__c = \''+contactId+'\' AND RecordType.DeveloperName IN (\'Instructor\') AND ((Status__c IN (\'Active\',\'On Hold\') AND ((Start_Date__c <= '+endDate+' AND End_Date__c >= '+startDate+') OR (Oral_Exam_Date_Time__c <= '+endDT+' AND Oral_Exam_Date_Time__c >= '+startDT+'))) OR (Status__c IN ( \'Ended\') AND  (End_Date__c >= '+caFilterDate+' OR Oral_Exam_Date_Time__c >= ' +caFilterDateTime+'))) AND Project__c != null AND Paper_Timesheet__c = false';
                 
                for(Contact_Assignments__c assign : ContactAssignmentService.getContactassignmentRec(condition,parentFields)) {
                     
                    projectId.add(assign.Project__c);
                    
                    if(assign.Rate_Card_Rate__c != null && assign.Project__r.RecordType.DeveloperName != 'Testing_Projects'){
                        validProjectIds.add(assign.Project__c);
                    }
                    
                    if(assign.Project__r.RecordType.DeveloperName == 'Testing_Projects'){
                        testingProjectIds.add(assign.Project__c);
                    }
                    
                    projectIdWithNoStudHrsVerificationMap.put(assign.Project__c, assign.No_Student_Hours_Verification__c);
                }
            }
            
            system.debug('::::::::validProjectIds::::'+validProjectIds);
            system.debug('::::::::projectId::::'+projectId);
            
            if(projectId.size() > 0){
            
                Date caEndDate = Date.valueOf(caFilterDate);
                
                Set<Id> contactAssignmentsIds = new Set<Id>();
                
                //W-004822 - to display ended students only upto the ended week
                //qry student contact assignments separately to filter the ended students
                for(Contact_Assignments__c ca : [SELECT Id,Name,Start_Date__c,End_Date__c,Status__c FROM Contact_Assignments__c 
                                                        WHERE Project__c = :projectId AND RecordType.DeveloperName = 'Student' 
                                                            AND (Status__c IN ('Active','On Hold') OR (Status__c IN ('Ended','Transferred')  AND End_Date__c >= :caEndDate))]){
                    
                    if((ca.Status__c == 'Active' || ca.Status__c == 'On Hold') || ((ca.Status__c == 'Ended' ||  ca.status__c == 'Transferred') && (ca.End_Date__c >= stDate))){ //&& ca.End_Date__c <= edDate
                        contactAssignmentsIds.add(ca.Id);
                    }
                }
                
                projectRecords = [SELECT Id,Name,DLS_Class__c,RecordType.DeveloperName,RecordTypeId,No_Student_Approval__c,No_Student_Hours_Verification__c,
                                                        (SELECT Id,Candidate_Name__r.FirstName,Candidate_Name__r.LastName,Assignment_Position__c 
                                                            FROM Contact_Assignments__r WHERE Id IN :contactAssignmentsIds) 
                                                FROM AcctSeed__Project__c WHERE Id IN :projectId];
                
                projectForSupervisor = [SELECT Id,Name,DLS_Class__c,RecordType.DeveloperName,RecordTypeId,No_Student_Approval__c,No_Student_Hours_Verification__c,
                                                        (SELECT Id,Candidate_Name__r.Name 
                                                            FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Staff' AND (Status__c = 'Active' OR (Status__c = 'Ended' AND End_Date__c > :caEndDate)) ORDER BY CreatedDate DESC LIMIT 1) 
                                                FROM AcctSeed__Project__c WHERE Id IN :projectId];
                
                projectWithInsCA = [SELECT Id,Name,DLS_Class__c,RecordType.DeveloperName,RecordTypeId,No_Student_Approval__c,No_Student_Hours_Verification__c,
                                        (SELECT Id,Candidate_Name__r.Name,Candidate_Name__r.FirstName,Candidate_Name__r.LastName,Assignment_Position__c 
                                            FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Instructor' AND Candidate_Name__c = :contactId AND Paper_Timesheet__c = false) 
                                                FROM AcctSeed__Project__c WHERE Id IN :projectId];
            }
            
            //Qry valid projects related Schedules with current week condition
            if(validProjectIds.size() > 0 || testingProjectIds.size() > 0){
                
                Set<Id> filteredProjIdsFromSchedule = new Set<Id>();
                System.debug('testingProjectIds::>'+testingProjectIds);
                if(testingProjectIds.size() > 0){
                    for(Events__c eve :[SELECT Id,Name,Project__c FROM Events__c 
                                        WHERE Status__c = 'Scheduled' AND (Date__c <= :edDate AND Date__c >= :stDate)
                                            AND Project__c IN :testingProjectIds AND Instructor__c = :contactId]){
                        
                        filteredProjIdsFromSchedule.add(eve.Project__c);
                        
                        if(!projectIdTimeEntered.containsKey(eve.Project__c)){
                            projectIdTimeEntered.put(eve.Project__c,false);
                        }
                    }
                }
                System.debug('filteredProjIdsFromSchedule::>'+filteredProjIdsFromSchedule);
                if(validProjectIds.size() > 0){
                    for(Schedule__c sch :[SELECT Id,Name,Project__c,Project_Task__c,Project_Task__r.Project_Task_Type__c,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c FROM Schedule__c 
                                        WHERE Status__c IN ('Active','Completed') AND (Start_Date__c <= :edDate AND End_Date__c >= :stDate)
                                            AND Project__c IN :validProjectIds AND Instructor__c = :contactId]){
                        
                        filteredProjIdsFromSchedule.add(sch.Project__c);
                        
                        if(!projectIdTimeEntered.containsKey(sch.Project__c)){
                            projectIdTimeEntered.put(sch.Project__c,false);
                        }
                    }
                }
                system.debug('::::::::filteredProjIdsFromSchedule::::'+filteredProjIdsFromSchedule);
                system.debug('::::::::projectIdTimeEntered::::'+projectIdTimeEntered);
                
                //Qry schedule project related TCL & their counts for time entered verification
                if(filteredProjIdsFromSchedule.size() > 0){
                    for(AcctSeed__Time_Card_Line__c line : [SELECT Id,Name,AcctSeed__Project__c,Completed__c FROM AcctSeed__Time_Card_Line__c
                                                                WHERE AcctSeed__Project__c IN :filteredProjIdsFromSchedule 
                                                                    AND AcctSeed__Time_Card__r.Intructor__c = :contactId AND Completed__c = true
                                                                    AND AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c = :stDate 
                                                                    AND AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c = :edDate]){
                        if(projectIdTimeEntered.containsKey(line.AcctSeed__Project__c)){
                            projectIdTimeEntered.put(line.AcctSeed__Project__c,line.Completed__c);
                        }
                    }
                }
                
                system.debug(':::::::::::projectIdTimeEntered:::::'+projectIdTimeEntered);
            }
            
            TimeCardDayCommunityDomain.ProjectFilterInfo proInfo = TimeCardDayCommunityTranslator.projectRelatedFilters(projectRecords,projectForSupervisor,projectWithInsCA,projectIdTimeEntered,projectIdWithNoStudHrsVerificationMap);
            
            return JSON.Serialize(proInfo);
        }catch(Exception e){
            system.debug('::::::exception:::::::::'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /************************************************************
    - Method to get the TCL Rows related information from TCD / PT (based in schedule information)
    - Added by NS on MAR 5 2019
    *************************************************************/
    
    @AuraEnabled
    public static String getTimeRowsRelatedInformation(String stDate,String endDate,String projectId,String contactId,String projectName,String studentNames){
    
        Date startDt = Date.valueOf(stDate);
        Date endDt = Date.valueOf(endDate);
        
        system.debug(':::::::startDt:::;;'+startDt);
        system.debug(':::::::endDt:::;;'+endDt);
        system.debug('projectId::'+projectId);
        
        Set<Id> filteredPTIds = new Set<Id>();
        
        List<AcctSeed__Project__c> projectRecord = [SELECT Id,Name,RecordType.DeveloperName,DLS_Class__c,No_Student_Approval__c,AcctSeed__Status__c,No_Student_Hours_Verification__c FROM AcctSeed__Project__c WHERE Id = :projectId];
        String projectRTName = projectRecord[0].RecordType.DeveloperName;
        String projectStatus = projectRecord[0].AcctSeed__Status__c;
        
        List<AcctSeed__Project_Task__c> taskRecords = new List<AcctSeed__Project_Task__c>();
        Map<Id,Integer> taskIdTimeCount = new Map<Id,Integer>();
        Map<Id,String> taskIdTimeMap = new Map<Id,String>();
        Map<Id,String> taskIdTimezone = new Map<Id,String>();
      
        //Apply schedule based filter condition to get the PT  on the Instructor Time Entry Page
        for(Schedule__c sch : [SELECT Id,Name,Project_Task__c,Project_Task__r.Project_Task_Type__c,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c,Timezone__c FROM Schedule__c 
                                    WHERE Project__c = :projectId AND Instructor__c = :contactId AND Status__c IN ('Active','Completed') 
                                    AND (Start_Date__c <= :endDt AND End_Date__c >= :startDt)]){
            
            filteredPTIds.add(sch.Project_Task__c);
            
            if(!taskIdTimezone.containsKey(sch.Project_Task__c)){
                taskIdTimezone.put(sch.Project_Task__c,sch.Timezone__c);
            }
            
            system.debug(':::::start::date:'+sch.Start_Date__c);
            system.debug(':::::end::date:'+sch.End_Date__c);
            system.debug(':::::task::type:::'+sch.Project_Task__r.Project_Task_Type__c);
            
            if(sch.Project_Task__r.Project_Task_Type__c == 'Preparation time') {
                if(!taskIdTimeCount.containsKey(sch.Project_Task__c)){
                    taskIdTimeCount.put(sch.Project_Task__c,1);
                }else {
                    taskIdTimeCount.put(sch.Project_Task__c,taskIdTimeCount.get(sch.Project_Task__c) + 1);
                }
                
                if(!taskIdTimeMap.containsKey(sch.Project_Task__c)){
                    
                    if(sch.Start_Time__c != null && sch.End_Time__c != null) {
                    
                        if(sch.Start_Time__c.split(' ')[1] == 'PM' && sch.End_Time__c.split(' ')[1] == 'PM'){
                            taskIdTimeMap.put(sch.Project_Task__c,'PM');
                        }else {
                            taskIdTimeMap.put(sch.Project_Task__c,'AM');
                        }
                    }
                }else {
                    taskIdTimeMap.put(sch.Project_Task__c,'Both');
                }
            }
        }
        
        for(Events__c eve : [SELECT Id,Name,Project_Task__c,Project_Task__r.Project_Task_Type__c,Date__c,Start_Time__c,End_Time__c,Timezone__c FROM Events__c
                                    WHERE Project__c = :projectId AND Instructor__c = :contactId AND Schedule__c = null AND Status__c IN ('Scheduled','Completed') //Added Completed Status - Dhinesh - 30-09-2021 - W-007020 
                                    AND Project_Task__r.Project_Task_Type__c != 'Material budget' AND (Date__c <= :endDt AND Date__c >= :startDt)]){ //Added Project Task Type filter - Dhinesh - 7/4/2022 - W-007427
            
            filteredPTIds.add(eve.Project_Task__c);
            
            if(!taskIdTimezone.containsKey(eve.Project_Task__c)){
                taskIdTimezone.put(eve.Project_Task__c,eve.Timezone__c);
            }
            
            if(eve.Project_Task__r.Project_Task_Type__c == 'Preparation time') {
                if(!taskIdTimeCount.containsKey(eve.Project_Task__c)){
                    taskIdTimeCount.put(eve.Project_Task__c,1);
                }else {
                    taskIdTimeCount.put(eve.Project_Task__c,taskIdTimeCount.get(eve.Project_Task__c) + 1);
                }
                
                if(!taskIdTimeMap.containsKey(eve.Project_Task__c)){
                    
                    if(eve.Start_Time__c != null && eve.End_Time__c != null) {
                    
                        if(eve.Start_Time__c.split(' ')[1] == 'PM' && eve.End_Time__c.split(' ')[1] == 'PM'){
                            taskIdTimeMap.put(eve.Project_Task__c,'PM');
                        }else {
                            taskIdTimeMap.put(eve.Project_Task__c,'AM');
                        }
                    }
                }else {
                    taskIdTimeMap.put(eve.Project_Task__c,'Both');
                }
            }
        }
        
        system.debug('::::::::::taskIdTimeCount::::'+taskIdTimeCount);
        system.debug(':::::::::taskIdTimeMap:::::'+taskIdTimeMap);
        system.debug('::::::filteredPTIds:::'+filteredPTIds);
        
        if(filteredPTIds.size() > 0){
            // taskRecords = [SELECT Id,Name,Billable__c,AcctSeed__Project__r.Training_Location__r.Name,AcctSeed__Project__r.Training_Location__c,Payroll_Item__c,
            //                         Parent_Project_Task__c,Project_Task_Type__c,AcctSeed__Project__r.RecordType.DeveloperName,RecordType.DeveloperName
            //                     FROM AcctSeed__Project_Task__c 
            //                     WHERE AcctSeed__Project__c = :projectId AND Id IN :filteredPTIds ORDER BY Project_Task_Type__c ASC];
        
            Map<Integer,AcctSeed__Project_Task__c> sequenceNoPTRec = new Map<Integer,AcctSeed__Project_Task__c>();
            List<Integer> seqNums = new List<Integer>();
            
            Integer count = 0;
            
            for(AcctSeed__Project_Task__c task : [SELECT Id,Name,Billable__c,AcctSeed__Project__r.Training_Location__r.Name,AcctSeed__Project__r.Training_Location__c,Payroll_Item__c,
                                                        Parent_Project_Task__c,Project_Task_Type__c,AcctSeed__Project__r.RecordType.DeveloperName,RecordType.DeveloperName, AcctSeed__Project__r.Default_Cost_Rate_Rate_Type__c
                                                    FROM AcctSeed__Project_Task__c 
                                                    WHERE AcctSeed__Project__c = :projectId AND Id IN :filteredPTIds ORDER BY Project_Task_Type__c ASC]){
                
                if(task.Name == 'Fringe-PTO'){
                    sequenceNoPTRec.put(500,task);
                } 
                else if(task.Name=='Fringe-Holiday'){
                    sequenceNoPTRec.put(501,task);
                    System.debug('Fringe-Holiday');
                } 
                else {
                    sequenceNoPTRec.put((count + 1),task);
                    count++;
                }
                
                filteredPTIds.add(task.Id);
            }
            
            for(Integer cnt : sequenceNoPTRec.keySet()){
                seqNums.add(cnt);
            }
            
            seqNums.sort();
            
            for(Integer seq : seqNums){
                
                if(sequenceNoPTRec.containsKey(seq)){
                    taskRecords.add(sequenceNoPTRec.get(seq));        
                }
            }
            
        }else if(projectRTName == 'EFL_Projects'){    //To include EFL Projects in instructor time entry. They dont have student &schedule details - W-005036
            
            //For display project task in order need to do some ordering
            Map<Integer,AcctSeed__Project_Task__c> sequenceNoPTRec = new Map<Integer,AcctSeed__Project_Task__c>();
            List<Integer> seqNums = new List<Integer>();
            
            Integer count = 0;
            
            for(AcctSeed__Project_Task__c task : [SELECT Id,Name,Billable__c,AcctSeed__Project__r.Training_Location__r.Name,AcctSeed__Project__r.Training_Location__c,
                                                        Parent_Project_Task__c,Project_Task_Type__c,RecordType.DeveloperName,Payroll_Item__c,AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Project__r.Default_Cost_Rate_Rate_Type__c
                                                    FROM AcctSeed__Project_Task__c 
                                                    WHERE AcctSeed__Project__c = :projectId AND Project_Task_Type__c IN ('Language Training','Fringe') ORDER BY Project_Task_Type__c ASC]){
                
                if(task.Project_Task_Type__c == 'Language Training'){
                    sequenceNoPTRec.put(0,task);
                }
                
                else {
                    sequenceNoPTRec.put((count + 1),task);
                    count++;
                }
                
                filteredPTIds.add(task.Id);
            }
            
            for(Integer cnt : sequenceNoPTRec.keySet()){
                seqNums.add(cnt);
            }
            
            seqNums.sort();
            
            for(Integer seq : seqNums){
                
                if(sequenceNoPTRec.containsKey(seq)){
                    taskRecords.add(sequenceNoPTRec.get(seq));        
                }
            }
            
        }
        
        
        //Qry currentWeek time card day records
        String filterCondition = ' ORDER BY AcctSeed__Date__c ASC';
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        List<Accounting_Seed_Time_Snapshot__c> accTimesnapshot = new List<Accounting_Seed_Time_Snapshot__c>();
        Set<Id> proIds = new Set<Id>{projectId};
        
        //Qry Existing TCL records with TCD
        if(contactId != null && proIds.size() > 0) {
            timeCardLineList = TimeCardLineService.getTCL_dayRecords(filterCondition,proIds,filteredPTIds,Date.valueOf(startDt),Date.valueOf(endDt),contactId);
        }
        
        Set<Id> tcdIds = new Set<Id>();
        
        for(AcctSeed__Time_Card_Line__c timeLine : timeCardLineList) {
             if(timeLine.AcctSeed__Time_Card_Days__r.size() > 0){
                 for(AcctSeed__Time_Card_Day__c tcd : timeLine.AcctSeed__Time_Card_Days__r){
                     tcdIds.add(tcd.Id);
                 }
             }
        }
        
        // Time Snapshot formation
        if(tcdIds.size() > 0) {
            accTimesnapshot = TimeSnapshotService.getSnpshotWithDaysIds(tcdIds);
        }
        
        system.debug('::::::accTimesnapshot::::::'+accTimesnapshot);
        
        //Qry Instructor contact related CA for that project to get the CA & CR values
        List<Contact_Assignments__c> caRecord = [SELECT Id,Name,Rate_Card_Rate__c,Rate_Card_Rate__r.Payroll_Item__c,Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Project_Task__c, Start_Date__c, End_Date__c, Oral_Exam_Date_Time__c
                                                 FROM Contact_Assignments__c 
                                                 WHERE Project__c = :projectId AND RecordType.DeveloperName = 'Instructor' AND Candidate_Name__c = :contactId AND ((Start_Date__c <= :endDt  AND End_Date__c >= :startDt) OR (Oral_Exam_Date_Time__c <= :endDT AND Oral_Exam_Date_Time__c >= :startDT))]; //Modified By Dhinesh - 21/12/2023 - W-007949 - Added Instructor Record Type Filter to fix the issue when there is 2 CA with same contact as instructor and LTS
        
        List<Contact_Assignments__History> caHistory = new List<Contact_Assignments__History>();
        List<AcctSeed__Cost_Rates__c> oldCRRecord = new List<AcctSeed__Cost_Rates__c>();
        List<AcctSeed__Cost_Rates__c> newCRRecord = new List<AcctSeed__Cost_Rates__c>();
        
        if(caRecord.size() > 0) {
        
            caHistory = [SELECT CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue,ParentId 
                            FROM Contact_Assignments__History 
                            WHERE ParentId = :caRecord[0].Id AND Field = 'Rate_Card_Rate__c' AND DataType = 'EntityId' ORDER BY CreatedDate DESC LIMIT 1];
                      
            if(caHistory.size() > 0 && caHistory[0].OldValue != null){
                String oldId = (String) caHistory[0].OldValue;
                oldCRRecord = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c FROM AcctSeed__Cost_Rates__c WHERE Id = :oldId];
                
                //W-007799 - Urgent: Instructor is unable to save timesheet due to Error Message - "Entity is Deleted"
                if(oldCRRecord.size() == 0 && (caHistory[0].NewValue != null)){
                    String newId = (String) caHistory[0].NewValue;
                    newCRRecord = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c FROM AcctSeed__Cost_Rates__c WHERE Id = :newId];
                    
                    if(newCRRecord.size() > 0){
                        oldCRRecord = newCRRecord; 
                    }
                }
            }
        }
        
        //Qry project related student CAs for student attendance table formation
        List<Contact_Assignments__c> studentCAs = new List<Contact_Assignments__c>();
        Set<Id> studentIds = new Set<Id>();
        
        Set<String> studentStatus = new Set<String>{'Active','On Hold','Ended','Transferred'};
        
        //W-004822 - to display ended students only upto the ended week
        //W-005456 - added ESL LT Projects record type for ELT Pilot program
        //W-006649 - Student Hours for Language Training Projects (Added LT Project condition to display student table by NS on June 3 2021)
        
        if((projectRTName == 'DLI_W_LT_Projects' || projectRTName == 'DODA_Projects' || projectRTName == 'ESL_LT_Projects'
            || (projectRTName == 'Language_Training_Projects')) && filteredPTIds.size() > 0){
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Name,Status__c,Start_Date__c,End_Date__c 
                                                FROM Contact_Assignments__c 
                                                WHERE Status__c IN :studentStatus AND RecordType.DeveloperName = 'Student' 
                                                    AND Project__c = :projectId ORDER BY Candidate_Name__r.FirstName ASC]){
                
                if((ca.Status__c == 'Active' || ca.Status__c == 'On Hold') || ((ca.Status__c == 'Ended' || ca.Status__c == 'Transferred') && ca.End_Date__c >= startDt)){//&& ca.End_Date__c <= endDt
                    studentCAs.add(ca);
                    studentIds.add(ca.Candidate_Name__c);
                }
            }
        }
        
        //Qry Existing attendance records to prepopulate the values in student time table
        Map<Id,List<Attendance__c>> studentIdAttendanceList = new Map<Id,List<Attendance__c>>();
        
        if(studentIds.size() > 0 && filteredPTIds.size() > 0 && projectRecord.size() > 0 && !projectRecord[0].No_Student_Approval__c){
        
            for(Attendance__c att : [SELECT Id,Name,Student__c,Student__r.Name,Instructor__c,Date__c,Duration__c,Student_Approval_Status__c,Event__r.No_Student_Approval__c,
                                                Event__c,Time_Card_Day__c,Time_Card_Day__r.Late_Cancellation__c,Time_Card_Day__r.Status__c,Recall_Reason__c,Rejection_Reason__c,Comments__c,Time_Card_Day__r.Total_Hours_Before_Approved__c,Time_Card_Day__r.AcctSeed__Time_Card_Line__r.Completed__c, Attendance__c  
                                        FROM Attendance__c 
                                        WHERE Student__c IN :studentIds AND (Date__c >= :startDt AND Date__c <= :endDt) AND Instructor__c = :contactId
                                                AND Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = :projectId ORDER BY Student__r.FirstName ASC]){
                
                if(!studentIdAttendanceList.containsKey(att.Student__c)){
                    studentIdAttendanceList.put(att.Student__c,new List<Attendance__c>{att});
                }else {
                    studentIdAttendanceList.get(att.Student__c).add(att);
                }
            }
        }
        
        //Display selected week & project & current contact related case record to show warning msg when they try to submit a case again
        List<Case> editRequestCase = [SELECT Id,Type,ContactId,Subject FROM Case WHERE ContactId = :contactId AND Type = 'Timesheet Edit Request'];
        
        Boolean alreadyCaseSubmitted = false;
        
        if(editRequestCase.size() > 0){
            String weekRange = stDate.split('-')[1]+'/'+stDate.split('-')[2]+'/'+stDate.split('-')[0]+' to '+endDate.split('-')[1]+'/'+endDate.split('-')[2]+'/'+endDate.split('-')[0];
            if(editRequestCase[0].Subject.contains(projectRecord[0].DLS_Class__c) && editRequestCase[0].Subject.contains(weekRange)){
                alreadyCaseSubmitted = true;
            }
        }
        
        //Query current contact related Planned Days off records
        List<Planned_Days_Off__c> daysOffRecords = [SELECT Id,Name,Date__c,Contact__c,Contact__r.Name,Description__c 
                                                            FROM Planned_Days_Off__c 
                                                            WHERE Status__c = 'Approved' AND RecordType.DeveloperName = 'Instructor_Planned_Days_Off' 
                                                            AND Date__c >= :startDt AND Date__c <= :endDt AND Contact__c = :contactId];
        
        //Qry DLI-W LT related planned days off
        Set<Date> holidayDates = new Set<Date>();
        
        if(projectRTName == 'DLI_W_LT_Projects'){
            for(Planned_Days_Off__c off : [SELECT Id,Date__c FROM Planned_Days_Off__c 
                                                WHERE RecordType.DeveloperName = 'DLI_W_LT_Training_Holidays' 
                                                                AND Date__c >= :startDt AND Date__c <= :endDt AND Type__c = 'DLI-W LT']){
                                                                
                holidayDates.add(off.Date__c);
            }
        }
        
        system.debug(':::::DLI-W:::LT:::::::holidayDates::::'+holidayDates);
        
        TimeCardDayCommunityDomain.InstructorRowDetails weekDetails = TimeCardDayCommunityTranslator.instructorTimeEntryRowWrapperFormation(startDt,endDt,projectName,studentNames,contactId,timeCardLineList,accTimesnapshot,taskRecords,caRecord,taskIdTimeCount,taskIdTimeMap,caHistory,oldCRRecord,studentCAs,studentIdAttendanceList,alreadyCaseSubmitted,daysOffRecords,holidayDates,taskIdTimezone);
        
        return JSON.serialize(weekDetails);
    }
    
    /*******************************************************************************************
    - Method to save the time card day records
    - Added by NS on Mar 13 2019
    - For Instructor Time Entry Component
    ********************************************************************************************/
    @AuraEnabled
    public static String dmlOperationMethod(String startDate, String endDate, String conId,String timeDayJson,String projectId,String actionType,String studentJson,List<String> updatedTCDs){
        
        //check current user profile is Instructor community / Any internal user allow them to create records
        //if not throw validation msg
        Boolean currentUsrIsValid = checkCurrentUsrIsValid();
        if(!currentUsrIsValid){
            throw new AuraHandledException('Your session is expried and the changes will not be saved. Please login to enter your time');
        }
        
        system.debug('::::::::::::conId:::::::'+conId);
        system.debug('::::::::::::projectId:::::::'+projectId);
        
        List<TimeCardDayCommunityDomain.DayEntries> dayRecords = (List<TimeCardDayCommunityDomain.DayEntries>) System.JSON.deserialize(timeDayJson, List<TimeCardDayCommunityDomain.DayEntries>.class);
        
        //Student Json deserialize
        List<TimeCardDayCommunityDomain.StudentEntry> studentRecords = (List<TimeCardDayCommunityDomain.StudentEntry>) System.JSON.deserialize(studentJson, List<TimeCardDayCommunityDomain.StudentEntry>.class);
        
        Set<String> updatedTCDIds = new Set<String>();
        updatedTCDIds.addAll(updatedTCDs);
        
        // Contact Id
        Id contactId = conId;
        // Logged in User id
        Id usrRecId = UserInfo.getUserId();
        
        Date startDt = Date.valueOf(startDate);
        Date endDt = Date.valueOf(endDate);
        
        // Variable Initialization
        Set<Id> timeCardId = new Set<Id>();
        Map<Id,AcctSeed__Time_Card__c> instrutorIdandRecordMap = new Map<Id,AcctSeed__Time_Card__c>();
        Map<Id,List<AcctSeed__Time_Card_Line__c>> instructorIdLineListMap = new Map<Id,List<AcctSeed__Time_Card_Line__c>>();
        Map<String,List<AcctSeed__Time_Card_Day__c>> instIdTaskIdStringDayLsitMap = new Map<String,List<AcctSeed__Time_Card_Day__c>>();
        Set<Id> timeCardLineId = new Set<Id>();
        Set<Id> insIdForRefer = new Set<Id>();
        Set<String> lineUniqueKeys = new Set<String>();
        
        
        Map<Id,Map<String,AcctSeed__Time_Card_Line__c>> insIdStringTimeLineMap = new Map<Id,Map<String,AcctSeed__Time_Card_Line__c>>();
        
        List<AcctSeed__Time_Card_Day__c> dayListToUpsert = new List<AcctSeed__Time_Card_Day__c>();
        List<AcctSeed__Time_Card_Line__c> timeLineCreation = new List<AcctSeed__Time_Card_Line__c>();
        List<AcctSeed__Time_Card__c> cardCreation = new List<AcctSeed__Time_Card__c>();
        
        List<AcctSeed__Time_Card_Day__c> daysForSubmit = new List<AcctSeed__Time_Card_Day__c>();
        
        Set<Id> dayIdsForComplete = new Set<Id>();
        
        List<AcctSeed__Time_Card_Line__c> updateTCLList = new List<AcctSeed__Time_Card_Line__c>();
        Set<Id> tclIdsForUpdate = new Set<Id>();
       
        // Static map initialization to use in Time Card Day Trigger
        //Work Item No : W-001481
        //tcdIdNoteType = new Map<Id,String>();
        pageType = 'Instructor Time Entry';
        
        //Map to hold Task related Line Ids to set student approval status based on that
        //Because student approval status is only set for Actual Class not for preparation
        Map<Id,String> lineIdTaskType = new Map<Id,String>();
        
        Map<String,AcctSeed__Time_Card_Line__c> lineKeyLineRecordMap = new Map<String,AcctSeed__Time_Card_Line__c>();
        Map<Id,String> taskIdExistingLineKeyMap = new Map<Id,String>(); 
        
        String inputJSON = '';
        
        // Account Period check & insertion
        TimesheetPage_RelatedCtrl.accountingPeriodCreation(startDt,endDt);
         
        // Time Card Period exist check & insertion
        Id timeCardPeriodId = TimesheetPage_RelatedCtrl.timeCardPeriodCreation(startDt,endDt);
        
        inputJSON = '1) Time Card Period Id: '+timeCardPeriodId+' /n 2) Contact Id: '+conId+' /n ';
        
        AcctSeed__Time_Card__c existingCardRecord = new AcctSeed__Time_Card__c();
        
         //Ledger record query for test class purpose
         List< AcctSeed__Ledger__c > ledger = [SELECT Id, Name, AcctSeed__Type__c FROM AcctSeed__Ledger__c LIMIT 1];
         
        //time card Period based existing time card records formation
        if(timeCardPeriodId != null) {
            
            List<AcctSeed__Time_Card__c> cardList = [SELECT Id,Name,AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card__c 
                                                    WHERE AcctSeed__Time_Card_Period__c = :timeCardPeriodId AND Intructor__c = :conId];
            
            inputJSON += '3) Existing Time Card List Based Time Card Period Id : '+cardList+' /n';
            
            for(AcctSeed__Time_Card__c card : cardList){
                
                timeCardId.add(card.Id);
                existingCardRecord = card; //only one record will retured from qry because added contact filter condition
            }
            
            inputJSON += '4) Time Card Id Set: '+timeCardId+' /n 5) Existing time card record: '+existingCardRecord+' /n';
        }
         
        system.debug('::::::timeCardId::::::'+timeCardId);
        //system.debug('::::::instrutorIdandRecordMap::::::'+instrutorIdandRecordMap);
        
        List<AcctSeed__Time_Card_Line__c> lineList = [SELECT Id,AcctSeed__Project_Task__c,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c,
                                                 AcctSeed__Billable__c,Payroll_Item__c,Location__c,
                                                 AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c 
                                             FROM AcctSeed__Time_Card_Line__c 
                                             WHERE AcctSeed__Time_Card__c IN :timeCardId AND AcctSeed__Time_Card__r.Intructor__c = :conId 
                                                 AND AcctSeed__Project__c = :projectId];
                                                 
         inputJSON += '6) Project Id from page: '+projectId+' /n 7) Existing Time Card Line Records: '+lineList+' /n';
        
        //Card based existing line records formation
        for(AcctSeed__Time_Card_Line__c line : lineList){
            Id locId = null;
            
            system.debug(':::quried:::::existing::::lines::::'+line);
            
            if(line.Location__c != null) {
                locId = line.Location__c;
            }/* else if(line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c != null) {
                locId = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c;
            }*/
            
            string key = line.AcctSeed__Project_Task__c+'-'+line.AcctSeed__Billable__c+'-'+line.Payroll_Item__c+'-'+line.Location__c;
            
            if(!lineKeyLineRecordMap.containsKey(key)){
                lineKeyLineRecordMap.put(key,line);
            }
            
            if(!taskIdExistingLineKeyMap.containsKey(line.AcctSeed__Project_Task__c)){
                taskIdExistingLineKeyMap.put(line.AcctSeed__Project_Task__c,key);
            }
        }
        
        system.debug('::::::::lineKeyLineRecordMap::::::'+lineKeyLineRecordMap);
        
        inputJSON += '8) LineKeyLineRecordMap: '+lineKeyLineRecordMap+' /n 9) taskIdExistingLineKeyMap: '+taskIdExistingLineKeyMap+' /n';
        
        // Formation of time card day records from UI list
        
        for(TimeCardDayCommunityDomain.DayEntries day : dayRecords){
            
            // Check existing TCD records
            if(day.isUpdated && day.dayId != null && day.dayHours != null) {
            
                AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
                newDay.Id = day.dayId;
                newDay.AcctSeed__Date__c = day.dateVal;
                newDay.Total_Hours_Before_Approved__c = Decimal.valueOf(day.dayHours);
                newDay.AcctSeed__Internal_Comment__c = day.comments;
                newDay.Status__c = day.status;
                newDay.AcctSeed__Hours__c = 0;
                
                if(day.TaskType != 'Preparation time') {
                    newDay.Student_Approval_Status__c = day.studentApprovalStatus;
                    newDay.Start_Time1__c = day.startTime1;
                    newDay.End_Time1__c = day.endTime1;
                    newDay.Late_Cancellation__c = day.lateCancellation;
                    newDay.Cancellation_Reason__c = day.cancellationReason;
                }else {
                    newDay.Start_Time1__c = day.startTime1;
                    newDay.End_Time1__c = day.endTime1;
                    newDay.Start_Time2__c = day.startTime2;
                    newDay.End_Time2__c = day.endTime2;
                }
                
                dayListToUpsert.add(newDay);
                
                if(!lineIdTaskType.containsKey(day.lineId)){
                    lineIdTaskType.put(day.lineId,day.taskType);
                }
                
                
                if(day.isCompleted && !tclIdsForUpdate.contains(day.lineId)){
                    AcctSeed__Time_Card_Line__c cardlineRec = new AcctSeed__Time_Card_Line__c();
                    cardlineRec.Id = day.lineId;
                    cardlineRec.Completed__c = false;
                    
                    tclIdsForUpdate.add(day.lineId);
                    
                    updateTCLList.add(cardlineRec);
                }
                
                //If the action type is completed, then update the existing tcl
                if(actionType == 'Complete' && !day.isCompleted && !tclIdsForUpdate.contains(day.lineId)){
                    AcctSeed__Time_Card_Line__c cardlineRec = new AcctSeed__Time_Card_Line__c();
                    cardlineRec.Id = day.lineId;
                    cardlineRec.Completed__c = true;
                    
                    tclIdsForUpdate.add(day.lineId);
                    
                    updateTCLList.add(cardlineRec);
                }
                
            }else if(actionType == 'Complete' && !day.isUpdated && !day.isNew && day.dayId != null) {   
                //Add the records which are not updated in UI,but already exisit in database for complete action
                dayIdsForComplete.add(day.dayId);
                
                //If the action type is completed, then update the existing tcl
                if(actionType == 'Complete' && !day.isCompleted && !tclIdsForUpdate.contains(day.lineId)){
                    AcctSeed__Time_Card_Line__c cardlineRec = new AcctSeed__Time_Card_Line__c();
                    cardlineRec.Id = day.lineId;
                    cardlineRec.Completed__c = true;
                    
                    tclIdsForUpdate.add(day.lineId);
                    
                    updateTCLList.add(cardlineRec);
                }
            }
            
            // If already TCD not exist - check already card,line exist if not create from parent to child
           //Check Card record already exist
           
           inputJSON += '10) Line No: 704 condition: timeCardIdSet size: '+timeCardId.size()+' /n 11) Existing Card Record time card period: '+existingCardRecord.AcctSeed__Time_Card_Period__c;
           inputJSON += '/n 12) timeCardPeriodId: '+timeCardPeriodId+' /n';
           
           if(timeCardId.size() > 0 && existingCardRecord.AcctSeed__Time_Card_Period__c == timeCardPeriodId){
               
               system.debug(':::::::::::enter card exist if::::::');
               
               AcctSeed__Time_Card__c cardRec = existingCardRecord;
               
               String lineKey = day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId;
               
               inputJSON += '/n Line No: 714 - 13) Task Id from page: '+day.taskId+', Billable from page: '+day.isBillable+', Payroll Item from page: '+day.payrollItem+', Location from page: '+day.locationId+' /n';
              
               // Check already card based line record exist
               if(lineKeyLineRecordMap.containsKey(lineKey)){
                   
                   system.debug(':::::::::::enter line exist if::::::');
                   
                   AcctSeed__Time_Card_Line__c lineRec = lineKeyLineRecordMap.get(lineKey);
                   
                   inputJSON += '/n Line No: 722 - 14) Existing TCL Record: '+lineRec+' /n';
                   
                   //If the action type is completed, then update the existing tcl
                   if(actionType == 'Complete' && !day.isCompleted && !tclIdsForUpdate.contains(lineRec.Id)){
                   
                        AcctSeed__Time_Card_Line__c cardlineRec = new AcctSeed__Time_Card_Line__c();
                        cardlineRec.Id = lineRec.Id;
                        cardlineRec.Completed__c = true;
                        
                        tclIdsForUpdate.add(day.lineId);
                        
                        updateTCLList.add(cardlineRec);
                   }
                   
                   String key = contactId+'-'+day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId;
                   
                   if(!lineUniqueKeys.contains(key)){
                       lineUniqueKeys.add(key);
                   }
                   
                   if(day.isNew && day.dayHours != null){
                       
                       AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
                       newDay.AcctSeed__Time_Card_Line__c = lineRec.Id;
                       newDay.AcctSeed__Date__c = day.dateVal;
                       newDay.Total_Hours_Before_Approved__c = Decimal.valueOf(day.dayHours);
                       newDay.AcctSeed__Internal_Comment__c = day.comments;
                       newDay.Status__c = day.status;
                       newDay.AcctSeed__Hours__c = 0;
                       newDay.Labor_Cost_Rate__c = day.costrateId;
                       
                       if(day.TaskType != 'Preparation time') {
                           newDay.Student_Approval_Status__c = day.studentApprovalStatus;
                           newDay.Start_Time1__c = day.startTime1;
                           newDay.End_Time1__c = day.endTime1;
                           newDay.Late_Cancellation__c = day.lateCancellation;
                           newDay.Cancellation_Reason__c = day.cancellationReason;
                       }else {
                           newDay.Start_Time1__c = day.startTime1;
                           newDay.End_Time1__c = day.endTime1;
                           newDay.Start_Time2__c = day.startTime2;
                           newDay.End_Time2__c = day.endTime2;
                       }
                       
                       dayListToUpsert.add(newDay);
                   }
               }else { // Line record not exist, going to create new one
                   
                   system.debug(':::::::::::card exist::but no line::part::');
                   
                    AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                    line.AcctSeed__Project_Task__c = day.taskId;
                    line.AcctSeed__Project__c = day.projectId;
                    line.AcctSeed__Time_Card__c = cardRec.Id;
                    line.AcctSeed__Billable__c = day.isBillable;
                    line.Payroll_Item__c = day.payrollItem;
                    line.Location__c = day.locationId;
                    line.Display_in_Future_Weeks__c = true;
                    //line.Labor_Cost_Rate__c = day.costrateId;
                    line.Contact_Assignment__c = day.contactAssignId;
                    line.Sequence_Number__c = day.sequenceNumber;
                    
                    String oldLineKey = taskIdExistingLineKeyMap.containsKey(day.taskId) ? taskIdExistingLineKeyMap.get(day.taskId) : null;
                    
                    line.Code_Line_No__c = '760 - Card Exist But No Line Part --> old key --> '+oldLineKey+' --> new Key'+lineKey;
                    
                    inputJSON += '/n Line No: 789 - 15) New TCL project Id: '+day.projectId+', New TCL task Id: '+day.taskId+', New TCL Billable: '+day.isBillable+', New TCL payrollItem: '+day.payrollItem+', New TCL Location Id: '+day.locationId+' /n';
                    
                    if(actionType == 'Complete'){
                        line.Completed__c = true;
                    }
                    
                    line.Input_JSON__c = inputJSON;
                    
                    String key = contactId+'-'+day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId;
                    
                    if(!lineUniqueKeys.contains(key)){
                        timeLineCreation.add(line);
                        lineUniqueKeys.add(key);
                    }
                    
                    // Time Card Day map formation - after line creation we can map the line id in day records
                    if(!instIdTaskIdStringDayLsitMap.containsKey(key)){
                        instIdTaskIdStringDayLsitMap.put(key,new List<AcctSeed__Time_Card_Day__c>());
                    }
                    
                    if(day.isNew && day.dayHours != null){
                       
                       AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
                       newDay.AcctSeed__Date__c = day.dateVal;
                       newDay.Total_Hours_Before_Approved__c = Decimal.valueOf(day.dayHours);
                       newDay.AcctSeed__Internal_Comment__c = day.comments;
                       newDay.Status__c = day.status;
                       newDay.AcctSeed__Hours__c = 0;
                       newDay.Labor_Cost_Rate__c = day.costrateId;
                       
                       if(day.TaskType != 'Preparation time') {
                           newDay.Student_Approval_Status__c = day.studentApprovalStatus;
                           newDay.Start_Time1__c = day.startTime1;
                           newDay.End_Time1__c = day.endTime1;
                           newDay.Late_Cancellation__c = day.lateCancellation;
                           newDay.Cancellation_Reason__c = day.cancellationReason;
                       }else {
                           newDay.Start_Time1__c = day.startTime1;
                           newDay.End_Time1__c = day.endTime1;
                           newDay.Start_Time2__c = day.startTime2;
                           newDay.End_Time2__c = day.endTime2;
                       }
                       
                       instIdTaskIdStringDayLsitMap.get(key).add(newDay);
                    }
               }// End of line creation if
           }else {// Already card record not exist, we are going to create card record, then line and day records
               
               system.debug(':::::::::::no existing card:::::exist:part:::');
               
                //Card records creation
                if(!insIdForRefer.contains(contactId) && contactId != null) {
                
                    AcctSeed__Time_Card__c card = new AcctSeed__Time_Card__c();
                    card.AcctSeed__Employee__c = usrRecId;
                    card.Intructor__c = contactId;
                    card.AcctSeed__Time_Card_Period__c = timeCardPeriodId;
                    
                   if(Test.isRunningTest()){
                        card.AcctSeed__Ledger__c = ledger[0].Id;
                    }
                    
                    cardCreation.add(card);
                    insIdForRefer.add(contactId);
                }
                
                // Line record related Map formation
                AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                line.AcctSeed__Project_Task__c = day.taskId;
                line.AcctSeed__Project__c = day.projectId;
                line.AcctSeed__Billable__c = day.isBillable;
                line.Payroll_Item__c = day.payrollItem;
                line.Location__c = day.locationId;
                line.Display_in_Future_Weeks__c = true;
                //line.Labor_Cost_Rate__c = day.costrateId;
                line.Contact_Assignment__c = day.contactAssignId;
                line.Sequence_Number__c = day.sequenceNumber;
                
                String oldLineKey = taskIdExistingLineKeyMap.containsKey(day.taskId) ? taskIdExistingLineKeyMap.get(day.taskId) : null;
                    
                line.Code_Line_No__c = '847 - Card not exist and Line not exist part--> old key --> '+oldLineKey+' --> new Key'+day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId;
                
                inputJSON += '/n Line No: 879 - 15) New TCL project Id: '+day.projectId+', New TCL task Id: '+day.taskId+', New TCL Billable: '+day.isBillable+', New TCL payrollItem: '+day.payrollItem+', New TCL Location Id: '+day.locationId+' /n';
                
                if(actionType == 'Complete'){
                    line.Completed__c = true;
                }
                
                line.Input_JSON__c = inputJSON;
                
                String key = contactId+'-'+day.taskId+'-'+day.isBillable+'-'+day.payrollItem+'-'+day.locationId;
                
                system.debug(':::::::line:::insert:::::key::'+key);
                system.debug('::::new:::line:::instance::'+line);
                    
                if(!lineUniqueKeys.contains(key)) {
                    lineUniqueKeys.add(key);
                    
                    if(!instructorIdLineListMap.containsKey(contactId)) {
                        instructorIdLineListMap.put(contactId,new List<AcctSeed__Time_Card_Line__c>());
                    }
                    instructorIdLineListMap.get(contactId).add(line);
                }
                
                // Time card Day Map formation
                if(!instIdTaskIdStringDayLsitMap.containsKey(key)) {
                    instIdTaskIdStringDayLsitMap.put(key,new List<AcctSeed__Time_Card_Day__c>());
                }
                
                if(day.isNew && String.isNotBlank(day.dayHours)){
                   
                   AcctSeed__Time_Card_Day__c newDay = new AcctSeed__Time_Card_Day__c();
                   newDay.AcctSeed__Date__c = day.dateVal;
                   newDay.Total_Hours_Before_Approved__c = Decimal.valueOf(day.dayHours);
                   newDay.AcctSeed__Internal_Comment__c = day.comments;
                   newDay.Status__c = day.status;
                   newDay.AcctSeed__Hours__c = 0;
                   newDay.Labor_Cost_Rate__c = day.costrateId;
                   
                   if(day.TaskType != 'Preparation time') {
                       newDay.Student_Approval_Status__c = day.studentApprovalStatus;
                       newDay.Start_Time1__c = day.startTime1;
                       newDay.End_Time1__c = day.endTime1;
                       newDay.Late_Cancellation__c = day.lateCancellation;
                       newDay.Cancellation_Reason__c = day.cancellationReason;
                   }else {
                       newDay.Start_Time1__c = day.startTime1;
                       newDay.End_Time1__c = day.endTime1;
                       newDay.Start_Time2__c = day.startTime2;
                       newDay.End_Time2__c = day.endTime2;
                   }
                   
                   instIdTaskIdStringDayLsitMap.get(key).add(newDay);
                }
           }// End of card creation if
            
        } //End of for loop
        
        system.debug(':::::::::::dayListToUpsert::::ins::time::::'+dayListToUpsert);
        system.debug('::::::cardCreation:::ins::time:::'+cardCreation);
        system.debug('::::::timeLineCreation::::ins::time::'+timeLineCreation);
        system.debug(':::instructorIdLineListMap:::::::ins:time::'+instructorIdLineListMap);
        system.debug('::::::instIdTaskIdStringDayLsitMap::ins::time::'+instIdTaskIdStringDayLsitMap);
            
        try {
        
            if(cardCreation.size() > 0) { //Card creation
                insert cardCreation;
                
                for(AcctSeed__Time_Card__c timeCard : cardCreation) {
                
                    if(instructorIdLineListMap.containsKey(timeCard.Intructor__c)) {
                    
                        for(AcctSeed__Time_Card_Line__c timeLine : instructorIdLineListMap.get(timeCard.Intructor__c)) {
                            
                            system.debug('::::::before:assigning:::newly:::created:::card::'+timeLine);
                            
                            timeLine.AcctSeed__Time_Card__c = timeCard.Id;
                            
                            if(timeLine.AcctSeed__Project__c != null && timeLine.AcctSeed__Project_Task__c != null 
                                && timeLine.Contact_Assignment__c != null){    //Do not allow line creation if the project, project task, contact assignment are null
                                
                                system.debug('::::::adding:::::line::to insert:::'+timeLine);
                                
                                timeLineCreation.add(timeLine);
                            }
                        }
                    }
                }
            }
            
            system.debug('::::::timeLineCreation::after::card::create::'+timeLineCreation);
            
            if(timeLineCreation.size() > 0) { // Line creation
                insert timeLineCreation;
                
                for(AcctSeed__Time_Card_Line__c cardLine :timeLineCreation) {
                    timeCardLineId.add(cardLine.Id);
                }
                
                system.debug(':::::timeCardLineId::::'+timeCardLineId);
                
                for(AcctSeed__Time_Card_Line__c lineRec : [SELECT Id,Name,AcctSeed__Project_Task__c,AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Billable__c,Payroll_Item__c,Location__c FROM AcctSeed__Time_Card_Line__c WHERE Id IN :timeCardLineId]) {
                    if(!insIdStringTimeLineMap.containsKey(lineRec.AcctSeed__Time_Card__r.Intructor__c)) {
                        insIdStringTimeLineMap.put(lineRec.AcctSeed__Time_Card__r.Intructor__c,new Map<String,AcctSeed__Time_Card_Line__c>{lineRec.AcctSeed__Project_Task__c+'-'+lineRec.AcctSeed__Billable__c+'-'+lineRec.Payroll_Item__c+'-'+lineRec.Location__c=>lineRec});
                    }
                    insIdStringTimeLineMap.get(lineRec.AcctSeed__Time_Card__r.Intructor__c).put(lineRec.AcctSeed__Project_Task__c+'-'+lineRec.AcctSeed__Billable__c+'-'+lineRec.Payroll_Item__c+'-'+lineRec.Location__c,lineRec);
                    
                    //For Submit action validate
                    if(!lineIdTaskType.containsKey(lineRec.Id)){
                        lineIdTaskType.put(lineRec.Id,lineRec.AcctSeed__Project_Task__r.Project_Task_Type__c);
                    }
                }
                system.debug('::::::insIdStringTimeLineMap:::::::'+insIdStringTimeLineMap);
                
                for(String insIdTaskId : instIdTaskIdStringDayLsitMap.keySet()) {
                    
                    String insId = insIdTaskId.split('-')[0];
                    String taskId = insIdTaskId.split('-')[1];
                    Boolean billValue = Boolean.valueOf(insIdTaskId.split('-')[2]);
                    String payRollItemList = insIdTaskId.split('-')[3];
                    String locationId = insIdTaskId.split('-')[4];
                    
                    for(AcctSeed__Time_Card_Day__c timeCardDay : instIdTaskIdStringDayLsitMap.get(insIdTaskId)) {
                        
                        if(insIdStringTimeLineMap.containsKey(insId)) {
                            
                            if(insIdStringTimeLineMap.get(insId).containsKey(taskId+'-'+billValue+'-'+payRollItemList+'-'+locationId)) {
                                
                                AcctSeed__Time_Card_Line__c timeLineRec = insIdStringTimeLineMap.get(insId).get(taskId+'-'+billValue+'-'+payRollItemList+'-'+locationId);
                                String linePayRoll = timeLineRec.Payroll_Item__c;
                                
                                if(timeLineRec.AcctSeed__Billable__c != null && linePayRoll != null && timeLineRec.Location__c != null){
                                    
                                    if(timeLineRec.AcctSeed__Billable__c ==  billValue && linePayRoll == payRollItemList && timeLineRec.Location__c == locationId) {
                                        timeCardDay.AcctSeed__Time_Card_Line__c = timeLineRec.Id;
                                        dayListToUpsert.add(timeCardDay);
                                    }
                                }
                            }
                        }
                    }
                }
                
                system.debug('::::::::dayListToUpsert:::::'+dayListToUpsert);
                
                // Time card day upsertion
                if(dayListToUpsert.size() > 0){
                
                    //To find which TCDs are newly inserted & which are came for update
                    for(AcctSeed__Time_Card_Day__c tcd : dayListToUpsert) {
                        if(updatedTCDIds.contains(tcd.Id) && actionType != 'Submit'){
                            if(!tcdIdNoteType.containsKey(tcd.Id)) {
                                tcdIdNoteType.put(tcd.Id,'TCD Edit');
                            }
                        }
                    }
                
                    upsert dayListToUpsert;
                }
            }else {
                system.debug('::::::::dayListToUpsert:::::'+dayListToUpsert);
                
                // Time card day upsertion
                if(dayListToUpsert.size() > 0){
                    
                    //To find which TCDs are newly inserted & which are came for update
                    for(AcctSeed__Time_Card_Day__c tcd : dayListToUpsert) {
                        if(updatedTCDIds.contains(tcd.Id) && actionType != 'Submit'){
                            if(!tcdIdNoteType.containsKey(tcd.Id)) {
                                tcdIdNoteType.put(tcd.Id,'TCD Edit');
                            }
                        }
                    }
                
                    upsert dayListToUpsert;
                }
            }
            
            //Create / Update Student Attendance Records after TCD create / update action
            if(studentRecords.size() > 0){
                List<Attendance__c> attendanceList = new List<Attendance__c>();
                Map<Date,Id> dateDayIdMap = new Map<Date,Id>();
                Set<Id> dayIds = new Set<Id>();
                Map<Date,Id> dateEventIdMap = new Map<Date,Id>();
                Map<Id,AcctSeed__Time_Card_Day__c> dayIdDayRecMap = new Map<Id,AcctSeed__Time_Card_Day__c>();
                
                
                //Get Exisitng TCD which are not related to Preparation time PT
                /*if(dayListToUpsert.size() > 0) {
                    for(AcctSeed__Time_Card_Day__c day : dayListToUpsert){
                        dayIds.add(day.Id);
                    }
                    
                    for(AcctSeed__Time_Card_Day__c day : [SELECT Id,AcctSeed__Date__c,Total_Hours_Before_Approved__c,Project_Task_Type__c,Instructor_Position__c,Instructor_Name__c 
                                                            FROM AcctSeed__Time_Card_Day__c 
                                                            WHERE Id IN :dayIds AND Project_Task_Type__c != 'Preparation time']){
                                                            
                        if(!dateDayIdMap.containsKey(day.AcctSeed__Date__c)){
                            dateDayIdMap.put(day.AcctSeed__Date__c,day.Id);
                        }
                        
                        if(!dayIdDayRecMap.containsKey(day.Id)){
                            dayIdDayRecMap.put(day.Id,day);
                        }
                    }
                
                }else {*/
                    for(AcctSeed__Time_Card_Day__c day : [SELECT Id,AcctSeed__Date__c,Total_Hours_Before_Approved__c,Project_Task_Type__c,Instructor_Position__c,Instructor_Name__c 
                                                            FROM AcctSeed__Time_Card_Day__c 
                                                            WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = :projectId 
                                                                        AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :contactId AND Project_Task_Type__c != 'Preparation time' AND 
                                                                        (AcctSeed__Date__c >= :startDt AND AcctSeed__Date__c <= :endDt)]){
                        if(!dateDayIdMap.containsKey(day.AcctSeed__Date__c)){
                            dateDayIdMap.put(day.AcctSeed__Date__c,day.Id);
                        }
                        
                        if(!dayIdDayRecMap.containsKey(day.Id)){
                            dayIdDayRecMap.put(day.Id,day);
                        }
                    }
                //}
                
                //Get Events for this date range
                for(Events__c eve : [SELECT Id,Name,Date__c FROM Events__c 
                                        WHERE Project__c = :projectId AND Instructor__c = :contactId AND (Date__c >= :startDt AND Date__c <= :endDt) 
                                        AND Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time']){
                                        
                    if(!dateEventIdMap.containsKey(eve.Date__c)){
                        dateEventIdMap.put(eve.Date__c,eve.Id);
                    }
                    
                }
                
                system.debug(':::::::dateDayIdMap::::::'+dateDayIdMap);
                system.debug(':::::::dateEventIdMap::::::'+dateEventIdMap);
                
                //Notes formation based on TCD Hrs & Student Hrs Missmatch
                //Added by NS on Apr 19 2019
                //Work Item No: W-001481
                Map<Id,Accounting_Seed_Time_Snapshot__c> tcdIdSnapshotRec = new Map<Id,Accounting_Seed_Time_Snapshot__c>();
                Map<Id,Set<Id>> tcdIdStudentIds = new Map<Id,Set<Id>>();
                
                String dtVal = system.now().format('MM/dd/yyyy hh:mm:ss a');
                
                //get student names values
                Map<Id,String> studentIdNameMap = new Map<Id,String>();
                Set<Id> studentIds = new Set<Id>();
                
                for(TimeCardDayCommunityDomain.StudentEntry stuRec : studentRecords){
                    studentIds.add(stuRec.studentId);
                    
                    if(dateDayIdMap.containsKey(stuRec.dateVal)){
                        Id dayId = dateDayIdMap.get(stuRec.dateVal);
                        
                        if(!tcdIdStudentIds.containsKey(dayId)){
                            tcdIdStudentIds.put(dayId,new Set<Id>{stuRec.studentId});
                        }else {
                            tcdIdStudentIds.get(dayId).add(stuRec.studentId);
                        }
                    }
                }
                
                system.debug('::::::tcdIdStudentIds:::'+tcdIdStudentIds);
                
                for(Contact con : [SELECT Id,FirstName,LastName FROM Contact WHERE Id IN :studentIds]){
                    if(!studentIdNameMap.containsKey(con.Id)){
                        studentIdNameMap.put(con.Id,con.FirstName+' '+con.LastName.subString(0,1)+'.');
                    }
                }
                
                system.debug(':::::::::studentIdNameMap:::::'+studentIdNameMap);
                
                for(TimeCardDayCommunityDomain.StudentEntry stuRec : studentRecords){
                    Attendance__c att = new Attendance__c();
                    
                    att.Student__c = stuRec.studentId;
                    att.Instructor__c = contactId;
                    att.Date__c = stuRec.dateVal;
                    att.Duration__c = Decimal.valueOf(stuRec.hours);
                    
                    att.Student_Approval_Status__c = 'Submitted';
                    att.Time_Card_Day__c = dateDayIdMap.containsKey(stuRec.dateVal) ? dateDayIdMap.get(stuRec.dateVal) : null;
                    
                    att.Comments__c = stuRec.comments;
                    
                    
                    //Check for the Actual Class Hrs & Student Hrs miss match for Notes creation
                    
                    //if(!updatedTCDIds.contains(att.Time_Card_Day__c)){
                        
                        if(dayIdDayRecMap.containsKey(att.Time_Card_Day__c) 
                            /*&& dayIdDayRecMap.get(att.Time_Card_Day__c).Total_Hours_Before_Approved__c != att.Duration__c*/ && String.isNotBlank(stuRec.comments)){
                            
                            
                            AcctSeed__Time_Card_Day__c day = dayIdDayRecMap.get(att.Time_Card_Day__c);
                            
                            Accounting_Seed_Time_Snapshot__c tcdSnapshot = new Accounting_Seed_Time_Snapshot__c();
                            tcdSnapshot.Note_Type__c = 'Instructor Daily Entry Student Hours Mismatch';
                            tcdSnapshot.Time_Card_Day__c = att.Time_Card_Day__c;
                            tcdSnapshot.Date__c = att.Date__c;
                            
                            String formattedDt = String.valueOf(att.Date__c).split('-')[1]+'/'+String.valueOf(att.Date__c).split('-')[2]+'/'+String.valueOf(att.Date__c).split('-')[0];
                            
                            tcdSnapshot.Notes__c = day.Instructor_Position__c+' '+day.Instructor_Name__c+' submitted a time entry on '+formattedDt+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                            
                            if(dayIdDayRecMap.get(att.Time_Card_Day__c).Total_Hours_Before_Approved__c != att.Duration__c)
                                tcdSnapshot.Notes__c += ', with different hours for a student.';
                            
                            
                            if(!tcdIdSnapshotRec.containsKey(att.Time_Card_Day__c)){
                                if(tcdIdStudentIds.containsKey(att.Time_Card_Day__c) && tcdIdStudentIds.get(att.Time_Card_Day__c).size() == 1) {
                                    tcdSnapshot.Notes__c += ' Notes: '+att.Comments__c;
                                }else if(tcdIdStudentIds.get(att.Time_Card_Day__c).size() > 1) {
                                    tcdSnapshot.Notes__c += ' Notes: '+studentIdNameMap.get(att.Student__c)+' - '+att.Comments__c;
                                }
                                tcdIdSnapshotRec.put(att.Time_Card_Day__c,tcdSnapshot);
                                
                            }else {
                                Accounting_Seed_Time_Snapshot__c existingSnapshot = tcdIdSnapshotRec.get(att.Time_Card_Day__c);
                                existingSnapshot.Notes__c += ', '+studentIdNameMap.get(att.Student__c)+' - '+att.Comments__c;
                                
                                tcdIdSnapshotRec.put(att.Time_Card_Day__c,existingSnapshot);
                            }
                        }
                    //}
                    
                    att.Event__c = dateEventIdMap.containsKey(stuRec.dateVal) ? dateEventIdMap.get(stuRec.dateVal) : null;
                    
                    if(stuRec.attendanceId != null){
                        att.Id = stuRec.attendanceId;
                    }
                    
                    if(stuRec.attendance != null){
                        att.Attendance__c = stuRec.attendance;
                    }
                    
                    system.debug(':::::::::att:::;;'+att);
                    
                    if(att.Time_Card_Day__c != null){
                        attendanceList.add(att);
                    }
                }
                
                system.debug('::::::::::::::attendanceList::::::'+attendanceList);
                system.debug('::::::::tcdIdSnapshotRec::::'+tcdIdSnapshotRec);
                
                List<Accounting_Seed_Time_Snapshot__c> snapshotRecords = new List<Accounting_Seed_Time_Snapshot__c>();
                
                if(tcdIdSnapshotRec.size() > 0){
                    for(Id tcdId : tcdIdSnapshotRec.keySet()){
                        snapshotRecords.add(tcdIdSnapshotRec.get(tcdId));
                    }
                }
                
                system.debug('::::::::::snapshotRecords:::'+snapshotRecords);
                
                if(snapshotRecords.size() > 0){
                    insert snapshotRecords;
                }
                
                if(attendanceList.size() > 0){
                    upsert attendanceList;
                }
            }
            
            system.debug(':::::updateTCLList::::'+updateTCLList);
                
                if(updateTCLList.size() > 0){
                    update updateTCLList;
                }
                
            //If action type is completed then call the timecardRelateEmail controller method to send email to student
            //For Student Time Approval preference is week
            //W-002922
            //Added by NS on OCT 22 2019
            if(actionType == 'Complete'){
                
                //update the existing time card line flag to completed
                //New TCL will be set as completed on creation itself
                
                /*system.debug(':::::updateTCLList::::'+updateTCLList);
                
                if(updateTCLList.size() > 0){
                    update updateTCLList;
                }*/
                
                //add newly created records ids to the set
                for(AcctSeed__Time_Card_Day__c day : dayListToUpsert){
                    dayIdsForComplete.add(day.Id);
                }
                
                // Commented on Nov 16 2023
                // W-007927 : Student Weekly Timesheet Approval Email Notification is Sending Daily Reminders
                // As students are receiving many (upon time entry submission, Weekly Approval Request, Weekly Approval Reminder) emails regarding the instructor's time entry approval or rejection process, this email could be commented to avoid further emails.
                /*
                if(dayIdsForComplete.size() > 0){
                    timeCardRelated_Email_Controller.sendAnEmailToStudent(dayIdsForComplete,true);
                }
                */
            }
            
            return 'SUCCESS';
        }catch(DmlException e){
           system.debug('::::::::exception msg:::::::'+e.getMessage());
           throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**************************************************************
    - Method to recall the existing time entries
    - Added by NS on Mar 17 2019
    **************************************************************/
    @AuraEnabled
    public static String recallExistingTimeEntries(String timeDayJson,String typeOfAction){
        
         //check current user profile is Instructor community / Any internal user allow them to create records
        //if not throw validation msg
        Boolean currentUsrIsValid = checkCurrentUsrIsValid();
        if(!currentUsrIsValid){
            throw new AuraHandledException('Your session is expried and the changes will not be saved. Please login to enter your time');
        }
        
        List<TimeCardDayCommunityDomain.DayEntries> dayRecords = (List<TimeCardDayCommunityDomain.DayEntries>) System.JSON.deserialize(timeDayJson, List<TimeCardDayCommunityDomain.DayEntries>.class);
        
        //Recall action update the TCL Completed checkbox field
        //By NS on July 31 2019
        
        List<AcctSeed__Time_Card_Day__c> daysForRecall = new List<AcctSeed__Time_Card_Day__c>();
        
        // Static map initialization to use in Time Card Day Trigger
        //Work Item No : W-001481
        tcdIdNoteType = new Map<Id,String>(); 
        Boolean submittedEntryExist = false;
        
        for(TimeCardDayCommunityDomain.DayEntries day : dayRecords){
        
             if(day.dayId != null){
            
                AcctSeed__Time_Card_Day__c dayRec = new AcctSeed__Time_Card_Day__c();
                dayRec.Id = day.dayId;
                
                if(typeOfAction == 'Group') {
                    
                    if(day.status == 'Submitted' || day.status == 'Approved' || day.status == 'Admin Approved') {
                        dayRec.Status__c = 'Recalled';
                        //For Notes Formation
                        if(!tcdIdNoteType.containsKey(day.dayId)) {
                            tcdIdNoteType.put(day.dayId,'Weekly Recall');
                        }
                    }
                    
                }else {
                
                    dayRec.Recall_Reason__c = day.recallReason;
                    
                    //For Notes Formation
                    if(!tcdIdNoteType.containsKey(day.dayId)) {
                        tcdIdNoteType.put(day.dayId,'Daily Recall');
                    }
                    
                    if(day.studentApprovalStatus == 'Approved'){
                        dayRec.Student_Approval_Status__c = 'Recalled';
                    }
                    
                    if(day.status == 'Submitted' || day.status == 'Approved' || day.status == 'Admin Approved'){
                        dayRec.Status__c = 'Recalled';
                    }
                }
                
                if(day.status == 'Submitted' || day.status == 'Approved' || day.status == 'Admin Approved'){
                    submittedEntryExist = true;
                }
                
                //W-005837 - Added by NS on Aug 13 2020
                if(day.status == 'Approved' || day.status == 'Admin Approved'){
                    dayRec.AcctSeed__Hours__c = 0;
                }
                
                daysForRecall.add(dayRec);
            }
        }
        
        system.debug('::::::daysForRecall:::::'+daysForRecall);
        
        List<AcctSeed__Time_Card_Line__c> lineForRecall = new List<AcctSeed__Time_Card_Line__c>();
        Set<Id> lineIds = new Set<Id>();
        
        
        for(TimeCardDayCommunityDomain.DayEntries day : dayRecords){
            
            if(day.lineId != null && !lineIds.contains(day.lineId)){
                AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                line.Id = day.lineId;
                line.Completed__c = false;
                
                lineForRecall.add(line);
                lineIds.add(day.lineId);
            }
        }
        
        Boolean updateTCDStatus = false;
        
        //check the existing TCLs count fields to update TCD status to Recalled
        //If the all TCDs are in submitted status we have to update the TCD status
        for(AcctSeed__Time_Card_Line__c line : [SELECT Id,Name,Completed__c,of_Approved_Hours__c,of_Pending_Time_Logs__c,of_Rejected_Hours__c,of_Submitted_Hours__c 
                                                    FROM AcctSeed__Time_Card_Line__c
                                                    WHERE Id IN :lineIds]){
                                                    
            system.debug(':::::::line::::::::'+line);
            
             if(typeOfAction == 'Group'){
                
                if(line.Completed__c && (line.of_Submitted_Hours__c > 0 || line.of_Approved_Hours__c > 0) && (line.of_Pending_Time_Logs__c == 0 && line.of_Rejected_Hours__c == 0)){
                    updateTCDStatus = true;
                }else if(submittedEntryExist){
                    updateTCDStatus = true;
                }else {
                    updateTCDStatus = false;
                }
            }
        }
        
        if(typeOfAction != 'Group'){
            updateTCDStatus = true;
        }
        
        system.debug('::::::updateTCDStatus::::'+updateTCDStatus);
        
        try {
            
            if(updateTCDStatus){
                if(typeOfAction == 'Group') {
                    isGroupAction = true;
                    groupActionType = 'Recalled';
                }
                
                if(daysForRecall.size() > 0){
                    update daysForRecall;
                }
            }
            
            if(lineForRecall.size() > 0 && typeOfAction == 'Group'){
                update lineForRecall;
            }
            
            return 'SUCCESS';
        }catch(DmlException e){
            system.debug('::::::::exception msg::recall:::::'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*******************************************************************************************8
    - Method to submit the time entries without any changes
    - Added by NS on Mar 22 2019
    ********************************************************************************************/
    @AuraEnabled
    public static String submitTCDEntries(String timeDayJson){
        
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
                
                if(day.taskType != 'Preparation time' && day.studentApprovalStatus != 'Approved' && day.studentApprovalStatus != 'Submitted'){
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
    
    /**********************************************************************
    - Method to recall the student attendance values from instructor time entry page
    - Added by NS on Mar 20 2019
    ***********************************************************************/
    @AuraEnabled
    public static String recallStudentAttendanceEntry(String studentJson){
        
         //check current user profile is Instructor community / Any internal user allow them to create records
        //if not throw validation msg
        Boolean currentUsrIsValid = checkCurrentUsrIsValid();
        if(!currentUsrIsValid){
            throw new AuraHandledException('Your session is expried and the changes will not be saved. Please login to enter your time');
        }
        
        List<TimeCardDayCommunityDomain.StudentEntry> studentRecords = (List<TimeCardDayCommunityDomain.StudentEntry>) System.JSON.deserialize(studentJson, List<TimeCardDayCommunityDomain.StudentEntry>.class);
        system.debug(':::::::::studentRecords:::'+studentRecords);
        
        Attendance__c attRec = new Attendance__c();
        attRec.Id = studentRecords[0].attendanceId;
        attRec.Recall_Reason__c = studentRecords[0].recallReason;
        attRec.Student_Approval_Status__c = 'Recalled';
        
        try {
            update attRec;
            
            return 'SUCCESS';
        }catch(Exception e) {
            system.debug('::::::::exception msg::recall:::::'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /************************************************************************************
    - Method to get project based Active, Draft & completed(last 14 days) schedule records
    - Added by NS on June 7 2019
    ************************************************************************************/
    @AuraEnabled
    public static List<Schedule__c> getProjectBasedSchedules(string projectId,String startDate, String endDate,String contactId){
        
        Date stDate = Date.valueOf(startDate);
        Date edDate = Date.valueOf(endDate);
        
        List<Schedule__c> scheduleRecords = [SELECT Id,Name,Start_Date__c,End_Date__c,Status__c,Days__c,Start_Time__c,
                                                    End_Time__c,Project_Task__r.Name,Project__r.Students__c 
                                                FROM Schedule__c 
                                                WHERE Project__c = :projectId AND Instructor__c = :contactId AND (Status__c IN ('Drafted','Active') AND End_Date__c > :stDate)];
        return scheduleRecords;
    }
    
    
    /*********************************************************************************************
    - Method to create case record when user click Request Edit Access btn for previous week
    - Added by NS on June 14 2019
    **********************************************************************************************/
    @AuraEnabled
    public static String createCaseRecord(String caseJson){
        
         //check current user profile is Instructor community / Any internal user allow them to create records
        //if not throw validation msg
        Boolean currentUsrIsValid = checkCurrentUsrIsValid();
        if(!currentUsrIsValid){
            throw new AuraHandledException('Your session is expried and the changes will not be saved. Please login to enter your time');
        }
        
        List<Case> caseRecords = (List<Case>) System.JSON.deserialize(caseJson, List<Case>.class);
        system.debug(':::::::::::::caseRecords::::::::::'+caseRecords);
        try {
            if(caseRecords.size() > 0){
                
                insert caseRecords;
                
                //Send Email to timesheets@dlsdc.com with same content
                List<Messaging.SingleEmailMessage> EmailList = new List<Messaging.SingleEmailMessage>();
                
                String mailContent = '<html>Timekeeping Admins,<br/><br/>The '+caseRecords[0].Subject+' for the following reason: ';
                
                if(caseRecords[0].Description != null){
                    mailContent += caseRecords[0].Description;
                }else {
                    mailContent += 'null';
                }
                
                mailContent += '<br/><br/>Please <a href="'+System.Label.Org_Prefix_Start_URL+'/lightning/n/Admin_Time_Entry" target="_blank">click Here</a> to go to the Admin Time Entry page to Revert the timesheet to the Instructor.<br/><br/>';
                
                mailContent += 'System Generated Email';
                
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String> {'timesheets@dlsdc.com'});
                mail.setSubject(caseRecords[0].Subject);
                mail.sethtmlBody(mailContent);
                mail.setSaveAsActivity(false);
                EmailList.add(mail);
                
                if( EmailList != null && EmailList.size() > 0 ) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(EmailList);
                } 
            }
            return 'SUCCESS';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*********************************************************************************************
    - Method to get the Existing TCD records from other projects for the same week
    - Added by NS on July 12 2019
    **********************************************************************************************/
    @AuraEnabled
    public static String getExistingTCDsForOtherProjects(String instructorId,String startDate,String endDate,String projectId){
        system.debug('::::::existing:::tcd:::::'+instructorId+' '+startDate+' '+endDate+' '+projectId);
        
        Date stDate = Date.valueOf(startDate);
        Date edDate = Date.valueOf(endDate);
        
        List<AcctSeed__Time_Card_Day__c> existingTCDs = [SELECT Id,Name,AcctSeed__Date__c,Start_Time1__c,End_Time1__c,Start_Time2__c,End_Time2__c,
                                                            Total_Hours_Before_Approved__c,Project_Task_Name__c,Project_Task_Type__c,Status__c,DLS_Class__c,
                                                            AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c 
                                                         FROM AcctSeed__Time_Card_Day__c
                                                         WHERE AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :edDate AND Status__c != 'Unposted'
                                                                 AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :instructorId
                                                                 AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c != :projectId];
        
        Map<Date,List<TimeCardDayCommunityDomain.DayEntries>> dateEntryMap = new Map<Date,List<TimeCardDayCommunityDomain.DayEntries>>();
        Set<Id> projectIds = new Set<Id>();
        Map<Id,String> projectIdsRelatedStudents = new Map<Id,String>();
        
        for(AcctSeed__Time_Card_Day__c day : existingTCDs){
            projectIds.add(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c);
        }
        
        if(projectIds.size() > 0){
            for(Contact_Assignments__c ca : [SELECT Id,Candidate_Name__r.Name,Candidate_Name__r.FirstName,Candidate_Name__r.LastName,Project__c 
                                                FROM Contact_Assignments__c 
                                                WHERE Project__c IN : projectIds AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active']){
                if(projectIdsRelatedStudents.containsKey(ca.Project__c)){
                    projectIdsRelatedStudents.put(ca.Project__c, projectIdsRelatedStudents.get(ca.Project__c)+ca.Candidate_Name__r.FirstName+' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.; ');
                }else{
                    projectIdsRelatedStudents.put(ca.Project__c, (ca.Candidate_Name__r.FirstName+' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.; '));
                }
            }
        }
        
        system.debug('::::::projectIdsRelatedStudents:::'+projectIdsRelatedStudents);
        
        
        for(AcctSeed__Time_Card_Day__c day : existingTCDs){
            TimeCardDayCommunityDomain.DayEntries entry = new TimeCardDayCommunityDomain.DayEntries();
            entry.hours = day.Total_Hours_Before_Approved__c;
            entry.dayId = day.Id;
            entry.projectId = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            entry.taskId = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            entry.status = day.Status__c;
            entry.dateVal = day.AcctSeed__Date__c;
            entry.projectName = day.DLS_Class__c;
            entry.taskName = day.Project_Task_Name__c;
            entry.taskType = day.Project_Task_Type__c;
            entry.startTime1 = day.Start_Time1__c;
            entry.endTime1 = day.End_Time1__c;
            entry.startTime2 = day.Start_Time2__c;
            entry.endTime2 = day.End_Time2__c;
            entry.displayDate = String.valueOf(day.AcctSeed__Date__c).split('-')[1]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[2]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[0];
            
            DateTime actualDt = DateTime.newInstance(day.AcctSeed__Date__c, Time.newInstance(0, 0, 0, 0));
            entry.dayType = actualDt.format('EEEE');
            
            entry.dayHours = String.valueOf(day.Total_Hours_Before_Approved__c);
            if(!entry.dayHours.contains('.')){
                entry.dayHours = entry.dayHours+'.00';
            }
            
            if(projectIdsRelatedStudents.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c)){
                entry.studentNames = projectIdsRelatedStudents.get(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c);
            }
            
            if(!dateEntryMap.containsKey(day.AcctSeed__Date__c)){
                dateEntryMap.put(day.AcctSeed__Date__c,new List<TimeCardDayCommunityDomain.DayEntries>{entry});
            }else {
                dateEntryMap.get(day.AcctSeed__Date__c).add(entry);
            }
        }
        
        system.debug(':::::::::dateEntryMap:::::'+dateEntryMap);
        
        return JSON.serialize(dateEntryMap);
        
    }
    
     /*******************************************************************************************8
    - Method to complete the time entries for that week
    - Added by NS on July 30 2019
    ********************************************************************************************/
    @AuraEnabled
    public static string completeTCDEntries(String timeDayJson){
    
         //check current user profile is Instructor community / Any internal user allow them to create records
        //if not throw validation msg
        Boolean currentUsrIsValid = checkCurrentUsrIsValid();
        if(!currentUsrIsValid){
            throw new AuraHandledException('Your session is expried and the changes will not be saved. Please login to enter your time');
        }
    
        List<TimeCardDayCommunityDomain.DayEntries> dayRecords = (List<TimeCardDayCommunityDomain.DayEntries>) System.JSON.deserialize(timeDayJson, List<TimeCardDayCommunityDomain.DayEntries>.class);
        
        List<AcctSeed__Time_Card_Line__c> lineRecordsForComplete = new List<AcctSeed__Time_Card_Line__c>();
        
        Set<Id> lineIds = new Set<Id>();
        Set<Id> dayIds = new Set<Id>();
        
        for(TimeCardDayCommunityDomain.DayEntries day : dayRecords){
        
            if(day.dayId != null){
                dayIds.add(day.dayId);
            }
            
            if(day.dayId != null && day.lineId != null && !lineIds.contains(day.lineId)){
                lineIds.add(day.lineId);
                
                AcctSeed__Time_Card_Line__c line = new AcctSeed__Time_Card_Line__c();
                line.Id = day.lineId;
                line.Completed__c = true;
                
                lineRecordsForComplete.add(line);
            }
        }
        
        try {
            if(lineRecordsForComplete.size() > 0){
                update lineRecordsForComplete;
                                
                // Commented on Nov 16 2023
                // W-007927 : Student Weekly Timesheet Approval Email Notification is Sending Daily Reminders
                // As students are receiving many (upon time entry submission, Weekly Approval Request, Weekly Approval Reminder) emails regarding the instructor's time entry approval or rejection process, this email could be commented to avoid further emails.
                /*
                //Call Student Weekly email notification method if completed action is success
                //Call generic method in time card related email controller
                //Added by NS on NOV 21 2019 for student time approval preference task
                //W-002922
                if(dayIds.size() > 0){
                    timeCardRelated_Email_Controller.sendAnEmailToStudent(dayIds,true);
                }
                */
            }
            return 'SUCCESS';
        }catch(DmlException e){
            system.debug('::::::::exception msg::complete:::::'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*******************************************************************************************
    - Method to get the selected week & project related scheduled events
    - Added by NS on August 1 2019
    ********************************************************************************************/
    @AuraEnabled
    public static String getScheduledEvents(String startDt, String endDt, String projectId, String contactId){
    
        String msg = '';
        String finalMsg = '';
        
        Date dt1 = Date.valueOf(startDt);
        Date dt2 = Date.valueOf(endDt);
       
        for(Events__c eve : [SELECT Id,Name,Date__c,Start_Time__c,End_Time__c,Duration__c,Schedule__r.Project_Task__r.Name FROM Events__c 
                                WHERE Project__c = :projectId AND Instructor__c = :contactId AND Date__c >= :dt1 AND Date__c <= :dt2
                                        AND Status__c = 'Scheduled']){
                                        
            String dt = String.valueOf(eve.Date__c).split('-')[1]+'/'+String.valueOf(eve.Date__c).split('-')[2]+'/'+String.valueOf(eve.Date__c).split('-')[0];
            msg += '<li>'+dt+' / '+eve.Start_Time__c+'-'+eve.End_Time__c+' / '+eve.Duration__c+'Hrs / '+eve.Schedule__r.Project_Task__r.Name+'</li>';
        }
        
        if(String.isNotBlank(msg)){
             finalMsg = '<ul style="list-style-type: initial;">';
             finalMsg += msg;
             
             finalMsg += '</ul>';
        }
        
        system.debug('::::::::finalMsg::::::'+finalMsg);
        
        return finalMsg;
    }
    
    //Method to check current user is session is expired or not
    public static Boolean checkCurrentUsrIsValid(){
        
        List<User> currentUsr = [SELECT Id,Name,Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        if(currentUsr.size() > 0 && currentUsr[0].Profile.Name == 'Instructor Profile'){
            
            return false;
        }
        return true;
        
    }
    
    /*******************************************************************************************
    - Added by NS on Dec 23 2019
    - To get the selected week & project & instructor related events to check with planned & actual hours
    ********************************************************************************************/
    @AuraEnabled
    public static String getProjectRelatedEvents(String projectId, String instructorId, String startDate, String endDate, String timeDayJson){
        
        system.debug(':::::getProjectRelatedEvents:::::'+projectId+' '+instructorId+' '+startDate+' '+endDate);
        
        List<TimeCardDayCommunityDomain.DayEntries> dayRecords = (List<TimeCardDayCommunityDomain.DayEntries>) System.JSON.deserialize(timeDayJson, List<TimeCardDayCommunityDomain.DayEntries>.class);
        
        Date stDate = Date.valueOf(startDate);
        Date edDate = Date.valueOf(endDate);
        
        Map<Date,Decimal> eventDateHrsMap = new Map<Date,Decimal>();
        Map<Date,Decimal> tcdDateHrsMap = new Map<Date,Decimal>();
        
        Map<Date,Boolean> dateNotesRequiredFlagMap = new Map<Date,Boolean>();
        
        for(Events__c eve : [SELECT Id,Name,Duration__c,Date__c FROM Events__c 
                                WHERE Project__c = :projectId AND Instructor__c = :instructorId 
                                        AND Date__c >= :stDate AND Date__c < TODAY 
                                        AND Status__c = 'Scheduled' AND Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time']){
            
            if(!eventDateHrsMap.containsKey(eve.Date__c)){
                eventDateHrsMap.put(eve.Date__c,eve.Duration__c);
            }
        }
        
        Date todayDt = system.today();
        
        //TCD Formation
        for(TimeCardDayCommunityDomain.DayEntries day : dayRecords){
            
            if(day.dateVal < todayDt && eventDateHrsMap.containsKey(day.dateVal)){
                
                if(eventDateHrsMap.get(day.dateVal) != Decimal.valueOf(day.dayHours)){
                    
                    if(!dateNotesRequiredFlagMap.containsKey(day.dateVal)){
                        dateNotesRequiredFlagMap.put(day.dateVal,true);
                    }
                }
            }
        }
        
        system.debug('::::::::::dateNotesRequiredFlagMap:::::'+dateNotesRequiredFlagMap);
        
        return JSON.serialize(dateNotesRequiredFlagMap);
    }
}