@isTest(SeeAllData=true)
public class RHX_TEST_AcctSeed_Project {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
            FROM AcctSeed__Project__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new AcctSeed__Project__c(TO__c = '376329',Project_Type__c = 'JMAS')
            );
        }
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}