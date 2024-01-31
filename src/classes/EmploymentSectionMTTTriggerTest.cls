@isTest
private class EmploymentSectionMTTTriggerTest{
    private static testMethod void myTest(){
    
    
    //CASE 1: test inserting a deployed instructor with status Deployed or To Be Deployed, and AFPAK Hub Location, update instructor +1  
    Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
    MTT_Location__c Loc = New MTT_Location__c();
    Loc.Name = 'NAS Oceana (HUB Norfolk), VA';
    Database.insert(Loc);
    MTT__c M = new MTT__c();
    M.MTT_Location__c = Loc.Id;
    Database.insert(M);
    Deployed_Instructor__c A = new Deployed_Instructor__c();
    A.MTT_Name__c=M.Id;
    A.status__c = 'Deployed';
    Contact Instructor = new Contact();
    Instructor.LastName = 'MTtest';
    Instructor.Employment_Section__c = null;
    Instructor.Next_Availability__c = null;
    Instructor.Instructor_Status__c = null;
    Instructor.Current_Account__c = null;
    Instructor.RecordTypeId=rt.id;
    Database.insert(Instructor);
    A.Contact__c = Instructor.Id;
    Database.insert(A);
    Database.update(Instructor);
    test.startTest();
       
    //CASE 2: test an insert with status Deployed or To Be Deployed, and other location, instructor +1 
     MTT_Location__c Loc2 = New MTT_Location__c();
     Loc.Name = 'Test Location';
     Database.insert(Loc2);
     MTT__c M2 = new MTT__c();
     M2.MTT_Location__c = Loc2.Id;
     Database.insert(M2);
     Deployed_Instructor__c B = new Deployed_Instructor__c();
     B.status__c = 'To Be Deployed';
     B.MTT_Name__c=M2.Id;
    Contact InstructorB = new Contact();
    InstructorB.LastName = 'MTtestB';
    InstructorB.Employment_Section__c = null;
    InstructorB.Next_Availability__c = null;
    InstructorB.Instructor_Status__c = null;
    InstructorB.Current_Account__c = null;
    InstructorB.RecordTypeId=rt.id;
    Database.insert(InstructorB);
    B.Contact__c = InstructorB.Id;
    Database.insert(B);
    Database.update(InstructorB);
        
    //CASE 4: test update and Not Deployed to Deployed and Hub Location        
    MTT_Location__c Loc3 = New MTT_Location__c();
    Loc3.Name = 'NAS Oceana (HUB Norfolk), VA';
    Database.insert(Loc3);
    MTT__c M3 = new MTT__c();
    M3.MTT_Location__c = Loc3.Id;
    Database.insert(M3);
    Deployed_Instructor__c C = new Deployed_Instructor__c();
    C.MTT_Name__c=M.Id;
    C.status__c = 'Not Deployed';
    Contact Instructor3 = new Contact();
    Instructor3.LastName = 'MTtest3';
    Instructor3.Employment_Section__c = null;
    Instructor3.Next_Availability__c = null;
    Instructor3.Instructor_Status__c = null;
    Instructor3.Current_Account__c = null;
    Instructor3.RecordTypeId=rt.id;
    Database.insert(Instructor3);
    C.Contact__c = Instructor3.Id;
    Database.insert(C);
    Database.update(Instructor3);
    C.Status__c = 'Deployed';
    Database.update(C);
    Database.update(Instructor3);
    C.Status__c = 'Not Deployed';
    Database.update(C);
    Database.update(Instructor3);
    C.Status__c = 'To Be Deployed';
    Database.update(C);
    Database.update(Instructor3);
   
    //CASE 5: test update and Deployed to Not Deployed, other location
    /*MTT_Location__c Loc4 = New MTT_Location__c();
    Loc4.Name = 'Test Location 2';
    Database.insert(Loc4);
    MTT__c M4 = new MTT__c();
    M4.MTT_Location__c = Loc4.Id;
    Database.insert(M4);
    Deployed_Instructor__c D = new Deployed_Instructor__c();
    D.MTT_Name__c=M4.Id;
    D.status__c = 'Not Deployed';
    Contact Instructor4 = new Contact();
    Instructor4.LastName = 'MTtest4';
    Instructor4.Employment_Section__c = null;
    Instructor4.Next_Availability__c = null;
    Instructor4.Instructor_Status__c = null;
    Instructor4.Current_Account__c = null;
    Instructor4.RecordTypeId=rt.id;
    Database.insert(Instructor4);
    D.Contact__c = Instructor4.Id;
    Database.insert(D);
    Database.update(Instructor4);
    D.Status__c = 'Deployed';
    Database.update(D);
    Database.update(Instructor4);
    D.Status__c = 'Not Deployed';
    Database.update(D);
    Database.update(Instructor4);
    D.Status__c = 'To Be Deployed';
    Database.update(D);
    Database.update(Instructor4);*/
       
    test.StopTest();
        }
    }