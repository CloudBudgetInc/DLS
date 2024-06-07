/** 
Copyright (c) AJR, 2024, CloudBudget, Inc.
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
// CBTestCoverage, CBPLSummaryReportTest
 */


@isTest
private class CBPLSummaryReportTest {

	@testSetup
	static void setup() {
		cb5__CBOrgVariable__c orgVariable = new cb5__CBOrgVariable__c(Name = 'General');
		insert orgVariable;

		List<cb5__CBScenario__c> scenarios = new List<cb5__CBScenario__c>{
				new cb5__CBScenario__c(Name = 'Salary Allocation'),
				new cb5__CBScenario__c(Name = 'Main')
		};
		insert scenarios;

		cb5__CBBudgetYear__c budgetYear = new cb5__CBBudgetYear__c(Name = '2025', cb5__Start__c = Date.newInstance(2025, 1, 1));
		insert budgetYear;
		List<cb5__CBPeriod__c> periods = new List<cb5__CBPeriod__c>();
		for (Integer i = 0; i < 4; i++) periods.add(new cb5__CBPeriod__c(Name = 'Q' + 1, cb5__Start__c = Date.newInstance(2024, i + 1, 1), cb5__End__c = Date.newInstance(2024, i + 1, 25), cb5__CBBudgetYear__c = budgetYear.Id));
		insert periods;

		cb5__CBAccountType__c accType = new cb5__CBAccountType__c(Name = 'Expense', cb5__Sign__c = '+');
		insert accType;
		cb5__CBSubAccount__c accSubtype = new cb5__CBSubAccount__c(Name = 'Facilities');
		insert accSubtype;
		cb5__CBAccount__c acc = new cb5__CBAccount__c(Name = '78525-Other', cb5__CBAccountType__c = accType.Id, cb5__CBSubAccount__c = accSubtype.Id);
		insert acc;

		cb5__CBDivision__c division = new cb5__CBDivision__c(Name = 'Test');
		insert division;

		cb5__CBBudgetLine__c bl = new cb5__CBBudgetLine__c(Name = 'TestBL', cb5__CBAccount__c = acc.Id, cb5__CBDivision__c = division.Id, cb5__CBBudgetYear__c = budgetYear.Id);
		insert bl;
		List<cb5__CBAmount__c> amounts = new List<cb5__CBAmount__c>();
		for (cb5__CBPeriod__c p : periods) amounts.add(new cb5__CBAmount__c(cb5__CBBudgetLine__c = bl.Id, cb5__CBPeriod__c = p.Id, cb5__Value__c = 1));
		insert amounts;

		// Create mock cb5__CBCube__c records
		List<cb5__CBCube__c> cubes = new List<cb5__CBCube__c>();
		for (cb5__CBPeriod__c period : periods) {
			cubes.add(new cb5__CBCube__c(
					cb5__CBPeriod__c = period.Id,
					cb5__DrillDownIds__c = bl.Id,
					cb5__CBAccount__c = acc.Id,
					cb5__CBDivision__c = division.id,
					cb5__Actual__c = 100,
					cb5__Budget__c = 200
			));
		}
		insert cubes;
	}

	@isTest
	static void PLSummaryReportPageControllerTest() {
		Test.startTest();
		List<cb5__CBPeriod__c> periods = CBPLSummaryReportPageController.getPeriodsServer();
		String startPeriodId = periods[0].Id;
		String endPeriodId = periods[1].Id;
		List<cb5__CBCube__c> cubes = CBPLSummaryReportPageController.getCBCubesForPeriodServer(startPeriodId, endPeriodId);
		cb5__CBAmount__c amount = [SELECT Id FROM cb5__CBAmount__c LIMIT 1][0];
		CBPLSummaryReportPageController.DDResult result = CBPLSummaryReportPageController.getDDRecordsServer(
				new List<String>{
						amount.Id
				});
		Test.stopTest();

		System.assertNotEquals(0, periods.size(), 'Periods should not be empty');
		System.assertNotEquals(0, cubes.size(), 'Cubes should not be empty');
	}

}