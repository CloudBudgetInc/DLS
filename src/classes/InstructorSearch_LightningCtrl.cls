public class InstructorSearch_LightningCtrl {
    public class filterDetails {
        List<String> serviceList;
        List<String> skillRating;
        List<String> degrees;
        List<String> dlsRating;
        List<String> citizenship;
        List<String> countryOfBirth;
        List<Language__c> langList;
        List<MTT_Location__c> locations;
        List<String> timeList;
        List<String> instructorStatus;
        List<User> userList;
    }
    
    public class contactChildDetails {
        List<Skill__c> skillRecords;
        List<Experience__c> experienceRecords;
        List<Language_Testing__c> languageTestingRecords;
        List<Schedule__c> scheduleRecords;
     }
    
    @AuraEnabled
    public static String getContacts(){
        List<Contact> contactList = [SELECT Id,Name,Language_1__c,Language_2__c,DLS_Candidate_Rating__c,Testing_Experience__c,
                                            of_Class_Projects_Taught__c,Proximity__c,Instructor_Status__c,Next_Availability__c,Availability__c,Candidate_Notes__c
                                    FROM Contact];
        return JSON.serialize(contactList);
    }
    
    @AuraEnabled
    public static String getFilterRelatedInfo(){
        filterDetails filDetail = new filterDetails();
        
        // Service info
        List<String> sericeValues = InstructorSearchController.getService();
        
        // skillRating
        List<String> skillRate = new List<String>();
        List<Schema.PicklistEntry> dlsRatePicklist = Skill__c.Rating__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : dlsRatePicklist) {
            skillRate.add(entry.getValue());
        }
        // Degrees
        List<String> degreesList = InstructorSearchController.getDegreeLevel();
        
        // DLS Candidate Rating
        List<String> dlsRating = InstructorSearchController.getDlSRatePicklistValues();
        
        // Citizenship
        List<String> citizenship = InstructorSearchController.getCitizenshipvalues();
        
        // Country of Birth
        List<String> cob = InstructorSearchController.getCountryofBirthvalues();
        
        // Language
        List<Language__c> languageRecords = InstructorSearchController.getAllLanguages();
        
        // Locations
        List<MTT_Location__c> locationsList = [SELECT Id,Name FROM MTT_Location__c ORDER BY Name ASC]; 
        
        //Time
        List<String> timeList = InstructorSearchController.getTimePicklist();
        
        // Instructor Status
        List<String> insStatusList = new List<String>();
        List<Schema.PicklistEntry> statucPicklist = Contact.Instructor_Status__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : statucPicklist) {
            insStatusList.add(entry.getValue());
        }
        
        // User list for book mark filters
        List<User> usrList = [SELECT Id,Name FROM User];
        
        filDetail.serviceList = sericeValues;
        filDetail.skillRating = skillRate;
        filDetail.degrees = degreesList;
        filDetail.dlsRating = dlsRating;
        filDetail.citizenship = citizenship;
        filDetail.countryOfBirth = cob;
        filDetail.langList = languageRecords;
        filDetail.locations = locationsList;
        filDetail.timeList = timeList;
        filDetail.instructorStatus = insStatusList;
        filDetail.userList = usrList;
        
        return JSON.serialize(filDetail);
    }
    
    /***************************************************************
     - Method to filter the contacts based on the user filters
     - Added by NS on May 21 2018
    ***************************************************************/
    @AuraEnabled
    public static string getAllInstructors(Boolean isConflictSearch, String conflictSearchJSon, String parametersJson) {
       try {
           
            InstructorSearchController.ConflictSearchParameter conflictSearch = (InstructorSearchController.ConflictSearchParameter) System.JSON.deserialize(conflictSearchJSon, InstructorSearchController.ConflictSearchParameter.class);
            SearchParameter parameters = (SearchParameter) System.JSON.deserialize(parametersJson, SearchParameter.class);
            system.debug(':::::::::::::isConflictSearch::::::'+isConflictSearch);
            system.debug(':::::::::::::conflictSearch::::::'+conflictSearch);
            system.debug(':::::::::::::parameters::::::'+parameters);
            
            InstructorSearchController.SearchResult result = new InstructorSearchController.SearchResult();
            result = getAllInstructorsWithoutConflictCheck(parameters);
            if(isConflictSearch) {
                //Search Instructors without conflicts
                result.conflictCount = InstructorSearchController.getInstructorsWithConflictsCheck(conflictSearch, parameters, InstructorSearchController.getContactIdSet(result.instructors));
            }
            system.debug('::::::::::::Limits.getHeapSize():::::'+Limits.getHeapSize());
            return JSON.serialize(result);
        }catch(Exception e) {
            system.debug(':::::::e.getMessage():::::'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static InstructorSearchController.SearchResult getAllInstructorsWithoutConflictCheck(SearchParameter parameters) {
        String zip = parameters.zip;
        Id locationId = parameters.locationId;
                
        InstructorSearchController.SearchResult result = new InstructorSearchController.SearchResult();
        //result.instructors = instructorList;
        QualificationUtil_Clone.FilteredContacts fContacts = QualificationUtil_Clone.getFilteredContact(parameters.bundleId, parameters);
        result.instructors = fContacts.filteredList;
        result.instructorScore = fContacts.instructorScore;
        result.proximities = InstructorSearchController.getProximites(fContacts.filteredList, zip, locationId);
        result.recordCount = fContacts.totalCount;
        return result;
    }
    
    /***************************************************************
     - Method to get Contact related Book Mark record
     - Added by NS on May 23 2018
    ***************************************************************/
    @AuraEnabled
    public static string getBookmarkDetails(String contactId,String userId) {
        if(userId == null){
            userId = userinfo.getuserid();
        }
        List<Bookmark__c> bookMarkList = new List<Bookmark__c>();
        bookMarkList = [SELECT Id,Name,Contact__c,User__c,Referral_Source__c,To_Hire__c,To_Interview__c,Top_Candidate__c 
                            FROM Bookmark__c WHERE Contact__c = :contactId AND User__c = :userId];
        
        return JSON.serialize(bookMarkList);
    }
    
    /**********************************************************
    - Method to get Contact related child records information(Skills, Experience, Schedules,Language Testing)
    - Added by NS on July 20 2018
    ***********************************************************/  
    @AuraEnabled
    public static string getContactChildRecords(String contactId) {
        List<Skill__c> skills = [SELECT Id,Name,Contact__c,Contact__r.Name,ContId_ExperienceId_FLang_TLan_Skill_Ext__c,From_Language_LU__c,
                                        From_Language_LU__r.Name,Language_S_L_R_W__c,Skill__c,Skill_Verification__c,To_Language_LU__c,To_Language_LU__r.Name,From_Language__c,To_Language__c 
                                FROM Skill__c WHERE Contact__c = :contactId];
                                
        List<Experience__c> experiences = [SELECT Id, Name, Country__c,End_Date__c,Experience_in_Years__c,Experience_in_Months__c,ILR_Skill_Level__c,
                                                        Name_of_Company__c,Role_Title__c,Services__c,Start_Date__c,State__c,RecordType.DeveloperName,
                                                        College_School__c,College_School_Type__c,Degree__c,Degree_Level__c,Year_of_Completion__c,Total_Hours_Performed__c 
                                                FROM Experience__c WHERE Contact__c = :contactId];
                                                
        List<Language_Testing__c> languageTesting = [SELECT Id, Target_Language__c, L_Score__c, S_Score__c FROM Language_Testing__c WHERE Tester__c = :contactId];
        
        List<Schedule__c> schedules = [SELECT Id,Name,Start_Date__c,Start_Time__c,End_Date__c,End_Time__c,Days__c,Hours_Week__c FROM Schedule__c WHERE Instructor__c = :contactId];
        
        contactChildDetails childInfo = new contactChildDetails();
        childInfo.skillRecords = skills;
        childInfo.experienceRecords = experiences;
        childInfo.languageTestingRecords = languageTesting;
        childInfo.scheduleRecords = schedules;
        
        system.debug('::::::Limits.getHeapSize():::'+Limits.getHeapSize());
        return JSON.serialize(childInfo);
    }
    
    /******************************************************
     - Get Lookup search related records
     - Added by NS on August 27 2018
    *******************************************************/
    @AuraEnabled
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(searchString,objectName,fieldName,condition,selectedIds);
    }   
    
    /*********************************************************
    - Get Parent language value to pre popoulate the language filter
    - Added by NS on Dec 31 2018
    **********************************************************/
    @AuraEnabled
    public static String getParentInformation(String parentId, String parentType){
        
        List<Language__c> langRec = new List<Language__c>();
        
        if(parentType == 'OPPORTUNITY') {
            List<Opportunity> oppList = [SELECT Id,Name,Language_LU__c,Language_LU__r.Name FROM Opportunity WHERE Id = :parentId];
            Language__c lang = new Language__c();
            lang.Id = oppList[0].Language_LU__c;
            lang.Name = oppList[0].Language_LU__r.Name;
            langRec.add(lang);
        }else if(parentType == 'PROJECT') {
            List<AcctSeed__Project__c> proList = [SELECT Id,Name,Language__c,Language__r.Name FROM AcctSeed__Project__c WHERE Id = :parentId];
            Language__c lang = new Language__c();
            lang.Id = proList[0].Language__c;
            lang.Name = proList[0].Language__r.Name;
            langRec.add(lang);
        }
        
        return JSON.serialize(langRec);
        //return '';
    }
     
}