@isTest
private class GetApproval_RejectionCommentsCtrl_Test{
    
    @testSetup static void setupMethod(){
        
        List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'FALSE')};
        Insert sysVal;    
        List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        Test.startTest();
            List<Events__c> events = TestClassUtil.createTestEvent();
        Test.stopTest();
    }
    
    private static testMethod void myTest(){
    
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName IN ('Student') LIMIT 1];
        
        Id reqPDORTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' LIMIT 1];
        projects[0].Project_Manager__c = usrId;
        update projects[0];
        
        Test.startTest();
        
        Planned_Days_Off__c pdo = new Planned_Days_Off__c(Contact__c=stdCon[0].Id, From_Date__c=System.today().addDays(5),To_Date__c=System.today().addDays(6), Description__c='Test Desc1',RecordTypeId = reqPDORTId, Status__c = 'Draft', Type__c='Student', Project__c = projects[0].Id);
        insert pdo;    
        
        pdo.Status__c = 'Approved';
        update pdo;
        
        GetApproval_RejectionCommentsCtrl getComment = new GetApproval_RejectionCommentsCtrl();
        getComment.pdoId = pdo.Id;
        getComment.setpdoId(pdo.Id);
        getComment.getpdoId();
        
        System.debug('::comments:::'+getComment.comments);
        System.debug('::stepStatus:::'+getComment.stepStatus);
    }
}