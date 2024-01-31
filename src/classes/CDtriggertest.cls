@isTest
private class CDtriggertest{
    private static testMethod void myTest(){
    
        //CASE 1: test an insert with status active
        Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
        Account Acc = new Account ();
        Acc.Name = 'CD Test Account';
        Database.insert(Acc);
        Curriculum_Development_Project__c Proj = new Curriculum_Development_Project__c();
        Proj.Client__c = Acc.Id;
        Database.insert(Proj);
        CD_Assignment__c A = new CD_Assignment__c();
        A.Curriculum_Development_Project__c=Proj.Id;
        A.status__c = 'Active';
        Contact Developer = new Contact();
        Developer.LastName = 'CDtest';
        Developer.Employment_Section__c = null;
        Developer.Next_Availability__c = null;
        Developer.Instructor_Status__c = null;
        Developer.Current_Account__c = null;
        Developer.RecordTypeId=rt.id;
        Database.insert(Developer);
        A.developer_Name__c = Developer.Id;
        Database.insert(A);
        Database.update(Developer);
        
        Test.startTest();
        //CASE 2: test an update with status change from Ended to Active (just in case)
        CD_Assignment__c B = new CD_Assignment__c();
        B.status__c = 'Ended';
        B.Curriculum_Development_Project__c=Proj.Id;
        Contact DeveloperB = new Contact();
        DeveloperB.LastName = 'CDtestB';
        DeveloperB.Employment_Section__c = null;
        DeveloperB.Next_Availability__c = null;
        DeveloperB.Instructor_Status__c = null;
        DeveloperB.Current_Account__c = null;
        DeveloperB.RecordTypeId=rt.id;
        Database.insert(DeveloperB);
        B.developer_Name__c = DeveloperB.Id;
        Database.insert(B);
        Database.update(DeveloperB);
        B.status__c = 'Active';
        Database.update(B);
        Database.update(DeveloperB);
        
        //CASE 3: test update with status change from Active to Ended
        B.status__c = 'Ended';
        Database.update(B);
        Database.update(DeveloperB);
                           
        //CASE 4: test a delete with status active. first create the developer assignment record, then delete it and update the contact.  
        CD_Assignment__c C = new CD_Assignment__c();
        C.status__c = 'Active';
        C.Curriculum_Development_Project__c=Proj.Id;
        Contact Developer3 = new Contact();
        Developer3.Employment_Section__c = null;
        Developer3.Next_Availability__c = null;
        Developer3.Instructor_Status__c = null;
        Developer3.Current_Account__c = null;
        Developer3.RecordTypeId=rt.id;
        Developer3.LastName = 'CDtest3';
        C.developer_name__c = Developer3.Id;
        Database.insert(Developer3);
        Database.insert(C);
        Database.delete(C);
        Database.update(Developer3);
        
        Test.StopTest();
    }
}