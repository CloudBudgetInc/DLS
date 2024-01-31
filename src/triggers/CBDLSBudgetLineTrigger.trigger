/**
 * Created by Alex JR on 1/8/2024.
 */

trigger CBDLSBudgetLineTrigger on cb5__CBBudgetLine__c (before insert, before update) {

	for (cb5__CBBudgetLine__c bl : Trigger.new) {
		cb5__CBScenario__c scenario = [SELECT Id FROM cb5__CBScenario__c WHERE Name =: 'Salary Allocation' LIMIT 1];
		if (bl.cb5__CBScenario__c == scenario.Id) continue;
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
		bl.Name = (accountName + variableName).left(80);
	}

}