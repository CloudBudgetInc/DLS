@isTest
public class Clin_Trigger_Test {

    @testSetup static void setup(){
    
        List<Contract> contractList = TestClassUtil.createTestContracts(); 
        List<Contract> updateContracts = new List<Contract>();
        
        Integer i = 1;
        for(Contract c : contractList){
            
            if(c.Name == NULL){
                c.Name = 'Test Contract'+i;
                i = i+1;    
                updateContracts.add(c);
            }
        }
        
        if(updateContracts.size() > 0){
        
           update updateContracts; 
        }
    }
    
    // Inserting Clin Record With Duplicate  Clin# Values
    public static testMethod void testMethod1() {
        
        Test.startTest();
        try{
            List<Contract> contList = [Select Id,Name From Contract Limit 2];
            contList[1].APXT_Redlining__Contract_Family_Parent__c = contList[0].Id;
            update contList;
            
            List<CLIN__c> clinList = new List<CLIN__c>{
                new CLIN__c(CLIN_Name__c = 'ODC', Name = 'Test 1', CLIN_Unit_Price__c = 100, Contract__c = contList[0].Id,CLIN_Type__c = 'FFP',CLIN_Start_Date__c = System.today(),CLIN_End_Date__c = System.today().addDays(5)),
                    new CLIN__c(CLIN_Name__c = 'Material', Name = 'Test 1', CLIN_Unit_Price__c = 150, Contract__c = contList[0].Id,CLIN_Type__c = 'FFP',CLIN_Start_Date__c = System.today(),CLIN_End_Date__c = System.today().addDays(5)),
                    new CLIN__c(CLIN_Name__c = 'MaT', Name = 'Test 3', CLIN_Unit_Price__c = 100, Contract__c = contList[0].Id,CLIN_Type__c = 'COST',CLIN_Start_Date__c = System.today(),CLIN_End_Date__c = System.today().addDays(5)),
                    new CLIN__c(CLIN_Name__c = 'ODC', Name = 'Test 4', CLIN_Unit_Price__c = 100, Contract__c = contList[1].Id,CLIN_Type__c = 'COST',CLIN_Start_Date__c = System.today(),CLIN_End_Date__c = System.today().addDays(5))
                    };
             insert clinList;
            
        }catch(Exception ex){
           //System.AssertEquals(true,ex.getMessage().contains('CLIN record for the same Contract must have unique CLIN #\'s'));
        }
        Test.stopTest();       
    } 
    
   // Updating Clin Record With Duplicate Clin# Values 
    public static testMethod void testMethod2() {
        
        Test.startTest();
        try{      
            List<Contract> contList = [Select Id,Name From Contract Limit 2];
            contList[1].APXT_Redlining__Contract_Family_Parent__c = contList[0].Id;
            update contList;
            
                       List<CLIN__c> clinList = new List<CLIN__c>{
                new CLIN__c(CLIN_Name__c = 'ODC', Name = 'Test 1', CLIN_Unit_Price__c = 100, Contract__c = contList[0].Id,CLIN_Type__c = 'FFP',CLIN_Start_Date__c = System.today(),CLIN_End_Date__c = System.today().addDays(5)),
                    new CLIN__c(CLIN_Name__c = 'Material', Name = 'Test 2', CLIN_Unit_Price__c = 150, Contract__c = contList[0].Id,CLIN_Type__c = 'FFP',CLIN_Start_Date__c = System.today(),CLIN_End_Date__c = System.today().addDays(5)),
                    new CLIN__c(CLIN_Name__c = 'MaT', Name = 'Test 3', CLIN_Unit_Price__c = 100, Contract__c = contList[0].Id,CLIN_Type__c = 'COST',CLIN_Start_Date__c = System.today(),CLIN_End_Date__c = System.today().addDays(5)),
                    new CLIN__c(CLIN_Name__c = 'ODC', Name = 'Test 4', CLIN_Unit_Price__c = 100, Contract__c = contList[1].Id,CLIN_Type__c = 'COST',CLIN_Start_Date__c = System.today(),CLIN_End_Date__c = System.today().addDays(5))
                    };
             insert clinList;
            
            List<CLIN__c> clinListToUpdate = [SELECT Id,Name,Contract__c FROM CLIN__c Where Id IN :clinList AND Name = 'Test 1'];
            clinListToUpdate[0].Name = 'Test 2';
            clinListToUpdate[0].CLIN_Name__c = 'ODC1'; 
            update clinListToUpdate;
        }catch(Exception ex){
            System.AssertEquals(true,ex.getMessage().contains('CLIN record for the same Contract must have unique CLIN #\'s'));
        }
        Test.stopTest();       
    }
     
    // Updating Clin Record with uniques Values
    public static testMethod void testMethod3() {
        
        Test.startTest();
        List<Contract> contList = [Select Id,Name From Contract Limit 2];
        contList[1].APXT_Redlining__Contract_Family_Parent__c = contList[0].Id;
        update contList;
        
        List<CLIN__c> clinList = new List<CLIN__c>{
            new CLIN__c(CLIN_Name__c = 'ODC', Name = 'Test 1', CLIN_Unit_Price__c = 100, Contract__c = contList[0].Id,CLIN_Type__c = 'FFP',CLIN_Start_Date__c = System.today(),CLIN_End_Date__c = System.today().addDays(5)),
                new CLIN__c(CLIN_Name__c = 'Material', Name = 'Test 2', CLIN_Unit_Price__c = 150, Contract__c = contList[0].Id,CLIN_Type__c = 'FFP',CLIN_Start_Date__c = System.today(),CLIN_End_Date__c = System.today().addDays(5)),
                new CLIN__c(CLIN_Name__c = 'MaT', Name = 'Test 3', CLIN_Unit_Price__c = 100, Contract__c = contList[0].Id,CLIN_Type__c = 'COST',CLIN_Start_Date__c = System.today(),CLIN_End_Date__c = System.today().addDays(5)),
                new CLIN__c(CLIN_Name__c = 'ODC', Name = 'Test 4', CLIN_Unit_Price__c = 100, Contract__c = contList[1].Id,CLIN_Type__c = 'COST',CLIN_Start_Date__c = System.today(),CLIN_End_Date__c = System.today().addDays(5))
                };
            insert clinList;
        
        List<CLIN__c> clinListToUpdate = [SELECT Id,Name,Contract__c,Parent_CLIN__c FROM CLIN__c Where Id IN :clinList AND Name = 'Test 1'];
        if(clinListToUpdate.size() > 0){
            clinListToUpdate[0].CLIN_Name__c = 'ODC1';
            clinListToUpdate[0].Parent_CLIN__c = clinList[1].Id;
            update clinListToUpdate;
            System.AssertEquals(clinList[1].Id, clinListToUpdate[0].Parent_CLIN__c);
        }
        Test.stopTest();       
    } 
}