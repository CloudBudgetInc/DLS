// This scheduler to execute the ScheduleStatusUpdate_ToCompleted daily
// scheduled on ('0 0 6 * * ?')

global class ScheduleStatusUpdateScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        ScheduleStatusUpdate_ToCompleted schCom = new ScheduleStatusUpdate_ToCompleted();
        database.executebatch(schCom, 10);
    }
}