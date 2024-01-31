@isTest(SeeAllData=true)
public class RHX_TEST_Material_Rating {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Material_Rating__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Material_Rating__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}