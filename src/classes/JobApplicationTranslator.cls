/**********************************************************************
    Created by Vinitha on Jan 7 2017: Translator class used for JobApplication object
***********************************************************************/

global class JobApplicationTranslator {
    
    /**********************************************************************
        Created by Vinitha on Jan 6 2017: This method return list of JobApplication with one condition
         @jobList - List of JobApplication record         
         return - set of JobApplication records ids
    ***********************************************************************/

    global static Set<Id> jobApplicationinfo( List<Job_Application__c> jobList ) {
        Set<Id> jobIdSet = new Set<Id>();
        if(jobList != null && jobList.size() > 0){
            for(Job_Application__c jobApplication : jobList){
                jobIdSet.add(jobApplication.Applicant__c);
            }          
            return jobIdSet;
        }else {
            return null;
        }
    }
       
}