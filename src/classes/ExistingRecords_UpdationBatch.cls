/*****************************************************************
- Batch to update the existing records values
- To populate Entered On Time, Entered Late, Submitted On time, Submitted Late for all TCL & TCD - Updated by Dhinesh on March 22 2023

*****************************************************************/

global class ExistingRecords_UpdationBatch implements Database.batchable<Sobject>,Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String snapshotQry = '';
        
        if(!Test.isRunningTest()){
            snapshotQry = 'SELECT Id,Name,CreatedDate FROM Accounting_Seed_Time_Snapshot__c WHERE CreatedDate >= 2023-04-01T00:00:00z AND CreatedDate <= 2023-08-01T00:00:00z AND CreatedById = \'00560000003Co3bAAC\'';
        }else {
            snapshotQry = 'SELECT Id,Name,CreatedDate FROM Accounting_Seed_Time_Snapshot__c LIMIT 1';
        }
        return Database.getQueryLocator(snapshotQry);
    }
    
    global void execute(Database.BatchableContext BC, List<Accounting_Seed_Time_Snapshot__c> snapshotRecords){
    
        System.debug('::::snapshotRecords::::'+snapshotRecords.size());
        
        if(snapshotRecords.size() > 0){
            delete snapshotRecords;
        }    
    }
    
    global void finish(Database.BatchableContext BC){
       
    }
}