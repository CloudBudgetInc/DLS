/**********************************************************************
    Created by Vinitha on Jan 12 2017: Service class used for MTT_Location__c object
***********************************************************************/
public with sharing class MTTLocationService {    
     
    /**********************************************************************
        Created by Vinitha on Jan 12 2017: This method return list of MTTLocation         
        @filterQry - pass Limit
        return - list of MTTLocation records
    ***********************************************************************/    
    
    public Static List<MTT_Location__c> getMTTloaction(String filterQry) {
    
        List<MTT_Location__c> locationList = new List<MTT_Location__c>();        
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('MTT_Location__c');
        String defaultQry = 'SELECT ' +fieldName+ ' FROM MTT_Location__c ORDER BY Name ASC';
        if(filterQry != null && filterQry !=''){
            defaultQry = defaultQry + filterQry;
        }
        locationList = Database.query(defaultQry);
        return locationList;
    }
     /**********************************************************************
        Created by Vinitha on Jan 10 2017: This method return list of MTTLocation 
        @fltrqryStr - pass where Conditions
        return - list of MTTLocation records
    ***********************************************************************/  
    
    public Static List<MTT_Location__c> getMTTlocationRectype(String filterQrystr,String parentField) {
        
        List<MTT_Location__c> locationList = new List<MTT_Location__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('MTT_Location__c');
        String defalutQry = 'SELECT '+ fieldName + parentField +' FROM MTT_Location__c';
        
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        system.debug(':defalutQry::'+defalutQry);        
        system.debug(':filterQrystr::'+filterQrystr);
        
        locationList = Database.query(defalutQry);
        
        return locationList;        
    
    }
     /**********************************************************************
        Created by Vinitha on Jan 12 2017: This method return list of MTTLocation 
        @rectypeName1 - String of RecordType records
        @rectypeName2 - String of RecordType records
        @locationName - String of LocationName records
        return - list of MTTLocation records
    ***********************************************************************/    
    /*public static list<MTT_Location__c> getMTTlocationRectype(String rectypeName1 , String rectypeName2, String locationName) {
        
        List<MTT_Location__c> locationList = new List<MTT_Location__c>();
        if(rectypeName1 != null && rectypeName2 != null){
            locationList = [
                    SELECT
                        Id,
                        Name
                    FROM
                        MTT_Location__c
                    WHERE
                        RecordType.DeveloperName = :rectypeName1
                    OR
                        RecordType.DeveloperName = :rectypeName2
                    ];   
        } else if (locationName != null && locationName != ''){
            locationList = [
                        SELECT
                            Id,
                            Name,
                            CITY_AND_STATE__C,
                            Wifi_Password__c
                        FROM
                            MTT_Location__c
                        WHERE
                            Name = :locationName
                        LIMIT 1 ];
        }
        return locationList;        
        
    }*/
}