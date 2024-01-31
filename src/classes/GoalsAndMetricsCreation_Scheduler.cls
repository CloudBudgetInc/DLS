/*****************
    - Created By HL on Jan 10 2022
    - To create custom Goals and Metrics records
    - This scheduler runs starting day of every year - changed to December 1st on every year for next year record creation done by NS on NOV 30 2023
    - Work Item: W-007098 - 2022 YTD Actual vs Proforma Budget Report
    **************/
global class GoalsAndMetricsCreation_Scheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
    
        // Modified on Nov 30 2023
        // To get currect year goals
        Integer lastYear = Date.today().year();    
        Date startDate_LastYear = Date.newinstance(lastYear, 01, 01);
        Date endDate_LastYear = Date.newinstance(lastYear, 12, 31);

        List<Goal__c> old_Goals = [SELECT Id, Name, Start_Date__c, Description__c, Due_Date__c, Sequence_No__c, Service_Business_Unit__c, 
                                        Status__c, RecordTypeId
                                    FROM Goal__c
                                    WHERE Start_Date__c = :startDate_LastYear AND Due_Date__c = :endDate_LastYear];
        if(old_Goals.size() > 0){
        
            Map<String, Goal__c> oldGoalNameAndNewGoal = new Map<String, Goal__c>();
            
            String lastYear_Str = String.valueOf(lastYear); 
            // To create goals for next year           
            Integer currentYear = Date.today().year()+1;
            String currentYear_Str = String.valueOf(currentYear);

            for(Goal__c oldG : old_Goals){
                
                Goal__c newG = new Goal__c();
                
                String oldGoalName = oldG.Name;
                if(oldGoalName.contains(lastYear_Str)){
                    newG.Name = oldGoalName.replace(lastYear_Str, currentYear_Str);
                }else{
                    newG.Name = oldG.Name;
                }
                newG.RecordTypeId = oldG.RecordTypeId; 
                newG.Start_Date__c = oldG.Start_Date__c.addYears(1); 
                newG.Description__c = oldG.Description__c;
                newG.Due_Date__c = oldG.Due_Date__c.addYears(1);
                newG.Status__c = oldG.Status__c;
                newG.Sequence_No__c = oldG.Sequence_No__c;
                newG.Service_Business_Unit__c = oldG.Service_Business_Unit__c;
                
                oldGoalNameAndNewGoal.put(oldG.Name, newG);
            }    
            
            if(oldGoalNameAndNewGoal != NULL && oldGoalNameAndNewGoal.size() > 0){
                insert oldGoalNameAndNewGoal.values();
            }
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType objSchema = schemaMap.get('Metric__c');
            Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
            
            Map<String, String> fieldLabelAndAPIName = new Map<String, String>();
            List<sObject> metricRecs = new List<sObject>();
            String dynamic_Fields = '';
            
            for (String fieldName: fieldMap.keySet()){
                
                String field_Label = fieldMap.get(fieldName).getDescribe().getLabel();
                String year_Str = field_Label.left(4);
                
                if(year_Str.isNumeric()){
                
                    fieldLabelAndAPIName.put(fieldMap.get(fieldName).getDescribe().getLabel(), fieldName);
                    dynamic_Fields += ', ';
                    dynamic_Fields += fieldName;
                }
            }
            
            String metric_query = 'SELECT Id, Name, RecordTypeId, Budget_Value__c, Comment__c, Current_Value__c';
            metric_query += ', Due_Date__c, Goal__c, Goal__r.Name, Metric_Type__c, Sequence_No__c, Start_Date__c, Target_Value__c';
            metric_query += dynamic_Fields;
            metric_query += ' FROM Metric__c';
            metric_query += ' WHERE Goal__c IN : old_Goals AND Metric_Type__c IN (\'Hours\', \'Sales - Inquiries\', \'Sales - Enrollments\', \'Price\')';
            
            List<Metric__c> oldMetrics = Database.Query(metric_query);
            
            if(oldMetrics.size() > 0){
                            
                for(Metric__c oldM : oldMetrics){
                
                    Metric__c newM = new Metric__c();
                    
                    String oldMetricName = oldM.Name;
                    if(oldMetricName.contains(lastYear_Str)){
                        newM.Name = oldMetricName.replace(lastYear_Str, currentYear_Str);
                    }else{
                        newM.Name = oldM.Name;
                    }
                    newM.RecordTypeId = oldM.RecordTypeId;
                    if(oldGoalNameAndNewGoal.containsKey(oldM.Goal__r.Name)){
                        newM.Goal__c = oldGoalNameAndNewGoal.get(oldM.Goal__r.Name).Id;
                    }
                    newM.Start_Date__c = oldM.Start_Date__c.addYears(1);
                    newM.Due_Date__c = oldM.Due_Date__c.addYears(1);
                    newM.Target_Value__c = oldM.Target_Value__c;
                    newM.Comment__c = oldM.Comment__c;
                    newM.Sequence_No__c = oldM.Sequence_No__c;
                    newM.Budget_Value__c = oldM.Budget_Value__c;
                    newM.Metric_Type__c = oldM.Metric_Type__c;
                    
                    sObject sobjRec_newRec = newM;
                    sObject sobjRec_OldRec = oldM;
                    
                    for(String label : fieldLabelAndAPIName.keyset()){
                        
                        String fieldAPIName = fieldLabelAndAPIName.get(label);
                        String year_Str = label.left(4);
                        
                        if(year_Str == String.valueOf(lastYear)){
                            sobjRec_newRec.put(fieldAPIName, sobjRec_OldRec.get('Current_Value__c'));
                        }else{
                            sobjRec_newRec.put(fieldAPIName, sobjRec_OldRec.get(fieldAPIName));
                        }
                    }
                    metricRecs.add(sobjRec_newRec);
                }
                
                if(metricRecs != NULL && metricRecs.size() > 0){
                    insert metricRecs;
                }
            }
        }
    }
}