trigger UpdateGoalVSscoreField on Assessment_Report__c (Before insert,Before update,After insert,After update) {

    Map<String,Integer> gradeAndMarkMap = new  Map<String,Integer> {'0'=>1,'0+'=>2,'1'=>3,'1+'=>4,'2'=>5,'2+'=>6,'3'=>7,'3+'=>8,'4'=>9,'4+'=>10,'5'=>11};
    List<Assessment_Report__c> assReportList = new  List<Assessment_Report__c>();
    Map<Id,String> ProjectIdLanguageMap = new Map<Id,String>();
    Map<Id,AcctSeed__Project_Task__c> projectProjectTaskMap = new Map<Id,AcctSeed__Project_Task__c>();
    
    Id apmoReport = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('APMO_Progress').getRecordTypeId();
    Id dliReport = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Progress').getRecordTypeId();
    Id dli22Report = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Progress_2022').getRecordTypeId();
    Id dliTest = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Test_Report').getRecordTypeId();
    Id dliSelfTest = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Self_Assessment_Test_Report').getRecordTypeId();
    Id lTReport = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Language_Training_Progress').getRecordTypeId();
    Id observationRecordTypeId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Observation_Report').getRecordTypeId();
    Id dliObservationRecordTypeId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_Observation_Report').getRecordTypeId();
    Id testRTId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Test_Report').getRecordTypeId();
    Id annualReviewRTId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Annual_Instructor_Performance_Review').getRecordTypeId();


    Set<Id> projIds = new Set<Id>();
    List<Assessment_Report__c> aRUpdateList = new List<Assessment_Report__c>();
    Map<String, Assessment_Report__c> projAReportMap = new Map<String, Assessment_Report__c>();
        
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        
        List<Assessment_Report__c> updateARLRSProficiency = new List<Assessment_Report__c>();
        Map<String, Language_Testing__c> projIdStdIdAndLTRec = new Map<String, Language_Testing__c>();
        Map<String, Contact_Assignments__c> projIdStdIdAndCARec = new Map<String, Contact_Assignments__c>();
        Set<Id> projIdsToUpdateARs = new Set<Id>();
        Set<Id> stdIdsToUpdateARs = new Set<Id>();
        
        Set<Id> projIdsToUpdateARName = new Set<Id>();
        Set<Id> stdIdsToUpdateARName = new Set<Id>();
        Set<Id> insIdsToUpdateARName = new Set<Id>();
        List<Assessment_Report__c> arListToUpdateName = new List<Assessment_Report__c>();
        
        List<Assessment_Report__c> annualReports = new List<Assessment_Report__c>();
        Set<Id> annualReportInsIds = new Set<Id>();
        
        Map<Id, Id> newProjIdAndOldProjId = new Map<Id, Id>();
        List<Assessment_Report__c> transferredReports = new List<Assessment_Report__c>();
        
        for(Assessment_Report__c ar: Trigger.new){
            
            //Added By Dhinesh - 14/10/2021 - To Update the Name for Observation and Annual Report if the Review Date changes
            if(Trigger.isUpdate && ar.Status__c != 'Canceled' && ar.Status__c != 'Completed' && (ar.RecordTypeId == annualReviewRTId || ar.RecordTypeId == observationRecordTypeId || ar.RecordTypeId == dliObservationRecordTypeId ) 
                && ar.Report_Date__c != Trigger.oldMap.get(ar.Id).Report_Date__c){
                String str = ar.RecordTypeId == annualReviewRTId ? ' - ' : '-';    
                ar.Name = ar.Name.substring(0, ar.Name.lastIndexOfIgnoreCase(str)) + str +('0' + ar.Report_Date__c.month()).right(2)+'/'+ar.Report_Date__c.year();
            }
                        
            /* Commented since we replaced Language_Proficiency_Score_Listening__c with the Current_Estimated_ILR_Rating_Listening new fields
            if( ( ar.Proficiency_Objective_Listening__c != null && 
                  ar.Proficiency_Objective_Listening__c != 'N/A' && 
                  ar.Proficiency_Objective_Reading__c != null && 
                  ar.Proficiency_Objective_Reading__c != 'N/A' &&
                  ar.Proficiency_Objective_Speaking__c != null &&
                  ar.Proficiency_Objective_Speaking__c != 'N/A'
                ) ||  
                ( 
                 ar.Language_Proficiency_Score_Listening__c != null &&
                 ar.Language_Proficiency_Score_Listening__c != 'N/A' &&
                 ar.Language_Proficiency_Score_Reading__c != null &&
                 ar.Language_Proficiency_Score_Reading__c != 'N/A' &&
                 ar.Language_Proficiency_Score_Speaking__c != null &&
                 ar.Language_Proficiency_Score_Speaking__c != 'N/A'
                )
            ) {
                               
               if(gradeAndMarkMap.get(ar.Proficiency_Objective_Listening__c ) > gradeAndMarkMap.get(ar.Language_Proficiency_Score_Listening__c) ||
                  gradeAndMarkMap.get(ar.Proficiency_Objective_Reading__c ) > gradeAndMarkMap.get(ar.Language_Proficiency_Score_Reading__c) ||
                  gradeAndMarkMap.get(ar.Proficiency_Objective_Speaking__c ) > gradeAndMarkMap.get(ar.Language_Proficiency_Score_Speaking__c)) {
                   
                  ar.GoalVersusScore__c = 'Not Met';
               } else if(gradeAndMarkMap.get(ar.Proficiency_Objective_Listening__c ) == gradeAndMarkMap.get(ar.Language_Proficiency_Score_Listening__c) &&
                  gradeAndMarkMap.get(ar.Proficiency_Objective_Reading__c ) == gradeAndMarkMap.get(ar.Language_Proficiency_Score_Reading__c) &&
                  gradeAndMarkMap.get(ar.Proficiency_Objective_Speaking__c ) == gradeAndMarkMap.get(ar.Language_Proficiency_Score_Speaking__c)) {
                  
                   ar.GoalVersusScore__c = 'Met';
               } else if(gradeAndMarkMap.get(ar.Proficiency_Objective_Listening__c ) <= gradeAndMarkMap.get(ar.Language_Proficiency_Score_Listening__c) &&
                  gradeAndMarkMap.get(ar.Proficiency_Objective_Reading__c ) <= gradeAndMarkMap.get(ar.Language_Proficiency_Score_Reading__c) &&
                  gradeAndMarkMap.get(ar.Proficiency_Objective_Speaking__c ) <= gradeAndMarkMap.get(ar.Language_Proficiency_Score_Speaking__c)) {
                   
                   ar.GoalVersusScore__c = 'Exceeded';
               }
            
            }
            */
            
            if(ar.Project__c != NULL && String.isNotBlank(ar.Language__c) && !ProjectIdLanguageMap.containskey(ar.Project__c)) {
                ProjectIdLanguageMap.put(ar.Project__c,ar.Language__c);
            }
            
            // To update the Scheduled Report with the old values when it is already having values in the Assessment fields
            if(Trigger.isUpdate && ar.Status__c != Trigger.oldMap.get(ar.Id).Status__c && ar.Status__c == 'Scheduled' && Trigger.oldMap.get(ar.Id).Status__c == 'Draft' && 
                (ar.RecordTypeId == dliReport || ar.RecordTypeId == apmoReport || ar.RecordTypeId == dli22Report || ar.RecordTypeId == dliTest || ar.RecordTypeId == dliSelfTest || (ar.RecordTypeId == lTReport && (ar.Language_Training_Status__c == 'Monthly' || ar.Language_Training_Status__c == 'Final' || ar.Language_Training_Status__c == 'Midterm')))) {
                projIds.add(ar.Project__c);
                aRUpdateList.add(ar);
            }
            
            // To temporarily have a field to get the Student comments from the Student during the signing process
            if(Trigger.isUpdate && ar.Student_Comments_Conga__c != Trigger.oldMap.get(ar.Id).Student_Comments_Conga__c && ar.Student_Comments_Conga__c != null) {
                
                ar.Student_Comments__c = ar.Student_Comments_Conga__c;
            }
            
            // To update Initial Proficiency fields based on the Language Testing Initial record
            if(Trigger.isUpdate && ar.Status__c == 'Scheduled' && ar.Status__c != Trigger.oldMap.get(ar.Id).Status__c && Trigger.oldMap.get(ar.Id).Status__c == 'Draft'){
                updateARLRSProficiency.add(ar);
                projIdsToUpdateARs.add(ar.Project__c);
                stdIdsToUpdateARs.add(ar.Student__c);
            }           
            
            // Added on Aug 10 2023
            if(Trigger.isInsert){
                if(ar.Project__c != null && ar.RecordTypeId != Assessment_Report_Helper.getARRecordTypeId('Annual_Instructor_Performance_Review')){
                    projIdsToUpdateARName.add(ar.Project__c);
                    if(ar.Student__c != null){
                        stdIdsToUpdateARName.add(ar.Student__c);
                    }
                    if(ar.Student__c == null && ar.Instructor__c != null){
                        insIdsToUpdateARName.add(ar.Instructor__c);
                    }
                    arListToUpdateName.add(ar);
                }    
                if(ar.RecordTypeId == Assessment_Report_Helper.getARRecordTypeId('Annual_Instructor_Performance_Review') && ar.Instructor__c != null){
                    annualReports.add(ar); 
                    annualReportInsIds.add(ar.Instructor__c);           
                }
            }
            
            // W-007991 : Update to Transfer Button Functionality on Student CA
            if(Trigger.isUpdate && ar.Project__c != Trigger.oldMap.get(ar.Id).Project__c && ar.Status__c != 'Canceled' && ar.Status__c != 'Completed'){
                
                transferredReports.add(ar);
                newProjIdAndOldProjId.put(ar.Project__c, Trigger.oldMap.get(ar.Id).Project__c);
            }
        }
        
        if(transferredReports.size() > 0){
            AssessmentReportTriggerHandler.updateTransferredTRName(transferredReports, newProjIdAndOldProjId);
        }
        
        if(arListToUpdateName.size() > 0){
            AssessmentReportTriggerHandler.updateAssessmentReportName(projIdsToUpdateARName, stdIdsToUpdateARName, insIdsToUpdateARName, arListToUpdateName);        
        }
        
        if(annualReports.size() > 0){
            AssessmentReportTriggerHandler.updateAnnualReportsName(annualReportInsIds, annualReports);
        }
        
        if(updateARLRSProficiency.size() > 0){
        
            for(Language_Testing__c  lt : [SELECT Id, Project__c, Testee__c, L_Score__c, R_Score__c, S_Score__c FROM Language_Testing__c WHERE Project__c IN: projIdsToUpdateARs AND Testee__c IN : stdIdsToUpdateARs AND Test_Type__c = 'Initial' ORDER BY CreatedDate DESC]){
                String projIdAndStdId = lt.Project__c+'-'+lt.Testee__c;
                if(!projIdStdIdAndLTRec.containsKey(projIdAndStdId)){
                    projIdStdIdAndLTRec.put(projIdAndStdId, lt);
                }        
            }
            // Ended Status condition added on Feb 29 2024 : W-008001 - Final Progress Report Missing Goals (Proficiency Objectives fields = NA)
            //  If the Student CA is updated to Ended before the Final report is updated to Scheduled, then the system will correctly pull the goals from the Ended Student CA.
            for(Contact_Assignments__c  ca : [SELECT Id, Project__c, Candidate_Name__c, L_Score_Final__c, R_Score_Final__c, S_Score_Final__c FROM Contact_Assignments__c WHERE Project__c IN: projIdsToUpdateARs AND Candidate_Name__c IN : stdIdsToUpdateARs AND RecordType.DeveloperName = 'Student' AND Status__c IN ('Active', 'Ended') ORDER BY CreatedDate DESC]){
                String projIdAndStdId = ca.Project__c+'-'+ca.Candidate_Name__c;
                if(!projIdStdIdAndCARec.containsKey(projIdAndStdId)){
                    projIdStdIdAndCARec.put(projIdAndStdId, ca);
                }        
            }
            
            // Added By HL on Jul 27 2021 - Work Item: W-005524 - Progress Reports in DLS Online (JUL 1-2021)
            for(Assessment_Report__c ar : updateARLRSProficiency){
                String projIdAndStdId = ar.Project__c+'-'+ar.Student__c;
                if(projIdStdIdAndLTRec.containsKey(projIdAndStdId)){
                    ar.Initial_Proficiency_Listening__c = projIdStdIdAndLTRec.get(projIdAndStdId).L_Score__c;
                    ar.Initial_Proficiency_Reading__c = projIdStdIdAndLTRec.get(projIdAndStdId).R_Score__c;
                    ar.Initial_Proficiency_Speaking__c = projIdStdIdAndLTRec.get(projIdAndStdId).S_Score__c;
                }   
                if(projIdStdIdAndCARec.containsKey(projIdAndStdId)){
                    ar.Proficiency_Objective_Listening__c = projIdStdIdAndCARec.get(projIdAndStdId).L_Score_Final__c;
                    ar.Proficiency_Objective_Reading__c = projIdStdIdAndCARec.get(projIdAndStdId).R_Score_Final__c;
                    ar.Proficiency_Objective_Speaking__c = projIdStdIdAndCARec.get(projIdAndStdId).S_Score_Final__c;
                }   
            }
        }
        
        if(ProjectIdLanguageMap != NULL && ProjectIdLanguageMap.size() > 0){
        
            for(AcctSeed__Project_Task__c pt:[SELECT Id,Name,Language__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :ProjectIdLanguageMap.keyset() AND Language__c IN:ProjectIdLanguageMap.values()]){
                projectProjectTaskMap.put(pt.AcctSeed__Project__c,pt);
            }
        }
       
        if(projectProjectTaskMap != NULL && projectProjectTaskMap.size() > 0){
        
            for (Assessment_Report__c ass : Trigger.New) {
                
                if(projectProjectTaskMap.containskey(ass.Project__c)) {
                    ass.Project_Task__c = projectProjectTaskMap.get(ass.Project__c).Id;
                }
            }
        }
        
        // Autofill the response from the previous Report if the New report is updated to Scheduled for the following Report types
        // Language Training - Monthly, Final
        // DLI Report
        System.debug('projIds::::'+projIds);
        System.debug('aRUpdateList::::'+aRUpdateList);
        
        if(projIds.size() > 0 ) {
        
            for(Assessment_Report__c art : AssessmentReportService.getAssessmentReportsByprojIds(projIds, ' AND Status__c = \'Completed\' ORDER By Report_Date__c DESC', '')) {
                String temp = art.Project__c + '~' + art.Student__c + '~' + art.RecordTypeId;
                if(!projAReportMap.containskey(temp)) {
                    projAReportMap.put(temp, art);
                }
            }
            System.debug('projAReportMap:::::'+projAReportMap);
            
            if(projAReportMap.size() > 0 ) {
            
                for(Assessment_Report__c rep : aRUpdateList ) {
                
                    String temp = rep.Project__c + '~' + rep.Student__c + '~' + rep.RecordTypeId;
                    
                    if(projAReportMap.containskey(temp)){
                    
                        if(rep.RecordTypeId == dliReport || rep.RecordTypeId == apmoReport) {
                            Assessment_Report__c tempAR = projAReportMap.get(temp);
                            rep.Prefilled_from_Recent_Completed_Report__c = true;
                            if(rep.Pronunciation1__c == null && tempAR.Pronunciation1__c != null) {
                                rep.Pronunciation1__c = tempAR.Pronunciation1__c;
                            }
                            if(rep.Fluency1__c == null && tempAR.Fluency1__c != null) {
                                rep.Fluency1__c = tempAR.Fluency1__c;
                            }
                            if(rep.Grammar1__c == null && tempAR.Grammar1__c != null) {
                                rep.Grammar1__c = tempAR.Grammar1__c;
                            }
                            if(rep.Vocabulary_Retention1__c == null && tempAR.Vocabulary_Retention1__c != null) {
                                rep.Vocabulary_Retention1__c = tempAR.Vocabulary_Retention1__c;
                            }
                            if(rep.Listening_Main_Idea1__c == null && tempAR.Listening_Main_Idea1__c != null) {
                                rep.Listening_Main_Idea1__c = tempAR.Listening_Main_Idea1__c;
                            }
                            if(rep.Listening_Details1__c == null && tempAR.Listening_Details1__c != null) {
                                rep.Listening_Details1__c = tempAR.Listening_Details1__c;
                            }
                            if(rep.Reading_Main_Idea1__c == null && tempAR.Reading_Main_Idea1__c != null) {
                                rep.Reading_Main_Idea1__c = tempAR.Reading_Main_Idea1__c;
                            }
                            if(rep.Reading_Details1__c == null && tempAR.Reading_Details1__c != null) {
                                rep.Reading_Details1__c = tempAR.Reading_Details1__c;
                            }
                            if(rep.Preparation_for_Class1__c == null && tempAR.Preparation_for_Class1__c != null) {
                                rep.Preparation_for_Class1__c = tempAR.Preparation_for_Class1__c;
                            }
                            if(rep.Attitude_and_Motivation1__c == null && tempAR.Attitude_and_Motivation1__c != null) {
                                rep.Attitude_and_Motivation1__c = tempAR.Attitude_and_Motivation1__c;
                            }
                            if(rep.Speaking_ILR_Rating__c == null && tempAR.Speaking_ILR_Rating__c != null) {
                                rep.Speaking_ILR_Rating__c = tempAR.Speaking_ILR_Rating__c;
                            }
                            if(rep.Listening_ILR_Rating__c == null && tempAR.Listening_ILR_Rating__c != null) {
                                rep.Listening_ILR_Rating__c = tempAR.Listening_ILR_Rating__c;
                            }
                            if(rep.Reading_ILR_Rating__c == null && tempAR.Reading_ILR_Rating__c != null) {
                                rep.Reading_ILR_Rating__c = tempAR.Reading_ILR_Rating__c;
                            }
                            if(rep.Simple_short_conversations__c == null && tempAR.Simple_short_conversations__c != null) {
                                rep.Simple_short_conversations__c = tempAR.Simple_short_conversations__c;
                            }
                            if(rep.Ask_simple_questions__c == null && tempAR.Ask_simple_questions__c != null) {
                                rep.Ask_simple_questions__c = tempAR.Ask_simple_questions__c;
                            }
                            if(rep.Cope_with_basic_survival_situation__c == null && tempAR.Cope_with_basic_survival_situation__c != null) {
                                rep.Cope_with_basic_survival_situation__c = tempAR.Cope_with_basic_survival_situation__c;
                            }
                            if(rep.Narrate_in_the_future__c == null && tempAR.Narrate_in_the_future__c != null) {
                                rep.Narrate_in_the_future__c = tempAR.Narrate_in_the_future__c;
                            }
                            if(rep.Narrate_in_the_past__c == null && tempAR.Narrate_in_the_past__c != null) {
                                rep.Narrate_in_the_past__c = tempAR.Narrate_in_the_past__c;
                            }
                            if(rep.Narrate_in_the_present__c == null && tempAR.Narrate_in_the_present__c != null) {
                                rep.Narrate_in_the_present__c = tempAR.Narrate_in_the_present__c;
                            }
                            if(rep.Do_physical_descriptions__c == null && tempAR.Do_physical_descriptions__c != null) {
                                rep.Do_physical_descriptions__c = tempAR.Do_physical_descriptions__c;
                            }
                            if(rep.Give_instructions_or_directions__c == null && tempAR.Give_instructions_or_directions__c != null) {
                                rep.Give_instructions_or_directions__c = tempAR.Give_instructions_or_directions__c;
                            }
                            if(rep.Report_facts_about_current_events__c == null && tempAR.Report_facts_about_current_events__c != null) {
                                rep.Report_facts_about_current_events__c = tempAR.Report_facts_about_current_events__c;
                            }
                            if(rep.Cope_with_survival_situation_with_a_comp__c == null && tempAR.Cope_with_survival_situation_with_a_comp__c != null) {
                                rep.Cope_with_survival_situation_with_a_comp__c = tempAR.Cope_with_survival_situation_with_a_comp__c;
                            }
                            if(rep.Support_opinion__c == null && tempAR.Support_opinion__c != null) {
                                rep.Support_opinion__c = tempAR.Support_opinion__c;
                            }
                            if(rep.Hypothesize__c == null && tempAR.Hypothesize__c != null) {
                                rep.Hypothesize__c = tempAR.Hypothesize__c;
                            }
                            if(rep.Discuss_an_abstract_topic__c == null && tempAR.Discuss_an_abstract_topic__c != null) {
                                rep.Discuss_an_abstract_topic__c = tempAR.Discuss_an_abstract_topic__c;
                            }
                            if(rep.Cope_with_an_unfamiliar_situation__c == null && tempAR.Cope_with_an_unfamiliar_situation__c != null) {
                                rep.Cope_with_an_unfamiliar_situation__c = tempAR.Cope_with_an_unfamiliar_situation__c;
                            }
                            if(rep.Understand_speech_about_basic_survival_n__c == null && tempAR.Understand_speech_about_basic_survival_n__c != null) {
                                rep.Understand_speech_about_basic_survival_n__c = tempAR.Understand_speech_about_basic_survival_n__c;
                            }
                            if(rep.Understand_simple_questions__c == null && tempAR.Understand_simple_questions__c != null) {
                                rep.Understand_simple_questions__c = tempAR.Understand_simple_questions__c;
                            }
                            if(rep.Listening_Understand_Main_Ideas__c == null && tempAR.Listening_Understand_Main_Ideas__c != null) {
                                rep.Listening_Understand_Main_Ideas__c = tempAR.Listening_Understand_Main_Ideas__c;
                            }
                            if(rep.Able_to_follow_instructions__c == null && tempAR.Able_to_follow_instructions__c != null) {
                                rep.Able_to_follow_instructions__c = tempAR.Able_to_follow_instructions__c;
                            }
                            if(rep.Understand_speech_on_concrete_topics__c == null && tempAR.Understand_speech_on_concrete_topics__c != null) {
                                rep.Understand_speech_on_concrete_topics__c = tempAR.Understand_speech_on_concrete_topics__c;
                            }
                            if(rep.Understand_supported_opinion__c == null && tempAR.Understand_supported_opinion__c != null) {
                                rep.Understand_supported_opinion__c = tempAR.Understand_supported_opinion__c;
                            }
                            if(rep.Understand_hypothesizing__c == null && tempAR.Understand_hypothesizing__c != null) {
                                rep.Understand_hypothesizing__c = tempAR.Understand_hypothesizing__c;
                            }
                            if(rep.Understand_abstract_topics__c == null && tempAR.Understand_abstract_topics__c != null) {
                                rep.Understand_abstract_topics__c = tempAR.Understand_abstract_topics__c;
                            }
                            if(rep.Read_short_simple_text_with_limited_acc__c == null && tempAR.Read_short_simple_text_with_limited_acc__c != null) {
                                rep.Read_short_simple_text_with_limited_acc__c = tempAR.Read_short_simple_text_with_limited_acc__c;
                            }
                            if(rep.Reading_Understand_Main_Ideas__c == null && tempAR.Reading_Understand_Main_Ideas__c != null) {
                                rep.Reading_Understand_Main_Ideas__c = tempAR.Reading_Understand_Main_Ideas__c;
                            }
                            if(rep.Able_to_read_simple_authentic_material__c == null && tempAR.Able_to_read_simple_authentic_material__c != null) {
                                rep.Able_to_read_simple_authentic_material__c = tempAR.Able_to_read_simple_authentic_material__c;
                            }
                            if(rep.Understand_main_ideas_details__c == null && tempAR.Understand_main_ideas_details__c != null) {
                                rep.Understand_main_ideas_details__c = tempAR.Understand_main_ideas_details__c;
                            }
                            if(rep.Authentic_materials_on_unfamiliar_topics__c == null && tempAR.Authentic_materials_on_unfamiliar_topics__c != null) {
                                rep.Authentic_materials_on_unfamiliar_topics__c = tempAR.Authentic_materials_on_unfamiliar_topics__c;
                            }
                            if(rep.Comprehend_supported_opinion__c == null && tempAR.Comprehend_supported_opinion__c != null) {
                                rep.Comprehend_supported_opinion__c = tempAR.Comprehend_supported_opinion__c;
                            }
                            
                        } else if(rep.RecordTypeId == lTReport) {
                            Assessment_Report__c tempAR = projAReportMap.get(temp);
                            rep.Prefilled_from_Recent_Completed_Report__c = true;
                            if(rep.Motivation1__c == null && tempAR.Motivation1__c != null) {
                                rep.Motivation1__c = tempAR.Motivation1__c;
                            }
                            if(rep.Attendance1__c == null && tempAR.Attendance1__c != null) {
                                rep.Attendance1__c = tempAR.Attendance1__c;
                            }
                            if(rep.Preparation1__c == null && tempAR.Preparation1__c != null) {
                                rep.Preparation1__c = tempAR.Preparation1__c;
                            }
                            if(rep.Pronunciation1__c == null && tempAR.Pronunciation1__c != null) {
                                rep.Pronunciation1__c = tempAR.Pronunciation1__c;
                            }
                            if(rep.Fluency1__c == null && tempAR.Fluency1__c != null) {
                                rep.Fluency1__c = tempAR.Fluency1__c;
                            }
                            if(rep.Grammar1__c == null && tempAR.Grammar1__c != null) {
                                rep.Grammar1__c = tempAR.Grammar1__c;
                            }
                            if(rep.Vocabulary_Retention1__c == null && tempAR.Vocabulary_Retention1__c != null) {
                                rep.Vocabulary_Retention1__c = tempAR.Vocabulary_Retention1__c;
                            }
                            if(rep.Syntax1__c == null && tempAR.Syntax1__c != null) {
                                rep.Syntax1__c = tempAR.Syntax1__c;
                            }
                            if(rep.Reading_Comprehension1__c == null && tempAR.Reading_Comprehension1__c != null) {
                                rep.Reading_Comprehension1__c = tempAR.Reading_Comprehension1__c;
                            }
                            if(rep.Listening_Comprehension1__c == null && tempAR.Listening_Comprehension1__c != null) {
                                rep.Listening_Comprehension1__c = tempAR.Listening_Comprehension1__c;
                            }
                        } else if(rep.RecordTypeId == dli22Report) {
                            Assessment_Report__c tempAR = projAReportMap.get(temp);
                            rep.Prefilled_from_Recent_Completed_Report__c = true;
                            if(rep.Assignments_includes_homework__c == null && tempAR.Assignments_includes_homework__c != null) {
                                rep.Assignments_includes_homework__c = tempAR.Assignments_includes_homework__c;
                            }
                            if(rep.Attitude_and_Engagement__c == null && tempAR.Attitude_and_Engagement__c != null) {
                                rep.Attitude_and_Engagement__c = tempAR.Attitude_and_Engagement__c;
                            }
                            if(rep.Class_Participation__c == null && tempAR.Class_Participation__c != null) {
                                rep.Class_Participation__c = tempAR.Class_Participation__c;
                            }
                            if(rep.Speaking_ILR_Rating__c == null && tempAR.Speaking_ILR_Rating__c != null) {
                                rep.Speaking_ILR_Rating__c = tempAR.Speaking_ILR_Rating__c;
                            }
                            if(rep.Listening_ILR_Rating__c == null && tempAR.Listening_ILR_Rating__c != null) {
                                rep.Listening_ILR_Rating__c = tempAR.Listening_ILR_Rating__c;
                            }
                            if(rep.Reading_ILR_Rating__c == null && tempAR.Reading_ILR_Rating__c != null) {
                                rep.Reading_ILR_Rating__c = tempAR.Reading_ILR_Rating__c;
                            }
                        } else if(rep.RecordTypeId == dliTest || rep.RecordTypeId == dliSelfTest) {
                            Assessment_Report__c tempAR = projAReportMap.get(temp);
                            rep.Prefilled_from_Recent_Completed_Report__c = true;
                            if(rep.Memorized_Formulaic_Words_Phrases__c == null && tempAR.Memorized_Formulaic_Words_Phrases__c != null) {
                                rep.Memorized_Formulaic_Words_Phrases__c = tempAR.Memorized_Formulaic_Words_Phrases__c;
                            }
                            if(rep.Using_Memorized_Formulaic_Phrases__c == null && tempAR.Using_Memorized_Formulaic_Phrases__c != null) {
                                rep.Using_Memorized_Formulaic_Phrases__c = tempAR.Using_Memorized_Formulaic_Phrases__c;
                            }
                            if(rep.Greet_and_Introduce_Myself__c == null && tempAR.Greet_and_Introduce_Myself__c != null) {
                                rep.Greet_and_Introduce_Myself__c = tempAR.Greet_and_Introduce_Myself__c;
                            }
                            if(rep.Provide_Minimal_Biographical_Info__c == null && tempAR.Provide_Minimal_Biographical_Info__c != null) {
                                rep.Provide_Minimal_Biographical_Info__c = tempAR.Provide_Minimal_Biographical_Info__c;
                            }
                            if(rep.Simple_Exchanges_about_Work_Experience__c == null && tempAR.Simple_Exchanges_about_Work_Experience__c != null) {
                                rep.Simple_Exchanges_about_Work_Experience__c = tempAR.Simple_Exchanges_about_Work_Experience__c;
                            }
                            if(rep.Simple_Exchanges_about_Travel__c == null && tempAR.Simple_Exchanges_about_Travel__c != null) {
                                rep.Simple_Exchanges_about_Travel__c = tempAR.Simple_Exchanges_about_Travel__c;
                            }
                            if(rep.Simple_Exchanges_Educational_Experience__c == null && tempAR.Simple_Exchanges_Educational_Experience__c != null) {
                                rep.Simple_Exchanges_Educational_Experience__c = tempAR.Simple_Exchanges_Educational_Experience__c;
                            }
                            if(rep.Make_Simple_Recommendations__c == null && tempAR.Make_Simple_Recommendations__c != null) {
                                rep.Make_Simple_Recommendations__c = tempAR.Make_Simple_Recommendations__c;
                            }
                            if(rep.Ask_simple_questions__c == null && tempAR.Ask_simple_questions__c != null) {
                                rep.Ask_simple_questions__c = tempAR.Ask_simple_questions__c;
                            }
                            if(rep.Cope_with_basic_survival_situation__c == null && tempAR.Cope_with_basic_survival_situation__c != null) {
                                rep.Cope_with_basic_survival_situation__c = tempAR.Cope_with_basic_survival_situation__c;
                            }
                            if(rep.Narrate_in_the_present__c == null && tempAR.Narrate_in_the_present__c != null) {
                                rep.Narrate_in_the_present__c = tempAR.Narrate_in_the_present__c;
                            }
                            if(rep.Narrate_in_the_past__c == null && tempAR.Narrate_in_the_past__c != null) {
                                rep.Narrate_in_the_past__c = tempAR.Narrate_in_the_past__c;
                            }
                            if(rep.Narrate_in_the_future__c == null && tempAR.Narrate_in_the_future__c != null) {
                                rep.Narrate_in_the_future__c = tempAR.Narrate_in_the_future__c;
                            }
                            if(rep.Do_physical_descriptions__c == null && tempAR.Do_physical_descriptions__c != null) {
                                rep.Do_physical_descriptions__c = tempAR.Do_physical_descriptions__c;
                            }
                            if(rep.Give_Instructions__c == null && tempAR.Give_Instructions__c != null) {
                                rep.Give_Instructions__c = tempAR.Give_Instructions__c;
                            }
                            if(rep.Give_Geographical_Directions__c == null && tempAR.Give_Geographical_Directions__c != null) {
                                rep.Give_Geographical_Directions__c = tempAR.Give_Geographical_Directions__c;
                            }
                            if(rep.Report_facts_about_current_events__c == null && tempAR.Report_facts_about_current_events__c != null) {
                                rep.Report_facts_about_current_events__c = tempAR.Report_facts_about_current_events__c;
                            }
                            if(rep.Cope_with_survival_situation_with_a_comp__c == null && tempAR.Cope_with_survival_situation_with_a_comp__c != null) {
                                rep.Cope_with_survival_situation_with_a_comp__c = tempAR.Cope_with_survival_situation_with_a_comp__c;
                            }
                            if(rep.Discuss_a_Hypothetical_Situation__c == null && tempAR.Discuss_a_Hypothetical_Situation__c != null) {
                                rep.Discuss_a_Hypothetical_Situation__c = tempAR.Discuss_a_Hypothetical_Situation__c;
                            }
                            if(rep.Present_on_a_Topic__c == null && tempAR.Present_on_a_Topic__c != null) {
                                rep.Present_on_a_Topic__c = tempAR.Present_on_a_Topic__c;
                            }
                            if(rep.Discuss_and_Compare_Societal_Issues__c == null && tempAR.Discuss_and_Compare_Societal_Issues__c != null) {
                                rep.Discuss_and_Compare_Societal_Issues__c = tempAR.Discuss_and_Compare_Societal_Issues__c;
                            }
                            if(rep.State_and_Defend_a_Position_or_Policy__c == null && tempAR.State_and_Defend_a_Position_or_Policy__c != null) {
                                rep.State_and_Defend_a_Position_or_Policy__c = tempAR.State_and_Defend_a_Position_or_Policy__c;
                            }
                            if(rep.Recognize_Common_Greetings_and_Intro__c == null && tempAR.Recognize_Common_Greetings_and_Intro__c != null) {
                                rep.Recognize_Common_Greetings_and_Intro__c = tempAR.Recognize_Common_Greetings_and_Intro__c;
                            }
                            if(rep.Understand_Minimal_Exchanges__c == null && tempAR.Understand_Minimal_Exchanges__c != null) {
                                rep.Understand_Minimal_Exchanges__c = tempAR.Understand_Minimal_Exchanges__c;
                            }
                            if(rep.Understand_Simple_Statements_Questions_L__c == null && tempAR.Understand_Simple_Statements_Questions_L__c != null) {
                                rep.Understand_Simple_Statements_Questions_L__c = tempAR.Understand_Simple_Statements_Questions_L__c;
                            }
                            if(rep.Understand_General_Subject_Matter_L__c== null && tempAR.Understand_General_Subject_Matter_L__c != null) {
                                rep.Understand_General_Subject_Matter_L__c = tempAR.Understand_General_Subject_Matter_L__c;
                            }
                            if(rep.Understand_main_ideas_details__c == null && tempAR.Understand_main_ideas_details__c != null) {
                                rep.Understand_main_ideas_details__c = tempAR.Understand_main_ideas_details__c;
                            }
                            if(rep.Understand_Narration_across_Timeframes_L__c== null && tempAR.Understand_Narration_across_Timeframes_L__c != null) {
                                rep.Understand_Narration_across_Timeframes_L__c = tempAR.Understand_Narration_across_Timeframes_L__c;
                            }
                            if(rep.Understand_Straightforward_Descriptions__c == null && tempAR.Understand_Straightforward_Descriptions__c != null) {
                                rep.Understand_Straightforward_Descriptions__c = tempAR.Understand_Straightforward_Descriptions__c;
                            }
                            if(rep.Comprehend_Supported_Opinion_Listening__c == null && tempAR.Comprehend_Supported_Opinion_Listening__c != null) {
                                rep.Comprehend_Supported_Opinion_Listening__c = tempAR.Comprehend_Supported_Opinion_Listening__c;
                            }
                            if(rep.Comprehend_Hypothesis_or_Conjecture_L__c == null && tempAR.Comprehend_Hypothesis_or_Conjecture_L__c != null) {
                                rep.Comprehend_Hypothesis_or_Conjecture_L__c = tempAR.Comprehend_Hypothesis_or_Conjecture_L__c;
                            }
                            if(rep.Draw_Inferences__c == null && tempAR.Draw_Inferences__c != null) {
                                rep.Draw_Inferences__c = tempAR.Draw_Inferences__c;
                            }
                            if(rep.Understand_Commonly_used_Rhetorical__c == null && tempAR.Understand_Commonly_used_Rhetorical__c != null) {
                                rep.Understand_Commonly_used_Rhetorical__c = tempAR.Understand_Commonly_used_Rhetorical__c;
                            }
                            if(rep.Recognize_Elements_of_the_Writing__c == null && tempAR.Recognize_Elements_of_the_Writing__c != null) {
                                rep.Recognize_Elements_of_the_Writing__c = tempAR.Recognize_Elements_of_the_Writing__c;
                            }
                            if(rep.Understand_Numbers__c == null && tempAR.Understand_Numbers__c != null) {
                                rep.Understand_Numbers__c = tempAR.Understand_Numbers__c;
                            }
                            if(rep.Understand_General_Subject_Matter_R__c == null && tempAR.Understand_General_Subject_Matter_R__c != null) {
                                rep.Understand_General_Subject_Matter_R__c = tempAR.Understand_General_Subject_Matter_R__c;
                            }
                            if(rep.Comprehend_Supported_Opinion_Reading__c== null && tempAR.Comprehend_Supported_Opinion_Reading__c != null) {
                                rep.Comprehend_Supported_Opinion_Reading__c = tempAR.Comprehend_Supported_Opinion_Reading__c;
                            }
                            if(rep.Comprehend_Hypothesis_or_Conjecture_R__c == null && tempAR.Comprehend_Hypothesis_or_Conjecture_R__c != null) {
                                rep.Comprehend_Hypothesis_or_Conjecture_R__c = tempAR.Comprehend_Hypothesis_or_Conjecture_R__c;
                            }
                            if(rep.Comprehend_Conjecture__c== null && tempAR.Comprehend_Conjecture__c != null) {
                                rep.Comprehend_Conjecture__c = tempAR.Comprehend_Conjecture__c;
                            } 
                            if(rep.Understand_some_Isolated_Words_Phrases__c == null && tempAR.Understand_some_Isolated_Words_Phrases__c != null) {
                                rep.Understand_some_Isolated_Words_Phrases__c = tempAR.Understand_some_Isolated_Words_Phrases__c;
                            }
                            if(rep.Understand_Simple_Statements_Questions_R__c== null && tempAR.Understand_Simple_Statements_Questions_R__c != null) {
                                rep.Understand_Simple_Statements_Questions_R__c = tempAR.Understand_Simple_Statements_Questions_R__c;
                            }
                            if(rep.Understand_Instructions_Written__c == null && tempAR.Understand_Instructions_Written__c != null) {
                                rep.Understand_Instructions_Written__c = tempAR.Understand_Instructions_Written__c;
                            }
                            if(rep.Understand_Narration_across_Timeframes_R__c == null && tempAR.Understand_Narration_across_Timeframes_R__c != null) {
                                rep.Understand_Narration_across_Timeframes_R__c = tempAR.Understand_Narration_across_Timeframes_R__c;
                            }
                            if(rep.Understand_Descriptions_Written__c == null && tempAR.Understand_Descriptions_Written__c != null) {
                                rep.Understand_Descriptions_Written__c = tempAR.Understand_Descriptions_Written__c;
                            }
                        }                       
                    }
                }
            }
        }
    }
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        // Addition to Observation Report changes 
        // To update the "Observation Completed This Year" field in Contact
        Date thisYR = Date.newInstance(System.Today().year(),1,1);
        System.debug('thisYR::::'+thisYR);
        List<Assessment_Report__c> obsAR = new List<Assessment_Report__c>();
        List<Assessment_Report__c> deaTestReports = new List<Assessment_Report__c>();
        
        Set<Id> insIds = new Set<Id>();
        List<Assessment_Report__c> completedReports = new List<Assessment_Report__c>();
        
        for(Assessment_Report__c ar: Trigger.new){
            
            // Added Annual Review fields condition on Feb 06 2024 - W-007981 : Changes to Observation Report and Annual Review Contact Checkbox
            // (For only "Observation Report") Update Contact's "Annual Review Completed This Year" to "True" if the "Annual Review Strengths" and "Annual Review Areas for Further Develop" fields are completed 
            if(((((ar.RecordTypeId == observationRecordTypeId && String.isNotBlank(ar.Annual_Review_Areas_for_Further_Develop__c) && String.isNotBlank(ar.Annual_Review_Strengths__c)) || 
                ar.RecordTypeId == dliObservationRecordTypeId) && ar.Date_Completed__c >= thisYR) || (ar.RecordTypeId == annualReviewRTId && ar.Report_Date__c >= thisYR)) && 
                ((Trigger.isUpdate && ar.Status__c != Trigger.oldMap.get(ar.Id).Status__c) || Trigger.isInsert) && ar.Status__c == 'Completed' && ar.Instructor__c != null) {
                
                completedReports.add(ar);
                insIds.add(ar.Instructor__c);
                
                // To Create Observation Report from the follow up Observation Date field
                if(ar.Follow_up_Observation__c != null) {
                    Assessment_Report__c obs = new Assessment_Report__c();
                    obs.Report_Date__c = ar.Follow_up_Observation__c;
                    obs.Status__c = 'Scheduled';
                    obs.Project__c = ar.Project__c;
                    obs.Student_Name_s__c = ar.Student_Name_s__c;
                    obs.Instructor__c = ar.Instructor__c ;
                    obs.RecordTypeId = ar.RecordTypeId;
                    obs.Project_Manager__c = ar.Project_Manager__c;
                    obs.Name = ar.Name.substringBeforeLast('-') + '-' + String.ValueOf(obs.Report_Date__c.month()) + '_' + String.ValueOf(obs.Report_Date__c.Year());
                    obsAR.add(obs);
                }
            }
            
            // Added on Mar 07 2023
            if(Trigger.isUpdate && ar.RecordTypeId == testRTId && ar.Account_Name__c != null && ar.Account_Name__c.contains('PGLS') && ar.Status__c == 'Scheduled' && ar.Status__c != Trigger.oldMap.get(ar.Id).Status__c && 
                ar.Tester__c != null && ar.Test_Report_Type__c == 'Progress'){
                deaTestReports.add(ar);
            }
        }
        
        if(!completedReports.isEmpty()){
            AssessmentReportTriggerHandler.updateObservationAndAnnualCompletedFlag(completedReports, insIds);
        }
        
        if(obsAR != null && obsAR.size() > 0) {
            System.debug('obsAR::'+obsAR);
            Insert obsAR;
        }
        
        if(deaTestReports.size() > 0){
            
            List<Assessment_Report__c> reports = [SELECT Id, Name, Project__c, Project__r.DLS_Ref__c, Project_Manager__r.Name, Instructor__c,
                                                    Student__r.Name, Report_Date__c, Report_Type__c, Evaluation_Period_From__c, 
                                                    Evaluation_Period_To__c, RecordType_Name__c, Test_Report_Type__c, Tester__c
                                                FROM Assessment_Report__c 
                                                WHERE Id IN : deaTestReports];
            System.debug(':::::reports:::'+reports);
            
            AssessmentReportEmailToInstructor.sendAnEmailToInstructor_Tester(reports, Date.Today());
        }
    }    
}