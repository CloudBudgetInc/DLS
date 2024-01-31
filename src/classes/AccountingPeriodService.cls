/**********************************************************************
    Created by Vinitha on Jan 10 2017: Service class used for AcctSeed__Accounting_Period__c object
***********************************************************************/

public class AccountingPeriodService {

     /**********************************************************************
        Created by Vinitha on Jan 10 2017: This method return list of AcctseedAccountingperiod 
        @monthStartdtSet - Set of AcctseedAccountingperiod records
        @monthEnddtSet - Set of AcctseedAccountingperiod records
        return - list of AcctseedAccountingperiod records
    ***********************************************************************/ 
    //Issuse occur when change date type to String type so doesnt change this method.
    public static list<AcctSeed__Accounting_Period__c> getAccountperiodRec(Set<Date> monthStartdtSet, Set<Date> monthEnddtSet) {
            
            List<AcctSeed__Accounting_Period__c> accPeriodlist = new List<AcctSeed__Accounting_Period__c>();
            
            if(monthStartdtSet != null && monthEnddtSet != null){
                accPeriodlist = [
                            SELECT
                                Id,
                                Name,
                                AcctSeed__Start_Date__c,
                                AcctSeed__End_Date__c,
                                AcctSeed__Status__c
                            FROM
                                AcctSeed__Accounting_Period__c
                            WHERE
                                AcctSeed__Start_Date__c IN :monthStartdtSet
                            AND AcctSeed__End_Date__c IN :monthEnddtSet
                            ];
            } 
            return accPeriodlist; 
            
    }
    
    /**********************************************************************
        Created by Vinitha on Jan 10 2017: This method return newly created list of AcctseedAccountingperiod 
        @accountPeriodlist - List of Acctseed Accounting period records
        return - list of AcctseedAccountingperiod records
    ***********************************************************************/ 
    
    public static list<AcctSeed__Accounting_Period__c> insertAccountingperiod(list<AcctSeed__Accounting_Period__c> accountPeriodlist) {
    
        if(accountPeriodlist != null && accountPeriodlist.size() > 0){
            insert accountPeriodlist;            
        }
        return accountPeriodlist;    
    }
    
    
}