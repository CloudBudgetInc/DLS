/***********************************************************************************
        - To populate Average_Hourly_Cost_Non_SCA_LT__c field in Language__c object
        - Work Item : W-001294
        - This batch called from PopulateAverageHourlyCost_Schedule
        - Created by HL on Apr 09 2019
    *****************************************************************************************/
    
global class PopulateAverageHourlyCost implements Database.batchable<sObject>,Database.Stateful { 
    
    global String exceptionMsg = '';
    global Database.QueryLocator start(Database.BatchableContext info){
    
        String languageQry = '';
        
        if(!Test.isRunningTest()) {
            languageQry = 'SELECT Id, Name, Average_Hourly_Cost_LT_Cost_Rate__c,Average_Hourly_Cost_LT_without_Prep__c FROM Language__c'; //Average_Hourly_Cost_Non_SCA_LT__c
        }else if(Test.isRunningTest()){
            languageQry = 'SELECT Id, Name, Average_Hourly_Cost_LT_Cost_Rate__c,Average_Hourly_Cost_LT_without_Prep__c FROM Language__c LIMIT 1';
        }
        
        //System.debug('languageQry=========='+languageQry);
        return Database.getQueryLocator(languageQry);
    }
    
    global void execute(Database.BatchableContext info, List<Language__c> languages){
    
        Set<String> languageNames = new Set<String>();
        Map<String, Decimal> langNameAndAvgHC = new Map<String, Decimal>();
        Map<String, Decimal> langNameAndLTwoPrpAvgHC = new Map<String, Decimal>();
        List<Language__c> updateLanguages =new List<Language__c>();
        
        for(Language__c l : languages){
        
            languageNames.add(l.Name);
        }
        //System.debug('languageNames======='+languageNames+'languageNames SIZE======='+languageNames.size());
        
        for(AggregateResult r :[
            SELECT Contact__r.Language_1__c lang, AVG(AcctSeed__Hourly_Cost__c) avgHC 
            FROM AcctSeed__Cost_Rates__c 
            WHERE Contact__r.Language_1__c != '' AND Contact__r.Language_1__c IN :languageNames AND Status__c = 'Approved' AND Rate_Type__c = 'LT with Prep' AND  //Non-SCA LT
                Contact__r.RecordType.DeveloperName = 'Candidate' GROUP BY Contact__r.Language_1__c
        ]){
            //System.debug('r============'+r);
            Decimal hourlyCost = (Decimal)r.get('avgHC');
            String langName = (String)r.get('lang');
            langNameAndAvgHC.put(langName, hourlyCost.setscale(2));
        }
        
        for(AggregateResult r :[
            SELECT Contact__r.Language_1__c lang, AVG(AcctSeed__Hourly_Cost__c) avgHC 
            FROM AcctSeed__Cost_Rates__c 
            WHERE Contact__r.Language_1__c != '' AND Contact__r.Language_1__c IN :languageNames AND Status__c = 'Approved' AND Rate_Type__c = 'LT without Prep' AND  //Non-SCA LT
                Contact__r.RecordType.DeveloperName = 'Candidate' GROUP BY Contact__r.Language_1__c
        ]){
            //System.debug('r============'+r);
            Decimal hourlyCost = (Decimal)r.get('avgHC');
            String langName = (String)r.get('lang');
            langNameAndLTwoPrpAvgHC.put(langName, hourlyCost.setscale(2));
        }
        //System.debug('langNameAndAvgHC========='+langNameAndAvgHC);
        
        for(Language__c l : languages){
            Boolean isLangChanged = false;
            if(langNameAndAvgHC.containsKey(l.Name)){
                /*System.debug('l.Average_Hourly_Cost_Non_SCA_LT__c======'+l.Average_Hourly_Cost_Non_SCA_LT__c);
                if(l.Average_Hourly_Cost_Non_SCA_LT__c == NULL || (l.Average_Hourly_Cost_Non_SCA_LT__c != langNameAndAvgHC.get(l.Name))){
                    l.Average_Hourly_Cost_Non_SCA_LT__c = langNameAndAvgHC.get(l.Name);
                    updateLanguages.add(l);
                }*/
                System.debug('l.Average_Hourly_Cost_LT_Cost_Rate__c======'+l.Average_Hourly_Cost_LT_Cost_Rate__c);
                if(l.Average_Hourly_Cost_LT_Cost_Rate__c == NULL || (l.Average_Hourly_Cost_LT_Cost_Rate__c != langNameAndAvgHC.get(l.Name))){
                    l.Average_Hourly_Cost_LT_Cost_Rate__c = langNameAndAvgHC.get(l.Name);
                    isLangChanged = true;
                }
            }
            if(langNameAndLTwoPrpAvgHC.containsKey(l.Name)){
                System.debug('l.Average_Hourly_Cost_LT_without_Prep__c======'+l.Average_Hourly_Cost_LT_without_Prep__c);
                if(l.Average_Hourly_Cost_LT_without_Prep__c == NULL || (l.Average_Hourly_Cost_LT_without_Prep__c != langNameAndLTwoPrpAvgHC.get(l.Name))){
                    l.Average_Hourly_Cost_LT_without_Prep__c = langNameAndLTwoPrpAvgHC.get(l.Name);
                    isLangChanged = true;
                }
            }
            if(isLangChanged == true) {
                updateLanguages.add(l);
            }
        }
        //System.debug('updateLanguages ====='+updateLanguages+'updateLanguages SIZE======'+updateLanguages.size());
        
        if(updateLanguages.size() > 0){
        
            try{
                update updateLanguages;
            }catch(Exception e){
                if(String.isNotEmpty(exceptionMsg)){
                    exceptionMsg += '\n';
                }
                exceptionMsg += e.getMessage();
            }
        }
    }
    
    global void finish(Database.BatchableContext info){
        
        //system.debug(':::exceptionMsg:::::::'+exceptionMsg);
        if(String.isNotEmpty(exceptionMsg) || Test.isRunningTest()){
            List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setToAddresses(new String[] {system.Label.TimeCardDayEmail});
            mail.setSubject('Error on Populate Average Houly Cost'); 
            mail.setPlainTextBody(exceptionMsg);
            ErrorMailMsg.add(mail);
            try{
                if( ErrorMailMsg != null && ErrorMailMsg.size() > 0 ){
                    Messaging.sendEmail(ErrorMailMsg); 
                }
            } catch (Exception ex){
                system.debug('Ex::::'+ex);
            }    
        }
    }
}