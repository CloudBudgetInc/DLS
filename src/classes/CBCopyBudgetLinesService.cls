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
public with sharing class CBCopyBudgetLinesService {

	/*public static void copyBudgetLinesToTargetBudgetYear(String baseBYId, String targetBYId, List<cb5__CBBudgetLine__c> budgetLines) {
		List<cb5__CBPeriod__c> basePeriods = [SELECT Id FROM cb5__CBPeriod__c WHERE cb5__CBBudgetYear__c = :baseBYId ORDER BY cb5__Start__c];
		List<cb5__CBPeriod__c> targetPeriods = [SELECT Id FROM cb5__CBPeriod__c WHERE cb5__CBBudgetYear__c = :targetBYId ORDER BY cb5__Start__c];
		Map<Id, Id> periodsMap = new Map<Id, Id>();
		for (Integer i = 0; i < basePeriods.size(); i++) periodsMap.put(basePeriods[i].Id, targetPeriods[i].Id);


	}*/

}