@isTest
private class UpdateGoalVSscoreField_Test{

    @testSetup static void setupMethod(){
    
        List<AcctSeed__Time_Card_Day__c>  tcd = TestClassUtil.createTestTimeCardDay();
        
        Test.startTest();
            List<Contact_Assignments__c> conAssigns  = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
        
        List<Schedule__c> scheduleRecs = TestClassUtil.createTestSchedule();
        
    }
    
    private static testMethod void myTest1(){
    
        Date reportDate = Date.Today()+7;
        
        //List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName ='Student'];
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
        
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();

        List<Contact> contacts = new list<Contact>{
            new Contact(LastName = 'Std Con 1', Email = 'stdcon1@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 2', Email = 'stdcon2@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 3', Email = 'stdcon3@gmail.com', RecordTypeId = stdRTId)
        };
        insert contacts;
        
        Assessment_Report__c ar1 = new Assessment_Report__c(Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Draft',Language__c = 'Tamil',Student__c = contacts[0].Id, Proficiency_Objective_Listening__c = '4', Proficiency_Objective_Reading__c = '2', Proficiency_Objective_Speaking__c = '3', Language_Proficiency_Score_Listening__c = '2', Language_Proficiency_Score_Reading__c = '0', Language_Proficiency_Score_Speaking__c = '0+');
        insert ar1;
                
        List<Assessment_Report__c> updatedAr1 = [SELECT Id, GoalVersusScore__c FROM Assessment_Report__c WHERE Id =:ar1.Id];
        //System.debug('::updatedAr1:'+updatedAr1[0].GoalVersusScore__c);
        //System.assertEquals('Not Met', updatedAr1[0].GoalVersusScore__c);
        
        Test.startTest();
        
            Assessment_Report__c ar2 = new Assessment_Report__c(Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Draft',Language__c = 'Tamil',Student__c = contacts[1].Id, Proficiency_Objective_Listening__c = '2', Proficiency_Objective_Reading__c = '4', Proficiency_Objective_Speaking__c = '1', Language_Proficiency_Score_Listening__c = '2', Language_Proficiency_Score_Reading__c = '0', Language_Proficiency_Score_Speaking__c = '0+');
            insert ar2;
                    
            Assessment_Report__c ar3 = new Assessment_Report__c(Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Draft',Language__c = 'Tamil',Student__c = contacts[2].Id, Proficiency_Objective_Listening__c = '0', Proficiency_Objective_Reading__c = '0', Proficiency_Objective_Speaking__c = '4', Language_Proficiency_Score_Listening__c = '2', Language_Proficiency_Score_Reading__c = '0', Language_Proficiency_Score_Speaking__c = '0+');
            insert ar3;
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
        Date reportDate = Date.Today()+7;
                        
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
        
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact> conList = new list<Contact>{
            new Contact(LastName = 'Std Con 4', Email = 'stdcon3@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 5', Email = 'stdcon4@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 6', Email = 'stdcon5@gmail.com', RecordTypeId = stdRTId)
        };
        insert conList;
        
        Assessment_Report__c ar1 = new Assessment_Report__c(Name = 'My Test Report1', Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id, Proficiency_Objective_Listening__c = '2', Proficiency_Objective_Reading__c = '2', Proficiency_Objective_Speaking__c = '2', Language_Proficiency_Score_Listening__c = '2', Language_Proficiency_Score_Reading__c = '2', Language_Proficiency_Score_Speaking__c = '2');
        insert ar1;
        
        Test.startTest();
        
            Assessment_Report__c ar2 = new Assessment_Report__c(Name = 'My Test Report2', Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id, Proficiency_Objective_Listening__c = '2', Proficiency_Objective_Reading__c = '2', Proficiency_Objective_Speaking__c = '2', Language_Proficiency_Score_Listening__c = '2', Language_Proficiency_Score_Reading__c = '2', Language_Proficiency_Score_Speaking__c = '2');
            insert ar2;
            
            List<Assessment_Report__c> updatedAr2 = [SELECT Id, GoalVersusScore__c FROM Assessment_Report__c WHERE Id =:ar2.Id];
            //System.debug('::updatedAr2:'+updatedAr2[0].GoalVersusScore__c);
            //System.assertEquals('Met', updatedAr2[0].GoalVersusScore__c);
            
            Assessment_Report__c ar3 = new Assessment_Report__c(Name = 'My Test Report3', Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id, Proficiency_Objective_Listening__c = '2', Proficiency_Objective_Reading__c = '2', Proficiency_Objective_Speaking__c = '2', Language_Proficiency_Score_Listening__c = '2', Language_Proficiency_Score_Reading__c = '2', Language_Proficiency_Score_Speaking__c = '2');
            insert ar3;
        Test.stopTest();
    }
    
    private static testMethod void myTest3(){
    
        Date reportDate = Date.Today()+7;
        
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact> conList = new list<Contact>{
            new Contact(LastName = 'Std Con 7', Email = 'stdcon7@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 8', Email = 'stdcon8@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 9', Email = 'stdcon9@gmail.com', RecordTypeId = stdRTId)
        };
        insert conList;
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
        
        Assessment_Report__c ar1 = new Assessment_Report__c(Name = 'My Test Report1', Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id, Language_Proficiency_Score_Listening__c = '2', Language_Proficiency_Score_Reading__c = '2', Language_Proficiency_Score_Speaking__c = '2');
        insert ar1;
        
        Test.startTest();
        
            Assessment_Report__c ar2 = new Assessment_Report__c(Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id, Language_Proficiency_Score_Listening__c = '2', Language_Proficiency_Score_Reading__c = '2', Language_Proficiency_Score_Speaking__c = '2');
            insert ar2;
            
            Assessment_Report__c ar3 = new Assessment_Report__c(Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id, Proficiency_Objective_Listening__c = '2', Proficiency_Objective_Reading__c = '2', Proficiency_Objective_Speaking__c = '2', Language_Proficiency_Score_Listening__c = '2', Language_Proficiency_Score_Reading__c = '2', Language_Proficiency_Score_Speaking__c = '2');
            insert ar3;
        Test.stopTest();
    }
    
    private static testMethod void myTest4(){
    
        Date reportDate = Date.Today()+7;
        
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact> conList = new list<Contact>{
            new Contact(LastName = 'Std Con 10', Email = 'stdcon10@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 11', Email = 'stdcon11@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 12', Email = 'stdcon12@gmail.com', RecordTypeId = stdRTId)
        };
        insert conList;
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
        
        Assessment_Report__c ar1 = new Assessment_Report__c(Name = 'My Test Report1', Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id, Proficiency_Objective_Listening__c = '0', Proficiency_Objective_Reading__c = '0', Proficiency_Objective_Speaking__c = '0', Language_Proficiency_Score_Listening__c = '2', Language_Proficiency_Score_Reading__c = '2', Language_Proficiency_Score_Speaking__c = '2');
        insert ar1;
        
        Test.startTest();
        
            Assessment_Report__c ar2 = new Assessment_Report__c(Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id, Proficiency_Objective_Listening__c = '0', Proficiency_Objective_Reading__c = '0', Proficiency_Objective_Speaking__c = '0', Language_Proficiency_Score_Listening__c = '2', Language_Proficiency_Score_Reading__c = '2', Language_Proficiency_Score_Speaking__c = '2');
            insert ar2;
            
            Assessment_Report__c ar3 = new Assessment_Report__c(Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id, Proficiency_Objective_Listening__c = '0', Proficiency_Objective_Reading__c = '0', Proficiency_Objective_Speaking__c = '0', Language_Proficiency_Score_Listening__c = '2', Language_Proficiency_Score_Reading__c = '2', Language_Proficiency_Score_Speaking__c = '2');
            insert ar3;
            
            List<Assessment_Report__c> updatedAr3 = [SELECT Id, GoalVersusScore__c FROM Assessment_Report__c WHERE Id =:ar3.Id];
            //System.debug('::updatedAr3:'+updatedAr3[0].GoalVersusScore__c);
            //System.assertEquals('Exceeded', updatedAr3[0].GoalVersusScore__c);
            
        Test.stopTest();
    }
    
    private static testMethod void myTest5(){
    
        Date reportDate = Date.Today()+7;
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName ='Student'];
        
        //List<Account> account = [SELECT Id, Name FROM Account LIMIT 1];
        Account ac = new Account();
        ac.Name = 'FCS';
        insert ac;
        
        List<Schedule__c> schedule = [SELECT Id,Total_Hours__c
        FROM Schedule__c 
        WHERE Project_Task__r.Project_Task_Type__c = 'Language Training'];
        schedule[0].Total_Hours__c = 0;
        update schedule[0];
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 2];
        projList[0].AcctSeed__Account__c = ac.Id;
        update projList[0];
        
        Test.startTest();
        
            List<Schedule__c> sche = [SELECT Id,Total_Hours__c, Status__c
            FROM Schedule__c 
            WHERE Id = :schedule[0].Id];
            sche[0].Total_Hours__c = 10;
            sche[0].Status__c= 'Active';
            update sche;
            
            List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
            List<Contact_Assignments__c> allCAs = [SELECT Id, Project__c, Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.Developername = 'Student'];
            
            for(Contact_Assignments__c ca : allCAs){
            
                ca.Project__c = projList[0].Id;
                updateCAs.add(ca);
            }
            if(updateCAs.size() > 0){
            
                update updateCAs;
            }
            Id ltReport = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Language_Training_Progress').getRecordTypeId();

            Assessment_Report__c ar = new Assessment_Report__c(RecordTypeId = ltReport, Name = 'My Test Report', Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Completed',Language__c = 'Tamil',Student__c = allCAs[0].Candidate_Name__c, 
            Motivation1__c = 'Meets Expectations', Attendance1__c = 'Meets Expectations', Preparation1__c = 'Meets Expectations', Pronunciation1__c = 'Meets Expectations', Fluency1__c = 'Meets Expectations',
            Grammar1__c = 'Meets Expectations', Vocabulary_Retention1__c = 'Meets Expectations', Syntax1__c = 'Meets Expectations', Reading_Comprehension1__c = 'Meets Expectations', Listening_Comprehension1__c = 'Meets Expectations');
            insert ar;
        
            List<Assessment_Report__c> arReports = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Project__c = :projList[0].Id];
            List<Assessment_Report__c> updateARRs = new List<Assessment_Report__c>();
            
            if(arReports != NULL && arReports.size() > 0){
            
                for(Assessment_Report__c a : arReports){
                
                    a.Status__c = 'Scheduled';
                    updateARRs.add(a);
                }
                
                if(updateARRs != NULL && updateARRs.size() > 0){
                
                    update updateARRs;
                    
                    List<Assessment_Report__c> updatedARRs = [SELECT Id, Syntax1__c, Listening_Comprehension1__c FROM Assessment_Report__c WHERE Id = :updateARRs];
                    System.assertEquals(ar.Syntax1__c, updatedARRs[0].Syntax1__c);
                    System.assertEquals(ar.Listening_Comprehension1__c, updatedARRs[0].Listening_Comprehension1__c);
                }
            }            
        Test.stopTest();
    }
    
