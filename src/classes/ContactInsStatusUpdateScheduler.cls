/******
* Developed by Karthiga on May 18 2017 to call the batch "ContactInsStatusUpdateBatch"
****/

global class ContactInsStatusUpdateScheduler implements Schedulable{

    global void execute(SchedulableContext SC){
        ContactInsStatusUpdateBatch cis1 = new ContactInsStatusUpdateBatch();
        database.executebatch(cis1,1);
    } 
}