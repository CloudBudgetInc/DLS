/**
 * Created by Alex JR, CloudBudget on 1/24/2024.
 */

trigger CBGoalTrigger on Goal__c (after update) {

	try {
		if (Trigger.isAfter && Trigger.isUpdate) {
			List<Goal__c> applicableGoals = new List<Goal__c>();
			Set<Id> allGoalIds = new Set<Id>();
			List<String> nflIds = new List<String>();
			for (Goal__c g : Trigger.new) {
				nflIds.add(g.CBHours__c);
				nflIds.add(g.CBHours2__c);
				nflIds.add(g.CBHours3__c);
				if (g.YearlyHours__c != null && g.YearlyHours__c > 0 && g.Seasonality__c != null) applicableGoals.add(g);
				allGoalIds.add(g.Id);
			}
			if (applicableGoals.size() > 0) CBGoalTriggerService.updateGoalMetrics(applicableGoals);

			update [SELECT Id FROM cb5__CBNonFinancialItem__c WHERE cb5__NonFinancialLibrary__c IN:nflIds]; // run nfl items trigger
		}
	} catch (Exception e) {
		System.debug('Trigger failed: ' + e);
	}

}