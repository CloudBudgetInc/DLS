@isTest
private class Daily_AR_NotificationToLTS_Schedule_Test{

    private static testMethod void myTest(){
    
        // Schedule coverage
        String CRON_EXP = '0 0 10 * * ?';
        Daily_AR_NotificationToLTS_Schedule sch = new Daily_AR_NotificationToLTS_Schedule();
        system.schedule('Daily AR Notification To LTS', CRON_EXP, sch);
    }
}