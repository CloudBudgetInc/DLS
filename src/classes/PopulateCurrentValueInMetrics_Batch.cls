/*****************
    - Created By HL on Jan 10 2022
    - To populate current value field in metric records for the current year
    - This batch class is invoked from PopulateCurrentValueInMetrics_Scheduler, "Refresh" quick action and "Refresh Metrics" global action
    - Work Item: W-007098 - 2022 YTD Actual vs Proforma Budget Report
    - Modified By HL on Mar 17 2022
    - Work Item: W-007375 - Issues with 2022 Goals and Metrics (G&M) - Urgent
    **************/
    
public class PopulateCurrentValueInMetrics_Batch implements Database.Batchable<sObject>{

    public Id goalRec_Id;
    public Id metricRec_Id;
    public Date startDate_Val;
    public Date endDate_Val;
    public Integer todayDate_Month = Date.today().month();
    public Date endDate_Of_LastMonth = Date.today().toStartOfMonth()-1;
    public Date startDate_Of_LastMonth = endDate_Of_LastMonth.toStartOfMonth();
    
    public PopulateCurrentValueInMetrics_Batch(Id goal_Id, Id metric_Id, Date startDate, Date endDate){
        
        goalRec_Id = goal_Id;
        metricRec_Id = metric_Id;
        startDate_Val = startDate;
        endDate_Val = endDate;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bC){
            
        String goal_Query_Condition = '';
        String goal_Query_Str = 'SELECT Id, Name, Start_Date__c, Due_Date__c FROM Goal__c';
        
        if(goalRec_Id != null){
            goal_Query_Condition += 'Id = : goalRec_Id';
        }else if(goalRec_Id == null){
        
            Date goal_Start_Date_1; 
            Date goal_Due_Date_1;
                
            Date goal_Start_Date_2; 
            Date goal_Due_Date_2;
        
            // Scheduler Logic for previous month
            if(startDate_Val == null && endDate_Val == null){
            
                goal_Start_Date_1 = Date.newinstance(endDate_Of_LastMonth.year(), 1, 1);
                goal_Due_Date_1 = Date.newinstance(endDate_Of_LastMonth.year(), 12, 31);
                
                goal_Query_Condition += 'Start_Date__c = : goal_Start_Date_1 AND Due_Date__c = : goal_Due_Date_1';
            }
            
            // Global Action logic for date range
            if(startDate_Val != null && endDate_Val != null){
                
                if(startDate_Val.year() == endDate_Val.year()){
                
                    goal_Start_Date_1 = Date.newinstance(startDate_Val.year(), 1, 1);
                    goal_Due_Date_1 = Date.newinstance(startDate_Val.year(), 12, 31);
                    
                    goal_Query_Condition += 'Start_Date__c = : goal_Start_Date_1 AND Due_Date__c = : goal_Due_Date_1';
                }
                if(startDate_Val.year() != endDate_Val.year()){
                
                    goal_Start_Date_1 = Date.newinstance(startDate_Val.year(), 1, 1);
                    goal_Due_Date_1 = Date.newinstance(startDate_Val.year(), 12, 31);
                    
                    goal_Start_Date_2 = Date.newinstance(endDate_Val.year(), 1, 1);
                    goal_Due_Date_2 = Date.newinstance(endDate_Val.year(), 12, 31);
                    
                    goal_Query_Condition += '(Start_Date__c = : goal_Start_Date_1 AND Due_Date__c = : goal_Due_Date_1) OR (Start_Date__c = : goal_Start_Date_2 AND Due_Date__c = : goal_Due_Date_2)';
                }
            }
        }
        
        if(String.isNotBlank(goal_Query_Condition)){
            goal_Query_Str += ' WHERE '+ goal_Query_Condition;
        }
        
        if(Test.isRunningTest()){
            goal_Query_Str += ' LIMIT 1'; 
        }
        return Database.getQueryLocator(goal_Query_Str);    
    }
    
