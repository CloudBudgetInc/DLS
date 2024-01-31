/*****************************************************************************************
- Library Search Lightning component usage
- Created by NS on June 24 2019
*******************************************************************************************/
public without sharing class LibrarySearchController {
    
    @AuraEnabled
    public static String getCurrentUserType(){
        
        String userType = '';
        
        List<User> userList = SObjectQueryService.SObjectQuery('User',new Set<Id>{UserInfo.getUserId()},',Profile.Name');
        if(userList[0].UserType == 'Standard') {
            userType = 'Internal';
        }else if(userList[0].UserType != 'Standard' && userList[0].Profile.Name == 'Instructor Community'){
            userType = 'Instructor';
        }else if(userList[0].UserType != 'Standard' && userList[0].Profile.Name == 'Student Community'){
            userType = 'Student';
        }else if(userList[0].UserType != 'Standard' && userList[0].Profile.Name == 'Staff Community'){
            userType = 'Staff';
        }
        
        system.debug(':::::::::userType:::::'+userType);
        return userType;
    }
    
    //Method to get the language,format filter values for initial load
    @AuraEnabled 
    public static String getFilterValues(){
        
        //Used the existing wrapper class
        UtilDomain.SearchResultInfo filterInfo = new UtilDomain.SearchResultInfo();
        
        List<UtilDomain.FilterDetails> langFilter = new List<UtilDomain.FilterDetails>();
        List<UtilDomain.FilterDetails> formatFilter = new List<UtilDomain.FilterDetails>();
        List<UtilDomain.FilterDetails> seriesFilter = new List<UtilDomain.FilterDetails>();
        
        UtilDomain.FilterDetails filter;
        
        for(Language__c lang : LanguageService.getLanguages(' ORDER BY Name ASC')){
            
            filter = new UtilDomain.FilterDetails();
            filter.label = lang.Name;
            filter.value = lang.Id;
            
            langFilter.add(filter);
        }
        
        Set<String> fileTypes = new Set<String>();
        
        for(ContentVersion content : ContentVersionService.getContentVersionbyFilters(' ORDER BY FileType ASC NULLS LAST')){
            
            if(String.isNotBlank(content.FileType) && !fileTypes.contains(content.FileType)){
                fileTypes.add(content.FileType);
            }else if(!fileTypes.contains(content.FileType) && content.FileType == null){
                fileTypes.add('Other');
            }
        }
        
        for(String format : fileTypes){
            filter = new UtilDomain.FilterDetails();
            filter.label = format;
            filter.value = format;
            
            formatFilter.add(filter);
        }
        
        
        for(AggregateResult agg : [SELECT count(Id),Book_Series__c FROM Materials__c WHERE OwnerId != null GROUP BY Book_Series__c]){
        
            filter = new UtilDomain.FilterDetails();
            
            String fieldValue = (String) agg.get('Book_Series__c');
            
            if(fieldValue == NULL){
                filter.label = 'Other';
                filter.value = 'Other';
            }else {
                filter.label = fieldValue;
                filter.value = fieldValue;   
            }         
            
            seriesFilter.add(filter);
        }                
        
        filterInfo.formatValues = formatFilter;
        filterInfo.languageValues = langFilter;
        filterInfo.seriesValues = seriesFilter;
        
        
        return JSON.serialize(filterInfo);
    }
    
    //Method to get home page Material Request table filter information
    @AuraEnabled
    public static String getMRFilterDetails(){
        
        List<UtilDomain.FilterDetails> recordTypeValues = new List<UtilDomain.FilterDetails>();
        List<UtilDomain.FilterDetails> locationValues = new List<UtilDomain.FilterDetails>();
        Map<Id,String> rtIdDeveloperName = new Map<Id,String>();
        
        List<RecordType> materialReqRTList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName('','Materials_Request__c',new Set<String>{});
        
        for(RecordType rt : SObjectQueryService.getRecTypeListBySobjTypeAndDevName('','Materials_Request__c',new Set<String>{})){
            
            UtilDomain.FilterDetails filter = new UtilDomain.FilterDetails();
            filter.label = rt.Name;
            filter.value = rt.Id;
            
            recordTypeValues.add(filter);
            
            if(!rtIdDeveloperName.containsKey(rt.Id)){
                rtIdDeveloperName.put(rt.Id,rt.DeveloperName);
            } 
        }
        
        for(MTT_Location__c loc : [SELECT Id,Name FROM MTT_Location__c WHERE Name LIKE '%DLS - %' AND Name != 'DLS - Online' ORDER BY Name ASC]){
            if(loc.Name == 'DLS - Arlington'){
                loc.Name = 'DLS - Rosslyn';
            }
            
            UtilDomain.FilterDetails filter = new UtilDomain.FilterDetails();
            filter.label = loc.Name;
            filter.value = loc.Id;
            
            locationValues.add(filter);
        }
        
        UtilDomain.MRFilterDetails mrFilter = new UtilDomain.MRFilterDetails();
        mrFilter.locationValues = locationValues;
        mrFilter.recordTypeValues = recordTypeValues;
        mrFilter.rtIdDeveloperNameMap = rtIdDeveloperName;
        
        return JSON.serialize(mrFilter);
    }
    
    //Get status values based on material request record type selection
    @AuraEnabled
    public static string getRecordTypeBased_PicklistValues(String objectName,String fieldName, String recordTypeId){
        
        try {
            
            List<String> pickListValues = new List<String>();
            
            Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(CongaButtonsController.getServerUrlSessionId());
            
            String sessionId = (String) resultMap.get('sessionId');
        
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String host = System.Url.getSalesforceBaseURL().toExternalForm();
            String url = host+'/services/data/v42.0/ui-api/object-info/'+objectName+'/picklist-values/'+recordTypeId+'/'+fieldName;        
            request.setEndpoint(url);
            request.setMethod('GET');  
            request.setHeader('Authorization', 'OAuth '+sessionId);
            HttpResponse response;        
            response = http.send(request); 
            Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
          
            if(meta.containsKey('values')) {
                
                for(Object o: (List<Object>)meta.get('values')) {
                    Set<String> tempDepIndex = new Set<String> ();
                    Map<String,Object> temp = (Map<String,Object>) o;
                    String val = (String) temp.get('value');
                    pickListValues.add(val);
                }
            }
            system.debug(':::::::::pickListValues::::'+pickListValues);
            
            List<UtilDomain.FilterDetails> statusFilters = new List<UtilDomain.FilterDetails>();
            
            for(String status : pickListValues){
                UtilDomain.FilterDetails filter = new UtilDomain.FilterDetails();
                filter.label = status;
                filter.value = status;
                
                statusFilters.add(filter);
            }
            
            return JSON.serialize(statusFilters);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    }  
    
    //For Home Page Material Request Record query
    @AuraEnabled
    public static String materialRequestBasedonFilter(String recordTypeName,String status,String supervisorId,String relatedContactId,String relatedLocationId){
        
        try {
            system.debug(':::::::recordTypeName:::::'+recordTypeName);
            
            List<Materials_Request__c> materialRequestList = new List<Materials_Request__c>();
            
            Set<Id> projectIds = new Set<Id>();
            Set<Id> dlsLibraryProjects = new Set<Id>();
            
            String dlsLibraryProjIds = label.DLS_Library_Projects;
            if (String.isNotEmpty(dlsLibraryProjIds)) {
                if (dlsLibraryProjIds.contains(',')) {
                    for(String str : dlsLibraryProjIds.split(',')) {
                        if (!dlsLibraryProjects.contains(Id.valueOf(str.trim()))){
                            dlsLibraryProjects.add(Id.valueOf(str.trim()));
                        }
                    }
                } 
            }  
            
            if(String.isNotEmpty(supervisorId) && recordTypeName != 'New Library Purchase'){
                for(Contact_Assignments__c conAss : ContactAssignmentService.getContactAssignmentByContIds(new Set<Id>{supervisorId},new Set<String>{'Staff'},' AND Status__c = \'Active\' AND Assignment_Position__c = \'LTS\' ',',Candidate_Name__r.Name')){
                    
                    // exclude these DLS library project related request records if the record type is project materials request
                    if(recordTypeName == 'Project_Materials_Request' && !dlsLibraryProjects.contains(conAss.Project__c)) {
                        projectIds.add(conAss.Project__c);
                    } else if(recordTypeName != 'Project_Materials_Request') {
                        projectIds.add(conAss.Project__c);
                    }
                }
            }
            
            String filter = '';
            String parentConditionField = '';
            
            // Record Type Condition
            if(recordTypeName == 'All') {
                
                filter = ' WHERE ((RecordType.DeveloperName IN (\'Material_Loan_Request\',\'Project_Materials_Request\') AND (Project__c != null AND ((Project__r.AcctSeed__Status__c = \'Ended\' AND (Project__r.End_Date__c = LAST_N_MONTHS:3 OR (Project__r.End_Date__c = THIS_MONTH AND Project__r.End_Date__c <= TODAY))) OR (Project__r.AcctSeed__Status__c IN (\'Order\',\'Active\',\'On Hold\'))))) OR (RecordType.DeveloperName NOT IN (\'Material_Loan_Request\',\'Project_Materials_Request\') AND CreatedDate = LAST_N_MONTHS:3))';
            
            }else if(recordTypeName == 'Material_Loan_Request' || recordTypeName == 'Project_Materials_Request'){
                
                if(recordTypeName == 'Material_Loan_Request'){
                    filter = ' WHERE (RecordType.DeveloperName = \''+recordTypeName+'\' AND (Project__c != null AND Project__r.AcctSeed__Status__c IN (\'Order\',\'Active\',\'On Hold\',\'Ended\')))';
                }else {
                    filter = ' WHERE (RecordType.DeveloperName = \''+recordTypeName+'\' AND (Project__c != null AND ((Project__r.AcctSeed__Status__c = \'Ended\' AND (Project__r.End_Date__c = LAST_N_MONTHS:3 OR (Project__r.End_Date__c = THIS_MONTH AND Project__r.End_Date__c <= TODAY))) OR (Project__r.AcctSeed__Status__c IN (\'Order\',\'Active\',\'On Hold\')))))';
                }
            }else if(recordTypeName != 'Material_Loan_Request' && recordTypeName != 'Project_Materials_Request' && recordTypeName != 'New Library Purchase'){
                
                filter = ' WHERE RecordType.DeveloperName = \''+recordTypeName+'\' AND CreatedDate = LAST_N_MONTHS:3';
            
            }else if(recordTypeName == 'New Library Purchase'){
                
                // To display 3 dummay library project related material records
                filter = ' WHERE RecordType.DeveloperName = \'Project_Materials_Request\' AND CreatedDate = LAST_N_MONTHS:6';
            }
            
            // Status condition
            if(String.isNotEmpty(status) && status != 'All'){
                filter += ' AND Request_Status__c = \''+status+'\'';
            }
            
            //Contact filter condition
            if(String.isNotEmpty(relatedContactId)){
                filter += ' AND Contact__c = \''+ relatedContactId +'\'';
            }
            
            //location condition
            if(String.isNotEmpty(relatedLocationId) && relatedLocationId != 'All'){
                filter += ' AND (Location__c = \''+ relatedLocationId +'\' OR Target_Location__c = \''+ relatedLocationId + '\')';
            }
            
            Boolean includeParentCondition;
            
            //Supervsior Condition
            if((String.isNotEmpty(supervisorId) || recordTypeName == 'New Library Purchase') && projectIds.size() > 0){
                parentConditionField = 'Project__c';
                includeParentCondition = true;
            }else if(!String.isNotEmpty(supervisorId) && recordTypeName == 'Project_Materials_Request') {
                projectIds.addAll(dlsLibraryProjects);
                parentConditionField = 'Project__c';
                includeParentCondition = false;
            }
          
            String limitQry = '';
            
            if(recordTypeName == 'Project_Materials_Request'){
                limitQry = ' ORDER BY CreatedDate DESC LIMIT 1000';
            }else {
                limitQry = ' ORDER BY CreatedDate DESC LIMIT 1500';
            }
               
            materialRequestList = MaterialRequestService.getMRrecordsByParentIds(filter,' Materials_Name__r.Name,Project_Task__r.AcctSeed__Project__c,Project_Task__r.AcctSeed__Project__r.DLS_Class__c,Project__r.DLS_Class__c,Project__r.Name,Contact__r.Name,Class_Name__r.Name,Location__r.Name,Target_Location__r.Name,RecordType.DeveloperName',parentConditionField,includeParentCondition,projectIds,limitQry);
            
            system.debug(':::::::::::materialRequestList::::::'+materialRequestList.size());
            
            return JSON.serialize(materialRequestList);
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    //Method to update Loan Material Request record status
    @AuraEnabled
    public static String updateLoanMRRecords(String loanJson){
    
        List<Materials_Request__c> loanList = (List<Materials_Request__c>) System.JSON.deserialize(loanJson, List<Materials_Request__c>.class);
        
        if(loanList.size() > 0){
            loanList[0].Date_Returned__c = system.today();
        }
        
        return updateForallObjects(JSON.serialize(loanList),'Materials_Request__c');
    }
    
    @AuraEnabled
    public static String updateForallObjects(String updateJson,String objectName){
    
        try {
            
            if(objectName == 'Favourite_Material__c') {
                List<Favourite_Material__c> updationList = (List<Favourite_Material__c>) System.JSON.deserialize(updateJson, List<Favourite_Material__c>.class);
                
                if(updationList.size() > 0) {
                    update updationList;
                }
            
            }else if(objectName == 'Material_Rating__c') {
                List<Material_Rating__c> updationList = (List<Material_Rating__c>) System.JSON.deserialize(updateJson, List<Material_Rating__c>.class);
                
                if(updationList.size() > 0) {
                    update updationList;
                }
            }else if(objectName == 'Request__c') {
                List<Request__c> updationList = (List<Request__c>) System.JSON.deserialize(updateJson, List<Request__c>.class);
                
                if(updationList.size() > 0) {
                    update updationList;
                }
            }else if(objectName == 'ContentVersion') {
                List<ContentVersion> updationList = (List<ContentVersion>) System.JSON.deserialize(updateJson, List<ContentVersion>.class);
                
                if(updationList.size() > 0) {
                    update updationList;
                }
            }else if(objectName == 'Materials__c') {
                List<Materials__c> updationList = (List<Materials__c>) System.JSON.deserialize(updateJson, List<Materials__c>.class);
                
                if(updationList.size() > 0) {
                    update updationList;
                }
            } else if(objectName == 'Materials_Request__c') {
                List<Materials_Request__c> updationList = (List<Materials_Request__c>) System.JSON.deserialize(updateJson, List<Materials_Request__c>.class);
                
                if(updationList.size() > 0) {
                    update updationList;
                }
            }
            
            return 'Success';
        
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Method to delete records from different objects
    @AuraEnabled
    public static String deleteForallObjects(String deleteJson,String objectName){
        
        try{
            if(objectName == 'Favourite_Material__c') {
               List<Favourite_Material__c> deleteList = (List<Favourite_Material__c>) System.JSON.deserialize(deleteJson, List<Favourite_Material__c>.class);
               
               if(deleteList.size() > 0) {
                  delete deleteList; 
               }
           }else if(objectName == 'Material_Rating__c') {
               List<Material_Rating__c> deleteList = (List<Material_Rating__c>) System.JSON.deserialize(deleteJson, List<Material_Rating__c>.class);
               
               if(deleteList.size() > 0) {
                  delete deleteList;
               }
           }else if(objectName == 'Materials_Request__c') {
               List<Materials_Request__c> deleteList = (List<Materials_Request__c>) System.JSON.deserialize(deleteJson, List<Materials_Request__c>.class);
               
               if(deleteList.size() > 0) {
                   delete deleteList; 
               }
           }
           
           return 'SUCCCESS';
        
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    //Method to get the Coomunity Home Page related records
    @AuraEnabled
    public static String getCommunityHomePageDetails(){
        
        system.debug(':::::::::community::home:::::page::');
        
        UtilDomain.ContentandMaterialRecordsInfo info = new UtilDomain.ContentandMaterialRecordsInfo();
        
         // Query logged in User details 
        List<User> usrRec = SObjectQueryService.SObjectQuery('User',new Set<Id>{UserInfo.getUserId()},',Profile.Name');
        Id contactId = usrRec[0].ContactId;
        String userType;
        
        if(usrRec[0].Profile.Name == 'Instructor Community'){
            userType = 'Instructor';
        }else if(usrRec[0].Profile.Name == 'Student Community'){
            userType = 'Student';
        }
        
        Set<Id> contentRecIds = new Set<Id>();
        Set<Id> materialRecIds = new Set<Id>();
        List<ContentVersion> favouriteContents = new List<ContentVersion>();
        List<Materials__c> favouriteMaterials = new List<Materials__c>();
        
        List<ContentVersion> topRateContents = new List<ContentVersion>();
        List<Materials__c> topRateMaterials = new List<Materials__c>();
        
        List<Materials_Request__c> orderRequests = new List<Materials_Request__c>();
        List<Materials_Request__c> loanRequests = new List<Materials_Request__c>();
        
        List<ContentVersion> mostReqContents = new List<ContentVersion>();
        List<Materials__c> mostReqMaterials = new List<Materials__c>();
        
        
        //Commented all contentversion related quries because we are not going to use this
        //By NS on July 26 2019
        
        //Query Favourite Materials related records
        if(userType == 'Instructor' || userType == 'Student'){
            List<Favourite_Material__c> favmaterialList = FavouriteMaterialService.getFavouritematerial(' WHERE Contact__c = \'' +contactId+'\'');
            
            for(Favourite_Material__c favMaterial : favmaterialList){
               /*if(favMaterial.ContentVersion_Id__c != null) {
                   contentRecIds.add(favMaterial.ContentVersion_Id__c);
               }*/
               if(favMaterial.Material_Name__c != null){
                   materialRecIds.add(favMaterial.Material_Name__c);
               }
             }
            
            //String contentQry = 'SELECT Id,Title,ContentDocument.ParentId,ContentDocument.Title FROM ContentVersion WHERE ContentDocumentId != null AND IsLatest = true AND PublishStatus =\'p\' AND Id IN :contentRecIds ORDER BY Total_Favourite_Count__c DESC NULLS LAST LIMIT 2';
            //favouriteContents = database.query(contentQry);
            
            
            String materialQry = 'SELECT Id,Name,Book_Cover__c,Language_LU__r.Name FROM Materials__c WHERE Id IN :materialRecIds ORDER BY Total_Favourite_Count__c DESC NULLS LAST LIMIT 3';
            favouriteMaterials = database.query(materialQry);
        }
        
        // Qry Top rated books related details
        
        if(userType == 'Instructor' || userType == 'Student'){
            //contentRecIds = new Set<Id>();
            materialRecIds = new Set<Id>();
            List<Material_Rating__c> matRatList = new List<Material_Rating__c>(); 
            if(contactId !=  Null){
                matRatList = MaterialRatingService.getMaterialrating(' WHERE Ratings__c > 3 AND Contact__c = \''+contactId+'\'','Material_Name__r.Average_Rating__c');
            }
            for(Material_Rating__c rating : matRatList) {
                /*if(rating.ContentVersionId__c != null) {
                    contentRecIds.add(rating.ContentVersionId__c);
                }*/
                if(rating.Material_Name__c != null) {
                    materialRecIds.add(rating.Material_Name__c);
                }
            }
            
            // get Top rated books related Content & Material records
            
            //topRateContents = ContentVersionService.getContentVersionbyIds(contentRecIds,'Average_Rating__c',2);
            topRateMaterials = MaterialsService.getMaterialsbyIds(materialRecIds,'Average_Rating__c',2);
        }
        
        //Qry My Material Request records
        if(userType == 'Instructor' || userType == 'Student'){
            
            if(userType == 'Instructor'){
                orderRequests = MaterialRequestService.getMaterial(' WHERE Contact__c = \''+contactId+ '\' AND RecordType.DeveloperName IN (\'Project_Materials_Request\') ORDER BY CreatedDate DESC',' Project__r.DLS_Class__c,Project__r.End_Date__c,Project_Task__r.AcctSeed__Project__r.DLS_Class__c,Location__r.Name,Contact__r.Name,RecordType.DeveloperName,Materials_Name__r.Name');
            }else {
                Set<Id> projectIds = new Set<Id>();
                for(Contact_Assignments__c ca : [SELECT Id,Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId AND Status__c IN ('Active','Planned')]){
                    projectIds.add(ca.Project__c);
                }
                
                String materialRequestQry = 'SELECT '+MaterialRequestService.fldStr+',Project__r.DLS_Class__c,Project__r.End_Date__c,Project_Task__r.AcctSeed__Project__r.DLS_Class__c,Location__r.Name,Contact__r.Name,RecordType.DeveloperName,Materials_Name__r.Name FROM Materials_Request__c WHERE Project__c IN :projectIds AND RecordType.DeveloperName = \'Project_Materials_Request\' AND (Contact__c = \''+contactId+'\' OR Contact__c = null)';
                
                orderRequests = database.query(materialRequestQry);
            }      
            
            //orderRequests = MaterialRequestService.getMaterial(' WHERE Contact__c = \''+contactId+ '\' AND RecordType.DeveloperName IN (\'Project_Materials_Request\') ORDER BY CreatedDate DESC',' Project__r.DLS_Class__c,Project__r.End_Date__c,Project_Task__r.AcctSeed__Project__r.DLS_Class__c,Location__r.Name,Contact__r.Name,RecordType.DeveloperName,Materials_Name__r.Name');
            loanRequests = MaterialRequestService.getMaterial(' WHERE Contact__c = \''+contactId+ '\' AND RecordType.DeveloperName IN (\'Material_Loan_Request\') ORDER BY CreatedDate DESC',' Project__r.DLS_Class__c,Project__r.End_Date__c,Project_Task__r.AcctSeed__Project__r.DLS_Class__c,Location__r.Name,Contact__r.Name,RecordType.DeveloperName,Materials_Name__r.Name');
        }
        
        //Qry Most Requested records
        if(userType == 'Instructor' || userType == 'Student'){
        
            //Qry Record type details for Request object
            Set<String> devname = new Set<String>{'Material'};        
            List<RecordType> recordTypeList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName(' WHERE SobjectType = \'Request__c\' AND DeveloperName ','',devname);
            
            //contentRecIds = new Set<Id>();
            materialRecIds = new Set<Id>();
            
            //Qry request object & get content version id to display content version based on No.of download field
            List<Request__c> requestList = RequestService.getRequest(' WHERE RecordTypeId = \''+recordTypeList[0].Id+'\' AND Contact__c = \''+contactId+'\'','');
            
            /*for(Request__c reques : requestList) {
                
                if(reques.ContentVersionId__c != null) {
                    contentRecIds.add(reques.ContentVersionId__c);
                }
            }*/
            
            //Query Material Request records for Most Requested Materials display
            for(Materials_Request__c mr : [SELECT Id,Materials_Name__c FROM Materials_Request__c 
                                                WHERE Contact__c = :contactId AND RecordType.DeveloperName IN ('Material_Loan_Request','Project_Materials_Request') 
                                                    AND Request_Status__c NOT IN ('Returned' , 'Canceled')]){
                materialRecIds.add(mr.Materials_Name__c);
            }
            
            // Get the Most request book related infor for Content & Materials
            //mostReqContents = database.query('SELECT Id,Title,ContentDocument.ParentId,ContentDocument.Title FROM ContentVersion WHERE ContentDocumentId != null AND IsLatest = true AND PublishStatus = \'p\' AND Id IN :contentRecIds ORDER BY Number_of_Downloads__c DESC NULLS LAST LIMIT 2');
            mostReqMaterials = database.query('SELECT Id,Name,Book_Cover__c,Language_LU__r.Name FROM Materials__c WHERE Id IN :materialRecIds ORDER BY Number_of_Requests__c DESC NULLS LAST LIMIT 3');
            MaterialsService.getMaterialsbyIds(materialRecIds);
        }
        
        info.FavouriteContents = favouriteContents;
        info.FavouriteMaterials = favouriteMaterials;
        info.TopRateContents = topRateContents;
        info.TopRateMaterials = topRateMaterials;
        info.orderRequests = orderRequests;
        info.loanRequests = loanRequests;
        info.MostReqContents = mostReqContents;
        info.MostReqMaterials = mostReqMaterials;
        
        system.debug(':::::::info:::::'+info);
        
        return JSON.serialize(info);
    } 
    
    //SOSL Content Version query with search input  
    @AuraEnabled
    public static String getDigitalContentsByText(String SearchString,String language,String filetype,String bookseries,String dlsSection,String sortingOption,Integer pageNumber,Integer pageSize){
        
        try {
            System.debug('searchtype'+SearchString );
            String searchInput = '';
            Integer offset = null;

            if(pageNumber != null && pageSize != null){
                offset = ((Integer)pageNumber - 1) * pageSize;
            }
            
            list<ContentVersion> contentList = new list<ContentVersion>();
            UtilDomain.SearchResultInfo searchResult = new UtilDomain.SearchResultInfo();
            
             if(SearchString != null && SearchString != '' && SearchString.trim().length() > 0) {
            
                System.debug('searchtypeif');
                String specialChars = '(|)|-|';
                List<String> splittedBySpaceStringList = new List<String>();

                for( String str : parseCSVString(SearchString)) {
                    for(integer i=0; i<specialChars.split('|').size(); i++) 
                        str = str.replace(specialChars.split('|')[i], '');
                    
                    if(str.trim().length() > 0) {
                        searchInput += str.trim()+' OR ';
                        if(str.contains(' ')) {
                            for(String spacestr : str.split(' ')){
                                if(spacestr.trim().length() > 0) splittedBySpaceStringList.add(spacestr);
                            }
                        }
                    }
                }

                if(searchInput.endsWith(' OR ')) {
                    searchInput = searchInput.subString(0,searchInput.length()-4);
                }
                
                searchInput = String.EscapeSingleQuotes(searchInput);
                   
                if(searchInput.contains('+')||searchInput.contains('&')||searchInput.contains('{')||searchInput.contains('}')||searchInput.contains('^')||searchInput.contains('!')||searchInput.contains('[')||searchInput.contains(']')||searchInput.contains(':')) {
                    system.debug(':::::::::::::::::hello:::::::::::::::');
                    throw new AuraHandledException('Special characters are not allowed');
                }else {
                
                    String soslquerystring = '';
                    soslquerystring += ' WHERE ContentDocumentId != null AND IsLatest = true AND PublishStatus =\'p\'';
                     
                    if(language != 'All') {
                        if(language != 'Other') {
                            soslquerystring += ' AND Language_LU__c = \''+language+'\'';
                        }else {
                            soslquerystring += ' AND Language_LU__c = null';
                        }
                    } 
                    if(filetype != 'All') {
                        if(filetype != 'Other') {
                            soslquerystring += ' AND FileType = \''+filetype+'\'';
                        }else {
                            soslquerystring += ' AND FileType = null';
                        }
                    } 
                    if(bookseries != 'All') {
                        if(bookseries != 'Other') {
                            soslquerystring += ' AND Book_Series__c = \''+bookseries+'\'';
                        }else {
                            soslquerystring += ' AND Book_Series__c = null';
                        }
                    }
                    
                    if(dlsSection != 'All') {
                        if(dlsSection != 'Other') {
                            soslquerystring += ' AND DLS_Section__c = \''+dlsSection+'\'';
                        }else {
                            soslquerystring += ' AND DLS_Section__c = null';
                        }
                    }
                    
                    
                    // KnowledgeArtList = search.query(soslquerystring);
                    //List<List<SObject>> searchList = search.query(soslquerystring);
                    
                    //Added dynamic sorting option from client side to server side to avoid 15MB exceeded error
                    String sortingField = '';
                    String sortingType = '';
                    
                    if(sortingOption == 'Top Rated'){
                        sortingField = 'Average_Rating__c'; 
                        sortingType = 'DESC NULLS LAST';
                    }else if(sortingOption == 'Most Requested') {
                        sortingField = 'Number_of_Downloads__c'; 
                        sortingType = 'DESC NULLS LAST';
                    }else if(sortingOption == 'Newest'){
                        sortingField = 'CreatedDate'; 
                        sortingType = 'DESC';
                    }else if(sortingOption == 'Alphabetical'){
                        sortingField = 'Title'; 
                        sortingType = 'ASC';
                    }else if(sortingOption == 'Most Favorited'){
                        sortingField = 'Total_Favourite_Count__c'; 
                        sortingType = 'DESC NULLS LAST';
                    }
                    
                    String conditionQry = soslquerystring; 
                    
                    
                    if(String.isNotBlank(sortingField) && String.isNotBlank(sortingType)){
                        
                        soslquerystring += ' ORDER BY '+sortingField+' '+sortingType;
                    }
                    
                    /* Get the Material Records Total Count*/
                    List<List<SObject>> searchedCVList = ContentVersionService.getContentVersionbySearchParamter(searchInput,soslquerystring +')');
                    Integer conVersionTotalCnt = 0;
                    if(searchedCVList != NULL && searchedCVList.size() > 0){
                        conVersionTotalCnt = searchedCVList[0].size();
                    }
                    
                    if(offset != null){
                        soslquerystring += ' LIMIT '+pageSize+' OFFSET '+offset;
                    }else {
                        soslquerystring += ' LIMIT 100';
                    }
                    soslquerystring += ')';
                    system.debug('::::::qary:::::'+soslquerystring);
                    
                    List<List<SObject>> searchList = ContentVersionService.getContentVersionbySearchParamter(searchInput,soslquerystring);
                    
                    system.debug(':::::::searchList :::::::'+searchList);
                    
                     if(searchList != NULL && searchList.size() > 0){
                    
                        contentList = searchList[0];
                    }
                    
                    
                    //Get aggregate results for Format, Series, Language & DLS Section filters
                    //Added by NS on May 9 2019
                    Set<Id> contentVersionIds = new Set<Id>();
                    if(contentList.size() > 0){
                        for(ContentVersion con : contentList){
                            contentVersionIds.add(con.Id);
                        }
                    }
                    
                    conditionQry += ' AND Id IN :contentVersionIds';
                
                    //For Format filter
                    String formatQry = 'SELECT count(Id),FileType FROM ContentVersion';
                    
                    if(String.isNotBlank(conditionQry)){
                        formatQry += conditionQry;
                    }
                    
                    formatQry += ' GROUP BY FileType';
                    
                    system.debug(''+formatQry);
                    List<AggregateResult> formatRecords = database.query(formatQry);
                    //system.debug('::::::::formatRecords:::'+formatRecords);
                    
                    //For Langauge Filter
                    String languageQry = 'SELECT count(Id),Language_LU__c FROM ContentVersion';
                    
                    if(String.isNotBlank(conditionQry)){
                        languageQry += conditionQry;
                    }
                    
                    languageQry += ' GROUP BY Language_LU__c';
                    
                    List<AggregateResult> languageRecords = database.query(languageQry);
                    system.debug('::::::::::languageRecords:::'+languageRecords);
                    
                    Set<Id> langIds = new Set<Id>();
                    Map<Id,String> langIdNameMap = new Map<Id,String>();
                    
                    for(AggregateResult agg : languageRecords){
                        langIds.add((Id) agg.get('Language_LU__c'));
                    }
                    
                    for(Language__c lang : [SELECT Id,Name FROM Language__c WHERE Id IN :langIds]){
                        if(!langIdNameMap.containsKey(lang.Id)){
                            langIdNameMap.put(lang.Id,lang.Name);
                        }
                    }
                    
                    //For Series filter
                    String seriesQry = 'SELECT count(Id),Book_Series__c FROM ContentVersion';
                    
                    if(String.isNotBlank(conditionQry)){
                        seriesQry += conditionQry;
                    }
                    
                    seriesQry += ' GROUP BY Book_Series__c';
                    
                    List<AggregateResult> seriesRecords = database.query(seriesQry);
                    system.debug('::::::::::seriesRecords:::'+seriesRecords);
                    
                    //For DLS Section filter
                    String dlsSectionQry = 'SELECT count(Id),DLS_Section__c FROM ContentVersion';
                    
                    if(String.isNotBlank(conditionQry)){
                        dlsSectionQry += conditionQry;
                    }
                    
                    dlsSectionQry += ' GROUP BY DLS_Section__c';
                    
                    List<AggregateResult> dlsSectionRecords = database.query(dlsSectionQry);
                    system.debug('::::::::::dlsSectionRecords:::'+dlsSectionRecords);
                    
                    searchResult = UtilTranslator.searchResultFormation(contentList,new List<Materials__c>{},formatRecords,languageRecords,seriesRecords,dlsSectionRecords,langIdNameMap);
                    searchResult.materialCVRecordsCnt = conVersionTotalCnt;

                }
            }
            
            return JSON.serialize(searchResult);
        
        }catch(Exception ex) {
           throw new AuraHandledException(ex.getMessage());
        }
            
    }
    public static List<String> parseCSVString(String line) {

        List<String> fields = line.split(',');  
        List<String> cleanFields = new List<String>();
        String compositeField;
        Boolean makeCompositeField = false;  

        for(String field : fields) {
        
            if (field.startsWith('"') && field.endsWith('"')) {
            
                String x = field.replaceAll('DBLQT','"');
                x = x.substring(1);
                x = x.substring(0, x.length()-1);
                cleanFields.add(x);                    
            }else if (field.startsWith('"')) {
            
                makeCompositeField = true;
                compositeField = field;
            }else if (field.endsWith('"')) {
                compositeField += ',' + field;
                String x = compositeField.replaceAll('DBLQT','"');
                x = x.substring(1);
                x = x.substring(0, x.length()-1);
                cleanFields.add(x);
                makeCompositeField = false;
            }else if (makeCompositeField) {
            
                compositeField +=  ',' + field;
            }else {
                cleanFields.add(field.replaceAll('DBLQT','"'));
            }
        }
        return cleanFields;
    }
    
    //SOSL Materials query with search string
    @AuraEnabled
    public static String getMaterialsByText(String SearchString,String language,String filetype,String bookseries,String dlsSection,String sortingOption,String rating,String dateRange,Integer pageNumber,Integer pageSize){
        System.debug('searchtype'+SearchString );
        String searchInput = '';
        Integer offset = null;
        
        List<Materials__c> MaterialList = new List<Materials__c>();
        
        UtilDomain.SearchResultInfo searchResult = new UtilDomain.SearchResultInfo();
        
        try {
            
            if(pageNumber != null && pageSize != null){
                offset = ((Integer)pageNumber - 1) * pageSize;
            }
            
            if(SearchString != null && SearchString != '' && SearchString.trim().length() > 0) {
            
                System.debug('searchtypeif');
                String specialChars = '(|)|-|';
                List<String> splittedBySpaceStringList = new List<String>();
                
                for( String str : parseCSVString(SearchString)) {
                    for(integer i = 0; i < specialChars.split('|').size(); i++){
                        str = str.replace(specialChars.split('|')[i], '');
                    }
                    
                    if(str.trim().length() > 0) {
                        searchInput += str.trim()+' OR ';
                        if(str.contains(' ')) {
                            for(String spacestr : str.split(' ')){
                                if(spacestr.trim().length() > 0) splittedBySpaceStringList.add(spacestr);
                            }
                        }
                    }
                }
                
                if(searchInput.endsWith(' OR ')) {
                    searchInput = searchInput.subString(0,searchInput.length()-4);
                }
                
                searchInput = String.EscapeSingleQuotes(searchInput);
                
                if(searchInput.contains('+')||searchInput.contains('&')||searchInput.contains('{')||searchInput.contains('}')||searchInput.contains('^')||searchInput.contains('!')||searchInput.contains('[')||searchInput.contains(']')||searchInput.contains(':')) {
                    system.debug(':::::::::::::::::hello:::::::::::::::');
                    AuraHandledException e = new AuraHandledException('Special characters are not allowed');
                    e.setMessage('Special characters are not allowed');
                    throw e;
                }else {
                    String soslquerystring = '';
                    
                    soslquerystring += ' WHERE OwnerId != null';
                    
                    if(String.isNotBlank(language) && language != 'All') {
                        if(language != 'Other') {
                            soslquerystring += ' AND Language_LU__c = \''+language+'\'';
                        }else {
                            soslquerystring += ' AND Language_LU__c = null';
                        }
                    } 
                    if(filetype != 'All') {
                        if(filetype != 'Other') {
                            soslquerystring += ' AND Book_Format__c = \''+filetype+'\'';
                        }else {
                            soslquerystring += ' AND Book_Format__c = null';
                        }
                    } 
                    if(bookseries != 'All') {
                        if(bookseries != 'Other') {
                            soslquerystring += ' AND Book_Series__c = \''+bookseries+'\'';
                        }else {
                            soslquerystring += ' AND Book_Series__c = null';
                        }
                    }
                    
                    if(dlsSection != 'All') {
                        if(dlsSection != 'Other') {
                            soslquerystring += ' AND DLS_Section__c = \''+dlsSection+'\'';
                        }else {
                            soslquerystring += ' AND DLS_Section__c = null';
                        }
                    }
                    
                    if(rating != 'All'){
                        soslquerystring += rating;
                    }
                    
                    if(dateRange != 'All'){
                        soslquerystring += dateRange;
                    }
                    //List<List<SObject>> searchList = search.query(soslquerystring);
                    
                    //Added dynamic sorting option from client side to server side to avoid 15MB exceeded error
                    String sortingField = '';
                    String sortingType = '';
                    
                    if(sortingOption == 'Top Rated'){
                        sortingField = 'Average_Rating__c'; 
                        sortingType = 'DESC NULLS LAST';
                    }else if(sortingOption == 'Most Requested') {
                        sortingField = 'Number_of_Requests__c'; 
                        sortingType = 'DESC NULLS LAST';
                    }else if(sortingOption == 'Newest'){
                        sortingField = 'CreatedDate'; 
                        sortingType = 'DESC';
                    }else if(sortingOption == 'Alphabetical'){
                        sortingField = 'Name'; 
                        sortingType = 'ASC';
                    }else if(sortingOption == 'Most Favorited'){
                        sortingField = 'Total_Favourite_Count__c'; 
                        sortingType = 'DESC NULLS LAST';
                    }
                    
                    String conditionQry = soslquerystring;
                    
                    if(String.isNotBlank(sortingField) && String.isNotBlank(sortingType)){
                        soslquerystring += ' ORDER BY '+sortingField+' '+sortingType;
                    }
                    
                    /* Get the Material Records Total Count*/
                    List<List<SObject>> searchedMatList = MaterialsService.getMaterialsbySearchParamter(searchInput,soslquerystring +')');
                    Integer materialTotalCnt = 0;
                    if(searchedMatList != NULL && searchedMatList.size() > 0){
                        materialTotalCnt = searchedMatList[0].size();
                    }
                    
                    if(offset != null){
                        soslquerystring += ' LIMIT '+pageSize+' OFFSET '+offset;
                    }else {
                        soslquerystring += ' LIMIT 100'; 
                    }
                    
                    soslquerystring += ')';
                    List<List<SObject>> searchList = MaterialsService.getMaterialsbySearchParamter(searchInput,soslquerystring);
                    system.debug(':::::::searchList :::::::'+searchList);
                    
                    if(searchList != NULL && searchList.size() > 0){
                        MaterialList = searchList[0];
                    }
                    
                    
                    //Get aggregate results for Format, Series, Language & DLS Section filters
                    Set<Id> materialsIds = new Set<Id>();
                    for(Materials__c mat : MaterialList){
                        materialsIds.add(mat.Id);
                    }
                    
                    conditionQry += ' AND Id IN :materialsIds ';
                    
                    //For Format filter
                    String formatQry = 'SELECT count(Id),Book_format__c FROM Materials__c';
                    
                    if(String.isNotBlank(conditionQry)){
                        formatQry += conditionQry;
                    }
                    
                    formatQry += ' GROUP BY Book_format__c';
                    
                    List<AggregateResult> formatRecords = database.query(formatQry);
                    //system.debug('::::::::formatRecords:::'+formatRecords);
                    
                    //For Langauge Filter
                    String languageQry = 'SELECT count(Id),Language_LU__c FROM Materials__c';
                    
                    if(String.isNotBlank(conditionQry)){
                        languageQry += conditionQry;
                    }
                    
                    languageQry += ' GROUP BY Language_LU__c';
                    
                    List<AggregateResult> languageRecords = database.query(languageQry);
                    system.debug('::::::::::languageRecords:::'+languageRecords);
                    
                    Set<Id> langIds = new Set<Id>();
                    Map<Id,String> langIdNameMap = new Map<Id,String>();
                    
                    for(AggregateResult agg : languageRecords){
                        langIds.add((Id) agg.get('Language_LU__c'));
                    }
                    
                    for(Language__c lang : [SELECT Id,Name FROM Language__c WHERE Id IN :langIds]){
                        if(!langIdNameMap.containsKey(lang.Id)){
                            langIdNameMap.put(lang.Id,lang.Name);
                        }
                    }
                    
                    //For Series filter
                    String seriesQry = 'SELECT count(Id),Book_Series__c FROM Materials__c';
                    
                    if(String.isNotBlank(conditionQry)){
                        seriesQry += conditionQry;
                    }
                    
                    seriesQry += ' GROUP BY Book_Series__c';
                    
                    List<AggregateResult> seriesRecords = database.query(seriesQry);
                    system.debug('::::::::::seriesRecords:::'+seriesRecords);
                    
                    //For DLS Section filter
                    String dlsSectionQry = 'SELECT count(Id),Language_LU__r.DLS_Section__c FROM Materials__c';
                    
                    if(String.isNotBlank(conditionQry)){
                        dlsSectionQry += conditionQry;
                    }

                    dlsSectionQry += ' GROUP BY Language_LU__r.DLS_Section__c';
                    
                    //dlsSectionQry += ' LIMIT :pageSize OFFSET :offset';
                    List<AggregateResult> dlsSectionRecords = database.query(dlsSectionQry);
                    system.debug('::::::::::dlsSectionRecords:::'+dlsSectionRecords);
                    
                    searchResult = UtilTranslator.searchResultFormation(new List<ContentVersion>{},MaterialList,formatRecords,languageRecords,seriesRecords,dlsSectionRecords,langIdNameMap);
                    searchResult.materialCVRecordsCnt = materialTotalCnt;
                }
            }
            
            return JSON.serialize(searchResult);
            
        }catch(Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
        
    }
    
    //Mehtod to get the content records without search string
    @AuraEnabled
    public static String getDigitalContentsWithoutText(String language,String filetype,String bookseries,String dlsSection,String sortingOption,Integer pageNumber,Integer pageSize){
        
        try {
            Integer offset = null;
            
            if(pageNumber != null && pageSize != null) {
                offset = (pageNumber - 1) * pageSize;
            }
            
            String contentVersionQry = 'SELECT ContentDocumentId,Description,FileType,Id,IsLatest,PublishStatus,RatingCount,Average_Rating__c,Number_of_Downloads__c,Rating__c,Sum_Of_Rating__c,'
                                          +'Title,ContentDocument.ParentId,ContentDocument.Title,Author__c,Book_Series__c,Cost__c,Language_LU__c,Language_LU__r.Name,CreatedDate,Date__c,Copyright__c'
                                  +' FROM ContentVersion';
           
           //String contentVersionQry = '';
           String conditionQry = ' WHERE ContentDocument.ParentId != null AND ContentDocumentId != null AND IsLatest = true AND PublishStatus =\'p\'';
           
            if(language != 'All') {
                if(language != 'Other') {
                    conditionQry += ' AND Language_LU__c = \''+language+'\'';
                }else if(language == 'Other'){
                    conditionQry += ' AND Language_LU__c = null';
                }
            } 
            
            if(filetype != 'All') {
                if(filetype != 'Other') {
                    conditionQry += ' AND FileType = \''+filetype+'\'';
                }else {
                    conditionQry += ' AND FileType = null';
                }
            }
          
            if(bookseries != 'All') {
                if(bookseries != 'Other') {
                    conditionQry += ' AND Book_Series__c = \''+bookseries+'\'';
                }else {
                    conditionQry += ' AND Book_Series__c = null';
                }
            }
            
            if(dlsSection != 'All') {
                if(dlsSection != 'Other') {
                    conditionQry += ' AND DLS_Section__c = \''+dlsSection+'\'';
                }else {
                    conditionQry += ' AND DLS_Section__c = null';
                }
            }
            
            system.debug(':::::::UserInfo.getUserType():::::::'+UserInfo.getUserType());
            
            //Sorting option details
            //Newly Addedby NS to avoid maximum size exceeded error
            String sortingField = '';
            String sortingType = '';
            
            if(sortingOption == 'Top Rated'){
                sortingField = 'Average_Rating__c'; 
                sortingType = 'DESC NULLS LAST';
            }else if(sortingOption == 'Most Requested') {
                sortingField = 'Number_of_Downloads__c'; 
                sortingType = 'DESC NULLS LAST';
            }else if(sortingOption == 'Newest'){
                sortingField = 'CreatedDate'; 
                sortingType = 'DESC';
            }else if(sortingOption == 'Alphabetical'){
                sortingField = 'Title'; 
                sortingType = 'ASC';
            }else if(sortingOption == 'Most Favorited'){
                sortingField = 'Total_Favourite_Count__c'; 
                sortingType = 'DESC NULLS LAST';
            }
            
            contentVersionQry += conditionQry;
            
            contentVersionQry += ' ORDER BY '+sortingField+' '+sortingType;
            
            if(offset != null){
                contentVersionQry += ' LIMIT '+pageSize+' OFFSET '+offset;
            }else{
               contentVersionQry += ' LIMIT 100';
            }
            
            /* get the conVersion Total Count*/
            String conVersionCntQuery = 'SELECT COUNT() FROM ContentVersion'+conditionQry;
            Integer conVersionTotalCnt = Database.countQuery(conVersionCntQuery);

            system.debug('::::::qary:::::'+contentVersionQry);
            List<ContentVersion> contentDetails = Database.query(contentVersionQry);
            //List<ContentVersion> contentDetails = ContentVersionService.getContentVersionbyFilters(contentVersionQry);
            
            system.debug('::::::::::::contentDetails::::'+contentDetails);
            system.debug('::::::::::::contentDetails:::size:'+contentDetails.size());
            
            
            //Get aggregate results for Format, Series, Language & DLS Section filters
                    
            //For Format filter
            String formatQry = 'SELECT count(Id),FileType FROM ContentVersion';
            
            if(String.isNotBlank(conditionQry)){
                formatQry += conditionQry;
            }
            
            formatQry += ' GROUP BY FileType';
            
            List<AggregateResult> formatRecords = database.query(formatQry);
            //system.debug('::::::::formatRecords:::'+formatRecords);
            
            //For Langauge Filter
            String languageQry = 'SELECT count(Id),Language_LU__c FROM ContentVersion';
            
            if(String.isNotBlank(conditionQry)){
                languageQry += conditionQry;
            }
            
            languageQry += ' GROUP BY Language_LU__c';
            
            List<AggregateResult> languageRecords = database.query(languageQry);
            system.debug('::::::::::languageRecords:::'+languageRecords);
            
            Set<Id> langIds = new Set<Id>();
            Map<Id,String> langIdNameMap = new Map<Id,String>();
            
            for(AggregateResult agg : languageRecords){
                langIds.add((Id) agg.get('Language_LU__c'));
            }
            
            for(Language__c lang : [SELECT Id,Name FROM Language__c WHERE Id IN :langIds]){
                if(!langIdNameMap.containsKey(lang.Id)){
                    langIdNameMap.put(lang.Id,lang.Name);
                }
            }
            
            //For Series filter
            String seriesQry = 'SELECT count(Id),Book_Series__c FROM ContentVersion';
            
            if(String.isNotBlank(conditionQry)){
                seriesQry += conditionQry;
            }
            
            seriesQry += ' GROUP BY Book_Series__c';
            
            List<AggregateResult> seriesRecords = database.query(seriesQry);
            system.debug('::::::::::seriesRecords:::'+seriesRecords);
            
            //For DLS Section filter
            String dlsSectionQry = 'SELECT count(Id),DLS_Section__c FROM ContentVersion';
            
            if(String.isNotBlank(conditionQry)){
                dlsSectionQry += conditionQry;
            }
            
            dlsSectionQry += ' GROUP BY DLS_Section__c';
            
            List<AggregateResult> dlsSectionRecords = database.query(dlsSectionQry);
            system.debug('::::::::::dlsSectionRecords:::'+dlsSectionRecords);
            
            UtilDomain.SearchResultInfo searchResult = UtilTranslator.searchResultFormation(contentDetails,new List<Materials__c>{},formatRecords,languageRecords,seriesRecords,dlsSectionRecords,langIdNameMap);
            searchResult.materialCVRecordsCnt = conVersionTotalCnt;
                
            return JSON.serialize(searchResult);
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    
    }
    
    //Method to get Materials records wihtout search string
    @AuraEnabled
    public static String getMaterialsWithoutText(String language,String filetype,String bookseries,String dlsSection,String sortingOption,String rating,String dateRange,Integer pageNumber,Integer pageSize){
        system.debug(':::filters::::::::::::'+language +' '+filetype +' '+bookseries +' '+dlsSection+' '+sortingOption);
        
        try {
            String MaterialQry = '';
            Integer offset = null;
            
            if(pageNumber != null && pageSize != null) {
                offset = (pageNumber - 1) * pageSize;
            }

            if(language != 'All') {
                if(language != 'Other') {
                  MaterialQry += ' AND Language_LU__c = \''+language+'\'';
                }else if(language == 'Other'){
                  MaterialQry += ' AND Language_LU__c = null';
                }
            } 
            if(filetype != 'All') {
               if(filetype != 'Other') {
                   MaterialQry += ' AND Book_Format__c = \''+filetype+'\'';
               }else {
                   MaterialQry += ' AND Book_Format__c = null';
               }
            }
            if(bookseries != 'All') {
                 if(bookseries != 'Other') {
                     MaterialQry += ' AND Book_Series__c = \''+bookseries+'\'';
                 }else {
                     MaterialQry += ' AND Book_Series__c = null';
                 }
            }
            
            if(dlsSection != 'All') {
                 if(dlsSection != 'Other') {
                     MaterialQry += ' AND DLS_Section__c = \''+dlsSection+'\'';
                 }else {
                     MaterialQry += ' AND DLS_Section__c = null';
                 }
            }

            if(rating != 'All'){
                MaterialQry += rating;
            }
            
            if(dateRange != 'All'){
                MaterialQry += dateRange;
            }
           
            
            String sortingField = ''; 
            String sortingType = '';
            String offsetQry = '';

            if(sortingOption == 'Top Rated'){
                sortingField = 'Average_Rating__c'; 
                sortingType = 'DESC NULLS LAST';
            }else if(sortingOption == 'Most Requested') {
                sortingField = 'Number_of_Requests__c'; 
                sortingType = 'DESC NULLS LAST';
            }else if(sortingOption == 'Newest'){
                sortingField = 'CreatedDate'; 
                sortingType = 'DESC';
            }else if(sortingOption == 'Alphabetical'){
                sortingField = 'Name'; 
                sortingType = 'ASC';
            }else if(sortingOption == 'Most Favorited'){
                sortingField = 'Total_Favourite_Count__c'; 
                sortingType = 'DESC NULLS LAST'; 
            }
             
            if(offset != null){
                offsetQry = ' LIMIT '+pageSize+' OFFSET '+offset;
            }
            
            system.debug('::::::qary:::::'+MaterialQry); 
            /* get the Material Total Count*/
            String materialCntQuery = 'SELECT COUNT() FROM Materials__c'+ (String.isNotBlank(MaterialQry) ? ' WHERE OwnerId != null '+MaterialQry : '');
            Integer materialTotalCnt = Database.countQuery(materialCntQuery);

            List<Materials__c> materialDetails = MaterialsService.getMaterialsbyFilters(MaterialQry,sortingField,sortingType,offsetQry);
            
            //Get aggregate results for Format, Series, Language & DLS Section filters
                        
            //For Format filter
            String formatQry = 'SELECT count(Id),Book_format__c FROM Materials__c WHERE OwnerId != null';
            
            if(String.isNotBlank(MaterialQry)){
                formatQry += MaterialQry;
            }
            
            formatQry += ' GROUP BY Book_format__c';
            List<AggregateResult> formatRecords = database.query(formatQry);
            //system.debug('::::::::formatRecords:::'+formatRecords);
            
            //For Langauge Filter
            String languageQry = 'SELECT count(Id),Language_LU__c FROM Materials__c WHERE OwnerId != null';
            
            if(String.isNotBlank(MaterialQry)){
                languageQry += MaterialQry;
            }
            
            languageQry += ' GROUP BY Language_LU__c';
            
            List<AggregateResult> languageRecords = database.query(languageQry);
            system.debug('::::::::::languageRecords:::'+languageRecords);
            
            Set<Id> langIds = new Set<Id>();
            Map<Id,String> langIdNameMap = new Map<Id,String>();
            
            for(AggregateResult agg : languageRecords){
                langIds.add((Id) agg.get('Language_LU__c'));
            }
            
            for(Language__c lang : [SELECT Id,Name FROM Language__c WHERE Id IN :langIds]){
                if(!langIdNameMap.containsKey(lang.Id)){
                    langIdNameMap.put(lang.Id,lang.Name);
                }
            }
            
            if(langIdNameMap.size() == 0){
                List<Language__c> lanRec = [SELECT Id,Name FROM Language__c WHERE Id = :language];
                if(lanRec.size() > 0) {
                    langIdNameMap.put(lanRec[0].Id,lanRec[0].Name);
                }
            }
            
            //For Series filter
            String seriesQry = 'SELECT count(Id),Book_Series__c FROM Materials__c WHERE OwnerId != null';
            
            if(String.isNotBlank(MaterialQry)){
                seriesQry += MaterialQry;
            }
            
            seriesQry += ' GROUP BY Book_Series__c';
            
            List<AggregateResult> seriesRecords = database.query(seriesQry);
            system.debug('::::::::::seriesRecords:::'+seriesRecords);
            
            //For DLS Section filter
            String dlsSectionQry = 'SELECT count(Id),Language_LU__r.DLS_Section__c FROM Materials__c WHERE OwnerId != null';
            
            if(String.isNotBlank(MaterialQry)){
                dlsSectionQry += MaterialQry;
            }
            
            dlsSectionQry += ' GROUP BY Language_LU__r.DLS_Section__c';
            
            List<AggregateResult> dlsSectionRecords = database.query(dlsSectionQry);
            system.debug('::::::::::dlsSectionRecords:::'+dlsSectionRecords);
          
            UtilDomain.SearchResultInfo searchResult = UtilTranslator.searchResultFormation(new List<ContentVersion>{},materialDetails,formatRecords,languageRecords,seriesRecords,dlsSectionRecords,langIdNameMap);
            searchResult.materialCVRecordsCnt = materialTotalCnt;
            //system.debug('::::::::::::materialDetails::::'+materialDetails); 
            system.debug('::::::::::::materialDetails:::size:'+materialDetails.size());
                
            return JSON.serialize(searchResult);
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    //Method to get the Content Version detail page related information
    @AuraEnabled
    public static String getContentVersionAllDetails(String userType,String contentVersionId){
        
        try {
            //Get Current User related Contact info
            
            Id contactId;
            List<Material_Rating__c> newBtnMaterialRating = new List<Material_Rating__c>();
            List<Material_Rating__c> materialRatingList = new List<Material_Rating__c>();
            List<Favourite_Material__c> favouriteMaterialList = new List<Favourite_Material__c>();
            List<Request__c> bookRequestDetails = new List<Request__c>();
            
            List<User> usrRec = SObjectQueryService.SObjectQuery('User',new Set<Id>{UserInfo.getUserId()},',Contact.MailingCity,Contact.MailingState,Contact.MailingCountry,Profile.Name');
            if(usrRec.size() > 0 && usrRec[0].ContactId != null) {
                contactId = usrRec[0].ContactId;
            }else {
                List<Contact> conRec = [SELECT Id,Name FROM Contact WHERE DLS_User__c = :UserInfo.getUserId()];
                if(conRec.size() > 0) {
                    contactId = conRec[0].Id;
                }
            }
            
            //Get ContentVersion detail
            List<ContentVersion> contentVersionRec = ContentVersionService.getContentVersionbyIds(new Set<Id>{contentVersionId},new Set<Id>{});
            
            //Get Material record type id from request object
            String devlopername = 'Material'; 
            List<RecordType> recordTypeRec = SObjectQueryService.getRecTypeListBySobjTypeAndDevName(' WHERE SobjectType = \'Request__c\' AND DeveloperName ','',new Set<String>{devlopername});
            
            if(userType == 'Internal' || userType == 'Staff'){
                
                // for new review btn display qry 
                newBtnMaterialRating = MaterialRatingService.getMaterialrating(' WHERE ContentVersionId__c = \''+contentVersionId+'\' AND Contact__c = \''+ contactId +'\' ORDER BY Date__c DESC', 'Contact__r.Name');
                
                // For material rating 
                materialRatingList = MaterialRatingService.getMaterialrating(' WHERE ContentVersionId__c = \''+contentVersionId+'\' AND Contact__c != \''+ contactId +'\' ORDER BY Date__c DESC','Contact__r.Name');
                
                // For Favourite material list 
                favouriteMaterialList = FavouriteMaterialService.getFavouritematerial(' WHERE ContentVersion_Id__c = \''+ contentVersionId +'\' AND Contact__c = \''+ contactId +'\'');
                
                
                // For Book request details qry
                bookRequestDetails = RequestService.getRequest(' WHERE RecordTypeId = \''+recordTypeRec[0].Id +'\' AND ContentVersionId__c = \''+contentVersionId+'\'','Project__r.DLS_Class__c');
            
            }else {
            
                // for new review btn display qry 
                newBtnMaterialRating = MaterialRatingService.getMaterialrating(' WHERE Contact__c = \''+contactId+'\' AND ContentVersionId__c = \''+contentVersionId+'\' ORDER BY Date__c DESC','Contact__r.Name');
                
                // For material rating 
                
                materialRatingList = MaterialRatingService.getMaterialrating(' WHERE ContentVersionId__c = \''+contentVersionId+'\' AND Contact__c != \''+contactId+'\' AND Hide_to_Community__c = false ORDER BY Date__c DESC','Contact__r.Name');
                                      
                // For Favourite material list 
                favouriteMaterialList = FavouriteMaterialService.getFavouritematerial(' WHERE ContentVersion_Id__c = \''+ contentVersionId +'\' AND Contact__c = \''+ contactId +'\'');
                                        
                // For Book request details qry
                bookRequestDetails = RequestService.getRequest(' WHERE RecordTypeId = \''+recordTypeRec[0].Id +'\' AND ContentVersionId__c = \''+contentVersionId+'\' AND Contact__c = \''+contactId+'\'','Project__r.DLS_Class__c');
            }
            
            List<AggregateResult> numberOfDwnload = RequestService.getAggregatelist(new Set<Id>{contentVersionId});
            
            Integer downloadedCnt = 0;
            
            if(numberOfDwnload.size() > 0){
                downloadedCnt = (Integer) numberOfDwnload[0].get('expr0');
            }
             
            // Check the logged in user is LTS or not to edit the LTS Description field
            Boolean allowLTS = false;
            if(usrRec[0].Profile.Name == 'LTS' || usrRec[0].Profile.Name == 'System Administrator'){
                allowLTS = true;
            }
            
            Boolean displayNewRatingBtn = false;
            if(newBtnMaterialRating.size() > 0){
                displayNewRatingBtn = false;
            }else {
                displayNewRatingBtn = true;
            }
            
            //Get Content Version parent related work space info
            List<ContentWorkspace> workSpaceRec = new List<ContentWorkspace>();
            
            if(contentVersionRec[0].ContentDocument.ParentId != null) {
                workSpaceRec = SObjectQueryService.SObjectQuery('ContentWorkspace',new Set<Id>{contentVersionRec[0].ContentDocument.ParentId},'');
            }
            
            ContentVersionDomain.ContentVersionInfo contentDetails = ContentVersionTranslator.formContentVersionDetails(contentVersionRec,displayNewRatingBtn,newBtnMaterialRating,materialRatingList,recordTypeRec,favouriteMaterialList,contactId,allowLTS,bookRequestDetails,downloadedCnt,workSpaceRec);
            
            return JSON.serialize(contentDetails);
            
        }catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    //Method to create records for Material_Rating__c,Favourite_Material__c,Materials_Request__c objects
    @AuraEnabled
    public static String createForallObjects(String createJson,String objectName){
        
        try {
            if(objectName == 'Favourite_Material__c') {
               List<Favourite_Material__c> insertionList = (List<Favourite_Material__c>) System.JSON.deserialize(createJson, List<Favourite_Material__c>.class);
               
               if(insertionList.size() > 0) {
                  insert insertionList; 
               }
           }else if(objectName == 'Material_Rating__c') {
               List<Material_Rating__c> insertionList = (List<Material_Rating__c>) System.JSON.deserialize(createJson, List<Material_Rating__c>.class);
               
               if(insertionList.size() > 0) {
                  insert insertionList;
               }
           }else if(objectName == 'Request__c') {
               List<Request__c> insertionList = (List<Request__c>) System.JSON.deserialize(createJson, List<Request__c>.class);
               
               if(insertionList.size() > 0) {
                  insert insertionList;
               }
           }
           
           return 'SUCCESS';
       }catch(Exception ex) {
           throw new AuraHandledException(ex.getMessage());
       }
    }
    
    //Method to get Material related all information
    //Added by NS on July 16 2019
    @AuraEnabled
    public static String getMeterialRelatedAllInfo(String userType, String materialId){
    
        try{
            
            List<Favourite_Material__c> favouriteList = new List<Favourite_Material__c>();
            List<Material_Rating__c> materialRatingNewBtn = new List<Material_Rating__c>();
            List<Material_Rating__c> materialRatingList = new List<Material_Rating__c>();
            List<Materials_Request__c> orderRequests = new List<Materials_Request__c>();
            List<Materials_Request__c> loanRequests = new List<Materials_Request__c>();
            
            Id contactId;
        
            List<User> usrRec = SObjectQueryService.SObjectQuery('User',new Set<Id>{UserInfo.getUserId()},',Contact.MailingCity,Contact.MailingState,Contact.MailingCountry,Profile.Name');
            if(usrRec[0].ContactId != null) {
                contactId = usrRec[0].ContactId;
            }else {
                List<Contact> conRec = [SELECT Id,Name FROM Contact WHERE DLS_User__c = :UserInfo.getUserId()];
                if(conRec.size() > 0) {
                    contactId = conRec[0].Id;
                }
            }
            
            //Get material details
            List<Materials__c> materialDetail = MaterialsService.getMaterialsbyIds(new Set<Id>{materialId});
            
            //get Favouite Material details
            if(userType == 'Internal' || userType == 'Staff') {
               favouriteList = FavouriteMaterialService.getFavouritematerial(' WHERE Material_Name__c = \'' +materialId +'\' AND Contact__c = \'' +contactId+'\'');
            }else {
                favouriteList = FavouriteMaterialService.getFavouritematerial(' WHERE Material_Name__c = \'' +materialId +'\' AND Contact__c = \'' +contactId+'\'');
            }
            
            //New Review Btn Display
            if(userType == 'Instructor' || userType == 'Student') {
                materialRatingNewBtn = MaterialRatingService.getMaterialrating(' WHERE Material_Name__c = \''+materialId+'\' AND Contact__c = \''+contactId+'\' ORDER BY Date__c DESC','Contact__r.Name');
            }else if(userType == 'Internal' || userType == 'Staff'){
                materialRatingNewBtn = MaterialRatingService.getMaterialrating(' WHERE Material_Name__c = \''+materialId+'\' AND Contact__c = \''+contactId+'\' ORDER BY Date__c DESC','Contact__r.Name');
            }
            
            
            //Rating records from other user
            if(userType == 'Instructor' || userType == 'Student') {
                materialRatingList = MaterialRatingService.getMaterialrating(' WHERE Material_Name__c = \''+materialId +'\' AND Contact__c != \''+contactId+'\' AND Hide_to_Community__c = false ORDER BY Date__c DESC','Contact__r.Name');
            }else {
                materialRatingList = MaterialRatingService.getMaterialrating(' WHERE Material_Name__c = \''+materialId+'\' AND Contact__c != \''+contactId+'\' ORDER BY Date__c DESC','Contact__r.Name');
            }
            
            
            //Qry Order & Loan material request records
            if(userType == 'Instructor' || userType == 'Student') {
                
                if(userType == 'Instructor') {
                    orderRequests = MaterialRequestService.getMaterial(' WHERE Materials_Name__c = \''+materialId+'\' AND Contact__c = \''+contactId+'\' AND RecordType.DeveloperName = \'Project_Materials_Request\' ORDER BY CreatedDate DESC',' Project__r.DLS_Class__c,Project__r.End_Date__c,Project_Task__r.AcctSeed__Project__r.DLS_Class__c,Location__r.Name,Contact__r.Name,RecordType.DeveloperName');
                }else {
                    Set<Id> projectIds = new Set<Id>();
                    for(Contact_Assignments__c ca : [SELECT Id,Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId AND Status__c IN ('Active','Planned')]){
                        projectIds.add(ca.Project__c);
                    }
                    
                    String materialRequestQry = 'SELECT '+MaterialRequestService.fldStr+',Project__r.DLS_Class__c,Project__r.End_Date__c,Project_Task__r.AcctSeed__Project__r.DLS_Class__c,Location__r.Name,Contact__r.Name,RecordType.DeveloperName FROM Materials_Request__c WHERE Materials_Name__c = \''+materialId+'\' AND Project__c IN :projectIds AND RecordType.DeveloperName = \'Project_Materials_Request\' AND (Contact__c = :contactId OR Contact__c = null)';
                    
                    orderRequests = database.query(materialRequestQry);
                    
                    //orderRequests = MaterialRequestService.getMRrecordsByParentIds(' WHERE Materials_Name__c = \''+materialId+'\' AND RecordType.DeveloperName = \'Project_Materials_Request\' ORDER BY CreatedDate DESC',' Project__r.DLS_Class__c,Project__r.End_Date__c,Project_Task__r.AcctSeed__Project__r.DLS_Class__c,Location__r.Name,Contact__r.Name,RecordType.DeveloperName');
                    
                }
                loanRequests = MaterialRequestService.getMaterial(' WHERE Materials_Name__c = \''+materialId+'\' AND Contact__c = \''+contactId+'\' AND RecordType.DeveloperName = \'Material_Loan_Request\' ORDER BY CreatedDate DESC',' Project__r.DLS_Class__c,Project__r.End_Date__c,Project_Task__r.AcctSeed__Project__r.DLS_Class__c,Location__r.Name,Contact__r.Name,RecordType.DeveloperName');
            }else {
                orderRequests = MaterialRequestService.getMaterial(' WHERE Materials_Name__c = \''+materialId+'\' AND RecordType.DeveloperName = \'Project_Materials_Request\' ORDER BY CreatedDate DESC',' Project__r.DLS_Class__c,Project__r.End_Date__c,Project_Task__r.AcctSeed__Project__r.DLS_Class__c,Location__r.Name,Contact__r.Name,RecordType.DeveloperName'); 
                loanRequests = MaterialRequestService.getMaterial(' WHERE Materials_Name__c = \''+materialId+'\' AND RecordType.DeveloperName = \'Material_Loan_Request\' ORDER BY CreatedDate DESC',' Project__r.DLS_Class__c,Project__r.End_Date__c,Project_Task__r.AcctSeed__Project__r.DLS_Class__c,Location__r.Name,Contact__r.Name,RecordType.DeveloperName'); 
            }
            
            
            // Check the logged in user profile to enable the LTS Description field edit
            Boolean allowLTS = false;
            if(usrRec[0].Profile.Name == 'LTS' || usrRec[0].Profile.Name == 'System Administrator') {
                allowLTS = true;
            }
            
            MaterialsDomain.MaterialDetailInfo materialInfo = MaterialsTranslator.materialDetailFormation(materialDetail,favouriteList,materialRatingNewBtn,materialRatingList,contactId,allowLTS,orderRequests,loanRequests);
            
            return JSON.serialize(materialInfo);
        
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    //Method to get the Favouite Materials
    //Added by NS on July 26 2019
    @AuraEnabled 
    public static List<Materials__c> getFavoriteMaterialsInfo(){
        
        Set<Id> materialIds = new Set<Id>();
        
        List<User> usrRec = SObjectQueryService.SObjectQuery('User',new Set<Id>{UserInfo.getUserId()},'');
        
        List<Favourite_Material__c> favouritematList = FavouriteMaterialService.getFavouritematerial(' WHERE Contact__c = \''+usrRec[0].ContactId +'\'');
        for(Favourite_Material__c favourite : favouritematList) {
            
            if(favourite.Material_Name__c != null) {
               materialIds.add(favourite.Material_Name__c);  
            }
        }
        
        List<Materials__c> favoriteMaterials = MaterialsService.getMaterialsbyIds(materialIds);
        
        return favoriteMaterials;
    }
    
    //Method to get the Top Rated Materials
    // Added by NS on July 26 2019
    @AuraEnabled
    public static List<Materials__c> getTopRatedMaterialsInfo(){
    
        Set<Id> materialIds = new Set<Id>();
        
        List<User> usrRec = SObjectQueryService.SObjectQuery('User',new Set<Id>{UserInfo.getUserId()},'');
       
        List<Material_Rating__c> matRatingList = MaterialRatingService.getMaterialrating(' WHERE Ratings__c > 3 AND Contact__c = \''+usrRec[0].ContactId+'\'','Material_Name__r.Average_Rating__c');
        
        for(Material_Rating__c rate : matRatingList) {
            
            if(rate.Material_Name__c != null) {
                materialIds.add(rate.Material_Name__c);  
            }
        }
        
        List<Materials__c> topRatedMaterials = MaterialsService.getMaterialsbyIds(materialIds);
        
        return topRatedMaterials;
    }
    
    //Method to upsert material request records for transfer to new project option in library home page / material request detail page transfer btn
    //Added by NS on March 10 2020
    @AuraEnabled
    public static String upsertLoanMRRecords(String loanMRId,String projectId){
        
        try{
                
            List<Materials_Request__c> oldMaterialRequest = [SELECT Id,Name,Project__c,Contact__c,Materials_Name__c,Qty__c,RecordTypeId,Request_type__c,Request_Notes__c,
                                                                    Est_Arrival_Date__c,Date_Loaned_Out__c,Date_Returned__c,Request_Status__c,Location__c,Materials_Source__c,
                                                                    Materials_Stock__c
                                                                FROM Materials_Request__c WHERE Id = :loanMRId];
            
            Materials_Request__c newLoan = new Materials_Request__c();
            newLoan = oldMaterialRequest.size() > 0 ? oldMaterialRequest[0].clone() : null;
            
            newLoan.Id = null;
            newLoan.Request_Status__c = 'Loaned Out';
            newLoan.Project__c = projectId;
            newLoan.Prior_Materials_Request__c = loanMRId;
            
            //old record status update
            Materials_Request__c oldLoan = new Materials_Request__c();
            oldLoan.Id = oldMaterialRequest[0].Id;
            oldLoan.Request_Status__c = 'Transferred to new Project';
            
            
            List<Materials_Request__c> materialRequestToUpdate = new List<Materials_Request__c>();
            materialRequestToUpdate.add(newLoan);
            materialRequestToUpdate.add(oldLoan);
            
            if(materialRequestToUpdate.size() > 0){
                
                upsert materialRequestToUpdate;
                
                return 'SUCCESS';
            }
            
            return null;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getInstructorProjects(String instructorId){
        
        Set<Id> projectIds = new Set<Id>();
        List<AcctSeed__Project__c> projectRecords = new List<AcctSeed__Project__c>();
        
        for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c FROM Contact_Assignments__c 
                                            WHERE Candidate_Name__c = :instructorId AND RecordType.DeveloperName = 'Instructor' AND Status__c IN ('Planned','Active')]){
            
            projectIds.add(ca.Project__c);
        }
        
        if(projectIds.size() > 0){
            projectRecords = [SELECT Id,Name,DLS_Class__c FROM AcctSeed__Project__c WHERE Id IN :projectIds AND AcctSeed__Status__c IN ('Order','Active')];
        }
        
        return JSON.serialize(projectRecords);
    }
    
}