/*****************************************************************
 - Scheduler to execute the Contact assignment status updation based on active project start date / oral exam date
 - Batch name - CAStatusUpdation_FromProject_Batch
 - Batch size should be 1
 - Created by NS on April 24 2019
 - Scheduled to run daily @ AM
******************************************************************/
global class CAStatusUpdate_Schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        CAStatusUpdation_FromProject_Batch statusUpdate = new CAStatusUpdation_FromProject_Batch();
        database.executeBatch(statusUpdate,1);
    }
}