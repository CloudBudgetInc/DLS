@isTest
private class TestChangeStatusLinguistAssignment{
    private static testMethod void myTest(){
    
    Recordtype rt = [Select ID from RecordType where name = 'Candidate' and SObjectType = 'Contact'];
    Recordtype rt2 = [Select ID from RecordType where name = 'Translation Opportunities' and SObjectType = 'Opportunity'];
    
    Account Acc = new Account();
    Acc.Name = 'T and I test account';
    Database.insert(Acc);
    
    Opportunity Opp = new Opportunity();
    Opp.RecordTypeId = rt2.id;
    Opp.Name = 'Translation test2';
    Opp.CloseDate = Date.today();
    Opp.StageName = 'Closed Won';
    opp.Supervisor__c = userInfo.getUserId();
    Database.insert(opp);
    
    //Case 1: test an update of Linguist from active to ended
    Linguist_Assignment__c A = new Linguist_Assignment__c();
    A.status__c = 'Active';
    A.End_Date__c = Date.today();
    A.Opportunity_Name__c = Opp.Id;
    Contact Linguist= new Contact();
    Linguist.LastName = 'LAtest';
    Linguist.Employment_Section__c = null;
    Linguist.Next_Availability__c = null;
    Linguist.Current_Account__c = null;
    Linguist.Instructor_Status__c = 'Available';
    Linguist.RecordTypeId = rt.id;
    Database.insert(linguist);
    A.Linguist_Name__c = Linguist.Id;
    Database.insert(A);
    Database.update(linguist);
    A.Status__c = 'Ended';
    Database.update(A);
    Database.update(linguist);
    
    //Case 2: test an update of Linguist from ended to active
    
    A.Status__c = 'Active';
    Database.update(A);
    Database.update(linguist);
    
    //Case 3: test a delete with status active
    Database.delete(A);
    Database.update(linguist);
    
    test.startTest();
    test.StopTest();
    }
  }