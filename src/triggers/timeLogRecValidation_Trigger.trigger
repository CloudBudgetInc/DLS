trigger timeLogRecValidation_Trigger on Time_Log__c (before insert,before update,before delete,after insert,after update) {
  
    // Get TimeLog_Profile_Ids,TimeLog_Admin_ProfileIds Custom label values 
    
    String ids = label.TimeLog_Profile_Ids;
    system.debug('::::::::::::::::::;;'+ids);
   // List<String> profileIdList = ids.split(',');
    
    String adminIds = label.TimeLog_Admin_ProfileIds;
    system.debug(':::::adminIds::::'+adminIds);
    //List<String> adminIdList = adminIds.split(',');
    
    Set<Id> profileIdSet = new Set<Id>();
    Set<Id> adminProfileIdSet = new Set<Id>();
    
    for(String str : ids.split(',')) {
        if(!profileIdSet.contains(Id.valueOf(str.trim()))){
            profileIdSet.add(Id.valueOf(str.trim()));
        }
    }
    
    for(String str : adminIds.split(',')) {
        if(!adminProfileIdSet.contains(Id.valueOf(str.trim()))){
            adminProfileIdSet.add(Id.valueOf(str.trim()));
        }
    }
    
    system.debug('::::::profileIdSet:::::'+profileIdSet);
    system.debug('::::::adminProfileIdSet:::::'+adminProfileIdSet);
    
    // Get TimeLog_Locking_Date custom setting value
    
    System_Values__c sysVal = System_Values__c.getValues('TimeLog_Locking_Date');
    system.debug('::::::::TimeLog_Locking_Date::::::'+sysVal);
    
    Date lockingDate;
    
    if(sysVal != null && sysVal.Value__c != null) {
        lockingDate = Date.valueOf(sysVal.Value__c);
    }
    system.debug('::::::::::lockingDate:::::::'+lockingDate);
    
    String loggedInProfileId = UserInfo.getProfileId();
   // User usr = [SELECT Id,Name,ProfileId FROM User WHERE Id =:UserInfo.getUserId()];
    
    //system.debug('::::::::usr::::::::'+usr);
    
    List<Time_Log_Snapshot__c> timeLogSnapshotList = new List<Time_Log_Snapshot__c>();
    
    if(trigger.isbefore && (Trigger.isInsert || Trigger.isUpdate)) {
    
        for (Time_Log__c timeLog : trigger.new) {
            
            //Check proflie ids
            
            if(profileIdSet.contains(loggedInProfileId) || adminProfileIdSet.contains(loggedInProfileId)){ // || adminProfileIdSet
            
            //Check time log locking date
                
                //system.debug(':::::::::timeLog.Date__c::::::::'+Trigger.oldMap.get(timeLog.Id).Date__c);
                //system.debug(':::::::::date:::condition:::::'+(lockingDate < Trigger.oldMap.get(timeLog.Id).Date__c));
                
                if(Trigger.isUpdate) {
                
                     if(lockingDate < Trigger.oldMap.get(timeLog.Id).Date__c) { 
                     
                        if(!adminProfileIdSet.contains(loggedInProfileId)) {  // && Not in adminProfileIdSet
                        
                            if( Trigger.oldMap.get(timeLog.Id).Hours__c != timeLog.Hours__c && 
                                ( Trigger.oldMap.get(timeLog.Id).Notes__c == timeLog.Notes__c || timeLog.Notes__c == null ) ) {
                                timeLog.addError('Please update Time Log comments');
                            } 
                            if( Trigger.oldMap.get(timeLog.Id).Unposted__c != timeLog.Unposted__c && 
                                ( Trigger.oldMap.get(timeLog.Id).Notes__c == timeLog.Notes__c || timeLog.Notes__c == null ) ) {
                                timeLog.addError('Please update Time Log comments');
                            }
                            if( Trigger.oldMap.get(timeLog.Id).Billable_Work__c != timeLog.Billable_Work__c && 
                                ( Trigger.oldMap.get(timeLog.Id).Notes__c == timeLog.Notes__c || timeLog.Notes__c == null ) ) {
                                timeLog.addError('Please update Time Log comments');
                            }
                            
                            if(timeLog.Date__c == null && timeLog.Unposted__c == false) {
                                timeLog.addError('Date value is Required');
                            }
                        }
                         
                     }else {
                         // Not in adminProfileIdSet
                         
                         if(!adminProfileIdSet.contains(loggedInProfileId))
                             timeLog.addError('You cannot edit Time Log record after Time Log locking period');
                     } 
                 }
            }else {
                timeLog.addError('Insufficient Privilege');
            }
        }
    
    }
    
    if(trigger.isbefore && Trigger.isDelete) {
        for (Time_Log__c timeLog : trigger.Old) {
            timeLog.addError('You cannot delete Time Log record. Please unpost it.');
        }
    }
    
    // After isert Time Log Comments Create
    
   /* if(trigger.isAfter && Trigger.isInsert){
        
        for (Time_Log__c timeLog : trigger.new) {
                
            Time_Log_Snapshot__c timeSnapshot = new Time_Log_Snapshot__c();
            
            timeSnapshot.Comments__c = timeLog.Notes__c;
            timeSnapshot.Hours__c = timeLog.Hours__c;
            timeSnapshot.Time_Log__c = timeLog.Id;
            timeSnapshot.Unposted__c = timeLog.Unposted__c;
            
            timeSnapshot.Billable_Work__c = timeLog.Billable_Work__c;
            timeSnapshot.Classification__c = timeLog.Classification__c;
            timeSnapshot.Contact__c = timeLog.Contact__c;
            timeSnapshot.Date__c = timeLog.Date__c;
            
            timeSnapshot.First_Name__c = timeLog.First_Name__c;
            timeSnapshot.Last_Month__c = timeLog.Last_Month__c;
            timeSnapshot.Last_Name__c = timeLog.Last_Name__c;
            timeSnapshot.Training_Location__c = timeLog.Training_Location__c;
            
            timeSnapshot.Month__c = timeLog.Month__c;
            timeSnapshot.Opportunity__c = timeLog.Opportunity__c;
            timeSnapshot.Payroll_Item__c = timeLog.Payroll_Item__c;
            timeSnapshot.PC_Cust_Job__c = timeLog.PC_Cust_Job__c;
            
            timeSnapshot.PC_GL_Code__c = timeLog.PC_GL_Code__c;
            timeSnapshot.QB_Cust_Job__c = timeLog.QB_Cust_Job__c;
            timeSnapshot.Section__c = timeLog.Section__c;
            timeSnapshot.Service_Item__c = timeLog.Service_Item__c;
            
            timeSnapshot.TL_Contact_ID__c = timeLog.TL_Contact_ID__c;
            timeSnapshot.TL_Opportunity_ID__c = timeLog.TL_Opportunity_ID__c;
            timeSnapshot.Week_Day__c = timeLog.Week_Day__c;
            
            
            timeLogSnapshotList.add(timeSnapshot);
        }
    }*/
    
    // After update Time Log comments record create
    
    if(trigger.isAfter && Trigger.isUpdate){
        
        for (Time_Log__c timeLog : trigger.new) {
        
            if( Trigger.oldMap.get(timeLog.Id) != Trigger.newMap.get(timeLog.Id) ) {
                
                system.debug(':::oldMap::'+Trigger.oldMap.get(timeLog.Id));
                system.debug(':::newMap::'+Trigger.newMap.get(timeLog.Id));
                Time_Log_Snapshot__c timeSnapshot = new Time_Log_Snapshot__c();
                
                timeSnapshot.Comments__c = Trigger.oldMap.get(timeLog.Id).Notes__c;
                timeSnapshot.Hours__c = Trigger.oldMap.get(timeLog.Id).Hours__c;
                timeSnapshot.Time_Log__c = Trigger.oldMap.get(timeLog.Id).Id;
                timeSnapshot.Unposted__c = Trigger.oldMap.get(timeLog.Id).Unposted__c;
                
                timeSnapshot.Billable_Work__c = Trigger.oldMap.get(timeLog.Id).Billable_Work__c;
                timeSnapshot.Classification__c = Trigger.oldMap.get(timeLog.Id).Classification__c;
                timeSnapshot.Contact__c = Trigger.oldMap.get(timeLog.Id).Contact__c;
                timeSnapshot.Date__c = Trigger.oldMap.get(timeLog.Id).Date__c;
                
                timeSnapshot.First_Name__c = Trigger.oldMap.get(timeLog.Id).First_Name__c;
                timeSnapshot.Last_Month__c = Trigger.oldMap.get(timeLog.Id).Last_Month__c;
                timeSnapshot.Last_Name__c = Trigger.oldMap.get(timeLog.Id).Last_Name__c;
                timeSnapshot.Training_Location__c = Trigger.oldMap.get(timeLog.Id).Training_Location__c;
                
                timeSnapshot.Month__c = Trigger.oldMap.get(timeLog.Id).Month__c;
                timeSnapshot.Opportunity__c = Trigger.oldMap.get(timeLog.Id).Opportunity__c;
                timeSnapshot.Payroll_Item__c = Trigger.oldMap.get(timeLog.Id).Payroll_Item__c;
                timeSnapshot.PC_Cust_Job__c = Trigger.oldMap.get(timeLog.Id).PC_Cust_Job__c;
                
                timeSnapshot.PC_GL_Code__c = Trigger.oldMap.get(timeLog.Id).PC_GL_Code__c;
                timeSnapshot.QB_Cust_Job__c = Trigger.oldMap.get(timeLog.Id).QB_Cust_Job__c;
                timeSnapshot.Section__c = Trigger.oldMap.get(timeLog.Id).Section__c;
                timeSnapshot.Service_Item__c = Trigger.oldMap.get(timeLog.Id).Service_Item__c;
                
                timeSnapshot.TL_Contact_ID__c = Trigger.oldMap.get(timeLog.Id).TL_Contact_ID__c;
                timeSnapshot.TL_Opportunity_ID__c = Trigger.oldMap.get(timeLog.Id).TL_Opportunity_ID__c;
                timeSnapshot.Week_Day__c = Trigger.oldMap.get(timeLog.Id).Week_Day__c;
                
                timeLogSnapshotList.add(timeSnapshot);
            }
        
        }
    }
    
    system.debug(':::::::::timeLogSnapshotList:::::::'+timeLogSnapshotList);
    
    if(timeLogSnapshotList.size() > 0) {
        insert timeLogSnapshotList;
    }
}