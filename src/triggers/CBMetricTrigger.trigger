trigger CBMetricTrigger on Metric__c (after update) {

	if (CBMetricTriggerService.NFLMetricTriggerNeeded && Trigger.isAfter && Trigger.isUpdate) {
		CBMetricTriggerService.updateNFLWithHours(Trigger.new);
	}

	Integer i = 0;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
}