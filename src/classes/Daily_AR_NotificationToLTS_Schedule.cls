/****************
    - Added by HL on June 11 2021
    - Work Item: W-005524 - Progress Reports in DLS Online (JUN 1-2021)
    - To send a daily email notification to LTS related to the "Submitted to LTS" Assessment_Report 
    - This scheduler is used to invoke the Flow and to fix the issue related to, 
        using VF emails do not work when merge fields are used and the context user is Automated Process.
    ******************/
    
public class Daily_AR_NotificationToLTS_Schedule implements Schedulable{

    public void execute(SchedulableContext sc) {
        
        Map<String, Object> params = new Map<String, Object>();
        Flow.Interview.To_Notify_LTS_regarding_Submitted_to_LTS_AR_Recs flow1 = new Flow.Interview.To_Notify_LTS_regarding_Submitted_to_LTS_AR_Recs(params);
        flow1.start();
    }   
}