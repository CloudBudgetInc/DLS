@isTest(SeeAllData=true)
public class RHX_TEST_AcctSeed_Time_Card_Day {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM AcctSeed__Time_Card_Day__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new AcctSeed__Time_Card_Day__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}