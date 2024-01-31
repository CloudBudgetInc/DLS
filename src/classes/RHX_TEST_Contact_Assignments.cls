@isTest(SeeAllData=true)
public class RHX_TEST_Contact_Assignments {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Contact_Assignments__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Contact_Assignments__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}