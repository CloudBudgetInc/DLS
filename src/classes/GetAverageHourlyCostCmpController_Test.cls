@isTest
private class GetAverageHourlyCostCmpController_Test{

    @testSetup static void setupMethod(){
    
        List<Language__c> languages = TestClassUtil.createTestLanguages();
        List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        Test.startTest();
            List<AcctSeed__Cost_Rates__c> costRates = TestClassUtil.createTestCostRates();
        Test.stopTest();
        List<Labor_Cost_Rate_Master__c> costrateMasterList = TestClassUtil.createTestCostRatesMaster();
    }
    
    private static testMethod void myTest1(){
    
        List<Language__c> languages = [SELECT Id, Name, Average_Hourly_Cost_LT_Cost_Rate__c, Average_Hourly_Cost_LT_without_Prep__c FROM Language__c LIMIT 1];
        languages[0].Average_Hourly_Cost_LT_Cost_Rate__c = 80;
        languages[0].Average_Hourly_Cost_LT_without_Prep__c = 20;
        update languages[0];
        System.debug('languages======='+languages);
        
        List<Contact> contacts = [SELECT Id, Language_1__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        System.debug('contacts======='+contacts);
        
        contacts[0].Language_1__c = languages[0].Name;
        update contacts[0];
                
        List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Contact__c, Rate_Type__c, Status__c FROM AcctSeed__Cost_Rates__c WHERE Contact__c != NULL AND Status__c = 'Approved' LIMIT 1];
        System.debug('costRates========'+costRates);
        
        Test.startTest();
        
            costRates[0].Contact__c = contacts[0].Id;
            costRates[0].Rate_Type__c = 'LT with Prep';
            update costRates;
            
            List<Labor_Cost_Rate_Master__c> crMaster = [SELECT Id, Name, Rate_Type__c, YTD_Merit_Increases__c FROM Labor_Cost_Rate_Master__c WHERE Rate_Type__c = :costRates[0].Rate_Type__c];
            System.debug('crMaster==================='+crMaster);
            crMaster[0].YTD_Merit_Increases__c = 3;
            crMaster[0].Annual_Merit_Budget__c = 5;
            update crMaster[0];
            
            GetAverageHourlyCostCmpController c = new GetAverageHourlyCostCmpController();
            c.languageNameValue = languages[0].Name;
            c.laborCostRateId = costRates[0].Id;
            System.debug('c HOURLY COST======='+c.hourlyCost);
            System.debug('c hourlyCost_WithoutPrep======='+c.hourlyCost_WithoutPrep);
            System.debug('lCRMRec_WithPrep======='+c.lCRMRec_WithPrep);
            System.debug('lCRMRec_WithoutPrep======='+c.lCRMRec_WithoutPrep);
            
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
        List<Language__c> languages = [SELECT Id, Name, Average_Hourly_Cost_LT_Cost_Rate__c FROM Language__c];
        System.debug('languages======='+languages);
        
        List<Contact> contacts = [SELECT Id, Language_1__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        System.debug('contacts======='+contacts);
        
        contacts[0].Language_1__c = languages[0].Name;
        update contacts[0];
        
        List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Contact__c, Rate_Type__c, Status__c FROM AcctSeed__Cost_Rates__c WHERE Contact__c != NULL AND Status__c = 'Approved' LIMIT 1];
        System.debug('costRates========'+costRates);
        
        Test.startTest();
        
            costRates[0].Contact__c = contacts[0].Id;
            costRates[0].Rate_Type__c = 'LT with Prep';
            update costRates;
            
            GetAverageHourlyCostCmpController c = new GetAverageHourlyCostCmpController();
            c.languageNameValue = 'Test';
            c.laborCostRateId = contacts[0].Id;
            System.debug('======hourlyCost '+c.hourlyCost);
            System.debug('c hourlyCost_WithoutPrep======='+c.hourlyCost_WithoutPrep);
            System.debug('lCRMRec_WithPrep======='+c.lCRMRec_WithPrep);
            System.debug('lCRMRec_WithoutPrep======='+c.lCRMRec_WithoutPrep);
        Test.stopTest();
    }
    
    private static testMethod void myTest3(){
    
        List<Language__c> languages = [SELECT Id, Name, Average_Hourly_Cost_LT_Cost_Rate__c FROM Language__c];
        System.debug('languages======='+languages);
        
        List<Contact> contacts = [SELECT Id, Language_1__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        System.debug('contacts======='+contacts);
        
        contacts[0].Language_1__c = languages[0].Name;
        update contacts[0];
        
        List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Contact__c, Rate_Type__c, Status__c FROM AcctSeed__Cost_Rates__c WHERE Contact__c != NULL AND Status__c = 'Approved' LIMIT 1];
        System.debug('costRates========'+costRates);
        
        Test.startTest();
        
            costRates[0].Contact__c = contacts[0].Id;
            costRates[0].Rate_Type__c = 'LT with Prep';
            update costRates;
            
            GetAverageHourlyCostCmpController c = new GetAverageHourlyCostCmpController();
            c.languageNameValue = NULL;
            c.laborCostRateId = NULL;
            System.debug('======hourlyCost '+c.hourlyCost);
            System.debug('c hourlyCost_WithoutPrep======'+c.hourlyCost_WithoutPrep);
            System.debug('lCRMRec_WithPrep======='+c.lCRMRec_WithPrep);
            System.debug('lCRMRec_WithoutPrep======='+c.lCRMRec_WithoutPrep);
        Test.stopTest();
    }
    
