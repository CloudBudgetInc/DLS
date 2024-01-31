public class CreateAndDeleteTaskforCA implements Queueable {
    private List<Task> taskListToCreate;
    private List<Task> taskListToDelete;
    
    public CreateAndDeleteTaskforCA(List<Task> tasksToCreate, List<Task> tasksToDelete) {
        this.taskListToCreate = tasksToCreate;
        this.taskListToDelete = tasksToDelete;
    }
    public void execute(QueueableContext context) {
        if(taskListToCreate.size() > 0){
            insert taskListToCreate;
        }
        if(taskListToDelete.size() > 0){
            delete taskListToDelete;
        }
    }
}