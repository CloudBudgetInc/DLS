/*************
    - W-007669 : Create Goals & Metrics for Inquiries & Enrollments (JAN-6-2023)
    - To populate Current Value field in marketing related metrics
    - Scheduler logic and Global Action are excluded for Closure Rate - Q1 {Current Year}, Closure Rate - Q2 {Current Year}, Closure Rate - Q3 {Current Year}, Closure Rate - Q4 {Current Year}, 
        Closure Rate - {Current Year}, # of Inquiries - {Current Year}, # of Enrollments - {Current Year}, Value of Inquiries - {Current Year},
        Value of Enrollments - {Current Year}, Avg Hourly Rate of Enrollments - {Current Year} 
    - Refresh (Quick Action) will works for above mentioned metrics
    *************/
    
public class PopulateCurrentValueInMarketingMetrics implements Database.Batchable<sObject>{

    public Id goalRec_Id;
    public Id metricRec_Id;
    public Date startDate_Val;
    public Date endDate_Val;
    public Date endDate_Of_LastMonth = Date.today().toStartOfMonth()-1;
    public Date startDate_Of_LastMonth = endDate_Of_LastMonth.toStartOfMonth();
    public Integer todayDate_Month = Date.today().month();
    public Integer todayDate_Year = Date.today().year();
    public Date todayDate = Date.Today();
    
