/**********
    - W-007700 - DODA End of Training GetFeedback Survey (MAR-1-2023)
    - To send GetFeedback Survey email to the Students for DODA Projects on the Project End Date
    - This scheduler runs on daily basis at 5 PM
    **********/
public class DODA_EOT_GetFeedback_Survey_Email implements Schedulable {    

    public void execute(SchedulableContext sc) {
                
        DODA_EOT_GetFeedback_Survey_Email_Batch doda_EOT_Email = new DODA_EOT_GetFeedback_Survey_Email_Batch();
        Database.executeBatch(doda_EOT_Email, 50);
    }    
}