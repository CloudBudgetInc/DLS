@isTest
public class Test_createContactRoles_Util {
    
     @testSetup static void setup(){
         Test.StartTest();
         List<Opportunity> oppList = TestClassUtil.createTestOpportunities();
         List<contact> contactList = TestClassUtil.createTestContacts();
         Test.StopTest();
         
    }

    public static testmethod void createContactRoles_Util_Fun1() {
    
        /*List<RecordType> oppRecTypeList = [ SELECT Id,DeveloperName,SObjectType,isActive 
                                            FROM RecordType 
                                            WHERE DeveloperName = 'New_Classes_Opportunities'
                                            AND isActive = TRUE
                                            AND SObjectType = 'Opportunity'
                                            LIMIT 1
                                          ];
                                          
        Id dlsEmployeeRecTypeId, studentRecTypeId;
        for (RecordType conRecType : [ SELECT Id,DeveloperName,SObjectType,isActive 
                                       FROM RecordType 
                                       WHERE DeveloperName IN ('DLS_Employee', 'Student')
                                       AND isActive = TRUE
                                       AND SObjectType = 'Contact'
                                     ]) {
            if (conRecType.DeveloperName == 'DLS_Employee') dlsEmployeeRecTypeId = conRecType.Id;
            else if (conRecType.DeveloperName == 'Student') studentRecTypeId = conRecType.Id;
        }
        
        Account acc = new Account(name='Test Acct 1',Type = 'Other',BillingStreet = '24 Jackson Road');
        Insert acc;
        
        List<User> userList = [SELECT Id, FirstName, LastName, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Contact[] conList = new Contact[]{
            new Contact(LastName='Test Contact',AccountId=acc.Id,MailingPostalCode = '60012'),
            new Contact(LastName='Test Contact 2',AccountId=acc.Id,MailingPostalCode = '60013'),
            new Contact(LastName='Test Contact 3',AccountId=acc.Id,MailingPostalCode = '60014'),
            new Contact(LastName='Test Contact 4',AccountId=acc.Id,MailingPostalCode = '60015'),
            new Contact(LastName='Test Contact 5',AccountId=acc.Id,MailingPostalCode = '60016'),
            new Contact(LastName='Test Contact 6',AccountId=acc.Id,MailingPostalCode = '60017')
        };
        
        if (userList != null && userList.size() > 0 && String.isNotBlank(dlsEmployeeRecTypeId)) {
            Contact con1 = new Contact(FirstName = userList[0].FirstName, LastName = userList[0].LastName, RecordtypeId = dlsEmployeeRecTypeId, AccountId=acc.Id,MailingPostalCode = '60017');
            conList.add(con1);
        }
         if (String.isNotBlank(studentRecTypeId)) {
            Contact con1 = new Contact(FirstName = userList[0].FirstName, LastName = userList[0].LastName, RecordtypeId = studentRecTypeId, AccountId=acc.Id,MailingPostalCode = '60017');
            conList.add(con1);
        }
        Test.starttest();
        
        Contact con1 = new Contact(LastName = 'Test Contact 9', AccountId=acc.Id, MailingPostalCode = '60019');
        conList.add(con1);
        Insert conList;
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        Opportunity opportinutyInst = New Opportunity();
        if (oppRecTypeList != null && oppRecTypeList.size() > 0) opportinutyInst.RecordTypeId = oppRecTypeList[0].Id; 
        opportinutyInst.Name = 'Afgan-Pack';
        opportinutyInst.AccountId = acc.Id;
        opportinutyInst.StageName = 'Gate 1';
        opportinutyInst.CloseDate = date.valueof(system.today() + 20);
        opportinutyInst.Student_Name__c = conList[0].Id;
        opportinutyInst.Contracting_Officer__c = conList[1].Id;
        opportinutyInst.Agency_Contact__c = conList[2].Id;
        opportinutyInst.InstructorName__c = conList[3].Id;
        opportinutyInst.Supervisor__c = Userinfo.getUserId();
        opportinutyInst.EI_lookup__c = conList[4].Id;
        opportinutyInst.X2nd_Instructor__c = conList[5].Id;
        oppList.add(opportinutyInst);
        
        Opportunity opp = New Opportunity();
        if (oppRecTypeList != null && oppRecTypeList.size() > 0) opp.RecordTypeId = oppRecTypeList[0].Id; 
        opp.Name = 'Afgan-Pack';
        opp.AccountId = acc.Id;
        opp.StageName = 'Gate 1';
        opp.CloseDate = date.valueof(system.today() + 20);
        opp.Student_Name__c = conList[0].Id;
        opp.Contracting_Officer__c = conList[1].Id;
        oppList.add(opp);
        
        insert oppList;*/
        
        Test.starttest();
        
                                          
        Id dlsEmployeeRecTypeId, studentRecTypeId;
        for (RecordType conRecType : [ SELECT Id,DeveloperName,SObjectType,isActive 
                                       FROM RecordType 
                                       WHERE DeveloperName IN ('DLS_Employee', 'Student')
                                       AND isActive = TRUE
                                       AND SObjectType = 'Contact'
                                     ]) {
            if (conRecType.DeveloperName == 'DLS_Employee') dlsEmployeeRecTypeId = conRecType.Id;
            else if (conRecType.DeveloperName == 'Student') studentRecTypeId = conRecType.Id;
        }
        
        List<Opportunity> oppList = [SELECT Id,Name,CloseDate,AccountId FROM Opportunity WHERE RecordType.DeveloperName = 'New_Classes_Opportunities' LIMIT 1];
        List<contact> conList = [SELECT Id,Name,RecordType.DeveloperName FROM Contact LIMIT 2];
        
        
        conList[0].RecordTypeId = dlsEmployeeRecTypeId;
        conList[1].RecordTypeId = studentRecTypeId;
        
        update conList;
                
        Contact_Assignments__c ca = new Contact_Assignments__c();
        ca.Candidate_Name__c = conList[0].RecordType.DeveloperName == 'DLS_Employee'? conList[0].Id : conList[1].Id;
        ca.Opportunity_Name__c = oppList[0].Id;
        ca.Assignment_Position__c = 'Developer';
        ca.Start_Date__c = Date.today();
        ca.End_Date__c = Date.today().addDays(10);
        insert ca;  
        
        Test.Stoptest();
        
        Student_Assignment__c[] studentList = new Student_Assignment__c[]{
            new Student_Assignment__c(Student_Name__c = conList[0].RecordType.DeveloperName == 'Student'? conList[0].Id : conList[1].Id, Class_Name__c = oppList[0].Id),
            new Student_Assignment__c(Student_Name__c = conList[0].RecordType.DeveloperName == 'Student'? conList[0].Id : conList[1].Id, Class_Name__c = oppList[0].Id)
        };
        insert studentList; 
         
        createContactRoles_Util.createContactRoles(new Set<Id>{oppList[0].Id}, true);
        createContactRoles_Util.createContactRoles(new Set<Id>{oppList[0].Id}, false);
    }
}