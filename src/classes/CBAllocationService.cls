/** 
Copyright (c) 2022, CloudBudget, Inc.
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


public with sharing class CBAllocationService {

	@AuraEnabled
	public static void generateAllocation(String byId) {
		byId = 'aAQRT000000001d4AA';
		List<cb5__CBBudgetLine__c> sourceBudgetLines = CBSourceBudgetLineSelector.getBudgetLines(byId);
		Map<String, Map<Id, Decimal>> depTotalAmountsMap = new Map<String, Map<Id, Decimal>>();
		for (cb5__CBBudgetLine__c bl : sourceBudgetLines) {
			Map<Id, Decimal> amounts = depTotalAmountsMap.get(bl.cb5__CBVariable1__c);
			if (amounts == null) {
				amounts = new Map<Id, Decimal>();
				depTotalAmountsMap.put(bl.cb5__CBVariable1__c, amounts);
			}
			for (cb5__CBAmount__c a : bl.cb5__CBAmounts__r) {
				Decimal oldValue = amounts.get(a.cb5__CBPeriod__c);
				if (oldValue == null) oldValue = 0;
				amounts.put(a.cb5__CBPeriod__c, oldValue + a.cb5__Value__c);
			}
		}
		Map<Id, Decimal> totalByMonthMap = new Map<Id, Decimal>();
		System.debug('depTotalAmountsMap size = ' + depTotalAmountsMap.size());
		for (Map<Id, Decimal> depValuesByMonth : depTotalAmountsMap.values()) {
			for (Id perId : depValuesByMonth.keySet()) {

				Decimal oldValue = totalByMonthMap.get(perId);
				Decimal newValue = depValuesByMonth.get(perId);
				System.debug('PerId = ' + perId + ' old=' + oldValue + ' new =' + newValue);
				if (oldValue == null) oldValue = 0;
				if (newValue == null) newValue = 0;
				totalByMonthMap.put(perId, oldValue + newValue);
			}
		}

		System.debug(depTotalAmountsMap);
		System.debug(totalByMonthMap.size());
		System.debug(totalByMonthMap);


	}

}