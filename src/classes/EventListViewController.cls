/************************************************************************
 - Created by NS on May 30 2019
 - To display the Events table in Schedules Tab section in Student & Instructor Community
*************************************************************************/
public without sharing class EventListViewController { 


    @AuraEnabled
    public static String getEventRecords(List<String> statusValues,List<String> taskType,String stDate,String edDate ,List<String> otherTaskTypes ,String projectId){
    
        String contactId = EventCalendarController.getLoggedUserContactId(); // Get Currently logged user's contact Id
        String communityName = EventCalendarController.getCommunityPathPrefix();
        String recordTypeName = '';
        Map<String,String> projectIdNameMap = new Map<String,String>();
        Date startDate;
        Date endDate;
        Date todayDate = System.today();
        EventInfo eventView = new EventInfo();
        List<ListViewController.PicklistWrap> pickListValues = new List<ListViewController.PicklistWrap>();
        
        ListViewController.PicklistWrap pickListVal = new ListViewController.PicklistWrap();
        pickListVal.label = 'All';
        pickListVal.value = 'All';
        pickListValues.add(pickListVal);
        
        if(projectId == 'All'){
            projectId = null;
        }
        system.debug('stDate:'+stDate);
        if(String.isNotBlank(stDate)){
            startDate = Date.valueOf(stDate);
        }
        
        /*if(String.isBlank(stDate)){
            date tempDate = Date.today();
            startDate = (tempDate.toStartOfWeek()).addDays(1);
        }
        
        if(String.isBlank(edDate)){
            endDate = startDate.addDays(6);
        }*/
        system.debug('edDate:'+edDate);
        if(String.isNotBlank(edDate)){
            endDate = Date.valueOf(edDate);
        }
        
        if(communityName == 'instructor' || Test.isRunningTest()){
            recordTypeName = 'Instructor';
        }else if(communityName == 'student' || Test.isRunningTest()){
            recordTypeName = 'Student';
        }else if(communityName == 'client'){
            recordTypeName = 'Client_Partner';
        }
        
        Set<Id> projectIds = new Set<Id>();
        system.debug('commmunity name'+communityName);
        
        if(String.isNotBlank(contactId) && communityName != null) {
            for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,Project__r.DLS_Ref__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId AND RecordType.DeveloperName = :recordTypeName AND Project__c != null]){
                if(ca.Project__c != null){
                         projectIds.add(ca.Project__c);
                }
            }
        }
        
        system.debug('project id set'+projectIds);
        
        for(AcctSeed__Project__c proj : [SELECT Id,Name,AcctSeed__Account__r.Name,DLS_Ref__c,Start_Date__c,End_Date__c, AcctSeed__Status__c,Project_Manager__c,Project_Manager__r.Name,Training_Location__c,Training_Location__r.Name FROM AcctSeed__Project__c WHERE Id IN : projectIds] ){
            
            ListViewController.PicklistWrap pickListVal1 = new ListViewController.PicklistWrap();
                if(proj.DLS_Ref__c != null){
                    pickListVal1.label = proj.DLS_Ref__c;
                    pickListVal1.value = proj.id;
                    pickListValues.add(pickListVal1);
                }
        }
        
        eventView.projectValues = pickListValues;
        
        system.debug('pickListValues id set'+pickListValues);
        system.debug('contatcId id set'+contactId);

        String eventQryStr = 'SELECT Id, Name, Agenda_Sequence_No__c, Cancelled_by__c, ContentVersionId__c, Date__c, Duration__c, End_Date_Time__c'; 
        
        eventQryStr += ', End_Time__c, Event_Agenda__c, Instructor__c, IsEvent__c, Language__c, Meeting_URL__c, Project__c, Room__c, Schedule__c, SequenceNo__c';
        eventQryStr += ', Instructor__r.Name, Project__r.Name, Project__r.Project_Manager__c, Project__r.Project_Manager__r.Name,Parent_Event__r.Status__c, Room__r.Name, Schedule__r.Name, Reject_Comment__c, Cancelled_by__r.Name, project__r.DLS_Ref__c';
        eventQryStr += ', Start_Date_Time__c, Start_Time__c, Status__c, Time_Card_Day__c, Timezone__c, Total_Used_Hours__c,Day_of_Week__c,Parent_Event__c,Approver_Name__c';
        eventQryStr += ',Schedule__r.Project_Task__c,Project_Task__c,Project_Task__r.Name,Project_Task__r.Project_Task_Type__c, Schedule__r.Project_Task__r.Name,Schedule__r.Project_Task__r.Project_Task_Type__c,Approval_Status__c, Schedule__r.Meeting_URL__c, Project__r.AcctSeed__Account__c, Project__r.AcctSeed__Account__r.Name, Project__r.RecordType.DeveloperName, Project__r.Project_Type__c, Instructor__r.FirstName, Instructor__r.LastName, Schedule__r.Create_Zoom_Meetings__c FROM Events__c ';
        
        if((communityName == 'instructor' && contactId != null && contactId != '') || Test.isRunningTest()){
            eventQryStr += ' WHERE Instructor__c = :contactId';
        }else if((communityName == 'student' || communityName == 'client') && projectIds.size() > 0){ 
            eventQryStr += ' WHERE Project__c IN :projectIds AND (Project_Task__r.Project_Task_Type__c != \'Preparation time\' OR Schedule__r.Project_Task__r.Project_Task_Type__c != \'Preparation time\')';
        }
        
        if(startDate != null && endDate != null) {
            eventQryStr += ' AND Date__c >= :startDate AND Date__c <= :endDate'; 
        }else if(startDate != null){
            eventQryStr += ' AND Date__c >= :startDate'; 
        }else if(endDate != null){
            eventQryStr += ' AND Date__c <= :endDate'; 
        }else if(todayDate != null){
            eventQryStr += ' AND Date__c >= :todayDate';
        }
        
        if(statusValues.size() > 0){
            eventQryStr += ' AND Status__c IN :statusValues ';
        }
        
        if(projectId != null){
            eventQryStr += ' AND project__c = :projectId';
        }
        
        if(taskType.size() > 0){
            eventQryStr += ' AND Schedule__r.Project_Task__r.Project_Task_Type__c IN :taskType';
        }
       
        if(communityName == 'instructor'){
            eventQryStr += ' AND Status__c != \'Draft\'';  
        }
        
        eventQryStr += ' AND Approval_Status__c != \'Rejected\'';
        system.debug('::::::::::eventQryStr:::'+eventQryStr);
        //Get Planned Days Off records

        List<Planned_Days_Off__c> plaNnedLeaves = new List<Planned_Days_Off__c>();
        List<Planned_Days_Off__c> plannedLeaves1 = new List<Planned_Days_Off__c>();
        
        List<Holiday> holidayRecords = new List<Holiday>();
        
        if(otherTaskTypes.contains('PlannedDayOff')){
            
            List<String> filterRecordTypes = new List<String>{'Request','DLI-W LT Training Holidays'};
            List<String> statusFilters = new List<String>{'Approved','Submitted for Approval'};
            //Set<Id> projectIdSet = new Set<Id>();
            Set<Id> contactIDs = new Set<Id>();
            
            /*if(String.isNotBlank(contactId) && (communityName == 'student' || communityName == 'instructor')) {
                for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,Project__r.DLS_Ref__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId AND RecordType.DeveloperName = :recordTypeName AND Project__c != null]){
                    if(ca.Project__c != null){
                        projectIdSet.add(ca.Project__c);
                    }
                }
            }*/  
            
            if(projectIDs.size() > 0){
                String rtType = (recordTypeName == 'Student' ? 'Instructor' : 'Student');
                for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,Project__r.DLS_Ref__c,RecordType.DeveloperName,Candidate_Name__c,Candidate_Name__r.FirstName,Candidate_Name__r.LastName 
                                                 FROM Contact_Assignments__c 
                                                 WHERE RecordType.DeveloperName = :rtType AND Status__c != 'Ended' 
                                                 AND Project__c IN :projectIDs]){
                    if(ca.Candidate_Name__c != null){
                        contactIDs.add(ca.Candidate_Name__c);
                    } 
                }
            }
            
            String plannedQuery1;
            String plannedQuery2;
            
            plannedQuery1 = 'SELECT Id,name,Description__c,Contact__c,Contact__r.Name,Leave_Type__c,Project__c,Project__r.DLS_Ref__c,Project__r.name ,Date__c, Type__c,Status__c '+
                                          'FROM Planned_Days_Off__c WHERE Contact__c = :contactId AND Status__c IN :statusFilters';
            
            if(recordTypeName == 'Student'){
                
                filterRecordTypes .add('Student_Planned_Days_Off');                
                plannedQuery1 += ' AND RecordType.DeveloperName = \'Student_Planned_Days_Off\'';                
            }else if(recordTypeName == 'Instructor'){
                
                filterRecordTypes .add('Instructor_Planned_Days_Off');                
                plannedQuery1 += ' AND RecordType.DeveloperName = \'Instructor_Planned_Days_Off\''; 
            }
            
            //get Planned Days Off records except logged Contact related planned Days Off records
            plannedQuery2 = 'SELECT Id,name,Description__c,Contact__c,Contact__r.Name,Leave_Type__c,Project__c,Project__r.DLS_Ref__c,Project__r.name ,Date__c, Type__c,Status__c '+
                                'FROM Planned_Days_Off__c WHERE RecordType.DeveloperName Not IN :filterRecordTypes AND Status__c IN :statusFilters AND Contact__c IN :contactIDs';
            Date startDateForPDO;
            if(String.isBlank(stDate)){
                startDateForPDO = System.today();
            }else{
                startDateForPDO = startDate;
            }
            if(stDate != null && edDate != null) {
                plannedQuery1 += ' AND ((Date__c >= :startDateForPDO AND Date__c <= :endDate) OR (From_Date__c >= :startDate AND To_Date__c <= :endDate))'; 
                plannedQuery2 += ' AND ((Date__c >= :startDateForPDO AND Date__c <= :endDate) OR (From_Date__c >= :startDate AND To_Date__c <= :endDate))'; 
            }else if(stDate != null || startDateForPDO != null){
                plannedQuery1 += ' AND (Date__c >= :startDateForPDO OR From_Date__c >= :startDateForPDO)'; 
                plannedQuery2 += ' AND (Date__c >= :startDateForPDO OR From_Date__c >= :startDateForPDO)';
            }else if(edDate != null){
                plannedQuery1 += ' AND (Date__c <= :endDate OR To_Date__c <= :endDate)';
                plannedQuery2 += ' AND (Date__c <= :endDate OR To_Date__c <= :endDate)';
            }
                
            plannedLeaves = database.query(plannedQuery1);
            plannedLeaves1 = database.query(plannedQuery2);
            plannedLeaves.addAll(plannedLeaves1);
        }
        
        if(otherTaskTypes.contains('Holiday') && startDate != null && endDate != null){
            holidayRecords = HolidayService.getHolidayRecordsWithRecurrence(startDate,endDate);
        }
        
        List<Events__c> eventRecords = new List<Events__c>();
        
        if(taskType.size() != 0){
            eventRecords = database.query(eventQryStr);
        }
        
        // Currently Event Approval process only for Instructor
        List<EventDomain.EventCalendarInfo> pendingApprovalEvtList = new List<EventDomain.EventCalendarInfo>();
        if(communityName == 'instructor'){            
            pendingApprovalEvtList = EventApproval_Ctrl.getEventsForApproval(null);
        }
        
        String childEventRelParentIdsJSON = getChildEventRelParentIds(eventRecords);
        Set<Id> childEventRelParentIds = (Set<Id>) JSON.deserialize(childEventRelParentIdsJSON, Set<Id>.class);
        
        Map<Id,String> proIdStudentNames = new Map<Id,String>();
        
        if(String.isNotBlank(contactId) && communityName == 'student') {
            for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId AND RecordType.DeveloperName = :recordTypeName AND Project__c != null]){
                
                String studentName = ca.Candidate_Name__r.FirstName+' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.';
                
                if(!proIdStudentNames.containsKey(ca.Project__c)){
                    proIdStudentNames.put(ca.Project__c,studentName);
                }else {
                    String existingName = proIdStudentNames.get(ca.Project__c);
                    
                    proIdStudentNames.put(ca.Project__c,(existingName+', '+studentName));
                }
                
            }
        }else {

            for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Project__c IN :projectIds]){
                String studentName = '';
                
                studentName = (ca.Candidate_Name__r.FirstName == null ? '' : ca.Candidate_Name__r.FirstName);
                studentName += (ca.Candidate_Name__r.LastName != null ? ' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.' : '');
                
                if(!proIdStudentNames.containsKey(ca.Project__c)){
                    proIdStudentNames.put(ca.Project__c,studentName);
                }else {
                    String existingName = proIdStudentNames.get(ca.Project__c);
                    
                    proIdStudentNames.put(ca.Project__c,(existingName+', '+studentName));
                }
            }
        }
            
        List<EventDomain.EventCalendarInfo> eventWrapList = EventTranslator.eventCalendarInfo(eventRecords,holidayRecords,proIdStudentNames,planNedLeaves,startDate,endDate,childEventRelParentIds,new Map<Id,Date>());
        
        if(pendingApprovalEvtList.size() > 0){
            eventWrapList.addAll(pendingApprovalEvtList);
        }
        
        eventView.eventRecords = eventWrapList;
        eventView.endDate = endDate;
        eventView.stDate = startDate != null ? startDate : System.today();
        return JSON.serialize(eventView);
    }
    
    @AuraEnabled
    public static string getCommunityName(){
        return EventCalendarController.getCommunityPathPrefix();
    }
    
    @AuraEnabled
    public static String getPlannedRecords(String stDate , String edDate ,String projectId, String status, Boolean recordLimit){
        
        String contactId = EventCalendarController.getLoggedUserContactId();
        String communityName = EventCalendarController.getCommunityPathPrefix();
        String recordTypeName = '';
        Set<Id> projectIds = new Set<Id>();
        Set<Id> insRelatedStuIds = new Set<Id>();

        LeaveInfo plannedOff = new LeaveInfo();
        
        List<plannedLeaveInfo> plannedLeaveList = new List<plannedLeaveInfo>();
        Date startDate,endDate;
        
        if(String.isNotBlank(stDate)){
            startDate = Date.valueOf(stDate);
        }
        
        if(String.isNotBlank(edDate)){
            endDate = Date.valueOf(edDate);
        }
        
        if(communityName == 'instructor' || Test.isRunningTest()){
            recordTypeName = 'Instructor';
        }else if(communityName == 'student'){
            recordTypeName = 'Student';
        }else if(communityName == 'client'){
            recordTypeName =  'Client_Partner';
        }
        
        List<ListViewController.PicklistWrap> pickListValues = new List<ListViewController.PicklistWrap>();
        ListViewController.PicklistWrap pickListVal = new ListViewController.PicklistWrap();
        ListViewController.PicklistWrap pickListVal2 = new ListViewController.PicklistWrap();
        
        PickListVal.label = '--None--';
        pickListVal.value = '';
        pickListVal2.label = 'All';
        pickListVal2.value = 'All';
         
        pickListValues.add(pickListVal);
        pickListValues.add(pickListVal2);

        //Modified By Dhinesh - 19/03/2021 - W-006581 - Planned Days Off Message Specific for DODA Students - Added Account.Name
        //Get current Contact info
        List<Contact> conList = [SELECT Id,Name,RecordType.DeveloperName, Account.Name FROM Contact WHERE Id = :contactId];
        String insOffRTId;
        String studentOffRTId;
        String requestRTId;
        
        //Get current contact based planned off record type for new records creation
        for(RecordType rt : [SELECT Id,DeveloperName,SobjectType FROM RecordType 
                                    WHERE SobjectType = 'Planned_Days_Off__c' AND 
                                    DeveloperName IN ('Instructor_Planned_Days_Off','Student_Planned_Days_Off','Request')]){
            if(rt.DeveloperName == 'Instructor_Planned_Days_Off'){
                insOffRTId = rt.Id;
            }else if(rt.DeveloperName == 'Student_Planned_Days_Off'){
                studentOffRTId = rt.Id;
            }else {
                requestRTId = rt.Id;
            }
        }
        
        
        if(String.isNotBlank(contactId) && communityName != null) {
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Status__c,Project__c,Project__r.DLS_Ref__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName 
                                                FROM Contact_Assignments__c 
                                                    WHERE Candidate_Name__c = :contactId AND RecordType.DeveloperName = :recordTypeName AND Project__c != null]){
                if(ca.Project__c != null && (!recordLimit || ca.Status__c == 'Active')){ //Modified by Dhinesh - 4/3/2024 - W-007995 - Added Status filter to exclude ended CA Project PDO for Instructor Community 
                     projectIds.add(ca.Project__c);
                }
            }
        }
        
        system.debug('project id set'+projectIds);
        //system.debug('project id query'+[SELECT Id,Name,AcctSeed__Account__r.Name,DLS_Ref__c,Start_Date__c,End_Date__c, AcctSeed__Status__c,Project_Manager__c,Project_Manager__r.Name,Training_Location__c,Training_Location__r.Name FROM AcctSeed__Project__c WHERE Id IN : projectIds]);
        
        /*for(AcctSeed__Project__c proj : [SELECT Id,Name,AcctSeed__Account__r.Name,DLS_Ref__c,Start_Date__c,End_Date__c, AcctSeed__Status__c,Project_Manager__c,Project_Manager__r.Name,Training_Location__c,Training_Location__r.Name FROM AcctSeed__Project__c WHERE Id IN : projectIds] ){
            
            ListViewController.PicklistWrap pickListVal1 = new ListViewController.PicklistWrap();
                if(proj.DLS_Ref__c != null){
                    pickListVal1.label = proj.DLS_Ref__c;
                    pickListVal1.value = proj.id;
                    pickListValues.add(pickListVal1);
                }
        }    */
        
        Map<Id,String> projectRelatedCAStuNamesMap = new Map<Id,String>();
        String projQryStr = 'SELECT Id,Name,AcctSeed__Account__r.Name,DLS_Ref__c,';
        projQryStr += ' (SELECT Id,Candidate_Name__r.FirstName,Candidate_Name__r.LastName,Candidate_Name__r.Name ';
        projQryStr += 'FROM Contact_Assignments__r WHERE RecordType.DeveloperName = \'Student\' AND Status__c = \'Active\')'; 
        projQryStr += ' FROM AcctSeed__Project__c WHERE Id IN :projectIds AND AcctSeed__Status__c IN (\'Active\',\'Order\')';
        
        if(conList[0].RecordType.DeveloperName == 'Student' && conList[0].Account.Name == 'DODA'){
            projQryStr += ' AND (Project_Type__c = \'JMAS\' OR AcctSeed__Account__r.Name = \'NGA\')';
        }
        for(AcctSeed__Project__c proj : Database.query(projQryStr)){
            
            //get Active Students Related Projects
            for(Contact_Assignments__c ca : proj.Contact_Assignments__r){
            
                if(projectRelatedCAStuNamesMap.containsKey(proj.Id)){
                    projectRelatedCAStuNamesMap.put(proj.Id, projectRelatedCAStuNamesMap.get(proj.Id)+ca.Candidate_Name__r.FirstName+'.'+ca.Candidate_Name__r.LastName.subString(0,1)+'; ');
                }else{
                    projectRelatedCAStuNamesMap.put(proj.Id, proj.DLS_Ref__c+'/'+ca.Candidate_Name__r.FirstName+'.'+ca.Candidate_Name__r.LastName.subString(0,1)+'; ');
                }
                insRelatedStuIds.add(ca.Candidate_Name__c);
            }
            
            ListViewController.PicklistWrap pickListVal1 = new ListViewController.PicklistWrap();
            
            if(proj.DLS_Ref__c != null){
            
                pickListVal1.label = ((projectRelatedCAStuNamesMap.containsKey(proj.id)) ? projectRelatedCAStuNamesMap.get(proj.id) : proj.DLS_Ref__c+'/');
                pickListVal1.value = proj.id;
                pickListValues.add(pickListVal1);
            }
            
        } 
               
        plannedOff.projectValues = pickListValues.size() > 1 ? pickListValues : new List<ListViewController.PicklistWrap>();

        String squery = 'SELECT Id,name,Description__c, Parent_Planned_Day_Off__c , Leave_Type__c,Project__c,Project__r.DLS_Ref__c,RecordType.DeveloperName,Project__r.name ,Date__c, Type__c,Status__c,From_Date__c,To_Date__c FROM Planned_Days_Off__c WHERE Status__c != \'Delete\'';
                
        if(communityName != 'client'){
            squery += ' AND ( Contact__c = :contactId';
            //W-007861 - Add Student Planned Days Off to Instructors Home Page (Added by Siva Prasanth)
            
            if(communityName == 'instructor' && recordLimit){
                squery += ' OR Contact__c IN :insRelatedStuIds';
            }
            squery += ' )';
            
        }else if(projectId == null){
            squery += ' AND Project__c = :projectIds';
        }
        
        if(recordLimit){
        
            squery += ' AND (Date__c >= TODAY OR From_Date__c >= TODAY)';
            
            squery += ' AND RecordType.DeveloperName = \'Request\'';
        }
        
        if(stDate != null && edDate != null) {
            squery += ' AND ((Date__c >= :startDate AND Date__c <= :endDate) OR (From_Date__c >= :startDate AND To_Date__c <= :endDate))'; 
        }else if(stDate != null){
            squery += ' AND (Date__c >= :startDate OR From_Date__c >= :startDate)'; 
        }else if(edDate != null){
            squery += ' AND (Date__c <= :endDate OR To_Date__c <= :endDate)'; 
        }
                
        if(projectId != null){
            squery += ' AND Project__c = :projectId'; 
        }
        
        if(String.isNotBlank(status) && status != 'All'){
            squery += ' AND Status__c = \''+status+'\''; 
        }
        
        squery += ' ORDER BY Date__c ASC';
        
        if(recordLimit) {
            squery += ' LIMIT 5'; 
        }
        
        List<Planned_Days_Off__c> plannedDaysList = database.query(squery);
        
        system.debug('upcoming planned days list::::'+plannedDaysList);
        
        Set<Id> parentPlannedDaysOffIdSet = new Set<Id>();
        
        if(recordLimit) {
        
            for(Planned_Days_Off__c leaveInfo : plannedDaysList){
                parentPlannedDaysOffIdSet.add(leaveInfo.Id);
            }
            
            for(Planned_Days_Off__c days : [SELECT Id,name,Description__c, Parent_Planned_Day_Off__c ,Leave_Type__c,Project__c,Project__r.DLS_Ref__c,RecordType.DeveloperName,Project__r.name ,Date__c, Type__c,Status__c,From_Date__c,To_Date__c 
                                            FROM Planned_Days_Off__c 
                                                WHERE Parent_Planned_Day_Off__c IN :parentPlannedDaysOffIdSet]) {
             
                plannedDaysList.add(days);
                
            }
        }
        
        Map<Id, List<plannedLeaveInfo>> plannedDaysParentChildMap = new Map<Id, List<plannedLeaveInfo>>();
        
        for(Planned_Days_Off__c leaveInfo : plannedDaysList){
        
            plannedLeaveInfo leave = new plannedLeaveInfo();
            
            leave.name = leaveInfo.name;
            
            if(leaveInfo.date__c != null){
                leave.dateStr = ContactChildUpdateController.dateConversion(leaveInfo.date__c.format());
                leave.dateValue = leaveInfo.Date__c;
            }else if(leaveInfo.From_Date__c != null && leaveInfo.To_Date__c != null){
                leave.dateStr = ContactChildUpdateController.dateConversion(leaveInfo.From_Date__c.format()) +' - '+ContactChildUpdateController.dateConversion(leaveInfo.To_Date__c.format());
                leave.fromDate = leaveInfo.From_Date__c;
                leave.toDate =  leaveInfo.To_Date__c;
            }else if(leaveInfo.From_Date__c != null){
                leave.dateStr = ContactChildUpdateController.dateConversion(leaveInfo.From_Date__c.format());
                //leave.dateValue = leaveInfo.From_Date__c;
                leave.fromDate = leaveInfo.From_Date__c;
            }
            
            leave.description = leaveInfo.Description__c;
            leave.leaveType = leaveInfo.Leave_Type__c;
            leave.type = leaveInfo.Type__c;
            leave.status = leaveInfo.Status__c;
            leave.projectId = leaveInfo.Project__c;
            leave.projectName = leaveInfo.Project__r.name;
            leave.id = leaveInfo.Id; 
            leave.requestOffRT = leaveInfo.RecordType.DeveloperName;
            leave.parentPlannedDaysOff = leaveInfo.Parent_Planned_Day_Off__c;
            
            if(communityName == 'instructor' && leave.type == 'Student'){
                leave.showEditDelIcon = false;
            }else{
                leave.showEditDelIcon = true;
            }
            
            system.debug('::::::leaveInfo::::'+leaveInfo.RecordType.DeveloperName);
            
            if(communityName == 'client'){
                plannedLeaveList.add(leave);
            }else{
                if(leaveInfo.RecordType.DeveloperName == 'Request') {
                    plannedLeaveList.add(leave);
                }else {
                    if(String.isNotBlank(leaveInfo.Parent_Planned_Day_Off__c)) {
                        if(!plannedDaysParentChildMap.containsKey(leaveInfo.Parent_Planned_Day_Off__c)) {
                            plannedDaysParentChildMap.put(leaveInfo.Parent_Planned_Day_Off__c, new List<plannedLeaveInfo>());
                        }
                        plannedDaysParentChildMap.get(leaveInfo.Parent_Planned_Day_Off__c).add(leave);
                    }
                    
                }
            }

        }
        
        plannedOff.leaveInfoList = plannedLeaveList;
        
        if(conList != null && conList.size() > 0) {
            plannedOff.contactInfo = conList[0];
        }
        
        plannedOff.plannedDaysOffMap = plannedDaysParentChildMap;
        //plannedOff.instructorDaysOffRTId = insOffRTId;
        //plannedOff.studentDaysOffRTId = studentOffRTId;
        plannedOff.requestOffRTId = requestRTId;
        
        List<ListViewController.PicklistWrap> pdoStatus = ListViewController.getPickListValues('Planned_Days_Off__c','Status__c');
        
        plannedOff.statusValues = new List<ListViewController.PicklistWrap>();
        
        ListViewController.PicklistWrap statusVal = new ListViewController.PicklistWrap();
        statusVal.label = 'All';
        statusVal.value = 'All';
        
        plannedOff.statusValues.add(statusVal);
        plannedOff.statusValues.addAll(pdoStatus);
        plannedOff.communityName = communityName;
        
        return JSON.serialize(plannedOff);
    }
    
    //Method to insert new Planned Days Off records from Community
    @AuraEnabled
    public static String createNewPlannedOffRecords(String newPlannedOffJson, String status, Boolean allowParentPlanToUpdate, String parentPlannedDayId){
        
        try {
            List<Planned_Days_Off__c> requestList = (List<Planned_Days_Off__c>) System.JSON.deserialize(newPlannedOffJson, List<Planned_Days_Off__c>.class);
            
            if(status == 'Deleted' && allowParentPlanToUpdate) {
                Planned_Days_Off__c parentPlannedDay = new Planned_Days_Off__c();
                parentPlannedDay.Id = parentPlannedDayId;
                parentPlannedDay.Status__c = 'Delete';
                
                requestList.add(parentPlannedDay);
            }
            
            if(requestList.size() > 0){
                upsert requestList;
            }
            
            return 'SUCCESS';
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getCommunityNameWithEventsInfo(String communityName,String newYorkDateNow){
        
        String contactId = EventCalendarController.getLoggedUserContactId(); // Get Currently logged user's contact Id
        List<Events__c> eventLst = new List<Events__c>();
        List<EventDomain.EventCalendarInfo> eventRecordInfo = new List<EventDomain.EventCalendarInfo>();
        List<EventDomain.EventCalendarInfo> pendingApprovalEvtList = new List<EventDomain.EventCalendarInfo>();
        Set<Id> projectIds = new  Set<Id>();
        Map<Id,String> proIdStudentNames = new Map<Id,String>();
        
        String evtQryString = 'SELECT Id,Name,Date__c,Room__c,Timezone__c,Day_of_Week__c,Schedule__r.Project_Task__r.Name,Instructor__r.Name,Status__c,Duration__c,Room__r.Name,Project__r.DLS_Ref__c,';
        evtQryString += 'Start_Time__c,End_Time__c,Start_Date_Time__c,Parent_Event__r.Status__c,End_Date_Time__c,Reject_Comment__c,Project_Task__c,Project_Task__r.Name,Project_Task__r.Project_Task_Type__c, Schedule__r.Name,Schedule__r.Project_Task__r.Project_Task_Type__c,Instructor__c,Parent_Event__c,Schedule__c,Approval_Status__c, Schedule__r.Meeting_URL__c,Project__r.Project_Manager__c, Project__r.Project_Manager__r.Name, Project__r.AcctSeed__Account__c, Project__r.AcctSeed__Account__r.Name, Meeting_URL__c, Project__r.RecordType.DeveloperName, Project__r.Project_Type__c, Instructor__r.FirstName, Instructor__r.LastName, Schedule__r.Create_Zoom_Meetings__c FROM Events__c ';
        
        if(communityName == 'instructor' || Test.isRunningTest()){
            evtQryString += ' WHERE Status__c IN (\'Scheduled\',\'Draft\') AND Instructor__c =  \''+contactId+'\' AND (Project__r.RecordType.DeveloperName NOT IN (\'Language_Training_Projects\',\'DODA_Projects\',\'DLI_W_LT_Projects\',\'FSI_Projects\') OR (Project_Task__r.Project_Task_Type__c != \'Preparation time\' AND Schedule__r.Project_Task__r.Project_Task_Type__c != \'Preparation time\')) AND Date__c >= '+newYorkDateNow+' Order BY Date__c ASC, Start_Time__c ASC LIMIT 5';
        }else{            
            String caRecordType = communityName == 'student' ? 'Student' :  'Client_Partner';            
            
            for(Contact_Assignments__c  ca : [SELECT Id,Project__c,Status__c FROM Contact_Assignments__c 
                                                                     WHERE Status__c IN ('Active','Planned') AND Candidate_Name__c =: contactId 
                                                                     AND RecordType.DeveloperName = :caRecordType AND Project__c != null])  {
                    projectIds.add(ca.Project__c);
            }
            evtQryString += ' WHERE Status__c IN (\'Scheduled\',\'Draft\') AND Project__c IN :projectIds  AND (Project_Task__r.Project_Task_Type__c != \'Preparation time\' AND Schedule__r.Project_Task__r.Project_Task_Type__c != \'Preparation time\') AND Date__c >= '+newYorkDateNow+' Order BY  Date__c ASC, Start_Time__c ASC LIMIT 5 ';
        }
        
        eventLst = database.query(evtQryString);
        
        String childEventRelParentIdsJSON = getChildEventRelParentIds(eventLst);
        Set<Id> childEventRelParentIds = (Set<Id>) JSON.deserialize(childEventRelParentIdsJSON, Set<Id>.class);
        
        if(eventLst.size() > 0){
            if(communityName == 'instructor' || communityName == 'client' || Test.isRunningTest()){
                
                for(Events__c event : eventLst){
                    projectIds.add(event.Project__c);
                }
                
                if(projectIds.size() > 0){
                    for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName FROM Contact_Assignments__c 
                                                     WHERE Project__c IN :projectIds AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active']){
                        
                        String studentName = ca.Candidate_Name__r.FirstName+' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.';
                        if(!proIdStudentNames.containsKey(ca.Project__c)){
                            proIdStudentNames.put(ca.Project__c,studentName);
                        }else {
                            String existingName = proIdStudentNames.get(ca.Project__c);
                            proIdStudentNames.put(ca.Project__c,(existingName+', '+studentName));
                        }
                    } 
                }
            }
            
            eventRecordInfo = EventTranslator.eventCalendarInfo(eventLst,new List<Holiday>(),proIdStudentNames,new List<Planned_Days_Off__c>(),null,null,childEventRelParentIds,new Map<Id,Date>());
        }     
        return JSON.serialize(eventRecordInfo);
    }
    @AuraEnabled 
    public static String getChildEventRelParentIds(List<Events__c> eventList){
        Set<Id> evtIds = new Set<Id>();
        Set<Id> childEventRelParentIds = new Set<Id>();
        
        if(eventList.size() > 0){
            for(Events__c evt : eventList){
                evtIds.add(evt.Id);
            }
            
            if(evtIds.size() > 0){
                for(Events__c event : [Select Id,Parent_Event__c FROM Events__c WHERE Parent_Event__c IN :evtIds]){
                    childEventRelParentIds.add(event.Parent_Event__c);
                }
            }
        }   
        return JSON.serialize(childEventRelParentIds);
    }
    
    //W-003064 - Add ability for students and instructors to edit and delete Planned Days Off records in the community
    @AuraEnabled
    public static String updatePDOStatusAsDelete(String plannedOffJson) {
    
        List<Planned_Days_Off__c> pdoRec = (List<Planned_Days_Off__c>) System.JSON.deserialize(plannedOffJson, List<Planned_Days_Off__c>.class);
        System.debug('pdoRec::'+pdoRec);
        
        try{
            if(pdoRec.size() > 0){
                update pdoRec;
            }
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    //W-006147 - Modified By Dhinesh - 15/12/2020 - Adjust Planned Days Off request time requirement from 2 business days to 1 business day / 24 hours based on the Scheduled Event
    @AuraEnabled
    public static Integer getPDODaysDifference(Date pdoSTDt){
        
        DateTime pdoSTDtTime;
        String weekOfDay = '';
        Long differenceDate;
        
        String contactId = EventCalendarController.getLoggedUserContactId();
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'Community'];
        Set<Id> projectIds = new Set<Id>();
        Map<String, EventDomain.EventCalendarInfo> projectRefWithNewReqEvent = new Map<String, EventDomain.EventCalendarInfo>();
        
        for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__c != null]){
            projectIds.add(ca.Project__c);            
        }
         
        for(Events__c eve : [SELECT Id, Start_Date_Time__c FROM Events__c WHERE Project__c IN :projectIds AND Date__c = :pdoSTDt AND Status__c = 'Scheduled' AND Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time']){
            System.debug(pdoSTDtTime+'::>'+eve.Id);
            pdoSTDtTime = (pdoSTDtTime == null || eve.Start_Date_Time__c  < pdoSTDtTime) ? eve.Start_Date_Time__c : pdoSTDtTime;            
        }
        
        if(pdoSTDtTime == null){
            pdoSTDtTime = pdoSTDt;
        }
        
        //Modified By Siva Prasanth - 07/07/2023 -  To allow creating PDO (Planned Day Off) records on Saturdays only if events exist on that specific Saturday,
        if(pdoSTDtTime != null){
            weekOfDay = pdoSTDtTime.format('EEE');
        }
                
        System.debug('weekOfDay::'+weekOfDay);
        if(weekOfDay == 'Sat'){
            differenceDate = (pdoSTDtTime.getTime() - System.now().getTime());
        }else{
            differenceDate = BusinessHours.diff(bh.id,system.now(),pdoSTDtTime);
        }

        System.debug(differenceDate);
        Long mins = differenceDate / 60000;
        Long hours = mins / 60;
        Long Days = (hours /24);
        
        return Integer.valueOf(Days);
    }
    
    //Modified By Dhinesh - W-006013 - Zoom Integration - to move the events to zoom online from instructor community
    @AuraEnabled
    public static string moveEventToOnline(String eventStr){
        EventDomain.EventCalendarInfo eventToMoveOnline = (EventDomain.EventCalendarInfo) JSON.deserialize(eventStr, EventDomain.EventCalendarInfo.class);        
        
        Id onlineRoomId = ZoomUtil.getOnlineRoomId();
        TimezoneUtilClass utilCls = new TimezoneUtilClass();  
        Boolean isCreateMeeting = false;
        AcctSeed__Project__c proj = [SELECT Id, Number_of_Students_Active__c FROM AcctSeed__Project__c WHERE Id = :eventToMoveOnline.projectId];
        Contact con = [SELECT Id, Zoom_User_Status__c, Virtual_Conference_License__c, Zoom_Id__c FROM Contact WHERE Id = :eventToMoveOnline.instructorId];
        Boolean isStartWithin24Hrs = utilCls.getUserTimeZoneDateTime(System.now().addDays(1)) > eventToMoveOnline.startDateTime;
        Boolean isRequiredProLisence =  isStartWithin24Hrs && /*proj.Number_of_Students_Active__c > 1 &&*/ con.Virtual_Conference_License__c != 'Zoom - Pro';
        Boolean isUpdateContact = false;
        ZoomDomain.userReponseWrap resWrap = new ZoomDomain.userReponseWrap();
            
        if(con.Zoom_Id__c != null && con.Zoom_User_Status__c == 'Active'){
            if(isRequiredProLisence){
                resWrap = ZoomUtil.getUserDetailsAndUpdateDetails(con.Zoom_Id__c, JSON.serialize(new ZoomDomain.zoomUser('2'), true), String.valueOf(con.Id), false, false);
                con = resWrap.con;
                
                isUpdateContact = true;
            }
            isCreateMeeting = true;
        }else if(con.Zoom_User_Status__c == 'Pending'){
            
            resWrap.message = 'Please check your email and use the link provided to set up your Zoom User Account. Once you have set up your Zoom User Account, please come back and click “Move Online” again.';
        }else if(con.Zoom_Id__c == null){
                        
            List<User> users = [SELECT Id, FirstName, LastName, Email, ContactId, Contact.Zoom_ID__c, Contact.Virtual_Conference_License__c FROM User WHERE ContactId = :con.Id AND Contact.Active_DLS_Online_User__c = true];                
            resWrap = ZoomUtil.getUserDetailsAndUpdateDetails(users[0].Email, JSON.serialize(new ZoomDomain.zoomUser(users[0].FirstName, users[0].LastName, users[0].Email, isRequiredProLisence ? '2' : '1')), String.valueOf(users[0].ContactId), true, false);
            con = resWrap.con;
            
            if(!resWrap.isZoomUserAvailable || (resWrap.con != null && resWrap.con.Zoom_User_Status__c != 'Active')){
                
                 resWrap.message = 'Please check your email and use the link provided to set up your Zoom User Account. Once you have set up your Zoom User Account, please come back and click “Move Online” again.';
            }else if(resWrap.con != null && resWrap.con.Zoom_User_Status__c == 'Active'){
                isCreateMeeting = true;                
            }
            
            isUpdateContact = resWrap.con != null;
        }
        
        if(isCreateMeeting){
            
            ZoomDomain.zoomMeeting zoomMeeting = new ZoomDomain.zoomMeeting();
            ZoomMeeting.topic = eventToMoveOnline.project;
            zoomMeeting.duration = Integer.valueOf( Decimal.valueOf(eventToMoveOnline.duration) * 60 );
            zoomMeeting.timezone = eventToMoveOnline.timezone;
            zoomMeeting.start_time = eventToMoveOnline.startDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss', eventToMoveOnline.timezone);
            zoomMeeting.type = 2;
            zoomMeeting.schedule_for = con.Zoom_Id__c;
            zoomMeeting.password = String.valueOf(Math.round((Math.random() * (900000) + 100000)));
            zoomMeeting.settings = new ZoomDomain.zoomMeetingSettings();
            String resultStr = ZoomUtil.createMeeting(zoomMeeting.schedule_for, JSON.serialize(zoomMeeting));
            System.debug('resultStr::>'+resultStr);
            
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resultStr);
            
            Events__c eventToUpdate = new Events__c();
            eventToUpdate.Id = eventToMoveOnline.eventId;
            eventToUpdate.Meeting_URL__c = String.valueOf(result.get('join_url'))+'?pwd='+String.valueOf(result.get('encrypted_password'));
            eventToUpdate.Room__c = onlineRoomId;
            eventToUpdate.Meeting_Id__c = String.valueOf(result.get('id'));
            eventToUpdate.Is_Meeting_Created__c = true;
            eventToUpdate.Is_Moved_Online_via_Community__c = true;
    
            update eventToUpdate;

            eventToMoveOnline.roomId = onlineRoomId;
            eventToMoveOnline.room = 'Zoom - Online';
            eventToMoveOnline.meetingUrl = String.valueOf(result.get('join_url'));
            eventToMoveOnline.allowToJoinMeeting = isStartWithin24Hrs;
        }
        
        if(isUpdateContact && con != null){
            update con;
        }
        
        resWrap.event = eventToMoveOnline;       
        return JSON.serialize(resWrap);
    }
    
    //Added By Jain S. (Aug 04, 2020)
    @AuraEnabled
    public static List<EventDomain.PendingEventsInfo> getEventsForApproval(){
        return EventApproval_Ctrl.getPendingEventsForApproval(null);
    }
    
    //Modified By Dhinesh - W-006142 - Request an Event feature for Student Community - to get the initial values for request new events
    @AuraEnabled
    public static Map<String, EventDomain.EventCalendarInfo> getDetailsForRequestEvent(){
        return EventCalendarController.getDetailsForRequestEvent();
    }
        
    @AuraEnabled
    public static List<Planned_Days_Off__c> getPlannedDaysOffInfo(Id projectId){
        
        String contactId = EventCalendarController.getLoggedUserContactId(); // Get Currently logged user's contact Id
        String communityName = EventCalendarController.getCommunityPathPrefix();
        List<Contact_Assignments__c> contactAssignments = new List<Contact_Assignments__c>();
        if(communityName == 'instructor'){
			List<Contact_Assignments__c> instructorCAs = [SELECT Project__c, Opportunity_Name__c, Candidate_Name__c 
                                                         FROM Contact_Assignments__c
                                                         WHERE Project__c = :projectId 
                                                         AND Status__c = 'Active' 
                                                         AND (RecordType.DeveloperName = 'Instructor' AND Candidate_Name__c = :contactId)];
            if(instructorCAs.size() > 0){
                contactAssignments = [SELECT Project__c, Opportunity_Name__c, Candidate_Name__c 
                                      FROM Contact_Assignments__c
                                      WHERE Project__c = :projectId 
                                      AND Status__c = 'Active' 
                                      AND RecordType.DeveloperName = 'Student'];
                contactAssignments.addAll(instructorCAs);
            }
        }else{
            Set<String> contactAssignmentRecordType = new Set<String>{'Student','Instructor'};
            contactAssignments = [SELECT Project__c, Opportunity_Name__c, Candidate_Name__c 
                                  FROM Contact_Assignments__c
                                  WHERE Project__c = :projectId 
                                  AND Status__c = 'Active' 
                                  AND RecordType.DeveloperName IN :contactAssignmentRecordType];
        }
       
        Set<Id> contactIdSet = new Set<Id>();
        for(Contact_Assignments__c ca : contactAssignments){
            contactIdSet.add(ca.Candidate_Name__c);
        }
        
        if(contactIdSet.size() > 0){
            return [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,From_Date__c,To_Date__c,
                Type__c,Leave_Type__c,Status__c,Contact__c,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,RecordTypeId,RecordType.DeveloperName
                FROM Planned_Days_Off__c 
                WHERE (Contact__c IN :contactIdSet OR Project__c = :projectId) AND RecordType.DeveloperName != 'Request' ORDER BY  Date__c DESC,From_Date__c DESC];
        }else{
            return new List<Planned_Days_Off__c>();
        }
        
        
    }
    
    public class EventInfo {
        
        @AuraEnabled public List<EventDomain.EventCalendarInfo> eventRecords;
        @AuraEnabled public List<ListViewController.PicklistWrap> projectValues;
        @AuraEnabled public Date stDate;
        @AuraEnabled public Date endDate;
    }
    public class plannedLeaveInfo {
        
        @AuraEnabled public string dateStr;
        @AuraEnabled public Date fromDate;
        @AuraEnabled public Date toDate;
        @AuraEnabled public Date dateValue;
        @AuraEnabled public string name;
        @AuraEnabled public string description;
        @AuraEnabled public string leaveType;
        @AuraEnabled public string type;
        @AuraEnabled public string status;
        @AuraEnabled public string projectName;
        @AuraEnabled public string projectId;
        @AuraEnabled public string id;
        @AuraEnabled public string requestOffRT;
        @AuraEnabled public string parentPlannedDaysOff;  
        @AuraEnabled public boolean showEditDelIcon;  
    }
    
    public class LeaveInfo {
        @AuraEnabled public List<plannedLeaveInfo> leaveInfoList;
        @AuraEnabled public List<ListViewController.PicklistWrap> projectValues;
        @AuraEnabled public Contact contactInfo;
        @AuraEnabled public Map<Id, List<plannedLeaveInfo>> plannedDaysOffMap;
        //@AuraEnabled public String instructorDaysOffRTId;
        //@AuraEnabled public String studentDaysOffRTId;
        @AuraEnabled public String requestOffRTId;
        @AuraEnabled public List<ListViewController.PicklistWrap> statusValues;
        @AuraEnabled public string communityName;
    }   
}