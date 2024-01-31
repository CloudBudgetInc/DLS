/*****************

    - Added by HL on Sep 04 2019
    - Work Item :  W-001476 - Community User Login Experience (Login, Logout, New User Welcome Emails, Password Resets, etc.
    - To create task records based on Contact's Beta Group flag for student & instructor community user creation
    - To avoid "MIXED_DML_OPERATION, DML operation on setup object is not permitted Error" created this Queueable class
    ***************/
public class CreateTaskforContact implements Queueable {
    
    private List<Task> taskList;
    List<Contact> contactForUpdate;
    
    public CreateTaskforContact(List<Task> taskList,List<Contact> contactForUpdate) {
        this.taskList = taskList;
        this.contactForUpdate = contactForUpdate;
    }
    
    public void execute(QueueableContext context) {
        
        if(taskList.size() > 0){
            insert taskList;
        }
        
        //update contact's Active DLS Online User flag based on user's active field
        system.debug('::::inside:::queueable:::::contactForUpdate:::::'+contactForUpdate);
        
        if(contactForUpdate.size() > 0){
            update contactForUpdate;
        }
        
    }
}