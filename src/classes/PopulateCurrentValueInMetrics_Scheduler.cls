/*****************
    - Work Item: W-007098 - 2022 YTD Actual vs Proforma Budget Report
    - To populate current value field in metric records for the current year
    - This scheduler class runs 15'th of every month
    **************/
global class PopulateCurrentValueInMetrics_Scheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        
        PopulateCurrentValueInMetrics_Batch updateMetrics = new PopulateCurrentValueInMetrics_Batch(null,null,null,null);
        Database.executeBatch(updateMetrics,1);
        
        PopulateCurrentValueInMarketingMetrics updateMarketingMetricRec = new PopulateCurrentValueInMarketingMetrics(null, null, null, null);
        Database.ExecuteBatch(updateMarketingMetricRec, 1);
    }
}