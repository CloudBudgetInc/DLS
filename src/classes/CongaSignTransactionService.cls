/**********************************************************************
    Created by Dhinesh on April 01, 2022: Service class used for Conga Transaction
***********************************************************************/
public class CongaSignTransactionService {

        /**********************************************************************
        Created by Dhinesh on April 01, 2022: 
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of Conga Transaction.
        ***********************************************************************/ 
        public Static List<APXT_CongaSign__Transaction__c> getCongaSignTransactions(String filterQuery , String parentFields) {
            
            List<APXT_CongaSign__Transaction__c> conSignTransList = new List<APXT_CongaSign__Transaction__c>();
            String qryStr = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('APXT_CongaSign__Transaction__c')+
                                  	  (String.isNotBlank(parentFields) ? parentFields : '')+                                      
                                      ' FROM APXT_CongaSign__Transaction__c';
                                        
            if(filterQuery != '') {
                 qryStr += ' WHERE '+filterQuery;
            }
            
            conSignTransList = database.query(qryStr );                           
            return conSignTransList;    
        }
}