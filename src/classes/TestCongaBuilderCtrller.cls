@IsTest 
public class TestCongaBuilderCtrller{
    static testMethod void testCongaBuilderCtrller() { 
     
        list<account> acclist = new list<account>();
        Account ac1 = new account();
        ac1.name = 'DLI-W';
        acclist.add(ac1);
         
        Account ac2 = new account();
        ac2.name = 'DLI-W - LT';
        acclist.add(ac2);
         
        Account ac3 = new account();
        ac3.name = 'DLI-W - AFPAK';
        acclist.add(ac3);
        insert acclist;      
         
        Account acc1 =[select id from Account where name = 'DLI-W'];
        Account acc2 =[select id from Account where name = 'DLI-W - LT'];  
        Account acc3 =[select id from Account where name = 'DLI-W - AFPAK'];     
        
        list<Opportunity> opplist = new list<opportunity>();
        Opportunity opp = new opportunity();
        opp.name='test 1';
        opp.Account= acc1;
        opp.StageName = 'Proposal';
        opp.CloseDate =system.today();        
        opp.Conga_Opportunity__c =true;
        opplist.add(opp); 
        
        Opportunity opp1 = new opportunity();
        opp1.name='test 2';
        opp1.Account = acc2;
        opp1.StageName = 'Proposal';
        opp1.CloseDate =system.today();        
        opp1.Conga_Opportunity__c =false;
        opplist.add(opp1); 
        
        Opportunity opp2 = new opportunity();
        opp2.name='test 3';
        opp2.Account = acc3;
        opp2.StageName = 'Proposal';
        opp2.CloseDate =system.today();        
        opp2.Conga_Opportunity__c =false;
        opplist.add(opp2); 
        insert opplist;
        
        list<Time_Log__c> tloglist = new list<Time_Log__c>(); 
        Time_Log__c tl = new Time_Log__c();
        tl.Opportunity__c = opplist[1].id;
        tl.Date__c = system.today();
        tl.Hours__c = 6;
        tl.Last_Month__c = true;
        tloglist.add(tl);
                
        Time_Log__c t2 = new Time_Log__c();
        t2.Opportunity__c = opplist[0].id;
        t2.Date__c = system.today()-31;
        t2.Hours__c = 6;
        t2.Last_Month__c = false;
        tloglist.add(t2);
        
        Time_Log__c t3 = new Time_Log__c();
        t3.Opportunity__c = opplist[2].id;
        t3.Date__c = system.today()-31;
        t3.Hours__c = 6;
        t3.Last_Month__c = false;
        tloglist.add(t3);
        
        try {
            insert tloglist;  
            
        }catch(Exception e) {
        
            system.debug(':::::::::erro::::::'+e.getMessage());
            Boolean expectedExceptionThrown;
            
            if(e.getMessage().contains('You cannot delete Time Log record. Please unpost it.')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('You cannot edit Time Log record after Time Log locking period')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('Insufficient Privilege')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('Please update Time Log comments')) {
                expectedExceptionThrown = true;
            }
            
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        
        CongaBuilderCtrller conga = new CongaBuilderCtrller(); 
        conga.timelog = 'This Month';
        conga.acc=acc2.id;    
        conga.getItems();      
        conga.getDetails(); 
        
        CongaBuilderCtrller conga1 = new CongaBuilderCtrller(); 
        conga1.timelog = 'Last Month';
        conga1.acc=acc3.id;             
        conga1.getItems();         
        conga1.getDetails();   
        
        CongaBuilderCtrller conga2 = new CongaBuilderCtrller(); 
        conga2.timelog = 'Last Month';
        conga2.acc='';  
        conga2.optlog.opportunity__c=opplist[2].id;          
        conga2.getItems();         
        conga2.getDetails(); 
        conga2.Pgref();     
            
    }
}