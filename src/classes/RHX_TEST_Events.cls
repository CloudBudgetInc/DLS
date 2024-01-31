@isTest(SeeAllData=true)
public class RHX_TEST_Events {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Events__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Events__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}