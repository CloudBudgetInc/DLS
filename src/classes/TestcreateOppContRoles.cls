@isTest
public class TestcreateOppContRoles {

    @testSetup static void setup(){
        Test.startTest();
            List<Contact_Assignments__c> conAssignlist = TestClassUtil.createTestContactAssignment();                
        Test.stopTest();        
        List<Events__c> events = TestClassUtil.createTestEvent();
    }
    
    // For Project Manager Updation in Project
    public static testmethod void testMethod1() {
        
        List<RecordType> conRt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'DLS_Employee'];
        
        List<Account> account = [SELECT Id FROM Account LIMIT 2];
        if(conRt.size() > 0) {
            List<Contact> con = new List<Contact> { 
                new Contact(LastName = 'Tom Curise'+Datetime.now(),Email='test1343@test.com', RecordTypeId = conRt[0].Id, AccountId = account[0].Id),
                new Contact(LastName = 'Dora'+Datetime.now(),Email='test22313@test.com', RecordTypeId = conRt[0].Id, AccountId = account[0].Id)
            };
            insert con;
            List<Profile> profileUser = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
            String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
            if(profileUser != null && profileUser.size() > 0 && con != null && con.size() > 0) {
                List<User> userList = new List<User>{        
                    new User(Alias = 'standt', Email = 'test@gmail.com',EmailEncodingKey = 'UTF-8', LastName = 'Test Contact21314', 
                    LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profileUser[0].Id, 
                    TimeZoneSidKey = 'America/Los_Angeles', UserName = un)
                };
                insert userList;
    
                List<Contact_Assignments__c> conAss = [SELECT Id, Name, Assignment_Position__c, Candidate_Name__c, Project__c, candidate_Name__r.DLS_User__c, Project__r.Project_Manager__c FROM Contact_Assignments__c 
                                                       WHERE Project__c != null AND Candidate_Name__c != null AND Project__r.RecordType.DeveloperName != 'Admin_Projects' LIMIT 2];
                
                Test.startTest();
                
                    if(conAss.size() > 0) {
                        conAss[0].Assignment_Position__c = 'Project Manager';
                        conAss[1].Assignment_Position__c = 'Manager';
                        
                        if(con.size() > 0) {
                            con[0].DLS_User__c = userList[0].Id;
                            con[1].DLS_User__c = userList[0].Id;
                            update con;
                            
                            conAss[0].Candidate_Name__c = con[0].Id;
                            conAss[1].Candidate_Name__c = con[1].Id;
                        }
                        update conAss;                    
                    } 
                    List<Contact_Assignments__c> conAssUp = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.DLS_User__c, Candidate_Name__r.DLS_User__r.Name, Project__r.Project_Manager__c FROM Contact_Assignments__c WHERE Id = :conAss[0].Id];
                    if(conAssUp.size() > 0)
                        System.assertEquals(conAssUp[0].Candidate_Name__r.DLS_User__c, conAssUp[0].Project__r.Project_Manager__c);
                
                Test.stopTest();
            }
        }
    } 
    
    // For Contact Role Creation
    public static testmethod void testMethod2() {
        
        List<Contact> con = [SELECT Id FROM Contact LIMIT 2];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Assignment_Position__c, Candidate_Name__c, Opportunity_Name__c FROM Contact_Assignments__c 
                                               WHERE Opportunity_Name__c != null AND Candidate_Name__c != null LIMIT 2];
        Set<Id> oppId = new Set<Id>();
        Test.startTest();
        if(conAss.size() > 0) {
            conAss[0].Assignment_Position__c = 'Project Manager';
            conAss[1].Assignment_Position__c = 'Manager';
            
            if(con.size() > 0) {
                conAss[0].Candidate_Name__c = con[0].Id;
                conAss[1].Candidate_Name__c = con[1].Id;
            }
            update conAss;
            oppId.add(conAss[0].Opportunity_Name__c);
            oppId.add(conAss[1].Opportunity_Name__c);
        }
        Test.stopTest();
        List<OpportunityContactRole> ocrList = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN :oppId LIMIT 2];
        System.assert(ocrList.size() > 0);
    }  
    
    // For # of Instructor Active / Awarded count
    public static testmethod void testMethod3() {
        
        List<Contact> con = [SELECT Id FROM Contact LIMIT 2];
        Id proRt,oppRt;
        Set<Id> proId = new Set<Id>();
        Set<Id> oppId = new Set<Id>();
        
        List<RecordType> rtype = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType IN ('Opportunity', 'AcctSeed__Project__c') AND DeveloperName IN ('MTT_Opportunities', 'MTT_Projects') LIMIT 2];
        
        if(rtype.size() > 0) {
            for(RecordType rt : rtype) {
                if(rt.DeveloperName == 'MTT_Opportunities')
                    oppRt = rt.Id;
                if(rt.DeveloperName == 'MTT_Projects')
                    proRt = rt.Id;
            }
        }
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Project__c, Project__r.RecordTypeId, Opportunity_Name__c, Opportunity_Name__r.RecordTypeId FROM Contact_Assignments__c 
                                               WHERE Project__c != null AND Opportunity_Name__c != null AND Status__c = 'Active' AND RecordType.DeveloperName = 'Instructor' LIMIT 2];       
        if(conAss.size() > 0) {
           proId.add(conAss[0].Project__c);
           proId.add(conAss[1].Project__c);
           oppId.add(conAss[0].Opportunity_Name__c);
           oppId.add(conAss[1].Opportunity_Name__c);
           
           List<AcctSeed__Project__c> pro = [SELECT Id, Name, Oral_Exam_Date_Time__c FROM AcctSeed__Project__c WHERE Id IN :proId LIMIT 2];
           List<Opportunity> opp = [SELECT Id, Name, RecordTypeId FROM Opportunity WHERE Id IN :oppId LIMIT 2];
            
           if(pro.size() > 0) {
               pro[0].RecordTypeId = proRt;
               pro[0].Project_Type__c = 'HUB';
               pro[0].To__c = 'TestTo';
               update pro;
           }
           if(opp.size() > 0) {
               opp[0].RecordTypeId = oppRt;
               opp[0].Project_Type__c = 'HUB';
               opp[0].To__c = 'TestTo';
               update opp;
           }
           conAss[0].Status__c = 'Awarded';
           conAss[1].Status__c = 'Awarded';
           
           Test.startTest();
           
               update conAss;
               delete conAss;
               List<Opportunity> oppUp = [SELECT Id, Name, of_Instructors_awarded__c FROM Opportunity WHERE Id IN :oppId LIMIT 2];
               if(oppUp.size() > 0)
                   System.assertEquals(0,oppUp[0].of_Instructors_awarded__c);
           Test.stopTest();
        }
    }        
    
    // For Text Field Updation
    public static testmethod void testMethod5() {
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Status__c, Candidate_Name__c, Candidate_Name__r.Name, Project__c, Opportunity_Name__c FROM Contact_Assignments__c 
                                               WHERE Project__c != null AND Opportunity_Name__c != null AND Candidate_Name__c  != null LIMIT 2];
        Set<Id> proId = new Set<Id>();
        
        Test.startTest();
        
        if(conAss.size() > 0) {
            proId.add(conAss[0].Project__c);
            proId.add(conAss[1].Project__c);
            
            List<AcctSeed__Project__c> pro = [SELECT Id, Name, Instructors__c , Students__c , Staffs__c FROM AcctSeed__Project__c WHERE Id IN :proId];
            if(pro.size() > 0) {
                pro[0]. AcctSeed__Status__c = 'Order';
                update pro;
            }
                
            conAss[0].Status__c = 'Planned';
            conAss[1].Status__c = 'Planned';
            update conAss;
        }
        
        
            List<AcctSeed__Project__c> proUp = [SELECT Id, Name, Instructors__c , Students__c , Staffs__c FROM AcctSeed__Project__c WHERE Id IN :proId];
            if(proUp.size() > 0)
                System.assert(proUp[0].Instructors__c.contains(conAss[0].Candidate_Name__r.Name)) ;
        Test.stopTest();
    } 
    
    // For Contact Field Updation
    public static testmethod void testMethod6() {
            
        Set<Id> oppId = new Set<Id>();
        List<Contact> con = [SELECT Id FROM Contact LIMIT 2];
        List<AcctSeed__Project__c> pro = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 2];
        List<Opportunity> opp = [SELECT Id, Name, Location__c FROM Opportunity LIMIT 2];
        if(pro.size() > 0 && con.size() > 0 && opp.size() > 0) {
               
            oppId.add(opp[0].Id);
            oppId.add(opp[1].Id);
            
            List<Contact_Assignments__c> conAss = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Opportunity_Name__c = opp[0].Id, Project__c = pro[0].Id, Assignment_Position__c = 'Project Manager', Candidate_Name__c = Con[0].Id, Status__c = 'Active',Start_Date__c = system.today(), End_Date__c = System.today().addDays(10)),
                new Contact_Assignments__c(Opportunity_Name__c = opp[1].Id, Project__c = pro[1].Id, Assignment_Position__c = 'Training Officer', Candidate_Name__c = Con[1].Id, Status__c = 'Active',Start_Date__c = system.today(), End_Date__c = System.today().addDays(10))
            };
            
            Test.startTest();
                insert conAss;
            
                List<Opportunity> oppUp = [SELECT Id, Name, Agency_Contact__c FROM Opportunity WHERE Id IN :oppId AND Agency_Contact__c != null];
                if(oppUp.size() > 0)
                    System.assertEquals(conAss[1].Candidate_Name__c,oppUp[0].Agency_Contact__c);
            Test.stopTest();
        }
    }   
    
    // For contact Most_Recent_Requested_Language__c Updation
    public static testmethod void testMethod7() {
        
        List<Language__c> lang = [SELECT Id, Name FROM Language__c LIMIT 1];
        
        List<Opportunity> opp = [SELECT Id, Language_LU__c FROM Opportunity LIMIT 1];
        opp[0].Language_LU__c = lang[0].Id;
        Test.startTest();
        update opp[0];
        
        List<Contact> con = [SELECT Id FROM Contact LIMIT 2];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Opportunity_Name__c FROM Contact_Assignments__c 
                                               WHERE Opportunity_Name__c != null AND 
                                               Candidate_Name__c != null AND 
                                               Status__c = 'Active' AND
                                               RecordType.DeveloperName = 'Student' AND Candidate_Name__c != : con[0].Id LIMIT 1];
       conAss[0].Candidate_Name__c = con[0].Id;
       conAss[0].Opportunity_Name__c = opp[0].Id;
       
        
       
           update conAss[0];
        Test.stopTest();     
           List<Contact_Assignments__c> ca = [SELECT Id, Candidate_Name__c, Candidate_Name__r.Most_Recent_Requested_Language__c FROM Contact_Assignments__c WHERE Id = :conAss[0].Id];
           System.assertEquals(lang[0].Name, ca[0].Candidate_Name__r.Most_Recent_Requested_Language__c);       
                                        
    } 
    
    // For Location__c Updation when Opportunity is not Null
    public static testmethod void testMethod8() {
        
        List<MTT_Location__c> loc = new List<MTT_Location__c> {
            new MTT_Location__c(Name='Test Loc 1', State__c = 'Test State'),
            new MTT_Location__c(Name='Test Loc 2', State__c = 'Test State')
        };
        insert loc; 
        
        List<Opportunity> opp = [SELECT Id, Name, Location__c FROM Opportunity LIMIT 2];
        List<Contact> con = [SELECT Id FROM Contact LIMIT 2];
        if(opp.size() > 0 && con.size() > 0) {
            opp[0].Location__c = loc[0].Id;
            opp[1].Location__c = loc[1].Id;
            update opp;
        
            Test.StartTest();
            
                List<Contact_Assignments__c> conAss = new List<Contact_Assignments__c> {
                    new Contact_Assignments__c(Opportunity_Name__c = opp[0].Id, Candidate_Name__c = Con[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), Status__c = 'Active'),
                    new Contact_Assignments__c(Candidate_Name__c = Con[1].Id, Opportunity_Name__c = opp[1].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), Status__c = 'Active')
                };
                insert conAss;
                
                Set<Id> conAssId = new Set<Id>();
                conAssId.add(conAss[0].Id);
                conAssId.add(conAss[1].Id);
                
                List<Contact_Assignments__c> conAssUp = [SELECT Id, Name, Opportunity_Name__c, Opportunity_Name__r.Location__c, Location__c FROM Contact_Assignments__c WHERE Id IN :conAssId AND Project__c = null];
                if(conAssUp.size() > 0)
                    System.assertEquals(conAssUp[0].Opportunity_Name__r.Location__c,conAssUp[0].Location__c);
            Test.stopTest();
        }
    } 
    
    // For Location__c Updation when Project is not Null
    public static testmethod void testMethod9() {
        
        List<MTT_Location__c> loc = new List<MTT_Location__c> {
            new MTT_Location__c(Name='Test Loc 1', State__c = 'Test State'),
            new MTT_Location__c(Name='Test Loc 2', State__c = 'Test State')
        };
        insert loc; 
        
        List<AcctSeed__Project__c> pro = [SELECT Id, Name, Training_Location__c FROM AcctSeed__Project__c LIMIT 2];
        List<Contact> con = [SELECT Id FROM Contact LIMIT 2];
        if(pro.size() > 0 && con.size() > 0) {
            
            pro[0].Training_Location__c = loc[0].Id;
            pro[0].QB_Classification__c='OF0MTT0PS';
            pro[1].Training_Location__c = loc[1].Id;
            pro[1].QB_Classification__c='OF0MTT0PS';
            update pro;
            
            Test.startTest();
            
            List<Contact_Assignments__c> conAss = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Project__c = pro[0].Id, Candidate_Name__c = Con[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), Status__c = 'Active'),
                new Contact_Assignments__c(Project__c = pro[1].Id, Candidate_Name__c = Con[1].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), Status__c = 'Active')
            };
            insert conAss;
            
            Set<Id> conAssId = new Set<Id>();
            conAssId.add(conAss[0].Id);
            conAssId.add(conAss[1].Id);
            
            List<Contact_Assignments__c> conAssUp = [SELECT Id, Name, Project__c, Opportunity_Name__c, Project__r.Training_Location__c, Location__c FROM Contact_Assignments__c WHERE Id IN :conAssId];
           
            if(conAssUp.size() > 0)
                System.assertEquals(conAssUp[0].Project__r.Training_Location__c,conAssUp[0].Location__c);
            Test.stopTest();
        }
    } 
    
    // For Status Updation based on Project Status
    public static testmethod void testMethod10() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c FROM Contact_Assignments__c WHERE Project__c != null LIMIT 2];
        Set<Id> proId = new Set<Id>();
        Test.startTest();
        if(conAssList.size() > 0) {
            
            proId.add(conAssList[0].Project__c);
            proId.add(conAssList[1].Project__c);
                        
            List<AcctSeed__Project__c> proList = [SELECT Id, Name FROM AcctSeed__Project__c WHERE Id NOT IN :proId LIMIT 2];
            
            if(proList.size() > 0) {
                proList[0].AcctSeed__Status__c = 'Active';
                proList[1].AcctSeed__Status__c = 'Active';
                update proList;
            }
            
            conAssList[0].Status__c = 'Planned';
            conAssList[0].Project__c = proList[0].Id;
            conAssList[1].Project__c = proList[1].Id;
            conAssList[1].Status__c = 'Planned';
            update conAssList;
       Test.stopTest(); 
            List<Contact_Assignments__c> conAssUp = [SELECT Id, Name, Status__c FROM Contact_Assignments__c WHERE Id = :conAssList[0].Id];
            if(conAssUp.size() > 0)
                System.assertEquals(conAssUp[0].Status__c, proList[0].AcctSeed__Status__c);
        }
    }
    
    // Submit the Approval Request To HR
    public static testmethod void testMethod11() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c,Additional_Compensation_Status__c, Additional_Compensation_Type__c, Daily_Travel_Reimbursement_Amount__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Instructor' LIMIT 2];        
        
        ContactAssignmentLightningCtrl.isFromCA = True;
        
        conAssList[0].Additional_Compensation_Status__c = 'Draft';
        conAssList[0].Additional_Compensation_Type__c = 'Client Site Travel Reimbursement';
        conAssList[0].Daily_Travel_Reimbursement_Amount__c = 600;
        update conAssList[0];
    }
    
    // Submit the Approval Request To HR
    public static testmethod void testMethod12() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c,Additional_Compensation_Status__c, Additional_Compensation_Type__c, Bonus_Amount__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Instructor' LIMIT 2];        
        
        ContactAssignmentLightningCtrl.isFromCA = True;
        
        conAssList[0].Additional_Compensation_Status__c = 'Draft';
        conAssList[0].Additional_Compensation_Type__c = 'End of Training Bonus';
        conAssList[0].Bonus_Amount__c = 600;
        update conAssList[0];
    }
    
    // Added By HL
    // To update Opportunity_Product_Id__c of CA when OPLI related to that CA was deleted
    public static testMethod void deleteOPLI(){
    
        List<Contact> con = [SELECT Id FROM Contact LIMIT 1];
        List<OpportunityLineItem> opliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :projList LIMIT 1];
        
        List<Contact_Assignments__c> instructors = new List<Contact_Assignments__c> {
            new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = con[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10)),
            new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = con[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10))
        };
        
        Test.startTest();
        
            insert instructors;
            delete opliList;
        Test.stopTest();
    }
    
    // Added By HL 
    // To sharing the cost Rate records
    public static testMethod void shareCRMethod1(){
    
        Id staffRTId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        Id supervisorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        Id instructorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        List<OpportunityLineItem> opliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        Account acc = new Account(Name='Test Account 1'+Datetime.now());
        Insert acc;
        
        List<Contact> staffContacts = new List<Contact>{
            new Contact(AccountId=acc.Id,LastName='Testing', RecordTypeId = staffRTId)            
        };
        insert staffContacts;
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :projList LIMIT 1];
                
        Test.startTest();
        
            List<AcctSeed__Cost_Rates__c>  costRates = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
            insert costRates;
            List<Contact_Assignments__c> Supervisor = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = supervisorRTId)
            };
            insert Supervisor;
            
            List<Contact_Assignments__c> instructors = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Rate_Card_Rate__c = costRates[0].Id, Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = instructorRTId),
                new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Rate_Card_Rate__c = costRates[0].Id, Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = instructorRTId)
            };
            
            insert instructors;
        Test.stopTest();
    }
    
    public static testMethod void shareCRMethod2(){
    
        Id staffRTId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        Id supervisorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        Id instructorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        List<OpportunityLineItem> opliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        Account acc = new Account(Name='Test Account 1'+Datetime.now());
        Insert acc;
        
        List<Contact> staffContacts = new List<Contact>{
            new Contact(AccountId=acc.Id,LastName='Testing', RecordTypeId = staffRTId)            
        };
        insert staffContacts;
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :projList LIMIT 1];
                
        Test.startTest();
            
            List<AcctSeed__Cost_Rates__c>  costRates = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
            insert costRates;
        
            List<Contact_Assignments__c> instructors = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Rate_Card_Rate__c = costRates[0].Id, Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = instructorRTId),
                new Contact_Assignments__c(Rate_Card_Rate__c = costRates[0].Id, Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = instructorRTId)
            };
            insert instructors;
            
            List<Contact_Assignments__c> Supervisor = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = supervisorRTId)
            };
            insert Supervisor;
        Test.stopTest();
    }
    
    public static testMethod void shareCRMethod3(){
    
        Id staffRTId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        Id supervisorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        Id instructorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        List<OpportunityLineItem> opliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        Account acc = new Account(Name='Test Account 1'+Datetime.now());
        Insert acc;
        
        List<Contact> staffContacts = new List<Contact>{
            new Contact(AccountId=acc.Id,LastName='Testing', RecordTypeId = staffRTId)            
        };
        insert staffContacts;
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :projList LIMIT 1];
                
        Test.startTest();
            
            List<AcctSeed__Cost_Rates__c>  costRates = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
            insert costRates;
        
            List<Contact_Assignments__c> Supervisor = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = supervisorRTId)
            };
            insert Supervisor;
            
            List<Contact_Assignments__c> instructors = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Drafted_Labor_Cost_Rate__c = costRates[0].Id, Status__c = 'Active', Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = instructorRTId),
                new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Drafted_Labor_Cost_Rate__c = costRates[0].Id, Status__c = 'Active', Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = instructorRTId)
            };
            insert instructors;
        Test.stopTest();
    }
    
    public static testMethod void shareCRMethod4(){
    
        Id staffRTId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        Id supervisorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        Id instructorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        List<OpportunityLineItem> opliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        Account acc = new Account(Name='Test Account 1'+Datetime.now());
        Insert acc;
        
        List<Contact> staffContacts = new List<Contact>{
            new Contact(AccountId=acc.Id,LastName='Testing', RecordTypeId = staffRTId)            
        };
        insert staffContacts;
       
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :projList LIMIT 1];
                
        Test.startTest();
            
            List<AcctSeed__Cost_Rates__c>  costRates = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
            insert costRates;
        
            List<Contact_Assignments__c> instructors = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Rate_Card_Rate__c = costRates[0].Id, Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = instructorRTId),
                new Contact_Assignments__c(Rate_Card_Rate__c = costRates[0].Id, Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = instructorRTId)
            };
            insert instructors;
            
            List<Contact_Assignments__c> Supervisor = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Status__c = 'Active', Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = supervisorRTId)
            };
            insert Supervisor;
        Test.stopTest();
    }
    
    public static testMethod void shareCRMethod5(){
    
        Id staffRTId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        Id supervisorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        Id instructorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        List<OpportunityLineItem> opliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        Account acc = new Account(Name='Test Account 1'+Datetime.now());
        Insert acc;
        
        List<Contact> staffContacts = new List<Contact>{
            new Contact(AccountId=acc.Id,LastName='Testing', RecordTypeId = staffRTId)            
        };
        insert staffContacts;
       
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :projList LIMIT 1];
                
        Test.startTest();
            List<AcctSeed__Cost_Rates__c>  costRates = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
            insert costRates;
        
            List<Contact_Assignments__c> Supervisor = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Status__c = 'Active', Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = supervisorRTId)
            };
            insert Supervisor;
            
            List<Contact_Assignments__c> instructors = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Drafted_Labor_Cost_Rate__c = costRates[0].Id, Status__c = 'Active', Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = instructorRTId),
                new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Drafted_Labor_Cost_Rate__c = costRates[0].Id, Status__c = 'Active', Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = instructorRTId)
            };
            insert instructors;
        Test.stopTest();
    }
    
    public static testMethod void shareCRMethod6(){
    
        Id staffRTId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        Id supervisorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        Id instructorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        List<OpportunityLineItem> opliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        Account acc = new Account(Name='Test Account 1'+Datetime.now());
        Insert acc;
        
        List<Contact> staffContacts = new List<Contact>{
            new Contact(AccountId=acc.Id,LastName='Testing', RecordTypeId = staffRTId)            
        };
        insert staffContacts;
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :projList LIMIT 1];
                
        Test.startTest();
            
            List<AcctSeed__Cost_Rates__c>  costRates = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Draft', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Draft', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
            insert costRates;
        
            List<Contact_Assignments__c> instructors = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Drafted_Labor_Cost_Rate__c = costRates[0].Id, Status__c = 'Active', Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = instructorRTId),
                new Contact_Assignments__c(Drafted_Labor_Cost_Rate__c = costRates[0].Id, Status__c = 'Active', Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = instructorRTId)
            };
            insert instructors;
            
            List<Contact_Assignments__c> Supervisor = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Status__c = 'Active', Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = supervisorRTId)
            };
            insert Supervisor;
        Test.stopTest();
    }
    
    // Added By HL
    // To revoke the sharing of Cost Rate records
    public static testMethod void revokeCRMethod1(){
    
        Id staffRTId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        Id supervisorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        Id instructorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        List<OpportunityLineItem> opliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        Account acc = new Account(Name='Test Account 1'+Datetime.now());
        Insert acc;
        
        List<Contact> staffContacts = new List<Contact>{
            new Contact(AccountId=acc.Id,LastName='Testing', RecordTypeId = staffRTId)            
        };
        insert staffContacts;
      
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :projList LIMIT 1];
        
        Test.startTest();
            List<AcctSeed__Cost_Rates__c>  costRates = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
            insert costRates;
                
            List<Contact_Assignments__c> Supervisor = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = supervisorRTId)
            };
            insert Supervisor;
            
            List<Contact_Assignments__c> instructors = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Rate_Card_Rate__c = costRates[0].Id, Status__c = 'Active', Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today()-1, End_Date__c = System.today(), RecordTypeId = instructorRTId),
                new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Rate_Card_Rate__c = costRates[0].Id, Status__c = 'Active', Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today()-1, End_Date__c = System.today(), RecordTypeId = instructorRTId)
            };
            insert instructors;
            
            List<Contact_Assignments__c> toUpdateCAs = [SELECT Id, Status__c FROM Contact_Assignments__c WHERE Id IN : instructors];
            toUpdateCAs[0].Status__c = 'Ended';
            update toUpdateCAs;
        Test.stopTest();
    }
    
    public static testMethod void revokeCRMethod2(){
    
        Id staffRTId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        Id supervisorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        Id instructorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        List<OpportunityLineItem> opliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        Account acc = new Account(Name='Test Account 1'+Datetime.now());
        Insert acc;
        
        List<Contact> staffContacts = new List<Contact>{
            new Contact(AccountId = acc.Id,LastName = 'Testing', RecordTypeId = staffRTId)            
        };
        insert staffContacts;
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :projList LIMIT 1];
        
        Test.startTest();
            List<AcctSeed__Cost_Rates__c>  costRates = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
            insert costRates;
                
            List<Contact_Assignments__c> Supervisor = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = supervisorRTId)
            };
            insert Supervisor;
            
            List<Contact_Assignments__c> instructors = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Drafted_Labor_Cost_Rate__c = costRates[0].Id, Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today()-1, End_Date__c = System.today(), RecordTypeId = instructorRTId),
                new Contact_Assignments__c(Drafted_Labor_Cost_Rate__c = costRates[0].Id, Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today()-1, End_Date__c = System.today(), RecordTypeId = instructorRTId)
            };
            insert instructors;
            
            List<Contact_Assignments__c> toUpdateCAs = [SELECT Id, Status__c FROM Contact_Assignments__c WHERE Id IN : instructors];
            toUpdateCAs[0].Status__c = 'Ended';
            update toUpdateCAs;
        Test.stopTest();
    }
    
    public static testMethod void revokeCRMethod3(){
    
        Id staffRTId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        Id supervisorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        Id instructorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        List<OpportunityLineItem> opliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        Account acc = new Account(Name='Test Account 1'+Datetime.now());
        Insert acc;
        
        List<Contact> staffContacts = new List<Contact>{
            new Contact(AccountId=acc.Id,LastName='Testing', RecordTypeId = staffRTId)            
        };
        insert staffContacts;
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :projList LIMIT 1];
        
        Test.startTest();
            List<AcctSeed__Cost_Rates__c>  costRates = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
            insert costRates;
        
            List<Contact_Assignments__c> instructors = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Drafted_Labor_Cost_Rate__c = costRates[0].Id, Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today()-1, End_Date__c = System.today(), RecordTypeId = instructorRTId),
                new Contact_Assignments__c(Drafted_Labor_Cost_Rate__c = costRates[0].Id, Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today()-1, End_Date__c = System.today(), RecordTypeId = instructorRTId)
            };
            insert instructors;
            
            List<Contact_Assignments__c> Supervisor = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Status__c = 'Active', Project__c = projList[0].Id, Project_Task__c = projTask[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today()-1, End_Date__c = System.today(), RecordTypeId = supervisorRTId)
            };
            insert Supervisor;
            
            List<Contact_Assignments__c> toUpdateCAs = [SELECT Id, Status__c FROM Contact_Assignments__c WHERE Id IN : Supervisor];
            toUpdateCAs[0].Status__c = 'Ended';
            update toUpdateCAs;
        Test.stopTest();
    }
    
    public static testMethod void revokeCRMethod4(){
    
        Id staffRTId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        Id supervisorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        Id instructorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        List<OpportunityLineItem> opliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        Account acc = new Account(Name='Test Account 1'+Datetime.now());
        Insert acc;
        
        List<Contact> staffContacts = new List<Contact>{
            new Contact(AccountId=acc.Id,LastName='Testing', RecordTypeId = staffRTId)            
        };
        insert staffContacts;
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :projList LIMIT 1];
                
        Test.startTest();
            List<AcctSeed__Cost_Rates__c>  costRates = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
            insert costRates;
            
            List<Contact_Assignments__c> instructors = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Rate_Card_Rate__c = costRates[0].Id, Status__c = 'Active', Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today()-1, End_Date__c = System.today(), RecordTypeId = instructorRTId),
                new Contact_Assignments__c(Rate_Card_Rate__c = costRates[0].Id, Status__c = 'Active', Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today()-1, End_Date__c = System.today(), RecordTypeId = instructorRTId)
            };
            insert instructors;
            
            List<Contact_Assignments__c> Supervisor = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Opportunity_Name__c = projList[0].AcctSeed__Opportunity__c, Opportunity_Product_Id__c = opliList[0].Id, Status__c = 'Active', Candidate_Name__c = staffContacts[0].Id,Start_Date__c = system.today()-1, End_Date__c = System.today(), RecordTypeId = supervisorRTId)
            };
            insert Supervisor;
            
            List<Contact_Assignments__c> toUpdateCAs = [SELECT Id, Status__c FROM Contact_Assignments__c WHERE Id IN : Supervisor];
            toUpdateCAs[0].Status__c = 'Ended';
            update toUpdateCAs;
        Test.stopTest();
    }
    
    // To populate Time_Approval_Preference__c field in CA 
    private static testMethod void populateTAP1(){
    
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact> contacts = [SELECT Id, Time_Approval_Preference__c FROM Contact LIMIT 1];
        contacts[0].Time_Approval_Preference__c = 'Daily';
        update contacts[0];
        
        List<AcctSeed__Project__c> projList = [SELECT Id, No_Student_Approval__c FROM AcctSeed__Project__c LIMIT 1];
        projList[0].No_Student_Approval__c = FALSE;
        update projList[0];
        
        Test.startTest();
        
            List<Contact_Assignments__c> stdCAs = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = projList[0].Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = stdRTId),
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = projList[0].Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = stdRTId)
            };
            insert stdCAs;
            
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE Id IN : stdCAs];
            System.assertEquals('Daily', conAssigns[0].Time_Approval_Preference__c);
        Test.stopTest();
    }
    
    // To populate Time_Approval_Preference__c field in CA 
    private static testMethod void populateTAP2(){
    
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact> contacts = [SELECT Id, Time_Approval_Preference__c FROM Contact LIMIT 1];
        contacts[0].Time_Approval_Preference__c = 'Weekly';
        update contacts[0];
        
        List<AcctSeed__Project__c> projList = [SELECT Id, No_Student_Approval__c FROM AcctSeed__Project__c LIMIT 1];
        projList[0].No_Student_Approval__c = TRUE;
        update projList[0];
        
        Test.startTest();
        
            List<Contact_Assignments__c> stdCAs = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = projList[0].Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = stdRTId),
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = projList[0].Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = stdRTId)
            };
            insert stdCAs;
            
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE Id IN : stdCAs];
            System.assertEquals('No Approval', conAssigns[0].Time_Approval_Preference__c);
        Test.stopTest();
    }
    
    // To cover CancelAReport method in ContactAssignmentTriggerHandler
    private static testMethod void myTest1(){
    
        Date reportDate = Date.Today()+7;
        
        List<Contact> conList = [SELECT Id, RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName IN ('Candidate', 'Student')];
        
        Id stdId;
        Id insId;
        
        for(Contact c : conList){
        
            if(c.RecordType.DeveloperName == 'Candidate'){
                insId = c.Id;
            }else if(c.RecordType.DeveloperName == 'Student'){
                stdId = c.Id;
            }
        }
        
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 2'];
        
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
        
        //Report_Date__c = Date.Today().addDays(1),
        //Report_Date__c = Date.Today().addDays(2),
        
        List<Assessment_Report__c> reports = new List<Assessment_Report__c>{
            new Assessment_Report__c(Name = 'My Test Report1', Project__c=projList[0].Id, Instructor__c = insId, Status__c = 'Scheduled',Language__c = 'Tamil',Student__c = stdId,Training_officer__c = conList[1].Id,Sponser__c = accList[0].Id, Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
            //new Assessment_Report__c(Name = 'My Test Report2', Project__c=projList[0].Id, Instructor__c = insId, Status__c = 'Scheduled',Language__c = 'English',Student__c = stdId,Training_officer__c = conList[1].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+20)
        };
        insert reports;
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Status__c, Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__c = : projList[0].Id LIMIT 1];
            conAss[0].Status__c = 'Canceled';
            conAss[0].Candidate_Name__c = stdId;
            update conAss[0];
            
            List<Assessment_Report__c> arRecs = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Id IN : reports];
            //System.assertEquals('Canceled', arRecs[0].Status__c);
        Test.stopTest();
    }
    
    // To cover CancelAReport method in ContactAssignmentTriggerHandler (Bulk Updation)
    private static testMethod void myTest1a(){
    
        Date reportDate = Date.Today()+7;
        
        List<Contact> conList = [SELECT Id, RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName IN ('Candidate', 'Student')];
        
        Id stdId;
        Id insId;
        
        for(Contact c : conList){
        
            if(c.RecordType.DeveloperName == 'Candidate'){
                insId = c.Id;
            }else if(c.RecordType.DeveloperName == 'Student'){
                stdId = c.Id;
            }
        }
        
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 2'];
        
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
        
        //Report_Date__c = Date.Today().addDays(1), 
        //Report_Date__c = Date.Today().addDays(2), 
        
        List<Assessment_Report__c> reports = new List<Assessment_Report__c>{
            new Assessment_Report__c(Name = 'My Test Report1', Project__c=projList[0].Id, Instructor__c = insId, Status__c = 'Scheduled',Language__c = 'Tamil',Student__c = stdId,Training_officer__c = conList[1].Id,Sponser__c = accList[0].Id, Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
            //new Assessment_Report__c(Name = 'My Test Report2', Project__c=projList[0].Id, Instructor__c = insId, Status__c = 'Scheduled',Language__c = 'English',Student__c = stdId,Training_officer__c = conList[1].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+20)
        };
        insert reports;
        
        Test.startTest();
            
            List<Contact_Assignments__c> updateConAssigns = new List<Contact_Assignments__c>();
            
            for(Contact_Assignments__c conAss : [SELECT Id, Status__c, Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Project__c = : projList[0].Id]){
            
                conAss.Status__c = 'Canceled';
                conAss.Candidate_Name__c = stdId;
                updateConAssigns.add(conAss);
            }
            
            if(updateConAssigns != NULL && updateConAssigns.size() > 0){
                
                update updateConAssigns;
                
                List<Assessment_Report__c> arRecs = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Id IN : reports];
                //System.assertEquals('Canceled', arRecs[1].Status__c);
            }
        Test.stopTest();
    }
    
    // To cover createAReport method in ContactAssignmentTriggerHandler
    private static testMethod void myTest2(){
    
        Date reportDate = Date.Today()+7;
        
        List<Contact> conList = [SELECT Id, RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName IN ('Candidate', 'Student')];
        
        Id stdId;
        Id insId;
        
        for(Contact c : conList){
        
            if(c.RecordType.DeveloperName == 'Candidate'){
                insId = c.Id;
            }else if(c.RecordType.DeveloperName == 'Student'){
                stdId = c.Id;
            }
        }
        
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 2'];
        
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 2];        
        projList[0].AcctSeed__Account__c = acc[0].Id;
        update projList[0];
        
        //Report_Date__c = Date.Today().addDays(1),
        Assessment_Report__c arRec = new Assessment_Report__c(Name = 'My Test Report1', Project__c = projList[0].Id, Instructor__c = insId, Status__c = 'Scheduled',Language__c = 'Tamil',Student__c = stdId,Training_officer__c = conList[1].Id,Sponser__c = accList[0].Id, Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10);
        insert arRec;
        
        Test.startTest();
            
            Id studRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            Contact_Assignments__c stdCA = new Contact_Assignments__c(RecordTypeId = studRTId, Status__c = 'Active', Project__c = projList[0].Id, Candidate_Name__c = stdId,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10));
            insert stdCA;
            
            List<Assessment_Report__c> arRecs = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Project__c = :projList[0].Id AND Student__c = :stdId];
            
            Boolean temp = (arRecs != NULL && arRecs.size() > 0) ? TRUE : FALSE;
            System.assertEquals(TRUE, temp);
            
        Test.stopTest();
    }
    
    // To cover createAReport method in ContactAssignmentTriggerHandler (Bulk Insertion)
    private static testMethod void myTest2a(){
    
        Date reportDate = Date.Today()+7;
        
        List<Contact> conList = [SELECT Id, RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName IN ('Candidate', 'Student')];
        
        Id stdId;
        Id insId;
        
        for(Contact c : conList){
        
            if(c.RecordType.DeveloperName == 'Candidate'){
                insId = c.Id;
            }else if(c.RecordType.DeveloperName == 'Student'){
                stdId = c.Id;
            }
        }
        
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 2'];
        
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 2];        
        projList[0].AcctSeed__Account__c = acc[0].Id;
        update projList[0];
        
        //Report_Date__c = Date.Today().addDays(1), 
        Assessment_Report__c arRec = new Assessment_Report__c(Name = 'My Test Report1', Project__c = projList[0].Id, Instructor__c = insId, Status__c = 'Scheduled',Language__c = 'Tamil',Student__c = stdId,Training_officer__c = conList[1].Id,Sponser__c = accList[0].Id, Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10);
        insert arRec;
        
        Test.startTest();
            
            Id studRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> stdCA = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = studRTId, Status__c = 'Active', Project__c = projList[0].Id, Candidate_Name__c = stdId,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10)),
                new Contact_Assignments__c(RecordTypeId = studRTId, Status__c = 'Active', Project__c = projList[0].Id, Candidate_Name__c = stdId,Start_Date__c = system.today().addDays(5), End_Date__c = System.today().addDays(20))
            };
            insert stdCA;
            
            List<Assessment_Report__c> arRecs = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Project__c = :projList[0].Id AND Student__c = :stdId];
            
            Boolean temp = (arRecs != NULL && arRecs.size() > 0) ? TRUE : FALSE;
            System.assertEquals(TRUE, temp);
            
        Test.stopTest();
    }
    
    // To cover createAReport method in ContactAssignmentTriggerHandler : No existing AR records
    private static testMethod void myTest2b(){
    
        Date reportDate = Date.Today()+7;
        
        List<Contact> conList = [SELECT Id, RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName IN ('Candidate', 'Student')];
        
        Id stdId;
        Id insId;
        
        for(Contact c : conList){
        
            if(c.RecordType.DeveloperName == 'Candidate'){
                insId = c.Id;
            }else if(c.RecordType.DeveloperName == 'Student'){
                stdId = c.Id;
            }
        }
        
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 2'];
        
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 2];        
        projList[0].AcctSeed__Account__c = acc[0].Id;
        update projList[0];
        
        Test.startTest();
            
            Id studRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            
            List<Contact_Assignments__c> stdCA = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = studRTId, Status__c = 'Active', Project__c = projList[0].Id, Candidate_Name__c = stdId,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10)),
                new Contact_Assignments__c(RecordTypeId = studRTId, Status__c = 'Active', Project__c = projList[0].Id, Candidate_Name__c = stdId,Start_Date__c = system.today().addDays(5), End_Date__c = System.today().addDays(20))
            };
            insert stdCA;
            
            List<Assessment_Report__c> arRecs = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Project__c = :projList[0].Id AND Student__c = :stdId];
            
            Boolean temp = (arRecs != NULL && arRecs.size() > 0) ? TRUE : FALSE;
            System.assertEquals(FALSE, temp);
            
        Test.stopTest();
    }
    
    // To cover updateMoodleSyncStatus method in ContactAssignmentTriggerHandler
    private static testMethod void myTest3(){
    
        List<Contact_Assignments__c> conAss = [SELECT Id, Moodle_Sync_Status__c, Start_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        conAss[0].Moodle_Sync_Status__c = 'Completed';
        conAss[0].Start_Date__c = System.today().addDays(2);
        update conAss[0];
    }
    
    private static testMethod void myTest4(){
            
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName = 'DLS_Employee' LIMIT 1];
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];        
        
        Id staffRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
            
        List<Contact_Assignments__c> staffCA = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = staffRTId, Assignment_Position__c = 'Project Support', Status__c = 'Active', Project__c = projList[0].Id, Candidate_Name__c = conList[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10))
        };
        Test.startTest();
        insert staffCA;
        Test.stopTest();
    }
    
    //To update the L/S/R Goal Score Applicable fields when we have values in Score Final and uncheck it when it is null
    private static testMethod void myTest5(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id, L_Score_Final__c, L_Goal_Score_Applicable__c FROM Contact_Assignments__c LIMIT 1];
        conAssigns[0].L_Score_Final__c = '3+';
        conAssigns[0].L_Goal_Score_Applicable__c = FALSE;
        update conAssigns[0];   
        
        Test.startTest();
            List<Contact_Assignments__c> conAssigns1 = [SELECT Id, L_Score_Final__c, L_Goal_Score_Applicable__c FROM Contact_Assignments__c WHERE Id = :conAssigns[0].Id];
            conAssigns1[0].L_Score_Final__c = null;
            conAssigns1[0].L_Goal_Score_Applicable__c = TRUE;
            update conAssigns1[0]; 
            
            List<Contact_Assignments__c> conAssigns2 = [SELECT Id, L_Score_Final__c, L_Goal_Score_Applicable__c FROM Contact_Assignments__c WHERE Id = :conAssigns1[0].Id];
            System.assertEquals(FALSE, conAssigns2[0].L_Goal_Score_Applicable__c);
        Test.stopTest();            
    }
    
    private static testMethod void myTest6(){
    
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 2];        
            
        List<Contact> conList = [SELECT Id, RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName = 'Student'];
        
        Id studRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        Test.startTest();   
            List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(R_Score_Final__c = '2+', R_Goal_Score_Applicable__c = false, RecordTypeId = studRTId, Status__c = 'Active', Project__c = projList[0].Id, Candidate_Name__c = conList[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10)),
                new Contact_Assignments__c(R_Goal_Score_Applicable__c = true, RecordTypeId = studRTId, Status__c = 'Active', Project__c = projList[0].Id, Candidate_Name__c = conList[0].Id,Start_Date__c = system.today().addDays(5), End_Date__c = System.today().addDays(20)),
                new Contact_Assignments__c(S_Goal_Score_Applicable__c = true, RecordTypeId = insRTId, Status__c = 'Active', Project__c = projList[0].Id, Candidate_Name__c = conList[0].Id,Start_Date__c = system.today(), End_Date__c = System.today().addDays(10)),
                new Contact_Assignments__c(S_Score_Final__c = '4+', S_Goal_Score_Applicable__c = false, RecordTypeId = insRTId, Status__c = 'Active', Project__c = projList[0].Id, Candidate_Name__c = conList[0].Id,Start_Date__c = system.today().addDays(5), End_Date__c = System.today().addDays(20))
            };
            insert conAssigns;
            
            List<Contact_Assignments__c> conAssigns1 = [SELECT Id, R_Goal_Score_Applicable__c FROM Contact_Assignments__c WHERE Id IN : conAssigns];
            System.assertEquals(TRUE, conAssigns1[0].R_Goal_Score_Applicable__c);
        Test.stopTest();
    }
    
    private static testMethod void myTest7(){
    
        Id testProjId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project 01',AcctSeed__Status__c = 'Order', Oral_Exam_Date_Time__c = System.today().addDays(10), Project_Manager__c = NULL, RecordTypeId = testProjId);
        insert proj;
        
        List<Contact> conList = [SELECT Id, RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName = 'Candidate' LIMIT 1];
        
        Test.startTest();
        
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
                
            List<Contact_Assignments__c> stdCA = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = insRTId, Status__c = 'Active', Project__c = proj.Id, Candidate_Name__c = conList[0].Id,Start_Date__c = system.today().addDays(5), End_Date__c = System.today().addDays(20), Oral_Exam_Date_Time__c = system.today().addDays(7))
            };
            insert stdCA;
                
            try{
            
                stdCA[0].Oral_Exam_Date_Time__c = System.Today().addDays(8);
                update stdCA[0];
                
            }catch(Exception e){
            
                Boolean isError = e.getMessage().contains('You can\'t edit this field, please update related event if you want to update the Oral Exam Date & Time') ? true : false;
                System.assertEquals(isError, True); 
            }
        Test.stopTest();
    }
    
    // To cover employeeRehiringNotification() method
    private static testMethod void myTest8(){
        
        Date year_back = Date.Today().addDays(-365);
        System.debug('::::::year_back:::::'+year_back);
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 2];        
        
        List<Contact> conList = [SELECT Id, Last_Time_Entered_Date__c, Instructor_Status__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate' LIMIT 1];
        conList[0].Last_Time_Entered_Date__c = year_back;
        conList[0].Instructor_Status__c = 'Available';
        update conList[0];
        
        Test.startTest();
        
            List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Employee Rehiring Email Ids', Value__c = 'hemalatha@softsquare.biz')};
            insert sysVal;
            
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
                
            List<Contact_Assignments__c> stdCA = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = insRTId, Status__c = 'Active', Project__c = projList[0].Id, Candidate_Name__c = conList[0].Id,Start_Date__c = system.today().addDays(5), End_Date__c = System.today().addDays(20))
            };
            insert stdCA;
        Test.stopTest();
    }
    
    private static testMethod void updateLanguageTestingRecs_Test(){
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            
        List<Language_Testing__c> langtestList = new List<Language_Testing__c> {
            new Language_Testing__c(Name='Test Lang1', Contact_Assignment__c = conAssigns[0].Id, Test_Type__c='Initial', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, Date_Time_Scheduled__c = System.now().addDays(5),Target_Language__c = 'Tamil'),
            new Language_Testing__c(Name='Test Lang2', Contact_Assignment__c = conAssigns[0].Id, Test_Type__c='Final', Project__c = conAssigns[0].Project__c, Testee__c = conAssigns[0].Candidate_Name__c, Date_Time_Scheduled__c = System.now().addDays(10),Target_Language__c = 'Russian')
        };
        insert langtestList;  
        
        Test.startTest();
                    
            List<Contact_Assignments__c> conAssignRec = [SELECT Id, L_Score_Final__c, R_Score_Final__c, S_Score_Final__c, W_Score_Goal__c FROM Contact_Assignments__c WHERE Id IN : conAssigns];
            conAssignRec[0].L_Score_Final__c = '4+';
            conAssignRec[0].R_Score_Final__c = '5';
            conAssignRec[0].S_Score_Final__c = '4';
            conAssignRec[0].W_Score_Goal__c = '5';
            update conAssignRec[0];
            
            List<Language_Testing__c> ltRecs = [SELECT Id, L_Goal__c, R_Goal__c, S_Goal__c, W_Goal__c FROM Language_Testing__c WHERE Contact_Assignment__c = :conAssignRec[0].Id];
            System.assertEquals('4+', ltRecs[0].L_Goal__c);
            
        Test.stopTest();
    }
    
    private static testMethod void SendEmail_CancelOrientation_NewHire_Test(){
        
        Contact newCon = new Contact(LastName = 'Test NewHire Con', Email = 'newhire@gmail.com');
        insert newCon;
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> insCA = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Status__c = 'Active', Project__c = projList[0].Id, Candidate_Name__c = newCon.Id,Start_Date__c = system.today().addDays(5), End_Date__c = System.today().addDays(90))
        };
        insert insCA;
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAssignRec = [SELECT Id, Status__c FROM Contact_Assignments__c WHERE Id = :insCA[0].Id];
            conAssignRec[0].Status__c = 'On Hold';
            update conAssignRec[0];
            
        Test.stopTest();
    }
    
    private static testMethod void sendInstructorGetFeedbackEmail_Test(){
       
        Id testingProjRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName != 'Testing_Projects' LIMIT 1];
       
        List<Contact_Assignments__c> caRec = [SELECT Id, Status__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' LIMIT 1];
        caRec[0].Assignment_Position__c = 'Instructor';
        caRec[0].Status__c = 'Active';
        caRec[0].Project__c = projList[0].Id;
        update caRec[0];
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAssignRec = [SELECT Id, Status__c FROM Contact_Assignments__c WHERE Id = :caRec[0].Id];
            conAssignRec[0].Status__c = 'Ended';
            conAssignRec[0].End_Date__c = Date.Today();
            update conAssignRec[0];
            
        Test.stopTest();
    }
    
    private static testMethod void updateTextFields_Test(){

        List<Contact_Assignments__c> caRec = [SELECT Id, Status__c FROM Contact_Assignments__c WHERE Status__c = 'Active' LIMIT 1];
        
        Test.startTest();
           
            delete caRec[0];
            
        Test.stopTest();
    }
}