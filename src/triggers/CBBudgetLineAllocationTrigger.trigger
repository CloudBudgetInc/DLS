/**
 * Created by Alex JR on 2/26/2024.
 */

trigger CBBudgetLineAllocationTrigger on cb5__CBBudgetLine__c (after insert, after update) {

	for (cb5__CBBudgetLine__c bl : Trigger.new) {
		cb5__CBBudgetLine__c selected;
		if (bl.cb5__isAllocation__c) {
			selected = bl;
		}
		if (selected != null) {
			CBCalculationRuleAllocationService.runAllocationProcess(selected);
		}
	}

}