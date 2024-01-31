/**********************************************************************
    Created by Vinitha on Feb 4 2017: Service class used for Test_Score__c object
***********************************************************************/
public with sharing class TestScoreService {
    
     /**********************************************************************
        Created by Vinitha on Feb 4 2017: This method return list of TestScore 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of TestScore records
    ***********************************************************************/  
    
    public Static List<Test_Score__c> getTestscore(String filterQrystr, String parentFields) {
    
        List<Test_Score__c> knownLangList = new List<Test_Score__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Test_Score__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Test_Score__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Test_Score__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        knownLangList = Database.query(defalutQry);        
        return knownLangList;        
    
    }
}