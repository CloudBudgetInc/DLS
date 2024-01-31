/***********
    - Created by HL on Dec 31 2021
    - Schdeuler to call SuspendMoodleUser_Batch class
    - Scheduled on daily basis
        ****************/
global class SuspendMoodleUser_Scheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
    
        System_Values__c last_Access_Days_Ins = System_Values__c.getValues('Moodle Last Access Days for Suspend');
        Integer last_Access_Days_Val_Ins;
        
        if(last_Access_Days_Ins != NULL && last_Access_Days_Ins.Value__c != NULL){
            last_Access_Days_Val_Ins = Integer.valueOf(last_Access_Days_Ins.Value__c);
        }
        Date last_Accessed_Date_Ins = system.today() - last_Access_Days_Val_Ins;
        
        // Commented on June 23 2023
        // W-007820 - Update Suspend Student User in Moodle from 2 years to 90 days
        // To update the suspension of Student Users in Moodle based on Enrollment End Date instead of LastAccessedDate
        /*
            System_Values__c last_Access_Days_Std = System_Values__c.getValues('Moodle Last Access Days_Student');
            Integer last_Access_Days_Val_Std;
            
            if(last_Access_Days_Std != NULL && last_Access_Days_Std.Value__c != NULL){
                last_Access_Days_Val_Std = Integer.valueOf(last_Access_Days_Std.Value__c);
            }
            Date last_Accessed_Date_Std = system.today() - last_Access_Days_Val_Std;
        */
        List<Contact> contactRecords = [SELECT Id, Name 
                                            FROM Contact
                                            WHERE Moodle_User_Id__c != null AND Moodle_User_Status__c = 'Active' AND 
                                                RecordType.DeveloperName IN ('Candidate','Student', 'Commercial_Client', 'USG_Client') AND (Moodle_Last_Accessed_Date__c = null OR
                                                (RecordType.DeveloperName IN ('Candidate','Commercial_Client','USG_Client') AND Moodle_Last_Accessed_Date__c <= : last_Accessed_Date_Ins) OR 
                                                (RecordType.DeveloperName = 'Student')) 
                                                ORDER BY Moodle_Last_Accessed_Date__c ASC];
        //system.debug('::::::::contactRecords:::::'+contactRecords.size());  
        
        if(contactRecords.size() > 0){
        
            System_Values__c batch_Size = System_Values__c.getValues('Suspend Moodle User Batch Size');
            Integer batch_Size_Val;
            if(batch_Size != NULL && batch_Size.Value__c != NULL){
                batch_Size_Val = Integer.valueOf(batch_Size.Value__c);
            }
            SuspendMoodleUser_Batch suspendMoodleUser = new SuspendMoodleUser_Batch();
            Database.ExecuteBatch(suspendMoodleUser, batch_Size_Val);    
        }  
    }    
}