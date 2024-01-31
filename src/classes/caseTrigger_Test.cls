@isTest
private class caseTrigger_Test {

    // Cover before insert event
    private static testMethod void testMethod1(){
    
        List<User> user = [SELECT ID, FirstName, MiddleName, LastName FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE];
        System.debug('user =============='+user);
        
        Contact con = new Contact();
        con.FirstName = user[0].FirstName;
        con.MiddleName = user[0].MiddleName;
        con.LastName = user[0].LastName;
        con.Email = 'mytestcase123@gmail.com';
        insert con;
        
        System.runAs(user[0]){
        
            Case newCaseRec = new Case(Subject = 'Case1',Description = 'Case Record',Priority = 'High',Type ='Problem');
            insert newCaseRec;
            
            Case caseRec = [SELECT Id, ContactId, Origin FROM Case WHERE Id = :newCaseRec.Id];
            System.debug('caseRec=========='+caseRec);
            
            system.assertEquals('Web', caseRec.Origin);
            system.assertEquals(con.Id, caseRec.ContactId);
        }
    }
    
    // Cover after insert event
    private static testMethod void testMethod2() {
    
        List<User> user = [SELECT Id, IsPortalEnabled FROM User WHERE Profile.Name = 'Instructor Community' AND ISActive = TRUE AND IsPortalEnabled = TRUE];
        System.debug('user =============='+user);
        
        System.runAs(user[0]){
        
            Case caseRec = new Case(Subject = 'Case1',Description = 'Case Record',Priority = 'High',Type ='Problem');
            insert caseRec;
            system.assertEquals('Problem',caseRec.type);
        }
    }
    
    // Cover after insert event
    private static testMethod void testMethod3() {
        
        CaseCreationController.isInvokeCaseAssign = TRUE;
        
        Case caseRec = new Case(Subject = 'Case1',Description = 'Case Record',Priority = 'High',Type ='Question');
        insert caseRec;
        system.assertEquals('Question',caseRec.type);
    }
    
    // Calculate Case's initial response time after a user submits a Case
    private static testMethod void testMethod4() {
                
        Case caseRec = new Case(Subject = 'Initial Case Response Time Test',Description = 'Case Record',Priority = 'High',Type ='Question', Status = 'New');
        insert caseRec;
        
        List<Case> updateCase = [SELECT Id, Status FROM Case WHERE Id =:caseRec.Id];
        updateCase[0].Status = 'Escalated';
        update updateCase[0];
    }
    
    // Cover Is_Send_Escalation_Reminder__c field updation logic
    private static testMethod void testMethod5() {
        
        Case caseRec = new Case(Subject = 'Initial Case Response Time Test',Description = 'Case Record',Priority = 'High',Type ='Question', Status = 'New', Is_Send_Escalation_Reminder__c = True);
        insert caseRec;
        
        List<Case> updateCase = [SELECT Id, Status FROM Case WHERE Id =:caseRec.Id];
        updateCase[0].Status = 'Escalated';
        update updateCase[0];
        
        Test.startTest();
        
            List<Case> updatedCaseRec = [SELECT Id, Is_Send_Escalation_Reminder__c FROM Case WHERE Id =:caseRec.Id]; 
            System.assertEquals(False, updatedCaseRec[0].Is_Send_Escalation_Reminder__c);   
        Test.stopTest();
    }
}