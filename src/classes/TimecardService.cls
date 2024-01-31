/**********************************************************************
        Created by Kuppulakshmi on Feb 15 2017: This method return list of AcctSeed__Time_Card_Period__c 
        @filterQry - pass where Condition
        @conId - pass set of contactId
        @timecardIdset - pass set of timecardid
    ***********************************************************************/
    public Class TimecardService{
        public Static List<AcctSeed__Time_Card__c> getTimeCardByDate(String filterQry,Set<Id> conId,Set<Id> timecardIdset,String ParentField) {
           
           List<AcctSeed__Time_Card__c> timeCardList = new List<AcctSeed__Time_Card__c>();
           
           String defaultquery = 'SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card__c')+ParentField+
                                   ' FROM AcctSeed__Time_Card__c';
                                   
           if(filterQry != NULL && filterQry != ''){
              defaultquery += filterQry;
           } 
           if(timecardIdset != NULL && timecardIdset.size()>0){
               defaultquery += ' IN :timecardIdset';
           }
           if(conId != NULL && conId.size()>0){
               defaultquery += ' AND Intructor__c IN :conId';
           }
             
            
           System.debug('defaultquery:::'+defaultquery);            
           timeCardList = Database.Query(defaultquery);
          return timeCardList;
        }
    }