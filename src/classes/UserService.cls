/**********************************************************************
    Created by Vinitha on Feb 13 2017: Service class used for User object
***********************************************************************/
public with sharing class UserService {
     
     /**********************************************************************
        Created by Vinitha on Feb 14 2017: This method return list of User 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of User records
    ***********************************************************************/  
    
    public Static List<User> getUserRec(String filterQrystr, String parentFields) {
    
        List<User> userList = new List<User>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('User');
        String defalutQry = 'SELECT '+ fieldName +' FROM User';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM User';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        system.debug('::userservice::getuserRec :::defalutQry'+defalutQry);
        userList = Database.query(defalutQry);        
        return userList;        
    
    }
    
    /**********************************************************************
        Created by Shalini on Feb 14 2017: This method returns list of User object records
        @names - Set of Names of User
        @conId - Set of Contact IDs
        @filterQrystr - Filter conditions
        @parentFields - parent fields to be queried
        return - List of User records 
    ***********************************************************************/
    
    public Static List<User> getUserRecByNameAndContactId(Set<String> names, Set<Id> conId, String filterQrystr, String parentFields) {
    
        List<User> userList = new List<User>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('User');
        String defaultQry = 'SELECT '+ fieldName +parentFields+' FROM User';
        
        if(filterQrystr != null && filterQrystr != ''){
            defaultQry += filterQrystr;           
        } 
        
        if(filterQrystr == '' && names != Null && names.size() > 0){
            defaultQry += ' WHERE Name IN :names';
        }else if(names != Null && names.size() > 0){
            defaultQry += ' AND Name IN :names';    
        }
        
        if(filterQrystr == '' && names.size() == 0 && conId != Null && conId.size() > 0){
            defaultQry += ' WHERE ContactId IN :conId';
        }else if(conId != Null && conId.size() > 0){
            defaultQry += ' AND ContactId IN :conId';
        }
        
        System.debug('::defaultQry:::'+defaultQry);
        userList = Database.query(defaultQry);
        return userList;        
    
    }
    
    /**********************************************************************
        Created by Vinitha on Aug 30 2017: This method return list of User 
        @firstnameSet - pass user firstname
        @middlenameSet - pass user middlename
        @lastnameSet - pass user lastname
        @parentFields - Pass parent field name
        return - list of User records
    ***********************************************************************/  
    
    public Static List<User> getInternalUserRecord(Set<String> firstnameSet,Set<String> midnameSet,Set<String> lastnameSet) {
    
        List<User> userList = new List<User>();
        String defalutQry;
        String fieldName = 'Id,FirstName,LastName,MiddleName,IsPortalEnabled';           
        if(!firstnameSet.isEmpty() && !midnameSet.isEmpty() && !lastnameSet.isEmpty()){
            defalutQry = 'SELECT '+fieldName+' FROM User WHERE (FirstName IN :firstnameSet OR LastName IN :lastnameSet OR MiddleName IN :midnameSet)  AND IsPortalEnabled = false';           
        } 
        system.debug('::userservice::getuserRec :::defalutQry'+defalutQry);
        userList = Database.query(defalutQry);        
        return userList;    
    
    }
    
    /**********************************************************************
        Created by Karthiga on Jan 23 2019: This method return list of User 
        @userId - logged in User Id/ any other User Id to get the limited info of User
        @userList - List of User records
        return - list of User records
    ***********************************************************************/ 
    public Static List<User> getLoggedInUserInfo(Id userId) {
        List<User> loggedUser = new List<User>();
        String fieldStr = 'Id,Name,ProfileId,Profile.Name';
        String defaultQry;
        if(userId != null) {
            defaultQry = 'SELECT ' + fieldStr + ' FROM User WHERE Id =\'' + userId + '\'';
        }
        System.debug('deafultQry::::'+defaultQry);
        loggedUser = Database.query(defaultQry);
        return loggedUser;
    }
     
    /**********************************************************************
        Created by Vinitha on Feb 13 2017: This method return list of User 
        @userList - List of User records
        return - list of User records
    ***********************************************************************/ 
    
    public static list<User> updateUser(list<User> userList) {
    
        if(userList != null && userList.size() > 0){
            update userList;            
        }
        return userList;    
    } 
}