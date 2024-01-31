public class Goal_Metric_Util{
    
    /********
        - Work Item: W-007098 - 2022 YTD Actual vs Proforma Budget Report
        - This method is invoked from PopulateCurrentValueInMetrics_Scheduler as well as "Refresh" quick action
        ***********/
    public static Decimal getGoalNameAndTotalHours(List<AcctSeed__Time_Card_Day__c> days, Goals_Metrics_Mapping__c mappingRec, Metric__c metricRec, Date startDateVal, Date endDateVal){
        
        // Total hours value for corresponding metric record
        Decimal totalHours;
        
        Map<String, Decimal> goalNameAndTotalHours = new Map<String, Decimal>();
        List<String> accountNames = new List<String>();
        List<String> classifications = new List<String>();
        List<String> caPositions = new List<String>();
        List<String> projectRTs = new List<String>();
        List<String> gLAV2_Values = new List<String>();
        
        // Account values from custom setting
        if(mappingRec.Account__c != null){
            accountNames = mappingRec.Account__c.split(',');
        }
        
        // Classification values from custom setting
        if(mappingRec.QB_Classification__c != null){
            classifications = mappingRec.QB_Classification__c.split(',');
        }
        
        // Contact Assignment position values from custom setting
        if(mappingRec.Contact_Assignment_Position__c != null){
            caPositions = mappingRec.Contact_Assignment_Position__c.split(',');
        }
        
        // Project Recordtype values from custom setting
        if(mappingRec.Project_Record_Type__c != null){
            projectRTs = mappingRec.Project_Record_Type__c.split(',');
        }
        
        // GLAV2 values from custom setting
        if(mappingRec.GLAV2__c != null){
            gLAV2_Values = mappingRec.GLAV2__c.split(',');
        }
        
        for(AcctSeed__Time_Card_Day__c tcd : days){
            
            // TCD date should within the given date range
            if(tcd.AcctSeed__Date__c >= metricRec.Start_Date__c && tcd.AcctSeed__Date__c <= metricRec.Due_Date__c){
                
                // Check Classification values if its condition and values not null in custom setting
                if((mappingRec.QB_Classification__c != null && mappingRec.QB_Classification_Condition__c != null && 
                    ((mappingRec.QB_Classification_Condition__c == 'IN' && classifications.contains(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.QB_Classification__c)) ||
                    (mappingRec.QB_Classification_Condition__c == 'NOT IN' && !classifications.contains(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.QB_Classification__c)))) ||
                    (mappingRec.QB_Classification__c == null && mappingRec.QB_Classification_Condition__c == null)){
                    
                    // Check Contact Assignment position values if its condition and values not null in custom setting
                    if((mappingRec.Contact_Assignment_Position__c != null && mappingRec.Contact_Assignment_Position_Condition__c != null && 
                        mappingRec.Contact_Assignment_Position_Condition__c == 'IN' && caPositions.contains(tcd.AcctSeed__Time_Card_Line__r.Contact_Assignment__r.Assignment_Position__c)) ||
                        (mappingRec.Contact_Assignment_Position__c == null && mappingRec.Contact_Assignment_Position_Condition__c == null)){
                        
                        // Check Project Recordtype values if its condition and values not null in custom setting
                        if((mappingRec.Project_Record_Type__c != null && mappingRec.Project_Record_Type_Condition__c != null && 
                            mappingRec.Project_Record_Type_Condition__c == 'IN' && projectRTs.contains(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Project_Record_Type_Name__c)) ||
                            (mappingRec.Project_Record_Type__c == null && mappingRec.Project_Record_Type_Condition__c == null)){
                            
                            // Check GLAV2 values if its condition and values not null in custom setting
                            if((mappingRec.GLAV2__c != null && mappingRec.GLAV2_Condition__c != null && 
                                mappingRec.GLAV2_Condition__c == 'EQUALS' && gLAV2_Values.contains(tcd.GL_Variable_2__r.Name)) ||
                                (mappingRec.GLAV2__c == null && mappingRec.GLAV2_Condition__c == null)){
                               
                                // Check Account values if its condition and values not null in custom setting
                                if(mappingRec.Account__c != null && mappingRec.Account_Condition__c != null &&
                                    mappingRec.Account_Condition__c == 'NOT CONTAINS'){
                                    
                                    // Account name should not contain the values in custom setting
                                    Boolean isContain = False;
                                    for(String accName : accountNames){                                    
                                        if(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.AcctSeed__Account__r.Name.contains(accName)){
                                            isContain = True;
                                            break;   
                                        }
                                    }
                                    
                                    if(!isContain){
                                        
                                        if(!mappingRec.Goal_Name__c.contains('- Testing') && !mappingRec.Goal_Name__c.contains('- TST')){
                                        
                                            // For non testing goals, we are considering sum of tcd record's Total_Hours_Before_Approved__c field value
                                            if(!goalNameAndTotalHours.containsKey(mappingRec.Goal_Name__c)){
                                                goalNameAndTotalHours.put(mappingRec.Goal_Name__c, 0); 
                                            }    
                                            goalNameAndTotalHours.put(mappingRec.Goal_Name__c, goalNameAndTotalHours.get(mappingRec.Goal_Name__c)+tcd.Total_Hours_Before_Approved__c); 
                                        }else{
                                        
                                            // For testing goals, we are considering sum of tcd record's count
                                            if(!goalNameAndTotalHours.containsKey(mappingRec.Goal_Name__c)){
                                                goalNameAndTotalHours.put(mappingRec.Goal_Name__c, 0); 
                                            }    
                                            goalNameAndTotalHours.put(mappingRec.Goal_Name__c, goalNameAndTotalHours.get(mappingRec.Goal_Name__c)+1); 
                                        }
                                    }
                                }     
                                        
                                // Check Account values if its condition and values not null in custom setting               
                                if((mappingRec.Account__c != null && mappingRec.Account_Condition__c != null && 
                                    ((mappingRec.Account_Condition__c == 'EQUALS' && accountNames.contains(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.AcctSeed__Account__r.Name)) ||
                                    (mappingRec.Account_Condition__c == 'NOT EQUALS' && !accountNames.contains(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.AcctSeed__Account__r.Name)))) ||
                                    (mappingRec.Account__c == null && mappingRec.Account_Condition__c == null)){
                                    
                                    if(!mappingRec.Goal_Name__c.contains('- Testing') && !mappingRec.Goal_Name__c.contains('- TST')){
                                    
                                        // For non testing goals, we are considering sum of tcd record's Total_Hours_Before_Approved__c field value
                                        if(!goalNameAndTotalHours.containsKey(mappingRec.Goal_Name__c)){
                                            goalNameAndTotalHours.put(mappingRec.Goal_Name__c, 0); 
                                        }    
                                        goalNameAndTotalHours.put(mappingRec.Goal_Name__c, goalNameAndTotalHours.get(mappingRec.Goal_Name__c)+tcd.Total_Hours_Before_Approved__c); 
                                    }else{
                                    
                                        // For testing goals, we are considering sum of tcd record's count
                                        if(!goalNameAndTotalHours.containsKey(mappingRec.Goal_Name__c)){
                                            goalNameAndTotalHours.put(mappingRec.Goal_Name__c, 0); 
                                        }    
                                        goalNameAndTotalHours.put(mappingRec.Goal_Name__c, goalNameAndTotalHours.get(mappingRec.Goal_Name__c)+1); 
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        System.debug(':::goalNameAndTotalHours::'+goalNameAndTotalHours);
        totalHours = goalNameAndTotalHours.get(mappingRec.Goal_Name__c);
        return totalHours;
    }
    
    //Method to initiate the metric refresh process from metric record page quick action "Refresh"
    // Added by NS on Feb 7 2022
    @AuraEnabled
    public static void refreshMetric(Id metricId,Date startDate,Date endDate){
        
        if(metricId != null) {
            
            List<Metric__c> metricRec = [SELECT Id, Goal__c, Goal__r.Name FROM Metric__c WHERE Id = :metricId];
            
            if(metricRec[0].Goal__r.Name.contains('Registrar')){
            
                // For Marketing related goals & metrics process
                PopulateCurrentValueInMarketingMetrics updateMarketingMetricRec = new PopulateCurrentValueInMarketingMetrics(metricRec[0].Goal__c, metricId, null, null);
                Database.ExecuteBatch(updateMarketingMetricRec, 1);
            }else{
            
                // For Proforma Actual related goals & metrics process
                PopulateCurrentValueInMetrics_Batch updateMetricRec = new PopulateCurrentValueInMetrics_Batch(metricRec[0].Goal__c, metricId, null, null);
                Database.ExecuteBatch(updateMetricRec, 1);
            }
            
        }else if(metricId == null && startDate != null && endDate != null) {
        
            PopulateCurrentValueInMetrics_Batch updateMetricRec = new PopulateCurrentValueInMetrics_Batch(null, null, startDate, endDate);
            Database.ExecuteBatch(updateMetricRec, 1);
            
            PopulateCurrentValueInMarketingMetrics updateMarketingMetricRec = new PopulateCurrentValueInMarketingMetrics(null, null, startDate, endDate);
            Database.ExecuteBatch(updateMarketingMetricRec, 1);
        }
    } 
    
    // To filter opportunity records based on goal and metric mapping record's condition and input date range
    public static List<Opportunity> get_FilteredOpportunities(List<Opportunity> opportunities, Goals_Metrics_Mapping__c mappingRec, Date metric_StartDate, Date metric_EndDate){
        
        List<Opportunity> filteredOpportunities = new List<Opportunity>();
        List<String> accountNames = new List<String>();
        List<String> classifications = new List<String>();
        List<String> stageName = new List<String>();
        List<String> opportunityRTs = new List<String>();
        
        if(mappingRec.Account__c != null){
            accountNames = mappingRec.Account__c.split(',');
        }
        
        if(mappingRec.QB_Classification__c != null){
            classifications = mappingRec.QB_Classification__c.split(',');
        }
        
        if(mappingRec.Stage_Name__c != null){
            stageName = mappingRec.Stage_Name__c.split(',');
        }
        
        if(mappingRec.Opportunity_Record_Type__c != null){
            opportunityRTs = mappingRec.Opportunity_Record_Type__c.split(',');
        }
        
        for(Opportunity opp : opportunities){
            
            Date opp_CreatedDate = Date.newinstance(opp.CreatedDate.year(), opp.CreatedDate.month(), opp.CreatedDate.day());
       
            if((mappingRec.Goal_Name__c.contains('Inquiries') && opp_CreatedDate >= metric_StartDate && opp_CreatedDate <= metric_EndDate) || 
                (mappingRec.Goal_Name__c.contains('Enrollments') && opp.Enrollment_Date__c >= metric_StartDate && opp.Enrollment_Date__c <= metric_EndDate)){
                            
                if((mappingRec.Opportunity_Record_Type__c != null && mappingRec.Opportunity_Record_Type_Condition__c != null && 
                    mappingRec.Opportunity_Record_Type_Condition__c == 'IN' && opportunityRTs.contains(opp.RecordType.DeveloperName)) ||
                    (mappingRec.Opportunity_Record_Type__c == null && mappingRec.Opportunity_Record_Type_Condition__c == null)){
                                                
                    if((mappingRec.QB_Classification__c != null && mappingRec.QB_Classification_Condition__c != null && 
                        ((mappingRec.QB_Classification_Condition__c == 'IN' && classifications.contains(opp.Classification__c)) ||
                        (mappingRec.QB_Classification_Condition__c == 'NOT IN' && !classifications.contains(opp.Classification__c)))) ||
                        (mappingRec.QB_Classification__c == null && mappingRec.QB_Classification_Condition__c == null)){
                                        
                        if((mappingRec.Stage_Name__c != null && mappingRec.Stage_Name_Condition__c != null && 
                            mappingRec.Stage_Name_Condition__c == 'IN' && stageName.contains(opp.StageName)) ||
                            (mappingRec.Stage_Name__c == null && mappingRec.Stage_Name_Condition__c == null)){
                                                    
                            if((mappingRec.Account__c != null && mappingRec.Account_Condition__c != null && 
                                ((mappingRec.Account_Condition__c == 'EQUALS' && accountNames.contains(opp.Account.Name)) ||
                                (mappingRec.Account_Condition__c == 'NOT EQUALS' && !accountNames.contains(opp.Account.Name)))) ||
                                (mappingRec.Account__c == null && mappingRec.Account_Condition__c == null)){
                                                                
                                filteredOpportunities.add(opp);
                            }
                        }
                    }
                }
            }
        }
        return filteredOpportunities;
    }
    
    // To calculate "# of Inquiries" and "# of Enrollments" value for "Registrar # of Inquiries" and "Registrar # of Enrollments" goals related metrics
    public static Decimal count_Of_Inquiries_Enrollments(List<Opportunity> all_Opportunities, Goals_Metrics_Mapping__c mappingRec, Date metric_StartDate, Date metric_EndDate){
                
        List<Opportunity> filteredOpportunities = get_FilteredOpportunities(all_Opportunities, mappingRec, metric_StartDate, metric_EndDate);
        
        Decimal total_Opp_Count;
        Map<String, Decimal> goalNameAndOppCount = new Map<String, Decimal>();
        
        if(filteredOpportunities != null && filteredOpportunities.size() > 0){
        
            for(Opportunity opp : filteredOpportunities){
                
                if(!goalNameAndOppCount.containsKey(mappingRec.Goal_Name__c)){
                    goalNameAndOppCount.put(mappingRec.Goal_Name__c, 0); 
                }    
                goalNameAndOppCount.put(mappingRec.Goal_Name__c, goalNameAndOppCount.get(mappingRec.Goal_Name__c)+1); 
            }    
        }
        
        total_Opp_Count = (goalNameAndOppCount.containsKey(mappingRec.Goal_Name__c) ? goalNameAndOppCount.get(mappingRec.Goal_Name__c) : null);
        return total_Opp_Count;
    }
    
    // To calculate "Value of Inquiries" and "Value of Enrollments" value for "Registrar Value of Inquiries" and "Registrar Value of Enrollments" goals related metrics
    public static Decimal value_Of_Inquiries_Enrollments(List<Opportunity> all_Opportunities, Goals_Metrics_Mapping__c mappingRec, Date metric_StartDate, Date metric_EndDate){
                        
        List<Opportunity> filteredOpportunities = get_FilteredOpportunities(all_Opportunities, mappingRec, metric_StartDate, metric_EndDate);
        
        Decimal total_Opp_Value;
        Map<String, Decimal> goalNameAndOppValue = new Map<String, Decimal>();
        
        if(filteredOpportunities != null && filteredOpportunities.size() > 0){
        
            for(Opportunity opp : filteredOpportunities){
                
                if(!goalNameAndOppValue.containsKey(mappingRec.Goal_Name__c)){
                    goalNameAndOppValue.put(mappingRec.Goal_Name__c, 0); 
                }    
                goalNameAndOppValue.put(mappingRec.Goal_Name__c, goalNameAndOppValue.get(mappingRec.Goal_Name__c)+opp.Total_LT_Revenue__c); 
            }    
        }
        
        total_Opp_Value = (goalNameAndOppValue.containsKey(mappingRec.Goal_Name__c) ? goalNameAndOppValue.get(mappingRec.Goal_Name__c) : null);
        return total_Opp_Value;
    }
    
    // To calculate "Avg Hourly Rate of Enrollments" value for "Registrar Avg Hourly Rate of Enrollments" goal related metrics
    public static Decimal avg_HourlyRate_Of_Enrollments(List<Opportunity> all_Opportunities, Goals_Metrics_Mapping__c mappingRec, Date metric_StartDate, Date metric_EndDate){
                
        List<Opportunity> filteredOpportunities = get_FilteredOpportunities(all_Opportunities, mappingRec, metric_StartDate, metric_EndDate);
        
        Decimal total_Opp_Avg_HourlyRate;
        Map<String, Decimal> goalNameAndOppAvgHR = new Map<String, Decimal>();
        
        if(filteredOpportunities != null && filteredOpportunities.size() > 0){
        
            Decimal hourly_Rate_Val = 0;
            Integer record_Count = 0;
            Decimal avg_HR_Val = 0;
            
            for(Opportunity opp : filteredOpportunities){
                
                if(opp.Hourly_Rate__c > 0){
                    
                    hourly_Rate_Val += opp.Hourly_Rate__c;
                    record_Count += 1;
                }
            }    
            
            if(hourly_Rate_Val > 0 && record_Count > 0){
                avg_HR_Val = (hourly_Rate_Val / record_Count).setscale(2);
            }
            
            goalNameAndOppAvgHR.put(mappingRec.Goal_Name__c, avg_HR_Val); 
        }
        
        total_Opp_Avg_HourlyRate = (goalNameAndOppAvgHR.containsKey(mappingRec.Goal_Name__c) ? goalNameAndOppAvgHR.get(mappingRec.Goal_Name__c) : null);
        return total_Opp_Avg_HourlyRate;
    }  
    
    // To query opportunity records based on goal and metric mapping record's condition and input date range
    public static List<Opportunity> getOpportunityRecs(Goals_Metrics_Mapping__c goalAndMetricMappingRecs, Id metricRec_Id, List<Metric__c> metrics, String goalName, Date startDate_Val, Date endDate_Val, Goal__c goal_Rec){
    
        Date endDate_Of_LastMonth = Date.today().toStartOfMonth()-1;
        Date startDate_Of_LastMonth = endDate_Of_LastMonth.toStartOfMonth();
    
        List<Opportunity> opportunities = new List<Opportunity>();
                
        Goals_Metrics_Mapping__c mappingRec = goalAndMetricMappingRecs;
                    
        String condition = '';  
        Boolean accCond = False;
        Boolean classificationCond = False;
        Boolean stageCond = False;
                    
        if(mappingRec.Account__c != null && mappingRec.Account_Condition__c != null){
            
            accCond = True;
            condition += ' AccountId != null';
        }
        // Null value records are excluded due to this condition, so commented it
        /*
        if(mappingRec.QB_Classification__c != null && mappingRec.QB_Classification_Condition__c != null){
                
            if(accCond){
                condition += ' AND';
            }
            classificationCond = True;
            condition += ' Classification__c != null';
        }
        */
        if(mappingRec.Stage_Name__c != null && mappingRec.Stage_Name_Condition__c != null){
            
            if(accCond || classificationCond){
                condition += ' AND';
            }
            stageCond = True;
            condition += ' StageName != null';
        }
                    
        if(accCond || classificationCond || stageCond){
            
            if(metricRec_Id != null && metrics != null && metrics.size() > 0){
                
                Date metric_SD = metrics[0].Start_Date__c;
                Date metric_ED = metrics[0].Due_Date__c; 
                
                if(!goalName.contains('Closure Rate per QTR') && !goalName.contains('Closure Rate per Year')){
                                
                    // Quarter and Year based Goals dosn't have separate mapping record, so here we are considering mapping record's goal name instead of actual record's goal name
                    // For Inquiries we are considering CreatedDate 
                    if(mappingRec.Goal_Name__c.contains('Inquiries')){
                    
                        // addDays(1) condition added to fixed CreatedDate(Time) related issue. Because CreatedDate is a datetime field so it dosn't consider (queried) few actual (Opportunity) records
                        Date metric_ED_temp = (metrics[0].Due_Date__c).addDays(1); 
                    
                        condition += ' AND CreatedDate >= : metric_SD AND CreatedDate <= : metric_ED_temp';
                    } 
                    
                    // For Enrollemts we are considering Award date
                    if(mappingRec.Goal_Name__c.contains('Enrollments')){
                        condition += ' AND Enrollment_Date__c >= : metric_SD AND Enrollment_Date__c <= : metric_ED';
                    }
                }
                if(goalName.contains('Closure Rate per QTR')){
                    
                    Date goal_Date_Val = goal_Rec.Start_Date__c;
                    Date from_DateRange = Date.newinstance(goal_Date_Val.year()-1, 10, 1);
                    Date to_DateRange = goal_Rec.Due_Date__c;
                    
                    if(mappingRec.Goal_Name__c.contains('Inquiries')){
                        
                        // addDays(1) condition added to fixed CreatedDate(Time) related issue. Because CreatedDate is a datetime field so it dosn't consider (queried) few actual (Opportunity) records
                        Date to_DateRange_temp = to_DateRange.addDays(1);
                        
                        condition += ' AND CreatedDate >= : from_DateRange AND CreatedDate <= : to_DateRange_temp';
                    }
                    
                    if(mappingRec.Goal_Name__c.contains('Enrollments')){
                        condition += ' AND Enrollment_Date__c >= : from_DateRange AND Enrollment_Date__c <= : to_DateRange';
                    }
                }
                if(goalName.contains('Closure Rate per Year')){
                    // Nothing to do here, because it is depends on "Closure Rate per QTR" goal related metrics's current value
                }
                
            }else if(metricRec_Id == null){
                
                if(!goalName.contains('Closure Rate per QTR') && !goalName.contains('Closure Rate per Year')){
                    
                    // Logic for Scheduler
                    if(startDate_Val == null && endDate_Val == null){
                        
                        if(mappingRec.Goal_Name__c.contains('Inquiries')){
                        
                            Date endDate_Of_LastMonth_temp = endDate_Of_LastMonth.addDays(1);
                            condition += ' AND CreatedDate >= :startDate_Of_LastMonth AND CreatedDate <= :endDate_Of_LastMonth_temp';
                        }
                        
                        if(mappingRec.Goal_Name__c.contains('Enrollments')){
                            
                            condition += ' AND Enrollment_Date__c >= :startDate_Of_LastMonth AND Enrollment_Date__c <= :endDate_Of_LastMonth';
                        }
                    }
                    
                    // Logic for Global Action
                    if(startDate_Val != null && endDate_Val != null){
                    
                        Date from_Date = startDate_Val.toStartOfMonth();
                        Date to_Date;
                        Integer numberOfDays = Date.daysInMonth(endDate_Val.year(), endDate_Val.month());
                        Date lastDay_Of_ED = Date.newInstance(endDate_Val.year(), endDate_Val.month(), numberOfDays);
                        
                        if(lastDay_Of_ED > Date.Today()){
                            to_Date = endDate_Val; 
                        }else{
                            to_Date = lastDay_Of_ED; 
                        }
                        
                        if(mappingRec.Goal_Name__c.contains('Inquiries')){
                        
                            Date to_Date_temp = to_Date.addDays(1);
                            condition += ' AND CreatedDate >= :from_Date AND CreatedDate <= :to_Date_temp';
                        }
                        
                        if(mappingRec.Goal_Name__c.contains('Enrollments')){
                            
                            condition += ' AND Enrollment_Date__c >= :from_Date AND Enrollment_Date__c <= :to_Date';
                        }
                    }
                }
            } 
        }
        String opp_Str = 'SELECT Id, Name, AccountId, Account.Name, Classification__c, StageName, RecordType.DeveloperName, Enrollment_Date__c, CreatedDate, Total_LT_Revenue__c, Hourly_Rate__c';     
        opp_Str += ' FROM Opportunity';
        opp_Str += ' WHERE '+ condition;
        
        System.debug('::opp_Str:::'+opp_Str);     
        
        opportunities = Database.Query(opp_Str);
        
        return opportunities;
    }
}