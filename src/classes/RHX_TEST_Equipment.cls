@isTest(SeeAllData=true)
public class RHX_TEST_Equipment {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Equipment__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Equipment__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}