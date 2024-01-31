/**********************************************************************
    Created by Vinitha on Feb 15, 2017: Apex controller class for this FindPartnerSchoolSite_Component
    to referred in ResourcesPageComponents, to Convert all force.query to Remote action on that component. 
***********************************************************************/

global class FindPartnerSchoolSite_Compo_Ctrl{
    
    global class SchoolsiteRec{
        public List<Country__c> countryList;
        public List<MTT_Location__c> mttLocationList;
        public List<MTT_Location__c> partnerLocations;
        public List<MTT_Location__c> clientLocations;
    }
    
    /**********************************************************************
    Created by Vinitha on Feb 15, 2017: Apex controller class for this FindPartnerSchoolSite_Component
    to referred in ResourcesPageComponents, to Convert all force.query to Remote action on that component.                                         
    ***********************************************************************/
    @RemoteAction
    global static SchoolsiteRec getSchoolsiteRec(){
    
        List<Country__c> ctylist = CountryService.getCountryRec(' WHERE Sub_Continent_Name__c != NULL AND Country_Name__c != NULL','');
        List<MTT_Location__c> mttlocList = MTTLocationService.getMTTlocationRectype(' WHERE Location_GeoCode__latitude__s != Null AND RecordType.DeveloperName = \'DLS_Site\'',',Recordtype.DeveloperName');
        List<MTT_Location__c> partnerSites = MTTLocationService.getMTTlocationRectype(' WHERE Location_GeoCode__latitude__s != Null AND RecordType.DeveloperName = \'Partner_Site\'',',Recordtype.DeveloperName');
        List<MTT_Location__c> clientSites = MTTLocationService.getMTTlocationRectype(' WHERE Location_GeoCode__latitude__s != Null AND RecordType.DeveloperName = \'Client_Site\'',',Recordtype.DeveloperName');
        
        SchoolsiteRec sclrec = new SchoolsiteRec();
        sclrec.countryList = ctylist;
        sclrec.mttLocationList = mttlocList;
        sclrec.partnerLocations = partnerSites;
        sclrec.clientLocations = clientSites;
        
        return sclrec;
    }
    
}