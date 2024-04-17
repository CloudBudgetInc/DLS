/**
 * Created by Alex JR on 1/8/2024.
 */

trigger CBDLSBudgetLineTrigger on cb5__CBBudgetLine__c (before insert, before update, before delete) {

	cb5__CBScenario__c selAllocScenario = [SELECT Id FROM cb5__CBScenario__c WHERE Name = :'Salary Allocation' LIMIT 1];
	/**
	 * Set a lookup to division if Var1 or Var2 selected
	 * Set combined name of BL
	 */
	if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {

		for (cb5__CBBudgetLine__c bl : Trigger.new) {
			if (bl.cb5__CBScenario__c == selAllocScenario.Id && bl.cb5__isAllocation__c) continue;
			Id v1 = bl.cb5__CBVariable1__c, v2 = bl.cb5__CBVariable2__c, divId;
			String variableName;
			if (v1 != null) {
				divId = CBTriggerService.varDivisionMap.get(v1);
				variableName = CBTriggerService.var1Var2IdToNameMap.get(v1);
			} else if (v2 != null) {
				divId = CBTriggerService.varDivisionMap.get(v2);
				variableName = CBTriggerService.var1Var2IdToNameMap.get(v2);
			}
			bl.cb5__CBDivision__c = divId;
			variableName = variableName == null ? '' : ' (' + variableName + ')';
			String accountName = bl.cb5__CBAccount__c == null ? 'Account not specified' : CBTriggerService.accountMap.get(bl.cb5__CBAccount__c);
			String CRMAccountName = bl.cb5__CBVariable3__c == null ? '' : ' (' + CBTriggerService.CRMAccountMap.get(bl.cb5__CBVariable3__c) + ')' ;
			bl.Name = (accountName + variableName + CRMAccountName).left(80);
		}
	}

	/**
	 * Delete Allocated fringes if allocated salary line must be deleted
	 */
	if (Trigger.isBefore && Trigger.isDelete) {
		System.debug('DELETE TRIGGER');
		Set<String> allocatedLines = new Set<String>();
		for (cb5__CBBudgetLine__c bl : Trigger.old) {
			if (bl.cb5__isAllocation__c || bl.cb5__ParentBudgetLine__c == null || bl.cb5__CBScenario__c != selAllocScenario.Id) continue;
			allocatedLines.add(bl.Id);
		}
		System.debug('DELETE TRIGGER allocatedLines = ' + allocatedLines);
		if (allocatedLines.size() == 0) return;
		Set<String> parentBLIds = new Set<String>();
		List<cb5__CBBudgetLine__c> budgetLines = [SELECT Id, cb5__ParentBudgetLine__c FROM cb5__CBBudgetLine__c WHERE cb5__SystemAccessKey__c IN:allocatedLines];
		System.debug('DELETE TRIGGER budgetLines = ' + budgetLines);
		for (cb5__CBBudgetLine__c b : budgetLines) parentBLIds.add(b.cb5__ParentBudgetLine__c);
		delete budgetLines;
		System.debug('DELETE TRIGGER parentBLIds = ' + parentBLIds);
		List<cb5__CBBudgetLine__c> parentBudgetLines = [
				SELECT Id, (SELECT cb5__Value__c FROM cb5__CBAmounts__r ORDER BY cb5__CBPeriod__r.cb5__Start__c)
				FROM cb5__CBBudgetLine__c
				WHERE Id IN:parentBLIds
		];
		CBCalculationRuleAllocationService.updateTotalsInAutoAllocatedBudgetLines(parentBudgetLines);
	}

}