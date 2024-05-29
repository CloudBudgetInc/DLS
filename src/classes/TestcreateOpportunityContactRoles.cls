@isTest
public class TestcreateOpportunityContactRoles {
   
    @testSetup static void setup(){
    
        //List<Opportunity> oppList = TestClassUtil.createTestOpportunities();
        List<AcctSeed__Project__c> projectRecs = TestClassUtil.createTestProject();
        List<Contact> contacts = TestClassUtil.createTestContacts();
        List<System_Values__c> sysVal = new List<System_Values__c>{
            new System_Values__c(Name =  'Paper Timesheet Value',Value__c = 'TRUE')
        };
        Insert sysVal;
    }
    
    // For Enrollment_Date__c updation
    public static testMethod void testMethod1() {
       
        List<Opportunity> oppList = [SELECT Id, Name, StageName, Enrollment_Date__c, End_Date__c FROM Opportunity WHERE StageName != 'Active' LIMIT 2];
        
        if(oppList != null && oppList.size() > 0){
            for(Opportunity opp : oppList) {
                opp.StageName = 'Active';
            }
            update oppList;
        }
        
        List<Opportunity> oppRecs = [SELECT Id, Name,Enrollment_Date__c FROM Opportunity WHERE StageName = 'Active' ORDER BY LastModifiedDate DESC LIMIT 1];  
        if(oppRecs != null && oppRecs.size() > 0)
            System.assertEquals(system.today(), oppRecs[0].Enrollment_Date__c);
    }
    
    // For AccountId updation when the opportunity Recordtype is 'Admin_Opportunities' 
    public static testMethod void testMethod2() {
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
       
        if(accList != null && accList.size() > 0) {
            System_Values__c sysVal = new System_Values__c(Name =  'DLS Account',Value__c = accList[0].Id);
            insert sysVal;
          
            List<RecordType> rt = [SELECT Id, Name From RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Admin_Opportunities' LIMIT 1];
            
            List<Opportunity> oppList = new List<Opportunity> {
                                            new Opportunity(Name = 'Test Opp 1',StageName = 'Inquiry',CloseDate = System.Today(),AccountId = accList[0].Id,RecordTypeId = (rt != null && rt.size() > 0) ?rt[0].Id : null),
                                            new Opportunity(Name = 'Test Opp 2',StageName = 'Inquiry',CloseDate = System.Today(),AccountId = accList[0].Id,RecordTypeId = (rt != null && rt.size() > 0) ?rt[0].Id : null)
                                        };
            insert oppList;
            
            System.assertEquals(sysVal.Value__c, oppList[0].AccountId);
        }
    }
    
    // For Institutional_Results_in_Target_Language__c and Relevant_training_in_the_Target_Language__c updation in Contact
    public static testMethod void testMethod3() {
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        List<Language__c> lang = new List<Language__c> {
                                    new Language__c(Name = 'Albanian'),
                                    new Language__c(Name = 'English')
                                };
        insert lang;
        
        List<Overall_Past_Performance__c> overAllPer = new List<Overall_Past_Performance__c> {
                                                           new Overall_Past_Performance__c(Name = 'overAllPer 1', Results_Institutional__c = 'Test1', Target_Language__c = lang[0].Id),
                                                           new Overall_Past_Performance__c(Name = 'overAllPer 2', Results_Institutional__c = 'Test2', Target_Language__c = lang[1].Id)
                                                       };
        insert overAllPer;
        
        if(accList != null && accList.size() > 0 && lang != null && lang.size() > 0 && overAllPer != null && overAllPer.size() > 0) {
          
            List<RecordType> rt = [SELECT Id, Name From RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'New_Classes_Opportunities' LIMIT 1];
            List<Opportunity> opp = new List<Opportunity> {
                                        new Opportunity(Name = 'Test Opp 1',Language__c = 'Albanian',StageName = 'Inquiry',CloseDate = System.Today(),AccountId = accList[0].Id,RecordTypeId = (rt != null && rt.size() > 0) ?rt[0].Id : null),
                                        new Opportunity(Name = 'Test Opp 1',Language__c = 'English',StageName = 'Inquiry',CloseDate = System.Today(),AccountId = accList[0].Id,RecordTypeId = (rt != null && rt.size() > 0) ?rt[0].Id : null)
                                    };
            insert opp;
            
            List<Opportunity> oppList = [SELECT Id, Name, Institutional_Results_in_Target_Language__c FROM Opportunity WHERE Id = :opp[0].Id];
            if(oppList != null && oppList.size() > 0) {
                System.assertEquals(overAllPer[0].Results_Institutional__c, oppList[0].Institutional_Results_in_Target_Language__c);
            }
        }
        
    } 
    
    // For Contact Role Creation
    public static testMethod void testMethod4() {
        
        List<System_Values__c> sysVal = [SELECT Id, Value__c FROM System_Values__c WHERE Name = 'Paper Timesheet Value'];
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 2];
        if(accList != null && accList.size() > 0) {
            List<Contact> con = new List<Contact> {
                                    new Contact(LastName = 'Contact 1', AccountId = accList[0].Id,Email = 'test1@gmail.com'),
                                    new Contact(LastName = 'Contact 2', AccountId = accList[0].Id,Email = 'test2@gmail.com')
                                };
            insert con;
            
            List<RecordType> rt = [SELECT Id, Name From RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'New_Classes_Opportunities' LIMIT 1];
            if(con != null && con.size() > 0) {
                List<Opportunity> opp = new List<Opportunity> {
                                            new Opportunity(Name = 'Test Opp 1', Student_Name__c = con[0].Id, StageName = 'Inquiry',CloseDate = System.Today(),Start_Date__c = system.today(),AccountId = accList[0].Id,RecordTypeId = (rt != null && rt.size() > 0) ? rt[0].Id : null),
                                            new Opportunity(Name = 'Test Opp 12', InstructorName__c = con[1].Id, StageName = 'Inquiry',CloseDate = System.Today(),Start_Date__c = system.today(),AccountId = accList[0].Id,RecordTypeId = (rt != null && rt.size() > 0) ? rt[0].Id : null)
                                        };
                insert opp;
                
                List<OpportunityContactRole> ocrList = [SELECT Id FROM OpportunityContactRole ORDER BY createdDate DESC LIMIT 2];
                System.assert(ocrList.size() > 0);
            }
        }
    } 
    
