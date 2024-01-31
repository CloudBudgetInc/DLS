/**
 * @description       : 
 * @author            : Vasanthram
 * @group             : 
 * @last modified on  : 11-01-2023
 * @last modified by  : Vasanthram
**/
// To handle all the Time card day related actions in this class
// Created by NS on OCT 4 2018
public class TimeCardDayTrigger_Handler {
    
    public static Set<Date> holidayDates;
    public static Map<Id,Set<Date>> pdosByProjectId;
    
    //Added method to link the Event record with the following conditions
    //When time entry is created (!= Unposted), identify and associate the Event record (!= Canceled, Completed) and set the status to completed
    //When time entry is "Unposted", remove the value in Event record and set the event status to "Completed without TCD"
    public static void updateEventBasedonTCD(Set<Id> tcdIds,Set<Id> lineIds){
        
        system.debug(':::::::::::::enter::updateEventBasedonTCD::::::'+tcdIds);
        
        Set<Id> taskIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();
        Set<Id> instructorIds = new Set<Id>();
        Set<Date> tcdDates = new Set<Date>();
        Map<Date,List<AcctSeed__Time_Card_Day__c>> dateDayRecMap = new Map<Date,List<AcctSeed__Time_Card_Day__c>>();
        Map<Id,String> tclIdParentString = new Map<Id,String>();
        Map<Id,Id> tclIdInstructorId = new Map<Id,Id>();
        
        List<Events__c> eventsToUpdate = new List<Events__c>();
        
        
        for(AcctSeed__Time_Card_Day__c tcd : [SELECT Id,Name,Total_Hours_Before_Approved__c,AcctSeed__Date__c,Status__c,AcctSeed__Time_Card_Line__c, Project_Task_Type__c, Start_Time1__c, Start_Time2__c, End_Time1__c, End_Time2__c 
                                                FROM AcctSeed__Time_Card_Day__c 
                                                WHERE Id IN : tcdIds]){
            
            if(!dateDayRecMap.containsKey(tcd.AcctSeed__Date__c)){
                dateDayRecMap.put(tcd.AcctSeed__Date__c,new List<AcctSeed__Time_Card_Day__c>{tcd});
            }else {
                dateDayRecMap.get(tcd.AcctSeed__Date__c).add(tcd);
            }
       }
        
        //Qry TCL for Project, Task & Instrcutor informations
        for(AcctSeed__Time_Card_Line__c tcl : [SELECT Id,Name,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Project__c,AcctSeed__Project_Task__c 
                                            FROM AcctSeed__Time_Card_Line__c
                                            WHERE Id IN :lineIds]){
            taskIds.add(tcl.AcctSeed__Project_Task__c);
            projectIds.add(tcl.AcctSeed__Project__c);
            instructorIds.add(tcl.AcctSeed__Time_Card__r.Intructor__c);
            
            if(!tclIdParentString.containsKey(tcl.Id)){
                tclIdParentString.put(tcl.Id,tcl.AcctSeed__Project__c+'~'+tcl.AcctSeed__Project_Task__c);
            }
            
            if(!tclIdInstructorId.containsKey(tcl.AcctSeed__Time_Card__r.Intructor__c)){
                tclIdInstructorId.put(tcl.Id,tcl.AcctSeed__Time_Card__r.Intructor__c);
            }
        }
        
        system.debug('::::::::::dateDayRecMap:::::::'+dateDayRecMap);
        system.debug('::::::::::taskIds:::::::'+taskIds);
        system.debug('::::::::::projectIds:::::::'+projectIds);
        system.debug('::::::::::instructorIds:::::::'+instructorIds);
        system.debug('::::::tclIdParentString:::::'+tclIdParentString);
        system.debug('::::::tclIdInstructorId:::::::::::'+tclIdInstructorId);
        
        Set<Id> eventIdsSet = new Set<Id>();
        
        
        //Qry the Event records with all conditions
        for(Events__c eve : [SELECT Id,Name,Date__c,Duration__c,Instructor__c,Project__c,Room__c,Schedule__c,Status__c,Time_Card_Day__c,Schedule__r.Project_Task__c, Start_Time__c, End_Time__c, Project_Task__c
                                FROM Events__c
                                WHERE Date__c IN :dateDayRecMap.keySet() AND Project__c IN :projectIds AND Instructor__c IN :instructorIds
                                    AND ((Schedule__r.Project_Task__c IN :taskIds AND Schedule__r.Status__c = 'Active') OR (Project_Task__c IN :taskIds))]){
            
            
            if(eve.Time_Card_Day__c == null && eve.Status__c != 'Canceled' && eve.Status__c != 'Completed'){
                
                if(dateDayRecMap.containsKey(eve.Date__c)){
                    
                    for(AcctSeed__Time_Card_Day__c day : dateDayRecMap.get(eve.Date__c)){
                    
                        if(day.Status__c != 'Unposted' && tclIdInstructorId.containsKey(day.AcctSeed__Time_Card_Line__c) 
                            && eve.Instructor__c == tclIdInstructorId.get(day.AcctSeed__Time_Card_Line__c) 
                            && tclIdParentString.containsKey(day.AcctSeed__Time_Card_Line__c)){
                            
                            String proId = tclIdParentString.get(day.AcctSeed__Time_Card_Line__c).split('~')[0];
                            String taskId = tclIdParentString.get(day.AcctSeed__Time_Card_Line__c).split('~')[1];
                            
                            //If the TCD hrs is 0 then, no need to map with event. LTS will manually update from approval page
                            //Added by NS on Sep 20 2019 - Work Item No:W-002712
                            if(eve.Project__c == proId && (eve.Project_Task__c == taskId || eve.Schedule__r.Project_Task__c == taskId) && day.Total_Hours_Before_Approved__c != 0){
                                
                                eve.Time_Card_Day__c = day.Id;
                                eve.Status__c = 'Completed';
                                
                                //Commented by NS on July 25 2019
                                //Because we are not updating the Events time & duration based on TCD
                                /*if(day.Project_Task_Type__c != 'Preparation time'){
                                
                                    if(day.Start_Time1__c != NULL && day.End_Time1__c != NULL){
                                    
                                        eve.Start_Time__c = day.Start_Time1__c;
                                        eve.End_Time__c = day.End_Time1__c;
                                        eve.Duration__c = day.Total_Hours_Before_Approved__c;
                                    }
                                }else if(day.Project_Task_Type__c == 'Preparation time'){
                                    EventHandler eveHan = new EventHandler();
                                    
                                    if(eve.Start_Time__c != NULL && eve.End_Time__c != NULL){
                                    
                                        if(eve.Start_Time__c.contains(' AM') || eve.End_Time__c.contains(' AM')){
                                        
                                            if(day.Start_Time1__c != NULL && day.End_Time1__c != NULL){
                                            
                                                eve.Start_Time__c = day.Start_Time1__c;
                                                eve.End_Time__c = day.End_Time1__c;
                                                
                                                Integer stMins = eveHan.convertToMinutes(eve.Start_Time__c);
                                                Integer etMins = eveHan.convertToMinutes(eve.End_Time__c);
                                                System.debug('stMins ========'+stMins +'etMins ============='+etMins );
                                                
                                                eve.Duration__c = findDuration(stMins, etMins);
                                            }
                                        } else if(eve.Start_Time__c.contains(' PM') && eve.End_Time__c.contains(' PM')){
                                        
                                            if(day.Start_Time2__c != NULL && day.End_Time2__c != NULL){
                                            
                                                eve.Start_Time__c = day.Start_Time2__c;
                                                eve.End_Time__c = day.End_Time2__c;
                                                
                                                Integer stMins = eveHan.convertToMinutes(eve.Start_Time__c);
                                                Integer etMins = eveHan.convertToMinutes(eve.End_Time__c);
                                                System.debug('stMins ========'+stMins +'etMins ============='+etMins );
                                                
                                                eve.Duration__c = findDuration(stMins, etMins);
                                            }
                                        }
                                    }
                                }*/
                                eventsToUpdate.add(eve);
                                break;
                            }
                        }
                    }
                }
           }else if(eve.Time_Card_Day__c != null && eve.Status__c == 'Completed'){
               System.debug('UPDATED========');
               if(dateDayRecMap.containsKey(eve.Date__c)){
                    
                    for(AcctSeed__Time_Card_Day__c day : dateDayRecMap.get(eve.Date__c)){
                    
                        if(day.Status__c == 'Unposted' && tclIdInstructorId.containsKey(day.AcctSeed__Time_Card_Line__c) 
                            && eve.Instructor__c == tclIdInstructorId.get(day.AcctSeed__Time_Card_Line__c) 
                            && tclIdParentString.containsKey(day.AcctSeed__Time_Card_Line__c)){
                            
                            String proId = tclIdParentString.get(day.AcctSeed__Time_Card_Line__c).split('~')[0];
                            String taskId = tclIdParentString.get(day.AcctSeed__Time_Card_Line__c).split('~')[1];
                            
                            if(eve.Project__c == proId && eve.Schedule__r.Project_Task__c == taskId){
                                
                                eve.Time_Card_Day__c = null;
                                eve.Status__c = 'Scheduled';
                                
                                eventsToUpdate.add(eve);
                                break;
                            }
                       }
                   }
               }
           }
        }
        
        system.debug(':::::::::eventsToUpdate:::::::::'+eventsToUpdate);
        
        if(eventsToUpdate.size() > 0){
            update eventsToUpdate;
        }
    }
    
