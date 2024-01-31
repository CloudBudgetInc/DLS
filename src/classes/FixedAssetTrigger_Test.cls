@isTest
private class FixedAssetTrigger_Test {

    @testSetup static void setup() { 
        List<Sobject_Master_Field_Mapping__c> masterFieldMappingList = TestClassUtil.createSobjMasterFieldMap();
        List<AcctSeed__Fixed_Asset__c> fixAssetList = TestClassUtil.createFixedAsset();
        List<MTT_Location__c> locList = TestClassUtil.createTestLocations();
    }
    
    //Flosum_Deployment_Issue_Test_Nixon_Oct25,2019
    // For updating the of_Months_Depreciation__c (AcctSeed__Fixed_Asset__c - object) field based on Default_Field_Value__c (AcctSeed__Ledger__c - object) field
    static testMethod void testMethod1() {
       
        List<Sobject_Master_Field_Mapping__c> masterFieldMapList = [SELECT Id, Name, Default_Field_Value__c FROM Sobject_Master_Field_Mapping__c LIMIT 1];
      
        if(masterFieldMapList.size() > 0) { 

            List<AcctSeed__Fixed_Asset__c> fixedAssertUp = [SELECT Id, Name, of_Months_Depreciation__c FROM AcctSeed__Fixed_Asset__c LIMIT 1];
            if(fixedAssertUp.size() > 0)
                System.assertEquals(Integer.valueOf(masterFieldMapList[0].Default_Field_Value__c), fixedAssertUp[0].of_Months_Depreciation__c);
        }
    }
    
    // For updating the Related_GL_Account__c (AcctSeed__Fixed_Asset__c - object) field based on AcctSeed__Default_Bank_Account__c (Sobject_Master_Field_Mapping__c - object) field 
    static testMethod void testMethod2() {
        
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'AcctSeed__Fixed_Asset__c' AND DeveloperName IN ('Computer_Equipment', 'Leasehold_Improvements')];
        List<Sobject_Master_Field_Mapping__c> masterFieldMapList = [SELECT Id, Name, Default_Field_Value__c FROM Sobject_Master_Field_Mapping__c LIMIT 1];
        
