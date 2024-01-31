/**********************************************************************
    Created by Vinitha on Feb 14 2017: Service class used for Room__c object
***********************************************************************/
public with sharing class RoomService {
    
     /**********************************************************************
        Created by Vinitha on Feb 14 2017: This method return list of Room
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of Room records
    ***********************************************************************/  
    
    public Static List<Room__c> getRoomRec(String filterQrystr, String parentFields) {
    
        List<Room__c> roomList = new List<Room__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Room__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Room__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Room__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        }
        System.debug('RoomService:::::::::getRoomRec:::::::::'+defalutQry); 
        roomList = Database.query(defalutQry);        
        return roomList;        
    
    }
    
    /**********************************************************************
        Created by Shalini on Feb 17 2017: This method return list of Room
        @fltrqryStr - pass where Conditions
        @idSet - set of Ids
        @nameSet - set of Names
        @parentFields - Pass parent field name
        return - list of Room records
    ***********************************************************************/ 
    
    public Static List<Room__c> getRoomRecByIdAndName(String filterQrystr, Set<Id> idSet, Set<String> nameSet, String parentFields,String limitQry) {
    
        List<Room__c> roomList = new List<Room__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Room__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Room__c';
        
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Room__c';
        }
        
        if(filterQrystr != null && filterQrystr != '' && idSet != Null && idSet.size() > 0){
            defalutQry = defalutQry + filterQrystr + ' IN :idSet'+limitQry;           
        }
        
        if(filterQrystr != null && filterQrystr != '' && nameSet != Null && nameSet.size() > 0){
            defalutQry = defalutQry + filterQrystr + ' IN :nameSet'+limitQry;           
        }
        
        System.debug('RoomService:::::::::ByIdAndName:::::::::'+defalutQry); 
        roomList = Database.query(defalutQry);        
        return roomList;        
    
    }
}