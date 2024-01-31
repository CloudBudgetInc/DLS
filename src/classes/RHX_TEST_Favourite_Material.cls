@isTest(SeeAllData=true)
public class RHX_TEST_Favourite_Material {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Favourite_Material__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Favourite_Material__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}