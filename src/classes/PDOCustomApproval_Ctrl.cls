public with sharing class PDOCustomApproval_Ctrl {
    @AuraEnabled
    public static String approveOrRejectPDO(String recordId , String approveOrReject , Boolean isDeleteEvents , String comments){

        try{
            List<User> loggedInUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        String successMessage;
        
        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :recordId ];

        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();

            req.setAction(approveOrReject);
            req.setComments(comments);
            req.setWorkitemId(workItems[0].Id);

            Approval.ProcessResult result =  Approval.process(req);
            if(result.isSuccess() == true){
                if(approveOrReject == 'Approve'){
                    successMessage = 'Planned Days Off has been approved.';
                }
                else if(approveOrReject == 'Reject'){
                    successMessage = 'Planned Days Off has been rejected.';
                }
            }

            if(isDeleteEvents){
                List<Planned_Days_Off__c> childPlannedDaysOff = [SELECT Id , Contact__c , Date__c , Project__c , All_Projects__c FROM Planned_Days_Off__c WHERE Parent_Planned_Day_Off__c = :recordId];
                PlannedDaysOffHandler.cancelInstructorPDORelatedEvents(childPlannedDaysOff);
            }
            return successMessage;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}