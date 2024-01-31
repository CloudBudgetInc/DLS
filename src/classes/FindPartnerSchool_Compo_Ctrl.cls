/**********************************************************************
    Created by Vinitha on Feb 14, 2017: Apex controller class for this FindPartnerSchool_Component
    to referred in ResourcesPageComponents, to Convert all force.query to Remote action on that component. 
    LibraryContentSearch methods are replaced this controller.                                    
***********************************************************************/

global class FindPartnerSchool_Compo_Ctrl{
    
    global class schoolBasedRec{
        public List<Hotel__c> hotelList;
        public List<Floor_Suite__c> floorsuiteList;        
    }
    
    global class locationbasedRec {
        public List<MTT_Location__c> mttlocationList;        
        public List<MTT_Location__c> partnerSchoolList;
        public List<Hotel__c> hotelList;
        public List<Contact> candidateRecords;
        public List<MTT_Location__c> clientLocations;
    }
    
    global class latlangitudeRec{
        public List<MTT_Location__c> mttloctionlatList;
        public List<MTT_Location__c> partnerSchoolList;
        public List<Hotel__c> hotelList;
        public List<Contact> candidateRecords;
        public List<MTT_Location__c> clientLocations;
    }
    
     /**********************************************************************
    Created by Vinitha on Feb 14, 2017: Apex controller class for this FindPartnerSchool_Component
    to referred in ResourcesPageComponents, to Convert all force.query to Remote action on that component.                                         
    ***********************************************************************/
    @RemoteAction
    global static latlangitudeRec getlatitudeRec(String latitude,String longitude){
        
        system.debug(':::::findpartnerscl::getschooldetailrec latitude'+latitude);
        system.debug(':::::findpartnerscl::getschooldetailrec longitude'+longitude);
        
        List<MTT_Location__c> mttloc = new List<MTT_Location__c>();
        List<MTT_Location__c> partnerSchools = new List<MTT_Location__c>();
        List<Hotel__c> hotelRecords = new List<Hotel__c>();
        List<MTT_Location__c> clientLocation = new List<MTT_Location__c>();
        List<Contact> contactList = new List<Contact>();
        
        if(latitude != null && longitude != null) {
        
            mttloc = MTTLocationService.getMTTlocationRectype(' WHERE RecordType.DeveloperName = \'DLS_Site\' AND DISTANCE(Location_GeoCode__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\') < 500 ORDER BY DISTANCE(Location_GeoCode__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')','');
            
            partnerSchools = MTTLocationService.getMTTlocationRectype(' WHERE RecordType.DeveloperName = \'Partner_Site\' AND DISTANCE(Location_GeoCode__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\') < 500 ORDER BY DISTANCE(Location_GeoCode__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')','');
            
            hotelRecords = HotelService.getHotels(' WHERE DISTANCE(Hotel_GeoCode__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\') < 500 ORDER BY DISTANCE(Hotel_GeoCode__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')','',new Set<Id>{});
            
            clientLocation = MTTLocationService.getMTTlocationRectype(' WHERE RecordType.DeveloperName = \'Client_Site\' AND DISTANCE(Location_GeoCode__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\') < 500 ORDER BY DISTANCE(Location_GeoCode__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')','');
            
            //contactList = ContactService.getContactByparentId(' WHERE RecordType.DeveloperName = \'Candidate\' AND DISTANCE(Location_GeoCode__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\') < 100 ORDER BY DISTANCE(Location_GeoCode__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')','',new Set<Id>{});
            String query = 'SELECT Id,Name,MailingCity,MailingState,MailingCountry,MailingPostalCode,Location_GeoCode__Latitude__s,Location_GeoCode__Longitude__s,All_Count_as_Instructor__c,Active_Count_as_Instructor__c FROM Contact';
            query += ' WHERE RecordType.DeveloperName = \'Candidate\' AND DISTANCE(Location_GeoCode__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\') < 500 ORDER BY DISTANCE(Location_GeoCode__c, GEOLOCATION('+latitude+','+longitude+'), \'mi\')';
            system.debug('::::::::query:::::'+query);
            contactList = Database.query(query);
        }
        
        latlangitudeRec lang = new latlangitudeRec(); 
        lang.mttloctionlatList = mttloc;
        lang.partnerSchoolList = partnerSchools;
        lang.hotelList = hotelRecords;
        lang.clientLocations = clientLocation;
        lang.candidateRecords = contactList;
        
        
        system.debug('::::::::heap::size::::'+Limits.getHeapSize());
        
        return lang; 
    }
    
    /**********************************************************************
    Created by Vinitha on Feb 14, 2017: Apex controller class for this FindPartnerSchool_Component
    to referred in ResourcesPageComponents, to Convert all force.query to Remote action on that component.                                         
    ***********************************************************************/
    @RemoteAction
    global static locationbasedRec getSchooldetailRec(string typename,String stateorcountry){
        
        system.debug(':::::findpartnerscl::getschooldetailrec typename '+typename);
        system.debug(':::::findpartnerscl::getschooldetailrec stateorcountry'+stateorcountry);
        
        
        List<MTT_Location__c> mttlocList = new List<MTT_Location__c>();
        List<MTT_Location__c> partnerSchools = new List<MTT_Location__c>();
        List<Hotel__c> hotelRecords = new List<Hotel__c>();
        List<MTT_Location__c> clientLocation = new List<MTT_Location__c>();
        List<Contact> candidateContacts = new List<Contact>();
        
        if(typename != null && typename != ''){
            if(typename == 'US'){
                // DLS Site Locations
                mttlocList = MTTLocationService.getMTTlocationRectype(' WHERE RecordType.DeveloperName = \'DLS_Site\' AND State__c = \''+ stateorcountry+ '\' AND Location_GeoCode__Latitude__s != Null','');            
                
                // Partner Site Locations
                partnerSchools = MTTLocationService.getMTTlocationRectype(' WHERE RecordType.DeveloperName = \'Partner_Site\' AND State__c = \''+ stateorcountry+ '\' AND Location_GeoCode__Latitude__s != Null','');            
                
                // Hotel locations
                hotelRecords = HotelService.getHotels(' WHERE State__c = \''+ stateorcountry+ '\' AND Hotel_GeoCode__Latitude__s != Null','',new Set<Id>{});
                
                // Client site informations
                clientLocation = MTTLocationService.getMTTlocationRectype(' WHERE RecordType.DeveloperName = \'Client_Site\' AND State__c = \''+ stateorcountry+ '\' AND Location_GeoCode__Latitude__s != Null','');            
                
                // Candidate details
                candidateContacts = [SELECT Id,Name,MailingCity,MailingState,MailingCountry,MailingPostalCode,Location_GeoCode__Latitude__s,Location_GeoCode__Longitude__s,All_Count_as_Instructor__c,Active_Count_as_Instructor__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate' AND MailingState = :stateorcountry AND Location_GeoCode__Latitude__s != Null];
                
            }else{
                // DLS Site Locations
                mttlocList = MTTLocationService.getMTTlocationRectype(' WHERE RecordType.DeveloperName = \'DLS_Site\' AND Country__c = \''+ stateorcountry + '\' AND Location_GeoCode__Latitude__s != Null','');        
                
                // Partner Site Locations
                partnerSchools = MTTLocationService.getMTTlocationRectype(' WHERE RecordType.DeveloperName = \'Partner_Site\' AND Country__c = \''+ stateorcountry + '\' AND Location_GeoCode__Latitude__s != Null','');        
                
                //Hotel locations
                hotelRecords = HotelService.getHotels(' WHERE Country__c = \''+ stateorcountry+ '\' AND Hotel_GeoCode__Latitude__s != Null','',new Set<Id>{});
                
                // Client site informations
                clientLocation = MTTLocationService.getMTTlocationRectype(' WHERE RecordType.DeveloperName = \'Client_Site\' AND Country__c = \''+ stateorcountry + '\' AND Location_GeoCode__Latitude__s != Null','');            
                
                // Candidate details
                candidateContacts = [SELECT Id,Name,MailingCity,MailingState,MailingCountry,MailingPostalCode,Location_GeoCode__Latitude__s,Location_GeoCode__Longitude__s,All_Count_as_Instructor__c,Active_Count_as_Instructor__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate' AND MailingCountry = :stateorcountry AND Location_GeoCode__Latitude__s != Null];
                
            }
        }        
                  
        locationbasedRec sclrec = new locationbasedRec();
        sclrec.mttlocationList = mttlocList;
        sclrec.partnerSchoolList = partnerSchools;       
        sclrec.hotelList = hotelRecords;
        sclrec.candidateRecords = candidateContacts;
        sclrec.clientLocations = clientLocation;
        
        system.debug('::::::::heap::size::::'+Limits.getHeapSize());
        
        return sclrec;
    }
    
    /**********************************************************************
        Created by Vinitha on Feb 14, 2017: Apex controller class for this FindPartnerSchool_Component
        to referred in ResourcesPageComponents, to Convert all force.query to Remote action on that component.                                         
    ***********************************************************************/
    
    @RemoteAction
    global static schoolBasedRec getMttLocationRec(List<Id> locationIdList){    
         
        Set<Id> locationId = new Set<Id>();
        system.debug(':::::locationIdList'+locationIdList);
        for(String rec :locationIdList){
            rec = rec.remove('\'');
            locationId.add(rec);
        }
        system.debug('::::locationId::'+locationId);
        
        List<Hotel__c> hotlList = HotelService.getHotels(' Where MTT_Location__c ',',MTT_Location__r.Location_GeoCode__Latitude__s,MTT_Location__r.Location_GeoCode__Longitude__s',locationId);
        
        List<Floor_Suite__c> flrsuitList = FloorSuiteService.getFloorsuite(' Where Location__c ','',locationId,'');
        
        schoolBasedRec sclrec = new schoolBasedRec();
        sclrec.hotelList = hotlList;
        sclrec.floorsuiteList = flrsuitList;
        
        return sclrec;
    }
    
    /**********************************************************************
        Created by Vinitha on Feb 14, 2017: Apex controller class for this FindPartnerSchool_Component
        to referred in ResourcesPageComponents, to Convert all force.query to Remote action on that component.                                         
    ***********************************************************************/
    
    @RemoteAction
    global static List<Contact> getUserRelatedContactdetail(){
        Id userId = UserInfo.getUserId();
        List<User> userList = [SELECT Id,Name,IsPortalEnabled,IsActive FROM User WHERE Id = :userId];   
        
        List<Contact> contactRec = new List<Contact>();
        
        if(userList != null && userList.size() > 0) {
            if(userList[0].IsPortalEnabled && userList[0].ContactId != null) {
                ContactRec = [SELECT Id,Name,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode FROM Contact WHERE Id = :userList[0].ContactId];
            }else {
                ContactRec = [SELECT Id,Name,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode FROM Contact WHERE DLS_User__c = :userList[0].Id];
            }
        } 
        
        system.debug('::::::::heap::size::::'+Limits.getHeapSize());
        
        return ContactRec;
    }
    
    //This remote action method take from librarycontentsearch controller.
    @RemoteAction
        global static string geoCodeFinder( string Street,String City, String State, String Country, String Zipcode) {        
            
            TimezoneUtilClass util = new TimezoneUtilClass();
            TimezoneUtilClass.location ll = new TimezoneUtilClass.location();
            system.debug(':street:::'+street);
            ll = util.geoCode(street,city,state,country,Zipcode);
            return JSON.Serialize(ll);
           // return ll;
        }
}