    public static Decimal findDuration(Integer stMins, Integer etMins){
    
        Decimal durationInMins = 0;
        Decimal durationInHrs = 0;
        
        if(stMins != NULL && etMins != NULL){
        
            durationInMins= etMins - stMins;
            System.debug('durationInMins ========='+durationInMins );
            
            durationInHrs = durationInMins / 60;
            System.debug('durationInHrs ================'+durationInHrs );
            
            
        }
        return durationInHrs;
    }
    
    //Added by NS on Apr 17 2019
    //Added the Snapshot records creation logic from trigger to handler. Becuase trigger get overloaded
    // Added Logic with Instructor Time Entry & Student approval related different notes formation
    public void notesFormationBasedonTCD(List<AcctSeed__Time_Card_Day__c> newRecords,Map<Id,AcctSeed__Time_Card_Day__c> oldMap) {
        
        system.debug('::::::::::::isGroupAction:::::::::::'+DLS_Staff_Time_Entry_Ctrl.isGroupAction);
            
        Boolean isGroupAction;
        String groupActionType;
        
        isGroupAction = DLS_Staff_Time_Entry_Ctrl.isGroupAction != null?DLS_Staff_Time_Entry_Ctrl.isGroupAction:false;
        groupActionType = DLS_Staff_Time_Entry_Ctrl.groupActionType;
        
        system.debug(':::::isGroupAction:::'+isGroupAction);
        system.debug(':::::groupActionType:::'+groupActionType);
        
        if(!isGroupAction && groupActionType == null) {
            isGroupAction = supervisorTimeApproval_Ctrl.isGroupAction != null?supervisorTimeApproval_Ctrl.isGroupAction:false;
            groupActionType = supervisorTimeApproval_Ctrl.groupActionType;
            
            system.debug(':::::isGroupAction:::'+isGroupAction);
            system.debug(':::::groupActionType:::'+groupActionType);
        }
        
        // groupAction is done on Admin time entry page
        
        if(!isGroupAction && groupActionType == null){
            isGroupAction = TimeKeeping_Admin_Controller.isGroupAction != null?TimeKeeping_Admin_Controller.isGroupAction:false;
            groupActionType = TimeKeeping_Admin_Controller.groupActionType;
            
            system.debug(':::::isGroupAction:Admin::timeentry::'+isGroupAction);
            system.debug(':::::groupActionType:Admin::timeentry::'+groupActionType);
        }
        
        // groupAction is done on Mobile Staff Time Entry Page
        if(!isGroupAction && groupActionType == null){
            isGroupAction = Staff_Daily_Timesheet_Ctrl.isGroupAction != null?Staff_Daily_Timesheet_Ctrl.isGroupAction:false;
            groupActionType = Staff_Daily_Timesheet_Ctrl.groupActionType;
            
            system.debug(':::::isGroupAction:daily::mobile:entry:'+isGroupAction);
            system.debug(':::::groupActionType:daily::mobile:entry::'+groupActionType);
        }
        
        // groupAction done on Instructor Time entry Page - InstructorTimeEntry component - Community 
        if(!isGroupAction && groupActionType == null){
            isGroupAction = InstructorTimeEntry_Controller.isGroupAction != null ? InstructorTimeEntry_Controller.isGroupAction:false;
            groupActionType = InstructorTimeEntry_Controller.groupActionType;
            
            system.debug(':::::isGroupAction:instructor::timeentry::'+isGroupAction);
            system.debug(':::::groupActionType:instructor::timeentry::'+groupActionType);
        }
        
        // groupAction done on Event Reconciliation Page - EventReconciliation component - Intenrnal
         if(!isGroupAction && groupActionType == null){
            isGroupAction = EventReconciliationController.isGroupAction != null ? EventReconciliationController.isGroupAction:false;
            groupActionType = EventReconciliationController.groupActionType;
            
            system.debug(':::::isGroupAction:event:reconciliation:'+isGroupAction);
            system.debug(':::::groupActionType:event:reconciliation::'+groupActionType);
        }
        
        // groupAction done on Instructor Time Review & Submit Page - InstructorTimeSubmitCmp- Community 
        // Added by August 1 2019
        if(!isGroupAction && groupActionType == null){
            isGroupAction = InstructorTimeSubmitCtrl.isGroupAction != null ? InstructorTimeSubmitCtrl.isGroupAction:false;
            groupActionType = InstructorTimeSubmitCtrl.groupActionType;
            
            system.debug(':::::isGroupAction:instructor::review::&:::::Submit:::'+isGroupAction);
            system.debug(':::::groupActionType:instructor::review::&:::::Submit::::'+groupActionType);
        }

         if(!isGroupAction && groupActionType == null){
            isGroupAction = StaffTimeEntryController.isGroupAction != null ? StaffTimeEntryController.isGroupAction:false;
            groupActionType = StaffTimeEntryController.groupActionType;
            
            system.debug(':::::isGroupAction:instructor::review::&:::::Submit:::'+isGroupAction);
            system.debug(':::::groupActionType:instructor::review::&:::::Submit::::'+groupActionType);
        }
        
        // groupAction done on Admin Time Entry Instructor View - AdminTimeEntry_InstructorCmp- Internal 
        // Added by NS August 1 2019
        if(!isGroupAction && groupActionType == null) {
            isGroupAction = AdminTimeEntry_InstructorCtrl.isGroupAction != null ? AdminTimeEntry_InstructorCtrl.isGroupAction:false;
            groupActionType = AdminTimeEntry_InstructorCtrl.groupActionType;
            
            system.debug(':::::isGroupAction:::admin::;time::::entry::instructor::'+isGroupAction);
            system.debug(':::::groupActionType:::::admin::;time::::entry::instructor::::'+groupActionType);
        }
        
        Map<Id,String> tcdIdNoteType = new Map<Id,String>();
        
        //Get Instructor Time Entry Ctrl Static Map
        if(tcdIdNoteType.size() == 0) {
            tcdIdNoteType = InstructorTimeEntry_Controller.tcdIdNoteType;
        }
        
        //Get the static map value from Student Approval Controller
        if(tcdIdNoteType.size() == 0) {
            tcdIdNoteType = StudentApproval_Controller.tcdIdNoteType;
        }
        
        //Get the static map value from Event Reconciliation Controller
        if(tcdIdNoteType.size() == 0) {
            tcdIdNoteType = EventReconciliationController.tcdIdNoteType;
        }
        
        //Get InstructorTimeSubmitCtrl Static Map
        if(tcdIdNoteType.size() == 0) {
            tcdIdNoteType = InstructorTimeSubmitCtrl.tcdIdNoteType;
        }
        
        //W-007742
        // Get StaffTimeSubmitCtrl Static Map
        if(tcdIdNoteType.size() == 0) {
            tcdIdNoteType = StaffTimeEntryController.tcdIdNoteType;
        }
        
        //Get AdminTimeEntry_InstructorCtrl Static Map
        if(tcdIdNoteType.size() == 0) {
            tcdIdNoteType = AdminTimeEntry_InstructorCtrl.tcdIdNoteType;
        }
        
        List<Accounting_Seed_Time_Snapshot__c> tcdSnapshotList = new List<Accounting_Seed_Time_Snapshot__c>();
        
        //Get Current TCD Project related Supervisor Positions based on the Logged in user
        Set<Id> projectIds = new Set<Id>();
        Map<Id,String> proIdSuperivisorPosition = new Map<Id,String>();
        
        for(AcctSeed__Time_Card_Day__c tcd : newRecords){
            projectIds.add(tcd.Project_Id__c);
        }
        
        
        //Get Logged In User related Contact Id
        Id supervisorId;
        Id usrId = UserInfo.getUserId();
        String firstName = UserInfo.getFirstName();
        String lastName = UserInfo.getLastName();
        
        String fname = firstName != null ? '%'+String.escapeSingleQuotes(firstName)+'%' : null;
        String lName = lastName != null ? '%'+String.escapeSingleQuotes(lastName)+'%' : null;
        
        List<Contact> conRecList = new List<Contact>();
        
        if(firstName != null && lastName != null){                  
            conRecList = ContactService.getContactByName(' WHERE FirstName LIKE \''+fname+'\' AND LastName LIKE \''+lName+'\'',',RecordType.DeveloperName',new Set<String>{},'');
        } else if(lastName != null){
            conRecList = ContactService.getContactByName(' WHERE LastName LIKE \''+lName+'\'',',RecordType.DeveloperName',new Set<String>{},'');
        }
        system.debug('::::::conRecList::::'+conRecList.size());
        
        if(conRecList.size() > 0){
            supervisorId = conRecList[0].Id;
        }
        
        for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,Assignment_Position__c,Project__c 
                                            FROM Contact_Assignments__c 
                                            WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' AND Candidate_Name__c = :supervisorId]){
            
            if(!proIdSuperivisorPosition.containsKey(ca.Project__c)){
                proIdSuperivisorPosition.put(ca.Project__c,ca.Assignment_Position__c);
            }
        }
        system.debug('::::::proIdSuperivisorPosition:::'+proIdSuperivisorPosition);
        
