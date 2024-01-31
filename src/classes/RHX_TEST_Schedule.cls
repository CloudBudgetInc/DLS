@isTest(SeeAllData=true)
public class RHX_TEST_Schedule {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Schedule__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Schedule__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}