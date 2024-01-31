@isTest
private class LCRStatusUpdationBatch_Test{

    @testSetup static void setupMethod(){
    
        Test.startTest();
            List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
    }
    
    private static testMethod void myTest1(){
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        List<AcctSeed__Cost_Rates__c>  priorCostRate = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 20,Payroll_Item__c='R',Per_Test_Cost__c = 20, Expiration_Date__c = System.today()),
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 30,Payroll_Item__c='R',Per_Test_Cost__c = 20, Expiration_Date__c = System.today())
        };
        Test.startTest();
        
            insert priorCostRate;
            
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Prior_Version__c = priorCostRate[1].Id, Pay_Type__c = 'Hourly', Status__c = 'Approved', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
            };
            insert costrateList;
            
            priorCostRate[0].Status__c = 'Draft';
            priorCostRate[1].Status__c = 'Draft';
            update priorCostRate;
            
            List<AcctSeed__Cost_Rates__c> cost = [SELECT Id FROM AcctSeed__Cost_Rates__c WHERE Id IN :priorCostRate];
            // Schedule coverage
            String CRON_EXP = '0 0 22 * * ? *';
            LCRStatusUpdationBatch_Schedule sch = new LCRStatusUpdationBatch_Schedule();
            system.schedule('LCR And CA updation batch', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    public static testMethod void testMethod2() {
                                             
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        List<AcctSeed__Cost_Rates__c>  priorCostRate = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 20,Payroll_Item__c='R',Per_Test_Cost__c = 20, Expiration_Date__c = System.today()),
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 30,Payroll_Item__c='R',Per_Test_Cost__c = 20, Expiration_Date__c = System.today())
        };
            
        Test.startTest();
        
            insert priorCostRate;
            
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Prior_Version__c = priorCostRate[1].Id, Pay_Type__c = 'Hourly', Status__c = 'Approved', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
            };
            insert costrateList;            
            
            priorCostRate[0].Status__c = 'Approved';
            priorCostRate[1].Status__c = 'Approved';
            update priorCostRate;
            
            List<AcctSeed__Cost_Rates__c> rates = [SELECT Id, Status__c FROM AcctSeed__Cost_Rates__c WHERE Id IN :priorCostRate];
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Rate_Card_Rate__c, Start_Date__c, End_Date__c, Status__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
            System.debug('conAss========##'+conAss.size());
            
            conAss[0].Rate_Card_Rate__c  = rates[1].Id;
            conAss[0].Candidate_Name__c= conList[0].Id;
            conAss[0].End_Date__c = System.today();
            update conAss[0];
                        
            // Schedule coverage
            String CRON_EXP = '0 0 22 * * ? *';
            LCRStatusUpdationBatch_Schedule sch = new LCRStatusUpdationBatch_Schedule();
            system.schedule('LCR And CA updation batch', CRON_EXP, sch);
           
        Test.stopTest();
    }
    
    public static testMethod void testMethod3() {
                                             
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        
        List<AcctSeed__Cost_Rates__c>  priorCostRate = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 30,Payroll_Item__c='R',Per_Test_Cost__c = 20, Expiration_Date__c = System.today())
        };
            
        Test.startTest();
        
            insert priorCostRate;
            
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Prior_Version__c = priorCostRate[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Approved', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
            };
            insert costrateList;            
            
            priorCostRate[0].Status__c = 'Approved';
            update priorCostRate;
                        
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Rate_Card_Rate__c, Start_Date__c, End_Date__c, Status__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c IN ('Active','Planned') LIMIT 2];
            System.debug('conAss========##'+conAss.size());
            
            conAss[0].Rate_Card_Rate__c  = priorCostRate[0].Id;
            conAss[0].Candidate_Name__c= conList[0].Id;
            conAss[0].End_Date__c = System.today();
            
            conAss[1].Start_Date__c  = System.today().addDays(1);
            conAss[1].Rate_Card_Rate__c  = costrateList[0].Id;
            conAss[1].Candidate_Name__c= conList[0].Id;
            conAss[1].End_Date__c =  System.today().adddays(2);
            conAss[1].Status__c =  'Planned';
            update conAss;
                        
            // Schedule coverage
            String CRON_EXP = '0 0 22 * * ? *';
            LCRStatusUpdationBatch_Schedule sch = new LCRStatusUpdationBatch_Schedule();
            system.schedule('LCR And CA updation batch', CRON_EXP, sch); 
            
            LCRStatusUpdationBatch testBatch = new LCRStatusUpdationBatch();
            Database.executeBatch(testBatch);
            
        Test.stopTest();
        
        List<AcctSeed__Cost_Rates__c> rates1 = [SELECT Id, Status__c FROM AcctSeed__Cost_Rates__c WHERE Id IN :priorCostRate];
        System.assertEquals('Inactive', rates1[0].Status__c);
        
        List<Contact_Assignments__c > conAss1 = [SELECT Id, Status__c FROM Contact_Assignments__c WHERE Id = :conAss[1].Id];
        System.assertEquals('Active', conAss1[0].Status__c);
    }
    public static testMethod void testMethod4() {
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        
        List<AcctSeed__Cost_Rates__c>  priorCostRate = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 30,Payroll_Item__c='R',Per_Test_Cost__c = 20, Expiration_Date__c = System.today())
                };
                    
                    Test.startTest();
        
        insert priorCostRate;
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Prior_Version__c = priorCostRate[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Approved', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
                };
                    insert costrateList;            
        
        priorCostRate[0].Status__c = 'Approved';
        update priorCostRate;
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Rate_Card_Rate__c, Start_Date__c, End_Date__c, Status__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 2];
        System.debug('conAss========##'+conAss.size());
        
        conAss[0].Rate_Card_Rate__c  = priorCostRate[0].Id;
        conAss[0].Candidate_Name__c= conList[0].Id;
        conAss[0].End_Date__c = System.today();
        
        conAss[1].Start_Date__c  = System.today().addDays(1);
        conAss[1].Rate_Card_Rate__c  = costrateList[0].Id;
        conAss[1].Candidate_Name__c= conList[0].Id;
        conAss[1].End_Date__c =  System.today().adddays(2);
        conAss[1].Status__c =  'Planned';
        update conAss;
        
        // Schedule coverage
        String CRON_EXP = '0 0 22 * * ? *';
        LCRStatusUpdationBatch_Schedule sch = new LCRStatusUpdationBatch_Schedule();
        system.schedule('LCR And CA updation batch', CRON_EXP, sch); 
        
        LCRStatusUpdationBatch testBatch = new LCRStatusUpdationBatch();
        Database.executeBatch(testBatch);
        
        Test.stopTest();
        
        List<AcctSeed__Cost_Rates__c> rates1 = [SELECT Id, Status__c FROM AcctSeed__Cost_Rates__c WHERE Id IN :priorCostRate];
        System.assertEquals('Inactive', rates1[0].Status__c);
        
        List<Contact_Assignments__c > conAss1 = [SELECT Id, Status__c FROM Contact_Assignments__c WHERE Id = :conAss[1].Id];
        System.assertEquals('Planned', conAss1[0].Status__c);
    }
    
}