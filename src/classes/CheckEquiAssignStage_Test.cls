@isTest
public class CheckEquiAssignStage_Test {
   
    @testSetup static void setup() {
        List<Equipment_Assignment__c> equiAssignList = TestClassUtil.createTestEquipmentAssignment();  
        List<Room__c> rooms = TestClassUtil.createTestRoom();
    }
    
    public static testMethod void testMethod1() {
        
        Id ActiveId, UpActiveId;
        List<Equipment_Assignment__c> equiAssList = [Select Id, Name, Equipment__c, Stage__c FROM Equipment_Assignment__c];
        
        if(equiAssList != Null && equiAssList.size() > 0) {
            for(Equipment_Assignment__c equiAss : equiAssList) {
              
                if(equiAss.Stage__c == 'Active') {
                    ActiveId = equiAss.Id;
                } else {
                    equiAss.Stage__c = 'Active';
                    UpActiveId = equiAss.Id;
                    update equiAss;
                }
            }
        }   
        
        Equipment_Assignment__c equiassign = [Select Id, Name, Equipment__c, Stage__c FROM Equipment_Assignment__c WHERE Id = :ActiveId];
        // Stage of the Equipment Assignment is updated to Active, Then the Active Equipment Assignment with the same Equipment become Ended 
        System.assertEquals('Ended', equiassign.Stage__c);  
           
        try {
            List<Equipment_Assignment__c> EquAssignList = new List<Equipment_Assignment__c> {
                                                                new Equipment_Assignment__c(Equipment__c = equiAssList[0].Equipment__c, Stage__c = 'Active'), 
                                                                new Equipment_Assignment__c(Equipment__c = equiAssList[0].Equipment__c, Stage__c = 'Active')                                        
                                                            };
            insert EquAssignList;  
        }
        catch(DMLException e) {
            //Inserting more than one Equipment Assignment of the same Equipment stage as Active
            System.assert(e.getMessage().contains('Stage as Active'), e.getMessage());
        }     
         
        List<Equipment_Assignment__c> EquipAssignList = new List<Equipment_Assignment__c> {
                                                            new Equipment_Assignment__c(Equipment__c = equiAssList[0].Equipment__c, Stage__c = 'Active'), 
                                                            new Equipment_Assignment__c(Equipment__c = equiAssList[0].Equipment__c, Stage__c = 'Planned')                                        
                                                        };
        insert EquipAssignList;   
        
        Equipment_Assignment__c equiassign1 = [Select Id, Name, Equipment__c, Stage__c FROM Equipment_Assignment__c WHERE Id = :UpActiveId];
       
        // Equipment Assignment is inserted with the Stage as Active, Then the Active Equipment Assignment with the same Equipment become Ended 
        System.assertEquals('Ended', equiassign1.Stage__c); 
        
        List<Equipment_Assignment__c> equipAssNonActive = [SELECT Id, Name, Stage__c FROM Equipment_Assignment__c WHERE Stage__c != 'Active' LIMIT 2];
        
        if(equipAssNonActive != Null && equipAssNonActive.size() > 0) {
            
            try {
                for(Equipment_Assignment__c equAss : equipAssNonActive) {
                   equAss.Stage__c = 'Active';     
                }
                update equipAssNonActive;
            } 
            catch(DMLException e) {
                // Updating more than one Equipment Assignment of the same Equipment stage as Active
                System.assert(e.getMessage().contains('Stage as Active'), e.getMessage());
            }
        }
    }
    
    private static testMethod void myTest1(){
    
        List<Room__c> rooms = [SELECT Id, Location_n__c FROM Room__c WHERE Location_n__c != NULL];
        
        List<Equipment__c> equipments = [SELECT Id FROM Equipment__c];
        
        List<Equipment_Assignment__c> equipAssigns = new List<Equipment_Assignment__c>{
            new Equipment_Assignment__c(Equipment__c = equipments[0].Id, Room__c = rooms[0].Id, Date_Assigned__c = Date.Today(), Date_Returned__c = Date.Today().addDays(1), Stage__c = 'Active'),
            new Equipment_Assignment__c(Equipment__c = equipments[0].Id, Room__c = rooms[0].Id, Date_Assigned__c = Date.Today(), Date_Returned__c = Date.Today().addDays(2), Stage__c = 'Planned')
        };
        insert equipAssigns;
        
        List<Equipment_Assignment__c> toUpdateEquipAssigns = [SELECT Id, Room__c, Location__c FROM Equipment_Assignment__c WHERE Id IN :equipAssigns];
        System.AssertEquals(toUpdateEquipAssigns[0].Location__c, rooms[0].Location_n__c);
    }
    
    private static testMethod void myTest2(){
    
        List<Room__c> rooms = [SELECT Id, Location_n__c FROM Room__c WHERE Location_n__c != NULL];
        
        List<Equipment__c> equipments = [SELECT Id FROM Equipment__c];
        
        List<Equipment_Assignment__c> equipAssigns = new List<Equipment_Assignment__c>{
            new Equipment_Assignment__c(Equipment__c = equipments[0].Id, Room__c = rooms[0].Id, Date_Assigned__c = Date.Today(), Date_Returned__c = Date.Today().addDays(1), Stage__c = 'Active'),
            new Equipment_Assignment__c(Equipment__c = equipments[0].Id, Room__c = rooms[0].Id, Date_Assigned__c = Date.Today(), Date_Returned__c = Date.Today().addDays(2), Stage__c = 'Planned')
        };
        insert equipAssigns;
        
        List<Equipment_Assignment__c> toUpdateEquipAssigns = [SELECT Id, Room__c FROM Equipment_Assignment__c WHERE Id IN :equipAssigns];
        toUpdateEquipAssigns[0].Room__c = rooms[1].Id;
        toUpdateEquipAssigns[1].Room__c = NULL;
        update toUpdateEquipAssigns;
        
        List<Equipment_Assignment__c> updatedEquipAssigns = [SELECT Id, Room__c, Location__c FROM Equipment_Assignment__c WHERE Id IN :toUpdateEquipAssigns];
        System.AssertEquals(updatedEquipAssigns[0].Location__c, rooms[1].Location_n__c);
        System.AssertEquals(updatedEquipAssigns[1].Location__c, NULL);
    }
}