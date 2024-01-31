@isTest(SeeAllData=true)
public class RHX_TEST_Get_Feedback {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Get_Feedback__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Get_Feedback__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}