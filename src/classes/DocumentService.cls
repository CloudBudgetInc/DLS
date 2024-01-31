/**********************************************************************
    Created by Vinitha on Feb 16 2017: Service class used for Document object
***********************************************************************/
public with sharing class DocumentService {
    
     /**********************************************************************
        Created by Vinitha on Feb 16 2017: This method return list of Document
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of Document records
    ***********************************************************************/  
    
    public Static List<Document> getDocumentRec(String filterQrystr, String parentFields) {
    
        List<Document> documentList = new List<Document>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Document');
        String defalutQry = 'SELECT '+ fieldName +' FROM Document';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Document';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        system.debug('defalutQry'+defalutQry);
        documentList = Database.query(defalutQry);        
        return documentList;        
    
    }
   
}