/*
* This class is used to Create Chart Of Account records in Bill.com from GL Account records in AS
* Conditions:
    1) Name != null
    2) Active = true
    3) Type = Revenue / Expense / Balance Sheet
*/
global class ChartOfAccountCreation implements Database.batchable<sObject>,Database.Stateful,Database.AllowsCallouts { 
    
    global List<AcctSeed__GL_Account__c> updateGLAccountList = new List<AcctSeed__GL_Account__c>();
    global DateTime LastSyncDate;
    global DateTime dateToUpdateCustomSetting;
    global static Map<String,String> cookieAndSessionIdMap_ChartOfAccount;
    
    global ChartOfAccountCreation(Map<String,String> cookieAdSessionMap){
        cookieAndSessionIdMap_ChartOfAccount = cookieAdSessionMap;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){
        
        System_Values__c sysVal = System_Values__c.getValues('Bill.com COA Last Sync Date Time');
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
        
         
        String  glAccountQry = 'SELECT Id,Name,Bill_com_Chart_Of_Account_Id__c,AcctSeed__Active__c,GL_Account__c,AcctSeed__Billing_Description__c,Bill_com_Last_Successful_Sync_Date_Time__c FROM AcctSeed__GL_Account__c'+
                                    ' WHERE AcctSeed__Active__c = true AND AcctSeed__Type__c IN (\'Revenue\',\'Expense\',\'Balance Sheet\') AND LastModifiedDate >= :LastSyncDate AND '+
                                    '((Bill_com_Last_Successful_Sync_Date_Time__c != null AND  Bill_com_Sync_Status__c IN (\'Pending\',\'Failure\')) '+ 
                                    'OR Bill_com_Last_Successful_Sync_Date_Time__c = null)';
        
        System.debug('::::::::glAccountQry::::::::::'+glAccountQry);
        return Database.getQueryLocator(glAccountQry);
    }
    
    global void execute(Database.BatchableContext info, List<AcctSeed__GL_Account__c> glAccountList){
    
       BillDotComUtil.ChartOfAccountRequest chartOfAcc = new BillDotComUtil.ChartOfAccountRequest();
       
       Id glAccountId;
      
      try {
          
          if(glAccountList != null && glAccountList.size() > 0) {
          
              for(AcctSeed__GL_Account__c glAcc : glAccountList){
                  
                  glAccountId = glAcc.Id;
                  
                  chartOfAcc.entity = 'ChartOfAccount';
                  
                  if(glAcc.Bill_com_Chart_Of_Account_Id__c != null) {
                      chartOfAcc.id = glAcc.Bill_com_Chart_Of_Account_Id__c;
                  }
                  
                  if(glAcc.Name.contains(' - ')){
                      chartOfAcc.name = glAcc.Name.split(' - ')[1];    
                  }
                  chartOfAcc.accountNumber = glAcc.GL_Account__c;
                  chartOfAcc.description = glAcc.AcctSeed__Billing_Description__c;
                  chartOfAcc.accountType = '14';
                  
                  if(glAcc.AcctSeed__Active__c){
                      chartOfAcc.isActive = '1';    
                  }else {
                      chartOfAcc.isActive = '2';
                  }
              }          
              system.debug(':::::chartOfAcc:::::::::::'+chartOfAcc);
              
              BillDotComUtil.ChartOfAccountResponse response = new BillDotComUtil.ChartOfAccountResponse();
              
              if(glAccountList[0].Bill_com_Chart_Of_Account_Id__c == null) { 
                  response = BillDotComUtil.chartOfAccountMethod(chartOfAcc,'create',cookieAndSessionIdMap_ChartOfAccount);
              }else {
                  response = BillDotComUtil.chartOfAccountMethod(chartOfAcc,'update',cookieAndSessionIdMap_ChartOfAccount);
              }
              system.debug(':::::::response:::::'+response);
        
              if(response.response_status == '0' && response.response_data != null && response.response_data.id != null) {
              
                  AcctSeed__GL_Account__c glAcc = new AcctSeed__GL_Account__c();
                  glAcc.Id = glAccountId;
                  glAcc.Bill_com_Chart_Of_Account_Id__c = response.response_data.id;
                  glAcc.Bill_com_Chart_Of_Account_Created_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(response.response_data.createdTime));
                  glAcc.Bill_com_Chart_Of_Account_Updated_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(response.response_data.updatedTime));
                  glAcc.Bill_com_Sync_Status__c = 'Success';
                  glAcc.Bill_com_Sync_Error__c = '';
                  glAcc.Bill_com_Last_Successful_Sync_Date_Time__c = dateToUpdateCustomSetting;
                  
                  updateGLAccountList.add(glAcc);
                   
              }else {
                  system.debug('::::::::::fail:::::::'+response.response_data.error_code+' - '+response.response_data.error_message);
                  AcctSeed__GL_Account__c glAcc = new AcctSeed__GL_Account__c();
                  glAcc.Id = glAccountId;
                  glAcc.Bill_com_Sync_Status__c = 'Failure';
                  glAcc.Bill_com_Sync_Error__c = response.response_data.error_code+' - '+response.response_data.error_message;
                  updateGLAccountList.add(glAcc);
              }
               
          }
      }catch (Exception e){
      
          system.debug(':::::::::catch:::::'+e.getMessage());
          AcctSeed__GL_Account__c glAcc = new AcctSeed__GL_Account__c();
          glAcc.Id = glAccountId;
          glAcc.Bill_com_Sync_Status__c = 'Failure';
          glAcc.Bill_com_Sync_Error__c = e.getMessage();
          updateGLAccountList.add(glAcc);
      }
        
    }
    global void finish(Database.BatchableContext info) { 
        
        system.debug(':::::::::updateGLAccountList:::::'+updateGLAccountList);
        system.debug('::::::dateToUpdateCustomSetting:::::::::'+dateToUpdateCustomSetting);
        
        try{
                    
            BillDotComUtil.updateFromBillDotComSync = true;
            
            Database.SaveResult[] srList = Database.update(updateGLAccountList, false);
            
            System_Values__c sysValue = System_Values__c.getValues('Bill.com COA Last Sync Date Time');
            
            sysValue.Value__c = string.valueOf(dateToUpdateCustomSetting);
            update sysValue;
            
        }catch(Exception ex){
            system.debug('::::::error:Message::::'+ex.getMessage());
        }
      
    }   
}