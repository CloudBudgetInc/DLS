@isTest
public class Material_Trigger_Test {
    
    @testSetup static void setup(){
        List<Materials__c> materialList = TestClassUtil.createTestmaterials();
    }
    
    Static testMethod void testupateName(){
        Test.StartTest();
        List<Materials__c> matList = [Select Id,Name From Materials__c Limit 2];
        
        List<Materials__c> MaterialsList = new List<Materials__c>();
        
        MaterialsList = new List<Materials__c>{
            new Materials__c(Name = 'test 3', Book_Series__c = 'SN0012', Cost__c = 40,Author__c = 'Harry Potter',ISBN__c = '76542965',Language__c = 'Danish'),
            new Materials__c(Name = 'test 1',Book_Series__c = 'SN0043', Cost__c = 50,Author__c = 'Cartoon Network',ISBN__c = '06235778',Language__c = 'Arabic')
        };
      
        insert MaterialsList;
        
        MaterialsList[0].Book_Series__c = 'SN0022';
        update MaterialsList;
        
        system.debug(':::::matList'+matList);
        Test.StopTest();
    }
}