@isTest
private class EmploymentSectionInsertOppTest{
    private static testMethod void myTest(){/*
    
    Date thisDate = Date.today();
    Date newDate = thisDate.addDays(1);
    
    //CASE 3: insert a Columbia class
    Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
    Account Acc2 = new Account();
    Acc2.Name = 'ESTest Account';
    Database.insert(Acc2);
    Contact InstructorJ = new Contact();
    InstructorJ.LastName = 'EtestJ';
    InstructorJ.Employment_Section__c = null;
    InstructorJ.Next_Availability__c = null;
    InstructorJ.Instructor_Status__c = 'Available';
    InstructorJ.Current_Account__c = null;
    InstructorJ.RecordTypeId=rt.id;
    Database.insert(InstructorJ);
    Opportunity OppJ = new Opportunity();
    OppJ.StageName = 'Active';
    OppJ.Section__c='RA';
    OppJ.Offsite_Location__c = 'Columbia';
    OppJ.Name = 'EtestJ';
    OppJ.AccountId = Acc2.Id;
    OppJ.CloseDate = Date.today();
    OppJ.Instructor_1_End_Date__c = Date.today();
    OppJ.InstructorName__c = InstructorJ.Id;
    Database.insert(OppJ);
    OppJ.Instructor_1_End_Date__c = newDate;
    Database.update(OppJ);
    Database.update(InstructorJ);
    
    //CASE 4: Insert an FSI class
    Contact InstructorI = new Contact();
    InstructorI.LastName = 'EtestI';
    InstructorI.Employment_Section__c = null;
    InstructorI.Next_Availability__c = null;
    InstructorI.Instructor_Status__c = 'Available';
    InstructorI.Current_Account__c = null;
    InstructorI.RecordTypeId=rt.id;
    Database.insert(InstructorI);
    Account Acc3 = [Select Id from Account where Name = 'FSI'];
    Opportunity OppI = new Opportunity();
    OppI.AccountId = Acc3.Id;
    OppI.StageName = 'Active';
    OppI.Name = 'EtestI';
    OppI.CloseDate = Date.today();
    OppI.InstructorName__c = InstructorJ.Id;
    OppI.X2nd_Instructor__c = InstructorI.Id;
    Database.insert(OppI);
    Database.update(InstructorJ);
    Database.update(InstructorI);
    
    //CASE 5: insert/update Tampa active class
    Opportunity OppH = new Opportunity();
    OppH.StageName = 'Active';
    OppH.Offsite_Location__c = 'Tampa';
    OppH.Name = 'EtestH';
    OppH.AccountId = Acc2.Id;
    OppH.CloseDate = Date.today();
    OppH.Instructor_1_End_Date__c = Date.today();
    OppH.InstructorName__c = InstructorJ.Id;
    Database.insert(OppH);
    OppH.Instructor_1_End_Date__c = newDate;
    Database.update(OppH);
    Database.update(InstructorJ);
    
    //CASE 6: insert/update Norfolk active class
    Opportunity OppG = new Opportunity();
    OppG.StageName = 'Active';
    OppG.Offsite_Location__c = 'Norfolk';
    OppG.Name = 'EtestG';
    OppG.AccountId = Acc2.Id;
    OppG.CloseDate = Date.today();
    OppG.Instructor_1_End_Date__c = Date.today();
    OppG.InstructorName__c = InstructorJ.Id;
    Database.insert(OppG);
    OppG.Instructor_1_End_Date__c = newDate;
    Database.update(OppG);
    Database.update(InstructorJ);
    
    //Case 7: Insert active RA class
    Opportunity OppK = new Opportunity();
    OppK.StageName = 'Active';
    OppK.Offsite_Location__c = 'Arlington';
    OppK.Name = 'EtestK';
    OppK.AccountId = Acc2.Id;
    OppK.CloseDate = Date.today();
    OppK.InstructorName__c = InstructorJ.Id;
    OppK.Section__c = 'RA';
    Database.insert(OppK);
    Database.update(InstructorJ);
    
    //Case 8: Insert active EE class
    Opportunity OppL = new Opportunity();
    OppL.StageName = 'Active';
    OppL.Offsite_Location__c = 'Arlington';
    OppL.Name = 'EtestL';
    OppL.AccountId = Acc2.Id;
    OppL.CloseDate = Date.today();
    OppL.InstructorName__c = InstructorJ.Id;
    OppL.Section__c = 'EE';
    Database.insert(OppL);
    Database.update(InstructorJ);
    
    //Case 9: insert active AA class
    Opportunity OppM = new Opportunity();
    OppM.StageName = 'Active';
    OppM.Offsite_Location__c = 'Arlington';
    OppM.Name = 'EtestM';
    OppM.AccountId = Acc2.Id;
    OppM.CloseDate = Date.today();
    OppM.InstructorName__c = InstructorJ.Id;
    OppM.Section__c = 'AA';
    Database.insert(OppM);
    Database.update(InstructorJ);
    
    //Case 10: insert an active AFPAK class
    Opportunity OppN = new Opportunity();
    OppN.StageName = 'Active';
    OppN.Offsite_Location__c = 'Arlington';
    OppN.Name = 'EtestN';
    OppN.AccountId = Acc2.Id;
    OppN.CloseDate = Date.today();
    OppN.InstructorName__c = InstructorJ.Id;
    OppN.Section__c = 'AFPAK';
    Database.insert(OppN);
    Database.update(InstructorJ);
    
    
    //CASE 2: test an insert/update of a Hanover active class with instructor, employment section = Hanover/Columbia
    Opportunity OppB = new Opportunity();
    OppB.StageName = 'Active';
    OppB.Offsite_Location__c = 'Hanover';
    OppB.Name = 'EtestB';
    OppB.AccountId = Acc2.Id;
    OppB.CloseDate = Date.today();
    OppB.Instructor_1_End_Date__c = Date.today();
    OppB.InstructorName__c = InstructorI.Id;
    Database.insert(OppB);
    OppB.Instructor_1_End_Date__c = newDate;
    Database.update(OppB);
    Database.update(InstructorI);
    
    //CASE 1: test an insert of On-Site active class and Account ODNI with instructor
    Account Acc = [Select Id from Account where Name = 'ODNI'];
    Opportunity Opp = new Opportunity();
    Opp.AccountId = Acc.Id;
    Opp.StageName = 'Active';
    Opp.Name = 'Etest';
    Opp.CloseDate = Date.today();
    Opp.Offsite_Location__c = 'Hanover';
    Opp.InstructorName__c = InstructorI.Id;
    Database.insert(Opp);
    Opp.Offsite_Location__c = 'Arlington';
    Database.update(Opp);
    Database.update(InstructorI);
    
    //CASE 6: insert/update other Off-site active class
    Contact InstructorZ = new Contact();
    InstructorZ.LastName = 'EtestZ';
    InstructorZ.Employment_Section__c = null;
    InstructorZ.Next_Availability__c = null;
    InstructorZ.Instructor_Status__c = 'Available';
    InstructorZ.Current_Account__c = null;
    InstructorZ.RecordTypeId=rt.id;
    Database.insert(InstructorZ);
    Opportunity OppZ = new Opportunity();
    OppZ.StageName = 'Active';
    OppZ.Offsite_Location__c = 'NASA';
    OppZ.Name = 'EtestZ';
    OppZ.AccountId = Acc2.Id;
    OppZ.CloseDate = Date.today();
    OppZ.InstructorName__c = InstructorZ.Id;
    Database.insert(OppZ);
    OppZ.Offsite_Location__c = 'Quantico';
    Database.update(OppZ);
    Database.update(InstructorZ);
        
       test.startTest();
    test.StopTest();
        */}
    }