    // For Contact Assignment Creation based on contract Primary_POC__c
    /*public static testMethod void testMethod5() {
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 2];
        List<Opportunity> oppList = [SELECT Id, Name, ContractId, StageName, CloseDate, AccountId, RecordTypeId FROM Opportunity LIMIT 4];
        
        if(accList != null && accList.size() > 0) {
            
            List<Contact> con = new List<Contact> {
                                    new Contact(LastName = 'Contact 1', AccountId = accList[0].Id),
                                    new Contact(LastName = 'Contact 2', AccountId = accList[0].Id)
                                };
            insert con;
            
            List<RecordType> rtContract = [SELECT Id, Name From RecordType WHERE SObjectType = 'Contract' LIMIT 1];
            Set<Id> oppId = new Set<Id>();
            
            if(con != null && con.size() > 0) {
                List<Contract> contr = new List<Contract> {
                                           new Contract(RecordTypeId = (rtContract != null && rtContract.size() > 0) ? rtContract[0].Id : null,AccountId = accList[0].Id, Primary_POC__c = con[0].Id),
                                           new Contract(RecordTypeId = (rtContract != null && rtContract.size() > 0) ? rtContract[0].Id : null,AccountId = accList[0].Id, Primary_POC__c = con[1].Id)
                                       };
                insert contr;
                
                if(oppList != null && oppList.size() > 0) {
                    oppList[0].ContractId = contr[0].Id;
                    oppList[0].StageName = 'Response in-progress';
                    oppList[1].ContractId = contr[0].Id;
                    oppList[1].StageName = 'Submitted';
                    oppList[2].ContractId = contr[0].Id;
                    oppList[2].StageName = 'Awarded';
                    oppList[3].ContractId = contr[0].Id;
                    oppList[3].StageName = 'Canceled';
                    
                    oppId.add(oppList[0].Id);
                    oppId.add(oppList[1].Id);
                    oppId.add(oppList[2].Id);
                    oppId.add(oppList[3].Id);
                }
                update oppList;
            }
            
            List<Contact_Assignments__c> caList = [SELECT Id FROM Contact_Assignments__c WHERE Opportunity_Name__c IN :oppId];
            System.assert(caList.size() > 0);
        }
    }
    
    // For Contact Assignment Creation based on contract Billing_Contact__c
    public static testMethod void testMethod6() {
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 2];
        List<Opportunity> oppList = [SELECT Id, Name, ContractId, StageName, CloseDate, AccountId, RecordTypeId FROM Opportunity LIMIT 4];
        Set<Id> oppId = new Set<Id>();
        
        if(accList != null && accList.size() > 0) {
            
            List<Contact> con = new List<Contact> {
                                    new Contact(LastName = 'Contact 1', AccountId = accList[0].Id),
                                    new Contact(LastName = 'Contact 2', AccountId = accList[0].Id)
                                };
            insert con;
            
            List<RecordType> rtContract = [SELECT Id, Name From RecordType WHERE SObjectType = 'Contract' LIMIT 1];
            
            if(con != null && con.size() > 0) {
                
                List<Contract> contr = new List<Contract> {
                                           new Contract(RecordTypeId = (rtContract != null && rtContract.size() > 0) ? rtContract[0].Id : null,AccountId = accList[0].Id, Billing_Contact__c = con[0].Id),
                                           new Contract(RecordTypeId = (rtContract != null && rtContract.size() > 0) ? rtContract[0].Id : null,AccountId = accList[0].Id, Billing_Contact__c = con[1].Id)
                                       };
                insert contr;
               
                if(oppList != null && oppList.size() > 0) {
                    oppList[0].ContractId = contr[0].Id;
                    oppList[0].StageName = 'Response in-progress';
                    oppList[1].ContractId = contr[0].Id;
                    oppList[1].StageName = 'Submitted';
                    oppList[2].ContractId = contr[0].Id;
                    oppList[2].StageName = 'Awarded';
                    oppList[3].ContractId = contr[0].Id;
                    oppList[3].StageName = 'Canceled';
                    
                    oppId.add(oppList[0].Id);
                    oppId.add(oppList[1].Id);
                    oppId.add(oppList[2].Id);
                    oppId.add(oppList[3].Id);
                }
                update oppList;
            }
            List<Contact_Assignments__c> caList = [SELECT Id FROM Contact_Assignments__c WHERE Opportunity_Name__c IN :oppId];
            System.assert(caList.size() > 0);
        }
    } */
    
