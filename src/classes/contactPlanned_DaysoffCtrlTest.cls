@isTest
public class contactPlanned_DaysoffCtrlTest {
    
    @testSetup static void setup(){
        
        Test.startTest();
            List<Planned_Days_Off__c> plantDays = TestClassUtil.createTestPlannedDaysOff();
        Test.stopTest();
    }
    
    // For getting Planned days off information
    private static testMethod void testMethod1() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, Candidate_Name__c, Opportunity_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN ('Student','Instructor','Staff')];
        List<Planned_Days_Off__c> plannedDaysOffList = [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,
                                                        Type__c,Contact__c,RecordTypeId,RecordType.DeveloperName
                                                        FROM Planned_Days_Off__c];
        
        if(conAssList.size() > 0 && plannedDaysOffList.size() > 0) {
        
            conAssList[0].Candidate_Name__c = plannedDaysOffList[0].Contact__c;
            update conAssList;
            
            Test.startTest();
            
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(conAssList[0].Candidate_Name__c, null,null,String.valueOf(System.today()),String.valueOf(System.today()+5));
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(conAssList[0].Candidate_Name__c, null,null,String.valueOf(System.today()),null);
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(conAssList[0].Candidate_Name__c, null,null,null,String.valueOf(System.today()+5));
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(conAssList[0].Candidate_Name__c, null,null,null,null);
                
                
                ContactPlanned_DaysoffCtrl.PlannedOff wrap = new ContactPlanned_DaysoffCtrl.PlannedOff();
                wrap = ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(null, conAssList[0].Project__c, null,String.valueOf(System.today()),String.valueOf(System.today()+2));
                
                if(wrap != null) {
                    System.assert(wrap.typeValues.contains('Instructor'));
                }
            
            Test.stopTest();
        }
    }
    
    // For getting Planned days off information
    private static testMethod void testMethod2() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, Candidate_Name__c, Opportunity_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN ('Student','Instructor','Staff')];
        List<Planned_Days_Off__c> plannedDaysOffList = [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,
                                                        Type__c,Contact__c,RecordTypeId,RecordType.DeveloperName
                                                        FROM Planned_Days_Off__c];
        
        if(conAssList.size() > 0 && plannedDaysOffList.size() > 0) {
            
            for(Contact_Assignments__c conAss : conAssList) {
                conAss.Status__c = 'Planned';
                conAss.Candidate_Name__c = plannedDaysOffList[0].Contact__c;
            } 
            
            Test.startTest();
            
                update conAssList;
                        
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(null, null, conAssList[0].Opportunity_Name__c,String.valueOf(System.today()),String.valueOf(System.today()+5));
                
                ContactPlanned_DaysoffCtrl.PlannedOff wrap = new ContactPlanned_DaysoffCtrl.PlannedOff();
                
                wrap = ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(null, conAssList[0].Project__c, null,String.valueOf(System.today()),String.valueOf(System.today()+5));
                
                if(wrap != null) {
                    System.assert(wrap.typeValues.contains('Student'));
                }
            Test.stopTest();
        }
    } 
    
    // For getting Planned days off information
    private static testMethod void testMethod3() {
        
        //List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, Candidate_Name__c, Opportunity_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN ('Student','Instructor','Staff')];
        List<Planned_Days_Off__c> plannedDaysOffList = [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,
                                                        Type__c,Contact__c,RecordTypeId,RecordType.DeveloperName
                                                        FROM Planned_Days_Off__c];
        
        List<RecordType> conRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'DLS_Employee'];
        
        if(conRt.size() > 0) {
            List<Contact> conList = new List<Contact> { 
                new Contact(LastName = 'PDOTestNewCon1', FirstName = 'PDO1', Email='pdotestnewcon1@test.com', RecordTypeId = conRt[0].Id),
                new Contact(LastName = 'PDOTestNewCon2', Email='pdotestmynewcon2@test.com', RecordTypeId = conRt[0].Id)
            };
            insert conList;
            
            List<Profile> profileUser = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
            String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
            
            if(profileUser.size() > 0) {
            
                List<User> userList = new List<User>{        
                    new User(Alias = 'standt', Email = 'test@gmail.com',EmailEncodingKey = 'UTF-8', LastName = 'Testing', FirstName = 'Test1',
                             LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profileUser[0].Id, DelegatedApproverId = UserInfo.getUserId(),
                             TimeZoneSidKey = 'America/Los_Angeles', UserName = un, contact = conList[0])
                        };
                            insert userList;
                
                Test.startTest();
                
                    for(Planned_Days_Off__c pdo : plannedDaysOffList) {
                        pdo.Contact__c = userList[0].ContactId;
                    }
                    update plannedDaysOffList;
                    
                    ContactPlanned_DaysoffCtrl.PlannedOff wrap = new ContactPlanned_DaysoffCtrl.PlannedOff();
                    
                    System.RunAs(userList[0]) {
                        wrap = ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(null, null, null,String.valueOf(System.today()),String.valueOf(System.today()+5));
                        
                        Test.stopTest();
                        
                        if(wrap != null) {
                            System.assert(wrap.typeValues.contains('Staff'));
                        }
                    }
                
            }
        }
    }
    
    // For Updating the planned days of Records  
    private static testMethod void testMethod4() {
        
        List<Planned_Days_Off__c> plannedDaysOffList = [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,
                                                        Type__c,Contact__c,RecordTypeId,RecordType.DeveloperName
                                                        FROM Planned_Days_Off__c];
        
        List<RecordType> conRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'DLS_Employee'];
        List<Contact> contactList = [SELECT Id, Name, LastName, FirstName FROM Contact WHERE Id = :plannedDaysOffList[0].Contact__c];
        
        if(contactList.size() > 0 && conRt.size() > 0) {
            
            List<Profile> profileUser = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
            String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
          
            system.debug(':contactList'+contactList);
            if(profileUser.size() > 0) {
                List<User> userList = new List<User>{        
                    new User(Alias = 'standt', Email = 'test@gmail.com',EmailEncodingKey = 'UTF-8', LastName = contactList[0].LastName, FirstName = contactList[0].FirstName,
                             LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profileUser[0].Id, DelegatedApproverId = UserInfo.getUserId(),
                             TimeZoneSidKey = 'America/Los_Angeles', UserName = un, contact = contactList[0], IsActive = true)
                        };
                            insert userList;
                
                ApexPages.StandardController sc = new ApexPages.StandardController(contactList[0]);
                contactPlanned_DaysoffCtrl controller = new contactPlanned_DaysoffCtrl(sc);
                
                plannedDaysOffList[0].Date__c = System.Today().addMonths(5);
                plannedDaysOffList[1].Date__c = System.Today().addMonths(2);
                plannedDaysOffList[2].Date__c = System.Today().addMonths(1);
                update plannedDaysOffList;
                
                List<Planned_Days_Off__c> pdo = new List<Planned_Days_Off__c>();
                List<Planned_Days_Off__c> pdoRequest = new List<Planned_Days_Off__c>();
                
                pdo.add(plannedDaysOffList[0]);
                pdo.add(plannedDaysOffList[1]);
                pdoRequest.add(plannedDaysOffList[2]);
                    
                Test.startTest();
                
                System.runAs(userList[0]) {
                    List<Planned_Days_Off__c> updatedPlannedDaysOffList = contactPlanned_DaysoffCtrl.create_updatemethod(JSON.serialize(pdo), plannedDaysOffList[0].Contact__c, JSON.serialize(pdoRequest),false);
                    String updatedPlannedDaysOffListStr = contactPlanned_DaysoffCtrl.create_updatemethodPDO(JSON.serialize(pdo), plannedDaysOffList[0].Contact__c, JSON.serialize(pdoRequest),false);
                    
                    for(Contact con : contactList) {
                        con.RecordTypeId = conRt[0].Id;
                    }
                    update contactList;
                    
                    pdo[0].Id = null;
                    pdo[1].Id = null;
                    
                    pdoRequest[0].Contact__c = contactList[0].Id;
                    update pdoRequest;
                    pdoRequest[0].Id = null;
                    
                    List<Planned_Days_Off__c> updatedPlannedDaysOffListRet = contactPlanned_DaysoffCtrl.create_updatemethod(JSON.serialize(pdo), plannedDaysOffList[0].Contact__c, JSON.serialize(pdoRequest),false);
                    
                }
                Test.stopTest();
            }
        }
    }
    
    // For Deleting the planned days of Records 
    private static testMethod void testMethod5() {
        
        List<Contact> contactList = [SELECT Id, Name FROM Contact];
        
        List<Planned_Days_Off__c> plannedDaysOffList = [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,
                                                        Type__c,Contact__c,RecordTypeId,RecordType.DeveloperName
                                                        FROM Planned_Days_Off__c];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contactList[0]);
        contactPlanned_DaysoffCtrl controller = new contactPlanned_DaysoffCtrl(sc);
        
        plannedDaysOffList[0].Date__c = System.Today().addMonths(5);
        plannedDaysOffList[1].Date__c = System.Today().addMonths(2);
        plannedDaysOffList[2].Date__c = System.Today().addMonths(1);
        plannedDaysOffList[0].Requested_Reschedule_Date__c=System.Today().addDays(28);
        plannedDaysOffList[1].Requested_Reschedule_Date__c=System.Today().addDays(17);
        plannedDaysOffList[2].Requested_Reschedule_Date__c=System.Today().addDays(20);
        update plannedDaysOffList;
        
        Test.startTest();
        
            contactPlanned_DaysoffCtrl.deleteDaysOff(JSON.serialize(plannedDaysOffList), true);
            contactPlanned_DaysoffCtrl.deletePlannedDaysOff(JSON.serialize(plannedDaysOffList), true);
            contactPlanned_DaysoffCtrl.deleteDaysOff(JSON.serialize(plannedDaysOffList), false);
            List<Planned_Days_Off__c> deletedPlannedDaysOffList = [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,Type__c,Contact__c,RecordTypeId,RecordType.DeveloperName FROM Planned_Days_Off__c];
            System.assertEquals(0, deletedPlannedDaysOffList.size());
            
        Test.stopTest();
    }
    
    // For getting the records value for Look field
    private static testMethod void testMethod6() {
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Name LIKE '%Test%'];
        contactPlanned_DaysoffCtrl conPlan = new contactPlanned_DaysoffCtrl();
        
        Test.startTest();
        
            List<sObject> objRet = contactPlanned_DaysoffCtrl.getLookupRecords('Contact', 'Test', '');
            contactPlanned_DaysoffCtrl.getLookupRecords('Test','Contact','Name','',new List<string>());
            system.debug(':::tetsconList'+conList+'::objRet'+objRet+ contactPlanned_DaysoffCtrl.getLookupRecords('Test','Contact','Name','',new List<string>()));
            if(objRet.size() > 0) {
                System.assertEquals(conList.size(), objRet.size());
            }
        Test.stopTest();
    }
    
    // For getting Contact Records based on Parent Id (Project/Opp) & type of PDO selected
    private static testMethod void testMethod7() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, Candidate_Name__c, RecordType.DeveloperName FROM Contact_Assignments__c WHERE RecordTypeId != null];
        
        if(conAssList.size() > 0) {
            
            List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :conAssList[0].Candidate_Name__c];
            
            Test.startTest();
            
                List<Contact> conListRet = contactPlanned_DaysoffCtrl.getRelatedContacts(conAssList[0].Project__c, '', conAssList[0].RecordType.DeveloperName);
                String conListStr = contactPlanned_DaysoffCtrl.getRelatedContactsPDO(conAssList[0].Project__c, '', conAssList[0].RecordType.DeveloperName);
                
                if(conListRet.size() > 0) {
                    System.assertEquals(conList.size(), conListRet.size());
                }
            Test.stopTest();
        }
    }
    
    private static testMethod void testMethod8() {
    
        contactPlanned_DaysoffCtrl.returnFieldValues();
    }
    
    //getting PDO records related Opportunity
    private static testMethod void testMethod9() {
    
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, Candidate_Name__c, Opportunity_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN ('Student','Instructor','Staff')];
        List<Planned_Days_Off__c> plannedDaysOffList = [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,
                                                        Type__c,Contact__c,RecordTypeId,RecordType.DeveloperName
                                                        FROM Planned_Days_Off__c];
        
        if(conAssList.size() > 0 && plannedDaysOffList.size() > 0) {
            conAssList[0].Candidate_Name__c = plannedDaysOffList[0].Contact__c;
            update conAssList;
            
            Test.startTest();
            
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,null,conAssList[0].Opportunity_Name__c,String.valueOf(System.today()),String.valueOf(System.today()+5));
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,null,conAssList[0].Opportunity_Name__c,String.valueOf(System.today()),null);
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,null,conAssList[0].Opportunity_Name__c,null,String.valueOf(System.today()));
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,null,conAssList[0].Opportunity_Name__c,null,null);
                ContactPlanned_DaysoffCtrl.getPlannedDaysOffInfo( null,null,conAssList[0].Opportunity_Name__c,null,null);
                
                   ContactPlanned_DaysoffCtrl.PlannedOff wrap = new ContactPlanned_DaysoffCtrl.PlannedOff();
                wrap = ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(null, conAssList[0].Project__c, null,String.valueOf(System.today()),String.valueOf(System.today()+2));
                
                if(wrap != null) {
                    System.assert(wrap.typeValues.contains('Instructor'));
                }
            Test.stopTest();
        }
    }
    
    //getting PDO records related Project
    private static testMethod void testMethod10() {
    
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, Candidate_Name__c, Opportunity_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN ('Student','Instructor','Staff')];
        List<Planned_Days_Off__c> plannedDaysOffList = [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,
                                                        Type__c,Contact__c,RecordTypeId,RecordType.DeveloperName
                                                        FROM Planned_Days_Off__c];
        
        if(conAssList.size() > 0 && plannedDaysOffList.size() > 0) {
            conAssList[0].Candidate_Name__c = plannedDaysOffList[0].Contact__c;
            update conAssList;
            
            Test.startTest();
            
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,conAssList[0].Project__c,null,String.valueOf(System.today()),String.valueOf(System.today()+5));
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,conAssList[0].Project__c,null,String.valueOf(System.today()),null);
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,conAssList[0].Project__c,null,null,String.valueOf(System.today()+5));
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,conAssList[0].Project__c,null,null,null);
                
                   ContactPlanned_DaysoffCtrl.PlannedOff wrap = new ContactPlanned_DaysoffCtrl.PlannedOff();
                wrap = ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(null, conAssList[0].Project__c, null,String.valueOf(System.today()),String.valueOf(System.today()+2));
                
                if(wrap != null) {
                    System.assert(wrap.typeValues.contains('Staff'));
                }
            Test.stopTest();
        }
    }
    
    //getting PDO records related userContact
    private static testMethod void testMethod11() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, Candidate_Name__c, Opportunity_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN ('Student','Instructor','Staff')];
        List<Planned_Days_Off__c> plannedDaysOffList = [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,
                                                    Type__c,Contact__c,RecordTypeId,RecordType.DeveloperName
                                                    FROM Planned_Days_Off__c];
        List<Contact> contactList = [SELECT Id, Name, LastName, FirstName FROM Contact WHERE Id = :plannedDaysOffList[0].Contact__c];

        for(Contact conlst : contactList ){
             conlst.FirstName = null;
            conlst.LastName = 'SoftSquare';
        }
        update contactList;
        
        Test.startTest();
        
            if(conAssList.size() > 0 && plannedDaysOffList.size() > 0) {
                conAssList[0].Candidate_Name__c = plannedDaysOffList[0].Contact__c;
                update conAssList;
                
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(null,null,null,String.valueOf(System.today()),String.valueOf(System.today()+5));
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(null,null,null,String.valueOf(System.today()),null);
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(null,null,null,null,null);
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(null,null,null,null,String.valueOf(System.today()));
               
            }
            ContactPlanned_DaysoffCtrl.PlannedOff wrap = new ContactPlanned_DaysoffCtrl.PlannedOff();
            wrap = ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(null, conAssList[0].Project__c, null,String.valueOf(System.today()),String.valueOf(System.today()+2));
            
        Test.stopTest();
            
            if(wrap != null) {
                System.assert(wrap.typeValues.contains('Student'));
            }
            
        
    }
    
    // getting Opportunity related PDO record without Contact
    private static testMethod void testMethod12() {
    
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, Candidate_Name__c,Status__c, Opportunity_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN ('Student','Instructor','Staff')];
        List<Planned_Days_Off__c> plannedDaysOffList = [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,
                                                        Type__c,Contact__c,RecordTypeId,RecordType.DeveloperName
                                                        FROM Planned_Days_Off__c];
        
        for(Contact_Assignments__c  conlist : conAssList)   {
            conlist.Status__c = null;
        }
        update conAssList;
        
        Test.startTest();
        
            if( plannedDaysOffList.size() > 0) {
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,null,conAssList[3].Opportunity_Name__c,String.valueOf(System.today()),String.valueOf(System.today()+5));
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,null,conAssList[3].Opportunity_Name__c,String.valueOf(System.today()),null);
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,null,conAssList[3].Opportunity_Name__c,null,String.valueOf(System.today()));
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,null,conAssList[3].Opportunity_Name__c,null,null);
            }
            ContactPlanned_DaysoffCtrl.PlannedOff wrap = new ContactPlanned_DaysoffCtrl.PlannedOff();
            wrap = ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(null, conAssList[0].Project__c, null,String.valueOf(System.today()),String.valueOf(System.today()+2));
            
        Test.stopTest();
            
            if(wrap != null) {
                System.assert(wrap.typeValues.contains('Instructor'));
            }
        
    }
    
   // getting project related PDO record without Contact
    private static testMethod void testMethod13() {
    
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, Candidate_Name__c,Status__c, Opportunity_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN ('Student','Instructor','Staff')];
        List<Planned_Days_Off__c> plannedDaysOffList = [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,
                                                        Type__c,Contact__c,RecordTypeId,RecordType.DeveloperName
                                                        FROM Planned_Days_Off__c];
        
        for(Contact_Assignments__c  conlist : conAssList)   {
            
            conlist.Status__c = null;
        }
        update conAssList;
        
        Test.startTest();
        
            if( plannedDaysOffList.size() > 0) {
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,conAssList[1].Project__c,null,String.valueOf(System.today()),String.valueOf(System.today()+5));
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,conAssList[1].Project__c,null,String.valueOf(System.today()),null);
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,conAssList[1].Project__c,null,null,String.valueOf(System.today()));
                ContactPlanned_DaysoffCtrl.plannedDaysOffInfo( null,conAssList[1].Project__c,null,null,null);
            }
            ContactPlanned_DaysoffCtrl.PlannedOff wrap = new ContactPlanned_DaysoffCtrl.PlannedOff();
            wrap = ContactPlanned_DaysoffCtrl.plannedDaysOffInfo(null, conAssList[0].Project__c, null,String.valueOf(System.today()),String.valueOf(System.today()+2));
            
        Test.stopTest();
            
            if(wrap != null) {
                System.assert(wrap.typeValues.contains('Instructor'));
            }
        
    }
}