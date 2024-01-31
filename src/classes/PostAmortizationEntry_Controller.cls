/***************************************************
    Developed by GRK on 16 Aug, 2018
    to use it in Lightning Component
******************************************************/

public class PostAmortizationEntry_Controller{
    @AuraEnabled
    public static String getAmortizationEntries(String filterName) {
        List<AcctSeed__Fixed_Asset__c> fAList = new List<AcctSeed__Fixed_Asset__c>();
        //fAList = FixedAssetService.getFixedAssets(new Set<Id>(), ' WHERE Stage__c = \'Active\'', ',Equipment__r.Name');
        fAList = FixedAssetService.getFixedAssets(new Set<Id>(), ' WHERE ( Stage__c = \'Active\' OR ( (Stage__c = \'Available\' OR Stage__c = \'Parts\' OR Stage__c = \'Planned Disposal\' OR Stage__c = \'Inactive\') AND Date_Placed_in_Service__c != null)) AND Book_Value__c > 0',',Equipment__r.RecordTypeId,Equipment__r.Name,Equipment__r.Service_Tag__c,Location__r.Name,RecordType.DeveloperName,RecordType.Name');
        String currentMonth;    
        System.debug(':::***:::fAList--Size:::'+fAList.size());
        
        List<AmortizationEntryDomain.AEWrapperClass> aes = formAEList(fAList);
        List<AmortizationEntryDomain.AELocationWrapperClass> aeWrappers = new List<AmortizationEntryDomain.AELocationWrapperClass>();
        Map<String,List<AmortizationEntryDomain.AEWrapperClass>> tempAEMap = new Map<String,List<AmortizationEntryDomain.AEWrapperClass>>();
        Map<String, Decimal> amountTotalMap = new Map<String, Decimal>();
        System.debug('aes :::::'+aes );

        for(AmortizationEntryDomain.AEWrapperClass ae : aes) {
            currentMonth = ae.periodName;

            if(filterName == 'Location'){
                if(!tempAEMap.containsKey(ae.locationName)) {
                    tempAEMap.put(ae.locationName, New List<AmortizationEntryDomain.AEWrapperClass>());
                } 
                tempAEMap.get(ae.locationName).add(ae);
                
                if(!amountTotalMap.containskey(ae.locationName) && ae.amount != null) {
                    amountTotalMap.put(ae.locationName, ae.amount);
                } else if(amountTotalMap.get(ae.locationName) != null && ae.amount != null){
                    System.debug(ae.locationName + ':::::' + ae.amount);
                    Decimal temp = amountTotalMap.get(ae.locationName) + ae.amount;
                    amountTotalMap.put(ae.locationName, temp );
                }
                
            }else if(filterName == 'Fixed Asset RecordType'){
                if(!tempAEMap.containsKey(ae.fixedAssetRT)) {
                    tempAEMap.put(ae.fixedAssetRT, New List<AmortizationEntryDomain.AEWrapperClass>());
                } 
                tempAEMap.get(ae.fixedAssetRT).add(ae);
                
                if(!amountTotalMap.containskey(ae.fixedAssetRT) && ae.amount != null) {
                    amountTotalMap.put(ae.fixedAssetRT, ae.amount);
                } else if(amountTotalMap.get(ae.fixedAssetRT) != null && ae.amount != null){
                    System.debug(ae.fixedAssetRT + ':::::' + ae.amount);
                    Decimal temp = amountTotalMap.get(ae.fixedAssetRT) + ae.amount;
                    amountTotalMap.put(ae.fixedAssetRT, temp );
                }
            }
            
            System.debug('tempAEMap::::'+tempAEMap);
            
            System.debug('amountTotalMap::::::'+amountTotalMap);
            //amountTotalMap.get(ae.AcctSeed__Fixed_Asset__r.Location__c);
        }
        
        for(String key : tempAEMap.keySet()) {
            AmortizationEntryDomain.AELocationWrapperClass aeWrap = new AmortizationEntryDomain.AELocationWrapperClass();
            aeWrap.locationFARTGroupBy = key;
            aeWrap.aeList.addAll(tempAEMap.get(key));
            aeWrap.count = tempAEMap.get(key) != null ? tempAEMap.get(key).size() : 0;
            aeWrap.amountSum = amountTotalMap.get(key);
            aeWrap.currentMonth = currentMonth;
            aeWrappers.add(aeWrap);
        }
        return SYSTEM.JSON.serialize(aeWrappers);
    }
    
