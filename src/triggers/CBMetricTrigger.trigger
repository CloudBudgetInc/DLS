trigger CBMetricTrigger on Metric__c (after update) {

	if (Trigger.isAfter && Trigger.isUpdate) {
		CBMetricTriggerService.updateNFLWithHours(Trigger.new);
	}

}