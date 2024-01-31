@isTest(SeeAllData=true)
public class RHX_TEST_Contact_Affiliation {
  static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
      FROM Contact_Affiliation__c ORDER BY LastModifiedDate DESC LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Contact_Affiliation__c()
            );
        }
      rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}