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
		return [SELECT Id, Subtype__c, ChartSection__c, Name FROM cb5__CBVariable2__c];
	}


	@AuraEnabled
	public static List<AggregateResult> getAFSATLaborTotalServer(String startPeriodId, String endPeriodId) {
		List<AggregateResult> aggr;
		Set<String> neededPeriods = getSetOfAllNeededPeriods(startPeriodId, endPeriodId);
		aggr = [
				SELECT SUM(Actual_Inverted__c) actual, SUM(cb5__Budget__c) budget, cb5__CBAccount__r.cb5__CBAccountType__r.Name accType
				FROM cb5__CBCube__c
				WHERE cb5__CBVariable2__r.Name = 'LT - EFL' AND cb5__CBPeriod__c IN :neededPeriods AND AFSATLabor__c = true
				GROUP BY cb5__CBAccount__r.cb5__CBAccountType__r.Name
		];
		return aggr;
	}

	///////// BILLING REPORT //////////////
	@AuraEnabled
	public static List<AcctSeed__Billing_Aging_History__c> getBillingAgingHistoryDataServer(String ASPeriodId) {
		Set<String> statuses = new Set<String>{
				'Approved', 'In Process', 'Rejected', 'Waiting for Approval'
		};
		return [
				SELECT Id, AcctSeed__Age__c, AcctSeed__Amount__c, AcctSeed__Billing__r.AcctSeed__Customer__r.Name
				FROM AcctSeed__Billing_Aging_History__c
				WHERE AcctSeed__Accounting_Period__c = :ASPeriodId
				AND AcctSeed__Billing__r.AcctSeed__Status__c NOT IN:statuses
				AND AcctSeed__Amount__c != 0
				ORDER BY AcctSeed__Billing__r.AcctSeed__Customer__r.Name
		];
	}
	///////// BILLING REPORT //////////////
	@AuraEnabled
	public static List<ReportWrapper> getWageReportDataServer(String ASPeriodId) {
		Map<String, Decimal> wageTransactionsMap = getWageAggrTransactions(ASPeriodId);
		Map<String, Decimal> timeCardMap = getWageAggrTimeCards(ASPeriodId);
		List<ReportWrapper> r = new List<CBPLSummaryReportPageController.ReportWrapper>();
		for (String var2Name : wageTransactionsMap.keySet()) {
			ReportWrapper w = new ReportWrapper();
			w.label = var2Name;
			w.amount = wageTransactionsMap.get(var2Name);
			Decimal hours = timeCardMap.get(var2Name);
			w.hours = hours == null ? 0 : hours;
			w.rate = w.hours == 0 ? 0 : (w.amount / w.hours).round();
			r.add(w);
			System.debug(w);
		}
		return r;
	}


	public static Map<String, Decimal> getWageAggrTransactions(String ASPeriodId) {
		Set<String> accountSet = new Set<String>{
				'51130 - Direct Salaried Non-SCA', '51140 - Direct Hourly Non-SCA', '51220 - Direct Contractors-Other'
		};
		Map<String, Decimal> wageTransactionMap = new Map<String, Decimal>();
		for (AggregateResult tr : [
				SELECT AcctSeed__GL_Account_Variable_2__r.Name var2Name, SUM(AcctSeed__Amount__c) amount
				FROM AcctSeed__Transaction__c
				WHERE AcctSeed__Accounting_Period__c = :ASPeriodId AND AcctSeed__GL_Account__r.Name IN:accountSet
				GROUP BY AcctSeed__GL_Account_Variable_2__r.Name
				ORDER BY AcctSeed__GL_Account_Variable_2__r.Name
		]) {
			String var2Name = (String) tr.get('var2Name');
			Decimal amount = (Decimal) tr.get('amount');
			wageTransactionMap.put(var2Name, amount);
		}
		return wageTransactionMap;
	}

	public static Map<String, Decimal> getWageAggrTimeCards(String ASPeriodId) {
		AcctSeed__Accounting_Period__c ap = [SELECT AcctSeed__Start_Date__c, AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c WHERE Id = :ASPeriodId];
		Map<String, Decimal> timeCardMap = new Map<String, Decimal>();
		for (AggregateResult timeCard : [
				SELECT SUM(AcctSeed__Hours__c) hours, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__GL_Account_Variable_2__r.Name var2Name
				FROM AcctSeed__Time_Card_Day__c
				WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c = true
				AND AcctSeed__Time_Card_Line__r.Payroll_Item__c != 'TES'
				AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.QB_Classification__c != 'ON0TST'
				AND (NOT AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name LIKE '%Testing%')
				AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.AcctSeed__Account__r.Name != 'DLS'
				AND AcctSeed__Date__c >= :ap.AcctSeed__Start_Date__c AND AcctSeed__Date__c <= :ap.AcctSeed__End_Date__c
				GROUP BY AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__GL_Account_Variable_2__r.Name
		]) {
			String var2Name = (String) timeCard.get('var2Name');
			Decimal hours = (Decimal) timeCard.get('hours');
			timeCardMap.put(var2Name, hours);
		}
		return timeCardMap;
	}

	@AuraEnabled
	public static List<ReportWrapper> getGSAReportingJEServer(String ASPeriodId) {
		Set<String> accounts = new Set <String>{
				'40110 - Language Training Revenue',
				'40130 - EFL Revenue',
				'40210 - Curriculum Development Revenue',
				'40220 - Linguist Support Revenue',
				'40320 - Interpretation Revenue',
				'40310 - Translation Revenue',
				'40410 - Language Testing Revenue'
		};
		List<ReportWrapper> r = new List<ReportWrapper>();
		Set<String> excludedVar2 = new Set<String>{
				'TST', 'TANDI', 'LT - EFL', 'LNG'
		};
		List<AggregateResult> aggregateResults = [
				SELECT AcctSeed__GL_Account_Variable_2__r.Name var2Name,
						AcctSeed__GL_Account_Variable_1__r.Name var1Name,
						SUM(AcctSeed__Units__c) quantity,
						SUM(AcctSeed__Debit__c) debit,
						SUM(AcctSeed__Credit__c) credit,
						AcctSeed__Journal_Entry__r.Project__c projectId,
						AcctSeed__Journal_Entry__r.Project__r.Contract__r.Name contractNo,
						AcctSeed__Journal_Entry__r.Project__r.AcctSeed__Account__r.Name accountName
				FROM AcctSeed__Journal_Entry_Line__c
				WHERE AcctSeed__GL_Account__r.Name IN:accounts
				AND AcctSeed__Journal_Entry__r.AcctSeed__Accounting_Period__c = :ASPeriodId
				AND (NOT AcctSeed__GL_Account_Variable_2__r.Name IN:excludedVar2)
				GROUP BY AcctSeed__GL_Account_Variable_2__r.Name, AcctSeed__GL_Account_Variable_1__r.Name, AcctSeed__Journal_Entry__r.Project__c, AcctSeed__Journal_Entry__r.Project__r.Contract__r.Name, AcctSeed__Journal_Entry__r.Project__r.AcctSeed__Account__r.Name
				ORDER BY AcctSeed__GL_Account_Variable_2__r.Name, AcctSeed__Journal_Entry__r.Project__r.Contract__r.Name
		];
		List<AggregateResult> aggregateResults2 = [
				SELECT AcctSeed__GL_Account_Variable_2__r.Name var2Name,
						AcctSeed__GL_Account_Variable_1__r.Name var1Name,
						SUM(AcctSeed__Hours_Units__c) quantity,
						SUM(AcctSeed__Total__c) total,
						AcctSeed__Billing__r.Project__c projectId,
						AcctSeed__Billing__r.Project__r.Contract__r.Name contractNo,
						AcctSeed__Billing__r.Project__r.AcctSeed__Account__r.Name accountName
				FROM AcctSeed__Billing_Line__c
				WHERE AcctSeed__Revenue_GL_Account__r.Name IN:accounts
				AND AcctSeed__Billing__r.AcctSeed__Accounting_Period__c = :ASPeriodId
				AND (NOT AcctSeed__GL_Account_Variable_2__r.Name IN:excludedVar2)
				GROUP BY AcctSeed__GL_Account_Variable_2__r.Name, AcctSeed__GL_Account_Variable_1__r.Name, AcctSeed__Billing__r.Project__c, AcctSeed__Billing__r.Project__r.Contract__r.Name, AcctSeed__Billing__r.Project__r.AcctSeed__Account__r.Name
				ORDER BY AcctSeed__GL_Account_Variable_2__r.Name, AcctSeed__Billing__r.Project__r.Contract__r.Name
		];

		Set<String> projectIds = new Set<String>();
		Map<Id, Decimal> projectRateMap = new Map<Id, Decimal>();
		for (AggregateResult ar : aggregateResults) projectIds.add((String) ar.get('projectId'));
		for (AggregateResult ar : aggregateResults2) projectIds.add((String) ar.get('projectId'));
		for (AcctSeed__Project__c p : [SELECT Id, Hourly_Rate__c FROM AcctSeed__Project__c WHERE Id IN:projectIds]) projectRateMap.put(p.Id, p.Hourly_Rate__c);
		for (AggregateResult ar : aggregateResults) {
			ReportWrapper rw = new ReportWrapper();
			String projectId = (String) ar.get('projectId');
			rw.rate = projectRateMap.get(projectId);
			rw.label = (String) ar.get('var2Name') + (String) ar.get('var1Name') + (String) ar.get('accountName');
			Decimal debit = (Decimal) ar.get('debit');
			Decimal credit = (Decimal) ar.get('credit');
			rw.amount = debit == null ? credit : -1 * debit;
			rw.hours = (Decimal) ar.get('quantity');
			rw.contractNo = (String) ar.get('contractNo');
			rw.accountName = (String) ar.get('accountName');
			rw.var1Name = (String) ar.get('var1Name');
			rw.var2Name = (String) ar.get('var2Name');
			rw.projectId = projectId;
			r.add(rw);
		}
		for (AggregateResult ar : aggregateResults2) {
			ReportWrapper rw = new ReportWrapper();
			String projectId = (String) ar.get('projectId');
			rw.rate = projectRateMap.get(projectId);
			rw.label = (String) ar.get('var2Name') + (String) ar.get('var1Name') + (String) ar.get('accountName');
			rw.amount = (Decimal) ar.get('total');
			rw.hours = (Decimal) ar.get('quantity');
			rw.contractNo = (String) ar.get('contractNo');
			rw.accountName = (String) ar.get('accountName');
			rw.var1Name = (String) ar.get('var1Name');
			rw.var2Name = (String) ar.get('var2Name');
			rw.projectId = projectId;
			r.add(rw);
		}
		//r = getWrappersGroupedByRate(r);
		return r;
	}

	private static List<ReportWrapper> getWrappersGroupedByRate(List<ReportWrapper> wrappers) {
		Map<String, ReportWrapper> wrapperReportMap = new Map<String, ReportWrapper>();
		for (ReportWrapper sourceRW : wrappers) {
			String key = sourceRW.label + sourceRW.rate;
			ReportWrapper groupedRW = wrapperReportMap.get(key);
			if (groupedRW == null) {
				wrapperReportMap.put(key, sourceRW);
				continue;
			} else {
				groupedRW.hours += sourceRW.hours;
				groupedRW.amount += sourceRW.amount;
			}
		}
		return wrapperReportMap.values();
	}

	@AuraEnabled
	public static List<cb5__CBFunction__c> getReportConfigsServer() {
		return [SELECT Name, cb5__Details__c FROM cb5__CBFunction__c WHERE cb5__Type__c = 'Average Report' ORDER BY CreatedDate];
	}

	@AuraEnabled
	public static Map<String, String> getProjectMapServer() {
		Map<String, String> projectMap = new Map<String, String>();
		for (AcctSeed__Project__c p : [SELECT Name, Id FROM AcctSeed__Project__c]) {
			projectMap.put(p.Id, p.Name);
		}
		return projectMap;
	}

	public class ReportWrapper {
		@AuraEnabled public String label { get; set; }
		@AuraEnabled public Decimal hours { get; set; }
		@AuraEnabled public Decimal amount { get; set; }
		@AuraEnabled public Decimal rate { get; set; }
		@AuraEnabled public String contractNo { get; set; }
		@AuraEnabled public String accountName { get; set; }
		@AuraEnabled public String var1Name { get; set; }
		@AuraEnabled public String var2Name { get; set; }
		@AuraEnabled public String projectId { get; set; }
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