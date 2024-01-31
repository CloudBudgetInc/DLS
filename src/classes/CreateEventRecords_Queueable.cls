public class CreateEventRecords_Queueable implements Queueable {
    
    private Set<Id> scheduleIdSet;
    
    public CreateEventRecords_Queueable(Set<Id> scheduleIds) {
        this.scheduleIdSet = scheduleIds;
    }
    
    public void execute(QueueableContext context) {
        EventHandler.handleEventRecords(scheduleIdSet);
    }
}