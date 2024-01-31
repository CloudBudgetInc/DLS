@isTest
private class CreateAmortizationEntriesSchedule_Test {
    
    // For Amortization Entries Schedule
    private static testMethod void testMethod1() {
        Datetime dt = Datetime.now().addMinutes(2);
        String cronExpr = dt.format('s m H d M \'?\' yyyy');
        createAmortizationEntriesSchedule sch = new createAmortizationEntriesSchedule();
        String jobId = System.schedule('myJobTestJobName', cronExpr, sch);
    }
}