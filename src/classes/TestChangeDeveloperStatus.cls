@isTest
private class TestChangeDeveloperStatus{
    private static testMethod void myTest(){
    
    //CASE 1: test an update of CD project status from Active to Ended
    Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
    Account Acc2 = new Account();
    Acc2.Name = 'DE Test Account';
    Database.insert(Acc2);
    Curriculum_Development_Project__c Proj = new Curriculum_Development_Project__c();
    Proj.Status__c = 'Active';
    Proj.Name = 'DEtest';
    Proj.Client__c = Acc2.Id;
    Database.insert(Proj);
    CD_Assignment__c A = new CD_Assignment__c();
    Contact Developer = new Contact();
    Developer.LastName = 'DEtest';
    Developer.Instructor_Status__c = 'Available';
    Developer.Current_Account__c = null;
    Developer.Employment_Section__c = null;
    Developer.Next_Availability__c = null;
    Developer.RecordTypeId=rt.id;
    Database.insert(Developer);
    A.Curriculum_Development_Project__c=Proj.Id;
    A.status__c = 'Active';
    A.developer_Name__c = Developer.Id;
    Database.insert(A);
    Database.update(Developer);
    Proj.Status__c = 'Ended';
    Database.update(Proj);
    Database.update(A);
    Database.update(Developer);
    
               
    //CASE 6: test a delete with status active. first create the record, then delete it and update the contact.  
    
    Curriculum_Development_Project__c Proj2 = new Curriculum_Development_Project__c();
    Proj2.Status__c = 'Active';
    Proj2.Client__c = Acc2.Id;
    Database.insert(Proj2);
    Contact Developer2 = new Contact();
    Developer2.LastName = 'DEtest2';
    Developer2.Instructor_Status__c = 'Available';
    Developer2.Current_Account__c = null;
    Developer2.Employment_Section__c = null;
    Developer2.Next_Availability__c = null;
    Developer2.RecordTypeId=rt.id;
    Database.insert(Developer2);
    CD_Assignment__c B = new CD_Assignment__c();
    B.Curriculum_Development_Project__c=Proj2.Id;
    B.status__c = 'Active';
    B.developer_Name__c = Developer2.Id;
    Database.insert(B);
    Database.update(Developer2);
    Database.delete(Proj2);
    Database.update(Developer2);
    test.startTest();
    test.StopTest();
        }
    }