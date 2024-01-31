@isTest

private class SendEmailAECreationListSchedule_Test {
    
    private static testMethod void testMethod1() {
    
        Datetime dt = Datetime.now().addMinutes(2);
        String cronExpr = dt.format('s m H d M \'?\' yyyy');
        SendEmailAECreationListSchedule sch = new SendEmailAECreationListSchedule();
        String jobId = System.schedule('myJobTestJobName', cronExpr, sch);
    }
}