        if(rType.size() > 0 && masterFieldMapList.size() > 0) { 
            
            masterFieldMapList[0].Field_Name__c = 'Related_GL_Account__c';
            update masterFieldMapList;
            
            String comEqRtId, leaseRtId;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'Computer_Equipment') comEqRtId = rt.Id;
                if(rt.DeveloperName == 'Leasehold_Improvements') leaseRtId = rt.Id;
            }

            List<Account> accList = new List<Account> {
                new Account(Name = 'Test Account')
            };
            insert accList;
            
            List<Contract> contrList = new List<Contract> {
                new Contract(AccountId = accList[0].Id,Status = 'Completed Draft',StartDate = system.today(), Contract_End_Date__c = System.today().addDays(3)) 
            };
            insert contrList;
            
            List<Equipment__c> equipList = new List<Equipment__c> {
                new Equipment__c(Name = 'TestEquipment 1', Date_Placed_in_Service__c = System.today())
            };
            insert equipList;  
            
            List<AcctSeed__Ledger__c> LedgerList = [SELECT Id, Name, AcctSeed__Default_Bank_Account__c FROM AcctSeed__Ledger__c LIMIT 1];
            
            List<MTT_Location__c> locList = [SELECT Id, Name, State__c FROM MTT_Location__c];
            
            if(LedgerList.size() > 0) {
                
                List<AcctSeed__GL_Account__c> glAcc = [SELECT Id, Name FROM AcctSeed__GL_Account__c WHERE Id = :LedgerList[0].AcctSeed__Default_Bank_Account__c];

                if(glAcc.size() > 0) {
                    
                    glAcc[0].GL_Account__c = masterFieldMapList[0].Default_Field_Value__c;
                    update glAcc;
                    
                    List<AcctSeed__Fixed_Asset__c> fixedAssetList = new List<AcctSeed__Fixed_Asset__c> {
                        new AcctSeed__Fixed_Asset__c(Name = 'Test FixedAsset', AcctSeed__Value__c = 20.5, AcctSeed__Ledger__c = LedgerList[0].Id, Location__c = locList[0].Id),
                        new AcctSeed__Fixed_Asset__c(Name = 'Test FixedAsset', AcctSeed__Value__c = 20.5, AcctSeed__Ledger__c = LedgerList[0].Id, RecordTypeId = leaseRtId, Contract__c = contrList[0].Id, Equipment__c = equipList[0].Id, Location__c = locList[1].Id)
                    };
                    insert fixedAssetList; 
                    
                    List<AcctSeed__Fixed_Asset__c> fixedAssertUp = [SELECT Id, Name, Related_GL_Account__c FROM AcctSeed__Fixed_Asset__c WHERE Id = :fixedAssetList[0].Id];
                    if(fixedAssertUp.size() > 0)
                        System.assertEquals(glAcc[0].Id, fixedAssertUp[0].Related_GL_Account__c);
                }
            }
        }
    }
    
    // For updating the Related_GL_Account__c (AcctSeed__Fixed_Asset__c - object) field based on AcctSeed__Default_Bank_Account__c (Sobject_Master_Field_Mapping__c - object) field 
    static testMethod void testMethod3() {
        
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'AcctSeed__Fixed_Asset__c' AND DeveloperName IN ('Computer_Equipment', 'Leasehold_Improvements')];
        List<Sobject_Master_Field_Mapping__c> masterFieldMapList = [SELECT Id, Name, Default_Field_Value__c FROM Sobject_Master_Field_Mapping__c LIMIT 1];
        
        if(rType.size() > 0 && masterFieldMapList.size() > 0) { 
            
            masterFieldMapList[0].Field_Name__c = 'Related_GL_Account__c';
            update masterFieldMapList;
            
            String comEqRtId, leaseRtId;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'Computer_Equipment') comEqRtId = rt.Id;
                if(rt.DeveloperName == 'Leasehold_Improvements') leaseRtId = rt.Id;
            }

            List<Account> accList = new List<Account> {
                new Account(Name = 'Test Account')
            };
            insert accList;
            
            List<Contract> contrList = new List<Contract> {
                new Contract(AccountId = accList[0].Id,Status = 'Completed Draft',StartDate = system.today(), Contract_End_Date__c = System.today().addDays(3)) 
            };
            insert contrList;
            
            List<Equipment__c> equipList = new List<Equipment__c> {
                new Equipment__c(Name = 'TestEquipment 1', Date_Placed_in_Service__c = System.today())
            };
            insert equipList;  
            
            List<AcctSeed__Ledger__c> LedgerList = [SELECT Id, Name, AcctSeed__Default_Bank_Account__c FROM AcctSeed__Ledger__c LIMIT 1];
            
            List<MTT_Location__c> locList = [SELECT Id, Name, State__c FROM MTT_Location__c WHERE Name = 'DLS - Elkridge'];
            
            if(LedgerList.size() > 0) {
                
                List<AcctSeed__GL_Account__c> glAcc = [SELECT Id, Name FROM AcctSeed__GL_Account__c WHERE Id = :LedgerList[0].AcctSeed__Default_Bank_Account__c];

                if(glAcc.size() > 0) {
                    
                    glAcc[0].GL_Account__c = masterFieldMapList[0].Default_Field_Value__c;
                    update glAcc;
                    
                    List<AcctSeed__Fixed_Asset__c> fixedAssetList = new List<AcctSeed__Fixed_Asset__c> {
                        new AcctSeed__Fixed_Asset__c(Name = 'Test FixedAsset', AcctSeed__Value__c = 20.5, AcctSeed__Ledger__c = LedgerList[0].Id, Location__c = locList[0].Id)
                    };
                    insert fixedAssetList; 
                    
                    List<AcctSeed__Fixed_Asset__c> fixedAssertUp = [SELECT Id, Name, Related_GL_Account__c FROM AcctSeed__Fixed_Asset__c WHERE Id = :fixedAssetList[0].Id];
                    if(fixedAssertUp.size() > 0)
                        System.assertEquals(glAcc[0].Id, fixedAssertUp[0].Related_GL_Account__c);
                }
            }
        }
    }
    
    private static testMethod void myTest1(){
    
        List<MTT_Location__c> locList = [SELECT Id, Name, State__c FROM MTT_Location__c];
        
        List<AcctSeed__Ledger__c> LedgerList = [SELECT Id, Name, AcctSeed__Default_Bank_Account__c FROM AcctSeed__Ledger__c LIMIT 1];
        
        List<AcctSeed__Fixed_Asset__c> fixedAssetList = new List<AcctSeed__Fixed_Asset__c> {
            new AcctSeed__Fixed_Asset__c(Name = 'MyTest FixedAsset', AcctSeed__Value__c = 20.5, Location__c = locList[0].Id, Stage__c ='Active',AcctSeed__Ledger__c = LedgerList[0].Id)
        };
        insert fixedAssetList; 
        
        List<AcctSeed__Fixed_Asset__c> updateFA = [SELECT Id, Location__c, Stage__c FROM AcctSeed__Fixed_Asset__c WHERE Id = :fixedAssetList[0].Id];
        updateFA[0].Location__c = locList[1].Id;
        updateFA[0].Stage__c = 'Disposed';
        update updateFA[0];
    }
    
    private static testMethod void myTest2(){
    
        List<MTT_Location__c> locList = [SELECT Id, Name, State__c FROM MTT_Location__c];
        
        List<AcctSeed__Ledger__c> LedgerList = [SELECT Id, Name, AcctSeed__Default_Bank_Account__c FROM AcctSeed__Ledger__c LIMIT 1];
        
        Id compEquipRTId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Computer').getRecordTypeId();
        Id compEquipFARTId = Schema.SObjectType.AcctSeed__Fixed_Asset__c.getRecordTypeInfosByDeveloperName().get('Computer_Equipment').getRecordTypeId();
    
        List<Equipment__c> equipList = new List<Equipment__c> {
            new Equipment__c(Name = 'TestEquipment 1', Date_Placed_in_Service__c = System.today(), Service_Tag__c = 'Test Service Tag', RecordTypeId = compEquipRTId)
        };
        insert equipList;
        
        Test.startTest();
        
        List<AcctSeed__Fixed_Asset__c> fixedAssetList = new List<AcctSeed__Fixed_Asset__c> {
            new AcctSeed__Fixed_Asset__c(Name = 'MyTest FixedAsset', AcctSeed__Value__c = 20.5, Location__c = locList[0].Id, Stage__c ='Active',AcctSeed__Ledger__c = LedgerList[0].Id, RecordTypeId = compEquipFARTId, Equipment__c = equipList[0].Id)
        };
        insert fixedAssetList; 
        
        List<AcctSeed__Fixed_Asset__c> fixedAss = [SELECT Id, Asset_Id__c FROM AcctSeed__Fixed_Asset__c WHERE ID IN : fixedAssetList];
        System.assertEquals('Test Service Tag', fixedAss[0].Asset_Id__c);
        
        Test.stopTest();
    }
}