    private static testMethod void myTest6(){
    
        Date reportDate = Date.Today()+7;
        List<Contact> conList = [SELECT Id, Name, RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName = 'Candidate' LIMIT 1];
        
        Date myStdDate = Date.Today().toStartOfMonth();
        
        //List<Account> account = [SELECT Id, Name FROM Account LIMIT 1];
        Account ac = new Account();
        ac.Name = 'DLI-W';
        insert ac;
        
        List<Schedule__c> schedule = [SELECT Id,Total_Hours__c
        FROM Schedule__c 
        WHERE Project_Task__r.Project_Task_Type__c = 'Language Training'];
        schedule[0].Total_Hours__c = 0;
        update schedule[0];
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c, Start_Date__c, End_Date__c FROM AcctSeed__Project__c LIMIT 2];
        projList[0].AcctSeed__Account__c = ac.Id;
        projList[0].Start_Date__c = myStdDate;
        projList[0].End_Date__c = Date.Today().addMonths(3);
        update projList[0];
        
        Test.startTest();
        
            List<Schedule__c> sche = [SELECT Id,Total_Hours__c, Status__c
            FROM Schedule__c 
            WHERE Id = :schedule[0].Id];
            sche[0].Total_Hours__c = 10;
            sche[0].Status__c= 'Active';
            update sche;
            
