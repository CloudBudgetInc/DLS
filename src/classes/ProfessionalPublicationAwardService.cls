/**********************************************************************
    Created by Siva Prasanth K.T on Jul 8 2021: Service class used for Professional_Publication_and_Award__c object
***********************************************************************/
public class ProfessionalPublicationAwardService {
    /**********************************************************************
        Created by Siva Prasanth K.T on Jul 8 2021: This method return list of Professional_Publication_and_Award__c 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of knownLanguage records
    ***********************************************************************/  
    
    public Static List<Professional_Publication_and_Award__c> getProfPublicationAwards(String filterQrystr, String parentFields) {
    
        List<Professional_Publication_and_Award__c> ppaList = new List<Professional_Publication_and_Award__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Professional_Publication_and_Award__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Professional_Publication_and_Award__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Professional_Publication_and_Award__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        ppaList = Database.query(defalutQry);        
        return ppaList;        
    
    }
}