@isTest(SeeAllData=true)
public class RHX_TEST_Assessment_Report {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id
            FROM Assessment_Report__c WHERE Project__c != null LIMIT 1];
            
        List<sObject> projectList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        if(sourceList.size() == 0) {
            if(projectList.size() > 0) {
                sourceList.add(
                        new Assessment_Report__c(Project__c = projectList[0].Id)
                );
            }
        }
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}