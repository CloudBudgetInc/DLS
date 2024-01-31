@isTest
private class EmploymentSectionInsertOppTest2{
    private static testMethod void myTest(){
    test.startTest();
    Date thisDate = Date.today();
    Date newDate = thisDate.addDays(1);
    
    //CASE 3: insert a Columbia class
    Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
    Account Acc2 = new Account();
    Acc2.Name = 'Test Account';
    Database.insert(Acc2);
    Contact InstructorJ = new Contact();
    InstructorJ.LastName = 'ItestJ';
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
    OppJ.Name = 'ItestJ';
    OppJ.AccountId = Acc2.Id;
    OppJ.CloseDate = Date.today();
    OppJ.Instructor_2_End_Date__c = Date.today();
    OppJ.X2nd_Instructor__c = InstructorJ.Id;
    oppJ.Supervisor__c = Userinfo.getUserID();
    Database.insert(OppJ);
    OppJ.Instructor_2_End_Date__c = newDate;
    Database.update(OppJ);
    Database.update(InstructorJ);
    test.StopTest();    
    /*
    //CASE 5: insert/update Tampa active class
    Contact InstructorH = new Contact();
    InstructorH.LastName = 'ItestH';
    InstructorH.Employment_Section__c = null;
    InstructorH.Next_Availability__c = null;
    InstructorH.Instructor_Status__c = 'Available';
    InstructorH.Current_Account__c = null;
    InstructorH.RecordTypeId=rt.id;
    Database.insert(InstructorH);
    Opportunity OppH = new Opportunity();
    OppH.StageName = 'Active';
    OppH.Offsite_Location__c = 'Tampa';
    OppH.Name = 'ItestH';
    OppH.AccountId = Acc2.Id;
    OppH.CloseDate = Date.today();
    OppH.Instructor_2_End_Date__c = Date.today();
    OppH.X2nd_Instructor__c = InstructorH.Id;
    OppH.Supervisor__c = Userinfo.getUserID();
    Database.insert(OppH);
    OppH.Instructor_2_End_Date__c = newDate;
    Database.update(OppH);
    Database.update(InstructorH);
        
    //CASE 6: insert/update Norfolk active class
    Contact InstructorG = new Contact();
    InstructorG.LastName = 'ItestG';
    InstructorG.Employment_Section__c = null;
    InstructorG.Next_Availability__c = null;
    InstructorG.Instructor_Status__c = 'Available';
    InstructorG.Current_Account__c = null;
    InstructorG.RecordTypeId=rt.id;
    Database.insert(InstructorG);
    Opportunity OppG = new Opportunity();
    OppG.StageName = 'Active';
    OppG.Offsite_Location__c = 'Norfolk';
    OppG.Name = 'ItestG';
    OppG.AccountId = Acc2.Id;
    OppG.CloseDate = Date.today();
    OppG.Instructor_2_End_Date__c = Date.today();
    OppG.X2nd_Instructor__c = InstructorG.Id;
    oppG.Supervisor__c = Userinfo.getUserID();
    Database.insert(OppG);
    OppG.Instructor_2_End_Date__c = newDate;
    Database.update(OppG);
    Database.update(InstructorG);
    
    //Case 7: Insert active RA class
    Opportunity OppK = new Opportunity();
    OppK.StageName = 'Active';
    OppK.Offsite_Location__c = 'Arlington';
    OppK.Name = 'ItestK';
    OppK.AccountId = Acc2.Id;
    OppK.CloseDate = Date.today();
    OppK.X2nd_Instructor__c = InstructorG.Id;
    OppK.Section__c = 'RA';
    OppK.Supervisor__c = Userinfo.getUserID();
    Database.insert(OppK);
    Database.update(InstructorG);
    
    //Case 8: Insert active EE class
    Opportunity OppL = new Opportunity();
    OppL.StageName = 'Active';
    OppL.Offsite_Location__c = 'Arlington';
    OppL.Name = 'ItestL';
    OppL.AccountId = Acc2.Id;
    OppL.CloseDate = Date.today();
    OppL.X2nd_Instructor__c = InstructorG.Id;
    OppL.Section__c = 'EE';
    oppL.Supervisor__c = Userinfo.getUserID();
    Database.insert(OppL);
    Database.update(InstructorG);
    
    //Case 9: insert active AA class
    Opportunity OppM = new Opportunity();
    OppM.StageName = 'Active';
    OppM.Offsite_Location__c = 'Arlington';
    OppM.Name = 'ItestM';
    OppM.AccountId = Acc2.Id;
    OppM.CloseDate = Date.today();
    OppM.X2nd_Instructor__c = InstructorG.Id;
    OppM.Section__c = 'AA';
    OppM.Supervisor__c = Userinfo.getUserID();
    Database.insert(OppM);
    Database.update(InstructorG);
    
    //Case 10: insert an active AFPAK class
    Opportunity OppN = new Opportunity();
    OppN.StageName = 'Active';
    OppN.Offsite_Location__c = 'Arlington';
    OppN.Name = 'ItestN';
    OppN.AccountId = Acc2.Id;
    OppN.CloseDate = Date.today();
    OppN.X2nd_Instructor__c = InstructorG.Id;
    OppN.Section__c = 'AFPAK';
    OppN.Supervisor__c = Userinfo.getUserID();
    Database.insert(OppN);
    Database.update(InstructorG);
    
    
    //CASE 2: test an insert/update of a Hanover active class with instructor, employment section = Hanover/Columbia
    Contact InstructorB = new Contact();
    InstructorB.LastName = 'ItestB';
    InstructorB.Employment_Section__c = null;
    InstructorB.Next_Availability__c = null;
    InstructorB.Instructor_Status__c = 'Available';
    InstructorB.Current_Account__c = null;
    InstructorB.RecordTypeId=rt.id;
    Database.insert(InstructorB);
    Opportunity OppB = new Opportunity();
    OppB.StageName = 'Active';
    OppB.Offsite_Location__c = 'Hanover';
    OppB.Name = 'ItestB';
    OppB.AccountId = Acc2.Id;
    OppB.CloseDate = Date.today();
    OppB.Instructor_2_End_Date__c = Date.today();
    OppB.X2nd_Instructor__c = InstructorB.Id;
    oppB.Supervisor__c = Userinfo.getUserID();
    Database.insert(OppB);
    OppB.Instructor_2_End_Date__c = newDate;
    Database.update(OppB);
    Database.update(InstructorB);
    
    //CASE 1: test an insert of On-Site active class and Account ODNI with instructor
    Contact Instructor = new Contact();
    Instructor.LastName = 'Itest';
    Instructor.Employment_Section__c = null;
    Instructor.Next_Availability__c = null;
    Instructor.Instructor_Status__c = 'Available';
    Instructor.Current_Account__c = null;
    Instructor.RecordTypeId=rt.id;
    Database.insert(Instructor);
    Account Acc = new Account ();
    Acc.Name = 'ODNI';
    Database.insert(Acc);
    Opportunity Opp = new Opportunity();
    Opp.AccountId = Acc.Id;
    Opp.StageName = 'Active';
    Opp.Name = 'Itest';
    Opp.CloseDate = Date.today();
    Opp.Offsite_Location__c = 'Hanover';
    Opp.X2nd_Instructor__c = Instructor.Id;
    opp.Supervisor__c = Userinfo.getUserID();
    Database.insert(Opp);
    Opp.Offsite_Location__c = 'Arlington';
    Database.update(Opp);
    Database.update(Instructor);
    
    //CASE 6: insert/update other Off-site active class
    Opportunity OppZ = new Opportunity();
    OppZ.StageName = 'Active';
    OppZ.Offsite_Location__c = 'NASA';
    OppZ.Name = 'ItestZ';
    OppZ.AccountId = Acc2.Id;
    oppz.Supervisor__c = Userinfo.getUserID();
    OppZ.CloseDate = Date.today();
    Contact InstructorZ = new Contact();
    InstructorZ.LastName = 'ItestZ';
    InstructorZ.Employment_Section__c = null;
    InstructorZ.Next_Availability__c = null;
    InstructorZ.Instructor_Status__c = 'Available';
    InstructorZ.Current_Account__c = null;
    InstructorZ.RecordTypeId=rt.id;
    Database.insert(InstructorZ);
    OppZ.X2nd_Instructor__c = InstructorZ.Id;
    Database.insert(OppZ);
    OppZ.Offsite_Location__c = 'Quantico';
    Database.update(OppZ);
    Database.update(InstructorZ);
       */ 
        }
    }