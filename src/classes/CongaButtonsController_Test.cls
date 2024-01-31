@isTest
private class CongaButtonsController_Test {
    
    @testsetup static void setup() {
        Test.startTest();
        List<Contact_Assignments__c> caList = TestClassUtil.createTestContactAssignment();
        List<AcctSeed__Project_Task__c> task = TestClassUtil.createTestProjectTask();
        Test.stopTest();
        List<AcctSeed__Cost_Rates__c> crList = TestClassUtil.createTestCostRates();
        List<APXTConga4__Conga_Template__c> congaTemp = TestClassUtil.createCongaTemplate();
    } 
    
    // Create the Cover Page 
    private static testMethod void testMethod1() {
        
        List<AcctSeed__Project__c> proList = [SELECT Id, Name, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c != null];
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Cover Page for Project'),
                new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Cover Page')
                };
                    insert congaTemp;
        
        List<APXTConga4__Conga_Merge_Query__c > congaQuery = new List<APXTConga4__Conga_Merge_Query__c> {
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Room Query For Cover Letter'),
                new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Schedule Query for Project Cover Letter')
                };
                    insert congaQuery;
        
        if(proList.size() > 0) {
            Test.startTest();
            CongaButtonsController.congaWrapper wrap = new CongaButtonsController.congaWrapper();
            
            CongaButtonsController.createCoverPageConga(proList[0].AcctSeed__Opportunity__c, 'Room Query For Cover Letter,Schedule Query for Project Cover Letter', 'Cover Page,Cover Page for Project');
            
            wrap = CongaButtonsController.createCoverPageConga(proList[0].Id, 'Room Query For Cover Letter,Schedule Query for Project Cover Letter', 'Cover Page,Cover Page for Project');
            if(wrap != null)
                System.assertEquals(congaTemp[0].Id, wrap.congaWrap.tempNameIdMap.get('Cover Page for Project'));
            Test.stopTest();
        }
    }
    
    // DLI TOEP 
    private static testMethod void testMethod2() {
        
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'DLI TOEP')
                };
                    insert congaTemp;
        
        List<APXTConga4__Conga_Merge_Query__c > congaQuery = new List<APXTConga4__Conga_Merge_Query__c> {
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'DLI TOEP OPLI Sum'),
                new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'DLI TOEP Contact Query'),
                new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'DLI TOEP Work Experience Query')
                };
                    insert congaQuery;
        
        if(oppList.size() > 0) {
            Test.startTest();
            CongaButtonsController.congaWrapper wrap = new CongaButtonsController.congaWrapper();
            
            wrap = CongaButtonsController.dliToep(oppList[0].Id, 'DLI TOEP OPLI Sum,DLI TOEP Contact Query,DLI TOEP Work Experience Query', 'DLI TOEP');
            if(wrap != null)
                System.assertEquals(congaTemp[0].Id, wrap.congaWrap.tempNameIdMap.get('DLI TOEP'));
            Test.stopTest();
        }
    }
    
    // Generate Door Signs
    private static testMethod void testMethod3() {
        
        List<AcctSeed__Project__c> proList = [SELECT Id, Name, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c != null];
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Door Signs for Project')
                };
                    insert congaTemp;
        
        List<APXTConga4__Conga_Merge_Query__c > congaQuery = new List<APXTConga4__Conga_Merge_Query__c> {
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Schedule Query for Project Cover Letter'),
                new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Language Query for Door Signs')
                };
                    insert congaQuery;
        
        if(proList.size() > 0) {
            Test.startTest();
            CongaButtonsController.congaWrapper wrap = new CongaButtonsController.congaWrapper();
            wrap = CongaButtonsController.generateDoorSigns(proList[0].Id, 'Language Query for Door Signs,Schedule Query for Project Cover Letter', 'Door Signs for Project');
            if(wrap != null)
                System.assertEquals(congaTemp[0].Id, wrap.congaWrap.tempNameIdMap.get('Door Signs for Project'));
            Test.stopTest();
        }
    }
    
    // Gen & Send DocuSign
    private static testMethod void testMethod4() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name FROM Contact_Assignments__c LIMIT 2];
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null];
        
        if(conAssList.size() > 0 && costRateList.size() > 0) {
            Test.startTest();
            CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
            wrap = CongaButtonsController.genSendDocuSign(costRateList[0].Id);
            wrap = CongaButtonsController.genSendDocuSign(conAssList[0].Id);
            if(wrap != null) 
                System.assert(wrap.congaURL.contains('Please map a Rate Card rate'));
            Test.stopTest();
        }
    }
    
    //For Job Summary Report in Project
    private static testMethod void testMethod6() {
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
            
        List<AcctSeed__Project__c> proList = [SELECT Id FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+proList);
        
        Test.startTest();
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proList[0].Id LIMIT 1];
        System.debug('task ====='+task);
        
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c> {
            new AcctSeed__Project_Task__c(Name = 'Test Task',Billable__c = TRUE, Rate__c = 70, AcctSeed__Project__c = proList[0].Id,Project_Task_Type__c = 'Preparation time', Parent_Project_Task__c = task[0].Id, AcctSeed__Labor_GL_Account__c = task[0].AcctSeed__Labor_GL_Account__c)
        };
        
        insert projTask;
        
        conAss[0].Project_Task__c = projTask[0].Parent_Project_Task__c;
        update conAss[0];
        
        List<APXTConga4__Conga_Merge_Query__c > congaQuery = new List<APXTConga4__Conga_Merge_Query__c> {
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Project Query for Job Summary Report'),
                new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'ContactAssign Query for Job Summary Report')
                };
                    insert congaQuery;
        
        if(proList.size() > 0) {
            
            CongaButtonsController.congaWrapper wrap = new CongaButtonsController.congaWrapper();
            
            wrap = CongaButtonsController.jobSummaryReport(proList[0].Id,'Project Query for Job Summary Report,ContactAssign Query for Job Summary Report','Job Summary Report - Labor Actual');
            if(wrap!= null){
                List<APXTConga4__Conga_Template__c> congaTemp = [Select Id,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c  WHERE APXTConga4__Name__c = 'Job Summary Report - Labor Actual'];
                if(congaTemp.size() > 0){
                    System.assertEquals(congaTemp[0].Id, wrap.congaWrap.tempNameIdMap.get('Job Summary Report - Labor Actual'));
                }
            }
            Test.stopTest();
        }
    }
}