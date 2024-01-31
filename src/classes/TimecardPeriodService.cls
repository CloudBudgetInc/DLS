/**********************************************************************
        Created by Kuppulakshmi on Feb 15 2017: This method return list of AcctSeed__Time_Card_Period__c 
        @filterQry - pass where Condition
        @startdateset - pass set of start Date 
        @enddateset - pass set of end Date 
    ***********************************************************************/
    public Class TimecardPeriodService{
        public Static List<AcctSeed__Time_Card_Period__c> getTimeCardPeriodByDate(String filterQry,Set<Date> startdateset,Set<Date> enddateset) {
           
           List<AcctSeed__Time_Card_Period__c> timeCardPeriodList = new List<AcctSeed__Time_Card_Period__c>();
           
           String defaultquery = 'SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Period__c')+
                                   ' FROM AcctSeed__Time_Card_Period__c';
                                   
           if(startdateset != null && startdateset.size() > 0 && enddateset != null && enddateset.size() > 0 ){
              defaultquery += ' WHERE AcctSeed__Start_Date__c IN :startdateset AND AcctSeed__End_Date__c IN :enddateset'+ filterQry;
           } else {
              defaultquery += ' WHERE' + filterQry;
           }   
            
           System.debug('defaultquery::TimecardPeriodService:'+defaultquery);            
           timeCardPeriodList = Database.Query(defaultquery);
           
           
          return timeCardPeriodList;
       }
       
   }