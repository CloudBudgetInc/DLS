/* Developed by Shalini on June 27 2017 for "ManageCLINcontroller" */

@isTest
public class ManageCLINcontroller_Test {
    
    @testSetup static void setup() {
        List<CLIN__c> getclins = TestClassUtil.createTestClin();
    }
    
    public static testmethod void test1() {
        //CLIN__c clinRec = new CLIN__c(CLIN_Name__c="Test 1", CLIN_Type__c="T&M", CLIN_Max_Quantity__c=30, CLIN_Unit__c="Days", CLIN_Unit_Price__c=50, CLIN_Start_Date__c=system.today(), CLIN_End_Date__c=system.today().addDays(7), Contract__c=clin.contractId);
        Test.startTest();
            
            List<CLIN__c> clinList = [SELECT Id, Contract__c, Name, CLIN_Name__c FROM CLIN__c LIMIT 5];
            
            ApexPages.StandardController sc = new ApexPages.StandardController(clinList[0]);
            ManageCLINcontroller clinCtrl = new ManageCLINcontroller(sc);
            
            String newClinStr = '[{"clinName":"Test 2","contractId":"'+clinList[0].Contract__c+'"}]';
            String updateClinStr = '[{"Contract__c":"'+clinList[0].Contract__c+'","Id":"'+clinList[0].Id+'","CLIN_Name__c":"'+clinList[0].CLIN_Name__c+'","CLIN_Max_Quantity__c":20.0}]';
            
            ManageCLINcontroller.getCLINrecs(clinList[0].Contract__c);
            ManageCLINcontroller.getContractInfo(clinList[0].Contract__c);
            ManageCLINcontroller.picklistvalues('CLIN__c','CLIN_Type__c');
            ManageCLINcontroller.getAllCLINs(clinList[0].Contract__c);
            ManageCLINcontroller.createCLIN(newClinStr, updateClinStr);
            ManageCLINcontroller.deleteCLIN(updateClinStr);
            ManageCLINcontroller.getAllContracts();
            
        Test.stopTest();
    }
}