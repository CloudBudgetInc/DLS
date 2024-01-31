@isTest(SeeAllData=true)
public class RHX_TEST_TeamforcePro_TaskList {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM TeamforcePro__TaskList__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new TeamforcePro__TaskList__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}