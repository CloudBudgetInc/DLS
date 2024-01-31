@isTest
private class MaterialStockTrigger_Test {

    @testSetup static void setup() {
        TestClassUtil.createMaterialsStock();
    }
    
    // To populate the Material Stock information in Materials - To display the stock in hand values in Materials level - To restruct the user from creation MS duplicate record with same material & location combination
    Static testMethod void testMethod1() {
        
        List<MTT_Location__c> locations = new List<MTT_Location__c>();
        
        MTT_Location__c herdon_loc = new MTT_Location__c();
        herdon_loc.Name = 'DLS - Herndon';
        locations.add(herdon_loc);
        
        MTT_Location__c online_loc = new MTT_Location__c();
        online_loc.Name = 'DLS - Online';
        locations.add(online_loc);
        
        insert locations;
        
        List<Materials__c> materials = [SELECT Id,Name FROM Materials__c LIMIT 1];
        List<Materials_Stock__c> materialStock = [SELECT Id,Name,Materials__c,Location__c FROM Materials_Stock__c LIMIT 1];
        
        List<Materials_Stock__c> stock = new List<Materials_Stock__c> {
            new Materials_Stock__c(Materials__c = materials[0].Id, Location__c = locations[0].Id),
            new Materials_Stock__c(Materials__c = materialStock[0].Materials__c, Location__c = materialStock[0].Location__c),
            new Materials_Stock__c(Materials__c = materials[0].Id, Location__c = locations[1].Id)
        };
      
        try {
            insert stock;
        } catch(exception ex) {
            System.debug(':::Exception:::'+ex.getMessage());
        }
        
        List<Materials__c> matList = [SELECT Id, Name, ARL_Materials_Stock__c, ELK_Materials_Stock__c, HRN_Materials_Stock__c FROM Materials__c WHERE Id = :materials[0].Id LIMIT 1];
        
        if(matList.size() > 0) {
            System.assertEquals(matList[0].HRN_Materials_Stock__c, stock[0].Id);
        }
    }
}