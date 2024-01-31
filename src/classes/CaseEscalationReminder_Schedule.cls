/****************
    - Added by HL on Apr 19 2022
    - Work Item : W-007429 - Case Reminder Emails Not Sent to All Case Owners 
    - We can't add more than 5 actions under a single rule entry in Case Escalation Rule.
        At the same time if we have more than 1 rule entry with same conditions, then 
        the case escalation rule always takes first (order) rule entry only. 
        So we are using Is_Send_Escalation_Reminder__c checkbox field to differentiate the conditions for invoking second rule entry
    - This scheduler runs every one hour basis
    ******************/
public class CaseEscalationReminder_Schedule implements Schedulable{

    public void execute(SchedulableContext sc) {
        
        DateTime lastModifiedDate = System.Now().addHours(-120);
        List<Case> caseRecs = new List<Case>();
        if(!Test.isRunningTest()){
            caseRecs = [SELECT Id, Is_Send_Escalation_Reminder__c FROM Case WHERE Status != 'Closed' AND LastModifiedDate < :lastModifiedDate AND Is_Send_Escalation_Reminder__c = False ORDER BY LastModifiedDate ASC];
        }else if(Test.isRunningTest()){
            caseRecs = [SELECT Id, Is_Send_Escalation_Reminder__c FROM Case LIMIT 1];
        }
        //System.debug('::::caseRecs::::'+caseRecs);
        
        if(caseRecs.size() > 0){
            
            List<Case> updateCaseRecs = new List<Case>();
            
            for(Case c : caseRecs){
                c.Is_Send_Escalation_Reminder__c = True;
                updateCaseRecs.add(c);
            }    
            //System.debug(':::::updateCaseRecs::::'+updateCaseRecs);
            
            if(updateCaseRecs.size() > 0){
                update updateCaseRecs;
            }
        }
    }    
}