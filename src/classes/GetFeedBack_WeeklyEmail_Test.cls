@isTest
private class GetFeedBack_WeeklyEmail_Test {
    
    @testSetup static void setup(){
     
        List<AcctSeed__Project__c> getpro = TestClassUtil.createTestProject();
        
     //   List<Holiday> holi = TestClassUtil.createTestHoliday();
        
    }
    static testmethod void test() {

        Test.startTest();
         
           /*** List<Opportunity> oppList = [SELECT Id,Name,Start_Date__c FROM Opportunity LIMIT 3]; 
            oppList[0].Start_Date__c = oppList[0].Start_Date__c.addDays(-14);
            update OppList[0]; ***/
            
            List<Holiday> holiList = [SELECT Id, Name, Activitydate FROM Holiday];
            
            //Added
            List<AcctSeed__Project__c> proList = [SELECT Id, Name, Start_Date__c FROM AcctSeed__Project__c LIMIT 3];
            proList[0].Start_Date__c = proList[0].Start_Date__c.addDays(-14);
            proList[1].Start_Date__c = proList[0].Start_Date__c.addDays(-15);
            proList[2].Start_Date__c = proList[0].Start_Date__c.addDays(-16);
            update proList;
            //Ended
            
            Datetime dt = Datetime.now().addMinutes(1);
            String sch = dt.format('s m H d M \'?\' yyyy');
            String jobID = system.schedule('Test Schedule', sch, new GetFeedBack_WeeklyEmail());
            
        Test.stopTest();
}

    
}