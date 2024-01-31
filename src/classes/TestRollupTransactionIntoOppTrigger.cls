@isTest(seeAllData = TRUE)
private class TestRollupTransactionIntoOppTrigger {

    static testMethod void RollupTransactionIntoOpportunityTriggerTestMethod() {
        
        List<Opportunity> oppList = new List<Opportunity> {
            new opportunity(Name = 'testopp', StageName = 'Qualification', CloseDate = System.today(), Supervisor__c = userInfo.getUserId())
        };
        insert oppList;
       
        List<Transaction__c> transList = new List<Transaction__c> {
             new Transaction__c(Opportunity__c = oppList[0].Id, Travel_Amount__c = 100, ODCs_Amount__c = 100, Hours_Paid__c = 10, Type__c = 'Transfer', Proficiency_Testing__c = 100, Transaction_Date__c = System.today()),
             new Transaction__c(Opportunity__c = oppList[0].Id, Travel_Amount__c = 100, ODCs_Amount__c = 100, Hours_Paid__c = 10, Type__c = 'Payment', Proficiency_Testing__c = 100, Transaction_Date__c = System.today())
        };
        insert transList;
       
        /*Opportunity oppRcd1 = [SELECT Total_Hours_Paid_Auth__c , Materials_Budget__c, Travel_ODC_Cost__c, Proficiency_Testing__c FROM Opportunity WHERE Id = :oppList[0].Id];
        System.assertEquals(200, oppRcd1.Materials_Budget__c);
        System.assertEquals(200, oppRcd1.Travel_ODC_Cost__c);
        System.assertEquals(200, oppRcd1.Proficiency_Testing__c); 
        System.assertEquals(20, oppRcd1.Total_Hours_Paid_Auth__c);*/          
        
        /*transList[0].Materials_Amount__c = 1000;
        transList[1].Materials_Amount__c = 1000;         
        update transList;*/
               
        /*Opportunity oppRcd2 = [SELECT Materials_Budget__c FROM Opportunity WHERE Id = :oppList[0].Id];
        System.assertEquals(2000, oppRcd2.Materials_Budget__c);*/
        
        delete transList;
        
        /*Opportunity oppRcd3 = [SELECT Total_Hours_Paid_Auth__c , Materials_Budget__c, Travel_ODC_Cost__c, Proficiency_Testing__c FROM Opportunity WHERE Id = :oppList[0].Id];
        System.assertEquals(0, oppRcd3.Materials_Budget__c);
        System.assertEquals(0, oppRcd3.Travel_ODC_Cost__c);
        System.assertEquals(0, oppRcd3.Total_Hours_Paid_Auth__c );
        System.assertEquals(0, oppRcd3.Proficiency_Testing__c );*/
    }
}