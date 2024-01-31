@isTest(SeeAllData=true)
public class RHX_TEST_AcctSeed_Scheduled_Revenue_E189 {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM AcctSeed__Scheduled_Revenue_Expense__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new AcctSeed__Scheduled_Revenue_Expense__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}