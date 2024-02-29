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

public with sharing class CBAllocationBatch implements Database.Batchable<sObject> {

	String bdgYear;

	public CBAllocationBatch(String byId) {
		this.bdgYear = byId;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		cb5__CBBudgetYear__c budgetYear = [SELECT Id, Name FROM cb5__CBBudgetYear__c WHERE Id = :bdgYear];
		insert new cb5__CBLog__c(Name = budgetYear.Name + ' allocation started', cb5__Status__c = 'PROGRESS', cb5__Type__c = 'TASK QUEUE', cb5__Title__c = 'Running', cb5__Description__c = 'Allocation for ' + budgetYear.Name + ' is started');
		String query = 'SELECT Id FROM cb5__CBBudgetLine__c WHERE cb5__CBScenario__r.Name = \'Salary Allocation\'' +
				' AND cb5__isAllocation__c = true AND cb5__CBBudgetYear__c = \'' + bdgYear + '\' ORDER BY Name';
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<cb5__CBBudgetLine__c> salaryParentBudgetLines) {
		cb5__CBBudgetLine__c parentBudgetLine = [
				SELECT Id, Name, cb5__ParentBudgetLine__c, cb5__CBBudgetYear__c, cb5__CBScenario__c
				FROM cb5__CBBudgetLine__c
				WHERE Id = :salaryParentBudgetLines[0].Id
		];
		CBCalculationRuleAllocationService.runAllocationProcess(parentBudgetLine);
		insert new cb5__CBLog__c(Name = parentBudgetLine.Name + ' allocation', cb5__Status__c = 'PROGRESS', cb5__Type__c = 'TASK QUEUE', cb5__Title__c = 'Running', cb5__Description__c = parentBudgetLine.Name + ' allocation is done');
	}

	public void finish(Database.BatchableContext BC) {
		insert new cb5__CBLog__c(Name = 'Salary allocation', cb5__Status__c = 'DONE', cb5__Type__c = 'TASK QUEUE', cb5__Title__c = 'Done', cb5__Description__c = 'SALARY ALLOCATION IS DONE');
	}

}