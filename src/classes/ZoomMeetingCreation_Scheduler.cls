/*******************************************************************************
- class for scheduling Zoom meeting creation batch for Events with room as 'DLS - Online'
- Created by Dhinesh - W-006013 - Zoom Integration
- Scheduled for every 1 hr
*******************************************************************************/
public class ZoomMeetingCreation_Scheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        ZoomMeetingCreationBatch meetingCreationBatch = new ZoomMeetingCreationBatch();
        Database.executeBatch(meetingCreationBatch, 1);
    }
}