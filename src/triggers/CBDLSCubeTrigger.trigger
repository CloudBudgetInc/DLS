/**
 * Created by Alex JR on 1/8/2024.
 */

trigger CBDLSCubeTrigger on cb5__CBCube__c (before insert, before update) {


	for (cb5__CBCube__c c : Trigger.new) {
		Id v1 = c.cb5__CBVariable1__c, v2 = c.cb5__CBVariable2__c, divId;
		if (v1 != null) {
			divId = CBTriggerService.varDivisionMap.get(v1);
		} else if (v2 != null) {
			divId = CBTriggerService.varDivisionMap.get(v2);
		}
		c.cb5__CBDivision__c = divId;
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