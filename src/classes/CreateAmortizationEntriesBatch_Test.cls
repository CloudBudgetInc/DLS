@isTest
private class CreateAmortizationEntriesBatch_Test {
    
    @testSetup static void setup() {
        
        List<AcctSeed__Accounting_Settings__c> accSet = TestClassUtil.createAccountSettings();
        List<AcctSeed__Fixed_Asset__c> fixedAssList = TestClassUtil.createFixedAsset();
        List<AcctSeed__Accounting_Variable__c> accVar = TestClassUtil.createAccountingVariable();
        List<Sobject_Master_Field_Mapping__c> sobjFieldMap = TestClassUtil.createSobjMasterFieldMap();
        
    }
    
    // For auto creating the Amortization Entries when the Fixed Asset Location is 'DLS - Rosslyn'
    private static testMethod void testMethod1() {

        List<Equipment__c> equList = TestClassUtil.createTestEquipment();
        List<MTT_Location__c> locList = TestClassUtil.createTestLocations();
        // Since the GL inserted in UTIL is all used in the Accounting Settings
        List<AcctSeed__GL_Account__c> glAcc = new List<AcctSeed__GL_Account__c> {
            new AcctSeed__GL_Account__c(Name = 'Test GL1 15950',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Expense', AcctSeed__Bank__c = false,GL_Account__c = '15950'),
            new AcctSeed__GL_Account__c(Name = 'Test GL2 75175',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Expense', AcctSeed__Bank__c = false, GL_Account__c = '75175')
        };
        insert glAcc;
        
        List<AcctSeed__Fixed_Asset__c> faList = [SELECT Id, Name, Location__c, Equipment__r.Assigned_Location__c, Equipment__r.Acquisition_Cost__c,Stage__c FROM AcctSeed__Fixed_Asset__c LIMIT 2];
        
        Date myDate = System.today();
        Date stDate = System.today().addMonths(-1);
        Date enDate = System.today().addDays(10);
        String mon = String.valueOf(stDate.month());
        
        if(stDate.month() < 10) {
            mon = '0'+stDate.month();
        }
        
        String nameStr = stDate.year()+'-'+mon;
        
        List<AcctSeed__Accounting_Period__c> accPer = new List<AcctSeed__Accounting_Period__c> {
            new AcctSeed__Accounting_Period__c(name = nameStr, AcctSeed__Start_Date__c = stDate, AcctSeed__End_Date__c = enDate)
        };
        insert accPer;
        
        if(equList.size() > 0 && faList.size() > 0 && locList.size() > 0) {
                    
            locList[0].Name = 'DLS - Rosslyn';
            update locList;
            
            for(Equipment__c eq : equList) {
                eq.Stage__c = 'Active';
                eq.Assigned_Location__c = locList[0].Id;
                eq.Acquisition_Cost__c = 1200;
            }
            update equList;
            
            for(AcctSeed__Fixed_Asset__c fa : faList) {
                fa.Equipment__c = equList[0].Id;
                fa.of_Months_Depreciation__c = 5;
                fa.Stage__c  = 'Active';
                fa.Location__c = locList[0].Id;
            }   
            update faList;
               
            createAmortizationEntriesBatch amoEntBatch = new createAmortizationEntriesBatch();
            Database.executeBatch(amoEntBatch, 5);
        } 
    }
    
    // For auto creating the Amortization Entries when the Fixed Asset Location is 'DLS - Elkridge'
    private static testMethod void testMethod2() {

        List<Equipment__c> equList = TestClassUtil.createTestEquipment();
        List<MTT_Location__c> locList = TestClassUtil.createTestLocations();
        
        // Since the GL inserted in UTIL is all used in the Accounting Settings
        List<AcctSeed__GL_Account__c> glAcc = new List<AcctSeed__GL_Account__c> {
            new AcctSeed__GL_Account__c(Name = 'Test GL1 15950',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Expense', AcctSeed__Bank__c = false,GL_Account__c = '15950'),
            new AcctSeed__GL_Account__c(Name = 'Test GL2 75275',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Expense', AcctSeed__Bank__c = false, GL_Account__c = '75275')
        };
        insert glAcc;
        
        List<AcctSeed__Fixed_Asset__c> faList = [SELECT Id, Name FROM AcctSeed__Fixed_Asset__c LIMIT 2];
        
        Date myDate = System.today();
        Date stDate = System.today().addMonths(-1);
        Date enDate = System.today().addDays(10);
        String mon = String.valueOf(stDate.month());
        
        if(stDate.month() < 10) {
            mon = '0'+stDate.month();
        }
        
        String nameStr = stDate.year()+'-'+mon;
        
        List<AcctSeed__Accounting_Period__c> accPer = new List<AcctSeed__Accounting_Period__c> {
            new AcctSeed__Accounting_Period__c(name = nameStr, AcctSeed__Start_Date__c = stDate, AcctSeed__End_Date__c = enDate)
        };
        insert accPer;
        
        if(equList.size() > 0 && faList.size() > 0 && locList.size() > 0) {
            
            locList[0].Name = 'DLS - Elkridge';
            update locList;
            
            for(Equipment__c eq : equList) {
                eq.Stage__c = 'Active';
                eq.Assigned_Location__c = locList[0].Id;
                eq.Acquisition_Cost__c = 1200;
            }
            update equList;
              
            for(AcctSeed__Fixed_Asset__c fa : faList) {
                fa.Equipment__c = equList[0].Id;
                fa.of_Months_Depreciation__c = 5;
                fa.Stage__c  = 'Active';
                fa.Location__c = locList[0].Id;
            }   
            update faList;
            
            createAmortizationEntriesBatch amoEntBatch = new createAmortizationEntriesBatch();
            Database.executeBatch(amoEntBatch, 5);
        } 
    }
    
    // For auto creating the Amortization Entries when the Fixed Asset Location is 'DLS - Herndon'
    private static testMethod void testMethod3() {
        
        List<Equipment__c> equList = TestClassUtil.createTestEquipment();
        List<MTT_Location__c> locList = TestClassUtil.createTestLocations();
        // Since the GL inserted in UTIL is all used in the Accounting Settings
        List<AcctSeed__GL_Account__c> glAcc = new List<AcctSeed__GL_Account__c> {
            new AcctSeed__GL_Account__c(Name = 'Test GL1 15950',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Expense', AcctSeed__Bank__c = false,GL_Account__c = '15950'),
            new AcctSeed__GL_Account__c(Name = 'Test GL2 75475',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Expense', AcctSeed__Bank__c = false, GL_Account__c = '75475')
        };
        insert glAcc;
        List<AcctSeed__Fixed_Asset__c> faList = [SELECT Id, Name, Book_Value__c, current_month_Depreciation__c FROM AcctSeed__Fixed_Asset__c LIMIT 2];
        
        Date myDate = System.today();
        Date stDate = System.today().addMonths(-1);
        Date enDate = System.today().addDays(10);
        String mon = String.valueOf(stDate.month());
        
        if(stDate.month() < 10) {
            mon = '0'+stDate.month();
        }
        
        String nameStr = stDate.year()+'-'+mon;
        
        List<AcctSeed__Accounting_Period__c> accPer = new List<AcctSeed__Accounting_Period__c> {
            new AcctSeed__Accounting_Period__c(name = nameStr, AcctSeed__Start_Date__c = stDate, AcctSeed__End_Date__c = enDate)
        };
        insert accPer;
        
        if(equList.size() > 0 && faList.size() > 0 && locList.size() > 0) {
            
            locList[0].Name = 'DLS - Herndon';
            update locList;
            
            for(Equipment__c eq : equList) {
                eq.Stage__c = 'Active';
                eq.Assigned_Location__c = locList[0].Id;
                eq.Acquisition_Cost__c = 1200;
            }
            update equList;
            
            System.debug('faList::::'+faList);
            for(AcctSeed__Fixed_Asset__c fa : faList) {
                fa.Name = 'Insulation for 15 exisiting office partitions. Patch all holes from Testing';
                fa.Equipment__c = equList[0].Id;
                fa.of_Months_Depreciation__c = 3;
                fa.Stage__c  = 'Active';
                fa.Location__c = locList[0].Id;
                fa.AcctSeed__Value__c = 100;
                fa.Accumulated_Depreciation__c = 95;
            }   
            update faList;
            System.debug('after update'+[SELECT Id, Name, Book_Value__c, current_month_Depreciation__c FROM AcctSeed__Fixed_Asset__c LIMIT 2]);
                         
            createAmortizationEntriesBatch amoEntBatch = new createAmortizationEntriesBatch();
            Database.executeBatch(amoEntBatch, 5);
        } 
    } 
    
    private static testMethod void testMethod4() {
        
        List<Equipment__c> equList = TestClassUtil.createTestEquipment();
        List<MTT_Location__c> locList = TestClassUtil.createTestLocations();
        // Since the GL inserted in UTIL is all used in the Accounting Settings
        List<AcctSeed__GL_Account__c> glAcc = new List<AcctSeed__GL_Account__c> {
            new AcctSeed__GL_Account__c(Name = 'Test GL1 15950',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Expense', AcctSeed__Bank__c = false,GL_Account__c = '15950'),
            new AcctSeed__GL_Account__c(Name = 'Test GL2 75475',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Expense', AcctSeed__Bank__c = false, GL_Account__c = '75475'),
            new AcctSeed__GL_Account__c(Name = 'Test GL2 81370',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Expense', AcctSeed__Bank__c = false, GL_Account__c = '81370')
        };
        insert glAcc;
        List<AcctSeed__Fixed_Asset__c> faList = [SELECT Id, Name, Book_Value__c, current_month_Depreciation__c, RecordTypeId FROM AcctSeed__Fixed_Asset__c LIMIT 2];
        
        Id compSoft = Schema.SObjectType.AcctSeed__Fixed_Asset__c.getRecordTypeInfosByDeveloperName().get('Computer_Software').getRecordTypeId();
        
        
        Date myDate = System.today();
        Date stDate = System.today().addMonths(-1);
        Date enDate = System.today().addDays(10);
        String mon = String.valueOf(stDate.month());
        
        if(stDate.month() < 10) {
            mon = '0'+stDate.month();
        }
        
        String nameStr = stDate.year()+'-'+mon;
        
        List<AcctSeed__Accounting_Period__c> accPer = new List<AcctSeed__Accounting_Period__c> {
            new AcctSeed__Accounting_Period__c(name = nameStr, AcctSeed__Start_Date__c = stDate, AcctSeed__End_Date__c = enDate)
        };
        insert accPer;
        
        if(equList.size() > 0 && faList.size() > 0 && locList.size() > 0) {
            
            locList[0].Name = 'DLS - Herndon';
            update locList;
            
            for(Equipment__c eq : equList) {
                eq.Stage__c = 'Active';
                eq.Assigned_Location__c = locList[0].Id;
                eq.Acquisition_Cost__c = 1200;
            }
            update equList;
            
            System.debug('faList::::'+faList);
            for(AcctSeed__Fixed_Asset__c fa : faList) {
                fa.Name = 'Insulation for 15 exisiting office partitions. Patch all holes from Testing';
                fa.Equipment__c = equList[0].Id;
                fa.of_Months_Depreciation__c = 3;
                fa.Stage__c  = 'Active';
                fa.Location__c = locList[0].Id;
                fa.AcctSeed__Value__c = 100;
                fa.Accumulated_Depreciation__c = 95;
                fa.RecordTypeId = compSoft;
            }   
            update faList;
            System.debug('after update'+[SELECT Id, Name, Book_Value__c, current_month_Depreciation__c FROM AcctSeed__Fixed_Asset__c LIMIT 2]);
            
            try{
                createAmortizationEntriesBatch amoEntBatch = new createAmortizationEntriesBatch();
                Database.executeBatch(amoEntBatch, 5);
            }catch(DmlException e){
            
                System.debug(':::::'+e.getMessage());
            }
        } 
    } 
}