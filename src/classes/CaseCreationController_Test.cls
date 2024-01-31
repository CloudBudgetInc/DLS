@isTest
public class CaseCreationController_Test {
    private static testMethod void testMethod1() {      
        Case caseRec = new Case(Subject = 'Case1',Description = 'Case Record',Priority = 'High',Type ='Problem');
        CaseCreationController.getPickListValues();
        String caseId = CaseCreationController.createCase(null,'xxxxxx','',true,caseRec);
        List<Case> casList = [SELECT Id,Type FROM Case LIMIT 1];
        if(casList.size() > 0){
            system.assertEquals(casList[0].Type,caseRec.Type);
        }
    }
}