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

	public static cb5__CBBudgetLine__c parentBudgetLine; // allocatedBudgetLine - main budget line before allocation
	public static List<cb5__CBBudgetLine__c> allocatedBudgetLines; // allocatedBudgetLines
	public static final String TQ_DESCRIPTION = 'Salary Allocation';

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

	public static Map<Id, String> accountMap {
		get {
			if (accountMap == null) {
				accountMap = new Map<Id, String>();
				for (cb5__CBAccount__c acc : [SELECT Id,Name FROM cb5__CBAccount__c]) accountMap.put(acc.Id, acc.Name);
			}
			return accountMap;
		}
		set;
	}

	public static void runAllocationProcess(cb5__CBBudgetLine__c budgetLine) {
		if (!triggerIsNeeded(budgetLine)) return;
		parentBudgetLine = budgetLine;
		allocatedBudgetLines = getAllocatedBudgetLines(); // get children lines
		List<cb5__CBCalculationRule__c> calculationRules = getRelatedCalculationRules();
		Map<String, cb5__CBNonFinancialLibrary__c> NFLibraries = getNFLibraries(calculationRules);
		Map<String, cb5__CBBudgetLine__c> autoParentBudgetLines = getAutoParentBudgetLines(calculationRules);
		deleteOldAutoChildLines(calculationRules);
		regenerateAutoAllocatedBudgetLines(calculationRules, autoParentBudgetLines, NFLibraries);
		updateTotalsInAutoAllocatedBudgetLines(autoParentBudgetLines.values());
	}

	/**
	 * @return children budget lines of the main parent budget line
	 */
	public static List<cb5__CBBudgetLine__c> getAllocatedBudgetLines() {
		return [SELECT Name, cb5__CBVariable1__c, cb5__CBVariable2__c, (SELECT cb5__CBPeriod__c, cb5__Value__c FROM cb5__CBAmounts__r) FROM cb5__CBBudgetLine__c WHERE cb5__ParentBudgetLine__c = :parentBudgetLine.Id];
	}

	/**
	 * Method checks if this line need to recalculate amounts
	 * @param budgetLine
	 * @return true if line is before allocation and a parent
	 */
	private static Boolean triggerIsNeeded(cb5__CBBudgetLine__c budgetLine) {
		return budgetLine.cb5__ParentBudgetLine__c == null && scenarioNameIdMap.get('Salary Allocation') == budgetLine.cb5__CBScenario__c;
	}

	/**
	 * Method deletes old allocated budget lines after allocation
	 */
	private static void deleteOldAutoChildLines(List<cb5__CBCalculationRule__c> calculationRules) {
		Set<String> calcSetIds = new Set<String>();
		for (cb5__CBCalculationRule__c cr : calculationRules) calcSetIds.add(cr.Id);
		delete [SELECT Id FROM cb5__CBBudgetLine__c WHERE cb5__CBCalculationRule__c IN:calcSetIds AND cb5__Code__c = :parentBudgetLine.Id AND cb5__ParentBudgetLine__c != null];
	}

	/**
	 * @return list of calculation rules that related to the current budget line
	 */
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

	/**
	 * @param calculationRules
	 *
	 * @return list of NFL needed for calculation rules
	 */
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
		]) libMap.put(lib.Id, lib);
		for (cb5__CBCalculationRule__c cr : calculationRules) r.put(cr.Id, libMap.get(cr.cb5__NFL1__c));
		return r;
	}

	/**
	 * Method returns parent budget lines after allocation
	 * @return key is calculationRule Id, value is parent auto line
	 */
	public static Map<String, cb5__CBBudgetLine__c> getAutoParentBudgetLines(List<cb5__CBCalculationRule__c> calculationRules) {
		Map<String, cb5__CBBudgetLine__c> r = new Map<String, cb5__CBBudgetLine__c>();
		try {
			Set<String> crIds = new Set<String>(); // list of applicable calculation rule Ids
			for (cb5__CBCalculationRule__c cr : calculationRules) crIds.add(cr.Id);
			List<cb5__CBBudgetLine__c> existedParentBudgetLines = [
					SELECT Id, cb5__CBCalculationRule__c, cb5__CBAccount__c
					FROM cb5__CBBudgetLine__c
					WHERE cb5__CBCalculationRule__c IN:crIds AND cb5__isAllocation__c = true AND cb5__ParentBudgetLine__c = null AND cb5__CBBudgetYear__c = :parentBudgetLine.cb5__CBBudgetYear__c
			];
			for (cb5__CBBudgetLine__c bl : existedParentBudgetLines) r.put(bl.cb5__CBCalculationRule__c, bl); // key is CR Id, value is budget line parent
			List<cb5__CBBudgetLine__c> newBudgetLines = new List<cb5__CBBudgetLine__c>(); // new parent budget lines if they were not created
			String mainScenarioId = scenarioNameIdMap.get('Main');
			Map<Id, String> calculationRuleNameMap = new Map<Id, String>();
			for (cb5__CBCalculationRule__c cr : calculationRules) {
				calculationRuleNameMap.put(cr.Id, cr.Name);
				cb5__CBBudgetLine__c budgetLine = r.get(cr.Id); // try to get existed parent budget line
				if (budgetLine == null) { // if it is not exist, create a new one
					budgetLine = new cb5__CBBudgetLine__c(
							Name = 'Parent Budget Line',
							cb5__CBBudgetYear__c = parentBudgetLine.cb5__CBBudgetYear__c,
							cb5__CBCalculationRule__c = cr.Id,
							cb5__CBAccount__c = cr.cb5__CBAccount__c,
							cb5__CBScenario__c = mainScenarioId,
							cb5__isAllocation__c = true
					);
					if (cr.cb5__CBVariable1__c != null) budgetLine.cb5__CBVariable1__c = cr.cb5__CBVariable1__c;
					if (cr.cb5__CBVariable2__c != null) budgetLine.cb5__CBVariable2__c = cr.cb5__CBVariable2__c;
					newBudgetLines.add(budgetLine);
				}
			}
			if (newBudgetLines.size() > 0) {
				insert newBudgetLines;
				List<cb5__CBAmount__c> newAmounts = new List<cb5__CBAmount__c>();
				for (cb5__CBBudgetLine__c bl : newBudgetLines) { // for each new parent budget line
					for (cb5__CBPeriod__c p : periods) { // create respective number of amounts with periods and zero
						newAmounts.add(new cb5__CBAmount__c(cb5__Value__c = 0, cb5__CBPeriod__c = p.Id, cb5__CBBudgetLine__c = bl.Id));
					}
				}
				insert newAmounts;
				for (cb5__CBBudgetLine__c bl : newBudgetLines) r.put(bl.cb5__CBCalculationRule__c, bl);
			}
			for (cb5__CBBudgetLine__c bl : r.values()) {
				bl.Name = (accountMap.get(bl.cb5__CBAccount__c) + ' (' + calculationRuleNameMap.get(bl.cb5__CBCalculationRule__c) + ')').left(80);
			}
			update r.values();
		} catch (Exception e) {
			System.debug('ERROR:' + e);
			throw e;
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
							cb5__Code__c = parentBudgetLine.Id,
							cb5__SystemAccessKey__c = bl.Id // workaround for delete trigger only
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

	@AuraEnabled
	public static void updateTaskQueueForSelectedBudgetYearServer(String byId) {
		List<cb5__CBTaskQueue__c> taskQueues = [SELECT Id FROM cb5__CBTaskQueue__c WHERE cb5__RelatedTo__c = :byId AND cb5__Description__c = :TQ_DESCRIPTION];
		if (taskQueues.size() == 0) {
			String tqName = 'Salary Allocation ' + [SELECT Name FROM cb5__CBBudgetYear__c WHERE Id = :byId LIMIT 1][0].Name;
			cb5__CBTaskQueue__c tq = new cb5__CBTaskQueue__c(
					Name = tqName,
					cb5__Status__c = 'Idle',
					cb5__RelatedTo__c = byId,
					cb5__Description__c = TQ_DESCRIPTION
			);
			insert tq;
			cb5__CBTask__c task = new cb5__CBTask__c(
					cb5__CBTaskQueue__c = tq.Id,
					Name = tqName,
					cb5__Status__c = 'Idle',
					cb5__Parameter1__c = byId,
					cb5__ClassName__c = 'CBAllocationProcess');
			insert task;
		}
	}


}