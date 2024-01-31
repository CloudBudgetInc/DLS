public without sharing class BudgetCommunityListView_Controller {
    
    @AuraEnabled
    public static String getInitialBudgetRecords(String projectId) {
        
        Id usrId = UserInfo.getUserId();
        String cARecordType;
        String projectRTName = '';
        List<User> userLst = [Select ContactId from User where Id = :usrId];
        List<Contact_Assignments__c> cAList = new   List<Contact_Assignments__c>();
        List<AcctSeed__Project_Task__c> serviceproTaskList = new List<AcctSeed__Project_Task__c>();
        List<AcctSeed__Project_Task__c> materialProTaskList = new List<AcctSeed__Project_Task__c>();
        List<Materials_Request__c> matLoanList  = new List<Materials_Request__c>();
        
        if( userLst != null && userLst.size() > 0 ){
            if(userLst[0].ContactId != null){
                cAList = [SELECT Id,Candidate_Name__c,RecordType.DeveloperName, Status__c, Project__r.Acctseed__Status__c  FROM Contact_Assignments__c WHERE Candidate_Name__c = :userLst[0].ContactId AND  Project__c = :projectId ORDER BY Status__c];
                
                List<AcctSeed__Project__c> proRT = [SELECT Id,RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :projectId LIMIT 1];
                
                if(proRT.size() > 0) {
                    projectRTName = proRT[0].RecordType.DeveloperName;
                }
                
                if(cAList.size() > 0) {
                    cARecordType = cAList[0].RecordType.DeveloperName;
                    if(cARecordType == 'Instructor' && cAList[0].Status__c == 'Ended' && cAList[0].Project__r.Acctseed__Status__c == 'Active'){
                        ProjectTaskDomain.BudgetInformation budgetInfo = new ProjectTaskDomain.BudgetInformation();
                        budgetInfo.showBudgetSection = false;
                        return JSON.serialize(budgetInfo);
                    }
                
                    if(cARecordType == 'Student' || cARecordType == 'Instructor' || cARecordType == 'Client_Partner'){
                        
                        if(cARecordType == 'Student'){
                            serviceproTaskList = [SELECT Id,Name,Total_Qty_Planned__c,Unit__c,Total_Hours__c,Total_Qty_Used__c,Total_Qty_Planned_Remaining__c,Total_Qty_Scheduled_Remaining__c,
                                                            Total_Qty_Paid_Formula__c,Total_Qty_Paid_Remaining__c 
                                                    FROM AcctSeed__Project_Task__c 
                                                    WHERE AcctSeed__Project__r.Id = :projectId AND Project_Task_Type__c  = 'Language Training'];
                        }else if(cARecordType == 'Instructor'  || cARecordType == 'Client_Partner'){
                            serviceproTaskList = [SELECT Id,Name,Total_Qty_Planned__c,Unit__c,Total_Hours__c,Total_Qty_Used__c,Total_Qty_Planned_Remaining__c,Total_Qty_Scheduled_Remaining__c,
                                                            Total_Qty_Paid_Formula__c,Total_Qty_Paid_Remaining__c 
                                                    FROM AcctSeed__Project_Task__c 
                                                    WHERE AcctSeed__Project__r.Id = :projectId AND Project_Task_Type__c IN ('Language Training','Preparation time')];
                        }
                        
                        if(projectRTName != 'DLI_W_LT_Projects') {
                            
                            // Material table
                            materialProTaskList = [SELECT Id,Name,Total_Qty_Planned__c,Rate__c,Unit__c,Total_Budgeted__c,Total_Amount_Paid__c,Total_Spent__c,Total_Amount_Paid_Remaining__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__r.Id = :projectId AND Project_Task_Type__c = 'Material budget'];
                            
                            //for Material Loan Table
                            matLoanList = [SELECT Id,Name,Contact__r.Name,Request_Status__c,Date_Returned__c,Date_Loaned_Out__c,Materials_Name__r.Name,Qty__c FROM Materials_Request__c WHERE Project__c = :projectId AND RecordType.DeveloperName = 'Material_Loan_Request'];
                        }
                        
                        //for Material Request Table
                        List<Materials_Request__c> matReqlist = [SELECT Id,Name,Request_Status__c,Date_Delivered__c,Materials_Name__r.Name,DLS_Sales_Tax_Formula__c,Qty__c,DLS_Total__c FROM Materials_Request__c WHERE Project__c = :projectId AND RecordType.DeveloperName = 'Project_Materials_Request'];
                        ProjectTaskDomain.BudgetInformation budgetInfo = (ProjectTaskDomain.BudgetInformation)JSON.deserialize(ProjectTaskTranslator.getBudgetInfoRecords(projectId,serviceproTaskList,materialProTaskList,matReqlist,matLoanList,projectRTName), ProjectTaskDomain.BudgetInformation.class);
                        budgetInfo.showBudgetSection = true;
                        return (JSON.serialize(budgetInfo));
                    }
                }
            }
        }
        return null;
    }
    
}