@isTest(SeeAllData=true)
public class RHX_TEST_Known_Language {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Known_Language__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Known_Language__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}