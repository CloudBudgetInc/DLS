@isTest
private class DepInstrTriggerTest{
    private static testMethod void myTest(){
    
    //CASE 1: test inserting a deployed instructor with status Deployed, update instructor +1  
    Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
    MTT__c M = new MTT__c();
    Database.insert(M);
    Deployed_Instructor__c A = new Deployed_Instructor__c();
    A.MTT_Name__c=M.Id;
    A.status__c = 'Deployed';
    Contact Instructor = new Contact();
    Instructor.LastName = 'MTTtest';
    Instructor.Employment_Section__c = null;
    Instructor.Next_Availability__c = null;
    Instructor.Instructor_Status__c = null;
    Instructor.Current_Account__c = null;
    Instructor.RecordTypeId=rt.id;
    Database.insert(Instructor);
    A.Contact__c = Instructor.Id;
    Database.insert(A);
    Database.update(Instructor);
    
       
    //CASE 2: test an insert with status To Be Deployed, instructor +1 (still reserve as busy)
     Deployed_Instructor__c B = new Deployed_Instructor__c();
     B.status__c = 'To Be Deployed';
     B.MTT_Name__c=M.Id;
    Contact InstructorB = new Contact();
    InstructorB.LastName = 'MTTtestB';
    Instructor.Employment_Section__c = null;
    Instructor.Next_Availability__c = null;
    Instructor.Instructor_Status__c = null;
    Instructor.Current_Account__c = null;
    InstructorB.RecordTypeId=rt.id;
    Database.insert(InstructorB);
    B.Contact__c = InstructorB.Id;
    Database.insert(B);
    Database.update(InstructorB);
        
    //CASE 3: test update and Not Deployed to Deployed        
    B.status__c = 'Deployed';
    Database.update(B);
    Database.update(InstructorB);
                       
    //CASE 4: test update and Deployed to Not Deployed
    B.status__c = 'Not Deployed';
    Database.update(B);
    Database.update(InstructorB);
    
    //CASE 5: test delete of deployed instructor with status "Deployed", instructor -1        
    Deployed_Instructor__c C = new Deployed_Instructor__c();
    C.status__c = 'Deployed';
    C.MTT_Name__c=M.Id;
    Contact InstructorC = new Contact();
    InstructorC.LastName = 'MTTtest3';
    Instructor.Employment_Section__c = null;
    Instructor.Next_Availability__c = null;
    Instructor.Instructor_Status__c = null;
    Instructor.Current_Account__c = null;
    InstructorC.RecordTypeId=rt.id;
    Database.insert(InstructorC);
    A.Contact__c = InstructorC.Id;
    Database.insert(C);
    Database.delete(C);
    Database.update(InstructorC);
    test.startTest();
    test.StopTest();
        }
    }