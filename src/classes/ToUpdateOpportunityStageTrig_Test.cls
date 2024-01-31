@isTest
Public Class ToUpdateOpportunityStageTrig_Test{
     
    static testmethod void UpdateOpportunityMethod() {        
        
        List<Opportunity> oppList = new List<Opportunity> {
            new Opportunity(Name = 'Test Opp 1',StageName = 'Awarded',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20),
            new Opportunity(Name = 'Test Opp 2',StageName = 'Active',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20)
        };        
        insert oppList;
        
        List<Opportunity> opp = [SELECT Id,Name,StageName FROM Opportunity Limit 2];
        system.debug(':::opp'+opp);
        List<Transaction__c> transList = new List<Transaction__c>{
            new Transaction__c(Opportunity__c = opp[0].Id,Transaction_Date__c=System.today(), Reviewed__c = true),
            new Transaction__c(Opportunity__c = opp[0].Id,Transaction_Date__c=System.today().adddays(1), Reviewed__c = true),
            new Transaction__c(Opportunity__c = opp[1].Id,Transaction_Date__c=System.today().adddays(2), Reviewed__c = true)
            
        }; 
        insert transList;
        system.debug(':::transList'+transList);
        
        Transaction__c tra = transList[0];
        tra.Auth_last_4_digits__c = '2134';
        update tra;
        
    }
    
}