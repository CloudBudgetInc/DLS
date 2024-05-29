/*******************
    - W-007955 : Adjust Moodle Course Delete to Fit OpenLMS Requirements
    - To delete the courses in Moodle
    - Created on Jan 10 2024
    - In Zapier we faced callout timeout exception for Moodle Course Deletion API. So Course Deletion API logic moved from Zapier to Salesforce.
    - This scheduler runs on daily basis
    - Cron Expression Info:
        MoodleCourseDeletion_Scheduler  sch2 = new MoodleCourseDeletion_Scheduler(); 
        String sch = '0 0 3 * * ?'; 
        system.schedule('Moodle Course Deletion on Daily @ 3 AM EST', sch, sch2);
    *****************************/
public class MoodleCourseDeletion_Scheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        MoodleCourseDeletionBatch deleteCourse = new MoodleCourseDeletionBatch();
        Database.executeBatch(deleteCourse, 1);
    }
}