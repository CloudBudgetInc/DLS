@isTest
private class TestInsertUpdateDelete{
    private static testMethod void myTest(){
    
    /*//CASE 1: test an insert with stage active
    Account Acc = new Account();
    Acc.Name = 'test account';
    Database.insert(Acc);
    Opportunity Opp = new Opportunity();
    Opp.AccountId = Acc.Id;
    Opp.StageName = 'Active';
    Opp.Name = 'test';
    Opp.CloseDate = Date.today();
    Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
    Contact Instructor = new Contact();
    Instructor.LastName = 'test';
    Instructor.Active_Count__c=0;
    Instructor.RecordTypeId=rt.id;
    Database.insert(Instructor);
    Opp.InstructorName__c = Instructor.Id;
    Database.insert(Opp);
    Database.update(Instructor);
    
       
    //CASE 2: test an update with stage change from inquiry to Active (Not Active to Active)
    Opportunity OppB = new Opportunity();
    OppB.StageName = 'Inquiry';
    OppB.Name = 'testB';
    OppB.AccountId = Acc.Id;
    OppB.CloseDate = Date.today();
    Contact InstructorB = new Contact();
    InstructorB.LastName = 'testB';
    InstructorB.Active_Count__c=0;
    InstructorB.RecordTypeId=rt.id;
    Database.insert(InstructorB);
    OppB.InstructorName__c = InstructorB.Id;
    Database.insert(OppB);
    Database.update(InstructorB);
    OppB.StageName = 'Active';
    Database.update(OppB);
    Database.update(InstructorB);
    
    //CASE 3 and 5: test instructor name change on an active class--create a new contact and set as instructor
    Contact Instructor2 = new Contact();
    Instructor2.LastName = 'test2';
    Instructor2.Active_Count__c=0;
    Instructor2.RecordTypeId=rt.id;
    Database.insert(Instructor2);
    Opp.StageName='Active';
    Opp.InstructorName__c=Instructor2.Id;
    Database.update(Opp);
    Database.update(Instructor);
    Database.update(Instructor2);
    
    //CASE 4: test an update with stage change from active-inquiry (Active to Not Active)
    Opp.StageName='Active';
    Database.update(Opp);
    Database.update(Instructor);
    Opp.StageName='Inquiry';
    Database.update(Opp);
    Database.update(Instructor); 
            
        
    //CASE 6: test a delete with stage active. first create the record, then delete it and update the contact.  
    Opportunity Opp2 = new Opportunity();
    Opp2.StageName = 'Active';
    Opp2.AccountId = Acc.Id;
    Opp2.Name = 'test2';
    Opp2.CloseDate = Date.today();
    Contact Instructor3 = new Contact();
    Instructor3.Active_Count__c=0;
    Instructor3.RecordTypeId=rt.id;
    Instructor3.LastName = 'test3';
    Opp2.InstructorName__c = Instructor3.Id;
    Database.insert(Instructor3);
    Database.insert(Opp2);
    Database.delete(Opp2);
    Database.update(Instructor3);
    test.startTest();
    test.StopTest();*/
        }
    }