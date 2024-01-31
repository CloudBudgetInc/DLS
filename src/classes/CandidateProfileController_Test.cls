@isTest
public class CandidateProfileController_Test {
    
    @testsetup static void setup() {
        
        List<Known_Language__c> knowledges = TestClassUtil.createTestKnownLanguages();
        List<Skill__c> skills = TestClassUtil.createTestSkill();
        List<Experience__c> experiences = TestClassUtil.createTestExperience();
        List<Contact> con = [SELECT Id FROM Contact WHERE LastName = 'Test Contact1' LIMIT 1];
        insert new Professional_Publication_and_Award__c(Company_Institution_Name__c='test',Name_of_the_Publication_Award__c='pd2',Year__c='2020',Contact__c=con[0].Id);
    }
    
    
    private static testMethod void getTabsetRecords() {
        
        List<Contact> con = [SELECT Id FROM Contact WHERE LastName = 'Test Contact1' LIMIT 1];
        CandidateProfileController.getTabsetRecords(con[0].Id);
    }
    
    private static testMethod void saveLanguageRecord() {
        
        List<Contact> con = [SELECT Id FROM Contact WHERE LastName ='Test Contact1' LIMIT 1];
        CandidateProfileController.saveEditRecord('Known_Language__c',con[0].Id,'');
        
    }
    
    private static testMethod void saveProPubAwards() {
        
        List<Contact> con = [SELECT Id FROM Contact WHERE LastName ='Test Contact1' LIMIT 1];
        CandidateProfileController.saveEditRecord('Professional_Publication_and_Award__c',con[0].Id,'');
        
    }
    
    private static testMethod void saveSkillRecord() {
        
        List<Contact> con = [SELECT Id FROM Contact WHERE LastName = 'Test Contact1' LIMIT 1];
        CandidateProfileController.saveEditRecord('Skill__c',con[0].Id,'');
        
    }
    private static testMethod void saveExperienceRecord() {
        
        List<Contact> con = [SELECT Id FROM Contact WHERE LastName = 'Test Contact1' LIMIT 1];
        CandidateProfileController.saveEditRecord('Experience__c',con[0].Id,'Professional Work Experience');
        
    }
    private static testMethod void saveEducationRecord() {
        
          List<Contact> con = [SELECT Id FROM Contact WHERE LastName = 'Test Contact1' LIMIT 1];
        CandidateProfileController.saveEditRecord('Experience__c',con[0].Id,'Education Experience');
        
    }
    private static testMethod void deleteCandidateRecord(){
        
        List<Skill__c> skills = [SELECT Id FROM Skill__c];
        CandidateProfileController.deleteCandidateRecord(skills[0]);
    }
}