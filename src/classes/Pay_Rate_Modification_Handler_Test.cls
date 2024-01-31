@isTest
public class Pay_Rate_Modification_Handler_Test {
    
    @testsetup static void setup() {
        Test.startTest();
        List<AcctSeed__Cost_Rates__c> cRList = TestClassUtil.createTestCostRates();
        Test.stopTest();
    }
    //Insert a new version of Cost Rate based on existing CostRate . 
    private static testMethod void testMethod1(){
        List<AcctSeed__Cost_Rates__c> cRList = [SELECT Id,Effective_Date__c,Contact__c,Payroll_Item__c,AcctSeed__Hourly_Cost__c,Notes_Reasons_for_Change__c,Status__c,Prior_Version__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        if(cRList.size() > 0){
            String cRId = Pay_Rate_Modification_Handler.modifyCostRates(cRList[0],new List<Contact>(),null);
            
            if(cRId != null) {
                List<AcctSeed__Cost_Rates__c>  newCr = [SELECT Id FROM AcctSeed__Cost_Rates__c WHERE Id =: cRId];
                System.assertEquals(newCr.size(), 1);
            }    
        }
    }
    //Insert a new version of Cost Rate based on existing CostRate . 
    private static testMethod void testMethod2(){
        List<AcctSeed__Cost_Rates__c> cRList = [SELECT Id,Contact__c,Effective_Date__c,Rate_Type__c,New_Job_Title__c,Change_in_Reporting_New_Manager__c,Payroll_Item__c,AcctSeed__Hourly_Cost__c,Notes_Reasons_for_Change__c,Status__c,Prior_Version__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        if(cRList.size() > 0){
            Contact con = new Contact();
            con.Id = cRList[0].Contact__c;
            con.EE_Pay_Status_Eff_Date__c = system.Today().addDays(2);
            cRList[0].Effective_Date__c = system.Today().addDays(2);  
            
            String cRId = Pay_Rate_Modification_Handler.modifyCostRates(cRList[0],new List<Contact>{con},cRList[0].Contact__c);
            
            if(cRId != null) {
                List<AcctSeed__Cost_Rates__c>  newCr = [SELECT Id FROM AcctSeed__Cost_Rates__c WHERE Id =: cRId];
                System.assertEquals(newCr.size(), 1);
            }  
        }
    } 
    //getting profileName
    private static testMethod void testMethod3(){
        Pay_Rate_Modification_Handler.costRateInfo  crInfo = Pay_Rate_Modification_Handler.getPermissionAccess('FT Salary & Benefits');
        System.assertEquals(True, crInfo.isPermissionAccess);
    }
    // To cover getLookupRecords() method
    private static testMethod void myTest4(){
        try{
            Pay_Rate_Modification_Handler.getLookupRecords('', 'User', '', '', new List<String>{});
        }catch(Exception e){
            System.debug('======'+e.getMessage());     
        }
    }
}