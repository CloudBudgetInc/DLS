/**********************************************************************
    Created by Vinitha on Jan 20 2017: Service class used for Request__c object
***********************************************************************/
public class RequestService {
    
     /**********************************************************************
        Created by Vinitha on Jan 20 2017: This method return list of Request 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of Request records
    ***********************************************************************/  
    
    public Static List<Request__c> getRequest(String filterQrystr, String parentFields) {
    
        List<Request__c> requestList = new List<Request__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Request__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Request__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Request__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        System.debug('RequestService::getRequest:defalutQry'+defalutQry);
        requestList = Database.query(defalutQry);        
        return requestList;        
    
    }
    
     /**********************************************************************
        Created by Vinitha on Jan 20 2017: This method return  list of Request 
        @contentVersionId - Set of Request records ids
        return - list of Request records
    ***********************************************************************/ 
    
    public static list<AggregateResult> getAggregatelist(Set<Id> contentVersionId){
        
        list<AggregateResult> aggregateList = new list<AggregateResult>();
        if(contentVersionId != null ){
            aggregateList = [
                    SELECT 
                        count(Id) 
                    FROM 
                        Request__c 
                    WHERE 
                        ContentVersionId__c IN :contentVersionId
                    ];
        }
        return aggregateList; 
        
    }
    
    
    
     /**********************************************************************
        Created by Vinitha on Jan 20 2017: This method return newly created list of Request 
        @requestList - List of Request records
        return - list of Request records
    ***********************************************************************/ 
    public static list<Request__c> insertRequest(List<Request__c> requestList) {
    
        if(requestList != null && requestList.size() > 0){
            insert requestList;            
        }
        System.debug('RequestService:insertRequest:requestList'+requestList);
        return requestList;    
    } 
    
      /**********************************************************************
        Created by Vinitha on Jan 20 2017: This method return list of Request 
        @requestList - List of Request records
        return - list of Request records
    ***********************************************************************/ 
    public static list<Request__c> updateRequest(List<Request__c> requestList) {
    
        if(requestList != null && requestList.size() > 0){
            update requestList;            
        }
        System.debug('RequestService:updateRequest:requestList'+requestList);
        return requestList;    
    } 
}