            List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
            List<Contact_Assignments__c> allCAs = [SELECT Id, Project__c, Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.Developername = 'Student'];
            List<Assessment_Report__c> ars = new List<Assessment_Report__c>();
            
            for(Contact_Assignments__c ca : allCAs){
            
                ca.Project__c = projList[0].Id;
                updateCAs.add(ca);
            }
            if(updateCAs.size() > 0){
            
                update updateCAs;
            }
            
            Id dliReport = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Progress').getRecordTypeId();
            Id obsReport = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Observation_Report').getRecordTypeId();


            Assessment_Report__c ar1 = new Assessment_Report__c(RecordTypeId = dliReport, Name = 'My Test Report 1', Report_Date__c = reportDate, Project__c=projList[0].Id, Status__c = 'Completed',Language__c = 'Tamil',Student__c = allCAs[0].Candidate_Name__c, 
            Pronunciation1__c = 'Satisfactory/On Track', Fluency1__c = 'Satisfactory/On Track', Grammar1__c = 'Satisfactory/On Track', Vocabulary_Retention1__c = 'Satisfactory/On Track', Listening_Main_Idea1__c = 'Satisfactory/On Track', 
            Listening_Details1__c = 'Satisfactory/On Track', Reading_Main_Idea1__c = 'Satisfactory/On Track', Reading_Details1__c = 'Satisfactory/On Track', Preparation_for_Class1__c = 'Satisfactory/On Track', 
            Attitude_and_Motivation1__c = 'Satisfactory/On Track', Speaking_ILR_Rating__c = 'Meet goals', Listening_ILR_Rating__c = 'Meet goals', Reading_ILR_Rating__c = 'Meet goals', Simple_short_conversations__c = 'Marginal - High', 
            Ask_simple_questions__c = 'Marginal - Mid', Cope_with_basic_survival_situation__c = 'Marginal - Mid', Narrate_in_the_future__c = 'Marginal - High', Narrate_in_the_past__c = 'Marginal - Mid ', Narrate_in_the_present__c = 'Marginal - High', 
            Do_physical_descriptions__c = 'Marginal - Mid', Give_instructions_or_directions__c = 'Marginal - Mid', Report_facts_about_current_events__c = 'Can Do', Cope_with_survival_situation_with_a_comp__c = 'Can Do', 
            Support_opinion__c = 'Can Do', Hypothesize__c = 'Can Do', Discuss_an_abstract_topic__c = 'Can Do', Cope_with_an_unfamiliar_situation__c = 'Can Do', Understand_speech_about_basic_survival_n__c = 'Can Do', 
            Understand_simple_questions__c = 'Can Do', Listening_Understand_Main_Ideas__c = 'Marginal - High', Able_to_follow_instructions__c = 'Can Do', Understand_speech_on_concrete_topics__c = 'Can Do', Understand_supported_opinion__c = 'Marginal - High', 
            Understand_hypothesizing__c = 'Marginal - High', Understand_abstract_topics__c = 'Can Do', Read_short_simple_text_with_limited_acc__c = 'N/A*', Reading_Understand_Main_Ideas__c = 'Can Do', Able_to_read_simple_authentic_material__c = 'Marginal - Mid', 
            Understand_main_ideas_details__c = 'Marginal - High', Authentic_materials_on_unfamiliar_topics__c = 'Marginal - High', Comprehend_supported_opinion__c = 'Marginal - High');
            ars.add(ar1);
            
