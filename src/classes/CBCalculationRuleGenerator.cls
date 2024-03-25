/** 
Copyright (c) 2024, AlexJR, CloudBudget, Inc.
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

Controller serves to take calculation rule templates and based on them generates calculation rules for selected budget year
 */
public with sharing class CBCalculationRuleGenerator {

	private static String DESCRIPTION = 'Auto Generated from a template';
	private static String SOURCE_SCENARIO_NAME = 'Salary Allocation';
	private static String RESULT_SCENARIO_NAME = 'Main';

	/**
	 * @return list of budget years for the page dropdown
	 */
	@AuraEnabled
	public static List<cb5__CBBudgetYear__c> getBudgetYearsServer() {
		return [SELECT Id, Name FROM cb5__CBBudgetYear__c ORDER BY Name];
	}

	/**
	 * Method takes CR templates, BY Id, and generates a list of calculation rules based on templates. Calc rules must be in a folder of budget year name
	 * @param byId CBBudgetYear__c Id
	 */
	@AuraEnabled
	public static void generateCalculationRulesServer(String byId) {
		if (byId == null) return;
		cb5__CBBudgetYear__c budgetYear = [SELECT Id,Name FROM cb5__CBBudgetYear__c WHERE Id = :byId LIMIT 1];
		cb5__CBFolder__c folder = getRespectiveFolder(budgetYear.Name);
		List<CBCalculationRuleTemplate__c> templates = [SELECT Name,CBVariable1__c,CBVariable2__c,Fraction__c,ResultAccount__c FROM CBCalculationRuleTemplate__c];
		Map<Id, cb5__CBCalculationRule__c> existedCalculationRuleMap = new Map<Id, cb5__CBCalculationRule__c>();
		for (cb5__CBCalculationRule__c cr : [SELECT Id,CBCalculationRuleTemplate__c FROM cb5__CBCalculationRule__c WHERE CBCalculationRuleTemplate__c != null AND cb5__CBBudgetYear__c = :byId]) existedCalculationRuleMap.put(cr.CBCalculationRuleTemplate__c, cr);
		cb5__CBScenario__c sourceScenario = [SELECT Id FROM cb5__CBScenario__c WHERE Name = :SOURCE_SCENARIO_NAME LIMIT 1];
		cb5__CBScenario__c resultScenario = [SELECT Id FROM cb5__CBScenario__c WHERE Name = :RESULT_SCENARIO_NAME LIMIT 1];
		List<cb5__CBCalculationRule__c> calRules = new List<cb5__CBCalculationRule__c>();
		for (CBCalculationRuleTemplate__c crt : templates) {
			cb5__CBCalculationRule__c cr = existedCalculationRuleMap.get(crt.Id);
			calRules.add(getCalculationRule(cr, budgetYear, crt, folder.Id, sourceScenario.Id, resultScenario.Id));
		}
		upsert calRules;
	}

	/**
	 * The method returns respective calculation rule folder object for selected budget year or creates a new folder if it does not exist
	 * @param byName name of the selected budget year
	 */
	private static cb5__CBFolder__c getRespectiveFolder(String byName) {
		List<cb5__CBFolder__c> folders = [SELECT Id FROM cb5__CBFolder__c WHERE Name = :byName LIMIT 1];
		if (folders.size() > 0) return folders[0];
		cb5__CBFolder__c folder = new cb5__CBFolder__c(Name = byName, cb5__FolderType__c = 'Calculation Rule');
		insert folder;
		return folder;
	}

	/**
	 * Method creates a new cr or update already existed
	 *
	 * @param cr existed calculation rule if exist. If yes it will be updated, if not a new CR will be created
	 * @param budgetYear selected budget year
	 * @param crt template object
	 * @param folderId respective folder Id for calculation rule
	 * @param sourceScenarioId source scenario Id
	 * @param resultScenarioId target scenario Id
	 *
	 * @return updated or created calculation rule
	 */
	private static cb5__CBCalculationRule__c getCalculationRule(cb5__CBCalculationRule__c cr, cb5__CBBudgetYear__c budgetYear, CBCalculationRuleTemplate__c crt, String folderId, String sourceScenarioId, String resultScenarioId) {
		String name = crt.Name + ' ' + budgetYear.Name;
		String filter = 'cb5__CBBudgetYear__c = \'' + budgetYear.Id + '\' AND cb5__ParentBudgetLine__c != null AND cb5__CBScenario__c = \'' + sourceScenarioId + '\' AND ';
		if (cr == null) cr = new cb5__CBCalculationRule__c();
		if (crt.CBVariable1__c != null) {
			filter += 'cb5__CBVariable1__c = \'' + crt.CBVariable1__c + '\'';
		} else if (crt.CBVariable2__c != null) {
			filter += 'cb5__CBVariable2__c = \'' + crt.CBVariable2__c + '\'';
		} else {
			Integer i = 1 / 0;
		}
		cr.Name = name;
		cr.cb5__Mode__c = 'many-to-one';
		cr.cb5__CBAccount__c = crt.ResultAccount__c;
		cr.cb5__NFL1__c = crt.Fraction__c;
		cr.cb5__Value__c = 0;
		cr.cb5__Formula__c = '#1 * #2';
		cr.cb5__ResultName__c = crt.Name;
		cr.cb5__SourceParentFilter__c = filter;
		cr.cb5__CBFolder__c = folderId;
		cr.cb5__Description__c = DESCRIPTION;
		cr.cb5__CBScenario__c = resultScenarioId;
		cr.cb5__CBBudgetYear__c = budgetYear.Id;
		cr.CBCalculationRuleTemplate__c = crt.Id;
		cr.cb5__copyAccount__c = false;
		cr.cb5__copyScenario__c = false;
		cr.cb5__copyBudgetYear__c = true;
		cr.cb5__copyDivision__c = true;
		if (crt.CBVariable1__c != null) {
			cr.cb5__CBVariable1__c = crt.CBVariable1__c;
			cr.cb5__copyVariable1__c = false;
		} else {
			cr.cb5__copyVariable1__c = true;
		}
		if (crt.CBVariable2__c != null) {
			cr.cb5__CBVariable2__c = crt.CBVariable2__c;
			cr.cb5__copyVariable2__c = false;
		} else {
			cr.cb5__copyVariable2__c = true;
		}
		cr.cb5__copyVariable3__c = true;
		cr.cb5__copyVariable4__c = true;
		cr.cb5__copyVariable5__c = true;
		return cr;
	}
}