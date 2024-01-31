/**********************************************************************
    Created by Vinitha on Feb 3 2017: Service class used for Case object,
    This class also include CaseComment Object 
***********************************************************************/
public with sharing class CaseService {
     
      /**********************************************************************
        Created by Vinitha on Feb 24 2017: This method return list of Case
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        @limityQry - pass limit query
        return - list of Case records
    ***********************************************************************/  
    
    public Static List<CaseComment> getCasecommentRec(String filterQrystr, String parentFields,String limitQry) {
    
        List<CaseComment> caseList = new List<CaseComment>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('CaseComment');
        String defalutQry = 'SELECT '+ fieldName + parentFields +' FROM CaseComment';        
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr + limitQry;           
        }
        System.debug('CaseService:::::::::getCaseRec:::::::::'+defalutQry); 
        caseList = Database.query(defalutQry);        
        return caseList;        
    
    }
    
    /**********************************************************************
        Created by Vinitha on Feb 24 2017: This method return list of Case
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        @limityQry - pass limit query
        return - list of Case records
    ***********************************************************************/  
    
    public Static List<Case> getCaseRec(String filterQrystr, String parentFields,String limitQry) {
    
        List<Case> caseList = new List<Case>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Case');
        String defalutQry = 'SELECT '+ fieldName + parentFields +' FROM Case';        
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr + limitQry;           
        }
        System.debug('CaseService:::::::::getCaseRec:::::::::'+defalutQry); 
        caseList = Database.query(defalutQry);        
        return caseList;        
    
    }
     
     /**********************************************************************
        Created by Vinitha on Feb 3 2017: This method return list of Case 
        @knownList - List of case records
        return - list of Case records
    ***********************************************************************/ 
    public static list<Case> insertCase(list<Case> caseList) {
    
        if(caseList != null && caseList.size() > 0){
            insert caseList;            
        }
        return caseList;    
    }

}