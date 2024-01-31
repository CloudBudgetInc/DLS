/**************
        - To suspend the Instructor_Student Users in Moodle
        - Created by HL on Dec 31 2021
        - Logic moved from "Suspend Instructor_Student User Moodle" flow to here to fix the issue related to "Number of iterations exceeded"
        - In Zapier we can invoke only 100 API calls for an hour., so we added query limit as 40 here
    *****************************/

global class SuspendMoodleUser_Batch implements Database.batchable<sObject>,Database.AllowsCallouts,Database.Stateful { 

    global Database.QueryLocator start(Database.BatchableContext info){   
        
        System_Values__c last_Access_Days_Ins = System_Values__c.getValues('Moodle Last Access Days for Suspend');
        Integer last_Access_Days_Val_Ins;
        
        if(last_Access_Days_Ins != NULL && last_Access_Days_Ins.Value__c != NULL){
            last_Access_Days_Val_Ins = Integer.valueOf(last_Access_Days_Ins.Value__c);
        }
        Date last_Accessed_Date_Ins = System.today() - last_Access_Days_Val_Ins;
        
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
        
        String conQuery = 'SELECT Id, Name, Moodle_Sync_Status__c, Moodle_User_Status__c, RecordType.DeveloperName FROM Contact';
        conQuery += ' WHERE Moodle_User_Id__c != null AND Moodle_User_Status__c = \'Active\' AND RecordType.DeveloperName IN (\'Candidate\',\'Student\',\'Commercial_Client\',\'USG_Client\')';
        conQuery += ' AND (Moodle_Last_Accessed_Date__c = null OR';
        conQuery += ' (RecordType.DeveloperName IN (\'Candidate\',\'Commercial_Client\',\'USG_Client\') AND Moodle_Last_Accessed_Date__c <= : last_Accessed_Date_Ins) OR';
        conQuery += ' (RecordType.DeveloperName = \'Student\'))';
        conQuery += ' ORDER BY Moodle_Last_Accessed_Date__c ASC LIMIT 40';
        //System.debug(':::conQuery::::'+conQuery);
        
        return Database.getQueryLocator(conQuery);        
    }
    
    global void execute(Database.BatchableContext info, List<Contact > contacts){
                
        if(contacts.size() > 0){
        
            List<Contact> updateContacts = new List<Contact>();
            Map<Id, Date> stdIdAndEnrollmentDate = new Map<Id, Date>();
            Date lastDayFromEnrollmentDate = System.today() - 90;
            
            for(Contact_Assignments__c ca : [SELECT Id, Enrollment_End_Date__c, Candidate_Name__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN : contacts AND RecordType.DeveloperName = 'Student' AND Status__c IN ('Planned','Active') AND Enrollment_End_Date__c != null ORDER BY CreatedDate DESC]){
                if(!stdIdAndEnrollmentDate.containsKey(ca.Candidate_Name__c)){
                    stdIdAndEnrollmentDate.put(ca.Candidate_Name__c, ca.Enrollment_End_Date__c);
                }
            }
            
            for(Contact c : contacts){
                
                if(c.RecordType.DeveloperName != 'Student' || (c.RecordType.DeveloperName == 'Student' && (!stdIdAndEnrollmentDate.containsKey(c.Id) || (stdIdAndEnrollmentDate.containsKey(c.Id) && stdIdAndEnrollmentDate.get(c.Id) <= lastDayFromEnrollmentDate)))){
                    c.Moodle_Sync_Status__c = 'Pending';
                    c.Moodle_User_Status__c = 'Check';
                    updateContacts.add(c);
                }
            } 
            
            if(updateContacts.size() > 0){
                update updateContacts;  
            }
        }
    }
    
    global void finish(Database.BatchableContext info){
    
    }
}