/**********************************************************************
    Created by Arun on Jan 19, 2017: Service class used for Language_Testing__c 
***********************************************************************/

public with sharing Class LanguageTestingService {
    
     /**********************************************************************
        Created by Arun on Jan 19 2017: 
        @oppIdSet - Set of Opportunity Ids
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of LanguageTestings.
     ***********************************************************************/
    public Static List<Language_Testing__c > getLanguageTestingsByOppIds(Set<Id> oppIdSet,String filterQuery,String parentFields) {
        List<Language_Testing__c > langTestingList = new List<Language_Testing__c>();
        String defaultLangTestingQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Language_Testing__c')+
                                parentFields+
                                    ' ,(SELECT Id,Name FROM Attachments ORDER By createdDate DESC LIMIT 1)'+                                      
                                ' FROM'+
                                        ' Language_Testing__c';
                               
         if(oppIdSet != Null && oppIdSet.Size() > 0 && filterQuery != '') {
             
             defaultLangTestingQry += ' WHERE Opportunity__c IN :oppIdSet '+filterQuery; 
         }
         else if(filterQuery != '') {
             
             defaultLangTestingQry+= ' WHERE '+filterQuery;
         }
         System.debug('defaultLangTestingQry:::::'+defaultLangTestingQry);
         langTestingList = database.query(defaultLangTestingQry);                           
         return langTestingList;
    }
    
    /**********************************************************************
        Created by Arun on Jan 19 2017: 
        @oppAccIdSet - Set of Opportunity Ids
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of LanguageTestings.
     ***********************************************************************/
    public Static List<Language_Testing__c > getLanguageTestingsByOppAccIds(Set<Id> oppAccIdSet,String filterQuery,String parentFields) {
        List<Language_Testing__c > langTestingList = new List<Language_Testing__c>();
        String defaultLangTestingQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Language_Testing__c')+
                                parentFields+
                                    ' ,(SELECT Id,Name FROM Attachments ORDER By createdDate DESC LIMIT 1)'+                                      
                                ' FROM'+
                                        ' Language_Testing__c'+
                                ' WHERE'+
                                        ' Opportunity__r.AccountId IN :oppAccIdSet';
                                    
         if(filterQuery != '') {
             defaultLangTestingQry+= filterQuery;
         }
         System.debug('defaultLangTestingQry:::::'+defaultLangTestingQry);
         langTestingList = database.query(defaultLangTestingQry);                           
         return langTestingList;
    }
    
    /**********************************************************************
        Created by Vinitha on Feb 2 2017: This method return list of Language_Testing 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of Language_Testing records
    ***********************************************************************/  
    
    public Static List<Language_Testing__c> getLanguagetestingRec(String filterQrystr, String parentFields) {
    
        List<Language_Testing__c> langTestingList = new List<Language_Testing__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Language_Testing__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Language_Testing__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Language_Testing__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        langTestingList = Database.query(defalutQry);        
        return langTestingList;        
    
    }
    
    /**********************************************************************
        Created by Vinitha on Feb 23 2017: This method return list of LanguageTesting 
        @projecttaskId - Set of projecttaskIds 
        @testteeId - Set of testteeIds 
        return - list of LanguageTesting records
    ***********************************************************************/ 
    public static list<Language_Testing__c> getLanguagetestingByprojtaskId(Set<Id> projecttaskId, Set<Id> testteeId) {
        
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Language_Testing__c');
        String defaultQry = 'Select '+ 
                                fieldName + 
                            ' From Language_Testing__c'+
                            ' WHERE Project_Task__c IN :projecttaskId AND Testee__c IN :testteeId  ORDER BY CreatedDate DESC';
        if(projecttaskId != null && projecttaskId.size() > 0 && testteeId != null && testteeId.size() > 0){
            langtestList = Database.query(defaultQry);        
        }
        return langtestList;    
    } 
    
    
    /**********************************************************************
        Created by Vinitha on Feb 9 2017: This method return list of LanguageTesting 
        @langtestList - List of LanguageTesting records
        return - list of LanguageTesting records
    ***********************************************************************/ 
    public static list<Language_Testing__c> insertLanguageTesting(list<Language_Testing__c> langtestList) {
    
        if(langtestList != null && langtestList.size() > 0){
            insert langtestList;            
        }
        return langtestList;    
    } 
    
    /**********************************************************************
        Created by Vinitha on Feb 9 2017: This method return list of LanguageTesting 
        @langtestList - List of LanguageTesting records
        return - list of LanguageTesting records
    ***********************************************************************/ 
    public static list<Language_Testing__c> updateLanguageTesting(list<Language_Testing__c> langtestList) {
    
        if(langtestList != null && langtestList.size() > 0){
            update langtestList;            
        }
        return langtestList;    
    } 
}