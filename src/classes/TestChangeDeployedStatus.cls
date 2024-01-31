@isTest
private class TestChangeDeployedStatus{
    private static testMethod void myTest(){
    
    //CASE 1: test an update of MTT status from Active to Ended
    Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
    MTT__c M = new MTT__c();
    Database.insert(M);
    Deployed_Instructor__c A = new Deployed_Instructor__c();
    A.MTT_Name__c=M.Id;
    A.status__c = 'Deployed';
    Contact Instructor = new Contact();
    Instructor.LastName = 'Dtest';
    Instructor.Employment_Section__c = null;
    Instructor.Next_Availability__c = null;
    Instructor.Instructor_Status__c = null;
    Instructor.Current_Account__c = null;
    Instructor.RecordTypeId=rt.id;
    Database.insert(Instructor);
    A.Contact__c = Instructor.Id;
    Database.insert(A);
    Database.update(Instructor);
    M.Stage__c = 'Ended';
    Database.update(M);
    Database.update(A);
    Database.update(Instructor);
    
               
    //CASE 6: test a delete with status active. first create the record, then delete it and update the contact.  
    
    MTT__c M2 = new MTT__c();
    M2.Stage__c = 'Active';
    Database.insert(M2);
    Deployed_Instructor__c B = new Deployed_Instructor__c();
    B.MTT_Name__c=M2.Id;
    B.status__c = 'Deployed';
    Contact Instructor2 = new Contact();
    Instructor2.LastName = 'Dtest2';
    Instructor2.Employment_Section__c = null;
    Instructor2.Next_Availability__c = null;
    Instructor2.Instructor_Status__c = null;
    Instructor2.Current_Account__c = null;
    Instructor2.RecordTypeId=rt.id;
    Database.insert(Instructor2);
    B.Contact__c = Instructor2.Id;
    Database.insert(B);
    Database.update(Instructor2);
    Database.delete(M2);
    Database.update(Instructor2);
    test.startTest();
    test.StopTest();
        }
    }