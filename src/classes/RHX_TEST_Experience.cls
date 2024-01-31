@isTest(SeeAllData=true)
public class RHX_TEST_Experience {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Experience__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Experience__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}