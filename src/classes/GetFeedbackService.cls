/**********************************************************************
    Created by Vinitha on Jan 10 2017: Service class used for Get_Feedback__c object
***********************************************************************/
public with sharing class GetFeedbackService {
    
     /**********************************************************************
        Created by Vinitha on Jan 10 2017: This method return list of getFeedback 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        @oppId - pass set of opportunity ids
        return - list of getFeedback records
    ***********************************************************************/ 
    
    public Static List<Get_Feedback__c> getFeedback(String filterQrystr, String parentFields,Set<Id> oppId) {
     
        List<Get_Feedback__c> feedBacklist = new List<Get_Feedback__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Get_Feedback__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Get_Feedback__c';
        system.debug('::oppId::'+oppId);
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Get_Feedback__c';
        }
        
        if(filterQrystr != null && filterQrystr != '' && oppId != null && oppId.size() > 0){
            system.debug('enterifcondition:::::'+oppId);
            defalutQry = defalutQry + filterQrystr+'IN :oppId';            
        }              
        system.debug(':::::::defaultQry:::::::'+defalutQry);
        system.debug(':::::::filterQrystr:::::::'+filterQrystr);
        system.debug(':::::::parentFields:::::::'+parentFields);
        feedBacklist = Database.query(defalutQry);        
        return feedBacklist;   
    } 
    
    /**********************************************************************
        Created by Vinitha on Jan 10 2017: This method return list of getFeedback 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of getFeedback records
    ***********************************************************************/  
    
    public Static List<Get_Feedback__c> getFeedbackdetail(String filterQrystr, String parentFields) {
        List<Get_Feedback__c> feedBacklist = new List<Get_Feedback__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Get_Feedback__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Get_Feedback__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Get_Feedback__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        feedBacklist = Database.query(defalutQry);        
        return feedBacklist;        
    
    }
    
     /**********************************************************************
        Created by Vinitha on Jan 10 2017: This method return newly created list of getFeedback 
        @getFeedbacklist - List of getFeedback records
        return - list of getFeedback records
    ***********************************************************************/ 
    public static list<Get_Feedback__c> updateGetfeedback(list<Get_Feedback__c> getFeedbacklist) {
    
        if(getFeedbacklist != null && getFeedbacklist.size() > 0){
            update getFeedbacklist;            
        }
        return getFeedbacklist;    
    } 
    
   /* public Static List<Get_Feedback__c> getFeedback(String filterQrystr) {
        
        List<Get_Feedback__c> feedBacklist = new List<Get_Feedback__c>();
        String defalutQry = 'SELECT'+
                    +' Id,'
                    +' Name,'
                    +' Contact__c,'
                    +' Contact__r.Name,'
                    +' Language__c,'
                    +' Course_Rating__c,'                            
                    +' Course_Material_Rating__c,'
                    +' Classroom_Environment_Rating__c,'                            
                    +' Clarity_of_explanations__c,'
                    +' Knowledge_of_subject_language_and_cultu__c,'
                    +' Front_Desk_Support_Rating__c,'
                    +' Effectiveness_of_activities__c,'
                    +' IT_Support_Rating__c,'                            
                    +' Have_we_met_all_of_your_expectations__c,'
                    +' experience_at_DLS__c,'
                    +' experience_with_this_instructor__c,'
                    +' Opportunity__c,'
                    +' Opportunity__r.Name,'
                    +' Opportunity__r.AccountId,'
                    +' Opportunity__r.Account.Name,'
                    +' RecordType.DeveloperName,'
                    +' RecordType.Name,'
                    +' Feedback_Responce__c,'
                    +' Over_all_Instructor_rating__c,'
                    +' What_can_we_do_to_make_the_class_better__c,'
                    +' What_can_we_do_to_make_the_DLS_environme__c,'
                    +' What_have_we_done_right_so_far__c'
                +' FROM'
                    +' Get_Feedback__c'
                +' WHERE'
                    +' Opportunity__c != null'
                +' AND'
                    +' Opportunity__r.AccountId != null';
         if(filterQrystr != '') {
            defalutQry = defalutQry + filterQrystr;
        }
            feedBacklist = Database.query(defalutQry);   
                
        return feedBacklist; 
    }*/
    
    /**********************************************************************
        Created by Vinitha on Jan 10 2017: This method return list of getFeedback 
        @oppIds - Id of opportunity records
        return - list of getFeedback records
    ***********************************************************************/
    
    /*public Static List<Get_Feedback__c> getOppbyFeedback(Set<Id> oppIds) {
        
        List<Get_Feedback__c> feedBacklist = new List<Get_Feedback__c>();
        if(oppIds != null){
            feedBacklist = [
                        SELECT 
                            Id,
                            Name,
                            Contact__c,
                            Contact__r.Name,
                            Language__c,Course_Rating__c,
                            Course_Material_Rating__c,
                            Classroom_Environment_Rating__c,
                            Clarity_of_explanations__c,
                            Knowledge_of_subject_language_and_cultu__c,
                            Front_Desk_Support_Rating__c,
                            Effectiveness_of_activities__c,
                            IT_Support_Rating__c,
                            Have_we_met_all_of_your_expectations__c,
                            experience_at_DLS__c,
                            experience_with_this_instructor__c,
                            Opportunity__c,
                            Opportunity__r.Name,
                            Opportunity__r.AccountId,
                            Opportunity__r.Account.Name,
                            RecordType.DeveloperName,
                            RecordType.Name,
                            Feedback_Responce__c,
                            Over_all_Instructor_rating__c,
                            What_can_we_do_to_make_the_class_better__c,
                            What_can_we_do_to_make_the_DLS_environme__c,
                            What_have_we_done_right_so_far__c
                        FROM 
                            Get_Feedback__c
                        WHERE 
                            Opportunity__c != null 
                        AND 
                            Opportunity__r.AccountId != null 
                        AND 
                            Opportunity__c IN :oppIds
                        ];   
        }
        return feedBacklist;
        
    }*/
    
    
}