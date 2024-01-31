/**********************************************************************
    Created by Sukanya on Jan 12, 2017: Service class used for Time Card Line object
***********************************************************************/
public Class TimeCardLineService{

    
    public static String fieldStr = 'of_Approved_Hours__c,of_Pending_Time_Logs__c,of_Rejected_Hours__c,of_Submitted_Hours__c,'+
                                        'ApprovedTime__c,AcctSeed__Billable__c,AcctSeed__Billed__c,Approved_By__c,AcctSeed__Day_Count__c,'+
                                        'Contact_Assignment__c,Display_in_Future_Weeks__c,Location__c,AcctSeed__Overtime__c,AcctSeed__Parent_Status__c,'+
                                        'Payroll_Item__c,AcctSeed__Project__c,AcctSeed__Project_Task__c,Sequence_Number__c,Status__c,AcctSeed__Time_Card__c,'+
                                        'AcctSeed__Time_Card_Variable_1__c,AcctSeed__Time_Card_Variable_2__c,AcctSeed__Total_Hours__c,Labor_Cost_Rate__c,Completed__c';
    
    /**********************************************************************
        Created by Sukanya on Jan 12 2017: This method return list of Time Card Line
        @startDate - start date for time card day date
        @endDate - end date for time card day date
        @timeCardlineId - list of time card line records Ids
        return - list of Time Card Line records
    ***********************************************************************/
    public Static List<AcctSeed__Time_Card_Line__c> getLineWithCardday(Date startDate,Date endDate,Set<Id> timeCardlineId,String filterCondition) {
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        
        if(timeCardlineId != null && timeCardlineId.size() > 0 && startDate != null && endDate != null) {
            
            String stDate = String.valueOf(startDate).split(' ')[0];
            String edDate = String.valueOf(endDate).split(' ')[0]; 
            
            String qryString = 'SELECT Id,Name,'+fieldStr+
                            
                            ',AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.Name,'+
                            'AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName,'+
                            'AcctSeed__Project_Task__r.Rate__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId,AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,'+
                            'Location__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c,Labor_Cost_Rate__r.Rate_Type__c,('+ 
                            
                                'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c')+
                                    ' FROM AcctSeed__Time_Card_Days__r'+
                                    ' WHERE AcctSeed__Date__c >= '+stDate+' AND AcctSeed__Date__c <= '+edDate+filterCondition+')'+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Line__c WHERE Id IN :timeCardlineId';
            
            System.debug('qryString:::'+qryString);             
            timeCardLineList = Database.Query(qryString);
       }else if(timeCardlineId != null && timeCardlineId.size() > 0) {
           String qryString = 'SELECT Id,Name,'+fieldStr+
                            
                            ',AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.Name,'+
                            'AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName,'+
                            'AcctSeed__Project_Task__r.Rate__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId,AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,'+
                            'Location__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c,Labor_Cost_Rate__r.Rate_Type__c,('+ 
                            
                                'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c')+
                                    ' FROM AcctSeed__Time_Card_Days__r'+
                                    ' WHERE Status__c = \'Submitted\' ORDER BY AcctSeed__Date__c ASC)'+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Line__c WHERE Id IN :timeCardlineId';
            
            System.debug('qryString:::'+qryString);             
            timeCardLineList = Database.Query(qryString);
       }else if(startDate != null && endDate != null) {
       
           String stDate = String.valueOf(startDate).split(' ')[0];
            String edDate = String.valueOf(endDate).split(' ')[0]; 
            
            String qryString = 'SELECT Id,Name,'+fieldStr+
                            ',AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.Name,'+
                            'AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName,'+
                            'AcctSeed__Project_Task__r.Rate__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId,AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,'+
                            'Location__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c,Labor_Cost_Rate__r.Rate_Type__c,('+ 
                            
                                'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c')+
                                    ' FROM AcctSeed__Time_Card_Days__r'+
                                    ' WHERE AcctSeed__Date__c >= '+stDate+' AND AcctSeed__Date__c <= '+edDate+filterCondition+')'+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Line__c';
            
            System.debug('qryString:::'+qryString);             
            timeCardLineList = Database.Query(qryString);
       }
       
       return timeCardLineList;
        
    }
    
    /**********************************************************************
        Created by Sukanya on Jan 12 2017: This method return list of Time Card Line
        @InstructorIdSet - Id Set of contact used in time card instructor
        @ProjectTaskIdSet - Id Set of Project Task used in time card line Project Task field
        return - list of Time Card Line records
    ***********************************************************************/
    public Static List<AcctSeed__Time_Card_Line__c> getLineByInstructor(Set<Id> InstructorIdSet,Set<Id> ProjectTaskIdSet,String ParentField) {
       
       List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
       
       if(InstructorIdSet != null && InstructorIdSet.size() > 0 && ProjectTaskIdSet != null && ProjectTaskIdSet.size() > 0) {
            
            String qryString = 'SELECT Id,Name,'+fieldStr+ParentField+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Line__c'+
                            ' WHERE AcctSeed__Time_Card__r.Intructor__c IN :InstructorIdSet AND AcctSeed__Project_Task__c IN :ProjectTaskIdSet';
            
            System.debug('qryString:::'+qryString);             
            timeCardLineList = Database.Query(qryString);
            
       }else if(ProjectTaskIdSet != null && ProjectTaskIdSet.size() > 0) {
           
           String qryString = 'SELECT Id,Name,'+fieldStr+ParentField+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Line__c'+
                            ' WHERE AcctSeed__Project_Task__c IN :ProjectTaskIdSet';
            
            System.debug('qryString:::'+qryString);             
            timeCardLineList = Database.Query(qryString);
       }
       return timeCardLineList;
   }
   
    /**********************************************************************
        Created by Kuppulakshmi on Feb 24: This method return list of Time Card Line
        @timeCardlineId - Id Set of timecardline 
        return - list of Time Card Line records
    ***********************************************************************/
   
    /*public Static List<AcctSeed__Time_Card_Line__c> getLineWithCardbyParentId(String filterCondition,Set<Id> timeCardlineId,String Parentfield) {
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        String defaulttimecardline = 'SELECT Id,Name,'+fieldStr+Parentfield+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Line__c ';
        if(timeCardlineId != NULL && timeCardlineId.size()>0){
            defaulttimecardline += filterCondition+' IN :timeCardlineId';
        }
        system.debug(':::defaulttimecardline:::'+defaulttimecardline);
        timeCardLineList = Database.Query(defaulttimecardline);
        return timeCardLineList;
    } commented by Shalini because this method didn't refer in anywhere*/
    
     /**********************************************************************
        Created by Sukanya on March 16 2017: This method return list of Time Card Line
        
        return - list of Time Card Line records
    ***********************************************************************/
    public Static List<AcctSeed__Time_Card_Line__c> getLineRec_DayRecExist(Date startDate,Date endDate,String contactId) {
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        
        String lineQry = '';
        
        if(startDate != null && endDate != null && contactId != null && contactId != '') {
            
            String stDate = String.valueOf(startDate).split(' ')[0];
            String edDate = String.valueOf(endDate).split(' ')[0]; 
            
            lineQry = 'SELECT Id,Name FROM AcctSeed__Time_Card_Line__c '+
                       'WHERE AcctSeed__Time_Card__r.Intructor__c = \''+contactId+'\' AND Id IN (SELECT AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c WHERE AcctSeed__Date__c >= '+stDate+' AND AcctSeed__Date__c <= '+edDate+')';
            
        }else {
            lineQry = 'SELECT Id,Name FROM AcctSeed__Time_Card_Line__c WHERE Id IN (SELECT AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c WHERE Status__c != \'Unposted\' AND Status__c != \'Admin Approved\')';
        }
        
        
        system.debug(':::getLineRec_DayRecExist:::'+lineQry);
        
        timeCardLineList = Database.Query(lineQry);
        return timeCardLineList;
    }
    
    /**********************************************************************
        Created by Sukanya on April 6 2017: This method return list of Time Card Line with time card
        @filterQry - where conditions
        @parentFields - parent fields
        return - list of Time Card Line records
    ***********************************************************************/
    /*public Static List<AcctSeed__Time_Card_Line__c> getLineWithCardRecords(String filterQry,String parentFileds) {
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        
        String lineQry = 'SELECT Id,Name,'+fieldStr;
                            
        if(parentFileds != null && parentFileds != '')
            lineQry += ','+parentFileds+' FROM AcctSeed__Time_Card_Line__c';
            
            
        if(filterQry != null && filterQry != '')
            lineQry += filterQry;
        
        system.debug(':::getLineWithCardRecords:::'+lineQry);
        
        timeCardLineList = Database.Query(lineQry);
        return timeCardLineList;
    } commented by Shalini because this method didn't refer in anywhere*/
    
    /**********************************************************************
        Created by Sukanya on April 7 2017: This method return list of Time Card Line with time card day
        @filterCondition - where conditions
        @timeCardlineId - time card line Ids
        return - list of Time Card Line records
    ***********************************************************************/
    public Static List<AcctSeed__Time_Card_Line__c> getLineWithDayRecords(String filterCondition) {
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        
        
        if(filterCondition != null && filterCondition != '') {
           String qryString = 'SELECT Id,Name,'+fieldStr+
                            ',AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.Name,'+
                            'AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Name,'+
                            'AcctSeed__Project_Task__r.Rate__c,AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c,'+
                            'Location__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c,Labor_Cost_Rate__r.Rate_Type__c,('+ 
                            
                                'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c')+
                                    ' FROM AcctSeed__Time_Card_Days__r'+
                                    ' ORDER BY AcctSeed__Date__c ASC)'+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Line__c '+filterCondition;
            
            System.debug('qryString:::'+qryString);             
            timeCardLineList = Database.Query(qryString);
       }
        return timeCardLineList;
    }
    
     /**********************************************************************
        Created by Sukanya on April 21 2017: This method return list of Time Card Line with time card day
        @filterCondition - where conditions
        @Start date - end date for time card day 
        @End date - end date for time card day
        @projectIds - project id set
        @contactId - id of the contact
        return - list of Time Card Line records
    ***********************************************************************/
    public Static List<AcctSeed__Time_Card_Line__c> getTimeCardLine_dayRecords(String filterCondition,Set<Id> projectId,Date startDate,Date endDate,Id contactId) {
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        
        if(projectId != null && projectId.size() > 0 && startDate != null && endDate != null && contactId != null) {
            
            String stDate = String.valueOf(startDate).split(' ')[0];
            String edDate = String.valueOf(endDate).split(' ')[0]; 
            
            String qryString = 'SELECT Id,Name,'+fieldStr+
                            ',AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.Name,'+
                            'AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName,'+
                            'AcctSeed__Project_Task__r.Rate__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,AcctSeed__Project_Task__r.AcctSeed__Project__r.DLS_Class__c,'+
                            'Location__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c,Labor_Cost_Rate__r.Rate_Type__c,('+ 
                            
                                'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c')+
                                    ' FROM AcctSeed__Time_Card_Days__r'+
                                    ' WHERE AcctSeed__Date__c >= '+stDate+' AND AcctSeed__Date__c <= '+edDate+filterCondition+')'+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Line__c WHERE AcctSeed__Project_Task__r.AcctSeed__Project__c IN :projectId AND AcctSeed__Time_Card__r.Intructor__c = \''+contactId+'\'';
            
            System.debug('::::::if::::::qryString:::'+qryString);             
            timeCardLineList = Database.Query(qryString);
            
       } else if(projectId != null && projectId.size() > 0 && startDate != null && endDate != null) {
       
           String stDate = String.valueOf(startDate).split(' ')[0];
           String edDate = String.valueOf(endDate).split(' ')[0]; 
            
            String qryString = 'SELECT Id,Name,'+fieldStr+
                            ',AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.Name,'+
                            'AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName,'+
                            'AcctSeed__Project_Task__r.Rate__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,'+
                            'Location__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c,Labor_Cost_Rate__r.Rate_Type__c,('+ 
                            
                                'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c')+
                                    ' FROM AcctSeed__Time_Card_Days__r'+
                                    ' WHERE AcctSeed__Date__c >= '+stDate+' AND AcctSeed__Date__c <= '+edDate+filterCondition+')'+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Line__c WHERE AcctSeed__Project_Task__r.AcctSeed__Project__c IN :projectId';
            
            System.debug('::::else:::::::::qryString:::'+qryString);             
            timeCardLineList = Database.Query(qryString);
       }else if(startDate != null && endDate != null) {
           String stDate = String.valueOf(startDate).split(' ')[0];
           String edDate = String.valueOf(endDate).split(' ')[0]; 
            
            String qryString = 'SELECT Id,Name,'+fieldStr+
                            ',AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.Name,'+
                            'AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName,'+
                            'AcctSeed__Project_Task__r.Rate__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,'+
                            'Location__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c,Labor_Cost_Rate__r.Rate_Type__c,('+ 
                            
                                'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c')+
                                    ' FROM AcctSeed__Time_Card_Days__r'+
                                    ' WHERE AcctSeed__Date__c >= '+stDate+' AND AcctSeed__Date__c <= '+edDate+filterCondition+')'+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Line__c';
            
            System.debug('::::else:::::::::qryString:::'+qryString);             
            timeCardLineList = Database.Query(qryString);
       }
       
       return timeCardLineList;
    }
      
    /**********************************************************************
        Created by Sukanya on August 10 2017: This method return list of Time Card Line with time card day - if they have day records
        @filterCondition - where conditions
        @Start date - end date for time card day 
        @End date - end date for time card day
        @projectId - project id 
        @taskId - project task id
        @contactId - id of the contact
        return - list of Time Card Line records
    ***********************************************************************/
    public Static List<AcctSeed__Time_Card_Line__c> getTCL_TCD_withfilters(String filterCondition,Id projectId,Id taskId,Date startDate,Date endDate,Id contactId) {
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        
        if(projectId != null && taskId != null && startDate != null && endDate != null) {
            
            String stDate = String.valueOf(startDate).split(' ')[0];
            String edDate = String.valueOf(endDate).split(' ')[0]; 
            
            String qryString = 'SELECT Id,Name,'+fieldStr+
                            ',AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.Name,'+
                            'AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName,'+
                            'AcctSeed__Project_Task__r.Rate__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,'+
                            'Location__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c,Labor_Cost_Rate__r.Rate_Type__c,('+ 
                            
                                'SELECT Id,Name,AcctSeed__Date__c'+
                                    ' FROM AcctSeed__Time_Card_Days__r'+
                                    ' WHERE AcctSeed__Date__c >= '+stDate+' AND AcctSeed__Date__c <= '+edDate+filterCondition+')'+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Line__c WHERE AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c = '+stDate+' AND AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c = '+edDate+
                            ' AND AcctSeed__Project_Task__r.AcctSeed__Project__c = :projectId AND AcctSeed__Project_Task__c = :taskId AND AcctSeed__Time_Card__r.Intructor__c = \''+contactId+'\'';
            
            System.debug('qryString:::'+qryString);             
            timeCardLineList = Database.Query(qryString);
       }
       return timeCardLineList;
    }
    
    /**********************************************************************
        Created by Sukanya on August 10 2017: This method return list of Time Card Line with time card day - if they have day records
        @filterCondition - where conditions
        @Start date - end date for time card day 
        @End date - end date for time card day
        @projectId - project id 
        @taskId - project task id
        @contactId - id of the contact
        return - list of Time Card Line records
    ***********************************************************************/
    public Static List<AcctSeed__Time_Card_Line__c> getlinewithDayRec_withoutDateFilter(String filterCondition,Set<Id> projectId,Date startDate,Date endDate,Id contactId) {
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        
        String stDate = String.valueOf(startDate).split(' ')[0];
        String edDate = String.valueOf(endDate).split(' ')[0]; 
       
        if(projectId.size() > 0 && startDate != null && endDate != null) {

            String qryString = 'SELECT Id,Name,'+fieldStr+
                            ',AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.Name,'+
                            'AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName,'+
                            'AcctSeed__Project_Task__r.Rate__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,'+
                            'Location__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c,Labor_Cost_Rate__r.Rate_Type__c,('+ 
                            
                                'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c')+
                                    ' FROM AcctSeed__Time_Card_Days__r'+
                                    ' WHERE '+filterCondition+')'+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Line__c '+
                            ' WHERE AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c = '+stDate+' AND AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c = '+edDate+
                                ' AND AcctSeed__Project_Task__r.AcctSeed__Project__c IN :projectId AND AcctSeed__Time_Card__r.Intructor__c = \''+contactId+'\'';
            
            System.debug('qryString:::'+qryString);             
            timeCardLineList = Database.Query(qryString);
        }
       return timeCardLineList;
    }
    
    /**********************************************************************
        Created by Sukanya on March 05 2019: This method return list of Time Card Line with time card day
        @filterCondition - where conditions
        @Start date - end date for time card day 
        @End date - end date for time card day
        @projectIds - project id set
        @contactId - id of the contact
        @taskId - task records id
        return - list of Time Card Line records
    ***********************************************************************/
    public Static List<AcctSeed__Time_Card_Line__c> getTCL_dayRecords(String filterCondition,Set<Id> projectId,Set<Id> taskId,Date startDate,Date endDate,Id contactId) {
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        
        if(projectId != null && projectId.size() > 0 && taskId != null && taskId.size() > 0 && startDate != null && endDate != null && contactId != null) {
            
            String stDate = String.valueOf(startDate).split(' ')[0];
            String edDate = String.valueOf(endDate).split(' ')[0]; 
            
            String qryString = 'SELECT Id,Name,'+fieldStr+
                            ',AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.Name,'+
                            'AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName,'+
                            'AcctSeed__Project_Task__r.Rate__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,AcctSeed__Project_Task__r.AcctSeed__Project__r.DLS_Class__c,'+
                            'Location__r.Name,AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,'+
                            'AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c,Labor_Cost_Rate__r.Rate_Type__c,('+ 
                            
                                'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Time_Card_Day__c')+
                                    ' FROM AcctSeed__Time_Card_Days__r'+
                                    ' WHERE AcctSeed__Date__c >= '+stDate+' AND AcctSeed__Date__c <= '+edDate+filterCondition+')'+
                            ' FROM'+
                            ' AcctSeed__Time_Card_Line__c '+
                            'WHERE AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c = '+stDate+' AND AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c = '+edDate+
                                    ' AND AcctSeed__Project_Task__r.AcctSeed__Project__c IN :projectId AND AcctSeed__Project_Task__c IN :taskId AND AcctSeed__Time_Card__r.Intructor__c = \''+contactId+'\'';
            
            System.debug('::::::if::::::qryString:::'+qryString);             
            timeCardLineList = Database.Query(qryString);
            
       } 
       return timeCardLineList;
    }
}