        system.debug(':::::::::::tcdIdNoteType:::'+tcdIdNoteType);
        system.debug(':::::isGroupAction:::'+isGroupAction);
        system.debug(':::::groupActionType:::'+groupActionType);
        
        String dtVal = system.now().format('MM/dd/yyyy hh:mm:ss a');
        String supervisorName = UserInfo.getName();
        
        system.debug(':::::supervisorName:::'+supervisorName);
        
        if(oldMap.size() > 0) {
            for(AcctSeed__Time_Card_Day__c tcd : newRecords){
                // The below code for sanpshot object creation 
                
                //No need to create snapshot records for Save-Approved / Save-Rejected status changes
                
                if (tcd != oldMap.get(tcd.Id) && (tcd.Status__c != 'Save - Approved' || tcd.Status__c != 'Save - Rejected')) {
                    AcctSeed__Time_Card_Day__c oldTCD = oldMap.get(tcd.Id);
                   
                    Accounting_Seed_Time_Snapshot__c tcdSnapshot = new Accounting_Seed_Time_Snapshot__c();
                    
                    tcdSnapshot.Time_Card_Day__c = oldTCD.Id;
                    tcdSnapshot.Approved_Date__c = oldTCD.Approved_Date__c;
                    tcdSnapshot.Billing_Line__c = oldTCD.AcctSeed__Billing_Line__c;
                    tcdSnapshot.Date__c = oldTCD.AcctSeed__Date__c;
                    tcdSnapshot.Employee__c = oldTCD.AcctSeed__Employee__c;
                    
                    tcdSnapshot.Start_Time1__c = oldTCD.Start_Time1__c;
                    tcdSnapshot.End_Time1__c = oldTCD.End_Time1__c;
                    tcdSnapshot.Start_Time2__c = oldTCD.Start_Time2__c;
                    tcdSnapshot.End_Time2__c = oldTCD.End_Time2__c;
                    tcdSnapshot.Hours__c = oldTCD.AcctSeed__Hours__c;
                    
                    //tcdSnapshot.Internal_Comment__c = oldTCD.AcctSeed__Internal_Comment__c;
                    tcdSnapshot.Invoice_Comment__c = oldTCD.AcctSeed__Invoice_Comment__c;
                    tcdSnapshot.Language__c = oldTCD.Language__c;
                    tcdSnapshot.Late_Cancellation__c = oldTCD.Late_Cancellation__c;
                    tcdSnapshot.Cancellation_Reason__c = oldTCD.Cancellation_Reason__c;
                    
                    tcdSnapshot.TCD_Parent_Status__c = oldTCD.AcctSeed__Parent_Status__c;
                    tcdSnapshot.TCD_Project_Id__c = oldTCD.Project_Id__c;
                    tcdSnapshot.Service_Item__c = oldTCD.Service_Item__c;
                    tcdSnapshot.TCD_Status__c = oldTCD.Status__c;
                    tcdSnapshot.TCD_New_Status__c = tcd.Status__c;
                    
                    tcdSnapshot.Student_Initial__c = oldTCD.Student_Initial__c;
                    tcdSnapshot.Time_Card_Line__c = oldTCD.AcctSeed__Time_Card_Line__c;
                    
                    //tcdSnapshot.Time_Card_Period__c = oldTCD.AcctSeed__Time_Card_Period__c;
                    tcdSnapshot.Total_Hours_Before_Approved__c = oldTCD.Total_Hours_Before_Approved__c;
                    tcdSnapshot.TCD_Approved_by__c = oldTCD.Approved_by__c;
                    
                    //tcdSnapshot.Utilization_Category__c = oldTCD.AcctSeed__Utilization_Category__c;
                    tcdSnapshot.TCD_Instructor_Name__c = oldTCD.Instructor_Name__c;
                    tcdSnapshot.TCD_Project_Task_Type__c = oldTCD.Project_Task_Type__c;
                    tcdSnapshot.TCD_Service_Item__c = oldTCD.Service_Item__c;
                    tcdSnapshot.Student_Approval_Status__c = oldTCD.Student_Approval_Status__c;
                    tcdSnapshot.Student_Approved_Date__c = oldTCD.Student_Approved_Date__c;
                    tcdSnapshot.Student_Approver__c = oldTCD.Student_Approver__c;
                    tcdSnapshot.Student_Notes__c = oldTCD.Student_Notes__c;
                    tcdSnapshot.Recall_Reason__c = oldTCD.Recall_Reason__c;
                    
                    if(tcdIdNoteType.size() == 0) {    //Old Notes Formation for all other types Except Instructor Time Entry, Student Approval & Event Reconciliaiton changes
                    
                        if(oldTCD.Total_Hours_Before_Approved__c != tcd.Total_Hours_Before_Approved__c) {
                            
                            tcdSnapshot.Internal_Comment__c = tcd.AcctSeed__Internal_Comment__c;
                        
                        } else if(oldTCD.Total_Hours_Before_Approved__c == tcd.Total_Hours_Before_Approved__c && oldTCD.Status__c != tcd.Status__c && tcd.Status__c == 'Submitted') {
                            
                            tcdSnapshot.Internal_Comment__c = 'User ('+UserInfo.getName()+') submitted timesheet on '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                        
                        }else if(oldTCD.Total_Hours_Before_Approved__c == tcd.Total_Hours_Before_Approved__c && oldTCD.Status__c != tcd.Status__c && tcd.Status__c == 'Recalled') {
                            
                            tcdSnapshot.Internal_Comment__c = 'User ('+UserInfo.getName()+') recalled timesheet on '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                        
                        }else if(oldTCD.Total_Hours_Before_Approved__c == tcd.Total_Hours_Before_Approved__c && oldTCD.Status__c != tcd.Status__c && tcd.Status__c == 'Approved') {
                            
                            tcdSnapshot.Internal_Comment__c = 'Supervisor ('+UserInfo.getName()+') Approved timesheet on '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                            
                            //Added by NS on Nov 3 2023 for W-007742 Staff time entry for Instructor Community
                            tcdSnapshot.Notes__c = tcdSnapshot.Internal_Comment__c;
                            tcdSnapshot.Note_Type__c = 'Weekly Approval';
                            
                        }else if(oldTCD.Total_Hours_Before_Approved__c == tcd.Total_Hours_Before_Approved__c && oldTCD.Status__c != tcd.Status__c && tcd.Status__c == 'Rejected') {
                            
                            tcdSnapshot.Internal_Comment__c = 'Supervisor ('+UserInfo.getName()+') Rejected timesheet on '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                            
                            //Added by NS on Nov 3 2023 for W-007742 Staff time entry for Instructor Community
                            tcdSnapshot.Notes__c = tcdSnapshot.Internal_Comment__c;
                            tcdSnapshot.Note_Type__c = 'Weekly Reject';
                            
                        }else if(oldTCD.Status__c != tcd.Status__c && tcd.Status__c == 'Unposted'){
                            
                            tcdSnapshot.Internal_Comment__c = tcd.AcctSeed__Internal_Comment__c;
                        
                        }else if(oldTCD.Total_Hours_Before_Approved__c == tcd.Total_Hours_Before_Approved__c && oldTCD.Status__c != tcd.Status__c && tcd.Status__c == 'Reverted') {
                           
                           tcdSnapshot.Internal_Comment__c = 'Admin ('+UserInfo.getName()+') Reverted timesheet on '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                           
                            //Added by NS on Nov 3 2023 for W-007742 Staff time entry for Instructor Community
                            tcdSnapshot.Notes__c = tcdSnapshot.Internal_Comment__c;
                            tcdSnapshot.Note_Type__c = 'Weekly Revert';
                            
                        }else {
                           tcdSnapshot.Internal_Comment__c = tcd.AcctSeed__Internal_Comment__c;
                        }
                        
                        
                    }else if(tcdIdNoteType.containsKey(tcd.Id)){    //Notes formation for Instructor Time Entry & Student Approval & LTS Approval process
                        
                        String formatedTCDDt = String.valueOf(tcd.AcctSeed__Date__c).split('-')[1]+'/'+String.valueOf(tcd.AcctSeed__Date__c).split('-')[2]+'/'+String.valueOf(tcd.AcctSeed__Date__c).split('-')[0];
                        
                        String notes = '';
                        String noteType = '';
                        
                        if(tcdIdNoteType.get(tcd.Id) == 'TCD Edit') {
                            
                            notes = 'On '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2]+': '+tcd.Instructor_Position__c+' '+tcd.Instructor_Name__c+' edited an entry for Project Task: '+tcd.Project_Task_Name__c+'. Date: '+formatedTCDDt+'. Old Hours: '+oldMap.get(tcd.Id).Total_Hours_Before_Approved__c+' Hrs. New Hours: '+tcd.Total_Hours_Before_Approved__c+' Hrs. Old Status: '+oldMap.get(tcd.Id).Status__c+'. New Status: '+tcd.Status__c+'. Comment: '+tcd.AcctSeed__Internal_Comment__c;
                            if(tcd.Instructor_Position__c == null) {
                                notes = 'On '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2]+': '+' '+tcd.Instructor_Name__c+' edited an entry for Project Task: '+tcd.Project_Task_Name__c+'. Date: '+formatedTCDDt+'. Old Hours: '+oldMap.get(tcd.Id).Total_Hours_Before_Approved__c+' Hrs. New Hours: '+tcd.Total_Hours_Before_Approved__c+' Hrs. Old Status: '+oldMap.get(tcd.Id).Status__c+'. New Status: '+tcd.Status__c+'. Comment: '+tcd.AcctSeed__Internal_Comment__c;     
                            }
                            noteType = 'Daily Entry Edit';
                            
                        }else if(tcdIdNoteType.get(tcd.Id) == 'Daily Recall') {
                            
                            notes = 'On '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2]+': '+tcd.Instructor_Position__c+' '+tcd.Instructor_Name__c+' recalled an entry for Project Task: '+tcd.Project_Task_Name__c+'. Date: '+formatedTCDDt+'. Hours: '+tcd.Total_Hours_Before_Approved__c+' Hrs. Recall Reason: '+tcd.Recall_Reason__c;
                            noteType = 'Instructor Daily Entry Recall';
                            
                        }else if(tcdIdNoteType.get(tcd.Id) == 'Weekly Submit') {
                            
                            notes = tcd.Instructor_Position__c+' '+tcd.Instructor_Name__c+' submitted timesheet on '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                            noteType = 'Weekly Submit';
                            
                        }else if(tcdIdNoteType.get(tcd.Id) == 'Weekly Recall') {
                            
                            notes = tcd.Instructor_Position__c+' '+tcd.Instructor_Name__c+' recalled timesheet on '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                            noteType = 'Weekly Recall';
                            
                        }else if(tcdIdNoteType.get(tcd.Id) == 'Weekly Approval') {
                            
                            String position = proIdSuperivisorPosition.containsKey(tcd.Project_Id__c) ? proIdSuperivisorPosition.get(tcd.Project_Id__c) : 'Admin';
                            
                            notes = position+' '+supervisorName+' Approved timesheet on '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                            noteType = 'Weekly Approval';
                            
                        }else if(tcdIdNoteType.get(tcd.Id) == 'Weekly Reject') {
                            
                            String position = proIdSuperivisorPosition.containsKey(tcd.Project_Id__c) ? proIdSuperivisorPosition.get(tcd.Project_Id__c) : null;
                            
                            notes = position+' '+supervisorName+' Rejected timesheet on '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                            noteType = 'Weekly Reject';
                            
                        }else if(tcdIdNoteType.get(tcd.Id) == 'Weekly Revert') {
                            
                            String position = proIdSuperivisorPosition.containsKey(tcd.Project_Id__c) ? proIdSuperivisorPosition.get(tcd.Project_Id__c) : null;
                            
                            notes = ' Admin Reverted timesheet on '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                            noteType = 'Weekly Revert';
                            
                        }else if(tcdIdNoteType.get(tcd.Id) == 'Student Rejection'){
                            
                            String studentFN = UserInfo.getFirstName();
                            String studentLastInitial = UserInfo.getLastName().subString(0,1);
                            
                            notes = 'Student '+studentFN+' '+studentLastInitial+' rejected '+formatedTCDDt+' on '+dtVal.split(' ')[0]+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2]+'. Reason: '+tcd.Student_Notes__c;
                            noteType = 'Student Daily Entry Reject';
                        }
                       
