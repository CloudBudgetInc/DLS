public class Assessment_Report_Helper{
            
    // Added on Dec 30 2022
    public static Id dliRTId_Proj = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
   
    // Added on Apr 24 2023
    public static Map<Id, Integer> projIdAndLPROrder = new Map<Id, Integer>();
    public static Boolean isFromDCAT = False;
    
    // Added on July 27 2023 : W-007851 : Request to Prevent Initial Test Reports Creation on SLP Familiarization Projects
    public static Set<String> programTypesToExludeInitialTestReports = new Set<String>{'Initial acquisition', 'Familiarization'};
        
    public static void createAssessReport(Set<Id> projId, String launchedFrom, Map<String, String> reportVal, Map<Id,Assessment_Report__c> projARMap) {
         
        List<Assessment_Report__c> reports = new List<Assessment_Report__c>();
        Map<Id,List<Contact_Assignments__c>> projStudentsMap = new Map<Id,List<Contact_Assignments__c>>();
        Map<Id,List<String>> projIdReportTypes = new Map<Id,List<String>>();
        Map<Id,AcctSeed__Project__c> projMap = new Map<Id,AcctSeed__Project__c>();
        Map<String, List<Assessment_Report__c>> projIdARTypeARMap = new Map<String, List<Assessment_Report__c>>();
        Map<Id,List<Date>> projIdMonthlyDates = new Map<Id,List<Date>>();
        // To exclude the creation of monthly Report when thr is a final report for the project on the end date
        Map<String,Date> projIdFinalDate = new Map<String,Date>(); 
        Boolean formMonthlyDate, isFromPvt = false; //formEvMidDate
        Map<Id, Id> projIdAndInsId = new Map<Id, Id>();
        Map<Id, Id> projIdAndLTCoordId = new Map<Id, Id>();
        Map<Id,Id> projIdAndTOIdMap = new Map<Id,Id>();
        Set<Date> holSet = new Set<Date>(); // Holiday Set
        Map<Id,Boolean> projFinalReportMap = new Map<Id,Boolean>();
        Map<Id, Id> projIdAndProjTaskId = new Map<Id, Id>();
        Map<Id, Decimal> projIdAndTotalHours = new Map<Id, Decimal>();
        Boolean dLIObsReport = false;
        List<Contact_Assignments__c> cas = new List<Contact_Assignments__c>();
                
        // Midterm Progress Report Mid Event Date formation Variable
        //Set<Id> projIdForEventDate = new Set<Id>();
        //Map<Id,Date> proIdMidDateMap = new Map<Id,Date>();
        
        // Queries or values to use it in Code
        Id APMORTId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('APMO_Progress').getRecordTypeId();
        Id DEARTId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DEA_Progress').getRecordTypeId();
        Id DLIRTId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Progress_2022').getRecordTypeId(); // DLI_W_Progress updated to DLI_W_Progress_2022 W-007585
        Id ltRTId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Language_Training_Progress').getRecordTypeId();
        Id testRTId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Test_Report').getRecordTypeId();
        
        Id dli_Test_Report_RTId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Test_Report').getRecordTypeId();
        Id dli_Self_Test_Report_RTId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Self_Assessment_Test_Report').getRecordTypeId();
                
        List<AcctSeed__Project__c> projects = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',projId,',AcctSeed__Account__r.Name, Language__r.Name, Program_Iteration__r.Project_Type__c,Program_Iteration__r.Final_Progress_Due_Date__c,Program_Iteration__r.Midterm_Progress_Due_Date__c,Program_Iteration__r.Start_Date__c,Program_Iteration__r.End_Date__c,Program_Iteration__r.Program_Type__c,RecordType.DeveloperName');
        System.debug(':::projects:::'+projects);
       
        // Added on Nov 03 2021
        Set<Id> projIdsToQueryExistingARs = new Set<Id>();
        Map<Id, Set<Date>> projIdAndExistingARDates = new Map<Id, Set<Date>>();
        Set<Id> activatedProjIdsAfterOnhold = new Set<Id>();
        
        // Added on July 01 2022
        Set<Id> finalReportProjIds = new Set<Id>();
        
        //Include the report date to create monthly AR record when project's end date is updated
        Map<Date, String> reportDateAndLTS = new Map<Date, String>();
        
        Set<String> projId_ConId_RTId_RepDate_Set = new Set<String>();
        Set<String> projId_ConId_RTId_RepDate_RTyp_TestRTyp_LRS_Set = new Set<String>();
        
        for(Schedule__c sc : [SELECT Id,Name,Project__c,Instructor__c FROM Schedule__c WHERE Project__c IN :projId and Status__c = 'Active' AND Project_Task__r.Project_Task_Type__c = 'Language Training' ORDER BY CreatedDate ASC]) {
            if(sc.Instructor__c != null && !projIdAndInsId.containskey(sc.Project__c)) {
                projIdAndInsId.put(sc.Project__c, sc.Instructor__c);
            }
        } 
        
        if(projId != null && projId.size() > 0){
        
            for(Contact_Assignments__c ca : ContactAssignmentService.getContactassignmentByparentIds(projId,new Set<String>{'Active','Planned'},new Set<String>{'Student', 'Staff', 'Client_Partner', 'Instructor'}, ', Candidate_Name__r.FirstName, Candidate_Name__r.LastName, RecordType.DeveloperName, Candidate_Name__r.DLS_User__c,Project__r.DLS_Ref__c')) { //'Instructor'
                if(ca.RecordType.DeveloperName == 'Student') {
                    if(!projStudentsMap.containskey(ca.Project__c)){
                        projStudentsMap.put(ca.Project__c, new List<Contact_Assignments__c>());
                    }
                    projStudentsMap.get(ca.Project__c).add(ca);
                } /*else if(ca.RecordType.DeveloperName == 'Instructor' && ca.Assignment_Position__c == 'Instructor') {
                    if(!projIdAndInsId.containskey(ca.Project__c)) {
                        projIdAndInsId.put(ca.Project__c, ca.Candidate_Name__c);
                    }
                } */else if(ca.RecordType.DeveloperName == 'Staff' && ca.Assignment_Position__c == 'Project Support' && ca.Candidate_Name__r.DLS_User__c != null) {
                    if(!projIdAndLTCoordId.containskey(ca.Project__c)) {
                        projIdAndLTCoordId.put(ca.Project__c, ca.Candidate_Name__r.DLS_User__c);
                    }
                } else if(ca.RecordType.DeveloperName == 'Client_Partner' && ca.Assignment_Position__c == 'Training Officer') {
                    if(!projIdAndTOIdMap.containskey(ca.Project__c)) {
                        projIdAndTOIdMap.put(ca.Project__c, ca.Candidate_Name__c);
                    }
                // Used to create Observation Report for the DLI Account Projects
                } else if(ca.RecordType.DeveloperName == 'Instructor' && projIdAndInsId.containskey(ca.Project__c) && projIdAndInsId.get(ca.Project__c) == ca.Candidate_Name__c) {
                    cas.add(ca);
                }
                
            }
        }
                
        holSet = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
        //Updated By Dhinesh - 31-03-2022 - W-007418 - Remove Initial for FAS/PVT/Other/FCS
        Map<String, List<String>> AccountNameARMap = new Map<String, List<String>>{
            //'FAS' => new List<String>{'Midterm'}, 
            //'FCS' => new List<String>{'Midterm','Final Report'},
            //'PVT' => new List<String>{'Final Report'},
            //'JMAS' => new List<String>{'Final Report'}, Commented on Dec 12 2023 : W-007944 : Request to Stop Auto-Creation of Final PR Reports on JMAS Projects
            'FAS' => new List<String>{'Final Report'},
            'FCS' => new List<String>{'Monthly'}, 
            'FCS2' => new List<String>{'Final Report'},
            'PVT' => new List<String>{'Final Report'},
            'DLI' => new List<String>{'Monthly', 'Monthly_Test_Report', 'Monthly_Self_Test_Report'},
            'APMO' => new List<String>{'Monthly'},  // new Monthly Reports similar to DLI
            'SLP' => new List<String>{'Progress', 'Final Report','Initial Test Report','Final Test Report'}, // updated Midterm to Progress
            'Ad-hoc' => new List<String>{'Monthly', 'Final Report','Initial Test Report','Final Test Report'},
            'PLP' => new List<String>{'Final Report'},
            'PGLS' => new List<String>{'Monthly'},
            'Other' => new List<String>{'Final Report'} // All other accounts except the above listed
        };
        
        // To get the Label of the Program Type pikclist field from Project
        Map<String,String> typeApiToLabelMap = new Map<String,String>();
        typeApiToLabelMap = toGetProgramTypeLblVal();
        
        // To check the Proj has Langugae Training Project Task with hours planned less than 300
        for(AcctSeed__Project_Task__c pt: [Select Id,Name,Total_Qty_Planned__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN: projId AND Project_Task_Type__c = 'Language Training' AND (NOT Name LIKE '%Additional%')]) {
            // Create Final Reports for 'FAS/PVT/All Other Accounts' without considering the hours
            /*if(pt.Total_Qty_Planned__c < 300) {
                projFinalReportMap.put(pt.AcctSeed__Project__c, true);
            }*/ 
            projIdAndProjTaskId.put(pt.AcctSeed__Project__c, pt.Id);
            projIdAndTotalHours.put(pt.AcctSeed__Project__c, pt.Total_Qty_Planned__c);
        }
        
        
        // To determine the different reports that needs to be created for the Project
        for( AcctSeed__Project__c pr : projects ) {
            
            Date lastDate;
            projMap.put(pr.Id,pr);
            
            projIdsToQueryExistingARs.add(pr.Id);
            
            if(pr.Activated_Date_From_On_Hold__c != null){
                activatedProjIdsAfterOnhold.add(pr.Id);
            }
            
            // W-007837 : Create new FSI Labor Cost Rate Rate Type & Offer Letter (SEP-1-2023)
            // Should not create training reports for FSI projects
            // JMAS project type condition Added on May 15 2024 : W-008048 - JMAS Projects - No Longer Need Initial and Final assessments/reports/scores : To prevent the auto creation of training reports for DODA project with JMAS project type
            if(pr.AcctSeed__Account__c != null && pr.AcctSeed__Account__r.Name != null && pr.DLI_Project_Type__c != 'EI' && !pr.AcctSeed__Account__r.Name.contains('FSI') && pr.RecordType.DeveloperName != 'FSI_Projects' && pr.Project_Type__c != 'JMAS') {
            
                if(pr.AcctSeed__Account__r.Name.contains('DLI') || pr.RecordTypeId == dliRTId_Proj) {
                    projIdReportTypes.put(pr.Id,AccountNameARMap.get('DLI'));
                    formMonthlyDate = true;
                    dLIObsReport = true;
                } else if((pr.AcctSeed__Account__r.Name == 'PVT' || pr.AcctSeed__Account__r.Name.contains('PVT')) && pr.QB_Classification__c != 'OF0MTT0PS') {  //&& projFinalReportMap.containskey(pr.Id) && projFinalReportMap.get(pr.Id) == true
                    projIdReportTypes.put(pr.Id,AccountNameARMap.get('PVT'));
                    isFromPvt = true;
                } else if(pr.AcctSeed__Account__r.Name.contains('DODA') && pr.QB_Classification__c != 'OF0MTT0PS') { 
                    // Added QB_Classification__c condition on June 16 2023
                    // W-007783 : Issue with DLI Training Report Auto Cancellation when DLI Project End Date isChanged 
                    // To prevent reports creation for partner school projects 
                    if(pr.Program_Iteration__c != null) {
                        if( pr.Program_Iteration__r.Project_Type__c == 'SLP-FT' || pr.Program_Iteration__r.Project_Type__c == 'SLP-PT'){
                            // Modified on Jan 19 2023: W-007686 - Request to remove Initial Test Reports from SLP Initial Acquisition Projects
                            // Initial Test Report will not created for DODA Projects with Project Type = SLP-FT or SLP-PT and Program Type = Familiarization or Initial acquisition
                            if(!programTypesToExludeInitialTestReports.contains(pr.Program_Type__c)){
                                projIdReportTypes.put(pr.Id,AccountNameARMap.get('SLP'));
                            }else{
                                projIdReportTypes.put(pr.Id,new List<String>{'Progress', 'Final Report','Final Test Report'});
                            }
                        } 
                        // Commented on Dec 12 2023 : W-007944 : Request to Stop Auto-Creation of Final PR Reports on JMAS Projects
                        /*else if( pr.Program_Iteration__r.Project_Type__c == 'JMAS') {
                            projIdReportTypes.put(pr.Id,AccountNameARMap.get('JMAS'));
                        } */
                        else if( pr.Program_Iteration__r.Project_Type__c == 'PLP') {
                            projIdReportTypes.put(pr.Id,AccountNameARMap.get('PLP'));
                        }
                    } else {
                        projIdReportTypes.put(pr.Id,AccountNameARMap.get('Ad-hoc'));
                        formMonthlyDate = true;
                    }
                } else if(pr.AcctSeed__Account__r.Name.contains('FCS')) { 
                    if(pr.AcctSeed__Account__r.Name != 'FCS2') {
                        projIdReportTypes.put(pr.Id,AccountNameARMap.get('FCS'));
                        formMonthlyDate = true;
                    //} else if(pr.AcctSeed__Account__r.Name == 'FCS2' && projFinalReportMap.containskey(pr.Id) && projFinalReportMap.get(pr.Id) == true){
                    } else if(pr.AcctSeed__Account__r.Name == 'FCS2') {
                        projIdReportTypes.put(pr.Id,AccountNameARMap.get('FCS2'));
                    }
                //} else if(pr.AcctSeed__Account__r.Name.contains('FAS') && projFinalReportMap.containskey(pr.Id) && projFinalReportMap.get(pr.Id) == true) {
                } else if(pr.AcctSeed__Account__r.Name.contains('FAS')) {
                    projIdReportTypes.put(pr.Id,AccountNameARMap.get('FAS'));
                    //formEvMidDate = true;
                    //projIdForEventDate.add(pr.Id);
                } else if(pr.AcctSeed__Account__r.Name.contains('APMO')) {
                    projIdReportTypes.put(pr.Id,AccountNameARMap.get('APMO'));
                    formMonthlyDate = true;
                } else if(pr.AcctSeed__Account__r.Name.contains('PGLS')) {
                    projIdReportTypes.put(pr.Id,AccountNameARMap.get('PGLS'));
                    formMonthlyDate = true;
                } else if(pr.AcctSeed__Account__c != null){ // For all other Accounts create Final Reports
                    projIdReportTypes.put(pr.Id,AccountNameARMap.get('Other'));
                }
                System.debug(':::::projIdReportTypes::::*****:::'+projIdReportTypes);
                
                if((launchedFrom == 'PVTButton' || launchedFrom == 'ProjectTask') && reportVal.size() > 0) {
                    List<String> reportList = new List<String>();
                    if(reportVal.containskey('Language_Training_Status__c')){
                        reportList.add(reportVal.get('Language_Training_Status__c'));
                    }
                    System.debug(':::::reportList::::*****:::'+reportList);
                    if(reportVal.containskey('Test_Report_Type__c')){
                        reportList.add(reportVal.get('Test_Report_Type__c'));                        
                    }
                    
                    // set report date as Monthly Date if user selected the Monthly Report from PVTButton
                    // Commented on Nov 18 2022
                    /*
                    if(reportVal.containskey('Report_Date__c') && launchedFrom == 'PVTButton' && (!reportVal.containskey('Language_Training_Status__c') || (reportVal.containskey('Language_Training_Status__c') && reportVal.get('Language_Training_Status__c') != 'Monthly'))){    //Modified on Nov 11 2022
                        String mDate = reportVal.get('Report_Date__c'); 
                        projIdMonthlyDates.put(pr.Id, new List<Date>{Date.parse(mDate)});
                    }
                    */
                    // In Create PR/Test Report button logic for DLI Projects we are showing only Monthly option but we have to create all 3 reports (Monthly/Monthly_Test_Report/Monthly_Self_Test_Report)
                    if(!pr.AcctSeed__Account__r.Name.contains('DLI') && pr.RecordTypeId != dliRTId_Proj){
                        projIdReportTypes.put(pr.Id, reportList);
                    }
                }
                System.debug(':::::projIdReportTypes::::***&&*:::'+projIdReportTypes);           
                if(formMonthlyDate == true && pr.End_Date__c != null && pr.Start_Date__c != null) {
                    // To form the months for which the Progress Report needs to be sent
                    Date stDate = pr.Start_Date__c;
                    // to get the end date of the current start date
                    stDate = stDate.addMonths(1).toStartOfMonth().addDays(-1);
                    Integer i = 0;
                    
                    System.debug('::stDate:::'+stDate);
                    
                    while(stDate <= pr.End_Date__c) {
                                        
                        DateTime dtTim1 = DateTime.newInstance(stDate, Time.newInstance(0, 0, 0, 0));                     
                        String dayOfWeek = dtTim1.format('EEEE');
                        
                        System.debug('::dayOfWeek:::'+dayOfWeek);
                        System.debug('::stDate:::'+stDate);
                        System.debug('::::holSet.contains(stDate)::'+holSet.contains(stDate));
                        
                        if(!holSet.contains(stDate)) {
                        
                            if(dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday') {
                            
                                System.debug(':::pr.AcctSeed__Account__r.Name.contains::::'+pr.AcctSeed__Account__r.Name.contains('PGLS'));
                                System.debug(':::(pr.Start_Date__c.day() < 11 && i == 0)::::'+(pr.Start_Date__c.day() < 11 && i == 0));
                                System.debug('::i Value::::'+i);
                                
                                System.debug('::projIdMonthlyDates::First::'+projIdMonthlyDates);
                                
                                if(!projIdMonthlyDates.containskey(pr.Id)) {
                                    
                                    if((!pr.AcctSeed__Account__r.Name.contains('DLI') && !pr.AcctSeed__Account__r.Name.contains('FCS') && !pr.AcctSeed__Account__r.Name.contains('APMO') && !pr.AcctSeed__Account__r.Name.contains('PGLS') && pr.RecordTypeId != dliRTId_Proj) || 
                                        ((pr.AcctSeed__Account__r.Name.contains('DLI') || pr.AcctSeed__Account__r.Name.contains('FCS') || pr.AcctSeed__Account__r.Name.contains('APMO') || pr.AcctSeed__Account__r.Name.contains('PGLS') || pr.RecordTypeId == dliRTId_Proj) && ((pr.Start_Date__c.day() < 11 && i == 0) || i > 0))) {  
                                        
                                        projIdMonthlyDates.put(pr.Id, new List<Date>{stDate});
                                    }
                                } else {
                                    projIdMonthlyDates.get(pr.Id).add(stDate);
                                    if(pr.End_Date__c.month() == stDate.month()) {
                                        lastDate = stDate;
                                    }
                                }
                                System.debug('::projIdMonthlyDates::Second::'+projIdMonthlyDates);
                                // To find end date of the next month
                                stDate = stDate.addMonths(2).toStartOfMonth().addDays(-1);
                                //i = i+1; // To increment on loop so that the first month is excluded when
                                
                                System.debug('::stDate:AA:'+stDate);
                                
                                if((pr.AcctSeed__Account__r.Name.contains('DLI') || pr.AcctSeed__Account__r.Name.contains('FCS') || pr.AcctSeed__Account__r.Name.contains('APMO') || pr.AcctSeed__Account__r.Name.contains('PGLS') || pr.RecordTypeId == dliRTId_Proj) && i == 0){
                                    if(pr.End_Date__c.month() == stDate.month()){
                                        if(pr.End_Date__c < stDate && pr.End_Date__c.day() > 10){
                                            stDate = pr.End_Date__c;
                                        }    
                                    }
                                }
                                
                                System.debug('::stDate:BB:'+stDate);
                                
                                i = i+1; // To increment on loop so that the first month is excluded when   
                            } else {
                                stDate = stDate.addDays(-1);
                            }
                        } else {
                            stDate = stDate.addDays(-1);
                        }
                        if(pr.End_Date__c.month() == stDate.month() && pr.End_Date__c.day() > 10) {
                            lastDate = stDate;
                        }
                    }
                    System.debug('::::::projIdMonthlyDates:====::'+projIdMonthlyDates);
                    // To add the End Date of the project if the Date is greater than 10 and the DLI account related project
                    if((pr.AcctSeed__Account__r.Name.contains('DLI') || pr.AcctSeed__Account__r.Name.contains('FCS') || pr.AcctSeed__Account__r.Name.contains('APMO') || pr.AcctSeed__Account__r.Name.contains('PGLS') || pr.RecordTypeId == dliRTId_Proj) && pr.End_Date__c.day() > 10){
                        
                        if(projIdMonthlyDates.containskey(pr.Id) && lastDate != null && !projIdMonthlyDates.get(pr.Id).contains(lastDate)){
                            projIdMonthlyDates.get(pr.Id).add(pr.End_Date__c);
                        }
                        // W-008052 : APMO Project Failed to Auto-create Monthly Progress Report
                        // Auto-create training reports for the projects (excluding the PGLS project) with a short date range (within one month).
                        if(!pr.AcctSeed__Account__r.Name.contains('PGLS') && pr.Start_Date__c.day() < 11 && !projIdMonthlyDates.containskey(pr.Id)){
                            projIdMonthlyDates.put(pr.Id, new List<Date>{pr.End_Date__c});   
                        }
                    }
                }
            }
        }    
        System.debug('::::::projIdMonthlyDates:####::'+projIdMonthlyDates);
        System.debug('::::::projIdsToQueryExistingARs:::'+projIdsToQueryExistingARs);
        
        if(projIdsToQueryExistingARs.size() > 0){
            for(Assessment_Report__c ar : AssessmentReportService.getAssessmentReportsByprojIds(projIdsToQueryExistingARs, '', '')) {
                if(!projIdAndExistingARDates.containsKey(ar.Project__c)){
                    projIdAndExistingARDates.put(ar.Project__c, new Set<Date>());
                }   
                projIdAndExistingARDates.get(ar.Project__c).add(ar.Report_Date__c);
                if(ar.Language_Training_Status__c == 'Final'){
                    finalReportProjIds.add(ar.Project__c);
                    reportDateAndLTS.put(ar.Report_Date__c, ar.Language_Training_Status__c);
                }
                
                if(ar.Student__c != null){
                
                    String projId_ConId_RTId_RepDate = ar.Project__c+''+ar.Student__c+''+ar.RecordTypeId+''+String.valueOf(ar.Report_Date__c);
                    projId_ConId_RTId_RepDate_Set.add(projId_ConId_RTId_RepDate);
                    
                    // Added on Nov 11 2022
                    String projId_ConId_RTId_RepDate_RT_TRT_LTS = ar.Project__c+''+ar.Student__c+''+ar.RecordTypeId+''+String.valueOf(ar.Report_Date__c)+''+ar.Report_Type__c+''+ar.Test_Report_Type__c+''+ar.Language_Training_Status__c;
                    projId_ConId_RTId_RepDate_RTyp_TestRTyp_LRS_Set.add(projId_ConId_RTId_RepDate_RT_TRT_LTS);
                }
            } 
        }
        
        System.debug(':::projIdAndExistingARDates:::'+projIdAndExistingARDates);
        //To form the Event Mid Date to populate as the Report date in Midterm Progress Report for the FCS and FAS Projects
        /* 
        if(formEvMidDate == true) {
            Map<Id, List<Date>> projIdEventDateMap = new Map<Id,List<Date>>();
            for(Events__c ev : [Select Id,Date__c,Status__c,Project__c FROM Events__c WHERE Project__c IN: projIdForEventDate AND Status__c IN ('Scheduled', 'Completed') Order by Date__c ASC]) {
                if(!projIdEventDateMap.containskey(ev.Project__c)) {
                    projIdEventDateMap.put(ev.Project__c, new List<Date>());
                }   
                projIdEventDateMap.get(ev.Project__c).add(ev.Date__c);
            } 
            for(Id pId : projIdEventDateMap.keySet()) {
                List<Date> eventDates = projIdEventDateMap.get(pId);
                if(eventDates != null && eventDates.size() > 0 ) {
                    Integer lth = eventDates.size()/2; // To get the half length of the Event dates
                    proIdMidDateMap.put(pId, eventDates[lth]); 
                    // Example 50/2 = 25, but the index will point to 26th date, since 50 is an Even count
                    // Example 51/2 = 25, but the index will point to 26th date, since to get the center most date
                } 
            }  
            System.debug('proIdMidDateMap:::::'+proIdMidDateMap);   
        } 
        */
        System.debug(':::::projIdReportTypes:::::::'+projIdReportTypes);
        // To form the Assessment Report for the projects for every Report Type
        // Eg: If the Project is of FCS account, then here we will form 2 Reports, 1 - Midterm Report and Final Report
        if(projIdReportTypes.size() > 0 ) {
            for(String proId : projIdReportTypes.keySet()) {
                AcctSeed__Project__c pr = projMap.get(proId);
                for( String str : projIdReportTypes.get(proId)) {
                        Assessment_Report__c ar = new Assessment_Report__c();
                        String nameSuf = '';
                        
                        if(str == 'Final Report' || (launchedFrom == 'PVTButton' && str == 'Final')) {
                            if(pr.AcctSeed__Account__r.Name.contains('DODA') && pr.Program_Iteration__c != null) {
                                ar.Report_Date__c = pr.Program_Iteration__r.Final_Progress_Due_Date__c;
                                ar.Evaluation_Period_From__c = pr.Program_Iteration__r.Start_Date__c;
                                ar.Evaluation_Period_To__c = pr.Program_Iteration__r.End_Date__c;
                            } else {
                                // When launched from Button in Assessment Report, we get information from the screen
                                if(launchedFrom == 'PVTButton' && reportVal.size() > 0) {
                                    ar.Report_Date__c = reportVal.containskey('Report_Date__c')? date.parse(reportVal.get('Report_Date__c')): null;
                                    ar.Evaluation_Period_From__c = pr.Start_Date__c;
                                    ar.Evaluation_Period_To__c = pr.End_Date__c;
                                } else {
                                    //ar.Report_Date__c = pr.End_Date__c.addDays(-7);
                                    ar.Report_Date__c = pr.End_Date__c; 
                                    ar.Evaluation_Period_From__c = pr.Start_Date__c;
                                    ar.Evaluation_Period_To__c = pr.End_Date__c;
                                    
                                    // To exclude the creation of monthly Report when thr is a final report for the project on the end date
                                    if( formMonthlyDate == true) {
                                        projIdFinalDate.put(pr.Id, ar.Report_Date__c);
                                    }
                                }
                            }
                            ar.Language_Training_Status__c = 'Final';
                            ar.Test_Report_Type__c = 'Final';
                            ar.Test_Format__c = 'In-Class Assessment';
                        } else if(str == 'Progress') {
                            if(pr.AcctSeed__Account__r.Name.contains('DODA') && pr.Program_Iteration__c != null) {
                                ar.Report_Date__c = pr.Program_Iteration__r.Midterm_Progress_Due_Date__c;
                                ar.Evaluation_Period_From__c = pr.Program_Iteration__r.Start_Date__c;
                                ar.Evaluation_Period_To__c = pr.Program_Iteration__r.Midterm_Progress_Due_Date__c;
                            } else if(launchedFrom == 'PVTButton' && reportVal.size() > 0) {
                                ar.Report_Date__c = reportVal.containskey('Report_Date__c')? date.parse(reportVal.get('Report_Date__c')): null;
                                ar.Evaluation_Period_From__c = pr.Start_Date__c;
                                ar.Evaluation_Period_To__c = pr.End_Date__c;
                            } else if(launchedFrom == 'ProjectTask') {
                                //For the further reports, the old report Evaluation Period to + 1 and Evaluation Period to and Date on which the hour limit crosses
                                if(projARMap != null && projARMap.containskey(pr.Id)) {
                                    ar.Report_Date__c = System.today().addDays(15);
                                    ar.Evaluation_Period_From__c = (projARMap.get(pr.Id).Evaluation_Period_To__c != null ? projARMap.get(pr.Id).Evaluation_Period_To__c.addDays(1): null);
                                    ar.Evaluation_Period_To__c = System.today();
                                } else {
                                // For the first Report EPF is project.Start Date and EPT Date on which the hour limit crosses
                                    ar.Report_Date__c = System.today().addDays(15);
                                    ar.Evaluation_Period_From__c = pr.Start_Date__c;
                                    ar.Evaluation_Period_To__c = System.today();
                                }
                            }/*else {
                                ar.Evaluation_Period_From__c = pr.Start_Date__c;
                                // Formed from Events 
                                if(proIdMidDateMap.containskey(pr.Id)) {
                                    ar.Report_Date__c = proIdMidDateMap.get(pr.Id);
                                    ar.Evaluation_Period_To__c = proIdMidDateMap.get(pr.Id);
                                }
                            }*/
                            ar.Language_Training_Status__c = 'Progress';
                        }else if(str == 'Initial Test Report'){
                            ar.Report_Date__c = pr.Start_Date__c;
                            ar.Test_Report_Type__c = 'Initial';
                        }else if(str == 'Progress Test Report'){
                            // Modified on Mar 03 2023
                            if(pr.AcctSeed__Account__r.Name.contains('PGLS')){
                                ar.Report_Date__c =  System.today().addDays(15);
                            }else{
                                ar.Report_Date__c =  reportVal != null && reportVal.containskey('Report_Date__c') ? date.parse(reportVal.get('Report_Date__c')) : System.today().addDays(15);
                            }
                            ar.Test_Report_Type__c = 'Progress';
                        }else if(str == 'Final Test Report'){
                            ar.Report_Date__c = (pr.AcctSeed__Account__r.Name.contains('DODA') && pr.Program_Iteration__c != null) ? pr.Program_Iteration__r.Final_Progress_Due_Date__c : pr.End_Date__c;
                            ar.Test_Report_Type__c = 'Final';
                        }else if(str == 'Monthly_Test_Report' || str == 'Monthly_Self_Test_Report'){
                             ar.Test_Report_Type__c = 'Monthly'; 
                             //ar.Tester__c = projIdAndInsId.get(pr.Id);  Commented by GRK W-007895, not to populate Tester field for DLI reports
                        }
                        
                        // Added on Nov 07 2022
                        if(launchedFrom == 'PVTButton' && (str == 'Progress' || str == 'Final' || str == 'Initial Test Report' || str == 'Final Test Report')){
                            ar.Report_Date__c =  reportVal != null && reportVal.containskey('Report_Date__c') ? date.parse(reportVal.get('Report_Date__c')) : null;
                        }
                        
                        ar.Status__c = 'Draft';
                        ar.Training_Date_From__c = pr.Start_Date__c;
                        ar.Training_Date_To__c = pr.End_Date__c;
                        ar.Language_LU__c = pr.Language__c;
                        ar.Sponser__c = pr.AcctSeed__Account__c;
                        ar.Type_of_Training__c = typeApiToLabelMap.containskey(pr.Program_type__c) ? typeApiToLabelMap.get(pr.Program_type__c) : pr.Program_type__c;
                        ar.Project__c = pr.Id;
                        ar.Project_Manager__c = pr.Project_Manager__c;
                        if(projIdAndInsId.containskey(pr.Id)) {
                            ar.Instructor__c = projIdAndInsId.get(pr.Id);
                        }
                        
                        if(projIdAndLTCoordId.containskey(pr.Id) && projIdAndLTCoordId.get(pr.Id) != null) {
                            ar.LT_Coordinator__c = projIdAndLTCoordId.get(pr.Id);
                        }
                        
                        if(projIdAndTOIdMap.containskey(pr.Id) && projIdAndTOIdMap.get(pr.Id) != null) {
                            ar.Training_officer__c = projIdAndTOIdMap.get(pr.Id);
                        }
                        if(projIdAndProjTaskId.containskey(pr.Id) && projIdAndProjTaskId.get(pr.Id) != null) {
                            ar.Project_Task__c = projIdAndProjTaskId.get(pr.Id);
                        }
                        if(projIdAndTotalHours.containskey(pr.Id) && projIdAndTotalHours.get(pr.Id) != null) {
                            ar.Total_Hours__c = projIdAndTotalHours.get(pr.Id);
                        }
                        
                        if(str == 'Initial Test Report' || str == 'Final Test Report' || str == 'Progress Test Report'){
                            ar.RecordTypeId = testRTId;
                            ar.Tester__c = projIdAndInsId.get(pr.Id); //W-007583
                        }else if(pr.AcctSeed__Account__r.Name.contains('DLI') || pr.RecordTypeId == dliRTId_Proj) { //Name - student name is needed // DLI-W
                            
                            if(str == 'Monthly'){
                                ar.RecordTypeId = DLIRTId;
                            }else if(str == 'Monthly_Test_Report'){
                                ar.RecordTypeId = dli_Test_Report_RTId;
                            }else if(str == 'Monthly_Self_Test_Report'){
                                ar.RecordTypeId = dli_Self_Test_Report_RTId;
                            }
                            
                            ar.Report_Type__c = 'DLI';
                            // To Calculte the no of weeks for this project
                            if(pr.End_Date__c != null && pr.Start_Date__c != null) {
                                Date firstWeekSt = pr.Start_Date__c.toStartofWeek().addDays(1); // since start of Week returns sunday, adding 1 to the date
                                Date lastWeekEnd = pr.End_Date__c.toStartofWeek().addDays(8); // since start of week returns sunday, adding 8 to get the last Day
                                Integer noOfDays = firstWeekSt.daysBetween(lastWeekEnd);
                                ar.Total_Weeks__c = noOfDays/7;
                            }
                        } else if(pr.AcctSeed__Account__r.Name.contains('APMO')) { //Name - student name is needed
                            ar.RecordTypeId = APMORTId;
                            ar.Report_Type__c = 'APMO';
                            // To Calculte the no of weeks for this project
                            if(pr.End_Date__c != null && pr.Start_Date__c != null) {
                                Date firstWeekSt = pr.Start_Date__c.toStartofWeek().addDays(1); // since start of Week returns sunday, adding 1 to the date
                                Date lastWeekEnd = pr.End_Date__c.toStartofWeek().addDays(8); // since start of week returns sunday, adding 8 to get the last Day
                                Integer noOfDays = firstWeekSt.daysBetween(lastWeekEnd);
                                ar.Total_Weeks__c = noOfDays/7;
                            }
                        // For the PGLS Account related projects
                        } else if(pr.AcctSeed__Account__r.Name.contains('PGLS')) { //Name - student name is needed
                            ar.RecordTypeId = DEARTId;
                            ar.Report_Type__c = 'DEA';
                            // To Calculte the no of weeks for this project
                            if(pr.End_Date__c != null && pr.Start_Date__c != null) {
                                Date firstWeekSt = pr.Start_Date__c.toStartofWeek().addDays(1); // since start of Week returns sunday, adding 1 to the date
                                Date lastWeekEnd = pr.End_Date__c.toStartofWeek().addDays(8); // since start of week returns sunday, adding 8 to get the last Day
                                Integer noOfDays = firstWeekSt.daysBetween(lastWeekEnd);
                                ar.Total_Weeks__c = noOfDays/7;
                            }
                        } else {
                            ar.RecordTypeId = ltRTId;
                            ar.Report_Type__c = 'Language Training';
                        }
                        
                        
                        //reports.add(ar);
                    
                    // Map to store the Assessment Report based on the Report Type and Project Id without the Contact Assignment Detail
                    String tStr = pr.Id + '-' + str;
                    if(!projIdARTypeARMap.containskey(tStr)) {
                        projIdARTypeARMap.put(tStr, new List<Assessment_Report__c>{ar});
                    } else {
                        projIdARTypeARMap.get(tStr).add(ar);
                    }
                }
                //System.debug('projIdFinalDate::::'+projIdFinalDate);
            }
            System.debug('projIdARTypeARMap::::'+projIdARTypeARMap);
            //System.debug('projStudentsMap::::'+projStudentsMap);
        
            // Using the single Report type for each Project, here we create n number of Reports based on the Student count
            // Populate other Student related information in this
            for(String proStr : projIdARTypeARMap.keySet()) {
                List<String> strList = proStr.split('-');
                
                if(strList != null && strList.size() > 1) {
                    String proId = strList[0];
                    String arType = strList[1]; 
                    String nameSuf = '';
                    AcctSeed__Project__c pr = projMap.get(proId);
                   
                    if(arType == 'Progress') {
                        nameSuf = 'Progress';
                    } else if(arType == 'Final Report' || arType == 'Final Assessment' || (launchedFrom == 'PVTButton' && arType == 'Final')) {    // Added launchedFrom condition on Nov 07 2022
                        nameSuf = 'Final';
                    }else if(arType == 'Initial Test Report'){
                        nameSuf = 'Test Initial';
                    }else if(arType == 'Final Test Report'){
                        nameSuf = 'Test Final';
                    }else if(arType == 'Progress Test Report'){
                        nameSuf = 'Test Progress';
                    }else if(arType == 'Monthly_Test_Report'){
                        nameSuf = ' - Assessment by Instructor - '; // old Test
                    }else if(arType == 'Monthly_Self_Test_Report'){
                        nameSuf = ' - Self-Assessment - ';
                    }
                    
                    System.debug('::::projStudentsMap:::'+projStudentsMap);
                    System.debug('::::projStudentsMap:SIZE::'+projStudentsMap.size());
                    System.debug('::::projIdMonthlyDates::'+projIdMonthlyDates);
                    
                    if(projStudentsMap != null && projStudentsMap.containskey(proId)) {
                        for(Contact_Assignments__c st : projStudentsMap.get(proId)) {
                            if(launchedFrom == 'ScheduleTrigger' || launchedFrom == 'ProjectTask' || launchedFrom == 'PVTButton' || launchedFrom == 'CATrigger' || launchedFrom == 'Project_Trigger') { // For PVT Student inclusion to create Assessment Report
                                List<Assessment_Report__c> ars = projIdARTypeARMap.get(proStr);
                                Assessment_Report__c ar = new Assessment_Report__c();
                                
                                if(ars != null && ars.size() > 0) {
                                    // Commented on Aug 16 2023
                                    //String languageName = (String.isNotBlank(pr.Language__r.Name) && pr.Language__r.Name.contains(' - ')) ? pr.Language__r.Name.split(' - ')[0] : pr.Language__r.Name;
                                    
                                    if(!arType.contains('Monthly')) {
                                    
                                        System.debug('::::FINAL::::::');
                                        
                                        ar = ars[0].clone();
                                        //if(ars[0].Report_Type__c != 'DLI')  As it is not equal to monthly it is not of DLI type
                                        // Commented on Aug 16 2023
                                        /*
                                        String tempTestReportName = '';
                                        if(arType.contains('Test Report')){
                                            tempTestReportName = (nameSuf == 'Test Progress' ? (' ' + nameSuf+ ' '+ ar.Report_Date__c.month() + '_' + ar.Report_Date__c.year() + ' ' +st.Project__r.DLS_Ref__c) : (' ' + nameSuf+ ' '+ st.Project__r.DLS_Ref__c));
                                        }
                                        //ar.Name = st.Candidate_Name__r.FirstName + ' ' + st.Candidate_Name__r.LastName + ' ' + languageName + (arType.contains('Test Report') ? tempTestReportName : (' PR '+ nameSuf));
                                        if(isFromDCAT && projIdAndLPROrder.containsKey(ar.Project__c) && arType == 'Progress'){
                                            
                                            String arName = ar.Name;
                                            //ar.Name = arName + ' ' + projIdAndLPROrder.get(ar.Project__c);
                                        }
                                        */
                                        
                                        ar.Student__c = st.Candidate_Name__c;
                                        
                                        System.debug('::ar.Report_Date__c:::'+ar.Report_Date__c);
                                        // For old Active Project on creting the Reports, we should create it only for the future dates          
                                        // Added on July 28 2022
                                        if(ar.Report_Date__c > System.Today() || (ar.RecordTypeId == testRTId && ar.Test_Report_Type__c == 'Initial')) {
                                            
                                            // Added launchedFrom = "ProjectTask" condition to fix the issue in creation of new set of Assessment Reports when project taks's hours used for Language Training field is updated 
                                            /*
                                            if(((!finalReportProjIds.contains(ar.Project__c) && launchedFrom != 'ProjectTask') || (launchedFrom == 'ProjectTask')) && 
                                                (!activatedProjIdsAfterOnhold.contains(proId) || (activatedProjIdsAfterOnhold.contains(proId) && 
                                                (!projIdAndExistingARDates.containsKey(proId) || (projIdAndExistingARDates.containsKey(proId) && 
                                                !projIdAndExistingARDates.get(proId).contains(ar.Report_Date__c)))))){
                                                    reports.add(ar);
                                            }
                                            */
                                            System.debug('::::FINAL::::11::');
                                            /*
                                            String projId_ConId_RTId_RepDate = ar.Project__c+''+ar.Student__c+''+ar.RecordTypeId+''+String.valueOf(ar.Report_Date__c);
                                            System.debug('::::projId_ConId_RTId_RepDate_Set::::::'+projId_ConId_RTId_RepDate_Set);
                                            if(!projId_ConId_RTId_RepDate_Set.contains(projId_ConId_RTId_RepDate)){
                                                reports.add(ar);
                                            }
                                            */
                                            
                                            String projId_ConId_RTId_RepDate_RT_TRT_LTS = ar.Project__c+''+ar.Student__c+''+ar.RecordTypeId+''+String.valueOf(ar.Report_Date__c)+''+ar.Report_Type__c+''+ar.Test_Report_Type__c+''+ar.Language_Training_Status__c;
                                            System.debug('::::projId_ConId_RTId_RepDate_RT_TRT_LTS::::::'+projId_ConId_RTId_RepDate_RT_TRT_LTS);
                                            if(!projId_ConId_RTId_RepDate_RTyp_TestRTyp_LRS_Set.contains(projId_ConId_RTId_RepDate_RT_TRT_LTS)){
                                                reports.add(ar);
                                            }
                                            
                                        }
                                    } else {
                                        
                                        System.debug('::MONTHLY:::');
                                        System.debug('::projIdMonthlyDates:::');
                                        
                                        if(projIdMonthlyDates.containsKey(proId)){
                                            Date excludeDate;
                                            List<Date> monthlyDates = projIdMonthlyDates.get(proId);  
                                            System.debug('::projIdMonthlyDates.get(proId):::'+projIdMonthlyDates.get(proId));
                                            System.debug('::monthlyDates::1:'+monthlyDates); 
                                                                                     
                                            for ( Integer i = monthlyDates.size() - 1; i>= 0; i-- ){
                                                Date mDt = monthlyDates[i];
                                                
                                                
                                                if(projIdFinalDate.containskey(proId)) {
                                                    excludeDate = projIdFinalDate.get(proId);
                                                }
                                                    
                                                if(excludeDate == null || (excludeDate != null && (excludeDate.month() != mDt.month() || (excludeDate.month() == mDt.month() && excludeDate.year() != mDt.year()))) ) {
                                                    ar = ars[0].clone();
                                                    ar.Language_Training_Status__c = 'Monthly';
                                                    ar.Report_Date__c = mDt; // Last Working Day of the month
                                                    ar.Evaluation_Period_From__c = mDt.toStartOfMonth(); // First Calendar day of the Month
                                                    ar.Evaluation_Period_To__c = pr.End_Date__c >= mDt.addMonths(1).toStartOfMonth().addDays(-1) ? mDt.addMonths(1).toStartOfMonth().addDays(-1) : pr.End_Date__c; // Last calendar day of the month
                                                    ar.Student__c = st.Candidate_Name__c;
                                                    if(pr.AcctSeed__Account__r.Name.contains('APMO') && pr.RecordTypeId != dliRTId_Proj) {
                                                        // Commented on Aug 16 2023
                                                        //ar.Name = st.Candidate_Name__r.FirstName + ' ' + st.Candidate_Name__r.LastName + '_APMO Monthly Student Report_' + ar.Report_Date__c.month() + '_' +  ar.Report_Date__c.year();
                                                        ar.Report_Date__c = mDt;
                                                    } else if(pr.AcctSeed__Account__r.Name.contains('PGLS') && pr.RecordTypeId != dliRTId_Proj) {
                                                        // Commented on Aug 16 2023
                                                        //ar.Name = st.Candidate_Name__r.FirstName + ' ' + st.Candidate_Name__r.LastName + '_DEA Monthly Student Report_' + ar.Report_Date__c.month() + '_' +  ar.Report_Date__c.year();
                                                        ar.Report_Date__c = mDt; //date.newinstance(mDt.year(), mDt.month(), 22); Commented based on the task W-007697
                                                    } else if(ar.RecordTypeId == dli_Self_Test_Report_RTId) {
                                                        // Commented on Aug 16 2023
                                                        //ar.Name = st.Candidate_Name__r.FirstName + ' ' + st.Candidate_Name__r.LastName  + nameSuf  + languageName + ' ' + ar.Report_Date__c.month() + '-' +  ar.Report_Date__c.year() + '-' + pr.TO__c;
                                                    } else if(ar.RecordTypeId == dli_Test_Report_RTId) {
                                                        // Commented on Aug 16 2023
                                                        //ar.Name = st.Candidate_Name__r.FirstName + ' ' + st.Candidate_Name__r.LastName  + nameSuf  + languageName + ' ' + ar.Report_Date__c.month() + '-' +  ar.Report_Date__c.year() + '-' + pr.TO__c;
                                                    } else {
                                                        // Commented on Aug 16 2023
                                                        //ar.Name = st.Candidate_Name__r.FirstName + ' ' + st.Candidate_Name__r.LastName + (ar.Report_Type__c == 'DLI'? ' DLI' : '') + ' Monthly Student Report_' + ar.Report_Date__c.month() + '_' +  ar.Report_Date__c.year();
                                                        ar.Report_Date__c = mDt;
                                                    }
                                                    // Added on Aug 08 2021
                                                    if(pr.AcctSeed__Account__r.Name.contains('DLI-W') || pr.RecordTypeId == dliRTId_Proj) {
                                                        Date projSD = pr.Start_Date__c.toStartofWeek().addDays(1); // since start of Week returns sunday, adding 1 to the date
                                                        Date evaluationPeriodTo = ar.Evaluation_Period_To__c.toStartofWeek().addDays(8); // since start of week returns sunday, adding 8 to get the last Day
                                                        Integer noOfDays = projSD.daysBetween(evaluationPeriodTo);
                                                        ar.Total_Weeks_Used__c = noOfDays/7;
                                                    }
                                                    /*
                                                    if((((launchedFrom != 'Project_Trigger' && !activatedProjIdsAfterOnhold.contains(proId)) || 
                                                        (launchedFrom == 'Project_Trigger' || activatedProjIdsAfterOnhold.contains(proId))) && 
                                                        (!projIdAndExistingARDates.containsKey(proId) || (projIdAndExistingARDates.containsKey(proId) && 
                                                        !projIdAndExistingARDates.get(proId).contains(ar.Report_Date__c)))) ||
                                                        (reportDateAndLTS.containsKey(ar.Report_Date__c) && reportDateAndLTS.get(ar.Report_Date__c) == 'Final')){
                                                    */
                                                        // For old Active Project on creting the Reports, we should create it only for the future dates
                                                        if(ar.Report_Date__c > System.Today()) {
                                                            
                                                            String projId_ConId_RTId_RepDate_RT_TRT_LTS = ar.Project__c+''+ar.Student__c+''+ar.RecordTypeId+''+String.valueOf(ar.Report_Date__c)+''+ar.Report_Type__c+''+ar.Test_Report_Type__c+''+ar.Language_Training_Status__c;
                                                            System.debug('::::projId_ConId_RTId_RepDate_RT_TRT_LTS::::::'+projId_ConId_RTId_RepDate_RT_TRT_LTS);
                                                            if(!projId_ConId_RTId_RepDate_RTyp_TestRTyp_LRS_Set.contains(projId_ConId_RTId_RepDate_RT_TRT_LTS)){
                                                                reports.add(ar);
                                                            }                                                
                                                        }
                                                    //}
                                                }
                                                // Commented on Nov 11 2022
                                                /*
                                                if(activatedProjIdsAfterOnhold.contains(proId) && projIdAndExistingARDates.containsKey(proId) && projIdAndExistingARDates.get(proId).contains(mDt)){
                                                    System.debug('::monthlyDates::2:'+monthlyDates); 
                                                    monthlyDates.remove( i );
                                                    System.debug('::monthlyDates::3:'+monthlyDates); 
                                                }
                                                */
                                            }
                                            //Commented on Nov 11 2022
                                            //projIdMonthlyDates.put(proId, monthlyDates);
                                            //System.debug('::projIdMonthlyDates::2:'+projIdMonthlyDates); 
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            //System.debug('reports::::::'+reports);
            System.debug('reports Size::'+reports.size());            
            // To Create DLI Monthly Observation Report 
            // Added on May 16 2024 - W-008050 : Issue with DLI Observation Report Creation on DLI Project
            // To create DLI observation reports when the project's end date is extended 
            if((launchedFrom == 'ScheduleTrigger' || launchedFrom == 'Project_Trigger') && dLIObsReport == true) {
                List<Assessment_Report__c> obsRpt = Assessment_Report_Helper.createObservationReportRecs(projId,cas, projIdMonthlyDates, 'ScheduleTrigger');
                if(obsRpt != null && obsRpt.size() > 0) {
                    //System.debug('obsRpt::::'+obsRpt);
                    System.debug('obsRpt::::size:::'+obsRpt.size());
                    reports.addall(obsRpt);
                }
            }            
            if(reports.size() > 0 ) {
                System.debug('reports::::'+reports);
                Insert reports;
            }
        }
    }
    
    /* This Called from CreateAssesmentReportActionCmp*/
    /* this method to validate to create Assessment Report Records*/
    @AuraEnabled
    public static String createAssessmentReportRecs(String proId, String reportValJSON){
        
    List<AcctSeed__Project__c> proList = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',new Set<Id>{proId},',AcctSeed__Account__r.Name,AcctSeed__Account__r.ParentId,AcctSeed__Account__r.Parent.Name ');
    List<Account> accList = new  List<Account>();
    Map<String,String> reportVal = (Map<String,String>) JSON.deserialize(reportValJSON, Map<String,String>.class);
    System.debug('reportVal::::'+reportVal);
    String accName = '';
    String accParentName = '';
    Boolean isAccPVT = true;
    String finalMsg = '';
        
        if(proList.size() > 0){
            if(proList[0].AcctSeed__Account__c != null){
                accName = proList[0].AcctSeed__Account__r.Name;
                
                if(proList[0].AcctSeed__Account__r.ParentId != null){
                    accParentName = proList[0].AcctSeed__Account__r.Parent.Name;
                }
              
               /* if(accparentName == 'PVT' || accName == 'PVT' || accName.contains('FAS')){ //|| accName.contains('FCS')
                    isAccPVT = true;
                }
                if(isAccPVT == true){*/
                    Set<Id> stuConIds = new Set<Id>();
                    //Set<Id> arRelStuIds = new Set<Id>();
                    
                    for(Contact_Assignments__c ca  : [SELECT Id,Candidate_name__c FROM Contact_Assignments__c WHERE Candidate_name__c != null AND RecordType.DeveloperName = 'Student' AND Project__c = :proList[0].Id]){ // not used service class since we used only limited fields
                        stuConIds.add(ca.Candidate_name__c);   
                    }
                    
                    if(stuConIds.size() > 0){
                        
                        /*for(Assessment_Report__c ar : [SELECT Id, Student__c, Status__c, Project__c FROM Assessment_Report__c WHERE Student__c IN :stuConIds AND Project__c = :proList[0].Id]){
                            arRelStuIds.add(ar.Student__c);
                        }*/
                        
                        /*Set<Id> creationStuIds = new Set<Id>();
                        for(Id stuIds : stuConIds){
                            if(!arRelStuIds.contains(stuIds)){
                                creationStuIds.add(stuIds);
                            }
                        }*/
                        
                        //if(creationStuIds.size() > 0){
                            if(reportVal != null && reportVal.containskey('Report_Date__c')){
                                String rDate = reportVal.get('Report_Date__c');
                                List<String> tempDate2 = rDate != null ? rDate.split('-') : new List<String>();
                                String reportDate = (tempDate2 != null && tempDate2.size() > 1) ? (tempDate2[1]+'/'+tempDate2[2]+'/'+tempDate2[0]) : null;
                                reportVal.put('Report_Date__c',reportDate);
                            }
                            createAssessReport(new Set<Id>{proList[0].Id}, 'PVTButton', reportVal, new Map<Id,Assessment_Report__c>()); 
                            finalMsg = 'Assessment Reports are created sucessfully.';
                        //} else {
                        //    finalMsg = 'Already Assessment Reports are created for this Project.';
                        //}
                        
                    } else {
                        finalMsg = 'Please create Student Contact Assignments for this Project.';
                    }
               // } else {
                  //  finalMsg = 'Currently we support Assessment Report creation for PVT/FAS Account related Projects only.'; // FCS
              //  }               
            }else{
                finalMsg = 'Please populate Account in this Project.';
            }
        }

        return finalMsg;   
    }
    
    public class AssessmentReportWrapper{

        @InvocableVariable
        public List<Id> assRepIds;
    }
    
    // To update the Project Manager in the Assessment Report when the Project Manager is updated in the Project
    public static void updateAssementReportLT(Map<Id,Id> lTId) {
        List<Assessment_Report__c> ARToUpdate = new List<Assessment_Report__c>(); 
        System.debug('lTId::::::'+lTId);
        if(lTId.size() > 0 ) {
            Map<Id,Id> ContactIdWithUserIdMap = new Map<Id,Id>();
            System.debug('ContactIdWithUserIdMap::::'+ContactIdWithUserIdMap);
            for( User u : [Select Id,ContactId FROM User Where ContactId IN : lTId.Values() AND Profile.Name = 'Staff Community']) {
                ContactIdWithUserIdMap.put(u.ContactId,u.Id);
            }
            
            // Qry DLS User value from contact records 
            for(Contact con : [SELECT Id,Name,DLS_User__c FROM Contact WHERE Id IN :lTId.Values() AND DLS_User__c != null]){
                if(!ContactIdWithUserIdMap.containsKey(con.Id)) {
                    ContactIdWithUserIdMap.put(con.Id,con.DLS_User__c);
                }
            }
            
            for( Assessment_Report__c ar : [SELECT Id, Student__c, Status__c, Project__c, LT_Coordinator__c FROM Assessment_Report__c WHERE Project__c IN : lTId.keyset() AND Status__c IN ('Scheduled', 'Draft')]) {
                if( ContactIdWithUserIdMap.containskey(lTId.get(ar.Project__c)) && ContactIdWithUserIdMap.get(lTId.get(ar.Project__c)) != null ) {
                    ar.LT_Coordinator__c = ContactIdWithUserIdMap.get(lTId.get(ar.Project__c));
                    ARToUpdate.add(ar);
                }
            }
            System.debug('ARToUpdate::::::'+ARToUpdate);
            if(ARToUpdate.size() > 0) {
                update ARToUpdate;
            }
        }
    } 
    
    // To update the Instructor in the Assessment Report when the Instructor is updated in the Schedule
    public static void updateARInstructor(Map<Id,Id> priorSchIdAndInsId) {
        
        if(priorSchIdAndInsId != NULL && priorSchIdAndInsId.size() > 0){
        
            Map<Id, Id> projIdAndOldInsId = new Map<Id, Id>();
            Map<Id, Id> projIdAndNewInsId = new Map<Id, Id>();
            
            List<Assessment_Report__c> updateARs = new List<Assessment_Report__c>();
            
            for(Schedule__c s : [SELECT Id, Project__c, Instructor__c 
                                    FROM Schedule__c 
                                    WHERE Id IN :priorSchIdAndInsId.keySet()]){
            
                projIdAndOldInsId.put(s.Project__c, s.Instructor__c);
                projIdAndNewInsId.put(s.Project__c, priorSchIdAndInsId.get(s.Id));
            }
            
            for(Assessment_Report__c ar : [SELECT Id, Instructor__c, Project__c, RecordType.DeveloperName, Project__r.AcctSeed__Account__r.Name, Project__r.RecordTypeId
                                            FROM Assessment_Report__c 
                                            WHERE Project__c IN :projIdAndOldInsId.keySet() AND Instructor__c IN : projIdAndOldInsId.values() AND 
                                                Status__c IN ('Draft','Scheduled') AND RecordType_Name__c NOT IN ('Annual_Instructor_Performance_Review', 'Observation_Report')]){ // Commented for the DLI Observation report update 'Observation_Report',
             
                if(projIdAndOldInsId.containsKey(ar.Project__c) && projIdAndOldInsId.get(ar.Project__c) == ar.Instructor__c){
                    ar.Instructor__c = projIdAndNewInsId.get(ar.Project__c);
                    updateARs.add(ar);
                }    
            } 
            
            if(updateARs != NULL && updateARs.size() > 0){
                update updateARs;    
            }  
        }    
    }
    
    // W-006038 Observation Report
    public static List<Assessment_Report__c> createObservationReportRecs(Set<Id> proIds, List<Contact_Assignments__c> insCA, Map<Id, List<Date>> projIdMonthlyDates, String launchedFrom){
                
        System.debug(':::::projIdMonthlyDates::::'+projIdMonthlyDates);
        
        List<Assessment_Report__c > ars = new List<Assessment_Report__c>();
        Id ObsReportId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Observation_Report').getRecordTypeId();
        Id dLIObsReportId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_Observation_Report').getRecordTypeId();
        
        //Map<Id,String> projMap = new Map<Id,String>();    // Commented on Aug 16 2023
        Map<Id,Date> projSDMap = new Map<Id,Date>();
        Map<Id,Id> projManagerMap = new Map<Id,Id>();
        Map<Id,String> projStudentMap = new Map<Id,String>();
        //Map<Id,String> projInstructorMap = new Map<Id,String>();    // Commented on Aug 16 2023
        // Map to store the Observation Report dates to exclude the Reports if the same date exist already 
        Map<Id,List<Date>> projIdObsRptDateMap = new Map<Id,List<Date>>(); 
        Map<Id,Contact_Assignments__c> caIdCARecMap = new Map<Id,Contact_Assignments__c>();
        
        // Added on June 16 2023 - W-007783 : Issue with DLI Training Report Auto Cancellation when DLI Project End Date isChanged 
        // To prevent reports creation for partner school projects 
        // Added on May 15 2024 : W-008048 - JMAS Projects - No Longer Need Initial and Final assessments/reports/scores : To prevent the auto creation of observation report for DODA project with JMAS project type
        Map<Id, AcctSeed__Project__c> projRecMap = new Map<Id, AcctSeed__Project__c>([SELECT Id, Name, AcctSeed__Account__r.Name, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id IN : proIds AND (((NOT(AcctSeed__Account__r.Name LIKE '%DODA%')) AND (NOT(AcctSeed__Account__r.Name LIKE '%PVT%'))) OR (((AcctSeed__Account__r.Name LIKE '%DODA%' AND Project_Type__c != 'JMAS') OR AcctSeed__Account__r.Name LIKE '%PVT%') AND QB_Classification__c != 'OF0MTT0PS'))]);
        Map<Id, Contact_Assignments__c> caMapFromCATrigger = new Map<Id, Contact_Assignments__c>();
        
        if(projRecMap.size() > 0){
        
            // DLI Monthly Observation Report changes
            // Added on May 16 2024 - W-008050 : Issue with DLI Observation Report Creation on DLI Project
            // To create DLI observation reports when the project's end date is extended 
            if(launchedFrom == 'CATrigger' || launchedFrom == 'ScheduleTrigger' || launchedFrom == 'Project_Trigger') {
                
                if(projIdMonthlyDates == null){
                    projIdMonthlyDates = new Map<Id,List<Date>>();
                }
                
                // To fix duplicate training report name issue
                if(launchedFrom == 'CATrigger'){
                    caMapFromCATrigger = new Map<Id, Contact_Assignments__c>(insCA);   
                }
                
                for(Assessment_Report__c obsRt : [SELECT Id,Name,Report_Date__c,Project__c FROM Assessment_Report__c WHERE Project__c IN: proIds AND recordType.DeveloperName IN ('DLI_Observation_Report', 'Observation_Report')]) {
                    if(!projIdObsRptDateMap.containskey(obsRt.Project__c)) {
                        projIdObsRptDateMap.put(obsRt.Project__c, new List<Date>{obsRt.Report_Date__c});
                    } else {
                        projIdObsRptDateMap.get(obsRt.Project__c).add(obsRt.Report_Date__c);
                    }
                }
            }
            System.debug(':::::projIdMonthlyDates***::::'+projIdMonthlyDates);
            System.debug(':::projIdObsRptDateMap:::::'+projIdObsRptDateMap);
            if( proIds != null && proIds.size() > 0 ) {
                for( Contact_Assignments__c ca : [SELECT Id,Name,Project__c,Project__r.Name,Candidate_Name__r.Name,RecordType.DeveloperName,Status__c,Project__r.Project_Manager__c,Start_Date__c, Project__r.TO__c, Project__r.Language__r.Name,Project__r.AcctSeed__Account__r.Name, Project__r.RecordTypeId FROM Contact_Assignments__c WHERE Project__c IN: proIds AND Status__c IN ('Planned', 'Active') AND RecordType.DeveloperName IN ('Instructor', 'Student')]) {
                    // Commented on Aug 16 2023
                   /*
                    if(!projMap.containskey(ca.Project__c)) {
                        projMap.put(ca.Project__c, ca.Project__r.Name);
                    }
                    */
                    
                    if(!projManagerMap.containskey(ca.Project__c)) {
                        projManagerMap.put(ca.Project__c, ca.Project__r.Project_Manager__c);
                    }
                    
                    if(ca.RecordType.DeveloperName == 'Student' && ca.Candidate_Name__c != null) {
                        if(!projStudentMap.containskey(ca.Project__c)) {
                            projStudentMap.put(ca.Project__c, ca.Candidate_Name__r.Name);
                        } else {
                            String temp = projStudentMap.get(ca.Project__c);
                            temp = temp+ ', ' + ca.Candidate_Name__r.Name;
                            projStudentMap.put(ca.Project__c, temp);
                        }
                    }
                    // Commented on Aug 16 2023
                    /*
                    if(ca.RecordType.DeveloperName == 'Instructor') {
                        projInstructorMap.put(ca.Candidate_Name__c, ca.Candidate_Name__r.Name);
                    }
                    */
                    // DLI Monthly Observation Report changes
                    // Added on Nov 24 2023
                    // W-007931 :Issue with Instructor CA Activation when Project Status is Changed from Ended to Active
                    // To fix "duplicate training report name" issue
                    if(ca.RecordType.DeveloperName == 'Instructor' && caMapFromCATrigger.containsKey(ca.Id)){
                        if(!ca.Project__r.AcctSeed__Account__r.Name.contains('DLI') && ca.Project__r.RecordTypeId != dliRTId_Proj){
                            System.debug(':::CA::ID::::'+ca.Id+'::::::ca.RecordType.DeveloperName::::'+ca.RecordType.DeveloperName);
                            if(!projIdMonthlyDates.containskey(ca.Project__c)){
                                projIdMonthlyDates.put(ca.Project__c, new List<Date>{ca.Start_Date__c.addDays(14)});
                            }
                        }
                    }
                    // Used to populate the DLI specific Observation Report name
                    caIdCARecMap.put(ca.Id,ca);
                }
            }
            System.debug(':::projIdMonthlyDates:::'+projIdMonthlyDates);
            for ( Contact_Assignments__c ca : insCA) {
                if(projIdMonthlyDates.size() > 0 && projIdMonthlyDates.containskey(ca.Project__c)) {
                    List<Date> reportDates = projIdMonthlyDates.get(ca.Project__c);
                    Boolean isDLIProject = (projRecMap.containskey(ca.Project__c) && (projRecMap.get(ca.Project__c).Recordtype.DeveloperName == 'DLI_W_LT_Projects' || projRecMap.get(ca.Project__c).AcctSeed__Account__r.Name.contains('DLI'))) ? true : false; // returns true if the project is a DLI class
                    for (Date rd : reportDates) {
                        System.debug(':::rd:::::'+rd);
                        // To avoid duplicate Observation Report creation and past date report creation
                        if(!projIdObsRptDateMap.containskey(ca.Project__c) || (projIdObsRptDateMap.containskey(ca.Project__c) && !projIdObsRptDateMap.get(ca.Project__c).contains(rd) && rd >= System.Today())) {
                            System.debug(':::rd::1111:::'+rd);
                            Assessment_Report__c  ar = new Assessment_Report__c();
                            ar.Report_Date__c = rd;
                            ar.Status__c = 'Scheduled';
                            ar.Project__c = ca.Project__c;
                            ar.Student_Name_s__c = projStudentMap.containskey(ca.Project__c) ? projStudentMap.get(ca.Project__c) : '';
                            ar.Instructor__c = ca.Candidate_Name__c;
                            if(isDLIProject) {
                                ar.RecordTypeId = dLIObsReportId;
                            } else {
                                ar.RecordTypeId = ObsReportId;
                            }
                            ar.Project_Manager__c = projManagerMap.containskey(ca.Project__c) ? projManagerMap.get(ca.Project__c) : null;
                            
                            // Commented on Aug 16 2023
                            //ar.Name = (projMap.containskey(ca.Project__c) ? projMap.get(ca.Project__c) : '' ) 
                              //  + '-' + (projInstructorMap.containskey(ca.Candidate_Name__c) ? projInstructorMap.get(ca.Candidate_Name__c) : '') 
                                //+ '-' + String.ValueOf(ar.Report_Date__c.month()) + '_' + String.ValueOf(ar.Report_Date__c.Year()); // updated slash to underscore
                            ars.add(ar);
                        }
                    }
                }
            }
            System.debug('::ars::'+ars);
            if(ars.size() > 0 ) {
                //Insert ars;
                return ars;
            }
        }
        return null;
    }
    
    /*********
        - Added By HL on Dec 15 2020
        - Work Item : W-005524 - Progress Reports in DLS Online (JAN-1-2021)
        - To update the Status of the Assessment Report records to Cancelled when increase the Project Task's Total Qty Planned
        *************/
    /*
    public static Void updateStatusOfARRs(Set<Id> projIdsToUpdateARRs) {
    
        System.debug('::::projIdsToUpdateARRs::::'+projIdsToUpdateARRs);
        
        if(projIdsToUpdateARRs != NULL && projIdsToUpdateARRs.size() > 0){
            
            List<Assessment_Report__c> updateARRs = new List<Assessment_Report__c>();
            
            for(Assessment_Report__c a : [SELECT Id, Project__r.AcctSeed__Account__r.Name, Status__c
                                            FROM Assessment_Report__c 
                                            WHERE Project__c IN :projIdsToUpdateARRs AND Status__c != 'Completed' AND 
                                                RecordType.DeveloperName != 'Observation_Report']){
            
                if(a.Project__r.AcctSeed__Account__r.Name.contains('PVT') || a.Project__r.AcctSeed__Account__r.Name.contains('FAS') || a.Project__r.AcctSeed__Account__r.Name == 'FCS2'){
                    a.Status__c = 'Canceled';
                    updateARRs.add(a);
                }    
            }
            System.debug(':::updateARRs::::'+updateARRs);
            if(updateARRs != NULL && updateARRs.size() > 0){
                
                update updateARRs;
            }
        }
    }*/
    
    public static void createHoursbasedTR(Map<Id,List<AcctSeed__Project_Task__c>> projPTMap, Map<Id,AcctSeed__Project_Task__c> oldMap) {
                
        Map<Id,Decimal> langQtyPlannedMap = new Map<Id,Decimal>();
        Set<Id> categoryIds = new Set<Id>();
        //Map<Id,Language_Category__c> lanCatMap = new Map<Id,Language_Category__c>();
        Map<Id,List<Category_Item__c>> catItems = new Map<Id,List<Category_Item__c>>();
        Set<Id> projecIds = new Set<Id>();
        Map<String, String> reportMap = new Map<String, String>{
            'Language_Training_Status__c' => 'Progress'            
        };
        Map<Id,Assessment_Report__c> projARMap = new Map<Id,Assessment_Report__c>();
        List<AcctSeed__Project_Task__c> PTList = new List<AcctSeed__Project_Task__c>();
        List<Category_Item__c> debugList = new List<Category_Item__c>();
        // Key to store the Language Id and PT.Total Qty Planned 
        // Value to store the Id of the Category
        Map<String,Id> langHoursCatMap = new Map<String,Id>();
        Map<Id,Id> ptLanIdMap = new Map<Id,Id>();
        
        Map<String, Integer> catId_CatItemIdAndCIRecOrder = new Map<String, Integer>();
                
        for(AcctSeed__Project__c pro : [SELECT Id, Name, Language__c, Language__r.Name, AcctSeed__Account__r.Name, QB_Classification__c,RecordTypeId FROM AcctSeed__Project__c WHERE Id IN: projPTMap.keyset() AND Language__c != null]) {
            //if(pro.AcctSeed__Account__r.Name.contains('FAS') || pro.AcctSeed__Account__r.Name.contains('PVT') || pro.AcctSeed__Account__r.Name == 'FCS2') 
            // To create reports based on the Category for other accounts
            if(pro.AcctSeed__Account__c != null && !pro.AcctSeed__Account__r.Name.contains('DLI') && !pro.AcctSeed__Account__r.Name.contains('DODA') && !pro.AcctSeed__Account__r.Name.contains('APMO') && pro.RecordTypeId != dliRTId_Proj) {
                for(AcctSeed__Project_Task__c pt: projPTMap.get(pro.Id)) {
                    langQtyPlannedMap.put(pro.Language__c, pt.Total_Qty_Planned__c);
                    PTList.add(pt);
                    ptLanIdMap.put(pt.Id,pro.Language__c);
                }
                
                /*
                    // Commented on Feb 20 2023
                    // W-007724 : Remove Test Reports for PVT/All and FCS Projects. Add Test Comments to PR Template (MAR-15-2023)
                    // To stop creating Midterm Test Reports for FAS/PVT/FCS2/All Other Accounts and FCS
                if(((((pro.AcctSeed__Account__r.Name == 'PVT' || pro.AcctSeed__Account__r.Name.contains('PVT')) && pro.QB_Classification__c != 'OF0MTT0PS')) || pro.AcctSeed__Account__r.Name.contains('FCS') || pro.AcctSeed__Account__r.Name.contains('FAS') ) && pro.AcctSeed__Account__c != null){
                    reportMap.put('Test_Report_Type__c','Progress Test Report');
                }
                */
            }
            // To create Midterm Test Reports for the PGLS/DEA Projects and to exclude the other category ralted projects
            if(pro.AcctSeed__Account__r.Name.contains('PGLS')) {
                reportMap = new Map<String, String>{
                    'Test_Report_Type__c' => 'Progress Test Report'            
                };
                projecIds.add(pro.Id);
            }
        }
        
        if(langQtyPlannedMap.size() > 0) {
        
            for(Language_Category__c lc : [Select Id,Name,Language__c,Language__r.Name, Category__c, Category__r.Min_Hours__c FROM Language_Category__c WHERE Language__c IN: langQtyPlannedMap.keyset()]) {
                if(langQtyPlannedMap.get(lc.Language__c) != null && lc.Category__r.Min_Hours__c <= langQtyPlannedMap.get(lc.Language__c)) {
                    categoryIds.add(lc.Category__c);
                    //lanCatMap.put(lc.Language__c, lc);
                    langHoursCatMap.put(lc.Language__c + '~' + langQtyPlannedMap.get(lc.Language__c), lc.Category__c);
                }
            }
            if(categoryIds.size() > 0) {
                
                Integer recCount = 1;
                
                for(Category_Item__c ci : [SELECT Id,Name,Category__c,Category__r.Min_Hours__c,Course_Timeline__c,Create_Training_Report__c,From_R_S__c,Hours__c,To_R_S__c FROM Category_Item__c WHERE Category__c IN: categoryIds AND Create_Training_Report__c = true ORDER BY Course_Timeline__c ASC]) {
                    if(!catItems.containskey(ci.Category__c)) {
                        catItems.put(ci.Category__c, new List<Category_Item__c>{ci});
                    } else {
                        catItems.get(ci.Category__c).add(ci);
                    }
                    
                    String catIdCatItemId = ci.Category__c+'~'+ci.Id;
                                        
                    catId_CatItemIdAndCIRecOrder.put(catIdCatItemId, recCount);
                    recCount += 1;                    
                }
            }
            /*for( AcctSeed__Project_Task__c pt : PTList ) {
                for( Id lan : lanCatMap.keyset() ) {
                    Language_Category__c lc = lanCatMap.get(lan);
                    if(lc.Category__r.Min_Hours__c <= pt.Total_Qty_Planned__c){
                        for(Category_Item__c ci : catItems.get(lc.Category__c)) {
                            if( pt.Total_Hours_Used_For_Language_Training__c >= ci.Course_Timeline__c && oldMap.get(pt.Id).Total_Hours_Used_For_Language_Training__c < ci.Course_Timeline__c) {
                                projecIds.add(pt.AcctSeed__Project__c);
                                debugList.add(ci);
                            }
                        }
                    }
                }
            }*/
            
            System.debug(':::::catId_CatItemIdAndCIRecOrder::::'+catId_CatItemIdAndCIRecOrder);
            
            //Loops the Project task to create the Assessment Reports
            for( AcctSeed__Project_Task__c pt : PTList ) {
                //String tempKey = pt.Language_LU__c + '~' + pt.Total_Qty_Planned__c;
                String tempKey = ptLanIdMap.get(pt.Id) + '~' + pt.Total_Qty_Planned__c;
                Id catId = langHoursCatMap.containskey(tempKey) ? langHoursCatMap.get(tempKey) : null;
                //Loops the Category Item to check for the Course timeline and the hours Used for Language training
                if(catId != NULL && catItems.containsKey(catId)){
                    for(Category_Item__c ci : catItems.get(catId)) {
                        //To check the Old Total_Hours_Used_For_Language_Training__c is less than Course_Timeline__c and the new Total_Hours_Used_For_Language_Training__c is >= Course_Timeline__c
                        //if( pt.Total_Hours_Used_For_Language_Training__c >= ci.Course_Timeline__c && oldMap.get(pt.Id).Total_Hours_Used_For_Language_Training__c < ci.Course_Timeline__c) 
                        if( pt.Total_Hours_Used_For_Language_Training__c >= ci.Course_Timeline__c && ( ( oldMap.get(pt.Id).Total_Hours_Used_For_Language_Training__c != null && oldMap.get(pt.Id).Total_Hours_Used_For_Language_Training__c < ci.Course_Timeline__c) || oldMap.get(pt.Id).Total_Hours_Used_For_Language_Training__c == null)) {
                            projecIds.add(pt.AcctSeed__Project__c);
                            debugList.add(ci);
                            
                            String catIdCatItemId = ci.Category__c+'~'+ci.Id;
                            if(catId_CatItemIdAndCIRecOrder.containsKey(catIdCatItemId)){
                               projIdAndLPROrder.put(pt.AcctSeed__Project__c, catId_CatItemIdAndCIRecOrder.get(catIdCatItemId)); 
                            }
                            
                            isFromDCAT = True;
                        }
                    }
                }
            }            
        }
        System.debug(':projecIds::::'+projecIds);
        if(projecIds.size() > 0) {
            for(Assessment_Report__c a : [SELECT Id, Project__c, Project__r.AcctSeed__Account__r.Name, Status__c, Evaluation_Period_From__c, Evaluation_Period_To__c, Language_Training_Status__c, Report_Date__c
                                            FROM Assessment_Report__c 
                                            WHERE Project__c IN :projecIds AND (Language_Training_Status__c = 'Progress' OR Test_Report_Type__c = 'Progress') ORDER BY Report_Date__c DESC]){
            
                  if(!projARMap.containskey(a.PRoject__c)) {
                      projARMap.put(a.PRoject__c, a);
                  } 
            }
            createAssessReport(projecIds, 'ProjectTask', reportMap, projARMap); 
        }
    }
   
    /***********
        - Added By HL on June 09 2021
        - Work Item: W-005524 - Progress Reports in DLS Online (JUN 1-2021)
        - To send a daily email notification to LTS related to the "Submitted to LTS" Assessment_Report 
        - To return all the Assessment_Report records related to the LTS (Project Manager)
        - Used in GetAssessmentReportCmp (Visualforce Component)
        *********/
    public String projManagerId{ get; set; }
        
    public List<Assessment_Report__c> assessmentReports {
    
        get{
        
            if(projManagerId != NULL){
            
                List<Assessment_Report__c> ars = [SELECT Id, Name, Report_Date__c, Project__r.Name,
                                                        Instructor__r.Name, Language_LU__r.Name, Report_Type__c,
                                                        Student__r.Name, RecordType_Name__c, Test_Report_Type__c
                                                    FROM Assessment_Report__c
                                                    WHERE Project_Manager__c = :projManagerId AND Status__c = 'Submitted to LTS'];
                if(ars != NULL && ars.size() > 0){
                    return ars;
                }else{
                    return new List<Assessment_Report__c>();    
                }
            }else{
                return new List<Assessment_Report__c>();
            }
        }
        set;
    }
      
    //Added By Dhinesh - 29-09-2021 - W-006984 - Annual Instructor Performance Review Process - ACCET
    public static void createAnnualInstructorPerformanceReviewReport(Set<Id> instructorIds){
        List<Contact> instructors = [SELECT Id, FirstName, LastName, Name, Supervisor_Name__c, Language_1__c FROM Contact WHERE Id IN :instructorIds];
        List<Assessment_Report__c> assessmentReportToInsert = new List<Assessment_Report__c>();
        Set<Id> supervisorIds = new Set<Id>();
        Id annualPerformanceReviewRecordTypeId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Annual_Instructor_Performance_Review').getRecordTypeId();
        Date reviewDate = System.Today().addDays(28);
        Map<Id, Id> instructorIdWithProjectIdMap = new Map<Id, Id>();
        Map<Id, Id> projIdWithLanguageMap = new Map<Id, Id>();
        
        for(AcctSeed__Time_Card_Line__c tcl :  [SELECT Id,AcctSeed__Project__c, AcctSeed__Project__r.Language__c,AcctSeed__Time_Card__r.Intructor__c 
                                                FROM AcctSeed__Time_Card_Line__c                  
                                                WHERE AcctSeed__Time_Card__r.Intructor__c IN :instructorIds AND AcctSeed__Project__r.Name != 'AFSAT UAE EFL - 10' ORDER BY LastModifiedDate DESC]){
                                                
            if(!instructorIdWithProjectIdMap.containsKey(tcl.AcctSeed__Time_Card__r.Intructor__c))
                instructorIdWithProjectIdMap.put(tcl.AcctSeed__Time_Card__r.Intructor__c, tcl.AcctSeed__Project__c); 
                
            projIdWithLanguageMap.put(tcl.AcctSeed__Project__c, tcl.AcctSeed__Project__r.Language__c);                                                   
        }
               
        
        for(Contact instructor: instructors){
            if(instructor.Supervisor_Name__c != null && !instructor.Name.toLowercase().contains('partner') && instructorIdWithProjectIdMap.get(instructor.Id) != null){
                // Commented on Aug 16 2023
                //String insName = String.isNotBlank(instructor.FirstName) ? instructor.FirstName : '';
                //insName += String.isNotBlank(instructor.LastName) ? ' ' + instructor.LastName : '';
                
                supervisorIds.add(instructor.Supervisor_Name__c);
                
                assessmentReportToInsert.add(
                    new Assessment_Report__c(Instructor__c=instructor.Id, 
                                             Project_Manager__c=instructor.Supervisor_Name__c,
                                             Review_Period_Year__c=String.valueOf(System.Today().year()),
                                             Report_Date__c=reviewDate,
                                             RecordTypeId = annualPerformanceReviewRecordTypeId,
                                             // Commented on Aug 16 2023
                                             //Name = 'Instructor Annual Performance Review – '+insName+' - '+('0' + reviewDate.month()).right(2)+'/'+reviewDate.year(),
                                             Status__c = 'Scheduled',
                                             Project__c = instructorIdWithProjectIdMap.get(instructor.Id),
                                             Language_LU__c = projIdWithLanguageMap.get(instructorIdWithProjectIdMap.get(instructor.Id))
                                            )
                );
            }
        }
        insert assessmentReportToInsert;
        /*NewClassAnnouncementController.addStaffRecordTypeFilter = true;
        Map<Id,Id> userIdWithContactIdMap = PlannedDaysOffHandler.getUserRelatedContacts(supervisorIds);
        if(userIdWithContactIdMap.size() > 0){
            List<EmailTemplate> emailTemp = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Annual_Instructor_Performance_Report_Created']; 
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
            for(Assessment_Report__c assessmentReport: assessmentReportToInsert){
                Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
                
                message.setTargetObjectId(userIdWithContactIdMap.get(assessmentReport.Project_Manager__c)); 
                message.setTemplateID(emailTemp[0].Id); 
                message.setWhatId(assessmentReport.Id);
                messages.add(message);                
            }
            
            if(!Test.isRunningTest() && messages.size() > 0){
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                }
            }
        } */       
    }    
    
    //Added By Dhinesh - 27/04/2022 - W-007433 - Training Reports for On Hold Projects
    public static void deleteTrainingReportsForOnHoldProjects(Map<Id, Date> projIdsWithOnHoldDateMap){
        List<Assessment_Report__c> assessmentReportsToDelete = new List<Assessment_Report__c>();
        
        for(Assessment_Report__c assessmentReport : [SELECT Id, Project__c, Report_Date__c
                                                                                      FROM Assessment_Report__c 
                                                                                      WHERE Project__c IN :projIdsWithOnHoldDateMap.keyset() AND Status__c IN ('Scheduled','Draft')  
                                                                                      AND RecordType.DeveloperName NOT IN ('Annual_Instructor_Performance_Review') 
                                                                                      AND Report_Date__c >= :projIdsWithOnHoldDateMap.values()]){
            
            if(assessmentReport.Report_Date__c >= projIdsWithOnHoldDateMap.get(assessmentReport.Project__c)){
                assessmentReportsToDelete.add(assessmentReport);                                                                                  
            }
        }
        
        if(assessmentReportsToDelete.size() > 0)
            delete assessmentReportsToDelete;
    }
      //Added By Siva Prasanth - 17/11/2022 
    @AuraEnabled
    public static String getPRTestReportTypes(String projId){
      List<String> projIdReportTypes = new List<String>();
      Map<String, List<String>> AccountNameARMap = new Map<String, List<String>>{
            'FAS' => new List<String>{'Final Report'},
            'FCS' => new List<String>{'Monthly'}, 
            'FCS2' => new List<String>{'Final Report'},
            'PVT' => new List<String>{'Final Report'},
            'DLI' => new List<String>{'Monthly'}, 
            'APMO' => new List<String>{'Monthly'},  // new Monthly Reports similar to DLI
            'SLP' => new List<String>{'Progress', 'Final Report','Initial Test Report','Final Test Report'}, // updated Midterm to Progress
            //'JMAS' => new List<String>{'Final Report'},
            'Ad-hoc' => new List<String>{'Monthly', 'Final Report','Initial Test Report','Final Test Report'},
            'PLP' => new List<String>{'Final Report'},
            'PGLS' => new List<String>{'Monthly'},
            'Other' => new List<String>{'Final Report'} // All other accounts except the above listed
        }; 
            
        List<AcctSeed__Project__c> projects = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',new Set<Id>{projId},',AcctSeed__Account__r.Name, Language__r.Name, Program_Iteration__r.Project_Type__c,Program_Iteration__r.Final_Progress_Due_Date__c,Program_Iteration__r.Midterm_Progress_Due_Date__c,Program_Iteration__r.Start_Date__c,Program_Iteration__r.End_Date__c');
        System.debug(':::projects:::'+projects);     
        

        for( AcctSeed__Project__c pr : projects ) {
            // JMAS project type condition Added on May 15 2024 : W-008048 - JMAS Projects - No Longer Need Initial and Final assessments/reports/scores : To prevent the auto creation of training reports for DODA project with JMAS project type
            if(pr.AcctSeed__Account__c != null && pr.AcctSeed__Account__r.Name != null && pr.DLI_Project_Type__c != 'EI' && pr.Project_Type__c != 'JMAS') {
                if(pr.AcctSeed__Account__r.Name.contains('DLI') || pr.RecordTypeId == dliRTId_Proj) {
                    projIdReportTypes = AccountNameARMap.get('DLI');
                } else if((pr.AcctSeed__Account__r.Name == 'PVT' || pr.AcctSeed__Account__r.Name.contains('PVT')) && pr.QB_Classification__c != 'OF0MTT0PS') {  //&& projFinalReportMap.containskey(pr.Id) && projFinalReportMap.get(pr.Id) == true
                    projIdReportTypes = AccountNameARMap.get('PVT');
                } else if(pr.AcctSeed__Account__r.Name.contains('DODA')) { //&& pr.QB_Classification__c != 'OF0MTT0PS' Commented on 05/05/2022 to not check the QB Classification for DODA
                    if(pr.Program_Iteration__c != null) {
                        if( pr.Program_Iteration__r.Project_Type__c == 'SLP-FT' || pr.Program_Iteration__r.Project_Type__c == 'SLP-PT'){                            
                            // Modified on Jan 19 2023: W-007686 - Request to remove Initial Test Reports from SLP Initial Acquisition Projects
                            // Initial Test Report will not created for DODA Projects with Project Type = SLP-FT or SLP-PT and Program Type = Familiarization or Initial acquisition
                            if(!programTypesToExludeInitialTestReports.contains(pr.Program_Type__c)){
                                projIdReportTypes = AccountNameARMap.get('SLP');
                            }else{
                                projIdReportTypes = new List<String>{'Progress', 'Final Report','Final Test Report'};
                            }
                        } /*
                        else if( pr.Program_Iteration__r.Project_Type__c == 'JMAS') {
                            projIdReportTypes = AccountNameARMap.get('JMAS');
                        } */
                        else if( pr.Program_Iteration__r.Project_Type__c == 'PLP') {
                            projIdReportTypes = AccountNameARMap.get('PLP');
                        }
                    } else {
                        projIdReportTypes = AccountNameARMap.get('Ad-hoc');
                    }
                } else if(pr.AcctSeed__Account__r.Name.contains('FCS')) { 
                    if(pr.AcctSeed__Account__r.Name != 'FCS2') {
                        projIdReportTypes = AccountNameARMap.get('FCS');
                    } else if(pr.AcctSeed__Account__r.Name == 'FCS2') {
                        projIdReportTypes = AccountNameARMap.get('FCS2');
                    }
                } else if(pr.AcctSeed__Account__r.Name.contains('FAS')) {
                    projIdReportTypes = AccountNameARMap.get('FAS');
                } else if(pr.AcctSeed__Account__r.Name.contains('APMO')) {
                    projIdReportTypes = AccountNameARMap.get('APMO');
                } else if(pr.AcctSeed__Account__r.Name.contains('PGLS')) {
                    projIdReportTypes = AccountNameARMap.get('PGLS');
                } else if(pr.AcctSeed__Account__c != null){ // For all other Accounts create Final Reports
                    projIdReportTypes = AccountNameARMap.get('Other');
                }
            }
        }
        return JSON.serialize(projIdReportTypes);
    }
    
    // To update the Project Manager in the Assessment Report when the Project Manager is updated in the Project
    public static void updateAssementReportPM(Map<Id,Id> pMId, Set<Id> projProgramTypeUpd) {
        List<Assessment_Report__c> ARToUpdate = new List<Assessment_Report__c>(); 
        Map<String,String> typeApiToLabelMap = new Map<String,String>();
        Set<String> RTMap = new Set<String>{'Observation_Report','Annual_Instructor_Performance_Review','DLI_Observation_Report'};
        System.debug('pMId::::::'+pMId);
        Set<Id> projIds = new Set<Id>();
        // Id of the Project Manager Updated Project
        if(pMId.size() > 0) {
            projIds.addall(pMId.keyset());
        }
        // Id of the Program Type updated Project
        if(projProgramTypeUpd.size() > 0) {
            typeApiToLabelMap = toGetProgramTypeLblVal();
            projIds.addall(projProgramTypeUpd);
        }
        
        if(projIds.size() > 0 ) {
            for( Assessment_Report__c ar : [SELECT Id, Student__c, Status__c, Project__c, Project_Manager__c,Project__r.Program_type__c,RecordType.DeveloperNAme,Type_of_Training__c FROM Assessment_Report__c WHERE Project__c IN : projIds AND Status__c IN ('Scheduled', 'Draft')]) {
                if(pMId != null && pMId.containskey(ar.Project__c)) {
                    ar.Project_Manager__c = pMId.get(ar.Project__c);
                }
                // To update the Training Report's Type of Training field when the Program Type is updated in the Project
                if(projProgramTypeUpd != null && projProgramTypeUpd.contains(ar.Project__c) && !RTMap.contains(ar.RecordType.DeveloperNAme)) {
                    String tempStr = typeApiToLabelMap.containskey(ar.Project__r.Program_type__c) ? typeApiToLabelMap.get(ar.Project__r.Program_type__c) : ar.Project__r.Program_type__c; 
                    if(ar.Type_of_Training__c != tempStr) {
                        ar.Type_of_Training__c = tempStr;
                    }
                }
                ARToUpdate.add(ar);
            }
            System.debug('ARToUpdate::::::'+ARToUpdate);
            if(ARToUpdate.size() > 0) {
                update ARToUpdate;
            }
        }
    } 
    
    // To get the Label of the Program Type pikclist field from Project
    public static Map<String,String> toGetProgramTypeLblVal(){
        
        List<Schema.PicklistEntry> typvalues = AcctSeed__Project__c.Program_type__c.getDescribe().getPicklistValues();
        Map<String,String> typeApiToLabelMap = new Map<String,String>();
        For(Schema.PicklistEntry sp : typvalues){
            //Map to hold Picklist API as Key and Picklist Label as Value
            typeApiToLabelMap.put(sp.getValue(), sp.getLabel());
        }
        System.debug('Label value of Program Type picklist>>'+ typeApiToLabelMap);
        return typeApiToLabelMap;
    }
    
    /************
        - Added on May 11 2023
        - W-007783 : Issue with DLI Training Report Auto Cancellation when DLI Project End Date isChange
        - To update related assessment report's due date value when project's end date is increased or decreased
        - If Project_End_Date is decreased : To cancel assessment reports when project's end date is updated (decreased) from higher value to lower value
        - If Project_End_Date is increased : To update exist monthly report's due date if needed and create new reports for upcoming month(s)
        *************/
    public static void updateAssessmentReports_DueDate(List<Acctseed__Project__c> newProj, Map<Id, Acctseed__Project__c> oldProjMap){
        
        Map<Id, Date> projIdAndDate_Inc = new Map<Id, Date>();
        Map<Id, Date> projIdAndDate_Dec = new Map<Id, Date>();
        Map<Id, Date> projIdAndPostponedSD = new Map<Id, Date>();
        
        Set<Id> allProjdIds = new Set<Id>();
        Map<Id, Assessment_Report__c> arMap = new Map<Id, Assessment_Report__c>();
        Set<String> arStatus = new Set<String>{'Canceled', 'Completed'};
        
        for(Acctseed__Project__c pro : newProj){
            
            if(pro.End_Date__c > oldProjMap.get(pro.Id).End_Date__c){
                projIdAndDate_Inc.put(pro.Id, pro.End_Date__c);
            }
            if(pro.End_Date__c < oldProjMap.get(pro.Id).End_Date__c){
                projIdAndDate_Dec.put(pro.Id, pro.End_Date__c);    
            }
            if(pro.Start_Date__c > oldProjMap.get(pro.Id).Start_Date__c){
                projIdAndPostponedSD.put(pro.Id, pro.Start_Date__c);        
            }
            allProjdIds.add(pro.Id);
        }
             
        if(!ManageProjectDatescontroller.assessRep_MPD.isEmpty()){
            arMap.putAll(ManageProjectDatescontroller.assessRep_MPD);
        }
        
        List<Assessment_Report__c> allARs = [SELECT Id, Report_Date__c, Project__c, Language_Training_Status__c, Test_Report_Type__c, RecordType.DeveloperName 
                                                FROM Assessment_Report__c 
                                                WHERE Project__c IN : allProjdIds AND Status__c NOT IN : arStatus AND 
                                                    RecordType.DeveloperName NOT IN ('Annual_Instructor_Performance_Review')];
        if(!allARs.isEmpty()){
        
            if(projIdAndDate_Dec.size() > 0){
                toCancelAssessmentReports(projIdAndDate_Dec, allARs, arMap);
            }     
            
            if(projIdAndDate_Inc.size() > 0){
                to_Create_UpdateAssessmentReports(projIdAndDate_Inc, allARs, arMap, oldProjMap);
            } 
            
            if(projIdAndPostponedSD.size() > 0){
                to_Delete_AR_Project_SD_Postponed(projIdAndPostponedSD, allARs, arMap);
            }
        }
    }
    
    public static void to_Create_UpdateAssessmentReports(Map<Id, Date> projIdAndDate_Inc, List<Assessment_Report__c> allARs, Map<Id, Assessment_Report__c> arMap, Map<Id, Acctseed__Project__c> oldProjMap){
    
        List<Assessment_Report__c> updateARs = new List<Assessment_Report__c>();
        Set<Id> projectIds = new Set<Id>();
        
        Map<Id, Date> projIdAndMonthlyDate = new Map<Id, Date>();
        Set<Date> holSet = new Set<Date>();
        holSet = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
        
        for(AcctSeed__Project__c p : oldProjMap.values()){
        
            Integer i = 0;
        
            Date endDate = oldProjMap.get(p.Id).End_Date__c;
            Date lastDay_endDate = endDate.addMonths(1).toStartOfMonth().addDays(-1);
        
            while (i < 1){
        
                DateTime dtTim = DateTime.newInstance(lastDay_endDate, Time.newInstance(0, 0, 0, 0));  
        
                if(!holSet.contains(lastDay_endDate) && dtTim.format('EEEE') != 'Saturday' && dtTim.format('EEEE') != 'Sunday') {
                
                    projIdAndMonthlyDate.put(p.Id, lastDay_endDate);
                    i = 1;
                }else{
                    lastDay_endDate = lastDay_endDate.addDays(-1);
                }
            }
        }

        for(Assessment_Report__c a : allARs){
                
            if(!arMap.containsKey(a.Id)){
            
                if(projIdAndDate_Inc.containsKey(a.Project__c)){
                    
                    /**********
                        - For FCS / DLI / APMO / PGLS projects we set project's end date as due date instead of end date of a month for last record
                        - Update due date of monthly reports if it has due date as old end date of a project
                        - because while calling createAssessReport() method it will create duplicate monthly reports if they due date as mid of month()
                        - Ex : FCS Project (SD : 01/05/2023 ED : 17/07/2023) its Monthly Reports are (31/05/2023, 30/06/2023, 17/07/2023)
                        - Updating project's end date from 17/07/2023 to 24/08/2023 it will create duplicate report for 31/07/2023, so we are updating 17/07/2023 report date as 31/07/2023
                        - Added DLI observation recordtype condition on May 23 2024 : W-008050 - Issue with DLI Observation Report Creation on DLI Project
                        - To fix "DUPLICATES_DETECTED, There is an existing Training Report with this Name" issue
                        *************/
                    if(a.Language_Training_Status__c == 'Monthly' || a.Test_Report_Type__c == 'Monthly' || a.RecordType.DeveloperName == 'DLI_Observation_Report'){
                            
                        if((oldProjMap.get(a.Project__c).End_Date__c.month() == a.Report_Date__c.month() || oldProjMap.get(a.Project__c).End_Date__c == a.Report_Date__c) && 
                            projIdAndMonthlyDate.containsKey(a.Project__c) && projIdAndMonthlyDate.get(a.Project__c) != a.Report_Date__c){
                        
                            a.Report_Date__c = projIdAndMonthlyDate.get(a.Project__c);
                            updateARs.add(a);
                        }
                    }
                }
            }
        }
        
        if(updateARs.size() > 0){
            update updateARs;
        }
                
        for(Schedule__c s : [SELECT Id, Project__c FROM Schedule__c WHERE Project__c IN: projIdAndDate_Inc.keyset() and Status__c = 'Active' AND Project_Task__r.Project_Task_Type__c = 'Language Training' ORDER BY CreatedDate DESC]){
        
            projectIds.add(s.Project__c);
        }
        
        if(projectIds.size() > 0){
            //Assessment_Report_Helper.createAssessReport(projectIds, 'Project_Trigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());    
            Assessment_Report_Helper.callAssessmentReportHelper(projectIds);
        }
    }
    
    @future
    public static void callAssessmentReportHelper(Set<Id> projectIds){
        
        Assessment_Report_Helper.createAssessReport(projectIds, 'Project_Trigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());    
    }
    
    public static void toCancelAssessmentReports(Map<Id, Date> projIdAndDateToCancelARs, List<Assessment_Report__c> allARs, Map<Id, Assessment_Report__c> arMap){

        if(projIdAndDateToCancelARs.size() > 0){
                
            List<Assessment_Report__c> updateARs = new List<Assessment_Report__c>();
                
            for(Assessment_Report__c a : allARs){
                
                if(!arMap.containsKey(a.Id)){
                
                    if(projIdAndDateToCancelARs.containsKey(a.Project__c) && a.Report_Date__c > projIdAndDateToCancelARs.get(a.Project__c)){
                        
                        if(projIdAndDateToCancelARs.get(a.Project__c).month() != a.Report_Date__c.month()){
                        
                            a.Status__c = 'Canceled';
                        }else if(projIdAndDateToCancelARs.get(a.Project__c).month() == a.Report_Date__c.month()){
                            
                            if(a.Language_Training_Status__c != 'Monthly' && a.Test_Report_Type__c != 'Monthly'){
                            
                                a.Status__c = 'Canceled';
                            }else if(a.Language_Training_Status__c == 'Monthly' || a.Test_Report_Type__c == 'Monthly'){
                                
                                if(projIdAndDateToCancelARs.get(a.Project__c).day() > 10){
                                    
                                    a.Report_Date__c = projIdAndDateToCancelARs.get(a.Project__c);
                                }else{
                                    a.Status__c = 'Canceled';
                                }
                            }
                        }
                        updateARs.add(a);
                    }    
                }
            }
            if(updateARs.size() > 0){
                update updateARs;
            }
        }
    }
    
    public static void updateARToCancelled(Set<Id> projIds){
        
        List<Assessment_Report__c> allARs = [SELECT Id, Status__c 
                                                FROM Assessment_Report__c 
                                                WHERE Project__c IN : projIds AND Status__c IN ('Draft', 'Scheduled') AND 
                                                    RecordType.DeveloperName NOT IN ('Annual_Instructor_Performance_Review')];
        if(!allARs.isEmpty()){
        
            List<Assessment_Report__c> cancelARs = new List<Assessment_Report__c>();
            
            for(Assessment_Report__c a : allARs){
                a.Status__c = 'Canceled';  
                cancelARs.add(a);  
            }
            if(!cancelARs.isEmpty()){
                update cancelARs;
            }
        }
    }
    
    public static Id getARRecordTypeId(String recordTypeDevName){
        
        Id recordTypeId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        return recordTypeId;
    }
    
    public static void to_Delete_AR_Project_SD_Postponed(Map<Id, Date> projIdAndPostponedSD, List<Assessment_Report__c> allARs, Map<Id, Assessment_Report__c> arMap){
            
        if(projIdAndPostponedSD.size() > 0){
                
            List<Assessment_Report__c> deleteARs = new List<Assessment_Report__c>();
                
            for(Assessment_Report__c a : allARs){
                
                if(!arMap.containsKey(a.Id)){
                
                    if(projIdAndPostponedSD.containsKey(a.Project__c) && a.Report_Date__c < projIdAndPostponedSD.get(a.Project__c)){
                        
                        deleteARs.add(a);
                    }    
                }
            }
            if(deleteARs.size() > 0){
                delete deleteARs;
            }
        }
    }
}