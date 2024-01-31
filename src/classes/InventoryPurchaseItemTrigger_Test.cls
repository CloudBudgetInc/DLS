@isTest
public class InventoryPurchaseItemTrigger_Test {
    
    //Developed by Sangeetha G on June 13 2018 for InventoryPurchaseItemTrigger
    @testSetup static void setup() {
        
        //Method create Account, MTT_Location__c and Inventory_Purchase__c 
        TestClassUtil.createInventoryPurchase();
        
        //Method to create Materials__c and Materials_Stock__c
        TestClassUtil.createMaterialsStock();
    }
    
    Static testMethod void testMethod1() {
        
        List<Inventory_Purchase__c> ipList = [ SELECT Id, Location__c, Vendor__c  FROM Inventory_Purchase__c LIMIT 2 ];
        List<Materials__c> materialList = [ SELECT Id FROM Materials__c LIMIT 2 ];
        
        system.debug('ipList :::::::::::::::::'+ipList );
        
        //insert Inventory_Purchase_Item__c
        List<Inventory_Purchase_Item__c> ipiList = new List<Inventory_Purchase_Item__c>{
                                                       new Inventory_Purchase_Item__c( Inventory_Purchase__c = ipList[0].Id, Materials__c = materialList[0].Id, Quantity__c = 10, Price__c = 200 ),
                                                       new Inventory_Purchase_Item__c( Inventory_Purchase__c = ipList[0].Id, Materials__c = materialList[1].Id, Quantity__c = 20, Price__c = 200 )        
        };
        
        insert ipiList;
        
        List<Inventory_Purchase_Item__c> ipiList2 = [ SELECT Id, Name, Materials_Stock__c   FROM  Inventory_Purchase_Item__c WHERE  Materials__c  = :materialList[0].Id];
        system.debug('ipiList :::::::::::::::::::::::::'+ ipiList2 );
        
        System.assertNotEquals( null,ipiList2[0].Materials_Stock__c);
        
    }
}