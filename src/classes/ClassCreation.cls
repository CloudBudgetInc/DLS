/*
* This class is used to Create Class records in Bill.com from Accounting Variable records in AS
* Conditions:
    1) Name != null
    2) Active = true
*/
global class ClassCreation implements Database.batchable<sObject>,Database.Stateful,Database.AllowsCallouts { 
    
    global List<AcctSeed__Accounting_Variable__c> updateAccVariableList = new List<AcctSeed__Accounting_Variable__c>();
    global DateTime LastSyncDate;
    global DateTime dateToUpdateCustomSetting;
    global static Map<String,String> cookieAndSessionIdMap_Class;
    
    global ClassCreation(Map<String,String> cookieAdSessionMap){
        cookieAndSessionIdMap_Class = cookieAdSessionMap;
    }
        
    global Database.QueryLocator start(Database.BatchableContext info){
        
        System_Values__c sysVal = System_Values__c.getValues('Bill.com Class Last Sync Date Time');
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
        
         
        String  accVariableQry = 'SELECT Id,Name,Bill_com_Class_Id__c,AcctSeed__Active__c,Bill_com_Last_Successful_Sync_Date_Time__c FROM AcctSeed__Accounting_Variable__c'+
                            ' WHERE AcctSeed__Active__c = true AND LastModifiedDate >= :LastSyncDate AND '+
                            '((Bill_com_Last_Successful_Sync_Date_Time__c != null AND Bill_com_Sync_Status__c IN (\'Pending\',\'Failure\')) OR Bill_com_Last_Successful_Sync_Date_Time__c = null)';
        
        System.debug('::::::::accVariableQry::::::::::'+accVariableQry);
        return Database.getQueryLocator(accVariableQry);
    }
    
    global void execute(Database.BatchableContext info, List<AcctSeed__Accounting_Variable__c> accVariableList){
    
       BillDotComUtil.ClassRequest classRec = new BillDotComUtil.ClassRequest();
       
       Id accVariableId;
      
      try {
          
          if(accVariableList != null && accVariableList.size() > 0) {
          
              for(AcctSeed__Accounting_Variable__c accVar : accVariableList){
                  
                  accVariableId = accVar.Id;
                  
                  if(accVar.Bill_com_Class_Id__c != null) {
                      classRec.id = accVar.Bill_com_Class_Id__c;
                  }
                  
                  classRec.name = accVar.Name;
                  
                  if(accVar.AcctSeed__Active__c){
                      classRec.isActive = '1';    
                  }else {
                      classRec.isActive = '2';
                  }
              }          
              system.debug(':::::classRec:::::::::::'+classRec);
              
              BillDotComUtil.ClassResponse response = new BillDotComUtil.ClassResponse();
              
              if(accVariableList[0].Bill_com_Class_Id__c == null) { 
                  response = BillDotComUtil.classMethod(classRec,'create',cookieAndSessionIdMap_Class);
              }else {
                  response = BillDotComUtil.classMethod(classRec,'update',cookieAndSessionIdMap_Class);
              }
              system.debug(':::::::response:::::'+response);
        
              if(response.response_status == '0' && response.response_data != null && response.response_data.id != null) {
              
                  AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
                  accVar.Id = accVariableId;
                  accVar.Bill_com_Class_Id__c = response.response_data.id;
                  accVar.Bill_com_Class_Created_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(response.response_data.createdTime));
                  accVar.Bill_com_Class_Updated_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(response.response_data.updatedTime));
                  accVar.Bill_com_Sync_Status__c = 'Success';
                  accVar.Bill_com_Sync_Error__c = '';
                  accVar.Bill_com_Last_Successful_Sync_Date_Time__c = dateToUpdateCustomSetting;
                  
                  updateAccVariableList.add(accVar);
                   
              }else {
                  system.debug('::::::::::fail:::::::'+response.response_data.error_code+' - '+response.response_data.error_message);
                  AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
                  accVar.Id = accVariableId;
                  accVar.Bill_com_Sync_Status__c = 'Failure';
                  accVar.Bill_com_Sync_Error__c = response.response_data.error_code+' - '+response.response_data.error_message;
                  updateAccVariableList.add(accVar);
              }
               
          }
      }catch (Exception e){
      
          system.debug(':::::::::catch:::::'+e.getMessage());
          AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
          accVar.Id = accVariableId;
          accVar.Bill_com_Sync_Status__c = 'Failure';
          accVar.Bill_com_Sync_Error__c = e.getMessage();
          updateAccVariableList.add(accVar);
      }
        
    }
    global void finish(Database.BatchableContext info) { 
        
        system.debug(':::::::::updateAccVariableList:::::'+updateAccVariableList);
        system.debug('::::::dateToUpdateCustomSetting:::::::::'+dateToUpdateCustomSetting);
        
        try{
                    
            BillDotComUtil.updateFromBillDotComSync = true;
            
            Database.SaveResult[] srList = Database.update(updateAccVariableList, false);
                        
            System_Values__c sysValue = System_Values__c.getValues('Bill.com Class Last Sync Date Time');
            
            sysValue.Value__c = string.valueOf(dateToUpdateCustomSetting);
            update sysValue;
            
            //call class creation batch to push Chart Of Account records to bill.com
            ChartOfAccountCreation chartOfAcc = new ChartOfAccountCreation(cookieAndSessionIdMap_Class); 
            database.executebatch(chartOfAcc,1);
            
        }catch(Exception ex){
            system.debug('::::::error:Message::::'+ex.getMessage());
        }
      
    }   
}