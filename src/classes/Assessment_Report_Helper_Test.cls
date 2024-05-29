@isTest
private class Assessment_Report_Helper_Test{

    @testSetup static void setupMethod(){
    
        List<Assessment_Report__c> assessmentReports = TestClassUtil.createTestAssessmentReport();
        List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();        
        
        Test.startTest();
            List<AcctSeed__Time_Card_Day__c>  tcd = TestClassUtil.createTestTimeCardDay();
            List<Events__c> events = TestClassUtil.createTestEvent();
            List<APXTConga4__Conga_Template__c> congaTemp = TestClassUtil.createCongaTemplate();  
            List<MTT_Location__c> locations = TestClassUtil.createTestLocations();          
        Test.stopTest();
    }
    
    private static testMethod void myTest1(){
    
        Account a = new Account(Name = 'PVT');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = stdCon[0].Id;
        update conAss[0];
        
        Test.startTest();
        
            List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            projRecs[0].AcctSeed__Account__c = a.Id;
            update projRecs[0];
            
            List<AcctSeed__Project_Task__c> projTask = [SELECT Id,Name,Total_Qty_Planned__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projRecs[0].Id];
            projTask[0].Total_Qty_Planned__c = 150;
            projTask[0].Project_Task_Type__c = 'Language Training';
            update projTask[0];
            
            Map<String, String> reportVal = new Map<String, String>();
        
            Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'PVTButton', reportVal, new Map<Id,Assessment_Report__c>());
        Test.stopTest();

    }
    
    private static testMethod void myTest1a(){
    
        Account a = new Account(Name = 'PVT');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = stdCon[0].Id;
        update conAss[0];
        
        Test.startTest();
        
            List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            projRecs[0].AcctSeed__Account__c = a.Id;
            update projRecs[0];
        
            List<AcctSeed__Project_Task__c> projTask = [SELECT Id,Name,Total_Qty_Planned__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projRecs[0].Id];
            projTask[0].Total_Qty_Planned__c = 150;
            projTask[0].Project_Task_Type__c = 'Language Training';
            update projTask[0];
                    
            Map<String, String> reportVal = new Map<String, String>();
            reportVal.put('Language_Training_Status__c', 'Progress');
            //reportVal.put('Report_Date__c', String.valueOf(Date.Today()));

            Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'PVTButton', reportVal, new Map<Id,Assessment_Report__c>());
            Assessment_Report_Helper.getPRTestReportTypes(projRecs[0].Id);
        Test.stopTest();
    }
    
    private static testMethod void myTest1b(){
    
        Account a = new Account(Name = 'PVT');
        insert a;
        
        Id stdCAProjId;
        List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
        Map<Id, Contact> updateConMap = new Map<Id, Contact>();
        
        for(Contact_Assignments__c c : [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c, RecordType.DeveloperName
            FROM Contact_Assignments__c 
            WHERE RecordType.DeveloperName IN ('Student', 'Staff', 'Client_Partner') AND Status__c = 'Active']){
        
            if(c.RecordType.DeveloperName == 'Student'){
            
                stdCAProjId = c.Project__c;
            }
            if(c.RecordType.DeveloperName == 'Staff'){
            
                c.Assignment_Position__c = 'Project Support';
                updateCAs.add(c);
                
                Contact con = new Contact();
                con.Id = c.Candidate_Name__c;
                con.DLS_User__c = UserInfo.getUserId();
                if(!updateConMap.containsKey(con.Id)){
                    updateConMap.put(con.Id, con);
                }
            }
            if(c.RecordType.DeveloperName == 'Client_Partner'){
                
                c.Assignment_Position__c = 'Training Officer';
                updateCAs.add(c);
            }
        }
        
        if(updateCAs != NULL && updateCAs.size() > 0){
            update updateCAs;
        }
        if(updateConMap != NULL && updateConMap.size() > 0){
            update updateConMap.values();
        }
        
        Test.startTest();
            List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :stdCAProjId];
            projRecs[0].AcctSeed__Account__c = a.Id;
            update projRecs[0];
            
            List<AcctSeed__Project_Task__c> projTask = [SELECT Id,Name,Total_Qty_Planned__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projRecs[0].Id];
            projTask[0].Total_Qty_Planned__c = 150;
            projTask[0].Project_Task_Type__c = 'Language Training';
            update projTask[0];
                    
            Map<String, String> reportVal = new Map<String, String>();
            reportVal.put('Language_Training_Status__c', 'Progress');
            
            List<Assessment_Report__c> arRec = [SELECT Id, Project__c, Evaluation_Period_To__c FROM Assessment_Report__c WHERE Project__c =:projRecs[0].Id];
            Map<Id,Assessment_Report__c> projARMap = new Map<Id,Assessment_Report__c>();
            projARMap.put(projRecs[0].Id, arRec[0]);
        
            Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'ProjectTask', reportVal, projARMap);
        Test.stopTest();

    }
    
    private static testMethod void myTest1c(){
    
        Account a = new Account(Name = 'PVT');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = stdCon[0].Id;
        update conAss[0];
        
        Test.startTest();
            
            List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            projRecs[0].AcctSeed__Account__c = a.Id;
            update projRecs[0];
            
            List<AcctSeed__Project_Task__c> projTask = [SELECT Id,Name,Total_Qty_Planned__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projRecs[0].Id];
            projTask[0].Total_Qty_Planned__c = 150;
            projTask[0].Project_Task_Type__c = 'Language Training';
            update projTask[0];
                    
            Map<String, String> reportVal = new Map<String, String>();
            reportVal.put('Language_Training_Status__c', 'Progress');
        
            Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'ProjectTask', reportVal, new Map<Id,Assessment_Report__c>());
        Test.stopTest();
    }    
    
    private static testMethod void myTest1d(){
    
        Account a = new Account(Name = 'PVT');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = stdCon[0].Id;
        update conAss[0];
        
        Test.startTest();
        
            List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            projRecs[0].AcctSeed__Account__c = a.Id;
            update projRecs[0];
                
            List<AcctSeed__Project_Task__c> projTask = [SELECT Id,Name,Total_Qty_Planned__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projRecs[0].Id];
            projTask[0].Total_Qty_Planned__c = 150;
            projTask[0].Project_Task_Type__c = 'Language Training';
            update projTask[0];
            
            String dateStr = Date.today().format();
            
            Map<String, String> reportVal = new Map<String, String>();
            reportVal.put('Report_Date__c', dateStr);
        
            Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'PVTButton', reportVal, new Map<Id,Assessment_Report__c>());
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
        Account a = new Account(Name = 'FAS');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = stdCon[0].Id;
        update conAss[0];
        
        Test.startTest();
        
            List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            projRecs[0].AcctSeed__Account__c = a.Id;
            update projRecs[0];
            
            List<AcctSeed__Project_Task__c> projTask = [SELECT Id,Name,Total_Qty_Planned__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projRecs[0].Id];
            projTask[0].Total_Qty_Planned__c = 150;
            projTask[0].Project_Task_Type__c = 'Language Training';
            update projTask[0];
        
            Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'PVTButton', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
        Test.stopTest();
    }
    
    private static testMethod void myTest3(){
    
        Account a = new Account(Name = 'DODA');
        insert a;
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
    
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(Name = 'SLP PI', Total_LT_Class_Hours__c = 85, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), Project_Type__c = 'SLP-PT')
        };
        insert proItrList;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = stdCon[0].Id;
            update conAss[0];
            
            List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            projRecs[0].AcctSeed__Account__c = a.Id;
            projRecs[0].Project_Type__c = 'SLP-PT';
            projRecs[0].Program_Iteration__c = proItrList[0].Id;
            projRecs[0].RecordTypeId = dodaRTId;
            update projRecs[0];
        
            Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'PVTButton', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
            Assessment_Report_Helper.getPRTestReportTypes(projRecs[0].Id);
        Test.stopTest();

    }
    
    private static testMethod void myTest4(){
    
        Account a = new Account(Name = 'DODA');
        insert a;
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
    
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(Name = 'SLP PI', Total_LT_Class_Hours__c = 85, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), Project_Type__c = 'JMAS')
        };
        insert proItrList;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = stdCon[0].Id;
            update conAss[0];
            
            List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            projRecs[0].AcctSeed__Account__c = a.Id;
            projRecs[0].Project_Type__c = 'SLP-PT';
            projRecs[0].Program_Iteration__c = proItrList[0].Id;
            projRecs[0].RecordTypeId = dodaRTId;
            update projRecs[0];
        
            Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'PVTButton', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
            Assessment_Report_Helper.getPRTestReportTypes(projRecs[0].Id);
        Test.stopTest();

    }
    
    private static testMethod void myTest5(){
    
        Account a = new Account(Name = 'DODA');
        insert a;
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
    
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(Name = 'SLP PI', Total_LT_Class_Hours__c = 85, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), Project_Type__c = 'SLP-PT')
        };
        insert proItrList;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = stdCon[0].Id;
            update conAss[0];
            
            List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            projRecs[0].AcctSeed__Account__c = a.Id;
            projRecs[0].Project_Type__c = 'SLP-PT';
            //projRecs[0].Program_Iteration__c = proItrList[0].Id;
            projRecs[0].RecordTypeId = dodaRTId;
            update projRecs[0];
        
            Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'PVTButton', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
        Test.stopTest();

    }
    
    private static testMethod void myTest5a(){
    
        Account a = new Account(Name = 'DODA');
        insert a;
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
    
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(Name = 'SLP PI', Total_LT_Class_Hours__c = 85, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), Project_Type__c = 'SLP-PT')
        };
        insert proItrList;
        
        Test.startTest();
        
            List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = stdCon[0].Id;
            update conAss[0];
            
            List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            projRecs[0].AcctSeed__Account__c = a.Id;
            projRecs[0].Project_Type__c = 'SLP-PT';
            //projRecs[0].Program_Iteration__c = proItrList[0].Id;
            projRecs[0].RecordTypeId = dodaRTId;
            projRecs[0].Start_Date__c = Date.Today();
            projRecs[0].End_Date__c = projRecs[0].Start_Date__c.addMonths(3).toStartOfMonth().addDays(1);
            update projRecs[0];
        
            Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'PVTButton', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
        Test.stopTest();

    }
    
    private static testMethod void myTest6(){
    
        Account a = new Account(Name = 'FCS');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = stdCon[0].Id;
        update conAss[0];
        
        Test.startTest();
        
            List<Events__c> events = [SELECT Id,Date__c,Status__c,Project__c 
                FROM Events__c 
                WHERE Project__c =: conAss[0].Project__c AND Status__c IN ('Scheduled', 'Completed')];
            
            List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            projRecs[0].AcctSeed__Account__c = a.Id;
            update projRecs[0];
            
            List<AcctSeed__Project_Task__c> projTask = [SELECT Id,Name,Total_Qty_Planned__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projRecs[0].Id];
            projTask[0].Total_Qty_Planned__c = 150;
            projTask[0].Project_Task_Type__c = 'Language Training';
            update projTask[0];
        
            Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'PVTButton', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
        Test.stopTest();
    }
    
    private static testMethod void myTest7(){
    
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = stdCon[0].Id;
        update conAss[0];
        
        Test.startTest();
        
            List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c, Start_Date__c, End_Date__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            projRecs[0].AcctSeed__Account__c = a.Id;
            projRecs[0].Start_Date__c = Date.newInstance(projRecs[0].Start_Date__c.year(),projRecs[0].Start_Date__c.month(),03);
            projRecs[0].End_Date__c = Date.newInstance(projRecs[0].End_Date__c.year(),projRecs[0].End_Date__c.month(),15);
            update projRecs[0];
                
            Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'ScheduleTrigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
            
        Test.stopTest();
    }
    
    private static testMethod void myTest7a(){
    
        Account a = new Account(Name = 'DLI-W');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = stdCon[0].Id;
        update conAss[0];
        
        Test.startTest();
        
            List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c, Start_Date__c, End_Date__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            projRecs[0].AcctSeed__Account__c = a.Id;
            projRecs[0].Start_Date__c = Date.newInstance(projRecs[0].Start_Date__c.year(),projRecs[0].Start_Date__c.month(),12);
            projRecs[0].End_Date__c = Date.newInstance(projRecs[0].End_Date__c.year(),projRecs[0].End_Date__c.month(),15);
            update projRecs[0];
                
            Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'ScheduleTrigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
            
        Test.stopTest();
    }
    
    private static testMethod void myTest8(){
    
        List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c, Start_Date__c, End_Date__c FROM AcctSeed__Project__c LIMIT 1];
        projRecs[0].AcctSeed__Account__c = null;
        update projRecs[0];
        
        Map<String,String> reportVal = new Map<String,String>();
        reportVal.put('test','test');
        String msg =  Assessment_Report_Helper.createAssessmentReportRecs(projRecs[0].Id, JSON.serialize(reportVal));
        System.assertEquals('Please populate Account in this Project.', msg);
    }
    
    /*
    private static testMethod void myTest9(){
        Account acc = new Account(Name = 'DLI');
        insert acc;
        
        List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c, Start_Date__c, End_Date__c FROM AcctSeed__Project__c LIMIT 1];
        
        projRecs[0].AcctSeed__Account__c = acc.Id;
        update projRecs;
        
        Map<String,String> reportVal = new Map<String,String>();
        reportVal.put('test','test');
        
        Test.startTest(); 
            String msg =  Assessment_Report_Helper.createAssessmentReportRecs(projRecs[0].Id, JSON.serialize(reportVal));
            System.assertEquals('Currently we support Assessment Report creation for PVT/FAS Account related Projects only.', msg);
        Test.stopTest();
    }
    */
    private static testMethod void myTest10(){
        Account acc = new Account(Name = 'PVT');
        insert acc;
        
        List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c, Start_Date__c, End_Date__c FROM AcctSeed__Project__c LIMIT 1];
        
        projRecs[0].AcctSeed__Account__c = acc.Id;
        update projRecs;
        
        Map<String,String> reportVal = new Map<String,String>();
        reportVal.put('test','test');
        
        Test.startTest(); 
            String msg =  Assessment_Report_Helper.createAssessmentReportRecs(projRecs[0].Id, JSON.serialize(reportVal));
            System.assertEquals('Assessment Reports are created sucessfully.', msg);
        Test.stopTest();
    }
    
    private static testMethod void myTest11(){
        Account acc = new Account(Name = 'PVT');
        insert acc;
        
        List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c, Start_Date__c, End_Date__c FROM AcctSeed__Project__c WHERE Name = 'Test Project 4'];
        
        projRecs[0].AcctSeed__Account__c = acc.Id;
        update projRecs;
        
        Map<String,String> reportVal = new Map<String,String>();
        reportVal.put('test','test');
        
        Test.startTest(); 
            String msg =  Assessment_Report_Helper.createAssessmentReportRecs(projRecs[0].Id, JSON.serialize(reportVal));
            System.assertEquals('Please create Student Contact Assignments for this Project.', msg);
        Test.stopTest();
    }
    
    // To cover updateAssementReportPM() method
    private static testMethod void myTest12(){
            
        List<Account> acc = [SELECT Id, Name FROM Account LIMIT 1];
        List<Assessment_Report__c> reports = [SELECT Id, Name, Project__c, Status__c FROM Assessment_Report__c LIMIT 1];
        
        List<AcctSeed__Project__c> projRecs = [SELECT Id, Project_Manager__c FROM AcctSeed__Project__c WHERE Id = :reports[0].Project__c];
        projRecs[0].AcctSeed__Account__c = acc[0].Id;
        update projRecs[0];
        
        Test.startTest();
        
            Map<Id,Id> pMId = new Map<Id,Id>();
            pMId.put(projRecs[0].Id, projRecs[0].Project_Manager__c);
            Set<Id> projProgramTypeUpd = new Set<Id>();
            
            Assessment_Report_Helper.updateAssementReportPM(pMId, projProgramTypeUpd);
        Test.stopTest();
    }
    
    private static testMethod void myTest13(){
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        System.debug('p=========='+p);
        
        User myUser = new User(alias = 'test123', email='teststffuser123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert myUser;
        
        Test.startTest();
        
            List<Account> acc = [SELECT Id, Name FROM Account LIMIT 2];
            List<AcctSeed__Project__c> updateProj = new List<AcctSeed__Project__c>();
            
            Contact c = new Contact(LastName = 'AR Test Contact', DLS_User__c = myUser.Id);
            insert c;
            
            List<Assessment_Report__c> reports = [SELECT Id, Name, Project__c, Status__c FROM Assessment_Report__c LIMIT 1];
        
            List<AcctSeed__Project__c> projRecs = [SELECT Id, Project_Manager__c FROM AcctSeed__Project__c WHERE Id = :reports[0].Project__c];
            List<AcctSeed__Project__c> projRecs1 = [SELECT Id, Project_Manager__c FROM AcctSeed__Project__c WHERE Id != :reports[0].Project__c];
            
            projRecs[0].AcctSeed__Account__c = acc[0].Id;
            projRecs1[0].AcctSeed__Account__c = acc[1].Id;
            updateProj.add(projRecs[0]);
            updateProj.add(projRecs1[0]);
            
            update updateProj;
        
            Map<Id,Id> lTId = new Map<Id,Id>();
            lTId.put(projRecs[0].Id, conList[0].Id);
            lTId.put(projRecs1[0].Id, c.Id);
            
            Set<Id> projProgramTypeUpd = new Set<Id>();
            
            Assessment_Report_Helper.updateAssementReportLT(lTId);
            
        Test.stopTest();
    }  
    /*
    // To cover createObservationReportRecs() method
    private static testMethod void myTest14(){
    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        Assessment_Report_Helper.createObservationReportRecs(new Set<Id>{conAss[0].Project__c}, conAss);
    }*/
    /*
    private static testMethod void myTest15(){
    
        List<Assessment_Report__c> reports = [SELECT Id, Name, Project__c, Status__c 
            FROM Assessment_Report__c 
            WHERE Status__c != 'Completed' AND RecordType.DeveloperName != 'Observation_Report'];
        
        Account a = new Account();
        a.Name = 'FAS';
        insert a;
        
        List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :reports[0].Project__c];
        projRecs[0].AcctSeed__Account__c = a.Id;
        update projRecs[0];
        
        Test.startTest();
            Assessment_Report_Helper.updateStatusOfARRs(new Set<Id>{projRecs[0].Id});
            
            List<Assessment_Report__c> repRecs = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Project__c = :projRecs[0].Id]; 
            System.assertEquals('Canceled', repRecs[0].Status__c);
        Test.stopTest();
    }*/
    
    private static testMethod void myTest16(){
    
        List<Language__c> languages = [SELECT Id, Name FROM Language__c LIMIT 2];
        
        List<Category__c> categories = new List<Category__c>{
            new Category__c(Min_Hours__c = 200, Max_Hours__c = 900, DLS_Lang_Cat__c = 'I', Test_Hour_Frequency__c = 300),
            new Category__c(Min_Hours__c = 300, Max_Hours__c = 800, DLS_Lang_Cat__c = 'II', Test_Hour_Frequency__c = 225)
        };
        insert categories;
        
        List<Category_Item__c> categoryItems = new List<Category_Item__c>{
            new Category_Item__c(Category__c = categories[0].Id, Course_Timeline__c = 200, Create_Training_Report__c = true, From_R_S__c = '2', Hours__c = 100, To_R_S__c = '3'),
            new Category_Item__c(Category__c = categories[0].Id, Course_Timeline__c = 150, Create_Training_Report__c = false, From_R_S__c = '1+', Hours__c = 175, To_R_S__c = '2'),
            new Category_Item__c(Category__c = categories[1].Id, Course_Timeline__c = 100, Create_Training_Report__c = true, From_R_S__c = '0', Hours__c = 125, To_R_S__c = '1+')
        };
        insert categoryItems;
        
        List<Language_Category__c> langCategories = new List<Language_Category__c>{
        
            new Language_Category__c(Category__c = categories[0].Id, Language__c = languages[0].Id)
        };
        insert langCategories;
        
        Account a = new Account();
        a.Name = 'FAS';
        insert a;
        
        List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c, Language__c FROM AcctSeed__Project__c LIMIT 1];
        projRecs[0].AcctSeed__Account__c = a.Id;
        projRecs[0].Language__c = languages[0].Id;
        update projRecs[0];
        
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id,Name,Total_Qty_Planned__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projRecs[0].Id];
        projTask[0].Total_Qty_Planned__c = 450;
        projTask[0].Total_Hours_Used_For_Language_Training__c = 400;
        update projTask[0];
        
        Test.startTest();
        
            AcctSeed__Project_Task__c oldPT = new AcctSeed__Project_Task__c();
            oldPT.Id = projTask[0].Id;
            oldPT.Total_Hours_Used_For_Language_Training__c = 75;
            
            Map<Id,AcctSeed__Project_Task__c> oldMap = new Map<Id,AcctSeed__Project_Task__c>();
            oldMap.put(oldPT.Id, oldPT);
            
            Map<Id,List<AcctSeed__Project_Task__c>> projPTMap = new Map<Id,List<AcctSeed__Project_Task__c>>();
            projPTMap.put(projRecs[0].Id, new List<AcctSeed__Project_Task__c>{projTask[0]});
            
            List<Assessment_Report__c> repRecs = [SELECT Id, Language_Training_Status__c FROM Assessment_Report__c WHERE Project__c = :projRecs[0].Id]; 
            repRecs[0].Language_Training_Status__c = 'Progress';
            update repRecs[0];
            
            Assessment_Report_Helper.createHoursbasedTR(projPTMap, oldMap);
            
        Test.stopTest();
    }
    
    private static testMethod void myTest16a(){
        
        Account a = new Account(Name = 'FAS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name, FirstName, LastName FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),01);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        List<Language__c> languages = [SELECT Id, Name FROM Language__c LIMIT 2];
        
        List<Category__c> categories = new List<Category__c>{
            new Category__c(Min_Hours__c = 200, Max_Hours__c = 900, DLS_Lang_Cat__c = 'I', Test_Hour_Frequency__c = 300),
            new Category__c(Min_Hours__c = 300, Max_Hours__c = 800, DLS_Lang_Cat__c = 'II', Test_Hour_Frequency__c = 225)
        };
        insert categories;
        
        List<Category_Item__c> categoryItems = new List<Category_Item__c>{
            new Category_Item__c(Category__c = categories[0].Id, Course_Timeline__c = 200, Create_Training_Report__c = true, From_R_S__c = '2', Hours__c = 100, To_R_S__c = '3'),
            new Category_Item__c(Category__c = categories[0].Id, Course_Timeline__c = 150, Create_Training_Report__c = false, From_R_S__c = '1+', Hours__c = 175, To_R_S__c = '2'),
            new Category_Item__c(Category__c = categories[1].Id, Course_Timeline__c = 100, Create_Training_Report__c = true, From_R_S__c = '0', Hours__c = 125, To_R_S__c = '1+')
        };
        insert categoryItems;
        
        List<Language_Category__c> langCategories = new List<Language_Category__c>{
        
            new Language_Category__c(Category__c = categories[0].Id, Language__c = languages[0].Id)
        };
        insert langCategories;
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Language__c = languages[0].Id, AcctSeed__Account__c = a.Id, Name = 'Test Project 1 - myTest16a',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            
            Id ltPTRTId = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
            
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(RecordTypeId = ltPTRTId, Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 600);
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
            
            List<AcctSeed__Project_Task__c> pt = [SELECT Id,Name,Total_Qty_Planned__c,AcctSeed__Project__c,AcctSeed__Project__r.DLS_Ref__c FROM AcctSeed__Project_Task__c WHERE Id = :projTask.Id];
            pt[0].Total_Qty_Planned__c = 450;
            pt[0].Total_Hours_Used_For_Language_Training__c = 202;
            update pt[0]; 
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name, Project__r.DLS_Ref__c FROM Assessment_Report__c WHERE Project__c = :proj.Id AND Language_Training_Status__c = 'Progress'];
            String arName = pt[0].AcctSeed__Project__r.DLS_Ref__c + ' ' + stdCon[0].FirstName + ' ' + stdCon[0].LastName + ' ' + languages[0].Name + ' PR Progress ' + 1;
            System.assertEquals(1, arRecSize.size());
            System.assertEquals(arName, arRecSize[0].Name);
        Test.stopTest();
    }
    
    private static testMethod void myTest17(){
    
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),01);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 1 - myTest17',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
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
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(12, arRecSize.size());
            //System.assertEquals(9, arRecSize.size());
                        
            Assessment_Report_Helper.getPRTestReportTypes(proj.Id);
        Test.stopTest();
    }
    
    private static testMethod void myTest17a(){
    
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),18);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        
        Test.startTest();
        
            AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 17a',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
            insert proj;
                    
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Class Leader')
            };
                    
            insert conAssignRecs;
            
            Assessment_Report_Helper.createAssessReport(new Set<Id>{proj.Id}, 'ScheduleTrigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.debug(':::arRecSize::::'+arRecSize);
            System.assertEquals(12, arRecSize.size());
            
        Test.stopTest();
    }
    
    private static testMethod void myTest17b(){
    
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),18);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,9);
        
        Test.startTest();
        
            AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 17b',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
            insert proj;
                    
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Class Leader')
            };
                    
            insert conAssignRecs;
            
            Assessment_Report_Helper.createAssessReport(new Set<Id>{proj.Id}, 'ScheduleTrigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.debug(':::arRecSize::::'+arRecSize);
            System.assertEquals(6, arRecSize.size());
            
        Test.stopTest();
    }
   
    private static testMethod void myTest17c(){
    
        Account a = new Account(Name = 'FCS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),1);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,19);
        
        Test.startTest();
        
            AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 17c',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
            insert proj;
                    
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Class Leader')
            };
                    
            insert conAssignRecs;
            
            Assessment_Report_Helper.createAssessReport(new Set<Id>{proj.Id}, 'ScheduleTrigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(6, arRecSize.size());
            //System.assertEquals(4, arRecSize.size());
        
            Assessment_Report_Helper.getPRTestReportTypes(proj.Id);
            
        Test.stopTest();
    }
    
    // To cover updateAssessmentReportInstructor() method
    private static testMethod void myTest18(){
    
        Account a = new Account(Name = 'FAS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 3];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),18);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
                
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 18',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
        insert projTask;
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
       
       Test.startTest();  
          
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
            };
        
            insert conAssignRecs;
        
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            List<Schedule__c> updateSch = [SELECT Id, Status__c, Total_Hours__c FROM Schedule__c WHERE Id IN :schList];
            updateSch[0].Status__c = 'Active';
            updateSch[0].Total_Hours__c = 40;
            update updateSch[0];
            /*        
            List<Schedule__c> updateSch1 = [SELECT Id, Status__c, Total_Hours__c FROM Schedule__c WHERE Id IN :updateSch];
            updateSch[0].Status__c = 'Active';
            updateSch[0].Total_Hours__c = 40;
            update updateSch[0];
            */
            Schedule__c replaceInsSch = new Schedule__c(Prior_Schedule__c = updateSch[0].Id, Name = '15-00687-SH2', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 40,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Replace Instructor', Instructor__c = stdCon[2].Id);
            insert replaceInsSch;
            
            List<Schedule__c> updateReplaceInsSch = [SELECT Id, Status__c, Total_Hours__c, Instructor__c FROM Schedule__c WHERE Id = :replaceInsSch.Id];
            updateReplaceInsSch[0].Status__c = 'Active';
            update updateReplaceInsSch[0];
            
        Test.stopTest();
        
        List<Assessment_Report__c> arRecSize = [SELECT Id, Instructor__c FROM Assessment_Report__c WHERE Project__c = :proj.Id];
        System.assertEquals(updateReplaceInsSch[0].Instructor__c, arRecSize[0].Instructor__c);             
    }
    
    // Schedule change logic
    private static testMethod void myTest19(){
    
        Account a = new Account(Name = 'FAS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 3];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),18);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        
        Test.startTest();
        
            AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 19',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
            insert proj;
            
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
            };
            
            insert conAssignRecs;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            List<Schedule__c> updateSch = [SELECT Id, Status__c, Total_Hours__c FROM Schedule__c WHERE Id IN :schList];
            updateSch[0].Status__c = 'Active';
            updateSch[0].Total_Hours__c = 40;
            update updateSch[0];
                        
            List<Schedule__c> updateSch1 = [SELECT Id, Status__c, Total_Hours__c FROM Schedule__c WHERE Id IN :updateSch];
            updateSch[0].Status__c = 'Active';
            updateSch[0].Total_Hours__c = 40;
            update updateSch[0];
            
            Schedule__c replaceInsSch = new Schedule__c(Prior_Schedule__c = updateSch[0].Id, Name = '15-00687-SH2', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 40,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Schedule Change', Instructor__c = stdCon[2].Id);
            insert replaceInsSch;
            
            List<Schedule__c> updateReplaceInsSch = [SELECT Id, Status__c, Total_Hours__c, Instructor__c FROM Schedule__c WHERE Id = :replaceInsSch.Id];
            updateReplaceInsSch[0].Status__c = 'Active';
            update updateReplaceInsSch[0];
            
            Assessment_Report_Helper.getPRTestReportTypes(proj.Id);
            
        Test.stopTest();
    }
    
    // Schedule change logic
    private static testMethod void myTest19a(){
    
        Account a = new Account(Name = 'FAS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 3];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),18);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        
        Test.startTest();
        
            AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 19a',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
            insert proj;
            
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
            };
        
            insert conAssignRecs;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            List<Schedule__c> updateSch = [SELECT Id, Status__c, Total_Hours__c FROM Schedule__c WHERE Id IN :schList];
            updateSch[0].Status__c = 'Active';
            updateSch[0].Total_Hours__c = 40;
            update updateSch[0];
                        
            List<Schedule__c> updateSch1 = [SELECT Id, Status__c, Total_Hours__c FROM Schedule__c WHERE Id IN :updateSch];
            updateSch[0].Status__c = 'Active';
            updateSch[0].Total_Hours__c = 40;
            update updateSch[0];
            
            Schedule__c replaceInsSch = new Schedule__c(Prior_Schedule__c = updateSch[0].Id, Name = '15-00687-SH2', Project__c = proj.Id,Project_Task__c = projTask.Id, Total_Hours__c = 40,End_Date__c = System.Today()+10, Start_Date__c = System.Today().addDays(-25),Status__c= 'Drafted', Schedule_Type__c = 'Schedule Change', Instructor__c = stdCon[2].Id);
            insert replaceInsSch;
            
            List<Schedule__c> updateReplaceInsSch = [SELECT Id, Status__c, Total_Hours__c, Instructor__c FROM Schedule__c WHERE Id = :replaceInsSch.Id];
            updateReplaceInsSch[0].Status__c = 'Active';
            update updateReplaceInsSch[0];
                       
        Test.stopTest();
    }
    
    // Schedule change logic
    private static testMethod void myTest19b(){
    
        Account a = new Account(Name = 'FAS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 3];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),18);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        
        Test.startTest();
        
            AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 19b',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
            insert proj;
            
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
            };
            
            insert conAssignRecs;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            List<Schedule__c> updateSch = [SELECT Id, Status__c, Total_Hours__c FROM Schedule__c WHERE Id IN :schList];
            updateSch[0].Status__c = 'Active';
            updateSch[0].Total_Hours__c = 40;
            update updateSch[0];
                        
            List<Schedule__c> updateSch1 = [SELECT Id, Status__c, Total_Hours__c FROM Schedule__c WHERE Id IN :updateSch];
            updateSch[0].Status__c = 'Active';
            updateSch[0].Total_Hours__c = 40;
            update updateSch[0];
            
            Schedule__c replaceInsSch = new Schedule__c(Prior_Schedule__c = updateSch[0].Id, Name = '15-00687-SH2', Project__c = proj.Id,Project_Task__c = projTask.Id, Total_Hours__c = 40,End_Date__c = System.Today()+10, Start_Date__c = System.Today().addDays(45),Status__c= 'Drafted', Schedule_Type__c = 'Schedule Change', Instructor__c = stdCon[2].Id);
            insert replaceInsSch;
            
            List<Schedule__c> updateReplaceInsSch = [SELECT Id, Status__c, Total_Hours__c, Instructor__c FROM Schedule__c WHERE Id = :replaceInsSch.Id];
            updateReplaceInsSch[0].Status__c = 'Active';
            update updateReplaceInsSch[0];
                       
        Test.stopTest();
    }
    
    // To cover assessmentReports {get; set;} logic
    private static testMethod void myTest20(){
            
        List<AcctSeed__Project__c> projList = [SELECT Id, Project_Manager__c FROM AcctSeed__Project__c WHERE Project_Manager__c != NULL LIMIT 1];
        update projList[0];
        
        List<Assessment_Report__c> ars = [SELECT Id, Status__c,Project_Manager__c FROM Assessment_Report__c WHERE Project__c = :projList[0].Id];
        ars[0].Status__c = 'Submitted to LTS';
        ars[0].Project_Manager__c = projList[0].Project_Manager__c;
        update ars[0];
        
        Assessment_Report_Helper arh = new Assessment_Report_Helper();
        arh.projManagerId = projList[0].Project_Manager__c;
        System.debug('c HOURLY COST======='+arh.assessmentReports);
    }
    
     
     private static testMethod void myTest21(){
    
        Account a = new Account(Name = 'DODA');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 3];
        
        List<Id> projIds = new List<Id>();
        for(AcctSeed__Project__c proj : [SELECT Id, (SELECT Id FROM Assessment_Reports__r) FROM AcctSeed__Project__c]){
            if(proj.Assessment_Reports__r == null || proj.Assessment_Reports__r.size() == 0){
                projIds.add(proj.Id);
            }
        }
        
        Test.startTest();
        
            if(projIds.size() > 0){
                Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
                List<MTT_Location__c> loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Assignment_Position__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];        
                conAss[0].Project__c = projIds[0];
                conAss[0].Candidate_Name__c = stdCon[0].Id;
                update conAss;
                
                List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
                projRecs[0].AcctSeed__Account__c = a.Id;
                projRecs[0].RecordTypeId = dodaRTId;
                projRecs[0].QB_Classification__c = 'OF0MTT0PS';
                projRecs[0].Training_Location__c = loc[0].Id;
                update projRecs[0];
            
                Assessment_Report_Helper.createAssessReport(new Set<Id>{projRecs[0].Id}, 'ScheduleTrigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
                // To exclude the creation of monthly Report when thr is a final report for the project on the end date
                // Based on today (Test Class execution) date value AR record creation count for this method get varied
                //System.assertEquals(4, [SELECT Id FROM Assessment_Report__c WHERE Project__c = :projRecs[0].Id].size());
                
            Test.stopTest();
        }
    }
        
    private static testMethod void myTest22(){
    
        Account a = new Account(Name = 'Test Account for Other');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.Today();
        Date projED = Date.Today().addDays(40);
        
        Test.startTest();
        
            AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 22',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
            insert proj;
                    
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
            
            Assessment_Report_Helper.createAssessReport(new Set<Id>{proj.Id}, 'ScheduleTrigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(1, arRecSize.size());
                    
            Assessment_Report_Helper.getPRTestReportTypes(proj.Id);
                
        Test.stopTest();
    }
    
    private static testMethod void testAnnualReportCreation(){    
        
        Test.startTest();
        
        List<AcctSeed__Time_Card_Day__c>  tcd = [SELECT Id, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c WHERE AcctSeed__Time_Card_Line__c != null];
        AcctSeed__Time_Card_Line__c tcl = [SELECT Id,AcctSeed__Project__c,AcctSeed__Time_Card__r.Intructor__c 
                                                FROM AcctSeed__Time_Card_Line__c                  
                                                WHERE Id = :tcd[0].AcctSeed__Time_Card_Line__c LIMIT 1];
        
        Id dlsEmpId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        Contact con = [SELECT Id, Supervisor_Name__c, Hours_in_Current_Year__c FROM Contact WHERE Id = :tcl.AcctSeed__Time_Card__r.Intructor__c LIMIT 1];
        User userRec = [SELECT id, FirstName, LastName, MiddleName, email FROM User LIMIT 1];
        
        Contact c = new Contact();
        c.Id = tcl.AcctSeed__Time_Card__r.Intructor__c;
        c.Supervisor_Name__c = userRec.Id;
        update c;
                
        User usr = [SELECT id, FirstName, LastName, MiddleName, email FROM User WHERE Id = :c.Supervisor_Name__c];
        
        con.Hours_in_Current_Year__c = 55;
        update con;
        
        Assessment_Report_Helper.createAnnualInstructorPerformanceReviewReport(new Set<Id>{con.Id});
        AnnualReportReminderEmailToLTS.sendAnEmailLTS();
    
        /*List<Assessment_Report__c> annualReports = [SELECT Id, Report_Date__c , Instructor__c , Instructor__r.Name ,Report_File_Name__c FROM Assessment_Report__c WHERE RecordType.DeveloperName = 'Annual_Instructor_Performance_Review'];
        System.assertEquals(1, annualReports.size());
        
        AnnualReportReminderEmailToLTS.sendAnEmailLTS();
    
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = annualReports[0].Id);
        insert frup;
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Annual Instructor Performance Review', APXTConga4__Template_Group__c = 'Annual Instructor Performance Review')
        };
        insert congaTemp;
        
        string result = GenericUrlLaunch_Ctrl.validateAssessmentRecBoxFolder(annualReports[0].Id);        
        System.assertNotEquals('No Box Record', result);*/
        Test.stopTest();
    }
    
    private static testMethod void myTest23(){
    
        Account a = new Account(Name = 'APMO');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),01);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 23',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(3, arRecSize.size());
            //System.assertEquals(2, arRecSize.size()); 
            
            Assessment_Report_Helper.getPRTestReportTypes(proj.Id);
                        
        Test.stopTest();
    }
    
    private static testMethod void myTest24(){
    
        Account a = new Account(Name = 'FCS2');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),1);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,19);
        
        Test.startTest();
        
            AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 24',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
            insert proj;
                    
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Class Leader')
            };
                    
            insert conAssignRecs;
            
            Assessment_Report_Helper.createAssessReport(new Set<Id>{proj.Id}, 'ScheduleTrigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            
            Assessment_Report_Helper.getPRTestReportTypes(proj.Id);
            
        Test.stopTest();
    }
    
    private static testMethod void myTest_1(){
    
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),25);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+1,27);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project test 1',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(3, arRecSize.size());
                        
        Test.stopTest();
    }
    
    private static testMethod void myTest_2(){
    
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),25);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project test 2',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(6, arRecSize.size());
                        
        Test.stopTest();
    }
    private static testMethod void myTest_3(){
    
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),25);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,28);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project test 3',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(6, arRecSize.size());
                        
        Test.stopTest();
    }
    private static testMethod void myTest_4(){
    
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,03);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,28);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project test 4',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(6, arRecSize.size());
                        
        Test.stopTest();
    }
    private static testMethod void myTest_5(){
    
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,03);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project test 5',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(6, arRecSize.size());
                        
        Test.stopTest();
    }
    
    private static testMethod void myTest_6(){
    
        Account a = new Account(Name = 'DLIW');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,01);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,10);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project test 6',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name, Report_Date__c FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.debug(':::arRecSize:::'+arRecSize);
            System.debug(':::arRecSize:::'+arRecSize[0].Report_Date__c);
            System.assertEquals(3, arRecSize.size());
                        
        Test.stopTest();
    }
    
    private static testMethod void myTest_7(){
    
        Account a = new Account(Name = 'PGLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,03);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test PGLS Project 7',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(2, arRecSize.size());
                        
        Test.stopTest();
    }
    
    private static testMethod void myTest_8(){
    
        Account a = new Account(Name = 'DLI-W');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),03);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test PGLS Project 8',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(9, arRecSize.size());
            //System.assertEquals(6, arRecSize.size());
                
            List<AcctSeed__Project__c> updateProj = [SELECT Id, Name, AcctSeed__Status__c,On_Hold_Date__c FROM AcctSeed__Project__c WHERE Id = :proj.Id];
            updateProj[0].AcctSeed__Status__c = 'On Hold';
            updateProj[0].On_Hold_Date__c = projSD;
            update updateProj[0];
            
            List<Assessment_Report__c> arRecSize1 = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :updateProj[0].Id];
            System.assertEquals(0, arRecSize1.size());
            
        Test.stopTest();
    }
    
    private static testMethod void myTest_9(){
    
        Account a = new Account(Name = 'DLI-W');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,03);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test PGLS Project 9',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];

            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(6, arRecSize.size());
            
        Test.stopTest();
    }
    
    private static testMethod void myTest_10(){
        
        Map<String,String> reportVal = new Map<String,String>();
        
        Account a = new Account(Name = 'DLI-W');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,03);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        Test.startTest();
        
        reportVal.put('Language_Training_Status__c','Final Report');
        reportVal.put('Report_Date__c',String.valueOf(projSD));
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test PGLS Project 10',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
            
        insert conAssignRecs;
            
        String msg =  Assessment_Report_Helper.createAssessmentReportRecs(proj.Id, JSON.serialize(reportVal));
        System.assertEquals('Assessment Reports are created sucessfully.', msg);
        
        Test.stopTest();
    }
    
    // To Cover createObservationReportRecs from CA Trigger
    private static testMethod void myTest_11(){
    
        Account a = new Account(Name = 'DLI-W');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,03);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test PGLS Project 11',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
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
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id AND RecordType.DeveloperName = 'DLI_Observation_Report'];
            System.assertEquals(2, arRecSize.size());
            
            //Assessment_Report_Helper.createObservationReportRecs(new Set<Id>{proj.Id}, insCA, new Map<Id, List<Date>>(), 'CATrigger');
            
        Test.stopTest();
    }
    
    // To Cover createHoursbasedTR from Project Task Trigger
    private static testMethod void myTest_12(){
    
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
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Language__c = languages[0].Id, AcctSeed__Account__c = a.Id, Name = 'Test PGLS Project 12',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(RecordTypeId = lTPTRTId, Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 400, Total_Hours_Used_For_Language_Training__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
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
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(3, arRecSize.size());
                        
        Test.stopTest();
    }
    
    // DODA - 'Other' => new List<String>{'Final Report'} 
    private static testMethod void myTest_13(){
    
        Account a = new Account(Name = 'DODA');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
        Id plpPIRTId = Schema.SObjectType.Program_Iteration__c .getRecordTypeInfosByDeveloperName().get('PLP_Iteration').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,03);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(RecordTypeId = plpPIRTId, Name = 'SLP PI', Total_LT_Class_Hours__c = 85, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), Project_Type__c = 'PLP', Final_Progress_Due_Date__c = projED)
        };
        insert proItrList;
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Activated_Date_From_On_Hold__c = projSD, Program_Iteration__c = proItrList[0].Id, AcctSeed__Account__c = a.Id, Name = 'Test PGLS Project 13',AcctSeed__Status__c = 'Active',RecordTypeId = dodaRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];

            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(1, arRecSize.size());
            
            Assessment_Report_Helper.getPRTestReportTypes(proj.Id);
            
        Test.stopTest();
    }    
    
    // To cover updateAssessReportTypeOfTraining() method
    private static testMethod void myTest_14(){
        
        Account a = new Account(Name = 'DLI-W');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,03);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test PGLS Project 14',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
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
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(8, arRecSize.size());
            
            List<AcctSeed__Project__c> projRec = [SELECT Id, Program_Type__c FROM AcctSeed__Project__c WHERE Id = :proj.Id];
            projRec[0].Program_Type__c = 'Familiarization';
            update projRec[0];
            
            List<Assessment_Report__c> arRec = [SELECT Id, Type_of_Training__c FROM Assessment_Report__c WHERE Project__c = :proj.Id AND RecordType.DeveloperNAme NOT IN ('Observation_Report','Annual_Instructor_Performance_Review')];
            System.assertEquals(projRec[0].Program_Type__c, arRec[0].Type_of_Training__c);
            
        Test.stopTest();
    }
    
    // To cover updateAssessmentReports_DueDate and to_Create_UpdateAssessmentReports
    // to_Create_UpdateAssessmentReports method is future one, so new report count we can't get it
    private static testMethod void updateAssessmentReports_DueDate_Test1(){
    
        Account a = new Account(Name = 'FCS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Contact myCon = new Contact(LastName = 'My new test con 2', Email = 'mynewtestcon2@gmail.com');
        insert myCon;
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),1);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,19);
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        Test.startTest();
        
            AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project due date 1',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
            insert proj;
             
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = myCon.Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                    
            insert conAssignRecs;
            
            List<Schedule__c> updateSch = [SELECT Id, Project__c FROM Schedule__c LIMIT 1];
            updateSch[0].Project__c = proj.Id;
            updateSch[0].Project_Task__c=projTask.Id;
            updateSch[0].Status__c = 'Active';
            updateSch[0].Total_Hours__c = 40;
            update updateSch[0];
             
            Assessment_Report_Helper.createAssessReport(new Set<Id>{proj.Id}, 'ScheduleTrigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
            
            ManageProjectDatescontroller.isFromManageProjectDate_Status = True;
            
            proj.End_Date__c = projED.addMonths(1);
            update proj;
            
        Test.stopTest();
    }
    
    // To cover updateAssessmentReports_DueDate and toCancelAssessmentReports
    private static testMethod void updateAssessmentReports_DueDate_Test2(){
    
        Account a = new Account(Name = 'FCS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Contact myCon = new Contact(LastName = 'My new test con 1', Email = 'mynewtestcon1@gmail.com');
        insert myCon;
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),1);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+4,19);
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        Test.startTest();
        
            AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project Due date 1',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
            insert proj;
             
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = myCon.Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                    
            insert conAssignRecs;
            
            Assessment_Report_Helper.createAssessReport(new Set<Id>{proj.Id}, 'ScheduleTrigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
            
            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id AND Status__c IN ('Draft', 'Scheduled')];
            System.assertEquals(5, arRecSize.size());
            //System.assertEquals(4, arRecSize.size());
            
            ManageProjectDatescontroller.isFromManageProjectDate_Status = True;
            
            proj.End_Date__c = projED.addMonths(-2);
            update proj;
            
            List<Assessment_Report__c> arRecSize_New = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id AND Status__c IN ('Draft', 'Scheduled')];
            System.assertEquals(3, arRecSize_New.size());
            //System.assertEquals(2, arRecSize_New.size());
            
        Test.stopTest();
    }
    
    private static testMethod void updateARToCancelled_Test(){
    
        Account a = new Account(Name = 'FCS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Contact myCon = new Contact(LastName = 'My new test con 3', Email = 'mynewtestcon3@gmail.com');
        insert myCon;
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),15);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        Test.startTest();
        
            AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project AR cancel 1',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
            insert proj;
             
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = myCon.Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                    
            insert conAssignRecs;
            
            Assessment_Report_Helper.createAssessReport(new Set<Id>{proj.Id}, 'ScheduleTrigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
            
            CustomButtonService.isFromManageProjectStatus = True;
            
            proj.AcctSeed__Status__c = 'Canceled';
            update proj;
            
        Test.stopTest();
    }
    
    // Initial Test Report will not created for DODA Projects with Project Type = SLP-FT or SLP-PT and Program Type = Familiarization or Initial acquisition
    private static testMethod void myTest_15(){
    
        Account a = new Account(Name = 'DODA');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
        Id plpPIRTId = Schema.SObjectType.Program_Iteration__c .getRecordTypeInfosByDeveloperName().get('PLP_Iteration').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date todayDate = Date.Today();
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,todayDate.Day());
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(RecordTypeId = plpPIRTId, Name = 'SLP-PT', Total_LT_Class_Hours__c = 85, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(50), Project_Type__c = 'SLP-PT', Final_Progress_Due_Date__c = projED, Midterm_Progress_Due_Date__c = projSD.addDays(10))
        };
        insert proItrList;
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Program_Type__c = 'Familiarization', Activated_Date_From_On_Hold__c = projSD, Program_Iteration__c = proItrList[0].Id, AcctSeed__Account__c = a.Id, Name = 'Test PGLS Project 15',AcctSeed__Status__c = 'Active',RecordTypeId = dodaRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];

            List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE Project__c = :proj.Id];
            System.assertEquals(3, arRecSize.size());
            
            Assessment_Report_Helper.getPRTestReportTypes(proj.Id);
            
        Test.stopTest();
    }    
    
    // To cover the DLI observation reports creation logic when the project's end date is extended
    private static testMethod void myTest_16(){
    
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,01);
        Date projED = projSD.addMonths(2).toStartOfMonth().addDays(-1);
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project - myTest_16',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
                
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
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
            
            ManageProjectDatescontroller.isFromManageProjectDate_Status = true;
            proj.End_Date__c = projED.addMonths(3);
            update proj;
            
        Test.stopTest();
        
        List<Assessment_Report__c> arRecSize = [SELECT Id, Name FROM Assessment_Report__c WHERE RecordType.DeveloperName = 'DLI_Observation_Report' AND Report_Date__c > : projED];
        System.assertEquals(3, arRecSize.size());
    }
}