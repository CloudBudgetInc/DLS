/**********************************************************************
    Created by Sukanya on Jan 12, 2017: Service class used for Time Card Day object
***********************************************************************/
public Class TimeCardDayService{
    /**********************************************************************
        Created by Sukanya on Jan 12 2017: This method return list of Time Card Day
        @filterQry - filter qry with all where conditions
        @parentIdString - parent field values
        return - list of Time Card Day records
    ***********************************************************************/
    public Static List<AcctSeed__Time_Card_Day__c> getDayWithPro_Task_Ins_Datefilters(String filterConditions,String parentFieldsString,Date startDate,Date endDate) {
        
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = new List<AcctSeed__Time_Card_Day__c>();
        String qryString = '';
        
        system.debug('::::::startDate:::::::::'+startDate);
        system.debug('::::::endDate:::::::::'+endDate);
        
       
        system.debug('::::::startDate:::::::::'+ String.valueOf(startDate).split(' ')[0]);
        system.debug('::::::endDate:::::::::'+ String.valueOf(endDate).split(' ')[0]);
        
        
        if(filterConditions != null && filterConditions != '' && parentFieldsString != null && parentFieldsString != '') {
            if(startDate == null && endDate == null) {
                qryString = 'SELECT '+
                                SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c') +parentFieldsString+
                                ', ('+ 
                                    'SELECT Id,Time_Card_Day__c,createdDate,Date__c,Hours__c,Internal_Comment__c,Total_Hours_Before_Approved__c,Reference_Id__c,TCD_Status__c,TCD_New_Status__c,Time_Card_Day__r.Total_Hours_Before_Approved__c'+ 
                                       ' FROM Accounting_Seed_Time_Snapshots__r)'+
                                ' FROM'+
                                ' AcctSeed__Time_Card_Day__c'+filterConditions;
                                
            }else if(startDate != null && endDate != null) {
                
                 String stDate = String.valueOf(startDate).split(' ')[0];
                 String edDate = String.valueOf(endDate).split(' ')[0]; 
                
                qryString = 'SELECT '+
                                SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c') +parentFieldsString+
                                ', ('+ 
                                    'SELECT Id,Time_Card_Day__c,createdDate,Date__c,Hours__c,Internal_Comment__c,Total_Hours_Before_Approved__c,Reference_Id__c,TCD_Status__c,TCD_New_Status__c,Time_Card_Day__r.Total_Hours_Before_Approved__c'+ 
                                       ' FROM Accounting_Seed_Time_Snapshots__r)'+
                                ' FROM'+
                                ' AcctSeed__Time_Card_Day__c'+' WHERE AcctSeed__Date__c >= '+stDate+' AND AcctSeed__Date__c <= '+edDate+filterConditions;
            }
            
            System.debug('qryString:::'+qryString);             
            timeCardDayList = Database.Query(qryString);
       }
       
       return timeCardDayList;
        
    }
    
    /**********************************************************************
        Created by Sukanya on Jan 12 2017: This method return list of Time Card Day
        @timeCardLineIdSet - set of time card line Ids
        @startDate - start date 
        return - list of Time Card Day records
    ***********************************************************************/
    
   public Static List<AcctSeed__Time_Card_Day__c> getDayWithDate_timeLinefilter(Set<Id> timeCardLineIdSet,Date startDate,Date endDate) {
       
       List<AcctSeed__Time_Card_Day__c> timeCardDayList = new List<AcctSeed__Time_Card_Day__c>();
       
        if(timeCardLineIdSet != null && timeCardLineIdSet.size() > 0 
                && startDate != null && endDate != null
          ) {
              
          String stDate = String.valueOf(startDate).split(' ')[0];
          String edDate = String.valueOf(endDate).split(' ')[0]; 
            
            String qryString = 'SELECT '+
                            SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c') +
                            ', ('+ 
                                'SELECT Id,Time_Card_Day__c,createdDate,Date__c,Hours__c,Internal_Comment__c,Total_Hours_Before_Approved__c,TCD_Status__c,TCD_New_Status__c,Invoice_Comment__c,'+ 
                                       'Time_Card_Line__c,Time_Card_Line__r.AcctSeed__Project_Task__c,End_Time1__c,End_Time2__c,Start_Time1__c,Start_Time2__c,Late_Cancellation__c,'+
                                       'Time_Card_Line__r.AcctSeed__Project_Task__r.Name,Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,Notes__c,Note_Type__c,Time_Card_Line__r.AcctSeed__Time_Card__c,'+
                                       'Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c,Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.DLS_Class__c,'+
                                       'Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,Reference_Id__c,Time_Card_Day__r.Total_Hours_Before_Approved__c,CreatedBy.Name'+
                                   ' FROM Accounting_Seed_Time_Snapshots__r ORDER BY CreatedDate DESC)'+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Day__c'+
                            ' WHERE AcctSeed__Date__c >= '+stDate+' AND AcctSeed__Date__c <= '+edDate+' AND AcctSeed__Time_Card_Line__c IN :timeCardLineIdSet ORDER BY AcctSeed__Date__c ASC';
            
            System.debug('qryString:::'+qryString);             
            timeCardDayList = Database.Query(qryString);
       }
       
       return timeCardDayList;
       
   }
   
   /**********************************************************************
        Created by Sukanya on Jan 18 2017: This method return list of Time Card Day - only qry time car days
        @filterQry - filter qry with all where conditions
        @parentIdString - parent field values
        return - list of Time Card Day records
    ***********************************************************************/
    public Static List<AcctSeed__Time_Card_Day__c> getDayWithParentFilterConditions(String filterConditions,String parentFieldsString,String parentConditionName,Set<Id> parentIdSet) {
        
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = new List<AcctSeed__Time_Card_Day__c>();
        String qryString = '';
        
        system.debug(':::::::::filterConditions:::::'+filterConditions);
        system.debug(':::::::::parentFieldsString:::::'+parentFieldsString);
        
        if(filterConditions != null && filterConditions != '' && parentFieldsString != null && parentFieldsString != '') {
            qryString = 'SELECT '+
                            SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c') +parentFieldsString+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Day__c'+filterConditions;
        }
        
        if(parentConditionName != null && parentConditionName != '' && parentIdSet != null && parentIdSet.size() > 0) {
            qryString += parentConditionName + ' parentIdSet ' + 'ORDER BY AcctSeed__Date__c ASC';
        }
            
        System.debug('qryString:::'+qryString);             
        timeCardDayList = Database.Query(qryString);
        
       return timeCardDayList;
    }
    
    /**********************************************************************
        Created by Sukanya on August 18 2017: This method return list of Time Card Day - only qry time car days
        @filterQry - filter qry with all where conditions
        @parentIdString - parent field values
        @startdate 
        @enddate
        return - list of Time Card Day records
    ***********************************************************************/
    public Static List<AcctSeed__Time_Card_Day__c> getTimeCardDayRecords_Withfilters(String filterConditions,String parentFieldsString,Date startDate,Date endDate,Set<Id> projectId) {
        
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = new List<AcctSeed__Time_Card_Day__c>();
        String qryString = '';
        
        system.debug(':::::::::filterConditions:::::'+filterConditions);
        system.debug(':::::::::parentFieldsString:::::'+parentFieldsString);
        
        if(startDate != null && endDate != null && projectId != null && projectId.size() > 0) {
           String stDate = String.valueOf(startDate).split(' ')[0];
           String edDate = String.valueOf(endDate).split(' ')[0]; 
           
            qryString = 'SELECT '+
                            SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c') +parentFieldsString+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Day__c WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c IN :projectId AND AcctSeed__Date__c >= '+stDate+' AND AcctSeed__Date__c <= '+edDate+filterConditions;
        }else if(startDate != null && endDate != null) {
            
           String stDate = String.valueOf(startDate).split(' ')[0];
           String edDate = String.valueOf(endDate).split(' ')[0]; 
           
            qryString = 'SELECT '+
                            SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c') +parentFieldsString+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Day__c WHERE AcctSeed__Date__c >= '+stDate+' AND AcctSeed__Date__c <= '+edDate+filterConditions;
            
        }
            
        System.debug('::::getTimeDayRecords_Withfilters::::qryString:::'+qryString);             
        timeCardDayList = Database.Query(qryString);
        
       return timeCardDayList;
    }
    
     /**********************************************************************
        Created by Sukanya on Jan 23 2017: This method return list of Time Card Day after updation
        @UpdationList - list of time card days for updation
    ***********************************************************************/
     public Static List<AcctSeed__Time_Card_Day__c> updateTimecardDays(List<AcctSeed__Time_Card_Day__c> UpdationList) {
        
        if(UpdationList != null && UpdationList.size() > 0) {
            Update UpdationList;
            return UpdationList;
        }
        return null;
    }
    
    /**********************************************************************
        Created by Sukanya on March 15 2017: This method return list of Time Card Day after insert
        @UpdationList - list of time card days for insert
    ***********************************************************************/
     public Static List<AcctSeed__Time_Card_Day__c> insertTimecardDays(List<AcctSeed__Time_Card_Day__c> insertionList) {
        
        if(insertionList != null && insertionList.size() > 0) {
            insert insertionList;
            return insertionList;
        }
        return null;
    }
    
     public Static List<AcctSeed__Time_Card_Day__c> getAllTCD() {
         return database.query('SELECT Id,Name FROM AcctSeed__Time_Card_Day__c');
     }   
}