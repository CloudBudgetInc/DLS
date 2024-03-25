/** 
Copyright (c) 2024, CloudBudget, Inc.
All rights reserved.
Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
* Neither the name of the CloudBudget, Inc. nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

 */


public with sharing class CBMetricTriggerService {

	public static void updateNFLWithHours(List<Metric__c> metrics) {

		Set<Id> goalIds = new Set<Id>();
		Map<Id, Id> metricGoalIdMap = new Map<Id, Id>();
		for (Metric__c m : metrics) {
			goalIds.add(m.Goal__c);
			metricGoalIdMap.put(m.Id, m.Goal__c);
		}

		Set<Id> NFLIds = new Set<Id>();
		Map<Id, Id> goalIdNFLMap = new Map<Id, Id>();
		for (Goal__c g : [SELECT Id, CBHours__c FROM Goal__c WHERE Id IN:goalIds]) {
			if (g.CBHours__c != null) {
				NFLIds.add(g.CBHours__c);
				goalIdNFLMap.put(g.Id, g.CBHours__c);
			}
		}
		if (NFLIds.size() == 0) return;

		List<cb5__CBNonFinancialItem__c> itemsToUpdate = new List<cb5__CBNonFinancialItem__c>();
		Map<Id, Map<Date, cb5__CBNonFinancialItem__c>> NFLMap = new Map<Id, Map<Date, cb5__CBNonFinancialItem__c>>();
		for (cb5__CBNonFinancialLibrary__c lib : [SELECT Id, (SELECT cb5__CBPeriod__r.cb5__Start__c FROM cb5__NonFinancialItems__r) FROM cb5__CBNonFinancialLibrary__c WHERE Id IN:NFLIds]) {
			Map<Date, cb5__CBNonFinancialItem__c> dataItemMap = new Map<Date, cb5__CBNonFinancialItem__c>();
			for (cb5__CBNonFinancialItem__c item : lib.cb5__NonFinancialItems__r) {
				itemsToUpdate.add(item);
				dataItemMap.put(item.cb5__CBPeriod__r.cb5__Start__c, item);
			}
			NFLMap.put(lib.Id, dataItemMap);
		}

		for (Metric__c m : metrics) {
			Id goalId = metricGoalIdMap.get(m.Id);
			Id NFLId = goalIdNFLMap.get(goalId);
			Map<Date, cb5__CBNonFinancialItem__c> dataItemMap = NFLMap.get(NFLId);
			cb5__CBNonFinancialItem__c item = dataItemMap.get(m.Start_Date__c);
			if (item == null) continue;
			item.cb5__Value__c = m.Budget_Value__c;
		}

		update itemsToUpdate;


	}

}