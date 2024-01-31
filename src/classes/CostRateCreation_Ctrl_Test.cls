@isTest
private class CostRateCreation_Ctrl_Test{

    @testSetup static void setupMethod(){ 
    
        List<Contact_Assignments__c> conAssList = TestClassUtil.createTestContactAssignment();
        List<Labor_Cost_Rate_Master__c> masterRecs = TestClassUtil.createTestCostRatesMaster();
        Test.startTest();
            List<AcctSeed__Cost_Rates__c> costrateList = TestClassUtil.createTestCostRates();   
            List<AcctSeed__Project_Task__c> projTasks = TestClassUtil.createTestProjectTask();
        Test.stopTest();
    }
    
    // To cover getExistingCRInfo() method for these  'DLI-21 SCA CD' rate type 
    private static testMethod void myTest1(){
    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
       
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        Test.startTest();
        if(conAss.size() > 0 && costRateList.size() > 0){
            
            costRateList[0].AcctSeed__Hourly_Cost__c = 2;
            costRateList[0].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[0].Rate_Type__c = 'DLI-21 SCA LT';
            update costRateList;
                        
            CostRateCreation_Ctrl.getExistingCRInfo(conAss[0].Candidate_Name__c, 'DLI-21 SCA CD',null,null,null);
            
            costRateList[0].Rate_Type__c = 'DLI-21 SCA CD';
            costRateList[0].Non_Billable_Payroll_Item__c = 'BLE';
            update costRateList;
            
            CostRateCreation_Ctrl.MultiplePayRateExistingCRDetails existingCR = CostRateCreation_Ctrl.getExistingCRInfo(conAss[0].Candidate_Name__c, 'DLI-21 SCA CD', conAss[0].Project__c,'AcctSeed__Project__c',null);
            Map<String,ContactAssignmentDomain.MultiplePayRateCostRate> multiplePayRatMap = existingCR.MultiplePayRateCR;
            system.assertEquals(multiplePayRatMap.get('DLI-21 SCA CD').crId, costRateList[0].Id);  
        }
        Test.stopTest();
    }
     
    // To cover getExistingCRInfo() method for 'DLI-21 SCA MTT' and 'DLI-20 SCA MTT' rate type 
    private static testMethod void myTest1a(){
    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
       
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        Test.startTest();
        
        if(conAss.size() > 0 && costRateList.size() > 0){
            costRateList[0].AcctSeed__Hourly_Cost__c = 2;
            costRateList[0].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[0].Rate_Type__c = 'DLI-21 SCA LT';
            update costRateList;
            
            CostRateCreation_Ctrl.getExistingCRInfo(conAss[0].Candidate_Name__c, 'DLI-21 SCA MTT', null,null,null);
            
            costRateList[0].Rate_Type__c = 'DLI-21 SCA MTT';
            costRateList[0].Non_Billable_Payroll_Item__c = 'BLE';
            update costRateList;
            
            CostRateCreation_Ctrl.MultiplePayRateExistingCRDetails existingCR = CostRateCreation_Ctrl.getExistingCRInfo(conAss[0].Candidate_Name__c, 'DLI-21 SCA MTT', conAss[0].Project__c,'AcctSeed__Project__c',null);
            Map<String,ContactAssignmentDomain.MultiplePayRateCostRate> multiplePayRatMap = existingCR.MultiplePayRateCR;
            system.assertEquals(multiplePayRatMap.get('DLI-21 SCA MTT').crId, costRateList[0].Id);  
        }
        Test.stopTest();
    }
    
     // To cover getExistingCRInfo() method for 'LT' and 'Non-SCA CD' rate type 
    private static testMethod void myTest1aa(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        Test.startTest();
        
        if(conAss.size() > 0 && costRateList.size() > 0){
            costRateList[0].AcctSeed__Hourly_Cost__c = 2;
            costRateList[0].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[0].Rate_Type__c = 'LT with Prep';
            update costRateList;
            
            CostRateCreation_Ctrl.getExistingCRInfo(conAss[0].Candidate_Name__c, 'LT with Prep', null,null,null);
            
            costRateList[0].Rate_Type__c = 'Non-SCA CD';
            costRateList[0].Payroll_Item__c = 'ADM';
            update costRateList;
            
            CostRateCreation_Ctrl.MultiplePayRateExistingCRDetails existingCR = CostRateCreation_Ctrl.getExistingCRInfo(conAss[0].Candidate_Name__c, 'Non-SCA CD', conAss[0].Project__c,'AcctSeed__Project__c',null);
            Map<String,ContactAssignmentDomain.MultiplePayRateCostRate> multiplePayRatMap = existingCR.MultiplePayRateCR;
            system.assertEquals(multiplePayRatMap.get('Non-SCA CD').crId, costRateList[0].Id);  
        }
        
        Test.stopTest();
    }
    
