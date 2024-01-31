// Created batch class by Sukanya on June 5 2017
// To create Accounting period, time card period, time card, time card line, time card day
global class TimeCard_Creation_FromCTP implements Database.batchable<sObject>,Database.Stateful { 

    global Id oppId;
    global Map<String,String> contServItemPtName = new Map<String,String>();
    global Map<String,Id> projectTaskNameWithProjectTaskId = new Map<String,Id>();
    
    global Set<Date> startdtSet = new Set<Date>();  // For Time Card Period Query Week Start Date Set
    global Set<Date> enddtSet = new Set<Date>();    // For Time Card Period Query Week End Date Set
    global Map<Date,Date> stdateandEnddtMap = new Map<Date,Date>();
    global List<Date> tlDateSet = new List<Date>();     // Time Log Dates     
    global Set<Date> monthStartdtSet = new Set<Date>(); // For Accounting Period 
    global Set<Date> monthEnddtSet = new Set<Date>();   // For Accounting Period
    global Map<Id,Map<Date,Date>> contIdWithStAndEndDateMap = new Map<Id,Map<Date,Date>>();
    global Set<Id> ContIds = new Set<Id>(); 
    global Map<String,String> PayRollValuesMap = new Map<String,String>();
    global Id newProjectId;
    global Map<Id,Id> contactIdUserIdMap = new Map<Id,Id>();
    
    //For User name & id formation 
    global Map<String,Id> usrNameidMap = new Map<String,Id>();
    global Set<String> projectTaskNameSet = new Set<String>();
    global Set<Id> TCLIds = new Set<Id>();
    
    // For Exception handling process
    global List<UtilDomain.ErrorWrapper> errorWrapperList = new List<UtilDomain.ErrorWrapper>();
    
    global String oppName = '';
    global Set<Id> conIdRemaining = new Set<Id>();
    global Set<Id> existingTLIds = new Set<Id>();
    
    global Map<Id,Contact_Assignments__c> conIdConAssignMap = new Map<Id,Contact_Assignments__c>();
    global List<Contact_Assignments__c> contactAssignList =  new List<Contact_Assignments__c>();
    global Map<Id,AcctSeed__Project_Task__c> taskIdTaskRecMap = new Map<Id,AcctSeed__Project_Task__c>();
    
    global  Map<String,String> productNameStaticMap = new Map<String,String>{'Language Training- Arabic' => 'Language Training- Arabic (MSA and all dialects)', 'Language Training- Vietnamese' => 'Language Training- Vietnamese (all dialects)', 'Language Training- Mandarin' => 'Language Training- Chinese (Mandarin)', 'Language Training- Portuguese' => 'Language Training- Portuguese (all dialects)'};
    
    global Set<Id> oppIds = new Set<Id>();
    global Set<Id> projectIds = new Set<Id>();
    global Map<Id,Id> oppIdProjectIdMap = new Map<Id,Id>();
    global Map<String,Id> proId_TaskName_TaskId = new Map<String,Id>();
    global Map<Id,String> proId_TaskName = new Map<Id,String>();
    global String MPOAccountId;
    
            
    public TimeCard_Creation_FromCTP(UtilDomain.batchParameters params) {
        system.debug(':::::::params:::::::::::'+params);
        oppId = params.oppId;
        contServItemPtName = params.contServItemPtName;
        projectTaskNameWithProjectTaskId = params.projectTaskNameWithProjectTaskId;
        startdtSet = params.startdtSet;
        enddtSet = params.enddtSet;
        stdateandEnddtMap = params.stdateandEnddtMap;
        tlDateSet = params.tlDateSet;
        monthStartdtSet = params.monthStartdtSet;
        monthEnddtSet = params.monthEnddtSet;
        contIdWithStAndEndDateMap = params.contIdWithStAndEndDateMap;
        ContIds = params.ContIds;
        PayRollValuesMap = params.PayRollValuesMap;
        newProjectId = params.newProjectId;
        existingTLIds = params.existingTLIds;
        oppIds = params.oppIds;
        projectIds = params.projectIds;
        oppIdProjectIdMap = params.oppIdProjectIdMap;
        proId_TaskName_TaskId = params.proId_TaskName_TaskId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){  
        
        String timeLogQry = '';
        
        if(oppId != null) {
            timeLogQry = 'SELECT Contact__c,Contact__r.Name,Notes__c,Hours__c,Date__c,First_Name__c,Last_Name__c,'+
                                        'Name,Opportunity__c,Opportunity__r.Name,Opportunity__r.RecordType.DeveloperName,Service_Item__c,Billable_Work__c,Classification__c,Unposted__c,'+
                                        'Payroll_Item__c,Opportunity__r.AccountId,Opportunity__r.Project_Type__c,Opportunity__r.Location__c'+
                                        ' FROM Time_Log__c'+
                                        ' WHERE Opportunity__c = :oppId AND Unposted__c = False AND Id NOT IN : existingTLIds Order By Date__c Asc';
            
        }else if(oppIds != null && oppIds.size() > 0) {
            timeLogQry = 'SELECT Contact__c,Contact__r.Name,Notes__c,Hours__c,Date__c,First_Name__c,Last_Name__c,'+
                                        'Name,Opportunity__c,Opportunity__r.Name,Opportunity__r.RecordType.DeveloperName,Service_Item__c,Billable_Work__c,Classification__c,Unposted__c,'+
                                        'Payroll_Item__c,Opportunity__r.AccountId,Opportunity__r.Project_Type__c,Opportunity__r.Location__c'+
                                        ' FROM Time_Log__c'+
                                        ' WHERE Opportunity__c IN :oppIds AND Unposted__c = False AND Id NOT IN : existingTLIds Order By Date__c Asc';
             
        }
        system.debug('::::::::timeLogQry::::::::::'+timeLogQry);
        
        
        // UserId & Contact Id Map formation 
        // Queried here to avoid every time on batch execution
        for(User IdLoop : [SELECT contactId,Id,FirstName,MiddleName,LastName FROM User]){
                
            if(IdLoop.contactId != null && !contactIdUserIdMap.containsKey(IdLoop.contactId)) {
                contactIdUserIdMap.put(IdLoop.contactId,IdLoop.Id);
            }
             
            String nameStr = IdLoop.FirstName+'-'+IdLoop.MiddleName+'-'+IdLoop.LastName;
            nameStr = nameStr.toLowerCase();
            
            if(!usrNameidMap.containsKey(nameStr) && IdLoop.contactId == null)
                usrNameidMap.put(nameStr,IdLoop.Id);
        }
        
        system.debug(':::::::contactIdUserIdMap:::::::::'+contactIdUserIdMap);
        system.debug(':::::::contactIdUserIdMap:::::::::'+contactIdUserIdMap.size());
        system.debug('::::::::usrNameidMap:::::::::'+usrNameidMap);
        
        // Qry Contacts which have user with the same name & Staff record type
        
        Set<String> conRTvalues = new Set<String>{'DLS_Employee','Candidate','Partner','Student'};
        
        for(Contact con : [SELECT Id,Name,FirstName,MiddleName,LastName,RecordType.DeveloperName FROM Contact WHERE Id IN :ContIds]) {
            
            String conNamestr = con.FirstName+'-'+con.MiddleName+'-'+con.LastName;
            conNamestr = conNamestr.toLowerCase();
            
            if(usrNameidMap.containsKey(conNamestr) && conRTvalues.contains(con.RecordType.DeveloperName)) {
                if(!contactIdUserIdMap.containsKey(con.Id))
                    contactIdUserIdMap.put(con.Id,usrNameidMap.get(conNamestr));
            }
        }
        
        system.debug(':::::::contactIdUserIdMap:::::after::staff::'+contactIdUserIdMap.size());
        
        // For Contact Assingment Map & List Formation to populate value in time card line level
        
        // For single opp & project
        if(oppId != null && newProjectId != null) {
            for(Contact_Assignments__c conAssign : [SELECT Id,Name,Candidate_Name__c,Opportunity_Name__c,Project__c,Rate_Card_Rate__c,Payroll_Item__c,Project_Task__c 
                                                    FROM Contact_Assignments__c 
                                                    WHERE Candidate_Name__c IN : ContIds AND Opportunity_Name__c = :oppId AND Project__c = :newProjectId 
                                                    AND RecordType.DeveloperName IN ('Instructor','Staff')]) {
            
                contactAssignList.add(conAssign);
                if(!conIdConAssignMap.containsKey(conAssign.Candidate_Name__c)){
                    conIdConAssignMap.put(conAssign.Candidate_Name__c,conAssign);
                }
            }
            
            if(oppIdProjectIdMap == null)
                oppIdProjectIdMap = new Map<Id,Id>{oppId => newProjectId};
        }
        //For whole opp & project
        if(oppIds != null && oppIds.size() > 0 && projectIds != null && projectIds.size() > 0) {
            for(Contact_Assignments__c conAssign : [SELECT Id,Name,Candidate_Name__c,Opportunity_Name__c,Project__c,Rate_Card_Rate__c,Payroll_Item__c,Project_Task__c 
                                                    FROM Contact_Assignments__c 
                                                    WHERE Candidate_Name__c IN : ContIds AND Opportunity_Name__c IN :oppIds AND Project__c IN :projectIds 
                                                    AND RecordType.DeveloperName IN ('Instructor','Staff')]) {
            
                contactAssignList.add(conAssign);
                if(!conIdConAssignMap.containsKey(conAssign.Candidate_Name__c)){
                    conIdConAssignMap.put(conAssign.Candidate_Name__c,conAssign);
                }
            }
        }
        
        
        system.debug(':::::::contactAssignList:::::'+contactAssignList);
        system.debug(':::::::conIdConAssignMap:::::'+conIdConAssignMap);
        
        // Qry Project task Id related records for parent Project task related contact assignment
        
        Set<Id> projectTaskIds = new Set<Id>();
        
        System_Values__c acc = System_Values__c.getValues('ConvertToProject_MPOAccount');
        
        if(acc != null && acc.Value__c != null) {
            MPOAccountId = acc.Value__c;
        }
        
        if(projectTaskNameWithProjectTaskId != null) {
            projectTaskIds.addAll(projectTaskNameWithProjectTaskId.values());
        }else if(proId_TaskName_TaskId != null && proId_TaskName_TaskId.keySet().size() > 0) {
            projectTaskIds.addAll(proId_TaskName_TaskId.values());
        }
        
        if(projectTaskIds.size() > 0) {
            for(AcctSeed__Project_Task__c task : [SELECT Id,Name,Parent_Project_Task__c,AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c,RecordType.DeveloperName,
                                                        AcctSeed__Project__r.AcctSeed__Opportunity__r.AccountId,AcctSeed__Project__r.RecordType.DeveloperName 
                                                        FROM AcctSeed__Project_Task__c 
                                                        WHERE Id IN :projectTaskIds]){
                if(!taskIdTaskRecMap.containsKey(task.Id))
                    taskIdTaskRecMap.put(task.Id,task);
                
                if(!proId_TaskName.containsKey(task.AcctSeed__Project__c) && task.RecordType.DeveloperName == 'Language_Training' 
                    && ((String.isNotBlank(MPOAccountId) && task.AcctSeed__Project__r.AcctSeed__Opportunity__r.AccountId == MPOAccountId)
                    || (task.AcctSeed__Project__r.RecordType.DeveloperName == 'MTT_Projects' ))) {
                    
                    proId_TaskName.put(task.AcctSeed__Project__c,task.Name);
                }
            }
        }
            
        system.debug('::::::taskIdTaskRecMap::::::'+taskIdTaskRecMap);
        
        return Database.getQueryLocator(timeLogQry);
    }
    
    global void execute(Database.BatchableContext info, List<Time_Log__c> timeLoglist){
        
        system.debug(':::::timeLoglist::::::::'+timeLoglist);
        
        Set<Id> timePeriodIdSet = new Set<Id>();
        //Set<Date> startdtSet = new Set<Date>();      // For Time Card Period Query Week Start Date Set
        //Set<Date> enddtSet = new Set<Date>();        // For Time Card Period Query Week End Date Set
    
        Set<Date> timePrdStartdateSet = new Set<Date>();
        Set<Date> timePrdEnddateSet = new Set<Date>();
        Map<Id,Set<Id>> contIdTcIdMap = new Map<Id,Set<Id>>();
        //Map<Id,Map<Date,Date>> contIdWithStAndEndDateMap = new Map<Id,Map<Date,Date>>();
        Map<Date,AcctSeed__Accounting_Period__c> accPRdstDtandAccPrdIdMap = new Map<Date,AcctSeed__Accounting_Period__c>();
        
        
        List<AcctSeed__Accounting_Period__c> acctPrdList = new List<AcctSeed__Accounting_Period__c>();
        List<AcctSeed__Time_Card_Period__c> timeCardPerdList = new List<AcctSeed__Time_Card_Period__c>();
        
        Transient List<UtilDomain.tcdInnerCls> tcdL = new List<UtilDomain.tcdInnerCls>();
        Map<Id,AcctSeed__Time_Card_Period__c> acctTimePrdMap = new Map<Id,AcctSeed__Time_Card_Period__c>();
        
        Set<Id> timeCardIdSet = new Set<Id>(); 
        Set<Id> cardTimePeriodIdSet = new Set<Id>();
        
        List<AcctSeed__Time_Card__c> tcs = new List<AcctSeed__Time_Card__c>();
        List<AcctSeed__Time_Card__c> timeCardList = new List<AcctSeed__Time_Card__c >();
        
        List<AcctSeed__Time_Card_Line__c> tcls = new List<AcctSeed__Time_Card_Line__c>();
        
        Map<Date,Id> EvntDateIdMap = new Map<Date,Id>();
        
        List<AcctSeed__Time_Card_Day__c> tcdays = new List<AcctSeed__Time_Card_Day__c>();
        
        Date stDate;
        Date endDate;
        
        Id currentOppId;
        Set<Id> tlIdsForDuplicateCheck = new Set<Id>();
        Boolean allowForCreation = false;
        
        //Savepoint sp = Database.setSavepoint(); 
        
        try {
            
            system.debug(':::::::contactAssignList:::::'+contactAssignList);
            system.debug(':::::::conIdConAssignMap:::::'+conIdConAssignMap);
            system.debug('::::::taskIdTaskRecMap::::::'+taskIdTaskRecMap);
            system.debug('::::::proId_TaskName_TaskId::::::'+proId_TaskName_TaskId);
            system.debug('::::::proId_TaskName::::::'+proId_TaskName);
        
            for(Time_Log__c tl : timeLoglist) {
                String Proj_Task_Name = 'Language Training- ';
                if( tl.Service_Item__c != null && tl.Service_Item__c.contains('SVC:Language Training:')) {
                    List<String> serStrList = tl.Service_Item__c.split('SVC:Language Training:');
                    if(serStrList != null && serStrList.size() > 1) {
                        Proj_Task_Name += serStrList[1];
                        
                        if(productNameStaticMap.containsKey(Proj_Task_Name)){
                            Proj_Task_Name = productNameStaticMap.get(Proj_Task_Name);
                        }
                        
                        if(tl.Notes__c != null && tl.Notes__c.contains('Prep')) {
                           Proj_Task_Name = 'Language Training- Preparation';
                        }
                        
                        // MPO related Opps
                        if(String.isNotBlank(MPOAccountId) && tl.Opportunity__r.AccountId == MPOAccountId 
                            && oppIdProjectIdMap != null && oppIdProjectIdMap.containsKey(tl.Opportunity__c) && proId_TaskName.containsKey(oppIdProjectIdMap.get(tl.Opportunity__c))){
                            Proj_Task_Name = proId_TaskName.get(oppIdProjectIdMap.get(tl.Opportunity__c));
                        }
                        
                        // For MTT
                        if(((tl.Opportunity__r.RecordType.DeveloperName == 'DLI_W_TO_Opportunities' && 
                                ( tl.Opportunity__r.Project_Type__c == 'HUB' || tl.Opportunity__r.Project_Type__c == 'MTT' || tl.Opportunity__r.Project_Type__c == 'Overseas MTT')) 
                            || (tl.Opportunity__r.RecordType.DeveloperName == 'MTT_Opportunities')) 
                            &&  oppIdProjectIdMap != null && oppIdProjectIdMap.containsKey(tl.Opportunity__c) && proId_TaskName.containsKey(oppIdProjectIdMap.get(tl.Opportunity__c))) {
                            
                            Proj_Task_Name = proId_TaskName.get(oppIdProjectIdMap.get(tl.Opportunity__c));
                        }
                        
                    } 
                } else if ( tl.Service_Item__c != null && tl.Service_Item__c.contains('SVC:')) {
                    List<String> siStrList = tl.Service_Item__c.split('SVC:');
                    if(siStrList != null && siStrList.size() > 1) {
                        if(!tl.Service_Item__c.contains('SVC:Preparation time')) {
                            Proj_Task_Name = siStrList[1];
                        }else if(tl.Service_Item__c.contains('SVC:Preparation time')){
                            Proj_Task_Name = 'Language Training- Preparation';
                        }
                    } else {
                        Proj_Task_Name = tl.Service_Item__c;  
                    }
                    
                } else if ( tl.Service_Item__c != null) {
                    
                    if(tl.Service_Item__c != 'Fringe' || (tl.Service_Item__c == 'Fringe' && tl.Payroll_Item__c != null && !PayRollValuesMap.Containskey(tl.Payroll_Item__c))) {
                        Proj_Task_Name = tl.Service_Item__c;                            
                    } else if(tl.Service_Item__c == 'Fringe' && tl.Payroll_Item__c != null && PayRollValuesMap.Containskey(tl.Payroll_Item__c)) {
                        Proj_Task_Name = tl.Service_Item__c+'-'+PayRollValuesMap.get(tl.Payroll_Item__c);                                
                    } 
                }
                System.debug('Proj_Task_Name:::'+Proj_Task_Name);
                if(tl.Service_Item__c != null) {
                    
                    // Added time log id field in time card day object to track the number of records conversion
                    // Added by Sukanya on June 8 2017
                    
                    // For AFPAK_Classess Opp - to split 8.00 hrs to 6 hrs - for Language Training, 2 hrs for Prepartion
                    
                    if(tl.Opportunity__r.RecordType.DeveloperName != 'DLI_W_TO_Opportunities' 
                        || (tl.Opportunity__r.RecordType.DeveloperName == 'DLI_W_TO_Opportunities' && 
                            (tl.Hours__c != 8.00 || tl.Opportunity__r.Project_Type__c != 'AFPAK')
                        )) {
                        tcdL.add(new UtilDomain.tcdInnerCls(new AcctSeed__Time_Card_Day__c(AcctSeed__Date__c = tl.Date__c,Status__c = 'Approved',Total_Hours_Before_Approved__c = tl.Hours__c,AcctSeed__Hours__c = tl.Hours__c,Approved_Date__c = System.Today(),Approved_by__c = userInfo.getUserId(),Time_Log_Id__c = tl.Id,AcctSeed__Internal_Comment__c = tl.Notes__c),tl.Contact__c,tl.Contact__r.Name,tl.Billable_Work__c,Proj_Task_Name,tl));
                       
                    }else if(tl.Opportunity__r.RecordType.DeveloperName == 'DLI_W_TO_Opportunities' && tl.Hours__c == 8.00 
                            && tl.Opportunity__r.Project_Type__c == 'AFPAK'){
                        tcdL.add(new UtilDomain.tcdInnerCls(new AcctSeed__Time_Card_Day__c(AcctSeed__Date__c = tl.Date__c,Status__c = 'Approved',Total_Hours_Before_Approved__c = 6.00,AcctSeed__Hours__c = 6.00,Approved_Date__c = System.Today(),Approved_by__c = userInfo.getUserId(),Time_Log_Id__c = tl.Id,AcctSeed__Internal_Comment__c = tl.Notes__c),tl.Contact__c,tl.Contact__r.Name,tl.Billable_Work__c,Proj_Task_Name,tl));
                        tcdL.add(new UtilDomain.tcdInnerCls(new AcctSeed__Time_Card_Day__c(AcctSeed__Date__c = tl.Date__c,Status__c = 'Approved',Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2.00,Approved_Date__c = System.Today(),Approved_by__c = userInfo.getUserId(),Time_Log_Id__c = tl.Id,AcctSeed__Internal_Comment__c = tl.Notes__c),tl.Contact__c,tl.Contact__r.Name,tl.Billable_Work__c,'Language Training- Preparation',tl));
                    }
                }
                System.debug('PayRollValuesMap:::'+PayRollValuesMap);
                
                oppName = tl.Opportunity__r.Name;
                
                currentOppId = tl.Opportunity__c;
                
                tlIdsForDuplicateCheck.add(tl.Id);
            }
            System.debug('Size of Tcdl'+tcdL.size());
            
            Set<Id> dayTLIds = new Set<Id>();
            
            for(AcctSeed__Time_Card_Day__c day : [SELECT Id,Name,Time_Log_Id__c,AcctSeed__Internal_Comment__c 
                                                    FROM AcctSeed__Time_Card_Day__c 
                                                    WHERE Time_Log_Id__c IN :tlIdsForDuplicateCheck AND Time_Log_Id__c != null]) {
                dayTLIds.add(day.Time_Log_Id__c);
                if(day.AcctSeed__Internal_Comment__c != null && day.AcctSeed__Internal_Comment__c.contains('Merged - ') && day.AcctSeed__Internal_Comment__c.split('-').size() > 1) {
                    dayTLIds.add(day.AcctSeed__Internal_Comment__c.split('- ')[1]);
                }
            }
            
            for(Id ids : tlIdsForDuplicateCheck) {
                if(!dayTLIds.contains(ids)) {
                    allowForCreation = true;
                }
            }
            
            if(allowForCreation) {
            
            
                // Qry already existing Accouting period records
                for(AcctSeed__Accounting_Period__c aP: [SELECT AcctSeed__Start_Date__c,AcctSeed__End_Date__c,Name FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c IN: monthStartdtSet AND AcctSeed__End_Date__c IN: monthEnddtSet]){
                    if(!accPRdstDtandAccPrdIdMap.containsKey(aP.AcctSeed__Start_Date__c)){
                        accPRdstDtandAccPrdIdMap.put(aP.AcctSeed__Start_Date__c,aP);
                    } 
                }
                
                // Temp Variables
                Integer Mnth = 0;
                String month;
                
                // New Accounting period formation
                
                for(Date dt: monthStartdtSet) {
                    if(dt.Month() != Mnth){
                        
                        if(dt.Month() < 10) {
                            month = '0'+dt.Month();
                        } else {
                            month = String.ValueOf(dt.Month());
                        }
                    }
                    if(accPRdstDtandAccPrdIdMap != null && !accPRdstDtandAccPrdIdMap.containsKey(dt)) {
                        AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c();
                        accPeriod.name = dt.year()+'-'+month;
                        accPeriod.AcctSeed__End_Date__c = dt.addMonths(1).toStartofMonth().addDays(-1);
                        accPeriod.AcctSeed__Start_Date__c = dt.toStartofMonth();
                        acctPrdList.add(accPeriod);
                    }
                    Mnth = dt.Month();
                }
                
                system.debug(':::::::acctPrdList::::::::'+acctPrdList);
                
                // Qry existing time card period records
                for(AcctSeed__Time_Card_Period__c timePeriod: [SELECT Id,AcctSeed__End_Date__c,AcctSeed__Start_Date__c,Name FROM AcctSeed__Time_Card_Period__c WHERE AcctSeed__Start_Date__c IN: startdtSet AND AcctSeed__End_Date__c IN: enddtSet]){
                    timePrdStartdateSet.add(timePeriod.AcctSeed__Start_Date__c);
                    timePrdEnddateSet.add(timePeriod.AcctSeed__End_Date__c);
                    timePeriodIdSet.add(timePeriod.Id);                  
                }
                
                // New time card period creation
                for(Date dt: startdtSet) {
                    
                    if(!timePrdStartdateSet.contains(dt) && !timePrdEnddateSet.contains(stdateandEnddtMap.get(dt))) {                                         
                    
                        AcctSeed__Time_Card_Period__c tmPeriod = new AcctSeed__Time_Card_Period__c();
                        tmPeriod.name = dt.year()+'-'+ dt.Month();
                        tmPeriod.AcctSeed__End_Date__c = stdateandEnddtMap.get(dt);
                        tmPeriod.AcctSeed__Start_Date__c = dt;
                
                        timeCardPerdList.add(tmPeriod);
                    }
                }
                System.debug(':::::::::::timeCardPerdList:::'+timeCardPerdList);
                
                
                system.debug(':::::::contactIdUserIdMap::::execute:::::'+contactIdUserIdMap);
                system.debug(':::::::contactIdUserIdMap::::execute:::::'+contactIdUserIdMap.size());
                
                // accounting period insertion
                if( acctPrdList != null && acctPrdList.size() > 0 ) {
                    //Insert acctPrdList;
                    
                    Database.SaveResult[] srList = Database.insert(acctPrdList, false);
                    
                    for (Database.SaveResult sr : srList) {
                       system.debug(':::::::sr::::::'+sr);
                       String errMsg = '';
                        if (!sr.isSuccess()) {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('::::::::::::::: ' + err.getMessage());
                                errMsg += err.getMessage();
                            }
                            UtilDomain.ErrorWrapper errWrapper = new UtilDomain.ErrorWrapper(timeLoglist[0],errMsg,'Accounting Period');
                            errorWrapperList.add(errWrapper);
                        }
                    }
                }
                
                // time card period insertion
                if( timeCardPerdList != null && timeCardPerdList.size() > 0 ) {
                    //Insert timeCardPerdList;
                    
                    Database.SaveResult[] srList = Database.insert(timeCardPerdList, false);
                    
                    for (Database.SaveResult sr : srList) {
                       system.debug(':::::::sr::::::'+sr);
                       String errMsg = '';
                        if (!sr.isSuccess()) {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('::::::::::::::: ' + err.getMessage());
                                errMsg += err.getMessage();
                            }
                            UtilDomain.ErrorWrapper errWrapper = new UtilDomain.ErrorWrapper(timeLoglist[0],errMsg,'Time Card Period');
                            errorWrapperList.add(errWrapper);
                        }
                    }
                }
                // End of time card period creation 
                
                // Qry inserted time card period records
                for(AcctSeed__Time_Card_Period__c timePeriod: [SELECT Id,AcctSeed__End_Date__c,AcctSeed__Start_Date__c,Name FROM AcctSeed__Time_Card_Period__c WHERE AcctSeed__Start_Date__c IN: startdtSet AND AcctSeed__End_Date__c IN: enddtSet]){
                    timePeriodIdSet.add(timePeriod.Id); 
                    acctTimePrdMap.put(timePeriod.Id,timePeriod);                 
                }
                
                // Time card creation logic
                if( ContIds != null && ContIds.size() > 0 ) {
                    
                    for(AcctSeed__Time_Card__c crd : [SELECT AcctSeed__Employee__c,Id,Intructor__c,AcctSeed__Time_Card_Period__c,AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c,AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c FROM AcctSeed__Time_Card__c WHERE Intructor__c != null AND Intructor__c IN :ContIds AND AcctSeed__Time_Card_Period__c IN :timePeriodIdSet]){
                        if(!contIdTcIdMap.Containskey(crd.Intructor__c)) {
                            contIdTcIdMap.put(crd.Intructor__c,new Set<Id>());
                        }
                        contIdTcIdMap.get(crd.Intructor__c).add(crd.AcctSeed__Time_Card_Period__c);
                        cardTimePeriodIdSet.add(crd.AcctSeed__Time_Card_Period__c);
                        //timeCardList.add(crd);
                        timeCardIdSet.add(crd.Id);
                    }
                    
                    System.debug('%%%%%%%%%%%%%%%%%%%contIdTcIdMap::::'+contIdTcIdMap);
                    System.debug('contactIdUserIdMap::::'+contactIdUserIdMap);
                    
                    for(Id periodId: timePeriodIdSet) {
                        for(Id insId : ContIds) {
                            
                            if (contactIdUserIdMap.get(insId) != null && contIdTcIdMap != null && acctTimePrdMap.containskey(periodId) && contIdWithStAndEndDateMap.containskey(insId) && contIdWithStAndEndDateMap.get(insId).containskey(acctTimePrdMap.get(periodId).AcctSeed__Start_Date__c) && 
                               (!contIdTcIdMap.Containskey(insId) || (contIdTcIdMap.Containskey(insId) && !contIdTcIdMap.get(insId).contains(periodId)))) {
                               
                               AcctSeed__Time_Card__c TimeCardNew = new AcctSeed__Time_Card__c(Intructor__c = insId,AcctSeed__Employee__c = contactIdUserIdMap.get(insId),AcctSeed__Time_Card_Period__c = periodId);
                               tcs.add(TimeCardNew);       
                            }else {
                                if(!contactIdUserIdMap.containsKey(insId) && !conIdRemaining.contains(insId)) {
                                    UtilDomain.ErrorWrapper errWrapper = new UtilDomain.ErrorWrapper(timeLoglist[0],'Time card record not created because matching user not found for the contact','Time Card');
                                    errorWrapperList.add(errWrapper);
                                    
                                    conIdRemaining.add(insId);
                                }
                            }
                        }
                    }
                    system.debug('::::::::::tcs::::::'+tcs);
                }
                // Time Card record insertion
                if(tcs.size() > 0) {
                    //insert tcs;
                    
                    Database.SaveResult[] srList = Database.insert(tcs, false);
                    
                    for (Database.SaveResult sr : srList) {
                       system.debug(':::::::sr::::::'+sr);
                       String errMsg = '';
                        if(sr.isSuccess()) {
                            timeCardIdSet.add(sr.getId());
                        }
                        if (!sr.isSuccess()) {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('::::::::::::::: ' + err.getMessage());
                                errMsg += err.getMessage();
                            }
                            UtilDomain.ErrorWrapper errWrapper = new UtilDomain.ErrorWrapper(timeLoglist[0],errMsg,'Time Card');
                            errorWrapperList.add(errWrapper);
                        }
                    }
                    
                    /*system.debug('::::::::dddd::timeCardInsertList::::::'+tcs);
                    for( AcctSeed__Time_Card__c tc : tcs) {
                        timeCardIdSet.add(tc.Id);
                    }*/
                }
                System.debug('timeCardList:::'+timeCardList);
                
                //End of time card creation
                
                if( timeCardIdSet != null && timeCardIdSet.size() > 0 ) {
                    timeCardList = [SELECT AcctSeed__Employee__c,Id,Intructor__c,AcctSeed__Time_Card_Period__c,AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c,AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c FROM AcctSeed__Time_Card__c WHERE Id IN: timeCardIdSet];
                }
                
                system.debug('::::::::timeCardList.size::::::::'+timeCardList.size());
                
                system.debug(':::::contServItemPtName::::::::'+contServItemPtName);
                
                // To check whether the old Project Task name in TCDL List and the Summary Time Detail's Project Task are same
                for (UtilDomain.tcdInnerCls t : tcdL) { 
                    if(contServItemPtName.containskey(t.ContId+t.projTaskName) && t.projTaskName != contServItemPtName.get(t.ContId+t.projTaskName)) {
                        t.projTaskName = contServItemPtName.get(t.ContId+t.projTaskName);
                    }
                }
                
                // Time Card line creation logic
                
                system.debug(':::::projectTaskNameWithProjectTaskId::::::::'+projectTaskNameWithProjectTaskId);
                Id parentProjectId;
                if(newProjectId != null) {
                    parentProjectId = newProjectId;
                } else if(oppIdProjectIdMap != null && oppIdProjectIdMap.containsKey(currentOppId)) {
                    parentProjectId = oppIdProjectIdMap.get(currentOppId);
                }
                
                for(AcctSeed__Time_Card_Line__c lineRec : [SELECT Id,Name,AcctSeed__Project__c,AcctSeed__Project_Task__c,AcctSeed__Project_Task__r.Name,AcctSeed__Billable__c,Payroll_Item__c,Location__c,
                                                                AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c,AcctSeed__Project_Task__r.AcctSeed__Project__c,
                                                                AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c 
                                                            FROM AcctSeed__Time_Card_Line__c WHERE AcctSeed__Project__c = :parentProjectId]) {
                    
                    String keyval = lineRec.AcctSeed__Project_Task__r.AcctSeed__Project__c+lineRec.AcctSeed__Project_Task__r.Name+lineRec.Payroll_Item__c+lineRec.AcctSeed__Time_Card__c+lineRec.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c+lineRec.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c+lineRec.Location__c;
                    if(!projectTaskNameSet.contains(keyval)){
                        projectTaskNameSet.add(keyval);
                    }
                }
                
                system.debug('::::::::::projectTaskNameSet:::from::OLD::TCL::'+projectTaskNameSet);
                
                for(AcctSeed__Time_Card__c tm: timeCardList) {
                            
                    for (UtilDomain.tcdInnerCls t : tcdL) {  
                                              
                        // To Create Time Card Line Creation
                        //system.debug('t Time Card Day ::::'+parentProjectId+' '+t.projTaskName+' '+t.tlg.Payroll_Item__c+' '+tm.Id+' '+t.Billable+' '+tm.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c+' '+tm.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c);                            
                        //system.debug('tm Time Card ::::'+tm);
                        
                        String tclKey = parentProjectId+t.projTaskName+t.tlg.Payroll_Item__c+tm.Id+t.Billable+tm.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c+tm.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c+t.tlg.Opportunity__r.Location__c;
                        
                        if(!projectTaskNameSet.contains(tclKey)) {
                            
                            if (tm.Intructor__c == t.ContId && t.tcd.AcctSeed__Date__c >= tm.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c && t.tcd.AcctSeed__Date__c <= tm.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c 
                                && t.tlg.Opportunity__c == currentOppId) {
                                
                                AcctSeed__Time_Card_Line__c TimeCardLine = new AcctSeed__Time_Card_Line__c(AcctSeed__Time_Card__c = tm.Id,AcctSeed__Billable__c = t.Billable,Payroll_Item__c = t.tlg.Payroll_Item__c,Location__c = t.tlg.Opportunity__r.Location__c);
                                
                                // Project  value assigning for line rec
                                if(newProjectId != null) {
                                    TimeCardLine.AcctSeed__Project__c = newProjectId;
                                } else if(oppIdProjectIdMap != null && oppIdProjectIdMap.containsKey(currentOppId)) {
                                    TimeCardLine.AcctSeed__Project__c = oppIdProjectIdMap.get(currentOppId);
                                }
                                
                                //Project Task value assigning
                                
                                if(projectTaskNameWithProjectTaskId != null && projectTaskNameWithProjectTaskId.containsKey(t.projTaskName)) {
                                   TimeCardLine.AcctSeed__Project_Task__c = projectTaskNameWithProjectTaskId.get(t.projTaskName);
                                }else if(proId_TaskName_TaskId != null && proId_TaskName_TaskId.containsKey(TimeCardLine.AcctSeed__Project__c+'-'+t.projTaskName)) {
                                    TimeCardLine.AcctSeed__Project_Task__c = proId_TaskName_TaskId.get(TimeCardLine.AcctSeed__Project__c+'-'+t.projTaskName);
                                }
                                
                                // For Parent Project Task related Contact Assignments
                                if(taskIdTaskRecMap.containsKey(TimeCardLine.AcctSeed__Project_Task__c) && taskIdTaskRecMap.get(TimeCardLine.AcctSeed__Project_Task__c).Parent_Project_Task__c != null) {
                                    
                                    for(Contact_Assignments__c conAss : contactAssignList) {
                                        if(conAss.Candidate_Name__c == tm.Intructor__c && conAss.Project_Task__c == taskIdTaskRecMap.get(TimeCardLine.AcctSeed__Project_Task__c).Parent_Project_Task__c) {
                                            TimeCardLine.Contact_Assignment__c = conAss.Id;
                                            TimeCardLine.Labor_Cost_Rate__c = conAss.Rate_Card_Rate__c;
                                        }
                                    }
                                }else {
                                    // For Normal Project Task Contact Assignments
                                    TimeCardLine.Contact_Assignment__c = conIdConAssignMap.containsKey(tm.Intructor__c) ? conIdConAssignMap.get(tm.Intructor__c).Id: null;
                                    TimeCardLine.Labor_Cost_Rate__c = conIdConAssignMap.containsKey(tm.Intructor__c) ? conIdConAssignMap.get(tm.Intructor__c).Rate_Card_Rate__c : null;
                                }
                                
                                if(TimeCardLine.AcctSeed__Project_Task__c != null){
                                    tcls.add(TimeCardLine);
                                    
                                }
                                    
                                projectTaskNameSet.add(tclKey); // To avoid creating many Records.
                            }                                   
                        }                                
                    }                            
                    // End Of Time card Line Creation
                }
                System.debug('projectTaskNameSet:::'+projectTaskNameSet);
                System.debug('TimeCardLineList:::::'+tcls);
                System.debug('TimeCardLineList::size:::'+tcls.size());
                
                // time card line insert code
                
                if ( tcls.size() > 0) {
                    //Insert tcls;
                    
                    Database.SaveResult[] srList = Database.insert(tcls, false);
                    
                    for (Database.SaveResult sr : srList) {
                       String errMsg = '';
                       system.debug(':::::::sr::::::'+sr);
                        if(sr.isSuccess()) {
                            TCLIds.add(sr.getId());
                        }
                        if (!sr.isSuccess()) {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('::::::::::::::: ' + err.getMessage());
                                errMsg += err.getMessage();
                            }
                            UtilDomain.ErrorWrapper errWrapper = new UtilDomain.ErrorWrapper(timeLoglist[0],errMsg,'Time Card Line');
                            errorWrapperList.add(errWrapper);
                        }
                    }
                }
                
                /*for (AcctSeed__Time_Card_Line__c t : tcls) {
                    TCLIds.add(t.Id);
                }*/
                System.debug('TCLIds::'+TCLIds);
                
                // End of time card line creation 
                
                // Time card day creation logic
                List<AcctSeed__Time_Card_Line__c> timeCardLineLi =  new List<AcctSeed__Time_Card_Line__c>();
                if(TCLIds.size() > 0) {
                    timeCardLineLi =  [SELECT Id,Payroll_Item__c,AcctSeed__Billable__c, Name, AcctSeed__Project_Task__c,AcctSeed__Project_Task__r.Name,
                                                AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c,
                                                AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c,AcctSeed__Project__r.AcctSeed__Opportunity__c,
                                                AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.AcctSeed__Opportunity__c 
                                        FROM AcctSeed__Time_Card_Line__c 
                                        WHERE Id IN:TCLIds];
                }else {
                    Id proId;
                    if(newProjectId != null) {
                        proId = newProjectId;
                    } else if(oppIdProjectIdMap != null && oppIdProjectIdMap.containsKey(currentOppId)) {
                        proId = oppIdProjectIdMap.get(currentOppId);
                    }
                    
                    timeCardLineLi =  [SELECT Id,Payroll_Item__c,AcctSeed__Billable__c, Name, AcctSeed__Project_Task__c,AcctSeed__Project_Task__r.Name,
                                                AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c,
                                                AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c,AcctSeed__Project__r.AcctSeed__Opportunity__c,
                                                AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c,AcctSeed__Project_Task__r.AcctSeed__Project__r.AcctSeed__Opportunity__c 
                                        FROM AcctSeed__Time_Card_Line__c 
                                        WHERE AcctSeed__Project__c = :proId];
                    
                }
                
                // Qry existing events for time card day creation
                // For the particular opp
                
                // For single opp & project conversion
                
                //No need this section - because Event lookup field in TCD is removed
                //Commented code by NS on Mar 6 2019
                /*if(oppId != null) {
                    for(Events__c eve : [SELECT Id,Name,Date__c FROM Events__c WHERE Schedule__r.Opportunity__c = :oppId  AND Status__c = 'Scheduled' AND Date__c IN :tlDateSet]) {
                        if(!EvntDateIdMap.containsKey(eve.Date__c))
                            EvntDateIdMap.put(eve.Date__c,eve.Id);
                    }
                }
                // For bulk opp & project
                if(oppIds != null && oppIds.size() > 0 && currentOppId != null){
                    for(Events__c eve : [SELECT Id,Name,Date__c FROM Events__c WHERE Schedule__r.Opportunity__c = :currentOppId  AND Status__c = 'Scheduled' AND Date__c IN :tlDateSet]) {
                        if(!EvntDateIdMap.containsKey(eve.Date__c))
                            EvntDateIdMap.put(eve.Date__c,eve.Id);
                    }
                }
                system.debug('::::::EvntDateIdMap:::::'+EvntDateIdMap);*/
               
                 for (UtilDomain.tcdInnerCls t : tcdL) {
                    System.debug('Ineer Class Instance::'+t);
                    for ( AcctSeed__Time_Card_Line__c cl : timeCardLineLi) {
                        System.debug('cl :::'+cl);
     
                        if(t.projTaskName != null && t.ContId != null && t.ContId == cl.AcctSeed__Time_Card__r.Intructor__c && t.projTaskName == cl.AcctSeed__Project_Task__r.Name
                        && cl.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c <= t.tcd.AcctSeed__Date__c && cl.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c >= t.tcd.AcctSeed__Date__c 
                        && cl.AcctSeed__Billable__c == t.Billable && cl.Payroll_Item__c == t.tlg.Payroll_Item__c && cl.AcctSeed__Project_Task__r.AcctSeed__Project__r.AcctSeed__Opportunity__c == t.tlg.Opportunity__c) {
                            
                            t.tcd.AcctSeed__Time_Card_Line__c = cl.Id;
                            /*if(EvntDateIdMap.Containskey(t.tcd.AcctSeed__Date__c)) {
                                System.debug('EvntDateIdMap.get(t.tcd.AcctSeed__Date__c):::'+EvntDateIdMap.get(t.tcd.AcctSeed__Date__c));
                                t.tcd.Event__c = EvntDateIdMap.get(t.tcd.AcctSeed__Date__c);
                            }*/
                            tcdays.add(t.tcd);
                        }
                    }
                }
                
                System.debug('tcdays:::'+tcdays);
                if( tcdays != null && tcdays.size() > 0 ) {
                    //Insert tcdays;
                    
                    Database.SaveResult[] srList = Database.insert(tcdays, false);
                   
                   // For merging existing time card day values with time log hrs
                   Map<String,Map<Date,AcctSeed__Time_Card_Day__c>> lineName_Date_DayRecMap = new Map<String,Map<Date,AcctSeed__Time_Card_Day__c>>();
                   List<AcctSeed__Time_Card_Day__c> dayUpdationList = new List<AcctSeed__Time_Card_Day__c>();
                    
                    for (Database.SaveResult sr : srList) {
                       system.debug(':::::::sr::::::'+sr);
                       String errMsg = '';
                        if (!sr.isSuccess()) {
                            // Operation failed, so get all errors                
                            /*for(Database.Error err : sr.getErrors()) {
                                System.debug(':::::::::::::: ' + err.getMessage());
                                errMsg += err.getMessage();
                            }*/
                            //UtilDomain.ErrorWrapper errWrapper = new UtilDomain.ErrorWrapper(timeLoglist[0],errMsg,'Time Card Day');
                            //errorWrapperList.add(errWrapper);
                            
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('::::::::::::::: ' + err.getMessage());
                                if(err.getMessage().contains('TCL-')){
                                    String lineName = 'TCL-'+err.getMessage().split('TCL-')[1];
                                    system.debug('::::::lineName:::::'+lineName);
                                    
                                    String dateValueStr = err.getMessage().split('day record for ')[1].split(' already exists')[0];
                                    
                                    String mnth1 = dateValueStr.split('/')[0];
                                    String dt = dateValueStr.split('/')[1];
                                    String yr = dateValueStr.split('/')[2];
                                    
                                    String dtValue = yr+'-'+mnth1+'-'+dt;
                                    
                                    if(!lineName_Date_DayRecMap.containsKey(lineName)) {
                                        lineName_Date_DayRecMap.put(lineName,new Map<Date,AcctSeed__Time_Card_Day__c>{Date.valueOf(dtValue)=>new AcctSeed__Time_Card_Day__c()});
                                    }else {
                                        lineName_Date_DayRecMap.get(lineName).put(Date.valueOf(dtValue),new AcctSeed__Time_Card_Day__c());
                                    }
                                }
                            }
                        }
                    }
                    
                    system.debug(':::::::lineName_Date_DayRecMap:::::'+lineName_Date_DayRecMap);
                
                    for(AcctSeed__Time_Card_Line__c line : [SELECT Id,Name,(SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Time_Card_Line__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.AcctSeed__Opportunity__c,AcctSeed__Hours__c,Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c 
                                                                            FROM AcctSeed__Time_Card_Days__r WHERE Status__c = 'Approved') 
                                                            FROM AcctSeed__Time_Card_Line__c 
                                                            WHERE Name IN :lineName_Date_DayRecMap.keySet()]) {
                        if(line.AcctSeed__Time_Card_Days__r != null && line.AcctSeed__Time_Card_Days__r.size() > 0) {
                            for(AcctSeed__Time_Card_Day__c dayRec : line.AcctSeed__Time_Card_Days__r) {
                            
                                if(lineName_Date_DayRecMap.containsKey(line.Name) && lineName_Date_DayRecMap.get(line.Name).containsKey(dayRec.AcctSeed__Date__c)) {
                                     lineName_Date_DayRecMap.get(line.Name).put(dayRec.AcctSeed__Date__c,dayRec);
                                }
                            }
                        }
                    }
                    
                    system.debug(':::::::::lineName_Date_DayRecMap::::::'+lineName_Date_DayRecMap);
                
                    for(AcctSeed__Time_Card_Day__c newDay : tcdays) {
                        for(String lineName : lineName_Date_DayRecMap.keySet()) {
                            if(lineName_Date_DayRecMap.get(lineName).containsKey(newDay.AcctSeed__Date__c) 
                                && newDay.AcctSeed__Time_Card_Line__c == lineName_Date_DayRecMap.get(lineName).get(newDay.AcctSeed__Date__c).AcctSeed__Time_Card_Line__c
                                && currentOppId == lineName_Date_DayRecMap.get(lineName).get(newDay.AcctSeed__Date__c).AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.AcctSeed__Opportunity__c) {
                                                            
                                AcctSeed__Time_Card_Day__c dayVal = new AcctSeed__Time_Card_Day__c();
                                AcctSeed__Time_Card_Day__c oldDay = lineName_Date_DayRecMap.get(lineName).get(newDay.AcctSeed__Date__c);
                                
                                dayVal.Id = oldDay.Id;
                                dayVal.Total_Hours_Before_Approved__c = oldDay.Total_Hours_Before_Approved__c + newDay.Total_Hours_Before_Approved__c;
                                dayVal.AcctSeed__Hours__c = oldDay.AcctSeed__Hours__c + newDay.AcctSeed__Hours__c;
                                
                                String notes;
                                if(oldDay.AcctSeed__Internal_Comment__c != null)
                                    notes = oldDay.AcctSeed__Internal_Comment__c+'. Merged ';
                                else
                                    notes = 'Merged ';
                                    
                                dayVal.AcctSeed__Internal_Comment__c = notes;
                                dayVal.AcctSeed__Internal_Comment__c = dayVal.AcctSeed__Internal_Comment__c + '- '+newDay.Time_Log_Id__c;
                                
                                dayUpdationList.add(dayVal);
                            }
                        }
                    }
                    
                    system.debug(':::::::::dayUpdationList:::::'+dayUpdationList);
                    
                    if(dayUpdationList.size() > 0) {
                        //update dayUpdationList;
                        Database.SaveResult[] updateSrList = Database.update(dayUpdationList, false);
                        for (Database.SaveResult srUpdate : updateSrList) {
                           system.debug(':::::::srUpdate::time card::::'+srUpdate);
                           String errMsg = '';
                           if (!srUpdate.isSuccess()) {
                                // Operation failed, so get all errors                
                                for(Database.Error err : srUpdate.getErrors()) {
                                    System.debug('::::::Line Num 795::::::::: ' + err.getMessage());
                                    errMsg += err.getMessage();
                                }
                                UtilDomain.ErrorWrapper errWrapper = new UtilDomain.ErrorWrapper(timeLoglist[0],errMsg,'Time Card Day');
                                errorWrapperList.add(errWrapper);
                                
                            }
                        }
                        
                    }
                    
                }
                
                // End of time card day creation
            }
            
            
        }catch(DmlException e) {
            System.debug('DmlException caught: ' + e.getMessage()); 
            
            sendEmailWhenErrorOccurs(e.getMessage());  
            
            //Database.RollBack(sp);
        } catch(SObjectException e) {

            System.debug('SObjectException caught: ' + e.getMessage()); 
            
            sendEmailWhenErrorOccurs(e.getMessage());  
            
            //Database.RollBack(sp);  
        } catch(Exception e) {

            System.debug('Exception caught: ' + e.getMessage());
            
            sendEmailWhenErrorOccurs(e.getMessage());  
            
            //Database.RollBack(sp);   
        }
        
    }
    
    global void finish(Database.BatchableContext info){ 
        
        if(errorWrapperList != null && errorWrapperList.size() > 0) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            String mailContent = '<html>Dear Softsquare,<br/>The following errors are occured during time log to time card day conversion:'; 
            mailContent += '<br/><table border="1" style="border-collapse: collapse"><thead><th>Time Log Name</th><th>Date</th><th>Error Description</th></thead><tbody>';    
            
            Set<String> keyStr = new Set<String>();
            
            for(UtilDomain.ErrorWrapper val : errorWrapperList) {
                String key = val.record.get('Name')+'-'+val.record.get('Date__c')+'-'+val.objectType+'-'+val.message;
                
                if(!keyStr.contains(key)) {
                    mailContent += '<tr><td width="25%">'+val.record.get('Name')+'</td><td width="25%">'+val.record.get('Date__c')+'</td><td width="25%">'+ val.objectType +' - '+val.message +'</td></tr>'; 
                    keyStr.add(key);
                }
            }
            
            mailContent += '</tbody></table><br/><p>This e-mail was auto generated. Please do not respond.</p><p>If you have questions, contact your Salesforce Administrator.</p>';
            mailContent += '</html>';
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            List<String> supervisorEmails = new List<String>();
            for(Contact_Assignments__c conAss : [SELECT Id,Name,Project__c,Candidate_Name__c,Candidate_Name__r.Email FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Project__c = :newProjectId AND Status__c = 'Active']) {
                if(conAss.Candidate_Name__r.Email != null)
                    supervisorEmails.add(conAss.Candidate_Name__r.Email);
            }
            
            supervisorEmails.add('cbellas@dlsdc.com');
            supervisorEmails.add('abellas@dlsdc.com');
            
            
            //To add any emails in future used custom label to hold the emails
            List<String> exceptionMails = new List<String>();
            
            for(String str : system.Label.Convert_to_Project_Exception_Mails.split(',')){
                exceptionMails.add(str.trim());
            }
            
            //mail.setToAddresses(supervisorEmails);
            mail.setToAddresses(exceptionMails);
            mail.setSubject('Error on Time Log to Time card day conversion for '+oppName);
            mail.sethtmlBody(mailContent);
            mails.add(mail);
            System.debug('mails::::'+mails);
            if( mails != null && mails.size() > 0 && !Test.isRunningTest()) {
                Messaging.sendEmail(mails);
            }
            
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