    public PopulateCurrentValueInMarketingMetrics(Id goal_Id, Id metric_Id, Date startDate, Date endDate){
        
        goalRec_Id = goal_Id;
        metricRec_Id = metric_Id;
        startDate_Val = startDate;
        endDate_Val = endDate;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bC){
                    
        String goal_Query_Condition = '';
        String goal_Query_Str = 'SELECT Id, Name, Start_Date__c, Due_Date__c FROM Goal__c WHERE Name LIKE \'%Registrar%\'';
        
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
                    
                    goal_Query_Condition += '((Start_Date__c = : goal_Start_Date_1 AND Due_Date__c = : goal_Due_Date_1) OR (Start_Date__c = : goal_Start_Date_2 AND Due_Date__c = : goal_Due_Date_2))';
                }
            }
        }
        
        if(String.isNotBlank(goal_Query_Condition)){
            goal_Query_Str += ' AND '+ goal_Query_Condition;
        }
        
        if(Test.isRunningTest()){
            goal_Query_Str += ' LIMIT 1'; 
        }
        
        System.debug(':goal_Query_Str::::'+goal_Query_Str);
        
        return Database.getQueryLocator(goal_Query_Str);  
    }
    
    public void execute(Database.BatchableContext bC, List<Goal__c> goals) {
        
        if(goals.size() > 0){
                    
            Integer goal_Year = goals[0].Start_Date__c.year();
            String goal_Year_Str = String.valueOf(goal_Year);
                
            String goalName = goals[0].Name.contains(goal_Year_Str+' ') ? goals[0].Name.remove(goal_Year_Str+ ' ') : goals[0].Name;
            
            String metric_Query_Str = 'SELECT Id, Name, Current_Value__c, Goal__c, Goal__r.Name, Start_Date__c, Due_Date__c FROM Metric__c';
            String metric_Query_Condition = '';
        
            if(metricRec_Id != null){
                metric_Query_Condition = 'Id = : metricRec_Id';        
            }else if(metricRec_Id == null){
            
                metric_Query_Condition = 'Goal__c IN : goals';
                
                // To exlude date range condition in Quarter / Year based metric records
                if(!goalName.contains('Closure Rate per QTR') && !goalName.contains('Closure Rate per Year')){
                
                    // Scheduler Logic
                    if(startDate_Val == null && endDate_Val == null){
                        
                        metric_Query_Condition += ' AND Start_Date__c = : startDate_Of_LastMonth AND Due_Date__c = :endDate_Of_LastMonth';  
                    }
                    // Global Action
                    if(startDate_Val != null && endDate_Val != null){
                    
                        Date firstDay_Of_SD = startDate_Val.toStartOfMonth();    //First day of given from date
                        Integer numberOfDays = Date.daysInMonth(endDate_Val.year(), endDate_Val.month());
                        Date lastDay_Of_ED = Date.newInstance(endDate_Val.year(), endDate_Val.month(), numberOfDays);    //Last day of given to date
                        metric_Query_Condition += ' AND Start_Date__c >= : firstDay_Of_SD AND Due_Date__c <= :lastDay_Of_ED';                                   
                    }  
                }
            }
                    
            if(String.isNotBlank(metric_Query_Condition)){
                metric_Query_Str += ' WHERE '+ metric_Query_Condition;
            }
                
            List<Metric__c> metrics = Database.Query(metric_Query_Str);
            
            if(metrics.size() > 0){
                                
                List<Goals_Metrics_Mapping__c> goalAndMetricMappingRecs = new List<Goals_Metrics_Mapping__c>();
                Map<String, Goals_Metrics_Mapping__c> goalNameAndMapping = new Map<String, Goals_Metrics_Mapping__c>();
                
                List<Opportunity> opportunities = new List<Opportunity>();
                List<Opportunity> opps_Inquiries = new List<Opportunity>();
                List<Opportunity> opps_Enrollments = new List<Opportunity>();
                List<Metric__c> updateMetricRecs = new List<Metric__c>(); 
                
                Decimal closureRate_PY;
                
                if(!goalName.contains('Closure Rate per QTR') && !goalName.contains('Closure Rate per Year')){
                    
                    goalAndMetricMappingRecs = [SELECT Id, Name, Goal_Name__c, Account__c, Account_Condition__c, QB_Classification__c, QB_Classification_Condition__c, 
                                                    Opportunity_Record_Type__c, Opportunity_Record_Type_Condition__c, Stage_Name__c, Stage_Name_Condition__c
                                                FROM Goals_Metrics_Mapping__c
                                                WHERE Goal_Name__c = : goalName];
                                                
                    goalNameAndMapping.put(goalAndMetricMappingRecs[0].Goal_Name__c, goalAndMetricMappingRecs[0]);
                    opportunities = Goal_Metric_Util.getOpportunityRecs(goalAndMetricMappingRecs[0], metricRec_Id, metrics, goalName, startDate_Val, endDate_Val, goals[0]);
                }
                
                if(goalName.contains('Closure Rate per QTR')){
                    
                    Set<String> goalNames_Set = new Set<String>{'Registrar # of Inquiries', 'Registrar # of Enrollments'};
                    
                    goalAndMetricMappingRecs = [SELECT Id, Name, Goal_Name__c, Account__c, Account_Condition__c, QB_Classification__c, QB_Classification_Condition__c, 
                                                    Opportunity_Record_Type__c, Opportunity_Record_Type_Condition__c, Stage_Name__c, Stage_Name_Condition__c
                                                FROM Goals_Metrics_Mapping__c
                                                WHERE Goal_Name__c IN : goalNames_Set];
                    
                    for(Goals_Metrics_Mapping__c gm_map : goalAndMetricMappingRecs){
                        goalNameAndMapping.put(gm_map.Goal_Name__c, gm_map);
                    }
                    
                    opps_Inquiries = Goal_Metric_Util.getOpportunityRecs(goalNameAndMapping.get('Registrar # of Inquiries'), metricRec_Id, metrics, goalName, startDate_Val, endDate_Val, goals[0]);
                    opps_Enrollments = Goal_Metric_Util.getOpportunityRecs(goalNameAndMapping.get('Registrar # of Enrollments'), metricRec_Id, metrics, goalName, startDate_Val, endDate_Val, goals[0]);
                }  
                  
                if(goalName.contains('Closure Rate per Year')){
                    
                    List<Metric__c> quarterMetrics = [SELECT Id, Name, Current_Value__c, Start_Date__C, Due_Date__c 
                        FROM Metric__c 
                        WHERE Goal__r.Name LIKE '%Closure Rate per QTR%' AND 
                            Goal__r.Start_Date__c = :goals[0].Start_Date__c AND Goal__r.Due_Date__c = :goals[0].Due_Date__c];
                    
                    if(quarterMetrics.size() > 0){
                        
                        Decimal quarter_Val = 0;
                        Integer record_Count = 0;
                        
                        for(Metric__c m : quarterMetrics){
                            
                            if(m.Current_Value__c > 0){
                                
                                quarter_Val += m.Current_Value__c;
                                record_Count += 1;
                            }
                        }
                        if(quarter_Val > 0 && record_Count > 0){
                            closureRate_PY = quarter_Val / record_Count;
                        }
                    }
                }  
                            
                for(Metric__c m : metrics){
                    
                    Decimal final_Val;
                    
                    if(m.Name.contains('# of Inquiries') || m.Name.contains('# of Enrollments')){
                       
                        final_Val = Goal_Metric_Util.count_Of_Inquiries_Enrollments(opportunities, goalNameAndMapping.get(goalName), m.Start_Date__c, m.Due_Date__c);   
                    }
                    if(m.Name.contains('Value of Inquiries') || m.Name.contains('Value of Enrollments')){
                       
                        final_Val = Goal_Metric_Util.value_Of_Inquiries_Enrollments(opportunities, goalNameAndMapping.get(goalName), m.Start_Date__c, m.Due_Date__c);   
                    }
                    if(m.Name.contains('Avg Hourly Rate of Enrollments')){
                    
                        final_Val = Goal_Metric_Util.avg_HourlyRate_Of_Enrollments(opportunities, goalNameAndMapping.get(goalName), m.Start_Date__c, m.Due_Date__c);   
                    }
                    if(m.Name.contains('Closure Rate - Q')){
                        
                        String quarter = m.Name.split('- ')[1].left(2);
                        Decimal inquiries_Count;
                        Decimal enrollments_Count;
                        
                        Date goal_Date = goals[0].Start_Date__c;
                        Date from_date_Inq;
                        Date to_date_Inq;
                        
                        Date from_date_Enr;
                        Date to_date_Enr;
                        
                        if(quarter.contains('Q1')){
                        
                            from_date_Inq = Date.newinstance(goal_Date.year()-1, 10, 1);
                            to_date_Inq = Date.newinstance(goal_Date.year()-1, 12, 31);
                            
                            from_date_Enr = Date.newinstance(goal_Date.year(), 1, 1);
                            to_date_Enr = Date.newinstance(goal_Date.year(), 3, 31);
                            
                            inquiries_Count = Goal_Metric_Util.count_Of_Inquiries_Enrollments(opps_Inquiries, goalNameAndMapping.get('Registrar # of Inquiries'), from_date_Inq, to_date_Inq);   
                            enrollments_Count = Goal_Metric_Util.count_Of_Inquiries_Enrollments(opps_Enrollments, goalNameAndMapping.get('Registrar # of Enrollments'), from_date_Enr, to_date_Enr);                               
                        }
                        if(quarter.contains('Q2')){
                        
                            from_date_Inq = Date.newinstance(goal_Date.year(), 1, 1);
                            to_date_Inq = Date.newinstance(goal_Date.year(), 3, 31);
                            
                            from_date_Enr = Date.newinstance(goal_Date.year(), 4, 1);
                            to_date_Enr = Date.newinstance(goal_Date.year(), 6, 30);
                            
                            inquiries_Count = Goal_Metric_Util.count_Of_Inquiries_Enrollments(opps_Inquiries, goalNameAndMapping.get('Registrar # of Inquiries'), from_date_Inq, to_date_Inq);   
                            enrollments_Count = Goal_Metric_Util.count_Of_Inquiries_Enrollments(opps_Enrollments, goalNameAndMapping.get('Registrar # of Enrollments'), from_date_Enr, to_date_Enr);   
                        }
                        if(quarter.contains('Q3')){
                        
                            from_date_Inq = Date.newinstance(goal_Date.year(), 4, 1);
                            to_date_Inq = Date.newinstance(goal_Date.year(), 6, 30);
                            
                            from_date_Enr = Date.newinstance(goal_Date.year(), 7, 1);
                            to_date_Enr = Date.newinstance(goal_Date.year(), 9, 30);
                            
                            inquiries_Count = Goal_Metric_Util.count_Of_Inquiries_Enrollments(opps_Inquiries, goalNameAndMapping.get('Registrar # of Inquiries'), from_date_Inq, to_date_Inq);   
                            enrollments_Count = Goal_Metric_Util.count_Of_Inquiries_Enrollments(opps_Enrollments, goalNameAndMapping.get('Registrar # of Enrollments'), from_date_Enr, to_date_Enr);   
                        }
                        if(quarter.contains('Q4')){
                        
                            from_date_Inq = Date.newinstance(goal_Date.year(), 7, 1);
                            to_date_Inq = Date.newinstance(goal_Date.year(), 9, 30);
                            
                            from_date_Enr = Date.newinstance(goal_Date.year(), 10, 1);
                            to_date_Enr = Date.newinstance(goal_Date.year(), 12, 31);
                            
                            inquiries_Count = Goal_Metric_Util.count_Of_Inquiries_Enrollments(opps_Inquiries, goalNameAndMapping.get('Registrar # of Inquiries'), from_date_Inq, to_date_Inq);   
                            enrollments_Count = Goal_Metric_Util.count_Of_Inquiries_Enrollments(opps_Enrollments, goalNameAndMapping.get('Registrar # of Enrollments'), from_date_Enr, to_date_Enr);   
                        }
                        
                        if(inquiries_Count > 0 && enrollments_Count > 0){
                        
                            final_Val = (enrollments_Count / inquiries_Count * 100).setScale(2);
                            final_Val = final_Val.round();
                        }
                    }
                    if(goalName.contains('Closure Rate per Year')){
                        
                        final_Val = closureRate_PY;
                    }
                    
                    if(final_Val != null){
                        m.Current_Value__c = final_Val;            
                    }else{
                        m.Current_Value__c = 0;  
                    }
                    updateMetricRecs.add(m);
                }
                
                System.debug(':::updateMetricRecs::'+updateMetricRecs);
                if(updateMetricRecs.size() > 0){
                    update updateMetricRecs;
                }    
            }
        }
    }
    
    public void finish(Database.BatchableContext bC){
        
    }
}