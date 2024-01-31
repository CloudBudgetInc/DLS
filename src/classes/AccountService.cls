public with sharing class AccountService {

     /**********************************************************************
        Created by Kuppulakshmi on Feb 10 2017: This method return list of AcctseedAccountingperiod 
        @filterQry - pass where condition
        @limitQry - pass limit conditions
        return - list of Account records
    ***********************************************************************/ 
public static list<Account> getAccount(String filterQry,String limitQry){
    
        list<Account> accList =  new list<Account>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Account');
        String defalutQry = 'SELECT '+ fieldName +' FROM Account';
        
        if(filterQry != null && filterQry != ''){            
            defalutQry = defalutQry + filterQry ;          
        } 
        if(limitQry != null && limitQry != '')
        {
            defalutQry = defalutQry + limitQry ;
        }
        
        System.debug('::defalutQry:::'+defalutQry);
        accList =  Database.query(defalutQry);   
        return accList;
    }
}