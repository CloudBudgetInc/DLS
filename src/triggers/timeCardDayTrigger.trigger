// This trigger edited to merge Full SB  trigger code by Sukanya on DEC 15 2016

trigger timeCardDayTrigger on AcctSeed__Time_Card_Day__c (before insert, before update, before delete,after Insert,after update) {
    
    // Added by Sukanya
    Set<Id> WholeEventIdSet = new Set<Id>();
    Set<Id> completedEventIdSet = new Set<Id>();
    Set<Id> LatecancelEventIdSet = new Set<Id>();
    Set<Id> cancellationEventIdSet = new Set<Id>();
    List<Events__c> eventStatusUpdateList = new List<Events__c>();
    
    // Get TimeLog_Profile_Ids,TimeLog_Admin_ProfileIds Custom label values     
    String timelogProfids = label.TimeLog_Profile_Ids;    
    String timelogAdminProfIds = label.TimeLog_Admin_ProfileIds;    
    Set<Id> profileIdSet = new Set<Id>();
    Set<Id> adminProfileIdSet = new Set<Id>();
    
    
    // Added by Sukanya on Dec 2 2016
    Set<Id> CardLineIdSet = new Set<Id>();
    Map<Id,Id> LineIdContactIdMap = new Map<Id,Id>();
    List<Messaging.SingleEmailMessage> EmailToSupervisorList = new List<Messaging.SingleEmailMessage>();
    
    Map<Id,AcctSeed__Time_Card_Line__c> lineId_lineRec = new Map<Id,AcctSeed__Time_Card_Line__c>();
    
    if (String.isNotEmpty(timelogProfids)) {
        if (timelogProfids.contains(',')) {
            for(String str : timelogProfids.split(',')) {
                if (!profileIdSet.contains(Id.valueOf(str.trim()))){
                    profileIdSet.add(Id.valueOf(str.trim()));
                }
            }
        } else {
            profileIdSet.add(Id.valueOf(timelogProfids));
        }
    }  
    
    if (String.isNotEmpty(timelogAdminProfIds)) {
        if (timelogAdminProfIds.contains(',')) {  
            for(String str : timelogAdminProfIds.split(',')) {
                if (!adminProfileIdSet.contains(Id.valueOf(str.trim()))){
                    adminProfileIdSet.add(Id.valueOf(str.trim()));
                }
            }
        } else {
            adminProfileIdSet.add(Id.valueOf(timelogAdminProfIds));
        }
    }
    
    // Get TimeLog_Locking_Date custom setting value    
    System_Values__c sysVal = System_Values__c.getValues('TimeLog_Locking_Date');    
    Date lockingDate;   
    String loggedInProfileId = UserInfo.getProfileId();    
    if (sysVal != null && sysVal.Value__c != null) {
        lockingDate = Date.valueOf(sysVal.Value__c);
    } 
    
    
    // Newly Added from Full SB
    
    Set<Id> timeCardLineIdSetForProfile = new Set<Id>();
    Set<Id> lineRecIdForEmployeeContact = new Set<Id>();
    
    if (trigger.isBefore) {
        
        // this code added to omit the DLS_Employee contact time entry restrictions 
        //for profiles which are not in those 2 custom labels
        
        if (trigger.isInsert || trigger.isUpdate) {
            for (AcctSeed__Time_Card_Day__c tcd : trigger.new) {
                
                if(tcd.AcctSeed__Time_Card_Line__c != null)
                    timeCardLineIdSetForProfile.add(tcd.AcctSeed__Time_Card_Line__c);
                    
                // Populate Submitted date value on TCD records submission
                if(tcd.Status__c == 'Submitted' && (trigger.isInsert || (trigger.isUpdate && trigger.oldMap.get(tcd.Id).Status__c != tcd.Status__c))){
                    tcd.Submitted_Date__c = system.today();
                    tcd.Submitted_Date_Time__c = system.now();
                }                
            }                        
        }
        
        if(trigger.isInsert){
                TimeCardDayTrigger_Handler.populateEnteredLateFields(Trigger.new);
        }
        
        for(AcctSeed__Time_Card_Line__c lineRecs : [SELECT Id,Name,AcctSeed__Project_Task__c,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName
                                                   FROM AcctSeed__Time_Card_Line__c WHERE Id IN :timeCardLineIdSetForProfile]) {
            if(lineRecs.AcctSeed__Time_Card__c != null 
                && lineRecs.AcctSeed__Time_Card__r.Intructor__c != null 
                && lineRecs.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName == 'DLS_Employee') {
                
                lineRecIdForEmployeeContact.add(lineRecs.Id);
            }
        }
        
        system.debug('::::::::::lineRecIdForEmployeeContact:::::'+lineRecIdForEmployeeContact);
    
        if (trigger.isInsert || trigger.isUpdate) {
    
            for (AcctSeed__Time_Card_Day__c tcd : trigger.new) {
            
                
                if (lineRecIdForEmployeeContact.contains(tcd.AcctSeed__Time_Card_Line__c) 
                    || (profileIdSet.contains(loggedInProfileId) || adminProfileIdSet.contains(loggedInProfileId))) {
                    
                    if (trigger.isUpdate) {
                        if (!adminProfileIdSet.contains(loggedInProfileId)) {
                            if (lockingDate < trigger.oldMap.get(tcd.Id).AcctSeed__Date__c) {           
                                if (trigger.oldMap.get(tcd.Id).Total_Hours_Before_Approved__c != tcd.Total_Hours_Before_Approved__c && 
                                    (trigger.oldMap.get(tcd.Id).AcctSeed__Internal_Comment__c == tcd.AcctSeed__Internal_Comment__c || tcd.AcctSeed__Internal_Comment__c == null ) 
                                    && (trigger.oldMap.get(tcd.Id).Status__c != 'Unposted')) {
                                    
                                    tcd.addError('Please update Time Card Day comments');
                                }
                            } else {  
                                tcd.addError('You cannot edit Time Card Day record after Time Card Day locking period');
                            } 
                        }
                    }    
                } else {
                    //Commented by Sukanya on July 7 2017
                    // Need to get the profile ids from Chris for Instructor & Intenral time approval action
                    // That's why commented the else part
                    //tcd.addError('Insufficient Privilege');
                }
                
                if(trigger.isUpdate) {
                    if(tcd.Status__c == 'Unposted') {
                    
                        tcd.Total_Hours_Before_Approved__c = 0.00;
                        tcd.AcctSeed__Hours__c = 0.00;
                        tcd.Start_Time1__c = '';
                        tcd.Start_Time2__c = '';
                        tcd.End_Time1__c = '';
                        tcd.End_Time2__c = '';
                        tcd.Student_Approval_Status__c = '';
                        tcd.Student_Notes__c = '';
                        tcd.Approved_by__c = NULL;
                        tcd.Approved_Date__c = NULL;
                        tcd.AcctSeed__Invoice_Comment__c = '';
                        tcd.Submitted_Date__c = NULL;
                        tcd.Cancellation_Reason__c = NULL;
                        tcd.Hide_From_Student__c = FALSE;
                        tcd.Late_Cancellation__c = FALSE;
                        tcd.Student_Approved_Date__c = NULL;
                        tcd.Student_Approver__c = NULL;
                        tcd.Submitted_Date_Time__c = NULL;
                        
                        //tcd.AcctSeed__Internal_Comment__c = '';
                    }
                }
            }
        }
        if(trigger.isDelete) {
            for (AcctSeed__Time_Card_Day__c tcd : trigger.old) {
                tcd.addError('You cannot delete Time Card Day record.');
            }
        }
        
        //Added By Dhinesh - 21/12/2020 - W-006278 - Populate Classification value from Project
        if(Trigger.isInsert){
            Set<Id> timeCardLineIds = new Set<Id>();
            
            for(AcctSeed__Time_Card_Day__c tcd : Trigger.new){
                if(tcd.AcctSeed__Time_Card_Line__c != null){
                    timeCardLineIds.add(tcd.AcctSeed__Time_Card_Line__c);
                }
            }
            
            /* Commented by Dhinesh - 24/11/2021 - W-007183 - populate GLAV2 in time card day
            Map<Id, String> tclIdWithProjectClassificationMap = new Map<Id, String>();
            for(AcctSeed__Time_Card_Line__c tcl : [SELECT Id, AcctSeed__Project_Task__r.AcctSeed__Project__r.QB_Classification__c FROM AcctSeed__Time_Card_Line__c WHERE Id IN :timeCardLineIds AND AcctSeed__Project_Task__c != null]){
                tclIdWithProjectClassificationMap.put(tcl.Id, tcl.AcctSeed__Project_Task__r.AcctSeed__Project__r.QB_Classification__c);                
            }*/
            
            Map<Id, AcctSeed__Time_Card_Line__c> tclIdWithRecMap = new Map<Id, AcctSeed__Time_Card_Line__c>([SELECT Id, AcctSeed__Project_Task__r.AcctSeed__GL_Account_Variable_2__c, AcctSeed__Project_Task__r.AcctSeed__Project__r.QB_Classification__c FROM AcctSeed__Time_Card_Line__c WHERE Id IN :timeCardLineIds AND AcctSeed__Project_Task__c != null]);
            
            for(AcctSeed__Time_Card_Day__c tcd : Trigger.new){
                if(tcd.AcctSeed__Time_Card_Line__c != null && tclIdWithRecMap.get(tcd.AcctSeed__Time_Card_Line__c) != null){
                    tcd.QB_Classification__c = tclIdWithRecMap.get(tcd.AcctSeed__Time_Card_Line__c).AcctSeed__Project_Task__r.AcctSeed__Project__r.QB_Classification__c;
                    tcd.GL_Variable_2__c = tclIdWithRecMap.get(tcd.AcctSeed__Time_Card_Line__c).AcctSeed__Project_Task__r.AcctSeed__GL_Account_Variable_2__c;
                }
            }
        }
    }
    
    if (trigger.isAfter) {
        
        // Added by Sukanya on Dec 2 2016 to Send Mail When Day record created under Bonus Leave Earned Project Task
        // Send Mail to the Time Card - Instructor contact - Supervisor
       if (trigger.isInsert) {
           
           for (AcctSeed__Time_Card_Day__c tcd : trigger.new) {
               CardLineIdSet.add(tcd.AcctSeed__Time_Card_Line__c);
           }
           system.debug(':::::CardLineIdSet:::::'+CardLineIdSet);
           
           //Qry condition ProjectTask.Payrollitem is replaced with timecardLine.Payrollitem field
           // due to projecttask.apyrollitem field deletion
           // Changes made by Sukanya - 22.08.2017
           
           for(AcctSeed__Time_Card_Line__c line: [SELECT Id,Name,AcctSeed__Project_Task__c,AcctSeed__Time_Card__c,
                                                           AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c,
                                                           AcctSeed__Project_Task__r.Project_Task_Type__c,Payroll_Item__c,AcctSeed__Project_Task__r.Name
                                                   FROM AcctSeed__Time_Card_Line__c
                                                   WHERE AcctSeed__Project_Task__r.Project_Task_Type__c = 'Fringe' 
                                                               AND Payroll_Item__c = 'BLE' AND AcctSeed__Time_Card__r.Intructor__c != null
                                                               AND AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c != null AND Id IN :CardLineIdSet]) {
               
               if(!LineIdContactIdMap.containsKey(line.Id))
                   LineIdContactIdMap.put(line.Id,line.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c);
               
               if(!lineId_lineRec.containsKey(line.Id))
                   lineId_lineRec.put(line.Id,line);
           }
           
           system.debug('::::::::LineIdContactIdMap:::::::'+LineIdContactIdMap);
           
            EmailTemplate ContactTemplateId = [Select id from EmailTemplate where DeveloperName = 'Send_Email_to_Contact_Bonus_Hrs_Approve'];
           
           for(AcctSeed__Time_Card_Day__c tcd : trigger.new) {
               
                if((tcd.Status__c == 'Draft' || tcd.Status__c == 'Submitted') && LineIdContactIdMap.ContainsKey(tcd.AcctSeed__Time_Card_Line__c) 
                    && lineId_lineRec.containsKey(tcd.AcctSeed__Time_Card_Line__c) && lineId_lineRec.get(tcd.AcctSeed__Time_Card_Line__c).Payroll_Item__c == 'BLE' 
                    && lineId_lineRec.get(tcd.AcctSeed__Time_Card_Line__c).AcctSeed__Project_Task__r.Project_Task_Type__c == 'Fringe' 
                    && lineId_lineRec.get(tcd.AcctSeed__Time_Card_Line__c).AcctSeed__Project_Task__r.Name.contains('Bonus Leave Earned')) {
                    
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(tcd.id);
                    req.setNextApproverIds(new Id[] {LineIdContactIdMap.get(tcd.AcctSeed__Time_Card_Line__c)});
                    //req.setNextApproverIds(new Id[] {'00560000003Co3b'});
                    
                    Approval.ProcessResult result =  Approval.process(req);
                }
           }
           
           //Call Notes Formation Handler Method for Instructor Time Entry related TCD Process
           // Moved Snapshot creation logic to Handler by NS on Apr 17 2019
           //Only call Notes creation on insert action when the TCD records are created from Instructor Time Entry
           
           TimeCardDayTrigger_Handler handler = new TimeCardDayTrigger_Handler();
           
            //Get Instructor Time Entry Ctrl Static Map
            String pageType = InstructorTimeEntry_Controller.pageType;
        
            if(String.isNotBlank(pageType)) {
                handler.notesFormationBasedonTCD(trigger.new,new Map<Id,AcctSeed__Time_Card_Day__c>());
            }
       }
       
        Set<Id> unpostedTCDIds = new Set<Id>();
        Set<Id> tcdIds = new Set<Id>();
        
        if(trigger.isUpdate) {
            
            //Modified By Dhinesh - 26-11-2020 - Skip notesformation when billing line is updated in Time Card Day
            Map<Id, AcctSeed__Time_Card_Day__c> oldMapForNotesFormation = new Map<Id, AcctSeed__Time_Card_Day__c>();
            List<AcctSeed__Time_Card_Day__c> newTimeCardDayForNotesFormation = new List<AcctSeed__Time_Card_Day__c>();
            
            for (AcctSeed__Time_Card_Day__c tcd : trigger.new) {
            
                //To get unposted TCD ids
                if(trigger.oldmap.get(tcd.Id).Status__c != tcd.Status__c && tcd.Status__c == 'Unposted'){
                    unpostedTCDIds.add(tcd.Id);
                }
                
                // Added by HL on Oct 21 2019
                // To send an email notification to student when the Instructor Submits their Timesheet without Completing it    
                if(tcd.Status__c != Trigger.oldMap.get(tcd.Id).Status__c && tcd.Status__c == 'Submitted'){
                    tcdIds.add(tcd.Id);
                }
                
                //Modified By Dhinesh - 26-11-2020 - Skip notesformation when billing line is updated in Time Card Day
                if(tcd.AcctSeed__Billing_Line__c == trigger.oldmap.get(tcd.Id).AcctSeed__Billing_Line__c){
                    newTimeCardDayForNotesFormation.add(tcd);
                    oldMapForNotesFormation.put(tcd.Id, trigger.oldmap.get(tcd.Id));
                }
            } 
           
            // Call timecardRelated Email sending class
            timeCardRelated_Email_Controller.bonusLeaveEarned_Email(Trigger.New,Trigger.oldMap); 
                        
            //Call Notes Formation Handler Method for Instructor Time Entry related TCD Process
            // Moved Snapshot creation logic to Handler by NS on Apr 17 2019
            TimeCardDayTrigger_Handler handler = new TimeCardDayTrigger_Handler();
            
            //Modified By Dhinesh - 26-11-2020 - Skip notesformation when billing line is updated in Time Card Day
            if(oldMapForNotesFormation.size() > 0){
                handler.notesFormationBasedonTCD(newTimeCardDayForNotesFormation,oldMapForNotesFormation);
            }
            
            //check if the TCD records is unposted then delete the corresponding Attendance records
            //Added by NS on June 19 2019
            if(unpostedTCDIds.size() > 0){
                handler.unpostedTCDRelatedAttendance(unpostedTCDIds);
            }      
            
            if(tcdIds.size() > 0){
                
                timeCardRelated_Email_Controller.sendEmailToStd(tcdIds);
            }           
        }    
         
        
        //Added by NS on OCT 4 2018
        //For TCD value population in Event records based on the TCD status values
        
        Set<Id> dayIds = new Set<Id>();
        Set<Id> normalTCDIds = new Set<Id>();
        Set<Id> lineIds = new Set<Id>();
        for(AcctSeed__Time_Card_Day__c tcd : trigger.New){
        
            if((trigger.isInsert || (trigger.isUpdate && tcd.Status__c != trigger.oldMap.get(tcd.Id).Status__c))){
                
                dayIds.add(tcd.Id);
                
                if(!lineIds.contains(tcd.AcctSeed__Time_Card_Line__c))
                    lineIds.add(tcd.AcctSeed__Time_Card_Line__c);
           }
       }
       
       //Call Handler class to update the event record based on the TCD status value
       if(dayIds.size() > 0){
           TimeCardDayTrigger_Handler.updateEventBasedonTCD(dayIds,lineIds);
       }
        
    }
    
    // Added by HL 
    if(Trigger.isAfter){
    
        if(Trigger.isInsert){
            // An Email notification to Student for Daily Time Entry Approval Request Immediately upon Instructor Time Card Day save
            timeCardRelated_Email_Controller.dailyRequestToStudent(Trigger.new);
            // Commented on Apr 21 2023
            // An Email notification to Student for Daily Time Entry Approval Request for Late Cancellation Immediately upon Instructor Time Card Entry save where Late Cancellation checkbox is checked
            //timeCardRelated_Email_Controller.dailyReqToStudForLateCancellation(Trigger.new);
        }     
        
        if(Trigger.isUpdate){
        
            // An Email notification to Student When Instructor edits Time Entry - "re-approve / new approve "
            timeCardRelated_Email_Controller.reORnewApprovalRequestToStudent(Trigger.new, Trigger.oldMap);
            
            // An email notification to instructor when student reject the "time card day"
            timeCardRelated_Email_Controller.studentRejectionNotification(Trigger.new, Trigger.oldMap);
            
            //Added on Jan 21 2022 - W-007342 - Update Instructor Time Approval Email and Budget Columns in DLS Online
            //An email notification to instructor Immediately upon LTS / Supervisor Submit action when all entries are approved
            if(EventReconciliationController.isGroupAction == TRUE && EventReconciliationController.groupActionType == 'Approved'){
                timeCardRelated_Email_Controller.weeklyApprovedNotificationToInstructor(Trigger.new, Trigger.oldMap);
            }
            
            //An email notification to instructor when LTS / Supervisor Weekly Reject the time entries
            timeCardRelated_Email_Controller.weeklyRejectionNotificationtoInstructor(Trigger.new, Trigger.oldMap);
        }   
    }
}