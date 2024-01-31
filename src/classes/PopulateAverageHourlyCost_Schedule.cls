// Work Item : W-001294
// Scheduler to call PopulateAverageHourlyCost batch class to populate Average_Hourly_Cost_Non_SCA_LT__c field in Language__c object
// Created by HL on Apr 09 2019
// Scheduled on Daily basis     

global class PopulateAverageHourlyCost_Schedule implements Schedulable {

    global void execute(SchedulableContext sc) {
    
        PopulateAverageHourlyCost avgHCPopulation = new PopulateAverageHourlyCost();
        Database.executeBatch(avgHCPopulation,1);
    }
}