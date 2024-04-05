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

	@TestVisible
	public static Boolean NFLMetricTriggerNeeded = true;

	/**
	 * Method takes list of metrics and updates NFL libraries
	 *
	 * @param metrics list of goal metrics
	 */
	public static void updateNFLWithHours(List<Metric__c> metrics) {
		NFLMetricTriggerNeeded = false; // switch off the next trigger for metrics
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

	/**
	 * This method takes NFL items, and create or updates hours in goals
	 * @param nflItems list of NFL items
	 */
	public static void updateMetricsWithHours(List<cb5__CBNonFinancialItem__c> nflItems) {
		NFLMetricTriggerNeeded = false; // switch off the next trigger for NFLs
		Set<String> NFLibItemIds = new Set<String>();
		Set<String> NFLibIds = new Set<String>();
		Map<Date, Date> periodStartBudgetYearMap = new Map<Date, Date>();
		Map<String, Map<Date, Decimal>> nflMap = new Map<String, Map<Date, Decimal>>(); // key is NFL Id, value is map where key is Start Date, value is amount
		for (cb5__CBNonFinancialItem__c item : nflItems) NFLibItemIds.add(item.Id);
		for (cb5__CBNonFinancialItem__c item : [SELECT cb5__CBPeriod__r.cb5__Start__c, cb5__CBPeriod__r.cb5__CBBudgetYear__r.cb5__Start__c, cb5__NonFinancialLibrary__c, cb5__Value__c FROM cb5__CBNonFinancialItem__c WHERE Id IN:NFLibItemIds]) {
			NFLibIds.add(item.cb5__NonFinancialLibrary__c);
			periodStartBudgetYearMap.put(item.cb5__CBPeriod__r.cb5__Start__c, item.cb5__CBPeriod__r.cb5__CBBudgetYear__r.cb5__Start__c);
			Map<Date, Decimal> internalMap = nflMap.get(item.cb5__NonFinancialLibrary__c);
			if (internalMap == null) {
				internalMap = new Map<Date, Decimal>();
				nflMap.put(item.cb5__NonFinancialLibrary__c, internalMap);
			}
			internalMap.put(item.cb5__CBPeriod__r.cb5__Start__c, item.cb5__Value__c);
		}
		List<Metric__c> metricsToUpsert = new List<Metric__c>();
		for (Goal__c goal : [SELECT Id, CBHours__c, Start_Date__c, (SELECT Start_Date__c, Budget_Value__c FROM Metrics__r) FROM Goal__c WHERE CBHours__c IN:NFLibIds]) {
			Map<Date, Decimal> NFLInternalMap = nflMap.get(goal.CBHours__c);
			for (Date startDate : NFLInternalMap.keySet()) {
				if (periodStartBudgetYearMap.get(startDate) != goal.Start_Date__c) continue; // if NFL item is out of the goal budget year just skip it
				Metric__c respectiveMetric = getRespectiveMetric(goal, startDate);
				Decimal newValue = NFLInternalMap.get(startDate);
				if (respectiveMetric.Budget_Value__c != newValue) {
					respectiveMetric.Budget_Value__c = newValue;
					metricsToUpsert.add(respectiveMetric);
				}
			}
		}
		upsert metricsToUpsert;
	}

	@TestVisible
	private static Metric__c getRespectiveMetric(Goal__c goal, Date startDate) {
		Metric__c r;
		if (goal.Metrics__r.size() > 0) {
			for (Metric__c m : goal.Metrics__r) {
				if (m.Start_Date__c == startDate) {
					r = m;
					break;
				}
			}
		}
		return r == null ? new Metric__c(Goal__c = goal.Id, Name = 'Billable Hours ' + convertDateToString(startDate), Metric_Type__c = 'Hours', Start_Date__c = startDate, Budget_Value__c = -1) : r;
	}

	@TestVisible
	private static String convertDateToString(Date inputDate) {
		Datetime dt = Datetime.newInstance(inputDate.year(), inputDate.month(), inputDate.day());
		String dateString = dt.format('MMM yyyy');
		return dateString;
	}
}