@isTest
private class PostAmortizationEntry_Controller_Test {
    
    @testSetup static void setup() {
        
        List<AcctSeed__Fixed_Asset__c> fixedAssList = TestClassUtil.createFixedAsset();
        List<AcctSeed__Accounting_Variable__c> accVar = TestClassUtil.createAccountingVariable();
        List<Sobject_Master_Field_Mapping__c> sobjFieldMap = TestClassUtil.createSobjMasterFieldMap();
        List<AcctSeed__Accounting_Settings__c> accSet = TestClassUtil.createAccountSettings();
    }
    
    private static testMethod void testMethod1() {
        
        //List<AcctSeed__Fixed_Asset__c> fixedAssList = TestClassUtil.createFixedAsset();
        List<Equipment__c> equList = TestClassUtil.createTestEquipment();
        List<MTT_Location__c> locList = TestClassUtil.createTestLocations();
        List<AcctSeed__GL_Account__c> glAccList = TestClassUtil.createTestGLAccount();
        
        List<AcctSeed__Fixed_Asset__c> fixedAssList = [SELECT Id, Name, Stage__c, Location__c, AcctSeed__Value__c, Accumulated_Depreciation__c FROM AcctSeed__Fixed_Asset__c LIMIT 2];
        List<Equipment__c> eqip = [SELECT Id, Name, Acquisition_Cost__c  FROM Equipment__c LIMIT 2];
        
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
        
        if(fixedAssList.size() > 0 && eqip.size() > 0 && locList.size() > 0 && glAccList.size() > 0) {
            
            glAccList[0].GL_Account__c = '15950';
            glAccList[1].GL_Account__c = '75175';
            update glAccList;
            
            locList[0].Name = 'DLS - Rosslyn';
            update locList;

            for(Equipment__c eq : eqip) {
                eq.Stage__c = 'Active';
                eq.Assigned_Location__c = locList[0].Id;
                eq.Acquisition_Cost__c = 60;
            }
            update eqip;
            
            for(AcctSeed__Fixed_Asset__c fa : fixedAssList) {
                fa.Equipment__c = eqip[0].Id;
                fa.Stage__c  = 'Active';
                fa.Location__c = locList[0].Id;
                fa.AcctSeed__Value__c = 15;
                fa.Accumulated_Depreciation__c = 5;
                fa.of_Months_Depreciation__c = 5;
            }
            update fixedAssList;
        }
        
        String ret = PostAmortizationEntry_Controller.getAmortizationEntries('Location');
        
        if(ret != null && ret != '') {
            List<AcctSeed__Fixed_Asset__c> faList = [SELECT Id, Name, Location__c FROM AcctSeed__Fixed_Asset__c WHERE Id = :fixedAssList[0].Id];
            if(faList.size() > 0){
                System.assert(ret.contains(eqip[0].Name));
            }
        }
    }
        
    private static testMethod void testMethod2() {
        
        //List<AcctSeed__Fixed_Asset__c> fixedAssList = TestClassUtil.createFixedAsset();
        List<Equipment__c> equList = TestClassUtil.createTestEquipment();
        List<MTT_Location__c> locList = TestClassUtil.createTestLocations();
        
        List<AcctSeed__Fixed_Asset__c> fixedAssList = [SELECT Id, Name, Stage__c, Location__c FROM AcctSeed__Fixed_Asset__c LIMIT 2];
        List<Equipment__c> eqip = [SELECT Id, Name FROM Equipment__c LIMIT 2];
        
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
        
        if(fixedAssList.size() > 0 && eqip.size() > 0 && locList.size() > 0) {
            
            locList[0].Name = 'DLS - Herndon';
            update locList;

            for(Equipment__c eq : eqip) {
                eq.Stage__c = 'Active';
                eq.Assigned_Location__c = locList[0].Id;
            }
            update eqip;
            
            for(AcctSeed__Fixed_Asset__c fa : fixedAssList) {
                fa.Equipment__c = eqip[0].Id;
                fa.Stage__c  = 'Active';
                fa.Location__c = locList[0].Id;
            }
            update fixedAssList;
        }
        
        String ret = PostAmortizationEntry_Controller.getAmortizationEntries('Location');
        
        if(ret != null && ret != '') {
            List<AcctSeed__Fixed_Asset__c> faList = [SELECT Id, Name, Location__c FROM AcctSeed__Fixed_Asset__c WHERE Id = :fixedAssList[0].Id];
            if(faList.size() > 0){
                System.assert(ret.contains(eqip[0].Name));
            }
        }
    }
    
    private static testMethod void testMethod3() {
        
        //List<AcctSeed__Fixed_Asset__c> fixedAssList = TestClassUtil.createFixedAsset();
        List<Equipment__c> equList = TestClassUtil.createTestEquipment();
        List<MTT_Location__c> locList = TestClassUtil.createTestLocations();
        
        List<AcctSeed__Fixed_Asset__c> fixedAssList = [SELECT Id, Name, Stage__c,Location__c FROM AcctSeed__Fixed_Asset__c LIMIT 2];
        List<Equipment__c> eqip = [SELECT Id, Name FROM Equipment__c LIMIT 2];
        
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
        
        if(fixedAssList.size() > 0 && eqip.size() > 0 && locList.size() > 0) {
            
            locList[0].Name = 'DLS - Elkridge';
            update locList;

            for(Equipment__c eq : eqip) {
                eq.Stage__c = 'Active';
                eq.Assigned_Location__c = locList[0].Id;
            }
            update eqip;
            
            for(AcctSeed__Fixed_Asset__c fa : fixedAssList) {
                fa.Equipment__c = eqip[0].Id;
                fa.Stage__c  = 'Active';
                fa.Location__c = locList[0].Id;
            }
            update fixedAssList;
        }
        
        String ret = PostAmortizationEntry_Controller.getAmortizationEntries('Location');
        
        if(ret != null && ret != '') {
            List<AcctSeed__Fixed_Asset__c> faList = [SELECT Id, Name, Location__c FROM AcctSeed__Fixed_Asset__c WHERE Id = :fixedAssList[0].Id];
            if(faList.size() > 0){
                System.assert(ret.contains(eqip[0].Name));
            }
        }
    }
    
