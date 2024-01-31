@isTest(SeeAllData=true)
public class RHX_TEST_AcctSeed_Billing_Line {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
            FROM AcctSeed__Billing_Line__c LIMIT 1];
        if(sourceList.size() == 0) {
            List<sObject> billing = [SELECT Id FROM AcctSeed__Billing__c LIMIT 1];
            sourceList.add(
                    new AcctSeed__Billing_Line__c(AcctSeed__Billing__c = billing.size() > 0 ? billing[0].Id : null,AcctSeed__Rate__c = 50.50)
            );
        }
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}