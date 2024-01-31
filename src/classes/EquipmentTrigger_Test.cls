@isTest
private class EquipmentTrigger_Test{

    @testSetup static void setupMethod(){
    
        List<AcctSeed__Fixed_Asset__c> createFixedAsset = TestClassUtil.createFixedAsset();
        List<MTT_Location__c> createTestLocations = TestClassUtil.createTestLocations();
        
    }
    
    private static testMethod void myTest1(){
    
        List<Equipment__c> equipments = new List<Equipment__c>{
            new Equipment__c(Name = 'Test Equip1', Stage__c = 'Active', Date_Disposed__c = Date.Today().addDays(5)),
            new Equipment__c(Name = 'Test Equip2', Stage__c = 'Available', Date_Disposed__c = Date.Today().addDays(6)),
            new Equipment__c(Name = 'Test Equip3', Stage__c = 'Donated', Date_Disposed__c = Date.Today().addDays(7))
        };
        insert equipments;
        
        List<Equipment_Assignment__c> equipAssigns = new List<Equipment_Assignment__c>{
            new Equipment_Assignment__c(Equipment__c = equipments[0].Id, Date_Assigned__c = Date.Today(), Date_Returned__c = Date.Today().addDays(1), Stage__c = 'Active'),
            new Equipment_Assignment__c(Equipment__c = equipments[0].Id, Date_Assigned__c = Date.Today(), Date_Returned__c = Date.Today().addDays(2), Stage__c = 'Planned'),
            new Equipment_Assignment__c(Equipment__c = equipments[1].Id, Date_Assigned__c = Date.Today(), Date_Returned__c = Date.Today().addDays(1), Stage__c = 'Active'),
            new Equipment_Assignment__c(Equipment__c = equipments[1].Id, Date_Assigned__c = Date.Today(), Date_Returned__c = Date.Today().addDays(2), Stage__c = 'Planned')
        };
        insert equipAssigns;
        
        List<Equipment__c> equipToUpdate = [SELECT Id, Stage__c FROM Equipment__c WHERE Id IN :equipments];
        equipToUpdate[0].Stage__c = 'Disposed';
        equipToUpdate[1].Stage__c = 'Disposed';
        update equipToUpdate;
        
        List<Equipment_Assignment__c> updatedEquipAssigns = [SELECT Id, Date_Returned__c, Stage__c FROM Equipment_Assignment__c WHERE Equipment__c IN :equipToUpdate AND Stage__c != 'Planned'];
        System.assertEquals('Ended', updatedEquipAssigns[0].Stage__c);
        System.assertEquals(Date.Today().addDays(5), updatedEquipAssigns[0].Date_Returned__c);
    }
    
    private static testMethod void myTest2(){
           
        List<MTT_Location__c> loc = [SELECT Id FROM MTT_Location__c];
        
        List<Equipment__c> equipments = new List<Equipment__c>{
            new Equipment__c(Name = 'Test Equip1', Stage__c = 'Active', Date_Disposed__c = Date.Today().addDays(5), Assigned_Location__c = loc[0].Id, Date_Placed_in_Service__c = System.Today()),
            new Equipment__c(Name = 'Test Equip2', Stage__c = 'Available', Date_Disposed__c = Date.Today().addDays(6), Assigned_Location__c = loc[0].Id, Date_Placed_in_Service__c = System.Today())
        };
        insert equipments;
        
        List<AcctSeed__Fixed_Asset__c> fas = [SELECT Id, Equipment__c FROM AcctSeed__Fixed_Asset__c LIMIT  2];
        fas[0].Equipment__c = equipments[0].Id;
        fas[1].Equipment__c = equipments[1].Id;
        update fas;
        
        Account acc = new Account(Name='Test Account 1');
        insert acc;
        
        Purchase_Order__c order = new Purchase_Order__c(Name = 'Test Order', Vendor__c = acc.Id, Date__c = System.Today());
        insert order;
        
        List<Equipment__c>  equips = [SELECT Id, Stage__c, Date_Disposed__c, Assigned_Location__c, Date_Placed_in_Service__c FROM Equipment__c WHERE Id IN : equipments];
        equips[0].Stage__c = 'Available';
        equips[0].Date_Disposed__c = Date.Today().addDays(10);
        equips[0].Assigned_Location__c = loc[1].Id;
        equips[0].Date_Placed_in_Service__c = Date.Today().addDays(-1);
        equips[0].Purchase_Order_No__c = order.Id;
        
        Test.startTest();
        
            update equips[0];
            
            List<AcctSeed__Fixed_Asset__c> faList = [SELECT Id, Date_Disposed__c, Date_Placed_in_Service__c, Date_Purchased__c, Location__c, Stage__c, Equipment__c FROM AcctSeed__Fixed_Asset__c WHERE Id IN :fas LIMIT 2 ];
            System.assertEquals('Available', faList[0].Stage__c);
            System.assertEquals(loc[1].Id, faList[0].Location__c);
            
        Test.stopTest();
    }
    
    private static testMethod void myTest3(){
           
        List<MTT_Location__c> loc = [SELECT Id FROM MTT_Location__c];
        
        List<Equipment__c> equipments = new List<Equipment__c>{
            new Equipment__c(Name = 'Test Equip1', Stage__c = 'Active', Date_Disposed__c = Date.Today().addDays(5), Assigned_Location__c = loc[0].Id, Date_Placed_in_Service__c = System.Today()),
            new Equipment__c(Name = 'Test Equip2', Stage__c = 'Available', Date_Disposed__c = Date.Today().addDays(6), Assigned_Location__c = loc[0].Id, Date_Placed_in_Service__c = System.Today())
        };
        insert equipments;
        
        Test.startTest();
        
            Equipment__c newEquip = new Equipment__c(Name = 'Test Equip1', Stage__c = 'Active', Date_Disposed__c = Date.Today().addDays(5), Assigned_Location__c = loc[0].Id, Date_Placed_in_Service__c = System.Today());
            
            try{
               insert newEquip;
            }catch (Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Equipment Asset Name should be unique') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
                
        Test.stopTest();
    }
    
    private static testMethod void myTest4(){
           
        List<MTT_Location__c> loc = [SELECT Id FROM MTT_Location__c];
        
        List<Equipment__c> equipments = new List<Equipment__c>{
            new Equipment__c(Name = 'Test Equip1', Stage__c = 'Active', Date_Disposed__c = Date.Today().addDays(5), Assigned_Location__c = loc[0].Id, Date_Placed_in_Service__c = System.Today()),
            new Equipment__c(Name = 'Test Equip2', Stage__c = 'Available', Date_Disposed__c = Date.Today().addDays(6), Assigned_Location__c = loc[0].Id, Date_Placed_in_Service__c = System.Today())
        };
        insert equipments;
        
        Test.startTest();
        
            List<Equipment__c> oldEquip = [SELECT Id, Name FROM Equipment__c WHERE Id = :equipments[0].Id AND Name = 'Test Equip1'];
            
            try{
            
               oldEquip[0].Name = 'TEST EQUIP2';
               update oldEquip[0];
               
            }catch (Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Equipment Asset Name should be unique') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
                
        Test.stopTest();
    }
}