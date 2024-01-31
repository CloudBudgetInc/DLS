// To send more than 100 Email Notification in single execution
// This batch called from scheduler - GetFeedBack_MonthlyEmail 
// Created by Keerthika on April 7 2018

global class GetFeedbackMonthlyBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String proList = 'SELECT Id,Name,Start_Date__c,End_Date__c FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = \'Active\' AND End_Date__c > THIS_MONTH AND Start_Date__c <= THIS_MONTH AND  RecordType.DeveloperName != \'Testing_Projects\'';
        return Database.getQueryLocator(proList);
    }  
    global void execute(Database.BatchableContext BC, List<AcctSeed__Project__c> projList){
        Set<Id> proIdSet = new Set<Id>();
        List<AcctSeed__Project__c> proList = new List<AcctSeed__Project__c>();
        
        if(projList != Null && projList.size() > 0) {
            for(AcctSeed__Project__c pro : projList) {
                if(pro.Start_Date__c != Null) {
                    proIdSet.add(pro.Id);
                    proList.add(pro);
                }
            }
        }
        if(proIdSet.size() > 0) {
            sendFeedbackFormHelper.sendMonthlyEmail(proIdSet,proList);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}