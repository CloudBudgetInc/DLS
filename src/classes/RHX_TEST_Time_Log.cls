@isTest(SeeAllData=true)
public class RHX_TEST_Time_Log {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Time_Log__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Time_Log__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}