            Assessment_Report__c ar2 = new Assessment_Report__c();
            ar2.Name = 'My Test Report 2';
            ar2.Report_Date__c = reportDate.addDays(30);
            ar2.Status__c = 'Draft';
            ar2.Project__c=projList[0].Id;
            ar2.Student__c = allCAs[0].Candidate_Name__c;
            
            ars.add(ar2);
            
            Assessment_Report__c ar3 = new Assessment_Report__c();
            ar3.Name = 'My Test Report 2';
            ar3.Report_Date__c = reportDate.addDays(30);
            ar3.Status__c = 'Completed';
            ar3.Date_Completed__c = reportDate.addDays(32);
            ar3.Project__c=projList[0].Id;
            if(conList != null && conList.size() >0) {
                ar3.Instructor__c = conList[0].Id;
            }
            ar3.RecordTypeId = obsReport;
            ars.add(ar3);
            
            insert ars;
        
            List<Assessment_Report__c> arReports = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Project__c = :projList[0].Id AND Status__c != 'Completed'];
            List<Assessment_Report__c> updateARRs = new List<Assessment_Report__c>();
            System.debug('arReports:::::'+arReports.size());
            
            if(arReports != NULL && arReports.size() > 0){
            
                for(Assessment_Report__c a : arReports){
                
                    a.Status__c = 'Scheduled';
                    a.RecordTypeId = dliReport;
                    updateARRs.add(a);
                }
                
                if(updateARRs != NULL && updateARRs.size() > 0){
                
                    update updateARRs;
                }
                
                List<Assessment_Report__c> updatedARRs = [SELECT Id, Pronunciation1__c, Understand_main_ideas_details__c FROM Assessment_Report__c WHERE Id = :updateARRs];
                System.assertEquals(ars[0].Pronunciation1__c, updatedARRs[0].Pronunciation1__c);
                System.assertEquals(ars[0].Understand_main_ideas_details__c, updatedARRs[0].Understand_main_ideas_details__c);
            }            
        Test.stopTest();
    }
    
    private static testMethod void myTest7(){
    
        Date reportDate = Date.Today()+7;
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName ='Student'];
                
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        
        Test.startTest();
        
            List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
            List<Contact_Assignments__c> allCAs = [SELECT Id, Project__c, Candidate_Name__c, L_Score_Final__c, R_Score_Final__c, S_Score_Final__c FROM Contact_Assignments__c WHERE RecordType.Developername = 'Student'];
            
            for(Contact_Assignments__c ca : allCAs){
            
                ca.Project__c = projList[0].Id;
                ca.L_Score_Final__c = '2';
                ca.R_Score_Final__c = '3';
                ca.S_Score_Final__c = '4';
                updateCAs.add(ca);
            }
            if(updateCAs.size() > 0){
            
                update updateCAs;
            }
            
            Assessment_Report__c ar = new Assessment_Report__c(Name = 'My Test Report', Report_Date__c = reportDate, Project__c=projList[0].Id, 
                Status__c = 'Draft',Language__c = 'Tamil',Student__c = allCAs[0].Candidate_Name__c);
            insert ar;
        
            List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang1', Project__c = projList[0].Id, Testee__c = allCAs[0].Candidate_Name__c, Test_Type__c = 'Initial', 
                L_Score__c = '1+', R_Score__c = '2+', S_Score__c='3+')
            };
            insert langtestList1;
        
            List<Assessment_Report__c> arReports = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Id = :ar.Id];
            List<Assessment_Report__c> updateARRs = new List<Assessment_Report__c>();
            
            if(arReports != NULL && arReports.size() > 0){
            
                for(Assessment_Report__c a : arReports){
                
                    a.Status__c = 'Scheduled';
                    updateARRs.add(a);
                }
                
                if(updateARRs != NULL && updateARRs.size() > 0){
                
                    update updateARRs;
                    
                    List<Assessment_Report__c> updatedARRs = [SELECT Id, Initial_Proficiency_Listening__c, Proficiency_Objective_Reading__c FROM Assessment_Report__c WHERE Id = :updateARRs];
                    System.assertEquals(updatedARRs[0].Initial_Proficiency_Listening__c, langtestList1[0].L_Score__c);
                    System.assertEquals(updatedARRs[0].Proficiency_Objective_Reading__c, updateCAs[0].R_Score_Final__c);
                }
            }            
        Test.stopTest();
    }
    
    @isTest
    public static void updateGoalVSscoreField_Test_Observation_Report(){
        
        List<Contact_Assignments__c> allCAs = [SELECT Id, Project__c, Candidate_Name__c, L_Score_Final__c, R_Score_Final__c, S_Score_Final__c FROM Contact_Assignments__c WHERE RecordType.Developername = 'Student'];
                
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        
        Date oldReportDate = System.today();
        Date newReportDate = System.today().addDays(7);
        
        for(Contact_Assignments__c ca : allCAs){
            
            ca.Project__c = projList[0].Id;
            ca.L_Score_Final__c = '2';
            ca.R_Score_Final__c = '3';
            ca.S_Score_Final__c = '4';
        }
        update allCAs;
        
        Id observationRecordTypeId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Observation_Report').getRecordTypeId();
        
        Assessment_Report__c ar = new Assessment_Report__c(Name = 'My Test Report - AJ Test Report', Report_Date__c = oldReportDate, Project__c=projList[0].Id, 
                Status__c = 'Draft',Language__c = 'Tamil',Instructor__c = allCAs[0].Candidate_Name__c  , RecordTypeId = observationRecordTypeId);
            insert ar;
        
            List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang1', Project__c = projList[0].Id, Testee__c = allCAs[0].Candidate_Name__c, Test_Type__c = 'Initial', 
                L_Score__c = '1+', R_Score__c = '2+', S_Score__c='3+')
            };
            insert langtestList1;
        
            List<Assessment_Report__c> arReports = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Id = :ar.Id];
        
            for(Assessment_Report__c a : arReports){
                
                a.Status__c = 'Scheduled';
                a.Report_Date__c = newReportDate;
                a.Student_Comments_Conga__c = 'Performance Is Average';
            }
        Test.startTest();
        update arReports;
        Test.stopTest();
        
        List<Assessment_Report__c> updatedARRs = [SELECT Id, Student_Comments_Conga__c FROM Assessment_Report__c WHERE Id = :arReports];
        System.assertEquals(updatedARRs[0].Student_Comments_Conga__c, 'Performance Is Average');
    }
    
    @isTest
    public static void updateGoalVSscoreField_Test_lTReport(){
        
        List<Contact_Assignments__c> allCAs = [SELECT Id, Project__c, Candidate_Name__c, L_Score_Final__c, R_Score_Final__c, S_Score_Final__c FROM Contact_Assignments__c WHERE RecordType.Developername = 'Student'];
                
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        
        Date oldReportDate = System.today();
        Date newReportDate = System.today().addDays(7);
        
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact> conList = new list<Contact>{
            new Contact(LastName = 'Std Con 13', Email = 'stdcon13@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 14', Email = 'stdcon14@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 15', Email = 'stdcon15@gmail.com', RecordTypeId = stdRTId)
        };
        insert conList;
        
        Integer i = 0;
        
        Test.startTest();
        
            for(Contact_Assignments__c ca : allCAs){
                
                ca.Project__c = projList[0].Id;
                ca.L_Score_Final__c = '2';
                ca.R_Score_Final__c = '3';
                ca.S_Score_Final__c = '4';
                
                if(i <= conList.size()){
                    ca.Candidate_Name__c = conList[i].Id;
                    i++;
                }
            }
            update allCAs;
        
            Id lTReport = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Language_Training_Progress').getRecordTypeId();
            
            Assessment_Report__c ar = new Assessment_Report__c(Name = 'My Test Report - AJ Test Report', Report_Date__c = oldReportDate, Project__c=projList[0].Id, 
                    Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id, RecordTypeId = lTReport, Language_Training_Status__c = 'Progress');
            insert ar;
            
            Assessment_Report__c ar1 = new Assessment_Report__c(Report_Date__c = oldReportDate, Project__c=projList[0].Id, 
                    Status__c = 'Completed',Language__c = 'Tamil',Student__c = conList[0].Id  , RecordTypeId = lTReport , 
                    Motivation1__c = 'Meets Expectations' , Attendance1__c = 'Meets Expectations' , Preparation1__c = 'Meets Expectations' , Pronunciation1__c = 'Meets Expectations',
                    Fluency1__c = 'Meets Expectations' , Grammar1__c = 'Meets Expectations' , Vocabulary_Retention1__c = 'Meets Expectations' , Reading_Comprehension1__c = 'Meets Expectations' , 
                    Listening_Comprehension1__c = 'Meets Expectations', Language_Training_Status__c = 'Final');
            
            insert ar1;
        
            List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang1', Project__c = projList[0].Id, Testee__c = conList[0].Id, Test_Type__c = 'Initial', 
                L_Score__c = '1+', R_Score__c = '2+', S_Score__c='3+')
            };
            insert langtestList1;
        
            List<Assessment_Report__c> arReports = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Id = :ar.Id];
        
            for(Assessment_Report__c a : arReports){
                
                a.Status__c = 'Scheduled';
                a.Report_Date__c = newReportDate;
                a.Student_Comments_Conga__c = 'Performance Is Average';
                a.Language_Training_Status__c = 'Monthly';
            }
        
        update arReports;
        
        
        List<Assessment_Report__c> updatedARRs = [SELECT Id, Attendance1__c FROM Assessment_Report__c WHERE Id = :arReports];
        System.assertEquals(updatedARRs[0].Attendance1__c, ar1.Attendance1__c);
        
        Test.stopTest();
    }
    @isTest
    public static void updateGoalVSscoreField_Test_dli22Report(){
        
        List<Contact_Assignments__c> allCAs = [SELECT Id, Project__c, Candidate_Name__c, L_Score_Final__c, R_Score_Final__c, S_Score_Final__c FROM Contact_Assignments__c WHERE RecordType.Developername = 'Student'];
                
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        
        Date oldReportDate = System.today();
        Date newReportDate = System.today().addDays(7);
        
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact> conList = new list<Contact>{
            new Contact(LastName = 'Std Con 13', Email = 'stdcon13@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 14', Email = 'stdcon14@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 15', Email = 'stdcon15@gmail.com', RecordTypeId = stdRTId)
        };
        insert conList;
        
        Test.startTest();
        
            Integer i = 0;
            for(Contact_Assignments__c ca : allCAs){
                
                ca.Project__c = projList[0].Id;
                ca.L_Score_Final__c = '2';
                ca.R_Score_Final__c = '3';
                ca.S_Score_Final__c = '4';
                if(i <= conList.size()){
                    ca.Candidate_Name__c = conList[i].Id;
                    i++;
                }
            }
            update allCAs;
            
            Id dli22Report = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Progress_2022').getRecordTypeId();
        
            Assessment_Report__c ar = new Assessment_Report__c(Name = 'My Test Report - AJ Test Report', Report_Date__c = oldReportDate, Project__c=projList[0].Id, 
                Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id  , RecordTypeId = dli22Report);
            insert ar;
            
            Assessment_Report__c ar1 = new Assessment_Report__c(Report_Date__c = oldReportDate.addDays(45), Project__c=projList[0].Id, 
                    Status__c = 'Completed',Language__c = 'Tamil',Student__c = conList[0].Id, RecordTypeId = dli22Report ,
                    Assignments_includes_homework__c = 'Meets Expectations' , Attitude_and_Engagement__c = 'Meets Expectations' , Class_Participation__c = 'Meets Expectations' , Speaking_ILR_Rating__c = 'Meet goals' , Listening_ILR_Rating__c = 'Meet goals',
                    Reading_ILR_Rating__c = 'Meet goals');
            
            insert ar1;
        
            List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang1', Project__c = projList[0].Id, Testee__c = allCAs[0].Candidate_Name__c, Test_Type__c = 'Initial', 
                L_Score__c = '1+', R_Score__c = '2+', S_Score__c='3+')
            };
            insert langtestList1;
        
            List<Assessment_Report__c> arReports = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Id = :ar.Id];
        
            for(Assessment_Report__c a : arReports){
                
                a.Status__c = 'Scheduled';
                a.Report_Date__c = newReportDate;
                a.Student_Comments_Conga__c = 'Performance Is Average';
            }
        
            update arReports;
        
            List<Assessment_Report__c> updatedARRs = [SELECT Id, Class_Participation__c FROM Assessment_Report__c WHERE Id = :arReports];
            System.assertEquals(updatedARRs[0].Class_Participation__c, ar1.Class_Participation__c);
        Test.stopTest();
    }
    @isTest
    public static void updateGoalVSscoreField_Test_dliTest(){
        
        List<Contact_Assignments__c> allCAs = [SELECT Id, Project__c, Candidate_Name__c, L_Score_Final__c, R_Score_Final__c, S_Score_Final__c FROM Contact_Assignments__c WHERE RecordType.Developername = 'Student'];
                
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        
        Date oldReportDate = System.today();
        Date newReportDate = System.today().addDays(7);
        
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact> conList = new list<Contact>{
            new Contact(LastName = 'Std Con 13', Email = 'stdcon13@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 14', Email = 'stdcon14@gmail.com', RecordTypeId = stdRTId),
            new Contact(LastName = 'Std Con 15', Email = 'stdcon15@gmail.com', RecordTypeId = stdRTId)
        };
        insert conList;
        
        Test.startTest();
        
            Integer i = 0;
            
            for(Contact_Assignments__c ca : allCAs){
                
                ca.Project__c = projList[0].Id;
                ca.L_Score_Final__c = '2';
                ca.R_Score_Final__c = '3';
                ca.S_Score_Final__c = '4';
                
                if(i <= conList.size()){
                    ca.Candidate_Name__c = conList[i].Id;
                    i++;
                }
            }
            update allCAs;
            
                Id dliSelfTest = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Self_Assessment_Test_Report').getRecordTypeId();
            
            Assessment_Report__c ar = new Assessment_Report__c(Name = 'My Test Report - AJ Test Report', Report_Date__c = oldReportDate, Project__c=projList[0].Id, 
                    Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id  , RecordTypeId = dliSelfTest);
                insert ar;
            
            Assessment_Report__c ar1 = new Assessment_Report__c(Report_Date__c = oldReportDate.addDays(30), Project__c=projList[0].Id, 
                    Status__c = 'Completed',Language__c = 'Tamil',Student__c = conList[0].Id  , RecordTypeId = dliSelfTest,
                    Memorized_Formulaic_Words_Phrases__c = 'Can Do Some of the Time' , Using_Memorized_Formulaic_Phrases__c = 'Can Do Some of the Time' , Greet_and_Introduce_Myself__c = 'Can Do Some of the Time' , Provide_Minimal_Biographical_Info__c = 'Can Do Some of the Time' , Simple_Exchanges_about_Work_Experience__c = 'Can Do Some of the Time' , Simple_Exchanges_about_Travel__c = 'Cannot Do' , Simple_Exchanges_Educational_Experience__c = 'Can Do Some of the Time' , Make_Simple_Recommendations__c = 'Can Do Some of the Time' , Ask_simple_questions__c = 'Cannot Do' , Cope_with_basic_survival_situation__c = 'Can Do Some of the Time' , Narrate_in_the_present__c = 'Can Do Some of the Time' , Narrate_in_the_past__c = 'Cannot Do' , 
                    Narrate_in_the_future__c = 'Can Do Some of the Time' ,Do_physical_descriptions__c = 'Can Do Some of the Time' ,Give_Instructions__c = 'Cannot Do' , Give_Geographical_Directions__c = 'Can Do Some of the Time' , Report_facts_about_current_events__c = 'Cannot Do' , Cope_with_survival_situation_with_a_comp__c = 'Cannot Do' , Discuss_a_Hypothetical_Situation__c = 'Can Do Some of the Time' , Present_on_a_Topic__c = 'Can Do Some of the Time' , Discuss_and_Compare_Societal_Issues__c = 'Can Do Some of the Time' , State_and_Defend_a_Position_or_Policy__c = 'Can Do Some of the Time' , Recognize_Common_Greetings_and_Intro__c = 'Can Do Some of the Time' , Understand_Minimal_Exchanges__c = 'Cannot Do' , Understand_Simple_Statements_Questions_L__c = 'Can Do Some of the Time' , 
                    Understand_General_Subject_Matter_L__c = 'Can Do Some of the Time' , Understand_main_ideas_details__c = 'Cannot Do' , Understand_Narration_across_Timeframes_L__c = 'Can Do Some of the Time' , Understand_Straightforward_Descriptions__c = 'Can Do Some of the Time' , Comprehend_Supported_Opinion_Listening__c = 'Cannot Do' , Comprehend_Hypothesis_or_Conjecture_L__c = 'Can Do Most of the Time' , Draw_Inferences__c = 'Can Do Some of the Time' , Understand_Commonly_used_Rhetorical__c = 'Can Do Some of the Time' ,Recognize_Elements_of_the_Writing__c = 'Can Do Some of the Time' , Understand_Numbers__c = 'Can Do Some of the Time' , Understand_General_Subject_Matter_R__c = 'Cannot Do' , Comprehend_Supported_Opinion_Reading__c = 'Cannot Do' ,Comprehend_Hypothesis_or_Conjecture_R__c = 'Can Do Some of the Time' , 
                    Comprehend_Conjecture__c = 'Can Do Some of the Time' , Understand_some_Isolated_Words_Phrases__c = 'Can Do Some of the Time' , Understand_Simple_Statements_Questions_R__c = 'Can Do Some of the Time' , Understand_Instructions_Written__c = 'Can Do Some of the Time' , Understand_Narration_across_Timeframes_R__c = 'Can Do Some of the Time' , Understand_Descriptions_Written__c = 'Can Do Some of the Time' );
        
            insert ar1;
                
            List<Language_Testing__c> langtestList1 = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang1', Project__c = projList[0].Id, Testee__c = conList[0].Id, Test_Type__c = 'Initial', 
                L_Score__c = '1+', R_Score__c = '2+', S_Score__c='3+')
            };
            insert langtestList1;
        
            List<Assessment_Report__c> arReports = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Id = :ar.Id];
        
            for(Assessment_Report__c a : arReports){
                
                a.Status__c = 'Scheduled';
                a.Report_Date__c = newReportDate;
                a.Student_Comments_Conga__c = 'Performance Is Average';
            }
        
        update arReports;
        
        List<Assessment_Report__c> updatedARRs = [SELECT Id, Greet_and_Introduce_Myself__c FROM Assessment_Report__c WHERE Id = :arReports];
        System.assertEquals(updatedARRs[0].Greet_and_Introduce_Myself__c, ar1.Greet_and_Introduce_Myself__c);
        
        Test.stopTest();
    }
    
    private static testMethod void myTest8(){
    
        Account a = new Account(Name = 'PGLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id lTPTRTId = Schema.SObjectType.AcctSeed__Project_Task__c .getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,03);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        List<Language__c> languages = [SELECT Id, Name FROM Language__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Language__c = languages[0].Id, AcctSeed__Account__c = a.Id, Name = 'Test PGLS Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(RecordTypeId = lTPTRTId, Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 400, Total_Hours_Used_For_Language_Training__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
            };
                
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];
            
            AcctSeed__Project_Task__c pt = new AcctSeed__Project_Task__c();
            pt.Id = projTask.Id;
            pt.Total_Hours_Used_For_Language_Training__c = 400;
            update pt;
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id AND Test_Report_Type__c = 'Progress' AND RecordType.DeveloperName = 'Test_Report'];
            arRecSize[0].Status__c = 'Scheduled';
            update arRecSize[0];
                        
        Test.stopTest();
    }
     // Temporarily commented
    /*
    private static testMethod void myTest9(){
        
        List<AcctSeed__Time_Card_Day__c>  tcd = [SELECT Id, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c WHERE AcctSeed__Time_Card_Line__c != null];
        AcctSeed__Time_Card_Line__c tcl = [SELECT Id,AcctSeed__Project__c,AcctSeed__Time_Card__r.Intructor__c 
                                                FROM AcctSeed__Time_Card_Line__c                  
                                                WHERE Id = :tcd[0].AcctSeed__Time_Card_Line__c LIMIT 1];
                                                
        Contact con = [SELECT Id, Supervisor_Name__c, Hours_in_Current_Year__c FROM Contact WHERE Id = :tcl.AcctSeed__Time_Card__r.Intructor__c LIMIT 1];
        con.DLI_Hours_in_Current_Year__c = 60;
        update con;
        
        List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Instructor__c = :con.Id AND RecordType.DeveloperName = 'Annual_Instructor_Performance_Review'];
        System.assertEquals(1, arRecSize.size());
        
        Test.startTest();
        
        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Id = arRecSize[0].Id, Contributes_in_Helping_Other__c='Meets', 
             Willing_to_Share_Resources__c = 'Meets',
             Participates_in_Extracurricular_Events__c = 'Meets',
             Adheres_to_DLS_Code_of_Conduct__c = 'Meets',
             Communicates_Clearly_and_Openly__c = 'Meets',
             Works_Collaboratively__c = 'Meets',
             Exemplifies_Professional_Behavior__c = 'Meets',
             Understands_and_Adapts_Behaviors__c = 'Meets',
             Submits_Thoughtfully_Completed__c = 'Meets',
             Uses_Correct_Methods_to_Request_Time__c = 'Meets',
             Brings_Potential_Problems__c = 'Meets',
             Offers_Ideas_and_Suggestions_to_Improve__c = 'Meets',
             Has_Good_Rapport__c = 'Meets',
             Helps_LTS_Prepare_Programs__c='Meets',
             Participates_in_Teacher_Training__c='Meets',
             Utilizes_Technology_Appropriately__c='Meets',
             Performs_Uses_Assessment__c='Meets',
             Receives_Consistently_Positive_Feedback__c='Meets',
             Understands_ILR_Levels__c='Meets',
             Prepares_and_Uses_Student_Centered_Act__c='Meets',
             Shows_Ability_to_Work_Beyond__c='Meets',
             Prepares_for_Each_Class_and_Assigns__c='Meets',
             Classes_Conducted_Primarily_in_Target__c='Meets',
             Has_Good_Rapport_Comments__c = 'Test',Report_Type__c = 'DLI',Status__c = 'Completed',Language__c = 'Tamil')
        };
        update assReport;
        
        List<Contact> conRec = [SELECT Id, Name, Annual_Review_Completed_This_Year__c FROM Contact WHERE Id = :con.Id];
        System.assertEquals(true, conRec[0].Annual_Review_Completed_This_Year__c);
        
        Test.stopTest();
    }
    */
    
    // To cover Follow_up_Observation__c action
    // To check Observation_Completed_This_Year__c checkbox field
    private static testMethod void myTest10(){
                                  
        Account a = new Account(Name = 'Test Account - Observation');
        insert a;
        
        Contact con = [SELECT Id, Supervisor_Name__c, Hours_in_Current_Year__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate' AND Name LIKE '%Test%' LIMIT 1];
        
        List<AcctSeed__Project__c> proj = [SELECT Id, Start_Date__c, End_Date__c FROM AcctSeed__Project__c LIMIT 1];
        proj[0].AcctSeed__Account__c = a.Id;
        update proj[0];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
        Test.startTest();
        
            Contact_Assignments__c insCA = new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj[0].Id, Candidate_Name__c = con.Id, Start_Date__c = proj[0].Start_Date__c, End_Date__c = proj[0].End_Date__c, Status__c = 'Active', Assignment_Position__c = 'Instructor', Schedule_Observation__c = 'Yes');
            insert insCA;
                
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj[0].Id AND RecordType.DeveloperName = 'Observation_Report'];
            System.assertEquals(1, arRecSize.size());
            
            arRecSize[0].Status__c = 'Completed';
            arRecSize[0].Date_Completed__c = Date.Today().addDays(1);
            arRecSize[0].Follow_up_Observation__c = Date.Today().addDays(50);
            update arRecSize[0];
        
            List<Contact> conRec = [SELECT Id, Name, Observation_Completed_This_Year__c FROM Contact WHERE Id = :con.Id];
            System.assertEquals(true, conRec[0].Observation_Completed_This_Year__c);
            
        Test.stopTest();
    }
}