    // For Contact Assignment Creation based on opportunity Instructor/Student_Name__c/Agency_Contact__c/Supervisor__c
    public static testMethod void testMethod7() {
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 2];
        List<Opportunity> oppList = [SELECT Id, Name, InstructorName__c, Agency_Contact__c, Supervisor__c, Student_Name__c, StageName, CloseDate, AccountId, RecordTypeId FROM Opportunity LIMIT 4];
        Set<Id> oppId = new Set<Id>();
        
        if(accList != null && accList.size() > 0) {
            
            List<Contact> con = new List<Contact> {
                                    new Contact(LastName = 'Test Contact', AccountId = accList[0].Id),
                                    new Contact(LastName = 'Contact 2', AccountId = accList[0].Id)
                                };
            insert con;
            
            List<Profile> profileUser = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
            String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
            
            if(profileUser != null && profileUser.size() > 0 && con != null && con.size() > 0) {
                List<User> userList = new List<User>{        
                    new User(Alias = 'standt', Email = 'test@gmail.com',EmailEncodingKey = 'UTF-8', LastName = 'Test Contact', 
                    LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profileUser[0].Id, 
                    TimeZoneSidKey = 'America/Los_Angeles', UserName = un)
                };
                insert userList;
           
                if(oppList != null && oppList.size() > 0 && userList != null && userList.size() > 0) {
                    oppList[0].InstructorName__c = con[0].Id;
                    oppList[1].Student_Name__c = con[1].Id;
                    oppList[2].Agency_Contact__c = con[0].Id;
                    oppList[3].Supervisor__c = userList[0].Id;
                    
                    oppId.add(oppList[0].Id);
                    oppId.add(oppList[1].Id);
                    oppId.add(oppList[2].Id);
                    oppId.add(oppList[3].Id);
                }
                update oppList;
            }
            List<Contact_Assignments__c> caList = [SELECT Id FROM Contact_Assignments__c WHERE Opportunity_Name__c IN :oppId];
            System.assert(caList.size() > 0);
        }
    } 
    
    // For Cloning PlannedDayOff
    public static testMethod void testMethod8() {
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        if(accList != null && accList.size() > 0) {
            
            List<RecordType> rtPlanDaysOff = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Planned_Days_Off__c' AND DeveloperName = 'DLI_W_LT_Training_Holidays'];
            Id pdortId;
            
            if(rtPlanDaysOff != null && rtPlanDaysOff.size() > 0) {
                pdortId = rtPlanDaysOff[0].Id;
            }
            
            List<Planned_Days_Off__c> pdoList = new List<Planned_Days_Off__c> {
                                                    new Planned_Days_Off__c(Date__c=System.today().addDays(-1),Description__c='Test',Requested_Reschedule_Date__c=System.today().addDays(-1),RecordTypeId = pdortId),
                                                    new Planned_Days_Off__c(Date__c=System.today().addDays(-1),Description__c='Test',Requested_Reschedule_Date__c=System.today().addDays(-1),RecordTypeId = pdortId)
                                                };
            insert pdoList;
            
            System_Values__c sysVal = new System_Values__c(Name =  'DLS Account',Value__c = accList[0].Id);
            insert sysVal;
          
            List<RecordType> rt = [SELECT Id, Name From RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
            Id rtId;
            
            if(rt != null && rt.size() > 0) {
                rtId = rt[0].Id;
            }
            List<Opportunity> oppList = new List<Opportunity> {
                                        new Opportunity(Name = 'Test Opp 1',StageName = 'Inquiry', Project_Type__c = 'AFPAK', Start_Date__c = System.today().addDays(-10), End_Date__c = System.today().addDays(30), CloseDate = System.Today(),AccountId = accList[0].Id,RecordTypeId = rtId),
                                        new Opportunity(Name = 'Test Opp 2',StageName = 'Inquiry', Project_Type__c = 'Resident LT', Start_Date__c = System.today().addDays(-10), End_Date__c = System.today().addDays(30), CloseDate = System.Today(),AccountId = accList[0].Id,RecordTypeId = rtId)
                                    };
            insert oppList;
            
            List<Planned_Days_Off__c> planDayOffList = [SELECT Id FROM Planned_Days_Off__c WHERE RecordType.DeveloperName = 'Project_Planned_Days_Off'];
            System.assert(planDayOffList.size() > 0);
        }
    }
    
    public static testMethod void testMethod9() {
    
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
        Id testProjRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        
        Opportunity opp = new Opportunity(Name = 'Test Opp 1',StageName = 'Inquiry', Oral_Exam__c = System.Today().addDays(30), AccountId = accList[0].Id, RecordTypeId = testOppRTId, CloseDate = System.Today().addDays(20));
        insert opp;
        
        List<AcctSeed__Project__c> proj = [SELECT Id, AcctSeed__Opportunity__c, RecordTypeId FROM AcctSeed__Project__c LIMIT 1];
        proj[0].RecordTypeId = testProjRTId;
        proj[0].AcctSeed__Opportunity__c = opp.Id;
        update proj[0];
        
        try{
        
            opp.Oral_Exam__c = System.Today();
            update opp;
        }catch(Exception e){
        
            Boolean isError = e.getMessage().contains('You can\'t edit this field, please update related event if you want to update the Oral Exam Date & Time') ? true : false;
            System.assertEquals(isError, TRUE);
        }
    }
    
    public static testMethod void testMethod10() {
    
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
        
        List<Language__c> lang = new List<Language__c> {
            new Language__c(Name = 'Albanian'),
            new Language__c(Name = 'English')
        };
        insert lang;
        
        Test.startTest();
        
            Opportunity opp = new Opportunity(Name = 'My Test Opp 1', Language_LU__c = lang[0].Id, StageName = 'Inquiry', Oral_Exam__c = System.Today().addDays(30), AccountId = accList[0].Id, RecordTypeId = testOppRTId, CloseDate = System.Today().addDays(20));
            insert opp;
        
            List<Opportunity> oppRec = [SELECT Id, Language__c FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals(oppRec[0].Language__c, 'Albanian');
            
        Test.stopTest();
    }
    
    public static testMethod void testMethod11() {
    
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
        
        List<Language__c> lang = new List<Language__c> {
            new Language__c(Name = 'Albanian'),
            new Language__c(Name = 'English')
        };
        insert lang;
        
        Test.startTest();
        
            Opportunity opp = new Opportunity(Name = 'My Test Opp 1', Language_LU__c = lang[0].Id, StageName = 'Inquiry', Oral_Exam__c = System.Today().addDays(30), AccountId = accList[0].Id, RecordTypeId = testOppRTId, CloseDate = System.Today().addDays(20));
            insert opp;
        
            List<Opportunity> oppRec = [SELECT Id, Language_LU__c FROM Opportunity WHERE Id = :opp.Id];
            oppRec[0].Language_LU__c = lang[1].Id;
            update oppRec[0];
            
            List<Opportunity> updatedOppRec = [SELECT Id, Language__c FROM Opportunity WHERE Id = :oppRec[0].Id];
            System.assertEquals(updatedOppRec[0].Language__c, 'English');
        Test.stopTest();
    }
    
    public static testMethod void oCRCReation_Test1(){
    
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        Id newClassRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Classes_Opportunities').getRecordTypeId();
        List<Contact> contacts = [SELECT Id, Name FROM Contact LIMIT 3];
                
        Opportunity opp = new Opportunity(Name = 'My Test Opp 1', Student_Name__c = contacts[0].Id, StageName = 'Inquiry', Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(90), AccountId = accList[0].Id, RecordTypeId = newClassRTId, CloseDate = System.Today().addDays(20));
        insert opp;
                
        List<OpportunityContactRole> ocr = [SELECT Id, OpportunityId FROM OpportunityContactRole WHERE OpportunityId = : opp.Id];
        System.assertEquals(1, ocr.size());
        
        Test.startTest();
        
            for (AsyncApexJob aJob : [SELECT Id ,Status, ApexClass.Name FROM AsyncApexJob WHERE Status!='Aborted' and Status!='Completed']){
                System.AbortJob(aJob.Id);
            }

            List<Opportunity> updateOpp = [SELECT Id, Student_Name__c FROM Opportunity WHERE Id = :opp.Id];
            updateOpp[0].Student_Name__c = contacts[1].Id;
            update updateOpp[0];
        
        Test.stopTest();
    }
    
    public static testMethod void oCRCReation_Test2() {
    
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        Id newClassRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Classes_Opportunities').getRecordTypeId();
        List<Contact> contacts = [SELECT Id, Name FROM Contact LIMIT 3];        
        
        Opportunity opp = new Opportunity(Name = 'My Test Opp 1', Contracting_Officer__c = contacts[0].Id, StageName = 'Inquiry', Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(90), AccountId = accList[0].Id, RecordTypeId = newClassRTId, CloseDate = System.Today().addDays(20));
        insert opp;        
        
        Test.startTest();
        
            List<Opportunity> updateOpp = [SELECT Id, Contracting_Officer__c FROM Opportunity WHERE Id = :opp.Id];
            updateOpp[0].Contracting_Officer__c = contacts[1].Id;
            update updateOpp[0];
            
        Test.stopTest();
    }
    
    public static testMethod void oCRCReation_Test3() {
    
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        Id newClassRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Classes_Opportunities').getRecordTypeId();
        List<Contact> contacts = [SELECT Id, Name FROM Contact LIMIT 3];        
        
        Opportunity opp = new Opportunity(Name = 'My Test Opp 1', Agency_Contact__c = contacts[0].Id, StageName = 'Inquiry', Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(90), AccountId = accList[0].Id, RecordTypeId = newClassRTId, CloseDate = System.Today().addDays(20));
        insert opp;
        
        List<Contact_Assignments__c> caInTestClass = [SELECT Id FROM Contact_Assignments__c WHERE Opportunity_Name__c = :opp.Id];
        
        List<OpportunityContactRole> ocr = [SELECT Id, OpportunityId FROM OpportunityContactRole WHERE OpportunityId = : opp.Id];
        System.assertEquals(1, ocr.size());
        
        Test.startTest();
        
            List<Opportunity> updateOpp = [SELECT Id, Agency_Contact__c FROM Opportunity WHERE Id = :opp.Id];
            updateOpp[0].Agency_Contact__c = contacts[1].Id;
            update updateOpp[0];
            
        Test.stopTest();
    }
    
    public static testMethod void oCRCReation_Test4() {
    
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        Id newClassRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Classes_Opportunities').getRecordTypeId();
        List<Contact> contacts = [SELECT Id, Name FROM Contact LIMIT 3];        
        
        Opportunity opp = new Opportunity(Name = 'My Test Opp 1', InstructorName__c = contacts[0].Id, StageName = 'Inquiry', Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(90), AccountId = accList[0].Id, RecordTypeId = newClassRTId, CloseDate = System.Today().addDays(20));
        insert opp;
        
        List<Contact_Assignments__c> caInTestClass = [SELECT Id FROM Contact_Assignments__c WHERE Opportunity_Name__c = :opp.Id];
        
        List<OpportunityContactRole> ocr = [SELECT Id, OpportunityId FROM OpportunityContactRole WHERE OpportunityId = : opp.Id];
        System.assertEquals(1, ocr.size());
        
        Test.startTest();
        
            List<Opportunity> updateOpp = [SELECT Id, InstructorName__c FROM Opportunity WHERE Id = :opp.Id];
            updateOpp[0].InstructorName__c = contacts[1].Id;
            update updateOpp[0];
            
        Test.stopTest();
    }
    
    public static testMethod void oCRCReation_Test5() {
    
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        Id newClassRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Classes_Opportunities').getRecordTypeId();
        List<Contact> contacts = [SELECT Id, Name FROM Contact LIMIT 3];        
        
        Opportunity opp = new Opportunity(Name = 'My Test Opp 1', EI_lookup__c = contacts[0].Id, StageName = 'Inquiry', Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(90), AccountId = accList[0].Id, RecordTypeId = newClassRTId, CloseDate = System.Today().addDays(20));
        insert opp;
        
        Test.startTest();
        
            List<Opportunity> updateOpp = [SELECT Id, EI_lookup__c FROM Opportunity WHERE Id = :opp.Id];
            updateOpp[0].EI_lookup__c = contacts[1].Id;
            update updateOpp[0];
            
        Test.stopTest();
    }
    
    public static testMethod void oCRCReation_Test6() {
    
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        Id newClassRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Classes_Opportunities').getRecordTypeId();
        List<Contact> contacts = [SELECT Id, Name FROM Contact LIMIT 3];        
        
        Opportunity opp = new Opportunity(Name = 'My Test Opp 1', X2nd_Instructor__c = contacts[0].Id, StageName = 'Inquiry', Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(90), AccountId = accList[0].Id, RecordTypeId = newClassRTId, CloseDate = System.Today().addDays(20));
        insert opp;
        
        Test.startTest();
        
            List<Opportunity> updateOpp = [SELECT Id, X2nd_Instructor__c FROM Opportunity WHERE Id = :opp.Id];
            updateOpp[0].X2nd_Instructor__c = contacts[1].Id;
            update updateOpp[0];
            
        Test.stopTest();
    }
    
    public static testMethod void oCRCReation_Test7() {
    
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        Id newClassRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Classes_Opportunities').getRecordTypeId();
        List<Contact> contacts = [SELECT Id, Name, FirstName, LastName FROM Contact WHERE RecordType.DeveloperName = 'DLS_Employee' LIMIT 1];        
        
        Id staffTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        
        Contact c = new Contact(FirstName = 'testStaffFN', LastName = 'testStaffLN', AccountId = accList[0].Id);
        insert c;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;
        List<User> userList = new List<User>();
        
        User user1 = new User(alias = 'test123', email='test123@noemail.com',
        emailencodingkey='UTF-8', firstname=contacts[0].FirstName, lastname=contacts[0].LastName, languagelocalekey='en_US',
        localesidkey='en_US', profileid = p, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='adminusr1@ssemail.com');
           
        User user2 = new User(alias = 'test123', email='test123@noemail.com',
        emailencodingkey='UTF-8', firstname='testStaffFN', lastname='testStaffLN', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='adminusr2@ssemail.com');
       
        userList.add(user1);
        userList.add(user2);
        
        insert userList;
                
        Opportunity opp = new Opportunity(Name = 'My Test Opp 1', Supervisor__c = userList[0].Id, StageName = 'Inquiry', Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(90), AccountId = accList[0].Id, RecordTypeId = newClassRTId, CloseDate = System.Today().addDays(20));
        insert opp;
                
        List<OpportunityContactRole> ocr = [SELECT Id, OpportunityId FROM OpportunityContactRole WHERE OpportunityId = : opp.Id];
        System.assertEquals(1, ocr.size());
        
        Test.startTest();
        
            List<Opportunity> updateOpp = [SELECT Id, Supervisor__c FROM Opportunity WHERE Id = :opp.Id];
            updateOpp[0].Supervisor__c = userList[1].Id;
            update updateOpp[0];
            
        Test.stopTest();
    }
    
    public static testMethod void oCRCReation_Test8() {
    
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        Id newClassRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Classes_Opportunities').getRecordTypeId();
        List<Contact> contacts = [SELECT Id, Name, FirstName, LastName, RecordType.DeveloperName FROM Contact];        
        
        Contact staffContact = new Contact();
        
        for(Contact c : contacts){
            if(c.RecordType.DeveloperName == 'DLS_Employee'){
                staffContact = c;
            }
        }
        Id p = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;
        List<User> userList = new List<User>();
        
        User user1 = new User(alias = 'test123', email='test123@noemail.com',
        emailencodingkey='UTF-8', firstname=staffContact.FirstName, lastname=staffContact.LastName, languagelocalekey='en_US',
        localesidkey='en_US', profileid = p, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='adminusr1@ssemail.com');
        
        userList.add(user1);        
        insert userList;
               
        Test.startTest();
        
        Opportunity opp = new Opportunity(Name = 'My Test Opp 1', Student_Name__c = contacts[0].Id, Contracting_Officer__c = contacts[1].Id, Agency_Contact__c = contacts[2].Id, InstructorName__c = contacts[3].Id, EI_lookup__c = contacts[4].Id, X2nd_Instructor__c = contacts[5].Id, Supervisor__c = userList[0].Id, StageName = 'Inquiry', Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(90), AccountId = accList[0].Id, RecordTypeId = newClassRTId, CloseDate = System.Today().addDays(20));
        insert opp;
            
        createContactRoles_Util.createContactRoles(new Set<Id>{opp.Id}, True);
        
        List<OpportunityContactRole> ocr = [SELECT Id, OpportunityId FROM OpportunityContactRole WHERE OpportunityId = : opp.Id];
        System.assertEquals(7, ocr.size());
        
        Test.stopTest();
    }
    
    public static testMethod void updateCAAccountFromOpp_Test() {
    
        Account acc = new Account(Name = 'Opp Test Account');
        insert acc;
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        
        Id newClassRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Classes_Opportunities').getRecordTypeId();
        
        Test.startTest();
        
            Date projSD = Date.newInstance(System.today().year(),System.today().month(),01);
            Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
                
            List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
            
            Opportunity opp = new Opportunity(Name = 'Test CA Account Pop Opp 1', Supervisor__c = userInfo.getUserId(), StageName = 'Inquiry', Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(90), AccountId = accList[0].Id, RecordTypeId = newClassRTId, CloseDate = System.Today().addDays(20));
            insert opp;
                
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Candidate_Name__c = contacts[0].Id, Start_Date__c = projSD, End_Date__c = projED, Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Candidate_Name__c = contacts[1].Id, Start_Date__c = projSD, End_Date__c = projED, Status__c = 'Active', Assignment_Position__c = 'Instructor')
            };
            insert conAssignRecs;  
            
            Opportunity updateOpp = new Opportunity(Id = opp.Id, AccountId = acc.Id);
            update updateOpp;
            
            List<Opportunity> updatedOpp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals(acc.Id, updatedOpp[0].AccountId);
        
        Test.stopTest();
    }
}