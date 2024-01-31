@isTest
private class Populate_X_Year_Value_In_Metrics_Test{
    
    private static testMethod void myTest(){
    
        Integer cy = Date.today().year();
        Date startDate_CY = Date.newinstance(cy, 01, 01);
        Date endDate_CY = Date.newinstance(cy, 12, 31);
        String cy_Str = String.valueOf(cy); 
        
        Goal__c goal_CY = new Goal__c(Name = cy_Str +' Test Goal', Start_Date__c = startDate_CY, Due_Date__c = endDate_CY);
        insert goal_CY;
        
        Metric__c metric_CY = new Metric__c(Name = cy_Str + ' Test Metric', Goal__c = goal_CY.Id, Start_Date__c = startDate_CY, Due_Date__c = endDate_CY, Metric_Type__c = 'Hours');
        insert metric_CY;
        
        Integer lastYear = Date.today().year()-1;    
        Date startDate_LY = Date.newinstance(lastYear, 01, 01);
        Date endDate_LY = Date.newinstance(lastYear, 12, 31);
        String ly_Str = String.valueOf(lastYear); 
            
        Goal__c goal_LY = new Goal__c(Name = ly_Str+' Test Goal', Start_Date__c = startDate_LY, Due_Date__c = endDate_LY);
        insert goal_LY;
        
        Metric__c metric_LY = new Metric__c(Name = ly_Str + ' Test Metric', Goal__c = goal_LY.Id, Start_Date__c = startDate_LY, Due_Date__c = endDate_LY, Metric_Type__c = 'Hours');
        insert metric_LY;
        
        Test.startTest();
            String CRON_EXP = '0 0 0 1 1 ?';
            Populate_X_Year_Value_In_Metrics sch = new Populate_X_Year_Value_In_Metrics();
            System.schedule('Populate X Year Value In Metrics', CRON_EXP, sch);            
        Test.stopTest();
    }
}