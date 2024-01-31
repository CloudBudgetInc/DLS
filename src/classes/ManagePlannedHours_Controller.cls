public class ManagePlannedHours_Controller {
    
    @AuraEnabled
    public static String getInitialProjectTaskRelatedCA(String projectInfo){
        List<AcctSeed__Project_Task__c> allProjectTaskList = new List<AcctSeed__Project_Task__c>();
        
        String projectId = projectInfo.split('projectId=')[1];
        String templateType  = projectInfo.substringBetween('templateType=','&web');
        projectWrapper pjtWrapper = new projectWrapper();
        pjtWrapper.projectId = projectId;
        pjtWrapper.templateType = templateType;
     
        if(templateType == 'Planned'){
            
            allProjectTaskList = [SELECT Id,Name,Total_Qty_Planned__c,project_Task_Type__c,
                                  (SELECT Id,Name,Total_Qty_Planned__c, Candidate_Name__r.Name,Total_Prep_Qty_Planned__c,Project_Task__r.Name
                                   FROM Contact_Assignments__r 
                                   WHERE RecordType.DeveloperName = 'Instructor' AND Status__c IN ('Active', 'Planned'))
                                  ,(SELECT Id, Name,Total_Qty_Planned__c,project_Task_Type__c FROM Project_Tasks__r WHERE project_Task_Type__c = 'Preparation time')
                                  FROM AcctSeed__Project_Task__c 
                                  WHERE Total_Qty_Planned__c != NULL AND AcctSeed__Project__r.Id = :projectId 
                                  AND (Project_Task_Type__c != 'Material budget') ];
        }else if(templateType == 'Actual'){
            allProjectTaskList = [SELECT Id,Name,Total_Qty_Planned__c,project_Task_Type__c,
                                  (SELECT Id,Name,Total_Qty_Planned__c, Candidate_Name__r.Name,Total_Prep_Qty_Planned__c
                                   FROM Contact_Assignments__r 
                                   WHERE RecordType.DeveloperName = 'Instructor'),
                                  (SELECT Id,Name,Total_Qty_Planned__c,project_Task_Type__c FROM Project_Tasks__r WHERE project_Task_Type__c = 'Preparation time') 
                                  FROM AcctSeed__Project_Task__c 
                                  WHERE Total_Qty_Planned__c != NULL AND AcctSeed__Project__r.Id = :projectId 
                                  AND (Project_Task_Type__c != 'Material budget')];
        }
        system.debug('allProjectTaskList'+allProjectTaskList);
        List<projectTaskWrapper> proTaskWrapList = new List<projectTaskWrapper> ();
        if(allProjectTaskList.size() > 0){
            for(AcctSeed__Project_Task__c  proTskLst :allProjectTaskList ){
                List<CAWrapper> conAssignWrapList = new  List<CAWrapper>();
                projectTaskWrapper proTaskWrap = new projectTaskWrapper();
                
                if(proTskLst.Contact_Assignments__r.size() > 0){
                    proTaskWrap.proTaskId = proTskLst.Id;
                    proTaskWrap.proTaskType = proTskLst.Project_Task_Type__c;
                    proTaskWrap.totalQtyPlanned = String.valueOf(proTskLst.Total_Qty_Planned__c);
                    proTaskWrap.proTaskName = proTskLst.Name;
                    
                    for(Contact_Assignments__c conAssignLst : proTskLst.Contact_Assignments__r){
                        CAWrapper conAssignWrap = new CAWrapper();
                        conAssignWrap.cAId = conAssignLst.Id;
                        conAssignWrap.conId = conAssignLst.Candidate_Name__c;
                        conAssignWrap.conName = conAssignLst.Candidate_Name__r.Name;
                        conAssignWrap.totalQtyPlanned = conAssignLst.Total_Qty_Planned__c;
                        conAssignWrap.prepTotalQtyPlanned = conAssignLst.Total_Prep_Qty_Planned__c;
                        conAssignWrapList.add(conAssignWrap);
                    }
                    proTaskWrap.conAssignList = conAssignWrapList;
                    proTaskWrapList.add(proTaskWrap);
                }
                
                if(proTskLst.Project_Tasks__r.size() > 0){
                    for(AcctSeed__Project_Task__c childPTList : proTskLst.Project_Tasks__r){
                        projectTaskWrapper childTaskWrap = new projectTaskWrapper();
                        childTaskWrap.proTaskId =  childPTList.Id;
                        childTaskWrap.proTaskType =  childPTList.Project_Task_Type__c;
                        childTaskWrap.totalQtyPlanned = String.valueOf(childPTList.Total_Qty_Planned__c);
                        childTaskWrap.proTaskName =  childPTList.Name;
                        childTaskWrap.conAssignList = proTaskWrap.conAssignList;
                        proTaskWrapList.add(childTaskWrap);
                    }
                }
            }
        } 
        pjtWrapper.proTasks = proTaskWrapList;
        return JSON.serialize(pjtWrapper);
    }
    
    public class CAWrapper{
        @AuraEnabled
        public String cAId;
        @AuraEnabled
        public String conId;
        @AuraEnabled
        public String conName;
        @AuraEnabled
        public Decimal totalQtyPlanned;
        @AuraEnabled
        public Decimal prepTotalQtyPlanned;
    }
    public class projectTaskWrapper{
        @AuraEnabled
        public String proTaskId;
        @AuraEnabled
        public String proTaskName;
        @AuraEnabled
        public String totalQtyPlanned;
        @AuraEnabled
        public String parentProTaskId;
        @AuraEnabled
        public List<CAWrapper> conAssignList;
        @AuraEnabled
        public String proTaskType;
    }
    public class projectWrapper{
        @AuraEnabled
        public String projectId;
        @AuraEnabled
        public String templateType;
        @AuraEnabled
        public List<projectTaskWrapper> proTasks; 
    }
    @AuraEnabled
    public static String saveContactAssignment(List<Contact_Assignments__c> conAssign){
        try{
            update conAssign;
            return 'SUCCESS';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String getCongaUrl(String queryName,String templateName,String projectId){
          
        return JSON.serialize(CongaButtonsController.jobSummaryReport(projectId,queryName,templateName));
    }
    
}