    /*@AuraEnabled
    public static String updateAmortizationEntries(String aeWrapper, List<Id> aeId) {
        try{
            List<AmortizationEntryDomain.AEWrapperClass> aeWrappes = (List<AmortizationEntryDomain.AEWrapperClass>) System.JSON.deserialize(aeWrapper, List<AmortizationEntryDomain.AEWrapperClass>.class);
            //List<AmortizationEntryDomain.AEWrapperClass>) SYSTEM.JSON.Deserialize(aeWrapper);
            Set<Id> aeIdsToDel = New Set<Id>(aeId);
            List<AcctSeed__Scheduled_Revenue_Expense__c> toUpdate = new List<AcctSeed__Scheduled_Revenue_Expense__c>();
            List<AcctSeed__Scheduled_Revenue_Expense__c> toDelete = new List<AcctSeed__Scheduled_Revenue_Expense__c>();
            
            System.debug('aeIdsToDel:::'+aeIdsToDel);
            for( AmortizationEntryDomain.AEWrapperClass aeWrap : aeWrappes ) {
                for(AcctSeed__Scheduled_Revenue_Expense__c ae : aeWrap.aeList) {
                    if(aeIdsToDel.contains(ae.Id)) {
                        toDelete.add(ae);
                        ae.AcctSeed__Status__c = 'Scheduled';
                        toUpdate.add(ae);
                    } 
                }
            }
            System.debug('toDelete:::'+toDelete);
            System.debug('toUpdate:::'+toUpdate);
            update toUpdate;
            //delete toDelete;
        } catch(Exception ex) {
            System.debug('Error::::'+ex.getMessage());
        }
        
        return '';
    }*/
    
