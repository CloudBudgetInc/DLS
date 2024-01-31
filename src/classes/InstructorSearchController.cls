public class InstructorSearchController {
    
    public static SearchResult getAllInstructorsWithoutConflictCheck(SearchParameter parameters) {
        String zip = parameters.zip;
        Id locationId = parameters.locationId;
                
        SearchResult result = new SearchResult();
        //result.instructors = instructorList;
        QualificationUtil.FilteredContacts fContacts = QualificationUtil.getFilteredContact(parameters.bundleId, parameters);
        result.instructors = fContacts.filteredList;
        result.instructorScore = fContacts.instructorScore;
        result.proximities = getProximites(fContacts.filteredList, zip, locationId);
        result.recordCount = fContacts.totalCount;
        return result;
    }
    
    public static Integer sanitizeScore(String stringScore) {
        if(stringScore == 'N/A')
            return 0;
        Integer index = stringScore.indexOf('+');
        try {
            if(index != -1) {
                return Integer.valueOf(stringScore.substring(0, index));
            }
            return Integer.valueOf(stringScore);
        } catch(Exception e) {
            return 0;
        }
    }
    
    @RemoteAction
    public static List<Qualification_Bundle_Item__c> getQualificationSettings(Id bundleId,List<Id> qualificationIds) {
        return QualificationUtil.getQualificationSettings(bundleId,qualificationIds);
    }
    
    @RemoteAction
    public static List<Qualification_Bundle__c> getAllQualificationBundle() {
        return QualificationUtil.getAllQualificationBundle();
    }
    
    @RemoteAction
    public static SearchResult getAllInstructors(Boolean isConflictSearch, ConflictSearchParameter conflictSearch, SearchParameter parameters) {
        System.debug('mel ' + conflictSearch);
        System.debug('mel ' + isConflictSearch);
        System.debug('mel ' + parameters);
        SearchResult contactList = new SearchResult();
        contactList = getAllInstructorsWithoutConflictCheck(parameters);
        if(isConflictSearch) {
            //Search Instructors without conflicts
            contactList.conflictCount = getInstructorsWithConflictsCheck(conflictSearch, parameters, getContactIdSet(contactList.instructors));
        }
        return contactList;
    }
    
    public static Set<Id> getContactIdSet(List<Contact> contactList) {
        Set<Id> contactIdSet = new Set<Id>();
        for(Contact con : contactList) {
            contactIdSet.add(con.Id);
        }
        return contactIdSet;
    }
    
    @RemoteAction
    public static String[] getService() {
        return JobBoardController.getJobTypePicklist();
    }
    
    @RemoteAction
    public static List<Language__c> getAllLanguages() {
       return [SELECT Id,Name FROM Language__c ORDER BY Name ASC];    
   }
    
    @RemoteAction
    public static String[] getAllColleges() {
        String[] collegeList = new List<String>();
        //List<Experience__c> experienceLIst = [SELECT Id, Name, College_School__c FROM Experience__c WHERE College_School__c != null];
        List<Experience__c> experienceLIst = ExperienceService.getExperiencesByFilterQuery(' WHERE College_School__c != null');
        for(Experience__c exp : experienceLIst) {
            collegeList.add(exp.College_School__c);
        }
        return collegeList;
    }

    @RemoteAction
    public static void assignContactAssignment(String parentType, Id parentId, Id instructorId, Boolean isFSI) {
        Date startDate;
        Date endDate;
        Id projectId;
        Id opportunityId;
        String status;
        
        //List<AcctSeed__Project__c> prList = [SELECT Id, Start_Date__c, End_Date__c FROM AcctSeed__Project__c WHERE Id = :parentId];
        List<AcctSeed__Project__c> prList = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',new Set<Id>{parentId},'');
        if(prList.size() > 0) {
            projectId = prList[0].Id;
            startDate = prList[0].Start_Date__c;
            endDate = prList[0].End_Date__c;
            status = 'Planned';
        }
        
        //List<Opportunity> oppList = [SELECT Id, Start_Date__c, End_Date__c FROM Opportunity WHERE Id = :parentId];
        List<Opportunity> oppList = SObjectQueryService.SObjectQuery('Opportunity',new Set<Id>{parentId},'');
        if(oppList.size() > 0) {
            opportunityId = oppList[0].Id;
            startDate = oppList[0].Start_Date__c;
            endDate = oppList[0].End_Date__c;
            if(isFSI) status = 'Qualifying';
            else status = 'Planned';
        }
        
        //List<Contact_Assignments__c> contactList = [SELECT Id FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Candidate_Name__c = :instructorId AND (Project__c = :parentId OR Opportunity_Name__c = :parentId)];
        List<Contact_Assignments__c> contactList = ContactAssignmentService.getContactassignmentByprojectId( ' WHERE RecordType.DeveloperName = \'Instructor\' AND Candidate_Name__c = \''+instructorId+'\' AND (Project__c = \''+parentId+'\' OR Opportunity_Name__c = \''+parentId+'\')','',new Set<Id>{},'');
        
        System.debug('Plus contactList ' + contactList);
        if(contactList.size() == 0) {
            System.debug('Plus Going to insert');
            Contact_Assignments__c newInstructor = new Contact_Assignments__c();
            newInstructor.Candidate_Name__c = instructorId;
            newInstructor.Assignment_Position__c = 'Instructor';
            newInstructor.Status__c = status;
            newInstructor.Start_Date__c = startDate;
            newInstructor.End_Date__c = endDate;
            //List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact_Assignments__c' AND DeveloperName = 'Instructor'];
            List<RecordType> recordTypeList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName(' AND DeveloperName','Contact_Assignments__c',new Set<String>{'Instructor'});
            
            id insRecordTypeId;
            if(recordTypeList.size() > 0) {
                insRecordTypeId = recordTypeList[0].Id;
            }
            newInstructor.Project__c = projectId;
            newInstructor.Opportunity_Name__c = opportunityId;
            newInstructor.Opportunity_Name__c = opportunityId;
            newInstructor.RecordTypeId = insRecordTypeId;
            newInstructor.Assignment_Position__c = 'Instructor';
            insert newInstructor;
            System.debug('Plus Inserted Successfully ' + newInstructor);
        }
    }
    
    @RemoteAction
    public static void assignInstructor(Id scheduleId, Id instructorId) {
        EventManagementController.setInstructor(scheduleId, instructorId);
    }
    
    @RemoteAction
    public static String[] getAllCompanies() {
        String[] companyList = new List<String>();
        //List<Experience__c> experienceList = [SELECT Id, Name, Name_of_Company__c FROM Experience__c WHERE Name_of_Company__c!= null];
        List<Experience__c> experienceList = ExperienceService.getExperiencesByFilterQuery(' WHERE Name_of_Company__c != null');
        for(Experience__c exp : experienceLIst) {
            companyList.add(exp.Name_of_Company__c);
        }
        return companyList;
    }
    
    //
    // Retrive List of Instructors without conflicts on a particular time period.
    // 
    //
    @RemoteAction
    public static Map<Id, Integer> getInstructorsWithConflictsCheck(ConflictSearchParameter conflictSearch, SearchParameter parameters, Set<Id> contactIdSet) {
        String zip = parameters.zip;
        Date startDate = date.parse(conflictSearch.startDate);
        Date endDate = date.parse(conflictSearch.endDate);
        Integer currStartTime = EventManagementController.convertToMinutes(conflictSearch.startTime);
        Integer currEndTime = EventManagementController.convertToMinutes(conflictSearch.endTime);
        
        //Convert Time string to integer minutes.
        Map<Id, Integer> instructorMap = new Map<Id, Integer>();
        
        for(Schedule__c sch : [SELECT Id,Name,Start_Date__c,End_Date__c, Start_Time__c,Instructor__c, 
                                      End_Time__c, Room__c, Room__r.Name, Monday__c, Saturday__c, 
                                      Sunday__c, Thursday__c, Tuesday__c, Wednesday__c,Friday__c,
                                      Project__r.Name,Opportunity__c,Opportunity__r.Name
                              FROM Schedule__c 
                              WHERE Instructor__c != null AND Instructor__c IN :contactIdSet
                                  AND End_Date__c >= :startDate AND Start_Date__c <= :endDate]) {
            
            Integer StartTime = sch.Start_Time__c != null ? EventManagementController.convertToMinutes(sch.Start_Time__c):null;
            Integer EndTime = sch.End_Time__c != null ? EventManagementController.convertToMinutes(sch.End_Time__c): null;
            
            if((sch.Monday__c && (sch.Monday__c == conflictSearch.monday)) || (sch.Tuesday__c && (sch.Tuesday__c == conflictSearch.tuesday)) 
                ||(sch.Wednesday__c && (sch.Wednesday__c == conflictSearch.wednesday)) || (sch.Thursday__c && (sch.Thursday__c == conflictSearch.thursday )) 
                || (sch.Friday__c && (sch.Friday__c == conflictSearch.friday ))|| (sch.Saturday__c && (sch.Saturday__c == conflictSearch.saturday )) 
                || (sch.Sunday__c && (sch.Sunday__c == conflictSearch.sunday))) {
                
                if(EndTime >= currStartTime && StartTime <= currEndTime) {
                    if(!instructorMap.containsKey(sch.Instructor__c)) {
                        System.debug('::::::Conflict occured:::::');
                        instructorMap.put(sch.Instructor__c, 0);
                    }
                    instructorMap.put(sch.Instructor__c, instructorMap.get(sch.Instructor__c) + 1);
                }
            }
        
        }
        
        
        return instructorMap;
    }
    
    public static Boolean hasDay(Date checkDate, ConflictSearchParameter conflictSearch) {
       
        String day = ((DateTime) checkDate).format('E');
         system.debug(':::day'+day);
        if(!conflictSearch.sunday && !conflictSearch.monday && !conflictSearch.tuesday && !conflictSearch.wednesday && !conflictSearch.thursday && !conflictSearch.friday && !conflictSearch.saturday)
            return true;        
        if(day == 'Sun'){
            if(conflictSearch.sunday)
                return true;
        } else if(day == 'Mon'){
            if(conflictSearch.monday)
                return true;
        } else if(day == 'Tue'){
            if(conflictSearch.tuesday)
                return true;
        }else if(day == 'Wed'){
            if(conflictSearch.wednesday)
                return true;
        }else if(day == 'Thu'){
            if(conflictSearch.thursday)
                return true;
        }else if(day == 'Fri'){
            if(conflictSearch.friday)
                return true;
        }else if(day == 'Sat'){
            if(conflictSearch.saturday)
                return true;
        }
        
        return false;       
    }
    
    @RemoteAction
    public static List<String> getDlSRatePicklistValues() {
        List<String> dlsRate = new List<String>();
        List<Schema.PicklistEntry> dlsRatePicklist = Contact.DLS_Candidate_Rating__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : dlsRatePicklist) {
            dlsRate.add(entry.getValue());
        }
        return dlsRate;
    }
    
    @RemoteAction
    public static List<String> getCertifiedSkillsValues() {
        List<String> certifiedSkills = new List<String>();
        List<Schema.PicklistEntry> certifiedSkillsPickList = Skill__c.Skill_Verification__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : certifiedSkillsPickList) {
            certifiedSkills.add(entry.getValue());
        }
        return certifiedSkills;
    }
    
    @RemoteAction
    public static List<String> getTimePicklist() {
        List<String> timeList = new List<String>();
        List<Schema.PicklistEntry> timePickList = Events__c.Start_Time__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : timePickList) {
            timeList.add(entry.getValue());
        }
        return timeList;
    }
    
    @RemoteAction
    public static List<String> getDegreeLevel() {
        List<String> experience = new List<String>();
        List<Schema.PicklistEntry> experiencePickList = Experience__c.Degree_Level__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : experiencePickList) {
            experience.add(entry.getValue());
        }
        return experience;
    }
    
    public static Map<Id, Double> getProximites(List<Contact> contactList, String zip, Id locationId) {
        Map<Id, Double> proximityMap = new Map<Id, Double>();
        if((zip != null && zip != '') || locationId != null) {
            System.location loc;
            try {
                if(zip != null && zip != '')
                    loc = getLocation(zip);
                else
                    loc = getLatLangFromLocationObj(locationId);
                    
                for(Contact con : contactList) {
                    if(con.Location_GeoCode__Latitude__s != null && con.Location_GeoCode__Longitude__s != null) {
                        proximityMap.put(con.Id, loc.getDistance(System.Location.newInstance(con.Location_GeoCode__Latitude__s, con.Location_GeoCode__Longitude__s), 'mi'));
                    }
                }
            } catch(NullLocationException e) {
                
            }
        }
        return proximityMap;
    }
    
    public static System.Location getLocation(String zip) {
        System.Location loc;
        TimezoneUtilClass ts = new TimezoneUtilClass();
        TimezoneUtilClass.location location = ts.geoCode('', '', '', 'US', zip);
        if(location.lat == null || location.lng == null) {
            location.lat = location.lng = '0';
            throw new NullLocationException('NULL');
        }
        loc = System.Location.newInstance(Double.valueOf(location.lat), Double.valueOf(location.lng));
        return loc;
    }
    
    // For Latt & Lang retrive from Location obj
    
    public static System.Location getLatLangFromLocationObj(Id locationId) {
        System.Location loc;
        List<MTT_Location__c> locationRec = [SELECT Id,Location_GeoCode__Latitude__s,Location_GeoCode__Longitude__s FROM MTT_Location__c WHERE Id = :locationId];
        if(locationRec != null && locationRec.size() > 0)
            loc = System.Location.newInstance(Double.valueOf(locationRec[0].Location_GeoCode__Latitude__s), Double.valueOf(locationRec[0].Location_GeoCode__Longitude__s));
        
        return loc;
    }
    
    // Added by Sukanya on Feb 10 2017
    // get Parent values 
    @RemoteAction
    public static String getParentInformation(String parentType,Id parentId) {
        String LanguageName;
        
        if(parentType == 'OPPORTUNITY') {
            List<Opportunity> oppList = [SELECT Id,Name,Language_LU__r.Name FROM Opportunity WHERE Id = :parentId];
            //List<Opportunity> oppList = SObjectQueryService.SObjectQuery('Opportunity',new Set<Id>{parentId},'');
            LanguageName = oppList[0].Language_LU__c;
        }else if(parentType == 'PROJECT') {
            List<AcctSeed__Project__c> proList = [SELECT Id,Name,Language__r.Name FROM AcctSeed__Project__c WHERE Id = :parentId];
            LanguageName = proList[0].Language__c;
        }
        return LanguageName;
    }
    
    // Get Qualification Bundle Record Type values
    
    @RemoteAction
    public static List<String> getQualificationBundleRecordType() {
        List<String> recordTypes = new List<String>();
        List<Schema.PicklistEntry> recordTypePickList = Qualification_Bundle__c.Record_Type__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : recordTypePickList) {
            recordTypes.add(entry.getValue());
        }
        return recordTypes;
    }
    
    // Get Qualification Bundle Class Type values
    
    @RemoteAction
    public static List<String> getQualificationBundleClassType() {
        List<String> ClassTypes = new List<String>();
        List<Schema.PicklistEntry> classTypePickList = Qualification_Bundle__c.Class_Type__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : classTypePickList) {
            ClassTypes.add(entry.getValue());
        }
        return ClassTypes;
    }
    
    // Get Lookup record values for Sobject
    @RemoteAction
    public static List<sObject> getLookupRecords(String objectName, String searchString, String condition) {
        return LibraryContentSearch.getLookupRecords(objectName,searchString,condition);
        //return SObjectQueryService.getLookupRecords(objectName,searchString,condition);
    }
    
    // Get Location record with Id
    @RemoteAction
    public static List<MTT_Location__c> getLocationRecord(String locationId) {
        return [SELECT Id,Name FROM MTT_Location__c WHERE Id = :locationId];
    }
    
    // Get citizen values for filter
    @RemoteAction
    public static List<String> getCitizenshipvalues() {
        List<String> citizenship = new List<String>();
        List<Schema.PicklistEntry> citizenshipValues = Contact.Citizenship__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : citizenshipValues) {
            citizenship.add(entry.getValue());
        }
        return citizenship;
    }
    
    // Country of Birth values for filter
    @RemoteAction
    public static List<String> getCountryofBirthvalues() {
        List<String> countryOfbirth = new List<String>();
        List<Schema.PicklistEntry> cobValues = Contact.Country_of_Birth__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : cobValues) {
            countryOfbirth.add(entry.getValue());
        }
        return countryOfbirth;
    }
    
    // Create new Qualifications,Qualification Bundle and Bundle Line Items from Page
    @RemoteAction
    public static void createNewQualificationRecord(String QulificationBundleJson,String QualificationsJson) {
        List<Qualification__c> qualificationList = (List<Qualification__c>) System.JSON.deserialize(QualificationsJson, List<Qualification__c>.class);
        List<Qualification_Bundle__c> qualificationBundleList = (List<Qualification_Bundle__c>) System.JSON.deserialize(QulificationBundleJson, List<Qualification_Bundle__c>.class);
        
        system.debug('::::::::qualificationList:::::::'+qualificationList);
        system.debug('::::::::qualificationBundleList:::::::'+qualificationBundleList);
        
        Set<String> typeSet = new Set<String>();
        Set<String> conditionSet = new Set<String>();
        Set<String> ValueSet = new Set<String>();
        Set<Id> existingQualificationIds = new Set<Id>();
        
        Map<String,Id> typeConditionValue_QualIdMap = new Map<String,Id>();
        
        List<Qualification__c> qualificationCreationList = new List<Qualification__c>();
        List<Qualification_Bundle_item__c> bundleLineItemList = new List<Qualification_Bundle_item__c>();
        
        // Add user value if Available for all is true
        
        if(!qualificationBundleList[0].Available_for_All__c)
            qualificationBundleList[0].User__c = UserInfo.getUserId();
            
        
        for(Qualification__c qual : qualificationList) {
            typeSet.add(qual.Condition__c);
            conditionSet.add(qual.Type__c);
            ValueSet.add(qual.Value__c);
        }
        system.debug(':::::::typeSet:::::'+typeSet);
        system.debug(':::::::conditionSet:::::'+conditionSet);
        system.debug(':::::::ValueSet:::::'+ValueSet);
        
        /*for(Qualification__c qualification : [SELECT Id,Name,Type__c,Condition__c,Value__c FROM Qualification__c]) {
            if(!typeConditionValue_QualIdMap.containsKey(qualification.Type__c+'-'+qualification.Condition__c+'-'+qualification.Value__c)) {
                typeConditionValue_QualIdMap.put(qualification.Type__c+'-'+qualification.Condition__c+'-'+qualification.Value__c,qualification.Id);
            }
        }*/
        
        for(Qualification__c qualification : QualificationService.getQualificationrecords('','')) {
            if(!typeConditionValue_QualIdMap.containsKey(qualification.Type__c+'-'+qualification.Condition__c+'-'+qualification.Value__c)) {
                typeConditionValue_QualIdMap.put(qualification.Type__c+'-'+qualification.Condition__c+'-'+qualification.Value__c,qualification.Id);
            }
        }
        
        system.debug(':::::::typeConditionValue_QualIdMap:::::'+typeConditionValue_QualIdMap);
        
        for(Qualification__c qual : qualificationList) {
            
            if(!typeConditionValue_QualIdMap.containsKey(qual.Type__c+'-'+qual.Condition__c+'-'+qual.Value__c)) {
                qualificationCreationList.add(qual);
            }else {
                existingQualificationIds.add(typeConditionValue_QualIdMap.get(qual.Type__c+'-'+qual.Condition__c+'-'+qual.Value__c));
            }
        }
        
        system.debug(':::::qualificationCreationList::::::'+qualificationCreationList);
        system.debug(':::added:::existing::::Ids:::existingQualificationIds::::::'+existingQualificationIds);
        
        if(qualificationBundleList.size() > 0) {
            //insert qualificationBundleList;
            qualificationBundleList = QualificationBundleService.qualificationBundleCreation(qualificationBundleList);
        }
        
        if(qualificationCreationList.size() > 0) {
            //insert qualificationCreationList;
            qualificationCreationList = QualificationService.qualificationCreation(qualificationCreationList);
            
            for(Qualification__c qualification : qualificationCreationList) {
                existingQualificationIds.add(qualification.Id);
            }
        }
        
        system.debug('::::::Added::new quali:ids:'+existingQualificationIds);
        
        for(Id ids : existingQualificationIds) {
        
            Qualification_Bundle_item__c bundleItem = new Qualification_Bundle_item__c();
            bundleItem.Qualification__c = ids;
            bundleItem.Bundle__c = qualificationBundleList[0].Id;
            bundleItem.Prefered_Required__c = 'Required';
            
            bundleLineItemList.add(bundleItem);
        }
        
        system.debug('::::::bundleLineItemList:'+bundleLineItemList);
        if(bundleLineItemList.size() > 0) {
            //insert bundleLineItemList;
            bundleLineItemList = QualificationBundleItemService.qualificationBundleItemsCreation(bundleLineItemList);
        }
        
    }
    
    public class NullLocationException extends Exception {}
    
    public class SearchResult {
        public List<Contact> instructors;
        public Map<Id, Integer> conflictCount;
        public Map<Id, Double> proximities;
        public Map<Id, Decimal> instructorScore;
        public Integer recordCount;
    }
    
    public class ConflictSearchParameter {
        public String startDate;
        public String endDate;
        public String startTime;
        public String endTime;
        public Boolean monday = false;
        public Boolean tuesday = false;
        public Boolean wednesday = false;
        public Boolean thursday = false;
        public Boolean friday = false;
        public Boolean saturday = false;
        public Boolean sunday = false;
    }   
}