@isTest
private class NewClassAnnouncementController_Test {

    @testSetup static void setup() {
    
        Test.startTest();
            List<Contact_Assignments__c> proList = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
        List<Schedule__c> schList = TestClassUtil.createTestSchedule();
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = TestClassUtil.createTestTimeCardDay();
        List<Materials_Request__c> matReqs = TestClassUtil.createTestMaterialRequest();
    }
    
    // For getting the related information of the project
    private static testMethod void testMethod1() {
        List<Contact_Assignments__c> caList = [SELECT Id, Name, Project__c FROM Contact_Assignments__c WHERE Status__c = 'Active' AND RecordType.Developername = 'Instructor' AND Project__c  != null LIMIT 1];
        List<Folder> folder = [SELECT Id, Name from Folder WHERE Name = 'Shared Documents' LIMIT 1];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != null LIMIT 2];
        List<Schedule__c> schList = [SELECT Id, Name, Project__c FROM Schedule__c LIMIT 1];
        
        List<System_Values__c> sysVal = new List<System_Values__c> {
            new System_Values__c(Name = 'Class Announcement Additional To Ids', Value__c = 'Test@gmail.com;Test1@gmail.com'),
            new System_Values__c(Name = 'Class Announcement CC Ids', Value__c = 'Test2@gmail.com;Test3@gmail.com')
        };
        insert sysVal;
                  
