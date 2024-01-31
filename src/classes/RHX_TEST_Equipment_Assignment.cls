@isTest(SeeAllData=true)
public class RHX_TEST_Equipment_Assignment {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Equipment_Assignment__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Equipment_Assignment__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}