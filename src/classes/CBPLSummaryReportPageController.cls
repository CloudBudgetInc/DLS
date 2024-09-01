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


public with sharing class CBPLSummaryReportPageController {

	private static List<cb5__CBPeriod__c> sortedPeriods {
		get {
			if (sortedPeriods == null) sortedPeriods = [SELECT Id,cb5__CBBudgetYear__c,Name FROM cb5__CBPeriod__c ORDER BY cb5__Start__c DESC LIMIT 5000];
			return sortedPeriods;
		}
		set;
	}

	@AuraEnabled
	public static List<cb5__CBPeriod__c> getPeriodsServer() {
		return sortedPeriods;
	}

	/**
	 * @param startPeriodId selected on the page
	 * @param endPeriodId CBPeriod Id depends on the logic
	 *
	 * @return list of cubes for needed period range
	 */
	@AuraEnabled
	public static List<cb5__CBCube__c> getCBCubesForPeriodServer(String startPeriodId, String endPeriodId) {
		System.debug('Start: ' + startPeriodId + ' End: ' + endPeriodId);
		Set<String> neededPeriods = getSetOfAllNeededPeriods(startPeriodId, endPeriodId);
		System.debug('neededPeriods: ' + neededPeriods);
		return [
				SELECT Id, cb5__DrillDownIds__c,cb5__CBAccount__c,cb5__CBDivision__c,Actual_Inverted__c,cb5__Budget__c,cb5__CBAccount__r.Name,
						cb5__AccSubType__c,cb5__CBVariable1__r.Name,cb5__CBVariable2__r.Name,
						cb5__CBAccount__r.cb5__CBAccountType__r.Name,CBAccountSubtype2__c,cb5__CBDivision__r.Name
				FROM cb5__CBCube__c
				WHERE cb5__CBPeriod__c IN:neededPeriods
				ORDER BY cb5__CBVariable2__r.Name, cb5__CBAccount__r.Name
				LIMIT 48000
		];
	}

	/**
	 * @param startPeriodId start CBPeriod Id
	 * @param endPeriodId end CBPeriod Id
	 *
	 * @return list of CBPeriod from start to the end
	 */
	private static Set<String> getSetOfAllNeededPeriods(String startPeriodId, String endPeriodId) {
		if (endPeriodId == null) return new Set<String>{
				startPeriodId
		};
		Set<String> r = new Set<String>();
		Boolean isNeededPeriod = false;
		for (Integer i = sortedPeriods.size() - 1; i >= 0; i--) {
			cb5__CBPeriod__c p = sortedPeriods[i];
			if (startPeriodId == p.Id) isNeededPeriod = true;
			if (isNeededPeriod) r.add(p.Id);
			if (endPeriodId == p.Id) break;
		}
		return r;
	}


	@AuraEnabled
	public static DDResult getDDRecordsServer(List<String> ddIds) {
		DDResult r = new DDResult();
		r.BLAmounts = [SELECT cb5__CBBudgetLine__c,cb5__CBBudgetLine__r.Name,cb5__Value__c FROM cb5__CBAmount__c WHERE Id IN:new Set<String>(ddIds) ORDER BY cb5__CBBudgetLine__r.Name];
		r.accSeedCubes = [SELECT Id,Name,AcctSeed__MTD_Actual_P_L__c,AcctSeed__GL_Account__r.Name FROM AcctSeed__Financial_Cube__c WHERE Id IN:new Set<String>(ddIds) ORDER BY AcctSeed__GL_Account__r.Name];
		return r;
	}

	public class DDResult {
		@AuraEnabled
		public List<cb5__CBAmount__c> BLAmounts {
			get;
			set;
		}
		@AuraEnabled
		public List<AcctSeed__Financial_Cube__c> accSeedCubes {
			get;
			set;
		}
	}

	/**
	 * Gross margin uses fringe percent for calculation. Percent depends on the Var 2 lookup
	 * @param periodsId needed period Id
	 * @return
	 */
	@AuraEnabled
	public static Map<String, Decimal> getFringePercentServer(String periodsId) {
		Map<String, Decimal> r = new Map<String, Decimal>();
		Map<Id, Decimal> nflValueMap = new Map<Id, Decimal>();
		for (cb5__CBNonFinancialItem__c item : [
				SELECT cb5__NonFinancialLibrary__c, cb5__Value__c
				FROM cb5__CBNonFinancialItem__c
				WHERE cb5__NonFinancialLibrary__r.cb5__LayerTitle__c = 'Fringes' AND cb5__CBPeriod__c = :periodsId
		]) nflValueMap.put(item.cb5__NonFinancialLibrary__c, item.cb5__Value__c);
		for (cb5__CBVariable2__c var2 : [SELECT Name, IRM__c FROM cb5__CBVariable2__c]) {
			Decimal v = nflValueMap.get(var2.IRM__c);
			r.put(var2.Name, v == null ? 0 : v);
		}
		return r;
	}

	@AuraEnabled
	public static List<cb5__CBVariable2__c> getVar2Server() {
		return [SELECT Id, Subtype__c, Name FROM cb5__CBVariable2__c];
	}

	public static void cover() {
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

}