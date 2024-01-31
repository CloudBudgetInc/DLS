/*****************************************************************************
    - Created by Sukanya on June 14 2017
    - To call the Time card day creation batch & Event updation batch from Projects 2 buttons
    - Button names - "Convert Missed time log" & "Update Missed Events"
    - To convert the failed records from project conversion process & event updation process
*******************************************************************************/

global without sharing class CustomButtonService {
    
    public static Boolean isFromManageProjectStatus = false;
    
    @AuraEnabled
    webservice static void TimelogToTCDConversion(Id OppId,Id projectId) {
        system.debug('::::::::opp::::TCD::'+OppId);
        system.debug('::::::::projectId::::::::'+projectId);
        
        Map<String,String> contServItemPtName = new Map<String,String>();
        Map<String,Id> projectTaskNameWithProjectTaskId = new Map<String,Id>();
        Map<Date,Date> stdateandEnddtMap = new Map<Date,Date>();
        List<Date> tlDateSet = new List<Date>();     // Time Log Dates     
        Set<Date> monthStartdtSet = new Set<Date>(); // For Accounting Period 
        Set<Date> monthEnddtSet = new Set<Date>();   // For Ac
        Set<Id> ContIds = new Set<Id>();
        
        Set<Id> taskId = new Set<Id>();
        Set<Id> existingTLIds = new Set<Id>();
        Map<String,Map<String,Decimal>> contIdPtNameHoursMap = new Map<String,Map<String,Decimal>>();
        Map<Id,Map<Date,Date>> contIdWithStAndEndDateMap = new Map<Id,Map<Date,Date>>();
        
        Map<String,String> PayRollValuesMap = new Map<String,String>{'S' => 'Sick', 'V' => 'Vacation', 'HOL' => 'Holiday', 'OTH' => 'Other Pay', 'BLE' => 'Bonus Leave Earned', 'BLT' => 'Bonus Leave Taken'};
        
        Date stDate;
        Date endDate;
        
        Set<Date> startdtSet = new Set<Date>();      // For Time Card Period Query Week Start Date Set
        Set<Date> enddtSet = new Set<Date>();        // For Time Card Period Query Week End Date Set
        
         Map<String,String> productNameStaticMap = new Map<String,String>{'Language Training- Arabic' => 'Language Training- Arabic (MSA and all dialects)', 'Language Training- Vietnamese' => 'Language Training- Vietnamese (all dialects)', 'Language Training- Mandarin' => 'Language Training- Chinese (Mandarin)', 'Language Training- Portuguese' => 'Language Training- Portuguese (all dialects)'};
        
        Map<Id,Id> oppIdProjectIdMap = new Map<Id,Id>{OppId => projectId};
        
        for(AcctSeed__Project_Task__c task : [SELECT Id,Name,AcctSeed__Project__c,Service_Item__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = : projectId]) {
            
            projectTaskNameWithProjectTaskId.put(task.Name,task.Id);
            taskId.add(task.Id);
        }
        
        for(AcctSeed__Time_Card_Day__c day : [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c,Time_Log_Id__c,AcctSeed__Internal_Comment__c 
                                                    FROM AcctSeed__Time_Card_Day__c 
                                                    WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c IN : taskId 
                                                        AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c = : projectId AND Time_Log_Id__c != null]) {
            
            existingTLIds.add(day.Time_Log_Id__c);
            if(day.AcctSeed__Internal_Comment__c != null && day.AcctSeed__Internal_Comment__c.contains('Merged - ') && day.AcctSeed__Internal_Comment__c.split('-').size() > 1) {
                existingTLIds.add(day.AcctSeed__Internal_Comment__c.split('- ')[1]);
            }
        }
        
        system.debug(':::::::existingTLIds::::::'+existingTLIds);
        
        Set<String> tempProjTaskAddSet = new Set<String>();
        Set<String> oldPtNAmeSet = new Set<String>();
        
        for(Time_Log__c tl : [SELECT Contact__c,Contact__r.Name,Notes__c,Hours__c,Date__c,First_Name__c,Last_Name__c,Name,Opportunity__c,Service_Item__c,Billable_Work__c,Classification__c,Unposted__c,Payroll_Item__c 
                                FROM Time_Log__c 
                                WHERE Opportunity__c =: OppId AND Unposted__c = False 
                                    AND Id NOT IN : existingTLIds Order By Date__c Asc]) {
            //tlDateSet.add(tl.Date__c);
            
            String Proj_Task_Name = 'Language Training- ';
            
            if( tl.Service_Item__c != null && tl.Service_Item__c.contains('SVC:Language Training:')) {
                List<String> serStrList = tl.Service_Item__c.split('SVC:Language Training:');
                if(serStrList != null && serStrList.size() > 1) {
                    Proj_Task_Name += serStrList[1];
                    
                    if(productNameStaticMap.containsKey(Proj_Task_Name)){
                        Proj_Task_Name = productNameStaticMap.get(Proj_Task_Name);
                    }
                
                    System.debug('Proj_Task_Name :::'+Proj_Task_Name );
                } 
            } else if ( tl.Service_Item__c != null && tl.Service_Item__c.contains('SVC:')) {
                List<String> siStrList = tl.Service_Item__c.split('SVC:');
                if(siStrList != null && siStrList.size() > 1) {
                    Proj_Task_Name = siStrList[1];
                } else {
                    Proj_Task_Name = tl.Service_Item__c;  
                }
                if(!tempProjTaskAddSet.contains(Proj_Task_Name )) {
                    tempProjTaskAddSet.add(Proj_Task_Name);
                }
            } else if ( tl.Service_Item__c != null) {
                Proj_Task_Name = tl.Service_Item__c;
                if((tl.Service_Item__c != 'Fringe' || (tl.Service_Item__c == 'Fringe' && tl.Payroll_Item__c != null && !PayRollValuesMap.Containskey(tl.Payroll_Item__c))) && !tempProjTaskAddSet.contains(tl.Service_Item__c)) {
                   tempProjTaskAddSet.add(tl.Service_Item__c);
                   
                // For Admin Opp with Holidays, Sick, Vacation, Other Pay as Project Task    
                } else if(tl.Service_Item__c == 'Fringe' && tl.Payroll_Item__c != null && PayRollValuesMap.Containskey(tl.Payroll_Item__c)) {
                    String tempPT = tl.Service_Item__c+'-'+PayRollValuesMap.get(tl.Payroll_Item__c);
                    Proj_Task_Name = tl.Service_Item__c+'-'+PayRollValuesMap.get(tl.Payroll_Item__c);
                    if(!tempProjTaskAddSet.contains(tl.Service_Item__c+'-'+PayRollValuesMap.get(tl.Payroll_Item__c))) {
                        tempProjTaskAddSet.add(tempPT);
                    }
                }
            }
            System.debug('Proj_Task_Name:::'+Proj_Task_Name);
            
            if(tl.Contact__c != null) {
                ContIds.add(tl.Contact__c);
                String contIdName = tl.Contact__c + '-' + tl.Contact__r.Name;
                if(!contIdPtNameHoursMap.Containskey(contIdName) && tl.Service_Item__c != null) {
                    contIdPtNameHoursMap.put(contIdName, new Map<String,Decimal>());   
                    contIdPtNameHoursMap.get(contIdName).put(Proj_Task_Name,tl.Hours__c);
                } else if(contIdPtNameHoursMap.get(contIdName) != null && tl.Service_Item__c != null && !contIdPtNameHoursMap.get(contIdName).containskey(Proj_Task_Name)) {
                    contIdPtNameHoursMap.get(contIdName).put(Proj_Task_Name,tl.Hours__c);
                } else if(contIdPtNameHoursMap.get(contIdName) != null && tl.Service_Item__c != null && contIdPtNameHoursMap.get(contIdName).containskey(Proj_Task_Name)) {
                    System.debug('contIdPtNameHoursMap.get(contIdName):::'+contIdPtNameHoursMap.get(contIdName));
                    System.debug('contIdPtNameHoursMap.get(contIdName).get(Proj_Task_Name):::'+contIdPtNameHoursMap.get(contIdName).get(Proj_Task_Name));
                    Decimal hourTotal = (contIdPtNameHoursMap.get(contIdName).get(Proj_Task_Name) != null ? contIdPtNameHoursMap.get(contIdName).get(Proj_Task_Name) : 0) + (tl.Hours__c != null ? tl.Hours__c: 0);
                    System.debug('hourTotal :::'+hourTotal);
                    System.debug('tl.Hours__c:::'+tl.Hours__c);
                    contIdPtNameHoursMap.get(contIdName).put(Proj_Task_Name,hourTotal);
                }
            }
            
            Date sDate;
            Date eDate;
            if(tl.Date__c != null) {
                tlDateSet.add(tl.Date__c);
                
                if(tl.Date__c.toStartofWeek().addDays(1) < tl.Date__c)
                    sDate = tl.Date__c.toStartofWeek().addDays(1);
                else
                    sDate = tl.Date__c.addDays(-1).toStartofWeek().addDays(1);
                    
                eDate = sDate.addDays(6);
            }
            
            if(tl.Contact__c != null && !contIdWithStAndEndDateMap.Containskey(tl.Contact__c)) {
                contIdWithStAndEndDateMap.put(tl.Contact__c, new Map<Date,Date>());
            } 
            
            if(contIdWithStAndEndDateMap != null && contIdWithStAndEndDateMap.containskey(tl.Contact__c) && !contIdWithStAndEndDateMap.get(tl.Contact__c).containskey(sDate)) {
                contIdWithStAndEndDateMap.get(tl.Contact__c).put(sDate,eDate);
            }             
        }
        
        System.debug('contIdPtNameHoursMap:::::'+contIdPtNameHoursMap);
        for(String conId : contIdPtNameHoursMap.keyset()){
            List<String> conIdAndName = conId.split('-');
            if(conIdAndName != null && conIdAndName.size() > 1) {
                for(String pt : contIdPtNameHoursMap.get(conId).Keyset()) {
                    contServItemPtName.put(conId+pt,pt);
                }
            }
        }
        
        system.debug('::::::::::contServItemPtName::::'+contServItemPtName);
        
        if( tlDateSet != null && tlDateSet.size() > 0 ) {
                    
            stDate = tlDateSet[0];
            endDate = tlDateSet[tlDateSet.size()-1];
            Date FinalEndDate = endDate.toStartofWeek()+7;
            System.debug('tlDateSet.size()'+tlDateSet.size());
            System.debug('stDate :::'+stDate+'endDate :::'+endDate);
            System.debug('FinalEndDate :::'+FinalEndDate);
            
            Date weekstdate;
            Date weekenddate;
            
            if(stDate.toStartofWeek().addDays(1) < stDate)
                weekstdate = stDate.toStartofWeek().addDays(1);
            else
                weekstdate = stDate.addDays(-1).toStartofWeek().addDays(1);
                
            weekenddate = weekstdate.addDays(6);
            
            while(weekstdate <= FinalEndDate && weekenddate <= FinalEndDate) {
                startdtSet.add(weekstdate);
                enddtSet.add(weekenddate);  
                
                if(!stdateandEnddtMap.containsKey(weekstdate)) {
                    stdateandEnddtMap.put(weekstdate,weekenddate);
                }
                                        
                Date monthStart = weekstdate.toStartofMonth();
                Date monthEnd = weekstdate.addMonths(1).toStartofMonth().addDays(-1);
                
                monthStartdtSet.add(monthStart);
                monthEnddtSet.add(monthEnd);
                
                weekstdate = weekstdate.addDays(7);
                weekenddate = weekenddate.addDays(7); 
            }
        }
        
        UtilDomain.batchParameters batchParam = new UtilDomain.batchParameters();
        batchParam.oppId  = oppId;
        batchParam.contServItemPtName = contServItemPtName;
        batchParam.projectTaskNameWithProjectTaskId = projectTaskNameWithProjectTaskId;
        batchParam.startdtSet = startdtSet;
        batchParam.enddtSet = enddtSet;
        batchParam.stdateandEnddtMap = stdateandEnddtMap;
        batchParam.tlDateSet = tlDateSet;
        batchParam.monthStartdtSet = monthStartdtSet;
        batchParam.monthEnddtSet = monthEnddtSet;
        batchParam.contIdWithStAndEndDateMap = contIdWithStAndEndDateMap;
        batchParam.ContIds = ContIds;
        batchParam.PayRollValuesMap = PayRollValuesMap;
        batchParam.newProjectId = projectId;
        batchParam.existingTLIds = existingTLIds;
        batchParam.oppIdProjectIdMap = oppIdProjectIdMap;
        
        system.debug('L:::::::::::batchParam:::::::::::'+batchParam);
        
        // Calling User Creation batch to create missing time log record to time card day
        if(!Test.isRunningTest() && tlDateSet != null && tlDateSet.size() > 0) {
            UserCreation_FrmContact usrContactBatch = new UserCreation_FrmContact(batchParam);
            database.executeBatch(usrContactBatch);
        }
        
    }
    
    webservice static void EventUpdation(Id OppId,Id projectId) {
        system.debug('::::::::opp:::event:::'+OppId);
        system.debug('::::::::projectId:::::'+projectId);
        
        Set<Id> scheduleIdSet = new Set<Id>();
        Map<Id,Id> schIdWithInstructorIdMap = new Map<Id,Id>();
        List<UtilDomain.EventInnerClass> eventList = new List<UtilDomain.EventInnerClass>();
        
        for(Schedule__c sch : [SELECT Id,Name,Instructor__c,Opportunity__c,Project__c FROM Schedule__c WHERE Opportunity__c = :OppId]) {
            scheduleIdSet.add(sch.Id);
            schIdWithInstructorIdMap.put(sch.Id,sch.Instructor__c);
        }
        
        for(Events__c eve : [SELECT Id,Name,Date__c,Instructor__c,Project__c,Schedule__c,Status__c FROM Events__c WHERE Schedule__r.Opportunity__c = :OppId AND Status__c = 'Scheduled' AND Project__c = null]) {
            
            eventList.add(new UtilDomain.EventInnerClass(eve,'',null));
        }
        
        // Calling event updation batch for missing records
        if(!Test.isRunningTest()){
            EventUpdation_FromCTP eventBatch = new EventUpdation_FromCTP(scheduleIdSet,new Set<Id>(),eventList,schIdWithInstructorIdMap,projectId);
            database.executeBatch(eventBatch,1);
        }
    }
    
    /********************************************************************
    - Method to create Fixed Asset record from Equipment record on "Convert to Fixed Asset" button click
    - Added by NS on July 26 2018
    *********************************************************************/
    webservice static String convertToFixedAsset(Id equipmentId) {
        system.debug(':::::::::equipmentId::::::::'+equipmentId);
        
        AcctSeed__Fixed_Asset__c fixedAsset = new AcctSeed__Fixed_Asset__c();
        Map<String,String> equipRTName_AssetRTName = new Map<String,String>();
        Map<String,Id> FARTName_RTId = new Map<String,Id>();
        String returnStr;
        // To check for Fixed Asset availability for the Equipment
        List<AcctSeed__Fixed_Asset__c> faList = [SELECT Id,Name,Equipment__c FROM AcctSeed__Fixed_Asset__c WHERE Equipment__c =: equipmentId];
        
        if( faList != null && faList.size() > 0 ) {
            returnStr = 'Error';
        } else {
        
            for(Sobject_Master_Field_Mapping__c master : [SELECT Id,Name,Default_Field_Value__c,Field_Name__c,Object_Name__c,RecordType_Name__c 
                                                            FROM Sobject_Master_Field_Mapping__c 
                                                            WHERE Field_Name__c = 'RecordTypeId']) {
                
                if(!equipRTName_AssetRTName.containsKey(master.RecordType_Name__c))
                    equipRTName_AssetRTName.put(master.RecordType_Name__c,master.Default_Field_Value__c);
            }
            system.debug('::::::::equipRTName_AssetRTName:::::'+equipRTName_AssetRTName);
            
            for(RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE sObjectType = 'AcctSeed__Fixed_Asset__c']) {
                FARTName_RTId.put(rt.DeveloperName,rt.Id);
            }
            
            for(Equipment__c equip : [SELECT Id,Name,Acquisition_Cost__c,RecordTypeId,RecordType.DeveloperName,Purchase_Order_No__c FROM Equipment__c WHERE Id = :equipmentId]) {
                fixedAsset.Name = equip.Name;
                fixedAsset.AcctSeed__Value__c = equip.Acquisition_Cost__c != null ? equip.Acquisition_Cost__c : 0;
                fixedAsset.Purchase_Order__c = equip.Purchase_Order_No__c;
                fixedAsset.Equipment__c = equip.Id;
                
                if(equipRTName_AssetRTName.containsKey(equip.RecordType.DeveloperName)) {
                    if(FARTName_RTId.containsKey(equipRTName_AssetRTName.get(equip.RecordType.DeveloperName))) {
                        fixedAsset.RecordTypeId = FARTName_RTId.get(equipRTName_AssetRTName.get(equip.RecordType.DeveloperName));
                    }else {
                        fixedAsset.RecordTypeId = '';
                    }
                }
            }
            
            system.debug('::::::::fixedAsset::::::'+fixedAsset);
            insert fixedAsset;
            returnStr = fixedAsset.Id;
        }
        return returnStr;
    }
    
     //Method to create events for project from "Create Events" btn on Project detail page
    // Added by NS on Oct 15 2018
    @AuraEnabled
    webservice static void EventsCreationFromProject(Id projectId) {
        system.debug(':::inside::::eventcreationFromProject:::method::::projectId:::::::::::'+projectId);
        
        // Calling Events Creation batch to create events
        if(!Test.isRunningTest() && projectId != null) {
            CreateEventsFromSchedule createEventBatch = new CreateEventsFromSchedule(projectId);
            database.executeBatch(createEventBatch);
        }
    }
    
    /***************************************************
     - Method to update the Project & related Schedule records status as On Hold / Canceled based on the status selection in Manage Project Status quick action
     - Added by NS on Dec 18 2018
    *****************************************************/
    @AuraEnabled
    public static String updateProStatusToOnHold(String proId,String conAssignsJSON,String dateValue,String reason,String status, Boolean sendStudentReminder){
        system.debug('::::proId:::::'+proId);
        system.debug('::::dateValue:::::'+dateValue);
        List<Contact_Assignments__c> conAssigns = (List<Contact_Assignments__c>) JSON.deserialize(conAssignsJSON, List<Contact_Assignments__c>.class);
        Savepoint sp = Database.setSavepoint();
        try{
            if(String.isNotBlank(proId)){
                
                isFromManageProjectStatus = true;
                AcctSeed__Project__c proRec = new AcctSeed__Project__c();
                proRec.Id = proId;
                proRec.AcctSeed__Status__c = status;
                // To update the On Hold Date in Project for Report purpose
                // On_Hold_Date__c is cleared when the On Hold project is Activated, Changes in ManageProjectDatescontroller
                if(status == 'On Hold') { 
                    proRec.On_Hold_Date__c = Date.valueOf(dateValue);
                }
                
                update proRec;
                
                if(status == 'Order' && conAssigns.size() > 0){
                    /* upsert CAs From Manage_project_status QuickAction*/
                    upsert conAssigns;
                }else if(status == 'On Hold' || status == 'Canceled'){
                    if(sendStudentReminder){
                        sendOnHoldProjStudentRemainder(proId);
                    }
                    List<Schedule__c> schRecords = [SELECT Id,Name,Status__c,On_Hold_Date__c FROM Schedule__c WHERE Project__c = :proId AND Status__c IN ('Drafted','Active')];
                    system.debug(':::::::schRecords::::'+schRecords);
                    if(schRecords.size() > 0){
                        for(Schedule__c sch : schRecords){
                            
                            if(status == 'On Hold') {
                                //Modified by NS on May 10 2019
                                // When a project is put in On Hold status, related Schedule records date get updates & status set to completed due to long time on hold
                                //sch.Status__c = 'On Hold';
                                
                                sch.On_Hold_Date__c = Date.valueOf(dateValue);
                                sch.Status__c = 'Completed';
                                sch.End_Date__c = Date.valueOf(dateValue);
                                
                            } else if(status == 'Canceled') {
                                sch.Status__c = 'Canceled';
                                sch.Cancellation_Date__c = Date.valueOf(dateValue);
                                sch.Cancellation_Reason__c = reason;
                            }
                            
                        }
                        update schRecords;
                    }
                }
                
                return 'success';
            }
        }catch(Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
       }
        return '';
    }
    
    /*****************************************************************************
    - Method to send the Emails for Students when Project Status changed to On-Hold
    - W-006829 - Added by Dhinesh on Aug 2 2021
    ******************************************************************************/    
    @future
    public static void sendOnHoldProjStudentRemainder(Id prodId){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        try{
            AcctSeed__Project__c proj = [SELECT Id, Name, AcctSeed__Account__c, AcctSeed__Account__r.Name, DLS_Ref__c, On_Hold_Date__c, Project_Manager__r.Name, Project_Manager__r.Email, Project_Manager__r.Title FROM AcctSeed__Project__c WHERE Id = :prodId];
            List<Contact_Assignments__c> conAssignments = new List<Contact_Assignments__c>();
            
            List<String> instructorsEmailAddress = new List<String>();
            List<String> bccEmailAddress = new List<String>{'accountinggroup@dlsdc.com'};
            
            NewClassAnnouncementController.addStaffRecordTypeFilter = true;                      
            for(Contact_Assignments__c ca : [SELECT Id,RecordType.DeveloperName,
                                             Assignment_Position__c,
                                             Candidate_Name__r.Email, Candidate_Name__c, Candidate_Name__r.Name                                             
                                             FROM Contact_Assignments__c WHERE Project__c = :prodId AND Status__c NOT IN ('Canceled','Ended','Transferred') AND RecordType.DeveloperName IN ('Staff','Student','Instructor')]){
                                                 
                if(ca.RecordType.DeveloperName == 'Student'){
                    conAssignments.add(ca);   
                }else if(ca.RecordType.DeveloperName == 'Instructor'){
                    instructorsEmailAddress.add(ca.Candidate_Name__r.Email);
                }else if(ca.RecordType.DeveloperName == 'Staff' && (ca.Assignment_Position__c == 'Project Manager' || ca.Assignment_Position__c == 'Coordinator')){
                    bccEmailAddress.add(ca.Candidate_Name__r.Email);
                }       
            }
            
            if(conAssignments.size() > 0){
                List<User> usrRecord = [SELECT Id,Name,Email,Title FROM User WHERE Id = :userinfo.getUserId()];
                Map<Id,Id> userIdWithContactIdMap = PlannedDaysOffHandler.getUserRelatedContacts(new Set<Id>{userinfo.getUserId()});
                Contact con;
                if(userIdWithContactIdMap.size() > 0){
                    for(Contact c : [SELECT Id, Title, Ext__c, Phone FROM Contact WHERE Id IN :userIdWithContactIdMap.values()]){
                        con = c;
                    }
                }
                
                for(Contact_Assignments__c ca : conAssignments){                                        
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    Date endDate = proj.On_Hold_Date__c;                    
                    String dt = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day()).format('MM/dd/YYYY');
                    Date oneYrDate = proj.On_Hold_Date__c.addYears(1);                    
                    String oneYrDateStr = DateTime.newInstance(oneYrDate.year(),oneYrDate.month(),oneYrDate.day()).format('MM/dd/YYYY');
                    
                    String subject = 'Class On-Hold '+ dt + ' - ' +proj.Name;
                    
                    String mailContent = '<html>Dear '+ca.Candidate_Name__r.Name+',<br/><br/>';
                    mailContent += 'This email confirms that your Class '+ proj.DLS_Ref__c +' is now On Hold.';
                    
                    if(proj.AcctSeed__Account__r.Name.contains('PVT')){                        
                        mailContent += '<br/><br/>DLS will retain your funds for a year until you contact '+ proj.Project_Manager__r.Name +' at '+proj.Project_Manager__r.Email+' to resume training by '+oneYrDateStr+'.';
                        mailContent += '<br/><br/>You will receive a quarterly email inquiring about your plan to resume training or need a refund.<br/><br/>';
                        mailContent += 'To request a refund, please, email at accountinggroup@dlsdc.com.<br/> <br/>';                   
                    }else{                         

                        mailContent += '<br/><br/>Your class will be On Hold for a year until you contact '+ proj.Project_Manager__r.Name +' at '+proj.Project_Manager__r.Email+' to resume training by '+oneYrDateStr+'.<br/><br/>'; 
                    }
                    
                    mailContent += 'If you have any additional concerns or questions regarding this email, please email '+ proj.Project_Manager__r.Name+ '. <br/> <br/>';

                    mailContent += 'We appreciate your time and collaboration.<br/> <br/>';
                    mailContent += usrRecord[0].Name+'<br/>';
                    if(con != null){
                        if(con.Title != null) mailContent += con.Title+'<br/>'; 
                        mailContent += '(703) 243-4855';
                        if(con.Ext__c != null) mailContent += '-'+con.Ext__c;
                    }  
                    mailContent += '<br/>Diplomatic Language Services<br/>1901 N. Fort Myer Dr., Ste. 600 | Arlington, VA 22209';
                    mailContent += '<html>';

                    mail.setTargetObjectId(ca.Candidate_Name__c);
                    mail.setCcAddresses(instructorsEmailAddress);
                    mail.setBccAddresses(bccEmailAddress);
                    mail.setSubject(subject);
                    mail.setSaveAsActivity(true);
                    mail.sethtmlBody(mailContent);
                    mails.add(mail);
                }
            }
        
            system.debug('::::::mails:::::'+mails);
                    
            if( mails != null && mails.size() > 0) {
                Messaging.sendEmail(mails);
            }
        }catch(Exception e) {
                            
            String errorMessage = '';
            errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
            
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Send Material Return Alert');
        } 
    }
        
    /*********************************************************************
     - Method to initiate the Beta Group User creation batch from global actions
     - Added by NS on Aug 29 2019
     - Called from BetaGroupUserCreation aura component
    **********************************************************************/
    @AuraEnabled
    public static void initiateUserCreation(){
        
        //Initiate beta group user creation batch
        CreateBetaGroupUser createUsr = new CreateBetaGroupUser();
        database.executeBatch(createUsr,1);
    }
    /*********************************************************************
     - Method to create the Account record from Contact
     - Added by MS on Feb 17 2020
     - Called from CreateAccountAccountCmp aura component
    **********************************************************************/
    @AuraEnabled
    public static String createAccount(String contactId) {
        
        try {
            return AccountUtil.dlsInstructorAccountCreation(contactId);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*********************************************************************
     - Method to get Inactive costrate related contact assignments with new CA
     - Added by Siva Prasanth on June 19 2020
     - Called from Manage ProjectStatus aura component
    **********************************************************************/
    /* this method to check whether CAs has Inactive LCR or not
       if CAs has Inactive LCR, then create Active CA with assign the recent LCR of parent LCR to CA costRate field*/
    @AuraEnabled
    public static String getInactiveLCRRelatedConAssigns(String proId){
        List<Contact_Assignments__c> otherCAs = new List<Contact_Assignments__c>();
        List<Contact_Assignments__c> inActiveCRRelCAToNewCA = new List<Contact_Assignments__c>();
        Map<Id,AcctSeed__Cost_Rates__c> oldCRWirthNewCRMap = new Map<Id,AcctSeed__Cost_Rates__c>();
        List<Contact_Assignments__c> endedCAFromOnHoldForInActiveLCR = new List<Contact_Assignments__c>();
        Set<Id> inActiveCRSet = new Set<Id>();
        ManageProjectDatescontroller.CARecords caIns = new ManageProjectDatescontroller.CARecords();
        
        if(String.IsNotBlank(proId)) {
            List<Contact_Assignments__c> conass = ContactAssignmentService.getContactassignmentByprojectId(' WHERE RecordType.DeveloperName = \'Instructor\' AND Status__c != \'Ended\' AND Rate_Card_Rate__r.Status__c = \'Inactive\' AND Project__c ','Project__r.End_Date__c, Candidate_Name__r.Name, Project_Task__r.Name ',new Set<Id>{proId},'');
            
            for(Contact_Assignments__c ca : conass){
                if(ca.Rate_Card_Rate__c != null){
                    inActiveCRRelCAToNewCA.add(ca);
                    inActiveCRSet.add(ca.Rate_Card_Rate__c);
                    
                    /* Modified by Siva Prasanth , assign the old CA Status as Ended if CA has Inactive LCR and Status equal to On Hold*/
                    if(ca.Status__c == 'On Hold'){
                        Contact_Assignments__c caRec = new Contact_Assignments__c();
                        caRec.Status__c = 'Ended';
                        caRec.Id = ca.Id;
                        endedCAFromOnHoldForInActiveLCR.add(caRec);
                    }
                }
            }
            /* get the recent Child LCR of parent(Prior_Version__c) LCR and its assign to new CA*/
            if(inActiveCRRelCAToNewCA.size() > 0){
                for(AcctSeed__Cost_Rates__c cr : CostRateService.getCostRateByParentId(' WHERE Status__c != \'Inactive\' AND Prior_Version__c','',inActiveCRSet,' Order By Effective_Date__c Desc')){
                    if(!oldCRWirthNewCRMap.containsKey(cr.Prior_Version__c)){
                        oldCRWirthNewCRMap.put(cr.Prior_Version__c,cr);  
                    }
                }
                //System.debug('oldCRWirthNewCRMap::::'+oldCRWirthNewCRMap);
                for(Contact_Assignments__c ca : inActiveCRRelCAToNewCA){
                    ca.Id = null;
                    ca.Start_Date__c = System.Today();
                    ca.Status__c = 'Planned';
                    
                    if(ca.Project__r.End_Date__c != null){
                        ca.End_Date__c = ca.Project__r.End_Date__c;
                    }
                    if(oldCRWirthNewCRMap.containsKey(ca.Rate_Card_Rate__c)){
                        AcctSeed__Cost_Rates__c lcr = oldCRWirthNewCRMap.get(ca.Rate_Card_Rate__c);
                        ca.Rate_Card_Rate__c = null;
                        
                        if(lcr.Status__c == 'Approved'){
                            ca.Rate_Card_Rate__c = lcr.Id;
                        }else{
                            ca.Drafted_Labor_Cost_Rate__c = lcr.Id;
                        }
                    }else{
                        ca.Rate_Card_Rate__c = null;
                    }
                }
                otherCAs.addAll(inActiveCRRelCAToNewCA);
            }
        }
        system.debug('inActiveCRRelCAToNewCA:::'+inActiveCRRelCAToNewCA);
        caIns.conAssign = otherCAs;
        caIns.endedCAFromOnHoldForInActiveLCR = endedCAFromOnHoldForInActiveLCR;
        return JSON.serialize(caIns);
    }
    
    @auraEnabled
    public static Account getAccountForVendorCreation(Id accountId){
        return [SELECT Id, AcctSeed__Accounting_Type__c, Status_Bill_com__c FROM Account WHERE Id = :accountId LIMIT 1];
    }
    
    @auraEnabled
    public static String executeVendorCreationBatch(Id accountId){
        String result = 'success';
        try{
            
            database.executeBatch(new VendorCreation(accountId), 1);
        }catch(Exception ex){
            result = ex.getMessage();
        }
        
        return result;
    }
     
}