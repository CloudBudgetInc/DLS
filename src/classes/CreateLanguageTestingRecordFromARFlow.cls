public class CreateLanguageTestingRecordFromARFlow{

    @InvocableMethod
    public static void invokeSubflow(List<LanguageTestingParams> params){
        Set<Id> projIds = new Set<Id>();
        Set<Id> stdIds = new Set<Id>();
        Map<String, Id> projIdStdIdAndCAId = new Map<String, Id>();
        List<Language_Testing__c> createLangTestRecs = new List<Language_Testing__c>();
        List<Language_Testing__c> langTestRecs = new List<Language_Testing__c>();
        
        for(LanguageTestingParams param : params){
            projIds.addAll(param.projectIds);
            stdIds.addAll(param.studentIds);
            langTestRecs.addAll(param.languageTestingRecs);
        }
        for(Contact_Assignments__c stdCA : [SELECT Id, Project__c, Candidate_Name__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN : stdIds AND Project__c IN : projIds AND RecordType.DeveloperName = 'Student']){
            String projIdAndStdId = stdCA.Project__c+'-'+stdCA.Candidate_Name__c;
            projIdStdIdAndCAId.put(projIdAndStdId, stdCA.Id);               
        }        
        for(Language_Testing__c lt : langTestRecs){
            String projIdStdId = lt.Project__c+'-'+lt.Testee__c;
            lt.Contact_Assignment__c = (projIdStdIdAndCAId.containsKey(projIdStdId) ? projIdStdIdAndCAId.get(projIdStdId) : null);
            createLangTestRecs.add(lt);
        }        
        if(createLangTestRecs.size() >0){
            insert createLangTestRecs;
        }
    }
    Public Class LanguageTestingParams{
        @InvocableVariable
        public List<Language_Testing__c> languageTestingRecs;
        @InvocableVariable
        public List<Id> studentIds;
        @InvocableVariable
        public List<Id> projectIds;
    }
}