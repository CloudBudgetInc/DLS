global class Project_TimeCard_Ctrl {
    
    public Class HoursCalculation {
        public Decimal pendingHours;
        public Decimal ApprovedHours;
    }
    
    global class proIdNameHrsCalc{
        public Id proId;
        public String proName;
        public Decimal proAppHrs;
        public Decimal proPenHrs;
    } 
    global class InitialParameters {
        public List<AcctSeed__Time_Card_Period__c> timeCardPeriod;
        public List<AcctSeed__Time_Card_Line__c> timeCardLineList;
        public List<AcctSeed__Time_Card__c> timeCardList;
        public Map<Id,HoursCalculation> periodMap;
        public Map<Id,HoursCalculation> cardMap;
        public Map<String,List<proIdNameHrsCalc>> timePerRanProMap;
        Integer totBeforeAppHrs;
        Integer totAppHrs;     
    }

    @RemoteAction
    global static InitialParameters getInitialValues(Id urlId, String type){  
        // Qry time card line with time card day values

        String condition;
        if(type == 'Contact') {
            condition = ' WHERE AcctSeed__Time_Card__r.Intructor__c =  \''+urlId+'\' ORDER BY CreatedDate DESC LIMIT 500';
        } else {
            condition = ' WHERE AcctSeed__Project_Task__r.AcctSeed__Project__c =  \''+urlId+'\' ORDER BY CreatedDate DESC LIMIT 500';       
        }
        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = TimeCardLineService.getLineWithDayRecords(condition);
        system.debug(':::::::::timeCardLine:::::'+timeCardLine);
        
        Set<Id> timeCardperiodIds = new Set<Id>();
        Set<Id> timeCardIds = new Set<Id>();
        
        for(AcctSeed__Time_Card_Line__c lineRec : timeCardLine) {
            timeCardperiodIds.add(lineRec.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c);
            timeCardIds.add(lineRec.AcctSeed__Time_Card__c);
        }
        
        system.debug(':::::timeCardperiodIds:::::::'+timeCardperiodIds);
        system.debug('::::::::timeCardIds::::::::::'+timeCardIds);
       
        // Qry time card periods
        List<AcctSeed__Time_Card_Period__c> timeCardPeriodRecords = new List<AcctSeed__Time_Card_Period__c>();
        if(timeCardperiodIds.size() > 0)
            timeCardPeriodRecords = [SELECT Id,Name,AcctSeed__Start_Date__c,AcctSeed__End_Date__c,
                                        (SELECT Id,Name,of_Pending_Time_Logs__c,of_Approved_Hours__c,of_Rejected_Hours__c,of_Submitted_Hours__c,AcctSeed__Time_Card_Period__c 
                                            FROM AcctSeed__Time_Cards__r 
                                            WHERE Id IN :timeCardIds) 
                                    FROM AcctSeed__Time_Card_Period__c 
                                    WHERE Id IN :timeCardperiodIds];
        
        system.debug('::::::::timeCardPeriodRecords:::::::'+timeCardPeriodRecords);
        
        // Qry time card records
        Set<Id> insIdSet;
        if(type == 'Contact') {            
            insIdSet = new Set<Id>{urlId};
        } else {
            insIdSet = new Set<Id>();       
        } 
        
        List<AcctSeed__Time_Card__c> timCardRecords = new List<AcctSeed__Time_Card__c>();
        if(timeCardIds.size() > 0)
            timCardRecords = TimecardService.getTimeCardByDate(' WHERE Id ',insIdSet,timeCardIds,',Intructor__r.Name');
            
        system.debug('::::::::timCardRecords:::::::'+timCardRecords);
        
        
        //Pending hours & Approved hours map formation for Period & Card records
        
        // TimeCard map formation
        
        Map<Id,HoursCalculation> cardIdHrsMap = new Map<Id,HoursCalculation>();
        Map<String,List<proIdNameHrsCalc>> perRanProMap = new Map<String,List<proIdNameHrsCalc>>(); 
       
        /*for(AcctSeed__Time_Card__c card : [SELECT Id,Name,
                                                (SELECT Id,Name,of_Approved_Hours__c,of_Pending_Time_Logs__c,of_Submitted_Hours__c,
                                                    of_Rejected_Hours__c, AcctSeed__Time_Card__c, AcctSeed__Project_Task__r.AcctSeed__Project__c,
                                                    AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c, 
                                                    AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c,
                                                    AcctSeed__Project_Task__r.AcctSeed__Project__r.Name
                                                    FROM AcctSeed__Time_Card_Line_Details__r 
                                                    WHERE AcctSeed__Time_Card__r.Intructor__c = :urlId OR
                                                    AcctSeed__Project_Task__r.AcctSeed__Project__c = :urlId) 
                                            FROM AcctSeed__Time_Card__c WHERE Id IN :timeCardIds]) { 
                                                    
            if(card.AcctSeed__Time_Card_Line_Details__r != null && card.AcctSeed__Time_Card_Line_Details__r.size() > 0) {*/
                
        for(AcctSeed__Time_Card_Line__c line : [SELECT Id,Name,of_Approved_Hours__c,of_Pending_Time_Logs__c,of_Submitted_Hours__c,
                                            of_Rejected_Hours__c, AcctSeed__Time_Card__c, AcctSeed__Project_Task__r.AcctSeed__Project__c,
                                            AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c, 
                                            AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c,
                                            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,
                                            AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c
                                            FROM AcctSeed__Time_Card_Line__c WHERE (AcctSeed__Time_Card__r.Intructor__c = :urlId OR
                                            AcctSeed__Project_Task__r.AcctSeed__Project__c = :urlId) AND AcctSeed__Time_Card__c IN :timeCardIds ORDER BY CreatedDate DESC LIMIT 500]) {
            
            if(type == 'Contact') {
  
                Date stDt = line.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c;                                               
                Date enDt = line.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c;
                                                           
                String stDate = addZero(stDt.Month())+'/'+addZero(stDt.Day())+'/'+string.valueOf(stDt.Year());
                String enDate = addZero(enDt.Month())+'/'+addZero(enDt.Day())+'/'+string.valueOf(enDt.Year());
                                        
                String periodStEnDate = stDate+' - '+enDate;
                if(!perRanProMap.containsKey(periodStEnDate)) {
                    proIdNameHrsCalc proHr = new proIdNameHrsCalc();    

                    proHr.proId = line.AcctSeed__Project_Task__r.AcctSeed__Project__c;  
                    proHr.proName = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                    proHr.proAppHrs = line.of_Approved_Hours__c;
                    proHr.proPenHrs = line.of_Submitted_Hours__c;
                    
                    perRanProMap.put(periodStEnDate,new List<proIdNameHrsCalc>{proHr});
                    
                } else {
                    Boolean oldProj = false;
                    for(proIdNameHrsCalc pn : perRanProMap.get(periodStEnDate)) {
                        if(pn.proId == line.AcctSeed__Project_Task__r.AcctSeed__Project__c) {
                            oldProj = true;
                            pn.proAppHrs += line.of_Approved_Hours__c;
                            pn.proPenHrs += line.of_Submitted_Hours__c;
                        } 
                    }
                    if(!oldProj) {
                        proIdNameHrsCalc proHr = new proIdNameHrsCalc();    

                        proHr.proId = line.AcctSeed__Project_Task__r.AcctSeed__Project__c;  
                        proHr.proName = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                        proHr.proAppHrs = line.of_Approved_Hours__c;
                        proHr.proPenHrs = line.of_Submitted_Hours__c;
                        perRanProMap.get(periodStEnDate).add(proHr);
                    }
                    
                }                     

            } else {
                if(!cardIdHrsMap.containsKey(line.AcctSeed__Time_Card__c)) {
                    
                    HoursCalculation hrsCalc = new HoursCalculation();
                    hrsCalc.pendingHours = line.of_Pending_Time_Logs__c + line.of_Submitted_Hours__c;
                    hrsCalc.ApprovedHours = line.of_Approved_Hours__c;
                    
                    cardIdHrsMap.put(line.AcctSeed__Time_Card__c,hrsCalc);
                } else {
                    HoursCalculation hrsCalc = cardIdHrsMap.get(line.AcctSeed__Time_Card__c);
                    hrsCalc.pendingHours += line.of_Pending_Time_Logs__c + line.of_Submitted_Hours__c;
                    hrsCalc.ApprovedHours += line.of_Approved_Hours__c;    
                    cardIdHrsMap.put(line.AcctSeed__Time_Card__c,hrsCalc);
                }      
            }
            
        }
            /*}
            
        }*/
        
        system.debug(':::::::::cardIdHrsMap:::::::::::'+cardIdHrsMap);
        
        // Timecardperiod map formation
        
        Map<Id,HoursCalculation> periodIdHrsMap = new Map<Id,HoursCalculation>();
        
        if(type == 'Contact') {
            for(AcctSeed__Time_Card_Line__c LineRec : timeCardLine) {
              
                if(!periodIdHrsMap.containsKey(LineRec.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c)) {
                    HoursCalculation hrsCalc = new HoursCalculation();
                    hrsCalc.pendingHours = LineRec.of_Submitted_Hours__c;
                    hrsCalc.ApprovedHours = LineRec.of_Approved_Hours__c;
                    periodIdHrsMap.put(LineRec.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c,hrsCalc);
                
                } else {
                    HoursCalculation hrsCalc = periodIdHrsMap.get(LineRec.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c);
                    hrsCalc.pendingHours += LineRec.of_Submitted_Hours__c;
                    hrsCalc.ApprovedHours += LineRec.of_Approved_Hours__c;
                    periodIdHrsMap.put(LineRec.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c,hrsCalc);
                }
                   
            }
            
        } else {
            for(AcctSeed__Time_Card_Period__c period : timeCardPeriodRecords) {
                
                if(period.AcctSeed__Time_Cards__r != null && period.AcctSeed__Time_Cards__r.size() > 0) {
                    for(AcctSeed__Time_Card__c cardRec : period.AcctSeed__Time_Cards__r) {
                        
                        if(cardIdHrsMap.containsKey(cardRec.Id)) {
                            
                            if(!periodIdHrsMap.containsKey(cardRec.AcctSeed__Time_Card_Period__c)){
                                HoursCalculation hrsCalc = new HoursCalculation();
                                hrsCalc.pendingHours = cardIdHrsMap.get(cardRec.Id).pendingHours;
                                hrsCalc.ApprovedHours = cardIdHrsMap.get(cardRec.Id).ApprovedHours;
                                
                                periodIdHrsMap.put(cardRec.AcctSeed__Time_Card_Period__c,hrsCalc);
                                
                            }else {
                                HoursCalculation hrsCalc = periodIdHrsMap.get(cardRec.AcctSeed__Time_Card_Period__c);
                                hrsCalc.pendingHours += cardIdHrsMap.get(cardRec.Id).pendingHours;
                                hrsCalc.ApprovedHours += cardIdHrsMap.get(cardRec.Id).ApprovedHours;
                                
                                periodIdHrsMap.put(cardRec.AcctSeed__Time_Card_Period__c,hrsCalc);
                            }
                        }
                    }
                }     
            }
        }
            
        system.debug(':::::::::::::::periodIdHrsMap:::::::::::::'+periodIdHrsMap);
        
        InitialParameters init = new InitialParameters();
        
        init.timeCardLineList = timeCardLine;
        init.timeCardPeriod = timeCardPeriodRecords;
        init.timeCardList = timCardRecords;
        init.periodMap = periodIdHrsMap;
        init.cardMap = cardIdHrsMap; 
        init.timePerRanProMap = perRanProMap;
       
        system.debug('::init::'+init); 
        
        return init;     
    }
    
    public static String addZero(Integer dtMoVal) {
        String dtMo;
        if(dtMoVal < 10) {
            dtMo = String.valueOf(0)+String.valueOf(dtMoVal);
        } else {
            dtMo = String.valueOf(dtMoVal);
        }    
        return dtMo;
    }
    
    @RemoteAction
    global static Map<String,String> getInstructorFilterValues(Id pId, String type){

        Map<String,String> insIdMap = new Map<String,String>();
        insIdMap.put('All','All');
        
        String qry = 'SELECT Id,Name,AcctSeed__Project_Task__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Name FROM AcctSeed__Time_Card_Line__c WHERE AcctSeed__Time_Card__r.Intructor__c = : pId OR AcctSeed__Project_Task__r.AcctSeed__Project__c = :pId';
        
        for(AcctSeed__Time_Card_Line__c line : Database.query(qry)) {
        
            if(type != 'Contact') {
                if(!insIdMap.containskey(line.AcctSeed__Time_Card__r.Intructor__c)){
                     insIdMap.put(line.AcctSeed__Time_Card__r.Intructor__c,line.AcctSeed__Time_Card__r.Intructor__r.Name);     
                 }
            }else if(!insIdMap.containskey(line.AcctSeed__Project_Task__r.AcctSeed__Project__c)){
                 insIdMap.put(line.AcctSeed__Project_Task__r.AcctSeed__Project__c,line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name);     
            }
        }
        system.debug(':insIdMap:---:'+insIdMap);
        return insIdMap;
    }
    
    //Added by Dhinesh - 19/09/2022 - W-007567
    @RemoteAction
    global static Map<String,String> getProjectTaskFilterValues(Id pId){
         Map<String,String> projTaskIdMap = new Map<String,String>();
        projTaskIdMap.put('All','All');
        
        String qry = 'SELECT Id,Name,AcctSeed__Project_Task__c,AcctSeed__Project_Task__r.Name FROM AcctSeed__Time_Card_Line__c WHERE AcctSeed__Time_Card__r.Intructor__c = : pId OR AcctSeed__Project_Task__r.AcctSeed__Project__c = :pId';
        
        for(AcctSeed__Time_Card_Line__c line : Database.query(qry)) {
        
           if(!projTaskIdMap.containskey(line.AcctSeed__Project_Task__c)){
                 projTaskIdMap.put(line.AcctSeed__Project_Task__c,line.AcctSeed__Project_Task__r.Name);     
            }
        }
        
        return projTaskIdMap;
    }
    
    @RemoteAction
    global static List<AcctSeed__Time_Card_Day__c> getDaysByInstructor(String insId, Id pId, String sDate, String eDate, String projTaskId){ // string type  
        List<AcctSeed__Time_Card_Day__c> timeCardDaysList = new List<AcctSeed__Time_Card_Day__c>();
        String timeCardDayFields = 'SELECT Id,Name,Week_Day__c,AcctSeed__Date__c,AcctSeed__Hours__c,AcctSeed__Internal_Comment__c,Status__c,AcctSeed__Time_Card_Line__c,'
                                  +'Total_Hours_Before_Approved__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c,'
                                  +'AcctSeed__Time_Card_Line__r.Payroll_Item__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.QB_Classification__c,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,QB_Classification__c,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Home_Dept__c '
                                  +'FROM AcctSeed__Time_Card_Day__c WHERE (AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c = :pId '
                                  +'OR AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :pId)';
        if(String.isNotBlank(sDate) && String.isNotBlank(eDate)) {
            List<String> sDts = sDate.split('-');
            List<String> eDts = eDate.split('-');
            if(eDts != null && eDts.size() > 0 && sDts != null && sDts.size() > 0){
                Date sDt = Date.newinstance(Integer.ValueOf(sDts[2]), Integer.ValueOf(sDts[0]), Integer.ValueOf(sDts[1]));
                Date eDt = Date.newinstance(Integer.ValueOf(eDts[2]), Integer.ValueOf(eDts[0]), Integer.ValueOf(eDts[1]));
                System.debug('sDt'+sDt+'::eDt::'+eDt);
                if(sDt != null && eDt != null) {
                    timeCardDayFields = timeCardDayFields +' AND AcctSeed__Date__c >= :sDt AND AcctSeed__Date__c <= :eDt';
                }
            }
        }
        System.debug('timeCardDayFields::::'+timeCardDayFields);
        String allDaysQuery = timeCardDayFields;
        if(insId != 'All') {
            allDaysQuery += ' AND (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :insId OR AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c = :insId) ';           
        } 
        if(projTaskId != 'All'){
            allDaysQuery += ' AND  AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c = :projTaskId '; 
        }
        
        allDaysQuery += ' ORDER BY AcctSeed__Date__c DESC LIMIT 200';
           
        timeCardDaysList =  Database.query(allDaysQuery);
        system.debug(':::::timeCardDaysList:::'+timeCardDaysList);
        return timeCardDaysList;
    }

    @RemoteAction
    global static Integer getTCDCount(String insId, Id pId, String sDt, String eDt, String projTaskId) { // String type
        Integer count = 0;
        
        String timeCardDayFields = 'SELECT count()'                                  
                                  +'FROM AcctSeed__Time_Card_Day__c WHERE (AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c = :pId '
                                  +'OR AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :pId)';
        if(String.isNotBlank(sDt) && String.isNotBlank(eDt)) {
            List<String> sDts = sDt.split('-');
            List<String> eDts = eDt.split('-');
            if(eDts != null && eDts.size() > 0 && sDts != null && sDts.size() > 0){
                Date sDte = Date.newinstance(Integer.ValueOf(sDts[2]), Integer.ValueOf(sDts[0]), Integer.ValueOf(sDts[1]));
                Date eDte = Date.newinstance(Integer.ValueOf(eDts[2]), Integer.ValueOf(eDts[0]), Integer.ValueOf(eDts[1]));
                System.debug('sDt'+sDte+'::eDt::'+eDte);
                if(sDt != null && eDt != null) {
                    timeCardDayFields = timeCardDayFields +' AND AcctSeed__Date__c >= :sDte AND AcctSeed__Date__c <= :eDte';
                }
            }
        }
        if(projTaskId != 'All' && String.isNotBlank(projTaskId)){
            timeCardDayFields +=  ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c = :projTaskId';
        }
        
        
        if(insId != 'All') {
            String allDaysQuery = timeCardDayFields+' AND (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :insId OR AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c = :insId)';
            count =  Database.countQuery(allDaysQuery);
        } else {
            String allDaysQuery = timeCardDayFields;
            count =  Database.countQuery(allDaysQuery);
        }
        return count; 
    }

    @RemoteAction
    global static List<AcctSeed__Time_Card_Day__c> getTCDForDownload(String insId, Id pId, Integer offSetCount, String sDt, String eDt, String projTaskId){  // String type
        List<AcctSeed__Time_Card_Day__c> timeCardDaysList = new List<AcctSeed__Time_Card_Day__c>();
        String timeCardDayFields = 'SELECT Id,Name,Week_Day__c,AcctSeed__Date__c,AcctSeed__Hours__c,AcctSeed__Internal_Comment__c,Status__c,AcctSeed__Time_Card_Line__c,'
                                  +'Total_Hours_Before_Approved__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c,'
                                  +'AcctSeed__Time_Card_Line__r.Payroll_Item__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.QB_Classification__c,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,QB_Classification__c,'
                                  +'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Home_Dept__c '
                                  +'FROM AcctSeed__Time_Card_Day__c WHERE (AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c = :pId '
                                  +'OR AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :pId)';
        
        if(String.isNotBlank(sDt) && String.isNotBlank(eDt)) {
            List<String> sDts = sDt.split('-');
            List<String> eDts = eDt.split('-');
            if(eDts != null && eDts.size() > 0 && sDts != null && sDts.size() > 0){
                Date sDte = Date.newinstance(Integer.ValueOf(sDts[2]), Integer.ValueOf(sDts[0]), Integer.ValueOf(sDts[1]));
                Date eDte = Date.newinstance(Integer.ValueOf(eDts[2]), Integer.ValueOf(eDts[0]), Integer.ValueOf(eDts[1]));
                System.debug('sDt'+sDte+'::eDt::'+eDte);
                if(sDt != null && eDt != null) {
                    timeCardDayFields = timeCardDayFields +' AND AcctSeed__Date__c >= :sDte AND AcctSeed__Date__c <= :eDte';
                }
            }
        }
        
        if(projTaskId != 'All' && String.isNotBlank(projTaskId)){
            timeCardDayFields +=  ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c = :projTaskId';
        }
        
        if(insId != 'All') {
            String allDaysQuery = timeCardDayFields+' AND (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :insId OR AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c = :insId) ORDER BY AcctSeed__Date__c DESC LIMIT 200 OFFSET '+ offSetCount;
            timeCardDaysList =  Database.query(allDaysQuery);
        } else {
            String allDaysQuery = timeCardDayFields+' ORDER BY AcctSeed__Date__c DESC LIMIT 200 OFFSET '+ offSetCount;
            timeCardDaysList =  Database.query(allDaysQuery);
        }
        system.debug(':::::timeCardDaysList:::'+timeCardDaysList);
        return timeCardDaysList;
    }

    @RemoteAction
    global static List<AggregateResult> getTCDTotalHours(String insId, Id pId, String type, String projTaskId) {   
        List<AggregateResult> groupedResults = new List<AggregateResult>();
        String timeCardDayFields = 'SELECT SUM(Total_Hours_Before_Approved__c), SUM(AcctSeed__Hours__c)'
                                  +'FROM AcctSeed__Time_Card_Day__c WHERE (AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c = :pId '
                                  +'OR AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :pId)';
        
        if(projTaskId != 'All'){
            timeCardDayFields +=  ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c = :projTaskId';
        }
        
        if(insId != 'All') {
            String allDaysQuery = timeCardDayFields+' AND (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :insId OR AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c = :insId)';
            groupedResults =  Database.query(allDaysQuery);
        } else {
            String allDaysQuery = timeCardDayFields;
            groupedResults =  Database.query(allDaysQuery);
        }
        system.debug(':::::groupedResults:::'+groupedResults);
        return groupedResults;//(Decimal) groupedResults[0].get('aver');
    }

}