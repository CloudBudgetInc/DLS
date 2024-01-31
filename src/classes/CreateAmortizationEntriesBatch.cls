// This Batch to auto-create the Amortization Entries each month for all active fixed asset
// Developed by E. Keerthika on 16th, August 2018

public class CreateAmortizationEntriesBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bC){
        return Database.getQueryLocator('SELECT Id, Name, Location__c, Location__r.Name, Current_Month_Depreciation__c, Book_Value__c, RecordType.DeveloperName FROM AcctSeed__Fixed_Asset__c WHERE  ( Stage__c = \'Active\' OR ( (Stage__c = \'Available\' OR Stage__c = \'Parts\' OR Stage__c = \'Planned Disposal\' OR Stage__c = \'Inactive\') AND Date_Placed_in_Service__c != null)) AND Book_Value__c > 0');
    }
    
    public void execute(Database.BatchableContext bC, List<AcctSeed__Fixed_Asset__c> fixAssList){
        
        List<AcctSeed__Scheduled_Revenue_Expense__c> amoEntList = new List<AcctSeed__Scheduled_Revenue_Expense__c>();
               
        Map<String, Id> glAccMap = new Map<String, Id>();
        Map<String, Id> glAccVarMap = new Map<String, Id>();
        
        List<AcctSeed__Accounting_Period__c> accPeriod = [SELECT Id, Name FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c = LAST_MONTH];
        
        for(Sobject_Master_Field_Mapping__c master : [SELECT Id,Name,Default_Field_Value__c,Field_Name__c,Object_Name__c,RecordType_Name__c 
                                                      FROM Sobject_Master_Field_Mapping__c 
                                                      WHERE Field_Name__c IN ('AcctSeed__Debit_GL_Account__c', 'AcctSeed__Credit_GL_Account__c', 'AcctSeed__GL_Account_Variable_1__c')]) {
            if(master.Field_Name__c != 'AcctSeed__GL_Account_Variable_1__c') {
                glAccMap.put(master.Default_Field_Value__c, null);
            } else {
                glAccVarMap.put(master.Default_Field_Value__c, null);
            }
        }
        
        if(glAccMap != null && glAccMap.size() > 0) {
            for(AcctSeed__GL_Account__c glAcc : [SELECT Id, Name, GL_Account__c FROM AcctSeed__GL_Account__c 
                                                 WHERE GL_Account__c IN :glAccMap.keySet()]) {
            
                glAccMap.put(glAcc.GL_Account__c,glAcc.Id);
            }
        }
        
        if(glAccVarMap != null && glAccVarMap.size() > 0) {
            for(AcctSeed__Accounting_Variable__c glAccVar : [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c 
                                                 WHERE Name IN :glAccVarMap.keySet()]) {
            
                glAccVarMap.put(glAccVar.Name, glAccVar.Id);
            }
        }
        
        Id glAccVarId, glAccId;
        
        for(AcctSeed__Fixed_Asset__c fa : fixAssList) {
            
            AcctSeed__Scheduled_Revenue_Expense__c amoEnt = new AcctSeed__Scheduled_Revenue_Expense__c();
            
            if(glAccMap != null && glAccMap.size() > 0) {
                     
                if(fa.RecordType.DeveloperName == 'Computer_Software') { // Modified based on W-005074
                    glAccId = (glAccMap.containsKey('81370'))?glAccMap.get('81370'):null;
                } else if(fa.Location__c != null) {
                    if(fa.Location__r.Name == 'DLS - Rosslyn' || fa.Location__r.Name == 'Telework') {
                        glAccId = (glAccMap.containsKey('75175'))?glAccMap.get('75175'):null;
                    } else if(fa.Location__r.Name == 'DLS - Herndon') {
                        glAccId = (glAccMap.containsKey('75475'))?glAccMap.get('75475'):null;
                    } else if(fa.Location__r.Name == 'DLS - Elkridge') {
                        glAccId = (glAccMap.containsKey('75275'))?glAccMap.get('75275'):null;     
                    }    
                }
            }
            
            if(glAccVarMap != null && glAccVarMap.size() > 0) { 
                
                if(fa.RecordType.DeveloperName == 'Computer_Software') { // Modified based on W-005074
                    glAccVarId = (glAccVarMap.containsKey('ADM0SF'))?glAccVarMap.get('ADM0SF'):null;
                } else if(fa.Location__c != null) {
                    if(fa.Location__r.Name == 'DLS - Rosslyn' || fa.Location__r.Name == 'Telework') {
                        glAccVarId = (glAccVarMap.containsKey('FSC0ARL'))?glAccVarMap.get('FSC0ARL'):null;
                    } else if(fa.Location__r.Name == 'DLS - Herndon') {
                        glAccVarId = (glAccVarMap.containsKey('FSC0HRN'))?glAccVarMap.get('FSC0HRN'):null;
                    } else if(fa.Location__r.Name == 'DLS - Elkridge') {
                        glAccVarId = (glAccVarMap.containsKey('FSC0MD'))?glAccVarMap.get('FSC0MD'):null;       
                    }   
                }
            }
            
            if(accPeriod.size() > 0) {
                amoEnt.AcctSeed__Accounting_Period__c = accPeriod[0].Id;
            }
            
            amoEnt.AcctSeed__Status__c = 'Scheduled';
            amoEnt.AcctSeed__Fixed_Asset__c = fa.Id;
            if(fa.Book_Value__c > fa.Current_Month_Depreciation__c) {
                amoEnt.AcctSeed__Amount__c = (fa.Current_Month_Depreciation__c != null ? fa.Current_Month_Depreciation__c : 0);                
            } else {
                amoEnt.AcctSeed__Amount__c = fa.Book_Value__c;
            }
            amoEnt.AcctSeed__Credit_GL_Account__c = (glAccMap.containsKey('15950'))?glAccMap.get('15950'):null;
            amoEnt.AcctSeed__Debit_GL_Account__c = glAccId;
            amoEnt.AcctSeed__GL_Account_Variable_1__c = glAccVarId;
            amoEntList.add(amoEnt);
        }
        insert amoEntList;
    }
    
    public void finish(Database.BatchableContext bC){
    }

}