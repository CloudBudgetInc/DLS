@isTest(seeAllData = TRUE)
private class TestpopulateSupervisorTrigger {

    static testMethod void populateSupervisorTriggerTestMethod() {     
       
        List<User> userList = [SELECT Id FROM User];
        
        List<Supervisor_Assignment_CS__c> supervisorAssList = new List<Supervisor_Assignment_CS__c>{
            new Supervisor_Assignment_CS__c(Name = 'test1', Classification__c = 'OF:LT:OTH', Section__c = 'EE', Supervisor__c = userList[0].Id),
            new Supervisor_Assignment_CS__c(Name = 'test2', Classification__c = 'OF:LT:OTH', Section__c = 'RA', Supervisor__c = userList[1].Id)
        };
        insert supervisorAssList;
        
        List<Opportunity> oppList = new List<Opportunity> {
            new opportunity(Name = 'testopp', StageName = 'Qualification', CloseDate = System.today(), Classification__c = 'OF:LT:OTH', Section__c = 'EE')
        };
        insert oppList;   
        
        oppList[0].Section__c = 'RA';
        update oppList;
    }
}