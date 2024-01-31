public class UpdateChildRecs_Queuable implements Queueable {
    
    private List<AcctSeed__Project_Task__c> ptList;
    private List<Planned_Days_Off__c> daysInsList;
    private List<Planned_Days_Off__c> daysDelList; 
    private List<Opportunity> opp;
    
    public UpdateChildRecs_Queuable(List<AcctSeed__Project_Task__c> ptList, List<Planned_Days_Off__c> daysInsList, List<Planned_Days_Off__c> daysDelList, List<Opportunity> opp) {
        this.ptList = ptList;
        this.daysInsList = daysInsList;
        this.daysDelList = daysDelList;
        this.opp = opp;
    }
    
    public void execute(QueueableContext context) {
        
        try{
            if(opp.size() > 0){
                update opp;
            }
                
            if(ptList.size() > 0){
                update ptList;
            }
           
            if(daysInsList.size() > 0){
                insert daysInsList;
            }
            
            if(daysDelList.size() > 0){
                delete daysDelList;
            }
            
        }catch(Exception e) {
                            
            String errorMessage = '';
            errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
            
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Update Child Recs Queuable');
        } 
    }
}