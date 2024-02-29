/** 
Copyright (c) 2024, AJR, CloudBudget, Inc.
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


public with sharing class CBCalculationRuleAllocationService {

	public static cb5__CBBudgetLine__c parentBudgetLine; // allocatedBudgetLine
	public static List<cb5__CBBudgetLine__c> allocatedBudgetLines; // allocatedBudgetLine

	public static Map<String, String> budgetYearNameIdMap {
		get {
			if (budgetYearNameIdMap == null) {
				budgetYearNameIdMap = new Map<String, String>();
				for (cb5__CBBudgetYear__c s : [SELECT Id, Name FROM cb5__CBBudgetYear__c LIMIT 20]) {
					budgetYearNameIdMap.put(s.Name, s.Id);
					budgetYearNameIdMap.put(s.Id, s.Name);
				}
			}
			return budgetYearNameIdMap;
		}
		set;
	}

	//public static List<cb5__CBPeriod__c> periods = [SELECT Id FROM cb5__CBPeriod__c WHERE cb5__CBBudgetYear__c = :parentBudgetLine.cb5__CBBudgetYear__c];
	public static List<cb5__CBPeriod__c> periods {
		get {
			if (periods == null) {
				periods = [SELECT Id FROM cb5__CBPeriod__c WHERE cb5__CBBudgetYear__c = :parentBudgetLine.cb5__CBBudgetYear__c ORDER BY cb5__Start__c];
			}
			return periods;
		}
		set;
	}

	public static Map<String, String> scenarioNameIdMap {
		get {
			if (scenarioNameIdMap == null) {
				scenarioNameIdMap = new Map<String, String>();
				for (cb5__CBScenario__c s : [SELECT Id, Name FROM cb5__CBScenario__c LIMIT 5]) {
					scenarioNameIdMap.put(s.Name, s.Id);
					scenarioNameIdMap.put(s.Id, s.Name);
				}
			}
			return scenarioNameIdMap;
		}
		set;
	}

	public static void runAllocationProcess(cb5__CBBudgetLine__c budgetLine) {
		if (!triggerIsNeeded(budgetLine)) return;
		parentBudgetLine = budgetLine;
		allocatedBudgetLines = getAllocatedBudgetLines();
		List<cb5__CBCalculationRule__c> calculationRules = getRelatedCalculationRules();
		Map<String, cb5__CBNonFinancialLibrary__c> NFLibraries = getNFLibraries(calculationRules);
		Map<String, cb5__CBBudgetLine__c> autoParentBudgetLines = getAutoParentBudgetLines(calculationRules);
		deleteOldAutoChildLines(calculationRules);
		regenerateAutoAllocatedBudgetLines(calculationRules, autoParentBudgetLines, NFLibraries);
		updateTotalsInAutoAllocatedBudgetLines(autoParentBudgetLines.values());
	}

	public static List<cb5__CBBudgetLine__c> getAllocatedBudgetLines() {
		return [
				SELECT Name, cb5__CBVariable1__c, cb5__CBVariable2__c, (
						SELECT cb5__CBPeriod__c, cb5__Value__c
						FROM cb5__CBAmounts__r
				)
				FROM cb5__CBBudgetLine__c
				WHERE cb5__ParentBudgetLine__c = :parentBudgetLine.Id
		];
	}

	private static Boolean triggerIsNeeded(cb5__CBBudgetLine__c budgetLine) {
		return budgetLine.cb5__ParentBudgetLine__c == null && scenarioNameIdMap.get('Salary Allocation') == budgetLine.cb5__CBScenario__c;
	}

	private static void deleteOldAutoChildLines(List<cb5__CBCalculationRule__c> calculationRules) {
		Set<String> calcSetIds = new Set<String>();
		for (cb5__CBCalculationRule__c cr : calculationRules) calcSetIds.add(cr.Id);
		delete [SELECT Id FROM cb5__CBBudgetLine__c WHERE cb5__CBCalculationRule__c IN:calcSetIds AND cb5__Code__c = :parentBudgetLine.Id AND cb5__ParentBudgetLine__c != null];
	}

	public static List<cb5__CBCalculationRule__c> getRelatedCalculationRules() {
		String budgetYearName = budgetYearNameIdMap.get(parentBudgetLine.cb5__CBBudgetYear__c);
		List<cb5__CBCalculationRule__c> r = new List<cb5__CBCalculationRule__c>();
		Set<String> analytics = new Set<String>();
		for (cb5__CBBudgetLine__c bl : allocatedBudgetLines) {
			if (bl.cb5__CBVariable1__c != null) analytics.add(bl.cb5__CBVariable1__c);
			if (bl.cb5__CBVariable2__c != null) analytics.add(bl.cb5__CBVariable2__c);
		}
		for (cb5__CBCalculationRule__c cr : [
				SELECT Id, Name, cb5__SourceParentFilter__c, cb5__CBVariable1__c, cb5__CBVariable2__c, cb5__CBAccount__c, cb5__NFL1__c, cb5__ResultName__c
				FROM cb5__CBCalculationRule__c
				WHERE cb5__CBFolder__r.Name = :budgetYearName
		]) {
			for (String s : analytics) {
				if (cr.cb5__SourceParentFilter__c.contains(s)) {
					r.add(cr);
					continue;
				}
			}
		}
		return r;
	}

	public static Map<String, cb5__CBNonFinancialLibrary__c> getNFLibraries(List<cb5__CBCalculationRule__c> calculationRules) {
		Set<String> fractionIds = new Set<String>();
		for (cb5__CBCalculationRule__c cr : calculationRules) {
			if (cr.cb5__NFL1__c == null) continue;
			fractionIds.add(cr.cb5__NFL1__c);
		}
		Map<String, cb5__CBNonFinancialLibrary__c> r = new Map<String, cb5__CBNonFinancialLibrary__c>();

		Map<String, cb5__CBNonFinancialLibrary__c> libMap = new Map<String, cb5__CBNonFinancialLibrary__c>();
		for (cb5__CBNonFinancialLibrary__c lib : [
				SELECT Id, (
						SELECT Id, cb5__CBPeriod__c, cb5__Value__c
						FROM cb5__NonFinancialItems__r
						WHERE cb5__CBPeriod__r.cb5__CBBudgetYear__c = :parentBudgetLine.cb5__CBBudgetYear__c
						ORDER BY cb5__CBPeriod__r.cb5__Start__c
				)
				FROM cb5__CBNonFinancialLibrary__c
				WHERE Id IN:fractionIds
		]) {
			libMap.put(lib.Id, lib);
		}
		for (cb5__CBCalculationRule__c cr : calculationRules) {
			r.put(cr.Id, libMap.get(cr.cb5__NFL1__c));
		}
		return r;
	}

	/**
	 * @return key is calculationRule Id, value is parent auto line
	 */
	public static Map<String, cb5__CBBudgetLine__c> getAutoParentBudgetLines(List<cb5__CBCalculationRule__c> calculationRules) {
		Set<String> crIds = new Set<String>();
		Map<String, cb5__CBBudgetLine__c> r = new Map<String, cb5__CBBudgetLine__c>();
		for (cb5__CBCalculationRule__c cr : calculationRules) crIds.add(cr.Id);
		List<cb5__CBBudgetLine__c> existedParentBudgetLines = [SELECT Id, cb5__CBCalculationRule__c FROM cb5__CBBudgetLine__c WHERE cb5__CBCalculationRule__c IN:crIds AND cb5__isAllocation__c = true AND cb5__ParentBudgetLine__c = null];
		for (cb5__CBBudgetLine__c bl : existedParentBudgetLines) r.put(bl.cb5__CBCalculationRule__c, bl);
		List<cb5__CBBudgetLine__c> newBudgetLines = new List<cb5__CBBudgetLine__c>();
		String mainScenarioId = scenarioNameIdMap.get('Main');
		for (cb5__CBCalculationRule__c cr : calculationRules) {
			cb5__CBBudgetLine__c budgetLine = r.get(cr.Id);
			if (budgetLine == null) {
				budgetLine = new cb5__CBBudgetLine__c(Name = 'TEST', cb5__CBBudgetYear__c = parentBudgetLine.cb5__CBBudgetYear__c, cb5__CBCalculationRule__c = cr.Id);
				if (cr.cb5__CBVariable1__c != null) budgetLine.cb5__CBVariable1__c = cr.cb5__CBVariable1__c;
				if (cr.cb5__CBVariable2__c != null) budgetLine.cb5__CBVariable2__c = cr.cb5__CBVariable2__c;
				budgetLine.cb5__CBAccount__c = cr.cb5__CBAccount__c;
				budgetLine.cb5__CBScenario__c = mainScenarioId;
				budgetLine.cb5__isAllocation__c = true;
				newBudgetLines.add(budgetLine);
			}
		}
		if (newBudgetLines.size() > 0) {
			insert newBudgetLines;
			List<cb5__CBAmount__c> newAmounts = new List<cb5__CBAmount__c>();
			for (cb5__CBBudgetLine__c bl : newBudgetLines) {
				for (cb5__CBPeriod__c p : periods) {
					newAmounts.add(new cb5__CBAmount__c(cb5__Value__c = 0, cb5__CBPeriod__c = p.Id, cb5__CBBudgetLine__c = bl.Id));
				}
			}
			insert newAmounts;
			for (cb5__CBBudgetLine__c bl : newBudgetLines) r.put(bl.cb5__CBCalculationRule__c, bl);
		}
		return r;
	}

	public static void regenerateAutoAllocatedBudgetLines(List<cb5__CBCalculationRule__c> calculationRules, Map<String, cb5__CBBudgetLine__c> autoParentBudgetLines, Map<String, cb5__CBNonFinancialLibrary__c> NFLibraries) {
		String mainScenarioId = scenarioNameIdMap.get('Main');
		Map<cb5__CBBudgetLine__c, List<cb5__CBBudgetLine__c>> budgetLinesMapping = new Map<cb5__CBBudgetLine__c, List<cb5__CBBudgetLine__c>>();
		List<cb5__CBBudgetLine__c> budgetLinesToInsert = new List<cb5__CBBudgetLine__c>();
		for (cb5__CBBudgetLine__c bl : allocatedBudgetLines) {
			//System.debug('Allocated BL: ' + bl);
			for (cb5__CBCalculationRule__c cr : calculationRules) {
				//System.debug('CR:' + cr);
				if ((cr.cb5__CBVariable1__c != null && cr.cb5__CBVariable1__c == bl.cb5__CBVariable1__c) || (cr.cb5__CBVariable2__c != null && cr.cb5__CBVariable2__c == bl.cb5__CBVariable2__c)) {
					System.debug('NAME:' + bl.Name);
					cb5__CBBudgetLine__c newAutoChildBudgetLine = new cb5__CBBudgetLine__c(
							Name = bl.Name,
							cb5__Description__c = 'Allocated from budget line "' + bl.Name + '" using Calculation Rule "' + cr.Name + '" (' + System.now() + ')',
							cb5__CBScenario__c = mainScenarioId,
							cb5__ParentBudgetLine__c = autoParentBudgetLines.get(cr.Id).Id,
							cb5__CBAccount__c = cr.cb5__CBAccount__c,
							cb5__CBBudgetYear__c = parentBudgetLine.cb5__CBBudgetYear__c,
							cb5__CBCalculationRule__c = cr.Id,
							cb5__DrillDownIds__c = bl.Id,
							cb5__Code__c = parentBudgetLine.Id
					);
					if (cr.cb5__CBVariable1__c != null) newAutoChildBudgetLine.cb5__CBVariable1__c = cr.cb5__CBVariable1__c;
					if (cr.cb5__CBVariable2__c != null) newAutoChildBudgetLine.cb5__CBVariable2__c = cr.cb5__CBVariable2__c;
					budgetLinesToInsert.add(newAutoChildBudgetLine);
					List<cb5__CBBudgetLine__c> internalList = budgetLinesMapping.get(bl);
					if (internalList == null) {
						internalList = new List<cb5__CBBudgetLine__c>();
						budgetLinesMapping.put(bl, internalList);
					}
					internalList.add(newAutoChildBudgetLine);
				}
			}
		}
		insert budgetLinesToInsert;
		//System.debug('Inserted: ' + budgetLinesToInsert.size());
		List<cb5__CBAmount__c> newAmounts = new List<cb5__CBAmount__c>();
		for (cb5__CBBudgetLine__c bl : budgetLinesMapping.keySet()) {
			List<cb5__CBBudgetLine__c> internalList = budgetLinesMapping.get(bl);
			if (internalList == null || internalList.size() == 0) continue;
			for (cb5__CBBudgetLine__c newBL : internalList) {
				for (Integer i = 0; i < periods.size(); i++) {
					cb5__CBNonFinancialLibrary__c fraction = NFLibraries.get(newBL.cb5__CBCalculationRule__c);
					Decimal sAmount = bl.cb5__CBAmounts__r[i].cb5__Value__c;
					Decimal fAmount = fraction.cb5__NonFinancialItems__r[i].cb5__Value__c;
					Decimal res = (sAmount * fAmount).setScale(2);
					Id periodId = periods[i].Id;
					cb5__CBAmount__c newAmount = new cb5__CBAmount__c(cb5__CBBudgetLine__c = newBL.Id, cb5__CBPeriod__c = periodId, cb5__Value__c = res);
					newAmounts.add(newAmount);
				}
			}
		}
		//System.debug('AMOUNTS TO INSERT' + newAmounts.size());
		insert newAmounts;
	}

	public static void updateTotalsInAutoAllocatedBudgetLines(List<cb5__CBBudgetLine__c> autoParentBudgetLines) {
		Map<String, List<cb5__CBBudgetLine__c>> parentChildBudgetLines = new Map<String, List<cb5__CBBudgetLine__c>>();
		Set<String> parentAutoLineIds = new Set<String>();
		for (cb5__CBBudgetLine__c bl : autoParentBudgetLines) parentAutoLineIds.add(bl.Id);
		autoParentBudgetLines = [SELECT Id, (SELECT cb5__Value__c FROM cb5__CBAmounts__r) FROM cb5__CBBudgetLine__c WHERE Id IN:parentAutoLineIds];
		for (cb5__CBBudgetLine__c bl : [
				SELECT Id, cb5__ParentBudgetLine__c, (SELECT cb5__Value__c FROM cb5__CBAmounts__r ORDER BY cb5__CBPeriod__r.cb5__Start__c)
				FROM cb5__CBBudgetLine__c
				WHERE cb5__ParentBudgetLine__c IN:parentAutoLineIds
		]) {
			//System.debug('CHILD LINE : ' + bl);
			List<cb5__CBBudgetLine__c> internalList = parentChildBudgetLines.get(bl.cb5__ParentBudgetLine__c);
			if (internalList == null) {
				internalList = new List<cb5__CBBudgetLine__c>();
				parentChildBudgetLines.put(bl.cb5__ParentBudgetLine__c, internalList);
			}
			internalList.add(bl);
		}
		//System.debug('parentChildBudgetLines = ' + parentChildBudgetLines);
		List<cb5__CBAmount__c> amountsToUpdate = new List<cb5__CBAmount__c>();
		for (cb5__CBBudgetLine__c parentBL : autoParentBudgetLines) {
			List<cb5__CBBudgetLine__c> internalList = parentChildBudgetLines.get(parentBL.Id);
			//System.debug('IntLIST : ' + internalList);
			if (internalList == null) continue;
			//System.debug('GO GO GO Internal Size : ' + internalList.size());
			for (cb5__CBAmount__c a : parentBL.cb5__CBAmounts__r) a.cb5__Value__c = 1;
			for (cb5__CBBudgetLine__c childBL : internalList) {
				//System.debug('CHILD!: ' + childBL + ' size = ' + parentBL.cb5__CBAmounts__r.size());
				for (Integer i = 0; i < parentBL.cb5__CBAmounts__r.size(); i++) {
					parentBL.cb5__CBAmounts__r[i].cb5__Value__c += childBL.cb5__CBAmounts__r[i].cb5__Value__c;
					//System.debug('Child Amount = ' + childBL.cb5__CBAmounts__r[i].cb5__Value__c + ' Parent: ' + parentBL.cb5__CBAmounts__r[i].cb5__Value__c);
				}
			}
			amountsToUpdate.addAll(parentBL.cb5__CBAmounts__r);
		}
		//System.debug('Amounts to update: ' + amountsToUpdate);
		//System.debug('Amounts to update: ' + amountsToUpdate.size());
		update amountsToUpdate;
	}

	@AuraEnabled
	public static void runUpdatingInBatchForSelectedBudgetYearServer(String byId) {
		if (byId == null) return;
		CBAllocationBatch ab = new CBAllocationBatch(byId);
		Id test = Database.executeBatch(ab, 1);
	}


}