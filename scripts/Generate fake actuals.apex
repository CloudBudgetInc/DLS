List<cb5__CBCube__c> allCubes = [SELECT cb5__Budget__c, cb5__CBVariable2__c, cb5__CBAccount__r.Name FROM cb5__CBCube__c];
Decimal min = 0.85, max = 1.15;
for (cb5__CBCube__c c : allCubes) {
	c.cb5__Actual__c = c.cb5__Budget__c * (Math.random() * (max - min) + min);
	if (Pattern.matches('^[5-9].*', c.cb5__CBAccount__r.Name)) c.cb5__Actual__c *= -1;
}
update allCubes;