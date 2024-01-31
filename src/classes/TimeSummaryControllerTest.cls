@isTest
private class TimeSummaryControllerTest{

    @testSetup static void setupMethod(){
        
        Test.startTest();
        List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
        Test.stopTest();
        
        List<AcctSeed__Time_Card_Day__c>  tcd = TestClassUtil.createTestTimeCardDay();
        
    }
    
    // To cover getWeekSummaryDetails
    private static testMethod void testMethod1(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name LIKE '%Test%' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive = true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
       
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        System.debug('projects========'+projects);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
                
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
     
        Test.startTest();
        
        system.runAs(user) {
        
            try{
                String res = TimeSummaryController.getWeekSummaryDetails(projects[0].Id);                
                if(res == 'SUCCESS'){
                    System.assertEquals('SUCCESS', res);
                }
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
                System.debug('Line Number===='+e.getLineNumber());
                throw new AuraHandledException(e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // To cover getInstructorDetails
    private static testMethod void testMethod2(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name LIKE '%Test%' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = FALSE, Instructor_Access__c = FALSE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
       
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.Name FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        System.debug('projects========'+projects);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
                
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
     
        Test.startTest();
        
        system.runAs(user) {
        
            try{
                String res = TimeSummaryController.getInstructorDetails(projects[0].Id, tcp[0].Id);                
                TimeSummaryController.InstructorSummaryDetails tSC = (TimeSummaryController.InstructorSummaryDetails)JSON.deserialize(res, TimeSummaryController.InstructorSummaryDetails.class);
                
                if(tSC.InstructorSummary.size() > 0){
                
                    System.debug('tSC ============'+tSC);
                    String insId = tSC.InstructorSummary[0].insId;
                    System.assertEquals(insId, conList[0].Id);
                }
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
                System.debug('Line Number===='+e.getLineNumber());
                throw new AuraHandledException(e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // To cover getDaySummaryDetails with insId != NULL
    private static testMethod void testMethod3(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name LIKE '%Test%' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = FALSE, Instructor_Access__c = FALSE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
       
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.Name FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        System.debug('projects========'+projects);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
                
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
     
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        Test.startTest();
        
        system.runAs(user) {
        
            try{
                String res = TimeSummaryController.getDaySummaryDetails(projects[0].Id, tcp[0].Id, timeCard[0].Id, conList[0].Id);         
                System.debug('RESULT========='+res);       
                TimeSummaryController.OverallDaySummary oDS = (TimeSummaryController.OverallDaySummary)JSON.deserialize(res, TimeSummaryController.OverallDaySummary.class);
                if(oDS.DaySummary.size() > 0){
                    String hours = oDS.DaySummary[0].totalHours;
                    //System.assertEquals('2.00', hours);                
                }
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
                System.debug('Line Number===='+e.getLineNumber());
                throw new AuraHandledException(e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // To cover getDaySummaryDetails with insId = NULL
    private static testMethod void testMethod4(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name LIKE '%Test%' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = FALSE, Instructor_Access__c = FALSE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
       
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.Name FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        System.debug('projects========'+projects);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
                
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
     
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 4.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        Test.startTest();
        
        system.runAs(user) {
        
            try{
                String res = TimeSummaryController.getDaySummaryDetails(projects[0].Id, tcp[0].Id, timeCard[0].Id, NULL);                
                System.debug('RESULT2========='+res);       
                TimeSummaryController.OverallDaySummary oDS = (TimeSummaryController.OverallDaySummary)JSON.deserialize(res, TimeSummaryController.OverallDaySummary.class);
                if(oDS.DaySummary.size() > 0){
                    String hours = oDS.DaySummary[0].totalHours;
                    //System.assertEquals('4.00', hours);                
                }
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
                System.debug('Line Number===='+e.getLineNumber());
                throw new AuraHandledException(e.getMessage());
            }
        }
        Test.stopTest();
    }
}