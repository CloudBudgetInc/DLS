public with sharing class CandidateProfileController {
   
    @AuraEnabled
    public static WholeRecords getTabsetRecords(string recordId){
        WholeRecords recordInfo = new  WholeRecords();
        
        List<Known_Language__c> knowlanguages = [SELECT Id, Language_Name__c,Language__c,Native_Language__c,Speaking_Proficiency__c,Contact__c,Listening_Proficiency__c FROM Known_Language__c WHERE Contact__c=:recordId ORDER BY CreatedDate ASC];
        recordInfo.lstLanguage = knowlanguages;
        
        recordInfo.lstSkills = [SELECT Id, Skill__c,From_Language_LU__r.Name,To_Language_LU__r.Name,Rating__c,Skill_Verification__c,Contact__c,DLI_Qualified__c FROM Skill__c WHERE Contact__c=:recordId ORDER BY CreatedDate ASC];
        
        recordInfo.lstWork = [SELECT Id,Name,Name_of_Company__c,Role_Title__c,Services__c,Start_Date__c,End_Date__c,RecordTypeId, Contact__c,Experience_in_Months__c,City__c,State__c,Average_Hrs_Per_Week__c,Description__c,Experience_in_Years__c,
                              Total_Hours_Performed__c,Country__c,RecordType.Name FROM Experience__c WHERE RecordType.Name IN ('Professional Work Experience') AND Contact__c=:recordId ORDER BY CreatedDate ASC];
        
        recordInfo.lstEducation = [SELECT Id,Name,College_School__c,College_School_Type__c,Degree__c,Contact__c,RecordTypeId,Degree_Level__c,Year_of_Completion__c,Country__c ,Field_of_Concentration__c,State__c,City__c,
                                   RecordType.Name  FROM Experience__c WHERE RecordType.Name IN ('Education Experience') AND Contact__c=:recordId ORDER BY CreatedDate ASC];
        
        recordInfo.lstProfPublicationAward = [SELECT Id,Company_Institution__c,Contact__c,Name_of_the_Publication_Award__c,Year__c,Name,Company_Institution_Name__c,Company_Institution__r.Name FROM Professional_Publication_and_Award__c
                                               WHERE Contact__c= :recordId ORDER BY CreatedDate ASC];
        
        recordInfo.expTabRecTypeId = Schema.SObjectType.Experience__c.getRecordTypeInfosByDeveloperName().get('Professional_Work_Experience').getRecordTypeId();
        recordInfo.eduTabRecTypeId = Schema.SObjectType.Experience__c.getRecordTypeInfosByDeveloperName().get('Education_Experience').getRecordTypeId();

        return recordInfo;
    }
    @AuraEnabled 
    public static SObject deleteCandidateRecord(SObject del){
        delete del;
        return del;
    } 
    @AuraEnabled
    public static List<SObject> saveEditRecord(string objectName,string recordId,string recordType) {
        
        if(objectName == 'Skill__c'){
            
            return  [SELECT Id, Skill__c,From_Language_LU__r.Name,To_Language_LU__r.Name,Rating__c,Skill_Verification__c,DLI_Qualified__c,Contact__c FROM Skill__c WHERE Contact__c=:recordId ORDER BY CreatedDate ASC];        
       
        }else if(objectName == 'Known_Language__c'){
            
            return [SELECT Id, Language_Name__c,Language__c,Native_Language__c,Speaking_Proficiency__c,Listening_Proficiency__c,Contact__c FROM Known_Language__c WHERE Contact__c=:recordId ORDER BY CreatedDate ASC];
            
        }else if(objectName =='Experience__c' && recordType == 'Professional Work Experience' ){
            
            return  [SELECT Id,Name,Name_of_Company__c,Role_Title__c,Services__c,Start_Date__c,Contact__c,End_Date__c,RecordTypeId ,Experience_in_Months__c,City__c,State__c,Average_Hrs_Per_Week__c,Description__c,Experience_in_Years__c,
                     Total_Hours_Performed__c,Country__c,RecordType.Name FROM Experience__c WHERE RecordType.Name IN ('Professional Work Experience') AND Contact__c= :recordId ORDER BY CreatedDate ASC];
        }
        else if(objectName =='Experience__c' && recordType == 'Education Experience' ){
            
            return [select Id,Name,College_School__c,College_School_Type__c,Degree__c,RecordTypeId,Degree_Level__c,Contact__c,Year_of_Completion__c,Country__c  ,Field_of_Concentration__c,State__c,City__c,
                    RecordType.Name FROM Experience__c WHERE RecordType.Name IN ('Education Experience') AND Contact__c= :recordId ORDER BY CreatedDate ASC]; 
        }else if(objectName == 'Professional_Publication_and_Award__c'){
           
            return [SELECT Id,Company_Institution__c,Contact__c,Name_of_the_Publication_Award__c,Year__c,Company_Institution_Name__c, Company_Institution__r.Name,Name FROM Professional_Publication_and_Award__c
                                               WHERE Contact__c= :recordId ORDER BY CreatedDate ASC];
        }
        
        return null;
    }
    
    public class WholeRecords{
        @AuraEnabled public List<Known_Language__c> lstLanguage;
        @AuraEnabled public List<Skill__c> lstSkills;
        @AuraEnabled public List<Experience__c> lstWork;
        @AuraEnabled public List<Experience__c> lstEducation;
        @AuraEnabled public List<Professional_Publication_and_Award__c> lstProfPublicationAward;
        @AuraEnabled public String expTabRecTypeId;
        @AuraEnabled public String eduTabRecTypeId;

    }

    
}