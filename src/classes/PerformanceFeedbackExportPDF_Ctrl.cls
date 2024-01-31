public without sharing class PerformanceFeedbackExportPDF_Ctrl {
    public Id feedbackId;
    public Form_Response__c formResponse {get; set;}
    public List<Form_Response__c> formResponses {get; set;}
    public Boolean isFromManagerSummary {get; set;}
    public Integer totalCnt {get; set;}
    public Integer totalMangerSummaryCnt {get; set;}
    
    public PerformanceFeedbackExportPDF_Ctrl() {
    
        feedbackId = ApexPages.currentPage().getParameters().get('feedbackId');        
        
        isFromManagerSummary = false;
        formResponse = FormResponseService.getFormResWithFormResElements('Id = \''+feedbackId+'\'',',Feedback_About__r.Name',',Question__r.Question__c')[0];
        String fileName = formResponse.Feedback_About__r.Name +' - '+formResponse.Form_Feedback_Type__c+' - '+formResponse.Due_Date__c.month()+'.'+formResponse.Due_Date__c.day()+'.'+formResponse.Due_Date__c.year()+'.pdf';  
        totalCnt = 1;
        if(formResponse.Form_Feedback_Type__c == 'Self Summary'){//} && formResponse.Is_Feedback_By_Me__c){            
            formResponses = new List<Form_Response__c>();
            List<Form_Response__c> peerSummary = FormResponseService.getFormResWithFormResElements('Form_Feedback_Type__c IN (\'Peer Summary\') AND Is_Share_with_Employee__c = true AND Feedback_About__c = \''+formResponse.Feedback_About__c+'\' AND Performance_Cycle__c = \''+formResponse.Performance_Cycle__c+'\'',',Feedback_About__r.Name, Feedback_From__r.Name',',Question__r.Question__c');
            List<Form_Response__c> managerSummary = FormResponseService.getFormResWithFormResElements('Form_Feedback_Type__c IN (\'Manager Summary\') AND Status__c = \'Submitted\' AND Feedback_About__c = \''+formResponse.Feedback_About__c+'\' AND Performance_Cycle__c = \''+formResponse.Performance_Cycle__c+'\'',',Feedback_About__r.Name, Feedback_From__r.Name',',Question__r.Question__c');
            if(peerSummary.size() > 0){
            	formResponses.addAll(peerSummary);
            }
            if(managerSummary.size() > 0){
                formResponses.addAll(managerSummary);
            }
            System.debug('formResponses.size():>>'+formResponses.size());
            if(formResponses.size() > 0){
                totalCnt = formResponses.size();
                fileName = formResponse.Feedback_About__r.Name +' - Self & Peer Summaries - '+formResponse.Due_Date__c.month()+'.'+formResponse.Due_Date__c.day()+'.'+formResponse.Due_Date__c.year()+'.pdf';       
            }
        }else if(formResponse.Form_Feedback_Type__c == 'Manager Summary'){
            isFromManagerSummary = true;  
            formResponses = FormResponseService.getFormResWithFormResElements('Form_Feedback_Type__c IN (\'Self Summary\',\'Peer Summary\',\'Manager Summary\') AND Feedback_About__c = \''+formResponse.Feedback_About__c+'\' AND Performance_Cycle__c = \''+formResponse.Performance_Cycle__c+'\'',',Feedback_About__r.Name, Feedback_From__r.Name',',Question__r.Question__c');
            totalCnt = formResponses.size();
            fileName = formResponse.Feedback_About__r.Name +' - Self & Peer Summaries - '+formResponse.Due_Date__c.month()+'.'+formResponse.Due_Date__c.day()+'.'+formResponse.Due_Date__c.year()+'.pdf';       
        }
                 
        
        //Download the pdf file
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+fileName);
    }    
}