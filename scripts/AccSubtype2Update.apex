Map<Id, cb5__CBAccount__c> CBAccountsMap = new Map<Id, cb5__CBAccount__c>();
for (cb5__CBAccount__c cba : [SELECT Id, cb5__ExtId__c FROM cb5__CBAccount__c]) CBAccountsMap.put(cba.cb5__ExtId__c, cba);
for (AcctSeed__GL_Account__c accAcc : [SELECT Id, AcctSeed__Sub_Type_2__c FROM AcctSeed__GL_Account__c]) {
	cb5__CBAccount__c cba = CBAccountsMap.get(accAcc.Id);
	if (cba != null) cba.CBAccountSubtype2__c = accAcc.AcctSeed__Sub_Type_2__c;
}
update CBAccountsMap.values();

