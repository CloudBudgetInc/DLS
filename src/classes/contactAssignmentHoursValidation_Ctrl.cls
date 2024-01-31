/* This Apex class is the Controller class for the VF page called contactAssignmentHoursValidation
    where it is for the Total hour validation purpose for the Project task and their Contact Assignments*/

global class contactAssignmentHoursValidation_Ctrl {
    
    public List<AcctSeed__Project_Task__c> projectTaskList{get;set;}    //List of ProjectTask of the desired Project respectievely.    
    public String IdFromPage{get;set;}                                  //Id of the Project from the URL.  
    public Boolean emptyList{get;set;}
    public String fromWebService{get;set;}
    public String congaQueryMap{get;set;}
    public String congaTempMap{get;set;}
    public String displayMessage{get;set;}
    public String projectName{get;set;}

        
    public contactAssignmentHoursValidation_Ctrl(){
        
        Map<String,Id> congaQuery = CongaButtonsController.getQryMap('Project Query for Job Summary Report,ContactAssign Query for Job Summary Report');
        Map<String,Id>  congaTemp = CongaButtonsController.getTempMap('Job Summary Report - Labor Planned');
        
        congaQueryMap = JSON.serialize(congaQuery);
        congaTempMap = JSON.serialize(congaTemp);
        IdFromPage = ApexPages.currentPage().getParameters().get('projectId');
        String templateTypeFromPage = ApexPages.currentPage().getParameters().get('templateType');

        projectTaskList = new List<AcctSeed__Project_Task__c>();        //List of All Project Task of the URL passing Project Id.
        List<AcctSeed__Project_Task__c> allProjectTaskList = new List<AcctSeed__Project_Task__c>();
        List<AcctSeed__Project__c> projectList = [SELECT Id,Name FROM AcctSeed__Project__c WHERE Id = :IdFromPage];
        if(projectList.size() > 0){
           projectName = projectList[0].Name; 
        }
        if(templateTypeFromPage == 'Planned'){
            
            allProjectTaskList = [SELECT Name,Total_Qty_Planned__c,
                                  (SELECT Name,Total_Qty_Planned__c, Candidate_Name__r.Name 
                                   FROM Contact_Assignments__r 
                                   WHERE RecordType.DeveloperName = 'Instructor' AND Status__c IN ('Active', 'Planned')) 
                                  FROM AcctSeed__Project_Task__c 
                                  WHERE Total_Qty_Planned__c != NULL AND AcctSeed__Project__r.Id = :IdFromPage 
                                  AND (Project_Task_Type__c != 'Material budget')];
        }else if(templateTypeFromPage == 'Actual'){
            allProjectTaskList = [SELECT Name,Total_Qty_Planned__c,
                                  (SELECT Name,Total_Qty_Planned__c, Candidate_Name__r.Name 
                                   FROM Contact_Assignments__r 
                                   WHERE RecordType.DeveloperName = 'Instructor') 
                                  FROM AcctSeed__Project_Task__c 
                                  WHERE Total_Qty_Planned__c != NULL AND AcctSeed__Project__r.Id = :IdFromPage 
                                  AND (Project_Task_Type__c != 'Material budget')];
        }
        
        for(AcctSeed__Project_Task__c task : allprojectTaskList){
           if((task.Contact_Assignments__r).size() > 0){
               //system.debug(task.Contact_Assignments__r);
               projectTaskList.add(task);                              //Adding of the Project Task to the List where the Contact Assignments are not equal to NULL.
           }    
        }
        
        system.debug(projectTaskList);
        if(projectTaskList.size() < 1){
            if(templateTypeFromPage == 'Actual'){
                displayMessage = 'No Instructors are left for this Project';
            }else if(templateTypeFromPage == 'Planned'){
                displayMessage = 'No Active or Planned Instructors are left for this Project';
            }
            emptyList = True;
            system.debug(emptyList);
        }             
        fromWebService = ApexPages.currentPage().getParameters().get('web');
        system.debug('fromWebService'+fromWebService);
    }
    
    public pageReference hourSave(){
        //Save function to save the Valid added Hours of Contact Assignments.
        List<Contact_Assignments__c> CAList = new List<Contact_Assignments__c>();

        for(AcctSeed__Project_Task__c task : projectTaskList){
        
           if((task.Contact_Assignments__r).size() > 0){
               system.debug(task.Contact_Assignments__r);
                CAList.addAll(task.Contact_Assignments__r);        
           }
        }
        update CAList ;
        return null;
        
    }
    //call from JobSummary Component
    public static string callApproval(Id projectId,String templateName) { 
        
        system.debug(projectId);
        Integer equal = 0;
        Integer warning = 0;
        Integer error= 0;
        String sent;
        
        List<AcctSeed__Project_Task__c> projectTaskList = new List<AcctSeed__Project_Task__c>();        //List of All Project Task of the URL passing Project Id.
        List<AcctSeed__Project_Task__c> allProjectTaskList = new  List<AcctSeed__Project_Task__c>();
        
        if(templateName == 'Job Summary Report - Labor Planned'){
            
            allProjectTaskList = [SELECT Name,Total_Qty_Planned__c,
                                  (SELECT Name,Total_Qty_Planned__c, Candidate_Name__r.Name 
                                   FROM Contact_Assignments__r 
                                   WHERE RecordType.DeveloperName  = 'Instructor' AND Status__c IN ('Active', 'Planned')) 
                                  FROM AcctSeed__Project_Task__c 
                                  WHERE AcctSeed__Project__r.Id = :projectId  AND (Project_Task_Type__c != 'Material budget')];
        }else if(templateName == 'Job Summary Report - Labor Actual'){
            system.debug('templateName'+templateName);
            allProjectTaskList = [SELECT Name,Total_Qty_Planned__c,
                                  (SELECT Name,Total_Qty_Planned__c, Candidate_Name__r.Name 
                                   FROM Contact_Assignments__r 
                                   WHERE RecordType.DeveloperName  = 'Instructor') 
                                  FROM AcctSeed__Project_Task__c 
                                  WHERE AcctSeed__Project__r.Id = :projectId  AND (Project_Task_Type__c != 'Material budget')];
        }
        
        for(AcctSeed__Project_Task__c task : allprojectTaskList){
        
           if((task.Contact_Assignments__r).size() > 0){
               projectTaskList.add(task);                              //Adding of the Project Task to the List where the Contact Assignments are not equal to NULL.
           }    
        }
        
        system.debug(projectTaskList);
        if(projectTaskList.size() < 1){
            sent = 'error';
            return sent;
        }else if(templateName == 'Job Summary Report - Labor Actual'){
            return 'equal';
        }else {
            
            for(AcctSeed__Project_Task__c task : projectTaskList){
                
                Decimal taskHour = task.Total_Qty_Planned__c;
                decimal conHours = 0;
                
                for(Integer i = 0;i < (task.Contact_Assignments__r).size();i++){
                    
                    Contact_Assignments__c tempCon = task.Contact_Assignments__r[i];
                    decimal temphour = ((tempCon.Total_Qty_Planned__c != null) ? tempCon.Total_Qty_Planned__c : 0) ;
                    conHours = conHours + temphour;
                }
                if(taskHour == conHours) {
                    equal++;    
                }else if(taskHour > conHours) {
                    warning++;
                }else{
                    error++;
                }
            }
            system.debug('equal'+equal); 
            system.debug('warning'+warning);
            system.debug('error'+error);  
            
            if(error > 0) {
                sent = 'error';  
            }else if(warning > 0) {
                sent = 'warning';
            }else {
                sent = 'equal' ;
            }          
            return sent;
        }
    }
    
}