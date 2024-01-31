public class UpdateProject_Queuable implements Queueable {
    
    private List<AcctSeed__Project__c> projRec;
    private List<AcctSeed__Project_Task__c> ptList;
    private List<Planned_Days_Off__c> daysInsList;
    private List<Planned_Days_Off__c> daysDelList; 
    private List<Assessment_Report__c> assessmentReports;
    private List<Opportunity> opp;
    
    public UpdateProject_Queuable(List<AcctSeed__Project__c> projRec, List<AcctSeed__Project_Task__c> ptList, List<Planned_Days_Off__c> daysInsList, List<Planned_Days_Off__c> daysDelList, List<Assessment_Report__c> assessmentReports, List<Opportunity> opp) {
        this.projRec = projRec;
        this.ptList = ptList;
        this.daysInsList = daysInsList;
        this.daysDelList = daysDelList;
        this.assessmentReports = assessmentReports;
        this.opp = opp;
    }
    
    public void execute(QueueableContext context) {
        
        try{
        
            if(projRec.size() > 0){
            
                ManageProjectDatescontroller.makeStatusAsEnded = True;
                ManageProjectDatescontroller.makeStatusAsActive = True;
                ManageProjectDatescontroller.skipCAStatusUpdate = True;
                update projRec;
                
                // Modified on Mar 29 2023 - W-007683 : Final PR Auto- Creation Duplicate Issue on PVT Projects
                // To fix duplicate assessment report creation when project's end date is updated
                if(assessmentReports.size() > 0){
                    update assessmentReports;
                }
            }
            System.debug('::projRec:::'+projRec);
            
            if(!Test.isRunningTest()){
                UpdateChildRecs_Queuable update_ChildRec = new UpdateChildRecs_Queuable(ptList, daysInsList, daysDelList, opp);
                Id jobID = System.enqueueJob(update_ChildRec);
            }
        }catch(Exception e) {
                            
            String errorMessage = '';
            errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
            
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Update Project Queuable');
        } 
    }
}