    public static List<AmortizationEntryDomain.AEWrapperClass> formAEList(List<AcctSeed__Fixed_Asset__c> FAList) {
        List<AmortizationEntryDomain.AEWrapperClass> aEList = new List<AmortizationEntryDomain.AEWrapperClass>();
        Map<String, Id> glAccMap = new Map<String, Id>();
        Map<String, Id> glAccVarMap = new Map<String, Id>();
        
        List<AcctSeed__Accounting_Period__c> accPeriod;
        // To display the records for the Last Month before 17th of every month. (Since we are creating the records on 17th)
        if(System.Today().Day() < 17) {
            accPeriod = [SELECT Id, Name FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c = LAST_MONTH];
        } else {
            accPeriod = [SELECT Id, Name FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c = THIS_MONTH];
        }
        
        for(Sobject_Master_Field_Mapping__c master : [SELECT Id,Name,Default_Field_Value__c,Field_Name__c,Object_Name__c,RecordType_Name__c 
                                                      FROM Sobject_Master_Field_Mapping__c 
                                                      WHERE Field_Name__c IN ('AcctSeed__Debit_GL_Account__c', 'AcctSeed__Credit_GL_Account__c', 'AcctSeed__GL_Account_Variable_1__c')]) {
            if(master.Field_Name__c != 'AcctSeed__GL_Account_Variable_1__c')
                glAccMap.put(master.Default_Field_Value__c, null);
            else 
                glAccVarMap.put(master.Default_Field_Value__c, null);
        
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
        String glAccName,glAccVarName;
        
        for(AcctSeed__Fixed_Asset__c fa : FAList) {
        
            AmortizationEntryDomain.AEWrapperClass amoEnt = new AmortizationEntryDomain.AEWrapperClass();
            
            if(glAccMap != null && glAccMap.size() > 0) {
                                
                if(fa.RecordType.DeveloperName == 'Computer_Software') { // Modified based on W-005074
                    glAccId = (glAccMap.containsKey('81370'))?glAccMap.get('81370'):null;
                    glAccName = (glAccMap.containsKey('81370'))?'81370':'';
                } else if(fa.Location__c != null) {
                    if(fa.Location__r.Name == 'DLS - Rosslyn' || fa.Location__r.Name == 'Telework') {
                        glAccId = (glAccMap.containsKey('75175'))?glAccMap.get('75175'):null;
                        glAccName = (glAccMap.containsKey('75175')) ? '75175' : '';
                    } else if(fa.Location__r.Name == 'DLS - Herndon') {
                        glAccId = (glAccMap.containsKey('75475')) ? glAccMap.get('75475') : null;
                        glAccName = (glAccMap.containsKey('75475')) ? '75475' : '';
                    } else if(fa.Location__r.Name == 'DLS - Elkridge') {
                        glAccId = (glAccMap.containsKey('75275')) ? glAccMap.get('75275') : null;     
                        glAccName = (glAccMap.containsKey('75275')) ? '75275' : '';
                    }   
                }
            }
            
            if(glAccVarMap != null && glAccVarMap.size() > 0) {                
                if(fa.RecordType.DeveloperName == 'Computer_Software') { // Modified based on W-005074
                    glAccVarId = (glAccVarMap.containsKey('ADM0SF'))?glAccVarMap.get('ADM0SF'):null;
                    glAccVarName = (glAccVarMap.containsKey('ADM0SF'))?'ADM0SF':'';
                } else if(fa.Location__c != null) {
                    if(fa.Location__r.Name == 'DLS - Rosslyn' || fa.Location__r.Name == 'Telework') {
                        glAccVarId = (glAccVarMap.containsKey('FSC0ARL'))?glAccVarMap.get('FSC0ARL'):null;
                        glAccVarName = (glAccVarMap.containsKey('FSC0ARL'))?'FSC0ARL':'';
                    } else if(fa.Location__r.Name == 'DLS - Herndon') {
                        glAccVarId = (glAccVarMap.containsKey('FSC0HRN'))?glAccVarMap.get('FSC0HRN'):null;
                        glAccVarName = (glAccVarMap.containsKey('FSC0HRN'))?'FSC0HRN':'';
                    } else if(fa.Location__r.Name == 'DLS - Elkridge') {
                        glAccVarId = (glAccVarMap.containsKey('FSC0MD'))?glAccVarMap.get('FSC0MD'):null; 
                        glAccVarName = (glAccVarMap.containsKey('FSC0MD'))?'FSC0MD':'';      
                    }   
                }
            } 
            
            if(accPeriod.size() > 0) {
                amoEnt.periodId = accPeriod[0].Id;
                amoEnt.periodName = accPEriod[0].Name;
            } else {
                amoEnt.periodName = String.ValueOf(System.Today().Year()) + '-' + DateTime.Now().format('MM');
            }
            amoEnt.amount = fa.Current_Month_Depreciation__c;
            amoEnt.gLVar1Id = glAccVarId;
            amoEnt.gLVar1Name = glAccVarName;
            amoEnt.creditGLAccId = (glAccMap.containsKey('15950')) ? glAccMap.get('15950') : null;
            amoEnt.creditGLAccName = (glAccMap.containsKey('15950')) ? '15950' : null;
            amoEnt.debitGLAcctId = glAccId;
            amoEnt.debitGLAcctName = glAccName;
            amoEnt.locationName = fa.Location__r.Name;
            amoEnt.fAId = fa.Id;
            amoEnt.fAName = fa.Name;
            amoEnt.equipId = fa.Equipment__c;
            amoEnt.equipName = fa.Equipment__r.Name;
            amoEnt.fixedAssetRT = fa.RecordType.Name;
            amoEnt.assetId = fa.Asset_Id__c;
            amoEnt.serviceTag = fa.Equipment__r.Service_Tag__c;
            
            System.debug(':::***:::amoEnt:::'+amoEnt);
            aEList.add(amoEnt);
        }
        return aEList;
    }
}