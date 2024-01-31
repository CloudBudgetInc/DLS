@isTest
public class TestknownLanguageTabView_Controller {
    @testSetup static void setup(){
        List<Known_Language__c> KnownlangList = TestClassUtil.createTestKnownLanguages();
        List<Skill__c> skillsList = TestClassUtil.createTestSkill();
        List<Experience__c> expeList = TestClassUtil.createTestExperience();
    
    }
    Static testMethod void testKnownLanguage(){
    
        //ApexPages.StandardController std = new ApexPages.StandardController(sample);
        //Id urlId1 = ApexPages.currentPage().getParameters().get('id');
        
        List<Known_Language__c> languageList = [SELECT Id FROM Known_Language__c LIMIT 3]; //,Language__c,Contact__c
        List<Skill__c> skills = [SELECT Id,Name,Contact__c,From_Language__c,To_Language__c FROM Skill__c LIMIT 2];
        List<Experience__c> experience = [SELECT Id,College_School__c,Degree__c,Degree_Level__c,End_Date__c,Contact__c,Start_Date__c,Name_of_Company__c FROM Experience__c LIMIT 2];
        
        List<Contact> contactList = [SELECT Id,Name,accountId FROM Contact LIMIT 1];
        
        List<Language__c> langRecords = [SELECT Id,Name FROM Language__c LIMIT 5];
        
        String workRTId;
        String EducationRTId;
        ApexPages.currentPage().getParameters().put('Id',contactList[0].Id);
        for(RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType = 'Experience__c']) {
            if(rt.DeveloperName == 'Education_Experience')
                EducationRTId = rt.Id;
            if(rt.DeveloperName == 'Professional_Work_Experience')
                workRTId = rt.Id;
        }
        
        String contactId = ApexPages.currentPage().getParameters().get('id');
        ApexPages.StandardController std = new ApexPages.StandardController(contactList[0]);
        knownLanguageTabView_Controller knownLangController = new knownLanguageTabView_Controller(std);
        
        List<Skill__c> skilList = new List<Skill__c>{
                                        new Skill__c(Contact__c = contactList[0].Id, From_Language_LU__c = langRecords[0].Id, To_Language_LU__c = langRecords[1].Id)
                                    };
        List<Experience__c> expList = new List<Experience__c> {
                                            new Experience__c(RecordTypeId = EducationRTId,College_School__c = 'Test College',Degree__c = 'Test Degree',Degree_Level__c = 'B.A.',End_Date__c = date.newinstance(2000, 2, 17),Contact__c = contactId),
                                            new Experience__c(RecordTypeId = workRTId,Start_Date__c = date.newinstance(2000, 03, 01),End_Date__c = date.newinstance(2002, 10, 29),Contact__c = contactId,Name_of_Company__c = 'Test Company 1')
                                        };
        
        List<Known_Language__c> knownLang = new List<Known_Language__c>{
                                new Known_Language__c(Language__c = langRecords[0].Id,Contact__c = contactList[0].Id)
                            };
        
        String languageString = JSON.serializePretty(languageList);
        
        String langCreate = JSON.serializePretty(knownLang);
        
        String expCreate = JSON.serializePretty(expList);
        
        String educationCreate = JSON.serializePretty(expList);
        
        String experienceUpdate = JSON.serializePretty(experience);
        String educationUpdate = JSON.serializePretty(experience);
        
        String skillUpdate = JSON.serializePretty(skills);
        String skilldelete = JSON.serializePretty(skills);
        String skillcreate = JSON.serializePretty(skilList);
        
        knownLanguageTabView_Controller.UpdateKnownLanguageRec(languageString);
        knownLanguageTabView_Controller.CreateKnownLanguageRec(langCreate);
        
        knownLanguageTabView_Controller.DeleteMethodForAllObjects(languageString,'Known_Language__c');
        
        knownLanguageTabView_Controller.CreateExperienceRec(expCreate);
        knownLanguageTabView_Controller.UpdateExperienceRec(experienceUpdate);
        
        knownLanguageTabView_Controller.EducationRecordUpdate(educationUpdate);
        knownLanguageTabView_Controller.EducationRecCreate(educationCreate);
        
        knownLanguageTabView_Controller.SkillRecordsChanges(skillUpdate,skillcreate,contactId);
        
    }

}