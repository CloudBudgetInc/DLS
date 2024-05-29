trigger projectTriggerToUpdateAccount on AcctSeed__Project__c (before insert, before update, after insert, after update, after delete) {
    
    /**
    * Populate Delivery Account, End User Account when first entry to Billing Account is entered
    * for Language Training Projects, Online Projects
    **/ 
    
    Set<Id> projRecordTypeIdSet = new Set<Id>();
    Map<Id, String> oppIdStatusValueMap = new Map<Id, String>(); // To store the opportunity Id and Status of the project when the status is changed
    String adminProjRtId;
    Integer j = 0;
    Integer count = 0, cdCount = 0, testCount = 0, transCount = 0, interPreCount = 0;
    Id DLI_W_RTId;
    
    //Added by Shalini for sending courseCompletedFeedback on Feb 6 2018
    Set<Id> recTypeIdsForSendFeedback = new Set<Id>();
    Set<String> devNamesForSendFeedback = new Set<String>{'DLI_W_LT_Projects','CD_Projects','MTT_Projects','Language_Training_Projects','DODA_Projects'};
    Set<Id> proIdForCompleteFeedback = new Set<Id>();

    Set<String> proRTNames = new Set<String>{'Testing_Projects','Translation_Projects','Interpretation_Projects'};
    Set<Id> proRTIds = new Set<Id>();
    
    Map<Id,SObject> proIdRecMap = new Map<Id,SObject>();
    Id TestProRecTypeId, mttRecTypeId, cdRecTypeId, transRecTypeId, interPreRecTypeId;
    
    // For CA records status updation
    Map<Id,String> proIdStatusMap = new Map<Id,String>();
    Set<String> statusSet = new Set<String>{'Order','Active','Ended','Canceled','On Hold'}; 
    
    // Default Cost Rate population related variables
    Map<Id,String> rtId_RTName = new Map<Id,String>();
    Map<String,String> proRTName_RateType = new Map<String,String>();
    
    //Added
    List<AcctSeed__Project__c> glVarUpdateProjs = new List<AcctSeed__Project__c>();
    //Commented By Dhinesh - 12/7/2022 - W-007513 - Zoom License Agreement changes
    //Set<Id> projectIdsForZoomUserLisenceCheck = new Set<Id>(); //Added By Dhinesh - W-006013 - Zoom Integration - to check the zoom user license type when project changed to active or ended
    
    if(ProjectTrigger_Handler.loadResource == false) {
        ProjectTrigger_Handler.loadResource = true;
        ProjectTrigger_Handler.getProRecordType();
        ProjectTrigger_Handler.getOppProMappingRec(' WHERE Value_Type__c = \'Rate Type\'');
    }
    
    if(ProjectTrigger_Handler.rtList != null && ProjectTrigger_Handler.rtList.size() > 0) {
        for( RecordType rt : ProjectTrigger_Handler.rtList) {
            if(proRTNames.contains(rt.DeveloperName)) {
                proRTIds.add(rt.Id);
            } else if(rt.DeveloperName == 'Language_Training_Projects') {
                projRecordTypeIdSet.add(rt.Id);
            } else if (rt.DeveloperName == 'Admin_Projects') {
                adminProjRtId = rt.Id;
            } else if(rt.DeveloperName == 'DLI_W_LT_Projects') {
                DLI_W_RTId = rt.Id;
            } 
             
            if(rt.DeveloperName == 'Testing_Projects'){
                TestProRecTypeId = rt.Id;
            } else if(rt.DeveloperName == 'MTT_Projects') {
                mttRecTypeId = rt.Id;
            } else if(rt.DeveloperName == 'CD_Projects') {
                cdRecTypeId = rt.Id;
            } else if(rt.DeveloperName == 'Translation_Projects') {
                transRecTypeId = rt.Id;
            } else if(rt.DeveloperName == 'Interpretation_Projects') {
                interPreRecTypeId = rt.Id;
            }
            
            //Added by Shalini for sending courseCompletedFeedback on Feb 6 2018
            if(devNamesForSendFeedback.contains(rt.DeveloperName)){
                recTypeIdsForSendFeedback.add(rt.Id);
            }
            
            if(!rtId_RTName.containsKey(rt.Id))
                rtId_RTName.put(rt.Id,rt.DeveloperName);
        }
    }
    //Ended
    
    List<String> namesList = new List<String>();
    
    //Qry Opportunity Project Mapping Custom setting to get the mapping for Default Cost Rate population
    if(ProjectTrigger_Handler.oppProMapList != null && ProjectTrigger_Handler.oppProMapList.size() > 0) {
        for(Opportunity_Project_Mapping__c opm : ProjectTrigger_Handler.oppProMapList){
            
            if(opm.Project_Value__c.contains(',') && opm.Project_Value__c.split(',').size() > 1){
                namesList = opm.Project_Value__c.split(',');
                for(String name : namesList){
                    if(!proRTName_RateType.containsKey(name))
                        proRTName_RateType.put(name,opm.Default_CR_Rate_Type__c);
                }
            }else if(!proRTName_RateType.containsKey(opm.Project_Value__c)){
                proRTName_RateType.put(opm.Project_Value__c,opm.Default_CR_Rate_Type__c);
            }
        }
    }
    
    // start of Trigger is Before
    if (trigger.isBefore) {
       
        // To get the recent count of Opportunity or Project
        System.debug('CPU Time before getHighestNoForDLSClass:'+System.limits.getLimitCpuTime()+' Used'+Limits.getCpuTime());
        Set<Id> endedProjIds = new Set<Id>();
        Date oldDate = System.today().addDays(-60); // To not allow the End of training Getfeedback trigger for the old Opportunity getting converted to Project
        
        Set<Id> onHoldProIds = new Set<Id>();
        Map<Id,Boolean> proIdActiveCA = new Map<Id,Boolean>();
        Map<Id,Boolean> proIdActiveSchedule = new Map<Id,Boolean>();
        Boolean cdRtProAvailable = false, otherRtypeProAvailable = false, testRtProAvailable = false, transRtProAvailable = false, interPreRtProAvailable = false;
        Set<Id> projectIdToChangeGLAV2 = new Set<Id>(); //Added GLAV2 By Dhinesh - 02/12/2021 - W-007183
        Set<Id> accountIdToChangeGLAV2 = new Set<Id>();
        
        for (AcctSeed__Project__c pr : trigger.new) {
            if(pr.DLS_Class__c == null) {
                if(pr.RecordTypeId == cdRecTypeId) {
                    cdRtProAvailable = true;
                } else if(pr.RecordTypeId != mttRecTypeId && !proRTIds.contains(pr.RecordTypeId)) {
                    otherRtypeProAvailable = true;
                } else if(pr.RecordTypeId == TestProRecTypeId) {
                    testRtProAvailable = true;
                } else if(pr.RecordTypeId == transRecTypeId) {
                    transRtProAvailable = true;
                } else if(pr.RecordTypeId == interPreRecTypeId) {
                    interPreRtProAvailable = true;
                }
                j++;
            }
            
            //Added GLAV2 By Dhinesh - 02/12/2021 - W-007183
            if(Trigger.isUpdate && (pr.RecordTypeId != Trigger.oldMap.get(pr.Id).RecordTypeId || 
                                    pr.AcctSeed__Account__c != Trigger.oldMap.get(pr.Id).AcctSeed__Account__c ||
                                    pr.QB_Classification__c != Trigger.oldMap.get(pr.Id).QB_Classification__c ||
                                    pr.QB_Contract_Type__c != Trigger.oldMap.get(pr.Id).QB_Contract_Type__c)
              ){
                projectIdToChangeGLAV2.add(pr.Id);
                accountIdToChangeGLAV2.add(pr.AcctSeed__Account__c);
            }  
            
            //Added By Dhinesh - 27/04/2022 - W-007433 - Training Reports for On Hold Projects
            if(Trigger.isUpdate && pr.AcctSeed__Status__c == 'Active' && Trigger.oldMap.get(pr.Id).AcctSeed__Status__c == 'On Hold'){
                pr.Activated_Date_From_On_Hold__c = System.today();
            }
            
            if(Trigger.isUpdate && pr.AcctSeed__Status__c == 'On Hold' && Trigger.oldMap.get(pr.Id).AcctSeed__Status__c == 'Active'){
                pr.Activated_Date_From_On_Hold__c = null;
            }
        }

        if( j > 0 ) {
            OpportunityTrigger_Handler oTH = new OpportunityTrigger_Handler();
            Map<String, Integer> countMap = oTH.getHighestNoForDLSClass(cdRtProAvailable, otherRtypeProAvailable, testRtProAvailable, transRtProAvailable, interPreRtProAvailable);
            System.debug('countMap:::::countMap'+countMap);
            count = (countMap != null && countMap.size() > 0 && countMap.containsKey('otherRecCount')) ? countMap.get('otherRecCount') : 0;
            cdCount = (countMap != null && countMap.size() > 0 && countMap.containsKey('cdRecCount')) ? countMap.get('cdRecCount') : 0;
            testCount = (countMap != null && countMap.size() > 0 && countMap.containsKey('testRecCount')) ? countMap.get('testRecCount') : 0;
            transCount = (countMap != null && countMap.size() > 0 && countMap.containsKey('transRecCount')) ? countMap.get('transRecCount') : 0;
            interPreCount = (countMap != null && countMap.size() > 0 && countMap.containsKey('interPreRecCount')) ? countMap.get('interPreRecCount') : 0;
        }
        
        //Added GLAV2 By Dhinesh - 02/12/2021 - W-007183
        if(accountIdToChangeGLAV2.size() > 0){
            UpdateContAssignStatusAsEnded.accountIdWithRecMap  = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :accountIdToChangeGLAV2]);
        }
        
        for (AcctSeed__Project__c pr : trigger.new) {
            System.debug('pr:::::new'+pr);
           
           Integer dlsClassCount = 0;
           
           if(projRecordTypeIdSet != null && projRecordTypeIdSet.size() > 0 ) {
                if(projRecordTypeIdSet.Contains(pr.RecordTypeId) && pr.AcctSeed__Account__c != null && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(pr.Id).AcctSeed__Account__c != pr.AcctSeed__Account__c && Trigger.oldMap.get(pr.Id).AcctSeed__Account__c == null) )) {
                    if(pr.Delivery_Account__c == null){
                        pr.Delivery_Account__c = pr.AcctSeed__Account__c;                       
                    }
                    if(pr.End_User_Account__c == null) {
                        pr.End_User_Account__c = pr.AcctSeed__Account__c;                        
                    }                    
                }
            }
            
            // To Defaultly set the Admin Project's Account to DLS
            if(pr.RecordTypeId == adminProjRtId ) {
                System_Values__c sysValueDLS = System_Values__c.getValues('DLS Account');
                if(sysValueDLS != null && sysValueDLS.Value__c != null && pr.AcctSeed__Account__c != sysValueDLS.Value__c) {
                    pr.AcctSeed__Account__c = sysValueDLS.Value__c;
                }
            }
            
            if(trigger.isInsert) {
                  
                if(pr.DLS_Class__c == null) {
                    //if(!proRTIds.contains(pr.RecordTypeId)) {
                        if(pr.RecordTypeId != mttRecTypeId) {
                            if(pr.RecordTypeId != cdRecTypeId && !proRTIds.contains(pr.RecordTypeId)) {
                                count = count + 1;
                                dlsClassCount = count;
                            } else if(pr.RecordTypeId == cdRecTypeId) {
                                cdCount = cdCount + 1;
                                dlsClassCount = cdCount;
                            } else if(pr.RecordTypeId == TestProRecTypeId) {
                                testCount = testCount + 1;
                                dlsClassCount = testCount;
                            } else if(pr.RecordTypeId == transRecTypeId) {
                                transCount = transCount + 1;
                                dlsClassCount = transCount;
                            } else if(pr.RecordTypeId == interPreRecTypeId) {
                                interPreCount = interPreCount + 1;
                                dlsClassCount = interPreCount;
                            }
                                                   
                            Integer Year = Date.Today().Year();
                            String str1 = String.valueof(Year).substring(2,4);
                            integer n= dlsClassCount,i;
                            for(i=0;n!=0;i++){
                               n=n/10;
                            }
                            String sizeList;
                            if(i <=5 && i >= 1) {
                                if(i == 1 && pr.RecordTypeId != cdRecTypeId && !proRTIds.contains(pr.RecordTypeId)) sizeList = '0000'+String.ValueOf(dlsClassCount);
                                if((i == 2 && pr.RecordTypeId != cdRecTypeId && !proRTIds.contains(pr.RecordTypeId)) || (i == 1 && (pr.RecordTypeId == cdRecTypeId || pr.RecordTypeId == TestProRecTypeId || pr.RecordTypeId == transRecTypeId || pr.RecordTypeId == interPreRecTypeId))) sizeList = '000'+String.ValueOf(dlsClassCount);
                                if((i == 3 && pr.RecordTypeId != cdRecTypeId && !proRTIds.contains(pr.RecordTypeId)) || (i == 2 && (pr.RecordTypeId == cdRecTypeId || pr.RecordTypeId == TestProRecTypeId || pr.RecordTypeId == transRecTypeId || pr.RecordTypeId == interPreRecTypeId))) sizeList = '00'+String.ValueOf(dlsClassCount);
                                if((i == 4 && pr.RecordTypeId != cdRecTypeId && !proRTIds.contains(pr.RecordTypeId)) || (i == 3 && (pr.RecordTypeId == cdRecTypeId || pr.RecordTypeId == TestProRecTypeId || pr.RecordTypeId == transRecTypeId || pr.RecordTypeId == interPreRecTypeId))) sizeList = '0'+String.ValueOf(dlsClassCount);
                            }
                            
                            String refValue = str1 + sizeList;
                            
                            if(pr.RecordTypeId != cdRecTypeId && !proRTIds.contains(pr.RecordTypeId)) {
                                pr.DLS_Class__c = refValue;
                            } else if(pr.RecordTypeId == cdRecTypeId) {
                                pr.DLS_Class__c = 'CD'+refValue;
                            } else if(pr.RecordTypeId == TestProRecTypeId) {
                                pr.DLS_Class__c = 'TE'+refValue;
                            } else if(pr.RecordTypeId == transRecTypeId) {
                                pr.DLS_Class__c = 'TR'+refValue;
                            } else if(pr.RecordTypeId == interPreRecTypeId) {
                                pr.DLS_Class__c = 'IN'+refValue;
                            }
                            
                        } else if(pr.RecordTypeId == mttRecTypeId) {
                            
                            if(pr.TO__c != null && pr.Project_Type__c != null) {
                                pr.DLS_Class__c = pr.Project_Type__c+pr.TO__c;
                            } 
                        }
                    //}
                } 
            }
            
            //Added by Shalini to update End Date based on Oral_Exam_Date_Time__c for Testing Projects
            if(pr.RecordTypeId == TestProRecTypeId && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(pr.Id).Oral_Exam_Date_Time__c != pr.Oral_Exam_Date_Time__c))){
                pr.End_Date__c = Date.ValueOf(pr.Oral_Exam_Date_Time__c);
            }
            
            // ILR L,R,S Goal related changes from process builder to trigger
            // Added by NS on April 23 2018
            if(Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(pr.Id).ILR_L_Goal__c != pr.ILR_L_Goal__c)){
                if(pr.ILR_L_Goal__c != null && pr.ILR_L_Goal__c != 'N/A')
                    pr.L_Goal_Score_Applicable__c = true;
                else
                    pr.L_Goal_Score_Applicable__c = false;
            }
            if(Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(pr.Id).ILR_R_Goal__c != pr.ILR_R_Goal__c)){
                if(pr.ILR_R_Goal__c != null && pr.ILR_R_Goal__c != 'N/A')
                    pr.R_Goal_Score_Applicable__c = true;
                else
                    pr.R_Goal_Score_Applicable__c = false;
            }
            if(Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(pr.Id).ILR_S_Goal__c != pr.ILR_S_Goal__c)){
                if(pr.ILR_S_Goal__c != null && pr.ILR_S_Goal__c != 'N/A')
                    pr.S_Goal_Score_Applicable__c = true;
                else
                    pr.S_Goal_Score_Applicable__c = false;
            }
            
            // Default Cost Rate Rate Type value population based on Record Type
            // Moved the logic from process builder to trigger by NS on April 23 2018            
            if( Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(pr.Id).RecordTypeId != pr.RecordTypeId || Trigger.oldMap.get(pr.Id).DLI_PRoject_Type__c != pr.DLI_Project_Type__c))) {
                // To update the Rate Type in Project when the DLI Project Type is updated W-006039
                if(pr.AcctSeed__Opportunity__c == null || (pr.AcctSeed__Opportunity__c != null && Trigger.isUpdate && Trigger.oldMap.get(pr.Id).DLI_PRoject_Type__c != pr.DLI_Project_Type__c && pr.DLI_Project_Type__c != 'Partner School')) {
                    
                    if(rtId_RTName.containsKey(pr.RecordTypeId) && proRTName_RateType.containsKey(rtId_RTName.get(pr.RecordTypeId))){
                        
                        // To update the Cost Rate type value based on the Contract provided, Modified by GRK on June 14, 2018
                       
                        if(rtId_RTName.get(pr.RecordTypeId) == 'DLI_W_LT_Projects' && (Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(pr.Id).Contract__c != pr.Contract__c || Trigger.oldMap.get(pr.Id).DLI_PRoject_Type__c != pr.DLI_Project_Type__c) && pr.Default_Cost_Rate_Rate_Type__c == null))) {
                            
                            /*if(pr.Opportunity_Award_Date__c <= date.newinstance(2018, 09, 30)) {
                                if(pr.Contract_Number__c == Label.DLI_16_SCA_LT_Contract_No) {
                                    pr.Default_Cost_Rate_Rate_Type__c = proRTName_RateType.get(rtId_RTName.get(pr.RecordTypeId));
                                } else if (pr.Contract_Number__c == Label.DLI_11_SCA_LT_Contract_No) {
                                    pr.Default_Cost_Rate_Rate_Type__c = 'DLI-11 SCA LT';
                                }
                            } else if (pr.Opportunity_Award_Date__c >= date.newinstance(2019, 10, 01) && pr.Opportunity_Award_Date__c <= date.newinstance(2020,09,30)) {
                                pr.Default_Cost_Rate_Rate_Type__c = 'DLI-20 SCA LT';
                            } else */if(pr.Opportunity_Award_Date__c >= date.newinstance(2020, 10, 01)) {
                                pr.Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA LT';
                            }
                        } else if(Trigger.isInsert) {
                           /* if(pr.Opportunity_Award_Date__c <= date.newinstance(2018, 09, 30)) {
                                pr.Default_Cost_Rate_Rate_Type__c = proRTName_RateType.get(rtId_RTName.get(pr.RecordTypeId));
                            } else */if (rtId_RTName.get(pr.RecordTypeId) == 'MTT_Projects') {
                               /* if(pr.Opportunity_Award_Date__c >= date.newinstance(2019, 10, 01) && pr.Opportunity_Award_Date__c <= date.newinstance(2020,09,30)) { 
                                    pr.Default_Cost_Rate_Rate_Type__c = 'DLI-20 SCA MTT';
                                } else*/ if(pr.Opportunity_Award_Date__c >= date.newinstance(2020, 10, 01)) {
                                    pr.Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA MTT';
                                }
                            }
                        }
                    }
                // To update the Rate Type in Project when the DLI Project Type is updated W-006039
                } else if(pr.AcctSeed__Opportunity__c != null && Trigger.isUpdate && Trigger.oldMap.get(pr.Id).DLI_Project_Type__c != pr.DLI_Project_Type__c && pr.DLI_Project_Type__c == 'Partner School') {
                    pr.Default_Cost_Rate_Rate_Type__c = 'SubK-LT';
                }
            }
            
            // Project Status updation to active based on the start date / oral exam date on records creation & start date / oral exam date updation
            // Added by NS on April 24 2018
            if(pr.AcctSeed__Status__c != null && pr.AcctSeed__Status__c == 'Order'
                && (Trigger.isInsert || (Trigger.isUpdate 
                && (Trigger.oldMap.get(pr.Id).Start_Date__c != pr.Start_Date__c)
                    || Trigger.oldMap.get(pr.Id).Oral_Exam_Date_Time__c != pr.Oral_Exam_Date_Time__c
                    )
                )) {
                
                if(pr.RecordTypeId == TestProRecTypeId && pr.Oral_Exam_Date_Time__c != null) {
                    Date oralDate = date.newinstance(pr.Oral_Exam_Date_Time__c.year(),pr.Oral_Exam_Date_Time__c.month(),pr.Oral_Exam_Date_Time__c.day());
                    if(oralDate <= system.today())
                        pr.AcctSeed__Status__c = 'Active';
                } else if(pr.Start_Date__c < system.today() && pr.End_Date__c < system.today()){
                    pr.AcctSeed__Status__c = 'Ended';
                }else if(pr.Start_Date__c <= system.today() && pr.Start_Date__c != null){
                    pr.AcctSeed__Status__c = 'Active';
                }
                
            // Added by E. Keerthika on 3rd, September 2018
            } else if(!Test.isRunningTest() && Trigger.isUpdate && Trigger.oldMap.get(pr.Id).AcctSeed__Status__c != pr.AcctSeed__Status__c && pr.AcctSeed__Status__c == 'Ended' && !ManageProjectDatescontroller.makeStatusAsEnded) {
                // Display the error message when user manually update the project status as 'Ended' 
                //pr.addError('Please use End Project Button to update the project status as Ended');
                pr.addError('Please use Manage Project Status Button to update the project status as Ended');
            } else if(!Test.isRunningTest() && Trigger.isUpdate && Trigger.oldMap.get(pr.Id).AcctSeed__Status__c != pr.AcctSeed__Status__c && pr.AcctSeed__Status__c == 'On Hold' && !CustomButtonService.isFromManageProjectStatus){
                //Display the error message when user manually update the project status as "On Hold"
                //pr.addError('Please use On Hold Project Button to update the project status as On Hold');
                pr.addError('Please use Manage Project Status Button to update the project status as On Hold');
            }else if(!Test.isRunningTest() && Trigger.isUpdate && Trigger.oldMap.get(pr.Id).AcctSeed__Status__c != pr.AcctSeed__Status__c && pr.AcctSeed__Status__c == 'Canceled' && !CustomButtonService.isFromManageProjectStatus){
                //Display the error message when user manually update the project status as "Canceled"
                pr.addError('Please use Manage Project Status Button to update the project status as Canceled');
            }else if(!Test.isRunningTest() && Trigger.isUpdate && Trigger.oldMap.get(pr.Id).AcctSeed__Status__c != pr.AcctSeed__Status__c && pr.AcctSeed__Status__c == 'Active' && Trigger.oldMap.get(pr.Id).AcctSeed__Status__c == 'On Hold' && !ManageProjectDatescontroller.makeStatusAsActive){
                //Display the error message when user manually update the project status as "Active" from "On Hold"
                pr.addError('Please use Manage Project Status Button to update the project status as Active');
            }else if(!Test.isRunningTest() && Trigger.isUpdate && Trigger.oldMap.get(pr.Id).AcctSeed__Status__c != pr.AcctSeed__Status__c && pr.AcctSeed__Status__c == 'Order' && !CustomButtonService.isFromManageProjectStatus){
                //Display the error message when user manually update the project status as "Order"
                pr.addError('Please use Manage Project Status Button to update the project status as Order');
            }else if(!Test.isRunningTest() && Trigger.isUpdate && Trigger.oldMap.get(pr.Id).End_Date__c != pr.End_Date__c && !ManageProjectDatescontroller.isFromManageProjectDate_Status && (!ContactAssignmentTriggerHandler.isFromCATriggerHandlerForTesting_Pros)){
                //Display the error message when user manually update the project end date
                //W-007480 : Final Progress Report Creation Process Auto Created 3 Duplicate Reports
                //To fix "final report duplicate creation and child records not updated" issues while updating project's end date via project detail page
                pr.addError('Please use Manage Project Dates Button to update the project end date');
            }else if(!Test.isRunningTest() && Trigger.isUpdate && Trigger.oldMap.get(pr.Id).Start_Date__c != pr.Start_Date__c && !ManageProjectDatescontroller.isFromManageProjectDate_Status){
                pr.addError('Please use Manage Project Dates Button to update the project start date');
            }
            
            // W-007915 : Do not send EOT Instructor Survey when CA Status is changed from On Hold to Ended
            // When the Project Status is changed from On Hold to Ended, do not send the EOT GetFeedback survey
            // To query the History records on before update, since after update queries the newly created             
            if(trigger.isUpdate && pr.RecordTypeId != TestProRecTypeId && pr.End_Date__c != null && pr.End_Date__c >= oldDate && Trigger.oldMap.get(pr.Id).AcctSeed__Status__c != pr.AcctSeed__Status__c && pr.AcctSeed__Status__c == 'Ended' && Trigger.oldMap.get(pr.Id).AcctSeed__Status__c != 'On Hold'){
                 // W-007898 : Request to Stop Instructor Surveys for UAE Projects
                // To exclude UAE instructors from sending Get Feedback survey email process
                if(recTypeIdsForSendFeedback.contains(pr.RecordTypeId) && pr.QB_Classification__c != 'OF0UAE' && !pr.Name.contains('UAE')){
                    endedProjIds.add(pr.Id);   
                }
            }
            
            //To update the Bill.com Last Sync Status - if the project is updated after bill.com sync update status to Pending
            if(Trigger.isUpdate && pr.AcctSeed__Status__c == 'Active' && (pr.Bill_com_Sync_Status__c == 'Success' || pr.Bill_com_Sync_Status__c == 'Failure') 
                && !BillDotComUtil.updateFromBillDotComSync){
                
                pr.Bill_com_Sync_Status__c = 'Pending';
            } 
            
            /*********
                - Added By HL on Mar 19 2020
                - Work Item : W-002921 - Time Entry for Testing Projects
                - To prevent the manual updation of Oral Exam Date & Time field because it is updated by related event
                ********/
            if(Trigger.isUpdate && pr.RecordTypeId == TestProRecTypeId && pr.Oral_Exam_Date_Time__c != Trigger.oldMap.get(pr.Id).Oral_Exam_Date_Time__c &&
                !EventHandler.isFromEve && !ContactAssignmentTriggerHandler.isFromCATrigger && pr.Test_Type__c != 'Translation Billable'){ //Added By Dhinesh - 01/11/2021 - W-007174 - Change Oral Exam Date & Time Population for Test Type = Translation Billable
            
                pr.Oral_Exam_Date_Time__c.addError('You can\'t edit this field, please update related event if you want to update the Oral Exam Date & Time');
            }
            
            //Added GLAV2 By Dhinesh - 02/12/2021 - W-007183
            if(projectIdToChangeGLAV2.contains(pr.Id)){
                pr.GL_Variable_2__c = UpdateContAssignStatusAsEnded.getGLVariable2IdForProject(pr);                
            }                           
        }
        if( endedProjIds != null && endedProjIds.size() > 0 ) {
            for( AcctSeed__Project__History ph : [SELECT Id,OldValue,NewValue,parentId,Field FROM AcctSeed__Project__History where parentId IN :endedProjIds and Field ='AcctSeed__Status__c']) {
                if(ph.NewValue == 'Ended') {
                    sendFeedbackFormHelper.duplicateEndedId.add(ph.parentId);
                }
            }
        }
    }
    // end of Trigger is Before
    
    //To use for Project Manager related changes
    //Added by NS on July 25 2019
    Map<Id,Id> proIdManagerId = new Map<Id,Id>();
    
    // Variables to populate PC_Job_Code__c field in project task records
    Map<Id, AcctSeed__Project__c> projIdAndRec = new Map<Id, AcctSeed__Project__c>();
    List<AcctSeed__Project__c> projRecsToSendAnEmail = new List<AcctSeed__Project__c>();
    
    // Variables to populate "Time_Approval_Preference__c" field
    Map<Id, Boolean> projIdAndNoStdApproval = new Map<Id, Boolean>();
    
    // For creating Project specific planned days off records on direct project creation
    // Added by NS on 21.12.2018
    if(trigger.isAfter) {
        
        Set<Id> projIdsToSendEmail = new Set<Id>();
        List<Acctseed__Project__c> projectsEndedToSendMail = new List<Acctseed__Project__c>();
        Map<Id, Acctseed__Project__c> oldProjectsEndedToSendMailMap = new Map<Id, Acctseed__Project__c>();
        
        Set<Id> projIdsToCreateNewARs = new Set<Id>();
        Map<Id, Date> projIdsWithOnHoldDateMap = new Map<Id, Date>();
        Set<Id> programTypeUpdateProjIds = new Set<Id>();
        
        Map<Id, Id> projIdAndGLAV2Id = new Map<Id, Id>();
        List<AcctSeed__Project__c> projectUpdate_MPD = new List<AcctSeed__Project__c>();
   
        Set<Id> projIdsToCreateUpdateDeleteARs = new Set<Id>();
        Set<Id> projIdsToCancelARs = new Set<Id>();
        
        Map<Id, Id> oppIdAndProjId = new Map<Id, Id>();
        List<AcctSeed__Project__c> projsToSendLowHoursBalEmail = new List<AcctSeed__Project__c>();
        Map<Id, Id> projIdAndPIId = new Map<Id, Id>();
        Set<String> excludeProjRTs = new Set<String>{'Testing_Projects', 'Translation_Projects', 'Interpretation_Projects'};
        
        Set<String> costRateTypes = new Set<String>{'LT with Prep', 'LT with Billable Prep', 'LT without Prep', 'LT without Billable Prep'};
        List<AcctSeed__Project__c> projs_CRTChange = new List<AcctSeed__Project__c>();
        Map<Id, Id> projIdAndAccId = new Map<Id, Id>();
        Map<Id, Id> projIdAndParId = new Map<Id, Id>();
        
        if(trigger.isDelete) {
            for(AcctSeed__Project__c pro : trigger.old) {
                if(pro.AcctSeed__Opportunity__c != null && !oppIdStatusValueMap.containsKey(pro.AcctSeed__Opportunity__c)) {
                    oppIdStatusValueMap.put(pro.AcctSeed__Opportunity__c, '');
                }
            } 
        } else {
            Date oldDate = System.today().addDays(-60);
            
            for(AcctSeed__Project__c pro : trigger.new) {
                if(trigger.isInsert){
                    if(pro.RecordTypeId == DLI_W_RTId && pro.Start_Date__c != null && pro.End_Date__c != null 
                        && pro.AcctSeed__Opportunity__c == NULL) {
                        
                        if(!proIdRecMap.containsKey(pro.Id)) {
                            proIdRecMap.put(pro.Id,pro);
                        }
                    }
                }
                
                if(Trigger.isUpdate){
                    
                    /**********
                        - Added by HL on Oct 14 2019 (For Name / DLS_Class__c updation)
                        - Work Item : W-002986 - Create text field on Project Task object labeled "PC Job Code"
                        - To populate "PC Job Code" field in project task records
                        - Added by GRK on Mar 31 2020 (Training Location, Classification, Hourly Rate & Billing Type updation)
                        - Work Item : W-005136 - To have email notifications send to accounting group for any changes on Project
                        - Send an email notification to the Accounting group if any changes in Project\'s Training Location, Classification, Hourly Rate & Billing Type
                        *********/
                    if(pro.Name != Trigger.oldMap.get(pro.Id).Name || pro.DLS_Class__c != Trigger.oldMap.get(pro.Id).DLS_Class__c ||
                        pro.Training_Location__c != Trigger.oldMap.get(pro.Id).Training_Location__c || pro.QB_Classification__c != Trigger.oldMap.get(pro.Id).QB_Classification__c || 
                        pro.Hourly_Rate__c != Trigger.oldMap.get(pro.Id).Hourly_Rate__c || pro.Billing_Type__c != Trigger.oldMap.get(pro.Id).Billing_Type__c){
                        
                        // Added By HL on July 24 2020
                        // Work Item : W-005757 - New concat for PC Job Code
                        if(pro.DLS_Class__c != Trigger.oldMap.get(pro.Id).DLS_Class__c){
                            projIdAndRec.put(pro.Id, pro);
                        }
                        projRecsToSendAnEmail.add(pro);
                    }
                    
                    // Added by HL On Oct 22 2019
                    // Work Item : W-002922 - Student Time Approval Preferences (Daily, Weekly, No Approval)
                    // To populate "Time_Approval_Preference__c" field for related Student Contact Assignment records based on "No_Student_Approval__c" field value
                    if(pro.No_Student_Approval__c != Trigger.oldMap.get(pro.Id).No_Student_Approval__c){
                        projIdAndNoStdApproval.put(pro.Id, pro.No_Student_Approval__c);
                    }
                    
                    //To update the GL Variable 1 and GLAV2
                    if(Trigger.isUpdate && ( (pro.RecordTypeId != Trigger.oldMap.get(pro.Id).RecordTypeId || 
                                    pro.AcctSeed__Account__c != Trigger.oldMap.get(pro.Id).AcctSeed__Account__c ||
                                    pro.QB_Classification__c != Trigger.oldMap.get(pro.Id).QB_Classification__c ||
                                    pro.QB_Contract_Type__c != Trigger.oldMap.get(pro.Id).QB_Contract_Type__c) || pro.Hourly_Rate__c != Trigger.oldmap.get(pro.Id).Hourly_Rate__c)) {
                        glVarUpdateProjs.add(pro);
                    }
                    
                    /*Commented By Dhinesh - 12/7/2022 - W-007513 - Zoom License Agreement changes
                    //Added By Dhinesh - W-006013 - Zoom Integration - to check the zoom user license type when project changed to active or ended
                    if((pro.Number_of_Students_Active__c != Trigger.oldMap.get(pro.Id).Number_of_Students_Active__c)  || 
                        (((pro.AcctSeed__Status__c == 'Ended' && Trigger.oldMap.get(pro.Id).AcctSeed__Status__c != 'Order') || pro.AcctSeed__Status__c == 'Active') && pro.AcctSeed__Status__c != Trigger.oldMap.get(pro.Id).AcctSeed__Status__c)){
                        
                        projectIdsForZoomUserLisenceCheck.add(pro.Id);
                    }*/
                    
                    if(pro.Late_Cancelation__c == 'Yes' && pro.Number_of_Hrs_Charge__c != NULL && 
                        (pro.Late_Cancelation__c != Trigger.oldMap.get(pro.Id).Late_Cancelation__c || 
                        pro.Number_of_Hrs_Charge__c != Trigger.oldMap.get(pro.Id).Number_of_Hrs_Charge__c)){
                    
                        projIdsToSendEmail.add(pro.Id);    
                    }
                    
                    //Added By Dhinesh - 25-08-2021 - To Send Mail to Accounting team when the status is changed to Ended for PVT Accounts
                    if(pro.AcctSeed__Status__c == 'Ended' && pro.AcctSeed__Status__c != Trigger.oldMap.get(pro.Id).AcctSeed__Status__c && pro.Start_Date__c >= Date.valueOf('2020-01-01')){
                        projectsEndedToSendMail.add(pro);
                        oldProjectsEndedToSendMailMap.put(pro.Id, Trigger.oldMap.get(pro.Id));
                    }
                    /*
                        // Added on Nov 03 2021
                        if(pro.End_Date__c != Trigger.oldMap.get(pro.Id).End_Date__c){
                            projIdsToCreateNewARs.add(pro.Id);    
                        }
                    */
                    //Added By Dhinesh - 27/04/2022 - W-007433 - Training Reports for On Hold Projects
                    if(pro.AcctSeed__Status__c != Trigger.oldMap.get(pro.Id).AcctSeed__Status__c && pro.AcctSeed__Status__c == 'On Hold'){
                        projIdsWithOnHoldDateMap.put(pro.Id, pro.On_Hold_Date__c);
                    }  
                    
                    // Added on Mar 27 2023 - W-007750 - Issue with GLAV2 update - To update GLAV2 value in PTs when Project's GLAV2 is updated  
                    if(!UpdateContAssignStatusAsEnded.projectStaticIdSet.contains(pro.Id) && pro.GL_Variable_2__c != Trigger.oldMap.get(pro.Id).GL_Variable_2__c){
                        projIdAndGLAV2Id.put(pro.Id, pro.GL_Variable_2__c);  
                        UpdateContAssignStatusAsEnded.projectStaticIdSet.add(pro.Id);          
                    }         
                    
                    // This logic is built to update all related child records when a project is updated from "Manage Project Dates or Manage Project Status" button
                    if(Trigger.isUpdate && ManageProjectDatescontroller.isFromManageProjectDate_Status && (pro.AcctSeed__Status__c != Trigger.oldMap.get(pro.Id).AcctSeed__Status__c || pro.End_Date__c != Trigger.oldMap.get(pro.Id).End_Date__c || pro.Start_Date__c != Trigger.oldMap.get(pro.Id).Start_Date__c)){
                        projectUpdate_MPD.add(pro);    
                    }
                    
                    // Added on Apr 07 2023
                    // This logic is built to create and update assessment reports when a project is updated from "Manage Project Dates or Manage Project Status" button
                    if(Trigger.isUpdate && ManageProjectDatescontroller.isFromManageProjectDate_Status && ((pro.AcctSeed__Status__c != Trigger.oldMap.get(pro.Id).AcctSeed__Status__c && pro.AcctSeed__Status__c == 'Ended') || pro.End_Date__c != Trigger.oldMap.get(pro.Id).End_Date__c || pro.Start_Date__c != Trigger.oldMap.get(pro.Id).Start_Date__c)){
                                                
                        projIdsToCreateUpdateDeleteARs.add(pro.Id);       
                            
                        if(pro.AcctSeed__Status__c == 'Ended'){
                            ProjectTrigger_Handler.isFromProjectTrigger_StatusUpdate = True;
                        }  
                    }   
                    
                    // If a project is cancelled then no need to update assessment report's due date, just cancel all the reports         
                    if(Trigger.isUpdate && pro.AcctSeed__Status__c != Trigger.oldMap.get(pro.Id).AcctSeed__Status__c && pro.AcctSeed__Status__c == 'Canceled' && CustomButtonService.isFromManageProjectStatus){
                            
                        ProjectTrigger_Handler.isFromProjectTrigger_StatusUpdate = True;     
                        projIdsToCancelARs.add(pro.Id);
                    }   
                    
                    // To send low hours balance email to students and instructors
                    // W-007886 : Exclude UAE Instructors from "Low Hours Remaining for DLS Class #" Email Notification
                    // W-007948 : Exclude Testing Projects from Low Hours Balance Email
                    // PGLS Account Excluded on Mar 07 2024 : W-007863 : The system should Exclude Projects with Accounts = PGLS LLC from the Low Balance Hours Email notification
                    if((pro.Scheduled_Hours_Week__c != Trigger.oldMap.get(pro.Id).Scheduled_Hours_Week__c || pro.Hours_Remaining__c != Trigger.oldMap.get(pro.Id).Hours_Remaining__c) && pro.Hours_Remaining__c <= pro.Scheduled_Hours_Week__c && 
                        !pro.Account_Name__c.contains('PVT') && !pro.Account_Name__c.contains('DLI') && !pro.Account_Name__c.contains('AFSAT') && pro.QB_Classification__c != 'OF0UAE' && !pro.Name.contains('UAE') && 
                        !excludeProjRTs.contains(pro.Project_Record_Type_Name__c) && !pro.Account_Name__c.contains('PGLS') && pro.Account_Name__c != 'Booz Allen Hamilton (BAH)'){
                        
                        projsToSendLowHoursBalEmail.add(pro);
                        if(pro.Account_Name__c.contains('DODA') && pro.Program_Iteration__c != null){
                            projIdAndPIId.put(pro.Id, pro.Program_Iteration__c);
                        }
                    }
                    
                    // Added on Mar 18 2024 : W-008006 : Default Cost Rate and Project Task Mismatch
                    if(pro.Default_Cost_Rate_Rate_Type__c != Trigger.oldMap.get(pro.Id).Default_Cost_Rate_Rate_Type__c && costRateTypes.contains(pro.Default_Cost_Rate_Rate_Type__c)){
                        projs_CRTChange.add(pro);        
                    }                    
                }
                
                // Added by E. Keerthika on 29th, November 2018 to update the project status field in opportunity when the status of the project is changed
                if(pro.AcctSeed__Opportunity__c != null && (trigger.isInsert || trigger.isUpdate && Trigger.oldMap.get(pro.Id).AcctSeed__Status__c != pro.AcctSeed__Status__c)) {
                    if(!oppIdStatusValueMap.containsKey(pro.AcctSeed__Opportunity__c)) {
                        oppIdStatusValueMap.put(pro.AcctSeed__Opportunity__c, pro.AcctSeed__Status__c);
                    } 
                }
                
                //Added by Shalini for sending courseCompletedFeedback on Feb 6 2018
                if(trigger.isUpdate && pro.RecordTypeId != TestProRecTypeId && pro.End_Date__c != null && pro.End_Date__c >= oldDate && Trigger.oldMap.get(pro.Id).AcctSeed__Status__c != pro.AcctSeed__Status__c && pro.AcctSeed__Status__c == 'Ended' && Trigger.oldMap.get(pro.Id).AcctSeed__Status__c != 'On Hold'){
                     // W-007898 : Request to Stop Instructor Surveys for UAE Projects
                    // To exclude UAE instructors from sending Get Feedback survey email process
                    if(recTypeIdsForSendFeedback.contains(pro.RecordTypeId) && !sendFeedbackFormHelper.duplicateEndedId.contains(pro.Id) && pro.QB_Classification__c != 'OF0UAE' && !pro.Name.contains('UAE')) {
                        proIdForCompleteFeedback.add(pro.Id);   
                    }
                }
                
                // Added by NS on April 23 2018
                // CA status updation based on Project Status
                if(pro.AcctSeed__Status__c != null && statusSet.contains(pro.AcctSeed__Status__c) 
                    && (Trigger.isInsert || (Trigger.isUpdate 
                    && (Trigger.oldMap.get(pro.Id).AcctSeed__Status__c != pro.AcctSeed__Status__c || Trigger.oldMap.get(pro.Id).Oral_Exam_Date_Time__c != pro.Oral_Exam_Date_Time__c 
                    || Trigger.oldMap.get(pro.Id).Start_Date__c != pro.Start_Date__c))
                    )
                    ){
                    
                    if(!proIdStatusMap.containsKey(pro.Id)) {
                    
                        if(pro.AcctSeed__Status__c != 'Active') {
                            proIdStatusMap.put(pro.Id,pro.AcctSeed__Status__c);
                        }else if(pro.AcctSeed__Status__c == 'Active'){
                        
                            Date oralExamDate;
                            if(pro.Oral_Exam_Date_Time__c != null)
                                oralExamDate = date.newinstance(pro.Oral_Exam_Date_Time__c.year(),pro.Oral_Exam_Date_Time__c.month(),pro.Oral_Exam_Date_Time__c.day());
                            
                            //Commented because, start date based CA status change isnot needed.
                            //When a project status changed directly update related CA's status without considering start date
                            //W-005324
                            
                            /*if(pro.RecordTypeId == TestProRecTypeId && oralExamDate != null && oralExamDate <= system.today()) {
                                proIdStatusMap.put(pro.Id,pro.AcctSeed__Status__c);
                            }else if(pro.RecordTypeId != TestProRecTypeId && pro.Start_Date__c != null && pro.Start_Date__c <= system.today()){
                                proIdStatusMap.put(pro.Id,pro.AcctSeed__Status__c);
                            } */
                            proIdStatusMap.put(pro.Id,pro.AcctSeed__Status__c);
                        }
                    }
                }
                
                //Get the Projects who's Project Manager Field get populated / changed 
                //Exclude CD Projects from this automation (W-004236)
                
                if(Trigger.isUpdate && Trigger.oldMap.get(pro.Id).Project_Manager__c != pro.Project_Manager__c && pro.Project_Manager__c != null 
                    && pro.RecordTypeId != cdRecTypeId){
                    
                    if(!proIdManagerId.containsKey(pro.Id)){
                        proIdManagerId.put(pro.Id,pro.Project_Manager__c);
                    }
                }
                
                if(Trigger.isUpdate && pro.Program_Type__c != Trigger.OldMap.get(pro.Id).Program_Type__c && pro.AcctSeed__Status__c == 'Active') {
                    programTypeUpdateProjIds.add(pro.Id);
                }
                
                if(Trigger.isInsert && ConvertToProject.isFromConvertToProject && pro.AcctSeed__Opportunity__c != null){
                    oppIdAndProjId.put(pro.AcctSeed__Opportunity__c, pro.Id);
                }            
                
                // W-008024 : Update Account on CA (Student, Staff, Instructor), when there is an update in the Project or Opportunity Account
                if(!OpportunityTrigger_Handler.accPopFromOppTrig && !ConvertToProject.accPopFromConToProj && pro.AcctSeed__Account__c != null && Trigger.isUpdate && pro.AcctSeed__Account__c != Trigger.oldMap.get(pro.Id).AcctSeed__Account__c){
                    projIdAndAccId.put(pro.Id, pro.AcctSeed__Account__c);
                    if(pro.AcctSeed__Opportunity__c != null){
                        projIdAndParId.put(pro.Id, pro.AcctSeed__Opportunity__c);
                    }
                }    
            }
            
            if(projIdAndAccId.size() > 0){
                ProjectTrigger_Handler.accPopFromProjTrig = true;
                ProjectTrigger_Handler.updateContactAssignmentAccount(projIdAndAccId, 'Project');
                if(projIdAndParId.size() > 0){
                    ProjectTrigger_Handler.updateOpp_ProjectAccount(projIdAndParId, projIdAndAccId, 'Project');
                }
            }
            
            if(projectUpdate_MPD.size() > 0){
                ProjectTrigger_Handler.updateChildRecords_MPD();
            }
            
            if(projIdsToCreateUpdateDeleteARs.size() > 0){
                Assessment_Report_Helper.updateAssessmentReports_DueDate(Trigger.new, Trigger.oldMap);
            }
            
            if(!projIdsToCancelARs.isEmpty()){
                Assessment_Report_Helper.updateARToCancelled(projIdsToCancelARs);
            }
            if(projectsEndedToSendMail.size() > 0){
                ProjectTrigger_Handler.sendProjectEndedMailToAccountingGroup(JSON.serialize(projectsEndedToSendMail), JSON.serialize(oldProjectsEndedToSendMailMap));
            }
            
            // W-005871 PT Rate and GL Variable 1 to update the Project task when Project QB Classification and Hourly Rate is updated
            if( glVarUpdateProjs.size() > 0 ) {
                ProjectTrigger_Handler.updateProjectTask(glVarUpdateProjs, Trigger.oldMap);
            }     
            
            //Added By Dhinesh - 27/04/2022 - W-007433 - Training Reports for On Hold Projects
            if(projIdsWithOnHoldDateMap.size() > 0){
                Assessment_Report_Helper.deleteTrainingReportsForOnHoldProjects(projIdsWithOnHoldDateMap);
            }
            
            // Added by GRK to update Type of Training for Training Reports when a Project's Program Type is updated
            /*if(programTypeUpdateProjIds.size() > 0 ) {
                Assessment_Report_Helper.updateAssessReportTypeOfTraining(programTypeUpdateProjIds);
            }*/        
            
            if(projs_CRTChange.size() > 0){
                ProjectTrigger_Handler.sendEmail_CostRateTypeChange(projs_CRTChange);
            }    
        }
            
        if(projIdAndNoStdApproval.size() > 0){
            
            List<Contact_Assignments__c> updateConAssigns = new List<Contact_Assignments__c>();
            
            for(Contact_Assignments__c c : [SELECT Id, Candidate_Name__c, Candidate_Name__r.Time_Approval_Preference__c, Time_Approval_Preference__c, Project__c FROM Contact_Assignments__c WHERE Project__c IN :projIdAndNoStdApproval.keySet() AND RecordType.DeveloperName = 'Student']){
            
                if(projIdAndNoStdApproval.containsKey(c.Project__c)){
                    
                    if(projIdAndNoStdApproval.get(c.Project__c)){
                    
                        c.Time_Approval_Preference__c = 'No Approval';
                    }else{
                        c.Time_Approval_Preference__c = c.Candidate_Name__r.Time_Approval_Preference__c;
                    }
                    updateConAssigns.add(c);
                }
            }
            
            if(updateConAssigns.size() > 0){
                update updateConAssigns;
            }
            
        }
        
        if(proIdRecMap.keySet().size() > 0) {
            OpportunityTrigger_Handler.clonePlannedDaysOff(proIdRecMap,'Project');
        } 
        
        //Added by Shalini for sending courseCompletedFeedback on Feb 6 2018        
        if(proIdForCompleteFeedback.size() > 0) {
            if(sendFeedbackFormHelper.triggerExecution) {
                ProjectTrigger_Handler.isFromProjectTrigger_SendGetFeedback = True;
                sendFeedbackFormHelper.sendEmailForCompleted(proIdForCompleteFeedback,Trigger.new);
                sendFeedbackFormHelper.triggerExecution = false;
            }
        }
        
        //Contact Assingments qry for updation process - Added by NS on April 23 2018
        if(proIdStatusMap.size() > 0){
            if(ContactAssignmentTriggerHandler.isFromCATrigger) {
                System.debug(':::::ContactAssignmentTriggerHandler.isFromCATrigger:::::');
                OpportunityTrigger_Handler.contactAssignmentStatusUpdateFut(proIdStatusMap);
            }else if(!ManageProjectDatescontroller.skipCAStatusUpdate){
                System.debug(':::::ContactAssignmentTriggerHandler.isFromCATrigger:::::1111');
                OpportunityTrigger_Handler.contactAssignmentStatusUpdate(proIdStatusMap);
            }
        }
        
        // Opportunity query fro updation process - Added by E. Keerthika on 29th, November 2018
        System.debug('oppIdStatusValueMap:::::'+oppIdStatusValueMap);
        if(oppIdStatusValueMap != null && oppIdStatusValueMap.size() > 0) {
            OpportunityTrigger_Handler.opportunityUpdateFut(oppIdStatusValueMap);
        }
        System.debug(':::Query Count::::'+Limits.getQueries());
        
        //Call handler method to update the those project related Instructor & Student CA's contact's Supervisor values based on the project Manager
        if(proIdManagerId.size() > 0){
            ProjectTrigger_Handler.updateContactSupervisor(proIdManagerId);
        }
        
        if( proIdManagerId.size() > 0 || programTypeUpdateProjIds.size() > 0) {
            Assessment_Report_Helper.updateAssementReportPM(proIdManagerId,programTypeUpdateProjIds);
        }
        
        if(projIdsToSendEmail.size() > 0){
            ProjectTrigger_Handler.sendPaperTimesheetEmailOnLC(projIdsToSendEmail);
        }
        
        if(projIdAndGLAV2Id.size() > 0){
            UpdateContAssignStatusAsEnded.updateProjAndProjTaskGLV2Field(projIdAndGLAV2Id);
        } 
          
        if(oppIdAndProjId.size() > 0){
            ProjectTrigger_Handler.updateCongaSignTransaction_CTP(oppIdAndProjId);
        }
        
        if(projsToSendLowHoursBalEmail.size() > 0){
            ProjectTrigger_Handler.sendLowHoursBalanceEmail(projsToSendLowHoursBalEmail, projIdAndPIId);
        }
    }
    // End of NS Code  
    
    if(projIdAndRec.size() > 0){
        
        List<AcctSeed__Project_Task__c> taskRecs = new List<AcctSeed__Project_Task__c>();
        
        for(AcctSeed__Project_Task__c t : [SELECT Id, Name, PC_Job_Code__c, AcctSeed__Project__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN : projIdAndRec.keySet()]){
            
            if(t.AcctSeed__Project__c != NULL && projIdAndRec.containsKey(t.AcctSeed__Project__c)){
                
                if(t.AcctSeed__Project__r.RecordType.DeveloperName == 'DLI_W_LT_Projects'){
                    t.PC_Job_Code__c = projIdAndRec.get(t.AcctSeed__Project__c).DLS_Class__c+'-DLI-'+t.Id;
                }else{
                    t.PC_Job_Code__c = projIdAndRec.get(t.AcctSeed__Project__c).DLS_Class__c+'-'+t.Id;
                }
                taskRecs.add(t);
            }
        }
        
        if(taskRecs.size() > 0){
            
            update taskRecs;
        }
    }
    
    if(projRecsToSendAnEmail.size () > 0){
    
        ProjectTrigger_Handler.toSendAnEmailToAccGrp(projRecsToSendAnEmail, Trigger.oldMap);
    }
    
    /***************
        - Added by HL on Aug 07 2019
        - Populate Contract field value in Project Task records from Project while populating contract value on project
        - W-002222 : Lookup Search Filter for CLIN assignment on Project Task
    *******************/
    if(Trigger.isAfter){
        
        // Variables related to Moodle Integration
        Set<Id> projIds = new Set<Id>();
        Map<Id, String> projIdAndAllStdFirstName = new Map<Id, String>();
        List<AcctSeed__Project__c> updateProjs = new List<AcctSeed__Project__c>();
        
        if(Trigger.isUpdate){
        
            Map<Id, Id> projIdAndContractId = new Map<Id, Id>();
                                    
            for(AcctSeed__Project__c p : Trigger.new){
            
                if(p.Contract__c != Trigger.oldMap.get(p.Id).Contract__c){
                
                    projIdAndContractId.put(p.Id, p.Contract__c);
                }    
                
                // Added By HL on Aug 21 2020
                // Moodle Integration Purpose
                if(p.Moodle_Course_Id__c != null && (p.Name != Trigger.oldMap.get(p.Id).Name || p.Language__c != Trigger.oldMap.get(p.Id).Language__c ||
                    p.Start_Date__c != Trigger.oldMap.get(p.Id).Start_Date__c || p.DLS_Class__c != Trigger.oldMap.get(p.Id).DLS_Class__c)){
                
                    projIds.add(p.Id);
                }               
            }
            
            if(projIdAndContractId.size() > 0){
                                
                List<AcctSeed__Project_Task__c> projTasks = [
                    SELECT Id, AcctSeed__Project__c, Contract__c
                    FROM AcctSeed__Project_Task__c
                    WHERE AcctSeed__Project__c IN : projIdAndContractId.keySet()
                ];
                
                if(projTasks.size() > 0){
                
                    List<AcctSeed__Project_Task__c> updateProjTasks = new List<AcctSeed__Project_Task__c>();
                    
                    for(AcctSeed__Project_Task__c pt : projTasks){
                    
                        if(projIdAndContractId.containsKey(pt.AcctSeed__Project__c)){
                            
                            pt.Contract__c = projIdAndContractId.get(pt.AcctSeed__Project__c);
                            updateProjTasks.add(pt);
                        }
                    }
                    
                    if(updateProjTasks.size() > 0){
                        update updateProjTasks;
                    }
                }
            }   
            
            if(projIds != NULL && projIds.size() > 0){
                
                // Map to store all related Student's FirstName
                projIdAndAllStdFirstName = UserManagementUtil.getAllStdFirstNameForProject(projIds);
                
                Integer currentYear = System.Today().year();
                
                for(AcctSeed__Project__c p : [SELECT Id, Moodle_Sync_Status__c, Course_Name__c, DLS_Class__c, Language__r.Name
                                                FROM AcctSeed__Project__c
                                                WHERE Id IN : projIds]){
                
                    p.Moodle_Sync_Status__c = 'Pending';
                    
                    if(projIdAndAllStdFirstName != NULL && projIdAndAllStdFirstName.containsKey(p.Id)){
                        p.Course_Name__c = p.DLS_Class__c +'-'+projIdAndAllStdFirstName.get(p.Id)+'-'+p.Language__r.Name+'-'+currentYear;
                    }
                    updateProjs.add(p);
                }
                
                if(updateProjs != NULL && updateProjs.size() > 0){
            
                    update updateProjs;
                }
            }                     
        }
    }  
    
    /*Commented By Dhinesh - 12/7/2022 - W-007513 - Zoom License Agreement changes
    //Added By Dhinesh - W-006013 - Zoom Integration - to check the zoom user license type when project changed to active or ended
    if(projectIdsForZoomUserLisenceCheck.size() > 0){
        Set<Id> instructorIds = new Set<Id>();
        for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c FROM Contact_Assignments__c 
                                         WHERE Project__c IN :projectIdsForZoomUserLisenceCheck 
                                         AND RecordType.DeveloperName = 'Instructor']){
                                             
                                             instructorIds.add(ca.Candidate_Name__c);
                                         }
        ProjectTrigger_Handler.checkZoomUserLicenseTypesForInstructor(instructorIds);
    }*/
}