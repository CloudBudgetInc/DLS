@isTest
public class CreateDeliveryOrderController_Test {
   /*W-002025 Create button: “Create Delivery Order” Child Contract record from an Existing Parent Contract record*/
   // Created by Siva Prasanth on June 17,2019
    @testsetup static void setup() {
        Test.StartTest();
        List<Contract> contractList = TestClassUtil.createTestContracts(); 
        List<Language__c> langList = TestClassUtil.createTestLanguages();
        Test.Stoptest(); 
    }
    //This method to check if parent contract level is parent or not
    private static testMethod void testMethod1() {
        List<Contract> contractLst = [SELECT Id,Contract_Level__c FROM Contract LIMIT 1];
        
        if(contractLst.size() > 0){
            // if Parent Contract level is not parent,then returns false;
            Test.StartTest();
            CreateDeliveryOrderController.isContractLevelisParent(contractLst[0].Id);
            Test.Stoptest(); 
            // if Parent Contract level is parent,then returns true;
            contractLst[0].Contract_Level__c = 'Parent';
            update contractLst;
            
            Boolean isParentLevel = CreateDeliveryOrderController.isContractLevelisParent(contractLst[0].Id);
            System.assertEquals(true, isParentLevel);
        }
    }
    // This method to get Language Lookup Records
    private static testMethod void testMethod2() {
        List<Language__c>  langLst =  CreateDeliveryOrderController.getLookupRecords('English','Language__c','Name','',new List<String>());
        if(langLst.size() > 0){
            System.assertEquals('English', langLst[0].Name);
        }
    }
    // This method to insert child Contract and prepopulate default field values and autopopulate field values from Parent Contract fields
    private static testMethod void testMethod3() {
        List<Language__c>  langLst = [SELECT Id FROM Language__c LIMIT 1];
        List<Contract> parentContractLst = [SELECT Id,AccountId,ContractNumber FROM Contract LIMIT 1];
        parentContractLst[0].Contract_Level__c = 'Parent';
        update parentContractLst;
        
        List<Contract> childContractList = new List<Contract> {
             new Contract(Task_Order__c ='1', TOR__c = 'tor', StartDate = system.today(), EndDate = system.today().addDays(5),Language__c = (langLst.size() > 0 ? langLst[0].Id : null))
        };                
        if(parentContractLst.size() > 0) {
            String childContractId = CreateDeliveryOrderController.saveNewContract(JSON.serialize(childContractList),parentContractLst[0].Id);
            List<Contract> childContract = [SELECT Id,TOR__c FROM Contract WHERE Id = :childContractId];
            if(childContract.size() > 0){
                System.assertEquals('tor', childContract[0].TOR__c);
            }
        }
    }
}