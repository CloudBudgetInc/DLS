@isTest(SeeAllData=true)
public class RHX_TEST_Inventory_Purchase_Item {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id,Inventory_Purchase__c,Materials__c 
            FROM Inventory_Purchase_Item__c LIMIT 1];
        List<MTT_Location__c> loc = [SELECT Id,Name FROM MTT_Location__c LIMIT 1];  
        List<Materials__c> material = [SELECT Id,Name FROM Materials__c LIMIT 1];
              
        Inventory_Purchase__c inv = new Inventory_Purchase__c();
        inv.Location__c  = loc[0].Id;
        insert inv;
        
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Inventory_Purchase_Item__c(Inventory_Purchase__c = inv.Id,Materials__c = material[0].Id)
            );
        }
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}