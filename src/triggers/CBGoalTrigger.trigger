/**
 * Created by Alex JR on 1/24/2024.
 */

trigger CBGoalTrigger on Goal__c (after update) {

	if (Trigger.isAfter && Trigger.isUpdate) {
		List<Goal__c> applicableGoals = new List<Goal__c>();
		Set<Id> allGoalIds = new Set<Id>();
		for (Goal__c g : Trigger.new) {
			if (g.YearlyHours__c != null && g.YearlyHours__c > 0 && g.Seasonality__c != null) applicableGoals.add(g);
			allGoalIds.add(g.Id);
		}
		if (applicableGoals.size() > 0) CBGoalTriggerService.updateGoalMetrics(applicableGoals);
		update [SELECT Id FROM Metric__c WHERE Goal__c IN:allGoalIds]; // Run metric trigger
	}

}