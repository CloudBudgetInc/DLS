public class TimeSnapshotService {
    
    public static string fields = 'Id,Time_Card_Day__c,createdDate,CreatedBy.Name,Date__c,Hours__c,Internal_Comment__c,Total_Hours_Before_Approved__c,TCD_Status__c,TCD_New_Status__c,Invoice_Comment__c,'+ 
                                       'Time_Card_Line__c,Time_Card_Line__r.AcctSeed__Project_Task__c,End_Time1__c,End_Time2__c,Start_Time1__c,Start_Time2__c,Late_Cancellation__c,'+
                                       'Time_Card_Line__r.AcctSeed__Project_Task__r.Name,Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,Notes__c,Note_Type__c,'+
                                       'Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c,Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.DLS_Class__c,'+
                                       'Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,Reference_Id__c,Time_Card_Day__r.Total_Hours_Before_Approved__c,Time_Card_Day__r.AcctSeed__Date__c';
     
     /**********************************************************************
        Created by Sukanya on May 2 2019: This method return list of time snapshots
        @tcdIds - time card day record ids
        return - list of Time Card Day records
    ***********************************************************************/
    public Static List<Accounting_Seed_Time_Snapshot__c> getSnpshotWithDaysIds(Set<Id> tcdIds) {
        String snapshotQry = 'SELECT '+fields+' FROM Accounting_Seed_Time_Snapshot__c';
        
        if(tcdIds.size() > 0){
            snapshotQry += ' WHERE Time_Card_Day__c IN :tcdIds ORDER BY CreatedDate DESC';
        }
                                   
        return database.query(snapshotQry);
    }
}