    public void execute(Database.BatchableContext bC, List<Goal__c> goals){
        
        if(goals != null && goals.size() > 0){
                        
            try{
                
                Map<String, String> goalNameAndQueryCondition = new Map<String, String>();
                        
                Integer goal_Year = goals[0].Start_Date__c.year();
                
                String goal_Year_Str = String.valueOf(goal_Year);
                
                String metric_Query_Str = 'SELECT Id, Name, Current_Value__c, Goal__c, Goal__r.Name, Start_Date__c, Due_Date__c FROM Metric__c';
                String metric_Query_Condition = '';
                
                if(metricRec_Id != null){
                    metric_Query_Condition = 'Id = : metricRec_Id';        
                }else if(metricRec_Id == null){
                    metric_Query_Condition = 'Goal__c IN : goals';
                    
                    // Scheduler Purpose (To populate last month metric record's current value field)
                    if(startDate_Val == null && endDate_Val == null){
                    
                        metric_Query_Condition += ' AND Start_Date__c = : startDate_Of_LastMonth AND Due_Date__c = :endDate_Of_LastMonth';  
                    }
                    
                    // Global Action Purpose (To populate given date range related metrics record's current value field)
                    if(startDate_Val != null && endDate_Val != null){
                    
                        Date firstDay_Of_SD = startDate_Val.toStartOfMonth();
                        Integer numberOfDays = Date.daysInMonth(endDate_Val.year(), endDate_Val.month());
                        Date lastDay_Of_ED = Date.newInstance(endDate_Val.year(), endDate_Val.month(), numberOfDays);
                        metric_Query_Condition += ' AND Start_Date__c >= : firstDay_Of_SD AND Due_Date__c <= :lastDay_Of_ED';         
                    }      
                }
                
                if(String.isNotBlank(metric_Query_Condition)){
                    metric_Query_Str += ' WHERE Metric_Type__c = \'Hours\' AND '+ metric_Query_Condition;
                }
                
                List<Metric__c> metrics = Database.Query(metric_Query_Str);
                              
                // Batch size is 1, so considering one Goal here
                String goalName = goals[0].Name.contains(goal_Year_Str+' ') ? goals[0].Name.remove(goal_Year_Str+ ' ') : goals[0].Name;
                
                List<Goals_Metrics_Mapping__c> goalAndMetricMappingRecs = [
                    SELECT Id, Name, Goal_Name__c, Account__c, Account_Condition__c, Billable__c, Billable_Condition__c, 
                        Contact_Assignment_Position__c, Contact_Assignment_Position_Condition__c, Project_Record_Type__c, 
                        Project_Record_Type_Condition__c, QB_Classification__c, QB_Classification_Condition__c, 
                        GLAV2__c, GLAV2_Condition__c
                    FROM Goals_Metrics_Mapping__c
                    WHERE Goal_Name__c = : goalName
                ];
                
                                
                if(goalAndMetricMappingRecs != null && goalAndMetricMappingRecs.size() > 0){
                
                    Goals_Metrics_Mapping__c mappingRec = goalAndMetricMappingRecs[0];
                                            
                    String condition = '';                
                    Boolean haveAccCond = False;
                    Boolean haveClassCond = False;
                    Boolean haveBillCond = False;
                    Boolean haveCACond = False;
                    Boolean haveGLAV2Cond = False;
                    
                    if(mappingRec.Account__c != null && mappingRec.Account_Condition__c != null){
                    
                        haveAccCond = True;
                        condition += ' AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.AcctSeed__Account__c != null';
                    }
                    if(mappingRec.QB_Classification__c != null && mappingRec.QB_Classification_Condition__c != null){
                        
                        if(haveAccCond){
                            condition += ' AND';
                        }
                        haveClassCond = True;
                        condition += ' AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.QB_Classification__c != null';
                    }
                    if(mappingRec.Billable__c != null && mappingRec.Billable_Condition__c != null){
                        
                        if(haveAccCond || haveClassCond){
                            condition += ' AND';
                        }
                        
                        haveBillCond = True;
                        Boolean billable_Val = Boolean.valueOf(mappingRec.Billable__c);
                        condition += ' AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c = :billable_Val';
                    }
                    if(mappingRec.Contact_Assignment_Position__c != null && mappingRec.Contact_Assignment_Position_Condition__c != null){
                    
                        if(haveAccCond || haveClassCond || haveBillCond){
                            condition += ' AND';
                        }
                        haveCACond = True;
                        condition += ' AcctSeed__Time_Card_Line__r.Contact_Assignment__c != null AND AcctSeed__Time_Card_Line__r.Contact_Assignment__r.Assignment_Position__c != null';    
                    }
                    if(mappingRec.GLAV2__c != null && mappingRec.GLAV2_Condition__c != null){
                    
                        if(haveAccCond || haveClassCond || haveBillCond || haveCACond){
                            condition += ' AND';
                        }
                        haveGLAV2Cond = True;
                        condition += ' GL_Variable_2__c != null';
                    }
                    if(haveAccCond || haveClassCond || haveBillCond || haveCACond || haveGLAV2Cond){
                    
                        if(metricRec_Id != null && metrics != null && metrics.size() > 0){
                            
                            Date metric_SD = metrics[0].Start_Date__c;
                            Date metric_ED = metrics[0].Due_Date__c;
                            
                            condition += ' AND AcctSeed__Date__c >= : metric_SD AND AcctSeed__Date__c <= : metric_ED';
                            
                        }else if(metricRec_Id == null){
                            
                            // Logic for Scheduler
                            if(startDate_Val == null && endDate_Val == null){
                                condition += ' AND AcctSeed__Date__c >= :startDate_Of_LastMonth AND AcctSeed__Date__c <= :endDate_Of_LastMonth';
                            }
                            // Logic for Global Action
                            if(startDate_Val != null && endDate_Val != null){
                            
                                Date tcdSD = startDate_Val.toStartOfMonth();
                                Date tcdED;
                                Integer numberOfDays = Date.daysInMonth(endDate_Val.year(), endDate_Val.month());
                                Date lastDay_Of_ED = Date.newInstance(endDate_Val.year(), endDate_Val.month(), numberOfDays);
                                
                                if(lastDay_Of_ED > Date.Today()){
                                    tcdED = endDate_Val; 
                                }else{
                                    tcdED = lastDay_Of_ED; 
                                }
                                
                                condition += ' AND AcctSeed__Date__c >= :tcdSD AND AcctSeed__Date__c <= :tcdED';
                            }
                        }  
                    }
                    
                    String allCondition = '';
                    if(String.isNotBlank(condition)){
                        allCondition = ' WHERE Status__c IN (\'Approved\',\'Admin Approved\',\'Submitted\') AND Total_Hours_Before_Approved__c != 0 AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c != null AND'+condition;
                    }else{
                        allCondition = ' WHERE Status__c IN (\'Approved\',\'Admin Approved\',\'Submitted\') AND Total_Hours_Before_Approved__c != 0 AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c != null';
                    }
                    goalNameAndQueryCondition.put(mappingRec.Goal_Name__c, allCondition);
                                
                    String tcd_Query_Str = 'SELECT Id, Total_Hours_Before_Approved__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.AcctSeed__Account__r.Name, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.QB_Classification__c, ';  
                    tcd_Query_Str += 'AcctSeed__Time_Card_Line__r.Contact_Assignment__r.Assignment_Position__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Project_Record_Type_Name__c, ';
                    tcd_Query_Str += 'GL_Variable_2__r.Name, AcctSeed__Date__c FROM AcctSeed__Time_Card_Day__c';
                    tcd_Query_Str += goalNameAndQueryCondition.get(goalName);
                    
                    List<AcctSeed__Time_Card_Day__c> days = Database.Query(tcd_Query_Str);
                    
                    if(days != null && days.size() > 0){
                                
                        if(metrics != null && metrics.size() > 0){
                            
                            List<Metric__c> updateMetricRecs = new List<Metric__c>();  
                            
                            for(Metric__c m : metrics){
                                
                                Decimal totalHours = Goal_Metric_Util.getGoalNameAndTotalHours(days, mappingRec, m, startDate_Val, endDate_Val);   
                                if(totalHours != null){
                                    m.Current_Value__c = totalHours;            
                                }else{
                                    m.Current_Value__c = 0;  
                                }
                                updateMetricRecs.add(m);
                            }    
                            
                            if(updateMetricRecs.size() > 0){
                                update updateMetricRecs;
                            }
                        }
                    }
                }
            }catch(Exception exe){
                String result = exe.getMessage();            
                ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('PopulateCurrentValueInMetrics_Batch','Execute Method','',result+' at line number '+exe.getLineNumber(),'','Batch')});
            }   
        }
    }
    
    public void finish(Database.BatchableContext bC){
        
    }
}