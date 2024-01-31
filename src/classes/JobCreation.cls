/*
* This class is used to Create Job record in Bill.com from Project records 
* Conditions:
    1) Status = Active
    2) RecordType != ('Cost_Only','Partner_School_LT_Projects','Admin_Projects','Facilities_Project')
*/
global class JobCreation implements Database.batchable<sObject>,Database.Stateful,Database.AllowsCallouts { 
    
    global List<AcctSeed__Project__c> updateProjectList = new List<AcctSeed__Project__c>();
    global DateTime LastSyncDate;
    global DateTime dateToUpdateCustomSetting;
    global static Map<String,String> cookieAndSessionIdMap_Job;
    
    global Database.QueryLocator start(Database.BatchableContext info){
    
        cookieAndSessionIdMap_Job = BillDotComUtil.getCookieAndSessionId();
        
        System_Values__c sysVal = System_Values__c.getValues('Bill.com Job Last Sync Date Time');
        String dt = sysVal.Value__c;
        
        String datePart = dt.split(' ')[0];
        String timePart = dt.split(' ')[1];
        
        Integer year = Integer.ValueOf(datePart.split('-')[0]);
        Integer month = Integer.ValueOf(datePart.split('-')[1]);
        Integer dat = Integer.ValueOf(datePart.split('-')[2]);
        Integer hrs = Integer.ValueOf(timePart.split(':')[0]);
        Integer min = Integer.ValueOf(timePart.split(':')[1]);
        Integer sec = Integer.ValueOf(timePart.split(':')[2]);
        
        DateTime dateTimePart = DateTime.newInstanceGMT(year,month,dat,hrs,min,sec);
        system.debug('::::dateTimePart::::'+dateTimePart);
        
        LastSyncDate = dateTimePart;
        
        dateToUpdateCustomSetting = system.now();
        
        Set<String> recordTypesToExlude = new Set<String>{'Cost_Only','Partner_School_LT_Projects','Admin_Projects','Facilities_Project'};
        
        String  projectQry = 'SELECT Id,Name,Bill_com_Job_Id__c,DLS_Ref__c,AcctSeed__Status__c,Bill_com_Last_Successful_Sync_Date_Time__c FROM AcctSeed__Project__c '+
                                'WHERE RecordType.DeveloperName NOT IN :recordTypesToExlude AND AcctSeed__Status__c = \'Active\' AND LastModifiedDate >= :LastSyncDate '+
                                    ' AND ((Bill_com_Last_Successful_Sync_Date_Time__c != null AND Bill_com_Sync_Status__c IN (\'Pending\',\'Failure\')) OR Bill_com_Last_Successful_Sync_Date_Time__c = null)';
        
        System.debug('::::::::projectQry::::::::::'+projectQry);
        return Database.getQueryLocator(projectQry);
    }
    
    global void execute(Database.BatchableContext info, List<AcctSeed__Project__c> projectList){
    
       BillDotComUtil.JobRequest job = new BillDotComUtil.JobRequest();
       
       Id projectId;
      
      try {
          
          if(projectList != null && projectList.size() > 0) {
          
              for(AcctSeed__Project__c project : projectList){
              
                  if(project.Bill_com_Job_Id__c != null) {
                      job.id = project.Bill_com_Job_Id__c;
                  }
                  
                  projectId = project.Id;
                  
                  job.entity = 'Job';
                  job.name = project.DLS_Ref__c+' / '+project.Name;
                  
                  //if(project.AcctSeed__Status__c == 'Active') {
                      job.isActive = '1';
                  /*} else {
                      job.isActive = '0';
                  }*/
                      
              }          
              system.debug(':::::job:::::::::::'+job);
              
              BillDotComUtil.JobResponse response = new BillDotComUtil.JobResponse();
              
              if(projectList[0].Bill_com_Job_Id__c == null) { 
                  response = BillDotComUtil.jobMethod(job,'create', cookieAndSessionIdMap_Job);
              }else {
                  response = BillDotComUtil.jobMethod(job,'update', cookieAndSessionIdMap_Job);
              }
              system.debug(':::::::response:::::'+response);
        
              if(response.response_status == '0' && response.response_data != null && response.response_data.id != null) {
              
                  AcctSeed__Project__c pro = new AcctSeed__Project__c();
                  pro.Id = projectId;
                  pro.Bill_com_Job_Id__c = response.response_data.id;
                  pro.Bill_com_Job_Created_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(response.response_data.createdTime));
                  pro.Bill_com_Job_Updated_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(response.response_data.updatedTime));
                  pro.Bill_com_Sync_Status__c = 'Success';
                  pro.Bill_com_Sync_Error__c = '';
                  pro.Bill_com_Last_Successful_Sync_Date_Time__c = dateToUpdateCustomSetting;
                  updateProjectList.add(pro);
                   
              }else {
                  system.debug('::::::::::fail:::::::'+response.response_data.error_code+' - '+response.response_data.error_message);
                  
                  AcctSeed__Project__c pro = new AcctSeed__Project__c();
                  pro.Id = projectId;
                  pro.Bill_com_Sync_Status__c = 'Failure';
                  pro.Bill_com_Sync_Error__c = response.response_data.error_code+' - '+response.response_data.error_message;
                  updateProjectList.add(pro);
              }
               
          }
      }catch (Exception e){
      
          system.debug(':::::::::catch:::::'+e.getMessage());
          
          AcctSeed__Project__c pro = new AcctSeed__Project__c();
          pro.Id = projectId;
          pro.Bill_com_Sync_Status__c = 'Failure';
          pro.Bill_com_Sync_Error__c = e.getMessage();
          updateProjectList.add(pro);
      }
        
    }
    global void finish(Database.BatchableContext info) { 
        
        system.debug(':::::::::updateProjectList:::::'+updateProjectList);
        system.debug('::::::dateToUpdateCustomSetting:::::::::'+dateToUpdateCustomSetting);
        
        try{
            //update updateProjectList;
            
            BillDotComUtil.updateFromBillDotComSync = true;
            
            Database.SaveResult[] srList = Database.update(updateProjectList, false);
            
            System_Values__c sysValue = System_Values__c.getValues('Bill.com Job Last Sync Date Time');
            
            sysValue.Value__c = string.valueOf(dateToUpdateCustomSetting);
            update sysValue;
            
            //call item creation batch to push project task records to bill.com
            ItemCreation item = new ItemCreation(cookieAndSessionIdMap_Job); 
            database.executebatch(item,1);
            
        }catch(Exception ex){
            system.debug('::::::error:Message::::'+ex.getMessage());
        }
      
    }   
}