    private static testMethod void myTest4(){
    
        List<Language__c> languages = [SELECT Id, Name, Average_Hourly_Cost_LT_Cost_Rate__c FROM Language__c LIMIT 1];
        System.debug('languages======='+languages);
        
        List<Contact> contacts = [SELECT Id, Language_1__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        System.debug('contacts======='+contacts);
        
        contacts[0].Language_1__c = languages[0].Name;
        update contacts[0];
        
        List<Labor_Cost_Rate_Master__c> crMaster = [SELECT Id, Name, Rate_Type__c, YTD_Merit_Increases__c FROM Labor_Cost_Rate_Master__c WHERE Rate_Type__c = 'LT with Prep'];
        System.debug('crMaster==================='+crMaster);
        crMaster[0].YTD_Merit_Increases__c = 3;
        crMaster[0].Annual_Merit_Budget__c = 5;
        update crMaster[0];
        
        List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Contact__c, Rate_Type__c, Status__c FROM AcctSeed__Cost_Rates__c WHERE Contact__c != NULL AND Status__c = 'Approved' LIMIT 1];
        System.debug('costRates========'+costRates);
        
        Test.startTest();
        
            costRates[0].Contact__c = contacts[0].Id;
            costRates[0].Rate_Type__c = NULL;
            update costRates;
            
            GetAverageHourlyCostCmpController c = new GetAverageHourlyCostCmpController();
            c.languageNameValue = languages[0].Name;
            c.laborCostRateId = costRates[0].Id;
            System.debug('c HOURLY COST======='+c.hourlyCost);
            System.debug('c hourlyCost_WithoutPrep======='+c.hourlyCost_WithoutPrep);
            System.debug('lCRMRec_WithPrep======='+c.lCRMRec_WithPrep);
            System.debug('lCRMRec_WithoutPrep======='+c.lCRMRec_WithoutPrep);
        Test.stopTest();
    }
    
    private static testMethod void myTest5(){
                
        List<AcctSeed__Cost_Rates__c> priorCostRate = [SELECT Id, Contact__c, Rate_Type__c, Status__c FROM AcctSeed__Cost_Rates__c WHERE Contact__c != NULL AND Status__c = 'Approved' LIMIT 1];
        System.debug('priorCostRate========'+priorCostRate);
        
        List<Contact> conList = [SELECT Id, Language_1__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        System.debug('conList======='+conList);
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Prior_Version__c = priorCostRate[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Approved', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
        };
        
        Test.startTest();
        
            insert costrateList; 
        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Rate_Card_Rate__c, Start_Date__c, End_Date__c, Status__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
            System.debug('conAss========##'+conAss.size());
            
            conAss[0].Rate_Card_Rate__c  = costrateList[0].Id;
            conAss[0].Candidate_Name__c= costrateList[0].Contact__c;
            conAss[0].End_Date__c = System.today().addDays(30);
            update conAss[0];
            
            ContactAssignmentLightningCtrl.isFromCA = TRUE;
            
            GetAverageHourlyCostCmpController c = new GetAverageHourlyCostCmpController();
            c.laborCostRateId = costrateList[0].Id;
            System.debug('c HOURLY COST======='+c.conAssign);
            System.debug('lCRMRec_WithPrep======='+c.lCRMRec_WithPrep);
            System.debug('lCRMRec_WithoutPrep======='+c.lCRMRec_WithoutPrep);
        Test.stopTest();
    }
    
    private static testMethod void myTest6(){
                
        List<AcctSeed__Cost_Rates__c> priorCostRate = [SELECT Id, Contact__c, Rate_Type__c, Status__c FROM AcctSeed__Cost_Rates__c WHERE Contact__c != NULL AND Status__c = 'Approved' LIMIT 1];
        System.debug('priorCostRate========'+priorCostRate);
        
        List<Contact> conList = [SELECT Id, Language_1__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        System.debug('conList======='+conList);
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Prior_Version__c = priorCostRate[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Approved', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
        };
        
        Test.startTest();
        
            insert costrateList; 
            
            ContactAssignmentLightningCtrl.isFromCA = TRUE;
            
            GetAverageHourlyCostCmpController c = new GetAverageHourlyCostCmpController();
            c.laborCostRateId = costrateList[0].Id;
            System.debug('c HOURLY COST======='+c.conAssign);
            System.debug('hourlyCost_WithoutPrep======='+c.hourlyCost_WithoutPrep);
            System.debug('c HOURLY COST======='+c.hourlyCost);
        Test.stopTest();
    }
    
    private static testMethod void myTest7(){
        
        List<Contact> conList = [SELECT Id, Language_1__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        System.debug('conList======='+conList);
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Approved', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
        };
        
        Test.startTest();
        
            insert costrateList; 
            
            ContactAssignmentLightningCtrl.isFromCA = TRUE;
            
            GetAverageHourlyCostCmpController c = new GetAverageHourlyCostCmpController();
            c.laborCostRateId = costrateList[0].Id;
            System.debug('c HOURLY COST======='+c.conAssign);
            System.debug('hourlyCost_WithoutPrep======='+c.hourlyCost_WithoutPrep);
            System.debug('c HOURLY COST======='+c.hourlyCost);
        Test.stopTest();
    }
    
    private static testMethod void myTest8(){
        
        List<Contact> conList = [SELECT Id, Language_1__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        System.debug('conList======='+conList);
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Approved', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
        };
        
        Test.startTest();
        
            insert costrateList; 
            
            ContactAssignmentLightningCtrl.isFromCA = FALSE;
            
            GetAverageHourlyCostCmpController c = new GetAverageHourlyCostCmpController();
            c.laborCostRateId = costrateList[0].Id;
            System.debug('c HOURLY COST======='+c.conAssign);
            System.debug('hourlyCost_WithoutPrep======='+c.hourlyCost_WithoutPrep);
            System.debug('c HOURLY COST======='+c.hourlyCost);
        Test.stopTest();
    }
}