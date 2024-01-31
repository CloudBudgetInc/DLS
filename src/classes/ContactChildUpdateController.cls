public without sharing class ContactChildUpdateController {
    
    @AuraEnabled
    public static String getProfileInformation( String contactId) {
        
        try{
            
            if(contactId != null && contactId != '') {
                ContactDomain.MyProfileWrapper myProfile = new ContactDomain.MyProfileWrapper();
                List<Contact> contactRecord = [SELECT Id,Name, Salutation, FirstName, LastName, MiddleName, /*Suffix,*/ Email, Preferred_Phone__c, Phone,
                                               MobilePhone, HomePhone, MailingStreet, MailingCity, MailingState, MailingPostalCode, Teaching_in_DLS_since__c,
                                               Active_Count_as_Instructor__c, Sum_Instructor_Hours_Week__c, Count_Projects_by_Instructor_Name__c, 
                                               of_Class_Projects_Taught__c, number_of_workshops_attended__c
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
                }
                system.debug('My profile info::::'+myProfile);
                return json.serialize(myProfile);
            }else{
                return 'No Contact Found';
            }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
        
    }
    
    @AuraEnabled
    public static List<ContactDomain.LanguagesInfo> getLanguageList(String contactId){
        system.debug('contact id is '+contactId);
        List<Known_Language__c> languageList = [SELECT Id,Name,Status__c,Language_Name__c,Listening_Proficiency__c,Speaking_Proficiency__c, Native_Language__c, Contact__c FROM Known_Language__c
                                                            WHERE Contact__c = :contactId  AND (Status__c = 'Deleted' OR Status__c = 'Instructor Modified')];
        system.debug('language list is '+languageList);
        return ContactTranslator.knowLanguagesFormation(languageList);
    }
    @AuraEnabled
    public static void  updateStatus(Id recordId , String action){

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
        List<Skill__c> skillList = [SELECT Id,Name,Status__c,Skill_Name_Forumula__c,From_Language_LU__r.name,To_Language_LU__r.name,Rating__c,Skill_Verification__c,DLI_Qualified__c, Contact__c FROM Skill__c WHERE Contact__c = :contactId AND (Status__c = 'Deleted' OR Status__c = 'Instructor Modified')];
        
        return ContactTranslator.skillRecordFormation(skillList);
    }
    
    @AuraEnabled
    public static List<ContactDomain.ExperienceInfo> getExperienceList(String contactId){
        List<Experience__c> experienceList = [SELECT Id,Name,Status__c,Name_of_Company__c,recordtypeid, Role_Title__c, Start_Date__c, End_Date__c, Services__c, City__c,
                                                    State__c, Country__c, FT_PT__c, Average_Hrs_Per_Week__c, Total_Hours_Performed__c, Description__c
                                                    FROM Experience__c WHERE (Status__c = 'Deleted' OR Status__c = 'Instructor Modified') AND Contact__c = :contactId AND RecordType.DeveloperName = 'Professional_Work_Experience'];
        return  ContactTranslator.workExperienceFormation(experienceList);
    }
    
    @AuraEnabled
    public static List<ContactDomain.EducationWrapper> getEducationList(String contactId){
        List<Experience__c> educationList = [SELECT Id,Name,Status__c,College_School__c,recordtypeid,College_School_Type__c, City__c, State__c, Country__c, Degree__c,
                                                         Degree_Level__c, Field_of_Concentration__c, Year_of_Completion__c, Contact__c
                                                         FROM Experience__c WHERE  (Status__c = 'Deleted' OR Status__c = 'Instructor Modified')  AND Contact__c = :contactId AND RecordType.DeveloperName = 'Education_Experience'];
        return ContactTranslator.educationRecordsFormation(educationList);
    }

    @AuraEnabled
    public static String updateContactRecord(String contactRecord){
        /* For Updating Contact Record */
        ContactDomain.ContactInfo conRecord = (ContactDomain.ContactInfo)JSON.deserialize(contactRecord, ContactDomain.ContactInfo.class);
        List<Contact> contactList = ContactTranslator.wrapperToContactsFormation(new List<ContactDomain.ContactInfo>{conRecord});
        if(contactList != null && contactList.size() > 0) {
            update contactList;
        }
        System.debug('Contact list:::'+contactList);
        return '';
    }
    
    public static String getLoggedUserContactId() {
        return [Select Id,ContactId FROM User where Id =: userInfo.getUserId()].ContactId; //For getting Logged in User contact Id
    }
    
    
    @AuraEnabled
    public static List<ContactDomain.fieldWrapper> fieldValuesFormation(Id recId){
        system.debug('id is'+recId);
        String sobjectName = recId.getSObjectType().getDescribe().getName();
        Known_Language__c language;
        //Lookup fields value 
        
        List<Map<String,String>> languageLookup = new List<Map<String,String>>();
        List<Map<String,String>> oldLanguage = new List<Map<String,String>>();
        Map<String,String> oldlanguageIdname = new Map<String,String>();
        Map<String,String> newlanguageIdname = new Map<String,String>();
        
        String query = 'SELECT ';
        Map<String,String> oldObject;
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sobjectName).getDescribe().fields.getMap();
        for(String fieldName : fieldMap .Keyset()){
            query = query+fieldName+',';
        }
        query = query.removeEnd(',');
        query = query+' FROM '+sobjectName+' WHERE ID=:recId';
        Sobject newObject = Database.query(query);
        String oldJson = String.valueOf(newObject.get('Old_Value_Json__c'));
        if(newObject.get('Old_Value_Json__c') != null){
             oldObject = (Map<String,String>)JSON.deserialize(oldJson, Map<String,String>.class);
        }
        if(sobjectName == 'Known_Language__c'){
            language = [SELECT Id,Language__c,Language__r.name FROM Known_Language__c where id=:recId];
            newlanguageIdname.put('Id' , language.Language__c);
            newlanguageIdname.put('Name' , language.Language__r.name);
            languageLookup.add(newlanguageIdname);
            
        }
        List<ContactDomain.fieldWrapper> fieldsList = new List<ContactDomain.fieldWrapper>();
        Map<String,String> fieldLabelMap = new Map<String,String>();
        if(oldObject != null){
            if(oldObject.containsKey('Language__c')){
                Language__c lang = [SELECT Id,Name from Language__c where id=:oldObject.get('Language__c')];
                oldlanguageIdname.put('Id' , lang.Id);
                oldlanguageIdname.put('Name' , lang.Name);
                oldLanguage.add(oldlanguageIdname);
            }
            for(Schema.SObjectField sfield : fieldMap.Values()) {
                schema.describefieldresult dfield = sfield.getDescribe();                    
                     if(oldObject.get(dfield.getName()) != null){
                        if(oldObject.get(dfield.getName()) != newObject.get(dfield.getName())){
                            ContactDomain.fieldWrapper changedField = new ContactDomain.fieldWrapper();
                            changedField.fieldName = dfield.getLabel();
                            changedField.fieldType = String.valueOf(dfield.getType());
                            if(changedField.fieldType == 'DATE'){
                                
                                changedField.oldValue = dateConversion(Date.valueOf(oldObject.get(dfield.getName())).format());
                                changedField.newValue = dateConversion(Date.valueOf(newObject.get(dfield.getName())).format()); 
                                changedField.selectedValue = changedField.newValue;
                            }else{
                                changedField.oldValue = String.valueOf(oldObject.get(dfield.getName()));
                                changedField.newValue = String.valueOf(newObject.get(dfield.getName()));
                                changedField.selectedValue = String.valueOf(newObject.get(dfield.getName()));
                            }
                            if(changedField.fieldType == 'REFERENCE' && sobjectName == 'Known_Language__c'){
                                changedField.lookUpList = languageLookup;
                                changedField.oldlookUpList = oldLanguage;
                                changedField.newlookUpList = languageLookup;
                            }
                            changedField.apiName = dfield.getName();
                            fieldsList.add(changedField);
                        }
                    }                
            }
        }
                system.debug('id is'+fieldsList);

        return fieldsList;
    }
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    }  
    
    @AuraEnabled
    public static string updateRecords(List<Sobject> finalRecsList ){
        List<Sobject> newList = new List<Sobject>();
        for(Sobject obj : finalRecsList){
            obj.put('Status__c' , Null);
            obj.put('Old_Value_Json__c', Null);
            newList.add(obj);
        }
        system.debug('newList'+newList);
        if(newList.size() > 0){
            update newList;
        } 
        return 'Success';
    }
    
    @AuraEnabled
    public static string recordDelete(String recId ){
        database.delete(recId);
        return '';
    }
    
    public static string dateConversion(String dateStr){
        List<String> dateList = dateStr.split('/');
        if(Integer.Valueof(dateList[0]) < 10){
            dateList[0] = '0'+dateList[0];
        }
        if(Integer.Valueof(dateList[1]) < 10){
            dateList[1] = '0'+dateList[1];
        }
        String retString = dateList[0]+'/'+dateList[1]+'/'+dateList[2];
        return retString;
    }    
}