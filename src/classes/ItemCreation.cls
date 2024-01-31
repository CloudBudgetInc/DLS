/*
* This class is used to Create Item records in Bill.com from Project Task records 
* which have conditions need to be determined
* Finish method call another batch -LastModifiedDate >= :LastSyncDate
*/
global class ItemCreation implements Database.batchable<sObject>,Database.Stateful,Database.AllowsCallouts { 
    
    global List<AcctSeed__Project_Task__c> updateProjectTaskList = new List<AcctSeed__Project_Task__c>();
    global DateTime LastSyncDate;
    global DateTime dateToUpdateCustomSetting;
    global static Map<String,String> cookieAndSessionIdMap_Item;
    
    global ItemCreation(Map<String,String> cookieAdSessionMap){
        cookieAndSessionIdMap_Item = cookieAdSessionMap;
    }
    global Database.QueryLocator start(Database.BatchableContext info){
        
        System_Values__c sysVal = System_Values__c.getValues('Bill.com Item Last Sync Date Time');
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
        
        Set<String> taskTypeValues = new Set<String>{'Language Training','Language Testing','Linguist Support Services','Material Budget','Preparation Time','Translation','Translation (per hr)','Translation (per word)','Translation (per FFP)','Interpretation (per hr)','Accommodations','Admin Fee','Air Fare','Change Fee','Curriculum Development','ELC Langauge Training','Gas'};
         
        String  taskQry = 'SELECT Id,Name,RecordType.DeveloperName,RecordType.Name,AcctSeed__Project__r.DLS_Ref__c,Rate__c,Bill_com_Item_Id__c,AcctSeed__Status__c,Description__c,Bill_com_Last_Successful_Sync_Date_Time__c FROM AcctSeed__Project_Task__c '+
                            ' WHERE Project_Task_Type__c IN :taskTypeValues AND AcctSeed__Status__c = \'Active\' AND AcctSeed__Project__r.AcctSeed__Status__c = \'Active\' AND  (LastModifiedDate >= :LastSyncDate OR (LastModifiedDate <= :LastSyncDate AND Bill_com_Item_Id__c = null)) AND '+
                            '((Bill_com_Last_Successful_Sync_Date_Time__c != null AND Bill_com_Sync_Status__c IN (\'Pending\',\'Failure\')) OR Bill_com_Last_Successful_Sync_Date_Time__c = null)';
        
        System.debug('::::::::taskQry::::::::::'+taskQry);
        return Database.getQueryLocator(taskQry);
    }
    
    global void execute(Database.BatchableContext info, List<AcctSeed__Project_Task__c> taskList){
    
       BillDotComUtil.ItemRequest item = new BillDotComUtil.ItemRequest();
       
       Set<String> serviceRTValues = new Set<String>{'Curriculum Development','Language Testing','Language Training','Linguist Support','Translation','MTT'};
       
       Id taskId;
      
      try {
          
          if(taskList != null && taskList.size() > 0) {
          
              for(AcctSeed__Project_Task__c task : taskList){
                  
                  taskId = task.Id;
                  
                  if(task.Bill_com_Item_Id__c != null) {
                      item.id = task.Bill_com_Item_Id__c;
                  }
                  item.entity = 'Item';
                  item.price = task.Rate__c;
                  item.name = task.AcctSeed__Project__r.DLS_Ref__c+' - '+task.Name;
                  
                  if(serviceRTValues.contains(task.RecordType.Name)){
                      item.type = '1';
                  }else {
                      item.type = '8';
                  }
                  item.description = task.Description__c;
                  
                  if(task.AcctSeed__Status__c == 'Active'){
                      item.isActive = '1';    
                  }
              }          
              system.debug(':::::item:::::::::::'+item);
              
              BillDotComUtil.ItemResponse response = new BillDotComUtil.ItemResponse();
              
              if(taskList[0].Bill_com_Item_Id__c == null) { 
                  response = BillDotComUtil.itemMethod(item,'create', cookieAndSessionIdMap_Item);
              }else {
                  response = BillDotComUtil.itemMethod(item,'update', cookieAndSessionIdMap_Item);
              }
              system.debug(':::::::response:::::'+response);
        
              if(response.response_status == '0' && response.response_data != null && response.response_data.id != null) {
              
                  AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c();
                  task.Id = taskId;
                  task.Bill_com_Item_Id__c = response.response_data.id;
                  task.Bill_com_Item_Created_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(response.response_data.createdTime));
                  task.Bill_com_Item_Updated_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(response.response_data.updatedTime));
                  task.Bill_com_Sync_Status__c = 'Success';
                  task.Bill_com_Sync_Error__c = '';
                  task.Bill_com_Last_Successful_Sync_Date_Time__c = dateToUpdateCustomSetting;
                  updateProjectTaskList.add(task);
                   
              }else {
                  system.debug('::::::::::fail:::::::'+response.response_data.error_code+' - '+response.response_data.error_message);
                  AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c();
                  task.Id = taskId;
                  task.Bill_com_Sync_Status__c = 'Failure';
                  task.Bill_com_Sync_Error__c = response.response_data.error_code+' - '+response.response_data.error_message;
                  updateProjectTaskList.add(task);
              }
               
          }
      }catch (Exception e){
      
          system.debug(':::::::::catch:::::'+e.getMessage());
          AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c();
          task.Id = taskId;
          task.Bill_com_Sync_Status__c = 'Failure';
          task.Bill_com_Sync_Error__c = e.getMessage();
          updateProjectTaskList.add(task);
      }
        
    }
    global void finish(Database.BatchableContext info) { 
        
        system.debug(':::::::::updateProjectTaskList:::::'+updateProjectTaskList);
        system.debug('::::::dateToUpdateCustomSetting:::::::::'+dateToUpdateCustomSetting);
        
        try{
        
            BillDotComUtil.updateFromBillDotComSync = true;
            
            Database.SaveResult[] srList = Database.update(updateProjectTaskList, false);
            
            System_Values__c sysValue = System_Values__c.getValues('Bill.com Item Last Sync Date Time');
            
            sysValue.Value__c = string.valueOf(dateToUpdateCustomSetting);
            update sysValue;
            
            //call class creation batch to push Accounting Variable records to bill.com
            
            if(!Test.isRunningTest()){
                ClassCreation clsCreate = new ClassCreation(cookieAndSessionIdMap_Item); 
                database.executebatch(clsCreate,1);
            }
                        
        }catch(Exception ex){
            system.debug('::::::error:Message::::'+ex.getMessage());
        }
      
    }   
}