@isTest
private class ScheduleStatusUpdateScheduler_Test {
    
    // For executig the ScheduleStatusUpdate_ToCompleted daliy
    private static testMethod void testMethod1() {
        
        Datetime dt = Datetime.now().addMinutes(2);
        String cronExpr = dt.format('s m H d M \'?\' yyyy');
        ScheduleStatusUpdateScheduler sch = new ScheduleStatusUpdateScheduler();
        String jobId = System.schedule('myJobTestJobName', cronExpr, sch);
        
    }
}