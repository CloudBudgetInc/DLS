/*******************************************************************************
- class for schedule Expensify Credit Cards Sync from Expensify
- Created by Dhinesh - W-005523 - Expensify Integration
- Scheduled on Daily basis
*******************************************************************************/
public class ExpensifyCreditCardSync_Scheduler implements Schedulable, Database.AllowsCallouts, Database.Batchable<sObject> {
  
    public void execute(SchedulableContext SC) {
        Database.executebatch(new ExpensifyCreditCardSync_Scheduler());
    }
   
    public Iterable<sObject> start(Database.Batchablecontext BC){
        try{
            String creditCardsStr = ExpensifyUtil.getExpensifyCreditCards();
            List<ExpensifyDomain.CreditCardWrap> creditCardListWrap = (List<ExpensifyDomain.CreditCardWrap>) JSON.deserialize(creditCardsStr, List<ExpensifyDomain.CreditCardWrap>.class);        
            Map<String, Expensify_Credit_Card__c> creditNameIdAndEmailStrWithSFRecordMap = new Map<String, Expensify_Credit_Card__c>();
            List<Expensify_Credit_Card__c> expensifyCreditCardsToUpsert = new List<Expensify_Credit_Card__c>();
            
            for(Expensify_Credit_Card__c expensifyCreditCard : [SELECT Id, Card_ID__c, Card_Name__c, Card_Number__c, Contact__c, Email__c, Vendor__c FROM Expensify_Credit_Card__c]){
                creditNameIdAndEmailStrWithSFRecordMap.put(expensifyCreditCard.Card_ID__c+'~'+expensifyCreditCard.Email__c, expensifyCreditCard);
            }        
            
            for(ExpensifyDomain.CreditCardWrap creditCard : creditCardListWrap){
                Expensify_Credit_Card__c expensifyCreditCard = new Expensify_Credit_Card__c();
                if(creditNameIdAndEmailStrWithSFRecordMap.get(creditCard.cardID+'~'+creditCard.email) != null){
                    expensifyCreditCard.Id = creditNameIdAndEmailStrWithSFRecordMap.get(creditCard.cardID+'~'+creditCard.email).Id;
                }
                expensifyCreditCard.Card_ID__c = creditCard.cardID;
                expensifyCreditCard.Card_Name__c = creditCard.cardName;
                expensifyCreditCard.Card_Number__c = creditCard.cardNumber;
                expensifyCreditCard.Email__c = creditCard.email;
                expensifyCreditCard.Bank__c = creditCard.bank;
                
                expensifyCreditCardsToUpsert.add(expensifyCreditCard);
            } 
            
            upsert expensifyCreditCardsToUpsert;
        }catch(Exception exe){
            String result = exe.getMessage();            
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('ExpensifyCreditCardSync_Scheduler','ExpensifyCreditCardSync_Scheduler','',result+' at line number '+exe.getLineNumber(),'','Lightning Web Component')});
        }
        
        return new List<sObject>();    
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){  
        
    }

    public void finish(Database.BatchableContext info){
        
    }

}