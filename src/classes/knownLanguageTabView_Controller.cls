// This class is created for display known language related information in tabbed view
// By Sukanya Sep 19 2016

global class knownLanguageTabView_Controller {

    public String knownLangDisplayList {get;set;}
    public String skillsDisplayList {get;set;}
    public String educationDisplayList {get;set;}
    public String experienceDisplayList {get;set;}
    public String languageDetails {get;set;}
    public String AllExperience {get;set;}
    public Id ContactId {get;set;}
   
     
    global knownLanguageTabView_Controller(ApexPages.StandardController stdController) {
    
        String urlId;
        urlId = ApexPages.currentPage().getParameters().get('Id');
        //parentId = urlId;
        system.debug(':::::::urlId::::::'+urlId);
        ContactId = urlId;
        //List<Known_Language__c> knownLang = [SELECT Id,Name,Contact__c,Contact__r.Name,Language__c,Language_Name__c,Latest_Language_Testing__c,Listening_Proficiency__c,Native_Language__c,Speaking_Proficiency__c FROM Known_Language__c WHERE Contact__c = :urlId];
        List<Known_Language__c> knownLang = new List<Known_Language__c>();
        if(urlId != null)
        knownLang = KnownLanguageService.getKnownlanguage(' WHERE Contact__c = \''+urlId+'\'',' Contact__r.Name');
        
        List<Skill__c> skills = new List<Skill__c>();
       // List<Skill__c> skills = [SELECT Id,Name,Contact__c,Contact__r.Name,ContId_ExperienceId_FLang_TLan_Skill_Ext__c,From_Language_LU__c,From_Language_LU__r.Name,Language_S_L_R_W__c,Skill__c,Status__c,To_Language_LU__c,To_Language_LU__r.Name FROM Skill__c WHERE Contact__c = :urlId];
        if(urlId != null)
        skills = SkillService.getSkillRec(' WHERE Contact__c = \''+urlId+'\'',',Contact__r.Name,From_Language_LU__r.Name,To_Language_LU__r.Name');
        Set<Id> expConId = new Set<Id>();
        expConId.add(urlId);
        
        List<Experience__c> experience = ExperienceService.getExperiencesByRecordTypeDeveloperNameAndContactIdset(new Set<String>{'Professional_Work_Experience'}, expConId);
        //List<Experience__c> experience = [SELECT Id,Name,City__c,Contact__c,Contact__r.Name,Country__c,End_Date__c,Experience_in_Years__c,Experience_in_Months__c,ILR_Skill_Level__c,Name_of_Company__c,Role_Title__c,Services__c,Start_Date__c,State__c FROM Experience__c WHERE RecordType.DeveloperName = 'Professional_Work_Experience' AND Contact__c = :urlId];
        
        List<Experience__c> education = ExperienceService.getExperiencesByRecordTypeDeveloperNameAndContactIdset(new Set<String>{'Education_Experience'}, expConId);
        //List<Experience__c> education = [SELECT Id,Name,Aggregate__c,City__c,Contact__c,Contact__r.Name,Country__c,End_Date__c,College_School__c,College_School_Type__c,Degree__c,Degree_Level__c,Year_of_Completion__c,ILR_Skill_Level__c,Start_Date__c,State__c FROM Experience__c WHERE RecordType.DeveloperName = 'Education_Experience' AND Contact__c = :urlId];
        
        //List<Language__c> language = [SELECT Id,Name FROM Language__c];
        List<Language__c> language = LanguageService.getLanguages(' ORDER BY Name');
        String filterCondition = 'WHERE Contact__c ='+'\''+urlId+'\'';
        List<Experience__c> AllExperienceData = new List<Experience__c>();
        if(urlId != null)
        AllExperienceData = ExperienceService.getExperiencesByFilterQuery(filterCondition);
        //List<Experience__c> AllExperienceData = [SELECT Id,Name,Contact__c,Degree__c,Name_of_Company__c,Role_Title__c,College_School__c,RecordType.DeveloperName FROM Experience__c WHERE Contact__c = :urlId];
      
        
        knownLangDisplayList = String.escapeSingleQuotes(JSON.serialize(knownLang));
        skillsDisplayList = String.escapeSingleQuotes(JSON.serialize(skills));
        educationDisplayList = String.escapeSingleQuotes(JSON.serialize(education));
        experienceDisplayList = String.escapeSingleQuotes(JSON.serialize(experience));
        languageDetails = String.escapeSingleQuotes(JSON.serialize(language));
        AllExperience = String.escapeSingleQuotes(JSON.serialize(AllExperienceData));
        
        system.debug(':::::::::::knownLangDisplayList:::::'+knownLangDisplayList);
        system.debug(':::::::::::skillsDisplayList:::::'+skillsDisplayList);
        system.debug(':::::::::::knownLangDisplayList:::::'+experienceDisplayList);
        system.debug(':::::::::::educationDisplayList:::::'+educationDisplayList);
        system.debug(':::::::::::languageDetails:::::'+languageDetails);
        system.debug(':::::::::::AllExperience:::::'+AllExperience);
    }
    
    // To update the Known Language Records - Modified by E.Keerthika on 26th, April 2018
    @RemoteAction
    global static List<Known_Language__c> UpdateKnownLanguageRec(String languageString) {
        system.debug('::::::languageString::::::::'+languageString);
        List<Known_Language__c> knownLanguage = (List<Known_Language__c>) System.JSON.deserialize(languageString, List<Known_Language__c>.class);
        List<Known_Language__c> knownList = new List<Known_Language__c>();
        List<Known_Language__c> knownLangList = new List<Known_Language__c>();
        
        system.debug('::::::::knownLanguage:::::::'+knownLanguage);
        
        if(knownLanguage.size() > 0){
            knownList = KnownLanguageService.updateKnownlanguage(knownLanguage);
            //update knownLanguage;
        }
        
        if(knownList != null && knownList.size() > 0) {
            knownLangList = SObjectQueryService.SObjectQuery('Known_Language__c',new Set<Id>{knownList[0].Id},'');
        } 
        return knownLangList;  
    }
    
    @RemoteAction
    global static List<Known_Language__c> CreateKnownLanguageRec(String languageString) {
              
       List<Known_Language__c> knownLanguage = (List<Known_Language__c>) System.JSON.deserialize(languageString, List<Known_Language__c>.class);
       Set<Id> refId = new Set<Id>();
       List<Known_Language__c> knownList = new List<Known_Language__c>();
       system.debug('::::::::knownLanguage:::::::'+knownLanguage);
       
       if(knownLanguage.size() > 0){  
           knownList = KnownLanguageService.insertKnownlanguage(knownLanguage);
           //insert knownLanguage;
       }
           
           
       system.debug(':::::::::::knownLanguage:::::::'+knownLanguage);
       //List<Known_Language__c> knownLangList = [SELECT Id,Name,Contact__c,Contact__r.Name,Language__c,Language_Name__c,Latest_Language_Testing__c,Listening_Proficiency__c,Native_Language__c,Speaking_Proficiency__c FROM Known_Language__c WHERE Id = :knownLanguage[0].Id];
       //List<Known_Language__c> knownLangList = KnownLanguageService.createKnownlanguage(refId, new Set<Id>{knownLanguage[0].Id});
       List<Known_Language__c> knownLangList = SObjectQueryService.SObjectQuery('Known_Language__c',new Set<Id>{knownLanguage[0].Id},'');
       return knownLangList;
    }
    
    // To delete the records from different Object (Known Language and Experience) - Modified by E.Keerthika on 26th, April 2018
    @RemoteAction
    global static void DeleteMethodForAllObjects(String deleteList, String sObjectType) {
        
        if(deleteList != null && sObjectType!= null) {
            String objType = 'List<' + sObjectType + '>';
            Type typeOfObj = Type.forName(objType);
            List<SObject> deleteRecords = (List<SObject>)JSON.deserialize(deleteList, typeOfObj);
            if(deleteRecords.size() > 0)
                delete deleteRecords;
        }
    
    } 
    
    // Method for Experience Record Update,Create
    
    @RemoteAction
    global static void UpdateExperienceRec(String experienceString) {
       system.debug('::::::experienceString::::::::'+experienceString);
       List<Experience__c> experienceList = (List<Experience__c>) System.JSON.deserialize(experienceString, List<Experience__c>.class);
       system.debug('::::::::experienceList:::::::'+experienceList);
       
       if(experienceList.size() > 0)
           List<Experience__c> updatedExps = ExperienceService.updateExperiences(experienceList);
           //update experienceList;
           
       system.debug(':::::::::::experienceList:::::::'+experienceList);
    }
    
     @RemoteAction
    global static List<Experience__c> CreateExperienceRec(String experienceString) {
       system.debug('::::::experienceString::::::::'+experienceString);
       List<Experience__c> experienceList = (List<Experience__c>) System.JSON.deserialize(experienceString, List<Experience__c>.class);
       system.debug('::::::::experienceList:::::::'+experienceList);
        
       //RecordType rt = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Experience__c' AND DeveloperName = 'Professional_Work_Experience'];
       List<RecordType> rt = SObjectQueryService.getRecTypeListBySobjTypeAndDevName(' AND DeveloperName','Experience__c',new set<String>{'Professional_Work_Experience'});
       
       for(Experience__c exp : experienceList) {
           exp.RecordTypeId = rt[0].Id;
       }
       
       if(experienceList.size() > 0)
           List<Experience__c> InsertedExp = ExperienceService.insertExperiences(experienceList);
           //insert experienceList;
           
       system.debug(':::::::::::experienceList:::::::'+experienceList);
       
       List<Experience__c> experiences = ExperienceService.getExperiencesByRTDevNameAndExpIdset(new Set<String>{'Professional_Work_Experience'}, new Set<Id>{experienceList[0].Id});
       //List<Experience__c> experiences = [SELECT Id,Name,City__c,Contact__c,Contact__r.Name,Country__c,End_Date__c,Experience_in_Years__c,Experience_in_Months__c,ILR_Skill_Level__c,Name_of_Company__c,Role_Title__c,Services__c,Start_Date__c,State__c FROM Experience__c WHERE RecordType.DeveloperName = 'Professional_Work_Experience' AND Id = :experienceList[0].Id];
       system.debug(':::::::::::experiences:::::::'+experiences);
       
       return experiences;
       
    }
    
     // Method for Education Record Update,Create
     // Added by Sukanya on Sep 21 2016
    
    // To update the Experience__c Records with the RecordType 'Education_Experience' - Modified by E.Keerthika on 26th, April 2018
    @RemoteAction
    global static List<Experience__c> EducationRecordUpdate(String educationString) {
       system.debug('::::::educationString::::::::'+educationString);
       List<Experience__c> educationList = (List<Experience__c>) System.JSON.deserialize(educationString, List<Experience__c>.class);
       List<Experience__c> updatedEdu = new List<Experience__c>();
       List<Experience__c> education = new List<Experience__c>();
       
       system.debug('::::::::educationList:::::::'+educationList);
       
       if(educationList.size() > 0)
           updatedEdu = ExperienceService.updateExperiences(educationList);
           //update educationList;
        
       if(updatedEdu.size() > 0)
           education = ExperienceService.getExperiencesByRTDevNameAndExpIdset(new Set<String>{'Education_Experience'}, new Set<Id>{updatedEdu[0].Id});
       
       return education;
    }
    
     @RemoteAction
    global static List<Experience__c> EducationRecCreate(String educationString) {
       system.debug('::::::educationString::::::::'+educationString);
       List<Experience__c> educationList = (List<Experience__c>) System.JSON.deserialize(educationString, List<Experience__c>.class);
       system.debug('::::::::educationList:::::::'+educationList);
        
      // RecordType rt = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Experience__c' AND DeveloperName = 'Education_Experience'];
      List<RecordType> rt = SObjectQueryService.getRecTypeListBySobjTypeAndDevName(' AND DeveloperName','Experience__c',new set<String>{'Education_Experience'});
       
       for(Experience__c exp : educationList) {
           exp.RecordTypeId = rt[0].Id;
       }
       
       if(educationList.size() > 0)
           List<Experience__c> InsertedEdu = ExperienceService.insertExperiences(educationList);
           //insert educationList;
           
       system.debug(':::::::::::educationList:::::::'+educationList);
       
       List<Experience__c> education = ExperienceService.getExperiencesByRTDevNameAndExpIdset(new Set<String>{'Education_Experience'}, new Set<Id>{educationList[0].Id});
       //List<Experience__c> education = [SELECT Id,Name,Aggregate__c,City__c,Contact__c,Contact__r.Name,Country__c,End_Date__c,College_School__c,College_School_Type__c,Degree__c,Degree_Level__c,Year_of_Completion__c,ILR_Skill_Level__c,Start_Date__c,State__c FROM Experience__c WHERE RecordType.DeveloperName = 'Education_Experience' AND Id = :educationList[0].Id];
       
       system.debug(':::::::education::::::'+education);
       
       return education;
    }
    
    // Method for Skill create,Edit & Delete Added by Sukanya Sep 22 2016
    @RemoteAction
      global static List<Skill__c> SkillRecordsChanges(String skillUpdationJson,String skillCreationJson,String contactId) {

          List<Skill__c> skillUpdationList = (List<Skill__c>) System.JSON.deserialize(skillUpdationJson, List<Skill__c>.class);
          List<Skill__c> skillCreationList = (List<Skill__c>) System.JSON.deserialize(skillCreationJson, List<Skill__c>.class);

          system.debug(':::::::::::skillUpdationList::::::::::;;;;;'+skillUpdationList);
          system.debug(':::::::::::skillCreationList::::::::::;;;;;'+skillCreationList);

          if(skillUpdationList.size() > 0)
              update skillUpdationList;
              
          if(skillCreationList.size() > 0)
              insert skillCreationList;
              
         // List<Skill__c> skills = [SELECT Id,Name,Contact__c,Contact__r.Name,ContId_ExperienceId_FLang_TLan_Skill_Ext__c,From_Language_LU__c,From_Language_LU__r.Name,Language_S_L_R_W__c,Skill__c,Status__c,To_Language_LU__c,To_Language_LU__r.Name FROM Skill__c WHERE Contact__c = :contactId];
             List<Skill__c> skills = SkillService.getSkillRec(' WHERE Contact__c = \''+contactId+'\'',' ,Contact__r.Name,From_Language_LU__r.Name,To_Language_LU__r.Name');
          system.debug('::::::::skills:::::::'+skills);
          
          return skills;
      }

}