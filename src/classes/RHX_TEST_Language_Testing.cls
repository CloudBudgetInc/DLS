@isTest(SeeAllData=true)
public class RHX_TEST_Language_Testing {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Language_Testing__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Language_Testing__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}