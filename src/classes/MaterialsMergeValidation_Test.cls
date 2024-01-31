@isTest
private class MaterialsMergeValidation_Test {

    @testSetup static void setup() {
        List<Materials__c> matReq = TestClassUtil.createTestmaterials();
    }
    
    private static testmethod void myTest1() {
        
        Test.StartTest();
        List<Materials__c> MaList = new List<Materials__c>{
            new Materials__c(Name = 'Test 3', Book_Series__c = 'SN0012', Cost__c = 40,Author__c = 'Harry Potter',ISBN__c = '76542965',Language__c = 'Danish')
        };
      
        insert MaList;
    
        List<Materials__c> MaterialsList = [SELECT Id FROM Materials__c LIMIT 3];
       
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(MaterialsList);
        sc.setSelected(MaterialsList);
        sc.getSelected();
        
        MaterialsMergeValidation validate = new MaterialsMergeValidation(sc);
        validate.showMsg = false;
        
        List<Id> mateiralsId = new List<Id>();
        mateiralsId.add(MaterialsList[0].Id);
        mateiralsId.add(MaterialsList[1].Id);
        mateiralsId.add(MaterialsList[2].Id);
        
        validate.idsJson = JSON.serialize(mateiralsId);
                
        Test.StopTest();
    
    }
    
    private static testmethod void myTest2() {
        Test.StartTest();
        List<Materials__c> MaList = new List<Materials__c>{
            new Materials__c(Name = 'Test 3', Book_Series__c = 'SN0012', Cost__c = 40,Author__c = 'Harry Potter',ISBN__c = '76542965',Language__c = 'Danish')
        };
      
        insert MaList;
    
        List<Materials__c> MaterialsList = [SELECT Id FROM Materials__c LIMIT 2];
       
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(MaterialsList);
        sc.setSelected(MaterialsList);
        sc.getSelected();
        
        MaterialsMergeValidation validate = new MaterialsMergeValidation(sc);
        validate.showMsg = false;
        
        List<Id> mateiralsId = new List<Id>();
        mateiralsId.add(MaterialsList[0].Id);
        mateiralsId.add(MaterialsList[1].Id);
        
        validate.idsJson = JSON.serialize(mateiralsId);
                
        Test.StopTest();
    }
    
    private static testmethod void myTest3() {
        Test.StartTest();
        List<Materials__c> MaList = new List<Materials__c>{
            new Materials__c(Name = 'Test 3', Book_Series__c = 'SN0012', Cost__c = 40,Author__c = 'Harry Potter',ISBN__c = '76542965',Language__c = 'Danish')
        };
      
        insert MaList;
    
        List<Materials__c> MaterialsList = [SELECT Id FROM Materials__c LIMIT 1];
       
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(MaterialsList);
        sc.setSelected(MaterialsList);
        sc.getSelected();
        
        MaterialsMergeValidation validate = new MaterialsMergeValidation(sc);
        validate.showMsg = false;
        
        List<Id> mateiralsId = new List<Id>();
        mateiralsId.add(MaterialsList[0].Id);
        
        validate.idsJson = JSON.serialize(mateiralsId);
                
        Test.StopTest();
    }
    private static testmethod void myTest4() {
        Test.StartTest();
        List<Materials__c> MaList = new List<Materials__c>{
            new Materials__c(Name = 'Test 3', Book_Series__c = 'SN0012', Cost__c = 40,Author__c = 'Harry Potter',ISBN__c = '76542965',Language__c = 'Danish')
        };
      
        insert MaList;
    
        List<Materials__c> MaterialsList = [SELECT Id FROM Materials__c LIMIT 1];
       
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(MaterialsList);
        sc.setSelected(new List<Materials__c>{});
        sc.getSelected();
        
        MaterialsMergeValidation validate = new MaterialsMergeValidation(sc);
        validate.showMsg = true;
        
        List<Id> mateiralsId = new List<Id>();
        
        validate.idsJson = JSON.serialize(mateiralsId);
                
        Test.StopTest();
    }
    
}