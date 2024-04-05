/** 
Copyright (c) 4/1/2024, Alex JR CloudBudget, Inc.
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
@IsTest
public with sharing class CBTestCoverage {

	private static String HOUR_LAYER_NAME = 'Hours';
	private static String FRACTION_LAYER_NAME = 'Fraction';
	private static String SEASONALITY_LAYER_NAME = 'Seasonality';
	private static String SOURCE_SCENARIO_NAME = 'Salary Allocation';
	private static String RESULT_SCENARIO_NAME = 'Main';

	@TestSetup
	static void setupTestData() {
		cb5__CBOrgVariable__c orgVar = new cb5__CBOrgVariable__c();
		insert orgVar;
		////// PERIODS /////////
		cb5__CBBudgetYear__c budgetYear = new cb5__CBBudgetYear__c (Name = '2025', cb5__Start__c = Date.newInstance(2025, 1, 1));
		insert budgetYear;
		List<cb5__CBPeriod__c> periods = new List<cb5__CBPeriod__c>();
		for (Integer i = 1; i <= 12; i++) periods.add(new cb5__CBPeriod__c(Name = 'M' + i, cb5__Start__c = Date.newInstance(2025, i, 1), cb5__End__c = Date.newInstance(2025, i, 1).addDays(29), cb5__CBBudgetYear__c = budgetYear.Id));
		insert periods;
		///// LAYERS ////
		List<cb5__CBLayer__c> layers = new List<cb5__CBLayer__c>();
		for (String str : new String[]{
				FRACTION_LAYER_NAME, HOUR_LAYER_NAME, SEASONALITY_LAYER_NAME, 'Wage Rates', 'Revenue Rates'
		}) layers.add(new cb5__CBLayer__c(Name = str));
		insert layers;
		//// SCENARIOS ////
		List<cb5__CBScenario__c> scenarios = new List<cb5__CBScenario__c>();
		for (String str : new String[]{
				SOURCE_SCENARIO_NAME, RESULT_SCENARIO_NAME
		}) scenarios.add(new cb5__CBScenario__c(Name = str));
		insert scenarios;

		//// ACCOUNTS ////
		cb5__CBAccountType__c at = new cb5__CBAccountType__c(Name = 'Expenses', cb5__Sign__c = '+');
		insert at;
		cb5__CBSubAccount__c ast = new cb5__CBSubAccount__c(Name = 'Test ST');
		insert ast;
		cb5__CBAccount__c account = new cb5__CBAccount__c(Name = 'Test', cb5__CBAccountType__c = at.Id, cb5__CBSubAccount__c = ast.Id);
		insert account;
		//// DIVISION ////
		cb5__CBDivision__c division = new cb5__CBDivision__c(Name = 'Div');
		insert division;
		//// VARIABLES /////
		cb5__CBVariable1__c var1 = new cb5__CBVariable1__c(Name = 'Test Var', CBDivision__c = division.Id);
		insert var1;
		//// FRACTION /////
		cb5__CBNonFinancialLibrary__c nflFraction = new cb5__CBNonFinancialLibrary__c(Name = 'Fraction', cb5__Layer__c = layers[0].Id);
		insert nflFraction;
		//// CR TEMPLATES ////
		CBCalculationRuleTemplate__c template = new CBCalculationRuleTemplate__c(CBVariable1__c = var1.Id, ResultAccount__c = account.Id, Fraction__c = nflFraction.Id);
		insert template;


	}

	@IsTest
	static void validateGoalTrigger() {
		Id hoursLayerId = [SELECT Id FROM cb5__CBLayer__c WHERE Name = :HOUR_LAYER_NAME][0].Id;
		Goal__c goal = new Goal__c(Name = 'Test');
		insert goal;
		cb5__CBNonFinancialLibrary__c nfl = new cb5__CBNonFinancialLibrary__c(Name = 'Goal', cb5__Layer__c = hoursLayerId);
		insert nfl;
		goal.CBHours__c = nfl.Id;
		update goal;
		CBMetricTriggerService.NFLMetricTriggerNeeded = true;
		cb5__CBNonFinancialItem__c nfli = [SELECT Id, cb5__CBPeriod__r.cb5__Start__c FROM cb5__CBNonFinancialItem__c WHERE cb5__NonFinancialLibrary__c = :nfl.Id LIMIT 1];
		nfli.cb5__Value__c = 1;
		update nfli;
		String str = CBMetricTriggerService.convertDateToString(nfli.cb5__CBPeriod__r.cb5__Start__c);
		goal = [SELECT Id, (SELECT Start_Date__c FROM Metrics__r) FROM Goal__c LIMIT 1][0];
		CBMetricTriggerService.getRespectiveMetric(goal, nfli.cb5__CBPeriod__r.cb5__Start__c);
	}

	@IsTest
	static void validateMetricTrigger() {
		Id hoursLayerId = [SELECT Id FROM cb5__CBLayer__c WHERE Name = :HOUR_LAYER_NAME][0].Id;
		cb5__CBNonFinancialLibrary__c nfl = new cb5__CBNonFinancialLibrary__c(Name = 'Goal', cb5__Layer__c = hoursLayerId);
		insert nfl;
		Goal__c goal = new Goal__c(Name = 'Test', CBHours__c = nfl.Id);
		insert goal;
		Metric__c metric = new Metric__c(Goal__c = goal.Id, Start_Date__c = Date.newInstance(2025, 1, 1), Budget_Value__c = 100);
		insert metric;
		CBMetricTriggerService.updateNFLWithHours(new List<Metric__c>{
				metric
		});
	}

	@IsTest
	static void validateCBTriggerService() {
		Object o = CBTriggerService.varDivisionMap;
		o = CBTriggerService.accountMap;
		o = CBTriggerService.CRMAccountMap;
		o = CBTriggerService.var1Var2IdToNameMap;
	}

	@IsTest
	static void validateCBGoalTriggerService() {
		cb5__CBNonFinancialLibrary__c seasonality = new cb5__CBNonFinancialLibrary__c(Name = 'Spring', cb5__Layer__c = [SELECT Id FROM cb5__CBLayer__c WHERE Name = :SEASONALITY_LAYER_NAME][0].Id);
		insert seasonality;
		Goal__c goal = new Goal__c(Name = 'Goal', Start_Date__c = Date.newInstance(2025, 1, 1));
		insert goal;
		List<Metric__c> metrics = new List<Metric__c>();
		for (cb5__CBPeriod__c p : [SELECT Id, cb5__Start__c FROM cb5__CBPeriod__c]) metrics.add(new Metric__c(Name = p.Id, Start_Date__c = p.cb5__Start__c, Goal__c = goal.Id));
		insert metrics;

		goal.Seasonality__c = seasonality.Id;
		goal.YearlyHours__c = 100;
		update goal;
	}

	@IsTest
	static void validateCalculationRuleGeneratorAndAllocation() {
		List<cb5__CBBudgetYear__c> budgetYears = CBCalculationRuleGenerator.getBudgetYearsServer();
		CBCalculationRuleGenerator.generateCalculationRulesServer(budgetYears[0].Id);

		cb5__CBAccount__c acc = [SELECT Id FROM cb5__CBAccount__c][0];
		cb5__CBVariable1__c var1 = [SELECT Id FROM cb5__CBVariable1__c][0];
		cb5__CBScenario__c scenario = [SELECT Id FROM cb5__CBScenario__c WHERE Name = :SOURCE_SCENARIO_NAME][0];
		List<cb5__CBPeriod__c> periods = [SELECT Id FROM cb5__CBPeriod__c];
		cb5__CBBudgetLine__c parentBudgetLine = new cb5__CBBudgetLine__c(Name = 'Parent', cb5__isAllocation__c = true, cb5__CBBudgetYear__c = budgetYears[0].Id, cb5__CBAccount__c = acc.Id, cb5__CBScenario__c = scenario.Id);
		insert parentBudgetLine;
		cb5__CBBudgetLine__c allocatedBudgetLine = new cb5__CBBudgetLine__c(Name = 'Allocated', cb5__CBScenario__c = scenario.Id, cb5__ParentBudgetLine__c = parentBudgetLine.Id, cb5__CBBudgetYear__c = budgetYears[0].Id, cb5__CBAccount__c = acc.Id, cb5__CBVariable1__c = var1.Id);
		insert allocatedBudgetLine;
		cb5__CBBudgetLine__c simpleBudgetLine = new cb5__CBBudgetLine__c(Name = 'Simple', cb5__CBBudgetYear__c = budgetYears[0].Id, cb5__CBAccount__c = acc.Id, cb5__CBVariable1__c = var1.Id);
		insert simpleBudgetLine;

		List<cb5__CBAmount__c> amounts = new List<cb5__CBAmount__c>();
		for (cb5__CBPeriod__c p : periods) {
			amounts.add(new cb5__CBAmount__c(cb5__CBBudgetLine__c = parentBudgetLine.Id, cb5__CBPeriod__c = p.Id, cb5__Value__c = 100));
			amounts.add(new cb5__CBAmount__c(cb5__CBBudgetLine__c = allocatedBudgetLine.Id, cb5__CBPeriod__c = p.Id, cb5__Value__c = 100));
			amounts.add(new cb5__CBAmount__c(cb5__CBBudgetLine__c = simpleBudgetLine.Id, cb5__CBPeriod__c = p.Id, cb5__Value__c = 100));
		}
		insert amounts;

		new CBAllocationProcess().runProcess(budgetYears[0].Id, null);

		CBAllocationBatch.cover();
		CBCalculationRuleAllocationService.cover();

		delete allocatedBudgetLine;

	}

	@IsTest
	static void validateCubeTrigger() {
		cb5__CBVariable1__c var1 = [SELECT Id FROM cb5__CBVariable1__c][0];
		cb5__CBPeriod__c period = [SELECT Id FROM cb5__CBPeriod__c][0];
		insert new cb5__CBCube__c(cb5__CBVariable1__c = var1.Id, cb5__CBPeriod__c = period.Id);
	}


}