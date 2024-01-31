@isTest(SeeAllData=true)
public class RHX_TEST_Payment_Item {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Payment_Item__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Payment_Item__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}