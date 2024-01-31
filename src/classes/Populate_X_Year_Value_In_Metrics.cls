/*********
    - W-007946 : Change Goals & Metrics for Next Year from January to December
    - To populate year based field (2017,2018,2019,2020,2021,2022,2021) value in current year metrics from the current value of last year metrics
    - This scheduler runs January 15'th of every year
    - Overall Goals : 53
        1. Normal Goals: 46
            - Proforma Actual GLAV : 14
            - Proforma Actual - (Location) : 20
            - Proforma Sales - (Location) : 12
        2. Marketing Goals: 7
            - Registrar : 7
    *****************/
    
public class Populate_X_Year_Value_In_Metrics implements Database.Batchable<SObject>, Schedulable, Database.Stateful{
            
    public static Integer currentYear = Date.today().year();    
    public static Date startDate_CY = Date.newinstance(currentYear, 01, 01);
    public static Date endDate_CY = Date.newinstance(currentYear, 12, 31); 
    public static String currentYear_Str = String.valueOf(currentYear);
        
    public void execute(SchedulableContext sc){
        Populate_X_Year_Value_In_Metrics updateMetric = new Populate_X_Year_Value_In_Metrics();
        Database.executeBatch(updateMetric, 1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){  
    
        String goalQryStr = 'SELECT Id, Name, Start_Date__c, Due_Date__c FROM Goal__c WHERE Start_Date__c = : startDate_CY AND Due_Date__c = : endDate_CY';
        
        if(Test.isRunningTest()){
            goalQryStr += ' LIMIT 1';
        }         
        return Database.getQueryLocator(goalQryStr);    
    }
    
    public void execute(Database.BatchableContext context, List<Goal__c> goals){
    
        if(!goals.isEmpty()){
            
            Integer lastYear = Date.today().year()-1;    
            Date startDate_LY = Date.newinstance(lastYear, 01, 01);
            Date endDate_LY = Date.newinstance(lastYear, 12, 31);
            String lastYear_Str = String.valueOf(lastYear);
        
            String goalName_CY = goals[0].Name;
            String goalName_LY = '';
            
            if(goalName_CY.contains(currentYear_Str)){
                goalName_LY = goalName_CY.replace(currentYear_Str, lastYear_Str);
            }
            
            if(String.isNotBlank(goalName_LY)){
            
                List<Goal__c> goal_LY = [SELECT Id, Name FROM Goal__c WHERE Name = :goalName_LY AND Start_Date__c = :startDate_LY AND Due_Date__c = :endDate_LY];
                
                if(!goal_LY.isEmpty()){
                
                    List<Metric__c> metrics_LY = [SELECT Id, Name, Current_Value__c FROM Metric__c WHERE Goal__c IN : goal_LY];
                    
                    if(!metrics_LY.isEmpty()){
                    
                        String dynamic_Field = '';
                        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                        Schema.SObjectType objSchema = schemaMap.get('Metric__c');
                        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
                        
                        Map<String, Metric__c> metricNameANDMetricRec_LY = new Map<String, Metric__c>();
                        
                        for(Metric__c m : metrics_LY){
                            metricNameANDMetricRec_LY.put(m.Name, m);        
                        }
                        System.debug(':metricNameANDMetricRec_LY::::'+metricNameANDMetricRec_LY.size());
                        
                        for (String fieldName: fieldMap.keySet()){
                            
                            String field_Label = fieldMap.get(fieldName).getDescribe().getLabel();
                            String year_Str = field_Label.left(4);
                            
                            if(year_Str.isNumeric()){
                                
                                // It holds only last year field
                                if(year_Str == String.valueOf(lastYear)){
                                
                                    dynamic_Field = fieldName;
                                }
                            }
                        }
                        
                        if(String.isNotBlank(dynamic_Field)){
                        
                            List<sObject> updateMetrics = new List<sObject>();
                            
                            String metricQry_CY = 'SELECT Id, Name, ' + dynamic_Field + ' FROM Metric__c WHERE Goal__c IN : goals';
                                                    
                            List<Metric__c> metrics_CY = Database.Query(metricQry_CY);
                            System.debug('::metrics_CY::'+metrics_CY.size());
                            
                            if(!metrics_CY.isEmpty()){
                                                        
                                for(Metric__c m : metrics_CY){
                                    
                                    String metricName_CY = m.Name;
                                                                    
                                    if(metricName_CY.contains(currentYear_Str)){
                                        metricName_CY = metricName_CY.replace(currentYear_Str, lastYear_Str);
                                    }
                                    
                                    if(metricNameANDMetricRec_LY.containsKey(metricName_CY)){
                                        
                                        sObject metricRec = m;
                                        metricRec.put(dynamic_Field, metricNameANDMetricRec_LY.get(metricName_CY).Current_Value__c);
                                        updateMetrics.add(metricRec);
                                    }
                                }
                                System.debug('::updateMetrics::'+updateMetrics.size());
                                
                                if(!updateMetrics.isEmpty()){
                                    update  updateMetrics;   
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext context) {
    
    }
}