// Schdeuler to call TimeCard_Creation_FromCTP batch class for time log to time card day creation process
// Created by Sukanya on November 16 2017
// Scheduled on weekly basis
global class Weekly_timeLog_toTCDCreation implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        Map<String,String> contServItemPtName = new Map<String,String>();
        Map<String,Id> projectTaskNameWithProjectTaskId = new Map<String,Id>();
        Map<Date,Date> stdateandEnddtMap = new Map<Date,Date>();
        List<Date> tlDateSet = new List<Date>();     // Time Log Dates     
        Set<Date> monthStartdtSet = new Set<Date>(); // For Accounting Period 
        Set<Date> monthEnddtSet = new Set<Date>();   // For Ac
        Set<Id> ContIds = new Set<Id>();
        
        Set<Id> taskIds = new Set<Id>();
        Set<Id> existingTLIds = new Set<Id>();
        Map<String,Map<String,Decimal>> contIdPtNameHoursMap = new Map<String,Map<String,Decimal>>();
        Map<Id,Map<Date,Date>> contIdWithStAndEndDateMap = new Map<Id,Map<Date,Date>>();
        
        Map<String,String> PayRollValuesMap = new Map<String,String>{'S' => 'Sick', 'V' => 'Vacation', 'HOL' => 'Holiday', 'OTH' => 'Other Pay', 'BLE' => 'Bonus Leave Earned', 'BLT' => 'Bonus Leave Taken'};
        
        Date stDate;
        Date endDate;
        
        Set<Date> startdtSet = new Set<Date>();      // For Time Card Period Query Week Start Date Set
        Set<Date> enddtSet = new Set<Date>();        // For Time Card Period Query Week End Date Set
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();
        
        Map<String,String> productNameStaticMap = new Map<String,String>{'Language Training- Arabic' => 'Language Training- Arabic (MSA and all dialects)', 'Language Training- Vietnamese' => 'Language Training- Vietnamese (all dialects)', 'Language Training- Mandarin' => 'Language Training- Chinese (Mandarin)', 'Language Training- Portuguese' => 'Language Training- Portuguese (all dialects)'};
        
        Map<Id,Id> oppIdProjectIdMap = new Map<Id,Id>();
        Map<String,Id> pro_taskName_taskId = new Map<String,Id>();
         
        for(Opportunity opp : [SELECT Id,Name 
                                FROM Opportunity 
                                WHERE Id IN (SELECT AcctSeed__Opportunity__c FROM AcctSeed__Project__c) 
                                    AND End_Date__c >= 2017-01-01 AND StageName IN ('Active','Order','On Hold','Ended')]) {
            oppIds.add(opp.Id);
        }
        
        system.debug('::::::oppIds:::::'+oppIds.size());
        
        for(AcctSeed__Project__c proj : [SELECT Id,Name,AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c != null AND AcctSeed__Opportunity__c IN :oppIds]) {
            projectIds.add(proj.Id);
            
            if(!oppIdProjectIdMap.containsKey(proj.AcctSeed__Opportunity__c))
                oppIdProjectIdMap.put(proj.AcctSeed__Opportunity__c,proj.Id);
        }
        
        system.debug('::::::projectIds:::::'+projectIds.size());
        
        for(AcctSeed__Project_Task__c task : [SELECT Id,Name,AcctSeed__Project__c,Service_Item__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :projectIds]) {
            
            if(!pro_taskName_taskId.containsKey(task.AcctSeed__Project__c+'-'+task.Name))
                pro_taskName_taskId.put(task.AcctSeed__Project__c+'-'+task.Name,task.Id);
                
            taskIds.add(task.Id);
        }
        system.debug('::::::taskIds:::::'+taskIds.size());
        
        for(AcctSeed__Time_Card_Day__c day : [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c,Time_Log_Id__c,AcctSeed__Internal_Comment__c 
                                                    FROM AcctSeed__Time_Card_Day__c 
                                                    WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c IN : taskIds 
                                                        AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c IN :projectIds AND Time_Log_Id__c != null]) {
            
            existingTLIds.add(day.Time_Log_Id__c);
            if(day.AcctSeed__Internal_Comment__c != null && day.AcctSeed__Internal_Comment__c.contains('Merged - ') && day.AcctSeed__Internal_Comment__c.split('-').size() > 1) {
                existingTLIds.add(day.AcctSeed__Internal_Comment__c.split('- ')[1]);
            }
        }
        
        system.debug(':::::::existingTLIds::::::'+existingTLIds);
        system.debug(':::::::existingTLIds:::size:::'+existingTLIds.size());
        
        Set<String> tempProjTaskAddSet = new Set<String>();
        Set<String> oldPtNAmeSet = new Set<String>();
        
        
        for(Time_Log__c tl : [SELECT Contact__c,Contact__r.Name,Notes__c,Hours__c,Date__c,First_Name__c,Last_Name__c,Name,Opportunity__c,Service_Item__c,Billable_Work__c,Classification__c,Unposted__c,Payroll_Item__c 
                                FROM Time_Log__c 
                                WHERE Opportunity__c IN :oppIds AND Unposted__c = False 
                                    AND Id NOT IN : existingTLIds Order By Date__c Asc]) {
            tlDateSet.add(tl.Date__c);            
            if(tl.Contact__c != null) {
                ContIds.add(tl.Contact__c);
            }
            
            Date sDate;
            Date eDate;
            if(tl.Date__c != null) {
                tlDateSet.add(tl.Date__c);
                
                if(tl.Date__c.toStartofWeek().addDays(1) < tl.Date__c)
                    sDate = tl.Date__c.toStartofWeek().addDays(1);
                else
                    sDate = tl.Date__c.addDays(-1).toStartofWeek().addDays(1);
                    
                eDate = sDate.addDays(6);
            }
            
            if(tl.Contact__c != null && !contIdWithStAndEndDateMap.Containskey(tl.Contact__c)) {
                contIdWithStAndEndDateMap.put(tl.Contact__c, new Map<Date,Date>());
            } 
            
            if(contIdWithStAndEndDateMap != null && contIdWithStAndEndDateMap.containskey(tl.Contact__c) && !contIdWithStAndEndDateMap.get(tl.Contact__c).containskey(sDate)) {
                contIdWithStAndEndDateMap.get(tl.Contact__c).put(sDate,eDate);
            }             
        }
      
        if( tlDateSet != null && tlDateSet.size() > 0 ) {
                    
            stDate = tlDateSet[0];
            endDate = tlDateSet[tlDateSet.size()-1];
            Date FinalEndDate = endDate.toStartofWeek()+7;
            
            Date weekstdate;
            Date weekenddate;
            
            if(stDate.toStartofWeek().addDays(1) < stDate)
                weekstdate = stDate.toStartofWeek().addDays(1);
            else
                weekstdate = stDate.addDays(-1).toStartofWeek().addDays(1);
                
            weekenddate = weekstdate.addDays(6);
            
            while(weekstdate <= FinalEndDate && weekenddate <= FinalEndDate) {
                startdtSet.add(weekstdate);
                enddtSet.add(weekenddate);  
                
                if(!stdateandEnddtMap.containsKey(weekstdate)) {
                    stdateandEnddtMap.put(weekstdate,weekenddate);
                }
                                        
                Date monthStart = weekstdate.toStartofMonth();
                Date monthEnd = weekstdate.addMonths(1).toStartofMonth().addDays(-1);
                
                monthStartdtSet.add(monthStart);
                monthEnddtSet.add(monthEnd);
                
                weekstdate = weekstdate.addDays(7);
                weekenddate = weekenddate.addDays(7); 
            }
        }
        
        UtilDomain.batchParameters batchParam = new UtilDomain.batchParameters();
        batchParam.contServItemPtName = contServItemPtName;
        batchParam.projectTaskNameWithProjectTaskId = projectTaskNameWithProjectTaskId;
        batchParam.startdtSet = startdtSet;
        batchParam.enddtSet = enddtSet;
        batchParam.stdateandEnddtMap = stdateandEnddtMap;
        batchParam.tlDateSet = tlDateSet;
        batchParam.monthStartdtSet = monthStartdtSet;
        batchParam.monthEnddtSet = monthEnddtSet;
        batchParam.contIdWithStAndEndDateMap = contIdWithStAndEndDateMap;
        batchParam.ContIds = ContIds;
        batchParam.PayRollValuesMap = PayRollValuesMap;
        batchParam.existingTLIds = existingTLIds;
        batchParam.oppIds = oppIds;
        batchParam.projectIds = projectIds;
        batchParam.oppIdProjectIdMap = oppIdProjectIdMap;
        batchParam.proId_TaskName_TaskId = pro_taskName_taskId;
        
        system.debug('L:::::::::::batchParam:::::::::::'+batchParam);
        
        // Calling User Creation batch to create missing time log record to time card day
        if(!Test.isRunningTest() && tlDateSet != null && tlDateSet.size() > 0) {
            UserCreation_FrmContact usrContactBatch = new UserCreation_FrmContact(batchParam);
            database.executeBatch(usrContactBatch);
        }
    }
}