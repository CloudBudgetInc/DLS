@isTest(SeeAllData=true)
public class RHX_TEST_Skill {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Skill__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Skill__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}