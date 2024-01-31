public without sharing class InstructorMyProfileController{
    
    @AuraEnabled
    public static String getProfileInformation() {
        
        try{
        
            String contactId = getLoggedUserContactId();
            if(contactId != null && contactId != '') {
            
                MyProfileWrapper myProfile = new MyProfileWrapper();
                
                List<Contact> contactRecord = [SELECT Id,Name, Salutation, FirstName, LastName, MiddleName, /*Suffix,*/ Email, Preferred_Phone__c, Phone,
                                                       MobilePhone, HomePhone, MailingStreet, MailingCity, MailingState, MailingPostalCode, Teaching_in_DLS_since__c,
                                                       Active_Count_as_Instructor__c, Sum_Instructor_Hours_Week__c, Count_Projects_by_Instructor_Name__c, 
                                                       of_Class_Projects_Taught__c, number_of_workshops_attended__c,Timezone__c,of_Tests_Perfomed__c,
                                                       of_Students_Taught__c,of_Class_Hours__c,Time_Approval_Preference__c,of_Hours_Taught_at_Vendor__c, Virtual_Conference_License__c, (SELECT Id, Email FROM Users) //Added By Dhinesh - W-006013 - Zoom Integration - to show zoom license type and user name in the Profile detail page in the community 
                                               FROM Contact WHERE Id = :contactId];
                                               
                if(contactRecord.size() > 0) {
                
                    /* Querying Contact, Experience, Skill and known language objects */
                    List<Contact> contactList = new List<Contact>();
                    contactList.add(contactRecord[0]);
                    
                    myProfile.contactRec = ContactTranslator.contactRecordsFormation(contactList)[0];
                    myProfile.languageList = getLanguageList(contactId);
                    myProfile.skillList = getSkillList(contactId) ;
                    myProfile.workExperianceList = getExperienceList(contactId );
                    myProfile.educationList = getEducationList(contactId);
                    myProfile.expRecTypeId = [SELECT ID FROM Recordtype WHERE DeveloperName='Professional_Work_Experience'].Id;
                    myProfile.educationRecTypeId = [SELECT ID FROM Recordtype WHERE DeveloperName='Education_Experience'].Id;
                    
                    //Salutation,Preferred_Phone__c field picklist formation
                    myProfile.contactRec.salutationPickList = objPickListFormation('Salutation','Contact');
                    myProfile.contactRec.preferredPhonePickList = objPickListFormation('Preferred_Phone__c','Contact');
                    
                    //Skill Name Picklist Formation
                    myProfile.skillObjectPickList = objPickListFormation('Skill__c','Skill__c');
                }
                
                system.debug('My profile info::::'+myProfile);
                return JSON.serialize(myProfile);
            }else{
                return 'No Contact Found';
            }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
        
    }
    
    @AuraEnabled
    public static String getWorkshopAttededByContactId() {
        String contactId = getLoggedUserContactId();       
        return JSON.serialize([SELECT Id, Professional_Development__c, Professional_Development__r.Name, Professional_Development__r.Date__c, Professional_Development__r.Workshop_Presenter__c FROM Workshop_Attendance__c WHERE Instructor_Name__c = :contactId ORDER BY Professional_Development__r.Date__c DESC]);        
    }
    
    /* Picklist formation*/
    @AuraEnabled
    public static List<String> objPickListFormation(String fieldName,String ObjName){
    
        List<String> options = new List<String>();
        sObject sObj = Schema.getGlobalDescribe().get(ObjName).newSObject();
        Schema.sObjectType sObjType = sObj.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sObjType.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); 
        
        for( Schema.PicklistEntry f : pick_list_values){
            options.add(f.getValue());
        }      
        return options;
    }
    
    @AuraEnabled
    public static List<ContactDomain.LanguagesInfo> getLanguageList(String contactId){
    
        List<Known_Language__c> languageList = [SELECT Id,Name,Status__c, Language_Name__c, Native_Language__c, Contact__c,Speaking_Proficiency__c,Listening_Proficiency__c 
                                                FROM Known_Language__c
                                                WHERE Contact__c = :contactId AND Status__c != 'Deleted' Order By Language_Name__c ASC];
                                                
        return ContactTranslator.knowLanguagesFormation(languageList);
    }
    
    @AuraEnabled
    public static void  updateStatus(Id recordId , String action){
    
        system.debug('record id is '+recordId+action);
        String sobjectName = recordId.getSObjectType().getDescribe().getName();
        String query = 'SELECT ID,Status__c FROM '+ sobjectName+' WHERE ID =:recordId';
        Sobject objRec = Database.query(query);
        if(action == 'editicon'){
            objRec.put('Status__c','Instructor Modified');
        }else if(action == 'deleteicon'){
            objRec.put('Status__c','Deleted');
        }
        Update objRec; 
        
    } 
    @AuraEnabled
    public static List<ContactDomain.SkillInfo> getSkillList(String contactId){
        
        List<Skill__c> skillList = [SELECT Id,Name,Rating__c,Skill_Name_Forumula__c,Skill__c,status__c,From_Language_LU__r.name,From_Language_LU__c,To_Language_LU__r.name,
                                            To_Language_LU__c,Skill_Verification__c,DLI_Qualified__c, Contact__c 
                                    FROM Skill__c 
                                    WHERE Contact__c = :contactId AND Status__c != 'Deleted' Order By  Skill_Name_Forumula__c ASC];
        
        return ContactTranslator.skillRecordFormation(skillList);
    }
    
    @AuraEnabled
    public static List<ContactDomain.ExperienceInfo> getExperienceList(String contactId){
    
        List<Experience__c> experienceList = [SELECT Id,Name,status__c, Name_of_Company__c,recordtypeid, Role_Title__c, Start_Date__c, End_Date__c, Services__c, City__c,
                                                    State__c, Country__c, FT_PT__c, Average_Hrs_Per_Week__c, Total_Hours_Performed__c, Description__c
                                                FROM Experience__c 
                                                WHERE Status__c != 'Deleted' AND Contact__c = :contactId AND RecordType.DeveloperName = 'Professional_Work_Experience' Order By End_Date__c DESC];
        
        List<ContactDomain.ExperienceInfo> conExp = ContactTranslator.workExperienceFormation(experienceList);
        
        for(ContactDomain.ExperienceInfo contactExp : conExp) {
            if(String.isBlank(contactExp.endDateStr)) {
                contactExp.endDateStr = 'Present';
            }
        }
        return conExp;
    }
    
    @AuraEnabled
    public static List<ContactDomain.EducationWrapper> getEducationList(String contactId){
        
        List<Experience__c> educationList = [SELECT Id,Name,status__c, College_School__c,recordtypeid,College_School_Type__c, City__c, State__c, Country__c, Degree__c,
                                                         Degree_Level__c, Field_of_Concentration__c, Year_of_Completion__c, Contact__c
                                             FROM Experience__c 
                                             WHERE Status__c != 'Deleted'  AND Contact__c = :contactId AND RecordType.DeveloperName = 'Education_Experience' Order By Year_of_Completion__c DESC NULLS LAST];
        
        return ContactTranslator.educationRecordsFormation(educationList);
    }

    @AuraEnabled
    public static String updateContactRecord(String contactRecord){
    
        //check current user profile is Instructor community / Any internal user allow them to create records
        //if not throw validation msg
        Boolean currentUsrIsValid = checkCurrentUsrIsValid();
        if(!currentUsrIsValid){
            throw new AuraHandledException('Your session is expried and the changes will not be saved. Please login to contact information');
        }
        
        /* For Updating Contact Record */
        ContactDomain.ContactInfo conRecord = (ContactDomain.ContactInfo)JSON.deserialize(contactRecord, ContactDomain.ContactInfo.class);
        List<Contact> contactList = ContactTranslator.wrapperToContactsFormation(new List<ContactDomain.ContactInfo>{conRecord});
        if(contactList != null && contactList.size() > 0) {
            update contactList;
        }
        System.debug('Contact list:::'+contactList);
        return '';
    }
    
    @AuraEnabled
    public static String getLoggedUserContactId() {
        return [Select Id,ContactId FROM User where Id =: userInfo.getUserId()].ContactId; //For getting Logged in User contact Id
    }
    
    // to get lookup records
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    } 
     
    // to upsert the skill record
    @AuraEnabled
    public static String upsertSkill(String skillJSON){
        List<Skill__c> skillList = (List<Skill__c>) JSON.deserialize(skillJSON, List<Skill__c>.class);
        
        //check current user profile is Instructor community / Any internal user allow them to create records
        //if not throw validation msg
        Boolean currentUsrIsValid = checkCurrentUsrIsValid();
        if(!currentUsrIsValid){
            throw new AuraHandledException('Your session is expried and the changes will not be saved. Please login to skill information');
        }
        
        if(skillList.size() > 0) {
            upsert skillList;
        }
        return 'Success';
    }
    
    //Method to check current user is session is expired or not
    @AuraEnabled
    public static Boolean checkCurrentUsrIsValid(){
        
        List<User> currentUsr = [SELECT Id,Name,Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        if(currentUsr.size() > 0 && currentUsr[0].Profile.Name == 'Instructor Profile'){
            
            return false;
        }
        return true;
    }
    
    public class MyProfileWrapper {
        @AuraEnabled
        public ContactDomain.ContactInfo contactRec;
        @AuraEnabled
        public String educationRecTypeId;
        @AuraEnabled
        public String expRecTypeId;
        @AuraEnabled
        public List<ContactDomain.LanguagesInfo> languageList;
        @AuraEnabled
        public List<ContactDomain.SkillInfo> skillList;
        @AuraEnabled
        public List<ContactDomain.ExperienceInfo> workExperianceList;
        @AuraEnabled
        public List<ContactDomain.EducationWrapper> educationList;
        @AuraEnabled
        public List<String> skillObjectPickList;
    }
}