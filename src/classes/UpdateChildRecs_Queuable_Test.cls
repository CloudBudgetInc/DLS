@isTest
private class UpdateChildRecs_Queuable_Test {
   
    @testsetup static void setup() { 
    
        Test.StartTest();
            List<Contact_Assignments__c> conAssList = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
        
        List<Schedule__c> schTask = TestClassUtil.createTestSchedule();          
    }
    
    // For Contact Assignment, Schedule, Project Task, PlannedDaysOff, Project and Opportunity records Updation and PlannedDayOff deletion
    private static testMethod void testMethod1() {
       
        List<AcctSeed__Project__c> pro = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 2];
        List<Opportunity> opp = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<AcctSeed__Project_Task__c> proTask = [SELECT Id, Name FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :pro LIMIT 2];
        List<Contact> con = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
      
        List<Planned_Days_Off__c> pdoDel = new List<Planned_Days_Off__c> {
            new Planned_Days_Off__c(Opportunity__c = opp[0].Id, Contact__c = con[0].Id, Date__c = System.today().addDays(-1), Description__c = 'Test2')
        };
        insert pdoDel;
        
        List<Planned_Days_Off__c> pdoIn = new List<Planned_Days_Off__c> {
            new Planned_Days_Off__c(Opportunity__c = opp[0].Id, Contact__c = con[0].Id, Date__c = System.today().addDays(-1), Description__c = 'Test1')
        };
        
        UpdateChildRecs_Queuable update_ChildRec = new UpdateChildRecs_Queuable(proTask, pdoIn, pdoDel, opp);
        Test.startTest();
            System.enqueueJob(update_ChildRec);
        Test.stopTest();
                
    }
    
     // To cover try - catch block in UpdateProject_Queuable
    private static testMethod void UpdateProject_Queuable_Test() {
       
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Inquiry', Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(90), AccountId = accList[0].Id, CloseDate = System.Today().addDays(20));
        opps.add(opp);
        
        UpdateChildRecs_Queuable update_ChildRec = new UpdateChildRecs_Queuable(new List<AcctSeed__Project_Task__c>(), new List<Planned_Days_Off__c>(), new List<Planned_Days_Off__c>(), opps);
        Test.startTest();
            System.enqueueJob(update_ChildRec);
        Test.stopTest();          
    }
}