    // To cover getExistingCRInfo() method  to get FT Salary Benfits
    private static testMethod void myTest1b(){
    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Exempt_Status__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
       
        Test.startTest();
        
        if(conAss.size() > 0 && costRateList.size() > 0){
            
            costRateList[0].Annual_Salary_Cost__c  = 90;
            costRateList[0].Salary_Cost_Per_Hour__c  = 90;
            costRateList[0].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[0].Rate_Type__c = 'FT Salary & Benefits';
            costRateList[0].Exempt_Status__c = 'Exempt';
            costRateList[0].Non_Billable_Payroll_Item__c = 'BLE';
            update costRateList;
            
            CostRateCreation_Ctrl.MultiplePayRateExistingCRDetails existingCR = CostRateCreation_Ctrl.getExistingCRInfo(conAss[0].Candidate_Name__c, 'DLI-16 SCA CD', conAss[0].Project__c,'AcctSeed__Project__c',null);
            Map<String,ContactAssignmentDomain.MultiplePayRateCostRate> multiplePayRatMap = existingCR.MultiplePayRateCR;
            
            if(multiplePayRatMap.size() > 0){
                system.assertEquals(multiplePayRatMap.get('FT Salary & Benefits').crId, costRateList[0].Id); 
            }
            
        }
        Test.stopTest();
    }
    
    // To cover getContactRelatedcR() method 
    private static testMethod void myTest2(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Exempt_Status__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        Test.startTest();
        
        if(conAss.size() > 0 && costRateList.size() > 0){
            
            costRateList[0].contact__c = conAss[0].Candidate_Name__c;
            update costRateList;
            
            List<AcctSeed__Cost_Rates__c> crList =  CostRateCreation_Ctrl.getContactOrAccountRelCR(conAss[0].Candidate_Name__c,true,null);
            system.assertEquals(true , crList.size() > 0); 
        }
        
        Test.stopTest();
    }

    // To cover transInterPretPTExistingCR() method for 'Non-SCA Translation (Per Hour) rate type 
    private static testMethod void myTest3(){
    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Translation (per hr)'];
        
        Test.startTest();
        
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 2];
        
        if(costRateList.size() > 0 && conAss.size() > 0 && task.size() > 0){
            
            costRateList[0].AcctSeed__Hourly_Cost__c = 90;
            costRateList[0].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[0].Rate_Type__c = 'Non-SCA Translation (Per Hour)';
            
            costRateList[1].AcctSeed__Hourly_Cost__c = 29;
            costRateList[1].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[1].Rate_Type__c = 'Non-SCA Translation (Per Hour)';
            
            update costRateList;
            
            CostRateCreation_Ctrl.transIntrepretExistingCRDetails existingCR = CostRateCreation_Ctrl.transInterPretPTExistingCR(task[0].Id, conAss[0].Candidate_Name__c);
            Map<String,Map<String, List<ContactAssignmentDomain.MultiplePayRateCostRate>>> multiPayCR = existingCR.tIExistingCRMap;
            System.assertEquals(multiPayCR.containsKey('Non-SCA Translation (Per Hour)'),true);
        }
        
