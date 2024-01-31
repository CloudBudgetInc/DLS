@isTest(SeeAllData=true)
public class RHX_TEST_AcctSeed_Fixed_Asset {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
            FROM AcctSeed__Fixed_Asset__c WHERE AcctSeed__Value__c != null LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new AcctSeed__Fixed_Asset__c(AcctSeed__Value__c = 0)
            );
        }
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}