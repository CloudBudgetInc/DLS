global class TimeLog_delete_Override_Controller {

    public String timeLogId {get;set;}
    public String TimeLogDetail {get;set;}

    global TimeLog_delete_Override_Controller(ApexPages.StandardController stdcontroller){
        
        Time_Log__c timeLogRec =  (Time_Log__c)stdController.getRecord();
        system.debug(':::::timeLogRec:::::::'+timeLogRec);
        timeLogId = timeLogRec.Id;
        system.debug(':::::timeLogId::::::'+timeLogId);
        
        List<Time_Log__c> recordsDetail = [SELECT Id,Name,Classification__c,Contact__r.Name,Date__c,
                                First_Name__c,Hours__c,Last_Name__c,Training_Location__c,Month__c,Opportunity__c,Opportunity__r.Name,
                                Payroll_Item__c,PC_Cust_Job__c,PC_GL_Code__c,QB_Cust_Job__c,Section__c,Service_Item__c,TL_Contact_ID__c,
                                TL_Opportunity_ID__c,Week_Day__c,Notes__c,Unposted__c
                        FROM Time_Log__c WHERE Id = :timeLogId];
        
        TimeLogDetail = String.escapeSingleQuotes(JSON.serialize(recordsDetail));
        
        //return TimeLogDetail;
    }
    
    @RemoteAction
    global static void updateTimeLog(String timeLogString) {
    
       List<Time_Log__c> updateRecord = (List<Time_Log__c>) System.JSON.deserialize(timeLogString, List<Time_Log__c>.class);
       system.debug('::::::::updateRecord:::::::'+updateRecord);
          
       updateRecord[0].Unposted__c = true;
       updateRecord[0].Hours__c = 0.00;
       
       updateRecord[0].Billable_Work__c = false;
       updateRecord[0].Classification__c = '';
       updateRecord[0].Last_Month__c = false;
       updateRecord[0].Training_Location__c = '';
       updateRecord[0].Payroll_Item__c = '';
       updateRecord[0].Section__c = '';
       updateRecord[0].Service_Item__c = '';
       updateRecord[0].Contact__c = null;
       updateRecord[0].Date__c = null;
       
       system.debug(':::::::::::updateRecord:::::::'+updateRecord);
       
       //commented because this creation is done on trigger
       
       /*Time_Log_Comment__c timeComment = new Time_Log_Comment__c();
       
       timeComment.Comments__c = updateRecord[0].Notes__c;
       timeComment.Hours__c = 0.00;
       timeComment.Time_Log__c = updateRecord[0].Id;
       timeComment.Unposted__c = true;
       
       system.debug(':::::::::timeComment:::::::::'+timeComment);*/
       
       update updateRecord;
       
       //insert timeComment;
       
       
    }
}