        Test.stopTest();
    }
    
     // To cover transInterPretPTExistingCR() method for 'FT Salary & Benefits' rate type 
    private static testMethod void myTest3a(){
    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Translation (per hr)'];
        
        Test.startTest();
        
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 2];
        
        if(costRateList.size() > 0 && conAss.size() > 0 && task.size() > 0){
            
            costRateList[0].Annual_Salary_Cost__c  = 20;
            costRateList[0].Salary_Cost_Per_Hour__c  = 30;
            costRateList[0].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[0].Rate_Type__c = 'FT Salary & Benefits';
            costRateList[0].Exempt_Status__c = 'Exempt';
            costRateList[0].Non_Billable_Payroll_Item__c = 'BLE';
            
            
            costRateList[1].Annual_Salary_Cost__c  = 90;
            costRateList[1].Salary_Cost_Per_Hour__c  = 90;
            costRateList[1].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[1].Rate_Type__c = 'FT Salary & Benefits';
            costRateList[1].Exempt_Status__c = 'Exempt';
            costRateList[1].Non_Billable_Payroll_Item__c = 'BLE';
            
            update costRateList;
            
            CostRateCreation_Ctrl.transIntrepretExistingCRDetails existingCR = CostRateCreation_Ctrl.transInterPretPTExistingCR(task[0].Id, conAss[0].Candidate_Name__c);
            Map<String,Map<String, List<ContactAssignmentDomain.MultiplePayRateCostRate>>> multiPayCR = existingCR.tIExistingCRMap;
            System.assertEquals(multiPayCR.get('Non-SCA Translation (Per Hour)').containsKey('FTSalaryBenefits'),true);
        }
        
        Test.stopTest();
    }
    // To cover transInterPretPTExistingCR() method for 'Non-SCA Translation Editing Only (Per Word)' and ' 'Non-SCA Translation Editing Only (Per Word)'
    private static testMethod void myTest3b(){
            
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Default_Cost_Rate_Rate_Type__c = 'Non-SCA Translation (Per Word)'];
        
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 2];
        
        Test.startTest();
        
        if(costRateList.size() > 0 && conAss.size() > 0 && task.size() > 0){
            
            costRateList[0].Annual_Salary_Cost__c  = 90;
            costRateList[0].Salary_Cost_Per_Hour__c  = 90;
            costRateList[0].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[0].Rate_Type__c = 'Non-SCA Translation W/O Editing (Per Word)';
            
            costRateList[1].Annual_Salary_Cost__c  = 90;
            costRateList[1].Salary_Cost_Per_Hour__c  = 90;
            costRateList[1].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[1].Rate_Type__c = 'Non-SCA Translation Editing Only (Per Word)';
            update costRateList;
            
            CostRateCreation_Ctrl.transIntrepretExistingCRDetails existingCR = CostRateCreation_Ctrl.transInterPretPTExistingCR(task[0].Id, conAss[0].Candidate_Name__c);
            Map<String,Map<String, List<ContactAssignmentDomain.MultiplePayRateCostRate>>> multiPayCR = existingCR.tIExistingCRMap;
            System.assertEquals(multiPayCR.containsKey('Non-SCA Translation (Per Word)'),true);
        }
        
        Test.stopTest();
    }
    
    // To cover transInterPretPTExistingCR() method
    private static testMethod void myTest3c(){
            
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];

        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training'];
        
        Test.startTest();
        
        if(costRateList.size() > 0 && conAss.size() > 0 && task.size() > 0){
            
            task[0].Default_Cost_Rate_Rate_Type__c = '';
            update task[0];
            
            costRateList[0].Contact__c = conAss[0].Candidate_Name__c;
            update costRateList;
            
            CostRateCreation_Ctrl.transIntrepretExistingCRDetails existingCR = CostRateCreation_Ctrl.transInterPretPTExistingCR(task[0].Id, conAss[0].Candidate_Name__c);
            Map<String,Map<String, List<ContactAssignmentDomain.MultiplePayRateCostRate>>> multiPayCR = existingCR.tIExistingCRMap;
            System.assertEquals(multiPayCR.containsKey('Empty PTDefaultCR'),true);
            
        }
        Test.stopTest();
    }
    
    
    // To cover otherExistingCRInfo() method for Non-SCA Testing RateType
    private static testMethod void myTest4(){
            
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'Non-SCA Testing' LIMIT 1];
      
        
        Test.startTest();
        if(conAss.size() > 0 && costRateList.size() > 0){
            
            costRateList[0].Contact__c = conAss[0].Candidate_Name__c;
            update costRateList;
            
            ContactAssignmentDomain.CostRateDetails existingCR = CostRateCreation_Ctrl.otherExistingCRInfo('Non-SCA Testing', 'DLI_W_LT_Projects', 'AcctSeed__Project__c', conAss[0].Candidate_Name__c);
            ContactAssignmentDomain.CostRateDetails cRDetails  = CostRateCreation_Ctrl.otherExistingCRInfo('Non-SCA Testing', 'DLI_W_TO_Opportunities', 'Opportunity', conAss[0].Candidate_Name__c);
            system.assertEquals('Please enter the amount this Contact should be paid for each test completed on this Project',cRDetails.costRateMessage);
        }
        
        Test.stopTest();
    }
    // To cover otherExistingCRInfo() method
    private static testMethod void myTest4b(){
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' AND LastName='StaffContact' LIMIT 1];
        List<AcctSeed__Cost_Rates__c> coratList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c  = 'FT Salary & Benefits' LIMIT 2];
        
        Test.startTest();
        
      
        if(conList.size() > 0 && coratList.size() > 0){
            
            coratList[0].Contact__c = conList[0].Id;
            update coratList;
            
            ContactAssignmentDomain.CostRateDetails cRDetails  = CostRateCreation_Ctrl.otherExistingCRInfo('Non-SCA MTT (1099)', 'DLI_W_TO_Opportunities', 'Opportunity', conList[0].Id);
            system.assertEquals('This Contact\'s FT Salary & Benefits Cost Rate has been assigned for this Project Task. Please contact HR if you have any questions or concerns.',cRDetails.costRateMessage);
        }
        Test.stopTest();
    }
    // To cover otherExistingCRInfo() method
    private static testMethod void myTest4c(){
     
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c,Cost_Rate_Name__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        Test.startTest();
        if(conAss.size() > 0 && costRateList.size() > 0){
            costRateList[0].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[0].Rate_Type__c = 'DLI-21 SCA LT';
            costRateList[0].Non_Billable_Payroll_Item__c = 'BLE';

            update costRateList;
            
            CostRateCreation_Ctrl.otherExistingCRInfo('DLI-20 SCA LT', 'DLI_W_LT_Projects', 'AcctSeed__Project__c',conAss[0].Candidate_Name__c);
            ContactAssignmentDomain.CostRateDetails cRDetails  = CostRateCreation_Ctrl.otherExistingCRInfo('Non-SCA MTT (1099)', 'DLI_W_TO_Opportunities', 'AcctSeed__Project__c', conAss[0].Candidate_Name__c);
            system.assertEquals('Please enter Effective Date and Hourly Cost to create a "Non-SCA MTT (1099)" Type Cost Rate. If you have any questions, please contact HR.',cRDetails.costRateMessage);
        }
        
        Test.stopTest();
    }
    // To cover otherExistingCRInfo() method
    private static testMethod void myTest4e(){
            
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND Name = 'Test Contact1' LIMIT 1];
          
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
             
        Test.startTest();
        if(conList.size() > 0 && costRateList.size() > 0){
            
            costRateList[0].Contact__c = conList[0].Id;
            costRateList[0].Rate_Type__c = 'Non-SCA MTT (1099)';
            costRateList[0].Status__c = 'Rejected';
            costRateList[0].Non_Billable_Payroll_Item__c = 'BLE';
            update costRateList;
            
            CostRateCreation_Ctrl.otherExistingCRInfo('Non-SCA MTT (1099)', 'DLI_W_TO_Opportunities', 'Opportunity', conList[0].Id);
            ContactAssignmentDomain.CostRateDetails cRDetails =  CostRateCreation_Ctrl.otherExistingCRInfo('Non-SCA MTT (1099)', 'DLI_W_LT_Projects', 'AcctSeed__Project__c', conList[0].Id);
            system.assertEquals('Please enter Effective Date and Hourly Cost to create a "Non-SCA MTT (1099)" Type Cost Rate. If you have any questions, please contact HR.',cRDetails.costRateMessage);
        }
        Test.stopTest();
    }   
    
    // To cover otherExistingCRInfo() method
    private static testMethod void myTest4f(){
               
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND Name = 'Test Contact1' LIMIT 1];
        
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        Test.startTest();
        if(conList.size() > 0 && costRateList.size() > 0){
            
            costRateList[0].Contact__c = conList[0].Id;
            costRateList[0].Non_Billable_Payroll_Item__c = 'BLE';
            update costRateList;
            
            ContactAssignmentDomain.CostRateDetails cRDetails = CostRateCreation_Ctrl.otherExistingCRInfo('Non-SCA MTT (1099)', 'DLI_W_TO_Opportunities', 'Opportunity', conList[0].Id);
            system.assertEquals(false,cRDetails.createNewCR);
        }
        Test.stopTest();
    }  
    
    // To cover otherExistingCRInfo() method
    private static testMethod void myTest4g(){
            
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND Name = 'Test Contact1' LIMIT 1];
        
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        Test.startTest();
        if(conList.size() > 0 && costRateList.size() > 0){
            
            CostRateCreation_Ctrl.otherExistingCRInfo('Non-SCA MTT (1099)', 'DLI_W_LT_Projects', 'AcctSeed__Project__c', conList[0].Id);
            ContactAssignmentDomain.CostRateDetails cRDetails = CostRateCreation_Ctrl.otherExistingCRInfo('Non-SCA MTT (1099)', 'DLI_W_TO_Opportunities', 'Opportunity', conList[0].Id);
            system.assertEquals(false,cRDetails.createNewCR);
        }
        Test.stopTest();
    }
    // To cover otherExistingCRInfo() method
    private static testMethod void myTestFSI(){
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND Name = 'Test Contact1' LIMIT 1]; 
        
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        Test.startTest();
        if(conList.size() > 0 && costRateList.size() > 0){
            ContactAssignmentDomain.CostRateDetails cRDetails = CostRateCreation_Ctrl.otherExistingCRInfo('FSI', 'FSI_Projects', 'AcctSeed__Project__c', conList[0].Id);
            system.assertEquals(true,cRDetails.createNewCR);
        }
        Test.stopTest();
    }
    
    // This method to create Non-SCA Testing cost rate from project page
    private static testMethod void myTest5(){
    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
                
        ContactAssignmentDomain.CostRateCreationInputWrapper wrap = new ContactAssignmentDomain.CostRateCreationInputWrapper();
        wrap.getHourlyCost = '60';
        
        ContactAssignmentDomain.CostRateCreationInputWrapper wrap1 = new ContactAssignmentDomain.CostRateCreationInputWrapper();
        wrap1.perTestCost = 60;
        
        if(conAss.size() > 0){
            Test.startTest();
            CostRateCreation_Ctrl.createLaborCR('Non-SCA Testing', conAss[0].Project__c, JSON.serialize(wrap), conAss[0].Candidate_Name__c,null,false);
            String crJSON = CostRateCreation_Ctrl.createLaborCR('Non-SCA Testing', conAss[0].Project__c, JSON.serialize(wrap1), conAss[0].Candidate_Name__c,null,false);            
            List<AcctSeed__Cost_Rates__c> costRateList = (List<AcctSeed__Cost_Rates__c>) JSON.deserialize(crJSON, List<AcctSeed__Cost_Rates__c>.class);
            if(costRateList.size() > 0){
                system.assertEquals('Non-SCA Testing',costRateList[0].Rate_Type__c);
            }
            
            Test.stopTest();
        }
    }
    
    // This method to create Non-SCA Testing cost rate from opportunity page
    private static testMethod void myTest5a(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Opportunity_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        ContactAssignmentDomain.CostRateCreationInputWrapper wrap = new ContactAssignmentDomain.CostRateCreationInputWrapper();
        wrap.getHourlyCost = '20';
        wrap.isOppInsCA = TRUE;
        
        ContactAssignmentDomain.CostRateCreationInputWrapper wrap1 = new ContactAssignmentDomain.CostRateCreationInputWrapper();
        wrap1.perTestCost = 30;
        wrap.isOppInsCA = TRUE;
        
        if(conAss.size() > 0){
            Test.startTest();
            CostRateCreation_Ctrl.createLaborCR('Non-SCA Testing', conAss[0].Opportunity_Name__c, JSON.serialize(wrap), conAss[0].Candidate_Name__c,null,false);
            String crJSON = CostRateCreation_Ctrl.createLaborCR('Non-SCA Testing', conAss[0].Opportunity_Name__c, JSON.serialize(wrap1), conAss[0].Candidate_Name__c,null,false);
            
            List<AcctSeed__Cost_Rates__c> costRateList = (List<AcctSeed__Cost_Rates__c>) JSON.deserialize(crJSON, List<AcctSeed__Cost_Rates__c>.class);
            if(costRateList.size() > 0){
                system.assertEquals('Non-SCA Testing',costRateList[0].Rate_Type__c);
            }
            Test.stopTest();
        }
    }
    
    
   // This method to create 'Non-SCA Translation (Per Hour)' cost rate from project page
    private static testMethod void myTest5b(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        ContactAssignmentDomain.CostRateCreationInputWrapper wrap = new ContactAssignmentDomain.CostRateCreationInputWrapper();
        wrap.effectiveDate = String.valueOf(Date.Today());
        wrap.getHourlyCost = '60';
        wrap.selectedTIRateType = 'Non-SCA Translation (Per Hour)';
        wrap.ftSalRt = FALSE;
        wrap.isFirstCR = FALSE;
        
        Test.startTest();
        
        if(conAss.size() > 0){
            String crJSON = CostRateCreation_Ctrl.createLaborCR('Non-SCA Translation (Per Hour)', conAss[0].Project__c, JSON.serialize(wrap), conAss[0].Candidate_Name__c,null,false);
            
            List<AcctSeed__Cost_Rates__c> costRateList = (List<AcctSeed__Cost_Rates__c>) JSON.deserialize(crJSON, List<AcctSeed__Cost_Rates__c>.class);
            if(costRateList.size() > 0){
                system.assertEquals('Non-SCA Translation (Per Hour)',costRateList[0].Rate_Type__c);
            }
        }
        Test.stopTest();
    }
    
   // This method to create 'Non-SCA Translation (FFP)' cost rate from project page
    private static testMethod void myTest5c(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        ContactAssignmentDomain.CostRateCreationInputWrapper wrap = new ContactAssignmentDomain.CostRateCreationInputWrapper();
        wrap.effectiveDate = String.valueOf(Date.Today());
        wrap.getperFFP = '60';
        wrap.selectedTIRateType = 'Non-SCA Translation (FFP)';
        wrap.ftSalRT = TRUE;
        wrap.isFirstCR = FALSE;
        wrap.createNonSCALT = FALSE;
        
        Test.startTest();
        
        if(conAss.size() > 0){
            
            String crJSON = CostRateCreation_Ctrl.createLaborCR('Non-SCA Translation (FFP)', conAss[0].Project__c, JSON.serialize(wrap), conAss[0].Candidate_Name__c,null,false);
            
            List<AcctSeed__Cost_Rates__c> costRateList = (List<AcctSeed__Cost_Rates__c>) JSON.deserialize(crJSON, List<AcctSeed__Cost_Rates__c>.class);
            if(costRateList.size() > 0){
                system.assertEquals('Non-SCA Translation (FFP)',costRateList[0].Rate_Type__c);
            }
        }
        Test.stopTest();
    }
        
    // To cover createLaborCR() method for 'Non-SCA Translation W/O Editing (Per Word)'
    private static testMethod void myTest5d(){
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];

        
        ContactAssignmentDomain.CostRateCreationInputWrapper wrap = new ContactAssignmentDomain.CostRateCreationInputWrapper();
        wrap.effectiveDate = String.valueOf(Date.Today());
        wrap.selectedTIRateType = 'Non-SCA Translation W/O Editing (Per Word)';
        wrap.ftSalRT = TRUE;
        wrap.perWordCost = 20;
        wrap.isFirstCR = TRUE;
        
        Test.startTest();
        
        String crJSON =  CostRateCreation_Ctrl.createLaborCR('Non-SCA Translation W/O Editing (Per Word)', conAss[0].Project__c, JSON.serialize(wrap), conAss[0].Candidate_Name__c,null,false);
        List<AcctSeed__Cost_Rates__c> costRateList = (List<AcctSeed__Cost_Rates__c>) JSON.deserialize(crJSON, List<AcctSeed__Cost_Rates__c>.class);
        if(costRateList.size() > 0){
            system.assertEquals('Non-SCA Translation W/O Editing (Per Word)',costRateList[0].Rate_Type__c);
        }
        Test.stopTest();
    }
    // This method to create 'LT' cost rate from project page
    private static testMethod void myTest5e(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        ContactAssignmentDomain.CostRateCreationInputWrapper wrap = new ContactAssignmentDomain.CostRateCreationInputWrapper();
        wrap.effectiveDate = String.valueOf(Date.Today());
        wrap.getHourlyCost = '60';
        wrap.salaryCostPerHour = 60;
        wrap.annualcost = 12;
        wrap.perWordCost = 10;
        wrap.taxType = 'LT with Prep';
        wrap.selectedTIRateType = 'LT with Prep';
        wrap.ftSalRt = FALSE;
        wrap.isFirstCR = FALSE;
        
        Test.startTest();
        
        if(conAss.size() > 0){
            String crJSON = CostRateCreation_Ctrl.createLaborCR('LT with Prep', conAss[0].Project__c, JSON.serialize(wrap), conAss[0].Candidate_Name__c,null,false);
            
            List<AcctSeed__Cost_Rates__c> costRateList = (List<AcctSeed__Cost_Rates__c>) JSON.deserialize(crJSON, List<AcctSeed__Cost_Rates__c>.class);
            if(costRateList.size() > 0){
                system.assertEquals('LT with Prep',costRateList[0].Rate_Type__c);
            }
        }
        Test.stopTest();
    }
    // This method to create ' 'FT & Salary Benefit\'s' cost rate from project page
    private static testMethod void myTest5f(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        ContactAssignmentDomain.CostRateCreationInputWrapper wrap = new ContactAssignmentDomain.CostRateCreationInputWrapper();
        wrap.effectiveDate = String.valueOf(Date.Today());
        wrap.selectedTIRateType = 'FT & Salary Benefit\'s';
        wrap.ftSalRt = true;
        wrap.annualCost = 20;
        
        Test.startTest();
        
        if(conAss.size() > 0){
            String crJSON = CostRateCreation_Ctrl.createLaborCR('FT & Salary Benefit\'s', conAss[0].Project__c, JSON.serialize(wrap), conAss[0].Candidate_Name__c,null,false);
            
            List<AcctSeed__Cost_Rates__c> costRateList = (List<AcctSeed__Cost_Rates__c>) JSON.deserialize(crJSON, List<AcctSeed__Cost_Rates__c>.class);
            if(costRateList.size() > 0){
                system.assertEquals('FT & Salary Benefit\'s',costRateList[0].Rate_Type__c);
            }
        }
        Test.stopTest();
    }
    private static testMethod void myTest6(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        List<Account> accRecs = [SELECT Id FROM Account LIMIT 1];
        ContactAssignmentDomain.CostRateCreationInputWrapper wrap = new ContactAssignmentDomain.CostRateCreationInputWrapper();
        wrap.effectiveDate = String.valueOf(Date.Today());
        wrap.ftSalRt = FALSE;
        wrap.getHourlyCost = '20';
        
        Test.startTest();
        
        if(conAss.size() > 0 && accRecs.size() > 0){
            conAss[0].Account__c = accRecs[0].Id;
            update conAss[0];
            
            String crJSON = CostRateCreation_Ctrl.createLaborCR('SubK-LT', conAss[0].Project__c, JSON.serialize(wrap), null ,accRecs[0].Id,true);
            
            List<AcctSeed__Cost_Rates__c> costRateList = (List<AcctSeed__Cost_Rates__c>) JSON.deserialize(crJSON, List<AcctSeed__Cost_Rates__c>.class);
            if(costRateList.size() > 0){
                system.assertEquals( 'SubK-LT',costRateList[0].Rate_Type__c);
            }
        }
        Test.stopTest();
    }
    // This method to create 'DLI-W LTT' cost rate from project page
    private static testMethod void myTest5z(){  
        
        try{
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
            
            ContactAssignmentDomain.CostRateCreationInputWrapper wrap = new ContactAssignmentDomain.CostRateCreationInputWrapper();
            wrap.effectiveDate = String.valueOf(Date.Today());
            wrap.getHourlyCost = '60';
            wrap.selectedTIRateType = 'DLI-W LT';
            wrap.ftSalRt = FALSE; 
            wrap.isFirstCR = FALSE;
            
            Test.startTest();
            
            if(conAss.size() > 0){
                String crJSON = CostRateCreation_Ctrl.createLaborCR('DLI-W LT', conAss[0].Project__c, JSON.serialize(wrap), conAss[0].Candidate_Name__c,null,false);
                
                List<AcctSeed__Cost_Rates__c> costRateList = (List<AcctSeed__Cost_Rates__c>) JSON.deserialize(crJSON, List<AcctSeed__Cost_Rates__c>.class);
                if(costRateList.size() > 0){
                    system.assertEquals('DLI-W LT',costRateList[0].Rate_Type__c);
                }
            }
            Test.stopTest();
            
        }catch(exception ex){
            
        } 
    }
        // To cover getExistingCRInfo() method for 'DLI-W PS - Group 3' and 'DLI-W PS - Group 4' rate type 
    private static testMethod void myTestDLIPSGrp(){ 
    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
       
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        Test.startTest();
        
        if(conAss.size() > 0 && costRateList.size() > 0){
            costRateList[0].AcctSeed__Hourly_Cost__c = 2;
            costRateList[0].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[0].Rate_Type__c = 'DLI-W PS - Group 3';
            costRateList[0].Non_Billable_Payroll_Item__c = 'BLE';
            
            update costRateList;
            
            CostRateCreation_Ctrl.getExistingCRInfo(conAss[0].Candidate_Name__c, 'DLI-W PS - Group 3', null,'Opportunity',null);
            
            costRateList[0].Rate_Type__c = 'DLI-W PS - Group 4';
            update costRateList;
            
            CostRateCreation_Ctrl.MultiplePayRateExistingCRDetails existingCR = CostRateCreation_Ctrl.getExistingCRInfo(conAss[0].Candidate_Name__c, 'DLI-W PS - Group 4', conAss[0].Project__c,'AcctSeed__Project__c',null);
            Map<String,ContactAssignmentDomain.MultiplePayRateCostRate> multiplePayRatMap = existingCR.MultiplePayRateCR;
            
            if(multiplePayRatMap.containsKey('DLI-W PS - Group 4')){
                system.assertEquals(multiplePayRatMap.get('DLI-W PS - Group 4').crId, costRateList[0].Id);  
            }
        } 
        Test.stopTest();
    }
    
    private static testMethod void insDetailsMethod_Test(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Project_Task__c, Status__c, Opportunity_Product_Id__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        Map<Id, List<SelectOption>> conIdCRMap = new Map<Id, List<SelectOption>>();
        conIdCRMap.put(conAss[0].Candidate_Name__c, new List<SelectOption>());
        
        contactAssignmentTranslator.insDetailsMethod(conAss, conIdCRMap);
    }
    
    private static testMethod void getCAListView_Test(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Record_Type_Developer_Name__c, 
            Candidate_Name__r.firstname, Candidate_Name__r.lastname, Candidate_Name__r.name, Start_Date__c, End_Date__c,
            Status__c, Assignment_Position__c, RecordTypeId, RecordType.DeveloperName
             FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        contactAssignmentTranslator.getCAListView(conAss, conAss[0].Project__c, 'instructor', conAss[0].Candidate_Name__c);
    }
     // To cover getExistingCRInfo() method for 'LT'
    private static testMethod void myTestLTWithoutPrep(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        Test.startTest();
        
        if(conAss.size() > 0 && costRateList.size() > 0){
            costRateList[0].AcctSeed__Hourly_Cost__c = 2;
            costRateList[0].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[0].Rate_Type__c = 'LT without Prep';
            update costRateList;
            
            CostRateCreation_Ctrl.getExistingCRInfo(conAss[0].Candidate_Name__c, 'LT without Prep', conAss[0].Project__c,'Opportunity',null);
            
            CostRateCreation_Ctrl.MultiplePayRateExistingCRDetails existingCR = CostRateCreation_Ctrl.getExistingCRInfo(conAss[0].Candidate_Name__c, 'LT without Billable Prep', conAss[0].Project__c,'AcctSeed__Project__c',null);
            Map<String,ContactAssignmentDomain.MultiplePayRateCostRate> multiplePayRatMap = existingCR.MultiplePayRateCR;
            system.assertEquals(multiplePayRatMap.get('LT without Prep').crId, costRateList[0].Id);  
        }
        
        Test.stopTest();
    }
     // To cover getExistingCRInfo() method for 'LT With Prep
    private static testMethod void myTestLTWithPrep(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c,Opportunity_Name__c,Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Opportunity_Name__c != null LIMIT 1];
        
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        Test.startTest();
        
        if(conAss.size() > 0 && costRateList.size() > 0){
            costRateList[0].AcctSeed__Hourly_Cost__c = 2;
            costRateList[0].Contact__c = conAss[0].Candidate_Name__c;
            costRateList[0].Rate_Type__c = 'DLI-W PS - Group 3';
            update costRateList;
			CostRateCreation_Ctrl.getExistingCRInfo(conAss[0].Candidate_Name__c, 'DLI-W PS - Group 3', conAss[0].Project__c,'Opportunity',null);
            costRateList[0].Cost_Rate_Name__c = 'LT with Billable Prep 11';
            update costRateList;
            CostRateCreation_Ctrl.MultiplePayRateExistingCRDetails existingCR = CostRateCreation_Ctrl.getExistingCRInfo(conAss[0].Candidate_Name__c, 'LT with Billable Prep', conAss[0].Project__c,'AcctSeed__Project__c',null);
            Map<String,ContactAssignmentDomain.MultiplePayRateCostRate> multiplePayRatMap = existingCR.MultiplePayRateCR;
            
            if(multiplePayRatMap.containsKey('LT With Prep')){
                system.assertEquals(multiplePayRatMap.get('LT With Prep').crId, costRateList[0].Id);  
            }
        }
        
        Test.stopTest();
    }
}