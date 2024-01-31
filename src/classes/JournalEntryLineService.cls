/**********************************************************************
    Created by Siva Prasanth KT on Mar 03, 2020  Service class used for Journal Entry Line object 
***********************************************************************/
public Class JournalEntryLineService{
    
   /**********************************************************************
    Created by Siva Prasanth on Mar 3, 2020 : Service Method using  
    @filterQry- Filter query String
    @parentFields- Parent Fields String.
    @projectIdIdSet- Set of Parent Id's 
    Returns - List of JournalEntryLine.     
   ***********************************************************************/
    public Static List<AcctSeed__Journal_Entry_Line__c> getJELByParentIds(String filterQry,String parentFields,Set<Id> parentIdSet) {
        
        List<AcctSeed__Journal_Entry_Line__c> journalEntryLineList= new List<AcctSeed__Journal_Entry_Line__c>();
        String qryString = '';
        
        qryString = 'SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Journal_Entry_Line__c')+
                     parentFields+' FROM AcctSeed__Journal_Entry_Line__c';
        
        if(filterQry != null && filterQry != '' && parentIdSet!= null && parentIdSet.size() > 0){
            qryString += filterQry+' IN :parentIdSet';
        }else if(filterQry != null && filterQry != ''){
            qryString += filterQry;
        }
        
        System.debug('qryString:::'+qryString);             
        journalEntryLineList= Database.Query(qryString);
        
        return journalEntryLineList;
    }
}