    private static testMethod void testMethod4() {
        
        //List<AcctSeed__Fixed_Asset__c> fixedAssList = TestClassUtil.createFixedAsset();
        List<Equipment__c> equList = TestClassUtil.createTestEquipment();
        List<MTT_Location__c> locList = TestClassUtil.createTestLocations();
        List<AcctSeed__GL_Account__c> glAccList = TestClassUtil.createTestGLAccount();
        
        List<AcctSeed__Fixed_Asset__c> fixedAssList = [SELECT Id, Name, Stage__c, Location__c, AcctSeed__Value__c, Accumulated_Depreciation__c, RecordTypeId FROM AcctSeed__Fixed_Asset__c LIMIT 2];
        List<Equipment__c> eqip = [SELECT Id, Name, Acquisition_Cost__c  FROM Equipment__c LIMIT 2];
        
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
        
        if(fixedAssList.size() > 0 && eqip.size() > 0 && locList.size() > 0 && glAccList.size() > 0) {
            
            glAccList[0].GL_Account__c = '81370';
            glAccList[1].GL_Account__c = '75175';
            update glAccList;
            
            locList[0].Name = 'DLS - Rosslyn';
            update locList;

            for(Equipment__c eq : eqip) {
                eq.Stage__c = 'Active';
                eq.Assigned_Location__c = locList[0].Id;
                eq.Acquisition_Cost__c = 60;
            }
            update eqip;
            
            for(AcctSeed__Fixed_Asset__c fa : fixedAssList) {
                fa.Equipment__c = eqip[0].Id;
                fa.Stage__c  = 'Active';
                fa.Location__c = locList[0].Id;
                fa.AcctSeed__Value__c = 15;
                fa.Accumulated_Depreciation__c = 5;
                fa.of_Months_Depreciation__c = 5;
                fa.RecordTypeId = compSoft;
            }
            update fixedAssList;
        }
        
        String ret = PostAmortizationEntry_Controller.getAmortizationEntries('Location');
        
        if(ret != null && ret != '') {
            List<AcctSeed__Fixed_Asset__c> faList = [SELECT Id, Name, Location__c FROM AcctSeed__Fixed_Asset__c WHERE Id = :fixedAssList[0].Id];
            if(faList.size() > 0){
                System.assert(ret.contains(eqip[0].Name));
            }
        }
    }
    
    private static testMethod void testMethod5() {
        
        //List<AcctSeed__Fixed_Asset__c> fixedAssList = TestClassUtil.createFixedAsset();
        List<Equipment__c> equList = TestClassUtil.createTestEquipment();
        List<MTT_Location__c> locList = TestClassUtil.createTestLocations();
        List<AcctSeed__GL_Account__c> glAccList = TestClassUtil.createTestGLAccount();
        
        List<AcctSeed__Fixed_Asset__c> fixedAssList = [SELECT Id, Name, Stage__c, Location__c, AcctSeed__Value__c, Accumulated_Depreciation__c, RecordTypeId FROM AcctSeed__Fixed_Asset__c LIMIT 2];
        List<Equipment__c> eqip = [SELECT Id, Name, Acquisition_Cost__c  FROM Equipment__c LIMIT 2];
        
        Date myDate = System.today();
        Date stDate = System.today().addMonths(1);
        Date enDate = stDate.addDays(10);
        String mon = String.valueOf(stDate.month());
        
        if(stDate.month() < 10) {
            mon = '0'+stDate.month();
        }
        
        String nameStr = stDate.year()+'-'+mon;
        
        List<AcctSeed__Accounting_Period__c> accPer = new List<AcctSeed__Accounting_Period__c> {
            new AcctSeed__Accounting_Period__c(name = nameStr, AcctSeed__Start_Date__c = stDate, AcctSeed__End_Date__c = enDate)
        };
        insert accPer;
        
        if(fixedAssList.size() > 0 && eqip.size() > 0 && locList.size() > 0 && glAccList.size() > 0) {
            
            glAccList[0].GL_Account__c = '81370';
            glAccList[1].GL_Account__c = '75175';
            update glAccList;
            
            locList[0].Name = 'DLS - Rosslyn';
            update locList;

            for(Equipment__c eq : eqip) {
                eq.Stage__c = 'Active';
                eq.Assigned_Location__c = locList[0].Id;
                eq.Acquisition_Cost__c = 60;
            }
            update eqip;
            
            for(AcctSeed__Fixed_Asset__c fa : fixedAssList) {
                fa.Equipment__c = eqip[0].Id;
                fa.Stage__c  = 'Active';
                fa.Location__c = locList[0].Id;
                fa.AcctSeed__Value__c = 15;
                fa.Accumulated_Depreciation__c = 5;
                fa.of_Months_Depreciation__c = 5;
            }
            update fixedAssList;
        }
        
        String ret = PostAmortizationEntry_Controller.getAmortizationEntries('Fixed Asset RecordType');
        
        if(ret != null && ret != '') {
            List<AcctSeed__Fixed_Asset__c> faList = [SELECT Id, Name, Location__c FROM AcctSeed__Fixed_Asset__c WHERE Id = :fixedAssList[0].Id];
            if(faList.size() > 0){
                System.assert(ret.contains(eqip[0].Name));
            }
        }
    }
}