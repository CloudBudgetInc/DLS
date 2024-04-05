/**
 * Created by Alex JR on 3/28/2024.
 */
trigger CBNFLItemDLSTrigger on cb5__CBNonFinancialItem__c (after insert, after update) {

	if (CBMetricTriggerService.NFLMetricTriggerNeeded && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
		CBMetricTriggerService.updateMetricsWithHours(Trigger.new);
	}

}