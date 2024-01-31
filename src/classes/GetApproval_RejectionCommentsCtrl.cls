public class GetApproval_RejectionCommentsCtrl{
    
    public String pdoId;
    public String comments { get; set; }
    public String stepStatus { get; set; }
    
    public String getpdoId(){ return pdoId;}
            
    public void setpdoId(String pdoIdVal){
        pdoId = pdoIdVal;
        getApprovalRejectionComments();
    }
    
    public void getApprovalRejectionComments(){
        
        if(String.isNotBlank(pdoId)){
            List<ProcessInstance> processIns = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId =: pdoId];
            if(processIns.size() > 0){
                List<ProcessInstanceStep> processInsStep = [SELECT Id, Comments, StepStatus FROM ProcessInstanceStep WHERE ProcessInstanceId = :processIns[0].Id AND StepStatus IN ('Approved', 'Rejected')];
                if(processInsStep.size() > 0){
                    comments = processInsStep[0].Comments;
                    stepStatus = processInsStep[0].StepStatus;
                }
            }
        }
    }
}