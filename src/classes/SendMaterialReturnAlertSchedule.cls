/**********************************************************************
    Created by Vinitha on August 30, 2017: Scheduler class used for calling "SendMaterialReturnAlert" batch class.
***********************************************************************/
public class SendMaterialReturnAlertSchedule implements Schedulable {

    //public static String Sched = '0 0 8 * * ? ';  //Every Day at 8AM 
       
    public void execute(SchedulableContext sc) {
        
        Boolean Batchexe = false;
        Date todaydate = system.today();
        Date oneWeekBefore = system.today().adddays(7);
        
        Map<Id, AcctSeed__Project__c> projMap = new Map<Id, AcctSeed__Project__c>([
            SELECT Id, Name 
                FROM AcctSeed__Project__c 
                WHERE Id IN (SELECT Project__c FROM Materials_Request__c WHERE RecordType.DeveloperName ='Material_Loan_Request') AND 
                    Id IN (SELECT Project__c FROM Contact_Assignments__c WHERE End_Date__c = :todaydate OR End_Date__c = :oneWeekBefore)
        ]);
        System.debug('projMap::::::::'+projMap);
        
        //Scheduled on Batch Execution Before 1 week of Contact Assignment End Date && on end date
        if(projMap != NULL && projMap.size() > 0){
            Batchexe = true;
        }
        
        if(Batchexe){
            SendMaterialReturnAlert BatchJob = new SendMaterialReturnAlert();
            ID batchprocessid = Database.executeBatch(BatchJob);  
        }      
    }    
}