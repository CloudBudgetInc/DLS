@isTest(SeeAllData=true)
public class RHX_TEST_Deployed_Instructor {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Deployed_Instructor__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Deployed_Instructor__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}