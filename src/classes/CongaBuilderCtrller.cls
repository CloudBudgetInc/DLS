Public Class CongaBuilderCtrller {

    Public string timelog{get;set;}
    Public string acc{get;set;}
    public list<Time_Log__c> timelogold;
    public Map<id,list<Opportunity>> Accoppmap;
    public Map<id,list<Time_Log__c>> opptimelogmap;
    public list<Time_Log__c> tllist;
    public list<Opportunity> tempoplist;
    public list<opportunity> opplist;    
    public time_log__c optlog {get;set;}
    public boolean shouldRender{get;set;}
   
    Public CongaBuilderCtrller(){
        
        timelogold = new list<Time_Log__c>();    
        Accoppmap = new Map<id,list<Opportunity>>();
        opptimelogmap = new Map<id,list<Time_Log__c>>();
        tllist = new list<Time_Log__c>();
        tempoplist = new list<Opportunity>(); 
        opplist = new list<opportunity>(); 
        optlog = new time_log__c();
        shouldRender =true;
        
    }
    
    public List<SelectOption> getItems() {
           
            Account acc1 =[select id from Account where name = 'DLI-W'];
            Account acc2 =[select id from Account where name = 'DLI-W - LT'];  
            Account acc3 =[select id from Account where name = 'DLI-W - AFPAK'];     
            
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','None'));
            options.add(new SelectOption(acc1.id,'DLI-W'));
            options.add(new SelectOption(acc2.id,'DLI-W - LT'));
            options.add(new SelectOption(acc3.id,'DLI-W - AFPAK'));            
            return options;
    }        
    
    public pagereference getDetails() {        
           
            if((acc == '' || acc == null) && optlog.Opportunity__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select Opportunity'));
                return null;
            }            
            
            for(Time_Log__c tlog : [Select id,Name,Opportunity__c,Date__c,Hours__c,Service_Item__c,Last_Month__c From Time_Log__c 
                                    Where Last_Month__c=true]){
                
                tlog.Last_Month__c = false;
                timelogold.add(tlog);
                
            } 
            
            if(timelogold!=null && timelogold.size() > 0){
                update timelogold;
            }
            
            System.debug('----time log = true---'+timelogold);  
            
            for(Opportunity op: [select id,name from opportunity where Conga_Opportunity__c=true]){
                op.Conga_Opportunity__c =false;
                opplist.add(op);
            }    
            
            if(opplist!=null && opplist.size()>0){
                update opplist;
            } 
            
            System.debug('----Opportunity = true---'+opplist); 
            if(acc!='' && acc != null){
                for(Opportunity opp: [select id,AccountId,Conga_Opportunity__c from Opportunity where AccountId =:acc]){ 
                    
                    opp.Conga_Opportunity__c =true;
                    if(!Accoppmap.containskey(opp.AccountId)){
                        Accoppmap.put(opp.AccountId,new List<Opportunity>());
                        }
                        Accoppmap.get(opp.AccountId).add(opp);       
                }  
            }else{
                for(Opportunity opp: [select id,AccountId,Conga_Opportunity__c from Opportunity where id =:optlog.opportunity__c]){ 
                    
                    opp.Conga_Opportunity__c =true;
                    if(!Accoppmap.containskey(opp.AccountId)){
                        Accoppmap.put(opp.AccountId,new List<Opportunity>());
                        }
                        Accoppmap.get(opp.AccountId).add(opp);       
                }  
                
            }              
                 
            System.debug('----Opportunity under the selected account---'+Accoppmap);     
            
            
            for(id op : Accoppmap.keyset()){
                tempoplist.addall(accoppmap.get(op));
            } 
            
            if(tempoplist!=null && tempoplist.size()>0){
                update tempoplist;
            }
            
            System.debug('----tempoplist---'+tempoplist);  
            
            if(timelog == 'Last Month'){
                
                for(Time_Log__c tlog : [select id,Name,Opportunity__c,Date__c,Hours__c,Service_Item__c,Last_Month__c From Time_Log__c
                                        where Opportunity__c IN: tempoplist AND Date__c = LAST_MONTH] ){
                    
                    tlog.Last_Month__c = true;
                    if(!opptimelogmap.containskey(tlog.Opportunity__c)){
                        opptimelogmap.put(tlog.Opportunity__c, new List<Time_Log__c>());
                    }
                    opptimelogmap.get(tlog.Opportunity__c).add(tlog);           
                }            
                System.debug('----Last month time log---'+opptimelogmap); 
            
            }else if(timelog == 'This Month'){
                
                for(Time_Log__c tlog : [Select id,Name,Opportunity__c,Date__c,Hours__c,Service_Item__c,Last_Month__c From Time_Log__c 
                                        Where Opportunity__c IN: tempoplist AND Date__c = This_MONTH] ){                
                   
                   tlog.Last_Month__c = true;
                   if(!opptimelogmap.containskey(tlog.Opportunity__c)){
                       opptimelogmap.put(tlog.Opportunity__c, new List<Time_Log__c>());
                   }
                   opptimelogmap.get(tlog.Opportunity__c).add(tlog);
                }      
                System.debug('----This month time log---'+opptimelogmap);
            }                
            
            for(id tl : opptimelogmap.keyset()){
                tllist.addall(opptimelogmap.get(tl));    
            }        
            System.debug('----Time log to be updated---'+tllist);
            
            if(tllist != null && tllist.size() >0){
                update tllist;
            } 
        
        if(tllist != null && tllist.size() >0){       
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.confirm,'Disposition Form is successfully generated')); 
            return null;
        } 
        return null;    
    } 
    
    public PageReference Pgref() {
        if(acc!='' && acc!=null){
            pageReference pg=new pageReference('/'+acc);
            return pg; 
        }else if(optlog.opportunity__c!= null){
            pageReference pg=new pageReference('/'+optlog.opportunity__c);
            return pg; 
        }
        return null;        
    }     
}