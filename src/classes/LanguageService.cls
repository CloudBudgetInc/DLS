/**********************************************************************
    Created by Karthiga on Jan 5, 2017: Service class used for Language__c object
***********************************************************************/
public with sharing Class LanguageService{
    /**********************************************************************
        Created by Karthiga on Jan 5 2017: This method return list of Languages
        @fltrqryStr - pass where Conditions 
        return - list of material records
    ***********************************************************************/
    public Static List<Language__c> getLanguages(String fltrqryStr) {
        Set<Id> languageIdSet = new Set<Id>();
        List<Language__c> langList = new List<Language__c>();
        String defaultQry = 'SELECT '+
                SObjectQueryService.getSObjectFieldsBySObjectName('Language__c') +
            ' FROM'+
                ' Language__c';
        if(fltrqryStr != '') {
            defaultQry = defaultQry + fltrqryStr;         
        } 
        System.debug('defaultQry :::'+defaultQry);
        langList = Database.query(defaultQry);
        return langList;
    }
       
}