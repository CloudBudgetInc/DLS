/*
* This class is used to Create vendor record in Bill.com from Account records 
* Conditions:
    1) Accounting Type = Vendor,Customer and Vendor, 
    2) Accounting Active = true, 
    3) Account Record Type = All record types
    
* Finish method call another batch 
*/
global class VendorCreation implements Database.batchable<sObject>,Database.Stateful,Database.AllowsCallouts { 
    
    global List<Account> updateAccountList = new List<Account>();
    global DateTime LastSyncDate;
    global DateTime dateToUpdateCustomSetting;
    global Id accountId;
    
    global VendorCreation(Id accId){
        this.accountId = accId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){
    
        System_Values__c sysVal = System_Values__c.getValues('Bill.com Vendor Last Sync Date Time');
        String dt = sysVal.Value__c;
        
        system.debug(':::::dt::::'+dt);
        
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
        
        String  accQry = 'SELECT Id,Name,Type,Status_Bill_com__c,Bill_com_Vendor_Id__c,BillingStreet,BillingCountry,BillingPostalCode,BillingCity,AcctSeed__Billing_Contact__c,AcctSeed__Billing_Contact__r.FirstName,'+
                              'AcctSeed__Billing_Contact__r.LastName,Phone,BillingState,Account_Code__c,Account_Full_Name__c,AccountNumber,Tax_ID__c,AcctSeed__Accounting_Type__c,Bill_com_Name_On_Check__c,Bill_com_PayBy_Method__c,'+
                              'AcctSeed__X1099_Vendor__c,Email__c,Fax,Account_Description__c,RecordType.DeveloperName,Bill_com_Account_Type__c,Bill_com_Payment_Email__c,Bill_com_Payment_Phone__c,Bill_com_Last_Successful_Sync_Date_Time__c'+
                              ' FROM Account WHERE Id = :accountId AND AcctSeed__Accounting_Type__c IN (\'Vendor\',\'Customer and Vendor\')'+
                              ' AND Status_Bill_com__c = \'Active\'';
                          
        System.debug('::::::::accQrry::::::::::'+accQry);
        return Database.getQueryLocator(accQry);
    }
    
    global void execute(Database.BatchableContext info, List<Account> accountList){
    
       BillDotComUtil.VendorRequest vendor = new BillDotComUtil.VendorRequest();              
       
       Map<String,String> payByMap = new Map<String,String>{'check' => '0','ach' => '1','rpps' => '2','intlEPmt' => '6','offline' => '6','wallet' => '8'};
       
       Map<String,String> accountTypeMap = new Map<String,String>{'none' => '0','business' => '1','person' => '2'};
      
      try {
          
          if(accountList != null && accountList.size() > 0) {
          
              for(Account accRec : accountList){
                  
                  if(accRec.Bill_com_Vendor_Id__c != null) {
                      vendor.id = accRec.Bill_com_Vendor_Id__c;
                  }
                  
                  accountId = accRec.Id;
                  
                  vendor.entity = 'Vendor';
                  vendor.name = accRec.Name;
                  
                  if(accRec.Account_Code__c != null)
                      vendor.shortName = accRec.Account_Code__c;
                      
                  if(accRec.Account_Full_Name__c != null)
                      vendor.companyName = accRec.Account_Full_Name__c;
                      
                  if(accRec.Bill_com_Name_On_Check__c != null)
                      vendor.nameOnCheck = accRec.Bill_com_Name_On_Check__c;
                      
                  if(accRec.AccountNumber != null)
                      vendor.accNumber = accRec.AccountNumber;
                      
                  if(accRec.Tax_ID__c != null)
                      vendor.taxId = accRec.Tax_ID__c;
                      
                  if(accRec.AcctSeed__X1099_Vendor__c != null)
                      vendor.track1099 = accRec.AcctSeed__X1099_Vendor__c;
                  
                  if(accRec.BillingStreet != null)
                     vendor.address1 = accRec.BillingStreet;
                  
                  if(accRec.BillingCity != null)
                      vendor.addressCity = accRec.BillingCity;
                      
                  if(accRec.BillingState != null)
                      vendor.addressState = accRec.BillingState;
                      
                  if(accRec.BillingCountry != null)
                      vendor.addressCountry = accRec.BillingCountry;
                      
                  if(accRec.BillingPostalCode != null)
                      vendor.addressZip = accRec.BillingPostalCode;
                      
                  if(accRec.Email__c != null)   
                     vendor.email = accRec.Email__c;
                      
                  if(accRec.Fax!= null)
                     vendor.fax = accRec.Fax;
                      
                  if(accRec.Phone != null)
                     vendor.phone = accRec.Phone;
                      
                  if(accRec.Account_Description__c != null)
                      vendor.description = accRec.Account_Description__c;
                      
                  if(accRec.Bill_com_Payment_Email__c != null)
                      vendor.paymentEmail = accRec.Bill_com_Payment_Email__c;
                      
                  if(accRec.Bill_com_Payment_Phone__c != null)
                      vendor.paymentPhone = accRec.Bill_com_Payment_Phone__c;
                      
                  if(accRec.AcctSeed__Billing_Contact__c != null) {
                      
                      vendor.contactFirstName = accRec.AcctSeed__Billing_Contact__r.FirstName;
                      vendor.contactLastName = accRec.AcctSeed__Billing_Contact__r.LastName;
                  }
                  
                  if(accRec.Status_Bill_com__c == 'Active') {
                      vendor.isActive = '1';
                  } else {
                      vendor.isActive = '2';
                  }
                  
                  if(accRec.Bill_com_PayBy_Method__c != null && payByMap.containsKey(accRec.Bill_com_PayBy_Method__c)){
                      
                      vendor.payBy = payByMap.get(accRec.Bill_com_PayBy_Method__c);        
                  }else {
                      vendor.payBy = '0';
                  }
                  
                  if(accRec.Bill_com_Account_Type__c != null && accountTypeMap.containsKey(accRec.Bill_com_Account_Type__c)){
                      vendor.accountType = accountTypeMap.get(accRec.Bill_com_Account_Type__c);
                  }else {
                      vendor.accountType = '0';
                  }
              }          
              system.debug(':::::vendor:::::::::::'+vendor);
              
              BillDotComUtil.VendorResponse response = new BillDotComUtil.VendorResponse();
              
              if(accountList[0].Bill_com_Vendor_Id__c == null) { 
                  response = BillDotComUtil.vendorMethod(vendor,'create');
              }else {
                  response = BillDotComUtil.vendorMethod(vendor,'update');
              }
              system.debug(':::::::response:::::'+response);
        
              if(response.response_status == '0' && response.response_data != null && response.response_data.id != null) {
                  
                      Account acc = new Account();
                      acc.Id = accountId;
                      acc.Bill_com_Vendor_Id__c = response.response_data.id;
                      acc.Bill_com_Created_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(response.response_data.createdTime));
                      acc.Bill_com_Last_Updated_Date__c = BillDotComUtil.dateTimeConverion(String.valueOf(response.response_data.updatedTime));
                      acc.Bill_com_Sync_Status__c = 'Success';
                      acc.Bill_com_Sync_Error__c = '';
                      //acc.Bill_com_Last_Successful_Sync_Date_Time__c = dateToUpdateCustomSetting;
                      acc.Bill_com_Last_Successful_Sync_Date_Time__c = system.now();
                      
                      updateAccountList.add(acc);
                   
              }else {
                  
                  Account acc = new Account();
                  acc.Id = accountId;
                  acc.Bill_com_Sync_Status__c = 'Failure';
                  acc.Bill_com_Sync_Error__c =  response.response_data.error_code+': '+response.response_data.error_message;
                  
                  updateAccountList.add(acc); 
                  
                  system.debug('::::::::::fail:::::::'+response.response_data.error_code+' - '+response.response_data.error_message);
              }
               
          }
      }catch (Exception e){
      
          Account acc = new Account();
          acc.Id = accountId;
          acc.Bill_com_Sync_Status__c = 'Failure';
          acc.Bill_com_Sync_Error__c =  e.getMessage();
          
          updateAccountList.add(acc);  
          
          system.debug(':::::::::catch:::::'+e.getMessage());
      }
        
    }
    global void finish(Database.BatchableContext info) { 
        
        system.debug(':::::::::updateAccountList:::::'+updateAccountList);
        system.debug('::::::dateToUpdateCustomSetting:::::::::'+dateToUpdateCustomSetting);
        
        try{
            //update updateAccountList;
            
            Database.SaveResult[] srList = Database.update(updateAccountList, false);
            
            /*System_Values__c sysValue = System_Values__c.getValues('Bill.com Vendor Last Sync Date Time');
            
            sysValue.Value__c = string.valueOf(dateToUpdateCustomSetting);
            update sysValue;*/
            
            /*//call job creation batch to push project records to bill.com
            JobCreation job = new JobCreation(); 
            database.executebatch(job,1);*/
            
        }catch(Exception ex){
            system.debug('::::::error:Message::::'+ex.getMessage());
        }
      
    }   
}