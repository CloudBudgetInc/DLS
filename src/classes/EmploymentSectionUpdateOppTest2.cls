@isTest
private class EmploymentSectionUpdateOppTest2{
    private static testMethod void myTest(){
    
    Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
    Account Acc2 = new Account();
    Acc2.Name = 'Test Account';
    Database.insert(Acc2);
    
    //CASE 11: test update and AFPAK class
    Contact InstructorD = new Contact();
    InstructorD.LastName = '2testD';
    InstructorD.Employment_Section__c = null;
    InstructorD.Next_Availability__c = null;
    InstructorD.Instructor_Status__c ='Available';
    InstructorD.Current_Account__c = null;
    InstructorD.RecordTypeId=rt.id;
    Database.insert(InstructorD);
    Opportunity OppD = new Opportunity();
    OppD.AccountId = Acc2.Id;
    OppD.StageName = 'Active';
    OppD.Offsite_Location__c = 'Arlington';
    OppD.Name = '2testD';
    OppD.CloseDate = Date.today();
    OppD.X2nd_Instructor__c = InstructorD.Id;
    Database.insert(OppD);
    OppD.Name='2test12';
    OppD.Section__c='AFPAK';
    oppD.Supervisor__c = userInfo.getUserId();
    Database.update(OppD);
    Database.update(InstructorD);
    
    //CASE 10: Test update and RA class
    Contact InstructorE = new Contact();
    InstructorE.LastName = '2testE';
    InstructorE.Employment_Section__c = null;
    InstructorE.Next_Availability__c = null;
    InstructorE.Instructor_Status__c = 'Available';
    InstructorE.Current_Account__c = null;
    InstructorE.RecordTypeId=rt.id;
    Database.insert(InstructorE);
    Opportunity OppE = new Opportunity();
    OppE.AccountId = Acc2.Id;
    OppE.StageName = 'Active';
    OppE.Offsite_Location__c = 'Hanover';
    OppE.Name = '2testE';
    OppE.Section__c='RA';
    OppE.CloseDate = Date.today();
    OppE.X2nd_Instructor__c = InstructorE.Id;
    oppe.Supervisor__c = userInfo.getUserId();
    Database.insert(OppE);
    OppE.Name='2test14';
    OppE.Offsite_Location__c = 'Arlington';
    Database.update(OppE);
    Database.update(InstructorE);
    OppE.X2nd_Instructor__c = InstructorD.Id;
    Database.update(OppE);
    Database.update(InstructorE);
    Database.update(InstructorD);  
    test.startTest();
    //CASE 9: test update and state Active, section EE, Arlington 
    Contact InstructorF = new Contact();
    InstructorF.LastName = '2testF';
    InstructorF.Employment_Section__c = null;
    InstructorF.Next_Availability__c = null;
    InstructorF.Instructor_Status__c = 'Available';
    InstructorF.Current_Account__c = null;
    InstructorF.RecordTypeId=rt.id;
    Database.insert(InstructorF);
    Opportunity OppF = new Opportunity();
    OppF.AccountId = Acc2.Id;
    OppF.StageName = 'Active';
    OppF.Offsite_Location__c = 'Hanover';
    OppF.Name = '2testF';
    OppF.Section__c='EE';
    OppF.CloseDate = Date.today();
    OppF.X2nd_Instructor__c = InstructorF.Id;
    oppF.Supervisor__c = userInfo.getUserId();
    Database.insert(OppF);
    OppF.Name='2test15';
    OppF.Offsite_Location__c = 'Arlington';
    Database.update(OppF);
    Database.update(InstructorF);
    Database.delete(OppF);
    Database.update(InstructorF);
        
    //CASE 8: Test update and stage active, section AA, Arlington
    Contact InstructorC = new Contact();
    InstructorC.LastName = '2testC';
    InstructorC.Employment_Section__c = null;
    InstructorC.Next_Availability__c = null;
    InstructorC.Instructor_Status__c = 'Available';
    InstructorC.Current_Account__c = null;
    InstructorC.RecordTypeId=rt.id;
    Database.insert(InstructorC);
    Opportunity OppC = new Opportunity();
    OppC.AccountId = Acc2.Id;
    OppC.StageName = 'Active';
    OppC.Offsite_Location__c = 'Hanover';
    OppC.Name = '2testC';
    OppC.Section__c='AA';
    OppC.Language__c= 'Japanese';
    OppC.CloseDate = Date.today();
    OppC.X2nd_Instructor__c = InstructorC.Id;
    oppc.Supervisor__c = userInfo.getUserId();
    Database.insert(OppC);
    OppC.Name='2test2';
    OppC.Offsite_Location__c = 'Arlington';
    Database.update(OppC);
    Database.update(InstructorC);
    OppC.StageName = 'Ended';
    Database.update(OppC);
    Database.update(InstructorC);
                   
    test.StopTest();
        }
    }