        if(folder.size() > 0 && caList.size() > 0 && conList.size() > 0 && schList.size() > 0) {
            
            schList[0].Project__c = caList[0].Project__c;
            update schList;
            
            /*List<Document> doc = new List<Document> {
                new Document(Name = 'My Document', Body = Blob.valueOf('Some Text'), ContentType = 'application/pdf', DeveloperName = 'DLS_Logo1', IsPublic = true, FolderId = folder[0].Id)
            };
            insert doc;*/
            
            List<Document> doc = [SELECT Id,DeveloperName FROM Document WHERE DeveloperName = 'DLS_Logo1'];
            
            List<NewClassAnnouncementController.EmailContents> emailCon = new List<NewClassAnnouncementController.EmailContents>();            
            emailCon.add(NewClassAnnouncementController.getRelatedInformation(caList[0].Project__c));
            for(NewClassAnnouncementController.EmailContents email : emailCon) {
                email.toAddressContacts = conList;
                email.toEmailIds = 'Test4@gmail.com;Test5@gmail.com';
            }
            
            String status = NewClassAnnouncementController.sendNewClassAnnouncementEmail(JSON.serialize(emailCon), 'Name', '', '64base');
            if(status != '') {
                System.assertEquals('SUCCESS', status);
            }
        }
    }
    
    private static testMethod void testMethod2() {
        List<Contact_Assignments__c> caList = [SELECT Id, Name, Project__c,Status__c,RecordType.DeveloperName FROM Contact_Assignments__c WHERE Status__c = 'Active' AND RecordType.Developername = 'Student' AND Project__c  != null LIMIT 1];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != null LIMIT 2];
        
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c =:caList[0].Project__c];
        List<System_Values__c> sysVal = new List<System_Values__c> {
            new System_Values__c(Name = 'Student payment remainder from address', Value__c = 'Test@gmail.com;Test1@gmail.com'),
            new System_Values__c(Name = 'Student payment remainder CC Ids', Value__c = 'Test2@gmail.com;Test3@gmail.com')
        };
        insert sysVal;
        
        List<NewClassAnnouncementController.EmailContents> emailCon = new List<NewClassAnnouncementController.EmailContents>();            
        emailCon.add(NewClassAnnouncementController.getStudentPaymentInformation(caList[0].Project__c, projTask[0].Id));
        for(NewClassAnnouncementController.EmailContents email : emailCon) {
            email.toAddressContacts = conList;
            email.toEmailIds = 'Test4@gmail.com;Test5@gmail.com';
        }
        
        String status = NewClassAnnouncementController.sendStudentPaymentRemainderEmail(JSON.serialize(emailCon));
    }
        
    private static testMethod void testMethod3() {
        
        List<Contact_Assignments__c> caList = [SELECT Id, Name, Project__c,Status__c,RecordType.DeveloperName FROM Contact_Assignments__c WHERE Status__c = 'Active' AND RecordType.Developername = 'Student' AND Project__c  != null LIMIT 1];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != null LIMIT 1];
        
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c =:caList[0].Project__c];
        
        List<System_Values__c> sysVal = new List<System_Values__c> {
            new System_Values__c(Name = 'Student payment remainder from address', Value__c = 'Test@gmail.com;Test1@gmail.com'),
            new System_Values__c(Name = 'Student payment remainder CC Ids', Value__c = 'Test2@gmail.com')
        };
        insert sysVal;
        
        List<NewClassAnnouncementController.EmailContents> emailCon1 = new List<NewClassAnnouncementController.EmailContents>();            
        emailCon1.add(NewClassAnnouncementController.getStudentPaymentInformation(caList[0].Project__c, projTask[0].Id));
        for(NewClassAnnouncementController.EmailContents email : emailCon1) {
            email.toAddressContacts = conList;
            email.toEmailIds = 'Test4@gmail.com';
        }
        String status = NewClassAnnouncementController.sendStudentPaymentRemainderEmail(JSON.serialize(emailCon1));
        
        List<sObject> contactList = NewClassAnnouncementController.getLookupRecords('Test','Contact','Name','',new List<String>{});
        
        if(status != '') {
            System.assertEquals('SUCCESS', status);
        }
    }
    
    private static testMethod void testMethod3a() {
        
        List<Contact_Assignments__c> caList = [SELECT Id, Name, Project__c,Status__c,RecordType.DeveloperName FROM Contact_Assignments__c WHERE Status__c = 'Active' AND RecordType.Developername = 'Student' AND Project__c  != null LIMIT 1];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != null LIMIT 3];
                
        List<System_Values__c> sysVal = new List<System_Values__c> {
            new System_Values__c(Name = 'Student payment remainder from address', Value__c = 'Test@gmail.com;Test1@gmail.com'),
            new System_Values__c(Name = 'Student payment remainder CC Ids', Value__c = 'Test2@gmail.com')
        };
        insert sysVal;
        
        List<AcctSeed__Time_Card_Day__c> dayRecord = [SELECT Id,AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c FROM AcctSeed__Time_Card_Day__c LIMIT 1];
        
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, Total_Qty_Paid__c FROM AcctSeed__Project_Task__c WHERE Id =:dayRecord[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c];
        projTask[0].Total_Qty_Paid__c = 100;
        update projTask[0];
                    
        List<NewClassAnnouncementController.EmailContents> emailCon1 = new List<NewClassAnnouncementController.EmailContents>();            
        emailCon1.add(NewClassAnnouncementController.getStudentPaymentInformation(dayRecord[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, dayRecord[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c));
        for(NewClassAnnouncementController.EmailContents email : emailCon1) {
            email.toAddressContacts = conList;
            email.toEmailIds = 'Test4@gmail.com';
        }
        String status = NewClassAnnouncementController.sendStudentPaymentRemainderEmail(JSON.serialize(emailCon1));
        
        List<sObject> contactList = NewClassAnnouncementController.getLookupRecords('Test','Contact','Name','',new List<String>{});
        
        if(status != '') {
            System.assertEquals('SUCCESS', status);
        }
    }
    
    private static testMethod void testMethod4() {
        
        List<Contact_Assignments__c> caList = [SELECT Id, Name, Project__c,Status__c,RecordType.DeveloperName FROM Contact_Assignments__c WHERE Status__c = 'Active' AND RecordType.Developername = 'Student' AND Project__c  != null LIMIT 1];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != null LIMIT 1];
        
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c =:caList[0].Project__c LIMIT 1];
        
        List<AcctSeed__Project_Task__c> taskRecords = NewClassAnnouncementController.getServiceProjectTasks(caList[0].Project__c);
        
        if(taskRecords.size() > 0){
            System.assertEquals(projTask.size(), taskRecords.size());
        }
    }
    
    private static testMethod void testMethod5() {
        
        List<Contact_Assignments__c> stdConAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Assignment_Position__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE Id = :stdConAss[0].Project__c];
        
        List<Materials_Request__c> matReqUp = [SELECT Id, Name, Project__c, Est_Arrival_Date__c, Request_Status__c FROM Materials_Request__c LIMIT 1];        
        matReqUp[0].Est_Arrival_Date__c = Date.Today().addDays(-1);
        matReqUp[0].Project__c= projects[0].Id;
        matReqUp[0].Request_Status__c = 'Ordered';
        update matReqUp[0];
        
        NewClassAnnouncementController.getMaterialsOrderedInformation(projects[0].Id);
    }
    
    private static testMethod void testMethod6() {
    
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != null LIMIT 2];
        
        List<NewClassAnnouncementController.EmailContents> emailConts = new List<NewClassAnnouncementController.EmailContents>();    
        
        NewClassAnnouncementController.EmailContents emailCon =  new NewClassAnnouncementController.EmailContents();
        emailCon.toAddressContacts = conList;
        emailCon.toEmailIds = 'Test4@gmail.com;Test5@gmail.com';
        emailCon.ccEmailIds = 'mytest123@gmail.com';
        emailConts.add(emailCon);
        
        NewClassAnnouncementController.sendMaterialOrderEmail(JSON.serialize(emailConts)); 
    }
    
    private static testMethod void testMethod6a() {
    
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != null LIMIT 1];
        
        List<NewClassAnnouncementController.EmailContents> emailConts = new List<NewClassAnnouncementController.EmailContents>();    
        
        NewClassAnnouncementController.EmailContents emailCon =  new NewClassAnnouncementController.EmailContents();
        emailCon.toAddressContacts = conList;
        emailCon.toEmailIds = 'Test4@gmail.com;Test5@gmail.com';
        emailCon.ccEmailIds = 'mytest123@gmail.com';
        emailConts.add(emailCon);
        
        NewClassAnnouncementController.sendMaterialOrderEmail(JSON.serialize(emailConts)); 
    }
    
    private static testMethod void StudentOnHoldQuarterlyReminderEmailTest() {
        List<Contact_Assignments__c> caList = [SELECT Id, Name, Project__c,Status__c,RecordType.DeveloperName FROM Contact_Assignments__c WHERE Status__c = 'Active' AND RecordType.Developername = 'Student' AND Project__c  != null LIMIT 1];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != null LIMIT 2];
        Acctseed__Project__c proj = new Acctseed__Project__c();
        proj.Id = caList[0].Project__c;
        proj.AcctSeed__Status__c = 'On Hold';
        proj.On_Hold_Date__c = System.Today();
        update proj;
        
        NewClassAnnouncementController.EmailContents emailCon = NewClassAnnouncementController.getOnHoldProjectAndStudentInformation(caList[0].Project__c);
        emailCon.toAddressContacts = conList;
        emailCon.toEmailIds = 'Test4@gmail.com;Test5@gmail.com';       
        
        String status = NewClassAnnouncementController.sendStudentOnHoldQuarterlyReminderEmail(JSON.serialize(emailCon));
    }
    
    private static testMethod void translatorPaymentEmailConfirmationInformationTest() {
        List<Contact_Assignments__c> caList = [SELECT Id, Name, Project__c,Status__c,RecordType.DeveloperName FROM Contact_Assignments__c WHERE Status__c = 'Active' AND RecordType.Developername = 'Instructor' AND Project__c  != null LIMIT 1];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != null LIMIT 2];       
        
        NewClassAnnouncementController.EmailContents emailCon = NewClassAnnouncementController.getTranslatorPaymentEmailConfirmationInformation(caList[0].Id);
        emailCon.toAddressContacts = conList;
        emailCon.toEmailIds = 'Test4@gmail.com;Test5@gmail.com';       
        
        String status = NewClassAnnouncementController.sendTranslatorPaymentConfirmationEmail(JSON.serialize(emailCon));
    }
}