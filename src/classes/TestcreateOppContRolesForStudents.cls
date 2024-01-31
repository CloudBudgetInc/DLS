@isTest
public class TestcreateOppContRolesForStudents {

    public static testmethod void createOppContRolesForStudents_Fun1() {
    
        List<RecordType> oppRecTypeList = [ SELECT Id,DeveloperName,SObjectType,isActive 
                                            FROM RecordType 
                                            WHERE DeveloperName = 'New_Classes_Opportunities'
                                            AND isActive = TRUE
                                            AND SObjectType = 'Opportunity'
                                            LIMIT 1
                                          ];
        
        Account acc = new Account(name='Test Acct 1',Type = 'Other',BillingStreet = '24 Jackson Road');
        Insert acc;
        
        List<RecordType> conRecTypeList = new List<RecordType>();
        conRecTypeList = [ SELECT Id, Name, DeveloperName, isActive, SObjectType
                           FROM RecordType
                           WHERE DeveloperName = 'Student'
                           AND isActive = TRUE
                           AND SobjectType = 'Contact'
                           LIMIT 1
                         ];
        Contact[] conList = new Contact[] {
            new Contact(LastName='Test Contact', AccountId=acc.Id, MailingPostalCode = '60012'),
            new Contact(LastName='Test Contact 2',AccountId=acc.Id,MailingPostalCode = '60013')
        };
        if (conRecTypeList != null && conRecTypeList.size() > 0) {
            conList[0].RecordTypeId = conRecTypeList[0].Id; 
            conList[1].RecordTypeId = conRecTypeList[0].Id; 
        }
        insert conList;
        
        Opportunity opportinutyInst = New Opportunity();
        if (oppRecTypeList != null && oppRecTypeList.size() > 0) opportinutyInst.RecordTypeId = oppRecTypeList[0].Id; 
        opportinutyInst.Name = 'Afgan-Pack';
        opportinutyInst.AccountId = acc.Id;
        opportinutyInst.StageName = 'Gate 1';
        opportinutyInst.CloseDate = date.valueof(system.today() + 20);
        insert opportinutyInst;

        Student_Assignment__c[] studentList = new Student_Assignment__c[]{
            new Student_Assignment__c(Student_Name__c = conList[0].Id, Class_Name__c = opportinutyInst.Id),
            new Student_Assignment__c(Student_Name__c = conList[1].Id, Class_Name__c = opportinutyInst.Id)
        };
        insert studentList;  
        
        studentList[0].Student_Name__c = conList[1].Id;
        update studentList;
    }
}