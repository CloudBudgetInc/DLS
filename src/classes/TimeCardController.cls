public without sharing class TimeCardController {

    Public date myDate = date.today();
    Public date weekStart = myDate.toStartofWeek()+1;
    Public date weekEnd = myDate.toStartofWeek()+7;
    Public String month;
    
    Public date monthStart = weekStart.toStartofMonth();
    Public date monthEnd = weekStart.addMonths(1).toStartofMonth().addDays(-1);
    Public date monthStart1 = weekEnd.toStartofMonth();
    Public date monthEnd1 = weekEnd.addMonths(1).toStartofMonth().addDays(-1);
    
    public TimeCardController (){
    
        //TimeCardCreateRec();
    }
    
    public void TimeCardCreateRec() {
        
        try {
            List<AcctSeed__Accounting_Period__c> accPeriodList = new List<AcctSeed__Accounting_Period__c>();
            List<AcctSeed__Accounting_Period__c> accPeriodNextMonthList = new List<AcctSeed__Accounting_Period__c>();
            
            if(monthStart == monthStart1 && monthEnd == monthEnd1) {
                accPeriodList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c,AcctSeed__Status__c FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c =: monthStart AND AcctSeed__End_Date__c =: monthEnd];
                system.debug('::::accPeriodList::::'+accPeriodList.size());
            } else {
            
                accPeriodList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c,AcctSeed__Status__c FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c =: monthStart AND AcctSeed__End_Date__c =: monthEnd];
                accPeriodNextMonthList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c,AcctSeed__Status__c FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c =: monthStart1 AND AcctSeed__End_Date__c =: monthEnd1];
                system.debug('::::accPeriodList::::'+accPeriodList.size());
            }
            
            if (accPeriodList == null || accPeriodList.size() == 0) {
                
                if(monthStart.month() < 10){
                    month = '0'+monthStart.month();
                }else {
                    month = String.valueOf(monthStart.month());
                }
                
                AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c();
                accPeriod.name = monthStart.year()+'-' +month;
                accPeriod.AcctSeed__Start_Date__c = monthStart;
                accPeriod.AcctSeed__End_Date__c = monthEnd;
                system.debug(':::::::::accPeriod::iggg::::'+accPeriod);
                Insert accPeriod;
                system.debug('****'+accPeriod.id);
            } 
            
            if (monthStart != monthStart1 && monthEnd != monthEnd1 && (accPeriodNextMonthList == null || accPeriodNextMonthList.size() == 0)) {
                
                if(monthStart1.month() < 10){
                    month = '0'+monthStart1.month();
                }else {
                    month = String.valueOf(monthStart1.month());
                }
                
                AcctSeed__Accounting_Period__c accPeriod1 = new AcctSeed__Accounting_Period__c();
                accPeriod1.name = monthStart1.year()+'-' +month;
                accPeriod1.AcctSeed__Start_Date__c = monthStart1;
                accPeriod1.AcctSeed__End_Date__c = monthEnd1;
                system.debug(':::::::::accPeriod1::iggg::::'+accPeriod1);
                Insert accPeriod1;
                system.debug('****'+accPeriod1.id);
            }   
            
            List<AcctSeed__Time_Card_Period__c> TimeCardList = [SELECT AcctSeed__End_Date__c,AcctSeed__Start_Date__c,Name FROM AcctSeed__Time_Card_Period__c WHERE AcctSeed__Start_Date__c >=: weekStart AND AcctSeed__End_Date__c <=: weekEnd ];
            system.debug('::::DATE:::'+myDate+':::::Date::::'+TimeCardList.size() );
            if(TimeCardList.size()>0 && TimeCardList.size() == 1&& TimeCardList != NULL){
                CreateTimeCard(TimeCardList[0].id);
            
            }
            else{
                AcctSeed__Time_Card_Period__c TimeCardNew = new AcctSeed__Time_Card_Period__c();
                TimeCardNew.name = myDate.year()+'-' + myDate.Month();
                TimeCardNew.AcctSeed__End_Date__c = weekEnd ;
                TimeCardNew.AcctSeed__Start_Date__c = weekStart ;
                Insert TimeCardNew;
                system.debug('****'+TimeCardNew.id);
                CreateTimeCard(TimeCardNew.id);
            }
        
        } catch(DmlException e) {
        
            sendEmailWhenErrorOccurs(e.getMessage());    
        } catch(SObjectException e) {
            
            sendEmailWhenErrorOccurs(e.getMessage());
        } catch(Exception ex) {
        
            sendEmailWhenErrorOccurs(ex.getMessage());
        } 
       
    }
    Public void CreateTimeCard( Id TimeCardPjtID ) {
        
        Map<Id,Set<Id>> instructorProjectTaskMap = new Map<Id,Set<Id>>();
        Map<Id,Id> contactIdUserIdMap = new Map<Id,Id>();
        List<AcctSeed__Time_Card__c> newTimeCard = new List<AcctSeed__Time_Card__c>();
        List<AcctSeed__Time_Card_Line__c> TimeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        Set<Id> instructorWithCardIdSet = new Set<Id>();
        List<AcctSeed__Time_Card__c> timeCardList = new List<AcctSeed__Time_Card__c>(); 
        //Id USerId;
        
        //Added by Sukanya to populate Project value on Time card Line on the creation
       // August 29th 2016
       Map<Id,Id> projectTaskIdProjectIdMap = new Map<Id,Id>();
       
        try {
            
            List<Events__c> EventList = [SELECT Date__c,Instructor__c,Schedule__r.Project_Task__c,Schedule__r.Project_Task__r.AcctSeed__Project__c FROM Events__c WHERE Date__c >=: weekStart  AND Date__c <=: weekEnd AND Instructor__c != Null AND Schedule__r.Project_Task__r.Project_Task_Type__c = 'Language Training' ];
            //Set<Id> EmpId = new Set<Id>();
            
            for(Events__c Ev : EventList ){
                
                if(!instructorProjectTaskMap.containskey(Ev.Instructor__c)){
                    instructorProjectTaskMap .put(Ev.Instructor__c,new Set<Id>());
                }
                
                instructorProjectTaskMap.get(Ev.Instructor__c).add(Ev.Schedule__r.Project_Task__c);
                
                 // Added by sukanya
               if(!projectTaskIdProjectIdMap.containsKey(Ev.Schedule__r.Project_Task__c)) {
               
                   projectTaskIdProjectIdMap.put(Ev.Schedule__r.Project_Task__c,Ev.Schedule__r.Project_Task__r.AcctSeed__Project__c);
               }
            }
            
            List<User> UserList = [SELECT contactId,Id FROM User WHERE isActive = TRUE and ContactId != NULL];
            for(user IdLoop : UserList){
                contactIdUserIdMap.put(IdLoop.contactId,IdLoop.Id);
                //EmpId.add(IdLoop.Id);
            
            }
            
            system.debug('%%%%%%%%%%%%%%%%%%%instructorProjectTaskMap.keySet()::::'+instructorProjectTaskMap.keySet());
            system.debug('%%%%%%%%%%%%%%%%%%%contactIdUserIdMap::::'+contactIdUserIdMap);
            system.debug('::::::::::projectTaskIdProjectIdMap:::::::'+projectTaskIdProjectIdMap);

            //system.debug('&&&&&&&&&'+EmpId);
            
            Set <Id> existingTimeCardIdSet = new Set <Id>();
            
            for(AcctSeed__Time_Card__c cardloop : [SELECT AcctSeed__Employee__c,Id,Intructor__c FROM AcctSeed__Time_Card__c WHERE Intructor__c != null AND Intructor__c IN :instructorProjectTaskMap.keySet() AND Intructor__c IN :contactIdUserIdMap.keySet() AND AcctSeed__Time_Card_Period__c = :TimeCardPjtID]){
                instructorWithCardIdSet.add(cardloop.Intructor__c);
                timeCardList.add (cardLoop);
                existingTimeCardIdSet.add(cardloop.Id);
            }
            system.debug('existingTimeCardIdSet:::::'+existingTimeCardIdSet);
            system.debug('%%%%%%%%%%%%%%%%%%%33333333333::::'+instructorWithCardIdSet);
            system.debug('%%%%%%%%%%%%%%%%%%%33333333333::::'+timeCardList);
            
            
            for(Id Ids : instructorProjectTaskMap.keySet()){
               
               If ( !instructorWithCardIdSet.contains (Ids) && contactIdUserIdMap.containsKey(Ids)) {
                   AcctSeed__Time_Card__c  TimeCardNew = new AcctSeed__Time_Card__c(Intructor__c =Ids,AcctSeed__Employee__c=contactIdUserIdMap.get(Ids),AcctSeed__Time_Card_Period__c=TimeCardPjtID);
                   newTimeCard.add(TimeCardNew );       
               }
               
            }
            
            if ( newTimeCard.size() > 0 ) {
                Insert newTimeCard;
                timeCardList.addAll(newTimeCard);       //Merged already created and newly created Time Card to create new Time Card Line.       
            }
            
           Map <Id, set <Id> > instructorIdProjectTaskIdSetMap = new Map <Id, set <Id> > (); 
           
           
           
           for ( AcctSeed__Time_Card_Line__c timeCardLine : [ SELECT Id, AcctSeed__Time_Card__r.Intructor__c, AcctSeed__Project_Task__c,AcctSeed__Project_Task__r.AcctSeed__Project__c FROM AcctSeed__Time_Card_Line__c WHERE AcctSeed__Time_Card__c IN : existingTimeCardIdSet  ] ) {
                             
               if(!instructorIdProjectTaskIdSetMap.containskey(timeCardLine.AcctSeed__Time_Card__r.Intructor__c)){
                    instructorIdProjectTaskIdSetMap.put(timeCardLine.AcctSeed__Time_Card__r.Intructor__c,new Set<Id>());
                }
                instructorIdProjectTaskIdSetMap.get(timeCardLine.AcctSeed__Time_Card__r.Intructor__c).add(timeCardLine.AcctSeed__Project_Task__c);
              
           }
           
            system.debug('timeCardList::::'+timeCardList);
            system.debug('instructorProjectTaskMap::::'+instructorProjectTaskMap);
            system.debug('instructorIdProjectTaskIdSetMap::::'+instructorIdProjectTaskIdSetMap);
            
            for(AcctSeed__Time_Card__c tm: timeCardList){
                system.debug('tm.Intructor__c::::'+tm.Intructor__c);
                for(Id Idss : instructorProjectTaskMap.get(tm.Intructor__c)){
                    system.debug('Idsss:::'+Idss);//
                    If ( !instructorIdProjectTaskIdSetMap.containskey( tm.Intructor__c )||(instructorIdProjectTaskIdSetMap.get ( tm.Intructor__c ) != NULL && 
                         !instructorIdProjectTaskIdSetMap.get ( tm.Intructor__c ).contains( Idss)) ) {
                        AcctSeed__Time_Card_Line__c TimeCardLine = new AcctSeed__Time_Card_Line__c(AcctSeed__Time_Card__c =tm.Id,AcctSeed__Project_Task__c = idss,AcctSeed__Project__c = projectTaskIdProjectIdMap.containsKey(idss)?projectTaskIdProjectIdMap.get(idss):null);
                        system.debug(':::TimeCardLine  :::'+TimeCardLine );
                        TimeCardLineList.add(TimeCardLine);
                    }
                }
            }
            System.debug('TimeCardLineList:::::'+TimeCardLineList);
            if ( TimeCardLineList.size() > 0) {
                Insert TimeCardLineList;
            }
            
        } catch(DmlException e) {
        
            sendEmailWhenErrorOccurs(e.getMessage());    
        } catch(SObjectException e) {
            
            sendEmailWhenErrorOccurs(e.getMessage());
        } catch(Exception ex) {
        
            sendEmailWhenErrorOccurs(ex.getMessage());
        } 
    
    }
        
    public void sendEmailWhenErrorOccurs(String mailContent) {
        
        List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(new String[] {system.Label.TimeCardDayEmail});
        mail.setSubject('Error on creating Time Card'); 
        mail.setPlainTextBody(mailContent);
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