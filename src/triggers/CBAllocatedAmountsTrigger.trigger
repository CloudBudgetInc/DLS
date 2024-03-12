/**
 * Created by Alex JR on 2/29/2024.
 * This reacts on saving allocated line amounts in 'Salary Allocation' scenario and runs allocation process
 */

trigger CBAllocatedAmountsTrigger on cb5__CBAmount__c (after insert, after update) {
	cb5__CBAmount__c amount = Trigger.new[0];
	cb5__CBBudgetLine__c bl = [ // allocated Budget line
			SELECT Id, cb5__CBScenario__r.Name, cb5__CBScenario__c, cb5__ParentBudgetLine__c
			FROM cb5__CBBudgetLine__c
			WHERE Id = :amount.cb5__CBBudgetLine__c
	];
	if (bl.cb5__ParentBudgetLine__c == null || bl.cb5__CBScenario__r.Name != 'Salary Allocation') return;
	cb5__CBBudgetLine__c parentBudgetLine = [
			SELECT Id, Name, cb5__ParentBudgetLine__c, cb5__CBBudgetYear__c, cb5__CBScenario__c
			FROM cb5__CBBudgetLine__c
			WHERE Id = :bl.cb5__ParentBudgetLine__c
	];
	CBCalculationRuleAllocationService.runAllocationProcess(parentBudgetLine);
}