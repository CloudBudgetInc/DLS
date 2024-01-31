/**********************************************************************
    Created by Vinitha on Jan 7 2017: Service class used for Known_Language__c object
***********************************************************************/
public with sharing class KnownLanguageService {
    
     /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of knownLanguage 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of knownLanguage records
    ***********************************************************************/  
    
    public Static List<Known_Language__c> getKnownlanguage(String filterQrystr, String parentFields) {
    
        List<Known_Language__c> knownLangList = new List<Known_Language__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Known_Language__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Known_Language__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Known_Language__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        knownLangList = Database.query(defalutQry);        
        return knownLangList;        
    
    }
    
    /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of knownLanguage 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        @langset - Set of language ids
        return - list of knownLanguage records
    ***********************************************************************/  
    
    public Static List<Known_Language__c> getKnownlanguageBylangIdSet(String filterQrystr, String parentFields,Set<Id> langset) {
        List<Known_Language__c> knownLangList = new List<Known_Language__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Known_Language__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Known_Language__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Known_Language__c';
        }
        if(filterQrystr != null && filterQrystr != '' && langset != null && langset.size() > 0){
            defalutQry = defalutQry + filterQrystr+'IN :langset';            
        } 
        knownLangList = Database.query(defalutQry);        
        return knownLangList;        
    
    }
    
    /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of knownLanguage 
        @filterQrystr - String add to query
        return - list of knownLanguage records
    ***********************************************************************/ 
   public static list<Known_Language__c> getLanguagecontRec(String filterQrystr) {
    
         List<Known_Language__c> knownLangList = new List<Known_Language__c>();
         String defalutQry = 'SELECT Contact__c, Language_Name__c, Listening_Proficiency__c,'
                             +' Speaking_Proficiency__c'
                             +' FROM Known_Language__c'
                             +' WHERE Contact__c != null';
        if(filterQrystr != '') {
            defalutQry = defalutQry + filterQrystr;
        }else {         
            knownLangList = Database.query(defalutQry);
        }
        return knownLangList;
    
    }
    
    /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of knownLanguage 
        @knownList - List of known language records
        return - list of knownLanguage records
    ***********************************************************************/ 
    public static list<Known_Language__c> upsertKnownlanguage(list<Known_Language__c> knownList) {
    
        if(knownList != null && knownList.size() > 0){
            upsert knownList;            
        }
        return knownList;    
    } 
    /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of knownLanguage 
        @knownList - List of known language records
        return - list of knownLanguage records
    ***********************************************************************/ 
    public static list<Known_Language__c> insertKnownlanguage(list<Known_Language__c> knownList) {
    
        if(knownList != null && knownList.size() > 0){
            insert knownList;            
        }
        return knownList;    
    }
    /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of knownLanguage 
        @knownList - List of known language records
        return - list of knownLanguage records
    ***********************************************************************/ 
    public static list<Known_Language__c> updateKnownlanguage(list<Known_Language__c> knownList) {
    
        if(knownList != null && knownList.size() > 0){
            update knownList;            
        }
        return knownList;    
    } 
    
    
     /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of knownLanguage 
        @contactId - Id of contact records
        return - list of knownLanguage records
       
    public static list<Known_Language__c> createKnownlanguage(Set<Id> contactId) {
        
        List<Known_Language__c> knownLangList = new List<Known_Language__c>();
        if(contactId != null){            
            knownLangList = [
                        SELECT
                            Id,
                            Name,
                            Contact__c,
                            Contact__r.Name,
                            Language__c,
                            Language_Name__c,
                            Latest_Language_Testing__c,
                            Listening_Proficiency__c,
                            Native_Language__c,
                            Speaking_Proficiency__c,
                            Contact__r.Email,
                            Contact__r.MobilePhone,
                            Contact__r.MailingStreet,
                            Contact__r.MailingCity,
                            Contact__r.MailingState,
                            Contact__r.MailingCountry,
                            Contact__r.MailingPostalCode,
                            Contact_with_Language_Id__c
                        FROM
                            Known_Language__c
                        WHERE
                            Contact__c IN :contactId
                        ];
        }
        return knownLangList; 
    }
    ***********************************************************************/ 
    /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of knownLanguage 
        @lang1 - String of languageName records
        @parameterlanguage - String of languageName records
        return - list of knownLanguage records
    ***********************************************************************/ 
    /*public static list<Known_Language__c> getContacts(String lang1, String parameterlanguage) {
        
        List<Known_Language__c> knownLangList = new List<Known_Language__c>();
        if(lang1 != null){
            knownLangList = Database.query('SELECT Id, Native_Language__c, Language__c,'
                                            +'Language_Name__c, Listening_Proficiency__c, Speaking_Proficiency__c,'
                                            +'Latest_Language_Testing__c,Contact__c, Contact__r.Name, Contact__r.Email,'
                                            +'Contact__r.MobilePhone, Contact__r.MailingStreet, Contact__r.MailingCity,'
                                            +'Contact__r.MailingState, Contact__r.MailingCountry, Contact__r.MailingPostalCode'
                                            +'FROM Known_Language__c'
                                            +'WHERE Language_Name__c LIKE \''+lang1+'%\' ');
        } else if(parameterlanguage != null){
            knownLangList = Database.query('SELECT Contact__c '
                                            +'FROM Known_Language__c '
                                            +'WHERE Language__r.Name = \'' + parameterlanguage + '\'');
        }
        return knownLangList;       
    
    }*/
      
}