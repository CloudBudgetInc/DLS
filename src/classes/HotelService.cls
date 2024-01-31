/**********************************************************************
    Created by Vinitha on Jan 11 2017: Service class used for Hotel__c object
***********************************************************************/
public with sharing class HotelService {    
     
    /**********************************************************************
        Created by Vinitha on Jan 11 2017: This method return list of hotel 
        @fltrqryStr - pass where Condition
        return - list of hotel records
    ***********************************************************************/    
    
    public Static List<Hotel__c> getHotels(String fltrqryStr,String parentField,Set<Id> parentId) {
    
        List<Hotel__c> hotelList = new List<Hotel__c>();        
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Hotel__c');
        String defaultQry = 'SELECT ' +fieldName+ parentField+ ' FROM Hotel__c';                              
                            
        if(fltrqryStr != null && fltrqryStr != '' && parentId != null && parentId.size() > 0){
            defaultQry = defaultQry + fltrqryStr + 'IN :parentId';            
        }else if(fltrqryStr != null && fltrqryStr != ''){
            defaultQry += fltrqryStr;
        }else{
            defaultQry += ' Limit 25';                      
        }
        hotelList = Database.query(defaultQry);
        return hotelList;
    }
    
}