@isTest(SeeAllData=true)
public class RHX_TEST_TeamforcePro_Teamwork_Sub_Task {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM TeamforcePro__Teamwork_Sub_Task__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new TeamforcePro__Teamwork_Sub_Task__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}