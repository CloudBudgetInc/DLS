@isTest
private class GoalsAndMetricsCreation_Scheduler_Test{

    @testSetup static void setupMethod(){
        List<Metric__c> metrics = TestClassUtil.createMetrics();    
    }
    
    private static testMethod void myTest(){
        Integer lastYear = Date.today().year()-1;
        Date startDate_LastYear = Date.newinstance(lastYear, 01, 01);
        Date endDate_LastYear = Date.newinstance(lastYear, 12, 31);
        
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Start_Date__c = :startDate_LastYear AND Due_Date__c = :endDate_LastYear];
        List<Metric__c> metrics = [SELECT Id, Name FROM Metric__c WHERE Goal__c IN : goals];
        
        Test.startTest();
            String CRON_EXP = '0 0 0 1 1 ?';
            GoalsAndMetricsCreation_Scheduler sch = new GoalsAndMetricsCreation_Scheduler();
            System.schedule('Goals And Metrics Creation Scheduler', CRON_EXP, sch);            
        Test.stopTest();
        
        Integer currentYear = Date.today().year();
        Date startDate_CurrentYear = Date.newinstance(currentYear, 01, 01);
        Date endDate_CurrentYear = Date.newinstance(currentYear, 12, 31);
    }
}