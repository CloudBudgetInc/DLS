/**********************************************************************
    Created by Mohana on Apr 30 2019: Domain class used for Contact object inner class formation
***********************************************************************/

global class ContactDomain {
    
    /**********************************************************************
    - Added by Mohana on Apr 30 2019
    - For Instructor & Student Community My Profile tab
    ***********************************************************************/
    public class ContactInfo {
        public String contactId;
        public String salutation;
        public String firstName;
        public String lastName;
        public String middleName;
        public String email;
        public String preferredPhone;
        public String phone;
        public String mobilePhone;
        public String homePhone;
        public String timeZone;
        public String mailingStreet;
        public String mailingCity;
        public String mailingState;
        public String mailingPostalCode;
        public String timeApprovalPreference;
        public Date teachingInDlsSince;
        public String teachingInDlsSinceStr;
        public Decimal activeCountAsInstructor;
        public Decimal sumInstructorHoursWeek;
        public Decimal countProjectByInstructorName;
        public Decimal classProjectsTaught;
        public Decimal noOfWorkshopsAttended;
        public Decimal noOfTestsPerformed;
        public Decimal noofStudentsTaught;
        public Decimal noOfClassHours;
        
        //Added By Dhinesh - W-006013 - Zoom Integration - to show zoom license type and user name in the Profile detail page in the community
        public String zoomLicense;
        public String zoomUserName;
        
        public List<String> timeZonePicklist;
        public List<String> salutationPickList;
        public List<String> preferredPhonePickList;
        public List<String> timeApprovalPreferencePickList;
    }
    
    public class LanguagesInfo {
        public Id id;
        public String name;
        public String languageName;
        public String listening;
        public String status;
        public String speaking;
        public Boolean nativeLanguage;
        public Boolean isChanged;
        public string sobjectName;
    }
    
    public class SkillInfo {
        public Id id;
        public String name;
        public String skill;
        public String skillName;
        public String fromLanguage;
        public String toLanguage;
        public String fromLanguageId;
        public String toLanguageId;
        public String rating;
        public String status;
        public String skillVerification;
        public boolean dliQualified;
        public Boolean isChanged;
        public string sobjectName;
    }
       
    public class ExperienceInfo {
        public Id id;
        public String name;
        public String nameOfCompany;
        public String roleTitle;
        public Date stardDate;
        public String stardDateStr;
        public Date endDate;
        public String endDateStr;
        public String services;
        public String city;
        public String state;
        public String country;
        public String ftPt;
        public String status;
        public Decimal averageHrsPerWeek;
        public String totalHoursPerformed;
        public String description;
        public Boolean isChanged;
        public string sobjectName;
    }
    
    public class EducationWrapper {
        public String id;
        public String name;
        public String collegeSchool;
        public String collegeSchoolType;
        public String location;        
        public String degree;
        public String status;
        public String degreeLevel;
        public String fieldOfConcentration;
        public String yearOfCompletion;
        public Boolean isChanged;
        public string sobjectName;
    }
    public class fieldWrapper {
        @Auraenabled
        public String fieldName;
        @Auraenabled
        public String oldValue;
        @Auraenabled
        public String newValue;
        @Auraenabled
        public String fieldType;
        @Auraenabled
        public String apiName;
        @Auraenabled
        public String selectedValue;
        @Auraenabled
        public List<Map<String,String>> oldlookUpList;
        @Auraenabled
        public List<Map<String,String>> newlookUpList;
        @Auraenabled
        public List<Map<String,String>> lookUpList;
    }
        public class MyProfileWrapper {
        public ContactDomain.ContactInfo contactRec;
        public String educationRecTypeId;
        public String expRecTypeId;
        public List<ContactDomain.LanguagesInfo> languageList;
        public List<ContactDomain.SkillInfo> skillList;
        public List<ContactDomain.ExperienceInfo> workExperianceList;
        public List<ContactDomain.EducationWrapper> educationList;
    }
    
}