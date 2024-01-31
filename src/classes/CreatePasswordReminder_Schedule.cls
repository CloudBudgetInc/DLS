/****************
    - Added by HL on Aug 30 2019
    - To send an email notification to user regarding Reminder to create password
    - This scheduler runs daily basis
    ******************/

public class CreatePasswordReminder_Schedule implements Schedulable{

    public void execute(SchedulableContext sc) {
    
        List<User> users = UserManagementUtil.getUsersToCreatePassword();
        
        if(users != NULL && users.size() > 0){
            UserManagementUtil.reminderToCreatePassword(users);
        }
    }
}