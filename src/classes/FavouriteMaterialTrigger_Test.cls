@isTest
private class FavouriteMaterialTrigger_Test{

    @testSetup static void setupMethod(){
    
        Test.startTest();
            List<Contact> contacts = TestClassUtil.createTestContacts();
        Test.stopTest();
        List<Materials__c> materials = TestClassUtil.createTestmaterials();
        List<ContentVersion> contentVersions = TestClassUtil.createTestContents();
    }
    
    // For Insertion - Total_Favourite_Count__c value update from NULL to NOT NULL
    private static testMethod void MyTest1(){
    
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];
        List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion LIMIT 2];
        
        List<Favourite_Material__c> favMaterials = new List<Favourite_Material__c>{
        
            new Favourite_Material__c(Contact__c = contacts[0].Id, Material_Name__c = materials[0].Id, ContentVersion_Id__c = contentVersions[0].Id),
            new Favourite_Material__c(Contact__c = contacts[1].Id, Material_Name__c = materials[1].Id, ContentVersion_Id__c = contentVersions[0].Id)
        };
        
        Test.startTest();
        
            insert favMaterials;
            
            List<ContentVersion> conVer = [SELECT Id, Total_Favourite_Count__c FROM ContentVersion WHERE Id IN :contentVersions ];
            System.assertEquals(2, conVer[0].Total_Favourite_Count__c );
            
        Test.stopTest();
    } 
    
    // For Insertion - Total_Favourite_Count__c value update from NOT NULL to NOT NULL
    private static testMethod void MyTest2(){
    
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];
        List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
        
        List<ContentVersion> contentVersions = [SELECT Id, Total_Favourite_Count__c FROM ContentVersion LIMIT 2];
        contentVersions[0].Total_Favourite_Count__c = 1;
        update contentVersions[0];
        
        List<Favourite_Material__c> favMaterials = new List<Favourite_Material__c>{
        
            new Favourite_Material__c(Contact__c = contacts[0].Id, Material_Name__c = materials[0].Id, ContentVersion_Id__c = contentVersions[0].Id),
            new Favourite_Material__c(Contact__c = contacts[1].Id, Material_Name__c = materials[1].Id, ContentVersion_Id__c = contentVersions[1].Id)
        };
        
        Test.startTest();
        
            insert favMaterials;
            
            List<ContentVersion> conVer = [SELECT Id, Total_Favourite_Count__c FROM ContentVersion WHERE Id IN :contentVersions];
            System.assertEquals(2, conVer[0].Total_Favourite_Count__c );
            
        Test.stopTest();
    } 
    
    // For Deletion
    private static testMethod void MyTest3(){
    
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];
        List<Materials__c> materials = [SELECT Id FROM Materials__c LIMIT 2];
        
        List<ContentVersion> contentVersions = [SELECT Id, Total_Favourite_Count__c FROM ContentVersion LIMIT 2];
        contentVersions[0].Total_Favourite_Count__c = 1;
        update contentVersions[0];
        
        List<Favourite_Material__c> favMaterials = new List<Favourite_Material__c>{
        
            new Favourite_Material__c(Contact__c = contacts[0].Id, Material_Name__c = materials[0].Id, ContentVersion_Id__c = contentVersions[0].Id),
            new Favourite_Material__c(Contact__c = contacts[1].Id, Material_Name__c = materials[1].Id, ContentVersion_Id__c = contentVersions[1].Id)
        };
        
        Test.startTest();
        
            insert favMaterials;
            
            delete favMaterials[0];
            
            List<ContentVersion> conVer = [SELECT Id, Total_Favourite_Count__c FROM ContentVersion WHERE Id IN :contentVersions];
            System.assertEquals(1, conVer[0].Total_Favourite_Count__c );
            
        Test.stopTest();
    }
}