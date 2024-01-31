/**********************************************************************
    Created by Mohana on Apr 30 2019: Translator class used for Contact object inner class assignment
***********************************************************************/

global class ContactTranslator {
    
    /**************************************
        Added by Mohana on Apr 30 2019
        For Instructor & Student Community My Profile tab
    ***************************************/
    
    public static List<ContactDomain.ContactInfo> contactRecordsFormation(List<Contact> contacts) {
        
        List<ContactDomain.ContactInfo> contactRecords = new List<ContactDomain.ContactInfo>();
        
        for(Contact con : contacts) {
            ContactDomain.ContactInfo contactRec = new ContactDomain.ContactInfo();
            contactRec.contactId = con.Id;
            contactRec.salutation = con.Salutation;
            contactRec.firstName = con.FirstName;
            contactRec.lastName = con.LastName;
            contactRec.middleName = con.MiddleName;
            contactRec.email = con.Email;
            contactRec.preferredPhone = con.Preferred_Phone__c;
            contactRec.phone = con.Phone;
            contactRec.timeZone = con.Timezone__c;
            contactRec.mobilePhone = con.MobilePhone;
            contactRec.homePhone = con.HomePhone;
            contactRec.mailingStreet = con.MailingStreet;
            contactRec.mailingCity = con.MailingCity;
            contactRec.mailingState = con.MailingState;
            contactRec.mailingPostalCode = con.MailingPostalCode;
            contactRec.teachingInDlsSince = con.Teaching_in_DLS_since__c;
            contactRec.timeApprovalPreference = con.Time_Approval_Preference__c;
            if(con.Teaching_in_DLS_since__c != null) {
                contactRec.teachingInDlsSinceStr = con.Teaching_in_DLS_since__c.format();
            }
            contactRec.activeCountAsInstructor = con.Active_Count_as_Instructor__c;
            contactRec.sumInstructorHoursWeek = con.Sum_Instructor_Hours_Week__c;
            contactRec.countProjectByInstructorName = con.Count_Projects_by_Instructor_Name__c;
            contactRec.classProjectsTaught = con.of_Class_Projects_Taught__c;
            contactRec.noOfWorkshopsAttended = con.number_of_workshops_attended__c;
            contactRec.noOfTestsPerformed = con.of_Tests_Perfomed__c;
            contactRec.noofStudentsTaught = con.of_Students_Taught__c;
            contactRec.noOfClassHours = con.of_Hours_Taught_at_Vendor__c;
            
            //Added By Dhinesh - W-006013 - Zoom Integration - to show zoom license type and user name in the Profile detail page in the community
            contactRec.zoomLicense = con.Virtual_Conference_License__c;
            contactRec.zoomUserName = con.Users.size() > 0 ? con.Users[0].Email : null;
            
            contactRecords.add(contactRec);
        }
        
        return contactRecords;
    }
    
    public static List<contact> wrapperToContactsFormation(List<ContactDomain.ContactInfo> contacts) {
        
        List<contact> contactRecords = new List<contact>();
        
        for(ContactDomain.ContactInfo contactRec : contacts) {
            Contact con = new Contact();
            system.debug('contact Id:::'+contactRec.contactId);
            con.Id = contactRec.contactId;
            con.Salutation = contactRec.salutation;
            con.FirstName = contactRec.firstName;
            con.LastName = contactRec.lastName;
            con.MiddleName = contactRec.middleName;
            con.Email = contactRec.email;
            con.Timezone__c = contactRec.timeZone;
            con.Preferred_Phone__c = contactRec.preferredPhone;
            con.Phone = contactRec.phone;
            con.MobilePhone = contactRec.mobilePhone;
            con.HomePhone = contactRec.homePhone;
            con.MailingStreet = contactRec.mailingStreet;
            con.MailingCity = contactRec.mailingCity;
            con.MailingState = contactRec.mailingState;
            con.MailingPostalCode = contactRec.mailingPostalCode;
            con.Time_Approval_Preference__c = contactRec.timeApprovalPreference;
            
            contactRecords.add(con);
        }
        
        return contactRecords;
    }
    
    public static List<ContactDomain.LanguagesInfo> knowLanguagesFormation(List<Known_Language__c> knownLanguages){
        
        List<ContactDomain.LanguagesInfo> languages = new List<ContactDomain.LanguagesInfo>();
        
        for(Known_Language__c language : knownLanguages) {
            ContactDomain.LanguagesInfo languageRec = new ContactDomain.LanguagesInfo();
            
            languageRec.id = language.Id;
            languageRec.name = language.name;
            languageRec.speaking = language.Speaking_Proficiency__c;
            languageRec.listening = language.Listening_Proficiency__c;
            languageRec.languageName = language.Language_Name__c;
            languageRec.nativeLanguage = language.Native_Language__c;
            languageRec.status = language.status__c;
            languageRec.sobjectName = 'Known Language';
            languages.add(languageRec);
        }
        return languages;
    }
    
     public static List<ContactDomain.SkillInfo> skillRecordFormation(List<Skill__c> skills){
        
        List<ContactDomain.SkillInfo> skillList = new List<ContactDomain.SkillInfo>();
        
        for(Skill__c skill : skills) {
            ContactDomain.SkillInfo skillRec = new ContactDomain.SkillInfo();
            
            skillRec.id = skill.Id;
            skillRec.fromLanguage = skill.From_Language_LU__r.name;
            skillRec.fromLanguageId = skill.From_Language_LU__c;
            skillRec.toLanguageId = skill.To_Language_LU__c;
            skillRec.toLanguage = skill.To_Language_LU__r.name;
            skillRec.rating = skill.Rating__c;
            skillRec.skillVerification = skill.Skill_Verification__c;
            skillRec.dliQualified = skill.DLI_Qualified__c;
            skillRec.name = skill.name;
            skillRec.skill = skill.Skill__c;
            skillRec.sobjectName = 'Skill';
            skillRec.skillName = skill.Skill_Name_Forumula__c;
            skillRec.status = skill.status__c;
            
            skillList.add(skillRec);
        }
        return skillList;
    }
    
    
    public static List<ContactDomain.ExperienceInfo> workExperienceFormation(List<Experience__c> experienceList){
        
        List<ContactDomain.ExperienceInfo> expList = new List<ContactDomain.ExperienceInfo>();
        
        for(Experience__c exp : experienceList) {
            ContactDomain.ExperienceInfo expInfo = new ContactDomain.ExperienceInfo();
            
            expInfo.id = exp.Id;
            expInfo.name = exp.name;
            expInfo.nameOfCompany = exp.Name_of_Company__c;
            expInfo.roleTitle = exp.Role_Title__c;
            expInfo.stardDate = exp.Start_Date__c;
            expInfo.status = exp.status__c;
            if(exp.Start_Date__c != null) {
                expInfo.stardDateStr = ContactChildUpdateController.dateConversion(exp.Start_Date__c.format());
            }
            expInfo.endDate = exp.End_Date__c;
            if(exp.End_Date__c != null) {
                expInfo.endDateStr = ContactChildUpdateController.dateConversion(exp.End_Date__c.format());
            }
            expInfo.services = exp.Services__c;
            expInfo.city = exp.City__c;
            expInfo.state = exp.State__c;
            expInfo.country = exp.Country__c;
            expInfo.ftPt = exp.FT_PT__c;
            expInfo.averageHrsPerWeek = exp.Average_Hrs_Per_Week__c;
            expInfo.totalHoursPerformed = exp.Total_Hours_Performed__c;
            expInfo.description = exp.Description__c;
            expInfo.sobjectName = 'Experience';
            
            expList.add(expInfo);
        }
        
        return expList;
    }
    
    
    public static List<ContactDomain.EducationWrapper> educationRecordsFormation(List<Experience__c> educationList){
        
        List<ContactDomain.EducationWrapper> educationInfoList = new List<ContactDomain.EducationWrapper>();
        
        for(Experience__c exp : educationList) {
            ContactDomain.EducationWrapper educationInfo = new ContactDomain.EducationWrapper();
            
            educationInfo.id = exp.id;
            educationInfo.name = exp.name;
            educationInfo.collegeSchool = exp.College_School__c;
            educationInfo.collegeSchoolType = exp.College_School_Type__c;
            educationInfo.location =  ((exp.City__c == null)?'':(exp.City__c))+((exp.State__c == null)?'':','+(exp.State__c))+((exp.Country__c == null)?'':','+(exp.Country__c));
            educationInfo.degree = exp.Degree__c;
            educationInfo.degreeLevel = exp.Degree_Level__c;
            educationInfo.fieldOfConcentration = exp.Field_of_Concentration__c;
            educationInfo.sobjectName = 'Education';
            educationInfo.status = exp.status__c;
            educationInfo.yearOfCompletion = exp.Year_of_Completion__c;
            
            educationInfoList.add(educationInfo);
        }
        
        return educationInfoList;
    }
    
}