                        tcdSnapshot.Notes__c = notes;
                        tcdSnapshot.Note_Type__c = noteType;
                        tcdSnapshot.Internal_Comment__c = tcd.AcctSeed__Internal_Comment__c;
                        tcdSnapshot.Invoice_Comment__c = tcd.AcctSeed__Invoice_Comment__c;
                    }
                    
                    if(isGroupAction) {
                        tcdSnapshot.Reference_Id__c = groupActionType+' '+dtVal.split(' ')[0]+' '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                    }else if(tcdIdNoteType.get(tcd.Id) == 'Weekly Reject'){
                        tcdSnapshot.Reference_Id__c = 'Partial Reject '+dtVal.split(' ')[0]+' '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2];
                    }
                    
                    tcdSnapshotList.add(tcdSnapshot);
                }
            }
        }else {
        
            for(AcctSeed__Time_Card_Day__c tcd : newRecords){
                
                Accounting_Seed_Time_Snapshot__c tcdSnapshot = new Accounting_Seed_Time_Snapshot__c();
                
                String formatedTCDDt = String.valueOf(tcd.AcctSeed__Date__c).split('-')[1]+'/'+String.valueOf(tcd.AcctSeed__Date__c).split('-')[2]+'/'+String.valueOf(tcd.AcctSeed__Date__c).split('-')[0];
                
                if(tcd.Late_Cancellation__c && tcd.Cancellation_Reason__c != null){
                
                    tcdSnapshot.Notes__c = tcd.Instructor_Position__c+' '+tcd.Instructor_Name__c+' submitted a Late Cancellation time entry on '+formatedTCDDt+' at '+dtVal.split(' ')[1]+' '+dtVal.split(' ')[2]+'. Cancellation Reason Notes: '+tcd.Cancellation_Reason__c;
                    tcdSnapshot.Note_Type__c = 'Instructor Daily Entry Late Cancellation';
                    tcdSnapshot.Time_Card_Day__c = tcd.Id;
                    tcdSnapshot.Date__c = tcd.AcctSeed__Date__c;
                    tcdSnapshot.Start_Time1__c = tcd.Start_Time1__c;
                    tcdSnapshot.End_Time1__c = tcd.End_Time1__c;
                    tcdSnapshot.Start_Time2__c = tcd.Start_Time2__c;
                    tcdSnapshot.End_Time2__c = tcd.End_Time2__c;
                    tcdSnapshot.Hours__c = tcd.AcctSeed__Hours__c;
                    tcdSnapshot.Time_Card_Line__c = tcd.AcctSeed__Time_Card_Line__c;
                    
                    tcdSnapshotList.add(tcdSnapshot);
                }
            }
        }
        
        system.debug(':::::::tcdSnapshotList:::::'+tcdSnapshotList);
        system.debug(':::::::tcdSnapshotList:size::::'+tcdSnapshotList.size());
        
        if (tcdSnapshotList.size() > 0) {
            insert tcdSnapshotList;
        }  
            
    }
    
    /**********************************************************************************
    - Method to update the unposted tcd records related Attendace record
    - Added by NS on June 19 2019
    - Work Item No: W-001106
    ***********************************************************************************/
    public void unpostedTCDRelatedAttendance(Set<Id> unpostedTCDIds){
        
        if(unpostedTCDIds != NULL && unpostedTCDIds.size() > 0){
        
            List<Attendance__c> updateAttendanceRecs = new List<Attendance__c>();
            
            for(Attendance__c a : [SELECT Id, Comments__c, Duration__c, Recall_Reason__c, Rejection_Reason__c, Student_Approval_Status__c
                FROM Attendance__c 
                WHERE Time_Card_Day__c IN : unpostedTCDIds
            ]){
            
                a.Comments__c =  '';
                a.Duration__c = 0.00;
                a.Recall_Reason__c = '';
                a.Rejection_Reason__c = '';
                a.Student_Approval_Status__c = 'Unposted';
                
                updateAttendanceRecs.add(a);
            }
            
            system.debug('::::::updateAttendanceRecs::::for:::update::::::'+updateAttendanceRecs.size());
            
            if(updateAttendanceRecs.size() > 0){
                update updateAttendanceRecs;
            }
        }
    }
    
    public static void populateEnteredLateFields(List<AcctSeed__Time_Card_Day__c> timeCardDays){
        Set<Id> projectIds = new Set<Id>();
        Set<Date> dates = new Set<Date>();
        Set<Id> instructorIds = new Set<Id>();
        for(AcctSeed__Time_Card_Day__c tcd : timeCardDays){
            dates.add(tcd.AcctSeed__Date__c);
            projectIds.add(tcd.Project_Id__c);
            instructorIds.add(tcd.Instructor_Id__c);
        }
        
        Map<Id, Set<Id>> conIdsWithProjectIds = new Map<Id, Set<Id>>();
        
        for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Project__c 
                                                                FROM Contact_Assignments__c 
                                                                WHERE Project__c = :projectIds AND RecordType.DeveloperName IN ('Instructor','Student')]){
                                                                    
            if(!conIdsWithProjectIds.containsKey(ca.Candidate_Name__c))
                conIdsWithProjectIds.put(ca.Candidate_Name__c, new Set<Id>());
            
            conIdsWithProjectIds.get(ca.Candidate_Name__c).add(ca.Project__c);
        }
        
        pdosByProjectId = TimeEntryHelper.getApprovedPDOsByProjectIds(conIdsWithProjectIds, dates, projectIds);
       
        for(AcctSeed__Time_Card_Day__c tcd : timeCardDays){
            if(tcd.AcctSeed__Hours__c != 0 || (tcd.AcctSeed__Hours__c == 0 && (!pdosByProjectId.containsKey(tcd.Project_Id__c) || (pdosByProjectId.containsKey(tcd.Project_Id__c) && !pdosByProjectId.get(tcd.Project_Id__c).contains(tcd.AcctSeed__Date__c))))){
                Date nextWorkingDay = TimeCardDayTrigger_Handler.getNextWorkingDay(tcd.AcctSeed__Date__c, tcd.Project_Id__c);
                TimezoneUtilClass userTimeZone = new TimezoneUtilClass();
                tcd.Entered_On_Time__c = userTimeZone.getUserTimeZoneDateTime(system.now()) <= userTimeZone.getUserTimeZoneDateTime(Datetime.newInstance(nextWorkingDay.year(), nextWorkingDay.month(), nextWorkingDay.day(), 12, 0, 0));
                tcd.Entered_Late__c = !tcd.Entered_On_Time__c;
            }
        }
    }
    
    public static Date getNextWorkingDay(Date dt, Id projectId){
        Boolean isHoliday = false;
        Set<String> weekendDays = new Set<String>{'Saturday','Sunday'};
        Set<Date> pdo = new Set<Date>();
        if(holidayDates == null){
            holidayDates = HolidayService.getHolidaysWithRecurrence(Date.newInstance((system.today().year() - 1),01,01),Date.newInstance((system.today().year()+1),12,31));
        }
        
        if(pdosByProjectId != null && pdosByProjectId.containsKey(projectId)){
            pdo.addAll(pdosByProjectId.get(projectId));
        }
        
        if(holidayDates != null && holidayDates.size() > 0){
            do{                
                dt = dt.addDays(1);
                String day = Datetime.newInstance(dt.year(), dt.month(), dt.day()).format('EEEE');
                isHoliday = holidayDates.contains(dt) || weekendDays.contains(day) || pdo.contains(dt);
            }while(isHoliday);
        }
        
        return dt;
    }
}