@isTest
public class Contract_modification_Trigger_Test {
    @testSetup static void setup(){
        List<Contract> contractList = TestClassUtil.createTestContracts(); 
    }
    public static testMethod void myTest() {
        
        List<Contract> contList = [Select Id,Name From Contract Limit 2];
        
        List<Contract_Modification__c> contmodList = new List<Contract_Modification__c>{
            new Contract_Modification__c(Name = 'Test 1',of_Instructors_active__c = 5,of_Instructors_awarded__c = 10,Contract_Number__c = contList[0].Id),
            new Contract_Modification__c(Name = 'Test 2',of_Instructors_active__c = 10,of_Instructors_awarded__c = 20,Contract_Number__c = contList[1].Id)
        };
        insert contmodList; 
        
        contmodList[0].of_Instructors_active__c = 15;
        update contmodList;        
    }    
}