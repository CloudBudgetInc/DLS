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

Controller serves to generate NFL from CRM goals.
 */
public with sharing class CBGoalTriggerService {

	public static void updateGoalMetrics(List<Goal__c> applicableGoals) {
		Set<Id> goalIds = new Set<Id>();
		Set<Id> NFLIds = new Set<Id>();
		for (Goal__c g : applicableGoals) {
			goalIds.add(g.Id);
			NFLIds.add(g.Seasonality__c);
		}

		Map<Id, Map<Date, Decimal>> itemsMap = new Map<Id, Map<Date, Decimal>>(); // key is NFLib Id
		for (cb5__CBNonFinancialLibrary__c lib : [SELECT Id, (SELECT cb5__Value__c, cb5__CBPeriod__r.cb5__Start__c FROM cb5__NonFinancialItems__r ORDER BY cb5__CBPeriod__r.cb5__Start__c) FROM cb5__CBNonFinancialLibrary__c]) {
			Map<Date, Decimal> dataValueMap = new Map<Date, Decimal>();
			for (cb5__CBNonFinancialItem__c item : lib.cb5__NonFinancialItems__r) dataValueMap.put(item.cb5__CBPeriod__r.cb5__Start__c, item.cb5__Value__c);
			itemsMap.put(lib.Id, dataValueMap);
		}

		Map<Id, List<Metric__c>> metricsMap = new Map<Id, List<Metric__c>>(); // key is goal Id
		for (Goal__c g : [SELECT Id, (SELECT Id, Budget_Value__c, Start_Date__c FROM Metrics__r ORDER BY Start_Date__c) FROM Goal__c WHERE Id IN:goalIds]) {
			metricsMap.put(g.Id, g.Metrics__r);
		}

		List<Metric__c> metricsToUpdate = new List<Metric__c>();
		for (Goal__c g : applicableGoals) {
			List<Metric__c> metrics = metricsMap.get(g.Id);
			Map<Date, Decimal> dataValueMap = itemsMap.get(g.Seasonality__c);
			for (Metric__c m : metrics) {
				Decimal percent = dataValueMap.get(m.Start_Date__c);
				percent = percent == null ? 0 : percent;
				m.Budget_Value__c = (g.YearlyHours__c * percent).round(System.RoundingMode.CEILING);
			}
			metricsToUpdate.addAll(metrics);
		}
		update metricsToUpdate;
	}
	
}